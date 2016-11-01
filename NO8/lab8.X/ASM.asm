;*******************************************************************************
; ��    ��: PIC_ST_V3.0ѧϰ����ʾ����--Ƭ��flash��д
; �� �� ��: Flash_RW
; ��������: 2013.7.9
; �޸�����: 2013.7.9
; ��    ��: V1.0
; ��    ��: zyixin
;********************************************************************************
; ���߽ӷ������ڲ�Flashд���ݣ��ٶ�ȡ���ݣ�����ʾ
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

M_addr                     EQU  0x76             ;
M_data                      EQU  0x77             ;
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

org 0x0800
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
;------------------------------------------------------------------Main��������------------------------------------------------------------------------------




;------------------------------------------------------------------�Ӻ���------------------------------------------------------------------------------
;********EEPROM_Write******************
EEPROM_Write                     ; д�ڲ�EEPROM
;          banksel  EEADR             ;
;          movf       M_addr, w      ;д��ַ
;          movwf   EEADR             ;
;          movf       M_data, w       ;д����
;          movwf   EEDATA          ;
;	BSF STATUS, RP0 ; Bank1
;	BCF INTCON, GIE ; Disable INTs
;          banksel  EECON1          ;
;          bcf           EECON1, EEPGD ;�ڲ�EEPROM�ռ�
;          bsf           EECON1, WREN  ;дʹ��
;          movlw   0x55               ;
;          movwf   EECON2        ;
;          movlw   0xAA              ;
;          movwf   EECON2		 ;
;          bsf           EECON1,WR	;����д����
;          btfsc       EECON1,WR	;�ȴ�д��������
;          goto        $ - 1                   ;
;          bcf           EECON1, WREN;д��ֹ
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
EEPROM_Read                       ;���ڲ�EEPROM
          banksel  EEADR             ;д��ַ
          movf       M_addr, w      ;
          movwf   EEADR             ;          
          banksel  EECON1          ;
          bcf           EECON1, EEPGD ;�ڲ�EEPROM�ռ�
          bsf           EECON1, RD  ; ����������         
          btfsc       EECON1, RD  ;�ȴ������
          goto        $ - 1                   ; 
          banksel   EEDATA        ;
          movf       EEDATA, w  ;
          movwf   M_data           ;
          return                             ;
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




END                                        ; �������