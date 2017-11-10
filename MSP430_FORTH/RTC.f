; --------------------
; RTC.f
; --------------------

\ ==============================================================================
\ routines RTC for MSP430fr5xxx and MSP430FR6xxx families only
\ your target must have a LF_XTAL 32768Hz
\ add a LF_XTAL line for your target in target.inc.
\ ==============================================================================


\ TARGET SELECTION (MSP430FR5xxx or MSP430FR6xxx only)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MY_MSP430FR5738_1 MY_MSP430FR5738     MY_MSP430FR5948     MY_MSP430FR5948_1   
\ JMJ_BOX


\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4
\ example : PUSHM IP,Y
\
\ POPM  order :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before GOTO ?GOTO     : S< S>= U< U>= 0= 0<> <0 

\ FORTH conditionnal usage after IF UNTIL WHILE : 0= 0< = < > U<



\ use :
\ to set date, type : d m y DATE!
\ to view date, type DATE?
\ to set time, type : h m s TIME!, or h m TIME!
\ to view time, type TIME?
 
\ allow to write a file on a SD_Card with a valid date and a valid time


PWR_STATE
    \
[DEFINED] {RTC} [IF] {RTC} [THEN]     \ remove application
    \
[DEFINED] ASM [IF]      \ security test
    \
MARKER {RTC}
    \
[UNDEFINED] MAX [IF]
    \
CODE MAX    \    n1 n2 -- n3       signed maximum
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
ENDCODE
    \
CODE MIN    \    n1 n2 -- n3       signed minimum
    CMP @PSP,TOS     \ n2-n1
    S<  ?GOTO BW1    \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE
    \
[THEN]  \ MAX
    \

[UNDEFINED] U.R [IF]
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]  \ U.R
    \

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
    \
: DATE!
DEPTH 2 > IF
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
    \
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
    \
: TIME!
DEPTH 2 > IF
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
    \
CREATE ABUF 20 ALLOT
    \
: GET_TIME
    ECHO
    CR CR ."    DATE (DMY): "
[DEFINED] LOAD" [IF]    \ ACCEPT is a dEFERed word and redirected to SD_ACCEPT!
    ABUF ABUF 20 (ACCEPT) EVALUATE CR 3 SPACES DATE!
    CR CR ."    TIME (HMS): "
    ABUF ABUF 20 (ACCEPT) EVALUATE CR 3 SPACES TIME!
[ELSE]                  \ ACCEPT is not a DEFERed word
    ABUF ABUF 20 ACCEPT EVALUATE CR 3 SPACES DATE!
    CR CR ."    TIME (HMS): "
    ABUF ABUF 20 ACCEPT EVALUATE CR 3 SPACES TIME!
[THEN]
    CR
;
    \
[THEN]  \ ASM
    \
PWR_HERE
    \
GET_TIME
