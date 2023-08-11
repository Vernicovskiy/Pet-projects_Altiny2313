;### ������������� ����� ###

.include "tn2313def.inc"

.def	temp		=R16

main:	ldi		temp,0x0F
		com		temp			;������� ����� � �������� ��� (�������� ��������): 0xFF - temp
		nop
		nop

		com		temp			;�������� �������
		nop
		nop

		neg		temp			;������� ����� � �������������� ���: 0x00 - temp
		nop
		nop
		neg		temp			;�������� �������
		nop
		com		temp			;������� � �������� ���  = �������� � ���������� �� 1
		inc		temp
		nop

		clr		R17
		sub		R17,temp		;������� � �������������� ��� � ���������� � R17
		nop
		nop

		ldi		temp,-0x0F		;�������� � ������� ��������������� ���� ����� -0x0F
		nop
		nop
		neg		temp			;�������������� � ������������� ����� 0x0F
		nop
		nop
		ldi		temp,-239		;� �������� temp ������������� ����� -239
		nop
		neg		temp			;� �������� temp ������������� ����� 239
		nop
		
		cln						;���� N ������� � 0
		ldi		temp,0b01111111
		inc		temp			;���� N ���������� � 1
		cln						;���� N ������� � 0
		nop
		nop
		sbr		temp,(1<<7)		;���� N ���������� � 1
		cln						;���� N ������� � 0

		ldi		temp,15
		subi	temp,20			;15-20 = 0xFB
		brpl	PC+2			;�������� ������� N. ���� N = 1, �� ����� �������������
		neg		temp			;���� ����� �������������, �� ����������� ��� � �������������
		nop						;��� � = 1 => ����� �������������

		ldi		temp,20
		subi	temp,15			;20-15 = 0x05
		brpl	PC+2
		neg		temp
		nop						;��� � = 0 => ����� �������������

		ldi		temp,-15
		subi	temp,20			;-15 - 20 = 0xF1 - 20 = 241 - 20 = 221
		brpl	PC+2
		neg		temp			;15 + 20 = 35
		nop						;��� � = 1 => ����� �������������


;#### �������� ��� � ��������� ####
		ldi		temp,0x10
		subi	temp,-0x20		;�������� ����� 0�10 � 0�20. ��� 0�10 - (-0�20) = 0�10 - 0��0 = 0x30
		nop						;���� ������������ � = 1
		nop

		ldi		temp,0xF0
		subi	temp,-0xF0		;�������� ����� 0�F0 � 0�F0. ��� 0�F0 - (-0�F0) = 0�F0 - 0�10 = 0xE0
		nop						;���� ������������ � = 0
		nop


;#### �������� 16-������ �������� ��� ������������ ####
.equ	const1	=0xC5D0
.equ	const2	=0x02C0

		ldi		ZL,low (const1)
		ldi		ZH,high(const1)

		subi	ZL,low (-const2)	;�������� const2 � const1
		sbci	ZH,high(-const2)	;������������ ���, �� ���� � ���������� � 1

;#### �������� 16-������ �������� � ������������� ####
.equ	const_1	=0xC5D0
.equ	const_2	=0xF2CF

		ldi		ZL,low (const_1)
		ldi		ZH,high(const_1)

		subi	ZL,low (-const_2)	;�������� const2 � const1
		sbci	ZH,high(-const_2)	;������������ ����, �� ���� � ������� � 0



;#### �������� 32-������ �������� ####
.equ	const4_1	=0x0FFEFDFC
.equ	const4_2	=0x0F0E0D0C

		ldi		R16,byte1(const4_1)
		ldi		R17,byte2(const4_1)
		ldi		R18,byte3(const4_1)
		ldi		R19,byte4(const4_1)

		subi	R16,byte1(-const4_2)
		sbci	R17,byte2(-const4_2)
		sbci	R18,byte3(-const4_2)
		sbci	R19,byte4(-const4_2)	;������������ ���, �� ���� � ���������� � 1


		rjmp	main
