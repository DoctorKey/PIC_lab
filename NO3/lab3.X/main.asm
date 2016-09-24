list	p=16f877A
#include	<p16f877A.inc>
;CONFIG
;__config	0x3F7A
__CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
	ACCALO	EQU	0x70
	ACCAHI	EQU	0x71
	ACCBLO	EQU	0x72
	ACCBHI	EQU	0x73

	SUBALO	EQU	0x20
	SUBAHI	EQU	0x21
	SUBBLO	EQU	0x22
	SUBBHI	EQU	0x23
	
#define	ACCB	0x4C4B
#define	ACCA	0x40D2

;��дMain������ʹ�ñ���0x4C4B����0x40D2�Ա�д���ӳ�����мӷ��ͼ������ԡ�
;	���������ֿ�����ѡ��ע�����ݴ�С�Խ����Ӱ�졣��
org   0x0000
main
loop
	call	ADD_16
	nop
	call	SUB_16
	nop
	goto	loop

;1.	��д�ӳ��� Add_16��ʵ��˫�ֽ��޷������ӷ���
;	Ҫ���ڵ�ַ0x70~0x73�������ACCALO��ACCAHI��ACCBLO��ACCBHI��
;  ACCALO ;��ż����������8λ 
;  ACCAHI ;��ż����������8λ 
;  ACCBLO ;��ű������򱻼�����8λ ��Ž��
; ACCBHI ��ű������򱻼�����8λ	��Ž��
ADD_16	
	movlw	high(ACCB)
	movwf	ACCBHI	; ACCBHI ��ű������򱻼�����8λ
	movlw	low(ACCB)	
	movwf	ACCBLO	;  ACCBLO ;��ű������򱻼�����8λ 
	
	movlw	high(ACCA)
	movwf	ACCAHI	;  ACCAHI ;��ż����������8λ 
	movlw	low(ACCA)	
	movwf	ACCALO	;  ACCALO ;��ż����������8λ 
		
	addwf	ACCBLO,f	;��8λ��ӣ��������ACCBLO
	btfsc	STATUS,C	
	incf	ACCAHI,f	;C=1;�н�λ����8λ��1
	movf	ACCAHI,w
	addwf	ACCBHI,f	;��8λ��ӣ�����ACCBHI
	return
	
;2.	��д�ӳ���Sub_16��ʵ��˫�ֽ��޷�����������
;	Ҫ���ڵ�ַ0x20~0x23�������SUBALO��SUBAHI��SUBBLO��SUBBHI��
;  SUBALO ;��ż����������8λ 
;  SUBAHI ;��ż����������8λ 
;  SUBBLO ;��ű������򱻼�����8λ	 ��Ž��
;  SUBBHI ;��ű������򱻼�����8λ  ��Ž��
SUB_16
	movlw	high(ACCB)
	movwf	SUBBHI	; SUBBHI ��ű������򱻼�����8λ
	movlw	low(ACCB)	
	movwf	SUBBLO	;  SUBBLO ;��ű������򱻼�����8λ 
	
	movlw	high(ACCA)
	movwf	SUBAHI	;  SUBAHI ;��ż����������8λ 
	movlw	low(ACCA)	
	movwf	SUBALO	;  SUBALO ;��ż����������8λ 
	
	subwf	SUBBLO,f	;��8λ���
	btfss	STATUS,C
	decf	SUBBHI,f	;C=0,�н�λ����8λ��1
	movf	SUBAHI,w
	subwf	SUBBHI,f	;��8λ���
	return
	
	
END
