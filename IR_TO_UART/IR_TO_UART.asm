/*
ПЕРЕДАЧА IR-ПОСЫЛОК НА HYPER TERMINAL ЧЕРЕЗ UART

Вывод выхода tsop-приемника должен быть подключен на вывод захвата (ICP) таймера Т1
В микроконтроллере ATtiny2313 вывод захвата - PD6 (11)

Для повышения точности измеряемых интервалов в качестве 
тактового генератора можно использовать генератор с внешним 
кварцевым резанатором на 8 MHz

Максимальный измеряемый интервал 			65535 мкс
Максимальное число измеряемых интервалов	60

КОНТРОЛЛЕР:			ATtiny2313
ТАКТОВАЯ ЧАСТОТА:	8 MHz
*/
.include "tn2313def.inc"


.equ		Numbers_of_commands	=60				;Число импульсов нулей и единиц, которые могут быть приняты

.def		temp		=R16
.def		loop		=R17
.def		numb		=R18
.def		data		=R19
.def		FLAGS		=R20

.equ		Buf_Full	=0						;Флаг заполнения буфера

.equ		XTALL		=8000000				;Тактовая частота микроконтроллера
.equ		BAUD		=9600					;Скорость обмена RS232
.equ		SPEED		=XTALL/(16*BAUD) - 1	;Коэффициент деления в регистре UBRR

.macro		ldi16
			ldi		@0H,high(@1)
			ldi		@0L,low (@1)
.endm
.macro		trans
			ldi		temp,@0
			rcall	Translate_USART
.endm
.macro		outi
			ldi		R16,@1
			out		@0,R16
.endm

;#### ПАМЯТЬ ДАННЫХ ####
.dseg
.org	0x60
BUFER:		.byte	(Numbers_of_commands * 2)	;Буфер для хранения 60 значений счетчика (1 значение занимает 2 байта)

;#### ОСНОВНОЙ КОД ####
.cseg
.org	0x00
				rjmp	INIT
.org	ICP1addr
				rjmp	TIM1_CAPT				;Захват таймера
.org	OVF1addr
				rjmp	TIM1_OVER				;Переполнение таймера


.org			INT_VECTORS_SIZE				;Начало программного кода

INIT:			outi	SPL,RAMEND
				outi	PORTD,0xFF
				outi	PORTB,0xFF
				outi	UCSRB,(1<<TXEN)				;РАЗРЕШЕНИЕ ПЕРЕДАЧИ
				outi	UCSRC,(1<<UCSZ1|1<<UCSZ0)	;ФОРМАТ ПОСЫЛКИ - 8 БИТ (UCSZ0=1, UCSZ1=1, UCSZ2=0)
				outi	UBRRH,high(SPEED)
				outi	UBRRL,low (SPEED)
				outi	TIMSK,(1<<TOIE1|1<<ICIE1)	;ПРЕРЫВАНИЕ ПО ПЕРЕПОЛНЕНИЮ, ПРЕРЫВАНИЕ ПО ЗАХВАТУ
				

restart:		outi	TCCR1B,(1<<ICES1)		;ЗАХВАТ ПО НАРОСТАНИЮ. ТАЙМЕР ОСТАНОВЛЕН
				outi	TCNT1H,0				;ОЧИЩАЕМ ТАЙМЕР
				outi	TCNT1L,0
				ldi16	Y,BUFER
				clr		numb
				clr		FLAGS					;СБРАСЫВАЕМ ВСЕ ФЛАГИ
				outi	TIFR,0xFF				;СБРОС ВСЕХ ФЛАГОВ ПРЕРЫВАНИЙ
				sei
		

;#### ОСНОВНОЙ ЦИКЛ ####
MAIN:			sbic	PIND,PD6				;ЖДЕМ, ПОКА на выводе не появится НОЛЬ
				rjmp	MAIN
				outi	TCCR1B,(1<<ICES1|1<<CS11)	;ЗАХВАТ ПО НАРОСТАНИЮ. ДЕЛЕНИЕ НА 8				
				sbrs	FLAGS,Buf_Full			;Ожидание заполнения буфера
				rjmp	PC-1
				rcall	Translate_to_PC			;ПЕРЕДАЕМ МАССИВ НАКОПЛЕНЫХ ДАННЫХ
				rjmp	restart


;ПРЕРЫВАНИЕ ПО ЗАХВАТУ ТАЙМЕРА
TIM1_CAPT:		outi	TCNT1H,0				;ОЧИЩАЕМ ТАЙМЕР
				outi	TCNT1L,0

				ldi		data,(1<<ICES1)			
				in		temp,TCCR1B
				eor		temp,data				;ИНВЕРСИЯ БИТА ICES1
				out		TCCR1B,temp				

				in		temp,ICR1L				;СЧИТЫВАЕМ ЗНАЧЕНИЕ ИЗ РЕГИТРА ЗАХВАТА И ЗАПИСЫВАЕМ В BUFER
				st		Y+,temp
				in		temp,ICR1H				;СНАЧАЛА ЗАПИСЫВАЕМ СТАРШЕЕ ЗНАЧЕНИЕ БАЙТА
				st		Y+,temp			
		
				inc		numb
				cpi		numb,Numbers_of_commands
				breq	TIM1_OVER				;БУФЕР ЗАПОЛНЕН
				reti
;ПРЕРЫВАНИЕ ПО ПЕРЕПОЛНЕНИЮ ТАЙМЕРА
TIM1_OVER:		sbr		FLAGS,(1<<Buf_Full)		;УСТАНАВЛИВАЕМ ФЛАГ ГОТОВНОСТИ К ПЕРЕДАЧИ
				ret								;Запрет прерываний на выходе




;##### ОБРАБОТКА И ПЕРЕДАЧА МАССИВА ДАННЫХ В HYPER TERMINAL ####
.macro			Print_STR
				trans	' '
				ldi		temp,(@0 + 0x30)
				rcall	Translate_USART
				trans	':'					
				trans	' '					
				rcall	Print_pulse_time		;ПЕЧАТЬ СЛОВА	
				trans	' '					
.endm

Translate_to_PC:
				ldi16	Y,BUFER
				clr		loop
next_word:		inc		loop					;Печать номера строки
				clr		XH
				mov		XL,loop
				rcall	Calc_10
				trans	' '						;Два пробела
				trans	' '

				Print_STR	0					;Печать разряда "0: "
				
				dec		numb					;Проверка на окончание посылки
				breq	End_str

				Print_STR	1					;Печать разряда "1: "
				trans	' '					
				trans	' '					

				sbiw	YL:YH,4					;Вычисление общего времени 0-го и 1-го импульсов
				ld		XL,Y+
				ld		XH,Y+
				ld		temp,Y+
				add		XL,temp
				ld		temp,Y+
				adc		XH,temp

				trans	'('			
				rcall	Calc_10000				;Печать общего времени 0-го и 1-го импульсов
				trans	' '				
				trans	'u'			
				trans	's'			
				trans	')'			

				trans	0x0A					;Перевод на другую строку
				trans	0x0D			
				
				dec		numb
				brne	next_word

End_str:		trans	0x0A					;Окончание вывода данных
				trans	0x0D			
				trans	0x0A					;Перевод на другую строку
				trans	0x0D			
				ret



.macro			Calc_xxx						;Вычисление и передача разрядов числа
				clr		data
check_xxx:		mov		temp,XL
				subi	temp,low(@0)
				mov		temp,XH
				sbci	temp,high(@0)
				brcc	sub_xxx
				rjmp	Print_xxx
sub_xxx:		subi	XL,low(@0)
				sbci	XH,high(@0)
				inc		data
				rjmp	check_xxx
Print_xxx:		rcall	Print_Number
.endm		

Print_pulse_time:
				ld		XL,Y+
				ld		XH,Y+
Calc_10000:		Calc_xxx	10000				;ПЕЧАТЬ ДЕСЯТКОВ ТЫСЯЧ
Calc_1000:		Calc_xxx	1000				;ПЕЧАТЬ ТЫСЯЧ
Calc_100:		Calc_xxx	100					;ПЕЧАТЬ СОТЕН
Calc_10:		Calc_xxx	10					;ПЕЧАТЬ ДЕСЯТКОВ
Calc_1:			mov		temp,XL					;ПЕЧАТЬ ЕДИНИЦ
				subi	temp,-0x30
				rcall	Translate_USART
				ret


Print_Number:	mov		temp,data
				subi	temp,-0x30
Translate_USART:sbis	UCSRA,UDRE				;ПЕРЕДАЧА ПО USART
				rjmp	Translate_USART
				out		UDR,temp
				ret
