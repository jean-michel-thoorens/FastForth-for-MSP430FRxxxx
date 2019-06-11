\ -*- coding: utf-8 -*-

; ------------
; CHNGBAUD.f
; ------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: nothing
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\

PWR_STATE

[UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT 
: CONSTANT 
DEFER
HI2LO
MOV @RSP+,IP
MOV #DOCON,-4(W)        \   CFA = DOCON
MOV TOS,-2(W)           \   PFA = n
MOV @PSP+,TOS
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

[UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
CODE UM/MOD
    PUSH #DROP      \
    MOV #<#,X       \ X = addr of <#
    ADD #8,X        \ X = addr of MUSMOD
    MOV X,PC        \ execute MUSMOD then RET to DROP
ENDCODE
[THEN]

: MCLK.
0 1000 UM/MOD .
;

: ESC #27 EMIT ;

: BAD_MHz
    1 ABORT"  only for 1,4,8,16,24 MHz MCLK!"
;

: BAD_SPEED
SPACE ESC ." [7m"   \ set reverse video
." with MCLK = " MCLK. 1 ABORT" MHz? don't dream!"
;

: <> = 0= ;

: CHNGBAUD                  \ only for 8, 16, 24 MHz
PWR_STATE                   \ to remove this created word (garbage collector)

42              \ number of terminal lines   
0 DO CR LOOP    \ don't erase any line of source

ESC ." [1J"     \ erase up (42 empty lines)
ESC ." [H"      \ cursor home

FREQ_KHZ @ >R               \ r-- target MCLCK frequency in MHz
." target MCLK = " R@ MCLK. ." MHz" CR
." choose your baudrate:" CR
." 0 --> 6 MBds" CR
." 1 --> 5 MBds" CR
." 2 --> 4 MBds" CR      \ linux driver max speed
." 3 --> 2457600 Bds" CR
." 4 --> 921600 Bds" CR
." 5 --> 460800 Bds" CR
." 6 --> 230400 Bds" CR
." 7 --> 115200 Bds" CR
." other --> abort" CR
." your choice: "
KEY

#48 - ?DUP 0=               \ select 6MBds ?
IF  ." 6 MBds"              \ add this to the current line
    R@ #24000 <              \ < 24MHz ?
    IF  R@ BAD_SPEED
    THEN
    R@ #24000 <>             \ 24 MHz ?
    IF  BAD_MHz             \ no: --> abort
    THEN                
    $4                      \ TERM_BRW
    $0                      \ TERM_MCTLW
ELSE 1 - ?DUP 0=            \ select 5MBds ?
    IF  ." 5 MBds"
        R@ #16000 <         \ < 16MHz ?
        IF  R@ BAD_SPEED    \ abort
        THEN
        R@ #16000 =
        IF  $3              \ TERM_BRW
            $2100           \ TERM_MCTLW
        ELSE R@ #24000 <>
            IF  BAD_MHz
            THEN
            $4              \ TERM_BRW
            $EE00           \ TERM_MCTLW
        THEN
    ELSE 1 - ?DUP 0=            \ select 4MBds ?
        IF  ." 4 MBds"
            R@ #16000 <
            IF  R@ BAD_SPEED    \ abort
            THEN
            R@ #16000 =
                IF  $4          \ TERM_BRW
                    $0          \ TERM_MCTLW
                ELSE R@ #24000 <>
                    IF  BAD_MHz
                    THEN
                    $6          \ TERM_BRW
                    $0          \ TERM_MCTLW
                THEN
        ELSE 1 - ?DUP 0=            \ select 2457600 ?
            IF  ." 2457600 Bds"
                R@ #8000 <           \ < 8MHz ?
                IF  R@ BAD_SPEED    \ abort
                THEN
                R@ #8000 =
                IF  $3              \ TERM_BRW
                    $4400           \ TERM_MCTLW
                ELSE R@ #16000 =
                    IF  $6          \ TERM_BRW
                        $AA00       \ TERM_MCTLW
                    ELSE R@ #24000 <>
                        IF  BAD_MHz
                        THEN
                        $9          \ TERM_BRW
                        $DD00       \ TERM_MCTLW
                    THEN
                THEN
            ELSE 1 - ?DUP 0=                \ select 921600 ?
                IF  ." 921600 Bds"
                    R@ #4000 <
                    IF  R@ BAD_SPEED        \ abort 
                    THEN
                    R@ #4000 =              \ 4MHz ?
                    IF  4                   \ TERM_BRW
                        $4900               \ TERM_MCTLW
                    ELSE
                        R@ #8000 =
                        IF  8               \ TERM_BRW
                            $D600           \ TERM_MCTLW
                        ELSE R@ #16000 =
                            IF  $11         \ TERM_BRW
                                $4A00       \ TERM_MCTLW
                            ELSE R@ #24000 <>
                                IF  BAD_MHz
                                THEN
                                $1          \ TERM_BRW
                                $00A1       \ TERM_MCTLW
                            THEN
                        THEN
                    THEN
                ELSE 1 - ?DUP 0=                \ select 230400 ?
                    IF  ." 460800 Bds"
                        R@ #4000 <
                        IF  R@ BAD_SPEED        \ abort 
                        THEN
                        R@ #4000  =
                        IF  8                  \ TERM_BRW
                            $D600               \ TERM_MCTLW
                        ELSE
                            R@ #8000  =
                            IF  17               \ TERM_BRW
                                $4A00           \ TERM_MCTLW
                            ELSE R@ #16000 =
                                IF  2           \ TERM_BRW
                                    $BB21       \ TERM_MCTLW
                                ELSE R@ #24000 <>
                                    IF  BAD_MHz
                                    THEN
                                    6           \ TERM_BRW
                                    $0001       \ TERM_MCTLW
                                THEN
                            THEN
                        THEN
                    ELSE 1 - ?DUP 0=                \ select 230400 ?
                        IF  ." 230400 Bds"
                            R@ #1000 <
                            IF  R@ BAD_SPEED        \ abort 
                            THEN
                            R@ #1000 =
                            IF  4
                                $4900
                            ELSE
                                R@ #4000  =
                                IF  17                  \ TERM_BRW
                                    $4A00               \ TERM_MCTLW
                                ELSE
                                    R@ #8000  =
                                    IF  2               \ TERM_BRW
                                        $BB21           \ TERM_MCTLW
                                    ELSE R@ #16000 =
                                        IF  4           \ TERM_BRW
                                            $5551       \ TERM_MCTLW
                                        ELSE R@ #24000 <>
                                            IF  BAD_MHz
                                            THEN
                                            3           \ TERM_BRW
                                            $0241       \ TERM_MCTLW
                                        THEN
                                    THEN
                                THEN
                            THEN
                        ELSE 1 - ?DUP 0=                \ select 115200 ?
                            IF  ." 115200 Bds"
                                R@ #1000  =
                                IF  8
                                    $D600
                                ELSE
                                    R@ #4000  =
                                    IF  2                   \ TERM_BRW
                                        $BB21               \ TERM_MCTLW
                                    ELSE
                                        R@ #8000  =
                                        IF  4               \ TERM_BRW
                                            $5551           \ TERM_MCTLW
                                        ELSE R@ #16000 =
                                            IF  8           \ TERM_BRW
                                                $F7A1       \ TERM_MCTLW
                                            ELSE R@ #24000 <>
                                                IF  BAD_MHz
                                                THEN
                                                $0D         \ TERM_BRW
                                                $4901       \ TERM_MCTLW
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
TERMMCTLW_RST !             \ set UCAxMCTLW value in FRAM
TERMBRW_RST !               \ set UCAxBRW value in FRAM
R> DROP                     \ clear stacks
CR ESC ." [7m"              \ escape sequence to set reverse video
." Change baudrate in Teraterm, save its setup then reset target."
;

ECHO CHNGBAUD 
