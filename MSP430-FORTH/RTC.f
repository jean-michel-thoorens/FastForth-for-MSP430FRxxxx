\ -*- coding: utf-8 -*-

; --------------------
; RTC.f
; --------------------
\
\ ==============================================================================
\ routines RTC for MSP430fr5xxx and MSP430FR6xxx families only
\ your target must have a LF_XTAL 32768Hz
\ if no present, add a LF_XTAL line for your target in ThingsInFirst.inc.
\ ==============================================================================
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
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
\
\ use :
\ to set date, type : d m y DATE!
\ to view date, type DATE?
\ to set time, type : h m s TIME!, or h m TIME!
\ to view time, type TIME?
\
\ allow to write a file on a SD_Card with a valid date and a valid time
\

PWR_STATE

[UNDEFINED] {RTC} [IF]

MARKER {RTC}

[UNDEFINED] MAX [IF]

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

[THEN]  \ MAX

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

[UNDEFINED] U.R [IF]
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]  \ U.R

CODE DATE?
    SUB     #6,PSP
    MOV     TOS,4(PSP)
    BEGIN
        BIT.B #RTCRDY,&RTCCTL1  \ test RTCRDY flag
    0<> UNTIL                   \ wait until RTCRDY high
    MOV     &RTCYEARL,2(PSP)    \ year
    MOV.B   &RTCMON,TOS
    MOV     TOS,0(PSP)          \ month
    MOV.B   &RTCDAY,TOS         \ day
COLON
    2 U.R $2F EMIT
    2 U.R $2F EMIT . 
;

: DATE!
2 DEPTH U< IF
    HI2LO
    MOV     TOS,&RTCYEARL   \ year
    MOV.B   @PSP,&RTCMON    \ month     \ @PSP+ don't work because byte format !
    MOV.B   2(PSP),&RTCDAY  \ day       \ @PSP+ don't work because byte format !
    ADD     #4,PSP
    MOV     @PSP+,TOS       \
    LO2HI
THEN
    ." we are on " DATE? 
;

CODE TIME?
    SUB     #6,PSP
    MOV     TOS,4(PSP)      \ save TOS
    BEGIN
        BIT.B #RTCRDY,&RTCCTL1 \
    0<> UNTIL               \ wait until RTCRDY high
    MOV.B   &RTCSEC,TOS
    MOV     TOS,2(PSP)      \ seconds
    MOV.B   &RTCMIN,TOS
    MOV     TOS,0(PSP)      \ minutes
    MOV.B   &RTCHOUR,TOS    \ hours
COLON
    2 U.R $3A EMIT 
    2 U.R $3A EMIT 2 U.R 
;

: TIME!
2 DEPTH U< IF
    HI2LO
    MOV     TOS,&RTCSEC     \ seconds
    MOV.B   @PSP,&RTCMIN    \ minutes   \ @PSP+ don't work because byte format !
    MOV.B   2(PSP),&RTCHOUR \ hours     \ @PSP+ don't work because byte format !
    ADD     #4,PSP
    MOV     @PSP+,TOS       \
    LO2HI
THEN
    ." it is " TIME? 
;

RST_HERE

[THEN]

: ESC #27 EMIT ;

\ create a word to test DEFERred words
: [ISDEFERRED?]    \ [ISDEFERRED?] xt -- xt flag
    DUP @ $4030 = \ CFA of <name> = MOV @PC+,PC ? 
; IMMEDIATE

CREATE ABUF 20 ALLOT

: GET_TIME
PWR_STATE       \ all after PWR_HERE marker will be lost
42              \ number of terminal lines   
0 DO CR LOOP    \ don't erase any line of source

ESC ." [1J"     \ erase up (42 empty lines)
ESC ." [H"      \ cursor home

CR ." DATE (DMY): "
ABUF DUP 20 
    ['] ACCEPT [ISDEFERRED?] 
    [IF] >BODY   \   execute default part of ACCEPT
    [THEN] EXECUTE
EVALUATE CR DATE!
CR CR ." TIME (HMS): "
ABUF DUP 20 
    ['] ACCEPT [ISDEFERRED?] 
    [IF] >BODY   \   execute default part of ACCEPT
    [THEN] EXECUTE
EVALUATE CR TIME!
CR
;

ECHO GET_TIME
