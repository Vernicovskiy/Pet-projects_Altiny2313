/*
РАБОТА С LCD МОДУЛЕМ ТИПА HD44780

Микроконтроллер:	ATtiny2313
Тактовая частота:	8 MHz
*/
.include "tn2313def.inc"
	
;### ОПРЕДЕЛЕНИЕ ВЫВОДОВ ###
.equ	PORT_LCD	=PORTB		;ПОРТ ДЛЯ LCD-ИНДИКАТОРА
.equ	DDR_LCD		=DDRB		;ПОРТ DDR ДЛЯ LCD-ИНДИКАТОРА
.equ	RS			=2			;вывод индикатора  RS  (Команда(0)/Данные(1))
.equ	E			=3			;вывод индикатора  E   (Строб записи. Активное изменение с 1 на 0)
.equ	LCD_D4		=4			;вывод индикатора  D4  
.equ	LCD_D5		=5			;вывод индикатора  D5
.equ	LCD_D6		=6			;вывод индикатора  D6
.equ	LCD_D7		=7			;вывод индикатора  D7
;ВАЖНОЕ ЗАМЕЧАНИЕ: НА ВЫВОДЕ ИНДИКАТОРА RW (ЧТЕНИЕ/ЗАПИСЬ) ДОЛЖЕН БЫТЬ НИЗКИЙ УРОВЕНЬ (ЗАПИСЬ) 

;### ВЫБОР КОНСТАНТЫ ВРЕМЕННОЙ ЗАДЕРЖКИ ###
;Для  1  MHz	 10
;Для  4  MHz	 25
;Для  8  MHz	 50
;Для 16  MHz	100
.equ	Const_Delay_LCD		=50

.def	temp	=R16
.def	loop	=R17

.cseg	
.org	0x00
		rjmp	init

.org	0x20
init:	ldi		temp,RAMEND
		out		SPL,temp

		rcall	Init_HD44780	;Инициализация индикатора. Инициализация выводов под индикатор
	;	rcall	Init_HD44780_Prot

MAIN:	ldi		temp,0x30	;0
		rcall	jedat
		ldi		temp,0x31	;1
		rcall	jedat
;В символьной таблице индикаторов первые 128 ячеек, 
;в большинстве своем, совпадают с таблицей ASCII-символов.
;Поэтому на индикатор можно выводить основные ASCII символы.
		ldi		temp,'2'	;2
		rcall	jedat
		ldi		temp,3		;3
		rcall	jedat30		;Команда jedat30 выводит символы начиная с адреса 0x30 (начало числового ряда)
		ldi		temp,'!'	;!
		rcall	jedat
		ldi		temp,'.'	;Точка
		rcall	jedat
		ldi		temp,'*'	;*
		rcall	jedat
		ldi		temp,' '	;Пробел
		rcall	jedat
		ldi		temp,'A'	;A
		rcall	jedat
		ldi		temp,'b'	;b
		rcall	jedat
		
		ldi		temp,(15 + 0x80);15 + 0x80 =15 + 128 = 143		(0x80 = 0b10000000, 7-й бит в 1, следовательно, запись адреса DDRAM)
								;Команда перехода на 16-ое знакоместо первой строки, т.к. отсчет знакомест идет от нулевого адреса
		rcall	jecom
		ldi		temp,'2'	;2
		rcall	jedat
		ldi		temp,'3'	;3
		rcall	jedat
		ldi		temp,'4'	;4
		rcall	jedat
		ldi		temp,'5'	;5
		rcall	jedat

		ldi		temp,(0 + 0xC0)	;0 + 0x40 + 0x80 = 0 + 0xC0 = 192
								;Команда перехода на 1-ое знакоместо второй строки
		rcall	jecom

		ldi		temp,'H'	
		rcall	jedat
		ldi		temp,'I'
		rcall	jedat
		ldi		temp,'!'
		rcall	jedat

		ldi		temp,' '	;Пробел
		rcall	jedat

		ldi		temp,0xA8	;П
		rcall	jedat
		ldi		temp,0x70	;р
		rcall	jedat
		ldi		temp,0xB8	;и
		rcall	jedat
		ldi		temp,0xB3	;в
		rcall	jedat
		ldi		temp,0x65	;е
		rcall	jedat
		ldi		temp,0xBF	;т
		rcall	jedat

		rjmp	PC			;Зацикливаем программу

;####  ИНИЦИАЛИЗАЦИЯ ВЫВОДОВ, ИНИЦИАЛИЗАЦИЯ МОДУЛЯ LCD ####
Init_HD44780:  
		sbi		DDR_LCD,E		;Настройка выводов на выход
		sbi		DDR_LCD,RS
		sbi		DDR_LCD,LCD_D4
		sbi		DDR_LCD,LCD_D5
		sbi		DDR_LCD,LCD_D6
		sbi		DDR_LCD,LCD_D7
		rcall   delay_LCD_44780
		ldi     temp,0b00000011	;Установка дисплея в начальное положение. Возврат курсора
		rcall   jecom
		ldi     temp,0b00000011	;Установка дисплея в начальное положение. Возврат курсора
    	rcall   jecom
		ldi     temp,0b00000011	;Установка дисплея в начальное положение. Возврат курсора
    	rcall   jecom	
	    ldi     temp,0b00101000	;Параметры интерфейса: Разрядность 4 бита. 2 строки. Размер шрифта 5х7
		rcall   jecom
        ldi     temp,0b00101000	;Параметры интерфейса: Разрядность 4 бита. 2 строки. Размер шрифта 5х7
		rcall   jecom
        ldi     temp,0b00001000	;Выключение дисплея
		rcall   jecom	           
		ldi     temp,0b00000001	;Стирание дисплея
		rcall   jecom
		ldi     temp,0b00010000 ;Запрет сдвига изображения
		rcall   jecom	
		ldi     temp,0b00000110 ;Автосмещение курсора вправо, после записи
		rcall   jecom	
		ldi     temp,0b00000010 ;Установка дисплея в начальное положение. Возврат курсора
		rcall   jecom
		ldi     temp,0b00101000	;Параметры интерфейса: Разрядность 4 бита. 2 строки. Размер шрифта 5х7
		rcall   jecom				
        ldi     temp,0b00001100	;Включение дисплея. Запрет видимости курсора. Запрет мерцания курсора
		rcall   jecom
		ret
		
;####  ИНИЦИАЛИЗАЦИЯ ДЛЯ PROTEUS ####
Init_HD44780_Prot:
		sbi		DDR_LCD,E
		sbi		DDR_LCD,RS
		sbi		DDR_LCD,LCD_D4
		sbi		DDR_LCD,LCD_D5
		sbi		DDR_LCD,LCD_D6
		sbi		DDR_LCD,LCD_D7
		ldi		temp,0b00000010 ;Установка дисплея в начальное положение. Возврат курсора
		rcall   jecom
		ldi		temp,0b00101000	;Параметры интерфейса: Разрядность 4 бита. 2 строки. Размер шрифта 5х7
		rcall   jecom
		ldi		temp,0b00001100	;Включение дисплея. Запрет видимости курсора. Запрет мерцания курсора
		rcall   jecom	
		ret
		
;#### ВЫВОД ДАННЫХ С АДРЕСА 0х30 ####
jedat30:subi    temp,-0x30		;Вывод данных начиная с адреса 0x30. По этому адресу распологается начало числового ряда
;#### ВЫВОД ДАННЫХ ####
jedat:	sbi		PORT_LCD,RS		;Для вывода данных RS = 1
		rjmp	PC+2
;#### ВЫВОД КОМАНДЫ ####
jecom:  cbi		PORT_LCD,RS		;Для вывода команды RS = 0
;### ВЫВОД БАЙТА В ПОРТ ###
		rcall	outLCD			;Выводим старшую тетраду в порт
        swap    temp			;Меняем тетрады местами
		rcall	outLCD			;Выводим младшую тетраду в порт
		rcall	delay_LCD_44780	;Задержка 6,5 мс
		ret

;#### ВЫВОД ТЕТРАДЫ В ПОРТ ####	
outLCD:	cbi		PORT_LCD,LCD_D4	;Сбрасываем вывод D4
		cbi		PORT_LCD,LCD_D5	;Сбрасываем вывод D5
		cbi		PORT_LCD,LCD_D6	;Сбрасываем вывод D6
		cbi		PORT_LCD,LCD_D7	;Сбрасываем вывод D7
		sbrc	temp,4			;Пропускаем следующую строку, если 4-й разряд = 0
		sbi		PORT_LCD,LCD_D4	;Устанавливаем в 1 разряд D4
		sbrc	temp,5			;Пропускаем следующую строку, если 5-й разряд = 0
		sbi		PORT_LCD,LCD_D5	;Устанавливаем в 1 разряд D5
		sbrc	temp,6			;Пропускаем следующую строку, если 6-й разряд = 0
		sbi		PORT_LCD,LCD_D6	;Устанавливаем в 1 разряд D6
		sbrc	temp,7			;Пропускаем следующую строку, если 7-й разряд = 0
		sbi		PORT_LCD,LCD_D7	;Устанавливаем в 1 разряд D7
		sbi     PORT_LCD,E		;Импульс на выводе "Е" записывает тетраду в LCD
		nop
        cbi     PORT_LCD,E
		ret
		
;#### ВРЕМЕННАЯ ЗАДЕРЖКА ####
;Задержка по времени должна составлять 6,5 мс
delay_LCD_44780:
		push	temp
		ldi     temp,Const_Delay_LCD
dlylcd:	ldi		loop,25
		dec		loop
		brne	PC-1
		dec		temp
		brne	dlylcd
		pop		temp
		ret

