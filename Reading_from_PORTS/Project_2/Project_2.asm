.include "tn2313def.inc"



.def	temp		=R16	;�������� R16 ��������� ��� temp
.equ	const		=0x0F	;��������� 0x0F ��������� ��� const


		ldi		temp,0b00001111
		out		DDRD,temp
		ldi		temp,0b11111101
		out		PORTD,temp
		out		DDRB,temp

main:	in		temp,PIND
		out		PORTB,temp

		rjmp	main
