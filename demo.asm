; SWI function values
OS_WriteC           = $00
OS_WriteS           = $01
OS_NewLine          = $03
OS_Byte             = $06
OS_Exit             = $11

; VDU function values
VDU_TextColour      = 17
VDU_Palette         = 19
VDU_DefaultColours  = 20
VDU_Mode            = 22

; VDU macro, can accept upto 6 parameters
VDU:    macro
        if NARG=1           ; if macro is passed 1 parameter
            MOV R0,#\1      ; move parameter 1 into R0
            SWI OS_WriteC   ; write it to the display
        endif
        if NARG=2           ; if macro is passed 2 parameters
            MOV R0,#\1      ; move parameter 1 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\2      ; move parameter 2 into R0
            SWI OS_WriteC   ; write it to the display
        endif
        if NARG=3           ; if macro is passed 3 parameters
            MOV R0,#\1      ; move parameter 1 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\2      ; move parameter 2 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\3      ; move parameter 3 into R0
            SWI OS_WriteC   ; write it to the display
        endif
        if NARG=4           ; if macro is passed 4 parameters
            MOV R0,#\1      ; move parameter 1 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\2      ; move parameter 2 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\3      ; move parameter 3 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\4      ; move parameter 4 into R0
            SWI OS_WriteC   ; write it to the display
        endif
        if NARG=5           ; if macro is passed 5 parameters
            MOV R0,#\1      ; move parameter 1 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\2      ; move parameter 2 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\3      ; move parameter 3 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\4      ; move parameter 4 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\5      ; move parameter 5 into R0
            SWI OS_WriteC   ; write it to the display
        endif
        if NARG=6           ; if macro is passed 6 parameters
            MOV R0,#\1      ; move parameter 1 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\2      ; move parameter 2 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\3      ; move parameter 3 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\4      ; move parameter 4 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\5      ; move parameter 5 into R0
            SWI OS_WriteC   ; write it to the display
            MOV R0,#\6      ; move parameter 6 into R0
            SWI OS_WriteC   ; write it to the display
        endif
        endm

; start program for $8000 in memory
    org $00008000

; jump to start of our code
    B start

; reserve 256 bytes for a stack
    dcb.b 256
stack:

; start of our code
start:
    ADRL SP,stack       ; load stack pointer with our stack address

    VDU VDU_Mode,20                 ; change to mode 20 (640x512 16 colours)
    VDU VDU_Palette,0,16,64,64,64   ; set background colour to dark grey
    VDU VDU_Palette,0,24,64,64,64   ; set border colour to dark grey
    VDU VDU_Palette,1,16,255,64,64  ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,2,16,255,128,64 ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,3,16,255,255,64 ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,4,16,128,255,64 ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,5,16,64,255,64  ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,6,16,64,255,128 ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,7,16,64,255,255 ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,8,16,64,128,255 ; set colours 1-9 to a rainbow palette
    VDU VDU_Palette,9,16,64,64,255  ; set colours 1-9 to a rainbow palette

    VDU VDU_TextColour,1    ; select text colour 1

    MOV R0,#65      ; set the character value to display as 'A'
    SWI OS_WriteC   ; write it to the display
    ADD R0,R0,#1    ; increase the character value by 1
    SWI OS_WriteC   ; write it to the display
    ADD R0,R0,#1    ; increase the character value by 1
    SWI OS_WriteC   ; write it to the display
    ADD R0,R0,#1    ; increase the character value by 1
    SWI OS_WriteC   ; write it to the display
    ADD R0,R0,#1    ; increase the character value by 1
    SWI OS_WriteC   ; write it to the display
    ADD R0,R0,#1    ; increase the character value by 1
    SWI OS_WriteC   ; write it to the display
    SWI OS_NewLine  ; write a newline to the display

    SWI OS_WriteS       ; write the following string to the display
    dc.b "Hello World!"
    dc.b 0
    align 4             ; align back to the 4 byte boundary

    VDU VDU_TextColour,3    ; select text colour 3

    SWI OS_NewLine  ; write a newline to the display
    SWI OS_WriteS   ; write the following string to the display
    dc.b 17,1       ; select text colour 1
    dc.b "Welcome "
    dc.b 17,2       ; select text colour 2
    dc.b "to "
    dc.b 17,3       ; select text colour 3
    dc.b "ARM "
    dc.b 17,4       ; select text colour 4
    dc.b "Assembly "
    dc.b 17,5       ; select text colour 5
    dc.b "in "
    dc.b 17,6       ; select text colour 6
    dc.b "RISC "
    dc.b 17,7       ; select text colour 7
    dc.b "OS "
    dc.b 17,8       ; select text colour 8
    dc.b "3. "
    dc.b 17,9       ; select text colour 9
    dc.b "BLUE"
    dc.b 0          ; terminate the string
    align 4         ; align back to the 4 byte boundary

    SWI OS_NewLine  ; write a newline to the display

exit:
    MOV R0,#0
    SWI OS_Exit     ; return to RISC OS

