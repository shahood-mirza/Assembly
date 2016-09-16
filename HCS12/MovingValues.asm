;**************************************************************
; By: Shahood Mirza
;****************************************************************
; this program that will moves the six predefined numbers 
; starting from "Array" to memory location starting 
; from "Destination" using the following subroutine:
;
; RAMStart   EQU  $400
; ROMStart   EQU  $8000
;
; ORG  RAMStart
; Array      	  DC.W  	23, 22, 21, 41, 19, 21
; Destination	  DS.W	6
;**************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
	    INCLUDE 'derivative.inc' 

; variable/data section, For Testing purpose. 
ROMStart    EQU  $8000

            ORG  RAMStart
Array      	  DC.W  23, 22, 21, 41, 19, 21
Destination	  DS.W	6

; code section
            ORG   ROMStart
Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer
            CLI                   ; enable interrupts
            LDAA  #6              ; Load the counter of the bytes to move as 6
            LDX   #Array          ; Set index register as the source address; 
            LDY   #Destination    ; Set index register as the destination address; 
mainLoop:
            BSR   Byte_Movement   ; Call subroutine to move date from source to destination.
            DECA                  ; Decrease the Counter after each movement. 
            CMPA  #0              ; Check if all the bytes are moved
            BNE   mainLoop        ; if Not, Continue
            BRA   _Startup        ; If all the numbers are checked, return to start of the program

    
Byte_Movement:   
            PSHA                  ; Save the AccA register, (Counter is in this register)
            LDD  2, X+            ; Load number into D register; then increase X to the next WORD address. 
            STD  2, Y+            ; Store the number from D register to destination, then increase Y to the next WORD address.
            PULA                  ; Restore the AccA register (The counter)
            RTS                   ; return from Subroutine.
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
