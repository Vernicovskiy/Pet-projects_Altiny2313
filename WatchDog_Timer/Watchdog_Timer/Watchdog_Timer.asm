;#### ������������� ������������ ����������� ������� #### 
;���� ���������������� �������������, �� ��� ������� �������������
;������������� ����� ������� ���������������� ��������� �������

.include "tn2313def.inc"

.def	temp		=R16


.equ	DDR_VD		=DDRD					;���� ��� ����������� ���������� �����������
.equ	PORT_VD		=PORTD					;���� ��� ����������� ���������� �����������
.equ	Pr_Lck		=1						;������ "��������� �������������"
.equ	WD_int		=0						;������ "���������� WatchDog-�������"
	

.equ	DDR_SB		=DDRB					;���� ��� ����������� ������
.equ	PORT_SB		=PORTB					;���� ��� ����������� ������
.equ	PIN_SB		=PINB					;���� ��� ����������� ������
.equ	SB_Lck		=7						;������ ���������� ���������
.equ	SB_WDof		=0						;������ ���������� WatchDog-�������


.cseg	
.org	0x00
		rjmp	start


.org	0x12
		rjmp	WatchDog					;������ ���������� WatchDog-�������


start:	ldi		temp,RAMEND
		out		SPL,temp
		
		cbi		DDR_SB,SB_Lck				;����� ������ SB_Lck �� ����
		cbi		DDR_SB,SB_WDof				;����� ������ SB_WDof �� ����
		sbi		PORT_SB,SB_Lck				;��������� �������������� ��������� 
		sbi		PORT_SB,SB_WDof				;��������� �������������� ���������

		sbi		DDR_VD,WD_int				;����� ������� WD_int �� �����
		sbi		DDR_VD,Pr_Lck				;����� ������� Pr_Lck �� �����
		cbi		PORT_VD,WD_int				;������� ���������� "���������� WatchDog-�������"
		cbi		PORT_VD,Pr_Lck				;������� ���������� "��������� �������������"


;			������ ������������ ������� 2 �������


;			������������ - ����������	(���������� WDIE = 1)			
			ldi		temp,(1<<WDIE|0<<WDP3|1<<WDP2|1<<WDP1|1<<WDP0)


;			������������ - �����	(����� WDE = 1)
		;	ldi		temp,(1<<WDE|0<<WDP3|1<<WDP2|1<<WDP1|1<<WDP0)


;			������������ - ����������. ��������� ������������ - �����	(����� WDIE = 1, ���������� WDE = 1)
		;	ldi		temp,(1<<WDE|1<<WDIE|0<<WDP3|1<<WDP2|1<<WDP1|1<<WDP0)


			out		WDTCSR,temp				;������ � ������� ������������ WatchDog


			sei								;���������� ���������� WatchDog-�������


main:		wdr								;������� ������ ����������� �������
			sbis	PINB,SB_Lck				;�������� ������
			rjmp	Lock					;������� � ������������ ���������
			sbis	PINB,SB_WDof			;�������� ������
			rjmp	WD_OFF					;���������� Watchdog-�������
			rjmp	main	


;			������������ ���������
Lock:		sbi		PORTD,Pr_Lck			;��������� ���������� Pr_Lck (��������� �������������)
			rjmp	PC						;������������ ���������


;			���������� ����������� �������
WD_OFF:		clr		temp					;������������ ������� ���� WDRF �������� MCUSR
			out		MCUSR,temp
			ldi		temp,(1<<WDE|1<<WDCE)	;������ � WDE � WDCE ���������� 1
			out		WDTCSR,temp
			ldi		temp,0					;� ������� ��������� 4 ������ � WDE �������� ����
			out		WDTCSR,temp
	;		clr		temp					;���� ������ �������� � ������ ������ ����������, 
	;		out		WDTCSR,temp				;�� ��� ��������� watchdog ���������� ������ �������� ��� WDIE
			rjmp	main					;����� ���������� - �� �������� ����


;			���������� �� ����������� �������
WatchDog:	sbi		PORTD,WD_int			;��������� ���������� WD_int (���������� WatchDog-�������)
			cbi		PORTD,Pr_Lck			;���������� ���������� Pr_Lck (��������� �������������)
			reti
			
