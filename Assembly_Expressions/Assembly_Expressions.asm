.include "tn2313def.inc"

.def	temp	=R16
.def	temp2	=R17

		ldi		temp,99.99999999999		;������� ����� ����� ���������. � ������� ����� ��������� 99 (0x63)

.equ	numb_1	=12.35					;numb_1 = 12
.equ	numb_2	=0.99999				;numb_2 = 0

		ldi		temp,numb_2*numb_1		;� ������� temp ����� �������� ����

.equ	Const_1	=(25 + 0x1A/3 + 0b00000100*3*numb_1 - numb_2 - 0x0F)	;

		ldi		temp,Const_1

		ldi		temp,(25 + 0x1A/3 + 0b00000100*3 - 0x0F)
		ldi		temp,(184/3)			;� ������� ����������� 61
;		ldi		temp,(187/2*4)			;������! �������� ������ 0�FF (255)
		ldi		temp,(187/(2*4))

;---------------------
		ldi		temp,high(0x1234)		;��������� ������� ���� ����� (0x12)
		ldi		temp2,low(0x1234)		;��������� ������� ���� ����� (0x34)
;---------------------
.equ	const3	=987*7.5679 			;987*7.5679 = 7469 = 0x1D2D
		ldi		temp,high(const3)		;��������� ������� ���� �����
		ldi		temp2,low(const3)		;��������� ������� ���� �����
		nop
		
		ldi		temp,-34				;� ������� temp �������� ���� (������������� ����� -34)

		ldi		R17,byte1(0x12345678)	;� ������� R16 �������� ���� 0x78
		ldi		R18,byte2(0x12345678)	;� ������� R17 �������� ���� 0x56
		ldi		R19,byte3(0x12345678)	;� ������� R18 �������� ���� 0x34
		ldi		R20,byte4(0x12345678)	;� ������� R19 �������� ���� 0x12

		ldi		temp,'A'				;� ������� temp �������� ���� 0x41 (ascii ��� ����� A)
		ldi		temp,'g'				;� ������� temp �������� ���� 0x67 (ascii ��� ����� g)

;---------------------
		ldi		temp,~0b11110000 		;�������� ���������
		nop
;---------------------
.equ	Z0		=0
.equ	Z1		=1
.equ	Z2		=2

;����� ==
		ldi		temp,(Z1==Z1)			;������� Z1==Z1 ����������� => ���������� ����� 1
		ldi		temp,(Z1==Z2)			;������� Z1==Z1 ������������� => ���������� ����� 0

;������� !=
		ldi		temp,(Z1!=Z2)			;������� Z1!=Z1 ����������� => ���������� ����� 1

;������ >
		ldi		temp,(Z1>Z2)			;������� Z1>Z1 ������������� => ���������� ����� 0

;��������� !
		ldi		temp,!(Z1>Z2)			;������� Z1>Z1 ������������� => ���������� ����� !(0) = 1



;����������� ����� �����
		ldi		temp,(0b00001100<<3)	;����� ��������� �� ��� ������� ������ 0b01100000
		ldi		temp,(0b00001100<<1)	;����� ��������� �� ���� ������ ������ 0b00011000
		ldi		temp,(0b00001100>>3)	;����� ��������� �� ���� ������ ������ 0b00000001
		ldi		temp,(0b00001100>>1)	;����� ��������� �� ���� ������ ������ 0b00000110

;����� ������ ������������ ������� �� 2
;����� ����� ������������ ��������� �� 2
		ldi		temp,4<<3				;4*2^3 = 32 (0x20)
		ldi		temp,555>>3				;555/2^3 = 69,375 = 69 (0x45)


.equ	BIT_Reg	=6
		ldi		temp,(1<<BIT_Reg)	;������� ��������� �� 6 �������� ����� = ��������� � 1 ������� �������
		nop
		ldi		temp,(1<<0)			;������� ��������� �� 0 �������� ����� = ��������� � 1 �������� �������
		nop
		ldi		temp,exp2(3)		;� ������� ��������� 2^3 = 8 = 0b00001000 (�� �� ����� ��� � (1<<3))
		nop
		ldi		temp,exp2(BIT_Reg) 	;� ������� ��������� 2^6 = 64 = 0b001000000 (�� �� ����� ��� � (1<<6))
		nop
		ldi		temp,(8>>3)			;����� 8 (0b00001000) �������� �� 3 ������� ������



		ldi		temp,(1<<3|1<<5) 		;ldi temp,0b00101000
;������� �������� �� 3 ������� ����� ����� ��������� ������������ "���" 
;���������� � ������, � ������� ������� �������� �� 5 �������� �����

	;	ldi		temp,(1<<3 + 1<<5) 		;ldi temp,0b00101000
		ldi		temp,(1<<3)|(1<<5) 		;ldi temp,0b00101000
		ldi		temp,(1<<3)+(1<<5) 		;ldi temp,0b00101000
		nop
		ldi		temp,(1<<3|1<<5|1<<0) 	;ldi temp,0b00101001
		nop

		ldi		temp,0b11110000 & 0b10101110	;����������� ���������� ��������� 
		 
		ser		temp
		cbr		temp,(1<<3) 			;�������� 3-� ���
		cbr		temp,exp2(4) 			;�������� 4-� ���
		nop
		clr		temp
		sbr		temp,(1<<0) 			;���������� 0-� ���
		sbr		temp,exp2(7) 			;���������� 7-� ���
		nop
;---------------------
.equ	bit_4	=4
		ser		temp
		cbr		temp,(1<<bit_4)			;�������� 4-� ���
		nop
		sbr		temp,(1<<bit_4)			;���������� 4-� ���

;---------------------
.equ	bit_5	=5
		ser		temp
		cbr		temp,(1<<bit_4|1<<bit_5);�������� 4-� � 5-� ���
		ser		temp
		cbr		temp,(0<<bit_5|1<<bit_4);��������� ������ 4 ���
		ser		temp
		cbr		temp,(0<<bit_5|0<<bit_4);������� ������� ��� ���������
		nop
;---------------------
		clr		temp
		sbr		temp,(1<<bit_4|1<<bit_5);���������� 4-� � 5-� ���
		nop

zzz:	rjmp	zzz