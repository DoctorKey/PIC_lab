;*******************************************************************************
; ��    ��: PIC_ST_V3.0ѧϰ����ʾ����--RB0�ж�
; �� �� ��: RB0_INT
; ��������: 2013.7.8
; �޸�����: 2013.7.8
; ��    ��: V1.0
; ��    ��: zyixin
;********************************************************************************
; ���߽ӷ�������RB0���жϣ��½��ش����жϣ�������������һ��KEY1���������1
;*******************************************************************************
;����Ȩ��Copyright(C) 2009-2019 All Rights Reserved
;���������˳��������ѧϰ��ο���������ע����Ȩ��������Ϣ��
;******************************************************************************/

 list		p=16f877A	; �������õĴ���������
 #include	<p16f877A.inc>	; ����ͷ�ļ�	
 __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF;��˿λ������
; _CP_OFF: ���뱣���ر�
;_WDT_OFF: ���Ź��ر�
; _BODEN_OFF: ��ѹ��λ�ر�
; _PWRTE_OFF: �ϵ���ʱ�����ر�
; _HS_OSC : �ⲿ��������ʹ��
; _WRT_OFF : д����洢�������ر� 
;_LVP_OFF : �͵�ѹ��̹ر�
;_CPD_OFF : EEPROM�洢�����뱣��

;***** ��������*******************************************************
D1                              EQU   0x20             ; ����1����HC595�ĳ�ʼ����ʹ��
D2                              EQU   0x21             ; ����2��7������ѡ����ʹ��
count                         EQU   0x23              ; �������
wdata                        EQU   0x24              ; wdata����


Temp                         EQU  0x78             ;
L1                                EQU  0x79             ;��ʱ����ѭ������
L2                                EQU  0x7A             ;��ʱ����ѭ������
L3                                EQU  0x7B             ;��ʱ����ѭ������
i                                    EQU  0x7C
w_temp		  EQU	0x7D		;�ж��ֳ�����
status_temp	  EQU	0x7E		;�ж��ֳ�����
pclath_temp	  EQU	0x7F		;�ж��ֳ�����             
;**********************************************************************
	ORG         0x0000          ; ��λ��ڵ�ַ
	nop	                                ; ��ICD������ϵ�nop
            movlw   high(main)    ;
            movwf   PCLATH         ;
  	goto        main                ; ��ת��Main
;**********************************************************************
	ORG         0x0004                ; �ж�������ڵ�ַ
	movwf   w_temp                ; ��ջ����
	movf	      STATUS,w           ;         
	movwf   status_temp        ;
	movf	      PCLATH,w	  ;
	movwf   pclath_temp	  ;
;**********************************************************************
            clrf       PCLATH                  ; �趨PCLATHָ��page0�����жϳ�������ҳ��
            btfss    INTCON, INTE      ; �Ƿ������ж�
            goto     EndOfInt                ; ������ת���жϴ������β��
            btfss    INTCON, INTF      ; �Ƿ���λ�����жϵı�־
            goto     EndOfInt                ; ������ת���жϴ������β��           
            bcf        INTCON, INTF      ; ��������жϱ�־λ  
            banksel count                     ;
            incf       count, f                   ;  ���н�λ�����������λ��1
            movlw .60                           ;  ���Լ�������λ�Ƿ�Ϊ60
            subwf   count, w                ;  
            btfss     STATUS, Z             ;
            goto      EndOfInt               ;  ������ת���жϴ������β��            
            clrf        count                      ; ��������Ϊ60���������������          
EndOfInt  
	movf	     pclath_temp,w	  ; ��ջ
	movwf  PCLATH		  
	movf      status_temp,w    
	movwf  STATUS                
	swapf    w_temp,f
	swapf    w_temp,w           
;********************************************************************** 
	retfie                                              ;  �жϷ���      

;-------------------------------------------------------------------------�����---------------------------------------------------------------
org 0x0800
;**************�߶�����ܲ����**********
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

;**************�߶������λ��ѡ������*******
channel   
            addwf   PCL, f                              ;
            dt            0x0C                               ;
            dt            0x10                               ;
            dt            0x14                               ;
            dt            0x18                               ;    
;**************�߶������λ��˳��ѡ������*******
Next_channel   
            addwf   PCL, f                              ;
            dt            0x01                               ;
            dt            0x02                               ;
            dt            0x03                               ;
            dt            0x00                               ;      
;**************����������BCD������*******
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
;-------------------------------------------------Main�Ĵ���-----------------------------------------------------------------
main       
;*************************************��������ʾ�����ͨ�ó�ʼ��*******************************                                            
           banksel TRISD                              ; ѡ��bank1
           clrf         TRISD                              ; ����RD0-RD7Ϊ���ģʽ
           bcf          TRISE, PSPMODE        ; ����D�˿�ΪI/O�˿�ģʽ      
           call         HC595_Init                    ; 74HC595��ʼ��
           movlw 0x00;                                ; д0x00���ݣ��ص�LED������ʾ
           call        HC595_Write_Byte     ; 
           call        TurnOff_7LEDs            ; �����ӳ��򣬹ر��߶���LED 
;*****************************************************************************************************
           banksel OPTION_REG                ;  ѡ��bank1      
           bsf          OPTION_REG, NOT_RBPU; �ر���������ʹ��
           bcf          OPTION_REG, INTEDG; RB0�½�������
           bcf          TRISB, RB5                  ;RB5���ó����
           bsf          TRISB, RB0                  ;RB0���ó�����
           banksel PORTB                           ;RB5���0
           bcf          PORTB, RB5                ;   
           bcf          INTCON, INTF             ; �������жϱ�־
           bsf          INTCON, INTE             ; �������ж�
           bsf          INTCON, GIE                ; �����ж�

     
Loop              
           movf      count, w                       ;������������w�Ĵ���     
           call         Bin2BCD                      ; �����Ӻ�����ѯ��Ӧ��BCD��  
           movwf  Temp                             ;  ��BCD������Temp
           movlw  0x0f                               ;  ȡTemp�ĵ�4λ
           andwf    Temp, w                      ; 
           banksel   wdata; 
           movwf  wdata                           ;
           movlw  0x03                                ;  ѡ���3λ�߶���
           call         LED_Display                 ;  ��ʾ
           movlw  0xf0                                 ;  ȡTemp�ĸ�4λ
           andwf    Temp, f          ;
           swapf     Temp,w        ;
           banksel   wdata; 
           movwf  wdata                ;
           movlw  0x02                                 ;ѡ���2λ�߶���
           call         LED_Display                  ;��ʾ               
           goto       Loop;
;------------------------------------------------------------------Main��������------------------------------------------------------------------------------




;------------------------------------------------------------------�Ӻ���------------------------------------------------------------------------------
;********HC595_Init******************
HC595_Init                                     ; ��ʼ�� 74HC595
          banksel TRISA             ;
          bcf         TRISA, 5          ; SCK_595
          bcf         TRISE, 0          ; RCK_595
          bcf         TRISC, 0          ; SER_595
          return                             ;
;********HC595_Write_Byte***********
HC595_Write_Byte                    ; ���� 74HC595ѡ�е��У������������W�Ĵ�����ֵ����
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
TurnOff_7LEDs                    ; �ر��߶�����ʾ��
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
DelayUS                                 ; ��ʱx��΢�룬x�ɱ���W�趨
          movwf   L1                 ;
LL1US        
          nop                               ;
          nop                               ;
          decfsz    L1, f             ;          
          goto        LL1US         ;
          return                         ;

;********Select_7LEDs ***********
Select_7LEDs                        ; ѡ���߶�����ʾ����ĳһλ����ڲ���ΪW�Ĵ�����ֵ��
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
LED_Display                        ; ������ڲ�����ĳһλ7����LED��ʾһ�����֡�λ����W�Ĵ����У�������wdata��
          call        Select_7LEDs   ; 
          banksel PORTD        ;
;--------------------------ȷ��wdata�����ݲ�����9---------
          movlw .9                    ;
          subwf  wdata, w       ;  
          btfsc     STATUS, C   ;
          goto DS9
          goto  DSW
DS9
          movlw  .9                  ;�������9����w�Ĵ���Ϊ9
          goto   DSD      ;
DSW
          movf wdata,w         ; ���������9����wdata��ֵ��w
DSD
          call        disp               ; ������7�����Ӧ�����
          movwf PORTD         ; �������뵽�˿�D        
          movlw .100              ;
          call        DelayUS       ;
          movlw 0xff               ;
          movwf PORTD        ;
          return                        ;


END                                        ; �������