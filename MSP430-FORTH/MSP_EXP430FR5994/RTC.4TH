
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

[UNDEFINED] CONSTANT [IF]
: CONSTANT 
DEFER
HI2LO
MOV @R1+,R13
MOV #$1285,-4(R10)
MOV R14,-2(R10)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] BL [IF]
#32 CONSTANT BL
[THEN]

[UNDEFINED] SPACES [IF]
CODE SPACES
CMP #0,R14
0<> IF
    PUSH R13
    BEGIN
        LO2HI
        BL EMIT
        HI2LO
        SUB #2,R13 
        SUB #1,R14
    0= UNTIL
    MOV @R1+,R13
THEN
MOV @R15+,R14
MOV @R13+,R0              
ENDCODE
[THEN]

[UNDEFINED] OVER [IF]
CODE OVER
MOV R14,-2(R15)
MOV @R15,R14
SUB #2,R15
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
2 DEPTH U< IF
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
2 DEPTH U< IF
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

: [ISDEFERRED?]
    DUP @ $4030 =
; IMMEDIATE

CREATE ABUF 20 ALLOT

: GET_TIME
PWR_STATE
42
0 DO CR LOOP

ESC ." [1J"
ESC ." [H"

CR ." DATE (DMY): "
ABUF DUP 20 
    ['] ACCEPT [ISDEFERRED?] 
    [IF] >BODY
    [THEN] EXECUTE
EVALUATE CR DATE!
CR CR ." TIME (HMS): "
ABUF DUP 20 
    ['] ACCEPT [ISDEFERRED?] 
    [IF] >BODY
    [THEN] EXECUTE
EVALUATE CR TIME!
CR
;

ECHO GET_TIME