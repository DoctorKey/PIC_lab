;*******************************************************************************
; 标    题: PIC_ST_V3.0学习板演示程序--RB0中断
; 文 件 名: RB0_INT
; 建立日期: 2013.7.8
; 修改日期: 2013.7.8
; 版    本: V1.0
; 作    者: zyixin
;********************************************************************************
; 跳线接法：利用RB0的中断，下降沿触发中断，并计数，按下一次KEY1，则计数加1
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
D1                              EQU   0x20             ; 变量1，在HC595的初始化中使用
D2                              EQU   0x21             ; 变量2，7段数码选择中使用
count                         EQU   0x23              ; 秒计数器
wdata                        EQU   0x24              ; wdata字型


Temp                         EQU  0x78             ;
L1                                EQU  0x79             ;延时函数循环变量
L2                                EQU  0x7A             ;延时函数循环变量
L3                                EQU  0x7B             ;延时函数循环变量
i                                    EQU  0x7C
w_temp		  EQU	0x7D		;中断现场保护
status_temp	  EQU	0x7E		;中断现场保护
pclath_temp	  EQU	0x7F		;中断现场保护             
;**********************************************************************
	ORG         0x0000          ; 复位入口地址
	nop	                                ; 与ICD调试配合的nop
            movlw   high(main)    ;
            movwf   PCLATH         ;
  	goto        main                ; 跳转到Main
;**********************************************************************
	ORG         0x0004                ; 中断向量入口地址
	movwf   w_temp                ; 入栈保护
	movf	      STATUS,w           ;         
	movwf   status_temp        ;
	movf	      PCLATH,w	  ;
	movwf   pclath_temp	  ;
;**********************************************************************
            clrf       PCLATH                  ; 设定PCLATH指向page0，即中断程序所在页面
            btfss    INTCON, INTE      ; 是否开外设中断
            goto     EndOfInt                ; 否，则跳转至中断处理程序尾部
            btfss    INTCON, INTF      ; 是否置位外设中断的标志
            goto     EndOfInt                ; 否，则跳转至中断处理程序尾部           
            bcf        INTCON, INTF      ; 清除外设中断标志位  
            banksel count                     ;
            incf       count, f                   ;  如有进位，则计数器高位加1
            movlw .60                           ;  测试计数器低位是否为60
            subwf   count, w                ;  
            btfss     STATUS, Z             ;
            goto      EndOfInt               ;  否，则跳转至中断处理程序尾部            
            clrf        count                      ; 若计数器为60，则清零秒计数器          
EndOfInt  
	movf	     pclath_temp,w	  ; 出栈
	movwf  PCLATH		  
	movf      status_temp,w    
	movwf  STATUS                
	swapf    w_temp,f
	swapf    w_temp,w           
;********************************************************************** 
	retfie                                              ;  中断返回      

;-------------------------------------------------------------------------查表函数---------------------------------------------------------------
org 0x0800
;**************七段数码管查表函数**********
disp   
            addwf   PCL, f                              ;
            dt            0xC0                               ;
            dt            0xF9                               ;
            dt            0xA4                               ;
            dt            0xB0                               ;
            dt            0x99                               ;
            dt            0x92                               ;
            dt            0x82                               ;
            dt            0xF8                               ;
            dt            0x80                               ;
            dt            0x90                               ;

;**************七段数码管位数选择查表函数*******
channel   
            addwf   PCL, f                              ;
            dt            0x0C                               ;
            dt            0x10                               ;
            dt            0x14                               ;
            dt            0x18                               ;    
;**************七段数码管位数顺序选择查表函数*******
Next_channel   
            addwf   PCL, f                              ;
            dt            0x01                               ;
            dt            0x02                               ;
            dt            0x03                               ;
            dt            0x00                               ;      
;**************二进制数到BCD码查表函数*******
Bin2BCD   
            addwf   PCL, f                              ;
            dt            0x00                               ;
            dt            0x01                               ;
            dt            0x02                               ;
            dt            0x03                               ;
            dt            0x04                               ;
            dt            0x05                               ;
            dt            0x06                               ;
            dt            0x07                               ;
            dt            0x08                               ;
            dt            0x09                               ;
            dt            0x10                               ;
            dt            0x11                               ;
            dt            0x12                               ;
            dt            0x13                               ;
            dt            0x14                               ;
            dt            0x15                               ;
            dt            0x16                               ;
            dt            0x17                               ;
            dt            0x18                               ;
            dt            0x19                               ;
            dt            0x20                               ;
            dt            0x21                               ;
            dt            0x22                               ;
            dt            0x23                               ;
            dt            0x24                               ;
            dt            0x25                               ;
            dt            0x26                               ;
            dt            0x27                               ;
            dt            0x28                               ;
            dt            0x29                               ;
            dt            0x30                               ;
            dt            0x31                               ;
            dt            0x32                               ;
            dt            0x33                               ;
            dt            0x34                               ;
            dt            0x35                               ;
            dt            0x36                               ;
            dt            0x37                               ;
            dt            0x38                               ;
            dt            0x39                               ;
            dt            0x40                               ;
            dt            0x41                               ;
            dt            0x42                               ;
            dt            0x43                               ;
            dt            0x44                               ;
            dt            0x45                               ;
            dt            0x46                               ;
            dt            0x47                               ;
            dt            0x48                               ;
            dt            0x49                               ;
            dt            0x50                               ;
            dt            0x51                               ;
            dt            0x52                               ;
            dt            0x53                               ;
            dt            0x54                               ;
            dt            0x55                               ;
            dt            0x56                               ;
            dt            0x57                               ;
            dt            0x58                               ;
            dt            0x59                               ;
;-------------------------------------------------------------------------------------------
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
           banksel OPTION_REG                ;  选择bank1      
           bsf          OPTION_REG, NOT_RBPU; 关闭上拉电阻使能
           bcf          OPTION_REG, INTEDG; RB0下降沿输入
           bcf          TRISB, RB5                  ;RB5设置成输出
           bsf          TRISB, RB0                  ;RB0设置成输入
           banksel PORTB                           ;RB5输出0
           bcf          PORTB, RB5                ;   
           bcf          INTCON, INTF             ; 清外设中断标志
           bsf          INTCON, INTE             ; 开外设中断
           bsf          INTCON, GIE                ; 开总中断

     
Loop              
           movf      count, w                       ;将计数器移入w寄存器     
           call         Bin2BCD                      ; 调用子函数查询对应的BCD码  
           movwf  Temp                             ;  将BCD码移入Temp
           movlw  0x0f                               ;  取Temp的低4位
           andwf    Temp, w                      ; 
           banksel   wdata; 
           movwf  wdata                           ;
           movlw  0x03                                ;  选择第3位七段码
           call         LED_Display                 ;  显示
           movlw  0xf0                                 ;  取Temp的高4位
           andwf    Temp, f          ;
           swapf     Temp,w        ;
           banksel   wdata; 
           movwf  wdata                ;
           movlw  0x02                                 ;选择第2位七段码
           call         LED_Display                  ;显示               
           goto       Loop;
;------------------------------------------------------------------Main函数结束------------------------------------------------------------------------------




;------------------------------------------------------------------子函数------------------------------------------------------------------------------
;********HC595_Init******************
HC595_Init                                     ; 初始化 74HC595
          banksel TRISA             ;
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
          banksel  ADCON1      ;
          movlw  0x8E;
          movwf  ADCON1      ;          
          bcf           TRISA, 2      ;
          bcf           TRISA, 3      ;
          bcf           TRISA, 4      ;
          banksel  PORTA        ;
          bsf           PORTA, 2   ;
          bsf           PORTA, 3   ;
          bsf           PORTA, 4   ;
          return                         ;
;**************DelayUS**************
DelayUS                                 ; 延时x毫微秒，x由变量W设定
          movwf   L1                 ;
LL1US        
          nop                               ;
          nop                               ;
          decfsz    L1, f             ;          
          goto        LL1US         ;
          return                         ;

;********Select_7LEDs ***********
Select_7LEDs                        ; 选择七段码显示器的某一位，入口参数为W寄存器的值。
          banksel  D2                 ;
          movwf   D2                ;
          movlw   0x03            ;
          andwf     D2, w          ;
          call          channel       ;
          movwf   D2                 ;
          movlw   0xE3             ;
          andwf    PORTA, w   ;
          iorwf      D2, w           ;
          movwf   PORTA        ;
          return                         ;
;********LED_Display***********
LED_Display                        ; 根据入口参数在某一位7段码LED显示一个数字。位数在W寄存器中，数字在wdata中
          call        Select_7LEDs   ; 
          banksel PORTD        ;
;--------------------------确保wdata的内容不超过9---------
          movlw .9                    ;
          subwf  wdata, w       ;  
          btfsc     STATUS, C   ;
          goto DS9
          goto  DSW
DS9
          movlw  .9                  ;如果超过9则置w寄存器为9
          goto   DSD      ;
DSW
          movf wdata,w         ; 如果不超过9，则将wdata赋值给w
DSD
          call        disp               ; 查表，获得7断码对应数码表
          movwf PORTD         ; 更新数码到端口D        
          movlw .100              ;
          call        DelayUS       ;
          movlw 0xff               ;
          movwf PORTD        ;
          return                        ;


END                                        ; 程序结束