; This program shows how to use the 2x16 LCD
; We implement a simple 4 digit counter. At each iteration of the loop,
; we increment the counter by 1, and display its value on the screen
; We also show how to use the second line of the display
;	
    LIST 	P=16F877
    INCLUDE	P16F877.INC
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF 

    DATSEC1 udata
    LUT	    res	10
    no_iter EQU	    0x70
    i	    EQU	    0x71
    number  EQU	    0x72
    ; Reset vector
    org	0x00	
    GOTO    MAIN		; Jump to the main function
	
    #include <Delay.inc>	; Delay library (Copy the contents here)
    #include <LcdLib.inc>	; LcdLib.inc (LCD) utility routines

    ; This is the start of our main function
MAIN:    
	BSF     STATUS, RP0	; Select Bank1
	
	CLRF    TRISA
	CLRF	TRISD		; Make all pins of PORTD output
	CLRF	TRISE		; Make all ports of PORTE output

	; This is only necessary because our programming board connects E0, E1 and E2 pins of the MCU
	; to LCD's control pins RS, RW, EN respectively. Because PORTE shares the same pins as the analog pins of PORTA of the MCU,
	; not only we must we set PORTE pins as output, but also set the analog pins of PORTA as digital output.
	; If we don't do this, PORTE's pins are not set up properly, and the LCD does not work	
	MOVLW	0x03		; Choose RA0 analog input and RA3 reference input
	MOVWF	ADCON1		; Register to configure PORTA's pins as analog/digital <11> means, all but one are analog

	BCF	STATUS, RP0	; Select Bank0			
	CALL	LCD_Initialize	; Initialize the LCD
	CLRF	number		; Clear digits[0]
	CLRF	number+1	; Clear digits[1]
	CLRF    PORTD		; PORTD = 0
	CLRF    PORTA
	
;*******************************************************************************************************************************
GOTO    inf_loop
Message_Rolled_Over:
    call    DisplayCounter2
    CLRF    i
    MOVLW   d'90'
    MOVWF   no_iter
    CALL    Init_LUT
    GOTO    for_loop
    
inf_loop:
    call DisplayCounter
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
    GOTO    number1_equal_two	; Repeat

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
    GOTO    Message_Rolled_Over	

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
	
DisplayCounter
CALL counter_val
	
DisplayCounter_continue:
	
		
	; The rest of the characters will get displayed on the second line
	call	LCD_MoveCursor2SecondLine   ; Move the cursor to the start of the second line
	
	movlw	'C'	    
	call	LCD_Send_Char

	movlw	'o'	    
	call	LCD_Send_Char
	
	movlw	'u'	    
	call	LCD_Send_Char
	
	movlw	'n'	    
	call	LCD_Send_Char
	
	movlw	't'	    
	call	LCD_Send_Char
	
	movlw	'i'	    
	call	LCD_Send_Char
	
	movlw	'n'	    
	call	LCD_Send_Char

	movlw	'g'	
	call	LCD_Send_Char

	movlw	' '	
	call	LCD_Send_Char

	movlw	'u'	
	call	LCD_Send_Char
	
	movlw	'p'	
	call	LCD_Send_Char

	movlw	'.'	
	call	LCD_Send_Char

	movlw	'.'	
	call	LCD_Send_Char

	movlw	'.'	
	call	LCD_Send_Char
	
	movlw	' '	
	call	LCD_Send_Char
	
	movlw	' '	
	call	LCD_Send_Char
	
	RETURN
DisplayCounter2
	CALL counter_val
DisplayCounter2_CONTINUE:	
	; The rest of the characters will get displayed on the second line
	call	LCD_MoveCursor2SecondLine   ; Move the cursor to the start of the second line
	
	movlw	'R'	    
	call	LCD_Send_Char

	movlw	'o'	    
	call	LCD_Send_Char
	
	movlw	'l'	    
	call	LCD_Send_Char
	
	movlw	'l'	    
	call	LCD_Send_Char
	
	movlw	'e'	    
	call	LCD_Send_Char
	
	movlw	'd'	    
	call	LCD_Send_Char
	
	movlw	' '	    
	call	LCD_Send_Char

	movlw	'o'	
	call	LCD_Send_Char

	movlw	'v'	
	call	LCD_Send_Char

	movlw	'e'	
	call	LCD_Send_Char
	
	movlw	'r'	
	call	LCD_Send_Char

	movlw	' '	
	call	LCD_Send_Char

	movlw	't'	
	call	LCD_Send_Char

	movlw	'o'	
	call	LCD_Send_Char
	
	movlw	' '	
	call	LCD_Send_Char
	
	movlw	'0'	
	call	LCD_Send_Char
	
	RETURN
	
counter_val
	call	LCD_Clear		; Clear the LCD screen

	movlw	'C'	
	call	LCD_Send_Char
	movlw	'o'	
	call	LCD_Send_Char
	movlw	'u'	
	call	LCD_Send_Char
	movlw	'n'	
	call	LCD_Send_Char
	movlw	't'	
	call	LCD_Send_Char
	movlw	'e'	
	call	LCD_Send_Char
	movlw	'r'	
	call	LCD_Send_Char
	
	movlw	' '	
	call	LCD_Send_Char
	movlw	'V'	
	call	LCD_Send_Char
	movlw	'a'	
	call	LCD_Send_Char
	movlw	'l'	
	call	LCD_Send_Char
	movlw	':'	
	call	LCD_Send_Char
	movlw	' '	
	call	LCD_Send_Char	
	
	; Print digit1: digits[1]
	MOVF	number+1, W ; WREG <- digit
	ADDLW	'0'	    ; Add '0' to the digit 
	CALL	LCD_Send_Char

	; Print digit1: LSB
	MOVF	number, W   ; WREG <- digit
	ADDLW	'0'	    ; Add '0' to the digit 
	CALL	LCD_Send_Char
	
	RETURN
	
	END