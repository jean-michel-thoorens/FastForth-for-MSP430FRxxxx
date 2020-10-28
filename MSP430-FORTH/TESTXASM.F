\ -*- coding: utf-8 -*-

; -----------------------------------------------------------------------
; TESTXASM.f
; -----------------------------------------------------------------------
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\
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

PWR_STATE

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] - [IF]
\ https://forth-standard.org/standard/core/Minus
\ -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
CODE -
SUB @PSP+,TOS   \ 2  -- n2-n1 ( = -n3)
XOR #-1,TOS     \ 1
ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] MAX [IF]    \ define MAX and MIN

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

[UNDEFINED] C@ [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
CODE C@
MOV.B @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT 
: CONSTANT 
CREATE
HI2LO
MOV TOS,-2(W)           \   PFA = n
MOV @PSP+,TOS
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] BL [IF]
\ https://forth-standard.org/standard/core/BL
\ BL      -- char            an ASCII space
#32 CONSTANT BL
[THEN]

[UNDEFINED] SPACE [IF]
\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
: SPACE
BL EMIT ;
[THEN]

[UNDEFINED] SPACES [IF]
\ https://forth-standard.org/standard/core/SPACES
\ SPACES   n --            output n spaces
CODE SPACES
CMP #0,TOS
0<> IF
    PUSH IP
    BEGIN
        LO2HI
        BL EMIT
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

[UNDEFINED] OVER [IF]
\ https://forth-standard.org/standard/core/OVER
\ OVER    x1 x2 -- x1 x2 x1
CODE OVER
MOV TOS,-2(PSP)     \ 3 -- x1 (x2) x2
MOV @PSP,TOS        \ 2 -- x1 (x2) x1
SUB #2,PSP          \ 1 -- x1 x2 x1
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] SWAP [IF]
\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
CODE SWAP
MOV @PSP,W      \ 2
MOV TOS,0(PSP)  \ 3
MOV W,TOS       \ 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] >R [IF]
\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
CODE >R
PUSH TOS
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] R> [IF]
\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
CODE R>
SUB #2,PSP      \ 1
MOV TOS,0(PSP)  \ 3
MOV @RSP+,TOS   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] U.R [IF]        \ defined in {UTILITY}
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]

[UNDEFINED] DO [IF]     \ define DO LOOP +LOOP
\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
CODE DO
SUB #2,PSP              \
MOV TOS,0(PSP)          \
ADD #2,&DP              \   make room to compile xdo
MOV &DP,TOS             \ -- HERE+2
MOV #XDO,-2(TOS)        \   compile xdo
ADD #2,&LEAVEPTR        \ -- HERE+2     LEAVEPTR+2
MOV &LEAVEPTR,W         \
MOV #0,0(W)             \ -- HERE+2     L-- 0
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/LOOP
\ LOOP    DOadr --         L-- an an-1 .. a1 0
CODE LOOP
    MOV #XLOOP,X
BW1 ADD #4,&DP          \ make room to compile two words
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
CODE +LOOP
MOV #XPLOOP,X
GOTO BW1        \ goto BW1 LOOP
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] I [IF]
\ https://forth-standard.org/standard/core/I
\ I        -- n   R: sys1 sys2 -- sys1 sys2
\                  get the innermost loop index
CODE I
SUB #2,PSP              \ 1 make room in TOS
MOV TOS,0(PSP)          \ 3
MOV @RSP,TOS            \ 2 index = loopctr - fudge
SUB 2(RSP),TOS          \ 3
MOV @IP+,PC             \ 4 13~
ENDCODE
[THEN]

[UNDEFINED] DUMP [IF]       \ defined in {UTILITY}
\ https://forth-standard.org/standard/tools/DUMP
CODE DUMP                   \ adr n  --   dump memory
PUSH IP
PUSH &BASEADR               \ save current base
MOV #$10,&BASEADR           \ HEX base
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
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> BASEADR !              \ restore current base
;
[THEN]

[UNDEFINED] HERE [IF]
CODE HERE
MOV #HEREADR,PC
ENDCODE
[THEN]

PWR_HERE


ECHO
; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES IV : Adda|Cmpa|Mova|Suba (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

HERE
CODE TEST
MOVA @W,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
MOVA @T+,W
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>1A 0B<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
MOVA &$1.2345,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>2B 01 45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA $.1234(W),S
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>3C 0A 34 12<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA T,&$1.2345
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>61 0B 45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA S,$.1234(W)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>7A 0C 34 12<04 44 55 4D
PWR_STATE

HERE
CODE TEST
MOVA #$0.1,S
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>8C 00 01 00<04 44 55 4D
PWR_STATE

HERE
CODE TEST
CMPA #$1.2345,S
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>9C 01 45 23<04 44 55 4D
PWR_STATE

HERE
CODE TEST
ADDA #$2.3456,S
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>AC 02 56 34<04 44 55 4D
PWR_STATE

HERE
CODE TEST
SUBA #$3.4567,S
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>BC 03 67 45<04 44 55 4D
PWR_STATE



HERE
CODE TEST
MOVA W,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>CB 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CMPA W,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>DB 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
ADDA W,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>EB 0A<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
SUBA W,T
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
CALLA W
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>4A 13<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CALLA $.3456(W)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>5A 13 56 34<04 44 55 4D
PWR_STATE

HERE
CODE TEST
CALLA @W
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>6A 13<04 44 55 4D 50 4F
PWR_STATE

HERE
CODE TEST
CALLA @W+
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
MOV S,T
MOVX S,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 4C 40 18 0B 4C<04 44
PWR_STATE

HERE
CODE TEST
ADD T,T
ADDX.A T,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 5B 00 18 4B 5B<04 44
PWR_STATE

HERE
CODE TEST
ADD T,T
RPT X
ADDX.A T,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 5B 89 18 4B 5B<04 44
PWR_STATE

HERE
CODE TEST
ADD T,T
RPT #8
ADDX.A T,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 5B 07 18 4B 5B<04 44
PWR_STATE

HERE
CODE TEST
ADDC #$9876,T
ADDCX.A #$5.9876,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>3B 60 76 98 80 1A 7B 60
;     76 98<04 44 55 4D
PWR_STATE

HERE
CODE TEST
ADDC &$9876,T
ADDCX.A &$5.9876,T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>1B 62 76 98 80 1A 5B 62
;     76 98<04 44 55 4D
PWR_STATE

HERE
CODE TEST
XOR.B $5432(S),T
XORX.B $6.5432(S),T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>5B EC 32 54 46 18 5B EC
;     32 54<04 44 55 4D
PWR_STATE

HERE
CODE TEST
SUBC T,$5432(S)
SUBCX.A T,$6.5432(S)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>8C 7B 32 54 06 18 CC 7B
;     32 54<04 44 55 4D
PWR_STATE

HERE
CODE TEST
XOR.B T,$5432(S)
XORX.B T,$6.5432(S)
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
RRA X
RRAX X
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>09 11 40 18 09 11<04 44
PWR_STATE

HERE
CODE TEST
RRC @X
RRCX.A @X
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>29 10 00 18 69 10<04 44
PWR_STATE

HERE
CODE TEST
RRC @S
RRCX.A @S
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>2C 10 00 18 6C 10<04 44
PWR_STATE

HERE
CODE TEST
RRC @X+
RRUX.A @X+
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>39 10 00 19 79 10<04 44
PWR_STATE

HERE
CODE TEST
RRC T
RPT #9
RRUX.A T
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>0B 10 08 19 4B 10<04 44
PWR_STATE

HERE
CODE TEST
RRC T
RPT X
RRUX.A T
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
PUSH.B $3344(T)
PUSHX.B $.3344(T)
ENDCODE
HERE OVER - DUMP
; you should see: 45 53 54 52>5B 12 44 33 40 18 5B 12
;     44 33<04 44 55 4D
PWR_STATE



: %.
BASEADR @ %10 BASEADR ! SWAP 8 EMIT . BASEADR !
;

: %U.
BASEADR @ %10 BASEADR ! SWAP 8 EMIT U. BASEADR ! ;

PWR_HERE


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

RRUX_T ; you should see %111100001111000 --> %

PWR_STATE

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

RRUX_T ; you should see %111100001111000 --> %

PWR_STATE

CODE RRUX_T
MOV #$F0F0,Y
RPT #4
RRUX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRUX_T ; you should see %111100001111 --> %

PWR_STATE

CODE RRUX_T
MOV #$F0F0,Y
RPT #8
RRUX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRUX_T ; you should see %11110000 --> %

PWR_STATE


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

RRCX_T ; you should see %100000000000000 --> %

PWR_STATE

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

RRCX_T ; you should see %100000000000000 --> %

PWR_STATE

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

RRCX_T ; you should see %10000000 --> %

PWR_STATE

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

RRAX_T ; you should see %-100000000000000 --> %

PWR_STATE

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

RRAX_T ; you should see %-100000000000000 --> %

PWR_STATE

CODE RRAX_T
MOV #$8000,Y
RPT #2
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ; you should see %-10000000000000 --> %

PWR_STATE

CODE RRAX_T
MOV #$8000,Y
RPT #3
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ; you should see %-1000000000000 --> %

PWR_STATE

CODE RRAX_T
MOV #$8000,Y
RPT #7
RRAX Y
SUB #2,PSP
MOV TOS,0(PSP)
MOV Y,TOS
MOV #%.,PC
ENDCODE

RRAX_T ; you should see %-100000000 --> %

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE


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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

PWR_STATE

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

RST_STATE
