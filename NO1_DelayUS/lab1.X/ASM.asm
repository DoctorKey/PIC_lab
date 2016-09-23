;*******************************************************************************
; ��    ��: PIC_ST_V3.0ѧϰ����ʾ����--��ʱ1΢��
; �� �� ��: Delay_US
; ��������: 2013.7.2
; �޸�����: 2013.7.2
; ��    ��: V1.0
; ��    ��: zyixin
;********************************************************************************
; ���߽ӷ���
; ��������: ��ʱ1΢��
;*******************************************************************************
;����Ȩ��Copyright(C) 2009-2019 All Rights Reserved
;���������˳��������ѧϰ��ο���������ע����Ȩ��������Ϣ��
;******************************************************************************/

 list		p=16f877A	; �������õĴ���������
 #include	"p16f877A.inc"	; ����ͷ�ļ�	
; CONFIG
; __config 0x3F7A
 __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

;***** ��������*******************************************************
L1       EQU  0x70                       ;��ʱ����ѭ������           
;**********************************************************************
	org         0x0000            ; ��λ��ڵ�ַ
  
;-------------------------------------------------Main�Ĵ���-----------------------------------------------------------------
main                                                 
         banksel  TRISB;		;�л���TRISB���ڵ�bank(bank1)
         bcf           TRISB, RB0;	;ȷ��RB0Ϊ���״̬
         banksel  PORTB;		;�л���PORTB���ڵ�bank(bank0)
Loop
          bsf          PORTB, RB0;
          movlw  .100;
          call         DelayUS;
          bcf          PORTB, RB0;
          movlw  .100;
          call         DelayUS;
          goto       Loop              ;  
;------------------------------------------------------------------�Ӻ���------------------------------------------------------------------------------
;**************DelayUS**************
DelayUS                                 ; ��ʱx��΢�룬x�ɱ���w�Ĵ����趨
          movwf   L1                 ;
LL1US        
          nop                               ;
          nop                               ;
          decfsz    L1, f             ;          
          goto        LL1US         ;
          return                         ;
;-------------------------------------------------------------------------------------------
END                                        ; �������