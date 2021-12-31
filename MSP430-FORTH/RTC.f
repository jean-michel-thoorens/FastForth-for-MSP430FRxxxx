\ -*- coding: utf-8 -*-
\
\ ==============================================================================
\ routines RTC for MSP430FR5xxx
\ your target must have a LF_XTAL 32768Hz
\ ==============================================================================
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel minimal addons: MSP430ASSEMBLER, CONDCOMP
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ or, from windows explorer:
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\ ASSEMBLER REGISTERS USAGE
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
\
\

    CODE ABORT_RTC
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #BIT14,TOS
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (FIXPOINT input), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #309,TOS        \                   FastForth V3.9
    COLON
    $0D EMIT            \ return to column 1 without CR
    ABORT" FastForth V3.9 please!"
    ABORT" target without LF_XTAL !"
    RST_RET             \ if no abort remove this word
    ;

    ABORT_RTC

; --------------------
; RTC.f
; --------------------

\ use :
\ to set date, type : d m y DATE!
\ to view date, type DATE?
\ to set time, type : h m [s] TIME!
\ to view time, type TIME?
\

    MARKER {RTC}

\ https://forth-standard.org/standard/core/OR
\ C OR     x1 x2 -- x3           logical OR
    [UNDEFINED] OR
    [IF]
    CODE OR
    BIS @PSP+,TOS
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

\ https://forth-standard.org/standard/core/CStore
\ C!      char c-addr --    store char in memory
    [UNDEFINED] C!
    [IF]
    CODE C!
    MOV.B @PSP+,0(TOS)  \ 4
    ADD #1,PSP          \ 1
    MOV @PSP+,TOS       \ 2
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

\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
    [UNDEFINED] DUP
    [IF]    \define DUP and DUP?
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

\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
    [UNDEFINED] DROP
    [IF]
    CODE DROP
    MOV @PSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/DEPTH
\ DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
    [UNDEFINED] DEPTH
    [IF]
    CODE DEPTH
    MOV TOS,-2(PSP)
    MOV #PSTACK,TOS
    SUB PSP,TOS     \ PSP-S0--> TOS
    RRA TOS         \ TOS/2   --> TOS
    SUB #2,PSP      \ post decrement stack...
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
    [UNDEFINED] >R
    [IF]
    CODE >R
    PUSH TOS        \ 3
    MOV @PSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
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

\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
    [UNDEFINED] 1+
    [IF]
    CODE 1+
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/OneMinus
\ 1-      n1/u1 -- n2/u2     subtract 1 from TOS
    [UNDEFINED] 1-
    [IF]
    CODE 1-
    SUB #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] U<
    [IF]
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

\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    [UNDEFINED] =
    [IF]
    CODE =
    SUB @PSP+,TOS   \ 2
    0<> IF          \ 2
        AND #0,TOS  \ 1
        MOV @IP+,PC \ 4
    THEN
    XOR #-1,TOS     \ 1 flag Z = 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    [UNDEFINED] IF
    [IF]     \ define IF THEN
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

\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
    [UNDEFINED] ELSE
    [IF]
    CODE ELSE     \ immediate
    ADD #4,&DP              \ make room to compile two words
    MOV &DP,W               \ W=HERE+4
    MOV #BRAN,-4(W)
    MOV W,0(TOS)            \ HERE+4 ==> [IFadr]
    SUB #2,W                \ HERE+2
    MOV W,TOS               \ -- ELSEadr
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
    [UNDEFINED] DO
    [IF]                \ define DO LOOP +LOOP
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
BW2 ADD #4,&DP              \ make room to compile two words
    MOV &DP,W
    MOV X,-4(W)             \ xloop --> HERE
    MOV TOS,-2(W)           \ DOadr --> HERE+2
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
    GOTO BW2        \ goto BW1 LOOP
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
    [UNDEFINED] BEGIN
    [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT

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

\ https://forth-standard.org/standard/core/CASE
    [UNDEFINED] CASE
    [IF]
    : CASE
    0
    ; IMMEDIATE \ -- #of-1

\ https://forth-standard.org/standard/core/OF
    : OF \ #of-1 -- orgOF #of
    1+	                    \ count OFs
    >R	                    \ move off the stack in case the control-flow stack is the data stack.
    POSTPONE OVER POSTPONE = \ copy and test case value
    POSTPONE IF	            \ add orig to control flow stack
    POSTPONE DROP	        \ discards case value if =
    R>	                    \ we can bring count back now
    ; IMMEDIATE

\ https://forth-standard.org/standard/core/ENDOF
    : ENDOF \ orgOF #of -- orgENDOF #of
    >R	                    \ move off the stack in case the control-flow stack is the data stack.
    POSTPONE ELSE
    R>	                    \ we can bring count back now
    ; IMMEDIATE

\ https://forth-standard.org/standard/core/ENDCASE
    : ENDCASE \ orgENDOF1..orgENDOFn #of --
    POSTPONE DROP
    0 DO
        POSTPONE THEN
    LOOP
    ; IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3
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
    [IF]            \define MAX and MIN
    CODE MAX        \    n1 n2 -- n3       signed maximum
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
    ENDCODE

    CODE MIN        \    n1 n2 -- n3       signed minimum
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO BW1   \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE

    [THEN]  \ MAX

\ https://forth-standard.org/standard/core/TwoTimes
\ 2*      x1 -- x2         arithmetic left shift
    [UNDEFINED] 2*
    [IF]
    CODE 2*
    ADD TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/UMTimes
\ UM*     u1 u2 -- udlo udhi   unsigned 16x16->32 mult.
    [UNDEFINED] UM*
    [IF]    \ case of hardware_MPY
    CODE UM*
    MOV @PSP,&MPY       \ Load 1st operand for unsigned multiplication
BW1 MOV TOS,&OP2        \ Load 2nd operand
    MOV &RES0,0(PSP)    \ low result on stack
    MOV &RES1,TOS       \ high result in TOS
    MOV @IP+,PC
    ENDCODE

\ https://forth-standard.org/standard/core/MTimes
\ M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
    CODE M*
    MOV @PSP,&MPYS      \ Load 1st operand for signed multiplication
    GOTO BW1
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- ur uq   unsigned 32/16->r16 q16
    [UNDEFINED] UM/MOD
    [IF]
    CODE UM/MOD
    PUSH #DROP      \
    MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
    ENDCODE
    [THEN]

\ U*/     u1 u2 u3 -- uq        u1*u2/u3
    : U*/
    >R UM* R> UM/MOD SWAP DROP
    ;

\ U/MOD   u1 u2 -- ur uq     unsigned division
    : U/MOD
    0 SWAP UM/MOD
    ;

\ UMOD   u1 u2 -- ur        unsigned division
    : UMOD
    U/MOD DROP
    ;

\ https://forth-standard.org/standard/core/Div
\ U/      u1 u2 -- uq       signed quotient
    : U/
    U/MOD SWAP DROP
    ;

\ https://forth-standard.org/standard/core/SPACES
\ SPACES   n --            output n spaces
    [UNDEFINED] SPACES
    [IF]
    : SPACES
    BEGIN
        ?DUP
    WHILE
        'SP' EMIT
        1-
    REPEAT
    ;
    [THEN]

    [UNDEFINED] U.R
    [IF]
    : U.R                       \ u n --           display u unsigned in n width (n >= 2)
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    CODE TIME?
    BEGIN
        BIT.B #RTCRDY,&RTCCTL1
    0<> UNTIL                   \ wait until RTCRDY high
    COLON
    RTCHOUR C@ 2 U.R ':' EMIT
    RTCMIN C@  2 U.R ':' EMIT
    RTCSEC C@  2 U.R
    ;

    : TIME!
    2 DEPTH
    U< IF                   \ if 3 numbers on stack
        RTCSEC C!
        RTCMIN C!
        RTCHOUR C!
    THEN
    ." it is " TIME?
    ;

    CODE DATE?                  \ display date
    BEGIN
        BIT.B #RTCRDY,&RTCCTL1
    0<> UNTIL                   \ wait until windows time RTC_ReaDY is high
    COLON

\     [THEN]

\ ==============================================================================
\ end of RTC software|harware calendar
\ ==============================================================================
\ resume with common part of DATE? definition:

    RTCDOW C@                   \ -- weekday    {0=Sat...6=Fri}
    CASE
    0 OF ." Sat"    ENDOF
    1 OF ." Sun"    ENDOF
    2 OF ." Mon"    ENDOF
    3 OF ." Tue"    ENDOF
    4 OF ." Wed"    ENDOF
    5 OF ." Thu"    ENDOF
    6 OF ." Fri"    ENDOF
    ENDCASE
    RTCYEAR @
    RTCMON C@
    RTCDAY C@                   \ -- year mon day
    $20 EMIT
    2 U.R '/' EMIT              \ -- year mon
    2 U.R '/' EMIT              \ -- year
    .                           \ --
    ;

    : DATE!                         \ year mon day --
    2 DEPTH
    U< IF                   \ if 3 numbers on stack
        RTCYEAR !
        RTCMON C!
        RTCDAY C!
    THEN
    RTCDAY C@
    RTCMON C@
    RTCYEAR @               \ -- day mon year
\ ------------------------------------------
\ Zeller's congruence for gregorian calendar
\ see https://www.rosettacode.org/wiki/Day_of_the_week#Forth
\ : ZELLER \ day mon year -- weekday          {0=Sat, ..., 6=Fri}
\ OVER 3 <                \
\ IF 1- SWAP 12 + SWAP
\ THEN                    \ -- d m' y'  with m' {3=March, ..., 14=february}
\ 100 /MOD                \ -- d m' K J   with K = y' in century, J = century
\ DUP 4 / SWAP 2* -       \ -- d m' K (J/4 - 2J)
\ SWAP DUP 4 / + +        \ -- d m' ((J/4 - 2J) + (K + K/4))
\ SWAP 1+  13 5 */ + +    \ -- (d + (((J/4 - 2J) + (K + K/4)) + (m+1)*13/5))
\ 7 MOD                   \ -- weekday        = {0=Sat, ..., 6=Fri}
\ ------------------------------------------
    OVER 3 U<               \
    IF 1 - SWAP 12 + SWAP
    THEN                    \ -- d m' y'  with m' {3=March, ..., 14=february}
    100 U/MOD               \ -- d m' K J   with K = y' in century, J = century
    DUP 4 U/ SWAP 2* -      \ -- d m' K (J/4 - 2J)
    SWAP DUP 4 U/ + +       \ -- d m' ((J/4 - 2J) + (K + K/4))
    SWAP 1+  13 5 U*/ + +   \ -- (d + (((J/4 - 2J) + (K + K/4)) + (m+1)*13/5))
    7 UMOD                  \ -- weekday        = {0=Sat, ..., 6=Fri}
\ ------------------------------------------
    RTCDOW C!               \ --
    ." we are on " DATE?
    ;

    RST_SET

    [UNDEFINED] S_
    [IF]
    CODE S_             \           Squote alias with blank instead quote separator
    MOV #0,&CAPS        \           turn CAPS OFF
    COLON
    XSQUOTE ,           \           compile run-time code
    $20 WORD            \ -- c-addr (= HERE)
    HI2LO
    MOV.B @TOS,TOS      \ -- len    compile string
    ADD #1,TOS          \ -- len+1
    BIT #1,TOS          \           C = ~Z
    ADDC TOS,&DP        \           store aligned DP
    MOV @PSP+,TOS       \ --
    MOV @RSP+,IP        \           pop paired with push COLON
    MOV #$20,&CAPS      \           turn CAPS ON (default state)
    MOV @IP+,PC         \ NEXT
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ESC
    [IF]
    CODE ESC
    CMP #0,&STATEADR
    0= IF MOV @IP+,PC   \ interpret time usage disallowed
    THEN
    COLON
    $1B                 \ -- char escape
    POSTPONE LITERAL    \ compile-time code : lit $1B
    POSTPONE EMIT       \ compile-time code : EMIT
    POSTPONE S_         \ compile-time code : S_ <escape_sequence>
    POSTPONE TYPE       \ compile-time code : TYPE
    ; IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/EXECUTE
\ EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
    [UNDEFINED] EXECUTE
    [IF] \ "
    CODE EXECUTE
    PUSH TOS                \ 3 push xt
    MOV @PSP+,TOS           \ 2
    MOV @RSP+,PC            \ 4 xt --> PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/EVALUATE
\ EVALUATE          \ i*x c-addr u -- j*x  interpret string
    [UNDEFINED] EVALUATE
    [IF]
    CODE EVALUATE
    MOV #SOURCE_LEN,X       \ 2
    MOV @X+,S               \ 2 S = SOURCE_LEN
    MOV @X+,T               \ 2 T = SOURCE_ORG
    MOV @X+,W               \ 2 W = TOIN
    PUSHM #4,IP             \ 6 PUSHM IP,S,T,W
    LO2HI
    [ ' \ 8 + , ]           \ compile INTERPRET = BACKSLASH + 8
    HI2LO
    MOV @RSP+,&TOIN         \ 4
    MOV @RSP+,&SOURCE_ORG   \ 4
    MOV @RSP+,&SOURCE_LEN   \ 4
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]

\    DEFER CR       \ DEFERed definition, by default executes that of :NONAME
    CODE CR         \ create a DEFER definition of CR
    MOV #NEXT_ADR,PC
    ENDCODE

    :NONAME     \ starts at BODY address of DEFERed CR
    'CR' EMIT 'LF' EMIT
    ; IS CR     \ CR executes :NONAME by default
    [THEN]

    : SET_TIME
    ESC [8;40;80t       \ set terminal display 42L * 80C
    39 0 DO CR LOOP     \ to avoid erasing any line of source, create 42 empty lines
    ESC [H              \ then set cursor home
    CR ." DATE (DMY): "
    PAD_ORG DUP PAD_LEN
    ['] ACCEPT >BODY    \ find default part of deferred ACCEPT (terminal input)
    EXECUTE             \ wait human input for D M Y
    EVALUATE            \ interpret this input
    CR DATE!            \ set date
    CR ." TIME (HMS): "
    PAD_ORG DUP PAD_LEN
    ['] ACCEPT >BODY    \ find default part of deferred ACCEPT (terminal input)
    EXECUTE             \ wait human input for H M S
    EVALUATE            \ interpret this input
    CR TIME!            \ set time
    RST_RET             \ remove code beyond RST_HERE
    ;

ECHO
SET_TIME
