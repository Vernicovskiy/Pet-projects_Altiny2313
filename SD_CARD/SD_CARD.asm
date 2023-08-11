/* 
���������������� ��������� ��� ������ � ������ SD-����
��������� �������� ������ � �������, ��������������� ����� �� SPI
�������������� �����: SD, microSD, SDHC, microSDHC
�����, ������� �� ������������� �� �����������������: SDXC, microSDXC, MMC, RS-MMC 

������������ ����������� �������� ��������� SPI: ����� 0, �������� ������� ����� ������

������ � ������ ���� ������������� ��������� �������� � 512 ����

������� �� ������ � ������ ���������� ����� USART
����� ����������� ������ ������������� ����� USART

���������������		ATtiny2313
�������� ������� 	8 MHz (������� ��������� ���������)
�������� USART		9600
��������			���
���-�� ���� ���		1
*/ 
.include "tn2313def.inc"


;���� ��� ����������� SD-�����:
.equ	PORT_SD		=PORTB
.equ	DDR_SD		=DDRB
.equ	PIN_SD		=PINB

;������ ����� ��� ����������� SD-�����:
.equ	CS			=PB0
.equ	MOSI		=PB1
.equ	MISO		=PB2
.equ	SCK			=PB3

;������� ��������:
.def	temp		=R16
.def	loop		=R17

;�������� ��� �������� ��������� �������
.def	SDmemLL		=R1		;0-� ���� ��������� (���������� ���������)
.def	SDmemLH		=R2		;1-� ���� ���������
.def	SDmemHL		=R3		;2-� ���� ���������
.def	SDmemHH		=R4		;3-� ���� ��������� (���������� ������)

;��������� ���������� �����
.equ	XTALL		=8000000				;�������� ������� ����������������
.equ	BAUD		=9600					;�������� ������ �������
.equ	SPEED		=(XTALL/(16*BAUD))-1	;��������� ��� �������� UBRR


;������ �������� � �������� 32-������� ��������� (����� ������� ��� SD��-����):
.macro	arg						
		push	R16
		ldi		R16,byte1(@0)
		mov		SDmemLL,R16
		ldi		R16,byte2(@0)
		mov		SDmemLH,R16
		ldi		R16,byte3(@0)
		mov		SDmemHL,R16
		ldi		R16,byte4(@0)
		mov		SDmemHH,R16
		pop		R16
.endm

;������ �������� � �������� 32-������� ������ ������� (��� SD-����):
.macro	sector					
		push	R16
		ldi		R16,byte1(@0*512)	;����� ��������� �� 512
		mov		SDmemLL,R16
		ldi		R16,byte2(@0*512)
		mov		SDmemLH,R16
		ldi		R16,byte3(@0*512)
		mov		SDmemHL,R16
		ldi		R16,byte4(@0*512)
		mov		SDmemHH,R16
		pop		R16
.endm


.cseg
.org	0x00
		rjmp	start

.org	0x20
start:	ldi		temp,RAMEND
		out		SPL,temp

		ldi		temp,(1<<RXEN|1<<TXEN)		;��������� USART
		out		UCSRB,temp
		ldi		temp,(1<<UCSZ1|1<<UCSZ0)
		out		UCSRC,temp
		ldi		temp,high(SPEED)
		out		UBRRH,temp
		ldi		temp,low(SPEED)
		out		UBRRL,temp

		
;******************************* �������� ���� *********************************************
MAIN:	;	rcall	in_com		;���� ���-�����
		;	inc		temp	
		;	rcall	out_com
		;	rjmp	PC-3

			rcall	in_com		;�������� ����������� ������� �� �������������
		
			rcall	SD_init		;������������� ����� 
								;� ����� ����� USART ����� �������� 2 �����: 0x01,0�01 ��� 0x01,0�05
			rcall	in_com		;�������� ����������� ������� �� ������/������ �������

;####################################################################
;############ ��� ���� SD (���� � ���������� ����������) ############
;####################################################################
			arg		(512*2)		;������ �� 2 ������ (����� � ������ 512*2 = 1024)
			rcall	Write_SD
			arg		(512*2)		;������ �� 2 ������� (����� � ������ 512*2 = 1024)
			rcall	Read_SD

		rcall	in_com			;�����

			sector	10			;������ � 10 ������ (����� � ������ 512*10 = 5120)
			rcall	Write_SD
			sector	10			;������ �� 10 ������� (����� � ������ 512*10 = 5120)
			rcall	Read_SD
;####################################################################		
			
		rcall	in_com			;�����

;####################################################################
;############ ��� ���� SDHC (���� � ����������� ����������) #########
;############ ����� SD (� ���������� ����������) "��������" #########
;####################################################################
			arg		20			
			rcall	Write_SD	;������ � 20 ������ (��� ���� � ����������� ����������)
			arg		20			
			rcall	Read_SD		;������ �� 20 ������� (��� ���� � ����������� ����������)
;####################################################################

			rjmp	MAIN
;******************************************************************************************


	
		;#############################
		;#### ������������� ����� ####
		;#############################
SD_init:	sbi		DDR_SD,CS		;�������� ������� Chip Select ���������� ����
			sbi		DDR_SD,MOSI		;����� Master Output �� �����
			sbi		DDR_SD,SCK		;����� �������� ��������� �� �����
			cbi		DDR_SD,MISO		;����� Master Input �� ����
			
			sbi		PORT_SD,MISO	;������������� �������� MISO �������

			sbi		PORT_SD,CS		;Slave-���������� �� �������
			
			rcall	SD_80_clock		;���������� � ������. 80 ������ ��� MOSI=1

			cbi		PORT_SD,CS		;Slave-���������� �������
			
			arg		0x00			;������� ��������
			ldi		temp,0x40		;������ ������� CMD0 (0x40) ��� �������� � SPI
			ldi		loop,0x95		;CRC
			rcall	SD_CMD
			rcall	out_com			;�������� �� USART ����� �������. ���������� ������ 0x01

			arg		0x1AA			;�������� 0x1AA
			ldi		temp,0x48		;������� ������������� 0x48
			ldi		loop,0x87		;CRC 0x87
			rcall	SD_CMD
			rcall	out_com			;�������� �� USART ����� �������. ��� ����� ���� ���������� ������ 0x01

			rcall	SD_80_clock		;����� � 80 ������ ��� MOSI=1

			arg		0x40000000		;�������� 0x40000000
Send_Init:	ldi		temp,0x41		;������� ������������� CMD1 (0�41) � ����������	0x40000000
			rcall	SD_CMD
			tst		temp			;�������� �������, ������� ����
			brne	Send_Init		;�������� ����� 0,1..0,3 ���
			rcall	SPI_Write_FF	;�����
			ret


;#### �������� ������� �� 6 ����. ����� 1 ����� ������� ####
;����� temp ���������� �������. ����� loop ���������� CRC
SD_CMD:		push	temp			;����� ������� temp ���������� �������
			rcall	SPI_Write_FF	;�����
			pop		temp
			rcall	SPI_Write		;�������� �������
			mov		temp,SDmemHH
			rcall	SPI_Write		;3-� ���� ���������
			mov		temp,SDmemHL
			rcall	SPI_Write		;2-� ���� ���������
			mov		temp,SDmemLH
			rcall	SPI_Write		;1-� ���� ���������
			mov		temp,SDmemLL	
			rcall	SPI_Write		;0-� ���� ���������
			mov		temp,loop		;����������� ����� CRC
			rcall	SPI_Write		
			rcall	SPI_Write_FF	;�����
			rcall	SPI_Read		;����� ����� ������� � ������� temp
			ret
			
						
;#### �����/�������� ����� ����� SPI ####
;#### ����� 0  ������� ���� - ������ ####
;������������ ���� � �������� temp, �������� ���� � �������� temp
SPI_Write_FF:						;����� (�������� ����� 0xFF)
SPI_Read:	ser		temp			;������ ����� (������������ ���� 0xFF)
SPI_Write:	push	loop			;������ ����� (������������ ���� � �������� temp)
			ldi		loop,8			;������� ����������/�������� �����
			rol		temp			;����� �������� ���� � ��� ��������
Nxt_spi_bt:	cbi		PORT_SD,MOSI	;����� MOSI ���� ��� ����� ����
			brcc	PC+2
			sbi		PORT_SD,MOSI	;��������� MOSI ���� ��� ����� �������
			nop						;�����
			sbi		PORT_SD,SCK		;�������� ����� �����
			sec
			sbis	PIN_SD,MISO		;���������� ��������� ������ MISO
			clc
			rol		temp			;��������� ��������� ���������� � ������� ��� temp
			cbi		PORT_SD,SCK		;��������� ��������� ��������
			dec		loop
			brne	Nxt_spi_bt
			pop		loop
			ret


;#### 80 ������ ����� ####
SD_80_clock:sbi		PORT_SD,MOSI	;����� MOSI = 1
			ldi		loop,10				
			rcall	SPI_Write_FF	;�������� 8 ������
			dec		loop
			brne	PC-2
			ret


;###################################
;#### ������ ������� � 512 ���� ####
;###################################
Write_SD:	ldi		temp,0x58		;������� �� ������ �������
			rcall	SD_CMD
		;	rcall	out_com			;������� ����� ������ ����� USART (��� �������� ������������ ������)
			ldi		temp,0xFE		;��� ������ ����� ������ �������� ���� 0xFE
			rcall	SPI_Write		
			rcall	write_512		;������ ����� �� 512 ����
			rcall	SPI_Write_FF	;������ CRC 1
			rcall	SPI_Write_FF	;������ CRC 2
			rcall	SPI_Write_FF	;�����
wait_DO:	rcall	SPI_Write_FF	;�������� ��������� ������ DO � 1 (100..130 )
			sbis	PIN_SD,MISO
			rjmp	wait_DO
			ret
;*** ������ ����� �� 512 ���� ***
Write_512:		ldi		ZL,low (512)	;�������� �������� � ������� ���������� ����
				ldi		ZH,high(512)
repeat_write:	mov		temp,ZL			;������� � ������� temp ������� �������� ��������
				rcall	SPI_Write		;� ���������� ��� �������� � �����
				sbiw	ZL,1			;��������� ������� �� 1
				brne	repeat_write	;���� �� ����, ���������� ��������� ����
				ret

;###################################
;#### ������ ������� � 512 ���� ####
;###################################
Read_SD:	ldi		temp,0x51		;������� �� ������ �������	
			rcall	SD_CMD
		;	rcall	out_com			;������� ����� ������ ����� USART (��� �������� ������������ ������)
Wait_0xFE:	rcall	SPI_Read		;�������� 0xFE
			cpi		temp,0xFE
			brne	Wait_0xFE	
			rcall	Read_512		;������ ����� �� 512 ����
			rcall	SPI_Read		;������ CRC 1
			rcall	SPI_Read		;������ CRC 2
			rcall	SPI_Write_FF	;�����
			ret
;*** ������ ����� �� 512 ���� ***
Read_512:		ldi		ZL,low (512)	;�������� �������� � ������� �������� ����
				ldi		ZH,high(512)	
repeat_read:	rcall	SPI_Read		;������ �����
				rcall	out_com			;������� ����� ����� USART
				sbiw	ZL,1			;��������� ������� �� 1
				brne	repeat_read		;���� �� ����, ������ ��������� ����
				ret


;****************************************************************************
	;#### �������� ����� ����� UART ####
out_com:	sbis	UCSRA,UDRE
			rjmp	out_com
			out		UDR,temp
			ret
	;#### ����� ����� ����� UART ####
in_com:		sbis	UCSRA,RXC
			rjmp	in_com
			in		temp,UDR
			ret


