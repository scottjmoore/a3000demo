.include "swi.asm"
.include "vdu.asm"

; start program for $8000 in memory
.org 0x00008000

; start of our code
main:
    ADRL SP,stack       ; load stack pointer with our stack address

    VDU VDU_SelectScreenMode,13,-1,-1,-1,-1,-1,-1,-1,-1     ; change to mode 13 (320x256 256 colours) for A3000
    VDU VDU_MultiPurpose,1,0,0,0,0,0,0,0,0,0
    VDU VDU_DefineTextColour,128+4,-1,-1,-1,-1,-1,-1,-1,-1
    VDU VDU_ClearTextViewport,-1,-1,-1,-1,-1,-1,-1,-1,-1
    ADRL R0,vdu_variables
    ADRL R1,vdu_variables_result
    SWI OS_ReadVduVariables

loop:
    ADRL R1,vdu_variables_result
    LDR R12,[R1,#0]

    SWI OS_Mouse

    ADD R12,R12,R0,LSR #2
    MOV R0,#320
    MOV R1,R1,LSR #2
    EOR R1,R1,#255
    MLA R12,R0,R1,R12

    MOV R0,#19
    SWI OS_Byte

    VDU VDU_DefineLogicalColour,0,24,0,240,0,-1,-1,-1,-1
    VDU VDU_DefineTextColour,128+4,-1,-1,-1,-1,-1,-1,-1,-1
    VDU VDU_ClearTextViewport,-1,-1,-1,-1,-1,-1,-1,-1,-1

    VDU VDU_DefineLogicalColour,0,24,0,0,240,-1,-1,-1,-1

    ADD R11,R12,#0 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#50 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#100 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#150 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#200 + (0 * 320)
    BL draw_compiled_sprite

    ADD R12,R12,#50 * 320

    ADD R11,R12,#0 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#50 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#100 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#150 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#200 + (0 * 320)
    BL draw_compiled_sprite

    ADD R12,R12,#50 * 320
    
    ADD R11,R12,#0 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#50 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#100 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#150 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#200 + (0 * 320)
    BL draw_compiled_sprite

    ADD R12,R12,#50 * 320
    
    ADD R11,R12,#0 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#50 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#100 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#150 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#200 + (0 * 320)
    BL draw_compiled_sprite

    ADD R12,R12,#50 * 320
    
    ADD R11,R12,#0 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#50 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#100 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#150 + (0 * 320)
    BL draw_compiled_sprite

    ADD R11,R12,#200 + (0 * 320)
    BL draw_compiled_sprite

    VDU VDU_DefineLogicalColour,0,24,0,0,0,-1,-1,-1,-1

    VDU VDU_DefineLogicalColour,0,24,240,0,0,-1,-1,-1,-1
    VDU VDU_DefineLogicalColour,0,24,0,0,0,-1,-1,-1,-1

    MOV R0,#129
    MOV R1,#112
    EOR R1,R1,#0xff
    MOV R2,#0xff
    SWI OS_Byte
    CMP R1,#0xff
    BNE loop
    
exit:
    MOV R0,#0
    SWI OS_Exit

.balign 16
vdu_variables:
    .4byte 0x00000095       ; display memory start address
    .4byte 0xffffffff

.balign 16
vdu_variables_result:
    .4byte 0x00000000
    .4byte 0x00000000

draw_compiled_sprite:
    MOV R0,#0x00

    STRB R0,[R11,#0+(2*320)]
    STRB R0,[R11,#0+(3*320)]
    STRB R0,[R11,#0+(4*320)]
    STRB R0,[R11,#0+(5*320)]

    STRB R0,[R11,#1+(1*320)]
    STRB R0,[R11,#1+(6*320)]
    STRB R0,[R11,#1+(8*320)]

    STRB R0,[R11,#2+(1*320)]
    STRB R0,[R11,#2+(2*320)]
    STRB R0,[R11,#2+(3*320)]
    STRB R0,[R11,#2+(7*320)]
    STRB R0,[R11,#2+(9*320)]

    STRB R0,[R11,#3+(0*320)]
    STRB R0,[R11,#3+(2*320)]
    STRB R0,[R11,#3+(8*320)]

    STRB R0,[R11,#4+(1*320)]
    STRB R0,[R11,#4+(4*320)]
    STRB R0,[R11,#4+(7*320)]

    STRB R0,[R11,#5+(2*320)]
    STRB R0,[R11,#5+(7*320)]

    STRB R0,[R11,#6+(2*320)]
    STRB R0,[R11,#6+(7*320)]

    STRB R0,[R11,#7+(2*320)]
    STRB R0,[R11,#7+(7*320)]

    STRB R0,[R11,#8+(1*320)]
    STRB R0,[R11,#8+(4*320)]
    STRB R0,[R11,#8+(7*320)]

    STRB R0,[R11,#9+(0*320)]
    STRB R0,[R11,#9+(2*320)]
    STRB R0,[R11,#9+(8*320)]

    STRB R0,[R11,#10+(1*320)]
    STRB R0,[R11,#10+(2*320)]
    STRB R0,[R11,#10+(3*320)]
    STRB R0,[R11,#10+(7*320)]
    STRB R0,[R11,#10+(9*320)]

    STRB R0,[R11,#11+(1*320)]
    STRB R0,[R11,#11+(6*320)]
    STRB R0,[R11,#11+(8*320)]

    STRB R0,[R11,#12+(2*320)]
    STRB R0,[R11,#12+(3*320)]
    STRB R0,[R11,#12+(4*320)]
    STRB R0,[R11,#12+(5*320)]

    MOV R0,#0xff

    STRB R0,[R11,#1+(2*320)]
    STRB R0,[R11,#1+(3*320)]
    STRB R0,[R11,#1+(4*320)]
    STRB R0,[R11,#1+(5*320)]

    STRB R0,[R11,#2+(4*320)]
    STRB R0,[R11,#2+(5*320)]
    STRB R0,[R11,#2+(6*320)]
    STRB R0,[R11,#2+(8*320)]

    STRB R0,[R11,#3+(1*320)]
    STRB R0,[R11,#3+(3*320)]
    STRB R0,[R11,#3+(4*320)]
    STRB R0,[R11,#3+(5*320)]
    STRB R0,[R11,#3+(6*320)]
    STRB R0,[R11,#3+(7*320)]

    STRB R0,[R11,#9+(1*320)]
    STRB R0,[R11,#9+(3*320)]
    STRB R0,[R11,#9+(4*320)]
    STRB R0,[R11,#9+(5*320)]
    STRB R0,[R11,#9+(6*320)]
    STRB R0,[R11,#9+(7*320)]

    STRB R0,[R11,#10+(4*320)]
    STRB R0,[R11,#10+(5*320)]
    STRB R0,[R11,#10+(6*320)]
    STRB R0,[R11,#10+(8*320)]

    STRB R0,[R11,#11+(2*320)]
    STRB R0,[R11,#11+(3*320)]
    STRB R0,[R11,#11+(4*320)]
    STRB R0,[R11,#11+(5*320)]

    MOV PC,R14

; reserve 256 bytes for a stack
.space 256
stack:

