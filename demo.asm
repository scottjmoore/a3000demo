.include "swi.asm"
.include "vdu.asm"

; BFL macro to branch to a fixed 32 bit address with linked return
.macro BFL r,a
    MOV \r,#\a
    ADD R14,PC,#0
    MOV PC,\r
.endm

; BF macro to branch to a fixed 32 bit address
.macro BF r,a
    MOV \r,#\a
    MOV PC,\r
.endm

; start program for $8000 in memory
.org 0x00008000

; start of our code
main:
    ;ADRL SP,stack       ; load stack pointer with our stack address

    VDU VDU_SelectScreenMode,13,-1,-1,-1,-1,-1,-1,-1,-1     ; change to mode 13 (320x256 256 colours) for A3000
    VDU VDU_MultiPurpose,1,0,0,0,0,0,0,0,0,0
    ADRL R0,vdu_variables_screen_start
    ADRL R1,buffer
    SWI OS_ReadVduVariables

    MOV R0,#display_list
    STR R0,[R1,#4]

    MOV R0,#32
    STR R0,[R1,#20]

main_loop:
    ADRL R1,buffer
    LDR R12,[R1]
    LDR R11,[R1,#4]
    LDR R3,[R1,#16]
    CMP R3,#0
    SUBLT R11,R11,#40
    ADDGT R11,R11,#40
    MOV R0,#display_list_end
    CMP R11,R0
    SUBGE R11,R11,#40*256
    MOV R0,#display_list
    CMP R11,R0
    ADDLT R11,R11,#40*256
    STR R11,[R1,#4]
    LDR R0,[R1,#12]
    CMP R3,#0
    SUBLT R0,R0,#1
    ADDGT R0,R0,#1
    STR R0,[R1,#12]
    MOV R0,R0,LSR #1
    STR R0,[R1,#8]
    MOV R0,#sprite_list
    STR R0,[R1,#16]

    LDR R0,[R1,#20]
    ADRL R2,sprite_list
    MOV R9,#256
reset_sprite_positions:
    LDR R3,[R2,#4]
    ADD R3,R3,R0
    STR R3,[R2,#4]
    LDR R3,[R2,#12]
    ADD R3,R3,R0
    STR R3,[R2,#12]
    ADD R2,R2,#16
    SUBS R9,R9,#1
    BNE reset_sprite_positions

    LDR R0,[R1,#24]
    ADD R0,R0,#1
    CMP R0,#320
    MOVGE R0,#0
    STR R0,[R1,#24]
    AND R10,R0,#31
    MOV R0,R0,LSR #5
    ;ADD R11,R11,R0,LSL #2
    
    MOV R0,#display_list_offset_list
    ADD R0,R0,R10,LSL #3
    MOV R1,#display_list_offset_branch
    LDMIA R0,{R2-R3}
    ;STMIA R1,{R2-R3}

    MOV R9,#256

    MOV R0,#19
    SWI OS_Byte

    VDU 19,0,24,0,0,240,-1,-1,-1,-1

display_list_loop:
    MOV R8,R12
    MOV R1,#buffer
    LDR R0,[R1,#8]
    ADD R0,R0,#1
    AND R0,R0,#0xff
    STR R0,[R1,#8]
    ORR R0,R0,R0, LSL #8
    ORR R0,R0,R0, LSL #16
    MOV R1,R0
    MOV R2,R0
    MOV R3,R0
    MOV R4,R0
    MOV R5,R0
    MOV R6,R0
    MOV R7,R0

    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}
    STMIA R12!,{R0-R7}

    MOV R12,R8

display_list_offset_branch:
    BFL R0,display_list_offset_005

    MOV R12,R8
    MOV R1,#buffer
    LDR R0,[R1,#16]
    LDR R6,[R0],#4
    LDR R7,[R0],#4
    STR R0,[R1,#16]
    CMP R6,#0
    BEQ skip_sprite_1

    ADD R12,R12,R7

    TST R6,#0x80000000
    EORNE R6,R6,#0x80000000
    BLNE double_sprite
    BLEQ single_sprite

skip_sprite_1:
    MOV R12,R8
    ADRL R1,buffer
    LDR R0,[R1,#16]
    LDR R6,[R0],#4
    LDR R7,[R0],#4
    STR R0,[R1,#16]
    CMP R6,#0
    BEQ skip_sprite_2

    ADD R12,R12,R7

    TST R6,#0x80000000
    EORNE R6,R6,#0x80000000
    BLNE double_sprite
    BLEQ single_sprite

skip_sprite_2:
    MOV R12,R8
    ADD R12,R12,#320
    MOV R0,#display_list_end
    CMP R11,R0
    SUBGE R11,R11,#40*256

    MOV R0,#display_list
    CMP R11,R0
    ADDLT R11,R11,#40*256

    SUBS R9,R9,#1
    BNE display_list_loop
    
    MOV R0,#129
    MOV R1,#112
    EOR R1,R1,#0xff
    MOV R2,#0xff
    SWI OS_Byte
    CMP R1,#0xff
    BEQ exit

    MOV R3,#0

    MOV R1,#41
    MOV R2,#0xff
    EOR R1,R1,#0xff
    SWI OS_Byte
    CMP R1,#0xff
    MOVEQ R3,#-1

    MOV R1,#57
    EOR R1,R1,#0xff
    MOV R2,#0xff
    SWI OS_Byte
    CMP R1,#0xff
    MOVEQ R3,#1

    MOV R4,#0

    MOV R1,#25
    EOR R1,R1,#0xff
    MOV R2,#0xff
    SWI OS_Byte
    CMP R1,#0xff
    MOVEQ R4,#-1

    MOV R1,#121
    EOR R1,R1,#0xff
    MOV R2,#0xff
    SWI OS_Byte
    CMP R1,#0xff
    MOVEQ R4,#1

    ADRL R1,buffer
    STR R3,[R1,#16]
    STR R4,[R1,#20]

    VDU 19,0,24,0,0,0,-1,-1,-1,-1

    BF R0,main_loop

exit:
    MOV R0,#0
    SWI OS_Exit     ; return to RISC OS

.balign 16
single_sprite:
    LDMIA R6,{R0-R3}
    MOV R7,R0,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #3]
    MOV R7,R0,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #2]
    MOV R7,R0,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #1]
    MOV R7,R0
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #0]
        
    MOV R7,R1,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #7]
    MOV R7,R1,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #6]
    MOV R7,R1,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #5]
    MOV R7,R1
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #4]
        
    MOV R7,R2,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #11]
    MOV R7,R2,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #10]
    MOV R7,R2,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #9]
    MOV R7,R2
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #8]
        
    MOV R7,R3,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #15]
    MOV R7,R3,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #14]
    MOV R7,R3,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #13]
    MOV R7,R3
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #12]
    MOV PC,R14

.balign 16
double_sprite:
    LDMIA R6,{R0-R3}
    MOV R7,R0,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #7]
    STRNEB R7,[R12, #6]
    MOV R7,R0,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #5]
    STRNEB R7,[R12, #4]
    MOV R7,R0,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #3]
    STRNEB R7,[R12, #2]
    MOV R7,R0
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #1]
    STRNEB R7,[R12, #0]
        
    MOV R7,R1,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #15]
    STRNEB R7,[R12, #14]
    MOV R7,R1,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #13]
    STRNEB R7,[R12, #12]
    MOV R7,R1,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #11]
    STRNEB R7,[R12, #10]
    MOV R7,R1
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #9]
    STRNEB R7,[R12, #8]
        
    MOV R7,R2,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #23]
    STRNEB R7,[R12, #22]
    MOV R7,R2,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #21]
    STRNEB R7,[R12, #20]
    MOV R7,R2,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #19]
    STRNEB R7,[R12, #18]
    MOV R7,R2
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #17]
    STRNEB R7,[R12, #16]
        
    MOV R7,R3,LSR #24
    CMP R7,#0
    STRNEB R7,[R12, #31]
    STRNEB R7,[R12, #30]
    MOV R7,R3,LSR #16
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #29]
    STRNEB R7,[R12, #28]
    MOV R7,R3,LSR #8
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #27]
    STRNEB R7,[R12, #26]
    MOV R7,R3
    ANDS R7,R7,#0xff
    STRNEB R7,[R12, #25]
    STRNEB R7,[R12, #24]
    MOVS R7,#0xff
    MOV PC,R14

.balign 16
display_list_offset_000:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14


.balign 16
display_list_offset_001:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_1
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4

.skip_001_1:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADD R10,R10,#32*32
    ADDEQ R12,R12,#32
    BEQ .skip_001_2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_2:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_3
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_3:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_4
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_4:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_5
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_5:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_6
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_6:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_7
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_7:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_8
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_8:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_9
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_9:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_001_10
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_001_10:
    MOV PC,R14

.balign 16
display_list_offset_002:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_1
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4

.skip_002_1:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_2
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_2:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_3
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_3:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_4
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_4:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_5
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_5:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_6
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_6:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_7
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_7:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_8
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_8:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_9
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_9:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_002_10
    ADD R10,R10,#32*32*2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    MOV R2,#0xff000000
    ORR R2,R2,R2,LSR #8
    AND R0,R0,R2
    MOV R1,R7,LSR #16
    AND R7,R7,R2,LSR #16
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,R2,LSR #16
    ORR R0,R0,R1,LSL #16
    STR R0,[R12,#-36]
    
.skip_002_10:
    MOV PC,R14

.balign 16
display_list_offset_003:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_1
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4

.skip_003_1:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_2
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_2:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_3
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_3:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_4
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_4:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_5
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_5:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_6
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_6:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_7
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_7:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_8
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_8:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_9
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_9:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_003_10
    ADD R10,R10,#32*32*3
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xffffff00
    MOV R1,R7,LSR #8
    AND R7,R7,#0x000000ff
    ORR R0,R0,R7
    STR R0,[R12],#4
    
    LDR R0,[R12,#-36]
    AND R0,R0,#0x000000ff
    ORR R0,R0,R1,LSL #8
    STR R0,[R12,#-36]
    
.skip_003_10:
    MOV PC,R14

.balign 16
display_list_offset_004:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#28
    STRNE R0,[R12,#316]
    STMNEIA R12!,{R1-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_005:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#28
    BEQ .skip_005_1
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STR R0,[R12,#316]
    STMIA R12!,{R1-R6}
    LDR R0,[R12]
    AND R1,R7,#0x00ffffff
    AND R0,R0,#0xff000000
    ORR R0,R0,R1
    STR R0,[R12]
    LDR R0,[R12,#320-32]
    AND R1,R7,#0xff000000
    AND R0,R0,#0x00ffffff
    ORR R0,R0,R1
    STR R0,[R12,#320-32]

.skip_005_1:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADD R10,R10,#32*32
    ADDEQ R12,R12,#32
    BEQ .skip_005_2
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_2:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_3
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_3:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_4
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_4:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_5
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_5:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_6
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_6:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_7
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_7:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_8
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_8:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_9
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_9:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    ADDEQ R12,R12,#32
    BEQ .skip_005_10
    ADD R10,R10,#32*32
    LDMIA R10,{R0-R7}
    STMIA R12!,{R0-R6}
    LDR R0,[R12,#4]
    AND R0,R0,#0xff000000
    MOV R1,R7,LSR #24
    AND R7,R7,#0x00ffffff
    ORR R0,R0,R7
    STR R0,[R12],#4
    STRB R1,[R12,#-33]
    
.skip_005_10:
    MOV PC,R14

.balign 16
display_list_offset_008:
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#24
    STRNE R0,[R12,#312]
    STRNE R1,[R12,#316]
    STMNEIA R12!,{R2-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_012:
    ADD R13,R12,#308
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#20
    STMNEIA R13!,{R0-R2}
    STMNEIA R12!,{R3-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_016:
    ADD R13,R12,#304
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#16
    STMNEIA R13!,{R0-R3}
    STMNEIA R12!,{R4-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_020:
    ADD R13,R12,#300
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#12
    STMNEIA R13!,{R0-R4}
    STMNEIA R12!,{R5-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_024:
    ADD R13,R12,#296
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#8
    STMNEIA R13!,{R0-R5}
    STMNEIA R12!,{R6-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_028:
    ADD R13,R12,#292
    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#4
    STMNEIA R13!,{R0-R6}
    STRNE R7,[R12],#4

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}

    LDR R10,[R11],#4
    CMP R10,#0x00000000
    LDMNEIA R10,{R0-R7}
    ADDEQ R12,R12,#32
    STMNEIA R12!,{R0-R7}
    
    MOV PC,R14

.balign 16
display_list_offset_list:
    MOV R0,#display_list_offset_000
    ; MOV R0,#display_list_offset_000
    ; MOV R0,#display_list_offset_000
    ; MOV R0,#display_list_offset_000
    MOV R0,#display_list_offset_001
    MOV R0,#display_list_offset_002
    MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_004
    MOV R0,#display_list_offset_004
    MOV R0,#display_list_offset_004
    MOV R0,#display_list_offset_004
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_008
    MOV R0,#display_list_offset_008
    MOV R0,#display_list_offset_008
    MOV R0,#display_list_offset_008
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_012
    MOV R0,#display_list_offset_012
    MOV R0,#display_list_offset_012
    MOV R0,#display_list_offset_012
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_016
    MOV R0,#display_list_offset_016
    MOV R0,#display_list_offset_016
    MOV R0,#display_list_offset_016
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_020
    MOV R0,#display_list_offset_020
    MOV R0,#display_list_offset_020
    MOV R0,#display_list_offset_020
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_024
    MOV R0,#display_list_offset_024
    MOV R0,#display_list_offset_024
    MOV R0,#display_list_offset_024
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    MOV R0,#display_list_offset_028
    MOV R0,#display_list_offset_028
    MOV R0,#display_list_offset_028
    MOV R0,#display_list_offset_028
    ;MOV R0,#display_list_offset_001
    ;MOV R0,#display_list_offset_002
    ;MOV R0,#display_list_offset_003
    
.balign 16
vdu_variables_screen_start:
    .4byte 0x00000095       ; display memory start address
    .4byte 0xffffffff

.balign 16
buffer:
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000
    .4byte 0x00000000

    .nolist
    
    .balign 16
    .include "include/grey.inc"
    .balign 16
    .include "include/blue.inc"

    .balign 16
display_list:
    .4byte grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000
    .4byte grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000
    .4byte grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000
    .4byte grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000
    .4byte grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000
    .4byte grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000
    .4byte grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000
    .4byte grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000
    .4byte grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000
    .4byte grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000
    .4byte grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000
    .4byte grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000
    .4byte grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000
    .4byte grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000
    .4byte grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000
    .4byte grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000
    .4byte grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000
    .4byte grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000
    .4byte grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000
    .4byte grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000
    .4byte grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000
    .4byte grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000
    .4byte grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000
    .4byte grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000
    .4byte grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000
    .4byte grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000
    .4byte grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000
    .4byte grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000
    .4byte grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000
    .4byte grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000
    .4byte grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000
    .4byte grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000
    .4byte 0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5)
    .4byte 0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5)
    .4byte 0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5)
    .4byte 0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5)
    .4byte 0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5)
    .4byte 0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5)
    .4byte 0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5)
    .4byte 0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5)
    .4byte 0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5)
    .4byte 0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5)
    .4byte 0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5)
    .4byte 0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5)
    .4byte 0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5)
    .4byte 0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5)
    .4byte 0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5)
    .4byte 0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5)
    .4byte 0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5)
    .4byte 0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5)
    .4byte 0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5)
    .4byte 0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5)
    .4byte 0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5)
    .4byte 0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5)
    .4byte 0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5)
    .4byte 0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5)
    .4byte 0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5)
    .4byte 0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5)
    .4byte 0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5)
    .4byte 0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5)
    .4byte 0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5)
    .4byte 0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5)
    .4byte 0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5)
    .4byte 0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5)
    .4byte grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000
    .4byte grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000
    .4byte grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000
    .4byte grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000
    .4byte grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000
    .4byte grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000
    .4byte grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000
    .4byte grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000
    .4byte grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000
    .4byte grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000
    .4byte grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000
    .4byte grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000
    .4byte grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000
    .4byte grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000
    .4byte grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000
    .4byte grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000
    .4byte grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000
    .4byte grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000
    .4byte grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000
    .4byte grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000
    .4byte grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000
    .4byte grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000
    .4byte grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000
    .4byte grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000
    .4byte grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000
    .4byte grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000
    .4byte grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000
    .4byte grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000
    .4byte grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000
    .4byte grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000
    .4byte grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000
    .4byte grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000
    .4byte 0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5)
    .4byte 0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5)
    .4byte 0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5)
    .4byte 0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5)
    .4byte 0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5)
    .4byte 0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5)
    .4byte 0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5)
    .4byte 0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5)
    .4byte 0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5)
    .4byte 0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5)
    .4byte 0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5)
    .4byte 0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5)
    .4byte 0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5)
    .4byte 0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5)
    .4byte 0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5)
    .4byte 0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5)
    .4byte 0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5)
    .4byte 0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5)
    .4byte 0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5)
    .4byte 0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5)
    .4byte 0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5)
    .4byte 0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5)
    .4byte 0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5)
    .4byte 0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5)
    .4byte 0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5)
    .4byte 0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5)
    .4byte 0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5)
    .4byte 0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5)
    .4byte 0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5)
    .4byte 0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5)
    .4byte 0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5)
    .4byte 0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5)
    .4byte grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000
    .4byte grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000
    .4byte grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000
    .4byte grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000
    .4byte grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000
    .4byte grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000
    .4byte grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000
    .4byte grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000
    .4byte grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000
    .4byte grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000
    .4byte grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000
    .4byte grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000
    .4byte grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000
    .4byte grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000
    .4byte grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000
    .4byte grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000
    .4byte grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000
    .4byte grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000
    .4byte grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000
    .4byte grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000
    .4byte grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000
    .4byte grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000
    .4byte grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000
    .4byte grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000
    .4byte grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000
    .4byte grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000
    .4byte grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000
    .4byte grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000
    .4byte grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000
    .4byte grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000
    .4byte grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000
    .4byte grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000
    .4byte 0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5)
    .4byte 0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5)
    .4byte 0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5)
    .4byte 0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5)
    .4byte 0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5)
    .4byte 0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5)
    .4byte 0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5)
    .4byte 0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5)
    .4byte 0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5)
    .4byte 0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5)
    .4byte 0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5)
    .4byte 0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5)
    .4byte 0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5)
    .4byte 0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5)
    .4byte 0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5)
    .4byte 0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5)
    .4byte 0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5)
    .4byte 0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5)
    .4byte 0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5)
    .4byte 0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5)
    .4byte 0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5)
    .4byte 0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5)
    .4byte 0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5)
    .4byte 0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5)
    .4byte 0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5)
    .4byte 0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5)
    .4byte 0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5)
    .4byte 0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5)
    .4byte 0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5)
    .4byte 0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5)
    .4byte 0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5)
    .4byte 0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5)
    .4byte grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000
    .4byte grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000
    .4byte grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000
    .4byte grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000
    .4byte grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000
    .4byte grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000
    .4byte grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000
    .4byte grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000
    .4byte grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000
    .4byte grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000
    .4byte grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000
    .4byte grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000
    .4byte grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000
    .4byte grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000
    .4byte grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000
    .4byte grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000
    .4byte grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000
    .4byte grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000
    .4byte grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000
    .4byte grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000
    .4byte grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000
    .4byte grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000
    .4byte grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000
    .4byte grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000
    .4byte grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000
    .4byte grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000
    .4byte grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000
    .4byte grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000
    .4byte grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000
    .4byte grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000
    .4byte grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000
    .4byte grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000
    .4byte 0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5),0x00000000,grey + (0 << 5)
    .4byte 0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5),0x00000000,grey + (1 << 5)
    .4byte 0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5),0x00000000,grey + (2 << 5)
    .4byte 0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5),0x00000000,grey + (3 << 5)
    .4byte 0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5),0x00000000,grey + (4 << 5)
    .4byte 0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5),0x00000000,grey + (5 << 5)
    .4byte 0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5),0x00000000,grey + (6 << 5)
    .4byte 0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5),0x00000000,grey + (7 << 5)
    .4byte 0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5),0x00000000,grey + (8 << 5)
    .4byte 0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5),0x00000000,grey + (9 << 5)
    .4byte 0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5),0x00000000,grey + (10 << 5)
    .4byte 0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5),0x00000000,grey + (11 << 5)
    .4byte 0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5),0x00000000,grey + (12 << 5)
    .4byte 0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5),0x00000000,grey + (13 << 5)
    .4byte 0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5),0x00000000,grey + (14 << 5)
    .4byte 0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5),0x00000000,grey + (15 << 5)
    .4byte 0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5),0x00000000,grey + (16 << 5)
    .4byte 0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5),0x00000000,grey + (17 << 5)
    .4byte 0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5),0x00000000,grey + (18 << 5)
    .4byte 0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5),0x00000000,grey + (19 << 5)
    .4byte 0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5),0x00000000,grey + (20 << 5)
    .4byte 0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5),0x00000000,grey + (21 << 5)
    .4byte 0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5),0x00000000,grey + (22 << 5)
    .4byte 0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5),0x00000000,grey + (23 << 5)
    .4byte 0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5),0x00000000,grey + (24 << 5)
    .4byte 0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5),0x00000000,grey + (25 << 5)
    .4byte 0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5),0x00000000,grey + (26 << 5)
    .4byte 0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5),0x00000000,grey + (27 << 5)
    .4byte 0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5),0x00000000,grey + (28 << 5)
    .4byte 0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5),0x00000000,grey + (29 << 5)
    .4byte 0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5),0x00000000,grey + (30 << 5)
    .4byte 0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5),0x00000000,grey + (31 << 5)

display_list_end:
    .space 40*256

sprite_list:
    .space 8*16,0x00
    .4byte a + (0 << 4), 32, 0x80000000 | a + (0 << 4), 200
    .4byte a + (1 << 4), 32, 0x80000000 | a + (0 << 4), 200
    .4byte a + (2 << 4), 32, 0x80000000 | a + (1 << 4), 200
    .4byte a + (3 << 4), 32, 0x80000000 | a + (1 << 4), 200
    .4byte a + (4 << 4), 32, 0x80000000 | a + (2 << 4), 200
    .4byte a + (5 << 4), 32, 0x80000000 | a + (2 << 4), 200
    .4byte a + (6 << 4), 32, 0x80000000 | a + (3 << 4), 200
    .4byte a + (7 << 4), 32, 0x80000000 | a + (3 << 4), 200
    .4byte a + (8 << 4), 32, 0x80000000 | a + (4 << 4), 200
    .4byte a + (9 << 4), 32, 0x80000000 | a + (4 << 4), 200
    .4byte a + (10 << 4), 32, 0x80000000 | a + (5 << 4), 200
    .4byte a + (11 << 4), 32, 0x80000000 | a + (5 << 4), 200
    .4byte a + (12 << 4), 32, 0x80000000 | a + (6 << 4), 200
    .4byte a + (13 << 4), 32, 0x80000000 | a + (6 << 4), 200
    .4byte a + (14 << 4), 32, 0x80000000 | a + (7 << 4), 200
    .4byte a + (15 << 4), 32, 0x80000000 | a + (7 << 4), 200
    .4byte a + (15 << 4), 32, 0x80000000 | a + (8 << 4), 200
    .4byte a + (14 << 4), 32, 0x80000000 | a + (8 << 4), 200
    .4byte a + (13 << 4), 32, 0x80000000 | a + (9 << 4), 200
    .4byte a + (12 << 4), 32, 0x80000000 | a + (9 << 4), 200
    .4byte a + (11 << 4), 32, 0x80000000 | a + (10 << 4), 200
    .4byte a + (10 << 4), 32, 0x80000000 | a + (10 << 4), 200
    .4byte a + (9 << 4), 32, 0x80000000 | a + (11 << 4), 200
    .4byte a + (8 << 4), 32, 0x80000000 | a + (11 << 4), 200
    .4byte a + (7 << 4), 32, 0x80000000 | a + (12 << 4), 200
    .4byte a + (6 << 4), 32, 0x80000000 | a + (12 << 4), 200
    .4byte a + (5 << 4), 32, 0x80000000 | a + (13 << 4), 200
    .4byte a + (4 << 4), 32, 0x80000000 | a + (13 << 4), 200
    .4byte a + (3 << 4), 32, 0x80000000 | a + (14 << 4), 200
    .4byte a + (2 << 4), 32, 0x80000000 | a + (14 << 4), 200
    .4byte a + (1 << 4), 32, 0x80000000 | a + (15 << 4), 200
    .4byte a + (0 << 4), 32, 0x80000000 | a + (15 << 4), 200
    .space 8*16,0x00
    .4byte a + (0 << 4), 32, 0x80000000 | a + (0 << 4), 200
    .4byte a + (1 << 4), 32, 0x80000000 | a + (0 << 4), 200
    .4byte a + (2 << 4), 32, 0x80000000 | a + (1 << 4), 200
    .4byte a + (3 << 4), 32, 0x80000000 | a + (1 << 4), 200
    .4byte a + (4 << 4), 32, 0x80000000 | a + (2 << 4), 200
    .4byte a + (5 << 4), 32, 0x80000000 | a + (2 << 4), 200
    .4byte a + (6 << 4), 32, 0x80000000 | a + (3 << 4), 200
    .4byte a + (7 << 4), 32, 0x80000000 | a + (3 << 4), 200
    .4byte a + (8 << 4), 32, 0x80000000 | a + (4 << 4), 200
    .4byte a + (9 << 4), 32, 0x80000000 | a + (4 << 4), 200
    .4byte a + (10 << 4), 32, 0x80000000 | a + (5 << 4), 200
    .4byte a + (11 << 4), 32, 0x80000000 | a + (5 << 4), 200
    .4byte a + (12 << 4), 32, 0x80000000 | a + (6 << 4), 200
    .4byte a + (13 << 4), 32, 0x80000000 | a + (6 << 4), 200
    .4byte a + (14 << 4), 32, 0x80000000 | a + (7 << 4), 200
    .4byte a + (15 << 4), 32, 0x80000000 | a + (7 << 4), 200
    .4byte a + (15 << 4), 32, 0x80000000 | a + (8 << 4), 200
    .4byte a + (14 << 4), 32, 0x80000000 | a + (8 << 4), 200
    .4byte a + (13 << 4), 32, 0x80000000 | a + (9 << 4), 200
    .4byte a + (12 << 4), 32, 0x80000000 | a + (9 << 4), 200
    .4byte a + (11 << 4), 32, 0x80000000 | a + (10 << 4), 200
    .4byte a + (10 << 4), 32, 0x80000000 | a + (10 << 4), 200
    .4byte a + (9 << 4), 32, 0x80000000 | a + (11 << 4), 200
    .4byte a + (8 << 4), 32, 0x80000000 | a + (11 << 4), 200
    .4byte a + (7 << 4), 32, 0x80000000 | a + (12 << 4), 200
    .4byte a + (6 << 4), 32, 0x80000000 | a + (12 << 4), 200
    .4byte a + (5 << 4), 32, 0x80000000 | a + (13 << 4), 200
    .4byte a + (4 << 4), 32, 0x80000000 | a + (13 << 4), 200
    .4byte a + (3 << 4), 32, 0x80000000 | a + (14 << 4), 200
    .4byte a + (2 << 4), 32, 0x80000000 | a + (14 << 4), 200
    .4byte a + (1 << 4), 32, 0x80000000 | a + (15 << 4), 200
    .4byte a + (0 << 4), 32, 0x80000000 | a + (15 << 4), 200
    .space 8*16,0x00
    .4byte a + (0 << 4), 32, 0x80000000 | a + (0 << 4), 200
    .4byte a + (1 << 4), 32, 0x80000000 | a + (0 << 4), 200
    .4byte a + (2 << 4), 32, 0x80000000 | a + (1 << 4), 200
    .4byte a + (3 << 4), 32, 0x80000000 | a + (1 << 4), 200
    .4byte a + (4 << 4), 32, 0x80000000 | a + (2 << 4), 200
    .4byte a + (5 << 4), 32, 0x80000000 | a + (2 << 4), 200
    .4byte a + (6 << 4), 32, 0x80000000 | a + (3 << 4), 200
    .4byte a + (7 << 4), 32, 0x80000000 | a + (3 << 4), 200
    .4byte a + (8 << 4), 32, 0x80000000 | a + (4 << 4), 200
    .4byte a + (9 << 4), 32, 0x80000000 | a + (4 << 4), 200
    .4byte a + (10 << 4), 32, 0x80000000 | a + (5 << 4), 200
    .4byte a + (11 << 4), 32, 0x80000000 | a + (5 << 4), 200
    .4byte a + (12 << 4), 32, 0x80000000 | a + (6 << 4), 200
    .4byte a + (13 << 4), 32, 0x80000000 | a + (6 << 4), 200
    .4byte a + (14 << 4), 32, 0x80000000 | a + (7 << 4), 200
    .4byte a + (15 << 4), 32, 0x80000000 | a + (7 << 4), 200
    .4byte a + (15 << 4), 32, 0x80000000 | a + (8 << 4), 200
    .4byte a + (14 << 4), 32, 0x80000000 | a + (8 << 4), 200
    .4byte a + (13 << 4), 32, 0x80000000 | a + (9 << 4), 200
    .4byte a + (12 << 4), 32, 0x80000000 | a + (9 << 4), 200
    .4byte a + (11 << 4), 32, 0x80000000 | a + (10 << 4), 200
    .4byte a + (10 << 4), 32, 0x80000000 | a + (10 << 4), 200
    .4byte a + (9 << 4), 32, 0x80000000 | a + (11 << 4), 200
    .4byte a + (8 << 4), 32, 0x80000000 | a + (11 << 4), 200
    .4byte a + (7 << 4), 32, 0x80000000 | a + (12 << 4), 200
    .4byte a + (6 << 4), 32, 0x80000000 | a + (12 << 4), 200
    .4byte a + (5 << 4), 32, 0x80000000 | a + (13 << 4), 200
    .4byte a + (4 << 4), 32, 0x80000000 | a + (13 << 4), 200
    .4byte a + (3 << 4), 32, 0x80000000 | a + (14 << 4), 200
    .4byte a + (2 << 4), 32, 0x80000000 | a + (14 << 4), 200
    .4byte a + (1 << 4), 32, 0x80000000 | a + (15 << 4), 200
    .4byte a + (0 << 4), 32, 0x80000000 | a + (15 << 4), 200
    .space 256*16,0x00
sprite_list_end:

test_sprite:
    .include "include/redball.inc"
    .include "include/greenball.inc"
    .include "include/blueball.inc"
    .include "include/a.inc"

; reserve 256 bytes for a stack
.space 256
stack:

