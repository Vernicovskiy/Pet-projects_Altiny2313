/*
Изучение группы команд передачи управления по условию
*/

.include "tn2313def.inc"

.def	temp		=R16
.def	temp2		=R17
.equ	const_1		=234
.equ	const_2		=234
.equ	bit_3		=3
.equ	bit_5		=5
.equ	bit_7		=7

;#################################
		ldi		temp,const_1
		ldi		temp2,const_2
		cpse	temp,temp2		;Пропуск следующей команды, если регистры равны
		rjmp	other_branch	;Переход на другую ветвь программы
next_step_program:				;Программа продолжается
		nop						;ДЕЙСТВИЕ 1
		nop
		rjmp	next_action_

other_branch:					;ДЕЙСТВИЕ 2					
		nop
		nop

next_action_:
;####################################################
		ldi		temp,(1<<bit_3|1<<bit_5) ;Установили 3 и 5 биты
		sbrc	temp,bit_7	;Пропуск следующей команды, если бит bit_7 сброшен
		rjmp	action_1
action_2:
		nop					;ДЕЙСТВИЕ 2
		rjmp	next_action

action_1:
		nop					;ДЕЙСТВИЕ 1
		
		
next_action:
		sbrc	temp,bit_5	;Пропуск следующей команды, если бит bit_5 сброшен
		rjmp	action_3
		nop					;ДЕЙСТВИЕ 4
		rjmp	_next_action

action_3:
		nop					;ДЕЙСТВИЕ 3
		

_next_action:
;####################################################
;КОМАНДЫ ПРОВЕРКИ ПРОПУСКА, ЕСЛИ БИТ РВВ СБРОШЕН(УСТАНОВЛЕН)

		sbis	PIND,4			;Пропустить следующую команду, если на 4 выводе порта d логическая 1
		rjmp	press_button_4	;А если на выводе логический ноль (кнопка нажата), то переход к действию
		nop
		nop
		rjmp	END_button
		sbic	PIND,5				;Пропустить следующую команду, если на 5 выводе порта d логический 0
		rjmp	NO_press_button_5	;Выполнить переход, если кнопка не нажата
		nop
		nop

press_button_4:		nop		;Здесь прописать действие, если на 4 выводе порта d логическая 1
NO_press_button_5:	nop		;А здесь прописать действие, если на 4 выводе порта d логический 0
END_button:			nop

;####################################################
.equ	Pin_Button	=PIND			;Назначаем для регистра PIND удобное имя
.equ	button_1	=PIND4			;Определяем для кнопки 1 нужный вывод
.equ	button_2	=PIND5			;Определяем для кнопки 2 нужный вывод
.equ	signal_1	=0b11110000
.equ	signal_2	=0b00001111
.equ	signal_3	=0b00111100

		clr		temp
		out		DDRD,temp			;Порт D переводим на вход
		ser		temp
		out		PORTD,temp			;И включаем подтягивающие резисторы
		
		ser		temp
		out		DDRB,temp			;Порт В переводим на выход
		clr		temp
		out		PORTB,temp			;И на всех выводах устанавливаем 0

;ОСНОВНОЙ ЦИКЛ
main:	sbis	Pin_Button,button_1	;Пропускаем следующую команду, если кнопка 1 не нажата
		rjmp	button_down	 		;Если кнопка нажата, то переходим на button_down

button_up:							;Кнопка не нажата
		ldi		temp,signal_1		;Зажигаем светодиоды по программе 1
		out		PORTB,temp			;Выводим в порт в
		rjmp	main	

button_down:
		ldi		temp,signal_2		;Зажигаем светодиоды по программе 2
		out		PORTB,temp			;Выводим в порт в

		sbis	Pin_Button,button_2	;Если ключ разомкнут, то переходим на "секретный" цикл
		rjmp	main2

		rjmp	main

;####################################################
;"СЕКРЕТНЫЙ" ЦИКЛ
main2:	ldi		temp,signal_3		;Зажигаем светодиоды по программе 3
		sbis	Pin_Button,button_1	;Пропуск следующей команды, если кнопка не нажата
		swap	temp				;Меняем тетрады местами
		out		PORTB,temp			;Выводим в порт в
		rjmp	main2
