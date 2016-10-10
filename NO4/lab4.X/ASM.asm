

	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF

 MA              EQU    0x20  ;��ų���
 MB              EQU    0x21  ;��ű������ͳ˻� �� 8��15 λ
 MC              EQU    0x22  ;��ų˻��� 0��7 λ
 MD              EQU    0x23  ;��ʱ�Ĵ���
 TEMP         EQU    0x24  ;��ʱ�Ĵ���

ACCALO	equ	0x25	;��ų����� 8 λ
 ACCAHI	equ	0x26	;��ų����� 8 λ
 ACCBLO	equ	0x27	;��ű������� 8 λ�ͳ˻��� 16��23 λ
 ACCBHI	equ	0x28	 ;��ű������� 8 λ�ͳ˻��� 24��31 λ
 ACCCLO	equ	0x29	;��ų˻��� 0��7 λ
 ACCCHI	equ	0x2a	;��ų˻��� 8��15 λ
BTH	equ	0x2b	;��ʱ�Ĵ���
BTL	equ	0x2c	;��ʱ�Ĵ���
	
#define	A_16	0x4015
#define	B_16	0x3321
;***************************8 ��8 λ�޷��ų˷� ��ָ��***********************	
mpy	macro
	MOVLW	0xFE               ; ������0xFE �� MB
	MOVWF	MA	
	MOVLW	0xAB               ; ���� 0xAB�� MA
	MOVWF	MB	
	CALL	SETUP                    ;�����ӳ��򣬽�MB ��ֵ�� MD
 
	BCF          STATUS, C          ; ���λλ
	RRF         MD                        ; MD ����
	BTFSC    STATUS, C           ;�ж��Ƿ���Ҫ���
	CALL       Add_8                   ; �ӳ����� MB
	RRF         MB                         ; ���Ʋ��ֳ˻�
	RRF         MC	
	DECFSZ  TEMP                   ; �˷���ɷ�
	GOTO      $ - 7                ; �񣬼�����˻�
	endm
;**********************************************************************
	ORG         0x0000           ; ��λ��ڵ�ַ
	nop	                                 ; ����ICD���Թ��ߣ������nop
  	goto        Main                 ; ��ת��Main����
;**************************************Main �����Ĵ���**************
Main                                               
	MOVLW  0xFE               ; ������0xFE �� MB
	MOVWF  MA	
	MOVLW  0xAB               ; ���� 0xAB�� MA
	MOVWF  MB	
	CALL         Mpy_8            ; ����˫�ֽڳ˷��ӳ�����������ӦΪ0xA9AA
	nop
	mpy		;��ָ����ֽ��޷������˷�	
	nop
	call	Mpy_16
	nop
            nop
            goto           $                        ; ��ѭ��
;*********************************8 ��8 λ�޷��ų˷��ӳ��� ********************
	 ORG  0X0100
Mpy_8                 
            CALL    SETUP                    ;�����ӳ��򣬽�MB ��ֵ�� MD
MLOOP  
	BCF          STATUS, C          ; ���λλ
	RRF         MD                        ; MD ����
	BTFSC    STATUS, C           ;�ж��Ƿ���Ҫ���
	CALL       Add_8                   ; �ӳ����� MB
	RRF         MB                         ; ���Ʋ��ֳ˻�
	RRF         MC	
	DECFSZ  TEMP                   ; �˷���ɷ�
	GOTO      MLOOP                ; �񣬼�����˻�
	RETURN                               ; �ӳ��򷵻�
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
SETUP  
	MOVLW    .8                        ;��ʼ�� TEMP �Ĵ��� 
	MOVWF    TEMP
	MOVF         MB, W              ; ������MD
	MOVWF    MD             
	CLRF          MB                     ; �� MB
	 CLRF          MC                     ;�� MC
	RETURN                              ;�ӳ��򷵻�
Add_8         
	MOVF        MA, w                ;MA��MB��� 
	ADDWF    MB ,F	
	RETURN                               ;�ӳ��򷵻�  

;*****************************16*16λ�޷��ų˷�************************
;	ACCAHI ACCALO * ACCBHI ACCBLO = ACCBHI ACCBLO ACCCHI ACCCLO
Mpy_16
	movlw	.16
	movwf	TEMP	;��λ16��
	
	movlw	high(A_16)
	movwf	ACCAHI
	movlw	low(A_16)
	movwf	ACCALO
	movlw	high(B_16)
	movwf	ACCBHI
	movwf	BTH	;��ʱ�Ĵ�������B��8λ
	movlw	low(B_16)
	movwf	ACCBLO
	movwf	BTL	;��ʱ�Ĵ�������B��8λ
	
	clrf	ACCBHI
	clrf	ACCBLO
	clrf	ACCCHI
	clrf	ACCCLO	;����
M16LOOP
	bcf	STATUS, C	 ; ���λ
	rrf	BTH	; B��8λ����
	rrf	BTL	;B��8λ����
	btfsc	STATUS, C   ;�ж��Ƿ���Ҫ���
	call	ADD_16      ; �ӳ����� ACCB
	rrf	ACCBHI	; ���Ʋ��ֳ˻�
	rrf	ACCBLO
	rrf	ACCCHI
	rrf	ACCCLO
	decfsz	TEMP	; �˷���ɷ�
	goto	M16LOOP	; �񣬼�����˻�
	return		; �ӳ��򷵻�
	
ADD_16	;ACCAHI ACCALO + ACCBHI ACCBLO = ACCBHI ACCBLO
	movf	ACCALO,w	
	addwf	ACCBLO,f	;��8λ��ӣ��������ACCBLO
	btfsc	STATUS,C	
	incf	ACCAHI,f	;C=1;�н�λ����8λ��1
	movf	ACCAHI,w
	addwf	ACCBHI,f	;��8λ��ӣ�����ACCBHI
	return

END                                                     ; �������

