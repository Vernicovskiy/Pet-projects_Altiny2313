/*
�������� IR-������� �� HYPER TERMINAL ����� UART

����� ������ tsop-��������� ������ ���� ��������� �� ����� ������� (ICP) ������� �1
� ���������������� ATtiny2313 ����� ������� - PD6 (11)

��� ��������� �������� ���������� ���������� � �������� 
��������� ���������� ����� ������������ ��������� � ������� 
��������� ����������� �� 8 MHz

������������ ���������� �������� 			65535 ���
������������ ����� ���������� ����������	60

����������:			ATtiny2313
�������� �������:	8 MHz
*/
.include "tn2313def.inc"


.equ		Numbers_of_commands	=60				;����� ��������� ����� � ������, ������� ����� ���� �������

.def		temp		=R16
.def		loop		=R17
.def		numb		=R18
.def		data		=R19
.def		FLAGS		=R20

.equ		Buf_Full	=0						;���� ���������� ������

.equ		XTALL		=8000000				;�������� ������� ����������������
.equ		BAUD		=9600					;�������� ������ RS232
.equ		SPEED		=XTALL/(16*BAUD) - 1	;����������� ������� � �������� UBRR

.macro		ldi16
			ldi		@0H,high(@1)
			ldi		@0L,low (@1)
.endm
.macro		trans
			ldi		temp,@0
			rcall	Translate_USART
.endm
.macro		outi
			ldi		R16,@1
			out		@0,R16
.endm

;#### ������ ������ ####
.dseg
.org	0x60
BUFER:		.byte	(Numbers_of_commands * 2)	;����� ��� �������� 60 �������� �������� (1 �������� �������� 2 �����)

;#### �������� ��� ####
.cseg
.org	0x00
				rjmp	INIT
.org	ICP1addr
				rjmp	TIM1_CAPT				;������ �������
.org	OVF1addr
				rjmp	TIM1_OVER				;������������ �������


.org			INT_VECTORS_SIZE				;������ ������������ ����

INIT:			outi	SPL,RAMEND
				outi	PORTD,0xFF
				outi	PORTB,0xFF
				outi	UCSRB,(1<<TXEN)				;���������� ��������
				outi	UCSRC,(1<<UCSZ1|1<<UCSZ0)	;������ ������� - 8 ��� (UCSZ0=1, UCSZ1=1, UCSZ2=0)
				outi	UBRRH,high(SPEED)
				outi	UBRRL,low (SPEED)
				outi	TIMSK,(1<<TOIE1|1<<ICIE1)	;���������� �� ������������, ���������� �� �������
				

restart:		outi	TCCR1B,(1<<ICES1)		;������ �� ����������. ������ ����������
				outi	TCNT1H,0				;������� ������
				outi	TCNT1L,0
				ldi16	Y,BUFER
				clr		numb
				clr		FLAGS					;���������� ��� �����
				outi	TIFR,0xFF				;����� ���� ������ ����������
				sei
		

;#### �������� ���� ####
MAIN:			sbic	PIND,PD6				;����, ���� �� ������ �� �������� ����
				rjmp	MAIN
				outi	TCCR1B,(1<<ICES1|1<<CS11)	;������ �� ����������. ������� �� 8				
				sbrs	FLAGS,Buf_Full			;�������� ���������� ������
				rjmp	PC-1
				rcall	Translate_to_PC			;�������� ������ ���������� ������
				rjmp	restart


;���������� �� ������� �������
TIM1_CAPT:		outi	TCNT1H,0				;������� ������
				outi	TCNT1L,0

				ldi		data,(1<<ICES1)			
				in		temp,TCCR1B
				eor		temp,data				;�������� ���� ICES1
				out		TCCR1B,temp				

				in		temp,ICR1L				;��������� �������� �� ������� ������� � ���������� � BUFER
				st		Y+,temp
				in		temp,ICR1H				;������� ���������� ������� �������� �����
				st		Y+,temp			
		
				inc		numb
				cpi		numb,Numbers_of_commands
				breq	TIM1_OVER				;����� ��������
				reti
;���������� �� ������������ �������
TIM1_OVER:		sbr		FLAGS,(1<<Buf_Full)		;������������� ���� ���������� � ��������
				ret								;������ ���������� �� ������




;##### ��������� � �������� ������� ������ � HYPER TERMINAL ####
.macro			Print_STR
				trans	' '
				ldi		temp,(@0 + 0x30)
				rcall	Translate_USART
				trans	':'					
				trans	' '					
				rcall	Print_pulse_time		;������ �����	
				trans	' '					
.endm

Translate_to_PC:
				ldi16	Y,BUFER
				clr		loop
next_word:		inc		loop					;������ ������ ������
				clr		XH
				mov		XL,loop
				rcall	Calc_10
				trans	' '						;��� �������
				trans	' '

				Print_STR	0					;������ ������� "0: "
				
				dec		numb					;�������� �� ��������� �������
				breq	End_str

				Print_STR	1					;������ ������� "1: "
				trans	' '					
				trans	' '					

				sbiw	YL:YH,4					;���������� ������ ������� 0-�� � 1-�� ���������
				ld		XL,Y+
				ld		XH,Y+
				ld		temp,Y+
				add		XL,temp
				ld		temp,Y+
				adc		XH,temp

				trans	'('			
				rcall	Calc_10000				;������ ������ ������� 0-�� � 1-�� ���������
				trans	' '				
				trans	'u'			
				trans	's'			
				trans	')'			

				trans	0x0A					;������� �� ������ ������
				trans	0x0D			
				
				dec		numb
				brne	next_word

End_str:		trans	0x0A					;��������� ������ ������
				trans	0x0D			
				trans	0x0A					;������� �� ������ ������
				trans	0x0D			
				ret



.macro			Calc_xxx						;���������� � �������� �������� �����
				clr		data
check_xxx:		mov		temp,XL
				subi	temp,low(@0)
				mov		temp,XH
				sbci	temp,high(@0)
				brcc	sub_xxx
				rjmp	Print_xxx
sub_xxx:		subi	XL,low(@0)
				sbci	XH,high(@0)
				inc		data
				rjmp	check_xxx
Print_xxx:		rcall	Print_Number
.endm		

Print_pulse_time:
				ld		XL,Y+
				ld		XH,Y+
Calc_10000:		Calc_xxx	10000				;������ �������� �����
Calc_1000:		Calc_xxx	1000				;������ �����
Calc_100:		Calc_xxx	100					;������ �����
Calc_10:		Calc_xxx	10					;������ ��������
Calc_1:			mov		temp,XL					;������ ������
				subi	temp,-0x30
				rcall	Translate_USART
				ret


Print_Number:	mov		temp,data
				subi	temp,-0x30
Translate_USART:sbis	UCSRA,UDRE				;�������� �� USART
				rjmp	Translate_USART
				out		UDR,temp
				ret
