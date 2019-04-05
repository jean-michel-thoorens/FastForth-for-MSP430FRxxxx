
; --------------------
; RTC.4th
; --------------------

PWR_STATE

[UNDEFINED] {RTC} [IF]

MARKER {RTC}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE

CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]

[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]

CODE DATE?
    SUB     #6,R15
    MOV     R14,4(R15)
    BEGIN
        BIT.B #$10,&$4A2
    0<> UNTIL
    MOV     &$4B6,2(R15)
    MOV.B   &$4B5,R14
    MOV     R14,0(R15)
    MOV.B   &$4B4,R14
COLON
    2 U.R $2F EMIT
    2 U.R $2F EMIT . 
;

: DATE!
DEPTH 2 > IF
    HI2LO
    MOV     R14,&$4B6
    MOV.B   @R15,&$4B5
    MOV.B   2(R15),&$4B4
    ADD     #4,R15
    MOV     @R15+,R14
    LO2HI
THEN
    ." we are on " DATE? 
;

CODE TIME?
    SUB     #6,R15
    MOV     R14,4(R15)
    BEGIN
        BIT.B #$10,&$4A2
    0<> UNTIL
    MOV.B   &$4B0,R14
    MOV     R14,2(R15)
    MOV.B   &$4B1,R14
    MOV     R14,0(R15)
    MOV.B   &$4B2,R14
COLON
    2 U.R $3A EMIT 
    2 U.R $3A EMIT 2 U.R 
;

: TIME!
DEPTH 2 > IF
    HI2LO
    MOV     R14,&$4B0
    MOV.B   @R15,&$4B1
    MOV.B   2(R15),&$4B2
    ADD     #4,R15
    MOV     @R15+,R14
    LO2HI
THEN
    ." it is " TIME? 
;

RST_HERE

[THEN]

: ESC #27 EMIT ;

: [DEFERRED]
    ' @ $4030 =
; IMMEDIATE

CREATE ABUF 20 ALLOT

: GET_TIME
PWR_STATE
42
0 DO CR LOOP

ESC ." [1J"
ESC ." [H"

CR ." DATE (DMY): "
ABUF ABUF 20 
     [DEFERRED] ACCEPT 
     [IF] ['] ACCEPT >BODY EXECUTE
     [ELSE] ACCEPT
     [THEN]
EVALUATE CR DATE!
CR CR ." TIME (HMS): "
ABUF ABUF 20 
     [DEFERRED] ACCEPT 
     [IF] ['] ACCEPT >BODY EXECUTE
     [ELSE] ACCEPT
     [THEN]
EVALUATE CR TIME!
CR
;

ECHO GET_TIME
