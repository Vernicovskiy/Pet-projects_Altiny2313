/*
Расшифровка сигнала о направлении поворота 
с энкодера и передача по USART на ПК

Микроконтроллер		ATtiny2313
Тактовая частота	8 MHz	
*/ 
.include "tn2313def.inc"

.equ	Encoder_Pin	=PIND
.equ	Pin_A		=PD4
.equ	Pin_B		=PD5

.def	temp		=R16
.def	FLAGS		=R17	;Регистр флагов
.def	BUTTON		=R18	;Регистр кнопок

;Разряды регистра BUTTON
.equ	Encoder_L	=0		;Флаг поворота влево
.equ	Encoder_R	=1		;Флаг поворота вправо

;Разряды регистра FLAGS
.equ	Encoder_Act		=0	;Флаг обработки состояния энкодера
.equ	Encoder_Turn	=1	;Флаг направления поворота

;Определение параметров USART
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
			
			ldi		temp,~(1<<Pin_A|1<<Pin_B)	;Выводы энкодера на вход
			out		DDRD,temp
			ldi		temp,(1<<Pin_A|1<<Pin_B)	;Подключаем на выводы подтягивающие резисторы
			out		PORTD,temp
			
			clr		BUTTON
			clr		FLAGS

			ldi		temp,high(SPEED)		;Запись делителя для задания желаемой 
			out		UBRRH,temp				;скорости обмена
			ldi		temp,low(SPEED)
			out		UBRRL,temp

			ldi		temp,(1<<UCSZ1|1<<UCSZ0)	;Выбор размера слова данных 8 бит
			out		UCSRC,temp

			ldi		temp,(1<<RXEN|1<<TXEN)		;Разрешение приема и передачи
			out		UCSRB,temp


;### ГЛАВНЫЙ ЦИКЛ ###
main:		rcall	Encoder
			rcall	Message
			rjmp	main

;#### ОТПРАВКА СООБЩЕНИЯ О НАПРАВЛЕНИИ ПОВОРОТА ####
Message:	ldi		temp,'L'
			sbrc	BUTTON,Encoder_L
			rjmp	Send_Mes
			ldi		temp,'R'
			sbrc	BUTTON,Encoder_R
			rjmp	Send_Mes
			ret
Send_Mes:	rcall	out_com
			cbr		BUTTON,(1<<Encoder_L|1<<Encoder_R)
			ret

;#### ОБРАБОТКА СОСТОЯНИЯ ЭНКОДЕРА ####
Encoder:	in		temp,Encoder_Pin			;Считываем регистр PINX порта энкодера
			com		temp						;Инвертируем прочитанное значение
			andi	temp,(1<<Pin_A|1<<Pin_B)	;Оставляем только выводы энкодера
			brne	No_Neutral					;Если энкодер в нейтральном положении,
			cbr		FLAGS,(1<<Encoder_Act)		;то сбрасываем бит обработки энкодера
			ret									;и выходим
No_Neutral:	sbrc	FLAGS,Encoder_Act			;Если сигнал с энкодера уже обработан,
			ret									;то выходим
			cpi		temp,(1<<Pin_A|1<<Pin_B)	;Если оба вывода замкнуты,
			breq	Run							;то переходим на обработку сигнала с энкодера
			cbr		FLAGS,(1<<Encoder_Turn)		;Поворот влево
			sbrc	temp,Pin_B					;Проверка вывода энкодера
			sbr		FLAGS,(1<<Encoder_Turn)		;Поворот вправо
			ret									
Run:		sbr		FLAGS,(1<<Encoder_Act)		;Установка флага обработки сигнала с энкодера
			sbr		BUTTON,(1<<Encoder_L)		;Поворот влево
			cbr		BUTTON,(1<<Encoder_R)		
			sbrc	FLAGS,Encoder_Turn			;Проверка флага направления поворота
			ret
			cbr		BUTTON,(1<<Encoder_L)		
			sbr		BUTTON,(1<<Encoder_R)		;Поворот вправо
			ret


;#### ОТПРАВКА БАЙТА ЧЕРЕЗ UART ####
out_com:	sbis	UCSRA,UDRE	;Ожидание, когда бит UDRE 
			rjmp	out_com		;будет установлен в 1 (предыдущий байт отправлен) 
			out		UDR,temp	;Отправляем байт
			ret

