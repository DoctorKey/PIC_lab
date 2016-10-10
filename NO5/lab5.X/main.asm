

	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF
;1.	编写子程序Bin2BCD，实现二进制数到压缩BCD码的转换。
;	待转换的二进制数存放在w寄存器内，子程序调用完成后得到的BCD码仍存放在w寄存器内返回。例如
;movlw .45; w=45
;call   Bin2BCD;
;nop      ;w=0x45
;编写Main主程序，对编写的子程序进行测试。
;2.	编写子程序Div_16，实现双字节无符号数除法。自行定义变量，其中：
;ACCALO ;存放被除数低 8 位
;ACCAHI ;存放被除数高 8 位
;ACCBLO ;存放除数 8 位
;ACCCLO ;存放余数 8 位
;ACCCHI ;存放商 8 位

 TEN              EQU    0x23  ;临时寄存器
 TEMP         EQU    0x24  ;临时寄存器

ACCALO	equ	0x25	;存放乘数低 8 位
 ACCAHI	equ	0x26	;存放乘数高 8 位
 ACCBLO	equ	0x27	;存放被乘数低 8 位和乘积第 16～23 位
 ACCCLO	equ	0x29	;存放乘积第 0～7 位
 ACCCHI	equ	0x2a	;存放乘积第 8～15 位
NEXTC	equ	0x2b	;临时寄存器
BTL	equ	0x2c	;临时寄存器
	
#define	A_16	0x4015
#define	B_16	0x3321

;**********************************************************************
	ORG         0x0000           ; 复位入口地址
	nop	                                 ; 兼容ICD调试工具，必须加nop
  	goto        Main                 ; 跳转至Main函数
;**************************************Main 函数的代码**************
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
	goto           $                        ; 死循环
	
;**********************二进制转BCD***************************************	    
Bin2BCD
	    movwf	TEMP	;将w寄存器保存
	    clrf	TEN	;TEN每次清零，保证正确
	    movlw	.10	
	    subwf	TEMP,f	;循环，TEMP每次减10
	    btfss	STATUS,C
	    goto	$ + 3	;f<w
	    incf	TEN,f	;f>w，ten+1,继续减
	    goto	$ - 4
	    addwf	TEMP,w	;最后一次循环多减了10，此处加回来，得到个位
	    swapf	TEN,f	;将十位置于高四位
	    iorwf	TEN,w	;w高四位十位，低四位个位
	    return
;******************************双字节无符号数除法******************************
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
	    incf	ACCCHI,f	;f>w,商加一
	    goto	$ + 2	;跳过下一句，商左移
	    addwf	ACCAHI,f	;f<w,再加回去
	    rlf	ACCCHI,f	;
	    rlf	ACCALO
	    rlf	ACCAHI
	    btfsc	STATUS,C
	    incf	NEXTC,f
	    DECFSZ  TEMP                   ; 乘法完成否？
	    GOTO      MLOOP                ; 否，继续求乘积
	RETURN                               ; 子程序返回
	    
END                                                     ; 程序结束

