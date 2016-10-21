

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

ACCALO	equ	0x25	;存放被除数
 ACCAHI	equ	0x26	;存放被除数
 ACCBLO	equ	0x27	;存放除数
NACCBLO	equ	0x28	;存放除数的补码
 ACCCLO	equ	0x29	;存放余数
 ACCCHI	equ	0x2a	;存放商
NO_B	equ	0x2b	;除数的符号位
BTL	equ	0x2c	;临时寄存器
LOG	equ	0x2d	;报警寄存器，低两位为被除数符号位
COUNT	equ	0x2e	;计数寄存器
	
#define	ACCA	0x3453	;0x3453/0xb5=0x4a......0x01
#define	ACCB	0xb5	;

;**********************************************************************
	ORG         0x0000           ; 复位入口地址
	nop	                                 ; 兼容ICD调试工具，必须加nop
  	goto        Main                 ; 跳转至Main函数
;**************************************Main 函数的代码**************
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
;**********************BCD转二进制***************************************
BCD2Bin
	    movwf	TEMP	;将w寄存器保存
	    andlw	0xf0	;提取高四位
	    movwf	TEN
	    swapf	TEN,w	;将w寄存器十位移到低四位
	    bcf	STATUS,C
	    rrf	TEN,f	;右移一位，即TEN*8	    
	    addwf	TEN,f
	    addwf	TEN,f	;加两次，即TEN*10
	    movf	TEMP,w
	    andlw	0x0f
	    addwf	TEN,w	;十位个位相加
	    return
;******************************双字节无符号数除法******************************
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
	    incf	NACCBLO,f	;B的补码
	    clrf	ACCCHI
	    clrf	ACCCLO
	    clrf	LOG
	    
	    movf	ACCBLO,w
	    subwf	ACCAHI,f
	    btfss	STATUS,C
	    goto	$ + 3	
	    bsf	LOG,7	;溢出
	    return
SHANG0	    movf	ACCBLO,w
LOOP	    rlf	ACCCHI	;商左移一位
	    rlf	ACCALO,f
	    rlf	ACCAHI,f	;被除数左移一位    
	    addwf	ACCAHI,f	;ACCAHI=ACCAHI+w
	    decfsz	COUNT
	    goto	$ + 2
	    goto	LAST
	    btfss	STATUS,C
	    goto	SHANG0	;C=0,没有溢出
	    movf	NACCBLO,w
	    goto	LOOP
LAST	
	    btfsc	STATUS,C
	    goto	$ + 3	;C=1,不用加
	    movf	ACCBLO,w	;C=0,修正余数
	    addwf	ACCAHI,f
	    movf	ACCAHI,w
	    movwf	ACCCLO
	    return
;******************************双字节无符号数除法******************************
;	ACCAHI ACCALO / ACCBLO = ACCCHI ........ ACCCLO
;	扩展两个符号位，不用C
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
	    incf	NACCBLO,f	;B的补码
	    clrf	ACCCHI
	    clrf	ACCCLO
	    clrf	LOG
	    
	    call	sub
	    btfsc	LOG,0
	    btfss	LOG,1	;LOG(0)=1
	    goto	$ + 2	;LOG(0)=0||LOG(1)=0
	    goto	shang_e2	;LOG(1)=1	
	    bsf	LOG,7	;溢出
	    return 
	    
shang_e2	    rlf	ACCALO,f
	    rlf	ACCAHI,f	;被除数左移一位
	    rlf	LOG,f	;符号位左移一位
	    
	    btfss	ACCCHI,0
	    call	add	;上次商0，这次执行加法
	    btfsc	ACCCHI,0
	    call	sub	;上次商1，这次执行减法
	    
	    rlf	ACCCHI	;商左移一位
	    
	    decfsz	COUNT
	    goto	$ + 2
	    goto	LAST_e2	
	    
	    btfsc	LOG,0
	    btfss	LOG,1	;LOG(0)=1
	    goto	$ + 3	;LOG(0)=0||LOG(1)=0，为正数，商1
	    bcf	ACCCHI,0	;LOG(1)=1,为负数,商0
	    goto	shang_e2
	    bsf	ACCCHI,0
	    goto	shang_e2
LAST_e2	
	    btfsc	LOG,0
	    btfss	LOG,1	;LOG(0)=1
	    goto	$ + 3	;LOG(0)=0||LOG(1)=0，不用修正		
	    call	add	;LOG(1)=1,商为负，要修正
	    goto	$ + 2
	    bsf	ACCCHI,0	;商1
	    movf	ACCAHI,w
	    movwf	ACCCLO
	    return
;A+B,A为LOG(1:0)ACCAHI,B为ACCBLO，符号位为00，正数
add
	    movf	ACCBLO,w
	    addwf	ACCAHI,f
	    btfsc	STATUS,C
	    incf	LOG,f
	    movlw	0x00
	    addwf	LOG,f
	    return
;A-B，A为LOG(1:0)ACCAHI,B为NACCBLO，且符号位为11
sub
	    movf	NACCBLO,w
	    addwf	ACCAHI,f
	    btfsc	STATUS,C
	    incf	LOG,f
	    movlw	0x03
	    addwf	LOG,f
	    return
END                                                     ; 程序结束

