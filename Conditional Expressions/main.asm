

    LIST    P=16F877A
    INCLUDE P16F877.INC
    radix   dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF STATUS, RP0 ; Select Bank1
    CLRF TRISB         ; Set all pins of PORTB as output
    CLRF TRISD         ; Set all pins of PORTD as output
    BCF STATUS, RP0 ; Select Bank0
    CLRF PORTB         ; Turn off all LEDs connected to PORTB
    CLRF PORTD         ; Turn off all LEDs connected to PORTD

    ; ---------- Your code starts here --------------------------

    x EQU 0x20
    y EQU 0x21
    box EQU 0x22
    MOVLW 5
    MOVWF x
    MOVLW 5
    MOVWF y
    BTFSS    x, 7
    GOTO    X_MORE_THAN_11
    GOTO    LESS_ZERO
    
Y_LABEL:
    BTFSS    y, 7
    GOTO    Y_MORE_THAN_10
    GOTO    LESS_ZERO

LESS_ZERO:
    MOVLW    -d'1'
    MOVWF    box		    ; box = -1
    GOTO    NEXT_STATEMENT
    GOTO    X_MORE_THAN_11

X_MORE_THAN_11:	    
    BCF STATUS, C
    MOVF    x, W
    SUBLW    d'11'
    BTFSS    STATUS, C
    GOTO    LESS_ZERO
    GOTO    Y_LABEL		    ; x >= 0 && x <= 11

Y_MORE_THAN_10:
    BCF STATUS, C
    MOVF    y, W
    SUBLW    d'10'
    BTFSS    STATUS, C
    GOTO    LESS_ZERO
    
X_LESS_EQUAL_THAN_3:
    BCF STATUS, C
    MOVF x, W
    SUBLW d'3'
    BTFSS STATUS, C		    ; 0 <= Wreg <= 3 ?
    GOTO X_LESS_EQUAL_THAN_7
    
    BCF STATUS, C
    MOVF y, W
    SUBLW d'1'
    BTFSS STATUS, C
    GOTO Y_LESS_EQUAL_THAN_4
    MOVLW    d'3'
    MOVWF    box		    ; box = 3
    GOTO    NEXT_STATEMENT
    
    
Y_LESS_EQUAL_THAN_4:
    BCF STATUS, C
    MOVF y, W
    SUBLW d'4'
    BTFSS STATUS, C
    GOTO Y_MORE_THAN_4
    MOVLW    d'2'
    MOVWF    box		    ; box = 2
    GOTO    NEXT_STATEMENT
    
Y_MORE_THAN_4:
    MOVLW    d'1'
    MOVWF    box		    ; box = 1
    GOTO    NEXT_STATEMENT
    
X_LESS_EQUAL_THAN_7:
    BCF STATUS, C
    MOVF x, W
    SUBLW d'7'
    BTFSS STATUS, C		    ; Wreg > 3 && Wreg <= 7 ?
    GOTO X_MORE_THAN_7		    
				    
    BCF STATUS, C
    MOVF y, W 
    SUBLW d'5'	
    BTFSS STATUS, C		    ; Wreg > 1 && Wreg <= 5 ?
    GOTO Y_MORE_THAN_5
    MOVLW d'5'
    MOVWF box			    ; box = 5
    GOTO NEXT_STATEMENT
    
Y_MORE_THAN_5:
    MOVLW d'4'
    MOVWF box			    ; box = 4
    GOTO NEXT_STATEMENT

X_MORE_THAN_7:	
    BCF STATUS, C
    MOVF y, W
    SUBLW d'2'
    BTFSS STATUS, C
    GOTO Y_LESS_EQUAL_THAN_6
    MOVLW d'9'
    MOVWF box			    ; box = 9
    GOTO NEXT_STATEMENT
    
    
Y_LESS_EQUAL_THAN_6:
    BCF STATUS, C
    MOVF y, W
    SUBLW d'6'
    BTFSS STATUS, C
    GOTO Y_LESS_EQUAL_THAN_8
    MOVLW d'8'
    MOVWF box			    ; box = 8
    GOTO NEXT_STATEMENT
    
Y_LESS_EQUAL_THAN_8:
    BCF STATUS, C
    MOVF y, W
    SUBLW d'8'
    BTFSS STATUS, C
    GOTO Y_LESS_EQUAL_THAN_10
    MOVLW d'7'
    MOVWF box			      ; box = 7
    GOTO NEXT_STATEMENT
    
Y_LESS_EQUAL_THAN_10:
    MOVLW d'6'
    MOVWF box			      ; box = 6

NEXT_STATEMENT:
    ; ---------- Your code ends here ----------------------------
    MOVF box, W			    ; Wreg = box
    
    MOVWF PORTD ; Send the result stored in WREG to PORTD to display it on the LEDs
LOOP GOTO $ ; Infinite loop
    END ; End of the program