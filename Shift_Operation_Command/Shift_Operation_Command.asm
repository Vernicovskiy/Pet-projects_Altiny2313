	/*������ ������ �������� ������*/

		ldi		R16,0b00001101
		swap	R16				;����� ������ �������
		nop
		nop


;����� ������ ����� �������
		ldi		R16,0b11001101
		ror		R16
		ror		R16
		ror		R16
		clc						;���������� ��� �
		ror		R16
		ror		R16
		sec						;������������� ��� �
		ror		R16

;����� ����� ����� �������
		ldi		R16,0b11001101
		rol		R16
		rol		R16
		rol		R16
		rol		R16
		rol		R16
		clc						;���������� ��� �
		rol		R16
		rol		R16
		sec						;������������� ��� �
		rol		R16

;���������� ����� ������ (������� �� 2)
		ldi		R16,0b11001101	;205
		lsr		R16				;102
		lsr		R16				;51
		lsr		R16				;25

;���������� ����� ����� (��������� �� 2)
		ldi		R16,0b00101101	;45
		lsl		R16				;90
		lsl		R16				;180
		lsl		R16				;��� ����������� 360 ������ ����� ������������
								;9-� ��� ������� � ��� �


;�������������� ����� ������
;������� ��� ���������� ��� ������

		ldi		R16,0b10111010
		asr		R16		;0b11011101
		asr		R16		;0b11101110
		asr		R16		;0b11110111
		asr		R16		;0b11111011
		asr		R16		;0b11111101
		asr		R16		;0b11111110

		ldi		R16,0b00111010
		asr		R16		;0b00011101
		asr		R16		;0b00001110
		asr		R16		;0b00000111
		asr		R16		;0b00000011
		asr		R16		;0b00000001
		asr		R16		;0b00000000


main:	rjmp	main
