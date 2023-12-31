/*
���������������� ������ ������ ���� ���������� ������ ��� ��� ����� 
������������. ������� �������, ����������� �������� ������ ������������� 
�� ������ ��������� ����, ��� ������ ��������� � ������� ��� ������������
*/

.macro	subi16			;��������� ����� �� 16-� ���������� �������� 
	subi	@0L,low (@1)
	sbci	@0H,high(@1)
.endm

.macro    addi			;�������� �������� 
    subi	@0,-@1
.endm

.macro    addi16		;�������� �������� ����� c 16-� ��������� ���������
    subi	@0L,low (-@1)
	sbci	@0H,high(-@1)
.endm

.macro	outi			;�������� ����� � ���
	ldi		R16,@1
	out		@0,R16
.endm

.macro    table         ;�������� � ������� Z ������ ������ ������� �������� � ������ ��������
    ldi		ZL,low (@0*2)
    ldi		ZH,high(@0*2)
.endm

.macro    ldx           ;�������� � ������� X �����
    ldi		XL,low (@0)
    ldi		XH,high(@0)
.endm

.macro    ldy           ;�������� � ������� Y �����
    ldi    YL,low (@0)
    ldi    YH,high(@0)
.endm

.macro    ldz           ;�������� � ������� Z �����
    ldi    ZL,low (@0)
    ldi    ZH,high(@0)
.endm

.macro    clbr          ;����� ������� � ��������
    cbr		@0,(1<<@1)
.endm

.macro    stbr          ;��������� ������� � ��������
    sbr		@0,(1<<@1)
.endm

.macro    bbrc          ;�������, ���� ��� � ��� �������
    sbrs	@0,@1		;bbrc	temp,4,Metka
    rjmp	@2
.endm

.macro    bbrs          ;�������, ���� ��� � ��� ����������
    sbrc	@0,@1		;bbrs	temp,4,Metka
    rjmp	@2
.endm

.macro    bbic          ;�������, ���� ��� � ��� �������
    sbis	@0,@1		;bbic	ACSR,5,Metka
    rjmp	@2
.endm

.macro    bbis          ;�������, ���� ��� � ��� ����������
    sbic	@0,@1		;bbis	ACSR,5,Metka
    rjmp	@2
.endm

.macro	  save			;���������� 16-� ������� ��� � ������ ������
	sts		@1	,@0H	;save	Y,0x60
	sts		@1+1,@0L	
.endm

.macro	  loads			;�������� �� ������ 16-� ������� ���
	lds		@0H,@1		;loads	Y,0x60
	lds		@0L,@1+1
.endmacro

.macro plusr			;�������� 16-������� � 8-������� ���������
	add		@0L,@1 		;plusr	Z,R16
	brcc	PC+2		
	inc		@0H 		
.endm

.macro irq				;���������� ����������
	.org	@0 			;irq 	0x02,INT_1
	rjmp	@1 
.endm

;������ ��� � ��� ��� � ������ ������ 
;������:
;	store	mem,temp	;������ temp � ������ ������ ������ mem
;	store	PORTB,temp	;������ temp � ��� PORTB
.macro store			
	.if	@0>0x3F 		;���� ����� ������, ��� 0�3F, �� ��������� ������� sts
		sts	@0, @1 
	.else 				;���� ������, �� out
		out	@0, @1 		
	.endif 
.endm
 
;���������� � ��� �� ��� ��� �� ������ ������ 
;������:
;	load	temp,mem	;���������� � temp �� ������ ������ ������ mem
;	load	temp,PORTB	;���������� � temp �� ��� PORTB
.macro load		 		
	.if	@1>0x3F 		;���� ����� ������, ��� 0�3F, �� ��������� ������� sts
		lds	@0, @1 		
	.else 				;���� ������, �� out
		in	@0, @1 
	.endif 
.endm

;��������� ������� � ������ ������ ������ ��� ���
;������:
;	setb	mem,2,temp
;	setb	SREG,2,temp
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
 
;����� ������� � ������ ������ ������ ��� ���
;������:
;	clrb	mem,2,temp
;	clrb	SREG,2,temp
.macro clrb
	.if @1>7 
		.message "Only values 0-7 allowed for Bit parameter" 
	.endif 
	.if @0>0x3F 			;����� ���� � ������ ������ ������
		lds  @2, @0 
		cbr  @2, (1<<@1) 
		sts  @0, @2 
	.elif @0>0x1F 			;����� ���� � ��� � ������� ������� ��� 0x1F
		in   @2, @0 
		cbr  @2, (1<<@1) 
		out  @0, @2 
	.else 					;����� ���� � ��� � ������� ������� ��� 0x1F
		cbi  @0, @1 
	.endif 
.endm
 
;������� ��������� �������, ���� ��� � ��� ��� � ������ ������ ������ ����������
;������:
;	skbs	PIND,2,temp
.macro skbs
	.if @1>7 
		.message "Only values 0-7 allowed for Bit parameter" 
	.endif 
	.if @0>0x3F 
		lds  @2, @0 
		sbrs @2, @1 
	.elif @0>0x1F 
		in   @2, @0 
		sbrs @2, @1 
	.else 
		sbis @0, @1 
	.endif 
.endm
 
;������� ��������� �������, ���� ��� � ��� ��� � ������ ������ ������ �������
;������:
;	skbc	PIND,2,temp
.macro skbc
	.if @1>7 
		.message "Only values 0-7 allowed for Bit parameter" 
	.endif 
	.if @0>0x3F 
		lds	 @2, @0 
		sbrc @2, @1 
	.elif @0>0x1F 
		in	 @2, @0 
		sbrc @2, @1 
	.else 
		sbic @0, @1 
	.endif 
.endm