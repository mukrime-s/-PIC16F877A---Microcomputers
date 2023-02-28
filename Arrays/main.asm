    
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

    A           EQU 0x20;array 40 oldugu için sonraki 60 dan basliyor
    i           EQU 0x60
    m           EQU 0x61
    s           EQU 0x62
    p           EQU 0x63
    x           EQU 0x64
    y           EQU 0x65
    N           EQU 0x66
    count       EQU 0x67
    sum         EQU 0x68
    noElements  EQU 0x69
    R_H         EQU 0x70
    R_L         EQU 0x71
    counter_division EQU 0x72
      	
GOTO Main
    
Multiply:
    CLRF        R_L        
    CLRF        R_H         
    MOVF        y, F       
    BTFSC       STATUS, Z	
    RETURN                 
    MOVF        y, W
    MOVWF       i
    MOVF        x, W
    
Multiply_Loop:
    ADDWF       R_L, F      
    BTFSC       STATUS, C	
    INCF        R_H, F      
    DECFSZ      i, F        
    GOTO        Multiply_Loop
    BCF			STATUS,C
    RLF			R_L, W
    ADDWF       R_H, W
    RETURN              
    
GenerateNumbers:
    CLRF        count
    MOVLW       A
    MOVWF       FSR
    
    while_loop_begin:
        CLRF	counter_division
        IfState:
            MOVF        N, W
            SUBWF       x, W
            BTFSS       STATUS,C
		GOTO	if_statement
		
	while_loop_continue:
            MOVF        N, W
            SUBWF       y, W
            BTFSC       STATUS, C
            GOTO        ReturnState
			GOTO	if_statement
	    
	if_statement:
            MOVF        x, W
            ADDWF       y, W
            MOVWF       i
            BTFSS       i, 0            
            GOTO        else_statement
	    
          if_statement_continue:
            CALL        Multiply
            MOVWF       INDF
            INCF        FSR, F
            INCF        count, F  
            INCF        x, F
            GOTO        while_loop_begin
			GOTO		else_statement
			
          else_statement:
            MOVF        x, W
            ADDWF       y, W
            MOVWF       i
            bolum_loop:
                MOVLW   d'3'
                SUBWF   i, W
                BTFSC   STATUS, C
                GOTO    part_of_substraction
                GOTO    else_statement_continue
				
            part_of_substraction:
                INCF    counter_division, F
                MOVLW   d'3'
                SUBWF   i, F
                GOTO    bolum_loop
				
            else_statement_continue:
                MOVLW   d'3'
                ADDWF   y, F
                MOVF    counter_division, W
                MOVWF   INDF
                INCF    FSR, F
                INCF    count, F  
				
		GOTO    while_loop_begin
    ReturnState:
        MOVF    count, W
        RETURN
	
AddNumbers:
    CLRF        sum
    CLRF        i
    MOVLW       A
    MOVWF       FSR
    For_Loop_Begin:
        MOVF        INDF, W
        ADDWF       sum, F
        INCF        FSR, F
        DECFSZ      count, F
        GOTO        For_Loop_Begin
        MOVF        sum, W
        RETURN
	
DisplayNumbers:
    CLRF            i
    BANKSEL         TRISD
    CLRF            TRISD
    MOVLW           d'255'
    MOVWF           TRISB
    BANKSEL         PORTD
    MOVF            sum, W
    MOVWF           PORTD
    CALL            button   
    MOVLW           A
    MOVWF           FSR
    
    For_Loop_2:
        MOVF        INDF, W
        MOVWF       PORTD
        INCF        FSR, F
        CALL        Delay250ms
        CALL        button
        INCF        i, F
        MOVLW       d'5'
        SUBWF       i, W
        BTFSC       STATUS, C
        RETURN
        GOTO        For_Loop_2
	
Delay250ms:                        
    MOVLW       d'250'
    MOVWF       m
    Delay250ms_OuterLoop:
        MOVLW       d'250'
        MOVWF       s
    Delay250ms_InnerLoop:
        NOP
        DECFSZ      s, F                    
        GOTO        Delay250ms_InnerLoop  
        DECFSZ      m, F                  
        GOTO        Delay250ms_OuterLoop    
        RETURN                              
button:
    BTFSC           PORTB,3
    GOTO            button
    RETURN    
            
    Main:
    MOVLW       d'7'
    MOVWF       x
    MOVLW       d'11'
    MOVWF       y
    MOVLW       d'23'
    MOVWF       N
    CALL        GenerateNumbers
    MOVWF       noElements
    CALL        AddNumbers
    MOVWF       sum
    CALL        DisplayNumbers
    GOTO        $       
            
    BANKSEL         TRISD        
    CLRF            TRISD 
    BANKSEL         PORTD  
    MOVWF           PORTD 
        
LOOP GOTO $ ; Infinite loop
    END ; End of the program