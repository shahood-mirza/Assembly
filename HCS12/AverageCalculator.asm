;**************************************************************
; By: Shahood Mirza
;****************************************************************
; this program will calculate the average of the six 
; predefined numbers starting from "Array" and save the result
; into variable "Average_6" using the following subroutine: 
;
;
; RAMStart   EQU  $400
; ROMStart   EQU  $8000
;
; ORG  RAMStart
;
; Average_6	  DS.W	1	
; Array      	  DC.W  	23, 22, 21, 41, 19, 21

;**************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
	    INCLUDE 'derivative.inc' 

; variable/data section, For Testing purpose. 
ROMStart    EQU  $8000

            ORG  RAMStart
Average_6   DS.W	  1	
Array       DC.W  	23, 22, 21, 41, 19, 21

Sum_Result  DS.W   1               ; Define this variable to save the sum of the six numbers in the Array.

; code section
            ORG   ROMStart
Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer
            CLI                   ; enable interrupts
            LDAA  #6              ; Load the counter of the bytes to move as 6
            LDX   #Array          ; Set index register as the source address; 
            MOVW  #0, Sum_Result  ; set the Sum_Result as 0. 
mainLoop:
            BSR   Calculate_Sum   ; Call subroutine to calculate the sum of the numbers. 
            DECA                  ; Decrease the counter by 1.
            CMPA  #0              ; Check if all the bytes are moved
            BNE   mainLoop        ; if Not, Continue
            
            LDD   Sum_Result      ; Load Sum_Result into D register. 
            LDX   #6              ; Load 6 into X register.
            IDIV                  ; Do D/Y division.
            STX   Average_6       ; Store the quotient into Average_6
            BRA   _Startup        ; If all the numbers are checked, return to start of the program

    
Calculate_Sum:   
            PSHA                 ; Save the AccA register, (Counter is in this register)
            LDD  2, X+           ; Load number into D register; then increase X to the next WORD address. 
            ADDD Sum_Result      ; Get the sum result. 
            STD  Sum_Result      ; Store the result into Sum_Result.  
            PULA                 ; Restore the AccA register (The counter)
            RTS                  ; return from Subroutine.
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
