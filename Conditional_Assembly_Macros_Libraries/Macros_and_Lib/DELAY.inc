;Ѕиблиотека временнќй задержки

_delay:	push	R16
		push	R17
		ldi		R16,0xFF
Nxt:	ldi		R17,0xFF
		dec		R17
		brne	PC-1
		dec		R16
		brne	Nxt
		pop		R17
		pop		R16
		ret
