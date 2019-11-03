\ -*- coding: utf-8 -*-

; ------------
; CHNGBAUD.f
; ------------

\ FastForth kernel options: ASSEMBLER, COND_COMP
\ to see kernel options, download FF_SPECS.f
\
\ TARGET SELECTION : copy your target in (shift+F8) parameter 1: 
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\ LP_MSP430FR2476
\
PWR_STATE

[UNDEFINED] EXIT [IF]
\ https://forth-standard.org/standard/core/EXIT
\ EXIT     --      exit a colon definition
CODE EXIT
MOV @RSP+,IP    \ 2 pop previous IP (or next PC) from return stack
MOV @IP+,PC     \ 4 = NEXT
ENDCODE
[THEN]

[UNDEFINED] EXECUTE [IF] \ "
\ https://forth-standard.org/standard/core/EXECUTE
\ EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
CODE EXECUTE
MOV TOS,W               \ 1 put word address into W
MOV @PSP+,TOS           \ 2 fetch new TOS
MOV W,PC                \ 3 fetch code address into PC
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

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3
CODE +
ADD @PSP+,TOS
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
[THEN]

[UNDEFINED] DO [IF]
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
[THEN]

[UNDEFINED] LOOP [IF]
\ https://forth-standard.org/standard/core/LOOP
\ LOOP    DOadr --         L-- an an-1 .. a1 0
CODE LOOP               \ immediate
    ADD #4,&DP          \ make room to compile two words
    MOV &DP,W
    MOV #XLOOP,-4(W)    \ xloop --> HERE
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
[THEN]

[UNDEFINED] ESC" [IF]
\ ESC" <escape sequence>" --    type an escape sequence
: ESC" $1B POSTPONE LITERAL POSTPONE EMIT POSTPONE S" POSTPONE TYPE ; IMMEDIATE \ "
[THEN]

\ : OVER= OVER = ;      \ replace 'n1 DUP n2 =' by 'n1 n2 OVER='
CODE OVER=      \ n1 n2 -- n1 flag
SUB @PSP,TOS    \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1
ELSE            \ 2
    XOR #-1,TOS \ 1 flag Z = 1
THEN
MOV @IP+,PC     \ 4
ENDCODE

\ : OVRSWP<         \ n1 n2 -- n1 flag      flag = -1 if n1 < n2
\   OVER SWAP < ; 
CODE OVRSWP<        \ n1 n2 -- n1 flag      flag = -1 if n1 < n2
SUB @PSP,TOS        \ -- n1 n  TOS=n2-n1
S>= IF              \               if n2-n1 >= 0
    0<> IF          \               if n2-n1 <> 0
        MOV #-1,TOS \ -- n1 -1      flag Z = 0
    THEN
    MOV @IP+,PC 
THEN
AND #0,TOS          \ -- n1 0       flag Z = 1
MOV @IP+,PC
ENDCODE

\ ;THEN                 \ EXIT condition ended by THEN
\   POSTPONE EXIT POSTPONE THEN
\ ; IMMEDIATE 
CODE ;THEN              \ IFadr --        
ADD #2,&DP              \
MOV &DP,X
MOV #EXIT,-2(X)         \               compile EXIT
MOV X,0(TOS)            \ -- IFadr      compile current DP at IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

\ UM/   udlo|udhi u1 -- q   unsigned 32/16->q16
CODE UM/
CALL #MUSMOD    \ -- r Qlo Qhi
MOV @PSP,TOS    \ -- r Qlo Qlo
ADD #4,PSP      \ -- Qlo
MOV @IP+,PC
ENDCODE

: BAD_MHz           \ abort
$20 EMIT 1 ABORT" only for 1,4,8,16,24 MHz MCLK!"
;

: OVR_BAUDS         \ abort
$20 EMIT ESC" [7m"  \ set reverse video
FREQ_KHZ @ 0 1000 UM/ ." with MCLK = " .
1 ABORT" MHz? don't dream!"
;

\ conditionnal EXIT structure
: SELECT_BAUDS      \ -- char frequency TERM_BRW TERM_MCTLW
KEY                 \ -- char

48 OVER=                \ -- char flag     choice 0 = 6MBds ?
IF  ." 6 MBds"
    FREQ_KHZ @          \ -- char flag freq
    #24000 OVRSWP<      \ MCLK < 24MHz ?
    IF OVR_BAUDS ;THEN  \   ==> abort   ( ;THEN does nothing but solve paired IF during compilation)      
    #24000 OVER=        \ FREQ = 24 MHz ?
    IF $4  $0    ;THEN  \ --  char frequency TERM_BRW TERM_MCTLW
    BAD_MHz             \   ==> abort for other freq                
;THEN               \ ;THEN does nothing but solve paired IF during compilation

49 OVER=            \ -- char flag     choice 1 = 5MBds ?
IF  ." 5 MBds"
    FREQ_KHZ @
    #16000 OVRSWP<  \ MCLK < 16MHz ?    ==> abort
    IF OVR_BAUDS ;THEN
    #16000 OVER=
    IF $3  $2100 ;THEN
    #24000 OVER=
    IF $4  $EE00 ;THEN
    BAD_MHz         \ other freq    ==> abort
;THEN
50 OVER=            \ -- char flag     choice 2 = 4MBds ?
IF  ." 4 MBds"
    FREQ_KHZ @
    #16000 OVRSWP<  \ MCLK < 16MHz ?    ==> abort
    IF OVR_BAUDS ;THEN
    #16000 OVER=
    IF $4  $0    ;THEN
    #24000 OVER=
    IF $6  $0    ;THEN
    BAD_MHz         \ other freq    ==> abort             
;THEN
51 OVER=            \ -- char flag     choice 3 = 2457600 ?
IF  ." 2457600 Bds"
    FREQ_KHZ @
    #8000 OVRSWP<   \ MCLK < 8MHz ?    ==> abort
    IF OVR_BAUDS ;THEN
    #8000 OVER=
    IF $3  $4400 ;THEN
    #16000 OVER=
    IF $6  $AA00 ;THEN
    #24000 OVER=
    IF $9  $DD00 ;THEN
    BAD_MHz
;THEN    
52 OVER=            \ -- char flag     choice 4 = 921600 ?
IF  ." 921600 Bds"
    FREQ_KHZ @
    #4000 OVRSWP<   \ MCLK < 4MHz ?    ==> abort
    IF OVR_BAUDS ;THEN
    #4000 OVER=
    IF $4  $4900 ;THEN
    #8000 OVER=
    IF $8  $D600 ;THEN
    #16000 OVER=
    IF $11 $4A00 ;THEN
    #24000 OVER=
    IF $1  $00A1 ;THEN
    BAD_MHz
;THEN
53 OVER=            \ -- char flag     choice 5 = 460800 ?
IF  ." 460800 Bds"
    FREQ_KHZ @
    #4000 OVRSWP<   \ MCLK < 4MHz ?    ==> abort
    IF OVR_BAUDS ;THEN
    #4000 OVER=
    IF $8  $D600 ;THEN
    #8000 OVER=
    IF $11 $4A00 ;THEN
    #16000 OVER=
    IF $2  $BB21 ;THEN
    #24000 OVER=
    IF $6  $0001 ;THEN
    BAD_MHz
;THEN    
54 OVER=            \ -- char flag     choice 6 = 230400 ?
IF  ." 230400 Bds"
    FREQ_KHZ @
    #1000 OVRSWP<   \ MCLK < 1MHz ?    ==> abort
    IF OVR_BAUDS ;THEN
    #1000 OVER=
    IF $4  $4900 ;THEN
    #4000 OVER=
    IF $11 $4A00 ;THEN
    #8000 OVER=
    IF $2  $BB21 ;THEN
    #16000 OVER=
    IF $4  $5551 ;THEN
    #24000 OVER=
    IF $3  $0241 ;THEN
    BAD_MHz
;THEN
55 OVER=            \ -- char flag     choice 7 = 115200 ?
IF  ." 115200 Bds"
    FREQ_KHZ @
    #1000 OVER=
    IF $8  $D600 ;THEN
    #4000 OVER=
    IF $2  $BB21 ;THEN
    #8000 OVER=
    IF $4  $5551 ;THEN
    #16000 OVER=
    IF $8  $F7A1 ;THEN
    #24000 OVER=
    IF $0D $4901 ;THEN
    BAD_MHz
;THEN
56 OVER=            \ -- char flag     choice 8 = 38400 Bds?
IF  ." 38400 Bds"
    FREQ_KHZ @
    #1000 OVER=
    IF $1  $00A1 ;THEN
    #4000 OVER=
    IF $6  $2081 ;THEN
    #8000 OVER=
    IF $0D $4901 ;THEN
    #16000 OVER=
    IF $1A $D601 ;THEN
    #24000 OVER=
    IF $27 $0011 ;THEN
    BAD_MHz
;THEN
57 OVER=            \ -- char flag     choice 9 = 19200 Bds?
IF  ." 19200 Bds"
    FREQ_KHZ @
    #1000 OVER=
    IF $3  $0241 ;THEN
    #4000 OVER=
    IF $0D $4901 ;THEN
    #8000 OVER=
    IF $1A $D601 ;THEN
    #16000 OVER=
    IF $34 $4911 ;THEN
    #24000 OVER=
    IF $4E $0021 ;THEN
    BAD_MHz
;THEN
65 OVER=            \ -- char flag     choice A = 9600 Bds?
IF  ." 9600 Bds"
    FREQ_KHZ @
    #1000 OVER=
    IF $6  $2081 ;THEN
    #4000 OVER=
    IF $1A $D601 ;THEN
    #8000 OVER=
    IF $34 $4911 ;THEN
    #16000 OVER=
    IF $68 $D621 ;THEN
    #24000 OVER=
    IF $9C $0041 ;THEN
    BAD_MHz
;THEN               \ -- char           other key
    ." abort" CR ABORT
;

\ CREATE ABUF 10 ALLOT
\ 
\ : TERM_LINES    \ --
\ ESC" [18t"      \           TERMINAL reports '[8;y;xt' with y lines, x columns
\ ABUF 10         \ -- adr len 
\ ACCEPT          \ -- len'
\ drop            \ --
\ ABUF 3 + 2           \ -- ABUF+3, len=2
\ EVALUATE        \ --
\ ;

\ TERM_LINES ABUF !

: CHNGBAUD              \ only for 1, 4, 8, 16, 24 MHz
PWR_STATE               \ to remove this created word (garbage collector)
ECHO
42 0 DO CR LOOP         \ don't erase any line of source, create 42 empty lines
\ TERM_LINES 0 DO CR LOOP \ don't erase any line of source, create y empty lines
ESC" [H"                \ then cursor home
CR
FREQ_KHZ @ 0 1000 UM/ 
." target MCLK = " . ." MHz" CR
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

SELECT_BAUDS    \ -- char frequency TERM_BRW TERM_MCTLW

TERMMCTLW_RST ! \ set UCAxMCTLW value in FRAM
TERMBRW_RST !   \ set UCAxBRW value in FRAM
DROP DROP       \ clear stack

CR ESC" [7m"    \ escape sequence to set reverse video
." Change baudrate in Teraterm, save its setup, then reset target."
;

CHNGBAUD
