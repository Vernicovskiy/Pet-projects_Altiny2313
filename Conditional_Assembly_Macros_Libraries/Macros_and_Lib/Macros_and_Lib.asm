/*	���������������� ���������� & ����������� ������������ ������ & ������� ��������� ���������������


		### �������� ��������������� ###
			
&& - ���������� ���������
|| - ���������� ��������

.if	<�������>						;������� ������� [������(>), ������ ��� �����(>=), ������(<), ������ ��� �����(<=), �����(==), �������(!=)]
	<��������>						;���� ������� �����������, �� ������� ��� ��������
.endif								;�����, ������ ��������� ������ ��������


.if	<������� 1>						;������� ������� [������(>), ������ ��� �����(>=), ������(<), ������ ��� �����(<=), �����(==), �������(!=)]
	<�������� 1>					;���� ������� �����������, �� ���������� �������� 1
	.message "Print message 1"		;� ������ ��������� (������ ���������� �����)
	
.elif	<������� 2>					;���� ���������� �������� �� �����������, �� �������� ���
		<�������� 2>				;������� �������� 2
		.message "Print message 2"	;� ������ ��������� 2
									;�����
.elif	<������� 3>					;���� ���������� �������� �� �����������, �� �������� ���
		<�������� 3>				;������� �������� 3
		.message "Print message 3"	;� ������ ��������� 3
									;�����
.elif	<������� 4>					;���� ���������� �������� �� �����������, �� �������� ���
		.error "Print error"		;��������� ���������� ��������� � ������� "Print error"
			
.else								;���� �� ���� �� �������� ����� .if �� �����������, ��
	<�������� 5>					;������� �������� 5
.endif								;����� ������� .if


		### ���������������� ���������� ###

���������������� ������ ������ ���� ���������� ������ ��� ��� ����� ������������. 
������� �������, ����������� �������� ������ ������������� 
�� ������ ��������� ����, ��� ������ ��������� � ������� ��� ������������

.macro		������ �������
.endm		����� �������
.endmacro	����� �������
@0			������ ��������
@1			������ ��������
@2			������ ��������
...			
@9			������� (���������) ��������	
*/



		;###########################
		;### ���������� �������� ###
		;###########################

.macro    ldx           ;�������� � ������� X �����
	ldi		XL,low (@0)
    ldi		XH,high(@0)
.endm
;������:		ldx		0x25F9

.macro    clbr          ;����� ������� � ���
    cbr		@0,(1<<@1)
.endm
;������:	clbr	temp,1

.macro    stbr          ;��������� ������� � ���
    sbr		@0,(1<<@1)
.endm
;������:	stbr	temp,1

/*��� ���
.macro    clbr          ;����� ������� � ���
    cbr		@0,exp2(@1)
.endm*/

.macro	outi			;�������� ����� � ���
	ldi		R16,@1
	out		@0,R16
.endm
;������:		outi	DDRB,0b11001100

/*
.macro	outi			;�������� ����� � ��� c ����������� � ����� �������� R16
	push	R16
	ldi		R16,@1
	out		@0,R16
	pop		R16
.endm

.macro	outv			;�������� ����� � ��� � ������� �������������� ���
	ldi		@2,@1
	out		@0,@2
.endm
;������:		outv	DDRB,0b11001100,temp
*/

.macro	subi16			;��������� ����� �� 16-� ���������� �������� 
	subi	@0L,low (@1)
	sbci	@0H,high(@1)
.endm
;������:		subi16	X,0x25F9

/*��� ���
.macro	subi16			;��������� ����� �� 16-� ���������� �������� 
	subi	@0L,byte1(@1)
	sbci	@0H,byte2(@1)
.endm*/

.macro    table         ;�������� � ������� Z ������ ������ ������� �������� � ������ ��������
	ldi		ZL,low (@0*2)
    ldi		ZH,high(@0*2)
.endm

;��������� ������� � ������ ������ ������ ��� ���
.macro setb
	.if @1>7 
		.message "Only values 0-7 allowed for Bit parameter" 
	.endif 
	.if @0>0x3F 			;��������� ���� � ������ ������ ������
		lds  @2, @0 
		sbr  @2, (1<<@1) 
		sts  @0, @2 
	.elif @0>0x1F 			;��������� ���� � ��� � ������� ������� ��� 0x1F
		in   @2, @0 
		sbr  @2, (1<<@1) 
		out  @0, @2 
	.else 					;��������� ���� � ��� � ������� ������� ��� 0x1F
		sbi  @0, @1 
	.endif 
.endm




.include "tn2313def.inc"		;� ������� �������� ���� ��������



.def	temp		=R16
.equ	VD			=1			;����� �����, ��� ����������� ����������

		;##################################
		;#### ������ ������������ ���� ####
		;##################################
.cseg
.org	0x00
		rjmp	start	;������� �� ������ ������������ ���� (!)
		
		.include	"DELAY.inc"			;����������� � ������� ����� DELAY.inc

;		.include	"C:\LIB\MACROS.inc"	;����������� � ������� ����� �������� � ��������� ������� ����

;		.include	"MACROS.inc"		;����������� � ������� ����� �������� ��� �������� ���� (���� ����� � ����� �������)


start:	outi	SPL,RAMEND				;������������� �����
		


.equ	Const1		=5
.equ	Const2		=20
.equ	bool		=1
		
		inc		temp

		.if		Const1 == 21
				nop
				ldi		R18,0x80		;���� ������� �����������, �� ���������� ��� �������� � ������ ��� ���������
				nop
		.endif

		inc		temp


		.if		((Const1 < Const2 * 2)||(Const1 == Const2))&&bool
				ldi		R17,0x40		;���� ������� �����������, �� ���������� ��� �������� � ������ ��� ���������
				.message "((Const1 < Const2 * 2)||(Const1 == Const2))&&bool  condition fulfilled"
		.endif



		.if	Const1 == 20								;���� ������� �����������,
			ldi		temp,1								;�� ����������� ������� ldi	temp,1
			.message "Print message 1"					;� ���������� ���������. ����� ���� ��������, �����
				.elif	Const1 == 21					;���� ���������� ������� �� ���������, �� �������� ����������
						ldi		temp,2
						.message "Print message 2"
				.elif	Const1 == 22					;���� ���������� ������� �� ���������, �� �������� ����������	
						ldi		temp,3
						.message "Print message 3"
				.elif	Const1 == 23					;���� ��� ������� �����������, 
						.error "Print error"			;�� ��������� ���������� ��������� � ������� "Print error"
		.else											;���� �� ���� �� ������� �� ���������, 
			ldi		temp,4								;�� ���������� ������� ldi	temp,4
		.endif
		
		

		.include	"CLEAR.inc"	;������� ������ ������ � ���
		
		outi	DDRB,(1<<VD)	;� �������� DDRB � 1 ���������� ������ VD
		outi	PORTB,0xFF		;� ������� PORTB ��������� ����� 0xFF

		table	text			;� ������� Z �������� ����� ������ ������� ��������

		setb	SREG,6,temp		;���������� ���������������� ���� �
		setb	0x60,1,temp		;���������� ��� 1 � ������ 0�60

main:	rcall	_delay
		setb	PINB,VD,temp	;������������ ������ VD ����� �
		rjmp	main

text:
.db		0x01, 0x02, 0x03, 0xFF
