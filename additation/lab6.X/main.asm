

list		p=16f877A	; list directive to define processor
#include	<p16f877A.inc>	; processor specific variable definitions	
__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF

sort_0	equ	0x20
sort_1	equ	0x21
sort_2	equ	0x22
sort_3	equ	0x23
sort_4	equ	0x24
sort_5	equ	0x25
sort_6	equ	0x26
sort_7	equ	0x27
sort_8	equ	0x28
sort_9	equ	0x29
log	equ	0x2a
count_i	equ	0x2b
count_j	equ	0x2c
sort_i	equ	0x2d
sort_j	equ	0x2e
	
#define	num1	.15
#define	num2	.12
#define	num3	.17
#define	num4	.14
#define	num5	.19
#define	num6	.11
#define	num7	.1
#define	num8	.23
#define	num9	.21
#define	num10	.20
;***********宏定义*********************
;比较两个数，小的在前，大的在后
compare	macro	
	movf	INDF,w
	movwf	sort_i	;低位保存到i
	incf	FSR,f
	subwf	INDF,w
	decf	FSR,f
	btfsc	STATUS,C
	goto	$ + 9	;sort_b>sort_a
	incf	FSR,f
	movf	INDF,w	;sort_b<sort_a
	movwf	sort_j
	movf	sort_i,w
	movwf	INDF
	decf	FSR,f
	movf	sort_j,w
	movwf	INDF
	endm
;**********************************************************************
	ORG         0x0000           ; 复位入口地址
	nop	                                 ; 兼容ICD调试工具，必须加nop
  	goto        Main                 ; 跳转至Main函数
;**************************************Main 函数的代码**************
Main                                               
	call	setup
	call	paixu
	nop
	goto           $                        ; 死循环
setup
	movlw	num1
	movwf	sort_0
	movlw	num2
	movwf	sort_1
	movlw	num3
	movwf	sort_2
	movlw	num4
	movwf	sort_3
	movlw	num5
	movwf	sort_4
	movlw	num6
	movwf	sort_5
	movlw	num7
	movwf	sort_6
	movlw	num8
	movwf	sort_7
	movlw	num9
	movwf	sort_8
	movlw	num10
	movwf	sort_9
	return
	
;*********************冒泡排序*****************************
paixu
	movlw	.9
	movwf	count_i
out_loop	movf	count_i,w
	movwf	count_j
	movlw	sort_0
	movwf	FSR
in_loop	compare	
	incf	FSR,f	;右移一个
	decfsz	count_j	;内循环减一
	goto	in_loop
	decfsz	count_i	;外循环减一
	goto	out_loop
	return

END                                                     ; 程序结束




