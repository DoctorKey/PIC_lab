;*******************************************************************************
; 标    题: PIC_ST_V3.0学习板演示程序--IO输入模式
; 文 件 名: IO_IN
; 建立日期: 2013.7.2
; 修改日期: 2013.7.2
; 版    本: V1.0
; 作    者: zyixin
;********************************************************************************
; 跳线接法：用短接帽短接P14
; 功能描述: 按键1(key1)连接RB0和RB5，通过读取RB0的值来确定有没有按键按下
; 主要学习单片机IO口的输入功能
;对PORTD的操作，详细见PIC16F877A数据手册4.4章节内容
	
;编写程序，主程序Main点亮LED，持续1S后，关闭LED，进入休眠状态。
;使用RB0的外部中断唤醒CPU，重复上述的点亮、持续、关闭、休眠过程。
;*******************************************************************************
;【版权】Copyright(C) 2009-2019 All Rights Reserved
;【声明】此程序仅用于学习与参考，引用请注明版权和作者信息！
;******************************************************************************/

 list		p=16f877A	; 标明所用的处理器类型
 #include	<p16f877A.inc>	; 调用头文件	
 __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF;熔丝位配置字
; _CP_OFF: 代码保护关闭
;_WDT_OFF: 看门狗关闭
; _BODEN_OFF: 低压复位关闭
; _PWRTE_OFF: 上电延时计数关闭
; _HS_OSC : 外部高速振荡器使能
; _WRT_OFF : 写程序存储器保护关闭 
;_LVP_OFF : 低电压编程关闭
;_CPD_OFF : EEPROM存储器代码保护

;***** 变量声明*******************************************************
D1                                 EQU  0x20             ; 变量1，在HC595的初始化中使用
SHADE_PORTD	EQU	0x21	;PORTD影子寄存器

L1                                EQU  0x77             ;延时函数循环变量
L2                                EQU  0x78             ;延时函数循环变量
L3                                EQU  0x79             ;延时函数循环变量
i                                    EQU  0x7A             ;循环变量i
j                                    EQU  0x7B             ;循环变量j
k                                   EQU  0x7C             ;循环变量k
w_temp		  EQU	0x7D		;中断现场保护
status_temp	  EQU	0x7E		;中断现场保护
pclath_temp	  EQU	0x7F		;中断现场保护             
;**********************************************************************
	ORG         0x0000          ; 复位入口地址
	nop	                                ; 与ICD调试配合的nop
  	goto        main                ; 跳转到Main
;**********************************************************************
	ORG         0x0004                ; 中断向量入口地址
	movwf   w_temp                ; 入栈保护
	movf	      STATUS,w          
	movwf   status_temp        
	movf	      PCLATH,w	 
	movwf   pclath_temp	 
;**********************************************************************
	 btfss    INTCON, INTE      ; 是否开外设中断
            goto     EndOfInt                ; 否，则跳转至中断处理程序尾部
            btfss    INTCON, INTF      ; 是否置位外设中断的标志
            goto     EndOfInt                ; 否，则跳转至中断处理程序尾部           
            bcf        INTCON, INTF      ; 清除外设中断标志位  

	bcf	PORTD,7
	
          
;**********************************************************************
EndOfInt  
	movf	     pclath_temp,w	  ; 出栈
	movwf  PCLATH		  
	movf      status_temp,w    
	movwf  STATUS                
	swapf    w_temp,f
	swapf    w_temp,w           
;********************************************************************** 
	retfie                                              ;  中断返回      

;-------------------------------------------------Main的代码-----------------------------------------------------------------
main       
;*************************************开发板显示界面的通用初始化*******************************                                            
           banksel TRISD                              ; 选择bank1
           clrf         TRISD                              ; 设置RD0-RD7为输出模式
           bcf          TRISE, PSPMODE        ; 设置D端口为I/O端口模式              
           call         HC595_Init                    ; 74HC595初始化
           movlw 0x00;                                ; 写0x00数据，关掉LED点阵显示
           call        HC595_Write_Byte     ; 
           call        TurnOff_7LEDs            ; 调用子程序，关闭七段码LED 
;*****************************************************************************************************
          banksel  TRISB                             ; 选择bank1
	bsf          OPTION_REG, NOT_RBPU; 关闭上拉电阻使能
	bcf          OPTION_REG, INTEDG; RB0下降沿输入
	bsf           TRISB, RB0                  ; RB0为输入模式
	bcf           TRISB, RB5                  ; RB5为输出模式	
	banksel  PORTB                           ; 选择bank0
	bcf           PORTB, RB5                ; KEY1输出低电平，若按键1被按下，则KEY6接收到低电平，否则为高电平
	nop                                                  ; 空操作，使KEY1输出电平稳定
	  
	  movlw	0xff
	  movwf	PORTD	;将ＬＥＤ关闭
	  movlw	0xfe
	  movwf	SHADE_PORTD
	  bsf	STATUS,C
	  
	  bcf          INTCON, INTF             ; 清外设中断标志
	bsf          INTCON, INTE             ; 开外设中断
	bsf          INTCON, GIE                ; 开总中断
	
loop	
	bcf	PORTD,0		;点亮LED1
	movlw	.200
	call	DelayMS  
	movlw	.200
	call	DelayMS  
	movlw	.200
	call	DelayMS  
	movlw	.200
	call	DelayMS  
	movlw	.200
	call	DelayMS  
	bsf	PORTD,0		;灭LED1
	bsf	PORTD,7		;将中断标志LED灭掉
	sleep
	goto	loop   


;------------------------------------------------------------------子函数------------------------------------------------------------------------------
;********HC595_Init******************
HC595_Init                                     ; 初始化 74HC595
          banksel  ADCON1               ;
          movlw  0x8E;
          movwf  ADCON1                ;
          bcf         TRISA, 5          ; SCK_595
          bcf         TRISE, 0          ; RCK_595
          bcf         TRISC, 0          ; SER_595
          return                             ;
;********HC595_Write_Byte***********
HC595_Write_Byte                    ; 设置 74HC595选中的行，具体的行数由W寄存器的值决定
          banksel  D1                        ;
          movwf  D1                         ;
          movlw  .8                           ;
          movwf  i                             ; 
Loop_595
          btfsc      D1, 7                    ;
          goto       SET1_595          ;
          goto       SET0_595          ;
SET1_595
          bsf          PORTC, 0           ;
          goto       Clock_595         ;
 SET0_595
          bcf          PORTC, 0           ;
          goto       Clock_595         ;
Clock_595
          nop                                      ;
          bcf          PORTA, 5           ;           
          RLF        D1, f                     ;
          bsf          PORTA, 5           ;
          decfsz   i, f                         ;
          goto       Loop_595         ;      
          bcf          PORTE, 0          ;
          nop                                     ;
          bsf          PORTE, 0          ;        
          nop   
          return                               ;
;********TurnOff_7LEDs ***********
TurnOff_7LEDs                    ; 关闭七段码显示器
          banksel  TRISA           ;
          bcf           TRISA, 2      ;
          bcf           TRISA, 3      ;
          bcf           TRISA, 4      ;
          banksel  PORTA        ;
          bsf           PORTA, 2   ;
          bsf           PORTA, 3   ;
          bsf           PORTA, 4   ;
          return                         ;

;**************DelayMS**************
DelayMS                                 ; 延时x毫秒，x由变量W设定
          movwf   L1                 ;
LL1
          movlw   .17                ;
          movwf   L2                 ;
LL2
          movlw   .97            ;
          movwf   L3                 ;
LL3        
          decfsz    L3, f             ;
          goto        LL3              ;
          decfsz    L2, f             ;
          goto        LL2              ;
          decfsz    L1, f             ;
          goto        LL1              ;
          return                         ;


;-------------------------------------------------------------------------------------------
END                                        ; 程序结束
