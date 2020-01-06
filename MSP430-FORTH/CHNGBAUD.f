\ -*- coding: utf-8 -*-

; ------------
; CHNGBAUD.f
; ------------

\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: nothing
\
\ TARGET SELECTION : copy your target in (shift+F8) parameter 1: 
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\ LP_MSP430FR2476
\
\
PWR_STATE

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

[UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
CODE =
SUB @PSP+,TOS   \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1
ELSE            \ 2
    XOR #-1,TOS \ 1 flag Z = 1
THEN
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

[UNDEFINED] IF [IF]
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

[UNDEFINED] BEGIN [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT
\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
CODE BEGIN
    MOV #HEREADR,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/UNTIL
\ UNTIL    BEGINadr --             resolve conditional backward branch
CODE UNTIL              \ immediate
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
CODE AGAIN     \ immediate
MOV #BRAN,X
GOTO BW1
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/WHILE
\ WHILE    BEGINadr -- WHILEadr BEGINadr
: WHILE     \ immediate
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
CODE +LOOP              \ immediate
MOV #XPLOOP,X
GOTO BW1
ENDCODE IMMEDIATE
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

[UNDEFINED] R@ [IF]
\ https://forth-standard.org/standard/core/RFetch
\ R@    -- x     R: x -- x   fetch from return stack
CODE R@
SUB #2,PSP
MOV TOS,0(PSP)
MOV @RSP,TOS
MOV @IP+,PC
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

[UNDEFINED] ?DUP [IF]
\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
CODE ?DUP
CMP #0,TOS      \ 2  test for TOS nonzero
0<> IF
    SUB #2,PSP      \ 2  push old TOS..
    MOV TOS,0(PSP)  \ 3  ..onto stack
THEN
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] @ [IF]
\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- char   fetch char from memory
CODE @
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] ! [IF]
\ https://forth-standard.org/standard/core/Store
\ !        x a-addr --   store cell in memory
CODE !
MOV @PSP+,0(TOS)    \ 4
MOV @PSP+,TOS       \ 2
MOV @IP+,PC         \ 4
ENDCODE
[THEN]

[UNDEFINED] < [IF]
\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
CODE <
    SUB @PSP+,TOS   \ 1 TOS=n2-n1
    S< ?GOTO FW1    \ 2 signed
    0<> IF          \
BW1     MOV #-1,TOS \ 1 flag Z = 0
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

[UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
CODE UM/MOD
    PUSH #DROP      \
    MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
ENDCODE
[THEN]

[UNDEFINED] ESC" [IF]
\ ESC" <escape sequence>" --    type an escape sequence
: ESC" $1B POSTPONE LITERAL POSTPONE EMIT POSTPONE S" POSTPONE TYPE ; IMMEDIATE \ "
[THEN]

: BAD_MHz
$20 EMIT 1 ABORT" only for 1,4,8,16,24 MHz MCLK!"
;

: OVR_BAUDS
$20 EMIT ESC" [7m"   \ set reverse video
." with MCLK = " FREQ_KHZ @ 0 1000 UM/MOD . DROP
1 ABORT" MHz? don't dream!"
;

: <> = 0= ;

: CHNGBAUD                  \ only for 8, 16, 24 MHz
PWR_STATE                   \ to remove this created word (garbage collector)
ECHO
42              \ number of terminal lines   
0 DO CR LOOP    \ don't erase any line of source

ESC" [1J"     \ erase up (42 empty lines)
ESC" [H"      \ cursor home

FREQ_KHZ @ >R               \ r-- target MCLCK frequency in MHz
." target MCLK = " R@ 0 1000 UM/MOD . ." MHz" DROP CR
." choose your baudrate:" CR
."  0 --> 6 MBds" CR
."  1 --> 5 MBds" CR
."  2 --> 4 MBds" CR      \ linux driver max speed
."  3 --> 2457600 Bds" CR
."  4 --> 921600 Bds" CR
."  5 --> 460800 Bds" CR
."  6 --> 230400 Bds" CR
."  7 --> 115200 Bds" CR
."  8 --> 38400 Bds" CR
."  9 --> 19200 Bds" CR
."  A --> 9600 Bds" CR
." other --> abort" CR
." your choice: "
KEY

#48 - ?DUP 0=               \ select 6MBds ?
IF  ." 6 MBds"              \ add this to the current line
    R@ #24000 <             \ < 24MHz ?
    IF  OVR_BAUDS THEN
    R@ #24000 <>            \ > 24 MHz ?
    IF  BAD_MHz  THEN       \ yes --> abort
    $4                      \ TERM_BRW
    $0                      \ TERM_MCTLW
ELSE 1 - ?DUP 0=            \ select 5MBds ?
    IF  ." 5 MBds"
        R@ #16000 <         \ < 16MHz ?
        IF  OVR_BAUDS THEN
        R@ #16000 =         \ 16 MHz ?
        IF  $3              \ TERM_BRW
            $2100           \ TERM_MCTLW
        ELSE R@ #24000 <>
            IF  BAD_MHz  THEN
            $4              \ TERM_BRW
            $EE00           \ TERM_MCTLW
        THEN
    ELSE 1 - ?DUP 0=        \ 4MBds ?
        IF  ." 4 MBds"
            R@ #16000 <
            IF  OVR_BAUDS THEN
            R@ #16000 =
                IF  $4 $0
                ELSE R@ #24000 <>
                    IF  BAD_MHz  THEN
                    $6 $0
                THEN
        ELSE 1 - ?DUP 0=            \ 2457600 ?
            IF  ." 2457600 Bds"
                R@ #8000 <           \ < 8MHz ?
                IF  OVR_BAUDS THEN
                R@ #8000 =
                IF  $3 $4400
                ELSE R@ #16000 =
                    IF  $6 $AA00
                    ELSE R@ #24000 <>
                        IF  BAD_MHz  THEN
                        $9 $DD00
                    THEN
                THEN
            ELSE 1 - ?DUP 0=                \ 921600 ?
                IF  ." 921600 Bds"
                    R@ #4000 <              \ < 4MHz ?
                    IF  OVR_BAUDS THEN
                    R@ #4000 =
                    IF  4 $4900
                    ELSE R@ #8000 =
                        IF  8 $D600
                        ELSE R@ #16000 =
                            IF  $11 $4A00
                            ELSE R@ #24000 <>
                                IF  BAD_MHz  THEN
                                $1 $00A1
                            THEN
                        THEN
                    THEN
                ELSE 1 - ?DUP 0=                \ 460800 ?
                    IF  ." 460800 Bds"
                        R@ #4000 <
                        IF  OVR_BAUDS THEN
                        R@ #4000  =
                        IF  8 $D600
                        ELSE R@ #8000  =
                            IF $11 $4A00
                            ELSE R@ #16000 =
                                IF $2 $BB21
                                ELSE R@ #24000 <>
                                    IF  BAD_MHz  THEN
                                    $6 $0001
                                THEN
                            THEN
                        THEN
                    ELSE 1 - ?DUP 0=                \ 230400 ?
                        IF  ." 230400 Bds"
                            R@ #1000 <
                            IF  OVR_BAUDS THEN
                            R@ #1000 =
                            IF  4 $4900
                            ELSE R@ #4000  =
                                IF $11 $4A00
                                ELSE R@ #8000  =
                                    IF  2 $BB21
                                    ELSE R@ #16000 =
                                        IF  4 $5551
                                        ELSE R@ #24000 <>
                                            IF  BAD_MHz  THEN
                                            3 $0241
                                        THEN
                                    THEN
                                THEN
                            THEN
                        ELSE 1 - ?DUP 0=                \ 115200 ?
                            IF  ." 115200 Bds"
                                R@ #1000  =
                                IF  8 $D600
                                ELSE R@ #4000  =
                                    IF  2 $BB21
                                    ELSE R@ #8000  =
                                        IF  4 $5551
                                        ELSE R@ #16000 =
                                            IF  8 $F7A1
                                            ELSE R@ #24000 <>
                                                IF  BAD_MHz  THEN
                                                $0D $4901
                                            THEN
                                        THEN
                                    THEN
                                THEN
                            ELSE 1 - ?DUP 0=                \ 38400 ?
                                IF  ." 38400 Bds"
                                    R@ #1000  =
                                    IF  $1  $00A1
                                    ELSE R@ #4000  =
                                        IF  $6  $2081
                                        ELSE R@ #8000  =
                                            IF  $0D $4901
                                            ELSE R@ #16000 =
                                                IF  $1A $D601
                                                ELSE R@ #24000 <>
                                                    IF  BAD_MHz  THEN
                                                    $27 $0011
                                                THEN
                                            THEN
                                        THEN
                                    THEN
                                ELSE 1 - ?DUP 0=                \ 19200 ?
                                    IF  ." 19200 Bds"
                                        R@ #1000  =
                                        IF  $3  $0241
                                        ELSE R@ #4000  =
                                            IF  $0D $4901
                                            ELSE R@ #8000  =
                                                IF  $1A $D601
                                                ELSE R@ #16000 =
                                                    IF  $34 $4911
                                                    ELSE R@ #24000 <>
                                                        IF  BAD_MHz  THEN
                                                        $4E $0021
                                                    THEN
                                                THEN
                                            THEN
                                        THEN
                                    ELSE 8 - ?DUP 0=                \ 9600 ?
                                        IF  ." 9600 Bds"
                                            R@ #1000  =
                                            IF  $6  $2081
                                            ELSE R@ #4000  =
                                                IF  $1A $D601
                                                ELSE R@ #8000  =
                                                    IF  $34 $4911
                                                    ELSE R@ #16000 =
                                                        IF  $68 $D621
                                                        ELSE R@ #24000 <>
                                                            IF  BAD_MHz  THEN
                                                            $9C $0041
                                                        THEN
                                                    THEN
                                                THEN
                                            THEN
                                        ELSE                    \ other selected 
                                            ." abort" CR ABORT
                                        THEN
                                    THEN
                                THEN
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
THEN
TERMMCTLW_RST !             \ set UCAxMCTLW value in FRAM
TERMBRW_RST !               \ set UCAxBRW value in FRAM
R> DROP                     \ clear stacks
CR ESC" [7m"                \ escape sequence to set reverse video
." Change baudrate in Teraterm, save its setup, then reset target."
;

CHNGBAUD 
