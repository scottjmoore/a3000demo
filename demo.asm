; SWI function values
.set OS_WriteC,0x00
.set OS_WriteS,0x01
.set OS_NewLine,0x03
.set OS_Byte,0x06
.set OS_Exit,0x11
.set OS_ReadVduVariables,0x31

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

    VDU VDU_Mode,13,-1,-1,-1,-1     ; change to mode 13 (320x256 256 colours)

    ADR R11,grey
    ADD R9,R11,#32*32

frame_loop:
    ADRL R0,vdu_variables_screen_start
    ADRL R1,buffer
    SWI OS_ReadVduVariables
    LDR R12,[R1]
    MOV R10,#256

    MOV R0,#19
    SWI OS_Byte

    VDU 19,0,24,0,0,255
line_loop:

    LDMIA R11!, {R0-R7}
    
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}

    CMP R11,R9
    SUBGE R11,R9,#32*32

    SUBS R10,R10,#1
    BNE line_loop

    SUB R11,R11,#32

    VDU 19,0,24,255,0,0

    ADRL R1,buffer
    LDR R12,[R1]
    ADD R12,R12,#320*128
    MOV R10,#32

    MOV R8,R11
    ADRL R11,grey

layer_loop:

    LDMIA R11!, {R0-R7}
    
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}
    STMIA R12!, {R0-R7}

    SUBS R10,R10,#1
    BNE layer_loop

    VDU 19,0,24,64,64,64

    MOV R11,R8

    B frame_loop

exit:
    SWI OS_Exit     ; return to RISC OS

vdu_variables_screen_start:
    .4byte 0x00000095       ; display memory start address
    .4byte 0xffffffff

buffer:
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000

    .include "grey.asm"

