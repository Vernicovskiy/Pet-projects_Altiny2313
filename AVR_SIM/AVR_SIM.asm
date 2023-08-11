/*
Микроконтроллер:	ATtiny2313
Тактовая частота:	1 MHz
*/

.include "tn2313def.inc"

.def	temp		=R16
.def	loop		=R17
.def	count		=R18

.cseg
.org	0x00	rjmp	init		;ИНИЦИАЛИЗАЦИЯ
.org	0x05	rjmp	T1_over		;Переполнение таймера/счетчика Т1
.org	0x20


;ИНИЦИАЛИЗАЦИЯ
init:		ldi		temp,RAMEND		;Инициализация стека
			out		SPL,temp
		
			ser		temp			;Порт В на выход
			out		DDRB,temp
			out		PORTB,temp

			clr		temp
			out		DDRD,temp		;Все выводы на вход.
			ser		temp
			out		PORTD,temp
			


;НАСТРОЙКА ТАЙМЕРА Т1

			ldi		temp,(1<<TOIE1)
			out		TIMSK,temp

			ldi		temp,(0<<CS12|0<<CS11|1<<CS10) ;деление 1
			out		TCCR1B,temp

			rcall	T1_over			;ГЛОБАЛЬНОЕ РАЗРЕШЕНИЕ ПРЕРЫВАНИЙ



;##### ОСНОВНОЙ ЦИКЛ #####	
MAIN:		rcall	klav			;Вызов подпрограммы считывания состояния кнопки
			brtc	PC+2
			rcall	Count_Up		;Подпрограмма увеличения счетчика
			rjmp	MAIN


;Подпрограмма увеличения значения счетчика
Count_Up:	inc		count
			ret


;Подпрограмма считывания состояния кнопки
klav:		clt
			sbic	PIND,PD0		;Выход, если кнопка не нажата
			ret
			rcall	delay			;Задержка против дребезга
			sbis	PIND,PD0		;Ожидание отпускания кнопки
			rjmp	PC-1
			rcall	delay			;Задержка против дребезга
			set						;Установка флага Т - признак нажатия кнопки
			ret
;Задержка
delay:		ldi		loop,0xFF		;Заносим в регистр задержки желаемый коэфициент
			dec		loop			;Проверяем на нулевое значение
			nop
			nop
			nop
			brne	delay+1			;Ждем, пока не ноль
			ret



;### ПРЕРЫВАНИЕ ПО СОВПАДЕНИЮ В КАНАЛЕ A ###
T1_over:	in		R5,SREG			;Сохраняем регистр статуса
			out		PORTB,count
			out		SREG,R5			;Восстанавливаем регистр статуса
			reti


