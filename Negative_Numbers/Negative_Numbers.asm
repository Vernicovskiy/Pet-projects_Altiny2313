;### ОТРИЦАТЕЛЬНЫЕ ЧИСЛА ###

.include "tn2313def.inc"

.def	temp		=R16

main:	ldi		temp,0x0F
		com		temp			;Перевод числа в обратный код (инверсия разрядов): 0xFF - temp
		nop
		nop

		com		temp			;Обратный перевод
		nop
		nop

		neg		temp			;Перевод числа в дополнительный код: 0x00 - temp
		nop
		nop
		neg		temp			;Обратный перевод
		nop
		com		temp			;Перевод в обратный код  = инверсия и увеличение на 1
		inc		temp
		nop

		clr		R17
		sub		R17,temp		;Перевод в дополнительный код и сохранение в R17
		nop
		nop

		ldi		temp,-0x0F		;Загрузка в регистр дополнительного кода числа -0x0F
		nop
		nop
		neg		temp			;Преобразование в положительное число 0x0F
		nop
		nop
		ldi		temp,-239		;В регистре temp отрицательное число -239
		nop
		neg		temp			;В регистре temp положительное число 239
		nop
		
		cln						;Флаг N сброшен в 0
		ldi		temp,0b01111111
		inc		temp			;Флаг N установлен в 1
		cln						;Флаг N сброшен в 0
		nop
		nop
		sbr		temp,(1<<7)		;Флаг N установлен в 1
		cln						;Флаг N сброшен в 0

		ldi		temp,15
		subi	temp,20			;15-20 = 0xFB
		brpl	PC+2			;Проверка разряда N. Если N = 1, то число отрицательное
		neg		temp			;Если число отрицательное, то преобразуем его в положительное
		nop						;Бит С = 1 => число отрицательное

		ldi		temp,20
		subi	temp,15			;20-15 = 0x05
		brpl	PC+2
		neg		temp
		nop						;Бит С = 0 => число положительное

		ldi		temp,-15
		subi	temp,20			;-15 - 20 = 0xF1 - 20 = 241 - 20 = 221
		brpl	PC+2
		neg		temp			;15 + 20 = 35
		nop						;Бит С = 1 => число отрицательное


;#### СЛОЖЕНИЕ РОН И КОНСТАНТЫ ####
		ldi		temp,0x10
		subi	temp,-0x20		;Сложение числа 0х10 и 0х20. Или 0х10 - (-0х20) = 0х10 - 0хЕ0 = 0x30
		nop						;Флаг переполнения С = 1
		nop

		ldi		temp,0xF0
		subi	temp,-0xF0		;Сложение числа 0хF0 и 0хF0. Или 0хF0 - (-0хF0) = 0хF0 - 0х10 = 0xE0
		nop						;Флаг переполнения С = 0
		nop


;#### СЛОЖЕНИЕ 16-БИТНЫХ КОНСТАНТ БЕЗ ПЕРЕПОЛНЕНИЯ ####
.equ	const1	=0xC5D0
.equ	const2	=0x02C0

		ldi		ZL,low (const1)
		ldi		ZH,high(const1)

		subi	ZL,low (-const2)	;Сложение const2 и const1
		sbci	ZH,high(-const2)	;Переполнения нет, но флаг С установлен в 1

;#### СЛОЖЕНИЕ 16-БИТНЫХ КОНСТАНТ С ПЕРЕПОЛНЕНИЕМ ####
.equ	const_1	=0xC5D0
.equ	const_2	=0xF2CF

		ldi		ZL,low (const_1)
		ldi		ZH,high(const_1)

		subi	ZL,low (-const_2)	;Сложение const2 и const1
		sbci	ZH,high(-const_2)	;Переполнение есть, но флаг С сброшен в 0



;#### СЛОЖЕНИЕ 32-БИТНЫХ КОНСТАНТ ####
.equ	const4_1	=0x0FFEFDFC
.equ	const4_2	=0x0F0E0D0C

		ldi		R16,byte1(const4_1)
		ldi		R17,byte2(const4_1)
		ldi		R18,byte3(const4_1)
		ldi		R19,byte4(const4_1)

		subi	R16,byte1(-const4_2)
		sbci	R17,byte2(-const4_2)
		sbci	R18,byte3(-const4_2)
		sbci	R19,byte4(-const4_2)	;Переполнения нет, но флаг С установлен в 1


		rjmp	main
