/*
Макроопределения всегда должны быть определены прежде чем они будут 
использованы. Другими словами, определения макросов должны распологаться 
по тексту программы ВЫШЕ, чем строки программы в которых они используются
*/

.macro	subi16			;Вычетание числа из 16-и разрядного регистра 
	subi	@0L,low (@1)
	sbci	@0H,high(@1)
.endm

.macro    addi			;Операция сложения 
    subi	@0,-@1
.endm

.macro    addi16		;Операция сложения числа c 16-и разрядным регистром
    subi	@0L,low (-@1)
	sbci	@0H,high(-@1)
.endm

.macro	outi			;Загрузка числа в РВВ
	ldi		R16,@1
	out		@0,R16
.endm

.macro    table         ;Загрузка в регистр Z адреса начала таблицы констант в памяти программ
    ldi		ZL,low (@0*2)
    ldi		ZH,high(@0*2)
.endm

.macro    ldx           ;Загрузка в регистр X слова
    ldi		XL,low (@0)
    ldi		XH,high(@0)
.endm

.macro    ldy           ;Загрузка в регистр Y слова
    ldi    YL,low (@0)
    ldi    YH,high(@0)
.endm

.macro    ldz           ;Загрузка в регистр Z слова
    ldi    ZL,low (@0)
    ldi    ZH,high(@0)
.endm

.macro    clbr          ;Сброс разряда в регистре
    cbr		@0,(1<<@1)
.endm

.macro    stbr          ;Установка разряда в регистре
    sbr		@0,(1<<@1)
.endm

.macro    bbrc          ;Переход, если бит в РОН сброшен
    sbrs	@0,@1		;bbrc	temp,4,Metka
    rjmp	@2
.endm

.macro    bbrs          ;Переход, если бит в РОН установлен
    sbrc	@0,@1		;bbrs	temp,4,Metka
    rjmp	@2
.endm

.macro    bbic          ;Переход, если бит в РВВ сброшен
    sbis	@0,@1		;bbic	ACSR,5,Metka
    rjmp	@2
.endm

.macro    bbis          ;Переход, если бит в РВВ установлен
    sbic	@0,@1		;bbis	ACSR,5,Metka
    rjmp	@2
.endm

.macro	  save			;Сохранение 16-и битного РОН в памяти данных
	sts		@1	,@0H	;save	Y,0x60
	sts		@1+1,@0L	
.endm

.macro	  loads			;Загрузка из памяти 16-и битного РОН
	lds		@0H,@1		;loads	Y,0x60
	lds		@0L,@1+1
.endmacro

.macro plusr			;Сложение 16-битного и 8-битного регистров
	add		@0L,@1 		;plusr	Z,R16
	brcc	PC+2		
	inc		@0H 		
.endm

.macro irq				;Оформление прерываний
	.org	@0 			;irq 	0x02,INT_1
	rjmp	@1 
.endm

;ЗАПИСЬ РОН В РВВ ИЛИ В ПАМЯТЬ ДАННЫХ 
;Пример:
;	store	mem,temp	;Запись temp в ячейку памяти данных mem
;	store	PORTB,temp	;Запись temp в РВВ PORTB
.macro store			
	.if	@0>0x3F 		;Если адрес больше, чем 0х3F, то применить команду sts
		sts	@0, @1 
	.else 				;Если меньше, то out
		out	@0, @1 		
	.endif 
.endm
 
;СЧИТЫВАНИЕ В РОН ИЗ РВВ ИЛИ ИЗ ПАМЯТИ ДАННЫХ 
;Пример:
;	load	temp,mem	;Считывание в temp из ячейки памяти данных mem
;	load	temp,PORTB	;Считывание в temp из РВВ PORTB
.macro load		 		
	.if	@1>0x3F 		;Если адрес больше, чем 0х3F, то применить команду sts
		lds	@0, @1 		
	.else 				;Если меньше, то out
		in	@0, @1 
	.endif 
.endm

;УСТАНОВКА РАЗРЯДА В ЯЧЕЙКЕ ПАМЯТИ ДАННЫХ ИЛИ РВВ
;Пример:
;	setb	mem,2,temp
;	setb	SREG,2,temp
.macro setb
	.if @1>7 
		.message "Only values 0-7 allowed for Bit parameter" 
	.endif 
	.if @0>0x3F 			;Установка бита в ячейке памяти данных
		lds  @2, @0 
		sbr  @2, (1<<@1) 
		sts  @0, @2 
	.elif @0>0x1F 			;Установка бита в РВВ с адресом большим чем 0x1F
		in   @2, @0 
		sbr  @2, (1<<@1) 
		out  @0, @2 
	.else 					;Установка бита в РВВ с адресом меньшим чем 0x1F
		sbi  @0, @1 
	.endif 
.endm
 
;СБРОС РАЗРЯДА В ЯЧЕЙКЕ ПАМЯТИ ДАННЫХ ИЛИ РВВ
;Пример:
;	clrb	mem,2,temp
;	clrb	SREG,2,temp
.macro clrb
	.if @1>7 
		.message "Only values 0-7 allowed for Bit parameter" 
	.endif 
	.if @0>0x3F 			;Сброс бита в ячейке памяти данных
		lds  @2, @0 
		cbr  @2, (1<<@1) 
		sts  @0, @2 
	.elif @0>0x1F 			;Сброс бита в РВВ с адресом большим чем 0x1F
		in   @2, @0 
		cbr  @2, (1<<@1) 
		out  @0, @2 
	.else 					;Сброс бита в РВВ с адресом меньшим чем 0x1F
		cbi  @0, @1 
	.endif 
.endm
 
;ПРОПУСК СЛЕДУЮЩЕЙ КОМАНДЫ, ЕСЛИ БИТ В РВВ ИЛИ В ЯЧЕЙКЕ ПАМЯТИ ДАННЫХ УСТАНОВЛЕН
;Пример:
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
 
;ПРОПУСК СЛЕДУЮЩЕЙ КОМАНДЫ, ЕСЛИ БИТ В РВВ ИЛИ В ЯЧЕЙКЕ ПАМЯТИ ДАННЫХ СБРОШЕН
;Пример:
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