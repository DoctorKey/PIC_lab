;*************************************************************************
; 标 题: 微机实验--实现双字节无符号数除法（不恢复余数法）
; 文 件 名: ASM.asm
; 建立日期: 2016.10.14
; 修改日期: 2016.10.14
; 版 本: V1.0
; 作 者: 孙训
;*************************************************************************
; 跳线接法：
; 功能描述: 实现双字节无符号数除法（不恢复余数法）
;*************************************************************************
;【版权】Copyright(C) 20016-2026 All Rights Reserved
;【声明】此程序仅用于学习与参考，引用请注明版权和作者信息！
;相关编译配置*************************************************************
list p=16f877A ; 标明所用的处理器类型
#include <p16f877A.inc> ; 调用头文件
;相关变量常量申明*********************************************************
ACCALO EQU 0x70 ;存放被除数低 8 位
ACCAHI EQU 0x71 ;存放被除数高 8 位
ACCBLO EQU 0x72 ;存放除数 8 位
ACCCLO EQU 0x73 ;存放余数 8 位
ACCCHI EQU 0x74 ;存放商 8 位
COUNT EQU 0x75 ;计数器，左移次数
FLAG EQU 0x76 ;结果溢出标志，没有溢出 0x00，溢出 0xFF
;*************************************************************************
;自定义宏-----------------------------------------------------------------
;实现 16 位立即数除以 8 位立即数**********************************************
Div_16 macro AA, BB ;AA 是被除数，BB 是除数，即 AA÷BB
movlw low(AA) ;赋值到被除数寄存器
movwf ACCALO
movlw high(AA)
movwf ACCAHI
movlw BB ;赋值到除数寄存器
movwf ACCBLO
call div16 ;实现被减数寄存器和减数寄存器中的值相减
endm
;*************************************************************************
org 0x0000 ;复位入口地址
nop ;兼容 ICD 调试工具，必须加 nop
goto main ;跳转至 Main 函数
;Main 的代码---------------------------------------------------------------
main
;Div_16 .10000, .200 ;1234 ÷ 40 = 30 余 34，结果未溢出
Div_16 .1234, .4 ;1234 ÷ 4 = 308 余 2，结果溢出，直接溢出报错
goto main
;子函数代码---------------------------------------------------------------
;16 位无符号数除法*********************************************************
div16
clrf FLAG ;判断结果是否溢出标志位清零
movlw .8
movwf COUNT ;COUNT 初始值为 8
movf ACCBLO, w
subwf ACCAHI, f
btfss STATUS, C
goto $+3
comf FLAG, f ;溢出标志位置为 0xFF
return

rlf ACCCHI, f ;没溢出，把商存到商的寄存器里头
div16loop
rlf ACCALO, f ;被除数左移
rlf ACCAHI, f
btfsc ACCCHI, 0
goto $+3
addwf ACCAHI, f ;商 0，接下来加除数
goto $+2
subwf ACCAHI, f ;商 1，接下来减除数
rlf ACCCHI, f ;把商存到存商的寄存器里头
decfsz COUNT
goto div16loop
btfsc ACCCHI, 0
goto $+3
addwf ACCAHI, w ;商 0，变成加除数恢复余数
goto $+2
subwf ACCAHI, w ;商 1，变成减除数恢复余数
movwf ACCCLO ;把余数放到存余数的寄存器里
return
;-------------------------------------------------------------------------
END ;程序结束


