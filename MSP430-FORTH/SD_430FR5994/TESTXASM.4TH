
; -----------------------------------------------------------------------
; TESTXASM.4th for MSP_EXP430FR5994
; -----------------------------------------------------------------------

    CODE ABORT_TEST_ASMX
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #400,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.0 please!"
    RST_RET
    ;

    ABORT_TEST_ASMX

    MARKER {TEST_ASMX}

    [UNDEFINED] +
    [IF]
    CODE +
    ADD @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] -
    [IF]
    CODE -
    SUB @R15+,R14
    XOR #-1,R14
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] MAX
    [IF]
    CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
    ENDCODE

    CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] C@
    [IF]
    CODE C@
    MOV.B @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CONSTANT
    [IF]
    : CONSTANT
    CREATE
    HI2LO
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] SPACE
    [IF]
    : SPACE
    $20 EMIT ;
    [THEN]

    [UNDEFINED] SPACES
    [IF]
    CODE SPACES
    CMP #0,R14
    0<> IF
        PUSH R13
        BEGIN
            LO2HI
            $20 EMIT
            HI2LO
            SUB #2,R13
            SUB #1,R14
        0= UNTIL
        MOV @R1+,R13
    THEN
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] OVER
    [IF]
    CODE OVER
    MOV R14,-2(R15)
    MOV @R15,R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    MOV @R15,R10
    MOV R14,0(R15)
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] >R
    [IF]
    CODE >R
    PUSH R14
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] R>
    [IF]
    CODE R>
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] U.R
    [IF]
    : U.R
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    [UNDEFINED] DO
    [IF]

    HDNCODE XDO
    MOV #$8000,R9
    SUB @R15+,R9
    MOV R14,R8
    ADD R9,R8
    PUSHM #2,R9
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE

    CODE DO
    SUB #2,R15
    MOV R14,0(R15)
    ADD #2,&$1DC0
    MOV &$1DC0,R14
    MOV #XDO,-2(R14)
    ADD #2,&$1C00
    MOV &$1C00,R10
    MOV #0,0(R10)
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    HDNCODE XLOOP
    ADD #1,0(R1)
BW1 BIT #$100,R2
    0= IF
        MOV @R13,R13
        MOV @R13+,R0
    THEN
    ADD #4,R1
    ADD #2,R13
    MOV @R13+,R0
    ENDCODE

    CODE LOOP
    MOV #XLOOP,R9
BW2 ADD #4,&$1DC0
    MOV &$1DC0,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    BEGIN
        MOV &$1C00,R14
        SUB #2,&$1C00
        MOV @R14,R14
        CMP #0,R14
    0<> WHILE
        MOV R10,0(R14)
    REPEAT
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    HDNCODE XPLOO
    ADD R14,0(R1)
    MOV @R15+,R14
    GOTO BW1
    ENDCODE

    CODE +LOOP
    MOV #XPLOO,R9
    GOTO BW2
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] I
    [IF]
    CODE I
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1,R14
    SUB 2(R1),R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #$409E,R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] BASE
    [IF]
    $1DB6  CONSTANT BASE
    [THEN]

    [UNDEFINED] DUMP
    [IF]
    CODE DUMP
    PUSH R13
    PUSH &BASE
    MOV #$10,&BASE
    ADD @R15,R14
    LO2HI
    SWAP
    DO  CR
        I 4 U.R SPACE
        I 8 + I
        DO I C@ 3 U.R LOOP
        SPACE
        I $10 + I 8 +
        DO I C@ 3 U.R LOOP
        SPACE SPACE
        I $10 + I
        DO I C@ $7E MIN $20 MAX EMIT LOOP
    $10 +LOOP
    R> BASE !
    ;
    [THEN]

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #BEGIN,R0
    ENDCODE
    [THEN]

    RST_SET


    ECHO

; -----------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: CALLA (without extended word)
; -----------------------------------------------------------------------------
; absolute and immediate instructs. must be written as $x.xxxx (DOUBLE numbers)
; indexed instructions must be written as $xxxx(REG) (single numbers)
; -----------------------------------------------------------------------------

HERE
CODE TT
CALLA R10
ENDCODE
HERE OVER - DUMP
; you should see:       4A 13
RST_RET

HERE
CODE TT
CALLA $3456(R10)
ENDCODE
HERE OVER - DUMP
; you should see:       5A 13  56 34
RST_RET

HERE
CODE TT
CALLA 0(R15)
ENDCODE
HERE OVER - DUMP
; you should see:       5F 13  00 00
RST_RET

HERE
CODE TT
CALLA @R10
ENDCODE
HERE OVER - DUMP
; you should see:       6A 13
RST_RET

HERE
CODE TT
CALLA @R15
ENDCODE
HERE OVER - DUMP
; you should see:       6F 13
RST_RET

HERE
CODE TT
CALLA @R10+
ENDCODE
HERE OVER - DUMP
; you should see:       7A 13
RST_RET

HERE
CODE TT
CALLA &$2.3456
ENDCODE
HERE OVER - DUMP
; you should see:       82 13  56 34
RST_RET

HERE
CODE TT
CALLA #$5.6789
ENDCODE
HERE OVER - DUMP
; you should see:       B5 13  89 67
RST_RET

; -----------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES IV : Adda|Cmpa|Mova|Suba
; -----------------------------------------------------------------------------
; absolute and immediate instructs. must be written as $x.xxxx (DOUBLE numbers)
; indexed instructions must be written as $xxxx(REG) (single numbers)
; -----------------------------------------------------------------------------

HERE
CODE TT
MOVA @R10,R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 0A
RST_RET

HERE
CODE TT
MOVA @R11+,R10
ENDCODE
HERE OVER - DUMP
; you should see:       1A 0B
RST_RET

HERE
CODE TT
MOVA &$1.2345,R11
ENDCODE
HERE OVER - DUMP
; you should see:       2B 01  45 23
RST_RET

HERE
CODE TT
MOVA 2(R15),R14
ENDCODE
HERE OVER - DUMP
; you should see:       3E 0F  02 00
RST_RET

HERE
CODE TT
MOVA $1234(R10),R12
ENDCODE
HERE OVER - DUMP
; you should see:       3C 0A  34 12
RST_RET

HERE
CODE TT
MOVA R11,&$1.2345
ENDCODE
HERE OVER - DUMP
; you should see:       61 0B  45 23
RST_RET

HERE
CODE TT
MOVA R14,0(R15)
ENDCODE
HERE OVER - DUMP
; you should see:       7F 0E  00 00
RST_RET

HERE
CODE TT
MOVA R12,$1234(R10)
ENDCODE
HERE OVER - DUMP
; you should see:       7A 0C  34 12
RST_RET

HERE
CODE TT
MOVA #$.1,R12
ENDCODE
HERE OVER - DUMP
; you should see:       8C 00  01 00
RST_RET

HERE
CODE TT
CMPA #$1.2345,R12
ENDCODE
HERE OVER - DUMP
; you should see:       9C 01  45 23
RST_RET

HERE
CODE TT
ADDA #$2.3456,R12
ENDCODE
HERE OVER - DUMP
; you should see:       AC 02  56 34
RST_RET

HERE
CODE TT
SUBA #$3.4567,R12
ENDCODE
HERE OVER - DUMP
; you should see:       BC 03  67 45
RST_RET

HERE
CODE TT
MOVA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see:       CB 0A
RST_RET

HERE
CODE TT
CMPA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see:       DB 0A
RST_RET

HERE
CODE TT
ADDA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see:       EB 0A
RST_RET

HERE
CODE TT
SUBA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see:       FB 0A
RST_RET

; -----------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES V extended double operand
; -----------------------------------------------------------------------------
; absolute and immediate instructs. must be written as $x.xxxx (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; -----------------------------------------------------------------------------

HERE
CODE TT
MOV R12,R11
MOVX R12,R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 4C  40 18 0B 4C
RST_RET

HERE
CODE TT
ADD R11,R11
ADDX.A R11,R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 5B  00 18 4B 5B
RST_RET

HERE
CODE TT
ADD R11,R11
RPT R9
ADDX.A R11,R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 5B  89 18 4B 5B
RST_RET

HERE
CODE TT
ADD R11,R11
RPT #8
ADDX.A R11,R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 5B  07 18 4B 5B
RST_RET

HERE
CODE TT
ADDC #$9876,R11
ADDCX.A #$5.9876,R11
ENDCODE
HERE OVER - DUMP
; you should see:       3B 60  76 98 80 1A 7B 60 76 98
RST_RET

HERE
CODE TT
ADDC &$9876,R11
ADDCX.A &$5.9876,R11
ENDCODE
HERE OVER - DUMP
; you should see:       1B 62  76 98 80 1A 5B 62 76 98
RST_RET

HERE
CODE TT
XOR.B $5432(R12),R11
XORX.B $6.5432(R12),R11
ENDCODE
HERE OVER - DUMP
; you should see:       5B EC  32 54 46 18 5B EC 32 54
RST_RET

HERE
CODE TT
SUBC R11,$5432(R12)
SUBCX.A R11,$6.5432(R12)
ENDCODE
HERE OVER - DUMP
; you should see:       8C 7B  32 54 06 18 CC 7B 32 54
RST_RET

HERE
CODE TT
XOR.B R11,$5432(R12)
XORX.B R11,$6.5432(R12)
ENDCODE
HERE OVER - DUMP
; you should see:       CC EB  32 54 46 18 CC EB 32 54
RST_RET

; -----------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES VI extended single operand
; -----------------------------------------------------------------------------
; absolute and immediate instructs. must be written as $x.xxxx (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; -----------------------------------------------------------------------------

HERE
CODE TT
RRA R9
RRAX R9
ENDCODE
HERE OVER - DUMP
; you should see:       09 11  40 18 09 11
RST_RET

HERE
CODE TT
RRC @R9
RRCX.A @R9
ENDCODE
HERE OVER - DUMP
; you should see:       29 10  00 18 69 10
RST_RET

HERE
CODE TT
RRC @R12
RRCX.A @R12
ENDCODE
HERE OVER - DUMP
; you should see:       2C 10  00 18 6C 10
RST_RET

HERE
CODE TT
RRC @R9+
RRUX.A @R9+
ENDCODE
HERE OVER - DUMP
; you should see:       39 10  00 19 79 10
RST_RET

HERE
CODE TT
RRC R11
RPT #9
RRUX.A R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 10  08 19 4B 10
RST_RET

HERE
CODE TT
RRC R11
RPT R9
RRUX.A R11
ENDCODE
HERE OVER - DUMP
; you should see:       0B 10  89 19 4B 10
RST_RET

HERE
CODE TT
PUSH #$2345
PUSHX #$0.2345
ENDCODE
HERE OVER - DUMP
; you should see:       30 12  45 23 40 18 30 12 45 23
RST_RET

HERE
CODE TT
PUSH &$5678
PUSHX.A &$4.5678
ENDCODE
HERE OVER - DUMP
; you should see:       12 12  78 56 00 1A 52 12 78 56
RST_RET

HERE
CODE TT
PUSH.B &$33
PUSHX.B &$.33
ENDCODE
HERE OVER - DUMP
; you should see:       52 12  33 00 40 18 52 12 33 00
RST_RET

HERE
CODE TT
PUSH.B $3344(R11)
PUSHX.B $.3344(R11)
ENDCODE
HERE OVER - DUMP
; you should see:       5B 12  44 33 40 18 5B 12 44 33
RST_RET

    [UNDEFINED] BASE
    [IF]
    ' # 2 +  CONSTANT BASE
    [THEN]



: %.
BASE @ %10 BASE ! SWAP 8 EMIT . BASE !
RST_RET
;

: %U.
BASE @ %10 BASE ! SWAP 8 EMIT U. BASE !
RST_RET
;

RST_SET

; ================
; RRUX test
; ================


CODE RRUX_T
MOVX #$.F0F0,R8
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRUX_T ;            %
; you should see:   %111100001111000

; ================
; RRUX repeat test
; ================


CODE RRUX_T
MOV #$F0F0,R8
RPT #1
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRUX_T ;            %
; you should see:   %111100001111000

CODE RRUX_T
MOV #$F0F0,R8
RPT #4
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRUX_T ; -->        %
; you should see:   %111100001111

CODE RRUX_T
MOV #$F0F0,R8
RPT #8
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRUX_T ;            %
; you should see:   %11110000

; ================
; RRCX test
; ================

CODE RRCX_T
MOV #$8000,R8
BIC #1,R2
RRCX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%U.,R0
ENDCODE

RRCX_T ;            %
; you should see:   %100000000000000

; ================
; RRCX repeat test
; ================

CODE RRCX_T
MOV #$8000,R8
BIC #1,R2
RPT #1
RRCX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%U.,R0
ENDCODE

RRCX_T ;            %
; you should see:   %100000000000000

CODE RRCX_T
MOV #$8000,R8
BIC #1,R2
RPT #8
RRCX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%U.,R0
ENDCODE

RRCX_T ;            %
; you should see:   %10000000

; ================
; RRAX test
; ================

CODE RRAX_T
MOV #$8000,R8
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRAX_T ;            %
; you should see:   %-100000000000000

; ================
; RRAX repeat test
; ================


CODE RRAX_T
MOV #$8000,R8
RPT #1
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRAX_T ;            %
; you should see:   %-100000000000000

CODE RRAX_T
MOV #$8000,R8
RPT #2
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRAX_T ;            %
; you should see:   %-10000000000000

CODE RRAX_T
MOV #$8000,R8
RPT #3
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRAX_T ;            %
; you should see:   %-1000000000000

CODE RRAX_T
MOV #$8000,R8
RPT #7
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #%.,R0
ENDCODE

RRAX_T ;            %
; you should see:   %-100000000

; ================
; RLAX test
; ================


CODE RLAX_T
MOV #-1,R8
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -2 -->

; ================
; RLAX repeat test
; ================


CODE RLAX_T
MOV #-1,R8
RPT #1
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -2 -->

CODE RLAX_T
MOV #-1,R8
RPT #2
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -4 -->

CODE RLAX_T
MOV #-1,R8
RPT #3
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -8 -->

CODE RLAX_T
MOV #-1,R8
RPT #8
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -256 -->

; ================
; ADDX test
; ================


CODE ADDX_T
MOV #0,R8
MOV #-1,R9
ADDX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

ADDX_T ; you should see -1 -->

; ================
; ADDX repeat test
; ================


CODE ADDX_T
MOV #0,R8
MOV #-1,R9
RPT #1
ADDX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

ADDX_T ; you should see -1 -->

CODE ADDX_T
MOV #0,R8
MOV #-1,R9
RPT #2
ADDX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

ADDX_T ; you should see -2 -->

CODE ADDX_T
MOV #0,R8
MOV #-1,R9
RPT #8
ADDX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

ADDX_T ; you should see -8 -->

; ================
; SUBX test
; ================


CODE SUBX_T
MOV #0,R8
MOV #-1,R9
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 1 -->

; ================
; SUBX repeat test
; ================


CODE SUBX_T
MOV #0,R8
MOV #-1,R9
RPT #1
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 1 -->

CODE SUBX_T
MOV #0,R8
MOV #-1,R9
RPT #2
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 2 -->

CODE SUBX_T
MOV #0,R8
MOV #-1,R9
RPT #8
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 8 -->

CODE SUBX_T
MOV #15,R10
MOV #0,R8
MOV #-1,R9
RPT R10
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 16 -->

CODE SUBX_T
MOV #32,R10
MOV #0,R8
MOV #-1,R9
RPT R10
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 1 -->

CODE SUBX_T
MOV #33,R10
MOV #0,R8
MOV #-1,R9
RPT R10
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 2 -->

{TEST_ASMX}
