

    LIST    P=16F877A
    INCLUDE P16F877.INC
    radix   dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF

    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF STATUS, RP0	; Select Bank1
    CLRF TRISB		; Set all pins of PORTB as output
    CLRF TRISD		; Set all pins of PORTD as output
    BCF STATUS, RP0	; Select Bank0
    CLRF PORTB		; Turn off all LEDs connected to PORTB
    CLRF PORTD		; Turn off all LEDs connected to PORTD
   
    ; ---------- Your code starts here --------------------------

    zib0 EQU 0x20
    zib1 EQU 0x21
    zib EQU 0x22
    i EQU 0x23
    N EQU 0x24
    dispValue EQU 0x25
    tmp1 EQU 0x26
    tmp2 EQU 0x27
 
    MOVLW d'1'
    MOVWF zib0
    MOVLW d'2'
    MOVWF zib1
    MOVLW d'0'			    
    MOVWF zib
    MOVLW d'2'
    MOVWF i
    MOVLW d'13'
    MOVWF N
    
FORLOOP:			    
    MOVF i, W			    ; Wreg = i
    SUBWF N, W			    ; N - Wreg
    BTFSC STATUS, C		    ; Wreg < N ?
    GOTO CONTINUE
    GOTO ENDL
CONTINUE:    
    MOVF zib1, W
    ANDLW 0x3F			    ; WREG = WREG & 0x3f 
    MOVWF tmp1			    ; tmp1 = WREG
    MOVF zib0, W		    
    IORLW 0x05			    ; WREG = WREG | 0x05
    MOVWF tmp2			    ; tmp2 = WREG
    MOVF tmp1, W		    ; WREG = tmp1
    ADDWF tmp2, W		    ; WREG = tmp1 + tmp2
    MOVWF zib			    ; zib = WREG    (zib = tmp1 + tmp2)
    MOVF zib1, W		    ; Wreg = zib1
    MOVWF zib0			    ; zib0 = WREG   (zib0 = zib1)
    MOVF zib, W			    ; Wreg = zib
    MOVWF zib1			    ; zib1 = zib
  
    CALL Delay250ms		    ; Wait for 250ms
    CALL BUTTON_RB3		    ; Wait for Button3 (RB3) to be pressed
    
    MOVF    zib, W
    MOVWF   PORTD
    BCF STATUS, C
    INCF i
    MOVF i, W			    ; Wreg = i
    SUBWF N, W
    BTFSC STATUS, C		    ; Wreg < N ?
    GOTO FORLOOP
    GOTO ENDL
    
ENDL:
    MOVF zib, W	
    MOVWF dispValue		    ;
    BSF STATUS,RP0		    ; Select bank 1
    CLRF TRISD			    ; Set all pins of PORTD as output
    BCF STATUS,RP0		    ; Select Bank 0
    MOVF dispValue, W		    ;
    CALL Delay250ms		    ; Wait for 250ms
    CALL BUTTON_RB3		    ; Wait for Button3 (RB3) to be pressed
    MOVWF PORTD			    ; 
    
Delay250ms:
    k    EQU        0x70            ; Use memory slot 0x70
    j    EQU        0x71            ; Use memory slot 0x71
    MOVLW        d'250'             ; 
    MOVWF        k                  ; k = 250
Delay250ms_OuterLoop
    MOVLW        d'250'
    MOVWF        j                  ; j = 250
Delay250ms_InnerLoop    
    NOP
    DECFSZ        j, F              ; j--
    GOTO        Delay250ms_InnerLoop
    DECFSZ        k, F              ; k?
    GOTO        Delay250ms_OuterLoop    
    RETURN
    
BUTTON_RB3:
    BTFSC PORTB, 3
    GOTO BUTTON_RB3
    BANKSEL TRISB
    MOVLW 0xFF
    MOVWF TRISB
    MOVLW 0x00
    MOVWF TRISD
    BANKSEL PORTD
    CLRF PORTD
    RETURN
    
LOOP GOTO $ ; Infinite loop
    END ; End of the program
