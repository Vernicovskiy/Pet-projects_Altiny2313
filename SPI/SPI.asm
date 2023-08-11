/*
 ����������� �������� ��������� SPI
 ��������������� ��������� � ���� Master-����������
 �������������� �������������� � ����� Slave-�����������
*/ 
.include "tn2313def.inc"

;### ����������� ����� ��� SPI ###
.equ	PORT_SPI	=PORTB
.equ	DDR_SPI		=DDRB
.equ	PIN_SPI		=PINB

;### ����������� ������� ��� SPI ###
.equ	CS			=PB0
.equ	MOSI		=PB1
.equ	MISO		=PB2
.equ	SCK			=PB3

.def	temp		=R16
.def	loop		=R17	

.cseg
.org	0x00
		rjmp	start

.org	0x20
start:		ldi		temp,RAMEND
			out		SPL,temp

;### ������������� ������� SPI ###
			sbi		DDR_SPI,CS		;CS �� �����
			sbi		DDR_SPI,MOSI	;MOSI �� �����
			sbi		DDR_SPI,SCK		;SCK �� �����
			cbi		DDR_SPI,MISO	;MISO �� ����
			
			sbi		PORT_SPI,CS		;������ �� ������ Slave-����������


;### �������� ���� ###
main:		cbi		PORT_SPI,SCK	;��� ������ 0 �� ������ SCK ������ ���� ���������� ������ �������
			ldi		temp,0xAA
			cbi		PORT_SPI,CS		;��������� Slave-����������
			rcall	SPI_RW0			;����� 0
			sbi		PORT_SPI,CS		;������ �� ������ Slave-����������


			sbi		PORT_SPI,SCK	;��� ������ 1 �� ������ SCK ������ ���� ���������� ������� �������
			cbi		PORT_SPI,CS		;��������� Slave-����������
			ldi		temp,0xAA
			rcall	SPI_RW1			;����� 1
			sbi		PORT_SPI,CS		;������ �� ������ Slave-����������


			cbi		PORT_SPI,SCK	;��� ������ 2 �� ������ SCK ������ ���� ���������� ������ �������
			ldi		temp,0xAA
			cbi		PORT_SPI,CS		;��������� Slave-����������
			rcall	SPI_RW2			;����� 2
			sbi		PORT_SPI,CS		;������ �� ������ Slave-����������


			sbi		PORT_SPI,SCK	;��� ������ 3 �� ������ SCK ������ ���� ���������� ������� �������
			ldi		temp,0xAA
			cbi		PORT_SPI,CS		;��������� Slave-����������
			rcall	SPI_RW3			;����� 3
			sbi		PORT_SPI,CS		;������ �� ������ Slave-����������
			rjmp	main


;#### �����/�������� ����� ����� 0. ������� ��� ������ ####
SPI_RW0:	ldi		loop,8			;��������� ������� ��������
			rol		temp			;�������� ���������� temp �����. ������� ��� � �
		;	ror		temp			;�������� ���������� temp ������. ������� ��� � �
spi0_loop:	brcs	MOSI0_1			;������� �� MOSI_1, ���� �=1
MOSI0_0:	cbi		PORT_SPI,MOSI	;����� MOSI
			rjmp	rx0_bit
MOSI0_1:	sbi		PORT_SPI,MOSI	;��������� MOSI
rx0_bit:	nop						;��������� �������� ����� �������� ���������
			sbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����������)
			sec
			sbis	PIN_SPI,MISO	;���������� �������� ����� MISO
			clc
			rol		temp			;�������� ��������� ��� � ������� ������ �������� temp
		;	ror		temp			;�������� ��������� ��� � ������� ������ �������� temp
			cbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����� ��������)
			dec		loop			;��������� ������� �����
			brne	spi0_loop		;�������� �� ��������� ���
			ret
			
;�������������� ������� ��������� �������� MOSI
;spi0_loop:	cbi		PORT_SPI,MOSI	
;			brc�	PC+2			;������� ��������� MOSI, ���� �=0
;			sbi		PORT_SPI,MOSI

;#### �����/�������� ����� ����� 1. ������� ��� ������ ####
SPI_RW1:	ldi		loop,8			;��������� ������� ��������
			rol		temp			;�������� ���������� temp �����. ������� ��� � �
		;	ror		temp			;�������� ���������� temp ������. ������� ��� � �
spi1_loop:	sbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����� ��������)
			brcs	MOSI1_1			;������� �� MOSI_1, ���� �=1
MOSI1_0:	cbi		PORT_SPI,MOSI	;����� MOSI
			rjmp	rx1_bit
MOSI1_1:	sbi		PORT_SPI,MOSI	;��������� MOSI
rx1_bit:	nop						;��������� �������� ����� �������� ���������
			cbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����������)
			sec
			sbis	PIN_SPI,MISO	;���������� �������� ����� MISO
			clc
			rol		temp			;�������� ��������� ��� � ������� ������ �������� temp
		;	ror		temp			;�������� ��������� ��� � ������� ������ �������� temp
			dec		loop			;��������� ������� �����
			brne	spi1_loop		;�������� �� ��������� ���
			ret

;#### �����/�������� ����� ����� 2. ������� ��� ������ ####
SPI_RW2:	ldi		loop,8			;��������� ������� ��������
			rol		temp			;�������� ���������� temp �����. ������� ��� � �
		;	ror		temp			;�������� ���������� temp ������. ������� ��� � �
spi2_loop:	brcs	MOSI2_1			;������� �� MOSI_1, ���� �=1
MOSI2_0:	cbi		PORT_SPI,MOSI	;����� MOSI
			rjmp	rx2_bit
MOSI2_1:	sbi		PORT_SPI,MOSI	;��������� MOSI
rx2_bit:	nop						;��������� �������� ����� �������� ���������
			cbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����������)
			sec
			sbis	PIN_SPI,MISO	;���������� �������� ����� MISO
			clc
			rol		temp			;�������� ��������� ��� � ������� ������ �������� temp
		;	ror		temp			;�������� ��������� ��� � ������� ������ �������� temp
			sbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����� ��������)
			dec		loop			;��������� ������� �����
			brne	spi2_loop		;�������� �� ��������� ���
			ret

;#### �����/�������� ����� ����� 3. ������� ��� ������ ####
SPI_RW3:	ldi		loop,8			;��������� ������� ��������
			rol		temp			;�������� ���������� temp �����. ������� ��� � �
		;	ror		temp			;�������� ���������� temp ������. ������� ��� � �
spi3_loop:	cbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����� ��������)
			brcs	MOSI3_1			;������� �� MOSI_1, ���� �=1
MOSI3_0:	cbi		PORT_SPI,MOSI	;����� MOSI
			rjmp	rx3_bit
MOSI3_1:	sbi		PORT_SPI,MOSI	;��������� MOSI
rx3_bit:	nop						;��������� �������� ����� �������� ���������
			sbi		PORT_SPI,SCK	;������������� ������� ��������� �������� (����������)
			sec
			sbis	PIN_SPI,MISO	;���������� �������� ����� MISO
			clc
			rol		temp			;�������� ��������� ��� � ������� ������ �������� temp
		;	ror		temp			;�������� ��������� ��� � ������� ������ �������� temp
			dec		loop			;��������� ������� �����
			brne	spi3_loop		;�������� �� ��������� ���
			ret
