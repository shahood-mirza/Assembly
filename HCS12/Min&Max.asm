;****************************************************************
; Version 4.6
; Shahood Mirza   
;****************************************************************
; This is a program that will:
; 1. Search through an Array
; 2. Save the largest number into a WORD named "MaxNumber" defined in the memory
; 3. Save the smallest number into a WORD named "MinNumber" defined in the memory
;****************************************************************

; export symbols
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart   EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

           ORG RAMStart
; Data Section
Temp             DS.W   1   ; Temporary storage for Y
MaxNumber        DS.W   1   ; Save the max number here
MinNumber        DS.W   1   ; Save the min number here

; Code Section
           ORG   ROMStart   ; Code starts from $4000

Entry:
_Startup:
           LDS   #RAMEnd+1        ; initialize the stack pointer
           CLI                    ; enable interrupts
           LDX   #Array           ; Load X with address of the Array 
           MOVW  #1, Temp         ; Initialize Temp to $1
           MOVW  #1, MaxNumber    ; Initialize the MaxNumber to $1
           MOVW  #1, MinNumber    ; Initialize the MinNumber to $1
           LDY   Count            ; Initialize Y as the count of the array. 
           
mainLoop:           
           JSR   Compare          ; Call Multiplication Subroutine
           DBNE  Y, mainLoop      ; Decrement Y and Branch to mainLoop if Y is not ZERO.
           JMP   Entry            ; Loop to the start of the program.
           
MaxNum:
           STY   MaxNumber        ; Store the max number into MaxNumber
           INX                    ; Increase X for the next address.
           INX                    ; X is increased twive because of WORD value.
           JMP   Compare          ; Jump back to Compare another value     
           
MinNum:
           STY   MinNumber        ; Store the min number into MinNumber
           INX                    ; Increase X for the next address.
           INX                    ; X is increased twive because of WORD value.
           JMP   Compare          ; Jump back to Compare another value

Compare:
           LDY    Temp            ; Y is the number in Result
           LDAA   #0              ; D is the number in address (X+0)
           LDY    0, X            ; Load contents from memory address X+0 to Y register. 
           CPX    #$C002          ; Compares X address with starting address of the Array
           BEQ    MinNum          ; Skips comparing MinNumber value (which is declared as 0 to start)
                                  ;   with first entry of array, and assigns the first array entry to MinNumber
           CPY    MaxNumber       ; Compare Y with the current MaxNumber
           BGE    MaxNum          ; Branch to MaxNum if the value is bigger
           CPY    MinNumber       ; Compare Y with the current MinNumber
           BLT    MinNum          ; Branch to MinNum if the value is bigger
           CPX    #$C014          ; Compares X address with ending address of the Array
           BEQ    mainLoop        ; If the array is finished loopback without increasing X
           INX                    ; Increase X for the next address.
           INX                    ; X is increased twive because of WORD value.
           JMP    Compare
           
           ORG   ROM_C000Start     ; Constant Data Array in ROM, starts from $C000
Count:     DC.W   10               ; Size of the Array for counting
Array:     DC.W   23, 43, 123, 12, 345, 567, 82, 73, 213, 345   ; The numbers to be multiplied.


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            END                   ; END of the program