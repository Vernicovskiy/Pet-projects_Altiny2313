/* 		���������� ����� ��������� ������� DS1307

����� �������������� ���������� ���������� ��������� 
������������ ���������� ��������� i2c

� ���������� ������������ �������� R16 � R17

������ � ������ �������������� � 7 ����� ������ ������:
�������		DATA+0	;������� ������� - ������� ������ (0..5), ������ ������� - ������� ������ (0..9)
������		DATA+1	;������� ������� - ������� ����� (0..5), ������ ������� - ������� ����� (0..9)
����		DATA+2	;������� ������� - ������� ����� (0..2), ������ ������� - ������� ����� (0..9)
���� ������	DATA+3	;������� ������� - ����, ������ ������� - ��� ������ (1..7)
�����		DATA+4	;������� ������� - ������� ����� (0..3), ������ ������� - ������� ����� (0..9)
�����		DATA+5	;������� ������� - ������� ������ (0..1), ������ ������� - ������� ������ (0..9)
���			DATA+6	;������� ������� - ������� ��� (0..9), ������ ������� - ������� ��� (0..9)

			Init_DS1307
������������ ������ ��� ������������� DS1307.
��� ������������� ����������� ���� �������� (7-� ��� �������� ��������).
���� ���� ���������� � 1 (���� ���������� �������), �� ������������ ��� �����.
����� ������ ������������ ���� � �������� ����������� (�� ������) �������� ����� ��������.

			Read_RAM_DS1307
������������ ������ ������ �� RAM 
����� ������� R16 ���������� ����� ������ RAM (0..55)
����� ���������� ������������ � �������� R16 ��������� ������
	
			rcall	Write_RAM_DS1307	
������������ ������ ������ � RAM
����� ������� R17 ���������� ����� ������ (0..55)
����� ������� R16 ���������� ������ ��� ������
*/


;#### ���������� ��������� I2C ####
.include "I2C.inc"


;============== �������� ���������������� =====================
;���������� 7 ������ ��������� DS1307 � 7 ����� ������ ������. 
;��������� ����� ������ ������ ����������� � ���������
.macro		Read_7Byte_DS1307
			push	ZH
			push	ZL
			ldi		ZH,high(@0)
			ldi		ZL,low (@0)
			rcall	Read_Time
			pop		ZL
			pop		ZH
.endm

;������ ������ �� 7 ����� ������ ������ � 7 ������ ��������� DS1307 
;��������� ����� ������ ������ ����������� � ���������
.macro		Write_7Byte_DS1307
			push	ZH
			push	ZL
			ldi		ZH,high(@0)
			ldi		ZL,low (@0)
			rcall	Write_Time
			pop		ZL
			pop		ZH
.endm



;=============== �������� ������������ ========================

;#### ������������� ����� DS1307 ####
Init_DS1307:rcall	Write_DS1307		;������� DS1307 �� ������
			ldi		R16,0				;����� �������� ��������, ����������� ��� ���������� �����
			rcall	shout				;�������� �����	������
			rcall	Read_DS1307			;������� DS1307 �� ������
			rcall	shin				;������ �������� ��������, ����������� ��� ���������� �����
			rcall	NAK					;����������� ������
			rcall	stp					;����-�������
			clt							;���������� ������� �� ����
			sbrs	R16,7				;�������� 7 ����, ������������ ������ �����
			ret							;���� ��� �������, �� ������� �� ������������, � ���� ����������, �� ���������� ����������
			rcall	Write_DS1307		;����� ���� ���������� DS1307
			ldi		R16,0				;����� �������� ��������, ����������� ��� ���������� �����
			rcall	shout				;�������� ����� ������
			rcall	shout				;��� ���������� � ������� �������� �������
			rcall	stp					;����������� ������ � �����
			set							;���� ���������� �������
			ret

;#### ������ ������ �� 7 ��������� DS1307 � ������ ������ ������ ���������������� ####
Read_Time:	rcall	Write_DS1307		;������� DS1307 �� ������
			ldi		R16,0				;����� �������� ��������, ����������� �������� ������
			rcall	shout				;�������� �����	������
			rcall	Read_DS1307			;������� DS1307 �� ������
			ldi		R17,6
RdTm:		rcall	shin				;������ ������� ������, ������� � �������� ��������, ����������� �������� ������
			rcall	ACK					;������������� ������ �����
			st		Z+,R16
			dec		R17
			brne	RdTm
			rcall	shin				;������ ���������� 7-��� �����
			st		Z,R16				;������������ ����������� ���� � 7-� ������
			rcall	NAK					;��������� ������ ��������� ��������������� nak
			rcall	stp					;� ��������� ������ stop-��������
			ret

;#### ������ 7 ���� �� ������ ������ ���������������� � �������� DS1307 ####
Write_Time:	rcall	Write_DS1307		;������� DS1307 �� ������
			ldi		R16,0				;����� �������� ��������, ����������� �������� ������
			rcall	shout				;�������� �����	������
			ldi		R17,7				;��������� �������� �� ���������� �� CLOCK 7-� ����
WrTm:		ld		R16,Z+				;������ ����� �� ������� ������
			rcall	shout				;������ ����� �� CLOCK � ������ �����
			dec		R17					;��������� �������� ��������, ���� �� ����, ��
			brne	WrTm				;����������� ������ � ������ �����
			rcall	stp					;����-�������. ��������� ������.
			ret

;#### ������ ������ �� RAM ###
;����� ������� R16 ���������� ����� ������ RAM (�.�. ����� ������ ������������ � ���� �� 55) 
;����� ���������� ������������ � �������� R16 ���������� ������ �� ���� ������
Read_RAM_DS1307:	subi	R16,-0x08		;����� ������ ���������� ������ RAM
					push	R16
					rcall	Write_DS1307	;������� DS1307 �� ������
					pop		R16
					rcall	shout			;�������� ����� ������
					rcall	Read_DS1307		;������� DS1307 �� ������
					rcall	shin			;������ ������ ������
					rcall	NAK				;����������� ������ � �����
					rcall	stp	
					ret
		
;#### ������ ������ � RAM ####
;����� ������� R17 ���������� ����� ������ RAM (0..55)
;����� ������� R16 ���������� ������ ��� ������
Write_RAM_DS1307:	push	R16
					rcall	Write_DS1307	;������� DS1307 �� ������
					mov		R16,R17
					subi	R16,-0x08		;����� ������ ���������� ������ RAM
					rcall	shout			;�������� ����� ������
					pop		R16
					rcall	shout			;������ � ������ ������
					rcall	stp				;����������� ������ � �����
					ret

;������� DS1307 �� ������
Write_DS1307:	ldi		R16,0b11010000		;����� ����� �� ������
				rjmp	PC+2
;������� DS1307 �� ������		
Read_DS1307:	ldi		R16,0b11010001		;����� ����� �� ������
				rcall	str					;Start-�������
				rcall	shout				;�������� ����� ������
				ret
				
