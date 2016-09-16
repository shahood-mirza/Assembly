;****************************************************************
; Version 1.7   
; By: Shahood Mirza
;****************************************************************
; This program will:
; 1. Find the factorial of a number (defined by Factorial constant)
; 2. Save the results into a WORD named "FactorialResult" defined in the memory;
; 3. If the result has an overflow (cannot be held by a WORD), set a flag 
;    in Memory called "FactorialOverflow" to 1; Otherwise, clear it to 0. 
;****************************************************************

; export symbols
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart   EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

           ORG RAMStart
; Data Section
FactorialResult   DS.W   1   ; Save the result into here
Temp              DS.W   1   ; Temp for Y
FactorialOverflow DS.B   1   ; Flag to indicate if overflow happened. 
ResultOverflow    DS.W   1   ; Save the overflow part into here.


; Code Section
           ORG   ROMStart     ; Code starts from $4000

Entry:
_Startup:
           LDS   #RAMEnd+1        ; initialize the stack pointer
           CLI                    ; enable interrupts
           MOVW  #1, FactorialResult       ; Initialize the result to $1
           MOVW  #1, Temp         ; Initialize temp to $1
           MOVW  #0, ResultOverflow    ; Initialize the overflow part of the result to 0
           MOVB  #0, FactorialOverflow ; Initialize the overflow flag to 0
           
mainLoop:
           LDD   Factorial
           STD   Temp
           JSR   Decrement        ; Call Multiplication Subroutine
           BCS   OverflowSet      ; Determine if there is any overflow
           DBNE  Y, mainLoop      ; Decrement Y and Branch to mainLoop if Y is not ZERO.
           JMP   Entry            ; Loop to the start of the program.
           
OverflowSet: 
           MOVB  #1, FactorialOverflow ; set overflow as 1.      
           JMP   Entry
           
Decrement: 
           LDY Temp               ; Load Y with value of Temp (Temp stores the number to multiply with the result)
           DBNE Y, Multiplication ; Decrement Y and branch to Multiplication if Y is not ZERO
           JMP Entry              ; Loop to the beginning if Y is ZERO
           
Multiplication:
           STY Temp               ; Store the contents of Y into Temp
           EMUL                   ; Multiply Y * D = Y:D 
           STD FactorialResult    ; Store the product in D                 
           CPY #0                 ; Compare Y to ZERO for overflow
           BNE SetCBit            ; If there is an overflow branch to SetCBit
           CLC                    ; Clear Cbit if no overflow
           JMP Decrement          ; Jump to Decrement subroutine to decrement value for multiplication
           
SetCBit:     
           STY    ResultOverflow  ; Overflow generated, save the overflow part in "ResultOverflow"
           SEC                    ; Set carry bit to indicate the result has an overflow. 
           PULY                   ; restore Y register from stack.
           RTS                    ; Return to main program
           
           ORG   ROM_C000Start    ; Constant Data Array in ROM, starts from $C000
Factorial:     DC.W   8           ; Constant for which the factorial will be calculated


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            END                   ; END of the program