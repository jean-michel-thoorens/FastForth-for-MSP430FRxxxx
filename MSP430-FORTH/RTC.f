\ -*- coding: utf-8 -*-
\
\ ==============================================================================
\ routines RTC for MSP430FRxxxx
\ your target must have a LF_XTAL 32768Hz
\ ==============================================================================
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel minimal addons: MSP430ASSEMBLER, CONDCOMP
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
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
BIT #BIT15,TOS
0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (FIXPOINT input), set TOS = 0  
MOV TOS,0(PSP)
MOV &VERSION,TOS
SUB #307,TOS            \ FastForth V3.7
COLON
$0D EMIT    \ return to column 1 without CR
ABORT" FastForth version = 3.7 please!"
ABORT" target without LF_XTAL !"
PWR_STATE           \ if no abort remove this word
;

ABORT_RTC

; --------------------
; RTC.f
; --------------------

\ use :
\ to set date, type : d m y DATE!
\ to view date, type DATE?
\ to set time, type : h m s TIME!, or h m TIME!
\ to view time, type TIME?
\
[DEFINED] {RTC} [IF] {RTC} [THEN] 

MARKER {RTC}    \ restore the state before MARKER definition
\      {RTC}+8 = BODY+4 = RET_ADR: MARKER_DOES does a call to RET_ADR by default
8 ALLOT \ make room for:
\      {RTC}+10 for content of previous RTC_VEC
\      {RTC}+12 for content of previous COLD_PFA
\      {RTC}+14 for content of previous WARM_PFA
\      {RTC}+16 for content of previous SLEEP_PFA


[UNDEFINED] OR [IF]
\ https://forth-standard.org/standard/core/OR
\ C OR     x1 x2 -- x3           logical OR
CODE OR
BIS @PSP+,TOS
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

[UNDEFINED] C! [IF]
\ https://forth-standard.org/standard/core/CStore
\ C!      char c-addr --    store char in memory
CODE C!
MOV.B @PSP+,0(TOS)  \ 4
ADD #1,PSP          \ 1
MOV @PSP+,TOS       \ 2
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

[UNDEFINED] DUP [IF]    \define DUP and DUP?
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

[UNDEFINED] >R [IF]
\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
CODE >R
PUSH TOS        \ 3
MOV @PSP+,TOS   \ 2
MOV @IP+,PC     \ 4
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

[UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
CODE 1+
ADD #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

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

[UNDEFINED] IF [IF]     \ define IF THEN
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

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3
CODE +
ADD @PSP+,TOS
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

[UNDEFINED] MAX [IF]    \define MAX and MIN

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

[UNDEFINED] 2* [IF]
\ https://forth-standard.org/standard/core/TwoTimes
\ 2*      x1 -- x2         arithmetic left shift
CODE 2*
ADD TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] UM* [IF]    
\ https://forth-standard.org/standard/core/UMTimes
\ UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
CODE UM*
    MOV @PSP,&MPY       \ Load 1st operand for unsigned multiplication
    MOV TOS,&OP2        \ Load 2nd operand
    MOV &RES0,0(PSP)    \ low result on stack
    MOV &RES1,TOS       \ high result in TOS
    MOV @IP+,PC
ENDCODE
[THEN] 

[UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- ur uq   unsigned 32/16->r16 q16
CODE UM/MOD
    PUSH #DROP      \
    MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
ENDCODE
[THEN]

[UNDEFINED] U*/ [IF]
\ U*/     u1 u2 u3 -- uq        u1*u2/u3
: U*/
>R UM* R> UM/MOD SWAP DROP
;
[THEN]

[UNDEFINED] U/MOD [IF]
\ U/MOD   u1 u2 -- ur uq     unsigned division
: U/MOD
0 SWAP UM/MOD
;
[THEN]

[UNDEFINED] U/ [IF]
\ https://forth-standard.org/standard/core/Div
\ U/      u1 u2 -- uq       signed quotient
: U/
U/MOD SWAP DROP
;
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

[UNDEFINED] HERE [IF]
CODE HERE
MOV #HEREXEC,PC
ENDCODE
[THEN]

[UNDEFINED] U.R [IF]
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]  \ U.R

$81EF DEVICEID @ U<     ; search device ID: MSP430FR4133 or...
DEVICEID @ $8241 U<     ; ...MSP430FR2433
=   
$830B DEVICEID @ U<     ; MSP430FR21xx/23xx/24xx/25xx/26xx
OR                      ; -- flag

[IF] 

\ ==============================================================================
\ driver for RTC without calendar
\ ==============================================================================

    CREATE RTCSEC 2 ALLOT
    CREATE RTCMIN 2 ALLOT
    CREATE RTCHOUR 2 ALLOT
    CREATE RTCDOW 2 ALLOT
    CREATE RTCDAY 2 ALLOT
    CREATE RTCMON 2 ALLOT
    CREATE RTCYEAR 2 ALLOT

\   ************************************\
    CODE RTC_INT                        \ computes sec min hour day month year
\   ************************************\
    ADD #2,RSP                          \ remove previous_SR
    BIT #1,&RTCIV                       \ clear RTC_IFG
    ADD.B #1,&RTCSEC                    \ sec+1
    CMP.B #60,&RTCSEC
    U>= IF               
        MOV.B #0,&RTCSEC                \ sec=0
        ADD.B #1,&RTCMIN                \ min+1
        CMP.B #60,&RTCMIN
        U>= IF               
            MOV.B #0,&RTCMIN            \ min=0
            ADD.B #1,&RTCHOUR           \ hour+1
            CMP.B #24,&RTCHOUR
            U>= IF                
                MOV.B #0,&RTCHOUR       \ hour=0
                ADD.B #1,&RTCDOW        \ dow+1
                CMP.B #7,&RTCDOW
                U>= IF
                    MOV.B #0,&RTCDOW    \ dow=0
                THEN
                ADD.B #1,&RTCDAY        \ day+1
                CMP.B #2,&RTCMON        \ February month ?
\               ------------------------\ here we compute leap year
                0= IF                   \ yes
                    COLON
                    RTCYEAR @ 4 MOD 
                    IF 29
                    ELSE
                        RTCYEAR @ 100 MOD 
                        IF 30
                        ELSE
                            RTCYEAR @ 400 MOD
                            IF 29
                            ELSE 30
                            THEN
                        THEN
                    THEN
                    HI2LO
                    MOV @RSP+,IP
                    MOV TOS,X           \ X = 29|30
                    MOV @PSP+,TOS
\               ------------------------\
                ELSE                    \ month other than Feb
                    MOV #31,X
                    MOV.B &RTCMON,W
                    CMP.B #8,W
                    0>= IF              \ month >= August?
                        ADD.B #1,W      
                    THEN
                    BIT.B #1,W          \
                    0<> IF      
                        ADD #1,X        \ 31 days / month
                    THEN
                THEN
                CMP.B X,&RTCDAY
                U>= IF                  \ max day of month is exceeded
                    MOV.B #1,&RTCDAY    \ day=1
                    ADD.B #1,&RTCMON    \ mon+1
                    CMP.B #13,&RTCMON
                    U>= IF
                    MOV.B #1,&RTCMON    \ mon=1
                        ADD #1,&RTCYEAR \ year+1
                    THEN
                THEN
            THEN
        THEN
    THEN                \
    MOV @RSP+,PC        \ RET to BACKGrouND routine, with GIE disabled
    ENDCODE    

\   ------------------------\
    ASM STOP_RTC            \ define STOP_RTC as new COLD_APP subroutine, called by {RTC}|WIPE|RST|COLD|SYS_failures.
\   ------------------------\ ------------------------------------------
    CMP #RET_ADR,&{RTC}+8   \ 
    0<> IF                  \ and only if RTC_APP is started by START_RTC
    MOV #{RTC}+10,X         \
        MOV #RET_ADR,-2(X)  \ restore {RTC}+8 default value
        MOV @X+,&RTC_VEC    \ restore previous RTC_VEC content from {RTC}+10 
        MOV @X+,&COLD+2     \ restore previous STOP_APP from {RTC}+12 to COLD_PFA
        MOV @X+,&WARM+2     \ restore previous INI_APP from {RTC}+14 to WARM_PFA
\        MOV @X+,&SLEEP+2    \ restore previous BACKGND_APP from {RTC}+16 to SLEEP_PFA
    THEN
\   ------------------------\
    MOV #0,&RTCCTL          \ stops RTC and RTC_INT, see RTC15 in MSP430FR2xxx errata sheet
    MOV.B #XIN,X            \ X = bit_position of XT1 Xtal
    BIC.B X,&XT1_SEL        \ XIN as GPIO
    BIS.B X,&XT1_DIR        \ XIN as output
    BIC.B X,&XT1_OUT        \ RTC15 :"toggle twice XIN ouput"
    BIS.B X,&XT1_OUT        \ "with at least 2 rising or falling edges". 
    BIC.B X,&XT1_OUT        \
    BIS.B X,&XT1_OUT        \ 
    BIC.B X,&XT1_DIR        \ restore default state of XIN
    BIS.B X,&XT1_SEL        \ XIN as XT1 input
\   ------------------------\
    MOV &COLD+2,PC          \ 5 link (branch) to the previous STOP_APP subroutine,
\   ------------------------\ then RET to MARKER_DOES  or to COLD+4
    ENDASM                  \
\   ------------------------\

\   ----------------------------------------\ 
    ASM INI_RTC                             \ define INI_HDWR_APP called first by START_RTC then by WARM
\   ----------------------------------------\ ---------------------------------------------------------
    CALL &{RTC}+14                          \ call previous INI_APP (which sets TOS = RSTIV_MEM)
    CMP #0,&RTCCTL                          \ if RTCCTL = 0 = reset state, app is STOPPED and must to be started
    0= IF                                   \ and if RTCCTL <> 0, we don't restart app and no time is lost.
        MOV #$7F,&RTCMOD                    \ RTCMOD = 127
        BIT #-1,&RTCIV                      \ clear RTC_IFG
        MOV #%0010_0110_0100_0010,&RTCCTL   \ starts RTC with XT1CLK/256, enables RTC_INT
    THEN
    MOV @RSP+,PC                            \ RET to BODYWARM|START_RTC
    ENDASM                                  \
\   ----------------------------------------\

\\  -------------------------------------------------------------------------------
\\  WARNING! because RTC_INT have higher priority than eUSCI used for TERMINAL, 
\\  BACKGND_APP default subroutine execute pending RTC_INT, so you can download a file without RTC time lost.
\\  but if you manualy type a command, pending RTC_INT may not be executed during this time.
\\  -------------------------------------------------------------------------------
\\   --------------------\
\\   ASM BACKGND_RTC     \ define BACKGND_RTC to replace actual BACKGND_APP
\\   --------------------\
\    BEGIN               \
\       MOV &LPM_MODE,SR \ enter to SLEEP mode, waiting RTC_INT
\    AGAIN               \ loop back to BEGIN is executed before CPU shut down
\\   --------------------\
\    ENDASM              \
\\   -------------------------------------------------------------------------------
\\   WARNING! because unlinked, this BACKGND_APP doesn't execute XON, TERMINAL is MUTEd
\\   but maybe that is what you want: RTC time keeps its accuracy.
\\   -------------------------------------------------------------------------------

\   --------------------------------\
    CODE START_RTC                  \ save current content of WARM_PFA, COLD_PFA, SLEEP_PFA, RTC_VEC
\   --------------------------------\ then replace them by INI_RTC, STOP_RTC, BACKGND_RTC, RTC_INT then execute INI_RTC.
    CMP #STOP_RTC,&{RTC}+8          \ content of {RTC}+8 = STOP_RTC ?
    0<> IF                          \ if not
        MOV #STOP_RTC,&{RTC}+8      \ STOP_RTC must be executed by MARKER_DOES of {RTC}, else RTC15 hangs out!
        MOV &RTC_VEC,&{RTC}+10      \ save content of RTC_VEC to {RTC}+10...
        MOV #RTC_INT,&RTC_VEC       \ then set RTC_VEC with RTC_INT
        MOV &COLD+2,&{RTC}+12       \ save content of COLD_PFA to {RTC}+12...
        MOV #STOP_RTC,&COLD+2       \ ...and replace it by STOP_RTC, else RTC15 hangs out with Deep_RST!
        MOV &WARM+2,&{RTC}+14       \ save content of WARM_PFA to {RTC}+14...
        MOV #INI_RTC,&WARM+2        \ ...and replace it by INI_RTC
\        MOV &SLEEP+2,&{RTC}+16      \ save content of SLEEP_PFA to {RTC}+16...
\        MOV #BACKGND_RTC,&SLEEP+2   \ ...and replace it by BACKGND_RTC
    THEN                            \
    CALL #INI_RTC                   \
    MOV @IP+,PC                     \
\   --------------------------------\
    ENDCODE                 
\   --------------------------------\

    : TIME?                 \ display time
    RTCHOUR C@ 2 U.R $3A EMIT
    RTCMIN C@  2 U.R $3A EMIT
    RTCSEC C@  2 U.R 
    ;
    
    : TIME!                 \ hour min sec ---
    START_RTC               \ if not yet done, obviously!
    2 DEPTH
    U< IF                   \ if 3 numbers on stack
        RTCSEC C!
        RTCMIN C!
        RTCHOUR C!
    THEN
    ." it is " TIME? 
    ;

    : DATE?                     \ display date

[ELSE]

\ ==============================================================================
\ driver RTC for RTC_B|RTC_C hardware with calendar
\ ==============================================================================

    CODE TIME?
    BEGIN
        BIT.B #RTCRDY,&RTCCTL1
    0<> UNTIL                   \ wait until RTCRDY high
    COLON
    RTCHOUR C@ 2 U.R $3A EMIT
    RTCMIN C@  2 U.R $3A EMIT
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

[THEN]

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
    2 U.R $2F EMIT              \ -- year mon
    2 U.R $2F EMIT              \ -- year
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
IF 1- SWAP 12 + SWAP 
THEN                    \ -- d m' y'  with m' {3=March, ..., 14=february}
100 U/MOD               \ -- d m' K J   with K = y' in century, J = century
DUP 4 U/ SWAP 2* -      \ -- d m' K (J/4 - 2J) 
SWAP DUP 4 U/ + +       \ -- d m' ((J/4 - 2J) + (K + K/4)) 
SWAP 1+  13 5 U*/ + +   \ -- (d + (((J/4 - 2J) + (K + K/4)) + (m+1)*13/5))
7 U/MOD DROP            \ -- weekday        = {0=Sat, ..., 6=Fri} 
\ ------------------------------------------
RTCDOW C!               \ --
." we are on " DATE? 
;

RST_HERE

[UNDEFINED] S_ [IF]
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

[UNDEFINED] ESC [IF]
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

[UNDEFINED] >BODY [IF]
\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
CODE >BODY
ADD #4,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] EXECUTE [IF] \ "
\ https://forth-standard.org/standard/core/EXECUTE
\ EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
CODE EXECUTE
PUSH TOS                \ 3 push xt
MOV @PSP+,TOS           \ 2 
MOV @RSP+,PC            \ 4 xt --> PC
ENDCODE
[THEN]

[UNDEFINED] EVALUATE [IF]
\ https://forth-standard.org/standard/core/EVALUATE
\ EVALUATE          \ i*x c-addr u -- j*x  interpret string
CODE EVALUATE
MOV #SOURCE_LEN,X       \ 2
MOV @X+,S               \ 2 S = SOURCE_LEN
MOV @X+,T               \ 2 T = SOURCE_ORG
MOV @X+,W               \ 2 W = TOIN
PUSHM #4,IP             \ 6 PUSHM IP,S,T,W
LO2HI
INTERPRET
HI2LO
MOV @RSP+,&TOIN         \ 4
MOV @RSP+,&SOURCE_ORG   \ 4
MOV @RSP+,&SOURCE_LEN   \ 4
MOV @RSP+,IP 
MOV @IP+,PC
ENDCODE
[THEN]

: SET_TIME
ESC [8;42;96t       \ set terminal display 42L * 96C
42 0 DO CR LOOP     \ to avoid erasing any line of source, create 42 empty lines
ESC [H              \ then set cursor home
CR ." DATE (DMY): "
PAD_ORG DUP PAD_LEN
['] ACCEPT >BODY    \ find default part of deferred ACCEPT (from terminal input)
EXECUTE             \ wait human input for D M Y
EVALUATE            \ interpret this input
CR DATE!            \ set date
CR ." TIME (HMS): "
PAD_ORG DUP PAD_LEN
['] ACCEPT >BODY    \ find default part of deferred ACCEPT (from terminal input)
EXECUTE             \ wait human input for H M S
EVALUATE            \ interpret this input
CR TIME!            \ set time
RST_STATE           \ remove code beyond RST_HERE
;
 
ECHO
SET_TIME
