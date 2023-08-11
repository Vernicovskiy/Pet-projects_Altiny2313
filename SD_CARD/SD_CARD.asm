/* 
ДЕМОНСТРАЦИОННАЯ ПРОГРАММА ДЛЯ ЧТЕНИЯ И ЗАПИСИ SD-КАРТ
Программа работает только с картами, поддерживающими обмен по SPI
Поддерживаемые карты: SD, microSD, SDHC, microSDHC
Карты, которые не тестировались на работоспособность: SDXC, microSDXC, MMC, RS-MMC 

ИСПОЛЬЗУЕТСЯ ПРОГРАММНАЯ ЭМУЛЯЦИЯ ПРОТОКОЛА SPI: РЕЖИМ 0, ПЕРЕДАЧА СТАРШИМ БИТОМ ВПЕРЕД

Чтение и запись карт производиться секторами размером в 512 байт

Команды на чтение м запись передаются через USART
Вывод прочитанных данных производиться через USART

Микроконтроллер		ATtiny2313
Тактовая частота 	8 MHz (внешний кварцевый резанатор)
Скорость USART		9600
Четность			Нет
Кол-во стоп бит		1
*/ 
.include "tn2313def.inc"


;Порт для подключения SD-карты:
.equ	PORT_SD		=PORTB
.equ	DDR_SD		=DDRB
.equ	PIN_SD		=PINB

;Выводы порта для подключения SD-карты:
.equ	CS			=PB0
.equ	MOSI		=PB1
.equ	MISO		=PB2
.equ	SCK			=PB3

;Рабочие регистры:
.def	temp		=R16
.def	loop		=R17

;Регистры для хранения аргумента команды
.def	SDmemLL		=R1		;0-й байт аргумента (передается последним)
.def	SDmemLH		=R2		;1-й байт аргумента
.def	SDmemHL		=R3		;2-й байт аргумента
.def	SDmemHH		=R4		;3-й байт аргумента (передается первым)

;Настройка параметров связи
.equ	XTALL		=8000000				;Тактовая частота микроконтроллера
.equ	BAUD		=9600					;Скорость обмена данными
.equ	SPEED		=(XTALL/(16*BAUD))-1	;Константа для регистра UBRR


;МАКРОС ЗАГРУЗКИ В РЕГИСТРЫ 32-БИТНОГО АРГУМЕНТА (АДРЕС СЕКТОРА ДЛЯ SDНС-КАРТ):
.macro	arg						
		push	R16
		ldi		R16,byte1(@0)
		mov		SDmemLL,R16
		ldi		R16,byte2(@0)
		mov		SDmemLH,R16
		ldi		R16,byte3(@0)
		mov		SDmemHL,R16
		ldi		R16,byte4(@0)
		mov		SDmemHH,R16
		pop		R16
.endm

;МАКРОС ЗАГРУЗКИ В РЕГИСТРЫ 32-БИТНОГО АДРЕСА СЕКТОРА (ДЛЯ SD-КАРТ):
.macro	sector					
		push	R16
		ldi		R16,byte1(@0*512)	;Число домножаем на 512
		mov		SDmemLL,R16
		ldi		R16,byte2(@0*512)
		mov		SDmemLH,R16
		ldi		R16,byte3(@0*512)
		mov		SDmemHL,R16
		ldi		R16,byte4(@0*512)
		mov		SDmemHH,R16
		pop		R16
.endm


.cseg
.org	0x00
		rjmp	start

.org	0x20
start:	ldi		temp,RAMEND
		out		SPL,temp

		ldi		temp,(1<<RXEN|1<<TXEN)		;Настройка USART
		out		UCSRB,temp
		ldi		temp,(1<<UCSZ1|1<<UCSZ0)
		out		UCSRC,temp
		ldi		temp,high(SPEED)
		out		UBRRH,temp
		ldi		temp,low(SPEED)
		out		UBRRL,temp

		
;******************************* ОСНОВНОЙ ЦИКЛ *********************************************
MAIN:	;	rcall	in_com		;Тест СОМ-порта
		;	inc		temp	
		;	rcall	out_com
		;	rjmp	PC-3

			rcall	in_com		;Ожидание поступления команды на инициализацию
		
			rcall	SD_init		;Инициализация карты 
								;В ответ через USART будет получено 2 байта: 0x01,0х01 или 0x01,0х05
			rcall	in_com		;Ожидание поступления команды на запись/чтение сектора

;####################################################################
;############ Для карт SD (карт с побайтовой адресацией) ############
;####################################################################
			arg		(512*2)		;Запись во 2 сектор (адрес в байтах 512*2 = 1024)
			rcall	Write_SD
			arg		(512*2)		;Чтение из 2 сектора (адрес в байтах 512*2 = 1024)
			rcall	Read_SD

		rcall	in_com			;ПАУЗА

			sector	10			;Запись в 10 сектор (адрес в байтах 512*10 = 5120)
			rcall	Write_SD
			sector	10			;Чтение из 10 сектора (адрес в байтах 512*10 = 5120)
			rcall	Read_SD
;####################################################################		
			
		rcall	in_com			;ПАУЗА

;####################################################################
;############ Для карт SDHC (карт с посекторной адресацией) #########
;############ Карты SD (с побайтовой адресацией) "зависнут" #########
;####################################################################
			arg		20			
			rcall	Write_SD	;Запись в 20 сектор (для карт с посекторной адресацией)
			arg		20			
			rcall	Read_SD		;Чтение из 20 сектора (для карт с посекторной адресацией)
;####################################################################

			rjmp	MAIN
;******************************************************************************************


	
		;#############################
		;#### ИНИЦИАЛИЗАЦИЯ КАРТЫ ####
		;#############################
SD_init:	sbi		DDR_SD,CS		;Активный уровень Chip Select логический ноль
			sbi		DDR_SD,MOSI		;Вывод Master Output на выход
			sbi		DDR_SD,SCK		;Вывод тактовых импульсов на выход
			cbi		DDR_SD,MISO		;Вывод Master Input на вход
			
			sbi		PORT_SD,MISO	;Подтягивающий резистор MISO включен

			sbi		PORT_SD,CS		;Slave-устройство не активно
			
			rcall	SD_80_clock		;Подготовка к работе. 80 тактов при MOSI=1

			cbi		PORT_SD,CS		;Slave-устройство активно
			
			arg		0x00			;Нулевой аргумент
			ldi		temp,0x40		;Подача команды CMD0 (0x40) для перевода в SPI
			ldi		loop,0x95		;CRC
			rcall	SD_CMD
			rcall	out_com			;Отправка по USART байта отклика. Нормальный отклик 0x01

			arg		0x1AA			;Аргумент 0x1AA
			ldi		temp,0x48		;Команда инициализации 0x48
			ldi		loop,0x87		;CRC 0x87
			rcall	SD_CMD
			rcall	out_com			;Отправка по USART байта отклика. Для новых карт нормальный отклик 0x01

			rcall	SD_80_clock		;Пауза в 80 тактов при MOSI=1

			arg		0x40000000		;Аргумент 0x40000000
Send_Init:	ldi		temp,0x41		;Команда инициализации CMD1 (0х41) с аргументом	0x40000000
			rcall	SD_CMD
			tst		temp			;Проверка отклика, равного нулю
			brne	Send_Init		;Ожидание около 0,1..0,3 сек
			rcall	SPI_Write_FF	;Пауза
			ret


;#### ОТПРАВКА КОМАНДЫ ИЗ 6 БАЙТ. ПРИЕМ 1 БАЙТА ОТКЛИКА ####
;Через temp передается команда. Через loop передается CRC
SD_CMD:		push	temp			;Через регистр temp передается команда
			rcall	SPI_Write_FF	;Пауза
			pop		temp
			rcall	SPI_Write		;Передача команды
			mov		temp,SDmemHH
			rcall	SPI_Write		;3-й байт аргумента
			mov		temp,SDmemHL
			rcall	SPI_Write		;2-й байт аргумента
			mov		temp,SDmemLH
			rcall	SPI_Write		;1-й байт аргумента
			mov		temp,SDmemLL	
			rcall	SPI_Write		;0-й байт аргумента
			mov		temp,loop		;Контрольная сумма CRC
			rcall	SPI_Write		
			rcall	SPI_Write_FF	;Пауза
			rcall	SPI_Read		;Прием байта отклика в регистр temp
			ret
			
						
;#### ПРИЕМ/ПЕРЕДАЧА БАЙТА ЧЕРЕЗ SPI ####
;#### РЕЖИМ 0  СТАРШИЙ БАЙТ - ПЕРВЫЙ ####
;Передаваемый байт в регистре temp, принятый байт в регистре temp
SPI_Write_FF:						;Пауза (передача байта 0xFF)
SPI_Read:	ser		temp			;Чтение байта (передаваемый байт 0xFF)
SPI_Write:	push	loop			;Запись байта (передаваемый байт в регистре temp)
			ldi		loop,8			;Счетчик переданных/принятых битов
			rol		temp			;Сдвиг старшего бита в бит переноса
Nxt_spi_bt:	cbi		PORT_SD,MOSI	;Сброс MOSI если бит равен нулю
			brcc	PC+2
			sbi		PORT_SD,MOSI	;Установка MOSI если бит равен единице
			nop						;Пауза
			sbi		PORT_SD,SCK		;Передний фронт такта
			sec
			sbis	PIN_SD,MISO		;Считывание состояния вывода MISO
			clc
			rol		temp			;Считанное состояние сдвигается в младший бит temp
			cbi		PORT_SD,SCK		;Окончание тактового импульса
			dec		loop
			brne	Nxt_spi_bt
			pop		loop
			ret


;#### 80 ТАКТОВ ПАУЗЫ ####
SD_80_clock:sbi		PORT_SD,MOSI	;Вывод MOSI = 1
			ldi		loop,10				
			rcall	SPI_Write_FF	;Передача 8 тактов
			dec		loop
			brne	PC-2
			ret


;###################################
;#### ЗАПИСЬ СЕКТОРА В 512 БАЙТ ####
;###################################
Write_SD:	ldi		temp,0x58		;Команда на запись сектора
			rcall	SD_CMD
		;	rcall	out_com			;ПОСЫЛКА БАЙТА ОТВЕТА ЧЕРЕЗ USART (Для проверки правильности адреса)
			ldi		temp,0xFE		;Для начала блока данных передаем байт 0xFE
			rcall	SPI_Write		
			rcall	write_512		;ЗАПИСЬ БЛОКА ИЗ 512 БАЙТ
			rcall	SPI_Write_FF	;Запись CRC 1
			rcall	SPI_Write_FF	;Запись CRC 2
			rcall	SPI_Write_FF	;Пауза
wait_DO:	rcall	SPI_Write_FF	;Ожидание установки вывода DO в 1 (100..130 )
			sbis	PIN_SD,MISO
			rjmp	wait_DO
			ret
;*** ЗАПИСЬ БЛОКА ИЗ 512 БАЙТ ***
Write_512:		ldi		ZL,low (512)	;Загрузка значения в счетчик переданных байт
				ldi		ZH,high(512)
repeat_write:	mov		temp,ZL			;Заносим в регистр temp текущее значение счетчика
				rcall	SPI_Write		;И записываем это значение в карту
				sbiw	ZL,1			;Уменьшаем счетчик на 1
				brne	repeat_write	;Если не ноль, записываем следующий байт
				ret

;###################################
;#### ЧТЕНИЕ СЕКТОРА В 512 БАЙТ ####
;###################################
Read_SD:	ldi		temp,0x51		;Команда на чтение сектора	
			rcall	SD_CMD
		;	rcall	out_com			;ПОСЫЛКА БАЙТА ОТВЕТА ЧЕРЕЗ USART (Для проверки правильности адреса)
Wait_0xFE:	rcall	SPI_Read		;Ожидание 0xFE
			cpi		temp,0xFE
			brne	Wait_0xFE	
			rcall	Read_512		;ЧТЕНИЕ БЛОКА ИЗ 512 БАЙТ
			rcall	SPI_Read		;Чтение CRC 1
			rcall	SPI_Read		;Чтение CRC 2
			rcall	SPI_Write_FF	;Пауза
			ret
;*** ЧТЕНИЕ БЛОКА ИЗ 512 БАЙТ ***
Read_512:		ldi		ZL,low (512)	;Загрузка значения в счетчик принятых байт
				ldi		ZH,high(512)	
repeat_read:	rcall	SPI_Read		;Чтение байта
				rcall	out_com			;ПОСЫЛКА БАЙТА ЧЕРЕЗ USART
				sbiw	ZL,1			;Уменьшаем счетчик на 1
				brne	repeat_read		;Если не ноль, читаем следующий байт
				ret


;****************************************************************************
	;#### ОТПРАВКА БАЙТА ЧЕРЕЗ UART ####
out_com:	sbis	UCSRA,UDRE
			rjmp	out_com
			out		UDR,temp
			ret
	;#### ПРИЕМ БАЙТА ЧЕРЕЗ UART ####
in_com:		sbis	UCSRA,RXC
			rjmp	in_com
			in		temp,UDR
			ret


