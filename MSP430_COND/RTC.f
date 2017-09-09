; --------------------
; RTC_C.f
; --------------------

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



\ routines RTC for MSP430fr5xxx and MSP430FR6xxx families
\ target must have a LF_XTAL 32768Hz.

\ compile DTCforthMSP430FR5xxx.asm with the switch LF_XTAL set to ON (uncommment the line).

\ use :
\ to set date, type : dd mm yyyy DATE!
\ to view date, type DATE?
\ to set time, type : hh mm ss TIME!, or hh mm TIME!
\ to view time, type TIME?
 
\ allow to write on a SD_Card file with a valid date and a valid time

[UNDEFINED] {RTC} [IF]
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

[THEN]
    \

[UNDEFINED] U.R [IF]
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]
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
DEPTH 1 > IF
    DEPTH 2 = IF 0 THEN     \ to allow "hour min TIME!" scheme
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
    ABUF ABUF 20 (ACCEPT) EVALUATE CR 3 SPACES DATE!
    CR CR ."    TIME (HMS or HM): "
    ABUF ABUF 20 (ACCEPT) EVALUATE CR 3 SPACES TIME!
    CR NOECHO
    HI2LO
    MOV #PSTACK,PSP \ to avoid stack empty error if lack of typed values.
    MOV @RSP+,IP
    MOV @IP+,PC
ENDCODE
    \
PWR_HERE
[THEN]
    \
GET_TIME
