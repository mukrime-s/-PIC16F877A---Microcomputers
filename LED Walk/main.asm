    LIST    P=16F877A
    INCLUDE P16F877.INC
    radix   dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF STATUS, RP0 ; Select Bank1
    CLRF TRISB         ; Set all pins of PORTB as output
    CLRF TRISD         ; Set all pins of PORTD as output
    BCF STATUS, RP0 ; Select Bank0
    CLRF PORTB         ; Turn off all LEDs connected to PORTB
    CLRF PORTD         ; Turn off all LEDs connected to PORTD
   
    ; ---------- Your code starts here --------------------------
    
Main_Function:
    MOVE_LEFT	EQU	0x20
    MOVE_RIGHT	EQU	0x21	
    dir		EQU	0x22
    val		EQU	0x23
    count	EQU	0x24
    k		EQU	0x70
    j		EQU	0x71
    m		EQU	0x72
	
    MOVLW   d'0'
    MOVWF   MOVE_LEFT
    MOVLW   d'1'
    MOVWF   MOVE_RIGHT
    MOVF    MOVE_LEFT, W
    MOVWF   dir
    MOVLW   0x1
    MOVWF   val
    MOVLW   d'0'
    MOVWF   count
    CLRW			 
    BANKSEL TRISD		    
    MOVWF   TRISD		    
    BANKSEL TRISB		    
    MOVWF   TRISB
    BANKSEL PORTB 
    MOVWF   PORTB
While_Loop:
    MOVF    val, W		    
    MOVWF   PORTD		    
    CALL    Delay
    INCF    count, F
    
    MOVLW   d'15'		   
    SUBWF   count, W		    
    BTFSC   STATUS,Z		    
    GOTO    If_Statement		

	 
    Else_If:
	MOVLW   0x80		   	
	SUBWF   val, W		    
	BTFSS   STATUS, Z	 
	GOTO    LeftOrRightShift
	
	MOVF    MOVE_RIGHT, W	   
	MOVWF   dir		  
    
	
LeftOrRightShift:
    MOVF    MOVE_LEFT, W		  
    SUBWF   dir, W		    
    BTFSS   STATUS, Z		    
    GOTO    Shift_Right		   
    BCF	    STATUS, C		   
    RLF	    val, F		   
    GOTO    While_Loop

    Shift_Right:
	BCF	STATUS, C	  
	RRF 	val, F		    
	GOTO    While_Loop
    
	
If_Statement:
    CLRF PORTD			   	   
    CALL    Delay
    
    MOVLW   0xFF		   
    MOVWF   PORTD		   
    CALL    Delay
    
    CLRF PORTD		    
    CALL    Delay
    
    MOVLW   0xFF		   
    MOVWF   PORTD		 
    CALL    Delay
    
    CLRF PORTD		    
    CALL    Delay
    
    MOVLW   0x1			    
    MOVWF   val			    
    MOVLW   d'0'		   
    MOVWF   count		
    MOVF    MOVE_LEFT, W		    
    MOVWF   dir	
    GOTO    While_Loop    
    		   

Delay:  ;delay fonksyonu 250 ms ve 500 ms cagiracak sekilde olusturuldu.
    ;CALL Delay_250ms
    CALL Delay_500ms
      RETURN
	
	
Delay_250ms:                   
    MOVLW   d'250'
    MOVWF   j			    
    Delay250ms_OuterLoop:
        MOVLW	d'250'
        MOVWF	k			  
    Delay250ms_InnerLoop:
        NOP
        DECFSZ	k, F		         
        GOTO	Delay250ms_InnerLoop  
        DECFSZ	j, F		   
        GOTO	Delay250ms_OuterLoop
        RETURN                             

Delay_500ms:
    MOVLW	    d'2'
	MOVWF	    m			    
Delay500ms_Loop1_Begin
	MOVLW	    d'250'
	MOVWF	    j			    
Delay500ms_Loop2_Begin	
	MOVLW	    d'250'
	MOVWF	    k			    
Delay500ms_Loop3_Begin	
	NOP				    
	DECFSZ	    k, F		    
	GOTO	    Delay500ms_Loop3_Begin

	DECFSZ	    j, F		    
	GOTO	    Delay500ms_Loop2_Begin

	DECFSZ	    m, F		    
	GOTO	    Delay500ms_Loop1_Begin    
	RETURN
        
LOOP GOTO $ ; Infinite loop
    END ; End of the program


