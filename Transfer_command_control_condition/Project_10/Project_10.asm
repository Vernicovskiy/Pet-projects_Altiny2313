							
							/*������ ������ �������� ���������� �� �������*/


.def	temp	=R16
		

;��������� ��������
		ldi		temp,0xFF
delay:	dec		temp
		brne	delay	 	;���� temp �� ����, �� ������� �� ����� delay
	;	brne	PC-1		;��� ���, ���� temp �� ����, �� ������� �� ���������� �����



;������� �� ����������� ���������
		cpi		temp,0xF1
		breq	action_1	;������� �� action_1, ���� temp ����� 0xFE
		brcs	action_2	;������� �� action_2, ���� temp ������ 0xFE
		brcc	action_3	;������� �� action_2, ���� temp ������ 0xFE

action_3:					
		nop					;�������� 3
		rjmp	Ext
action_2:
		nop					;�������� 2
		rjmp	Ext
action_1:
		nop					;�������� 1

Ext:						;�����


;��������� � �������
		cpi		temp,1
		breq	act_1	;���� temp = 1, �� ��������� �� act_1
		cpi		temp,2
		breq	act_2	;���� temp = 2, �� ��������� �� act_2
		cpi		temp,3
		breq	act_3	;���� temp = 3, �� ��������� �� act_3
		cpi		temp,4
		breq	act_4	;���� temp = 4, �� ��������� �� act_4
		rjmp	End_Act
act_1:	nop				;�������� 1
		rjmp	End_Act
act_2:	nop				;�������� 2
		rjmp	End_Act
act_3:	nop				;�������� 3
		rjmp	End_Act
act_4:	nop				;�������� 4

End_Act:				;�����	


;����� �������� ���� brXX � ������ ��������� ������ ���� �� ������ ��� 63 ������ �������� ����� � 64 ������ ������

;������ ������, ������� ��������� ��� ���������� ����� ��c�������:

		cpi		temp,1
		breq	metka_too_far
;		nop		;���� ��� ������� �����������������, �� ��������� �������� 64 ������ �������� ������
		nop		
		nop
		nop 
		nop
		nop
		nop 
		nop
		nop
		nop
		nop
		nop
		nop	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

metka_too_far:
		
		rjmp	PC
