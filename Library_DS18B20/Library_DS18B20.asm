/* ПРОГРАММА СЧИТЫВАНИЯ ТЕМПЕРАТУРЫ С ДВУХ ДАТЧИКОВ И ВЫВОД ПОКАЗАНИЙ В ДЕСЯТИЧНОМ ВИДЕ НА ИНДИКАТОР 
Идентификация датчиков DS18B20 производится по ID-коду

Температура выводится на индикатор с точностью до десятых долей градуса

В программе используется 2-строчный 16-символьный индикатор типа HD44780

Перед использованием программы произвести настройку библиотек MicroLan.inc и HD44780.inc

Микроконтроллер		ATtiny2313
Тактовая частота	8 MHz
Индикатор			2-строчный 16-символьный типа HD44780
*/

.include "tn2313def.inc"


.def	temp	=R16

.cseg		rjmp	start

.include "DS18B20.inc"					;ПОДКЛЮЧЕНИЕ БИБЛИОТЕКИ DS18B20
.include "HD44780.inc"					;ПОДКЛЮЧЕНИЕ БИБЛИОТЕКИ HD44780


start:		ldi		temp,RAMEND
			out		SPL,temp

	;		Set_Reg_RAM	 0xFF,0xFF,9	;Инициализация DS18B20. Сохранение настроек в RAM

			Set_Reg_EEP	 0xFF,0xFF,12	;Инициализация DS18B20. Сохранение настроек в EEPROM-память

			Init_HD44780				;Инициализация индикатора


;#### ГЛАВНЫЙ ЦИКЛ ####
main:		First_Line					;Переход на первую строку индикатора


		;	rjmp	Single_Tmp			;Переход к подпрограмме измерения температуры с одного датчика



;Измерение температуры с нескольких датчиков
Temp_1:		Rd_Tmp_PZU		0x60,ID0	;Чтение температуры с датчика ID0
			brtc	T1_OK
			rcall	Print_ERR			;Печать ошибки
			rjmp	Temp_2

T1_OK:		Row		T1
			rcall	Out_tp_LCD			;Печать температуры


Temp_2:		Second_Line					;Переход на вторую строку индикатора
			Rd_Tmp_PZU		0x60,ID2	;Чтение температуры с датчика ID2
			brtc	T2_OK
			rcall	Print_ERR
			rjmp	main

T2_OK:		Row		T2
			rcall	Out_tp_LCD			;Печать температуры
			rjmp	main				;На начало основного цикла




;Измерение температуры с одного датчика
Single_Tmp:	Rd_one_Tmp		0x60
			brtc	Tp_OK
			rcall	Print_ERR
			rjmp	main

Tp_OK:		Row		Tp
			rcall	Out_tp_LCD
			rjmp	main






;ПЕЧАТЬ ТЕМПЕРАТУРЫ
Out_tp_LCD:	sbrs	ZL,7				;Проверка на отрицательное значение
			rjmp	m1
			dat		'-'					;Печать минуса
			rjmp	m3
m1:			sbrs	ZL,4				;Проверка сотен градусов
			rjmp	m2
			dat		'1'					;Печать сотни градусов
			rjmp	m3
m2:			dat		' '					;Печать пробела
m3:			mov		temp,ZH				;Печать десятков и единиц
			rcall	PrHEX
			dat		'.'					;Печать разделительной точки
			mov		temp,ZL
			andi	temp,0x0F
			rcall	jedat30				;Печать десятых градуса
			ret
			
;ПЕЧАТЬ ОШИБКИ
Print_ERR:	push	temp
			Row		Err
			pop		temp
			rcall	PrHEX
			Row		Space
			ret



;СООБЩЕНИЯ
Err:		.db	"Error ",0
Tp:			.db	"Temp = ",0
T1:			.db	"Temp1 = ",0
T2:			.db	"Temp2 = ",0
Space:		.db	"     ",0


;ID-КОДЫ ДАТЧИКОВ DS18B20
ID0:		.db	0x28,0xCC,0x8F,0x52,0x03,0x00,0x00,0x63		;ID-код датчика 0
ID1:		.db	0x28,0x7B,0x6C,0x81,0x00,0x00,0x00,0x18		;ID-код датчика 1
ID2:		.db	0x28,0x2A,0xB7,0xE5,0x00,0x00,0x00,0xB1		;ID-код датчика 2



