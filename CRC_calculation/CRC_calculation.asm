/* 	ПРОГРАММА РАСЧЕТА КОНТРОЛЬНОЙ СУММЫ (CRC - Cyclic Redundancy Check, Циклический избыточный код)
Программа производит подсчет контрольной суммы принятых байт

Подсчет производится либо для байт ID-кода (для любой мкс имеющей ID), либо для байт блокнотной памяти (только для DS18B20)
Перед считыванием байт блокнотной памяти, производится запуск процесса преобразования температуры.

Вывод данных производится на индикатор типа HD44780

Перед использованием программы произвести настройку библиотек MicroLan.inc и HD44780.inc

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
main:			rcall	CRC_Scratchpad		;Подсчет CRC для байт блокнотной памяти (только для DS18B20)
			;	rcall	CRC_ROM				;Подсчет CRC для байт ID-кода
				rjmp	main




;#### ПОДСЧЕТ CRC ДЛЯ 7 БАЙТ (56 БИТ) ID-КОДА ####
CRC_ROM:		rcall	resLAN
				ldi		R16,0x33			;Команда "Чтение ПЗУ"
				rcall	wr8LAN	

				clr		ZH
				ldi		ZL,0x60				;Загрузка в регистр Z начало расположения в памяти данных байт данных

				First_Line					;Переход на первую строку индикатора

				rcall	rd8LAN				;БАЙТ 0 ID-кода
				st		Z+,temp
				rcall	PrHEX
				
				rcall	rd8LAN				;БАЙТ 1 ID-кода
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 2 ID-кода
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 3	ID-кода
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 4 ID-кода
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 5 ID-кода
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 6 ID-кода
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 7 ID-кода
				st		Z+,temp
				rcall	PrHEX

				Second_Line					;Переход на вторую строку индикатора
				
				dat		'-'

				clr		ZH
				ldi		ZL,0x60				;Загрузка в регистр Z начало расположения в памяти данных байт данных
				
				rcall	Checksum			;Вызов подпрограммы расчета контрольной суммы
				rcall	PrHEX				;Печать байта CRC

				ret






;#### ПОДСЧЕТ CRC ДЛЯ 8 БАЙТ (64 БИТ) БЛОКНОТНОЙ ПАМЯТИ ####
CRC_Scratchpad:	rcall	Meas_DS1820			;Запуск процесса измерения температуры

				rcall	resLAN
				ldi		R16,0xCC			;Команда "Пропуск ПЗУ"
				rcall	wr8LAN
				ldi		R16,0xBE			;Команда "Чтение 9 байт блокнотной памяти"
				rcall	wr8LAN	
				
				clr		ZH
				ldi		ZL,0x60				;Загрузка в регистр Z начало расположения в памяти данных байт данных
				
				First_Line					;Переход на первую строку индикатора

				rcall	rd8LAN				;БАЙТ 0 Младший байт температуры
				st		Z+,temp
				rcall	PrHEX
				
				rcall	rd8LAN				;БАЙТ 1 Старший байт температуры
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 2 Регистр ТН
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 3	Регистр ТL
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 4 Регистр конфигурации
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 5 Резерв
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;БАЙТ 6 Резерв
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;БАЙТ 7 Резерв
				st		Z+,temp
				rcall	PrHEX

				Second_Line					;Переход на вторую строку индикатора

				rcall	rd8LAN				;БАЙТ 8 Контрольная сумма CRC
				st		Z+,temp
				rcall	PrHEX
				
				dat		'-'
				
				clr		ZH
				ldi		ZL,0x60				;Загрузка в регистр Z начало расположения в памяти данных байт данных
				
				rcall	Checksum			;Вызов подпрограммы расчета контрольной суммы
				rcall	PrHEX				;Печать байта CRC
				
				ret


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
Power_Action:	Wire_UP_Power				;Активная подтяжка к напряжению питания
				ldi		ZH,high(0x0430)
				ldi		ZL,low (0x0430)
Nxt_Pow_Delay:	rcall	delay_700_us		;Задержка 700 мкс
				Check_Lan					;Считывание вывода
				brcc	Sh_Circ				;Если на выводе ноль, то вывод закорочен на общий проводник
				sbiw	ZL:ZH,1
				brne	Nxt_Pow_Delay
Sh_Circ:		Wire_UP						;Отключение силового уровня питания датчика 
				ret
		

		





/*################################################################################						
						ПОДСЧЕТ КОНТРОЛЬНОЙ СУММЫ
			
Исходные байты должны быть записаны подряд в ячейках памяти данных, начиная с 
МЛАДШЕГО байта. До выполнения Сhecksum адрес расположения младшего байта должен 
быть загружен в регистр Z. Если в подсчете CRC присутствует байт CRC, то после 
выполнения Сhecksum в регистре R16 будет 0.

								! ВНИМАНИЕ ! 
После выполнения Сhecksum данные в указаных ячейках памяти будут ПОТЕРЯНЫ !
################################################################################*/

Checksum:	ldi		R18,(8*9)		;Записать количество бит (8*байт) по которым идет подсчет CRC
			clr		R16				;Обнуление регистра R16
Nxt_Shift:	
.macro		Shift_R					;Макрос сдвига ячейки памяти вправо на 1 бит, через флаг переноса
			ldd		R17,Z+@0
			ror		R17
			std		Z+@0,R17
.endm
			Shift_R	8				;Сдвиг 9 ячеек памяти данных на 1 бит вправо
			Shift_R	7				
			Shift_R	6
			Shift_R	5
			Shift_R	4
			Shift_R	3
			Shift_R	2
			Shift_R	1
			Shift_R	0
			ldi		R17,0b10000000	;Константа для инвертирования флага С (сдвинутого в 7-й бит R16)
			ror		R16				;Сдвиг бита С в 7-й разряд, 0-й разряд сдвигается в бит С
			brcc	PC+2			;Если нулевой разряд R16 равен 1, 
			eor		R16,R17			;то инвертируем старший разряд (флаг С)
			ldi		R17,0b00001100	;Константа для инвертирования 2 и 3 битов (3 и 4 до сдвига R16)
			sbrc	R16,7			;Если седьмой разряд (флаг С после "исключающего или" между С и 0-м битом R16) равен 1,
			eor		R16,R17			;то инвертируем 2 и 3 разряды (3 и 4 до сдвига R16)
			dec		R18				;Уменьшаем счетчик
			brne	Nxt_Shift
			tst		R16				;Проверка R16 на нулевое значение (R16=0 при подсчете CRC вместе с байтом CRC)
			ret
