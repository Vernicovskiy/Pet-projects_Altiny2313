/*	���������� ��������� ������� � ���� �� ���������� 
����� ��������� ������� DS1307

����� ������ ������������ �� ��������� ���� HD44780

���������������		ATtiny2313
�������� ������� 	8 MHz
*/
.include "tn2313def.inc"


.def	temp		=R16

.equ	Data_Cell	=0						;����� ������ � ����������� ������ DS1307 (0..55)


.dseg
.org		0x60
Data_Time:	.byte	7						;����������� 7 ���� ������ ������ ��� �������� ��������� ���� ��� ���� ��� ������

.cseg
			rjmp	start
.include "HD44780.inc"						;����������� ���������� ��� ������ � ����������� HD44780
.include "DS1307.inc"						;����������� ���������� ��� ������ � DS1307 (+ ���������� I2C)


start:		ldi		temp,RAMEND
			out		SPL,temp

			ldi		temp,0xFF
			out		PORTD,temp
			out		PORTB,temp
			
			rcall	Init_LCD_HD44780		;������������� ���������� HD44780

			rcall	Init_DS1307				;������������� DS1307
			brtc	PC+2					;���� � = 1, �� ���� ���������� ������� 
			rcall	Set_Time_and_Data		;��������� ������� � ����

			rcall	Inc_Cell_Ram			;������������ ���������� ����������� ������ Data_Cell ������ ������ DS1307



;�������� ����	
MAIN:		Read_7Byte_DS1307	Data_Time	;���������� 7 ������ ��������� � 7 ����� ������ ������

			ldi		ZH,high(Data_Time)		;�������� � temp ������ ������ ������ Data_Time
			ldi		ZL,low (Data_Time)

;������ �������:
			First_Line						;������� �� ������ ������ ����������
			Row		Time					;������ "Time:"
			ldd		temp,Z+2				;�������� � temp ������� ����� (����)
			rcall	prHEX
			dat		':'							
			ldd		temp,Z+1				;�������� � temp ������� ����� (������)
			rcall	prHEX
			dat		':'				
			ldd		temp,Z+0				;�������� � temp �������� ����� (�������)
			rcall	prHEX
			dat		' '

;������ ����� �� ������ RAM
			ldi		R16,Data_Cell
			rcall	Read_RAM_DS1307			;���������� � ������� R16 ����� �� ������ RAM � ������� Data_Cell
			rcall	prHEX					;����� �� ��������� ����������� R16


;������ ����:
			Second_Line						;������� �� ������ ������ ����������
			Row		Data					;������ "Data:"
			ldd		temp,Z+4				;�������� � temp ���������� ����� (����)
			rcall	prHEX
			dat		'.'
			ldd		temp,Z+5				;�������� � temp ������ ����� (�����)
			rcall	prHEX
			dat		'.'
			ldd		temp,Z+6				;�������� � temp ������ ����� (���)
			rcall	prHEX
			dat		' '
			ldd		temp,Z+3				;�������� � temp �������� ����� (���� ������)
			rcall	prHEX
					
			rjmp	MAIN



;������������� �����
;22 ���, �����, 2013 ���. 15 ����� 36 ����� 22 �������
;��������� �������� �� ������ SQW ���������.
Set_Time_and_Data:	
			ldi		ZH,high(Data_Time)		;���������� � ������� Z ����� �������� ������ ��� ������
			ldi		ZL,low (Data_Time)		;
			ldi		temp,0x22				;�������
			std		Z+0,temp
			ldi		temp,0x55				;������
			std		Z+1,temp
			ldi		temp,0x15				;����
			std		Z+2,temp
			ldi		temp,0x03				;���� ������
			std		Z+3,temp
			ldi		temp,0x22				;����
			std		Z+4,temp
			ldi		temp,0x05				;�����
			std		Z+5,temp
			ldi		temp,0x13				;���
			std		Z+6,temp

			rcall	Write_Time				;�������� ������������ ������ ������ �� ������ ������ � �������� DS1307

											;��� �� ����� ��������� ��� ����� ������:
	;		Write_7Byte_DS1307	Data_Time	;������ � 7 ������ ��������� DS1307 ���� ������ ���� 
			ret								;������������� �� ������ Data_Time



;���������� ����������� ������ ������ RAM 
Inc_Cell_Ram:	ldi		R16,Data_Cell			
				rcall	Read_RAM_DS1307		;���������� � R16 ����������� ������ � ������� Data_Cell
				inc		R16					;���������� ����������� R16
				ldi		R17,Data_Cell		;������ � ������� R17 ������ Data_Cell
				rcall	Write_RAM_DS1307	;������ � ������ � ������� Data_Cell ����������� R16
				ret

Time:		.db			"Time:",0
Data:		.db			"Data:",0
