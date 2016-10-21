

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

ACCALO	equ	0x25	;��ű�����
 ACCAHI	equ	0x26	;��ű�����
 ACCBLO	equ	0x27	;��ų���
NACCBLO	equ	0x28	;��ų����Ĳ���
 ACCCLO	equ	0x29	;�������
 ACCCHI	equ	0x2a	;�����
NO_B	equ	0x2b	;�����ķ���λ
BTL	equ	0x2c	;��ʱ�Ĵ���
LOG	equ	0x2d	;�����Ĵ���������λΪ����������λ
COUNT	equ	0x2e	;�����Ĵ���
	
#define	ACCA	0x3453	;0x3453/0xb5=0x4a......0x01
#define	ACCB	0xb5	;

;**********************************************************************
	ORG         0x0000           ; ��λ��ڵ�ַ
	nop	                                 ; ����ICD���Թ��ߣ������nop
  	goto        Main                 ; ��ת��Main����
;**************************************Main �����Ĵ���**************
Main                                               
	movlw	.45
	call	Bin2BCD
	call	BCD2Bin
	movlw	.20
	call	Bin2BCD
	call	BCD2Bin
	movlw	.55
	call	Bin2BCD
	call	BCD2Bin
	movlw	.5
	call	Bin2BCD
	call	BCD2Bin
	call	Div_16
	nop
	call	Div_16_e2
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
;**********************BCDת������***************************************
BCD2Bin
	    movwf	TEMP	;��w�Ĵ�������
	    andlw	0xf0	;��ȡ����λ
	    movwf	TEN
	    swapf	TEN,w	;��w�Ĵ���ʮλ�Ƶ�����λ
	    bcf	STATUS,C
	    rrf	TEN,f	;����һλ����TEN*8	    
	    addwf	TEN,f
	    addwf	TEN,f	;�����Σ���TEN*10
	    movf	TEMP,w
	    andlw	0x0f
	    addwf	TEN,w	;ʮλ��λ���
	    return
;******************************˫�ֽ��޷���������******************************
;	ACCAHI ACCALO / ACCBLO = ACCCHI ........ ACCCLO
Div_16
	    movlw	high(ACCA)
	    movwf	ACCAHI
	    movlw	low(ACCA)
	    movwf	ACCALO
	    movlw	.8
	    movwf	COUNT
	    movlw	ACCB
	    movwf	ACCBLO	;B
	    comf	ACCBLO,w
	    movwf	NACCBLO
	    incf	NACCBLO,f	;B�Ĳ���
	    clrf	ACCCHI
	    clrf	ACCCLO
	    clrf	LOG
	    
	    movf	ACCBLO,w
	    subwf	ACCAHI,f
	    btfss	STATUS,C
	    goto	$ + 3	
	    bsf	LOG,7	;���
	    return
SHANG0	    movf	ACCBLO,w
LOOP	    rlf	ACCCHI	;������һλ
	    rlf	ACCALO,f
	    rlf	ACCAHI,f	;����������һλ    
	    addwf	ACCAHI,f	;ACCAHI=ACCAHI+w
	    decfsz	COUNT
	    goto	$ + 2
	    goto	LAST
	    btfss	STATUS,C
	    goto	SHANG0	;C=0,û�����
	    movf	NACCBLO,w
	    goto	LOOP
LAST	
	    btfsc	STATUS,C
	    goto	$ + 3	;C=1,���ü�
	    movf	ACCBLO,w	;C=0,��������
	    addwf	ACCAHI,f
	    movf	ACCAHI,w
	    movwf	ACCCLO
	    return
;******************************˫�ֽ��޷���������******************************
;	ACCAHI ACCALO / ACCBLO = ACCCHI ........ ACCCLO
;	��չ��������λ������C
Div_16_e2
	    movlw	high(ACCA)
	    movwf	ACCAHI
	    movlw	low(ACCA)
	    movwf	ACCALO
	    movlw	.8
	    movwf	COUNT
	    movlw	ACCB
	    movwf	ACCBLO	;B
	    comf	ACCBLO,w
	    movwf	NACCBLO
	    incf	NACCBLO,f	;B�Ĳ���
	    clrf	ACCCHI
	    clrf	ACCCLO
	    clrf	LOG
	    
	    call	sub
	    btfsc	LOG,0
	    btfss	LOG,1	;LOG(0)=1
	    goto	$ + 2	;LOG(0)=0||LOG(1)=0
	    goto	shang_e2	;LOG(1)=1	
	    bsf	LOG,7	;���
	    return 
	    
shang_e2	    rlf	ACCALO,f
	    rlf	ACCAHI,f	;����������һλ
	    rlf	LOG,f	;����λ����һλ
	    
	    btfss	ACCCHI,0
	    call	add	;�ϴ���0�����ִ�мӷ�
	    btfsc	ACCCHI,0
	    call	sub	;�ϴ���1�����ִ�м���
	    
	    rlf	ACCCHI	;������һλ
	    
	    decfsz	COUNT
	    goto	$ + 2
	    goto	LAST_e2	
	    
	    btfsc	LOG,0
	    btfss	LOG,1	;LOG(0)=1
	    goto	$ + 3	;LOG(0)=0||LOG(1)=0��Ϊ��������1
	    bcf	ACCCHI,0	;LOG(1)=1,Ϊ����,��0
	    goto	shang_e2
	    bsf	ACCCHI,0
	    goto	shang_e2
LAST_e2	
	    btfsc	LOG,0
	    btfss	LOG,1	;LOG(0)=1
	    goto	$ + 3	;LOG(0)=0||LOG(1)=0����������		
	    call	add	;LOG(1)=1,��Ϊ����Ҫ����
	    goto	$ + 2
	    bsf	ACCCHI,0	;��1
	    movf	ACCAHI,w
	    movwf	ACCCLO
	    return
;A+B,AΪLOG(1:0)ACCAHI,BΪACCBLO������λΪ00������
add
	    movf	ACCBLO,w
	    addwf	ACCAHI,f
	    btfsc	STATUS,C
	    incf	LOG,f
	    movlw	0x00
	    addwf	LOG,f
	    return
;A-B��AΪLOG(1:0)ACCAHI,BΪNACCBLO���ҷ���λΪ11
sub
	    movf	NACCBLO,w
	    addwf	ACCAHI,f
	    btfsc	STATUS,C
	    incf	LOG,f
	    movlw	0x03
	    addwf	LOG,f
	    return
END                                                     ; �������

