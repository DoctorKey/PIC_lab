

	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF

 MA              EQU    0x20  ;存放乘数
 MB              EQU    0x21  ;存放被乘数和乘积 第 8～15 位
 MC              EQU    0x22  ;存放乘积第 0～7 位
 MD              EQU    0x23  ;临时寄存器
 TEMP         EQU    0x24  ;临时寄存器

ACCALO	equ	0x25	;存放乘数低 8 位
 ACCAHI	equ	0x26	;存放乘数高 8 位
 ACCBLO	equ	0x27	;存放被乘数低 8 位和乘积第 16～23 位
 ACCBHI	equ	0x28	 ;存放被乘数高 8 位和乘积第 24～31 位
 ACCCLO	equ	0x29	;存放乘积第 0～7 位
 ACCCHI	equ	0x2a	;存放乘积第 8～15 位
BTH	equ	0x2b	;临时寄存器
BTL	equ	0x2c	;临时寄存器
	
#define	A_16	0x4015
#define	B_16	0x3321
;***************************8 ×8 位无符号乘法 宏指令***********************	
mpy	macro
	MOVLW	0xFE               ; 被乘数0xFE 送 MB
	MOVWF	MA	
	MOVLW	0xAB               ; 乘数 0xAB送 MA
	MOVWF	MB	
	CALL	SETUP                    ;调用子程序，将MB 的值送 MD
 
	BCF          STATUS, C          ; 清进位位
	RRF         MD                        ; MD 右移
	BTFSC    STATUS, C           ;判断是否需要相加
	CALL       Add_8                   ; 加乘数至 MB
	RRF         MB                         ; 右移部分乘积
	RRF         MC	
	DECFSZ  TEMP                   ; 乘法完成否？
	GOTO      $ - 7                ; 否，继续求乘积
	endm
;**********************************************************************
	ORG         0x0000           ; 复位入口地址
	nop	                                 ; 兼容ICD调试工具，必须加nop
  	goto        Main                 ; 跳转至Main函数
;**************************************Main 函数的代码**************
Main                                               
	MOVLW  0xFE               ; 被乘数0xFE 送 MB
	MOVWF  MA	
	MOVLW  0xAB               ; 乘数 0xAB送 MA
	MOVWF  MB	
	CALL         Mpy_8            ; 调用双字节乘法子程序，求积，结果应为0xA9AA
	nop
	mpy		;宏指令，单字节无符号数乘法	
	nop
	call	Mpy_16
	nop
            nop
            goto           $                        ; 死循环
;*********************************8 ×8 位无符号乘法子程序 ********************
	 ORG  0X0100
Mpy_8                 
            CALL    SETUP                    ;调用子程序，将MB 的值送 MD
MLOOP  
	BCF          STATUS, C          ; 清进位位
	RRF         MD                        ; MD 右移
	BTFSC    STATUS, C           ;判断是否需要相加
	CALL       Add_8                   ; 加乘数至 MB
	RRF         MB                         ; 右移部分乘积
	RRF         MC	
	DECFSZ  TEMP                   ; 乘法完成否？
	GOTO      MLOOP                ; 否，继续求乘积
	RETURN                               ; 子程序返回
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
SETUP  
	MOVLW    .8                        ;初始化 TEMP 寄存器 
	MOVWF    TEMP
	MOVF         MB, W              ; 乘数送MD
	MOVWF    MD             
	CLRF          MB                     ; 清 MB
	 CLRF          MC                     ;清 MC
	RETURN                              ;子程序返回
Add_8         
	MOVF        MA, w                ;MA和MB相加 
	ADDWF    MB ,F	
	RETURN                               ;子程序返回  

;*****************************16*16位无符号乘法************************
;	ACCAHI ACCALO * ACCBHI ACCBLO = ACCBHI ACCBLO ACCCHI ACCCLO
Mpy_16
	movlw	.16
	movwf	TEMP	;移位16次
	
	movlw	high(A_16)
	movwf	ACCAHI
	movlw	low(A_16)
	movwf	ACCALO
	movlw	high(B_16)
	movwf	ACCBHI
	movwf	BTH	;临时寄存器保存B高8位
	movlw	low(B_16)
	movwf	ACCBLO
	movwf	BTL	;临时寄存器保存B低8位
	
	clrf	ACCBHI
	clrf	ACCBLO
	clrf	ACCCHI
	clrf	ACCCLO	;清零
M16LOOP
	bcf	STATUS, C	 ; 清进位
	rrf	BTH	; B高8位右移
	rrf	BTL	;B低8位右移
	btfsc	STATUS, C   ;判断是否需要相加
	call	ADD_16      ; 加乘数至 ACCB
	rrf	ACCBHI	; 右移部分乘积
	rrf	ACCBLO
	rrf	ACCCHI
	rrf	ACCCLO
	decfsz	TEMP	; 乘法完成否？
	goto	M16LOOP	; 否，继续求乘积
	return		; 子程序返回
	
ADD_16	;ACCAHI ACCALO + ACCBHI ACCBLO = ACCBHI ACCBLO
	movf	ACCALO,w	
	addwf	ACCBLO,f	;低8位相加，结果存入ACCBLO
	btfsc	STATUS,C	
	incf	ACCAHI,f	;C=1;有进位，高8位加1
	movf	ACCAHI,w
	addwf	ACCBHI,f	;高8位相加，存入ACCBHI
	return

END                                                     ; 程序结束

