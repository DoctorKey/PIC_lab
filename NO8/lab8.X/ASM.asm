;*******************************************************************************
; 标    题: PIC_ST_V3.0学习板演示程序--片内flash读写
; 文 件 名: Flash_RW
; 建立日期: 2013.7.9
; 修改日期: 2013.7.9
; 版    本: V1.0
; 作    者: zyixin
;********************************************************************************
; 跳线接法：给内部Flash写数据，再读取数据，并显示
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

M_addr                     EQU  0x76             ;
M_data                      EQU  0x77             ;
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

org 0x0800
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
	   banksel	PORTD
	   movlw	0xff
	   movwf	PORTD
	   
           movlw 0x00                                 ;
           movwf M_addr                            ;

;           movlw  0x12                                ;
;           movwf M_data                             ;
;           call        EEPROM_Write            ;       
           clrf        M_data                             ;
           call        EEPROM_Read             ;
	   
	   
	   movlw	0x12
	   subwf	M_data,w
	   btfss	STATUS,Z
	   goto	$ + 4
	   banksel	PORTD
	   movlw	0x0f
	   movwf	PORTD
	   

           
           
           
     
Loop    
           goto       Loop;
;------------------------------------------------------------------Main函数结束------------------------------------------------------------------------------




;------------------------------------------------------------------子函数------------------------------------------------------------------------------
;********EEPROM_Write******************
EEPROM_Write                     ; 写内部EEPROM
;          banksel  EEADR             ;
;          movf       M_addr, w      ;写地址
;          movwf   EEADR             ;
;          movf       M_data, w       ;写数据
;          movwf   EEDATA          ;
;	BSF STATUS, RP0 ; Bank1
;	BCF INTCON, GIE ; Disable INTs
;          banksel  EECON1          ;
;          bcf           EECON1, EEPGD ;内部EEPROM空间
;          bsf           EECON1, WREN  ;写使能
;          movlw   0x55               ;
;          movwf   EECON2        ;
;          movlw   0xAA              ;
;          movwf   EECON2		 ;
;          bsf           EECON1,WR	;启动写操作
;          btfsc       EECON1,WR	;等待写操作结束
;          goto        $ - 1                   ;
;          bcf           EECON1, WREN;写禁止
;	  BSF STATUS, RP0 ; Bank1
;	  BSF INTCON, GIE ; Enable INTs
	   BSF	STATUS,RP1 ;
	BSF	STATUS,RP0
	BTFSC	EECON1,WR ;Wait for write
	GOTO	$ - 1 ;to complete
	BCF	STATUS,RP0 ;Bank 2
	MOVF	 M_addr,W ;Data Memory
	MOVWF	EEADR ;Address to write
	MOVF	M_data,W ;Data Memory Value
	MOVWF	EEDATA ;to write
	BSF	STATUS,RP0 ;Bank 3
	BCF	EECON1,EEPGD ;Point to DATA
		;memory
	BSF	 EECON1,WREN ;Enable writes
	BCF	INTCON,GIE ;Disable INTs.
	MOVLW	0x55 ;
	MOVWF	EECON2 ;Write 55h
	MOVLW	0xAA  ;
	MOVWF	EECON2 ;Write AAh
	BSF	EECON1,WR	 ;Set WR bit to
			;begin write
	BSF	 INTCON,GIE	;Enable INTs.
	BCF	EECON1,WREN		;Disable writes
          return                             ;
;********EEPROM_Read******************
EEPROM_Read                       ;读内部EEPROM
          banksel  EEADR             ;写地址
          movf       M_addr, w      ;
          movwf   EEADR             ;          
          banksel  EECON1          ;
          bcf           EECON1, EEPGD ;内部EEPROM空间
          bsf           EECON1, RD  ; 启动读操作         
          btfsc       EECON1, RD  ;等待读完成
          goto        $ - 1                   ; 
          banksel   EEDATA        ;
          movf       EEDATA, w  ;
          movwf   M_data           ;
          return                             ;
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




END                                        ; 程序结束