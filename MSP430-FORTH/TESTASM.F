\ -*- coding: utf-8 -*-

; -----------------------------------------------------------------------
; TEST_ASM.f
; -----------------------------------------------------------------------
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
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

\ first, we do some tests allowing the download
    CODE ABORT_TEST_ASM
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #401,TOS        \   FastForth V4.1
    COLON
    'CR' EMIT            \ return to column 1 without 'LF'
    ABORT" FastForth V4.1 please!"
\    RST_RET           \ remove ABORT_TEST_ASM definition before resuming
    ;

    ABORT_TEST_ASM      \ abort test

ECHO

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.f)
; ------------------------------------------------------------------

    [UNDEFINED] >R
    [IF]
\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
    CODE >R
    PUSH TOS
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] R>
    [IF]
\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
    CODE R>
    MOV rDOVAR,PC
    ENDCODE
    [THEN]

    [UNDEFINED] +
    [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    CODE +
    ADD @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] -
    [IF]
\ https://forth-standard.org/standard/core/Minus
\ -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
    CODE -
    SUB @PSP+,TOS   \ 2  -- n2-n1 ( = -n3)
    XOR #-1,TOS     \ 1
    ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] SWAP
    [IF]
\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
    CODE SWAP
    MOV @PSP,W      \ 2
    MOV TOS,0(PSP)  \ 3
    MOV W,TOS       \ 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] MAX
    [IF]    \ MAX and MIN are defined in {UTILITY}

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

    [UNDEFINED] C@
    [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
    CODE C@
    MOV.B @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] VARIABLE
    [IF]
\ https://forth-standard.org/standard/core/VARIABLE
\ VARIABLE <name>       --                      define a Forth VARIABLE
    : VARIABLE
    CREATE
    HI2LO
    MOV #$1287,-4(W)        \   CFA = CALL rDOVAR
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] CONSTANT
    [IF]
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

    [UNDEFINED] >BODY
    [IF]
\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
    CODE >BODY
    ADD #4,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] SPACE
    [IF]
\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
    : SPACE
    $20 EMIT ;
    [THEN]

    [UNDEFINED] SPACES
    [IF]
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

    [UNDEFINED] DUP
    [IF]    \ define DUP and ?DUP
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
    0<> ?GOTO BW1   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] DROP
    [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
    CODE DROP
    MOV @PSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] OVER
    [IF]
\ https://forth-standard.org/standard/core/OVER
\ OVER    x1 x2 -- x1 x2 x1
    CODE OVER
    MOV TOS,-2(PSP)     \ 3 -- x1 (x2) x2
    MOV @PSP,TOS        \ 2 -- x1 (x2) x1
    SUB #2,PSP          \ 1 -- x1 x2 x1
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    [UNDEFINED] IF
    [IF]     \ define IF THEN

    CODE IF
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
    CODE THEN
    MOV &DP,0(TOS)          \ -- IFadr
    MOV @PSP+,TOS           \ --
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    PUSH TOS            \ 3
    MOV @PSP,TOS        \ 2
    MOV @RSP+,0(PSP)    \ 4
    MOV @IP+,PC         \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
    [UNDEFINED] BEGIN
    [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT

    CODE BEGIN
    MOV #BEGIN,PC
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

    [UNDEFINED] I
    [IF]
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

    [UNDEFINED] BASE
    [IF]
\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
    BASEADR  CONSTANT BASE
    [THEN]

\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]
\ create a primary defered word, i.e. with its default runtime beginning at the >BODY of the definition
    CODE CR     \ part I : DEFERed definition of CR
    MOV #NEXT_ADR,PC                \ [PFA] = NEXT_ADR
    ENDCODE

    :NONAME     \ part II : :NONAME part as default runtime of CR
    'CR' EMIT 'LF' EMIT
    ; IS CR                         \ set [PFA] of CR = >BODY addr of CR = CFA of :NONAME part
    [THEN]

    [UNDEFINED] C,
    [IF]
\ https://forth-standard.org/standard/core/CComma
\ C,   char --        append char
    CODE C,
    MOV &DP,W
    MOV.B TOS,0(W)
    ADD #1,&DP
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] C@
    [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
    CODE C@
    MOV.B @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

; ------------------------------------------------------------------
; then we download the set of definitions we need (from UTILITY.f)
; ------------------------------------------------------------------

    [UNDEFINED] U.R
    [IF]            \ defined in {UTILITY}
    : U.R                       \ u n --           display u unsigned in n width (n >= 2)
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    [UNDEFINED] DUMP
    [IF]       \ defined in {UTILITY}
\ https://forth-standard.org/standard/tools/DUMP
    CODE DUMP                   \ adr n  --   dump memory
    PUSH IP
    PUSH &BASE               \ save current base
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
        DO I C@ $7E MIN $20 MAX EMIT LOOP
    $10 +LOOP
    R> BASE !              \ restore current base
    ;
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

ECHO
\ -----------------------------------------------------------------------
\ test CPUx instructions PUSHM, POPM, RLAM, RRAM, RRCM, RRUM
\ -----------------------------------------------------------------------
    CODE TESTPUSHM
BW1
\    PUSHM  #16,R14     \ uncomment to test error "out of bounds"
\    PUSHM  #2,R0       \ uncomment to test error "out of bounds"
\    PUSHM  #0,IP       \ uncomment to test error "out of bounds"
\    POPM   #17,R15     \ uncomment to test error "out of bounds"
\    POPM   #2,R0       \ uncomment to test error "out of bounds"
\    POPM   #0,IP       \ uncomment to test error "out of bounds"
    MOV     #22222,Y
    MOV     #3,X
    MOV     #2,W
    MOV     #1,T
    MOV     #0,S

    PUSHM   #4,IP       \ PUSHM IP,S,T,W
    POPM    #4,IP       \ POPM  W,T,S,IP
    SUB     #10,PSP
    MOV     TOS,8(PSP)  \ save old TOS
    MOV     S,6(PSP)
    MOV     T,4(PSP)
    MOV     W,2(PSP)
    MOV     X,0(PSP)
    MOV     Y,TOS
\    RLAM    #0,TOS      \ uncomment to test error "out of bounds"
\    RLAM    #5,TOS      \ uncomment to test error "out of bounds"
    RRAM    #1,TOS      \ 0 < shift value < 5
    RLAM    #2,TOS
    RRCM    #1,TOS
    RRUM    #1,TOS
    COLON               \ high level part of the word starts here...
    space . . . . .
    ;                   \ and finishes here.

    TESTPUSHM  ; you should see 11111 3 2 1 0 -->

    CODE TESTPOPM
            GOTO BW1            \ JMP TESTPUSHM
    ENDCODE

    TESTPOPM  ; you should see 11111 3 2 1 0 -->


\ -----------------------------------------------------------------------
\ test symbolic branch in assembler
\ test a FORTH section encapsulated in an assembly word
\ -----------------------------------------------------------------------
    CODE TEST1                  \ the word "CODE" add ASSEMBLER as CONTEXT vocabulary...

    MOV &BASE,&BASE \ to test &xxxx src operand
    CMP #%10,&BASE
    0<> IF  MOV #2,&BASE    \ if base <> 2
    ELSE    MOV #$0A,&BASE  \ else base = 2
    THEN
    COLON           \ tips : no "ok" displayed in start of line <==> compilation mode
    BASE @ U.       \ always display 10 !
    ;
    \

\ -----------------------------------------------------------------------
\ test a word that starts as word FORTH and ends as assembly word
\ -----------------------------------------------------------------------
    : TEST2                     \ ":" starts compilation
    BASE @ U.       \ always display 10 !
    HI2LO           \ switch FORTH to ASM : compile one word (next address)
                    \                       add vocabulary ASSEMBLER as CONTEXT vocabulary
                    \                       switch in interpret mode
    CMP #2, &BASE
    0<> IF  MOV #2, &BASE   \ if variable system BASE <> 2
    ELSE    MOV #10,&BASE   \ else (BASE = 2)
    THEN
\           MOV #EXIT,PC    \ to pair with ":" i.e. to restore IP saved by : then execute NEXT.
\ but even compile two words, it's better to compile an inline EXIT :
    MOV @RSP+,IP    \ restore IP
    MOV @IP+,PC     \ = NEXT
    ENDCODE                     \ ends assembler : remove vocabulary ASSEMBLER from CONTEXT
\

\ -----------------------------------------------------------------------
\ test a word that starts as assembly word and ends as FORTH word
\ -----------------------------------------------------------------------
    CODE TEST3                  \ "CODE" starts assembler, i.e. add ASSEMBLER as CONTEXT vocabulary
    CMP #2, &BASE
    0<> IF  MOV #2, &BASE   \ if variable system BASE <> 2
    ELSE    MOV #10,&BASE   \ else (BASE = 2)
    THEN    COLON           \
    BASE @  U.      \ always display 10 !
    ;                           \
\


\ -----------------------------------------------------------------------
\ test an assembly jump spanning a section written in FORTH
\ -----------------------------------------------------------------------
: TEST5
            SPACE
            HI2LO
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #%1010,TOS  \ init count = 10
BEGIN       SUB #$0001,TOS
            LO2HI
                            \ IP is already saved by word ":"
            DUP U.          \ display count
            HI2LO
            CMP #0,TOS
0= UNTIL    MOV @PSP+,TOS
\           MOV #EXIT,PC    \ to pair with ":" i.e. to restore IP saved by : then execute NEXT.
            MOV @RSP+,IP    \ restore IP
            MOV @IP+,PC     \ = NEXT
ENDCODE
    \
TEST5  ; you should see :  9 8 7 6 5 4 3 2 1 0 -->
    \

\ -----------------------------------------------------------------------
\ tests indexing address
\ -----------------------------------------------------------------------
: BYTES_TABLE_IDX
CREATE
0 DO I C,
LOOP
DOES>
+
;

8 BYTES_TABLE_IDX BYTES_TABLE \ create table "BYTES_TABLE" with bytes content = 0,1,2,3,4,5,6,7
    \
2 BYTES_TABLE C@ . ; you should see 2 -->
\


VARIABLE BYTES_TABLE1

$0201 BYTES_TABLE1 !              \ words written in memory are little endian !

CODE IDX_TEST1                     \ index -- value
    MOV.B   BYTES_TABLE1(TOS),TOS  \ -- value
COLON
    U.
;

0 IDX_TEST1     ; you should see 1 -->

CODE TEST6
            MOV 0(PSP),0(PSP)  \
            MOV @IP+,PC
ENDCODE


1 TEST6 .       ; you should see 1 -->


\ -----------------------------------------------------------------------
\ tests access to a CREATED word with assembler
\ -----------------------------------------------------------------------


    \
CREATE TABLE0
0 C,
1 C,
2 C,
3 C,
    \

CREATE TABLE10
$10 C,
$11 C,
$12 C,
$13 C,

    \

CREATE TABLE20
$20 C,
$21 C,
$22 C,
$23 C,
    \

CREATE TABLE


TABLE 2 - CONSTANT PFA_TABLE      \ PFA_TABLE leave the PFA of TABLE


CODE REDIRECT       ; <table> --    redirects TABLE to argument <table>
MOV TOS,&PFA_TABLE
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
    \

CODE REDIRECT0      ; --            redirects TABLE to TABLE0
MOV #TABLE0,&PFA_TABLE
MOV @IP+,PC
ENDCODE
    \

CODE REDIRECT10     ; --            redirects TABLE to TABLE10
MOV #TABLE10,&PFA_TABLE
MOV @IP+,PC
ENDCODE
    \

CODE REDIRECT20     ; --            redirects TABLE to TABLE20
MOV #TABLE20,&PFA_TABLE
MOV @IP+,PC
ENDCODE
    \

' TABLE0 10 DUMP
    \
' TABLE10 10 DUMP
    \
' TABLE20 10 DUMP
    \
    \
TABLE0 REDIRECT TABLE 10 DUMP
    \
TABLE10 REDIRECT TABLE 10 DUMP
    \
TABLE20 REDIRECT TABLE 10 DUMP
    \
    \
REDIRECT0 TABLE 10 DUMP
    \
REDIRECT10 TABLE 10 DUMP
    \
REDIRECT20 TABLE 10 DUMP
    \

TABLE0 PFA_TABLE ! TABLE 10 DUMP
    \
TABLE10 PFA_TABLE ! TABLE 10 DUMP
    \
TABLE20 PFA_TABLE ! TABLE 10 DUMP
    \

\ -----------------------------------------------------------------------
\ tests behaviour of assembly error
\ -----------------------------------------------------------------------
\ R16 causes an error, assembler context is aborted and the word TEST7 is "hidden".

\CODE TEST7
\           MOV 0(truc),0(R16)  ; display an error "out of bounds" -->

; -----------------------------------------------------------------------
; create a primary DEFERred assembly word
; -----------------------------------------------------------------------

\ create a primary defered word, i.e. with its default runtime beginning at the >BODY of the definition
    CODE TRUC           \ part I : DEFERed definition of TRUC
    MOV #NEXT_ADR,PC    \ [PFA] = NEXT_ADR
    ENDCODE

    CODENNM             \ part II : :NONAME part as default runtime of TRUC
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV @IP+,PC
    ENDCODE     ; leaves its execution address (CFA) on stack

DUP .           ; see it --> 

IS TRUC         ; TRUC becomes a primary DEFERred word
                ; with its default action (DUP) located at its BODY addresse.

TRUC .          ; display TOS value -->

' DROP IS TRUC  ; TRUC is redirected to DROP

; TRUC          ; The generated error displays stack empty! in reverse video, removes the TRUC definition and restarts the interpretation after the end of the file. And as you see, FastForth is able to display long lines, interesting, doesn't it? -->

' TRUC >BODY IS TRUC    ; TRUC is reinitialized with its default action

TRUC .          ; display TOS value -->

\ bla
\ bla
\ bla
\
\
\
\
\
\
\
\ bla
\ ...
