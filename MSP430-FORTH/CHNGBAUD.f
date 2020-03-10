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

[UNDEFINED] DUP [IF]    \ define DUP and DUP?
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

[UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
CODE DROP
MOV @PSP+,TOS   \ 2
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

[UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
CODE 1+
ADD #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] U/ [IF]
\ U/   u1 u2 -- q   unsigned 16/16->q16
CODE U/
SUB #2,PSP
MOV #0,0(PSP)   \ -- u1lo u1hi u2
CALL #MUSMOD    \ -- r qlo qhi
MOV @PSP,TOS    \ -- r qlo qlo
ADD #4,PSP      \ -- qlo
MOV @IP+,PC
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

[UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
CODE =
SUB @PSP+,TOS   \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1 flag Z = 1
ELSE            \ 2
    XOR #-1,TOS \ 1
THEN
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] < [IF]  \ define < and >
\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
CODE <
    SUB @PSP+,TOS   \ 1 TOS=n2-n1
    S< ?GOTO FW1    \ 2 signed
    0<> IF          \ 2
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

[UNDEFINED] IF [IF]
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
CODE IF
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
CODE THEN
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
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
GOTO BW1
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] CASE [IF]
\ https://forth-standard.org/standard/core/CASE
: CASE 0 ; IMMEDIATE \ -- #of-1 

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

[UNDEFINED] S_ [IF]
CODE S_             \           Squote alias with blank separator instead quote
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

[UNDEFINED] ESC [IF]
CODE ESC
CMP #0,&STATEADR
0= IF MOV @IP+,PC   \ interpret time use is disallowed
THEN
COLON          
$1B                 \ -- char escape
POSTPONE LITERAL    \ compile-time code : lit $1B  
POSTPONE EMIT       \ compile-time code : EMIT
POSTPONE S_         \ compile-time code : S_ <escape_sequence>
POSTPONE TYPE       \ compile-time code : TYPE
; IMMEDIATE
[THEN]

: BAD_MHz
$20 DUP EMIT 
        ABORT" only for 1,4,8,16,24 MHz MCLK!"
;

: OVR_BAUDS
$20 DUP EMIT ESC [7m    \ set reverse video
        ." with MCLK = " FREQ_KHZ @ 1000 U/ .
        ABORT" MHz? don't dream!"
;

: CHNGBAUD                  \ only for 1, 4, 8, 16, 24 MHz
PWR_STATE                   \ removes this created word (garbage collector)
ECHO
42 0 DO CR LOOP    \ don't erase any line of source
ESC [H          \ cursor home

FREQ_KHZ @ DUP >R               \ r-- target MCLCK frequency in MHz
." target MCLK = " 1000 U/ . ." MHz" CR
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

CASE
#48 OF  ." 6 MBds"          \ add this to the current line
        R> CASE
            #24000 OF $4 $0 \ -- TERM_BRW  TERM_MCTLW
                   ENDOF
            24000 <   
            IF OVR_BAUDS    \ < 24 MHz --> abort
            THEN BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#49 OF  ." 5 MBds"
        R> CASE
            #24000 OF $4 $EE00  ENDOF
            #16000 OF $3 $2100  ENDOF
            16000 <   
            IF OVR_BAUDS    \ < 16 MHz --> abort
            THEN BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#50 OF  ." 4 MBds"
        R> CASE
            #24000 OF $6 $0     ENDOF
            #16000 OF $4 $0     ENDOF
            16000 <   
            IF OVR_BAUDS    \ < 16 MHz --> abort
            THEN BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#51 OF  ." 2457600 Bds"
        R> CASE
            #24000  OF $9 $DD00 ENDOF
            #16000  OF $6 $AA00 ENDOF
            #8000   OF $3 $4400 ENDOF
            8000 <   
            IF OVR_BAUDS    \ < 8 MHz --> abort
            THEN BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#52 OF  ." 921600 Bds"
        R> CASE
            #24000  OF $1 $00A1     ENDOF
            #16000  OF $11 $4A00    ENDOF
            #8000   OF $8 $D600     ENDOF
            #4000   OF $4 $4900     ENDOF
            4000 <   
            IF OVR_BAUDS    \ < 4 MHz --> abort
            THEN BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#53 OF  ." 460800 Bds"
        R> CASE
            #24000  OF $6 $0001     ENDOF
            #16000  OF $2 $BB21     ENDOF
            #8000   OF $11 $4A00    ENDOF
            #4000   OF $8 $D600     ENDOF
            4000 <   
            IF OVR_BAUDS    \ < 4 MHz --> abort
            THEN BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#54 OF  ." 230400 Bds"
        R> CASE
            #24000  OF $3 $0241     ENDOF
            #16000  OF $4 $5551     ENDOF
            #8000   OF $2 $BB21     ENDOF
            #4000   OF $11 $4A00    ENDOF
            #1000   OF $4 $4900     ENDOF
            BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#55 OF  ." 115200 Bds"
        R> CASE
            #24000  OF $0D $4901    ENDOF
            #16000  OF $8 $F7A1     ENDOF
            #8000   OF $4 $5551     ENDOF
            #4000   OF $2 $BB21     ENDOF
            #1000   OF $8 $D600     ENDOF
            BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#56 OF  ." 38400 Bds"
        R> CASE
            #24000  OF $27 $0011    ENDOF
            #16000  OF $1A $D601    ENDOF
            #8000   OF $0D $4901    ENDOF
            #4000   OF $6 $2081     ENDOF
            #1000   OF $1 $00A1     ENDOF
            BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#57 OF  ." 19200 Bds"
        R> CASE
            #24000  OF $4E $0021    ENDOF
            #16000  OF $34 $4911    ENDOF
            #8000   OF $1A $D601    ENDOF
            #4000   OF $0D $4901    ENDOF
            #1000   OF $3 $0241     ENDOF
            BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
#65 OF  ." 9600 Bds"
        R> CASE
            #24000  OF $9C $0041    ENDOF
            #16000  OF $68 $D621    ENDOF
            #8000   OF $34 $4911    ENDOF
            #4000   OF $1A $D601    ENDOF
            #1000   OF $6 $2081     ENDOF
            BAD_MHz    \ other MHz --> abort
        ENDCASE
    ENDOF
    ." abort" CR ABORT
ENDCASE
TERMMCTLW_RST !             \ set UCAxMCTLW value in FRAM
TERMBRW_RST !               \ set UCAxBRW value in FRAM
CR ESC [7m                  \ escape sequence to set reverse video
." Change baudrate in Teraterm, save its setup, then reset target."
;

CHNGBAUD 
