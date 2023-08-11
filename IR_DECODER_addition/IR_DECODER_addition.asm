/*
��������� ����������� �������� � ������������� ������ � ������� �������������� ����������

��� ������ ������� � ������ ������������� ��������� ������������ 
������ 1 ���������� � ������ �������.
����� ��-��������� ������ ���� �������� � ������ ������� ICP
� ���������������� ATtiny2313 ����� ������� - PD6 (11 �����).
����� ������� ����������� ������ ���� �������� �� ����

��������������� 	ATtiny2313
�������� ������� 	8 MHz
*/
.include "tn2313def.inc"


;���� ����������
.equ	PORT_CMD			=PORTB
.equ	DDR_CMD				=DDRB
.equ	PIN_CMD				=PINB
;����� ����������
.equ	Command_1			=PB6	;����� ��� ��������� ���������� ������ �������
.equ	Command_2			=PB5	;����� ��� ��������� ���������� ������ �������
.equ	Command_3			=PB4	;����� ��� ��������� ���������� ������ �������


;###########################################
;#### ���������� ������ � ������������� ####
;###########################################
;��������� �������
.equ	Time_Start			=3000	;�����������
.equ	Tolerance_Str		=300	;�����������
;������� ������� (1)
.equ	Time_pulse_11		=3500	;�����������
.equ	Tolerance_11		=200	;�����������
.equ	Time_pulse_10		=2600	;�����������
.equ	Tolerance_10		=300	;�����������
;�������� ������� (0)
.equ	Time_pulse_01		=1800	;�����������
.equ	Tolerance_01		=300	;�����������
.equ	Time_pulse_00		=1800	;�����������
.equ	Tolerance_00		=300	;�����������
;����� �� ���������� �������
.equ	Time_to_decod		=5000	;�����������


;����������� ���������
.def	Save_SREG			=R2		;������� ��� ���������� �������� SREG
.def	byte_1				=R10	;������ ����� ��� �������� ��������� ����
.def	byte_2				=R11
.def	byte_3				=R12
.def	byte_4				=R13
.def	temp				=R16
.def	FLAGS				=R17	;������� ������

;���� �������� FLAGS
.equ	Package_OK			=0		;��� �������� �������� �������
.equ	Package_FAIL		=1		;��� ������ ����������� ������������ ��������
.equ	IR_IS_ON			=2		;��� ����������� IR-������� � ������� 65536 ���


;#### ����� ����������� ####
.macro	table						;�������� ������ ��������
		ldi		ZH,high(@0*2)
		ldi		ZL,low (@0*2)
.endm
.macro	ldz							;�������� ��������� � 16-��������� �������
		ldi		ZH,high(@0)
		ldi		ZL,low (@0)
.endm
.macro	outi						;������ ��������� � ���
		ldi		R16,@1
		out		@0,R16
.endm



;#### ������ ������������ ���� ####
.cseg
.org	0x00
		rjmp	INIT			;�������������
.org	ICP1addr
		rjmp	TIM1_CAPT		;������ ������� 1
.org	OC1Aaddr
		rjmp	TIM1_COMP_A		;���������� � ������ � ������� 1
.org	OVF1addr
		rjmp	TIM1_OVER		;������������ ������� 1


;#### ������������� ####
.org	INT_VECTORS_SIZE
INIT:		outi	SPL,RAMEND
			outi	PORTD,0xFF			;����� ����� PD6 �� ����

			outi	DDR_CMD,0xFF		;������ ����� B �� �����
			outi	PORT_CMD,0x00		;�� ���� ������� ���������� ����
			outi	TIMSK,(1<<OCIE1A|1<<ICIE1|1<<TOIE1)	;���������� �� ���������� � ������ �,
														;���������� �� ������������, ���������� �� �������
			outi	OCR1AH,high(Time_to_decod)			;�������� � ������� ���������� ���������
			outi	OCR1AL,low (Time_to_decod)

			rcall	Restart_IR			;������������� �������, ������, ������ ������, ����� ������ ����������, ���������� ����������

			
;###### �������� ���� ######
MAIN:		rcall	Check_IR			;����� ������������ �������� ��������� ������� 
			rjmp	MAIN				
			
Check_IR:	sbrs	FLAGS,Package_OK	;������� reti, ���� ������� �������
			reti						;����� �� ������������ � ���������� ����� ����������� ���������� ����������
			sbrs	FLAGS,Package_FAIL	;������� ������ ������������ ���������� �������� �������, ���� � �������� ������ ��� ������ ������������ �������
			rcall	decoder				;���������� �������� �������
			sbrc	FLAGS,IR_IS_ON		;��������, ���� �� ������������ ������� � ������ (��� I ������ ���� ����������)
			rjmp	PC-1				;�������� ��������� ���� ���������� �������
			
Restart_IR:	outi	TCCR1B,0x00			;������ - �� C����, ��������� �������
			clr		FLAGS				;����� ������
			clr		byte_1				;������� ������ �������� ������
			clr		byte_2
			clr		byte_3
			clr		byte_4
			outi	TIFR,0xFF			;����� ���� ������ ����������
			reti						;���������� ����������
			
		
;������������� �������� � ������ �������
decoder:	cli									;������ ���������� �� ����� ���������� �������� �������
			table	P_POWER_0					;�������� ���� ������ POWER (10 ���)
			rcall	decod_cmd
			brts	POWER_COMMAND
			table	P_POWER_1					;�������� ���� ������ POWER (9 ���)
			rcall	decod_cmd
			brts	POWER_COMMAND
				table	P_DISP_0				;�������� ���� ������ DISPLAY (10 ���)
				rcall	decod_cmd
				brts	DISP_COMMAND
				table	P_DISP_1				;�������� ���� ������ DISPLAY (11 ���)
				rcall	decod_cmd
				brts	DISP_COMMAND
					table	P_PROG_0			;�������� ���� ������ PROG (8 ���)
					rcall	decod_cmd
					brts	PROG_COMMAND
					table	P_PROG_1			;�������� ���� ������ PROG (9 ���)
					rcall	decod_cmd
					brts	PROG_COMMAND
						table	P_RPT_0			;�������� ���� ������ REPEAT (9 ���)
						rcall	decod_cmd
						brts	RPT_COMMAND
						table	P_RPT_1			;�������� ���� ������ REPEAT (11 ���)
						rcall	decod_cmd
						brts	RPT_COMMAND
							reti				;��������� ����� ���������� ���������� ����� ���������� �������� �������

POWER_COMMAND:	sbi		PIN_CMD,Command_1
				reti						;��������� ����� ���������� ���������� ����� ���������� �������� �������
DISP_COMMAND:	sbi		PIN_CMD,Command_2
				reti						;��������� ����� ���������� ���������� ����� ���������� �������� �������
PROG_COMMAND:	sbi		PIN_CMD,Command_3
				reti						;��������� ����� ���������� ���������� ����� ���������� �������� �������
RPT_COMMAND:	sbi		PIN_CMD,Command_1
				reti						;��������� ����� ���������� ���������� ����� ���������� �������� �������


;��������� ��������� �������� ���� � ������� ������ ������
decod_cmd:	clt						;����� ����� ����������
			lpm		temp,Z+			;�������� ����� ������� �� ������
			cp		temp,byte_4		;��������� � �������� ������
			brne	No_cmd			;���� ���� �� ���������, �� ����� �� ������������ �� ���������� ������ ����������
			lpm		temp,Z+
			cp		temp,byte_3
			brne	No_cmd
			lpm		temp,Z+
			cp		temp,byte_2
			brne	No_cmd
			lpm		temp,Z+
			cp		temp,byte_1
			brne	No_cmd
			set						;��������� ����� ����������
No_cmd:		ret


;���������� �� ��������� �������
TIM1_COMP_A:	sbr		FLAGS,(1<<Package_OK)		;��������� ����� �������� �������� �������
				outi	TCCR1B,(1<<CS11|1<<CS10)	;������� �� 64 (��� ���������� ������� �������� ���������� ������)
				reti
				
;���������� �� ������������ �������
TIM1_OVER:		cbr		FLAGS,(1<<IR_IS_ON)			;����� ����� ����������� IR-������� � ������� 65536 ���
				ret									;������ ���������� ����� ��������� 
				
;���������� �� �������
TIM1_CAPT:		in		Save_SREG,SREG
				push	temp
				
				outi	TCNT1H,0x00					;������� ������� ��������� ������� 1
				outi	TCNT1L,0x00
				in		XL,ICR1L					;���������� �������� ������������ �������� �� �������� �������
				in		XH,ICR1H	
				
				sbrc	FLAGS,IR_IS_ON				;���� ������ ����������, �� ������� ������������� ��������
				rcall	Decoder_Pulse				;����� ������������ ������������� ������������ ��������� ��������
				
				outi	TCCR1B,(1<<CS11)			;������ ������� � ������ (������� �� 8, ������ - �� C����)
				sbr		FLAGS,(1<<IR_IS_ON)			;��������� ����� ����������� IR-������� � ������� 65536 ���
				pop		temp					
				out		SREG,Save_SREG
				reti

;##### ���������� ������������ ��������� �������� #####
Decoder_Pulse:		rcall	Detect_11				;��������� � ������������� �������� ���������� 1
					brcc	Detect_Pulse_Is_1		;���������� �������������� �������� ���������� 1 � ������
					rcall	Detect_10				;��������� � ������������� �������� ���������� 1
					brcc	Detect_Pulse_Is_1		;���������� �������������� �������� ���������� 1 � ������
					rcall	Detect_01				;��������� � ������������� �������� ����������� 0
					brcc	Detect_Pulse_Is_0		;���������� �������������� �������� ����������� 0 � ������
					rcall	Detect_00				;��������� � ������������� �������� ����������� 0
					brcc	Detect_Pulse_Is_0		;���������� �������������� �������� ����������� 0 � ������
					rcall	Detect_Start			;��������� � ������������� �����-��������
					brcc	PC+2					;���� ��������� ������� ������� ����������, �� ������ �������
					sbr		FLAGS,(1<<Package_FAIL)	;������������ �������� ����������� ���������. ��������� ����� ������ Package_FAIL
					ret

Detect_Pulse_Is_1:	sec								;����� ����� � = 1 � ����� ������
Detect_Pulse_Is_0:	rol		byte_1					;����� ����� � = 0 � ����� ������
					rol		byte_2
					rol		byte_3
					rol		byte_4
					ret

					
;������ ���������� ������������ ��������
.macro				Detect_Impulse
					ldz		@0 + @1			;�������� �� ���������� ������� �������
					rcall	Calc_Pulse		;��������� ������������ ��������� �������� � ��������� ���������
					brcs	Pulse_OK		;���� �=1, �� �������� ������� ������ ������� ������� (��� "����������" �������)
					sec						;�=0 => �������� ������� ������ ������� ������� (��� "������������" �������)
					ret						;������������� ���� ������ C=1 � �������
Pulse_OK:			ldz		@0 - @1			;�������� �� �������� �������, ��� ������ �������
					rcall	Calc_Pulse		;���� �=0, �� �������� ������� ������ ������ ������� (��� "����������" �������)
					ret						;���� �=1, �� �������� ������� ������ ������ ������� (��� "������������" �������)
.endm

;��������� ������������ �������� � ���������� ����������
Detect_Start:		Detect_Impulse		Time_Start,    Tolerance_Str;�������� ���������� ��������
Detect_11:			Detect_Impulse		Time_pulse_11, Tolerance_11	;�������� �������� �������� (1)
Detect_10:			Detect_Impulse		Time_pulse_10, Tolerance_10	;�������� ��������� �������� (0)
Detect_01:			Detect_Impulse		Time_pulse_01, Tolerance_01	;�������� �������� �������� (1)
Detect_00:			Detect_Impulse		Time_pulse_00, Tolerance_00	;�������� ��������� �������� (0)

Calc_Pulse:			mov		temp,XL			;��������� ������������ �������� � ��������� ���������
					sub		temp,ZL
					mov		temp,XH
					sbc		temp,ZH
					ret


;####################################################################
;						���� ������ ������
;��� ������� ���� ��������� 4 �����. ������������� ���� - ���� 
;####################################################################
;				   ������� ����						   ������� ����

P_POWER_0:	.db		0b00000000, 0b00000000, 0b00000000, 0b01100101	;POWER (10 ���)
P_POWER_1:	.db		0b00000000, 0b00000000, 0b00000000, 0b11100101	;POWER (9 ���)

P_DISP_0:	.db		0b00000000, 0b00000000, 0b00000000,	0b11001000	;DISPLAY (11 ���)
P_DISP_1:	.db		0b00000000, 0b00000000, 0b00000001,	0b11001000	;DISPLAY (10 ���)

P_PROG_0:	.db		0b00000000, 0b00000000, 0b00000000, 0b01111111	;PROG (8 ���)
P_PROG_1:	.db		0b00000000, 0b00000000, 0b00000000, 0b00111111	;PROG (9 ���)

P_RPT_0:	.db		0b00000000, 0b00000000, 0b00000000, 0b11101001	;REPEAT (9 ���)
P_RPT_1:	.db		0b00000000, 0b00000000, 0b00000000, 0b01101001	;REPEAT (11 ���)


