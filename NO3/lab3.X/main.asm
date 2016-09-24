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

;编写Main主程序，使用被数0x4C4B和数0x40D2对编写的子程序进行加法和减法测试。
;	（测试数字可以自选，注意数据大小对结果的影响。）
org   0x0000
main
loop
	call	ADD_16
	nop
	call	SUB_16
	nop
	goto	loop

;1.	编写子程序 Add_16，实现双字节无符号数加法。
;	要求在地址0x70~0x73定义变量ACCALO、ACCAHI、ACCBLO、ACCBHI。
;  ACCALO ;存放加数或减数低8位 
;  ACCAHI ;存放加数或减数高8位 
;  ACCBLO ;存放被加数或被减数低8位 存放结果
; ACCBHI 存放被加数或被减数高8位	存放结果
ADD_16	
	movlw	high(ACCB)
	movwf	ACCBHI	; ACCBHI 存放被加数或被减数高8位
	movlw	low(ACCB)	
	movwf	ACCBLO	;  ACCBLO ;存放被加数或被减数低8位 
	
	movlw	high(ACCA)
	movwf	ACCAHI	;  ACCAHI ;存放加数或减数高8位 
	movlw	low(ACCA)	
	movwf	ACCALO	;  ACCALO ;存放加数或减数低8位 
		
	addwf	ACCBLO,f	;低8位相加，结果存入ACCBLO
	btfsc	STATUS,C	
	incf	ACCAHI,f	;C=1;有进位，高8位加1
	movf	ACCAHI,w
	addwf	ACCBHI,f	;高8位相加，存入ACCBHI
	return
	
;2.	编写子程序Sub_16，实现双字节无符号数减法。
;	要求在地址0x20~0x23定义变量SUBALO、SUBAHI、SUBBLO、SUBBHI。
;  SUBALO ;存放加数或减数低8位 
;  SUBAHI ;存放加数或减数高8位 
;  SUBBLO ;存放被加数或被减数低8位	 存放结果
;  SUBBHI ;存放被加数或被减数高8位  存放结果
SUB_16
	movlw	high(ACCB)
	movwf	SUBBHI	; SUBBHI 存放被加数或被减数高8位
	movlw	low(ACCB)	
	movwf	SUBBLO	;  SUBBLO ;存放被加数或被减数低8位 
	
	movlw	high(ACCA)
	movwf	SUBAHI	;  SUBAHI ;存放加数或减数高8位 
	movlw	low(ACCA)	
	movwf	SUBALO	;  SUBALO ;存放加数或减数低8位 
	
	subwf	SUBBLO,f	;低8位相减
	btfss	STATUS,C
	decf	SUBBHI,f	;C=0,有借位，高8位减1
	movf	SUBAHI,w
	subwf	SUBBHI,f	;高8位相减
	return
	
	
END
