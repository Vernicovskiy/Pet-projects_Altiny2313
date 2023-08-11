/*
����������� ������� � ����������� �������� 
� �������� � �������� �� USART �� ��

���������������		ATtiny2313
�������� �������	8 MHz	
*/ 
.include "tn2313def.inc"

.equ	Encoder_Pin	=PIND
.equ	Pin_A		=PD4
.equ	Pin_B		=PD5

.def	temp		=R16
.def	FLAGS		=R17	;������� ������
.def	BUTTON		=R18	;������� ������

;������� �������� BUTTON
.equ	Encoder_L	=0		;���� �������� �����
.equ	Encoder_R	=1		;���� �������� ������

;������� �������� FLAGS
.equ	Encoder_Act		=0	;���� ��������� ��������� ��������
.equ	Encoder_Turn	=1	;���� ����������� ��������

;����������� ���������� USART
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
			
			ldi		temp,~(1<<Pin_A|1<<Pin_B)	;������ �������� �� ����
			out		DDRD,temp
			ldi		temp,(1<<Pin_A|1<<Pin_B)	;���������� �� ������ ������������� ���������
			out		PORTD,temp
			
			clr		BUTTON
			clr		FLAGS

			ldi		temp,high(SPEED)		;������ �������� ��� ������� �������� 
			out		UBRRH,temp				;�������� ������
			ldi		temp,low(SPEED)
			out		UBRRL,temp

			ldi		temp,(1<<UCSZ1|1<<UCSZ0)	;����� ������� ����� ������ 8 ���
			out		UCSRC,temp

			ldi		temp,(1<<RXEN|1<<TXEN)		;���������� ������ � ��������
			out		UCSRB,temp


;### ������� ���� ###
main:		rcall	Encoder
			rcall	Message
			rjmp	main

;#### �������� ��������� � ����������� �������� ####
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

;#### ��������� ��������� �������� ####
Encoder:	in		temp,Encoder_Pin			;��������� ������� PINX ����� ��������
			com		temp						;����������� ����������� ��������
			andi	temp,(1<<Pin_A|1<<Pin_B)	;��������� ������ ������ ��������
			brne	No_Neutral					;���� ������� � ����������� ���������,
			cbr		FLAGS,(1<<Encoder_Act)		;�� ���������� ��� ��������� ��������
			ret									;� �������
No_Neutral:	sbrc	FLAGS,Encoder_Act			;���� ������ � �������� ��� ���������,
			ret									;�� �������
			cpi		temp,(1<<Pin_A|1<<Pin_B)	;���� ��� ������ ��������,
			breq	Run							;�� ��������� �� ��������� ������� � ��������
			cbr		FLAGS,(1<<Encoder_Turn)		;������� �����
			sbrc	temp,Pin_B					;�������� ������ ��������
			sbr		FLAGS,(1<<Encoder_Turn)		;������� ������
			ret									
Run:		sbr		FLAGS,(1<<Encoder_Act)		;��������� ����� ��������� ������� � ��������
			sbr		BUTTON,(1<<Encoder_L)		;������� �����
			cbr		BUTTON,(1<<Encoder_R)		
			sbrc	FLAGS,Encoder_Turn			;�������� ����� ����������� ��������
			ret
			cbr		BUTTON,(1<<Encoder_L)		
			sbr		BUTTON,(1<<Encoder_R)		;������� ������
			ret


;#### �������� ����� ����� UART ####
out_com:	sbis	UCSRA,UDRE	;��������, ����� ��� UDRE 
			rjmp	out_com		;����� ���������� � 1 (���������� ���� ���������) 
			out		UDR,temp	;���������� ����
			ret

