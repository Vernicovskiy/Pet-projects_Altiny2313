/*
������ � LCD ������� ���� HD44780

���������������:	ATtiny2313
�������� �������:	8 MHz
*/
.include "tn2313def.inc"
	
;### ����������� ������� ###
.equ	PORT_LCD	=PORTB		;���� ��� LCD-����������
.equ	DDR_LCD		=DDRB		;���� DDR ��� LCD-����������
.equ	RS			=2			;����� ����������  RS  (�������(0)/������(1))
.equ	E			=3			;����� ����������  E   (����� ������. �������� ��������� � 1 �� 0)
.equ	LCD_D4		=4			;����� ����������  D4  
.equ	LCD_D5		=5			;����� ����������  D5
.equ	LCD_D6		=6			;����� ����������  D6
.equ	LCD_D7		=7			;����� ����������  D7
;������ ���������: �� ������ ���������� RW (������/������) ������ ���� ������ ������� (������) 

;### ����� ��������� ��������� �������� ###
;���  1  MHz	 10
;���  4  MHz	 25
;���  8  MHz	 50
;��� 16  MHz	100
.equ	Const_Delay_LCD		=50

.def	temp	=R16
.def	loop	=R17

.cseg	
.org	0x00
		rjmp	init

.org	0x20
init:	ldi		temp,RAMEND
		out		SPL,temp

		rcall	Init_HD44780	;������������� ����������. ������������� ������� ��� ���������
	;	rcall	Init_HD44780_Prot

MAIN:	ldi		temp,0x30	;0
		rcall	jedat
		ldi		temp,0x31	;1
		rcall	jedat
;� ���������� ������� ����������� ������ 128 �����, 
;� ����������� �����, ��������� � �������� ASCII-��������.
;������� �� ��������� ����� �������� �������� ASCII �������.
		ldi		temp,'2'	;2
		rcall	jedat
		ldi		temp,3		;3
		rcall	jedat30		;������� jedat30 ������� ������� ������� � ������ 0x30 (������ ��������� ����)
		ldi		temp,'!'	;!
		rcall	jedat
		ldi		temp,'.'	;�����
		rcall	jedat
		ldi		temp,'*'	;*
		rcall	jedat
		ldi		temp,' '	;������
		rcall	jedat
		ldi		temp,'A'	;A
		rcall	jedat
		ldi		temp,'b'	;b
		rcall	jedat
		
		ldi		temp,(15 + 0x80);15 + 0x80 =15 + 128 = 143		(0x80 = 0b10000000, 7-� ��� � 1, �������������, ������ ������ DDRAM)
								;������� �������� �� 16-�� ���������� ������ ������, �.�. ������ ��������� ���� �� �������� ������
		rcall	jecom
		ldi		temp,'2'	;2
		rcall	jedat
		ldi		temp,'3'	;3
		rcall	jedat
		ldi		temp,'4'	;4
		rcall	jedat
		ldi		temp,'5'	;5
		rcall	jedat

		ldi		temp,(0 + 0xC0)	;0 + 0x40 + 0x80 = 0 + 0xC0 = 192
								;������� �������� �� 1-�� ���������� ������ ������
		rcall	jecom

		ldi		temp,'H'	
		rcall	jedat
		ldi		temp,'I'
		rcall	jedat
		ldi		temp,'!'
		rcall	jedat

		ldi		temp,' '	;������
		rcall	jedat

		ldi		temp,0xA8	;�
		rcall	jedat
		ldi		temp,0x70	;�
		rcall	jedat
		ldi		temp,0xB8	;�
		rcall	jedat
		ldi		temp,0xB3	;�
		rcall	jedat
		ldi		temp,0x65	;�
		rcall	jedat
		ldi		temp,0xBF	;�
		rcall	jedat

		rjmp	PC			;����������� ���������

;####  ������������� �������, ������������� ������ LCD ####
Init_HD44780:  
		sbi		DDR_LCD,E		;��������� ������� �� �����
		sbi		DDR_LCD,RS
		sbi		DDR_LCD,LCD_D4
		sbi		DDR_LCD,LCD_D5
		sbi		DDR_LCD,LCD_D6
		sbi		DDR_LCD,LCD_D7
		rcall   delay_LCD_44780
		ldi     temp,0b00000011	;��������� ������� � ��������� ���������. ������� �������
		rcall   jecom
		ldi     temp,0b00000011	;��������� ������� � ��������� ���������. ������� �������
    	rcall   jecom
		ldi     temp,0b00000011	;��������� ������� � ��������� ���������. ������� �������
    	rcall   jecom	
	    ldi     temp,0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7
		rcall   jecom
        ldi     temp,0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7
		rcall   jecom
        ldi     temp,0b00001000	;���������� �������
		rcall   jecom	           
		ldi     temp,0b00000001	;�������� �������
		rcall   jecom
		ldi     temp,0b00010000 ;������ ������ �����������
		rcall   jecom	
		ldi     temp,0b00000110 ;������������ ������� ������, ����� ������
		rcall   jecom	
		ldi     temp,0b00000010 ;��������� ������� � ��������� ���������. ������� �������
		rcall   jecom
		ldi     temp,0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7
		rcall   jecom				
        ldi     temp,0b00001100	;��������� �������. ������ ��������� �������. ������ �������� �������
		rcall   jecom
		ret
		
;####  ������������� ��� PROTEUS ####
Init_HD44780_Prot:
		sbi		DDR_LCD,E
		sbi		DDR_LCD,RS
		sbi		DDR_LCD,LCD_D4
		sbi		DDR_LCD,LCD_D5
		sbi		DDR_LCD,LCD_D6
		sbi		DDR_LCD,LCD_D7
		ldi		temp,0b00000010 ;��������� ������� � ��������� ���������. ������� �������
		rcall   jecom
		ldi		temp,0b00101000	;��������� ����������: ����������� 4 ����. 2 ������. ������ ������ 5�7
		rcall   jecom
		ldi		temp,0b00001100	;��������� �������. ������ ��������� �������. ������ �������� �������
		rcall   jecom	
		ret
		
;#### ����� ������ � ������ 0�30 ####
jedat30:subi    temp,-0x30		;����� ������ ������� � ������ 0x30. �� ����� ������ ������������� ������ ��������� ����
;#### ����� ������ ####
jedat:	sbi		PORT_LCD,RS		;��� ������ ������ RS = 1
		rjmp	PC+2
;#### ����� ������� ####
jecom:  cbi		PORT_LCD,RS		;��� ������ ������� RS = 0
;### ����� ����� � ���� ###
		rcall	outLCD			;������� ������� ������� � ����
        swap    temp			;������ ������� �������
		rcall	outLCD			;������� ������� ������� � ����
		rcall	delay_LCD_44780	;�������� 6,5 ��
		ret

;#### ����� ������� � ���� ####	
outLCD:	cbi		PORT_LCD,LCD_D4	;���������� ����� D4
		cbi		PORT_LCD,LCD_D5	;���������� ����� D5
		cbi		PORT_LCD,LCD_D6	;���������� ����� D6
		cbi		PORT_LCD,LCD_D7	;���������� ����� D7
		sbrc	temp,4			;���������� ��������� ������, ���� 4-� ������ = 0
		sbi		PORT_LCD,LCD_D4	;������������� � 1 ������ D4
		sbrc	temp,5			;���������� ��������� ������, ���� 5-� ������ = 0
		sbi		PORT_LCD,LCD_D5	;������������� � 1 ������ D5
		sbrc	temp,6			;���������� ��������� ������, ���� 6-� ������ = 0
		sbi		PORT_LCD,LCD_D6	;������������� � 1 ������ D6
		sbrc	temp,7			;���������� ��������� ������, ���� 7-� ������ = 0
		sbi		PORT_LCD,LCD_D7	;������������� � 1 ������ D7
		sbi     PORT_LCD,E		;������� �� ������ "�" ���������� ������� � LCD
		nop
        cbi     PORT_LCD,E
		ret
		
;#### ��������� �������� ####
;�������� �� ������� ������ ���������� 6,5 ��
delay_LCD_44780:
		push	temp
		ldi     temp,Const_Delay_LCD
dlylcd:	ldi		loop,25
		dec		loop
		brne	PC-1
		dec		temp
		brne	dlylcd
		pop		temp
		ret

