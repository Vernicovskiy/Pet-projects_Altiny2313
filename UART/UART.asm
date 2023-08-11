/*
���������������� ������ ����� UART
������ ������ ������ ��� ������������� ����������.

��������:				9600 ���/�
������ ����� ������:	8 ���
���-�� ���� �����:		1
��������:				���

���������:
��� �������� ������ 9600 ���/� �������� ������� ������ ����
�� ���� 2 MHz.
��� ���� ��� ������ ���� 4 MHz ���������� ������������ ������� 
��������� ���������

���������������		ATtiny2313
�������� �������	8 MHz	
*/ 
.include "tn2313def.inc"

.def	temp		=R16
.def	loop		=R17	

.equ	XTALL	=8000000				;�������� ������� � ������
.equ	BAUD	=9600					;�������� ������ ������� � ���/�
.equ	SPEED	=(XTALL/(16*BAUD))-1	;���������� ������� ��� ��������� 
										;������� �������� ������
.cseg
.org	0x00
			rjmp	start

.org	0x20
start:		ldi		temp,RAMEND
			out		SPL,temp
			
			ldi		temp,high(SPEED)		;������ �������� ��� ������� �������� 
			out		UBRRH,temp				;�������� ������
			ldi		temp,low(SPEED)
			out		UBRRL,temp

			ldi		temp,(1<<UCSZ1|1<<UCSZ0)	;����� ������� ����� ������ 8 ���
			out		UCSRC,temp

			ldi		temp,(1<<RXEN|1<<TXEN)		;���������� ������ � ��������
			out		UCSRB,temp

;### ������� ���� ###
main:		rcall	in_com		;��������� ������
			cpi		temp,0x30	;���� ��� ��������� ���� 0x30 (� ���� ASCII ��� ������ '0')
			breq	Pr_Message	;�� � ����� ���������� ��������� 'Zero'
			inc		temp		;� ���� ������ ������, �� ����������� �������� ���� �� 1
			rcall	out_com		;� ���������� �������
			rjmp	main
Pr_Message:	rcall	message
			rjmp	main
		
message:	ldi		temp,'Z'	;�������� ��������� "Zero"
			rcall	out_com
			ldi		temp,'e'
			rcall	out_com
			ldi		temp,'r'
			rcall	out_com
			ldi		temp,'o'
			rcall	out_com
			ldi		temp,0x0A	;"������� ������" ������� ������� �� ������ ����
			rcall	out_com
			ldi		temp,0x0D	;"������� �������" ������� �� ������ ������� ������
			rcall	out_com
			ret

;#### �������� ����� ����� UART ####
out_com:	sbis	UCSRA,UDRE	;��������, ����� ��� UDRE 
			rjmp	out_com		;����� ���������� � 1 (���������� ���� ���������) 
			out		UDR,temp	;���������� ����
			ret

;#### ����� ����� ����� UART ####
in_com:		sbis	UCSRA,RXC	;��������, ����� ��� RXC ����� ���������� � 1 
			rjmp	in_com		;(� �������� ������ ���� �������� ������������� ����) 
			in		temp,UDR	;��������� �������� ����
			ret

