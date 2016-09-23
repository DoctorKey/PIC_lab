    list	p=16f877A
    #include	"p16f877A.inc"
    ;CONFIG
    ;__config	0x3F7A
    __CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
    
L1	EQU	0x70
L2	EQU	0x71

org   0x0000

main
Loop
	movlw       .1
	call            DelayMS
	movlw       .2
	call            DelayMS
	movlw       .3
	call            DelayMS
	movlw       .4
	call            DelayMS
	movlw       .5
	call            DelayMS
	movlw       .10
	call            DelayMS
	movlw       .20
	call            DelayMS
	movlw       .50
	call            DelayMS
	call            Delay1S
	goto        Loop

DelayUS
	movwf       L1
	decf	L1,f
LL1US
	nop
	nop
	decfsz      L1,f
	goto        LL1US
	return

DelayMS
	movwf       L2
LL1MS
	movlw       .199
	call             DelayUS
	movlw       .199
	call             DelayUS
	movlw       .200
	call             DelayUS
	movlw       .200
	call             DelayUS
	movlw       .200
	call             DelayUS
	nop
	nop
	decfsz      L2,f
	goto	LL1MS	
	return

Delay1S
	movlw	.250
	call	DelayMS          
	movlw	.250          
	call	DelayMS         
	movlw	.250           
	call	DelayMS 
	movlw	.249         
	call	DelayMS
	movlw	.250
	call	DelayUS
	movlw	.250
	call	DelayUS
	movlw	.250
	call	DelayUS
	movlw	.244
	call	DelayUS
	nop
	nop
	return
END            