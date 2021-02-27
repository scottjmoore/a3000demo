; SWI function values
.set OS_WriteC,0x00
.set OS_WriteS,0x01
.set OS_NewLine,0x03
.set OS_Byte,0x06
.set OS_Exit,0x11

; VDU function values
.set VDU_TextColour,17
.set VDU_Palette,19
.set VDU_DefaultColours,20
.set VDU_Mode,22

; VDU macro, can accept upto 6 parameters
.macro VDU v1,v2,v3,v4,v5,v6
    .nolist
    .if \v1<>-1           ; if macro is passed 1 parameter
        MOV R0,#\v1      ; move parameter 1 into R0
        SWI OS_WriteC   ; write it to the display
    .endif
    .if \v2<>-1           ; if macro is passed 2 parameters
        MOV R0,#\v2      ; move parameter 2 into R0
        SWI OS_WriteC   ; write it to the display
    .endif
    .if \v3<>-1           ; if macro is passed 3 parameters
        MOV R0,#\v3      ; move parameter 3 into R0
        SWI OS_WriteC   ; write it to the display
    .endif
    .if \v4<>-1           ; if macro is passed 4 parameters
        MOV R0,#\v4      ; move parameter 4 into R0
        SWI OS_WriteC   ; write it to the display
    .endif
    .if \v5<>-1           ; if macro is passed 5 parameters
        MOV R0,#\v5      ; move parameter 5 into R0
        SWI OS_WriteC   ; write it to the display
    .endif
    .if \v6<>-1           ; if macro is passed 6 parameters
        MOV R0,#\v6      ; move parameter 6 into R0
        SWI OS_WriteC   ; write it to the display
    .endif
    .list
.endm

; start program for $8000 in memory
.org 0x00008000

; jump to start of our code
    B start

; reserve 256 bytes for a stack
.space 256
stack:

; start of our code
start:
    ADR SP,stack       ; load stack pointer with our stack address

    VDU VDU_Mode,20,-1,-1,-1,-1     ; change to mode 20 (640x512 16 colours)
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

    VDU VDU_Palette,15,16,255,255,255   ; set colour 15 to white

    VDU VDU_TextColour,1,-1,-1,-1,-1    ; select text colour 1

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

    VDU VDU_TextColour,2,-1,-1,-1,-1    ; select text colour 2

    SWI OS_WriteS       ; write the following string to the display
    .byte "Hello World!",0
    .align 4             ; align back to the 4 byte boundary

    VDU VDU_TextColour,3,-1,-1,-1,-1    ; select text colour 3

    SWI OS_NewLine  ; write a newline to the display
    SWI OS_WriteS   ; write the following string to the display
    .byte 17,1       ; select text colour 1
    .byte "Welcome "
    .byte 17,2       ; select text colour 2
    .byte "to "
    .byte 17,3       ; select text colour 3
    .byte "ARM "
    .byte 17,4       ; select text colour 4
    .byte "Assembly "
    .byte 17,5       ; select text colour 5
    .byte "in "
    .byte 17,6       ; select text colour 6
    .byte "RISC "
    .byte 17,7       ; select text colour 7
    .byte "OS "
    .byte 17,8       ; select text colour 8
    .byte "3. "
    .byte 17,9       ; select text colour 9
    .byte "BLUE"
    .byte 0          ; terminate the string
    .align 4         ; align back to the 4 byte boundary

    SWI OS_NewLine  ; write a newline to the display

exit:
    VDU VDU_TextColour,15,-1,-1,-1,-1
    mov r0,#0x12340000
    add r0,r0,#0x00005678
    SWI OS_Exit     ; return to RISC OS

