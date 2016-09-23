;*******************************************************************************
; ?    ?: PIC_ST_V3.0???????--??1??
; ? ? ?: Delay_US
; ????: 2013.7.2
; ????: 2013.7.2
; ?    ?: V1.0
; ?    ?: zyixin
;********************************************************************************
; ?????
; ????: ??1??
;*******************************************************************************
;????Copyright(C) 2009-2019 All Rights Reserved
;?????????????????????????????
;******************************************************************************/

 list		p=16f877A	; ??????????
 #include	<p16f877A.inc>	; ?????	


;***** ????*******************************************************
L1       EQU  0x70                       ;????????           
;**********************************************************************
	org         0x0000            ; ??????
  
;-------------------------------------------------Main???-----------------------------------------------------------------
main                                                 
         banksel  TRISB;
         bcf           TRISB, RB0;
         banksel  PORTB;
Loop
          bsf          PORTB, RB0;
          movlw  .100;
          call         DelayUS;
          bcf          PORTB, RB0;
          movlw  .100;
          call         DelayUS;
          goto       Loop              ;  
;------------------------------------------------------------------???------------------------------------------------------------------------------
;**************DelayUS**************
DelayUS                                 ; ??x????x???w?????
          movwf   L1                 ;
LL1US        
          nop                               ;
          nop                               ;
          decfsz    L1, f             ;          
          goto        LL1US         ;
          return                         ;
;-------------------------------------------------------------------------------------------
END                                        ; ????
