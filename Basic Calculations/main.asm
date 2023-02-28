
    LIST    P=16F877A
    INCLUDE P16F877.INC
    radix   dec
    __CONFIG _CP_OFF &_WDT_OFF & _BODEN_ON & _PWRTE_ON & _XT_OSC & _WRT_ENABLE_OFF & _LVP_OFF & _DEBUG_OFF & _CPD_OFF
    
    ; Reset vector
    org 0x00
    ; ---------- Initialization ---------------------------------
    BSF STATUS, RP0 ; Select Bank1
    CLRF TRISB 		; Set all pins of PORTB as output
    CLRF TRISD 		; Set all pins of PORTD as output
    BCF STATUS, RP0 ; Select Bank0
    CLRF PORTB 		; Turn off all LEDs connected to PORTB
    CLRF PORTD 		; Turn off all LEDs connected to PORTD

    ; ---------- Your code starts here --------------------------	

    x EQU 0x20
    y EQU 0x21
    z EQU 0x22
    r1 EQU 0x23
    r2 EQU 0x24
    r3 EQU 0x25
    r4 EQU 0x26
    tempx EQU 0x27
    tempy EQU 0x28
    tempz EQU 0x29
    r EQU 0x30
 
    MOVLW d'5'
    MOVWF x	    ;x=5
    MOVLW d'6'
    MOVWF y	    ;y=6
    MOVLW d'7'
    MOVWF z	    ;z=7
    ;--------------------
    BCF	STATUS, C   ;C=0
    RLF x, W	    ;Wreg = 2*x
    MOVWF tempx	    ;tempx = Wreg = 2*x
    BCF	STATUS, C   ;C=0
    RLF tempx, W    ;Wreg = 4*x
    ADDWF x, W	    ;Wreg = (4x) + x
    MOVWF tempx	    ;tempx = Wreg = 5x
    ;----------------------------------
    MOVF y, W	    ;Wreg = y
    BCF	STATUS, C
    RLF y, W	    ;Wreg = 2*y
    MOVWF tempy	    ;tempy = Wreg = 2y
    ;----------------------------------
    MOVF z, W	    ;Wreg = z
    MOVWF tempz     ;tempz = Wreg = z
    MOVLW d'3'
    SUBWF tempz, F ; tempz = tempz - 3
    ;-----------------------------------
    CLRW	    ;Wreg = 0
    MOVF tempx, W   ;Wreg = tempx
    ADDWF tempz, F  ;tempz = tempx + tempz		(5x) + (z-3)	
    CLRW	    ;Wreg = 0
    MOVF tempy, W   ;Wreg = tempy
    SUBWF tempz, W  ;tempz = tempz - tempy		(5x) + (z-3) - (2y)
    MOVWF r1
    ;----------------------------------------------------------------------
    CLRW	    ;Wreg = 0
    CLRF tempx	    ;tempx = 0
    CLRF tempy	    ;tempy = 0
    CLRF tempz	    ;tempz = 0
    
    MOVF x, W	    ;Wreg = x
    ADDLW d'5'	    ;Wreg = x+5
    MOVWF tempx	    ;tempx = Wreg = x+5
    BCF	STATUS, C   ;C=0
    RLF tempx, F    ;tmpx = (x+5)*2
    BCF	STATUS, C   ;C=0
    RLF tempx, F    ;tempx = (x+5)*4
    ;------------
    BCF	STATUS, C   ;C=0
    RLF y, W	    ;Wreg = 2*y
    MOVWF tempy	    ;tempy = Wreg = 2*y
    ADDWF y, W	    ;Wreg = (2y) + y
    MOVWF tempy	    ;tempy = Wreg = 3y
    ;-----------
    MOVF tempy, W   ;Wreg = tempy = 3y
    SUBWF tempx, W  ;Wreg = tempx - tempy	    (x + 5)*4 - 3y
    ADDWF z, W	    ;				    (x + 5)*4 - 3y + z
    MOVWF r2	    ; 
    ;-----------------------------------------------
    CLRW	    ;Wreg = 0
    CLRF tempx	    ;tempx = 0
    CLRF tempy	    ;tempy = 0
    CLRF tempz	    ;tempz = 0
    
    BCF	STATUS, C   ;C=0
    RRF x, W	    ;Wreg = x/2
    MOVWF tempx	    ;tempx = Wreg
    ;-------------------------------
    BCF	STATUS, C   ;C=0
    RRF y, W	    ;Wreg = y/2
    MOVWF tempy	    ;tempy = Wreg
    ;-------------------------------
    BCF	STATUS, C   ;C=0
    RRF z, W	    ;Wreg = z/2
    MOVWF tempz	    ;tempz = Wreg
    BCF	STATUS, C   ;C=0
    RRF tempz, W    ;Wreg = z/4
    ADDWF tempx, W  ;Wreg = tempx + tempz
    ADDWF tempy, W  ;Wreg = (tempx + tempz) + tempy
    MOVWF r3	    ;
    ;---------------------------------------------------------------
    CLRW	    ;Wreg = 0
    CLRF tempx	    ;tempx = 0
    CLRF tempy	    ;tempy = 0
    CLRF tempz	    ;tempz = 0
    
    BCF	STATUS, C   ;C=0
    RLF x, W	    ;Wreg = 2*x
    ADDWF x, W	    ;2x + x
    MOVWF tempx	    ;tempx = 3x
    RLF z, W	    ;Wreg = 2*z
    ADDWF z, W	    ;Wreg = 3z
    ADDWF y, W	    ;Wreg = 3z + y
    SUBWF tempx, F  ;tempx = 3x - (3z + y)
    BCF	STATUS, C   ;C=0
    RLF tempx, W
    ADDLW -d'30'
    MOVWF r4
    ;--------------------------------------------------------------
    CLRW	    ;Wreg = 0
    CLRF tempx	    ;tempx = 0
    CLRF tempy	    ;tempy = 0
    CLRF tempz	    ;tempz = 0
    
    BCF	STATUS, C   ;C=0
    RLF r1, W	    ;Wreg = 2*r1
    ADDWF r1, W	    ;2r1 + r1
    MOVWF tempx	    ;tempx = Wreg
    ;-------------------------------------
    BCF	STATUS, C   ;C=0
    RLF r2, W	    ;Wreg = 2*r2
    MOVWF tempy	    ;tempy = Wreg
    ;--------------------------------------------
    BCF	STATUS, C   ;C=0
    RRF r3, W	    ;Wreg = r3/2
    MOVWF tempz	    ;tempz = Wreg
    ;-------------------------------------------
    MOVF tempx, W   ;Wreg = tempx
    ADDWF tempy, F  ;tempy = tempy + tempx
    MOVF tempz, W   ;Wreg = tempz
    SUBWF tempy, F  ;tempy = tempy - tempz
    MOVF r4, W   ;Wreg = r4
    SUBWF tempy, W  ;tempy = tempy - r4
    ;PORTD = r; // Display the result on the LEDs
    
    ; ---------- Your code ends here ----------------------------

    MOVWF PORTD ; Send the result stored in WREG to PORTD to display it on the LEDs
LOOP GOTO $ ; Infinite loop
    END ; End of the program








