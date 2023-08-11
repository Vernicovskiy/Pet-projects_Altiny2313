/*
�������� ������ ������ �������� ���������� �� �������
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
		cpse	temp,temp2		;������� ��������� �������, ���� �������� �����
		rjmp	other_branch	;������� �� ������ ����� ���������
next_step_program:				;��������� ������������
		nop						;�������� 1
		nop
		rjmp	next_action_

other_branch:					;�������� 2					
		nop
		nop

next_action_:
;####################################################
		ldi		temp,(1<<bit_3|1<<bit_5) ;���������� 3 � 5 ����
		sbrc	temp,bit_7	;������� ��������� �������, ���� ��� bit_7 �������
		rjmp	action_1
action_2:
		nop					;�������� 2
		rjmp	next_action

action_1:
		nop					;�������� 1
		
		
next_action:
		sbrc	temp,bit_5	;������� ��������� �������, ���� ��� bit_5 �������
		rjmp	action_3
		nop					;�������� 4
		rjmp	_next_action

action_3:
		nop					;�������� 3
		

_next_action:
;####################################################
;������� �������� ��������, ���� ��� ��� �������(����������)

		sbis	PIND,4			;���������� ��������� �������, ���� �� 4 ������ ����� d ���������� 1
		rjmp	press_button_4	;� ���� �� ������ ���������� ���� (������ ������), �� ������� � ��������
		nop
		nop
		rjmp	END_button
		sbic	PIND,5				;���������� ��������� �������, ���� �� 5 ������ ����� d ���������� 0
		rjmp	NO_press_button_5	;��������� �������, ���� ������ �� ������
		nop
		nop

press_button_4:		nop		;����� ��������� ��������, ���� �� 4 ������ ����� d ���������� 1
NO_press_button_5:	nop		;� ����� ��������� ��������, ���� �� 4 ������ ����� d ���������� 0
END_button:			nop

;####################################################
.equ	Pin_Button	=PIND			;��������� ��� �������� PIND ������� ���
.equ	button_1	=PIND4			;���������� ��� ������ 1 ������ �����
.equ	button_2	=PIND5			;���������� ��� ������ 2 ������ �����
.equ	signal_1	=0b11110000
.equ	signal_2	=0b00001111
.equ	signal_3	=0b00111100

		clr		temp
		out		DDRD,temp			;���� D ��������� �� ����
		ser		temp
		out		PORTD,temp			;� �������� ������������� ���������
		
		ser		temp
		out		DDRB,temp			;���� � ��������� �� �����
		clr		temp
		out		PORTB,temp			;� �� ���� ������� ������������� 0

;�������� ����
main:	sbis	Pin_Button,button_1	;���������� ��������� �������, ���� ������ 1 �� ������
		rjmp	button_down	 		;���� ������ ������, �� ��������� �� button_down

button_up:							;������ �� ������
		ldi		temp,signal_1		;�������� ���������� �� ��������� 1
		out		PORTB,temp			;������� � ���� �
		rjmp	main	

button_down:
		ldi		temp,signal_2		;�������� ���������� �� ��������� 2
		out		PORTB,temp			;������� � ���� �

		sbis	Pin_Button,button_2	;���� ���� ���������, �� ��������� �� "���������" ����
		rjmp	main2

		rjmp	main

;####################################################
;"���������" ����
main2:	ldi		temp,signal_3		;�������� ���������� �� ��������� 3
		sbis	Pin_Button,button_1	;������� ��������� �������, ���� ������ �� ������
		swap	temp				;������ ������� �������
		out		PORTB,temp			;������� � ���� �
		rjmp	main2
