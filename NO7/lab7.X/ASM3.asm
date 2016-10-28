;*******************************************************************************
; ��    ��: PIC_ST_V3.0ѧϰ����ʾ����--IO����ģʽ
; �� �� ��: IO_IN
; ��������: 2013.7.2
; �޸�����: 2013.7.2
; ��    ��: V1.0
; ��    ��: zyixin
;********************************************************************************
; ���߽ӷ����ö̽�ñ�̽�P14
; ��������: ����1(key1)����RB0��RB5��ͨ����ȡRB0��ֵ��ȷ����û�а�������
; ��Ҫѧϰ��Ƭ��IO�ڵ����빦��
;��PORTD�Ĳ�������ϸ��PIC16F877A�����ֲ�4.4�½�����
	
;��д����������Main����LED������1S�󣬹ر�LED����������״̬��
;ʹ��RB0���ⲿ�жϻ���CPU���ظ������ĵ������������رա����߹��̡�
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
D1                                 EQU  0x20             ; ����1����HC595�ĳ�ʼ����ʹ��
SHADE_PORTD	EQU	0x21	;PORTDӰ�ӼĴ���

L1                                EQU  0x77             ;��ʱ����ѭ������
L2                                EQU  0x78             ;��ʱ����ѭ������
L3                                EQU  0x79             ;��ʱ����ѭ������
i                                    EQU  0x7A             ;ѭ������i
j                                    EQU  0x7B             ;ѭ������j
k                                   EQU  0x7C             ;ѭ������k
w_temp		  EQU	0x7D		;�ж��ֳ�����
status_temp	  EQU	0x7E		;�ж��ֳ�����
pclath_temp	  EQU	0x7F		;�ж��ֳ�����             
;**********************************************************************
	ORG         0x0000          ; ��λ��ڵ�ַ
	nop	                                ; ��ICD������ϵ�nop
  	goto        main                ; ��ת��Main
;**********************************************************************
	ORG         0x0004                ; �ж�������ڵ�ַ
	movwf   w_temp                ; ��ջ����
	movf	      STATUS,w          
	movwf   status_temp        
	movf	      PCLATH,w	 
	movwf   pclath_temp	 
;**********************************************************************
	 btfss    INTCON, INTE      ; �Ƿ������ж�
            goto     EndOfInt                ; ������ת���жϴ������β��
            btfss    INTCON, INTF      ; �Ƿ���λ�����жϵı�־
            goto     EndOfInt                ; ������ת���жϴ������β��           
            bcf        INTCON, INTF      ; ��������жϱ�־λ  

	bcf	PORTD,7
	
          
;**********************************************************************
EndOfInt  
	movf	     pclath_temp,w	  ; ��ջ
	movwf  PCLATH		  
	movf      status_temp,w    
	movwf  STATUS                
	swapf    w_temp,f
	swapf    w_temp,w           
;********************************************************************** 
	retfie                                              ;  �жϷ���      

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
          banksel  TRISB                             ; ѡ��bank1
	bsf          OPTION_REG, NOT_RBPU; �ر���������ʹ��
	bcf          OPTION_REG, INTEDG; RB0�½�������
	bsf           TRISB, RB0                  ; RB0Ϊ����ģʽ
	bcf           TRISB, RB5                  ; RB5Ϊ���ģʽ	
	banksel  PORTB                           ; ѡ��bank0
	bcf           PORTB, RB5                ; KEY1����͵�ƽ��������1�����£���KEY6���յ��͵�ƽ������Ϊ�ߵ�ƽ
	nop                                                  ; �ղ�����ʹKEY1�����ƽ�ȶ�
	  
	  movlw	0xff
	  movwf	PORTD	;���̣ţĹر�
	  movlw	0xfe
	  movwf	SHADE_PORTD
	  bsf	STATUS,C
	  
	  bcf          INTCON, INTF             ; �������жϱ�־
	bsf          INTCON, INTE             ; �������ж�
	bsf          INTCON, GIE                ; �����ж�
	
loop	
	bcf	PORTD,0		;����LED1
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
	bsf	PORTD,0		;��LED1
	bsf	PORTD,7		;���жϱ�־LED���
	sleep
	goto	loop   


;------------------------------------------------------------------�Ӻ���------------------------------------------------------------------------------
;********HC595_Init******************
HC595_Init                                     ; ��ʼ�� 74HC595
          banksel  ADCON1               ;
          movlw  0x8E;
          movwf  ADCON1                ;
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
DelayMS                                 ; ��ʱx���룬x�ɱ���W�趨
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
END                                        ; �������
