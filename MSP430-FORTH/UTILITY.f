\ -*- coding: utf-8 -*-

\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    CHIPSTICK_FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\
\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use
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
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<

; ------------------------------------------------------------------------------
; UTILITY.f
; ------------------------------------------------------------------------------

\ first, we test for downloading driver only if UART TERMINAL target
CODE ABORT_UTILITY
SUB #2,PSP
MOV TOS,0(PSP)
MOV &VERSION,TOS
SUB #307,TOS        \ FastForth V3.7
COLON
'CR' EMIT           \ return to column 1 without 'LF'
ABORT" FastForth version = 3.7 please!"
PWR_STATE           \ remove ABORT_UTILITY definition before resuming
;

ABORT_UTILITY

PWR_STATE

[DEFINED] {TOOLS} [IF]  {TOOLS} [THEN]

[UNDEFINED] {TOOLS} [IF]

MARKER {TOOLS} 

[UNDEFINED] EXIT [IF]
\ https://forth-standard.org/standard/core/EXIT
\ EXIT     --      exit a colon definition; CALL #EXIT performs ASMtoFORTH (10 cycles)
\                                           JMP #EXIT performs EXIT
CODE EXIT
MOV @RSP+,IP    \ 2 pop previous IP (or next PC) from return stack
MOV @IP+,PC     \ 4 = NEXT
                \ 6 (ITC-2)
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

\ https://forth-standard.org/standard/core/Uless
\ U<    u1 u2 -- flag       test u1<u2, unsigned
[UNDEFINED] U< [IF]
CODE U<
SUB @PSP+,TOS   \ 2 u2-u1
0<> IF
    MOV #-1,TOS     \ 1
    U< IF           \ 2 flag 
        AND #0,TOS  \ 1 flag Z = 1
    THEN
THEN
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] IF [IF]     \ define IF and THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
CODE IF       \ immediate
SUB #2,PSP              \
MOV TOS,0(PSP)          \
MOV &DP,TOS             \ -- HERE
ADD #4,&DP            \           compile one word, reserve one word
MOV #QFBRAN,0(TOS)      \ -- HERE   compile QFBRAN
ADD #2,TOS              \ -- HERE+2=IFadr
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
CODE THEN               \ immediate
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] BEGIN [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT
\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
CODE BEGIN
    MOV #HEREXEC,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/UNTIL
\ UNTIL    BEGINadr --             resolve conditional backward branch
CODE UNTIL
    MOV #QFBRAN,X
BW1 ADD #4,&DP          \ compile two words
    MOV &DP,W           \ W = HERE
    MOV X,-4(W)         \ compile Bran or QFBRAN at HERE
    MOV TOS,-2(W)       \ compile bakcward adr at HERE+2
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/AGAIN
\ AGAIN    BEGINadr --             resolve uncondionnal backward branch
CODE AGAIN
MOV #BRAN,X
GOTO BW1
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/WHILE
\ WHILE    BEGINadr -- WHILEadr BEGINadr
: WHILE
POSTPONE IF SWAP
; IMMEDIATE

\ https://forth-standard.org/standard/core/REPEAT
\ REPEAT   WHILEadr BEGINadr --     resolve WHILE loop
: REPEAT
POSTPONE AGAIN POSTPONE THEN
; IMMEDIATE
[THEN]

[UNDEFINED] DO [IF]     \ define DO LOOP +LOOP
\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
CODE DO                 \ immediate
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
CODE LOOP               \ immediate
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

[UNDEFINED] DUP [IF]    \ define DUP and ?DUP
\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
CODE DUP
BW1 SUB #2,PSP      \ 2  push old TOS..
    MOV TOS,0(PSP)  \ 3  ..onto stack
    MOV @IP+,PC     \ 4
ENDCODE

\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
CODE ?DUP
CMP #0,TOS      \ 2  test for TOS nonzero
0<> ?GOTO BW1    \ 2
MOV @IP+,PC     \ 4
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


[UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
CODE DROP
MOV @PSP+,TOS   \ 2
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

[UNDEFINED] SPACE [IF]
\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
: SPACE
$20 EMIT ;
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

[UNDEFINED] 2DUP [IF]    \
\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
CODE 2DUP
MOV TOS,-2(PSP)     \ 3
MOV @PSP,-4(PSP)    \ 4
SUB #4,PSP          \ 1
MOV @IP+,PC         \ 4
ENDCODE
[THEN]

[UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
CODE 1+
ADD #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

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
\ -      n1/u1 n2/u2 -- n3/u3      n3 = n1-n2
CODE -
SUB @PSP+,TOS   \ 2  -- n2-n1
XOR #-1,TOS     \ 1
ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
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

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] ROT [IF]
\ https://forth-standard.org/standard/core/ROT
\ ROT    x1 x2 x3 -- x2 x3 x1
CODE ROT
MOV @PSP,W          \ 2 fetch x2
MOV TOS,0(PSP)      \ 3 store x3
MOV 2(PSP),TOS      \ 3 fetch x1
MOV W,2(PSP)        \ 3 store x2
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] MAX [IF]    \ define MAX and MIN
    CODE MAX    \    n1 n2 -- n3       signed maximum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO FW1    \ n2<n1
BW1     ADD #2,PSP
        MOV @IP+,PC
    ENDCODE

    CODE MIN    \    n1 n2 -- n3       signed minimum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO BW1    \ n2<n1
FW1     MOV @PSP+,TOS
        MOV @IP+,PC
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

[UNDEFINED] MOVE [IF]
\ https://forth-standard.org/standard/core/MOVE
\ MOVE    addr1 addr2 u --     smart move
\             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
CODE MOVE
MOV TOS,W           \ W = cnt
MOV @PSP+,Y         \ Y = addr2 = dst
MOV @PSP+,X         \ X = addr1 = src
MOV @PSP+,TOS       \ pop new TOS
CMP #0,W            \ count = 0 ?
0<> IF              \ if 0, already done !
    CMP X,Y         \ Y-X \ dst - src
    0= ?GOTO FW1    \ already done !
    U< IF           \ U< if src > dst
        BEGIN       \ copy W bytes
            MOV.B @X+,0(Y)
            ADD #1,Y
            SUB #1,W
        0= UNTIL
        MOV @IP+,PC
    ELSE            \ U>= if dst > src
        ADD W,Y     \ copy W bytes beginning with the end
        ADD W,X
        BEGIN
            SUB #1,X
            SUB #1,Y
            MOV.B @X,0(Y)
            SUB #1,W
        0= UNTIL
    THEN
THEN
FW1 MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] .S [IF]    \
\ https://forth-standard.org/standard/tools/DotS
\ .S        TOS -- TOS          display <depth> of param Stack and stack contents in hedadecimal if not empty
CODE .S
    MOV     TOS,-2(PSP) \ -- TOS ( TOS x x )
    MOV     PSP,TOS     \ -- PSP ( TOS x x )
    SUB     #2,TOS      \ -- PSP ( TOS x x )  to take count that TOS is first cell
    MOV     TOS,-6(PSP) \ -- TOS ( TOS x  PSP )
    MOV     #PSTACK,TOS \ -- P0  ( TOS x  PSP )
    SUB     #2,TOS      \ -- P0  ( TOS x  PSP ) to take count that TOS is first cell
BW1 MOV     TOS,-4(PSP) \ -- S0  ( TOS S0 PSP ) |  -- TOS ( TOS R0 RSP )
    SUB     #6,PSP      \ -- TOS S0 PSP S0      |  -- TOS R0 RSP R0 
    SUB     @PSP,TOS    \ -- TOS S0 PSP S0-SP   |  -- TOS R0 RSP R0-RSP 
    RRA     TOS         \ -- TOS S0 PSP #cells  |  -- TOS R0 RSP #cells 
COLON
    $3C EMIT            \ char '<'
    .                   \ display #cells
    $08 EMIT            \ backspace
    $3E EMIT SPACE      \ char '>' SPACE
    2DUP 1+             \ 
    U< IF 
        DROP DROP EXIT
    THEN                \ display content of stack in hexadecimal
    BASEADR @ >R
    $10 BASEADR !
    DO 
        I @ U.
    2 +LOOP
    R> BASEADR !
;
[THEN]

[UNDEFINED] .RS [IF]    \
\ .RS         TOS -- TOS           display <depth> of Return Stack and stack contents if not empty
CODE .RS
    MOV     TOS,-2(PSP) \ -- TOS ( TOS x x ) 
    MOV     RSP,-6(PSP) \ -- TOS ( TOS x  RSP )
    MOV     #RSTACK,TOS \ -- R0  ( TOS x  RSP )
    GOTO    BW1
ENDCODE
[THEN]

[UNDEFINED] ? [IF]    \
\ https://forth-standard.org/standard/tools/q
\ ?         adr --            display the content of adr
CODE ?          
    MOV @TOS,TOS
    MOV #U.,PC  \ goto U.
ENDCODE
[THEN]

[UNDEFINED] WORDS [IF]
\ https://forth-standard.org/standard/tools/WORDS
\ list all words of vocabulary first in CONTEXT.
: WORDS                         \ --            
CR 
CONTEXT @ PAD_ORG                   \ -- VOC_BODY PAD_ORG                  MOVE all threads of VOC_BODY in PAD_ORG
THREADS @ DUP +                 \ -- VOC_BODY PAD_ORG THREAD*2
MOVE                            \ -- vocabumary entries are copied in PAD_ORG
BEGIN                           \ -- 
    0 DUP                       \ -- ptr=0 MAX=0                
    THREADS @ DUP + 0           \ -- ptr=0 MAX=0 THREADS*2 0
        DO                      \ -- ptr MAX            I =  PAD_ptr = thread*2
        DUP I PAD_ORG + @           \ -- ptr MAX MAX NFAx
            U< IF               \ -- ptr MAX            if MAX U< NFAx
                DROP DROP       \ --                    drop ptr and MAX
                I DUP PAD_ORG + @   \ -- new_ptr new_MAX
            THEN                \ 
        2 +LOOP                 \ -- ptr MAX
    ?DUP                        \ -- ptr MAX MAX | -- ptr 0 (all threads in PAD_ORG = 0)
WHILE                           \ -- ptr MAX                    replace it by its LFA
    DUP                         \ -- ptr MAX MAX
    2 - @                       \ -- ptr MAX [LFA]
    ROT                         \ -- MAX [LFA] ptr
    PAD_ORG +                       \ -- MAX [LFA] thread
    !                           \ -- MAX                [LFA]=new_NFA updates PAD_ORG+ptr
    DUP                         \ -- MAX MAX
    COUNT $7F AND               \ -- MAX addr count (with suppr. of immediate bit)
    TYPE                        \ -- MAX
    C@ $0F AND                  \ -- count_of_chars
    $10 SWAP - SPACES           \ --                    complete with spaces modulo 16 chars
REPEAT                          \ --
DROP                            \ ptr --
;                               \ all threads in PAD_ORG are filled with 0
[THEN]

[UNDEFINED] U.R [IF]
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
>R  <# 0 # #S #>  
R> OVER - 0 MAX SPACES TYPE
;
[THEN]

[UNDEFINED] DUMP [IF]    \
\ https://forth-standard.org/standard/tools/DUMP
CODE DUMP                   \ adr n  --   dump memory
PUSH IP
PUSH &BASEADR               \ save current base
MOV #$10,&BASEADR           \ HEX base
ADD @PSP,TOS                \ -- ORG END
LO2HI
  SWAP 2DUP                 \ -- END ORG END ORG 
  U. U.                     \ -- END ORG        display org end 
  $FFF0 AND                 \ -- END ORG_modulo_16
  DO  CR                    \ generate line
    I 4 U.R SPACE           \ generate address
      I 8 + I               \ display first 8 bytes
      DO I C@ 3 U.R LOOP
      SPACE
      I $10 + I 8 +         \ display last 8 bytes
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I             \ display 16 chars
      DO I C@ $7E MIN $20 MAX EMIT LOOP
  $10 +LOOP
  R> BASEADR !                 \ restore current base
;
[THEN]  \ endof [UNDEFINED] DUMP

RST_HERE

[THEN]  \ endof [UNDEFINED] {TOOLS}
ECHO
