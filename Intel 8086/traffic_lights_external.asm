; controlling external device with 8086 microprocessor.
; realistic test for c:\emu8086\devices\Traffic_Lights.exe

#start=Traffic_Lights.exe#

name "traffic"

;--------------------------NORTH/SOUTH 4SEC-----------------------------;
northsouth:
mov ax, all_red
out 4, ax

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt

mov ax, ns_green
out 4, ax

; wait 4 seconds (4 million microseconds)
mov     cx, 3Dh    ;    003D0900h = 4,000,000
mov     dx, 0900h
mov     ah, 86h
int     15h        ;intterupt

mov ax, ns_yellow
out 4, ax

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt

jmp check_key

;--------------------------EAST/WEST 4SEC-----------------------------;
eastwest:
mov ax, all_red
out 4, ax

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt

mov ax, ew_green
out 4, ax

; wait 4 seconds (4 million microseconds)
mov     cx, 3Dh    ;    003D0900h = 4,000,000
mov     dx, 0900h
mov     ah, 86h
int     15h        ;intterupt

mov ax, ew_yellow
out 4, ax

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt


jmp northsouth

;--------------------------EAST/WEST ADVANCED 2SEC-----------------------------;
eastwestADV:
mov ax, all_red
out 4, ax

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt

mov ax, e_green
out 4, ax

; wait 2 seconds (2 million microseconds)
mov     cx, 1Eh    ;    001E8480h = 2,000,000
mov     dx, 8480h
mov     ah, 86h
int     15h        ;intterupt

mov ax, ew_green
out 4, ax

; wait 6 seconds (6 million microseconds)
mov     cx, 5Bh    ;    005B8D80h = 6,000,000
mov     dx, 8D80h
mov     ah, 86h
int     15h        ;intterupt


mov ax, ew_yellow
out 4, ax

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt

jmp northsouth                                                                  

;--------------------------TRIGGER CHECK FOR PEAK HOURS-----------------------------;
check_key:

; check for user commands:
mov     ah, 01h ;check keyboard buffer for key input
int     16h
jz      eastwest ;to run this after entering a key, clear the buffer (clear screen)

cmp     al, 1bh    ; if esc has been pressed then use advanced lights
je      eastwestADV

;--------------------------CORE FUNCTIONS-----------------------------;
;                        FEDC_BA98_7654_3210
all_red          equ     0000_0010_0100_1001b
ns_green         equ     0000_0011_0000_1100b
ns_yellow        equ     0000_0010_1000_1010b
ew_yellow        equ     0000_0100_0101_0001b
e_green          equ     0000_1000_0100_1001b
ew_green         equ     0000_1000_0110_0001b

;8sec  007A1200h
;4sec  003D0900h
;2sec  001E8480h
;1sec  000F4240h

; wait 8 seconds (8 million microseconds)
mov     cx, 7Ah    ;    007A1200h = 8,000,000
mov     dx, 1200h
mov     ah, 86h
int     15h        ;intterupt

; wait 6 seconds (6 million microseconds)
mov     cx, 5Bh    ;    005B8D80h = 6,000,000
mov     dx, 8D80h
mov     ah, 86h
int     15h        ;intterupt
       
; wait 4 seconds (4 million microseconds)
mov     cx, 3Dh    ;    003D0900h = 4,000,000
mov     dx, 0900h
mov     ah, 86h
int     15h        ;intterupt

; wait 2 seconds (2 million microseconds)
mov     cx, 1Eh    ;    001E8480h = 2,000,000
mov     dx, 8480h
mov     ah, 86h
int     15h        ;intterupt

; wait 1 second (1 million microseconds)
mov     cx, 0Fh    ;    000F4240h = 1,000,000
mov     dx, 4240h
mov     ah, 86h
int     15h        ;intterupt
;--------------------------CORE FUNCTIONS-----------------------------;