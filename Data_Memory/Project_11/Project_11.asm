
/*������ � ������� ������*/

.include "tn2313def.inc"

.def	temp	=R16

;#############################
;### ������� ������ ������ ###
;#############################
.dseg
.org	0x60		;������ ������ ������ ���������� � ������ 0�60 ����� �� ���

cell:	.byte	2	;���������� ��� ������ cell 2 �����
					;������ ���� ������ cell ���������� �� ������ 0�60
					;������ ���� - �� ������ 0x61

cell_2:	.byte	3	;������ ���� ������ cell_2 ���������� �� ������ 0�62. 
					;������ � ������ - 0�63 � 0�64

cell_3:	.byte	1	;���� ������ cell_3 ���������� �� ������ 0�65


;###############################
;### ������� ������ �������� ###
;###############################
.cseg
.org	0x10					;����������� ������� ������� � ������ 0�10

		ldi		temp,0x65		;��������� � ������� temp ���������

		ldi		YL,low (cell) 	;�������� � YL �������� ����� ������ ������ ������ cell (0x60)
		ldi		YH,high(cell)	;�������� � Y� �������� ����� ������ cell (0x00)
		
		;��������� ������� ��������� �� �� �����, ��� � ���������� ���:
		ldi		YL,low (0x60) 	;�������� � YL �������� ����� ������ ������ ������ (0x60)
		ldi		YH,high(0x60)	;�������� � Y� �������� ����� ������ (0x00)

		;��������� ������� ��������� �� �� �����, ��� � ���������� ���:
		ldi		YL,0x60		 	;�������� � YL �������� ����� ������ ������ ������ (0x60)
		ldi		YH,0x00			;�������� � Y� �������� ����� ������ (0x00)
		
		;��������� ������� ��������� �� �� �����, ��� � ���������� ���:
		ldi		YL,cell 		;�������� � YL ����� ������ ������ ������
		clr		YH

		;##############################
		;������ ������ �� ������ ������
		;##############################
		
		;������ � ������ ���� ������ ������ � ������� 0�60
		st		Y,temp	;���������� ���������� �������� temp � ������ ������ 0x60
		inc		YL		;����������� ����� 
		st		Y,temp	;� ������ �� ������ 0�61 ���������� ���������� �������� temp
		inc		YL		;����������� ����� 
		st		Y+,temp	;���������� ���������� �������� temp � ������ ������ 0x62
						;����� � �������� ������������� ���������� �� 1
		st		Y+,temp	;���������� ���������� �������� temp � ������ ������ 0x63
		ldi		temp,0x80
		st		-Y,temp	;����� ���������� �� 1, ����� ��������� ������
		
		ldi		temp,0xFA

		ldi		YL,low (cell_2) ;�������� � YL �������� ����� ������ ������ ������ cell_2 (0�62)
		ldi		YH,high(cell_2)	;�������� � Y� �������� ����� ������ cell_2 (0x00)
		
.equ	const = 5

		std		Y + const,temp		;�� ������ 0�62 + 0x05 = 0�67 �������� ���������� temp
		std		Y + 1,temp			;�� ������ 0�62 + 0x01 = 0�63 �������� ���������� temp
		std		Y + const + 1,temp	;�� ������ 0�68 �������� ���������� temp
		
		ldi		temp,0x10
		
		ldi		XL,low (cell_3 + 1)	;� ������� � ��������� ����� cell_3+1 (0�66)
		ldi		XH,high(cell_3 + 1)	;� ������� � ��������� ����� cell_3+1 (0�66)
		
		st		-X,temp	;�������� � ������ cell_3 (0x65) ���������� temp
		st		X+,temp	;�������� � ������ c ������� 0x65 ���������� temp
		st		X+,temp	;�������� � ������ c ������� 0x66 ���������� temp
		st		X,temp	;�������� � ������ c ������� 0x67 ���������� temp


		;���������������� ������ � ������ ������
		ldi		temp,0x11
		sts		cell_3,temp	 	;�������� � ������ �� ������ 0�65 �������� temp
		sts		cell_3+1,temp	;�������� � ������ �� ������ 0�66 �������� temp
		sts		0x70,temp		;�������� � ������ �� ������ 0�70 �������� temp

/*######################################################
� ��� � ��� ����� ���������� ��� � ������� ������ ������
#######################################################*/

;������ � ������� SREG (������������� ����� T,H,S,V)
		ldi		temp,(1<<6|1<<5|1<<4|1<<3)
		sts		0x5F,temp			;�������� � ������ �� ������ 0�5F �������� temp
		ldi		temp,(1<<6|0<<5|1<<4|0<<3)
		sts		SREG + 0x20,temp	;������ ����� ������ ������ �� 0�20 ������, ��� ������ ���

		sts		DDRD+0x20,temp		;������ � ��� DDRD ��� � ������ ���

;������ � ������� R0:
		ldi		temp,0x55
		sts		0x00,temp 			;�������� � ������ �� ������ 0�00 �������� temp
;������ � ������� R16 (temp):
		sts		0x10,temp 			;�������� � ������ �� ������ 0�10 (temp) �������� temp
;������ � ������� R17:
		sts		0x11,temp 			;�������� � ������ �� ������ 0�11 �������� temp


/*######################################################
RAMEND - ��������� �� ����� ��������, ���������� ����� 
��������� ����� ��������� ������ ������ ������.
��� ATtiny2313 RAMEND = 0xDF
#######################################################*/

		sts		RAMEND,temp ;�������� � ��������� ������ ������ �������� temp

		
/*######################################################
��������� ������ �� ������������� ������ ���������������
��������������� �����
#######################################################*/
.equ	numb	=10		;���������, ������������ ������� ����� ��������
.equ	adress	=0x60	;���������, ������������ � ������ ������ ������ ������
.equ	content	=0x10	;���������, ������������ ��������� �����

		ldi		temp,content
		ldi		ZL,low (adress)		;������������� ��������� �����
		ldi		ZH,high(adress)
write_to_ram:
		st		Z+,temp						;���������� ���������� temp � Z
		inc		temp						;����������� temp �� 1
		cpi		temp,low(numb + content)	;���������� � ������� ������ ��������� (numb + content)
		brne	write_to_ram				;���� temp �� �����, �� ������� �� write_to_ram


		;##############################
		;������ ������ �� ������ ������
		;##############################
		
		ldi		ZL,low (cell) 	;�������� � ZL �������� ����� ������ ������ ������ cell (0x60)
		ldi		ZH,high(cell)	;�������� � Z� �������� ����� ������ cell (0x00)

		ld		temp,Z		;��������� �� ������ 0�60 ������ � temp
		inc		ZL
		ld		R17,Z+		;��������� �� ������ 0�61 ������ � R17
		clr		temp
		ld		temp,-Z		;��������� �� ������ 0�61 ������ � temp
		ldd		temp,Z + 4	;��������� �� ������ 0�65 ������ � temp
		
		lds		temp,0x70 	;���������������� ������ �� ������ 0x70

		rjmp	PC		;����������� ���������

