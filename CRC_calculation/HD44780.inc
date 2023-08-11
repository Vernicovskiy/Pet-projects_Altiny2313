/*
���������� 2-���������, 16-����������� LCD ������ �� ���� HD44780
������������ ����������� �� 4-��������� ���� ������
��������� ��������� �������� �� ������ � ������ ������ (����� RW = 0)

��������! 
����� �������������� ���������� ���������� ��������� ���������:
1. ���������� ������ ��� ����������� � ����������
2. ������� ��������� ��������� �������� Const_Delay_LCD, � ����������� �� �������� �������

� ���������� ������������ ��������� ��������:
R16		� �������� �������������
R17		� ������������ �������� delay_LCD_44780
ZL � ZH ������������ � ������������ OutRow, �� ����� �������������� ����������� � �����
*/


			;################### � � � � � � � � ! ! ! #################
			;���������� �������� �� ��������� �� ����������� ����������� �����

			
;### ����������� ������� ###
.equ	PORT_LCD	=PORTD		;���� ��� LCD-����������
.equ	DDR_LCD		=DDRD		;������� ����������� ������ ��� LCD-����������
.equ	RS			=0			;����� ����������  RS  (�������(0)/������(1))
.equ	E			=1			;����� ����������  E   (����� ������)
.equ	LCD_D4		=2			;����� ����������  D4  
.equ	LCD_D5		=3			;����� ����������  D5
.equ	LCD_D6		=4			;����� ����������  D6
.equ	LCD_D7		=5			;����� ����������  D7

;### ����� ��������� ��������� �������� ###
;���  1  MHz	 10
;���  4  MHz	 25
;���  8  MHz	 50
;��� 16  MHz	100
.equ	Const_Delay_LCD		=90

;====================== �������� ������� ============================
;#### ������������� �������, ������������� ������ LCD ####
.macro	Init_HD44780
		rcall	Init_LCD_HD44780
.endm
;####  ������������� ��� PROTEUS ####
.macro	Init_HD44780_Proteus
		rcall	Init_LCD_HD44780_Proteus
.endm
;#### ����� ������� ####
.macro	cmd
		ldi		R16,@0
		rcall	jecom
.endm
;#### ����� ������ ####
.macro	dat
		ldi		R16,@0
		rcall	jedat
.endm
;#### ����� ������ � ������ 0x30 ####
.macro	dat30
		ldi		R16,@0 + 0x30
		rcall	jedat
.endm
;#### ������� �� ������ ������ ���������� ####
.macro	First_Line
		cmd		2
.endm
;#### ������� �� ������ ������ ����������  ####		
.macro	Second_Line
		cmd		192
.endm	
;#### ������� �� XX ���������� ������ ������ (1..16) ####
.macro	row1
		ldi		R16,(@0 - 1 + 0x00 + 0x80)
		rcall	jecom
.endm
;#### ������� �� XX ���������� ������ ������ (1..16) ####
.macro	row2
		ldi		R16,(@0 - 1 + 0x40 + 0x80)
		rcall	jecom
.endm
;#### ����� �� ��������� ������ �������� ####
.macro	Row
		push	ZL
		push	ZH
		ldi		ZH,high(@0*2)
		ldi		ZL,low (@0*2)
		rcall	OutRow
		pop		ZH
		pop		ZL
.endm
;#### ����� �� ��������� ������������������ �������� ����� ####
.macro	Hex
		ldi		R16,@0
		rcall	prHEX
.endm
;====================================================================

;####  ����� �� ��������� ������ �������� ####
OutRow:	lpm		R16,Z+		;��������� � ������� R16 ������ ������ ������ ��������
		cpi		R16,0		;���� R16 �� ����� 0, �� ���������� �����
		breq	PC+3		;� ���� �����, �� ������� �� ������������
		rcall	jedat		;������� ������
		rjmp	OutRow		;��������� � ���������� ������� ������
		ret
		
;####  ����� �� ��������� ������������������ �������� ����� ####
prHEX:	push	R16
		swap	R16
		rcall	print4		;������ ������� �������
		pop		R16			;������ ������� �������
print4:	andi	R16,0x0F	;�������� ������� �������
		cpi		R16,10
		brcs	PC+2		;���� �������� ������ 10, �� ����� �� ������
		subi	R16,-0x7	;���� ������, �� ��������� � ������ �������� (����� 7 ������ ����� ����� 9)
		rjmp	jedat30		;����� ������� �� ������

;===================== ������� ������������ =========================
;####  ������������� �������, ������������� ������ LCD ####
Init_LCD_HD44780:  
		sbi		DDR_LCD,E		;��������� ������� �� �����
		sbi		DDR_LCD,RS
		sbi		DDR_LCD,LCD_D4
		sbi		DDR_LCD,LCD_D5
		sbi		DDR_LCD,LCD_D6
		sbi		DDR_LCD,LCD_D7
		rcall	delay_LCD_44780
		cmd		0b00000011	;��������� ������� � ��������� ���������. ������� �������
		cmd		0b00000011	;��������� ������� � ��������� ���������. ������� �������
		cmd		0b00000011	;��������� ������� � ��������� ���������. ������� �������
		cmd		0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7
		cmd		0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7 (��� ���������� ��������� �������)
		cmd		0b00001000	;���������� �������
		cmd		0b00000001	;�������� �������
		cmd		0b00010000	;������ ������ �����������
		cmd		0b00000110	;������������ ������� ������, ����� ������
		cmd		0b00000010	;��������� ������� � ��������� ���������. ������� �������
		cmd		0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7
		cmd		0b00001100	;��������� �������. ������ ��������� �������. ������ �������� �������
		ret
		
;#### ����� ������ � ������ 0�30 ####
jedat30:subi	R16,-0x30		;����� ������ ������� � ������ 0x30. �� ����� ������ ������������� ������ ��������� ����
;#### ����� ������ � ������ 0�00 ####
jedat:	sbi		PORT_LCD,RS		;�� ������ RS ��������������� 1
		rjmp	PC+2
;#### ����� ������� ####
jecom:	cbi		PORT_LCD,RS		;�� ������ RS ��������������� 0
;### ����� ����� � ���� ###
		rcall	outLCD			;������� ������� ������� � ����
		rcall	outLCD			;������� ������� ������� � ����
		rjmp	delay_LCD_44780	;�������� 6,5 ��

;#### ����� ������� ������� � ���� ####	
outLCD:	cbi		PORT_LCD,LCD_D4	;���������� ����� D4
		cbi		PORT_LCD,LCD_D5	;���������� ����� D5
		cbi		PORT_LCD,LCD_D6	;���������� ����� D6
		cbi		PORT_LCD,LCD_D7	;���������� ����� D7
		sbrc	R16,4			;���������� ��������� ������, ���� 4-� ������ = 0
		sbi		PORT_LCD,LCD_D4	;������������� � 1 ������ D4
		sbrc	R16,5			;���������� ��������� ������, ���� 5-� ������ = 0
		sbi		PORT_LCD,LCD_D5	;������������� � 1 ������ D5
		sbrc	R16,6			;���������� ��������� ������, ���� 6-� ������ = 0
		sbi		PORT_LCD,LCD_D6	;������������� � 1 ������ D6
		sbrc	R16,7			;���������� ��������� ������, ���� 7-� ������ = 0
		sbi		PORT_LCD,LCD_D7	;������������� � 1 ������ D7
		sbi		PORT_LCD,E		;������� �� ������ "�" ���������� ������� � LCD
		swap	R16				;������ ������� ������� + ��������� �������� ������
		cbi		PORT_LCD,E
		ret
		
;#### ��������� �������� ####
;�������� �� ������� ����� 6,5 ��
delay_LCD_44780:	push	R16
					ldi		R16,Const_Delay_LCD
dlylcd:				ldi		R17,25
					dec		R17
					brne	PC-1
					dec		R16
					brne	dlylcd
					pop		R16
					ret
		
;####  ������������� ��� PROTEUS ####
Init_LCD_HD44780_Proteus:
		sbi		DDR_LCD,E
		sbi		DDR_LCD,RS
		sbi		DDR_LCD,LCD_D4
		sbi		DDR_LCD,LCD_D5
		sbi		DDR_LCD,LCD_D6
		sbi		DDR_LCD,LCD_D7
		cmd		0x02
		cmd		0x28
		cmd		0x0C
		ret
		