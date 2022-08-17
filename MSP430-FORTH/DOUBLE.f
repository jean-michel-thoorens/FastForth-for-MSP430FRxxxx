\ -*- coding: utf-8 -*-
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, DOUBLE_INPUT
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    CHIPSTICK_FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
\ MY_MSP430FR5738_2
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
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\
\ ASSEMBLER conditionnal usage with ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<
\

    CODE ABORT_DOUBLE
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #BIT7,TOS
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (DOUBLE input), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #400,TOS            \   FastForth V4.0
    COLON
    $0D EMIT                \ return to column 1 without CR
    ABORT" FastForth V4.0 please!"
    ABORT" build FastForth with DOUBLE_INPUT addon!"
    RST_RET                 \ if no abort remove this word
    ;

    ABORT_DOUBLE

; -----------------------------------------------------
; DOUBLE.f
; -----------------------------------------------------
    [DEFINED] {DOUBLE} 
    [IF] {DOUBLE} [THEN]

    [UNDEFINED] {DOUBLE} [IF]
    MARKER {DOUBLE}

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS)
; ------------------------------------------------------------------

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

    [UNDEFINED] 0< [IF]
\ https://forth-standard.org/standard/core/Zeroless
\ 0<     n -- flag      true if TOS negative
    CODE 0<
    ADD TOS,TOS     \ 1 set carry if TOS negative
    SUBC TOS,TOS    \ 1 TOS=-1 if carry was clear
    XOR #-1,TOS     \ 1 TOS=-1 if carry was set
    MOV @IP+,PC     \
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

    [UNDEFINED] DUP [IF]
\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
    CODE DUP
BW1 SUB #2,PSP      \ 2  push old TOS..
    MOV TOS,0(PSP)  \ 3  ..onto stack
    MOV @IP+,PC     \ 4
    ENDCODE

    CODE ?DUP
\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
    CMP #0,TOS      \ 2  test for TOS nonzero
    0<> ?GOTO BW1    \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] NIP [IF]
\ https://forth-standard.org/standard/core/NIP
\ NIP      x1 x2 -- x2         Drop the first item below the top of stack
    CODE NIP
    ADD #2,PSP
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
    CODE UM/MOD
        PUSH #DROP      \
        MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
    ENDCODE
    [THEN]

    KERNEL_ADDON @ 0<   ; test the switch: FLOORED/SYMETRIC DIVISION
    [IF]
        [UNDEFINED] FM/MOD [IF]
\ https://forth-standard.org/standard/core/FMDivMOD
\ FM/MOD   d1 n1 -- r q   floored signed div'n
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
        PUSHM #3,IP         \           save IP,S,T
        LO2HI
            UM/MOD          \ -- uREMlo uQUOTlo
        HI2LO
        POPM #3,IP          \           restore T,S,IP
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
        [UNDEFINED] SM/REM [IF]
\ https://forth-standard.org/standard/core/SMDivREM
\ SM/REM   DVDlo DVDhi DIV -- r3 q4  symmetric signed div
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
        PUSHM #3,IP         \           save IP,S,T
        LO2HI
            UM/MOD          \ -- uREMlo uQUOTlo
        HI2LO
        POPM #3,IP          \           restore T,S,IP
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

    [UNDEFINED] / [IF]
\ https://forth-standard.org/standard/core/Div
\ /      n1 n2 -- n3       signed quotient
    : /
    >R DUP 0< R>
    [ KERNEL_ADDON @ 0< ]
    [IF]    FM/MOD
    [ELSE]  SM/REM
    [THEN]
    NIP
    ;
    [THEN]

    [UNDEFINED] C@ [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
    CODE C@
    MOV.B @TOS,TOS
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

    [UNDEFINED] < [IF]      \ define < and >
\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
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

    [UNDEFINED] IF [IF] \ define IF THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    CODE IF             \ immediate
    SUB #2,PSP          \
    MOV TOS,0(PSP)      \
    MOV &DP,TOS         \ -- HERE
    ADD #4,&DP          \           compile one word, reserve one word
    MOV #QFBRAN,0(TOS)  \ -- HERE   compile QFBRAN
    ADD #2,TOS          \ -- HERE+2=IFadr
    MOV @IP+,PC
    ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
    CODE THEN           \ immediate
    MOV &DP,0(TOS)      \ -- IFadr
    MOV @PSP+,TOS       \ --
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
    CODE ELSE           \ immediate
    ADD #4,&DP          \ make room to compile two words
    MOV &DP,W           \ W=HERE+4
    MOV #BRAN,-4(W) 
    MOV W,0(TOS)        \ HERE+4 ==> [IFadr]
    SUB #2,W            \ HERE+2
    MOV W,TOS           \ -- ELSEadr
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] TO [IF]
\ https://forth-standard.org/standard/core/TO
    CODE TO
    BIS #UF9,SR
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] DOES> [IF]
\ https://forth-standard.org/standard/core/DOES
\ DOES>    --          set action for the latest CREATEd definition
    CODE DOES>
    MOV &LAST_CFA,W     \ W = CFA of CREATEd word
    MOV #DODOES,0(W)    \ replace CFA (CALL rDOCON) by new CFA (CALL rDODOES)
    MOV IP,2(W)         \ replace PFA by the address after DOES> as execution address
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
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
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] 2@ [IF]
\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
    CODE 2@
    SUB #2,PSP
    MOV 2(TOS),0(PSP)
    MOV @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] 2! [IF]
\ https://forth-standard.org/standard/core/TwoStore
\ 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
    CODE 2!
    MOV @PSP+,0(TOS)
    MOV @PSP+,2(TOS)
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] 2DUP [IF]
\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
    CODE 2DUP
    SUB #4,PSP          \ -- x1 x x x2
    MOV TOS,2(PSP)      \ -- x1 x2 x x2
    MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x2
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] 2DROP [IF]
\ https://forth-standard.org/standard/core/TwoDROP
\ 2DROP  x1 x2 --          drop 2 cells
    CODE 2DROP
    ADD #2,PSP
    MOV @PSP+,TOS
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] 2SWAP [IF]
\ https://forth-standard.org/standard/core/TwoSWAP
\ 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
    CODE 2SWAP
    MOV @PSP,W          \ -- x1 x2 x3 x4    W=x3
    MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x4
    MOV W,4(PSP)        \ -- x3 x2 x1 x4
    MOV TOS,W           \ -- x3 x2 x1 x4    W=x4
    MOV 2(PSP),TOS      \ -- x3 x2 x1 x2    W=x4
    MOV W,2(PSP)        \ -- x3 x4 x1 x2
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] 2OVER [IF]
\ https://forth-standard.org/standard/core/TwoOVER
\ 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
    CODE 2OVER
    SUB #4,PSP          \ -- x1 x2 x3 x x x4
    MOV TOS,2(PSP)      \ -- x1 x2 x3 x4 x x4
    MOV 8(PSP),0(PSP)   \ -- x1 x2 x3 x4 x1 x4
    MOV 6(PSP),TOS      \ -- x1 x2 x3 x4 x1 x2
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] 2>R [IF]
\ https://forth-standard.org/standard/core/TwotoR
\ ( x1 x2 -- ) ( R: -- x1 x2 )   Transfer cell pair x1 x2 to the return stack.
    CODE 2>R
    PUSH @PSP+
    PUSH TOS
    MOV @PSP+,TOS
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] 2R@ [IF]
\ https://forth-standard.org/standard/core/TwoRFetch
\ ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 ) Copy cell pair x1 x2 from the return stack.
    CODE 2R@
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV @RSP,TOS
    MOV 2(RSP),0(PSP)
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] 2R> [IF]
\ https://forth-standard.org/standard/core/TwoRfrom
\ ( -- x1 x2 ) ( R: x1 x2 -- )  Transfer cell pair x1 x2 from the return stack
    CODE 2R>
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV @RSP+,TOS
    MOV @RSP+,0(PSP)
    NEXT
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

; ===============================================
; DOUBLE word set
; ===============================================

    [UNDEFINED] D. [IF]
\ https://forth-standard.org/standard/double/Dd
\ D.     dlo dhi --           display d (signed)
    CODE D.
    MOV TOS,S       \ S will be pushed as sign by DDOT
    MOV #D.,PC   \ U. + 10 = DDOT
    ENDCODE
    [THEN]

    [UNDEFINED] 2ROT [IF]
\ https://forth-standard.org/standard/double/TwoROT
\ Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the top of the stack.
    CODE 2ROT
    MOV 8(PSP),X        \ 3
    MOV 6(PSP),Y        \ 3
    MOV 4(PSP),8(PSP)   \ 5
    MOV 2(PSP),6(PSP)   \ 5
    MOV @PSP,4(PSP)     \ 4
    MOV TOS,2(PSP)      \ 3
    MOV X,0(PSP)        \ 3
    MOV Y,TOS           \ 1
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] D>S [IF]
\ https://forth-standard.org/standard/double/DtoS
\ D>S    d -- n          double prec -> single.
    CODE D>S
    MOV @PSP+,TOS
    NEXT
    ENDCODE
    [THEN]

    [UNDEFINED] D0= [IF]    \ define: D0= D0< D= D< DU<

\ https://forth-standard.org/standard/double/DZeroEqual
    CODE D0=
    ADD #2,PSP
    CMP #0,TOS
    MOV #0,TOS
    0= IF
        CMP #0,-2(PSP)
        0= IF
BW1         MOV #-1,TOS
        THEN
    THEN
BW2 AND #-1,TOS         \  to set N, Z flags
    NEXT
    ENDCODE

\ https://forth-standard.org/standard/double/DZeroless
    CODE D0<
    ADD #2,PSP
    CMP #0,TOS
    MOV #0,TOS
    S< ?GOTO BW1
    GOTO BW2
    ENDCODE

\ https://forth-standard.org/standard/double/DEqual
    CODE D=
    ADD #6,PSP              \ 2
    CMP TOS,-4(PSP)         \ 3 ud1H - ud2H
    MOV #0,TOS              \ 1
    0<> ?GOTO BW2           \ 2
    CMP -6(PSP),-2(PSP)     \ 4 ud1L - ud2L
    0= ?GOTO BW1            \ 2
    GOTO BW2
    ENDCODE

\ https://forth-standard.org/standard/double/Dless
\ flag is true if and only if d1 is less than d2
    CODE D<
    ADD #6,PSP              \ 2
    CMP TOS,-4(PSP)         \ 3 d1H - d2H
    MOV #0,TOS              \ 1
    S< IF
BW1     MOV #-1,TOS
    THEN
BW3 0<> ?GOTO BW2           \ 2
    CMP -6(PSP),-2(PSP)     \ 4 d1L - d2L
    U>= ?GOTO BW2           \  to set N, Z flags
    U< ?GOTO BW1            \ 2
    ENDCODE

\ https://forth-standard.org/standard/double/DUless
\ flag is true if and only if ud1 is less than ud2
    CODE DU<
    ADD #6,PSP              \ 2
    CMP TOS,-4(PSP)         \ 3 ud1H - ud2H
    MOV #0,TOS              \ 1
    U>= ?GOTO BW3
    U< ?GOTO BW1            \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] D+ [IF] \ define: D+ M+
\ https://forth-standard.org/standard/double/DPlus
    CODE D+
BW1 ADD @PSP+,2(PSP)
    ADDC @PSP+,TOS
    MOV @IP+,PC         \ 4
    ENDCODE

\ https://forth-standard.org/standard/double/MPlus
    CODE M+
    SUB #2,PSP
    CMP #0,TOS
    MOV TOS,0(PSP)
    MOV #-1,TOS
    0>= IF
        MOV #0,TOS
    THEN
    GOTO BW1
    ENDCODE
    [THEN]

    [UNDEFINED] D- [IF]
\ https://forth-standard.org/standard/double/DMinus
    CODE D-
    SUB @PSP+,2(PSP)
    SUBC TOS,0(PSP)
    MOV @PSP+,TOS
    MOV @IP+,PC         \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] DNEGATE [IF]    \ define DNEGATE DABS
\ https://forth-standard.org/standard/double/DNEGATE
    CODE DNEGATE
BW1 XOR #-1,0(PSP)
    XOR #-1,TOS
    ADD #1,0(PSP)
    ADDC #0,TOS
    MOV @IP+,PC         \ 4
    ENDCODE

\ https://forth-standard.org/standard/double/DABS
\ DABS     d1 -- |d1|     absolute value
    CODE DABS
    CMP #0,TOS       \  1
    0< ?GOTO BW1
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] D2/ [IF]
\ https://forth-standard.org/standard/double/DTwoDiv
    CODE D2/
    RRA TOS
    RRC 0(PSP)
    MOV @IP+,PC         \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] D2* [IF]
\ https://forth-standard.org/standard/double/DTwoTimes
    CODE D2*
    ADD @PSP,0(PSP)
    ADDC TOS,TOS
    MOV @IP+,PC         \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] DMAX [IF]
\ https://forth-standard.org/standard/double/DMAX
    : DMAX              \ -- d1 d2
    2OVER 2OVER         \ -- d1 d2 d1 d2
    D< IF               \ -- d1 d2
        2>R 2DROP 2R>   \ -- d2
    ELSE                \ -- d1 d2
        2DROP           \ -- d1
    THEN
    ;
    [THEN]

    [UNDEFINED] DMIN [IF]
\ https://forth-standard.org/standard/double/DMIN
    : DMIN              \ -- d1 d2
    2OVER 2OVER         \ -- d1 d2 d1 d2
    D< IF               \ -- d1 d2
        2DROP           \ -- d1
    ELSE
        2>R 2DROP 2R>   \ -- d1 d2
    THEN                \ -- d2
    ;
    [THEN]

    [UNDEFINED] M*/ [IF]
\ https://forth-standard.org/standard/double/MTimesDiv

        RST_SET

        CODE TSTBIT     \ addr bit_mask -- true/flase flag
        MOV @PSP+,X
        AND @X,TOS
        MOV @IP+,PC
        ENDCODE

        KERNEL_ADDON HMPY TSTBIT \ hardware MPY ?

        RST_RET     \ remove TSTBIT definition

        [IF]   ; MSP430FRxxxx with hardware_MPY

        CODE M*/                \ d1 * n1 / +n2 -- d2
        MOV 4(PSP),&MPYS32L     \ 5             Load 1st operand    d1lo
        MOV 2(PSP),&MPYS32H     \ 5                                 d1hi
        MOV @PSP+,&OP2          \ 4 -- d1 n2    load 2nd operand    n1
        MOV TOS,T               \ T = DIV
        NOP3
        MOV &RES0,S             \ 3 S = RESlo
        MOV &RES1,TOS           \ 3 TOS = RESmi
        MOV &RES2,W             \ 3 W = REShi
        MOV #0,rDOCON           \ clear sign flag
        CMP #0,W                \ negative product ?
        S< IF                   \ compute ABS value if yes
            XOR #-1,S
            XOR #-1,TOS
            XOR #-1,W
            ADD #1,S
            ADDC #0,TOS
            ADDC #0,W
            MOV #-1,rDOCON       \ set sign flag
        THEN

        [ELSE]  ; no hardware multiplier

        CODE M*/    \ d1lo d1hi n1 +n2 -- d2lo d2hi
        MOV #0,rDOCON               \ rDOCON = sign
        CMP #0,2(PSP)               \ d1 < 0 ?
        S< IF
            XOR #-1,4(PSP)
            XOR #-1,2(PSP)
            ADD #1,4(PSP)
            ADDC #0,2(PSP)
            MOV #-1,rDOCON
        THEN                        \ ud1
        CMP #0,0(PSP)               \ n1 < 0 ?
        S< IF
            XOR #-1,0(PSP)
            ADD #1,0(PSP)           \ u1
            XOR #-1,rDOCON
        THEN                        \ let's process UM*     -- ud1lo ud1hi u1 +n2
                    MOV 4(PSP),Y            \ 3 uMDlo
                    MOV 2(PSP),T            \ 3 uMDhi
                    MOV @PSP+,S             \ 2 uMRlo        -- ud1lo ud1hi +n2
                    MOV #0,rDODOES          \ 1 uMDlo=0
                    MOV #0,2(PSP)           \ 3 uRESlo=0
                    MOV #0,0(PSP)           \ 3 uRESmi=0     -- uRESlo uRESmi +n2
                    MOV #0,W                \ 1 uREShi=0
                    MOV #1,X                \ 1 BIT TEST REGlo
        BEGIN       BIT X,S                 \ 1 test actual bit in uMRlo
            0<> IF  ADD Y,2(PSP)            \ 3 IF 1: ADD uMDlo TO uRESlo
                    ADDC T,0(PSP)           \ 3      ADDC uMDmi TO uRESmi
                    ADDC rDODOES,W          \ 1      ADDC uMRlo TO uREShi
            THEN    ADD Y,Y                 \ 1 (RLA LSBs) uMDlo *2
                    ADDC T,T                \ 1 (RLC MSBs) uMDhi *2
                    ADDC rDODOES,rDODOES    \ 1 (RLA LSBs) uMDlo *2
                    ADD X,X                 \ 1 (RLA) NEXT BIT TO TEST
        U>= UNTIL                           \ 1 IF BIT IN CARRY: FINISHED   W=uREShi
\       TOS     +n2
\       W       REShi
\       0(PSP)  RESmi
\       2(PSP)  RESlo
        MOV TOS,T
        MOV @PSP,TOS
        MOV 2(PSP),S

        [THEN]  ; endcase of software/hardware_MPY

\   process division
\   reg     input           output
\   ------------------------------
\   S       = DVD(15-0)
\   TOS     = DVD(31-16)
\   W       = DVD(47-32)    REM
\   T       = DIV(15-0)
\   X       = Don't care    QUOTlo
\   Y       = Don't care    QUOThi
\   rDODOES = count
\   rDOCON  = sign
\   2(PSP)                  REM
\   0(PSP)                  QUOTlo
\   TOS                     QUOThi
    MOV #32,rDODOES         \ 2  init loop count
    CMP #0,W                \ DVDhi = 0 ?
    0= IF                   \ if yes
        MOV TOS,W           \ DVDmi --> DVDhi
        CALL #MDIV1DIV2     \ with loop count / 2
    ELSE
        CALL #MDIV1         \ -- urem ud2lo ud2hi
    THEN
    MOV @PSP+,0(PSP)        \ -- d2lo d2hi
    CMP #0,rDOCON           \ RES sign is set ?
    0<> IF                  \ DNEGATE quot
        XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
        CMP #0,&KERNEL_ADDON    \ floored/symetric division flag test
        S< IF                   \ if floored division and quot<0
            CMP #0,W            \ remainder <> 0 ?
            0<> IF              \ if floored division, quot<0 and remainder <>0
                SUB #1,0(PSP)   \ decrement quotient
                SUBC #0,TOS
            THEN
        THEN
    THEN
    MOV #XDODOES,rDODOES
    MOV #XDOCON,rDOCON
    MOV @IP+,PC             \ 52 words
    ENDCODE
    [THEN]

    [UNDEFINED] 2VARIABLE [IF]
\ https://forth-standard.org/standard/double/TwoVARIABLE
    : 2VARIABLE \  --
    CREATE
    HI2LO
    ADD #4,&DP
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] 2CONSTANT [IF]
\ https://forth-standard.org/standard/double/TwoCONSTANT
    : 2CONSTANT \  udlo/dlo/Flo udhi/dhi/Shi --         to create double or s15q16 CONSTANT
    CREATE
    , ,             \ compile hi then lo
    DOES>
    2@              \ execution part
    ;
    [THEN]

    [UNDEFINED] 2VALUE [IF]
\ https://forth-standard.org/standard/double/TwoVALUE
    : 2VALUE        \ x1 x2 "<spaces>name" --
    CREATE , ,      \ compile Shi then Flo
    DOES>
    HI2LO
    MOV @RSP+,IP
    BIT #UF9,SR     \ flag set by TO
    0= IF
        MOV #2@,PC  \ execute TwoFetch
    THEN
    BIC #UF9,SR     \ clear flag
    MOV #2!,PC      \ execute TwoStore
    ENDCODE
    [THEN]


    [UNDEFINED] 2LITERAL [IF]
\ https://forth-standard.org/standard/double/TwoLITERAL
    CODE 2LITERAL
    BIS #UF9,SR     \ see LITERAL
    MOV #LITERAL,PC
    ENDCODE IMMEDIATE
    [THEN]


    [UNDEFINED] D.R [IF]
\ https://forth-standard.org/standard/double/DDotR
\ D.R       d n --
    : D.R
    >R SWAP OVER DABS <# #S ROT SIGN #>
    R> OVER - SPACES TYPE
    ;
    [THEN]

    RST_SET

    [THEN] \ endof [UNDEFINED] {DOUBLE} 

; -------------------------------
; Complement to pass DOUBLE TESTS
; -------------------------------

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

    [UNDEFINED] VARIABLE [IF]
\ https://forth-standard.org/standard/core/VARIABLE
\ VARIABLE <name>       --     define a Forth VARIABLE
    : VARIABLE
    CREATE
    HI2LO
    MOV #DOVAR,-4(W)    \   CFA = CALL rDOVAR
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --    define a Forth CONSTANT
    : CONSTANT
    CREATE
    HI2LO
    MOV TOS,-2(W)       \   PFA = n
    MOV @PSP+,TOS
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] CELLS [IF]
\ https://forth-standard.org/standard/core/CELLS
\ CELLS    n1 -- n2            cells->adrs units
    CODE CELLS
    ADD TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] DEPTH [IF]
\ https://forth-standard.org/standard/core/DEPTH
\ DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
    CODE DEPTH
    MOV TOS,-2(PSP)
    MOV #PSTACK,TOS
    SUB PSP,TOS     \ PSP-S0--> TOS
    RRA TOS         \ TOS/2   --> TOS
    SUB #2,PSP      \ post decrement stack...
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] IF [IF]     \ define IF THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    CODE IF       \ immediate
    SUB #2,PSP              \
    MOV TOS,0(PSP)          \
    MOV &DP,TOS             \ -- HERE
    ADD #4,&DP              \           compile one word, reserve one word
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

    [UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
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

    [UNDEFINED] DO [IF] \ define DO LOOP +LOOP

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

    [UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    CODE +
    ADD @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
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

    [UNDEFINED] 0= [IF]
\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
    CODE 0=
    SUB #1,TOS      \ borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] SOURCE [IF]
\ https://forth-standard.org/standard/core/SOURCE
\ SOURCE    -- adr u    of current input buffer
    CODE SOURCE
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &SOURCE_LEN,TOS
    MOV &SOURCE_ORG,0(PSP)
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] >IN [IF]
\ https://forth-standard.org/standard/core/toIN
\ C >IN     -- a-addr       holds offset in input stream
    TOIN CONSTANT >IN
    [THEN]

    [UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
    CODE 1+
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] CHAR [IF]
\ https://forth-standard.org/standard/core/CHAR
\ CHAR   -- char           parse ASCII character
    : CHAR
        $20 WORD 1+ C@
    ;
    [THEN]

    [UNDEFINED] [CHAR] [IF]
\ https://forth-standard.org/standard/core/BracketCHAR
\ [CHAR]   --          compile character literal
    : [CHAR]
        CHAR POSTPONE LITERAL
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] 2/ [IF]
\ https://forth-standard.org/standard/core/TwoDiv
\ 2/      x1 -- x2        arithmetic right shift
    CODE 2/
    RRA TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] INVERT [IF]
\ https://forth-standard.org/standard/core/INVERT
\ INVERT   x1 -- x2            bitwise inversion
    CODE INVERT
    XOR #-1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] RSHIFT [IF]
\ https://forth-standard.org/standard/core/RSHIFT
\ RSHIFT  x1 u -- x2    logical R7 shift u places
    CODE RSHIFT
    MOV @PSP+,W
    AND #$1F,TOS       \ no need to shift more than 16
    0<> IF
        BEGIN
            BIC #C,SR   \ Clr Carry
            RRC W
            SUB #1,TOS
        0= UNTIL
    THEN
    MOV W,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] S>D [IF]
\ https://forth-standard.org/standard/core/StoD
\ S>D    n -- d          single -> double prec.
    : S>D
        DUP 0<
    ;
    [THEN]

    [UNDEFINED] 1- [IF]
\ https://forth-standard.org/standard/core/OneMinus
\ 1-      n1/u1 -- n2/u2     subtract 1 from TOS
    CODE 1-
    SUB #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] NEGATE [IF]
\ https://forth-standard.org/standard/core/NEGATE
\ C NEGATE   x1 -- x2            two's complement
    CODE NEGATE
    XOR #-1,TOS
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] HERE [IF]
    CODE HERE
    MOV #BEGIN,PC
    ENDCODE
    [THEN]

    [UNDEFINED] CHARS [IF]
\ https://forth-standard.org/standard/core/CHARS
\ CHARS    n1 -- n2            chars->adrs units
    CODE CHARS
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
        0<> IF          \ else already done !
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

    [UNDEFINED] DECIMAL [IF]
\ https://forth-standard.org/standard/core/DECIMAL
    CODE DECIMAL
    MOV #$0A,&BASEADR
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] BASE [IF]
\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
    BASEADR CONSTANT BASE
    [THEN]

    [UNDEFINED] ( [IF]
\ https://forth-standard.org/standard/core/p
\ (         --          skip input until char ) or EOL
    : (
    ')' WORD DROP
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] .( [IF] ; "
\ https://forth-standard.org/standard/core/Dotp
\ .(        --          type comment immediatly.
    CODE .(        ; "
    MOV #0,&CAPS    \ CAPS OFF
    COLON
    ')' WORD
    COUNT TYPE
    $20 CAPS !      \ CAPS ON
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] CR [IF]
\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
\    DEFER CR       \ DEFERed definition, by default executes :NONAME part
    CODE CR         \ replaced by this CODE definition
    MOV #NEXT_ADR,PC
    ENDCODE

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]

\ ==============================================================================
\ TESTER
\ ==============================================================================
\
\ From: John Hayes S1I
\ Subject: tester.fr
\ Date: Mon, 27 Nov 95 13:10:09 PST
\
\ (C) 1995 JOHNS HOPKINS UNIVERSITY / APPLIED PHYSICS LABORATORY
\ MAY BE DISTRIBUTED FREELY AS LONG AS THIS COPYRIGHT NOTICE REMAINS.
\ VERSION 1.1
\
\ 22/1/09 The words { and } have been changed to T{ and }T respectively to
\ agree with the Forth 200X file ttester.fs. This avoids clashes with
\ locals using { ... } and the FSL use of }
\

\ 13/05/14 jmt. added colorised error messages.
 0 CONSTANT FALSE
-1 CONSTANT TRUE

\ SET THE FOLLOWING FLAG TO TRUE FOR MORE VERBOSE OUTPUT; THIS MAY
\ ALLOW YOU TO TELL WHICH TEST CAUSED YOUR SYSTEM TO HANG.
VARIABLE VERBOSE
    FALSE VERBOSE !
\   TRUE VERBOSE !
\
\ : EMPTY-STACK ( ... -- )  \ EMPTY STACK: HANDLES UNDERFLOWED STACK TOO.
\     DEPTH ?DUP
\             IF DUP 0< IF NEGATE 0
\             DO 0 LOOP
\             ELSE 0 DO DROP LOOP THEN
\             THEN ;
\
\ : ERROR     \ ( C-ADDR U -- ) DISPLAY AN ERROR MESSAGE FOLLOWED BY
\         \ THE LINE THAT HAD THE ERROR.
\     TYPE SOURCE TYPE CR          \ DISPLAY LINE CORRESPONDING TO ERROR
\     EMPTY-STACK              \ THROW AWAY EVERY THING ELSE
\     QUIT  \ *** Uncomment this line to QUIT on an error
\ ;

VARIABLE ACTUAL-DEPTH           \ STACK RECORD
CREATE ACTUAL-RESULTS 20 CELLS ALLOT

: T{        \ ( -- ) SYNTACTIC SUGAR.
    ;

: ->        \ ( ... -- ) RECORD DEPTH AND CONTENT OF STACK.
    DEPTH DUP ACTUAL-DEPTH !     \ RECORD DEPTH
    ?DUP IF              \ IF THERE IS SOMETHING ON STACK
        0 DO ACTUAL-RESULTS I CELLS + ! LOOP \ SAVE THEM
    THEN ;

: }T        \ ( ... -- ) COMPARE STACK (EXPECTED) CONTENTS WITH SAVED
            \ (ACTUAL) CONTENTS.
    DEPTH ACTUAL-DEPTH @ = IF   \ IF DEPTHS MATCH
        DEPTH ?DUP IF           \ IF THERE IS SOMETHING ON THE STACK
        0 DO                    \ FOR EACH STACK ITEM
            ACTUAL-RESULTS I CELLS + @  \ COMPARE ACTUAL WITH EXPECTED
\           = 0= IF S" INCORRECT RESULT: " ERROR LEAVE THEN \ jmt
            = 0= IF TRUE ABORT" INCORRECT RESULT" THEN      \ jmt : abort with colorised message
        LOOP
        THEN
    ELSE                 \ DEPTH MISMATCH
\       S" WRONG NUMBER OF RESULTS: " ERROR     \ jmt
        TRUE ABORT" WRONG NUMBER OF RESULTS"    \ jmt : abort with colorised message
    THEN ;

: TESTING   \ ( -- ) TALKING COMMENT.
    SOURCE VERBOSE @
    IF DUP >R TYPE CR R> >IN !
    ELSE >IN ! DROP [CHAR] * EMIT
    THEN ;

\ Constant definitions

DECIMAL

0 INVERT        CONSTANT 1SD
1SD 1 RSHIFT    CONSTANT MAX-INTD   \ 01...1
MAX-INTD INVERT CONSTANT MIN-INTD   \ 10...0
MAX-INTD 2/     CONSTANT HI-INT     \ 001...1
MIN-INTD 2/     CONSTANT LO-INT     \ 110...1

\ 1SD .
\ MAX-INTD .
\ MIN-INTD .
\ HI-INT .
\ LO-INT .

ECHO

\ ==============================================================================
\ DOUBLE TEST
\ ==============================================================================
\ https://raw.githubusercontent.com/gerryjackson/forth2012-test-suite/master/src/doubletest.fth
\
\ To test the ANS Forth Double-Number word set and double number extensions
\
\ This program was written by Gerry Jackson in 2006, with contributions from
\ others where indicated, and is in the public domain - it can be distributed
\ and/or modified in any way but please retain this notice.
\
\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
\
\ The tests are not claimed to be comprehensive or correct
\ ------------------------------------------------------------------------------
\ Version 0.13  Assumptions and dependencies changed
\         0.12  1 August 2015 test D< acts on MS cells of double word
\         0.11  7 April 2015 2VALUE tested
\         0.6   1 April 2012 Tests placed in the public domain.
\               Immediate 2CONSTANTs and 2VARIABLEs tested
\         0.5   20 November 2009 Various constants renamed to avoid
\               redefinition warnings. <TRUE> and <FALSE> replaced
\               with TRUE and FALSE
\         0.4   6 March 2009 { and } replaced with T{ and }T
\               Tests rewritten to be independent of word size and
\               tests re-ordered
\         0.3   20 April 2007 ANS Forth words changed to upper case
\         0.2   30 Oct 2006 Updated following GForth test to include
\               various constants from core.fr
\         0.1   Oct 2006 First version released
\ ------------------------------------------------------------------------------
\ The tests are based on John Hayes test program for the core word set
\
\ Words tested in this file are:
\     2CONSTANT 2LITERAL 2VARIABLE D+ D- D. D.R D0< D0= D2* D2/
\     D< D= D>S DABS DMAX DMIN DNEGATE M*/ M+ 2ROT DU<
\ Also tests the interpreter and compiler reading a double number
\ ------------------------------------------------------------------------------
\ Assumptions and dependencies:
\     - tester.fr (or ttester.fs), errorreport.fth and utilities.fth have been
\       included prior to this file
\     - the Core word set is available and tested
; ----------------------------------------------------------------------------
TESTING interpreter and compiler reading double numbers, with/without prefixes

T{ 1. -> 1 0 }T
T{ -2. -> -2 -1 }T
T{ : RDL1 3. ; RDL1 -> 3 0 }T
T{ : RDL2 -4. ; RDL2 -> -4 -1 }T

VARIABLE OLD-DBASE
DECIMAL BASE @ OLD-DBASE !
T{ #12346789. -> 12346789. }T
T{ #-12346789. -> -12346789. }T
T{ $12aBcDeF. -> 313249263. }T
T{ $-12AbCdEf. -> -313249263. }T
T{ %10010110. -> 150. }T
T{ %-10010110. -> -150. }T
; Check BASE is unchanged
T{ BASE @ OLD-DBASE @ = -> TRUE }T

; Repeat in Hex mode
16 OLD-DBASE ! 16 BASE !
T{ #12346789. -> BC65A5. }T
T{ #-12346789. -> -BC65A5. }T
T{ $12aBcDeF. -> 12AbCdeF. }T
T{ $-12AbCdEf. -> -12ABCDef. }T
T{ %10010110. -> 96. }T
T{ %-10010110. -> -96. }T
; Check BASE is unchanged
T{ BASE @ OLD-DBASE @ = -> TRUE }T   \ 2

DECIMAL
; Check number prefixes in compile mode
T{ : dnmp  #8327. $-2cbe. %011010111. ; dnmp -> 8327. -11454. 215. }T

; ----------------------------------------------------------------------------
TESTING 2CONSTANT

T{ 1 2 2CONSTANT 2C1 -> }T
T{ 2C1 -> 1 2 }T
T{ : CD1 2C1 ; -> }T
T{ CD1 -> 1 2 }T
T{ : CD2 2CONSTANT ; -> }T
T{ -1 -2 CD2 2C2 -> }T
T{ 2C2 -> -1 -2 }T
T{ 4 5 2CONSTANT 2C3 IMMEDIATE 2C3 -> 4 5 }T
T{ : CD6 2C3 2LITERAL ; CD6 -> 4 5 }T

; ----------------------------------------------------------------------------
; Some 2CONSTANTs for the following tests

1SD MAX-INTD 2CONSTANT MAX-2INT  \ 01...1
0   MIN-INTD 2CONSTANT MIN-2INT  \ 10...0
MAX-2INT 2/  2CONSTANT HI-2INT   \ 001...1
MIN-2INT 2/  2CONSTANT LO-2INT   \ 110...0

; ----------------------------------------------------------------------------
TESTING DNEGATE

T{ 0. DNEGATE -> 0. }T
T{ 1. DNEGATE -> -1. }T
T{ -1. DNEGATE -> 1. }T
T{ MAX-2INT DNEGATE -> MIN-2INT SWAP 1+ SWAP }T
T{ MIN-2INT SWAP 1+ SWAP DNEGATE -> MAX-2INT }T

; ----------------------------------------------------------------------------
TESTING D+ with small integers

T{  0.  5. D+ ->  5. }T
T{ -5.  0. D+ -> -5. }T
T{  1.  2. D+ ->  3. }T
T{  1. -2. D+ -> -1. }T
T{ -1.  2. D+ ->  1. }T
T{ -1. -2. D+ -> -3. }T
T{ -1.  1. D+ ->  0. }T

TESTING D+ with mid range integers

T{  0  0  0  5 D+ ->  0  5 }T
T{ -1  5  0  0 D+ -> -1  5 }T
T{  0  0  0 -5 D+ ->  0 -5 }T
T{  0 -5 -1  0 D+ -> -1 -5 }T
T{  0  1  0  2 D+ ->  0  3 }T
T{ -1  1  0 -2 D+ -> -1 -1 }T
T{  0 -1  0  2 D+ ->  0  1 }T
T{  0 -1 -1 -2 D+ -> -1 -3 }T
T{ -1 -1  0  1 D+ -> -1  0 }T
T{ MIN-INTD 0 2DUP D+ -> 0 1 }T
T{ MIN-INTD S>D MIN-INTD 0 D+ -> 0 0 }T

TESTING D+ with large double integers

T{ HI-2INT 1. D+ -> 0 HI-INT 1+ }T
T{ HI-2INT 2DUP D+ -> 1SD 1- MAX-INTD }T
T{ MAX-2INT MIN-2INT D+ -> -1. }T
T{ MAX-2INT LO-2INT D+ -> HI-2INT }T
T{ HI-2INT MIN-2INT D+ 1. D+ -> LO-2INT }T
T{ LO-2INT 2DUP D+ -> MIN-2INT }T

; ----------------------------------------------------------------------------
TESTING D- with small integers

T{  0.  5. D- -> -5. }T
T{  5.  0. D- ->  5. }T
T{  0. -5. D- ->  5. }T
T{  1.  2. D- -> -1. }T
T{  1. -2. D- ->  3. }T
T{ -1.  2. D- -> -3. }T
T{ -1. -2. D- ->  1. }T
T{ -1. -1. D- ->  0. }T

TESTING D- with mid-range integers

T{  0  0  0  5 D- ->  0 -5 }T
T{ -1  5  0  0 D- -> -1  5 }T
T{  0  0 -1 -5 D- ->  1  4 }T
T{  0 -5  0  0 D- ->  0 -5 }T
T{ -1  1  0  2 D- -> -1 -1 }T
T{  0  1 -1 -2 D- ->  1  2 }T
T{  0 -1  0  2 D- ->  0 -3 }T
T{  0 -1  0 -2 D- ->  0  1 }T
T{  0  0  0  1 D- ->  0 -1 }T
T{ MIN-INTD 0 2DUP D- -> 0. }T
T{ MIN-INTD S>D MAX-INTD 0 D- -> 1 1SD }T

TESTING D- with large integers

T{ MAX-2INT MAX-2INT D- -> 0. }T
T{ MIN-2INT MIN-2INT D- -> 0. }T
T{ MAX-2INT HI-2INT  D- -> LO-2INT DNEGATE }T
T{ HI-2INT  LO-2INT  D- -> MAX-2INT }T
T{ LO-2INT  HI-2INT  D- -> MIN-2INT 1. D+ }T
T{ MIN-2INT MIN-2INT D- -> 0. }T
T{ MIN-2INT LO-2INT  D- -> LO-2INT }T

; ----------------------------------------------------------------------------
TESTING D0< D0=

T{ 0. D0< -> FALSE }T
T{ 1. D0< -> FALSE }T
T{ MIN-INTD 0 D0< -> FALSE }T
T{ 0 MAX-INTD D0< -> FALSE }T
T{ MAX-2INT  D0< -> FALSE }T
T{ -1. D0< -> TRUE }T
T{ MIN-2INT D0< -> TRUE }T

T{ 1. D0= -> FALSE }T
T{ MIN-INTD 0 D0= -> FALSE }T
T{ MAX-2INT  D0= -> FALSE }T
T{ -1 MAX-INTD D0= -> FALSE }T
T{ 0. D0= -> TRUE }T
T{ -1. D0= -> FALSE }T
T{ 0 MIN-INTD D0= -> FALSE }T

; ----------------------------------------------------------------------------
TESTING D2* D2/

T{ 0. D2* -> 0. D2* }T
T{ MIN-INTD 0 D2* -> 0 1 }T
T{ HI-2INT D2* -> MAX-2INT 1. D- }T
T{ LO-2INT D2* -> MIN-2INT }T

T{ 0. D2/ -> 0. }T
T{ 1. D2/ -> 0. }T
T{ 0 1 D2/ -> MIN-INTD 0 }T
T{ MAX-2INT D2/ -> HI-2INT }T
T{ -1. D2/ -> -1. }T
T{ MIN-2INT D2/ -> LO-2INT }T

; ----------------------------------------------------------------------------
TESTING D< D=

T{  0.  1. D< -> TRUE  }T
T{  0.  0. D< -> FALSE }T
T{  1.  0. D< -> FALSE }T
T{ -1.  1. D< -> TRUE  }T
T{ -1.  0. D< -> TRUE  }T
T{ -2. -1. D< -> TRUE  }T
T{ -1. -2. D< -> FALSE }T
T{ 0 1   1. D< -> FALSE }T  \ Suggested by Helmut Eller
T{ 1.  0 1  D< -> TRUE  }T
T{ 0 -1 1 -2 D< -> FALSE }T
T{ 1 -2 0 -1 D< -> TRUE  }T
T{ -1. MAX-2INT D< -> TRUE }T
T{ MIN-2INT MAX-2INT D< -> TRUE }T
T{ MAX-2INT -1. D< -> FALSE }T
T{ MAX-2INT MIN-2INT D< -> FALSE }T
T{ MAX-2INT 2DUP -1. D+ D< -> FALSE }T
T{ MIN-2INT 2DUP  1. D+ D< -> TRUE  }T
T{ MAX-INTD S>D 2DUP 1. D+ D< -> TRUE }T \ Ensure D< acts on MS cells

T{ -1. -1. D= -> TRUE  }T
T{ -1.  0. D= -> FALSE }T
T{ -1.  1. D= -> FALSE }T
T{  0. -1. D= -> FALSE }T
T{  0.  0. D= -> TRUE  }T
T{  0.  1. D= -> FALSE }T
T{  1. -1. D= -> FALSE }T
T{  1.  0. D= -> FALSE }T
T{  1.  1. D= -> TRUE  }T

T{ 0 -1 0 -1 D= -> TRUE  }T
T{ 0 -1 0  0 D= -> FALSE }T
T{ 0 -1 0  1 D= -> FALSE }T
T{ 0  0 0 -1 D= -> FALSE }T
T{ 0  0 0  0 D= -> TRUE  }T
T{ 0  0 0  1 D= -> FALSE }T
T{ 0  1 0 -1 D= -> FALSE }T
T{ 0  1 0  0 D= -> FALSE }T
T{ 0  1 0  1 D= -> TRUE  }T

T{ MAX-2INT MIN-2INT D= -> FALSE }T
T{ MAX-2INT 0. D= -> FALSE }T
T{ MAX-2INT MAX-2INT D= -> TRUE }T
T{ MAX-2INT HI-2INT  D= -> FALSE }T
T{ MAX-2INT MIN-2INT D= -> FALSE }T
T{ MIN-2INT MIN-2INT D= -> TRUE }T
T{ MIN-2INT LO-2INT  D=  -> FALSE }T
T{ MIN-2INT MAX-2INT D= -> FALSE }T

; ----------------------------------------------------------------------------
TESTING 2LITERAL 2VARIABLE

T{ : CD3 [ MAX-2INT ] 2LITERAL ; -> }T
T{ CD3 -> MAX-2INT }T
T{ 2VARIABLE 2V1 -> }T
T{ 0. 2V1 2! -> }T
T{ 2V1 2@ -> 0. }T
T{ -1 -2 2V1 2! -> }T
T{ 2V1 2@ -> -1 -2 }T
T{ : CD4 2VARIABLE ; -> }T
T{ CD4 2V2 -> }T
T{ : CD5 2V2 2! ; -> }T
T{ -2 -1 CD5 -> }T
T{ 2V2 2@ -> -2 -1 }T
T{ 2VARIABLE 2V3 IMMEDIATE 5 6 2V3 2! -> }T
T{ 2V3 2@ -> 5 6 }T
T{ : CD7 2V3 [ 2@ ] 2LITERAL ; CD7 -> 5 6 }T
T{ : CD8 [ 6 7 ] 2V3 [ 2! ] ; 2V3 2@ -> 6 7 }T

; ----------------------------------------------------------------------------
TESTING DMAX DMIN

T{  1.  2. DMAX -> 2. }T
T{  1.  0. DMAX -> 1. }T
T{  1. -1. DMAX -> 1. }T
T{  1.  1. DMAX -> 1. }T
T{  0.  1. DMAX -> 1. }T
T{  0. -1. DMAX -> 0. }T
T{ -1.  1. DMAX -> 1. }T
T{ -1. -2. DMAX -> -1. }T

T{ MAX-2INT HI-2INT  DMAX -> MAX-2INT }T
T{ MAX-2INT MIN-2INT DMAX -> MAX-2INT }T
T{ MIN-2INT MAX-2INT DMAX -> MAX-2INT }T
T{ MIN-2INT LO-2INT  DMAX -> LO-2INT  }T

T{ MAX-2INT  1. DMAX -> MAX-2INT }T
T{ MAX-2INT -1. DMAX -> MAX-2INT }T
T{ MIN-2INT  1. DMAX ->  1. }T
T{ MIN-2INT -1. DMAX -> -1. }T


T{  1.  2. DMIN ->  1. }T
T{  1.  0. DMIN ->  0. }T
T{  1. -1. DMIN -> -1. }T
T{  1.  1. DMIN ->  1. }T
T{  0.  1. DMIN ->  0. }T
T{  0. -1. DMIN -> -1. }T
T{ -1.  1. DMIN -> -1. }T
T{ -1. -2. DMIN -> -2. }T

T{ MAX-2INT HI-2INT  DMIN -> HI-2INT  }T
T{ MAX-2INT MIN-2INT DMIN -> MIN-2INT }T
T{ MIN-2INT MAX-2INT DMIN -> MIN-2INT }T
T{ MIN-2INT LO-2INT  DMIN -> MIN-2INT }T

T{ MAX-2INT  1. DMIN ->  1. }T
T{ MAX-2INT -1. DMIN -> -1. }T
T{ MIN-2INT  1. DMIN -> MIN-2INT }T
T{ MIN-2INT -1. DMIN -> MIN-2INT }T

; ----------------------------------------------------------------------------
TESTING D>S DABS

T{  1234  0 D>S ->  1234 }T
T{ -1234 -1 D>S -> -1234 }T
T{ MAX-INTD  0 D>S -> MAX-INTD }T
T{ MIN-INTD -1 D>S -> MIN-INTD }T

T{  1. DABS -> 1. }T
T{ -1. DABS -> 1. }T
T{ MAX-2INT DABS -> MAX-2INT }T
T{ MIN-2INT 1. D+ DABS -> MAX-2INT }T

; ----------------------------------------------------------------------------
TESTING M+ M*/

T{ HI-2INT   1 M+ -> HI-2INT   1. D+ }T
T{ MAX-2INT -1 M+ -> MAX-2INT -1. D+ }T
T{ MIN-2INT  1 M+ -> MIN-2INT  1. D+ }T
T{ LO-2INT  -1 M+ -> LO-2INT  -1. D+ }T

; To correct the result if the division is floored, only used when
; necessary i.e. negative quotient and remainder <> 0

: ?FLOORED [ -3 2 / -2 = ] LITERAL IF 1. D- THEN ;

T{  5.  7 11 M*/ ->  3. }T
T{  5. -7 11 M*/ -> -3. ?FLOORED }T    \ FLOORED -4.
T{ -5.  7 11 M*/ -> -3. ?FLOORED }T    \ FLOORED -4.
T{ -5. -7 11 M*/ ->  3. }T
T{ MAX-2INT  8 16 M*/ -> HI-2INT }T
T{ MAX-2INT -8 16 M*/ -> HI-2INT DNEGATE ?FLOORED }T  \ FLOORED SUBTRACT 1
T{ MIN-2INT  8 16 M*/ -> LO-2INT }T
T{ MIN-2INT -8 16 M*/ -> LO-2INT DNEGATE }T
T{ MAX-2INT MAX-INTD MAX-INTD M*/ -> MAX-2INT }T
T{ MAX-2INT MAX-INTD 2/ MAX-INTD M*/ -> MAX-INTD 1- HI-2INT NIP }T
T{ MIN-2INT LO-2INT NIP 1+ DUP 1- NEGATE M*/ -> 0 MAX-INTD 1- }T
T{ MIN-2INT LO-2INT NIP 1- MAX-INTD M*/ -> MIN-INTD 3 + HI-2INT NIP 2 + }T
T{ MAX-2INT LO-2INT NIP DUP NEGATE M*/ -> MAX-2INT DNEGATE }T
T{ MIN-2INT MAX-INTD DUP M*/ -> MIN-2INT }T

; ----------------------------------------------------------------------------
TESTING D. D.R

; Create some large double numbers
MAX-2INT 71 73 M*/ 2CONSTANT DBL1
MIN-2INT 73 79 M*/ 2CONSTANT DBL2

: D>ASCII  ( D -- CADDR U )
   DUP >R <# DABS #S R> SIGN #>    ( -- CADDR1 U )
   HERE SWAP 2DUP 2>R CHARS DUP ALLOT MOVE 2R>
;

DBL1 D>ASCII 2CONSTANT "DBL1"
DBL2 D>ASCII 2CONSTANT "DBL2"

: DOUBLEOUTPUT
   CR ." You should see lines duplicated:" CR
   5 SPACES "DBL1" TYPE CR
   5 SPACES DBL1 D. CR
   8 SPACES "DBL1" DUP >R TYPE CR
   5 SPACES DBL1 R> 3 + D.R CR
   5 SPACES "DBL2" TYPE CR
   5 SPACES DBL2 D. CR
   10 SPACES "DBL2" DUP >R TYPE CR
   5 SPACES DBL2 R> 5 + D.R CR
;

T{ DOUBLEOUTPUT -> }T
; ----------------------------------------------------------------------------
TESTING 2ROT DU< (Double Number extension words)

T{ 1. 2. 3. 2ROT -> 2. 3. 1. }T
T{ MAX-2INT MIN-2INT 1. 2ROT -> MIN-2INT 1. MAX-2INT }T

T{  1.  1. DU< -> FALSE }T
T{  1. -1. DU< -> TRUE  }T
T{ -1.  1. DU< -> FALSE }T
T{ -1. -2. DU< -> FALSE }T
T{ 0 1   1. DU< -> FALSE }T
T{ 1.  0 1  DU< -> TRUE  }T
T{ 0 -1 1 -2 DU< -> FALSE }T
T{ 1 -2 0 -1 DU< -> TRUE  }T

T{ MAX-2INT HI-2INT  DU< -> FALSE }T
T{ HI-2INT  MAX-2INT DU< -> TRUE  }T
T{ MAX-2INT MIN-2INT DU< -> TRUE }T
T{ MIN-2INT MAX-2INT DU< -> FALSE }T
T{ MIN-2INT LO-2INT  DU< -> TRUE }T

; ----------------------------------------------------------------------------
TESTING 2VALUE

T{ 1111 2222 2VALUE 2VAL -> }T
T{ 2VAL -> 1111 2222 }T
T{ 3333 4444 TO 2VAL -> }T
T{ 2VAL -> 3333 4444 }T
T{ : TO-2VAL TO 2VAL ; 5555 6666 TO-2VAL -> }T
T{ 2VAL -> 5555 6666 }T

CR .( End of Double-Number word tests) CR
