							
							/*ГРУППА КОМАНД ПЕРЕДАЧИ УПРАВЛЕНИЯ ПО УСЛОВИЮ*/


.def	temp	=R16
		

;ПРОГРАММА ЗАДЕРЖКИ
		ldi		temp,0xFF
delay:	dec		temp
		brne	delay	 	;ЕСЛИ temp НЕ НОЛЬ, ТО ПЕРЕХОД ПО МЕТКЕ delay
	;	brne	PC-1		;ИЛИ ТАК, ЕСЛИ temp НЕ НОЛЬ, ТО ПЕРЕХОД на предыдущий адрес



;ПЕРЕХОД ПО РЕЗУЛЬТАТАМ СРАВНЕНИЯ
		cpi		temp,0xF1
		breq	action_1	;Переход на action_1, если temp РАВЕН 0xFE
		brcs	action_2	;Переход на action_2, если temp МЕНЬШЕ 0xFE
		brcc	action_3	;Переход на action_2, если temp БОЛЬШЕ 0xFE

action_3:					
		nop					;Действие 3
		rjmp	Ext
action_2:
		nop					;Действие 2
		rjmp	Ext
action_1:
		nop					;Действие 1

Ext:						;Выход


;СРАВНЕНИЕ И ПРОПУСК
		cpi		temp,1
		breq	act_1	;Если temp = 1, то переходим на act_1
		cpi		temp,2
		breq	act_2	;Если temp = 2, то переходим на act_2
		cpi		temp,3
		breq	act_3	;Если temp = 3, то переходим на act_3
		cpi		temp,4
		breq	act_4	;Если temp = 4, то переходим на act_4
		rjmp	End_Act
act_1:	nop				;ДЕЙСТВИЕ 1
		rjmp	End_Act
act_2:	nop				;ДЕЙСТВИЕ 2
		rjmp	End_Act
act_3:	nop				;ДЕЙСТВИЕ 3
		rjmp	End_Act
act_4:	nop				;ДЕЙСТВИЕ 4

End_Act:				;ВЫХОД	


;Между командой типа brXX и меткой растояние должно быть не больше чем 63 адреса программ назад и 64 адреса вперед

;Пример ошибки, которая возникает при привышении этого раcстояния:

		cpi		temp,1
		breq	metka_too_far
;		nop		;Если эту команду раскомментировать, то растояние превысит 64 адреса программ вперед
		nop		
		nop
		nop 
		nop
		nop
		nop 
		nop
		nop
		nop
		nop
		nop
		nop	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

metka_too_far:
		
		rjmp	PC
