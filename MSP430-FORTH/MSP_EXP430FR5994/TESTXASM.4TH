
; -----------------------------------------------------------------------
; TESTXASM.4th
; -----------------------------------------------------------------------

ECHO

PWR_STATE

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES IV : Adda|Cmpa|Mova|Suba (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

HERE
CODE TEST
MOVA @R10,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
MOVA @R11+,R10
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>1A 0B<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
MOVA &$1.2345,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>2B 01 45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA $.1234(R10),R12
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>3C 0A 34 12<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA R11,&$1.2345
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>61 0B 45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA R12,$.1234(R10)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>7A 0C 34 12<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA #$0.1,R12
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>8C 00 01 00<04 44 55 4D
PWR_STATE

HERE
CODE TEST
CMPA #$1.2345,R12
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>9C 01 45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
ADDA #$2.3456,R12
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>AC 02 56 34<04 44 55 4D
PWR_STATE

HERE
CODE TEST
SUBA #$3.4567,R12
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>BC 03 67 45<04 44 55 4D
PWR_STATE



HERE
CODE TEST
MOVA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>CB 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CMPA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>DB 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
ADDA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>EB 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
SUBA R10,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>FB 0A<04 44 55 4D 50 4F
PWR_STATE

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: CALLA (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

HERE
CODE TEST
CALLA R10
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>4A 13<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CALLA $.3456(R10)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>5A 13 56 34<04 44 55 4D
PWR_STATE

HERE
CODE TEST
CALLA @R10
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>6A 13<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CALLA @R10+
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>7A 13<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CALLA &$2.3456
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>82 13 56 34<04 44 55 4D
PWR_STATE

HERE
CODE TEST
CALLA #$5.6789
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>B5 13 89 67<04 44 55 4D
PWR_STATE

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES V extended double operand
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

HERE
CODE TEST
MOV R12,R11
MOVX R12,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 4C 40 18 0B 4C<04 44
PWR_STATE

HERE
CODE TEST
ADD R11,R11
ADDX.A R11,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 5B 00 18 4B 5B<04 44
PWR_STATE

HERE
CODE TEST
ADD R11,R11
RPT R9
ADDX.A R11,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 5B 89 18 4B 5B<04 44
PWR_STATE

HERE
CODE TEST
ADD R11,R11
RPT #8
ADDX.A R11,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 5B 07 18 4B 5B<04 44
PWR_STATE

HERE
CODE TEST
ADDC #$9876,R11
ADDCX.A #$5.9876,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>3B 60 76 98 80 1A 7B 60
;     76 98<04 44 55 4D
PWR_STATE

HERE
CODE TEST
ADDC &$9876,R11
ADDCX.A &$5.9876,R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>1B 62 76 98 80 1A 5B 62
;     76 98<04 44 55 4D
PWR_STATE

HERE
CODE TEST
XOR.B $5432(R12),R11
XORX.B $6.5432(R12),R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>5B EC 32 54 46 18 5B EC
;     32 54<04 44 55 4D
PWR_STATE

HERE
CODE TEST
SUBC R11,$5432(R12)
SUBCX.A R11,$6.5432(R12)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>8C 7B 32 54 06 18 CC 7B
;     32 54<04 44 55 4D
PWR_STATE

HERE
CODE TEST
XOR.B R11,$5432(R12)
XORX.B R11,$6.5432(R12)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>CC EB 32 54 46 18 CC EB
;     32 54<04 44 55 4D
PWR_STATE

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES VI extended single operand (take count of RPT)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

HERE
CODE TEST
RRA R9
RRAX R9
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>09 11 40 18 09 11<04 44
PWR_STATE

HERE
CODE TEST
RRC @R9
RRCX.A @R9
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>29 10 00 18 69 10<04 44
PWR_STATE

HERE
CODE TEST
RRC @R12
RRCX.A @R12
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>2C 10 00 18 6C 10<04 44
PWR_STATE

HERE
CODE TEST
RRC @R9+
RRUX.A @R9+
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>39 10 00 19 79 10<04 44
PWR_STATE

HERE
CODE TEST
RRC R11
RPT #9
RRUX.A R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 10 08 19 4B 10<04 44
PWR_STATE

HERE
CODE TEST
RRC R11
RPT R9
RRUX.A R11
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 10 89 19 4B 10<04 44
PWR_STATE

HERE
CODE TEST
PUSH #$2345
PUSHX #$0.2345
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>30 12 45 23 40 18 30 12
;     45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
PUSH &$5678
PUSHX.A &$4.5678
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>12 12 78 56 00 1A 52 12
;     78 56<04 44 55 4D
PWR_STATE

HERE
CODE TEST
PUSH.B &$33
PUSHX.B &$.33
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>52 12 33 00 40 18 52 12
;     33 00<04 44 55 4D
PWR_STATE

HERE
CODE TEST
PUSH.B $3344(R11)
PUSHX.B $.3344(R11)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>5B 12 44 33 40 18 5B 12
;     44 33<04 44 55 4D
PWR_STATE



: %.
BASE @ %10 BASE ! SWAP 8 EMIT . BASE !
;

: %U.
BASE @ %10 BASE ! SWAP 8 EMIT U. BASE ! ;

PWR_HERE


; ================
; RRUX test
; ================


CODE RRUX_T
MOVX #$.F0F0,R8
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRUX_T ; you should see %111100001111000 --> %

PWR_STATE

; ================
; RRUX repeat test
; ================


CODE RRUX_T
MOV #$F0F0,R8
RPT #0
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRUX_T ; you should see %111100001111000 --> %

PWR_STATE

CODE RRUX_T
MOV #$F0F0,R8
RPT #3
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRUX_T ; you should see %111100001111 --> %

PWR_STATE

CODE RRUX_T
MOV #$F0F0,R8
RPT #7
RRUX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRUX_T ; you should see %11110000 --> %

PWR_STATE


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
JMP %U.
ENDCODE

RRCX_T ; you should see %100000000000000 --> %

PWR_STATE

; ================
; RRCX repeat test
; ================

CODE RRCX_T
MOV #$8000,R8
BIC #1,R2
RPT #0
RRCX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %U.
ENDCODE

RRCX_T ; you should see %100000000000000 --> %

PWR_STATE

CODE RRCX_T
MOV #$8000,R8
BIC #1,R2
RPT #7
RRCX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %U.
ENDCODE

RRCX_T ; you should see %10000000 --> %

PWR_STATE

; ================
; RRAX test
; ================


CODE RRAX_T
MOV #$8000,R8
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRAX_T ; you should see %-100000000000000 --> %

PWR_STATE

; ================
; RRAX repeat test
; ================


CODE RRAX_T
MOV #$8000,R8
RPT #0
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRAX_T ; you should see %-100000000000000 --> %

PWR_STATE

CODE RRAX_T
MOV #$8000,R8
RPT #1
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRAX_T ; you should see %-10000000000000 --> %

PWR_STATE

CODE RRAX_T
MOV #$8000,R8
RPT #2
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRAX_T ; you should see %-1000000000000 --> %

PWR_STATE

CODE RRAX_T
MOV #$8000,R8
RPT #6
RRAX R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
JMP %.
ENDCODE

RRAX_T ; you should see %-100000000 --> %

PWR_STATE

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

PWR_STATE

; ================
; RLAX repeat test
; ================


CODE RLAX_T
MOV #-1,R8
RPT #0
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -2 -->

PWR_STATE

CODE RLAX_T
MOV #-1,R8
RPT #1
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -4 -->

PWR_STATE

CODE RLAX_T
MOV #-1,R8
RPT #2
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -8 -->

PWR_STATE

CODE RLAX_T
MOV #-1,R8
RPT #7
ADDX R8,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

RLAX_T ; you should see -256 -->

PWR_STATE

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

PWR_STATE

; ================
; ADDX repeat test
; ================


CODE ADDX_T
MOV #0,R8
MOV #-1,R9
RPT #0
ADDX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

ADDX_T ; you should see -1 -->

PWR_STATE

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

ADDX_T ; you should see -2 -->

PWR_STATE

CODE ADDX_T
MOV #0,R8
MOV #-1,R9
RPT #7
ADDX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

ADDX_T ; you should see -8 -->

PWR_STATE


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

PWR_STATE

; ================
; SUBX repeat test
; ================


CODE SUBX_T
MOV #0,R8
MOV #-1,R9
RPT #0
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 1 -->

PWR_STATE

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

SUBX_T ; you should see 2 -->

PWR_STATE

CODE SUBX_T
MOV #0,R8
MOV #-1,R9
RPT #7
SUBX R9,R8
SUB #2,R15
MOV R14,0(R15)
MOV R8,R14
MOV #.,R0
ENDCODE

SUBX_T ; you should see 8 -->

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

