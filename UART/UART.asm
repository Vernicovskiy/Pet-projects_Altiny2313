/*
Программирование модуля связи UART
ПРИМЕР РАБОТЫ МОДУЛЯ БЕЗ ИСПОЛЬЗОВАНИЯ ПРЕРЫВАНИЙ.

Скорость:				9600 Бит/с
Размер слова данных:	8 бит
Кол-во стоп битов:		1
Четность:				НЕТ

ЗАМЕЧАНИЕ:
Для скорости обмена 9600 бит/с тактовая частота должна быть
не ниже 2 MHz.
При этом для частот ниже 4 MHz желательно использовать внешний 
кварцевый резанатор

Микроконтроллер		ATtiny2313
Тактовая частота	8 MHz	
*/ 
.include "tn2313def.inc"

.def	temp		=R16
.def	loop		=R17	

.equ	XTALL	=8000000				;Тактовая частота в ГЕРЦАХ
.equ	BAUD	=9600					;Скорость обмена данными в бит/с
.equ	SPEED	=(XTALL/(16*BAUD))-1	;Коэфициент деления для получения 
										;заданой скорости обмена
.cseg
.org	0x00
			rjmp	start

.org	0x20
start:		ldi		temp,RAMEND
			out		SPL,temp
			
			ldi		temp,high(SPEED)		;Запись делителя для задания желаемой 
			out		UBRRH,temp				;скорости обмена
			ldi		temp,low(SPEED)
			out		UBRRL,temp

			ldi		temp,(1<<UCSZ1|1<<UCSZ0)	;Выбор размера слова данных 8 бит
			out		UCSRC,temp

			ldi		temp,(1<<RXEN|1<<TXEN)		;Разрешение приема и передачи
			out		UCSRB,temp

;### ГЛАВНЫЙ ЦИКЛ ###
main:		rcall	in_com		;Считываем данные
			cpi		temp,0x30	;Если был отправлен байт 0x30 (в коде ASCII это символ '0')
			breq	Pr_Message	;то в ответ отправляем сообщение 'Zero'
			inc		temp		;А если другой символ, то увеличиваем принятый байт на 1
			rcall	out_com		;и отправляем обратно
			rjmp	main
Pr_Message:	rcall	message
			rjmp	main
		
message:	ldi		temp,'Z'	;Отправка сообщения "Zero"
			rcall	out_com
			ldi		temp,'e'
			rcall	out_com
			ldi		temp,'r'
			rcall	out_com
			ldi		temp,'o'
			rcall	out_com
			ldi		temp,0x0A	;"ПЕРЕВОД СТРОКИ" Перевод курсора на строку ниже
			rcall	out_com
			ldi		temp,0x0D	;"ВОЗВРАТ КАРЕТКИ" Переход на начало текущей строки
			rcall	out_com
			ret

;#### ОТПРАВКА БАЙТА ЧЕРЕЗ UART ####
out_com:	sbis	UCSRA,UDRE	;Ожидание, когда бит UDRE 
			rjmp	out_com		;будет установлен в 1 (предыдущий байт отправлен) 
			out		UDR,temp	;Отправляем байт
			ret

;#### ПРИЕМ БАЙТА ЧЕРЕЗ UART ####
in_com:		sbis	UCSRA,RXC	;Ожидание, когда бит RXC будет установлен в 1 
			rjmp	in_com		;(в регистре данных есть принятый непрочитанный байт) 
			in		temp,UDR	;Считываем принятый байт
			ret

