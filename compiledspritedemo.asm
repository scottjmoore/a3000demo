.include "swi.asm"
.include "vdu.asm"

; start program for $8000 in memory
.org 0x00008000

; start of our code
main:
    ADRL SP,stack       ; load stack pointer with our stack address

    VDU VDU_Mode,13,-1,-1,-1,-1,-1,-1,-1,-1     ; change to mode 13 (320x256 256 colours) for A3000
    VDU VDU_Misc,1,0,0,0,0,0,0,0,0,0
    ADRL R0,vdu_variables
    ADRL R1,vdu_variables_result
    SWI OS_ReadVduVariables

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

; reserve 256 bytes for a stack
.space 256
stack:

