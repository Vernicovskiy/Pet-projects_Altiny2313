.include "tn2313def.inc"

.def	temp	=R16
.def	temp2	=R18
.equ	const	=0b10001101
		
		nop							;������ �������, ���������� 1 ���� (1 ���� ��� ������� 1 MHz = 1 ���)
		nop
		ser		temp 				;������������� �� ���� �������� �������� 1
		nop							;(���������� ldi  temp,0xFF)
;---------------------
		clr		temp				;���������� ������� (�� ���� �������� 0)
		nop			 				;(���������� ldi  temp,0x00)
;---------------------
		inc		temp 				;����������� �������� �������� �� 1
		inc		temp				;0x01
		inc		temp				;0x02
		ldi		temp,0xFE
		inc		temp				;0xFF
		inc		temp				;0x00
		inc		temp				;0x01
		nop
;---------------------
		ldi		temp,0x02
		dec		temp 				;��������� �������� �������� �� 1
		dec		temp				;0x00
		dec		temp				;0xFF
		nop
;---------------------
		ldi		temp,const
		com		temp 				;�������� �������� ��������
		nop			 				;(������������ ��������� 0xFF - const)
;---------------------
		ldi		temp,const
		neg		temp 				;������� � �������������� ���
		nop			 				;(�������� ��������, ����� ���������� �� 1)
;---------------------
		ldi		temp,0b11110000
		andi	temp,0b01010101		;���������� "�" �������� � ��������� 
		nop
;---------------------
		ldi		temp, 0b11110000
		ldi		temp2,0b01010101
		and		temp,temp2 			;���������� "�" ���� ��������� 
		nop
;---------------------
		ldi		temp,0b11110000
		ori		temp,0b01010101 	;���������� "���" �������� � ��������� 
		nop
;---------------------
		ldi		temp, 0b11110000
		ldi		temp2,0b01010101
		or		temp,temp2 			;���������� "���" ���� ��������� 
		nop
;---------------------
		ldi		temp, 0b11110000
		ldi		temp2,0b01010101
		eor		temp,temp2 			;"����������� ���" ���� ��������� 
		nop
;---------------------
		ser		temp
		cbr		temp,0b00101000 	;����� 3 � 5 ��������
		nop							;������������ andi temp,(0xFF - 0b00101000)
;---------------------
		clr		temp
		sbr		temp,0b00101000 	;��������� 3 � 5 ��������
		nop							;������������ ori temp,0b00101000
;---------------------
.equ	bit_5	=5
		sbi		DDRD,4				;���������� 4-� ����� ����� D �� �����
		sbi		DDRD,bit_5			;���������� 5-� ����� ����� D �� �����
		nop
;---------------------
.equ	bit_4	=4
		ser		temp
		out		DDRB,temp			;��� ������ ����� � �� �����
		out		PORTB,temp			;�� ���� ������� ���������� �������
		cbi		DDRB,bit_4			;4-� ����� ����� � ��������� �� ����
		cbi		PORTB,bit_5			;�������� 5-� ����� ����� � (�������� ���������� 0)
		sbi		DDRB,PB4			;4-� ����� ����� � ��������� �� ����� (PB4 = 4)
		sbi		PORTB,PD5			;���������� 5-� ����� ����� � (�������� ���������� 1) (PD5 = 5)
		nop
;---------------------
.equ	mask	=0b00110000			;������� (���������) �����
		in		temp,PIND			;��������� �������� ������� ����� D
		com		temp				;������������� �������� ����
		andi	temp,mask			;��������� ����� (��������� ���� ��������, ����� 5 � 4)
		nop


;���������� ������
		in		temp,0x17		;� ������� R16 ����� ��������� �������� �� �������� DDRB (����� 0x17 = DDRB)
		ldi		temp,PORTB		;� ������� R16 ����� ��������� ��������� 0x18 (.equ	PORTB	= 0x18)
		out		0x12,temp		;� ��� �� ������ 0x12 ����� �������� �������� �� temp (.equ	PORTD	= 0x12)
		cbr		temp,5			;� �������� ����� �������� ���� 0 � 2 (5 = 0b00000101)
		sbr		temp,0			;� �������� �� ���� ��� ���������� �� �����
		sbi		PORTB,0b00000110;� �������� ����� ���������� ��� 6 (6 = 0b00000110)
		cbi		PORTD,0b00000100;� �������� ����� ������� ��� 4 (4 = 0b00000100)
	//	ldi		temp,0���		;���������� ����� ���������� � ��������


;������������ �� ������ PB0 �������������� ������� � �������� 125 kHz (������ 8/1000000 Hz = 0,000008 ���)
main:	cbi		PORTB,PB0			;�� ������ PB0 ���� (2 ����� = 2 ���)
		nop							;1 ���� (1 ���)
		nop							;1 ���� (1 ���)
		sbi		PORTB,PB0			;�� ������ PB0 ������� (2 ����� = 2 ���)
		rjmp	main				;2 ����� (2 ���)






