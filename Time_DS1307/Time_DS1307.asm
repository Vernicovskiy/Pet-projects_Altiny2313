/*	Считывание показаний времени и даты из микросхемы 
часов реального времени DS1307

Вывод данных производится на индикатор типа HD44780

Микроконтроллер		ATtiny2313
Тактовая частота 	8 MHz
*/
.include "tn2313def.inc"


.def	temp		=R16

.equ	Data_Cell	=0						;Номер ячейки в оперативной памяти DS1307 (0..55)


.dseg
.org		0x60
Data_Time:	.byte	7						;Определение 7 байт памяти данных под хранение считанных байт или байт для записи

.cseg
			rjmp	start
.include "HD44780.inc"						;Подключение библиотеки для работы с индикатором HD44780
.include "DS1307.inc"						;Подключение библиотеки для работы с DS1307 (+ библиотека I2C)


start:		ldi		temp,RAMEND
			out		SPL,temp

			ldi		temp,0xFF
			out		PORTD,temp
			out		PORTB,temp
			
			rcall	Init_LCD_HD44780		;Инициализация индикатора HD44780

			rcall	Init_DS1307				;Инициализация DS1307
			brtc	PC+2					;Если Т = 1, то было отключение питания 
			rcall	Set_Time_and_Data		;Настройка времени и даты

			rcall	Inc_Cell_Ram			;Подпрограмма увеличения содержимого ячейки Data_Cell памяти данных DS1307



;ОСНОВНОЙ ЦИКЛ	
MAIN:		Read_7Byte_DS1307	Data_Time	;Считывание 7 первых регистров в 7 ячеек памяти данных

			ldi		ZH,high(Data_Time)		;Загрузка в temp адреса первой ячейки Data_Time
			ldi		ZL,low (Data_Time)

;ПЕЧАТЬ ВРЕМЕНИ:
			First_Line						;Переход на первую строку индикатора
			Row		Time					;Печать "Time:"
			ldd		temp,Z+2				;Загрузка в temp второго байта (часы)
			rcall	prHEX
			dat		':'							
			ldd		temp,Z+1				;Загрузка в temp первого байта (минуты)
			rcall	prHEX
			dat		':'				
			ldd		temp,Z+0				;Загрузка в temp нулевого байта (секунды)
			rcall	prHEX
			dat		' '

;ПЕЧАТЬ БАЙТА ИЗ ЯЧЕЙКИ RAM
			ldi		R16,Data_Cell
			rcall	Read_RAM_DS1307			;Считывание в регистр R16 байта из ячейки RAM с номером Data_Cell
			rcall	prHEX					;Вывод на индикатор содержимого R16


;ПЕЧАТЬ ДАТЫ:
			Second_Line						;Переход на вторую строку индикатора
			Row		Data					;Печать "Data:"
			ldd		temp,Z+4				;Загрузка в temp четвертого байта (дата)
			rcall	prHEX
			dat		'.'
			ldd		temp,Z+5				;Загрузка в temp пятого байта (месяц)
			rcall	prHEX
			dat		'.'
			ldd		temp,Z+6				;Загрузка в temp пятого байта (год)
			rcall	prHEX
			dat		' '
			ldd		temp,Z+3				;Загрузка в temp третьего байта (день недели)
			rcall	prHEX
					
			rjmp	MAIN



;Инициализация часов
;22 мая, среда, 2013 год. 15 часов 36 минут 22 секунды
;Генерация сигналов на выводе SQW отключена.
Set_Time_and_Data:	
			ldi		ZH,high(Data_Time)		;Записываем в регистр Z адрес хранения данных для записи
			ldi		ZL,low (Data_Time)		;
			ldi		temp,0x22				;Секунды
			std		Z+0,temp
			ldi		temp,0x55				;Минуты
			std		Z+1,temp
			ldi		temp,0x15				;Часы
			std		Z+2,temp
			ldi		temp,0x03				;День недели
			std		Z+3,temp
			ldi		temp,0x22				;Дата
			std		Z+4,temp
			ldi		temp,0x05				;Месяц
			std		Z+5,temp
			ldi		temp,0x13				;Год
			std		Z+6,temp

			rcall	Write_Time				;Вызываем подпрограмму записи байтов из памяти данных в регистры DS1307

											;Так же можно прописать вот такой макрос:
	;		Write_7Byte_DS1307	Data_Time	;Запись в 7 первых регистров DS1307 семи первых байт 
			ret								;расположенных по адресу Data_Time



;Увеличение содержимого ячейки памяти RAM 
Inc_Cell_Ram:	ldi		R16,Data_Cell			
				rcall	Read_RAM_DS1307		;Считывание в R16 содержимого ячейки с адресом Data_Cell
				inc		R16					;Увеличение содержимого R16
				ldi		R17,Data_Cell		;Запись в регистр R17 адреса Data_Cell
				rcall	Write_RAM_DS1307	;Запись в ячейку с адресом Data_Cell содержимого R16
				ret

Time:		.db			"Time:",0
Data:		.db			"Data:",0
