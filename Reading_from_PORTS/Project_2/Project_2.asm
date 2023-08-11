.include "tn2313def.inc"



.def	temp		=R16	;Регистру R16 присвоили имя temp
.equ	const		=0x0F	;Константе 0x0F присвоили имя const


		ldi		temp,0b00001111
		out		DDRD,temp
		ldi		temp,0b11111101
		out		PORTD,temp
		out		DDRB,temp

main:	in		temp,PIND
		out		PORTB,temp

		rjmp	main
