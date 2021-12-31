\ -*- coding: utf-8 -*-

; -----------------------------------------------------------------------
; TESTXASM.f
; -----------------------------------------------------------------------
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2355
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\
\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack
\
\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before ?JMP ?GOTO    : S< S>= U< U>= 0= 0<> 0<
\
\ FORTH conditionnal    : 0= 0< = < > U<

    CODE ABORT_TEST_ASMX
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #309,TOS        \                   FastForth V3.9
    COLON
    'CR' EMIT            \ return to column 1 without 'LF'
    ABORT" FastForth V3.9 please!"
    RST_RET              \ remove ABORT_TEST_ASM definition before resuming
    ;

    ABORT_TEST_ASMX      \ abort test

    MARKER {TEST_ASMX}

\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    [UNDEFINED] +
    [IF]
    CODE +
    ADD @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Minus
\ -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
    [UNDEFINED] -
    [IF]
    CODE -
    SUB @PSP+,TOS   \ 2  -- n2-n1 ( = -n3)
    XOR #-1,TOS     \ 1
    ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] MAX
    [IF]    \ define MAX and MIN
    CODE MAX    \    n1 n2 -- n3       signed maximum
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
    ENDCODE

    CODE MIN    \    n1 n2 -- n3       signed minimum
    CMP @PSP,TOS     \ n2-n1
    S<  ?GOTO BW1    \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
    [UNDEFINED] C@
    [IF]
    CODE C@
    MOV.B @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT
    [UNDEFINED] CONSTANT
    [IF]
    : CONSTANT
    CREATE
    HI2LO
    MOV TOS,-2(W)           \   PFA = n
    MOV @PSP+,TOS
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
    [UNDEFINED] SPACE
    [IF]
    : SPACE
    $20 EMIT ;
    [THEN]

\ https://forth-standard.org/standard/core/SPACES
\ SPACES   n --            output n spaces
    [UNDEFINED] SPACES
    [IF]
    CODE SPACES
    CMP #0,TOS
    0<> IF
        PUSH IP
        BEGIN
            LO2HI
            $20 EMIT
            HI2LO
            SUB #2,IP
            SUB #1,TOS
        0= UNTIL
        MOV @RSP+,IP
    THEN
    MOV @PSP+,TOS           \ --         drop n
    NEXT
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/OVER
\ OVER    x1 x2 -- x1 x2 x1
    [UNDEFINED] OVER
    [IF]
    CODE OVER
    MOV TOS,-2(PSP)     \ 3 -- x1 (x2) x2
    MOV @PSP,TOS        \ 2 -- x1 (x2) x1
    SUB #2,PSP          \ 1 -- x1 x2 x1
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    MOV @PSP,W      \ 2
    MOV TOS,0(PSP)  \ 3
    MOV W,TOS       \ 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
    [UNDEFINED] >R
    [IF]
    CODE >R
    PUSH TOS
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
    [UNDEFINED] R>
    [IF]
    CODE R>
    SUB #2,PSP      \ 1
    MOV TOS,0(PSP)  \ 3
    MOV @RSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] U.R
    [IF]        \ defined in {UTILITY}
    : U.R       \ u n --           display u unsigned in n width (n >= 2)
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    [UNDEFINED] DO
    [IF]     \ define DO LOOP +LOOP

\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
    HDNCODE XDO         \ DO run time
    MOV #$8000,X        \ 2 compute 8000h-limit = "fudge factor"
    SUB @PSP+,X         \ 2
    MOV TOS,Y           \ 1 loop ctr = index+fudge
    ADD X,Y             \ 1 Y = INDEX
    PUSHM #2,X          \ 4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
    MOV @PSP+,TOS       \ 2
    MOV @IP+,PC         \ 4
    ENDCODE

    CODE DO
    SUB #2,PSP          \
    MOV TOS,0(PSP)      \
    ADD #2,&DP          \   make room to compile xdo
    MOV &DP,TOS         \ -- HERE+2
    MOV #XDO,-2(TOS)    \   compile xdo
    ADD #2,&LEAVEPTR    \ -- HERE+2     LEAVEPTR+2
    MOV &LEAVEPTR,W     \
    MOV #0,0(W)         \ -- HERE+2     L-- 0, init
    MOV @IP+,PC
    ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/LOOP
\ LOOP    DOadr --         L-- an an-1 .. a1 0
    HDNCODE XLOOP       \   LOOP run time
    ADD #1,0(RSP)       \ 4 increment INDEX
BW1 BIT #$100,SR        \ 2 is overflow bit set?
    0= IF               \   branch if no overflow
        MOV @IP,IP
        MOV @IP+,PC
    THEN
    ADD #4,RSP          \ 1 empties RSP
    ADD #2,IP           \ 1 overflow = loop done, skip branch ofs
    MOV @IP+,PC         \ 4 14~ taken or not taken xloop/loop
    ENDCODE             \

    CODE LOOP
    MOV #XLOOP,X
BW2 ADD #4,&DP          \ make room to compile two words
    MOV &DP,W
    MOV X,-4(W)         \ xloop --> HERE
    MOV TOS,-2(W)       \ DOadr --> HERE+2
    BEGIN                   \ resolve all "leave" adr
        MOV &LEAVEPTR,TOS   \ -- Adr of top LeaveStack cell
        SUB #2,&LEAVEPTR    \ --
        MOV @TOS,TOS        \ -- first LeaveStack value
        CMP #0,TOS          \ -- = value left by DO ?
    0<> WHILE
        MOV W,0(TOS)        \ move adr after loop as UNLOOP adr
    REPEAT
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/PlusLOOP
\ +LOOP   adrs --   L-- an an-1 .. a1 0
    HDNCODE XPLOO   \   +LOOP run time
    ADD TOS,0(RSP)  \ 4 increment INDEX by TOS value
    MOV @PSP+,TOS   \ 2 get new TOS, doesn't change flags
    GOTO BW1        \ 2
    ENDCODE         \

    CODE +LOOP
    MOV #XPLOO,X
    GOTO BW2
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/I
\ I        -- n   R: sys1 sys2 -- sys1 sys2
\                  get the innermost loop index
    [UNDEFINED] I
    [IF]
    CODE I
    SUB #2,PSP              \ 1 make room in TOS
    MOV TOS,0(PSP)          \ 3
    MOV @RSP,TOS            \ 2 index = loopctr - fudge
    SUB 2(RSP),TOS          \ 3
    MOV @IP+,PC             \ 4 13~
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]
    DEFER CR    \ DEFERed definition, by default executes that of :NONAME

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]

\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
    [UNDEFINED] BASE
    [IF]
    BASEADR  CONSTANT BASE
    [THEN]

\ https://forth-standard.org/standard/tools/DUMP
    [UNDEFINED] DUMP
    [IF]       \ defined in {UTILITY}
    CODE DUMP                   \ adr n  --   dump memory
    PUSH IP
    PUSH &BASE                  \ save current base
    MOV #$10,&BASE              \ HEX base
    ADD @PSP,TOS                \ -- ORG END
    LO2HI
    SWAP                      \ -- END ORG
    DO  CR                    \ generate line
        I 4 U.R SPACE           \ generate address
        I 8 + I
        DO I C@ 3 U.R LOOP
        SPACE
        I $10 + I 8 +
        DO I C@ 3 U.R LOOP
        SPACE SPACE
        I $10 + I             \ display 16 chars
        DO I C@ $7E MIN $20 MAX EMIT LOOP
    $10 +LOOP
    R> BASE !               \ restore current base
    ;
    [THEN]

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #HEREXEC,PC
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
CALLA W
ENDCODE
HERE OVER - DUMP
; you should see:       4A 13
RST_RET

HERE
CODE TT
CALLA $3456(W)
ENDCODE
HERE OVER - DUMP
; you should see:       5A 13  56 34
RST_RET

HERE
CODE TT
CALLA 0(PSP)
ENDCODE
HERE OVER - DUMP
; you should see:       5F 13  00 00
RST_RET

HERE
CODE TT
CALLA @W
ENDCODE
HERE OVER - DUMP
; you should see:       6A 13
RST_RET

HERE
CODE TT
CALLA @PSP
ENDCODE
HERE OVER - DUMP
; you should see:       6F 13
RST_RET

HERE
CODE TT
CALLA @W+
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
MOVA @W,T
ENDCODE
HERE OVER - DUMP
; you should see:       0B 0A
RST_RET

HERE
CODE TT
MOVA @T+,W
ENDCODE
HERE OVER - DUMP
; you should see:       1A 0B
RST_RET

HERE
CODE TT
MOVA &$1.2345,T
ENDCODE
HERE OVER - DUMP
; you should see:       2B 01  45 23
RST_RET

HERE
CODE TT
MOVA 2(PSP),TOS
ENDCODE
HERE OVER - DUMP
; you should see:       3E 0F  02 00
RST_RET

HERE
CODE TT
MOVA $1234(W),S
ENDCODE
HERE OVER - DUMP
; you should see:       3C 0A  34 12
RST_RET

HERE
CODE TT
MOVA T,&$1.2345
ENDCODE
HERE OVER - DUMP
; you should see:       61 0B  45 23
RST_RET

HERE
CODE TT
MOVA TOS,0(PSP)
ENDCODE
HERE OVER - DUMP
; you should see:       7F 0E  00 00
RST_RET

HERE
CODE TT
MOVA S,$1234(W)
ENDCODE
HERE OVER - DUMP
; you should see:       7A 0C  34 12
RST_RET

HERE
CODE TT
MOVA #$0.1,S
ENDCODE
HERE OVER - DUMP
; you should see:       8C 00  01 00
RST_RET

HERE
CODE TT
CMPA #$1.2345,S
ENDCODE
HERE OVER - DUMP
; you should see:       9C 01  45 23
RST_RET

HERE
CODE TT
ADDA #$2.3456,S
ENDCODE
HERE OVER - DUMP
; you should see:       AC 02  56 34
RST_RET

HERE
CODE TT
SUBA #$3.4567,S
ENDCODE
HERE OVER - DUMP
; you should see:       BC 03  67 45
RST_RET

HERE
CODE TT
MOVA W,T
ENDCODE
HERE OVER - DUMP
; you should see:       CB 0A
RST_RET

HERE
CODE TT
CMPA W,T
ENDCODE
HERE OVER - DUMP
; you should see:       DB 0A
RST_RET

HERE
CODE TT
ADDA W,T
ENDCODE
HERE OVER - DUMP
; you should see:       EB 0A
RST_RET

HERE
CODE TT
SUBA W,T
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
MOV S,T
MOVX S,T
ENDCODE
HERE OVER - DUMP
; you should see:       0B 4C  40 18 0B 4C
RST_RET

HERE
CODE TT
ADD T,T
ADDX.A T,T
ENDCODE
HERE OVER - DUMP
; you should see:       0B 5B  00 18 4B 5B
RST_RET

HERE
CODE TT
ADD T,T
RPT X
ADDX.A T,T
ENDCODE
HERE OVER - DUMP
; you should see:       0B 5B  89 18 4B 5B
RST_RET

HERE
CODE TT
ADD T,T
RPT #8
ADDX.A T,T
ENDCODE
HERE OVER - DUMP
; you should see:       0B 5B  07 18 4B 5B
RST_RET

HERE
CODE TT
ADDC #$9876,T
ADDCX.A #$5.9876,T
ENDCODE
HERE OVER - DUMP
; you should see:       3B 60  76 98 80 1A 7B 60 76 98
RST_RET

HERE
CODE TT
ADDC &$9876,T
ADDCX.A &$5.9876,T
ENDCODE
HERE OVER - DUMP
; you should see:       1B 62  76 98 80 1A 5B 62 76 98
RST_RET

HERE
CODE TT
XOR.B $5432(S),T
XORX.B $6.5432(S),T
ENDCODE
HERE OVER - DUMP
; you should see:       5B EC  32 54 46 18 5B EC 32 54
RST_RET

HERE
CODE TT
SUBC T,$5432(S)
SUBCX.A T,$6.5432(S)
ENDCODE
HERE OVER - DUMP
; you should see:       8C 7B  32 54 06 18 CC 7B 32 54
RST_RET

HERE
CODE TT
XOR.B T,$5432(S)
XORX.B T,$6.5432(S)
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
RRA X
RRAX X
ENDCODE
HERE OVER - DUMP
; you should see:       09 11  40 18 09 11
RST_RET

HERE
CODE TT
RRC @X
RRCX.A @X
ENDCODE
HERE OVER - DUMP
; you should see:       29 10  00 18 69 10
RST_RET

HERE
CODE TT
RRC @S
RRCX.A @S
ENDCODE
HERE OVER - DUMP
; you should see:       2C 10  00 18 6C 10
RST_RET

HERE
CODE TT
RRC @X+
RRUX.A @X+
ENDCODE
HERE OVER - DUMP
; you should see:       39 10  00 19 79 10
RST_RET

HERE
CODE TT
RRC T
RPT #9
RRUX.A T
ENDCODE
HERE OVER - DUMP
; you should see:       0B 10  08 19 4B 10
RST_RET

HERE
CODE TT
RRC T
RPT X
RRUX.A T
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
PUSH.B $3344(T)
PUSHX.B $.3344(T)
ENDCODE
HERE OVER - DUMP
; you should see:       5B 12  44 33 40 18 5B 12 44 33
RST_RET

\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
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
\ MOVX #$F0F0,Y \ don't forget decimal point with MOVX instruction !
MOVX #$.F0F0,Y
RRUX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRUX_T ;            %
; you should see:   %111100001111000

; ================
; RRUX repeat test
; ================


CODE RRUX_T
MOV #$F0F0,Y
RPT #1
RRUX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRUX_T ;            %
; you should see:   %111100001111000

CODE RRUX_T
MOV #$F0F0,Y
RPT #4
RRUX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRUX_T ; -->        %
; you should see:   %111100001111

CODE RRUX_T
MOV #$F0F0,Y
RPT #8
RRUX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRUX_T ;            %
; you should see:   %11110000

; ================
; RRCX test
; ================

CODE RRCX_T
MOV #$8000,Y
BIC #C,SR
RRCX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%U.,PC
ENDCODE

RRCX_T ;            %
; you should see:   %100000000000000

; ================
; RRCX repeat test
; ================

CODE RRCX_T
MOV #$8000,Y
BIC #C,SR
RPT #1
RRCX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%U.,PC
ENDCODE

RRCX_T ;            %
; you should see:   %100000000000000

CODE RRCX_T
MOV #$8000,Y
BIC #C,SR
RPT #8
RRCX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%U.,PC
ENDCODE

RRCX_T ;            %
; you should see:   %10000000

; ================
; RRAX test
; ================

CODE RRAX_T
MOV #$8000,Y
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ;            %
; you should see:   %-100000000000000

; ================
; RRAX repeat test
; ================


CODE RRAX_T
MOV #$8000,Y
RPT #1
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ;            %
; you should see:   %-100000000000000

CODE RRAX_T
MOV #$8000,Y
RPT #2
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ;            %
; you should see:   %-10000000000000

CODE RRAX_T
MOV #$8000,Y
RPT #3
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ;            %
; you should see:   %-1000000000000

CODE RRAX_T
MOV #$8000,Y
RPT #7
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ;            %
; you should see:   %-100000000

; ================
; RLAX test
; ================


CODE RLAX_T
MOV #-1,Y
ADDX Y,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

RLAX_T ; you should see -2 -->

; ================
; RLAX repeat test
; ================


CODE RLAX_T
MOV #-1,Y
RPT #1
ADDX Y,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

RLAX_T ; you should see -2 -->

CODE RLAX_T
MOV #-1,Y
RPT #2
ADDX Y,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

RLAX_T ; you should see -4 -->

CODE RLAX_T
MOV #-1,Y
RPT #3
ADDX Y,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

RLAX_T ; you should see -8 -->

CODE RLAX_T
MOV #-1,Y
RPT #8
ADDX Y,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

RLAX_T ; you should see -256 -->

; ================
; ADDX test
; ================


CODE ADDX_T
MOV #0,Y
MOV #-1,X
ADDX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

ADDX_T ; you should see -1 -->

; ================
; ADDX repeat test
; ================


CODE ADDX_T
MOV #0,Y
MOV #-1,X
RPT #1
ADDX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

ADDX_T ; you should see -1 -->

CODE ADDX_T
MOV #0,Y
MOV #-1,X
RPT #2
ADDX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

ADDX_T ; you should see -2 -->

CODE ADDX_T
MOV #0,Y
MOV #-1,X
RPT #8
ADDX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

ADDX_T ; you should see -8 -->

; ================
; SUBX test
; ================


CODE SUBX_T
MOV #0,Y
MOV #-1,X
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 1 -->

; ================
; SUBX repeat test
; ================


CODE SUBX_T
MOV #0,Y
MOV #-1,X
RPT #1
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 1 -->

CODE SUBX_T
MOV #0,Y
MOV #-1,X
RPT #2
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 2 -->

CODE SUBX_T
MOV #0,Y
MOV #-1,X
RPT #8
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 8 -->

CODE SUBX_T     \ W register = R10
MOV #15,W       \ RPT [W] times, modulo 16 <--> RPT #16
MOV #0,Y
MOV #-1,X
RPT W
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 16 -->

CODE SUBX_T
MOV #32,W       \ RPT [W] times, modulo 16 <--> RPT #1
MOV #0,Y
MOV #-1,X
RPT W
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 1 -->

CODE SUBX_T
MOV #33,W       \ RPT [W] times, modulo 16 <--> RPT #2
MOV #0,Y
MOV #-1,X
RPT W
SUBX X,Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #.,PC   \ BRANCH to .
ENDCODE

SUBX_T ; you should see 2 -->

{TEST_ASMX}
