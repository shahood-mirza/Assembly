;**************************************************************
; By: Shahood Mirza
;****************************************************************
; There are 16 bytes of data in memory locations $0800 to 080F, 
; this program counts the number of 1's in these 16 bytes 
; and puts the result into $0812 using subroutines. 
;**************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data
StartAddr   EQU  $0800
Count       EQU  16

; variable/data section, For Testing purpose. 
            ORG StartAddr
TestData:   DC.B  32, 22, 1, 3, 4, 5, 1, 3, 1, 6, 9, 1, 1, 2, 2, 1 


; code section
            ORG   ROMStart
Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer
            CLI                   ; enable interrupts
            LDY   #Count          ; Load the count of the bytes in memory block.
            LDAB  #0              ; Initialize the AccB register to 0
            LDX   #StartAddr      ; Set index register as the starting address; 
mainLoop:
            BSR   Comp_Sub        ; Call subroutine to compare the data in Array and #1.   
            DEY                   ; Decrease Counter by 1 after each comparation.
            CPY   #0              ; Check if all the numbers are compared. 
            BNE   mainLoop        ; if Not, Continue
            STAB  $0812           ; Save the result to address $0812
            BRA   _Startup        ; If all the numbers are checked, return to start of the program

    
Comp_Sub:   LDAA  0, X           ; Load number into AccA register. 
            INX                  ; Increase X register for the next address. 
            CMPA  #1             ; Compare number of AccA with #1
            BEQ   IsOne          ; If result is #1, go to IsOne. 
            RTS                  ; return from Subroutine.
            
IsOne:      INCB                 ; Increase AccB if ncessary
            RTS
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
