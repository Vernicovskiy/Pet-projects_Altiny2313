/* 	*Запуск процесса измерения температуры и последующее 
	 считывание 9 байтов блокнотной памяти из DS18B20
	*На линии должен находиться только один датчик DS18B20
	*Программа расчитана на паразитное питание датчика
	*Все 9 байт выводятся на 2-строчный 16-символьный индикатор типа HD44780

	*Перед использованием программы произвести настройку библиотек MicroLan.inc и HD44780.inc

Микроконтроллер		ATtiny2313
Тактовая частота	8 MHz
Индикатор			2-строчный 16-символьный типа HD44780
*/

.include "tn2313def.inc"

.def	temp	=R16

.cseg			rjmp	start

.include "MicroLan.inc"						;БИБЛИОТЕКА ПРОТОКОЛА 1-WIRE
.include "HD44780.inc"						;БИБЛИОТЕКА HD4780


start:			ldi		temp,RAMEND
				out		SPL,temp


				Init_HD44780				;Инициализация индикатора

;#### ОСНОВНОЙ ЦИКЛ ####
main:			rcall	Meas_DS1820			;Запуск процесса измерения температуры

				rcall	resLAN
				ldi		R16,0xCC			;Команда "Пропуск ПЗУ"
				rcall	wr8LAN
				ldi		R16,0xBE			;Команда "Чтение 9 байт блокнотной памяти"
				rcall	wr8LAN	
				
				First_Line					;Переход на первую строку индикатора

				rcall	rd8LAN				;БАЙТ 0 Младший байт температуры
				rcall	PrHEX
				
				rcall	rd8LAN				;БАЙТ 1 Старший байт температуры
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 2 Регистр ТН
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 3	Регистр ТL
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 4 Регистр конфигурации
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 5 Резерв
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 6 Резерв
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 7 Резерв
				rcall	PrHEX

				Second_Line					;Переход на вторую строку индикатора

				rcall	rd8LAN				;БАЙТ 8 Контрольная сумма CRC
				rcall	PrHEX

				rjmp	main


;#### ЗАПУСК ИЗМЕРЕНИЯ ТЕМПЕРАТУРЫ ####
Meas_DS1820:	rcall	resLAN
				brne	Error_meas_t		;Проверка на отсутствие датчиков на линии
				ldi		temp,0xCC			;Пропуск ПЗУ
				rcall	wr8LAN
				ldi		temp,0x44			;Запуск преобразования
				rcall	wr8LAN	
				rcall	Power_Action		;Активная подтяжка к напряжению питания в течение 750 мс 
Error_meas_t:	ret


;#### ВЫДАЧА ПИТАНИЯ НА ЛИНИЮ В ТЕЧЕНИЕ 750 МС ####
;Константы задержек для частоты 8 MHz:
.equ	D_750	=0x0430		;750 мс
.equ	D_700	=0x03E8		;700 мс
.equ	D_650	=0x03A1		;650 мс
.equ	D_600	=0x0359		;600 мс

.equ	DL		=D_700
Power_Action:	Wire_UP_Power				;Активная подтяжка к напряжению питания
				ldi		ZH,high(DL)
				ldi		ZL,low (DL)
Nxt_Pow_Delay:	rcall	delay_700_us		;Задержка 700 мкс
				Check_Lan					;Считывание вывода
				brcc	Sh_Circ				;Если на выводе ноль, то вывод закорочен на общий проводник
				sbiw	ZL:ZH,1
				brne	Nxt_Pow_Delay
Sh_Circ:		Wire_UP						;Отключение силового уровня питания датчика 
				ret
		


