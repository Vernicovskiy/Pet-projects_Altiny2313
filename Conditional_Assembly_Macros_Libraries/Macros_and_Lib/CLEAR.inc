
;������� ������ ������
			ldi		ZL,low (SRAM_START)		;�������� ������ ������ ������������ ����� ������ ������
			ldi		ZH,high(SRAM_START)
			clr		R16
clram:		st		Z+,R16
			cpi		ZL,low (RAMEND+1)
			brne	clram
			cpi		ZH,high(RAMEND+1)
			brne	clram

;������� ��������� ������ ����������
			clr		ZL
			clr		ZH
clrg:		st		Z,ZH
			inc		ZL
			cpi		ZL,30
			brne	clrg
			clr		ZL
