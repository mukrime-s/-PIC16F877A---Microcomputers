   
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    radix	dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    
    DATSEC1 udata
    LUT	    res	10
    counter	EQU 0x70
    
    org	0x00	
    
    BSF     STATUS, RP0
    MOVLW   0xFF
    MOVWF   TRISB
    CLRF    TRISA
    CLRF    TRISD
    BCF	    STATUS, RP0
    
    BSF	    PORTA, 5
    CLRF    counter
    
inf_loop:
    CALL Init_LUT
    
check_button3:    
    BTFSC PORTB,3
    GOTO check_button4
    GOTO button3_pressed
	
button3_pressed:
    MOVLW d'9'
    SUBWF counter, W
    BTFSS STATUS, Z
    GOTO counterIncf
    CLRF counter
    GOTO load_counter

check_button4:
    BTFSC PORTB,4
    GOTO check_button5
    GOTO button4_pressed
    
button4_pressed:
    MOVLW d'0'
    SUBWF counter, W
    BTFSS STATUS, Z
    GOTO counterDecf
    MOVLW d'9'
    MOVWF counter
    GOTO load_counter

check_button5:
    BTFSC PORTB, 5
    GOTO load_counter
    GOTO button5_pressed
    
button5_pressed:
    CLRF counter
    GOTO load_counter
    
counterIncf:
    INCF    counter, F
    GOTO    load_counter
    
counterDecf:
    DECF    counter, F
    GOTO   load_counter

load_counter:
    MOVF counter, W
    CALL GetCodeFromLUT
    MOVWF PORTD
    CALL Delay100ms
    GOTO inf_loop
    	
Init_LUT
    MOVLW   B'00111111'		; 0
    MOVWF   LUT			; LUT[0] = WREG    
    MOVLW   B'00000110'		; 1
    MOVWF   LUT+1		; LUT[0] = WREG    
    MOVLW   B'01011011'		; 2
    MOVWF   LUT+2		; LUT[0] = WREG    
    MOVLW   B'01001111'		; 3
    MOVWF   LUT+3		; LUT[0] = WREG    
    MOVLW   B'01100110'		; 4
    MOVWF   LUT+4		; LUT[0] = WREG    
    MOVLW   B'01101101'		; 5
    MOVWF   LUT+5		; LUT[0] = WREG    
    MOVLW   B'01111101'		; 6
    MOVWF   LUT+6		; LUT[0] = WREG    
    MOVLW   B'00000111'		; 7
    MOVWF   LUT+7		; LUT[0] = WREG    
    MOVLW   B'01111111'		; 8
    MOVWF   LUT+8		; LUT[0] = WREG    
    MOVLW   B'01101111'		; 9    
    MOVWF   LUT+9		; LUT[0] = WREGs
    RETURN
    
GetCodeFromLUT
    MOVWF   FSR		; FSR = number
    MOVLW   LUT		; WREG = &LUT
    ADDWF   FSR, F	; FSR += &LUT
    MOVF    INDF, W	; WREG = LUT[number]
    RETURN    
    
Delay100ms
i	EQU	    0x7d		    ; Use memory slot 0x70
j	EQU	    0x7e		    ; Use memory slot 0x71
	MOVLW	    d'100'		    ; 
	MOVWF	    i			    ; i = 100
Delay100ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    ; j = 250
Delay100ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    ; j--
	GOTO	    Delay100ms_InnerLoop

	DECFSZ	    i, F		    ; i?
	GOTO	    Delay100ms_OuterLoop    
	RETURN

    END








