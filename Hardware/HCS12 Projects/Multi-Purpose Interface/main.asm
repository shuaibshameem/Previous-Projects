

; Define symbolic constants 
PORTT 	EQU  $240        ;Define Register Locations
PORTM   EQU  $250
PortT   EQU  $240
PortM   EQU  $250
PORTAD  EQU  $270
PortAD  EQU  $270
DDRAD   EQU  $272
DDRT  	EQU  $242
DDRM    EQU  $252
INITRG	EQU  $11
INITRM	EQU  $10
CLKSEL	EQU  $39
PLLCTL	EQU  $3A
CRGFLG	EQU  $37
SYNR  	EQU  $34
REFDV	  EQU  $35
COPCTL	EQU  $3C
TSCR1	  EQU  $46
TSCR2	  EQU  $4D
TIOS	  EQU  $40
TCNT	  EQU  $44
TC0		  EQU  $50
TFLG1	  EQU  $4E
TC5     EQU  $5A
TIE     EQU  $4C
RS	    EQU	  $01	  ; Register Select (RS) at PT0 (0 = command, 1= Data) 
ENABLE	EQU	  $02     ; LCD ENABLE at PT1
RCK 	  EQU	  $08	  ; RCK connect to PT2		
SPCR1   EQU   $00D8
SPCR2 	EQU	  $00D9
SPIB    EQU   $00DA
SPSR    EQU   $00DB
SPDR    EQU   $00DD
INITEE	EQU	  $0012


        ORG  $3800	  	; Beginning of RAM for Variables
;Program 3 Variables
ONES4   DS.W  1
TENS4   DS.W  1

;Program 4 Variables
COUNTP4 DS.B 1
FLAG1   DS.B 1
TIMETEN DS.B 1
TIMEONE DS.B 1

;Program 7 Variables
KEYP7   DS.B 1          ; Hold Key Press
PIN     DS.B 4          ; Hold Lock Pin
PINSET  DS.B 1          ; Boolean check of pin being set
INPUT   DS.B 4          ; Hold last 4 key presses
MODE    DS.W 1          ; Hold Current State of lock
OUT     DS.B 1          ; Hold arbitrary image state
SHOW    DS.W 1          ; Hold bottom LED image

;Program 9 Variables
COUNT DS.B 1	   	
PRINT DS.B 1    
KEY     DS.B 1    ; - Upper 8-bits of the Variable \
KEY_1   DS.B 1    ; - Lower 8-bits of the Variable / 16-bits
GEN     DS.B 1
NEGCH   DS.B 1
PORTMSK DS.B 1
KCOUNT  DS.B 1
DIGIT1  DS.B 1
DIGIT2  DS.B 1
SOLU    DS.B 1    ; - Upper 8-bits of the Variable \
SOLU_L  DS.B 1    ; - Lower 8-bits of the Variable / 16-bits
FANS    DS.B 1

;Program 12 Variables
Form    DS.B 1
Speed   DS.B 1
HourTen DS.B 1
HourOne DS.B 1
MinTen  DS.B 1
MinOne  DS.B 1
sCNT    DS.B 1
mCNT    DS.B 1
Tset    DS.B 1
Init    DS.B 1
ColonOn DS.B 1
EnterOne DS.B 1
EnterTwo DS.B 1
EnterThree DS.B 1
EnterFour DS.B 1


; General Variables
Exp3    DS.B 1
Exp4    DS.B 1
Exp7    DS.B 1
Exp9    DS.B 1
Exp12   DS.B 1
;
; The main code begins here. Note the START Label
;
      	ORG   $4000	      	; Beginning of Flash EEPROM
START 	LDS   #$3FCE	    ; Top of the Stack
      	SEI		      	    ; Turn Off Interrupts
        MOVB  #$00, INITRG	; I/O and Control Registers Start at $0000
	      MOVB  #$39, INITRM 	; RAM ends at $3FFF
;
; We Need To Set Up The PLL So that the E-Clock = 24MHz
;
      	BCLR  CLKSEL,$80      ; disengage PLL from system
      	BSET  PLLCTL,$40      ; turn on PLL
      	MOVB  #$2,SYNR        ; set PLL multiplier
      	MOVB  #$0,REFDV       ; set PLL divider
      	NOP	                  ; No OP
      	NOP		              ; NO OP
plp 	  BRCLR CRGFLG,$08,plp  ; while (!(crg.crgflg.bit.lock==1))
      	BSET  CLKSEL,$80      ; engage PLL
;

        MOVB #$07, TSCR2
      	MOVB #$20, TIOS
      	MOVB #$90, TSCR1
      	MOVB #$20, TIE
      	LDD TCNT
      	ADDD #INCREMENT4
      	STD TC5
      	MOVB #$20, TFLG1
      	BCLR Exp3, $FF
        BCLR Exp4, $FF
        BCLR Exp7, $FF
        BCLR Exp9, $FF
        BCLR Exp12, $FF
        


;
;
    	  CLI

RESTART:BCLR Exp3, $FF
        BCLR Exp4, $FF
        BCLR Exp7, $FF
        BCLR Exp9, $FF
        BCLR Exp12, $FF
        LDAA #$0F
        STAA DDRT
        LDAA #$FF
        STAA DDRAD
        LDAA  #$22
    	  STAA  SPIB	          ; SPI clocks a 1/24 of E-Clock
        MOVB  #$3F, DDRM      ; Setup PortM data direction 
;
; Setup for Master, enable, high speed SPI, and Built-in Timer
;
    	  LDAA  #$50
        STAA  SPCR1
    	  LDAA  #$00
    	  STAA  SPCR2
    	  LDAA  #$80            
    	  STAA  TSCR1
        
        LDAA  #00
        BSET  PortM, RCK    ; Set RCK to Idle HIGH
        ;JSR InitLCD
        
    	  LDX   #Intro1       	; Load base address of String1
        ;JSR   PrintString

    	  LDAA  #$C0	         	; First line is done jump to line 2
        ;JSR	  Command

    	  LDX   #Intro2    	    ; Load base address of String2
        ;JSR   PrintString
     
     	  ;JSR	  delay2	        ; Let's display the message a while 
	   
	      ;JSR   BlinkDisp         ; Blink the display 4 times
	   
        ;JSR   ClearDisp         ; Clear the display
    	
Redo	  LDX   #Intro3    	    ; Load base address of String3
        ;JSR   PrintString

    	  LDAA  #$C0	    	    ; First line is done jump to line 2
        ;JSR	  Command

    	  LDX   #Intro4    	    ; Load base address of String4
        ;JSR   PrintString
     
     	  ;JSR	  delay2	        ; Let's display the message a while  

        ;JSR   ShiftSecondLine   ; Shift the second line to left
        
        LDX   #Intro5    	    ; Load base address of String5
        ;JSR   PrintString
     
     	  ;JSR	  delay2	        ; Let's display the message a while 

        ;JSR   ShiftSecondLine
        
        LDX   #Intro6       	; Load base address of String6
        ;JSR   PrintString
     
     	  ;JSR	  delay2	        ; Let's display the message a while  
        
        
        ;JSR   ShiftSecondLine
        
        LDX   #Intro7       	; Load base address of String7
        ;JSR   PrintString
     
     	  ;JSR	  delay2	        ; Let's display the message a while  
        
        
        ;JSR   ShiftSecondLine
        
        LDX   #Intro8       	; Load base address of String8
        ;JSR   PrintString
     
      	;JSR GetKey
        LDAA #$01
        STAA KEY_1
        LDAA KEY_1
        CMPA #$01
        LBEQ Prgm3
        CMPA #$02
        LBEQ Prgm4
        CMPA #$03
        LBEQ Prgm7
        CMPA #$04
        LBEQ Prgm9
        CMPA #$05
        LBEQ Prgm12
        
        JSR ClearDisp
        LDX #Error1
        JSR PrintString
        
        LDAA #$C0
        JSR Command
        
        LDX #Error2
        JSR PrintString
        
        JSR delay2
        
        BRA Redo
        

        ; Reset Variables
        ; Output Intro Strings to LCD
        ; JSR GetKey
        ; Check Input against Menu Options
        ; Jump to program
        ; or display error
        ; jump back to getkey   	  
    	  
    	  
    	  
;
;
;       Program 3 Code
;
;    	  
Prgm3:  BSET Exp3, $FF
        LDAA	#$FF	; Make PortAD Outbound
	      STAA	DDRAD
        LDAA  #$18  ;76543210
        STAA  DDRM
        LDX  #$0000
        STX  ONES4
        STX  TENS4
        LDAA #$00
        STAA PORTM
        STAA PORTAD

HERE3   LDAA	TABLE
	      STAA  PORTAD
	      BSET  PORTM, $08
	      NOP
	      NOP
	      BCLR  PORTM, $08
	      NOP
	      NOP
	      BSET  PORTM, $10
	      NOP
	      NOP
	      BCLR  PORTM, $10
	      LDAA  #$00 
	      
INCRMNT3: JSR GetKey
        LDAA KEY_1
        CMPA #$0A
        BEQ DOIT3
        CMPA #$0B
        BEQ HERE3
        CMPA #$0E
        LBEQ RESTART
        BRA INCRMNT3
        
DOIT3   LDX ONES4
        INX
        STX ONES4
        LDX #$000A
        CPX ONES4
        BNE UPDATE3
        LDX #$00
        STX ONES4
        LDX TENS4
        INX
        STX TENS4
        LDX #$000A
        CPX TENS4
        BNE UPDATE3
        LDX #$0000
        STX TENS4
        BRA UPDATE3
        
UPDATE3: BCLR PORTM, $FF
        LDX ONES4
        LDAA TABLE, X
        STAA PORTAD
        BSET PORTM, $08
        NOP
        NOP
        BCLR PORTM, $08
        NOP
        NOP
        LDX TENS4
        LDAA TABLE, X
        STAA PORTAD
        BSET PORTM, $10
        NOP
        NOP
        BCLR PORTM, $10
        NOP
        NOP
        JSR DELAY
PRESSED3: BRCLR PORTM, $04, PRESSED3
        JSR DELAY
        JSR DELAY
        LBRA INCRMNT3        
;
;
;       End Program 3 Code
;
;       Program 4 Code
;
;
Prgm4   MOVB #$00, FLAG1
    	  MOVB #3, TIMETEN
    	  MOVB #6, TIMEONE
      	LDAA  #$FF      ; Make PortT Outbound
      	STAA  DDRAD
      	LDAA  #$18      ; Make PortM pins 1 and 2 Outbound
      	STAA  DDRM
      	BSET Exp4, $FF
      	     
; 
; Initial Reset Location
;

        JSR UPDATE4
Rpt4    JSR GetKey
        LDAA KEY_1
        CMPA #$0A
        BEQ StartStop
        CMPA #$0B
        BEQ SetTo24
        CMPA #$0E
        LBEQ RESTART
        BRA Rpt4

StartStop
        COM FLAG1
        RTS
        
SetTo24
        MOVB #3, TIMETEN
        MOVB #6, TIMEONE
        RTS
        
 
Check4: LDD #MAXCOUNT
        STD COUNTP4
HERE4:  BRCLR FLAG1, $01, HERE4
        LDD COUNTP4
        BNE HERE4a
        JSR UPDATE4
        JSR DONEYET
HERE4a  RTS
        
        
UPDATE4:LDY TIMEONE
        BEQ RESET1
BACK0:  DEY
        STY TIMEONE
        JSR ONES
        JSR TEN
        RTS
        
RESET1: LDY TIMETEN
        DEY
        STY TIMETEN
        LDY #$000A
        BRA BACK0
        
DONEYET:LDY TIMETEN
        BEQ DONEONE
BACK1:  RTS
        
DONEONE:LDY TIMEONE
        BNE BACK1
        JSR FLASH
        
ONES:   LDY TIMEONE
        LDAA TABLE, Y
        STAA PORTAD
        BSET PORTM, $08
        NOP
        NOP
        BCLR PORTM, $08
        RTS
        
TEN:    LDY TIMETEN
        LDAA TABLE, Y
        STAA PORTAD
        BSET PORTM, $10
        NOP
        NOP
        BCLR PORTM, $10
        RTS        
        
FLASH   BCLR  PortAD, $FF  ; Clears out PortT  
        JSR   OPENB       ; Opens both M1 and M2 for Latch Enable   
        JSR   DELAY       ; Delays the program for one second
        
        BSET  PortAD, $3F  ; Sets the value $7E in portT 
        JSR   OPENB       ; Opens both M1 and M2 for Latch Enable   
        JSR   DELAY       ; Delays the program for one second
        
        BRA   FLASH      ; Branch to "flashy" for infinite loop
;
; Open both ports
;    
OPENB   BSET  PortM, $18  ; Set Bits of PortM to 11
        NOP
        NOP
        BCLR  PortM, $FF  ; Clear all the bits of PortM  
        NOP
        RTS

;
;
;       End Program 4 Code
;
;       Program 7 Code     ----------------REDO DISPLAY CODE TO USE OLD OUTPUT TO LEDS-------------------
;
;
Prgm7   BSET Exp7, $FF
        LDD #$00
        STD PIN          ; Set PIN to 0000
        STD PIN+2
        STD INPUT        ; Set INPUT to 0000
        STD INPUT+2
        STAA PINSET      ; Set PINSET to FALSE
        STAA KEY         ; Set KEY to 00
        STAA OUT         ; Set OUT to 00
        STAA SHOW        ; Set SHOW to 00
        STAA SPIB       ; Set SPI Baud Rate to Eclock/2
        STAA MODE        ; Set MODE to LOCKED
        LDAA #$00
        STAA MODE+1
        LDAA #$12        ; Set SHOW to off
        STAA SHOW+1
        LDAA #$0F        ; Set PortT to (off/on)
        STAA DDRT
        LDAA #$50
        STAA SPCR1      ; Initialize SPI
        LDAA #$09
        STAA SPCR2
        LDAA #$07
        STAA DDRM        ; Set PortM to output on bottom 3 pins
        JSR DIGIT        ; Update Displays
        JSR STATUS
      
L0:     JSR GetKey              ; Get Key press
        BRCLR PINSET, $01, L0   ; Wait for Program to occur
        LDAA KEY                ; Load key
        CMPA #$09               ; If 0A-FF
        BHI L0                  ; Get another key (Related routine already ran)
        LDAA INPUT+1            ; Shift Input
        STAA INPUT
        LDAA INPUT+2
        STAA INPUT+1
        LDAA INPUT+3
        STAA INPUT+2
        LDAA KEY                ; Add Key press to end of Input
        STAA INPUT+3
        JSR ALT                ; Toggle Arbitrary Image
        BRA L0                  ; Loop
ENTER:  BRCLR PINSET, $01, RET0     ; If PIN hasn't been set, rts
        LDD PIN                     ; Load PIN0/1
        CPD INPUT                   ; Check against INPUT0/1
        BNE RET0                    ; If unequal, rts
        LDD PIN+2                   ; Load PIN2/3
        CPD INPUT+2                 ; Check against INPUT2/3
        BNE RET0                    ; If unequal, rts
        LDAA #$01                   ; Set MODE to OPEN
        STAA MODE+1
        LDAA #$00
        STAA MODE
        JSR STATUS                  ; Update STATUS Display
RET0:   LDD #$0000                  ; Clear INPUT
        STD INPUT
        STD INPUT+2
        RTS                         ; Return to calling routine
LOCK:   LDAA #$00                   ; Set MODE to LOCKED
        STAA MODE
        STAA MODE+1
        JSR STATUS                  ; Update STATUS Display
        LDD #$0000
        STD INPUT                   ; Clear INPUT
        STD INPUT+2
        RTS                         ; Return to calling routine
PROGRAM:LDY #0002                   ; Set MODE to PROGRAM
        STY MODE
        JSR STATUS                  ; Update STATUS Display
        JSR GetKey                  ; Get a Numerical Key Press
        LDAA KEY
        STAA INPUT                  ; Store in INPUT
        STAA SHOW+1                 ; Store in SHOW
        JSR DIGIT                   ; Update Bottom Display
        JSR GetKey                  ; Get a Numerical Key Press
        LDAA KEY
        STAA INPUT+1                ; Store in INPUT
        STAA SHOW+1                 ; Store in SHOW
        JSR DIGIT                   ; Update Bottom Display
        JSR GetKey                  ; Get a Numerical Key Press
        LDAA KEY                    
        STAA INPUT+2                ; Store in INPUT
        STAA SHOW+1                 ; Store in SHOW
        JSR DIGIT                   ; Update Bottom Display
        JSR GetKey                  ; Get a Numerical Key Press
        LDAA KEY
        STAA INPUT+3                ; Store in INPUT
        STAA SHOW+1                 ; Store in SHOW
        JSR DIGIT                   ; Update Bottom Display
        LDD PCode
        CPD INPUT                   ; Check INPUT against secret PCode
        BNE RET1
        LDD PCode+2
        CPD INPUT+2
        BNE RET1                    ; If unequal, rts
        LDAA #$0E
        STAA SHOW+1                 ; Store 'E' in SHOW (Enter)
        JSR DIGIT                   ; Update Bottom Display
        JSR GetKey                  ; Get a Numerical Input
        LDAA KEY
        STAA PIN                    ; Store in PIN
        STAA SHOW+1
        JSR DIGIT                   ; Store in SHOW and update Bottom Display
        JSR GetKey                  ; Get a Numerical Input
        LDAA KEY
        STAA PIN+1                  ; Store in PIN
        STAA SHOW+1
        JSR DIGIT                   ; Store in SHOW and update display
        JSR GetKey
        LDAA KEY                    ; Get a Numerical Input
        STAA PIN+2                  ; Store in PIN
        STAA SHOW+1
        JSR DIGIT                   ; Store in SHOW and update display
        JSR GetKey                  ; Get a Numerical Input
        LDAA KEY
        STAA PIN+3                  ; Store in PIN
        STAA SHOW+1                 ; STore in SHOW and update display
        JSR DIGIT
        COM PINSET                  ; Complement PINSET boolean
RET1:   LDD #$0000
        STD INPUT                   ; Clear INPUT
        STD INPUT+2
        STD MODE                    ; Set MODE to LOCKED
        JSR STATUS                  ; Update display
        RTS                         ; Return to calling routine
CLEAR:  LDD #$0000                  ; Clear INPUT
        STD INPUT
        STD INPUT+2
        RTS                         ; Return to calling routine
        
ALT:    LDAA OUT                    ; Check OUT against one of two values
        CMPA #$10
        BNE ALT1                    ; If not one, then set it to that one
        LDAA #$11                   ; Otherwise set it to the other
        STAA OUT                   ;
        STAA SHOW+1                ;  _
        LDAA #$00                  ; |_|.
        STAA SHOW                  ; Update display
        JSR DIGIT
        RTS
        
ALT1:   LDAA #$10                  ;  _
        STAA OUT                   ; |_|
        STAA SHOW+1                ;    .
        LDAA #$00
        STAA SHOW                  ; Update display
        JSR DIGIT
        RTS
        
;
; Updates LED dispaly for the DIGIT display
;
DIGIT:  LDY SHOW              ; Load Reg. Y with ONE
        LDAA TABLE, Y        ; Load Acc. A with offset TABLE value
        BRCLR SPSR, $20, *  ; Check for write-permission      
        STAA SPDR           ; Output LED value on Serial Pin
        BRCLR SPSR, $80, *  ; Check for transfer complete
        LDAA SPDR           ; Clear flags
        BSET PORTM, $04      ; Enable Latch (SIPO)
        NOP
        NOP
        BSET PORTM, $01      ; Enable Latch (Latch)
        NOP
        NOP
        BCLR PORTM, $05      ; Disable Latch
        RTS                  ; Return to calling routine
;
; Updates LED display for STATUS display
;        
STATUS: LDY MODE           ; Load Reg. Y with TEN
        LDAA TABLE2, Y       ; Load Acc. A with offset TABLE value
        BRCLR SPSR, $20, *  ; Check for write-permission      
        STAA SPDR           ; Store LED value on PortT
        BRCLR SPSR, $80, *  ; Check for transfer complete
        LDAA SPDR           ; Clear flags
        BSET PORTM, $04      ; Enable Latch (SIPO)
        NOP
        NOP
        BSET PORTM, $02      ; Enable Latch (Latch)
        NOP
        NOP
        BCLR PORTM, $06      ; Disable Latch
        RTS                  ; Return to calling routine
;
;
;       End Program 7 Code
;                                ----------------------------------------------------
;       Program 9 Code
;                  =========== Check Input Implementation ===============
;
Prgm9
    	  LDAA  #$0F	          ; Make PortT Bits 7-4 output
    	  STAA  DDRT
    	  LDAA  #$22
    	  STAA  SPIB	          ; SPI clocks a 1/24 of E-Clock
        MOVB  #$3F, DDRM      ; Setup PortM data direction 
;
; Setup for Master, enable, high speed SPI, and Built-in Timer
;
    	  LDAA  #$50
        STAA  SPCR1
    	  LDAA  #$00
    	  STAA  SPCR2
    	  LDAA  #$80            
    	  STAA  TSCR1
;
; Initialize Variables to $00
;
        BCLR  PRINT, $FF   
        BCLR  KEY,   $FF   
        BCLR  KEY_1, $FF
      	BCLR  GEN,   $FF
      	BCLR  FANS,  $FF
      	BCLR  SOLU,  $FF
      	BCLR  SOLU_L,$FF    	    
;
; Initialize the LCD Display
;
        LDAA  #00
        BSET  PortM, RCK    ; Set RCK to Idle HIGH

        JSR   InitLCD     	; Initialize the LCD
        
;
; User Interface
;
Loop0	  LDX   #String1       	; Load base address of String1
        JSR   PrintString

    	  LDAA  #$C0	         	; First line is done jump to line 2
        JSR	  Command

    	  LDX   #String2    	    ; Load base address of String2
        JSR   PrintString
     
     	  JSR	  delay2	        ; Let's display the message a while 
	   
	      JSR   BlinkDisp         ; Blink the display 4 times
	   
Begin   JSR   ClearDisp         ; Clear the display
    	
    	  LDX   #String3    	    ; Load base address of String3
        JSR   PrintString

    	  LDAA  #$C0	    	    ; First line is done jump to line 2
        JSR	  Command

    	  LDX   #String4    	    ; Load base address of String4
        JSR   PrintString
     
     	  JSR	  delay2	        ; Let's display the message a while  

        JSR   ShiftSecondLine   ; Shift the second line to left
        
        LDX   #String5    	    ; Load base address of String5
        JSR   PrintString
     
     	  JSR	  delay2	        ; Let's display the message a while 

        JSR   ShiftSecondLine
        
        LDX   #String6       	; Load base address of String6
        JSR   PrintString
     
     	  JSR	  delay2	        ; Let's display the message a while  
        
        
        JSR   ShiftSecondLine
        
        LDX   #String7       	; Load base address of String7
        JSR   PrintString
     
     	  JSR	  delay2	        ; Let's display the message a while  
        
        
        JSR   ShiftSecondLine
        
        LDX   #String8       	; Load base address of String8
        JSR   PrintString
     
      	JSR	  delay2	        ; Let's display the message a while  

 	 	
Select 	BCLR  GEN, $FF          ; Clear the GEN variable  
        JSR   GetKey            ; Get the Keypad input
    	
        JSR   ClearDisp         ; Clear the Display
            	
   	    LDX   #Strin13       	; Load base address of String13
        JSR   PrintString 	
    	
       	LDAA  #$C0	        	; Jump to line 2
        JSR	  Command
   	
        JSR   Method            ; Determine what arithmetic to use
        nop
        nop
        BRSET GEN, $FF, Select  ; If a wrong key is pressed, try again
      	
        LDAA  #$3D              ; Print the "=" sign
    	  JSR   Print
    	
    	  JSR   CheckAns          ; Chech if the Answer is correct or not
    	
        JMP   Begin    	        ; Start Over
;        
; =====================================================================================
;
; SubRoutines      
;
; Print Digit1
;       	
PDig1   LDAA  DIGIT1            ; Load Digit1 on Accl A
        BMI   PrintNeg1         ; Branch if the MSB is set, hence the number is negative
        JSR   AconvP            ; Convert the value of Accl A to Ascii and Print 
        JMP   con1
PrintNeg1
        LDAA  #$2D              
        JSR   Print             ; Print the "-" sign if negative
        LDAA  DIGIT1            ; Load Digit1 on Accl A
        COMA                    ; Get Two's compliment 
        INCA
        JSR   AconvP            ; Convert the value of Accl A to Ascii and Print
con1    RTS 
;
; Print Digit2
;
PDig2   LDAA  DIGIT2            ; Load Digit2 on Accl A
    	  BMI   PrintNeg2         ; Branch if the MSB is set, hence the number is negative
        JSR   AconvP            ; Convert the value of Accl A to Ascii and Print
        JMP   con2    
PrintNeg2
        LDAA  #$2D              ; Print the "-" sign if negative
        JSR   Print             ; Load Digit2 on Accl A
        LDAA  DIGIT2            ; Get Two's compliment 
        COMA
        INCA
        JSR   AconvP            ; Convert the value of Accl A to Ascii and Print
con2    RTS 
;
; Choose and do the Arithmetic Method
;
Method: JSR   RanNum            ; Generate Random Numbers
        LDAA  KEY_1             ; Load KEY_1 on Accl A
        CMPA  #$01              ; Compare Accl A to hex $01
        BEQ   Add               ; Branch to Add if Key 1 is pressed
        CMPA  #$02
        BEQ   Sub               ; Branch to Sub if Key 2 is pressed
        CMPA  #$03
        BEQ   Mult              ; Branch to Mult if Key 3 is pressed
        CMPA  #$04 
        BEQ   Divi              ; Branch to Divi if Key 4 is pressed
        
        BSET  GEN, $FF          ; Set GEN if some other key has been pressed
        JSR   ShiftSecondLine   ; Shift line to to the left
        LDX   #Strin12          ; Load base address of Strin12
        JSR   PrintString       ; Print the String
        RTS
;                   
; Add the Numbers   
;            	
Add:    LDAA  DIGIT1            ; Load Digit1 on Accl A
        ADDA  DIGIT2            ; Add Accl A and Digit2
        STAA  SOLU_L            ; Store Accl A to Low bits of SOL
        JSR   PDig1             ; Print Digit1
     	  LDAA  #$2B              ; Print the "+" sign
    	  JSR   Print
        JSR   PDig2	            ; Print Digit2
        RTS
;
; Subtract the Numbers
;
Sub:    LDAA  DIGIT1            ; Load Digit1 on Accl A
        SUBA  DIGIT2            ; Sub Digit2 from Accl A
        STAA  SOLU_L            ; Store Accl A to Low bits of SOL
        JSR   PDig1	            ; Print Digit1
    	  LDAA  #$2D              ; Print the "-" sign
    	  JSR   Print
    	  JSR   PDig2             ; Print Digit2
        RTS
;
; Multiply the Numbers
;
Mult:   LDAA  DIGIT1            ; Load Digit1 on Accl A
        LDAB  DIGIT2            ; Load Digit2 on Accl B
        MUL                     ; Multiply A and B
        STD   SOLU              ; Store D to SOLU
        JSR   PDig1             ; Print Digit1
        LDAA  #$2A              ; Print the "*" sign
    	  JSR   Print	
    	  JSR   PDig2             ; Print Digit2
        RTS
;
; Divide the Numbers
;
Divi:   LDAA  DIGIT1            ; Load Digit1 on Accl A
        LDAB  DIGIT2            ; Load Digit2 on Accl B
        IDIV                    ; Divide
		    STD   SOLU              ; Store D to SOLU
        JSR   PDig2             ; Print Digit1
       	LDAA  #$2F              ; Print the "/" sign
    	  JSR   Print
    	  JSR   PDig2             ; Print Digit2
        RTS  
;
; Check if the Answer is Correct of not
;      
CheckAns: 
        MOVB  #$00, FANS        ; Clear FANS 
        MOVB  #$00, NEGCH       ; Clear NEGCH
V0      JSR   GetKey            ; Get the value of Key pressed

        LDAA  KEY_1             ; Load KEY_1 on Accl A
        CMPA  #$0C              ; Branch to check Answer if A = $0C
        BEQ   V1
        CMPA  #$0B              ; Branch to negative input if A = $0B
        BEQ   V2
        CMPA  #$0A              ; If Any other key than Numbers, E and F, 
        BGE   V0                ; try again
        
        LDAA  FANS              ; Load FANS to Accl A
        LDAB  #10               ; Load #10 on Accl B
        MUL                     ; Multiply A and B
        STAB  FANS              ; Store B back to FANS to get the tenth place
                                ; of the original value in FANS
        
        LDAA  KEY_1             ; Load KEY_1 on Accl A
        ADDA  FANS              ; Add Accl A and FANS
        STAA  FANS              ; Store A back to FANS
        
        LDAA  KEY_1             ; Load KEY_1 on Accl A 
        JSR   AconvP            ; Convert the value to Ascii and Print
        JMP   V0                ; Go back to V0
        
V2      MOVB  #$FF, NEGCH       ; Set NEGCH
        LDAA  #$2D              ; Print the "-" Sign
        JSR   Print   
        JMP   V0                ; Go Back to V0
                   	
V1      LDAA  FANS              ; Load FANS on Accl A
        BRCLR NEGCH, $FF, PosSol; Branch if NEGCH is Clear, the solution is Positive,
        COMA                    ; Two's Compliment A
        INCA
PosSol  CMPA  SOLU_L            ; Compare A to the Low bits of SOLU
        BNE   IncAns            ; If not equal, the answer is incorrect
        
       	LDAA  #$C0	        	; Jump to line 2
	      JSR	  Command
    	  LDX   #Strin10    	    ; Load base address of Strin10
        JSR   PrintString    	; Print the String
        JSR   delay2
        JSR   BlinkDisp         ; Blink the Display
        RTS

IncAns  LDAA  #$C0	        	; Jump to line 2
        JSR	  Command
      	LDX   #Strin11       	; Load base address of Strin11
        JSR   PrintString       ; Print the String
        JSR   delay2
        JSR   BlinkDisp         ; Blink the Display
        RTS
;
; Random Number Generator
;
RanNum  LDD TCNT
Loop1   CMPB #10
        BLO  Save1
        SUBB #10
        BRA  Loop1
Save1   STAB DIGIT1
Loop2   CMPA #10
        BLO  Save2
        SUBA #10
        BRA  Loop2
Save2   STAA DIGIT2      	
;
; Initialize the LCD 
;
InitLCD	JSR	  delay3		
    	  LDAA  #$30	     	; Could be $38 too.
    	  JSR	  Command
    	  JSR	  delay3		; need extra delay at startup
    	  LDAA  #$30			; see data sheet. This is way
    	  JSR	  Command		; too much delay
    	  JSR	  delay3
    	  LDAA  #$30
    	  JSR	  Command
    	  LDAA  #$38		    ; Use 8 - words (command or data) and
    	  JSR	  Command	    ; and both lines of the LCD
    	  LDAA  #$0C		    ; Turn on the display
    	  JSR	  Command
    	  LDAA  #$01		    ; clear the display and put the cursor
    	  JSR	  Command	    ; in home position (DD RAM address 00)
    	  JSR   delay			; clear command needs more time
    	  JSR	  delay			; to execute
    	  JSR	  delay
    	  RTS
;
; Convert a hex to Ascii and Print the number
;    	
AconvP  LDAB  #$30          ; Load $30 on Accl B
        ABA                 ; Add A and B 
    	  JSR   Print         ; Print Accl A
    	  RTS   	
;
; Print or Command
;
Print   BSET  PRINT, $FF
        JMP   spi_a        
Command	BCLR  PRINT, $FF
spi_a:	BRCLR SPSR,  $20,spi_a    ; Wait for register empty flag (SPIEF)
;   	LDAB  SPDR		    	  ; Read the SPI data register. This clears the flag automatically
	      STAA  SPDR		    	  ; Output command  via SPI to SIPO
CKFLG1  BRCLR SPSR,  $80, CKFLG1  ; Wait for SPI Flag
	      LDAA  SPDR
        NOP                       ; Wait
        BCLR  PortM, RCK          ; Pulse RCK
        NOP
    	  NOP
    	  NOP
        BSET  PortM, RCK          ; Command now available for LCD
        BRCLR PRINT, $FF, ComL
        BSET  PortM, RS
        JMP   F1
ComL	  BCLR  PortM, RS		      ; RS = 0 for commands
F1    	NOP
    	  NOP			              ; Probably do not need to wait
    	  NOP			              ; but we will, just in case ...
    	  BSET  PortM, ENABLE	      ; Fire ENABLE
    	  NOP			              ; Maybe we will wait here too ...
    	  NOP
    	  NOP
    	  NOP
    	  BCLR  PortM, ENABLE	 	  ; ENABLE off
    	  JSR   delay
    	  RTS
;
;  Blink the Display 4 times
; 
BlinkDisp
        MOVB  #$04,	COUNT       ; Initialize a counter
A4	    LDAA  #$08	          	; Turn off display but keep memory values
    	  JSR	  Command	
    	  JSR   delay3
    	  LDAA  #$0C	         	; Turn on display. So, we Blinked!
    	  JSR	  Command
    	  JSR	  delay3
    	  DEC	  COUNT
    	  BNE	  A4	            ; Blink 4 times
    	  RTS 
;
; Clear the Display
;
ClearDisp    	
     	  LDAA  #$01             	; Clear the display and send cursor home
    	  JSR	  Command
    	  JSR	  delay	            ; Clear needs more time so 3 delays		
    	  JSR	  delay
    	  JSR	  delay    	
        RTS
;
; Print the String at the address loaded at X
; 
PrintString    	
Loop7	  LDAA  0,X	        	; Load a character into ACMA
    	  BEQ	  Done7	            ; quit when if last character is $00 
    	  JSR   Print	            ; and output the character
    	  INX	                    ; let's go get the next character
    	  BRA	  Loop7	
Done7   RTS     
;
; Shift the second line to the left
;
ShiftSecondLine
        LDAA  #$C0	        	; Jump to line 2
        JSR	  Command
        LDAA  #$0C              ; Shift the Line to the left
        JSR   Command
        JSR   delay2            ; Delay it by some 
        RTS
;
;
;       End Program 9 Code
;                              ---------------------------------------------------
;       Program 12 Code
;
;
Prgm12
        LDAA  #$22
    	  STAA  SPIB	          ; SPI clocks a 1/24 of E-Clock
        MOVB  #$3F, DDRM      ; Setup PortM data direction 
;
; Setup for Master, enable, high speed SPI, and Built-in Timer
;
    	  LDAA  #$50
        STAA  SPCR1
    	  LDAA  #$00
    	  STAA  SPCR2

        BSET Exp12, $FF
        LDAA  #00
        BSET  PortM, RCK    ; Set RCK to Idle HIGH

        JSR   InitLCD     	; Initialize the LCD
 
    	  LDAA #$FF
    	  STAA Tset       ; Tset = 00 -> Set Time Enabled
    	                  ; Tset = FF -> Set Time Disabled
    	  LDAA #$00
    	  STAA Init       ; Init = 00 -> Start-up Initialization
    	                  ; Init = FF -> Regular Operation
    	  STAA sCNT       ; Holds count for a second (4 interrupts = 1 sec)
    	  STAA mCNT       ; Holds count for a minute (60 increments = 240 interrupts = 1 min)
    	  STAA MinOne     ; Holds minute (ones digit)
    	  STAA MinTen     ; Holds minute (tens digit)
    	  STAA Form       ; Form = 00 -> 12hr Format
    	                  ; Form = FF -> 24hr Format
    	  STAA HourOne    ; Holds hour, starts at 12a
    	  STAA HourTen
    	  STAA Speed      ; Speed = 00 -> Regular Intervals
    	                  ; Speed = FF -> 120x Intervals
    	  
    	  STAA EnterOne   ; Boolean for number entry
    	  STAA EnterTwo   ; Boolean for number entry
    	  STAA EnterThree ; Boolean for number entry
    	  STAA EnterFour  ; Boolean for number entry
    	  STAA ColonOn    ; Boolean for colon omission
    	  STAA PRINT
    	  
      	LDAA  #$0F      ; Make PortT Outbound on the lower 4 pins
      	STAA  DDRT
      	     
; 
; Initial Reset Location
;


Loop
        JSR GetKey       ; Continuously get key
        LDAA KEY_1
        JSR KeyPress
        BRA Loop


;
; Update Display
;
UpDisp: BRCLR Form, $FF, AMPM  ;Check format (12/24)
        JSR ClearDisp          ; if 24, clear display
Back    LDAA HourTen           ; load tens digit of hour
        CMPA #$00              ; if 0, omit
        BEQ Jump               ; jump to omit
        JSR AconvP             ; else display
        BRA Next               ; jump to next digit
Jump    LDX #NoColon           ; load space
        JSR PrintString        ; print space
Next    LDAA HourOne           ; load ones digit of hour
        JSR AconvP             ; display
        BRSET ColonOn, $FF, Space   ; if no display colon, jump
        LDX #Colon             ; else load colon
        JSR PrintString        ; print coon
        BRA Skip               ; jump to min
Space   LDX #NoColon           ; load space
        JSR PrintString        ; print space
Skip    LDAA MinTen            ; load tens digit of min
        JSR AconvP             ; display
        LDAA MinOne            ; load ones digit of min
        JSR AconvP             ; display
        RTS                    ; return

AMPM                           ; if 12 hour mode
        JSR ClearDisp          ; clear display
        LDAA HourTen           ; load tens digit of hour
        CMPA #$00              ; if 0
        BEQ HourZero           ; branch to related method
        CMPA #$01              ; if 1
        BEQ HourNext           ; branch to related method
        CMPA #$02              ; if 2
        LBEQ HourTwo           ; branch to related method
        
HourZero                       ; if 0
        LDAB HourOne           ; load ones digit of hour
        CMPB #$00              ; compare to 0
        BEQ Midnight           ; if 0, midnight
        LDX #NoColon           ; otherwise load space
        JSR PrintString        ; print space
        LDAA HourOne           ; load ones digit
        JSR AconvP             ; print digit
Back2   BRSET ColonOn, $FF, Space2   ; check colon
        LDX #Colon             ; load colon
        JSR PrintString        ; print colon
        BRA Skip2              ; jump
Space2  LDX #NoColon           ; load space
        JSR PrintString        ; print space
Skip2   LDAA MinTen            ; load tens of min
        JSR AconvP             ; print
        LDAA MinOne            ; load ones of min
        JSR AconvP             ; print
        LDX #NotPM             ; load "am"
        JSR PrintString        ; print
        RTS                    ; return
        
Midnight                       ; if midnight
        LDAA #$01              ; load 1
        JSR AconvP             ; print
        LDAA #$02              ; load 2
        JSR AconvP             ; print
        BRA Back2              ; print rest of time

BackUp                         ; if am, but >9
        LDAA HourTen           ; load hour
        JSR AconvP             ; print
        LDAA HourOne           ; load hour
        JSR AconvP             ; print
        BRA Back2              ; print rest of time

        
HourNext                       ; if 1
        LDAB HourOne           ; load ones digit of hour
        CMPB #$2               ; compare to 2
        BLO BackUp             ; if less than, jump
        BEQ Noon               ; if equal, noon
        LDX #NoColon           ; load space
        JSR PrintString        ; print space
        LDAA HourOne           ; load hour
        DECA                   ; decrement
        DECA                   ; by 2
        JSR AconvP             ; print
Back3   BRSET ColonOn, $FF, Space3  ; check colon
        LDX #Colon             ; load colon
        JSR PrintString        ; print colon
        BRA Skip3              ; jump
Space3  LDX #NoColon           ; load space
        JSR PrintString        ; print space
Skip3   LDAA MinTen            ; load min
        JSR AconvP             ; print
        LDAA MinOne            ; load min
        JSR AconvP             ; print
        LDX #NotAM             ; load "pm"
        JSR PrintString        ; print
        RTS                    ; return
        
Noon                           ; if noon
        LDAA #$01              ; load 1
        JSR AconvP             ; print
        LDAA #$02              ; load 2
        JSR AconvP             ; print
        BRA Back3              ; print rest of time
        
HourTwo                        ; if 2
        LDAB HourOne           ; load ones hour
        CMPB #$02              ; compare to 2
        BLO Evening            ; if less than 2, evening
        LDAA #$01              ; load 1
        JSR AconvP             ; print
        LDAA HourOne           ; load hour
        DECA                   ; decrement by 2
        DECA                   ;
        JSR AconvP             ; print
        BRA Back3              ; print rest of time
        
Evening                        ; if evening
        LDX #NoColon           ; load space
        JSR PrintString        ; print space
        LDAA HourOne           ; load hour
        ADDA #$08              ; inc by 8
        JSR AconvP             ; print
        BRA Back3              ; print rest of time

KeyPress
        CMPA #$0A     ; A -> Format
        BEQ Format
        CMPA #$0B     ; B -> Speed
        BEQ ChangeSpd
        CMPA #$0F     ; F -> Enter Time
        BEQ StartEnterTime
        CMPA #$0E
        LBEQ RESTART
        BRSET Tset, $FF, NoEntry  ; Test for entry access
        BRA EnterNumber
NoEntry RTS                    ; return

EnterNumber
        BRSET EnterFour, $FF, EntryDone   ; if 4 # entered, no more entry
        BRSET EnterThree, $FF, EntryFour  ; if 3 # entered, enter ones min
        BRSET EnterTwo, $FF, EntryThree   ; if 2 # entered, enter tens min
        BRSET EnterOne, $FF, EntryTwo     ; if 1 # entered, enter ones hour
EntryOne                                  ; else enter tens hour
        CMPA #$02                         ; make sure between 0-2
        BHI Foul
        STAA HourTen                      ; store
        MOVB #$FF, EnterOne               ; toggle
Foul    RTS

EntryTwo
        STAA HourOne                      ; store
        MOVB #$FF, EnterTwo               ; toggle
        RTS
                     
EntryThree        
        CMPA #$06                         ;make sure between 0-6
        BHI Foul2                         
        STAA MinTen                        ; store
        MOVB #$FF, EnterThree             ; toggle
Foul2   RTS

EntryFour
        STAA MinOne                     ; store
        MOVB #$FF, EnterFour            ; toggle
EntryDone
        LDAA #$00
        STAA EnterOne
        STAA EnterTwo
        STAA EnterThree
        STAA EnterFour
        RTS

Format
        BRSET Form, $FF, Twelve         ; toggle format (12/24)
        MOVB #$FF, Form
        RTS
Twelve  MOVB #$00, Form
        RTS
        
ChangeSpd
        BRSET Speed, $FF, Slow          ; toggle speed (1x/120x)
        MOVB #$FF, Speed
        RTS
Slow    MOVB #$00, Speed
        RTS
        
StartEnterTime                          ; toggle run mode (run/enter time)
        BRSET Tset, $FF, AllowTime
        MOVB #$FF, Tset
        RTS
AllowTime
        MOVB #$00, Tset
        MOVB #$FF, Init
        RTS

;    	
; Get the Value of the Key pressed
; 
Check4a:JMP Check4
GetKey: BCLR KEY, $FF         ; Clear variable KEY contents
        BCLR KEY_1, $FF
        LDAA #$0F          ; Load Acc. A with $F0
        STAA PORTT         ; Output high on all rows
        BRSET PORTT, $80, *; Check Column 1 for pressed key
        NOP
        BRSET PORTT, $40, *; Check Column 2 for pressed key
        NOP
        BRSET PORTT, $20, *; Check Column 3 for pressed key
        NOP
        BRSET PORTT, $10, *; Check Column 4 for pressed key
GKEY:   BRSET Exp4, $FF, Check4a
Pcheck  LDAA #$08          ; Once all keys are released, load Acc. A with $80
        STAA PORTT         ; Output high on row 1
        JSR sdelay
        BRSET PORTT, $80, KEY1    ;If high, key 1 was pressed
        NOP
        BRSET PORTT, $40, KEY2    ;If high, key 2 was pressed
        NOP
        BRSET PORTT, $20, KEY3    ;If high, key 3 was pressed
        NOP
        BRSET PORTT, $10, KEYA    ;If high, key A was pressed
        LDAA #$04          ; No key press yet, load Acc. A with $40
        STAA PORTT         ; Output high on row 2
        JSR sdelay
        BRSET PORTT, $80, KEY4    ;If high, key 4 was pressed
        NOP
        BRSET PORTT, $40, KEY5    ;If high, key 5 was pressed
        NOP
        BRSET PORTT, $20, KEY6    ;If high, key 6 was pressed
        NOP
        BRSET PORTT, $10, KEYB    ;If high, key B was pressed
        LDAA #$02          ; No key press yet, load Acc. A with $20
        STAA PORTT         ; Output high on row 3
        JSR sdelay
        BRSET PORTT, $80, KEY7    ;If high, key 7 was pressed
        NOP
        BRSET PORTT, $40, KEY8    ;If high, key 8 was pressed
        NOP
        BRSET PORTT, $20, KEY9    ;If high, key 9 was pressed
        NOP
        BRSET PORTT, $10, KEYC    ;If high, key C was pressed
        LDAA #$01          ; No key press yet, load Acc. A with $10
        STAA PORTT         ; Output high on row 4
        JSR sdelay
        BRSET PORTT, $80, KEY0    ;If high, key 0 was pressed
        BRSET PORTT, $40, KEYF    ;If high, key F was pressed
        BRSET PORTT, $20, KEYE    ;If high, key E was pressed
        BRSET PORTT, $10, KEYD    ;If high, key D was pressed
        LBRA GKEY         ; No key press, check again 


;
; Set of labels to set KEY to the pressed key's value
;            OR to branch to a relevant routine
;        
KEY1:   BSET KEY_1, $01       ; Set KEY to 1
        RTS                 ; Return to GETKEY's calling routine
                      
KEY2:   BSET KEY_1, $02       ; Set KEY to 2
        RTS                 ; Return to GETKEY's calling routine

KEY3:   BSET KEY_1, $03       ; Set KEY to 3
        RTS                 ; Return to GETKEY's calling routine

KEYA:   BSET KEY_1, $0A       ; Set KEY to A
        RTS

KEY4:   BSET KEY_1, $04       ; Set KEY to 4
        RTS                 ; Return to GETKEY's calling routine

KEY5:   BSET KEY_1, $05       ; Set KEY to 5
        RTS                 ; Return to GETKEY's calling routine

KEY6:   BSET KEY_1, $06       ; Set KEY to 6
        RTS                 ; Return to GETKEY's calling routine

KEYB:   BSET KEY_1, $0B       ; Set KEY to B
        RTS

KEY7:   BSET KEY_1, $07       ; Set KEY to 7
        RTS                 ; Return to GETKEY's calling routine

KEY8:   BSET KEY_1, $08       ; Set KEY to 8
        RTS                 ; Return to GETKEY's calling routine

KEY9:   BSET KEY_1, $09       ; Set KEY to 9
        RTS                 ; Return to GETKEY's calling routine

KEYC:   BSET KEY_1, $0C       ; Set KEY to C
        RTS

KEY0:   BSET KEY_1, $00       ; Set KEY to 0
        RTS                 ; Return to GETKEY's calling routine
                      
KEYD:   BSET KEY, $0D       ; Set KEY to D
        RTS

KEYE:   BSET KEY, $0E       ; Set KEY to E
        RTS                 ; Return to GETKEY's calling routine

KEYF:   BSET KEY, $0F       ; Set KEY to F
        RTS                 ; Return to GETKEY's calling routine
;
; 



;
; Delay functions
;
delay   LDY	  #8000       	; Command Delay routine. Way to long. Overkill!
A2:	    DEY	            	; But we do need to wait for the LCD controller
	      BNE	  A2	        ; to do it's thing.  How much time is this
	      RTS                 ; anyway? 2.5 msec

delay2	LDY	  #$F000        ; Long Delay routine.  Adjust as needed. 
    	  PSHA		        ; Save ACMA (do we need to?)
A3:	    LDAA  #$4A          ; Makes the delay even longer! (Nested loop.)
AB: 	  DECA
    	  BNE	  AB          	; 
    	  DEY
    	  BNE	  A3          	; 
    	  PULA	        	; Get ACMA back
    	  RTS

delay3  LDAA  #$0F
AA6:	  LDY	  #$FFFF      	; Blink Delay routine. 
A6:	    DEY	            	; 
	      BNE	  A6
	      DECA
	      BNE	  AA6         	; 
	      RTS
	    
sdelay: PSHY
        LDY #15000   ; Loop counter = 15000 - 2 clock cycles
A0:     LBRN A0      ; 3 clock cycles \
        DEY          ; 1 clock cycles | 8 clock cycles in loop
        LBNE A0      ; 4 clock cycles / Time = 8*<Y>/(24*10**6) + 2 =
;                    ; [8X15000 + 2]/24000000 ~= 5msec
        PULY            
        RTS

DELAY 	PSHA			; Save accumulator A on the stack
	      LDY	#01		; We will repeat this subroutine 10 times
	      MOVB	#$90,TSCR1	; enable TCNT & fast flags clear
	      MOVB	#$07,TSCR2 	; configure prescale factor to 64
	      MOVB	#$01,TIOS	; enable OC0
	      LDD	TCNT		; Get current TCNT value
AGAIN	  ADDD	#18750		; start an output compare operation
	      STD	TC0		; with 100 ms time delay
WAIT	  BRCLR	TFLG1,$01,WAIT  ; Wait for TCNT to catch up
	      LDD	TC0		; Get the value in TC0
	      DBNE	Y,AGAIN		; 1 X 100ms = 100 ms
	      PULA			; Pull A
	      RTS
	      
SHORT_DELAY:
        LDAA #5   ; Outer Loop Counter ? 1 clock cycle
B3:     LDY #5000 ; Inside Loop Counter 2 clock cycles
B2:     LBRN B2    ; 3 clock cycles  \
        DEY        ; 1 clock cycle    | 8 clock cycles in loop
        LBNE B2    ; 4 clock cycles  /
        DECA       ; 1 clock cycle
        BNE B3     ; 3 clock cycles
        RTS        ; return from delay - 5 clock cycles	      

ISR_TC5:BRCLR Exp4, $FF, Check12
        LDD TC5
        ADDD #INCREMENT4
        STD TC5
        BRCLR FLAG1, $01, DONE4
        LDD COUNTP4
        SUBD #$0001
        STD COUNTP4
DONE4:  RTI

Check12:BRCLR Exp12, $FF, DONE4
        BRA ISR_TC5a
                      
Flash:  LDAA  #$08	          	; Turn off display but keep memory values
    	  JSR	  Command	
    	  JSR   delay3
    	  LDAA  #$0C	         	; Turn on display. So, we Blinked!
    	  JSR	  Command
    	  JSR	  delay3
    	  MOVB #$FF, Init
    	  RTI

helpDONE 
        RTI

ISR_TC5a:LDD TC5                   ; load counter
        BRSET Speed, $FF, Fast    ; check speed
        ADDD INCREMENT
        BRA Store                 ; inc counter
Fast:   ADDD FASTEMENT        
Store:  STD TC5                   ; store counter
        BRCLR Tset, $FF, helpDONE ; check for entry mode
        BRCLR Init, $FF, Flash    ; check for startup
        LDAA sCNT
        CMPA #$00                 ; keep track of interrupts
        BEQ Swap                  ; 3 = 1sec
        BRA Pass
Swap    BRSET ColonOn, $FF, Swit  ; toggle colon
        MOVB #$FF, ColonOn
        BRA Pass
Swit    MOVB #$00, ColonOn
Pass    LDAA sCNT
        INCA
        STAA sCNT
        CMPA #$03
        BNE DONE
        
        MOVB #$00, sCNT
        LDAA mCNT                 ; 60 mCNT = 1min
        INCA
        STAA mCNT
        CMPA #$3C
        BNE DONE
        
        MOVB #$00, mCNT
        LDAA MinOne               ; 60 min = 1hr
        INCA
        STAA MinOne
        CMPA #$0A
        BNE DONE
        
        MOVB #$00, MinOne
        LDAA MinTen
        INCA
        STAA MinTen
        CMPA #$06
        BNE DONE
        
        MOVB #$00, MinTen
        LDAA HourOne
        INCA
        STAA HourOne
        CMPA #$04
        BHS CheckHr
        CMPA #$0A
        BNE DONE
        
        MOVB #$00, HourOne
        LDAA HourTen
        INCA
        STAA HourTen
        BRA DONE
        
CheckHr:LDAA HourTen
        CMPA #$02                ; if hour = 24, reset to 00
        BNE DONE
        
        MOVB #$00, HourTen
        MOVB #$00, HourOne
        
DONE:   RTI







; Declare Constants
        ORG $5000
TABLE:  DC.B $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F, $77, $7F, $39, $3F, $79, $71, $63, $5C, $00
;Order:       0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F    o^   o.   off
MAXCOUNT:DC.W 500
INCREMENT4: DC.W 375
PCode   DC.B  $01, $02, $03, $05 ; Press 1235
TABLE2: DC.B $38, $3F, $73, $00
;Order:       L    O    P    off
String1	FCC	  "Welcome to Math "  
        DC.B  $00   
String2	FCC   "Flash Cards     "   
        DC.B  $00
String3 FCC   "Options:        "  
        DC.B  $00
String4 FCC   "Press the Key   "
        DC.B  $00
String5 FCC   "1.Addition      "
        DC.B  $00     
String6 FCC   "2.Subtraction   "
        DC.B  $00
String7 FCC   "3.Multiplication"
        DC.B  $00
String8 FCC   "4.Division      "
        DC.B  $00
Strin10 FCC   "That is correct!"
        DC.B  $00
Strin11 FCC   "Incorrect :/    "
        DC.B  $00
Strin12 FCC   "Invalid Option. "
        DC.B  $00
Strin13 FCC   "Question:       "
        DC.B  $00    	  
Colon   FCC ":"
        DC.B $00
        
NoColon FCC " "
        DC.B $00
        
NotPM   FCC "am"
        DC.B $00
        
NotAM   FCC "pm"
        DC.B $00    	  
INCREMENT: DC.W $EDA1 ; 45625 -> .25s at 128 prescale
FASTEMENT: DC.W $01FB ; 380 -> .25s/120 at 128 prescale    	  

Intro1  FCC   "Welcome To My"
        DC.B $00
        
Intro2  FCC   "Integrated Lab"
        DC.B $00
        
Intro3  FCC   "Choose Program"
        DC.B $00
     
Intro4  FCC   "1: Now Serving"
        DC.B $00
  
Intro5  FCC   "2: Shot Clock"
        DC.B $00
        
Intro6  FCC   "3: Combo Lock"
        DC.B $00
        
Intro7  FCC   "4: Flash Cards"
        DC.B $00
        
Intro8  FCC   "5: Clock"
        DC.B $00
        
Error1  FCC   "Bad Input"
        DC.B $00
        
Error2  FCC   "Try Again"
        DC.B $00        


; Define TC5 Interrupt Vector
    
        ORG $FFE4
        FDB ISR_TC5


; Define Power-On Reset Interrupt Vector

; AGAIN - OP CODES are at column 9 

        ORG $FFFE ; $FFFE, $FFFF = Power-On Reset Int. Vector Location
        FDB START ; Specify instruction to execute on power up

; End of Interrupt code
     
        END        ; (Optional) End of source code    	  