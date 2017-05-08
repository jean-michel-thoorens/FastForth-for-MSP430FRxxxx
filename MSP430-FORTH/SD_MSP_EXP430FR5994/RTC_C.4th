; --------------------
; RTC_C.f
; --------------------
 

CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

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

CODE DATE!
    MOV.B   #$A5,&$4A1
    MOV     R14,&$4B6
    MOV.B   @R15,&$4B5
    MOV.B   2(R15),&$4B4
    ADD     #4,R15
    MOV     @R15+,R14
COLON
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
    DEPTH 2 = IF 0 THEN
    HI2LO
    MOV.B   #$A5,&$4A1
    MOV     R14,&$4B0
    MOV.B   @R15,&$4B1
    MOV.B   2(R15),&$4B2
    ADD     #4,R15
    MOV     @R15+,R14
    LO2HI
    ." it is " TIME? 
;

CREATE ABUF 20 ALLOT

: GET_TIME
    ECHO
    CR CR ."    DATE (DMY): "
    ABUF ABUF 20 (ACCEPT) EVALUATE CR 3 SPACES DATE!
    CR CR ."    TIME (HMS or HM): "
    ABUF ABUF 20 (ACCEPT) EVALUATE CR 3 SPACES TIME!
    CR 
    PWR_STATE
    HI2LO
    MOV #$1C80,R15
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE

GET_TIME
