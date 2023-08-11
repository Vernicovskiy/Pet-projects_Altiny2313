/*
����������� ��������� ����������
��������� ���������� ������������ ��������� ����������
� ��� ����������� ������� ������, ������� �� �������� ����� 
� ���� D. ���� �� ���� ������ �� ������, �� � ���� ������������
����.

��������� ���������� ������� �� 4 ����� � 4 ��������:
������� 4 ������� ����� - ������� 
������� 4 ������� ����� - ������

��������!
������ � ������� 1 ������ ���������� �� 
����������� 1-�� ������ (4-� ������) � 1-��� ������� (0-� ������)

������ 3 - 3-� ������ (6-� ������) � 1-� ������� (0-� ������)

������ 10 - 2-� ������ (5-� ������) � 3-� ������� (2-� ������)

������ 16 - 4-� ������ (7-� ������) � 4-� ������� (3-� ������)

���������������		ATtiny2313
�������� �������	1 MHz
*/

.include "tn2313def.inc"

.equ	PIN_key		=PINB
.equ	PORT_key	=PORTB

.def	temp	=R16
.def	loop	=R17

.cseg
.org	0x00
		rjmp	init

.org	0x20
init:		ldi		temp,RAMEND
			out		SPL,temp
			
			ser		temp		;���� D �� �����
			out		DDRD,temp

;��� ����������� ��������� ���������� ������������ ���� ���� �
;������� 4 ������� ����� � ����������� �� �����
;������� 4 ������� - �� ���� � �������������� �����������
			ldi		temp,0x0F	
			out		DDRB,temp
			ldi		temp,0xF0
			out		PORTB,temp


;#### �������� ���� ####
main:		rcall	Keyboard	;����� ������������ ���������� ��������� ����������
			out		PORTD,loop	;� ���� D ������������ �������� �������� loop 
			rjmp	main


;### ����� ���������� ###
Keyboard:	ldi		temp,0b11111110	;������� ������ ����� � ���� (���������� 1-� �������)
			rcall	Ch_pin			;�������� ������������ ������ �����
			tst		loop			;��������� �� ���������� ������� ������
			breq	COL_2			;���� �� ���� ������ �� ������, �� ��������� � ���������� �������
			subi	loop,-0			;��� ������� ������. �������� � ������� ����� ��� ��������� ���������� ����
			ret						;���� ������ ��������� �������, �� ������� �� ������������
COL_2:		ldi		temp,0b11111101	;������ ������ ����� � ���� (2-� �������)
			rcall	Ch_pin
			tst		loop
			breq	COL_3
			subi	loop,-4			;������ ������ �� ������ ������� ���������� � 5 
			ret						;����� ���������� ������ ������� ������, ������� �� ������������
COL_3:		ldi		temp,0b11111011	;������ ������ ����� � ���� (3-� �������)
			rcall	Ch_pin
			tst		loop
			breq	COL_4
			subi	loop,-8			;������ ������ � ������� ������� ���������� � 9
			ret						;����� ���������� ������ ������� ������, ������� �� ������������
COL_4:		ldi		temp,0b11110111	;������ ������ ����� � ���� (4-� �������)
			rcall	Ch_pin
			tst		loop
			breq	Exit_Col			;���� � 4-�� ������� �� ���� ������ �� ������, �� �������
			subi	loop,-12		;������ ������ � ��������� ������� ���������� � 13
Exit_Col:	ret						;����� ���������� ������ ������� ������, ������� �� ������������

;������������ ���������� ������
Ch_pin:		
			out		PORT_key,temp	;�������� ����� ����� (�������� ������ �������)

			ldi		loop,0b11111111	;� ��������������� ������� ��������� 0xFF
			eor		temp,loop		;�������� �������� � temp
			out		DDRB,temp		;��������� �� ����� ������ ���� �����
			
			clr		loop			;������� ���������� ����, ���� �� ���� ������ � ������� �� ����� ������
			in		temp,PIN_key	;��������� ��������� ������
			com		temp			;����������� (����� �������� ������� ������ - ���. 1)
			andi	temp,0b11110000	;�������� �������� ������� �������
LINE_4:		cpi		temp,0b10000000	;��������� �� ��������� 4-� ������
			brne	LINE_3
			ldi		loop,4			;���������� ����� ������ � ������
			ret
LINE_3:		cpi		temp,0b01000000	;��������� �� ��������� 3-� ������
			brne	LINE_2
			ldi		loop,3
			ret
LINE_2:		cpi		temp,0b00100000	;��������� �� ��������� 2-� ������
			brne	LINE_1
			ldi		loop,2			
			ret
LINE_1:		cpi		temp,0b00010000	;��������� �� ��������� 1-� ������
			brne	No_BUT			;��������� �� No_BUT, ���� �� ���� ������ � ������� �� ������
			ldi		loop,1
No_BUT:		ret						;�� ���� ������ �� ������, � �������� loop ����
