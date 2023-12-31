/*		������� ����������� � �������������� ������� T0


���������������:	ATtiny2313
�������� �������:	1 MHz
*/

.include "tn2313def.inc"

.def	temp	=R16

.cseg
.org	0x00
		rjmp	init	
		reti			;(0�01) ������� ���������� 0
		reti			;(0�02) ������� ���������� 1
		reti			;(0�03) ������ �������/�������� �1
		reti		    ;(0�04) ���������� � �������/�������� �1
		reti			;(0�05) ������������ �������/�������� �1
		rjmp	T0_Ovr	;(0�06) ������������ �������/�������� �0
		reti			;(0�07) USART, ����� ��������
		reti			;(0�08) ������� ������ USART ����
		reti			;(0�09) USART, �������� ���������
		reti			;(0�0A) ���������� �� �����������
		reti			;(0�0B) ���������� �� ��������� �� ����� ��������
		reti			;(0�0C) ���������� � �������/�������� �1
		reti			;(0�0D) ���������� � �������/�������� �0
		reti			;(0�0E) ���������� � �������/�������� �0
		reti			;(0�0F) USI ��������� ����������
		reti			;(0�10) USI ������������
		reti			;(0�11) EEPROM ����������
		reti			;(0�12) ������������ ����������� ������

;�������������
init:	ldi		temp,RAMEND	;������������� �����
		out		SPL,temp
		
		ser		temp		;���� � �� �����
		out		DDRB,temp
		out		PORTB,temp

		ser		temp
		out		PORTD,temp	;���� D �� ����


/*
������� TIMSK ���������/��������� ��������� ���������� ��� �������� �0 � �1 
�������� �������� TIMSK �� 227 ��������
���� ������� �������� � ����, �� ��������������� ���� �������� ����������, ���������

��� ������� �0:
TOIE0 	���������� �� ������������ ������� �0 
		������������ - ����� ������� ������� ������� ��������� � 255 �� 0

OCIE0A	���������� �� ���������� �������� �������� TCNT0 ������� �0	� ��������� ���������� OCR0A

OCIE0B	���������� �� ���������� �������� �������� TCNT0 ������� �0	� ��������� ���������� OCR0B
*/

		ldi		temp,(1<<TOIE0)
		out		TIMSK,temp
;� �������� TIMSK ���������� ��� TOIE0, �������������,
;��� ������������ ������� �0 ��������� ���������� 
;�� ������������ ������� �0 (������ ���������� ���������� �� ������ 0�06)



/*
������� TCCR0B - ������� ���������� �������� �0
�������� �������� TCCR0B �� 238 ��������
���� CS02,CS01,CS00 �������� �� ������������ ������� ������� �0

CS02=0 CS01=0 CS00=0	������ ����������
CS02=0 CS01=0 CS00=1	��������  1
CS02=0 CS01=1 CS00=0	��������  8
CS02=0 CS01=1 CS00=1	��������  64
CS02=1 CS01=0 CS00=0	��������  256
CS02=1 CS01=0 CS00=1	��������  1024

CS02=1 CS01=1 CS00=0	������� �������� ������ �� ����� �0. ���� �� ���������� ������
CS02=1 CS01=1 CS00=1	������� �������� ������ �� ����� �0. ���� �� ������������ ������
*/

		ldi		temp,(0<<CS02|0<<CS01|1<<CS00) ;������� 1
		out		TCCR0B,temp
;CS02=0 CS01=0 CS00=1 , �������������, ������ �������� �� �������: (�������� �������)/1 = �������� �������
;������ ������ ������� ������ ����� ����, ��� � ������� TCCR0B
;����� ������� ����������� ������� �������� �� ����
		
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		clr		temp
		out		TCNT0,temp	;������������� �������� ������
		nop
		nop
		nop
		nop
		nop

		ldi		temp,100
		out		TCNT0,temp	;������������� ������ ��������� ��������
		nop
		nop
		nop
		nop
		nop
		
		clr		temp
		out		TCCR0B,temp	;������ ����������
		nop
		nop
		nop
		nop
		nop

		ldi		temp,(0<<CS02|0<<CS01|1<<CS00)
		out		TCCR0B,temp
;CS02=0 CS01=0 CS00=1 ��������  1 => ������ �������� �� ������� (�������� �������)/1 = 1000000/1 = 1000000 ��
;CS02=0 CS01=1 CS00=0 ��������  8 => ������ �������� �� ������� (�������� �������)/8 = 1000000/8 = 125000 ��
;CS02=1 CS01=0 CS00=1 ��������  1024 => ������ �������� �� ������� (�������� �������)/1024 = 1000000/1024 = 967 ��
;CS02=1 CS01=1 CS00=0 ������� �������� ������ �� ����� �0. ���� �� ���������� ������


		sei		;���������� ���������� ����������
;���� ������ ���������� �������� sei ��� I, �� ���������� ����������� �� �����
		
	;	ldi		temp,250
	;	out		TCNT0,temp	;������������� ������ ��������� ��������

MAIN:	rjmp	MAIN


;������������ ������� ���������� ���� ��� �� 256 ������ �������, �������������, 
;������� ������ ���������� = (������� �������)/256

T0_Ovr:
	;	ldi		temp,250
	;	out		TCNT0,temp	;������������� ������ ��������� �������� �������� �� ����

		sbi		PINB,0		;�������� ��������� ������ �� ���������������
		reti				;��������� ����������

;��� ��� ��� ������������ �� ������ ������ ������� ������� ������� ��������� ��� 
;������������ �������, �� ������� �� ������ � 2 ���� ���� ������� ������������ �������
;����� �������, ������� �� ������ �����: 
;F = (�������� �������)/[(����.������� �������) * 256 * 2]
;��� �������� ������� 1 MHz � ����. ������� 8, ������� �� ������ ��������:
;F = 1000000/(8 * 256 * 2) = 244,140625 Hz
