\ -*- coding: utf-8 -*-
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ (used by preprocessor GEMA to load the pattern: \inc\TARGET.pat)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
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
\ rDODOES to rEXIT must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use
\
\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT, rDOVAR, rDOCON, rDODOES
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  rDODOES, rDOCON, rDOVAR, rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM #6,IP   pulls Y,X,W,T,S,IP registers from return stack
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?GOTO           S<  S>=  U<   U>=  0=  0<>  0<

    CODE ABORT_CORE_ANS
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #309,TOS        \ FastForth V3.9
    COLON
    $0D EMIT            \ return to column 1 without CR
    ABORT" FastForth V3.9 please!"
    ;

    ABORT_CORE_ANS

\  BC!     pattern @ --            Bits Clear in @
    [UNDEFINED] BC!
    [IF]
    CODE BC!
    BIC @PSP+,0(TOS)
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\  BS!     pattern @ --            Bits Set in @
    [UNDEFINED] BS!
    [IF]
    CODE BS!
    BIS @PSP+,0(TOS)
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ =============================================================================
\    $8000 KERNEL_ADDON BS! \ uncomment to select FLOORED division
    $8000 KERNEL_ADDON BC! \ uncomment to select SYMMETRIC division
\ =============================================================================

    RST_RET           \ remove all above before CORE_ANS downloading

; ----------------------------------
; CORE_ANS.f
; ----------------------------------
\
\ words complement to pass CORETEST.4TH

    MARKER {CORE_ANS}   \ if already defined removes it before.

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #HEREXEC,PC
    ENDCODE
    [THEN]

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

\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
    [UNDEFINED] DUP
    [IF]
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

\ https://forth-standard.org/standard/core/EXIT
\ EXIT     --      exit a colon definition
    [UNDEFINED] EXIT
    [IF]
    CODE EXIT
    MOV @RSP+,IP    \ 2 pop previous IP (or next PC) from return stack
    MOV @IP+,PC     \ 4 = NEXT
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

\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
    [UNDEFINED] DROP
    [IF]
    CODE DROP
    MOV @PSP+,TOS   \ 2
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

\ https://forth-standard.org/standard/core/NIP
\ NIP      x1 x2 -- x2         Drop the first item below the top of stack
    [UNDEFINED] NIP
    [IF]
    CODE NIP
    ADD #2,PSP
    MOV @IP+,PC
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
\ R>    -- x    R: x --   pop from return stack
    [UNDEFINED] R>
    [IF]
    CODE R>
    SUB #2,PSP      \ 1
    MOV TOS,0(PSP)  \ 3
    MOV @RSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- word   fetch word from memory
    [UNDEFINED] @
    [IF]
    CODE @
    MOV @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Store
\ !      word c-addr --    store word in memory
    [UNDEFINED] !
    [IF]
    CODE !
    MOV @PSP+,0(TOS)    \ 4
    MOV @PSP+,TOS       \ 2
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Fetch
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

\ https://forth-standard.org/standard/core/CComma
\ C,   char --        append char
    [UNDEFINED] C,
    [IF]
    CODE C,
    MOV &DP,W
    MOV.B TOS,0(W)
    ADD #1,&DP
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
    [UNDEFINED] 0=
    [IF]
    CODE 0=
    SUB #1,TOS      \ 1 borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ 1 TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Zerone
\ 0<>     n/u -- flag    return true if TOS<>0
    [UNDEFINED] 0<>
    [IF]
    CODE 0<>
    SUB #1,TOS      \ 1 borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ 1 TOS=-1 if borrow was set
    XOR #-1,TOS     \ 1
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Zeroless
\ 0<     n -- flag      true if TOS negative
    [UNDEFINED] 0<
    [IF]
    CODE 0<
BW1 ADD TOS,TOS     \ 1 set carry if TOS negative
    SUBC TOS,TOS    \ 1 TOS=-1 if carry was clear
    XOR #-1,TOS     \ 1 TOS=-1 if carry was set
    MOV @IP+,PC     \
    ENDCODE
    [THEN]

\ HERE

\ https://forth-standard.org/standard/core/StoD
\ S>D    n -- d          single -> double prec.
    [UNDEFINED] S>D
    [IF]
    : S>D
    DUP 0<
    ;
    [THEN]

\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    [UNDEFINED] =
    [IF]
    CODE =
    SUB @PSP+,TOS   \ 2
    SUB #1,TOS      \ 1 borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ 1 TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Uless
\ U<    u1 u2 -- flag       test u1<u2, unsigned
    [UNDEFINED] U<
    [IF]

    CODE U<
    SUB @PSP+,TOS   \ 2 u2-u1
    U< ?GOTO FW1
    0<> IF
BW1 MOV #-1,TOS     \ 1
    THEN
    MOV @IP+,PC     \ 4
    ENDCODE

\ https://forth-standard.org/standard/core/Umore
\ U>     n1 n2 -- flag
    CODE U>
    SUB @PSP+,TOS   \ 2
    U< ?GOTO BW1    \ 2 flag = true, Z = 0
FW1 AND #0,TOS      \ 1 Z = 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
    [UNDEFINED] <
    [IF]  \ define < and >

    CODE <
    SUB @PSP+,TOS   \ 1 TOS=n2-n1
    S< ?GOTO FW1    \ 2 signed
    0<> IF          \ 2
BW1 MOV #-1,TOS \ 1 flag Z = 0
    THEN
    MOV @IP+,PC
    ENDCODE

\ https://forth-standard.org/standard/core/more
\ >     n1 n2 -- flag         test n1>n2, signed
    CODE >
    SUB @PSP+,TOS   \ 2 TOS=n2-n1
    S< ?GOTO BW1    \ 2 --> +5
FW1 AND #0,TOS      \ 1 flag Z = 1
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ ------------------------------------------------------------------------------
\ CONTROL STRUCTURES
\ ------------------------------------------------------------------------------
\ THEN and BEGIN compile nothing
\ DO compile one word
\ IF, ELSE, AGAIN, UNTIL, WHILE, REPEAT, LOOP & +LOOP compile two words
\ LEAVE compile three words
\
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

\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
    [UNDEFINED] ELSE
    [IF]
    CODE ELSE
    ADD #4,&DP              \ make room to compile two words
    MOV &DP,W               \ W=HERE+4
    MOV #BRAN,-4(W)
    MOV W,0(TOS)            \ HERE+4 ==> [IFadr]
    SUB #2,W                \ HERE+2
    MOV W,TOS               \ -- ELSEadr
    MOV @IP+,PC
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

\ https://forth-standard.org/standard/core/J
\ J        -- n   R: 4*sys -- 4*sys
\ C                  get the second loop index
    [UNDEFINED] J
    [IF]
    CODE J
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV 4(RSP),TOS
    SUB 6(RSP),TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/UNLOOP
\ UNLOOP   --   R: sys1 sys2 --  drop loop parms
    [UNDEFINED] UNLOOP
    [IF]
    CODE UNLOOP
    ADD #4,RSP
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/LEAVE
\ LEAVE    --    L: -- adrs
    [UNDEFINED] LEAVE
    [IF]
    CODE LEAVE
    MOV &DP,W               \ compile three words
    MOV #UNLOOP,0(W)        \ [HERE] = UNLOOP
    MOV #BRAN,2(W)          \ [HERE+2] = BRAN
    ADD #6,&DP              \ [HERE+4] = at adr After LOOP
    ADD #2,&LEAVEPTR
    ADD #4,W
    MOV &LEAVEPTR,X
    MOV W,0(X)              \ leave HERE+4 on LEAVEPTR stack
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
    [UNDEFINED] AND
    [IF]
    CODE AND
    AND @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/OR
\ C OR     x1 x2 -- x3           logical OR (BIS, BIts Set)
    [UNDEFINED] OR
    [IF]
    CODE OR
    BIS @PSP+,TOS
    AND #-1,TOS \ to set flags
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/XOR
\ C XOR    x1 x2 -- x3           logical XOR
    [UNDEFINED] XOR
    [IF]
    CODE XOR
    XOR @PSP+,TOS
    MOV @IP+,PC
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

\ https://forth-standard.org/standard/core/INVERT
\ INVERT   x1 -- x2            bitwise inversion
    [UNDEFINED] INVERT
    [IF]
    CODE INVERT
    XOR #-1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/NEGATE
\ C NEGATE   x1 -- x2            two's complement
    [UNDEFINED] NEGATE
    [IF]
    CODE NEGATE
    XOR #-1,TOS
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/ABS
\ C ABS     n1 -- +n2     absolute value
    [UNDEFINED] ABS
    [IF]
    CODE ABS
    CMP #0,TOS       \  1
    0>= IF
        MOV @IP+,PC
    THEN
    MOV #NEGATE,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/LSHIFT
\ LSHIFT  x1 u -- x2    logical L shift u places
    [UNDEFINED] LSHIFT
    [IF]
    CODE LSHIFT
    MOV @PSP+,W
    AND #$1F,TOS        \ no need to shift more than 16
    0<> IF
        BEGIN
            ADD W,W
            SUB #1,TOS
        0= UNTIL
    THEN
    MOV W,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/RSHIFT
\ RSHIFT  x1 u -- x2    logical R7 shift u places
    [UNDEFINED] RSHIFT
    [IF]
    CODE RSHIFT
    MOV @PSP+,W
    AND #$1F,TOS       \ no need to shift more than 16
    0<> IF
        BEGIN
            BIC #C,SR           \ Clr Carry
            RRC W
            SUB #1,TOS
        0= UNTIL
    THEN
    MOV W,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/MAX
\ MAX    n1 n2 -- n3       signed maximum
    [UNDEFINED] MAX
    [IF]

    CODE MAX
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
    ENDCODE

\ https://forth-standard.org/standard/core/MIN
\ MIN    n1 n2 -- n3       signed minimum
    CODE MIN
    CMP @PSP,TOS    \ n2-n1
    S< ?GOTO BW1    \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoTimes
\ 2*      x1 -- x2         arithmetic left shift
    [UNDEFINED] 2*
    [IF]
    CODE 2*
    ADD TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoDiv
\ 2/      x1 -- x2        arithmetic right shift
    [UNDEFINED] 2/
    [IF]
    CODE 2/
    RRA TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ --------------------
\ ARITHMETIC OPERATORS
\ --------------------
    RST_SET

    CODE TSTBIT         \ addr bit_mask -- true/flase flag
    MOV @PSP+,X
    AND @X,TOS
    MOV @IP+,PC
    ENDCODE

\    $81EF DEVICEID @ U<
\    DEVICEID @ $81F3 U<
\    = [IF]   ; MSP430FR413x subfamily without hardware_MPY
    KERNEL_ADDON HMPY TSTBIT    \   KERNEL_ADDON(BIT0) = hardware MPY flag
    RST_RET

    [IF]
\ https://forth-standard.org/standard/core/MTimes
\ M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
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

    [ELSE]  ; MSP430FRxxxx with hardware_MPY
\ https://forth-standard.org/standard/core/UMTimes
\ UM*     u1 u2 -- udlo udhi   unsigned 16x16->32 mult.
        [UNDEFINED] M* [IF]
    CODE M*
    MOV @PSP,S          \ S= n1
    CMP #0,S            \ n1 > -1 ?
    S< IF
        XOR #-1,0(PSP)  \ n1 --> u1
        ADD #1,0(PSP)   \
    THEN
    XOR TOS,S           \ S contains sign of result
    CMP #0,TOS          \ n2 > -1 ?
    S< IF
        XOR #-1,TOS     \ n2 --> u2
        ADD #1,TOS      \
    THEN
    PUSHM #2,IP         \ UMSTAR use S,T,W,X,Y
    LO2HI               \ -- ud1 u2
    UM*
    HI2LO
    POPM #2,IP           \ pop S,IP
    CMP #0,S            \ sign of result > -1 ?
    S< IF
        XOR #-1,0(PSP)  \ ud --> d
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
    THEN
    MOV @IP+,PC
    ENDCODE
        [THEN]
    [THEN]  ;  endof hardware_MPY

\ HERE

\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
    [UNDEFINED] UM/MOD
    [IF]
    CODE UM/MOD
    PUSH #DROP      \
    MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
    ENDCODE
    [THEN]

\ HERE OVER - DUMP


    KERNEL_ADDON @ 0<  ; test the switch: FLOORED / SYMETRIC DIVISION
    [IF]
\ https://forth-standard.org/standard/core/FMDivMOD
\ FM/MOD   d1 n1 -- r q   floored signed div'n
        [UNDEFINED] FM/MOD
        [IF]
        CODE FM/MOD
        MOV TOS,S           \           S=DIV
        MOV @PSP,T          \           T=DVDhi
        CMP #0,TOS          \           n2 >= 0 ?
        S< IF               \
            XOR #-1,TOS
            ADD #1,TOS      \ -- d1 u2
        THEN
        CMP #0,0(PSP)       \           d1hi >= 0 ?
        S< IF               \
            XOR #-1,2(PSP)  \           d1lo
            XOR #-1,0(PSP)  \           d1hi
            ADD #1,2(PSP)   \           d1lo+1
            ADDC #0,0(PSP)  \           d1hi+C
        THEN                \ -- uDVDlo uDVDhi uDIVlo
        PUSHM  #2,S         \ 4         PUSHM S,T
        CALL #MUSMOD
        MOV @PSP+,TOS
        POPM  #2,S          \ 4         POPM T,S
        CMP #0,T            \           T=DVDhi --> REM_sign
        S< IF
            XOR #-1,0(PSP)
            ADD #1,0(PSP)
        THEN
        XOR S,T             \           S=DIV XOR T=DVDhi = Quot_sign
        CMP #0,T            \ -- n3 u4  T=quot_sign
        S< IF
            XOR #-1,TOS
            ADD #1,TOS
        THEN                \ -- n3 n4  S=divisor

        CMP #0,0(PSP)       \ remainder <> 0 ?
        0<> IF
            CMP #1,TOS      \ quotient < 1 ?
            S< IF
            ADD S,0(PSP)  \ add divisor to remainder
            SUB #1,TOS    \ decrement quotient
            THEN
        THEN
        MOV @IP+,PC
        ENDCODE
        [THEN]
    [ELSE]
\ https://forth-standard.org/standard/core/SMDivREM
\ SM/REM   DVDlo DVDhi DIV -- r3 q4  symmetric signed div
        [UNDEFINED] SM/REM
        [IF]
        CODE SM/REM
        MOV TOS,S           \           S=DIV
        MOV @PSP,T          \           T=DVDhi
        CMP #0,TOS          \           n2 >= 0 ?
        S< IF               \
            XOR #-1,TOS
            ADD #1,TOS      \ -- d1 u2
        THEN
        CMP #0,0(PSP)       \           d1hi >= 0 ?
        S< IF               \
            XOR #-1,2(PSP)  \           d1lo
            XOR #-1,0(PSP)  \           d1hi
            ADD #1,2(PSP)   \           d1lo+1
            ADDC #0,0(PSP)  \           d1hi+C
        THEN                \ -- uDVDlo uDVDhi uDIVlo
        PUSHM  #2,S         \ 4         PUSHM S,T
        CALL #MUSMOD
        MOV @PSP+,TOS
        POPM  #2,S          \ 4         POPM T,S
        CMP #0,T            \           T=DVDhi --> REM_sign
        S< IF
            XOR #-1,0(PSP)
            ADD #1,0(PSP)
        THEN
        XOR S,T             \           S=DIV XOR T=DVDhi = Quot_sign
        CMP #0,T            \ -- n3 u4  T=quot_sign
        S< IF
            XOR #-1,TOS
            ADD #1,TOS
        THEN                \ -- n3 n4  S=divisor
        MOV @IP+,PC
        ENDCODE
        [THEN]
    [THEN]

\ https://forth-standard.org/standard/core/Times
\ *      n1 n2 -- n3       signed multiply
    [UNDEFINED] *
    [IF]
    : *
    M* DROP
    ;
    [THEN]

\ https://forth-standard.org/standard/core/DivMOD
\ /MOD   n1 n2 -- r3 q4     signed division
    [UNDEFINED] /MOD
    [IF]
    : /MOD
    >R DUP 0< R>
        [ KERNEL_ADDON @ 0< ]   \ test the switch: FLOORED / SYMETRIC DIVISION
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    ;
    [THEN]

\ https://forth-standard.org/standard/core/Div
\ /      n1 n2 -- n3       signed quotient
    [UNDEFINED] /
    [IF]
    : /
    >R DUP 0< R>
        [ KERNEL_ADDON @ 0< ]   \ test the switch: FLOORED / SYMETRIC DIVISION
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    NIP
    ;
    [THEN]

\ https://forth-standard.org/standard/core/MOD
\ MOD    n1 n2 -- n3       signed remainder
    [UNDEFINED] MOD
    [IF]
    : MOD
    >R DUP 0< R>
        [ KERNEL_ADDON @ 0< ]   \ test the switch: FLOORED / SYMETRIC DIVISION
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    DROP
    ;
    [THEN]

\ https://forth-standard.org/standard/core/TimesDivMOD
\ */MOD  n1 n2 n3 -- r4 q5    signed mult/div
    [UNDEFINED] */MOD
    [IF]
    : */MOD
    >R M* R>
        [ KERNEL_ADDON @ 0< ]   \ test the switch: FLOORED / SYMETRIC DIVISION
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    ;
    [THEN]

\ https://forth-standard.org/standard/core/TimesDiv
\ */     n1 n2 n3 -- n4        n1*n2/q3
    [UNDEFINED] */
    [IF]
    : */
    >R M* R>
        [ KERNEL_ADDON @ 0< ]   \ test the switch: FLOORED / SYMETRIC DIVISION
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    NIP
    ;
    [THEN]

\ -------------------------------------------------------------------------------
\  STACK OPERATIONS
\ -------------------------------------------------------------------------------
\ https://forth-standard.org/standard/core/ROT
\ ROT    x1 x2 x3 -- x2 x3 x1
    [UNDEFINED] ROT
    [IF]
    CODE ROT
    MOV @PSP,W          \ 2 fetch x2
    MOV TOS,0(PSP)      \ 3 store x3
    MOV 2(PSP),TOS      \ 3 fetch x1
    MOV W,2(PSP)        \ 3 store x2
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/RFetch
\ R@    -- x     R: x -- x   fetch from return stack
    [UNDEFINED] R@
    [IF]
    CODE R@
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV @RSP,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TUCK
\ TUCK  ( x1 x2 -- x2 x1 x2 )
    [UNDEFINED] TUCK
    [IF]
    : TUCK SWAP OVER ;
    [THEN]

\ ----------------------------------------------------------------------
\ DOUBLE OPERATORS
\ ----------------------------------------------------------------------
\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
    [UNDEFINED] 2@
    [IF]
    CODE 2@
    SUB #2,PSP
    MOV 2(TOS),0(PSP)
    MOV @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoStore
\ 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
    [UNDEFINED] 2!
    [IF]
    CODE 2!
    MOV @PSP+,0(TOS)
    MOV @PSP+,2(TOS)
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
    [UNDEFINED] 2DUP
    [IF]
    CODE 2DUP
    MOV TOS,-2(PSP)     \ 3
    MOV @PSP,-4(PSP)    \ 4
    SUB #4,PSP          \ 1
    MOV @IP+,PC         \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoDROP
\ 2DROP  x1 x2 --          drop 2 cells
    [UNDEFINED] 2DROP
    [IF]
    CODE 2DROP
    ADD #2,PSP
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoSWAP
\ 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
    [UNDEFINED] 2SWAP
    [IF]
    CODE 2SWAP
    MOV @PSP,W          \ -- x1 x2 x3 x4    W=x3
    MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x4
    MOV W,4(PSP)        \ -- x3 x2 x1 x4
    MOV TOS,W           \ -- x3 x2 x1 x4    W=x4
    MOV 2(PSP),TOS      \ -- x3 x2 x1 x2    W=x4
    MOV W,2(PSP)        \ -- x3 x4 x1 x2
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/TwoOVER
\ 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
    [UNDEFINED] 2OVER
    [IF]
    CODE 2OVER
    SUB #4,PSP          \ -- x1 x2 x3 x x x4
    MOV TOS,2(PSP)      \ -- x1 x2 x3 x4 x x4
    MOV 8(PSP),0(PSP)   \ -- x1 x2 x3 x4 x1 x4
    MOV 6(PSP),TOS      \ -- x1 x2 x3 x4 x1 x2
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ ----------------------------------------------------------------------
\ ALIGNMENT OPERATORS
\ ----------------------------------------------------------------------
\ https://forth-standard.org/standard/core/ALIGNED
\ ALIGNED  addr -- a-addr       align given addr
    [UNDEFINED] ALIGNED
    [IF]
    CODE ALIGNED
    BIT #1,TOS
    ADDC #0,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/ALIGN
\ ALIGN    --                         align HERE
    [UNDEFINED] ALIGN
    [IF]
    CODE ALIGN
    BIT #1,&DP  \ 3
    ADDC #0,&DP \ 4
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ ---------------------
\ PORTABILITY OPERATORS
\ ---------------------
\ https://forth-standard.org/standard/core/CHARS
\ CHARS    n1 -- n2            chars->adrs units
    [UNDEFINED] CHARS
    [IF]
    CODE CHARS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CHARPlus
\ CHAR+    c-addr1 -- c-addr2   add char size
    [UNDEFINED] CHAR+
    [IF]
    CODE CHAR+
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CELLS
\ CELLS    n1 -- n2            cells->adrs units
    [UNDEFINED] CELLS
    [IF]
    CODE CELLS
    ADD TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CELLPlus
\ CELL+    a-addr1 -- a-addr2      add cell size
    [UNDEFINED] CELL+
    [IF]
    CODE CELL+
    ADD #2,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ ---------------------------
\ BLOCK AND STRING COMPLEMENT
\ ---------------------------
\ https://forth-standard.org/standard/core/CHAR
\ CHAR   -- char           parse ASCII character
    [UNDEFINED] CHAR
    [IF]
    : CHAR
    $20 WORD 1+ C@
    ;
    [THEN]

\ https://forth-standard.org/standard/core/BracketCHAR
\ [CHAR]   --          compile character literal
    [UNDEFINED] [CHAR]
    [IF]
    : [CHAR]
    CHAR POSTPONE LITERAL
    ; IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/PlusStore
\ +!     n/u a-addr --       add n/u to memory
    [UNDEFINED] +!
    [IF]
    CODE +!
    ADD @PSP+,0(TOS)
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/MOVE
\ MOVE    addr1 addr2 u --     smart move
\             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
    [UNDEFINED] MOVE
    [IF]
    CODE MOVE
    MOV TOS,W           \ W = cnt
    MOV @PSP+,Y         \ Y = addr2 = dst
    MOV @PSP+,X         \ X = addr1 = src
    MOV @PSP+,TOS       \ pop new TOS
    CMP #0,W            \ count = 0 ?
    0<> IF              \ if 0, already done !
        CMP X,Y         \ dst = src ?
        0<> IF          \ if 0, already done !
            U< IF       \ U< if src > dst
                BEGIN   \ copy W bytes
                    MOV.B @X+,0(Y)
                    ADD #1,Y
                    SUB #1,W
                0= UNTIL
                MOV @IP+,PC \ out 1 of MOVE ====>
            THEN        \ U>= if dst > src
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
    MOV @IP+,PC \ out 2 of MOVE ====>
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/FILL
\ FILL   c-addr u char --  fill memory with char
    [UNDEFINED] FILL
    [IF]
    CODE FILL
    MOV @PSP+,X     \ count
    MOV @PSP+,W     \ address
    CMP #0,X
    0<> IF
        BEGIN
            MOV.B TOS,0(W)    \ store char in memory
            ADD #1,W
            SUB #1,X
        0= UNTIL
    THEN
    MOV @PSP+,TOS     \ empties stack
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ --------------------
\ INTERPRET COMPLEMENT
\ --------------------
\ https://forth-standard.org/standard/core/HEX
    [UNDEFINED] HEX
    [IF]
    CODE HEX
    MOV #$10,&BASEADR
    MOV @IP+,PC
    ENDCODE
    [THEN]

    \ https://forth-standard.org/standard/core/DECIMAL
    [UNDEFINED] DECIMAL
    [IF]
    CODE DECIMAL
    MOV #$0A,&BASEADR
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/p
\ (         --          skip input until char ) or EOL
    [UNDEFINED] (   ; )
    [IF]
    : (
    ')' WORD DROP
    ; IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/Dotp
\ .(        --          type comment immediatly.
    [UNDEFINED] .(  ; "
    [IF]
    CODE .(         ; "
    MOV #0,&CAPS    \ CAPS OFF
    COLON
    ')' WORD
    COUNT TYPE
    HI2LO
    MOV #$20,&CAPS   \ CAPS ON
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE IMMEDIATE
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
    [IF]
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
    [ ' \ 8 + , ]           \ compile INTERPRET
    HI2LO
    MOV @RSP+,&TOIN         \ 4
    MOV @RSP+,&SOURCE_ORG   \ 4
    MOV @RSP+,&SOURCE_LEN   \ 4
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/RECURSE
\ C RECURSE  --      recurse to current definition
    [UNDEFINED] RECURSE
    [IF]
    CODE RECURSE
    MOV &DP,X
    MOV &LAST_CFA,0(X)
    ADD #2,&DP
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/SOURCE
\ SOURCE    -- adr u    of current input buffer
    [UNDEFINED] SOURCE
    [IF]
    CODE SOURCE
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &SOURCE_LEN,TOS
    MOV &SOURCE_ORG,0(PSP)
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/VARIABLE
\ VARIABLE <name>       --                      define a Forth VARIABLE
    [UNDEFINED] VARIABLE
    [IF]
    : VARIABLE
    CREATE
    HI2LO
    MOV #DOVAR,-4(W)        \   CFA = CALL rDOVAR
    MOV @RSP+,IP
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

\ https://forth-standard.org/standard/core/STATE
\ STATE   -- a-addr       holds compiler state
    [UNDEFINED] STATE
    [IF]
    STATEADR CONSTANT STATE
    [THEN]

\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
    [UNDEFINED] BASE
    [IF]
    BASEADR  CONSTANT BASE
    [THEN]

\ https://forth-standard.org/standard/core/toIN
\ C >IN     -- a-addr       holds offset in input stream
    [UNDEFINED] >IN
    [IF]
    TOIN CONSTANT >IN
    [THEN]

\ https://forth-standard.org/standard/core/PAD
\  PAD           --  addr
    [UNDEFINED] PAD
    [IF]
    PAD_ORG CONSTANT PAD
    [THEN]

\ https://forth-standard.org/standard/core/BL
\ BL      -- char            an ASCII space
    [UNDEFINED] BL
    [IF]
    'SP' CONSTANT BL
    [THEN]

\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
    [UNDEFINED] SPACE
    [IF]
    : SPACE
    'SP' EMIT ;
    [THEN]

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

    [UNDEFINED] DEFER
    [IF]
\ https://forth-standard.org/standard/core/DEFER
\ Skip leading space delimiters. Parse name delimited by a space.
\ Create a definition for name with the execution semantics defined below.
\
\ name Execution:   --
\ Execute the xt that name is set to execute, i.e. NEXT (nothing),
\ until the phrase ' word IS name is executed, causing a new value of xt to be assigned to name.
    : DEFER
    CREATE
    HI2LO
    MOV #$4030,-4(W)        \4 first CELL = MOV @PC+,PC = BR #addr
    MOV #NEXT_ADR,-2(W)     \3 second CELL              =   ...mNEXT : do nothing by default
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]
\    DEFER CR       \ DEFERed definition, by default executes :NONAME part
    CODE CR         \ replaced by this CODE definition
    MOV #NEXT_ADR,PC
    ENDCODE

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]

\ https://forth-standard.org/standard/core/TO
\ TO name Run-time: ( x -- )
\ Assign the value x to named VALUE.
    [UNDEFINED] TO
    [IF]
    CODE TO
    BIS #UF9,SR
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/VALUE
\ ( x "<spaces>name" -- )                      define a Forth VALUE
\ Skip leading space delimiters. Parse name delimited by a space.
\ Create a definition for name with the execution semantics defined below,
\ with an initial value equal to x.
\
\ name Execution: ( -- x )
\ Place x on the stack. The value of x is that given when name was created,
\ until the phrase x TO name is executed, causing a new value of x to be assigned to name.
    [UNDEFINED] VALUE
    [IF]
    : VALUE                 \ x "<spaces>name" --
    CREATE ,
    DOES>
    HI2LO
    MOV @RSP+,IP
    BIT #UF9,SR         \ 2 see TO
    0= IF               \ 2 if UF9 is not set
        MOV @TOS,TOS    \ 2     execute FETCH
        MOV @IP+,PC     \ 4
    THEN                \   else
    BIC #UF9,SR         \ 2     clear UF9 flag
    MOV #!,PC           \ 4     execute STORE
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CASE
    [UNDEFINED] CASE
    [IF]

    : CASE 0
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
    0 DO POSTPONE THEN
    LOOP
    ; IMMEDIATE
    [THEN]

    RST_SET

    ECHO
; CORE_ANS.f is loaded

