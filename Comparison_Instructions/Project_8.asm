/*������ ������ ���������*/

.include "tn2313def.inc"

.def	temp	=R16
.def	temp2	=R17

;		#### ������� ��������� �������� � ��������� ####
		ldi		temp,0x10
		cpi		temp,0x11;���� Z=0, �������������, ������� �� ����� ���������
						 ;���� C=1, �������������, ������� ������ ���������
		
		ldi		temp,0x11
		cpi		temp,0x11;���� Z=1, �������������, ������� ����� ���������
						 ;���� C=0, �������������, ������� ������ ��� ����� ���������
						 
		ldi		temp,0x12
		cpi		temp,0x11;���� Z=0, �������������, ������� �� ����� ���������
						 ;���� C=0, �������������, ������� ������ ��� ����� ���������

		clr		R12
	;	cpi		R12,0	 ;������! ������� cpi ������ ��� ������� ��� (R16..R31)

;		#### ������� ��������� ��������� ####
		ldi		temp,0x8C
		ldi		temp2,0x8C
		cp		temp,temp2	;���� Z=1, �������������, �������� �����
		
		inc		temp2
		cp		temp,temp2	;���� Z=0, �������������, �������� �� �����
							;���� C=1, �������������, temp < temp2
							
		nop

.equ	content_Y			=0x542D	;���������� �������� Y
.equ	content_X			=0x542D ;���������� �������� X
.equ	const_comparation_1	=0x63FE
.equ	const_comparation_2	=0x2DFE
;#########################################################################################
;��������� �������� ���������� 16-���������� �������� Y � ���������� const_comparation_1

;��������� � Y ���������� content_Y:
		ldi		YL,low(content_Y)
		ldi		YH,high(content_Y)
		
;������� ���������� ������� ����� �������� Y � ��������� const_comparation_1:
		cpi		YL,low(const_comparation_1)		
;����� ��������� ��� �=1, �������������, ������� ���� const_comparation_1 ������ YL
		
;�����, �� ��������������� ������� temp, ��������� ������� ���� const_comparation_1:
		ldi		temp,high(const_comparation_1)

;� ���������� ������� ���� �������� Y � ����� [������� ����(const_comparation_1) + �]:
		cpc		YH,temp		;������� ��������� ��������� � ������ ����� ��������
		
;����� ��������� ��� �=1. �������������, const_comparation_1 ������ ����������� Y
;#########################################################################################

		nop

;#########################################################################################
;��������� �������� ���������� 16-���������� �������� � � ���������� const_comparation_2

;��������� � X ���������� content_X:
		ldi		XL,low(content_X)
		ldi		XH,high(content_X)
		
;������� ���������� ������� ����� �������� X � ��������� const_comparation_2:
		cpi		XL,low(const_comparation_2)		
;����� ��������� ��� �=1, �������������, ������� ���� const_comparation_2 ������ XL
		
;�����, �� ��������������� ������� temp, ��������� ������� ���� const_comparation_2:
		ldi		temp,high(const_comparation_2)

;� ���������� ������� ���� �������� X � ����� [������� ����(const_comparation_2) + �]:
		cpc		XH,temp		;������� ��������� ��������� � ������ ����� ��������
		
;����� ��������� �=0, Z=0. �������������, const_comparation_2 ������ ����������� X
;#########################################################################################

main:	rjmp	main