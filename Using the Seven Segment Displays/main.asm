; This program counts up to 16 and displays the corresponding hexadecimal number
; on one of the seven segment displays. By default this program uses the first
; segment display, but that can easily be changed.
;    
    LIST 	P=16F877A
    INCLUDE	P16F877.INC
    radix	dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

; Static global variables
DATSEC1	udata
LUT	res	10		; 16 byte look up value	    
    
; Here is the number variable
no_iter	    EQU	    0x70
i	    EQU	    0x71
number	    EQU	    0x72
	
    ; Reset vector
    org	    0x00
    BSF	    STATUS, RP0		; Select Bank1
    CLRF    TRISA		; PortA --> Output
    CLRF    TRISD		; PortD --> Output
    BCF	    STATUS, RP0		; Select Bank0
    
    CLRF number
    CLRF number+1
    CLRF    PORTD		; PORTD = 0
    CLRF    PORTA		; Deselect all SSDs
    
inf_loop:
    CLRF i
    MOVLW d'90'
    MOVWF no_iter
    CALL  Init_LUT
for_loop:
    MOVF no_iter, W
    SUBWF i, W
    BTFSS STATUS, C
    GOTO continue
    GOTO end_for_loop
    
continue:
    ; Clear PORTD & Select DIS4
    
    BSF	    PORTA, 5		; Select DIS4
    BCF	    PORTA, 4		; Select DIS4
    MOVF    number, W		; number->WREG
    CALL    GetCodeFromLUT	; Get the 7-segment code for the number    
    MOVWF   PORTD		; Display the number
    CALL    Delay		; Wait for 1 second
    BCF	    PORTA, 5		; Select DIS4
    BSF	    PORTA, 4		; Select DIS4
    MOVF    number+1, W		; number->WREG
    CALL    GetCodeFromLUT	; Get the 7-segment code for the number    
    MOVWF   PORTD		; Display the number
    CALL    Delay
    INCF    i
    GOTO    for_loop

end_for_loop:
    INCF    number,F
    MOVLW   d'10'		; 16->W
    SUBWF   number, W		; WREG = number - 16
    BTFSS   STATUS, C		; If the previous operation equals 0, then we must set number to 0
    GOTO    number1_equal_two
    GOTO    first_if

first_if:
    CLRF    number		; 0->number
    INCF    number+1
    GOTO    number1_equal_two		; Repeat

number1_equal_two:
    MOVLW   d'2'		; 16->W
    SUBWF   number+1, W		; WREG = number - 16
    BTFSS   STATUS, C
    GOTO    inf_loop
    GOTO    number0_equal_one
    
number0_equal_one:
    MOVLW   d'1'		; 16->W
    SUBWF   number, W		; WREG = number - 16
    BTFSS   STATUS, C
    GOTO    inf_loop
    CLRF    number
    CLRF    number+1
    
    GOTO    inf_loop
 
;------------------------------------------------------------------------------
; Init_LUT
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
; Get the code from the LUT
;------------------------------------------------------------------------------
GetCodeFromLUT
    MOVWF   FSR		; FSR = number
    MOVLW   LUT		; WREG = &LUT
    ADDWF   FSR, F	; FSR += &LUT
    MOVF    INDF, W	; WREG = LUT[number]
    RETURN
    
;------------------------------------------------------------------------------
; This function just wastes some time:
; Simply loops for 4x256x256 iterations of the loops
;------------------------------------------------------------------------------
Delay
m	EQU	    0x7d		    
j	EQU	    0x7e		    
	MOVLW	    d'5'		    
	MOVWF	    m			    
Delay5ms_OuterLoop
	MOVLW	    d'250'
	MOVWF	    j			    
Delay5ms_InnerLoop	
	NOP
	DECFSZ	    j, F		    
	GOTO	    Delay5ms_InnerLoop

	DECFSZ	    m, F		    
	GOTO	    Delay5ms_OuterLoop
	RETURN
   
		
    END

