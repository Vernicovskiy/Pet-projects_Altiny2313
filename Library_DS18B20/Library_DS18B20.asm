/* ��������� ���������� ����������� � ���� �������� � ����� ��������� � ���������� ���� �� ��������� 
������������� �������� DS18B20 ������������ �� ID-����

����������� ��������� �� ��������� � ��������� �� ������� ����� �������

� ��������� ������������ 2-�������� 16-���������� ��������� ���� HD44780

����� �������������� ��������� ���������� ��������� ��������� MicroLan.inc � HD44780.inc

���������������		ATtiny2313
�������� �������	8 MHz
���������			2-�������� 16-���������� ���� HD44780
*/

.include "tn2313def.inc"


.def	temp	=R16

.cseg		rjmp	start

.include "DS18B20.inc"					;����������� ���������� DS18B20
.include "HD44780.inc"					;����������� ���������� HD44780


start:		ldi		temp,RAMEND
			out		SPL,temp

	;		Set_Reg_RAM	 0xFF,0xFF,9	;������������� DS18B20. ���������� �������� � RAM

			Set_Reg_EEP	 0xFF,0xFF,12	;������������� DS18B20. ���������� �������� � EEPROM-������

			Init_HD44780				;������������� ����������


;#### ������� ���� ####
main:		First_Line					;������� �� ������ ������ ����������


		;	rjmp	Single_Tmp			;������� � ������������ ��������� ����������� � ������ �������



;��������� ����������� � ���������� ��������
Temp_1:		Rd_Tmp_PZU		0x60,ID0	;������ ����������� � ������� ID0
			brtc	T1_OK
			rcall	Print_ERR			;������ ������
			rjmp	Temp_2

T1_OK:		Row		T1
			rcall	Out_tp_LCD			;������ �����������


Temp_2:		Second_Line					;������� �� ������ ������ ����������
			Rd_Tmp_PZU		0x60,ID2	;������ ����������� � ������� ID2
			brtc	T2_OK
			rcall	Print_ERR
			rjmp	main

T2_OK:		Row		T2
			rcall	Out_tp_LCD			;������ �����������
			rjmp	main				;�� ������ ��������� �����




;��������� ����������� � ������ �������
Single_Tmp:	Rd_one_Tmp		0x60
			brtc	Tp_OK
			rcall	Print_ERR
			rjmp	main

Tp_OK:		Row		Tp
			rcall	Out_tp_LCD
			rjmp	main






;������ �����������
Out_tp_LCD:	sbrs	ZL,7				;�������� �� ������������� ��������
			rjmp	m1
			dat		'-'					;������ ������
			rjmp	m3
m1:			sbrs	ZL,4				;�������� ����� ��������
			rjmp	m2
			dat		'1'					;������ ����� ��������
			rjmp	m3
m2:			dat		' '					;������ �������
m3:			mov		temp,ZH				;������ �������� � ������
			rcall	PrHEX
			dat		'.'					;������ �������������� �����
			mov		temp,ZL
			andi	temp,0x0F
			rcall	jedat30				;������ ������� �������
			ret
			
;������ ������
Print_ERR:	push	temp
			Row		Err
			pop		temp
			rcall	PrHEX
			Row		Space
			ret



;���������
Err:		.db	"Error ",0
Tp:			.db	"Temp = ",0
T1:			.db	"Temp1 = ",0
T2:			.db	"Temp2 = ",0
Space:		.db	"     ",0


;ID-���� �������� DS18B20
ID0:		.db	0x28,0xCC,0x8F,0x52,0x03,0x00,0x00,0x63		;ID-��� ������� 0
ID1:		.db	0x28,0x7B,0x6C,0x81,0x00,0x00,0x00,0x18		;ID-��� ������� 1
ID2:		.db	0x28,0x2A,0xB7,0xE5,0x00,0x00,0x00,0xB1		;ID-��� ������� 2



