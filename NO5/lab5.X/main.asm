

	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF
;1.	��д�ӳ���Bin2BCD��ʵ�ֶ���������ѹ��BCD���ת����
;	��ת���Ķ������������w�Ĵ����ڣ��ӳ��������ɺ�õ���BCD���Դ����w�Ĵ����ڷ��ء�����
;movlw .45; w=45
;call   Bin2BCD;
;nop      ;w=0x45
;��дMain�����򣬶Ա�д���ӳ�����в��ԡ�
;2.	��д�ӳ���Div_16��ʵ��˫�ֽ��޷��������������ж�����������У�
;ACCALO ;��ű������� 8 λ
;ACCAHI ;��ű������� 8 λ
;ACCBLO ;��ų��� 8 λ
;ACCCLO ;������� 8 λ
;ACCCHI ;����� 8 λ

 TEN              EQU    0x23  ;��ʱ�Ĵ���
 TEMP         EQU    0x24  ;��ʱ�Ĵ���

ACCALO	equ	0x25	;��ų����� 8 λ
 ACCAHI	equ	0x26	;��ų����� 8 λ
 ACCBLO	equ	0x27	;��ű������� 8 λ�ͳ˻��� 16��23 λ
 ACCCLO	equ	0x29	;��ų˻��� 0��7 λ
 ACCCHI	equ	0x2a	;��ų˻��� 8��15 λ
NEXTC	equ	0x2b	;��ʱ�Ĵ���
BTL	equ	0x2c	;��ʱ�Ĵ���
	
#define	A_16	0x4015
#define	B_16	0x3321

;**********************************************************************
	ORG         0x0000           ; ��λ��ڵ�ַ
	nop	                                 ; ����ICD���Թ��ߣ������nop
  	goto        Main                 ; ��ת��Main����
;**************************************Main �����Ĵ���**************
Main                                               
	movlw	.45
	call	Bin2BCD
	movlw	.20
	call	Bin2BCD
	movlw	.55
	call	Bin2BCD
	movlw	.5
	call	Bin2BCD
	nop
	nop
	goto           $                        ; ��ѭ��
	
;**********************������תBCD***************************************	    
Bin2BCD
	    movwf	TEMP	;��w�Ĵ�������
	    clrf	TEN	;TENÿ�����㣬��֤��ȷ
	    movlw	.10	
	    subwf	TEMP,f	;ѭ����TEMPÿ�μ�10
	    btfss	STATUS,C
	    goto	$ + 3	;f<w
	    incf	TEN,f	;f>w��ten+1,������
	    goto	$ - 4
	    addwf	TEMP,w	;���һ��ѭ�������10���˴��ӻ������õ���λ
	    swapf	TEN,f	;��ʮλ���ڸ���λ
	    iorwf	TEN,w	;w����λʮλ������λ��λ
	    return
;******************************˫�ֽ��޷���������******************************
;	ACCAHI ACCALO / ACCBLO = ACCCHI ........ ACCCLO
Div_16
	    movlw	high(ACCA)
	    movwf	ACCAHI
	    movlw	low(ACCA)
	    movwf	ACCALO
	    movlw	.8
	    movwf	TEMP
	    movlw	ACCB
	    movwf	ACCBLO
	    
MLOOP	    subwf	ACCAHI,f
	    btfsc	NEXTC,1
	    goto	$ + 3	;NEXTC=1		
	    btfss	STATUS,C	;NEXTC=0
	    goto	$ + 3	;f<w
	    incf	ACCCHI,f	;f>w,�̼�һ
	    goto	$ + 2	;������һ�䣬������
	    addwf	ACCAHI,f	;f<w,�ټӻ�ȥ
	    rlf	ACCCHI,f	;
	    rlf	ACCALO
	    rlf	ACCAHI
	    btfsc	STATUS,C
	    incf	NEXTC,f
	    DECFSZ  TEMP                   ; �˷���ɷ�
	    GOTO      MLOOP                ; �񣬼�����˻�
	RETURN                               ; �ӳ��򷵻�
	    
END                                                     ; �������

