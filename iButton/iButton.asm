/* ���������� ID-���� ���������� � ����� �� ��������� ���� HD44780

���������������		ATtiny2313
�������� �������	8 MHz
���������			���� HD44780 (2 ������, 16 ��������)
*/
.include "tn2313def.inc"


.def	temp	=R16
.def	loop	=R17


.dseg		.org	0x60
mem:		.byte	8				;8 ���� � ������ ������ ��� �������� ������������ ID-����

.cseg		rjmp	start

.include "iButton.inc"				;����������� ������������� ����� ��� ������ � iButton
.include "HD44780.inc"				;����������� ������������� ����� ��� ������ � �����������

start:		ldi		temp,RAMEND
			out		SPL,temp

			Init_HD44780			;������������� ����������

;�������� ����
main:		Read_ID		mem			;���������� 8 ���� ID-����
			brtc	PC+2			;�������� �� ������ ����������
			rcall	Clear_ID		;������� ������ �������� ID-����
			rcall	Print_ID		;����� �� ��������� 8 ���� ID-����

			Second_Line				;������� �� ������ ������ ����������
			Check_ID	mem,ID0		;��������� ��������� ID-���� � ����� � ������
			brts	Print_OK		;���� ��� ���������, �� ������� �� Print_OK
			Row		Fail			;����� ��������� ��� ������������ �����
			rjmp	main
Print_OK:	Row		OK				;����� ������ ��������� OK
			rjmp	main

;������ ID-����
Print_ID:	First_Line				;������� �� ������ ������ ����������
			ldi		ZH,High(mem)	;�������� � ������� Z ������ ������� ����� ID-���� � ������ ������ 
			ldi		ZL,Low (mem)
			ldi		R20,8			;� ������� loop ��������� ��������� ��������
zzz:		ld		temp,Z+			;���������� � ������� temp ����� �� ������ ������
			rcall	prHEX			;����� ����� �� ������
			dec		R20
			brne	zzz
			ret

;��������� 8 ���� ������ ������ 
Clear_ID:	ldi		ZH,High(mem)	;�������� � ������� Z ������ ������� ����� ������ ������ 
			ldi		ZL,Low (mem)
			ldi		loop,8			;� ������� loop ��������� ��������� ��������
			ldi		R16,0
			st		Z+,R16			;��������� ������ ������ ������
			dec		loop
			brne	PC-2
			ret


Fail:	.db		"Unknown ID-code ",0,0					;��������� ������
OK:		.db		"      OK !      ",0,0					;��������� ��� ���������� ����

ID0:	.db		0x01,0xF5,0x77,0x0F,0x0F,0x00,0x00,0x5D	;8-������� ID-��� ����������
														;������ ������������ ������� ���� (��������� ���)
