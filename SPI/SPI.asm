/*
 ПРОГРАММНАЯ ЭМУЛЯЦИЯ ПРОТОКОЛА SPI
 Микроконтроллер выступает в роли Master-устройства
 Взаимодействие осуществляется с одним Slave-устройством
*/ 
.include "tn2313def.inc"

;### ОПРЕДЕЛЕНИЕ ПОРТА ПОД SPI ###
.equ	PORT_SPI	=PORTB
.equ	DDR_SPI		=DDRB
.equ	PIN_SPI		=PINB

;### ОПРЕДЕЛЕНИЕ ВЫВОДОВ ПОД SPI ###
.equ	CS			=PB0
.equ	MOSI		=PB1
.equ	MISO		=PB2
.equ	SCK			=PB3

.def	temp		=R16
.def	loop		=R17	

.cseg
.org	0x00
		rjmp	start

.org	0x20
start:		ldi		temp,RAMEND
			out		SPL,temp

;### ИНИЦИАЛИЗАЦИЯ ВЫВОДОВ SPI ###
			sbi		DDR_SPI,CS		;CS на выход
			sbi		DDR_SPI,MOSI	;MOSI на выход
			sbi		DDR_SPI,SCK		;SCK на выход
			cbi		DDR_SPI,MISO	;MISO на вход
			
			sbi		PORT_SPI,CS		;Запрет на работу Slave-устройства


;### ОСНОВНОЙ ЦИКЛ ###
main:		cbi		PORT_SPI,SCK	;Для режима 0 на выводе SCK должен быть изначально низкий уровень
			ldi		temp,0xAA
			cbi		PORT_SPI,CS		;Активация Slave-устройства
			rcall	SPI_RW0			;Режим 0
			sbi		PORT_SPI,CS		;Запрет на работу Slave-устройства


			sbi		PORT_SPI,SCK	;Для режима 1 на выводе SCK должен быть изначально высокий уровень
			cbi		PORT_SPI,CS		;Активация Slave-устройства
			ldi		temp,0xAA
			rcall	SPI_RW1			;Режим 1
			sbi		PORT_SPI,CS		;Запрет на работу Slave-устройства


			cbi		PORT_SPI,SCK	;Для режима 2 на выводе SCK должен быть изначально низкий уровень
			ldi		temp,0xAA
			cbi		PORT_SPI,CS		;Активация Slave-устройства
			rcall	SPI_RW2			;Режим 2
			sbi		PORT_SPI,CS		;Запрет на работу Slave-устройства


			sbi		PORT_SPI,SCK	;Для режима 3 на выводе SCK должен быть изначально высокий уровень
			ldi		temp,0xAA
			cbi		PORT_SPI,CS		;Активация Slave-устройства
			rcall	SPI_RW3			;Режим 3
			sbi		PORT_SPI,CS		;Запрет на работу Slave-устройства
			rjmp	main


;#### ПРИЕМ/ПЕРЕДАЧА БАЙТА РЕЖИМ 0. СТАРШИЙ БИТ ПЕРВЫЙ ####
SPI_RW0:	ldi		loop,8			;Загружаем счетчик разрядов
			rol		temp			;Сдвигаем содержимое temp влево. Старший бит в С
		;	ror		temp			;Сдвигаем содержимое temp вправо. Младший бит в С
spi0_loop:	brcs	MOSI0_1			;Переход на MOSI_1, если С=1
MOSI0_0:	cbi		PORT_SPI,MOSI	;Сброс MOSI
			rjmp	rx0_bit
MOSI0_1:	sbi		PORT_SPI,MOSI	;Установка MOSI
rx0_bit:	nop						;Небольшая задержка перед тактовым импульсом
			sbi		PORT_SPI,SCK	;Положительный перепад тактового импульса (считывание)
			sec
			sbis	PIN_SPI,MISO	;Считывание сотояния линии MISO
			clc
			rol		temp			;Сдвигаем считанный бит в младший разряд регистра temp
		;	ror		temp			;Сдвигаем считанный бит в старший разряд регистра temp
			cbi		PORT_SPI,SCK	;Отрицательный перепад тактового импульса (смена значения)
			dec		loop			;Уменьшаем счетчик битов
			brne	spi0_loop		;Проверка на последний бит
			ret
			
;Альтернативный вариант установки значения MOSI
;spi0_loop:	cbi		PORT_SPI,MOSI	
;			brcс	PC+2			;Пропуск установки MOSI, если С=0
;			sbi		PORT_SPI,MOSI

;#### ПРИЕМ/ПЕРЕДАЧА БАЙТА РЕЖИМ 1. СТАРШИЙ БИТ ПЕРВЫЙ ####
SPI_RW1:	ldi		loop,8			;Загружаем счетчик разрядов
			rol		temp			;Сдвигаем содержимое temp влево. Старший бит в С
		;	ror		temp			;Сдвигаем содержимое temp вправо. Младший бит в С
spi1_loop:	sbi		PORT_SPI,SCK	;Положительный перепад тактового импульса (смена значения)
			brcs	MOSI1_1			;Переход на MOSI_1, если С=1
MOSI1_0:	cbi		PORT_SPI,MOSI	;Сброс MOSI
			rjmp	rx1_bit
MOSI1_1:	sbi		PORT_SPI,MOSI	;Установка MOSI
rx1_bit:	nop						;Небольшая задержка перед тактовым импульсом
			cbi		PORT_SPI,SCK	;Отрицательный перепад тактового импульса (считывание)
			sec
			sbis	PIN_SPI,MISO	;Считывание сотояния линии MISO
			clc
			rol		temp			;Сдвигаем считанный бит в младший разряд регистра temp
		;	ror		temp			;Сдвигаем считанный бит в старший разряд регистра temp
			dec		loop			;Уменьшаем счетчик битов
			brne	spi1_loop		;Проверка на последний бит
			ret

;#### ПРИЕМ/ПЕРЕДАЧА БАЙТА РЕЖИМ 2. СТАРШИЙ БИТ ПЕРВЫЙ ####
SPI_RW2:	ldi		loop,8			;Загружаем счетчик разрядов
			rol		temp			;Сдвигаем содержимое temp влево. Старший бит в С
		;	ror		temp			;Сдвигаем содержимое temp вправо. Младший бит в С
spi2_loop:	brcs	MOSI2_1			;Переход на MOSI_1, если С=1
MOSI2_0:	cbi		PORT_SPI,MOSI	;Сброс MOSI
			rjmp	rx2_bit
MOSI2_1:	sbi		PORT_SPI,MOSI	;Установка MOSI
rx2_bit:	nop						;Небольшая задержка перед тактовым импульсом
			cbi		PORT_SPI,SCK	;Отрицательный перепад тактового импульса (считывание)
			sec
			sbis	PIN_SPI,MISO	;Считывание сотояния линии MISO
			clc
			rol		temp			;Сдвигаем считанный бит в младший разряд регистра temp
		;	ror		temp			;Сдвигаем считанный бит в старший разряд регистра temp
			sbi		PORT_SPI,SCK	;Положительный перепад тактового импульса (смена значения)
			dec		loop			;Уменьшаем счетчик битов
			brne	spi2_loop		;Проверка на последний бит
			ret

;#### ПРИЕМ/ПЕРЕДАЧА БАЙТА РЕЖИМ 3. СТАРШИЙ БИТ ПЕРВЫЙ ####
SPI_RW3:	ldi		loop,8			;Загружаем счетчик разрядов
			rol		temp			;Сдвигаем содержимое temp влево. Старший бит в С
		;	ror		temp			;Сдвигаем содержимое temp вправо. Младший бит в С
spi3_loop:	cbi		PORT_SPI,SCK	;Отрицательный перепад тактового импульса (смена значения)
			brcs	MOSI3_1			;Переход на MOSI_1, если С=1
MOSI3_0:	cbi		PORT_SPI,MOSI	;Сброс MOSI
			rjmp	rx3_bit
MOSI3_1:	sbi		PORT_SPI,MOSI	;Установка MOSI
rx3_bit:	nop						;Небольшая задержка перед тактовым импульсом
			sbi		PORT_SPI,SCK	;Положительный перепад тактового импульса (считывание)
			sec
			sbis	PIN_SPI,MISO	;Считывание сотояния линии MISO
			clc
			rol		temp			;Сдвигаем считанный бит в младший разряд регистра temp
		;	ror		temp			;Сдвигаем считанный бит в старший разряд регистра temp
			dec		loop			;Уменьшаем счетчик битов
			brne	spi3_loop		;Проверка на последний бит
			ret
