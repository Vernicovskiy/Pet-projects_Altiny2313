/* 	��������� ������� ����������� ����� (CRC - Cyclic Redundancy Check, ����������� ���������� ���)
��������� ���������� ������� ����������� ����� �������� ����

������� ������������ ���� ��� ���� ID-���� (��� ����� ��� ������� ID), ���� ��� ���� ���������� ������ (������ ��� DS18B20)
����� ����������� ���� ���������� ������, ������������ ������ �������� �������������� �����������.

����� ������ ������������ �� ��������� ���� HD44780

����� �������������� ��������� ���������� ��������� ��������� MicroLan.inc � HD44780.inc

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
main:			rcall	CRC_Scratchpad		;������� CRC ��� ���� ���������� ������ (������ ��� DS18B20)
			;	rcall	CRC_ROM				;������� CRC ��� ���� ID-����
				rjmp	main




;#### ������� CRC ��� 7 ���� (56 ���) ID-���� ####
CRC_ROM:		rcall	resLAN
				ldi		R16,0x33			;������� "������ ���"
				rcall	wr8LAN	

				clr		ZH
				ldi		ZL,0x60				;�������� � ������� Z ������ ������������ � ������ ������ ���� ������

				First_Line					;������� �� ������ ������ ����������

				rcall	rd8LAN				;���� 0 ID-����
				st		Z+,temp
				rcall	PrHEX
				
				rcall	rd8LAN				;���� 1 ID-����
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 2 ID-����
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;���� 3	ID-����
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 4 ID-����
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;���� 5 ID-����
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 6 ID-����
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;���� 7 ID-����
				st		Z+,temp
				rcall	PrHEX

				Second_Line					;������� �� ������ ������ ����������
				
				dat		'-'

				clr		ZH
				ldi		ZL,0x60				;�������� � ������� Z ������ ������������ � ������ ������ ���� ������
				
				rcall	Checksum			;����� ������������ ������� ����������� �����
				rcall	PrHEX				;������ ����� CRC

				ret






;#### ������� CRC ��� 8 ���� (64 ���) ���������� ������ ####
CRC_Scratchpad:	rcall	Meas_DS1820			;������ �������� ��������� �����������

				rcall	resLAN
				ldi		R16,0xCC			;������� "������� ���"
				rcall	wr8LAN
				ldi		R16,0xBE			;������� "������ 9 ���� ���������� ������"
				rcall	wr8LAN	
				
				clr		ZH
				ldi		ZL,0x60				;�������� � ������� Z ������ ������������ � ������ ������ ���� ������
				
				First_Line					;������� �� ������ ������ ����������

				rcall	rd8LAN				;���� 0 ������� ���� �����������
				st		Z+,temp
				rcall	PrHEX
				
				rcall	rd8LAN				;���� 1 ������� ���� �����������
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 2 ������� ��
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;���� 3	������� �L
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 4 ������� ������������
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;���� 5 ������
				st		Z+,temp
				rcall	PrHEX
								
				rcall	rd8LAN				;���� 6 ������
				st		Z+,temp
				rcall	PrHEX

				rcall	rd8LAN				;���� 7 ������
				st		Z+,temp
				rcall	PrHEX

				Second_Line					;������� �� ������ ������ ����������

				rcall	rd8LAN				;���� 8 ����������� ����� CRC
				st		Z+,temp
				rcall	PrHEX
				
				dat		'-'
				
				clr		ZH
				ldi		ZL,0x60				;�������� � ������� Z ������ ������������ � ������ ������ ���� ������
				
				rcall	Checksum			;����� ������������ ������� ����������� �����
				rcall	PrHEX				;������ ����� CRC
				
				ret


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
Power_Action:	Wire_UP_Power				;�������� �������� � ���������� �������
				ldi		ZH,high(0x0430)
				ldi		ZL,low (0x0430)
Nxt_Pow_Delay:	rcall	delay_700_us		;�������� 700 ���
				Check_Lan					;���������� ������
				brcc	Sh_Circ				;���� �� ������ ����, �� ����� ��������� �� ����� ���������
				sbiw	ZL:ZH,1
				brne	Nxt_Pow_Delay
Sh_Circ:		Wire_UP						;���������� �������� ������ ������� ������� 
				ret
		

		





/*################################################################################						
						������� ����������� �����
			
�������� ����� ������ ���� �������� ������ � ������� ������ ������, ������� � 
�������� �����. �� ���������� �hecksum ����� ������������ �������� ����� ������ 
���� �������� � ������� Z. ���� � �������� CRC ������������ ���� CRC, �� ����� 
���������� �hecksum � �������� R16 ����� 0.

								! �������� ! 
����� ���������� �hecksum ������ � �������� ������� ������ ����� �������� !
################################################################################*/

Checksum:	ldi		R18,(8*9)		;�������� ���������� ��� (8*����) �� ������� ���� ������� CRC
			clr		R16				;��������� �������� R16
Nxt_Shift:	
.macro		Shift_R					;������ ������ ������ ������ ������ �� 1 ���, ����� ���� ��������
			ldd		R17,Z+@0
			ror		R17
			std		Z+@0,R17
.endm
			Shift_R	8				;����� 9 ����� ������ ������ �� 1 ��� ������
			Shift_R	7				
			Shift_R	6
			Shift_R	5
			Shift_R	4
			Shift_R	3
			Shift_R	2
			Shift_R	1
			Shift_R	0
			ldi		R17,0b10000000	;��������� ��� �������������� ����� � (���������� � 7-� ��� R16)
			ror		R16				;����� ���� � � 7-� ������, 0-� ������ ���������� � ��� �
			brcc	PC+2			;���� ������� ������ R16 ����� 1, 
			eor		R16,R17			;�� ����������� ������� ������ (���� �)
			ldi		R17,0b00001100	;��������� ��� �������������� 2 � 3 ����� (3 � 4 �� ������ R16)
			sbrc	R16,7			;���� ������� ������ (���� � ����� "������������ ���" ����� � � 0-� ����� R16) ����� 1,
			eor		R16,R17			;�� ����������� 2 � 3 ������� (3 � 4 �� ������ R16)
			dec		R18				;��������� �������
			brne	Nxt_Shift
			tst		R16				;�������� R16 �� ������� �������� (R16=0 ��� �������� CRC ������ � ������ CRC)
			ret
