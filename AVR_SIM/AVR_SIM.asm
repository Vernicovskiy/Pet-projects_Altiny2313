/*
���������������:	ATtiny2313
�������� �������:	1 MHz
*/

.include "tn2313def.inc"

.def	temp		=R16
.def	loop		=R17
.def	count		=R18

.cseg
.org	0x00	rjmp	init		;�������������
.org	0x05	rjmp	T1_over		;������������ �������/�������� �1
.org	0x20


;�������������
init:		ldi		temp,RAMEND		;������������� �����
			out		SPL,temp
		
			ser		temp			;���� � �� �����
			out		DDRB,temp
			out		PORTB,temp

			clr		temp
			out		DDRD,temp		;��� ������ �� ����.
			ser		temp
			out		PORTD,temp
			


;��������� ������� �1

			ldi		temp,(1<<TOIE1)
			out		TIMSK,temp

			ldi		temp,(0<<CS12|0<<CS11|1<<CS10) ;������� 1
			out		TCCR1B,temp

			rcall	T1_over			;���������� ���������� ����������



;##### �������� ���� #####	
MAIN:		rcall	klav			;����� ������������ ���������� ��������� ������
			brtc	PC+2
			rcall	Count_Up		;������������ ���������� ��������
			rjmp	MAIN


;������������ ���������� �������� ��������
Count_Up:	inc		count
			ret


;������������ ���������� ��������� ������
klav:		clt
			sbic	PIND,PD0		;�����, ���� ������ �� ������
			ret
			rcall	delay			;�������� ������ ��������
			sbis	PIND,PD0		;�������� ���������� ������
			rjmp	PC-1
			rcall	delay			;�������� ������ ��������
			set						;��������� ����� � - ������� ������� ������
			ret
;��������
delay:		ldi		loop,0xFF		;������� � ������� �������� �������� ����������
			dec		loop			;��������� �� ������� ��������
			nop
			nop
			nop
			brne	delay+1			;����, ���� �� ����
			ret



;### ���������� �� ���������� � ������ A ###
T1_over:	in		R5,SREG			;��������� ������� �������
			out		PORTB,count
			out		SREG,R5			;��������������� ������� �������
			reti


