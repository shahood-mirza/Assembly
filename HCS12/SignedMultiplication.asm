;****************************************************************
; Version 2.0   
;****************************************************************
; This program will:
; 1. Multiply 5 unsigned numbers (BYTE) together, 
; 2. Save the results into a WORD named "Result" defined in the memory;
; 3. If the result has an overflow (cannot be held by a WORD), set a flag 
;    in Memory called "Overflow" to 1; Otherwise, clear it to 0. 
;****************************************************************

; export symbols
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart   EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

           ORG RAMStart
; Data Section
Result           DS.W   1   ; Save the result into here
Overflow         DS.B   1   ; Flag to indicate if overflow happened. 
ResultOverflow   DS.W   1   ; Save the overflow part into here.


; Code Section
           ORG   ROMStart     ; Code start from $4000

Entry:
_Startup:
           LDS   #RAMEnd+1        ; initialize the stack pointer
           CLI                    ; enable interrupts
           LDX   #Array           ; Load X with address of the Array 
           MOVW  #1, Result       ; Initialize the result to $1
           MOVW  #0, ResultOverflow   ; Initialize the overflow part of the result to 0
           MOVB  #0, Overflow     ; Initialize the overflow flag to 0
           LDY   Count            ; Initialize Y as the count of the array. 
mainLoop:
                      
           JSR   Multiplication    ; Call Multiplication Subroutine
           BCS   OverflowSet       ; Determine if there is any overflow
           DBNE  Y, mainLoop       ; Decrement Y and Branch to mainLoop if Y is not ZERO.
           JMP   Entry             ; Loop to the start of the program.
           
OverflowSet: 
           MOVB  #1, Overflow      ; set overflow as 1.      
           JMP   Entry
              

Multiplication:                   ; Multiply Result with the next number pointed by X
           PSHY                   ; Save Y register into stack
           LDY    Result          ; Y is the number in Result
           LDAA   #0              ; D is the number in address (X+0)
           LDAB   0, X            ; Load contents from memory address X+0 to B register. 
           EMUL                   ; Multiply Y * D = Y:D
           INX                    ; Increase X for the next address.
           STD    Result          ; Store lower part of the result into "Result"
           CPY    #0              ; Compare Y with zero, see if there is some number in Y
           BNE    SetCBit         ; If Y is not zero, branch to SetCBit. 
           CLC                    ; If program runs to here, it means NO overflow generated, thus clear the carry bit. 
           PULY                   ; Restore the Y register from stack
           RTS   

SetCBit:     
           STY    ResultOverflow   ; Overflow generated, save the overflow part in "ResultOverflow"
           SEC                     ; Set carry bit to indicate the result has an overflow. 
           PULY                    ; restore Y register from stack.
           RTS                     ; Return to main program
           
           ORG   ROM_C000Start     ; Constant Data Array in ROM, starts from $C000
Count:     DC.W   5                ; Size of the Array to do the multiplication
Array:     DC.B   $05, $A7, $B6, $09, $0A   ; The numbers to be multiplied.


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            END                   ; END of the program