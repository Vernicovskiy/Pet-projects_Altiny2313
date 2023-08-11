/* 	*������ �������� ��������� ����������� � ����������� 
	 ���������� 9 ������ ���������� ������ �� DS18B20
	*�� ����� ������ ���������� ������ ���� ������ DS18B20
	*��������� ��������� �� ���������� ������� �������
	*��� 9 ���� ��������� �� 2-�������� 16-���������� ��������� ���� HD44780

	*����� �������������� ��������� ���������� ��������� ��������� MicroLan.inc � HD44780.inc

���������������		ATtiny2313
�������� �������	8 MHz
���������			2-�������� 16-���������� ���� HD44780
*/

.include "tn2313def.inc"

.def	temp	=R16

.cseg			rjmp	start

.include "MicroLan.inc"						;���������� ��������� 1-WIRE
.include "HD44780.inc"						;���������� HD4780


start:			ldi		temp,RAMEND
				out		SPL,temp


				Init_HD44780				;������������� ����������

;#### �������� ���� ####
main:			rcall	Meas_DS1820			;������ �������� ��������� �����������

				rcall	resLAN
				ldi		R16,0xCC			;������� "������� ���"
				rcall	wr8LAN
				ldi		R16,0xBE			;������� "������ 9 ���� ���������� ������"
				rcall	wr8LAN	
				
				First_Line					;������� �� ������ ������ ����������

				rcall	rd8LAN				;���� 0 ������� ���� �����������
				rcall	PrHEX
				
				rcall	rd8LAN				;���� 1 ������� ���� �����������
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 2 ������� ��
				rcall	PrHEX

				rcall	rd8LAN				;���� 3	������� �L
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 4 ������� ������������
				rcall	PrHEX

				rcall	rd8LAN				;���� 5 ������
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 6 ������
				rcall	PrHEX

				rcall	rd8LAN				;���� 7 ������
				rcall	PrHEX

				Second_Line					;������� �� ������ ������ ����������

				rcall	rd8LAN				;���� 8 ����������� ����� CRC
				rcall	PrHEX

				rjmp	main


;#### ������ ��������� ����������� ####
Meas_DS1820:	rcall	resLAN
				brne	Error_meas_t		;�������� �� ���������� �������� �� �����
				ldi		temp,0xCC			;������� ���
				rcall	wr8LAN
				ldi		temp,0x44			;������ ��������������
				rcall	wr8LAN	
				rcall	Power_Action		;�������� �������� � ���������� ������� � ������� 750 �� 
Error_meas_t:	ret


;#### ������ ������� �� ����� � ������� 750 �� ####
;��������� �������� ��� ������� 8 MHz:
.equ	D_750	=0x0430		;750 ��
.equ	D_700	=0x03E8		;700 ��
.equ	D_650	=0x03A1		;650 ��
.equ	D_600	=0x0359		;600 ��

.equ	DL		=D_700
Power_Action:	Wire_UP_Power				;�������� �������� � ���������� �������
				ldi		ZH,high(DL)
				ldi		ZL,low (DL)
Nxt_Pow_Delay:	rcall	delay_700_us		;�������� 700 ���
				Check_Lan					;���������� ������
				brcc	Sh_Circ				;���� �� ������ ����, �� ����� ��������� �� ����� ���������
				sbiw	ZL:ZH,1
				brne	Nxt_Pow_Delay
Sh_Circ:		Wire_UP						;���������� �������� ������ ������� ������� 
				ret
		


