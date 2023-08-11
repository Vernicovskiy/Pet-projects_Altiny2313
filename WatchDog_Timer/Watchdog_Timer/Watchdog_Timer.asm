;#### ИСПОЛЬЗОВАНИЕ РАСШИРЕННОГО СТОРОЖЕВОГО ТАЙМЕРА #### 
;Если программирование внутрисхемное, то для чистоты экспериментов
;рекомендуется после каждого программирования отключать питание

.include "tn2313def.inc"

.def	temp		=R16


.equ	DDR_VD		=DDRD					;Порт для подключения сигнальных светодиодов
.equ	PORT_VD		=PORTD					;Порт для подключения сигнальных светодиодов
.equ	Pr_Lck		=1						;Сигнал "Программа заблокирована"
.equ	WD_int		=0						;Сигнал "Прерывание WatchDog-таймера"
	

.equ	DDR_SB		=DDRB					;Порт для подключения кнопок
.equ	PORT_SB		=PORTB					;Порт для подключения кнопок
.equ	PIN_SB		=PINB					;Порт для подключения кнопок
.equ	SB_Lck		=7						;Кнопка блокировки программы
.equ	SB_WDof		=0						;Кнопка отключение WatchDog-таймера


.cseg	
.org	0x00
		rjmp	start


.org	0x12
		rjmp	WatchDog					;Вектор прерывания WatchDog-таймера


start:	ldi		temp,RAMEND
		out		SPL,temp
		
		cbi		DDR_SB,SB_Lck				;Вывод кнопки SB_Lck на вход
		cbi		DDR_SB,SB_WDof				;Вывод кнопки SB_WDof на вход
		sbi		PORT_SB,SB_Lck				;Включение подтягивающего резистора 
		sbi		PORT_SB,SB_WDof				;Включение подтягивающего резистора

		sbi		DDR_VD,WD_int				;Вывод сигнала WD_int на выход
		sbi		DDR_VD,Pr_Lck				;Вывод сигнала Pr_Lck на выход
		cbi		PORT_VD,WD_int				;Гашение светодиода "Прерывание WatchDog-таймера"
		cbi		PORT_VD,Pr_Lck				;Гашение светодиода "Программа заблокирована"


;			ПЕРИОД ПЕРЕПОЛНЕНИЯ ТАЙМЕРА 2 СЕКУНДЫ


;			Переполнение - ПРЕРЫВАНИЕ	(Прерывание WDIE = 1)			
			ldi		temp,(1<<WDIE|0<<WDP3|1<<WDP2|1<<WDP1|1<<WDP0)


;			Переполнение - СБРОС	(Сброс WDE = 1)
		;	ldi		temp,(1<<WDE|0<<WDP3|1<<WDP2|1<<WDP1|1<<WDP0)


;			Переполнение - ПРЕРЫВАНИЕ. Повторное переполнение - СБРОС	(Сброс WDIE = 1, Прерывание WDE = 1)
		;	ldi		temp,(1<<WDE|1<<WDIE|0<<WDP3|1<<WDP2|1<<WDP1|1<<WDP0)


			out		WDTCSR,temp				;Запись в регистр конфигурации WatchDog


			sei								;Разрешение прерывания WatchDog-таймера


main:		wdr								;Команда сброса сторожевого таймера
			sbis	PINB,SB_Lck				;Проверка кнопки
			rjmp	Lock					;Переход к зацикливанию программы
			sbis	PINB,SB_WDof			;Проверка кнопки
			rjmp	WD_OFF					;Отключение Watchdog-таймера
			rjmp	main	


;			ЗАЦИКЛИВАНИЕ ПРОГРАММЫ
Lock:		sbi		PORTD,Pr_Lck			;Включение светодиода Pr_Lck (Программа заблокирована)
			rjmp	PC						;Зацикливание программы


;			ВЫКЛЮЧЕНИЕ СТОРОЖЕВОГО ТАЙМЕРА
WD_OFF:		clr		temp					;Обязательная очистка бита WDRF регистра MCUSR
			out		MCUSR,temp
			ldi		temp,(1<<WDE|1<<WDCE)	;Запись в WDE и WDCE логической 1
			out		WDTCSR,temp
			ldi		temp,0					;В течение следующих 4 тактов в WDE записать ноль
			out		WDTCSR,temp
	;		clr		temp					;Если таймер работает в только режиме прерывания, 
	;		out		WDTCSR,temp				;то для отклчения watchdog достаточно просто очистить бит WDIE
			rjmp	main					;После выключения - на основной цикл


;			ПРЕРЫВАНИЕ ОТ СТОРОЖЕВОГО ТАЙМЕРА
WatchDog:	sbi		PORTD,WD_int			;Включение светодиода WD_int (Прерывание WatchDog-таймера)
			cbi		PORTD,Pr_Lck			;ВЫключение светодиода Pr_Lck (Программа заблокирована)
			reti
			
