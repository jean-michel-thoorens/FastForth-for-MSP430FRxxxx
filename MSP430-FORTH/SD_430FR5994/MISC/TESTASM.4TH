
; -----------------------------------------------------------------------
; TEST_ASM.4th for MSP_EXP430FR5994
; -----------------------------------------------------------------------

    CODE ABORT_TEST_ASM
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #400,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.0 please!"
    ;

    ABORT_TEST_ASM

ECHO

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] >R
    [IF]
    CODE >R
    PUSH R14
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] R>
    [IF]
    CODE R>
    MOV R7,R0
    ENDCODE
    [THEN]

    [UNDEFINED] +
    [IF]
    CODE +
    ADD @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] -
    [IF]
    CODE -
    SUB @R15+,R14
    XOR #-1,R14
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    MOV @R15,R10
    MOV R14,0(R15)
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] MAX
    [IF]

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

    [UNDEFINED] C@
    [IF]
    CODE C@
    MOV.B @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] VARIABLE
    [IF]
    : VARIABLE
    CREATE
    HI2LO
    MOV #$1287,-4(R10)
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CONSTANT
    [IF]
    : CONSTANT
    CREATE
    HI2LO
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] SPACE
    [IF]
    : SPACE
    $20 EMIT ;
    [THEN]

    [UNDEFINED] SPACES
    [IF]
    CODE SPACES
    CMP #0,R14
    0<> IF
        PUSH R13
        BEGIN
            LO2HI
            $20 EMIT
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

    [UNDEFINED] DUP
    [IF]
    CODE DUP
BW1 SUB #2,R15
    MOV R14,0(R15)
    MOV @R13+,R0
    ENDCODE

    CODE ?DUP
    CMP #0,R14
    0<> ?GOTO BW1
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DROP
    [IF]
    CODE DROP
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] OVER
    [IF]
    CODE OVER
    MOV R14,-2(R15)
    MOV @R15,R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] IF
    [IF]

    CODE IF
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$1DC0,R14
    ADD #4,&$1DC0
    MOV #$4096,0(R14)
    ADD #2,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE THEN
    MOV &$1DC0,0(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    PUSH R14
    MOV @R15,R14
    MOV @R1+,0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] BEGIN
    [IF]

    CODE BEGIN
    MOV #BEGIN,R0
    ENDCODE IMMEDIATE

    CODE UNTIL
    MOV #$4096,R9
BW1 ADD #4,&$1DC0
    MOV &$1DC0,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE AGAIN
    MOV #$409C,R9
    GOTO BW1
    ENDCODE IMMEDIATE

    : WHILE
    POSTPONE IF SWAP
    ; IMMEDIATE

    : REPEAT
    POSTPONE AGAIN POSTPONE THEN
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] DO
    [IF]

    HDNCODE XDO
    MOV #$8000,R9
    SUB @R15+,R9
    MOV R14,R8
    ADD R9,R8
    PUSHM #2,R9
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE

    CODE DO
    SUB #2,R15
    MOV R14,0(R15)
    ADD #2,&$1DC0
    MOV &$1DC0,R14
    MOV #XDO,-2(R14)
    ADD #2,&$1C00
    MOV &$1C00,R10
    MOV #0,0(R10)
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    HDNCODE XLOOP
    ADD #1,0(R1)
BW1 BIT #$100,R2
    0= IF
        MOV @R13,R13
        MOV @R13+,R0
    THEN
    ADD #4,R1
    ADD #2,R13
    MOV @R13+,R0
    ENDCODE

    CODE LOOP
    MOV #XLOOP,R9
BW2 ADD #4,&$1DC0
    MOV &$1DC0,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    BEGIN
        MOV &$1C00,R14
        SUB #2,&$1C00
        MOV @R14,R14
        CMP #0,R14
    0<> WHILE
        MOV R10,0(R14)
    REPEAT
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    HDNCODE XPLOO
    ADD R14,0(R1)
    MOV @R15+,R14
    GOTO BW1
    ENDCODE

    CODE +LOOP
    MOV #XPLOO,R9
    GOTO BW2
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] I
    [IF]
    CODE I
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1,R14
    SUB 2(R1),R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] BASE
    [IF]
    $1DB6  CONSTANT BASE
    [THEN]

    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #$409E,R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] C,
    [IF]
    CODE C,
    MOV &$1DC0,R10
    MOV.B R14,0(R10)
    ADD #1,&$1DC0
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] C@
    [IF]
    CODE C@
    MOV.B @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; ------------------------------------------------------------------
; then we download the set of definitions we need (from UTILITY.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] U.R
    [IF]
    : U.R
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    [UNDEFINED] DUMP
    [IF]
    CODE DUMP
    PUSH R13
    PUSH &BASE
    MOV #$10,&$1DB6
    ADD @R15,R14
    LO2HI
    SWAP
    DO  CR
        I 4 U.R SPACE
        I 8 + I
        DO I C@ 3 U.R LOOP
        SPACE
        I $10 + I 8 +
        DO I C@ 3 U.R LOOP
        SPACE SPACE
        I $10 + I
        DO I C@ $7E MIN $20 MAX EMIT LOOP
    $10 +LOOP
    R> BASE !
    ;
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

ECHO
    CODE TESTPUSHM
BW1
    MOV     #22222,R8
    MOV     #3,R9
    MOV     #2,R10
    MOV     #1,R11
    MOV     #0,R12

    PUSHM   #4,R13
    POPM    #4,R13
    SUB     #10,R15
    MOV     R14,8(R15)
    MOV     R12,6(R15)
    MOV     R11,4(R15)
    MOV     R10,2(R15)
    MOV     R9,0(R15)
    MOV     R8,R14
    RRAM    #1,R14
    RLAM    #2,R14
    RRCM    #1,R14
    RRUM    #1,R14
    COLON
    space . . . . .
    ;

    TESTPUSHM  ; you should see 11111 3 2 1 0 -->

    CODE TESTPOPM
            GOTO BW1
    ENDCODE

    TESTPOPM  ; you should see 11111 3 2 1 0 -->


    CODE TEST1

    MOV &BASE,&BASE
    CMP #%10,&BASE
    0<> IF  MOV #2,&BASE
    ELSE    MOV #$0A,&BASE
    THEN
    COLON
    BASE @ U.
    ;


    : TEST2
    BASE @ U.
    HI2LO


    CMP #2, &BASE
    0<> IF  MOV #2, &BASE
    ELSE    MOV #10,&BASE
    THEN
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE

    CODE TEST3
    CMP #2, &BASE
    0<> IF  MOV #2, &BASE
    ELSE    MOV #10,&BASE
    THEN    COLON
    BASE @  U.
    ;


: TEST5
            SPACE
            HI2LO
            SUB #2,R15
            MOV R14,0(R15)
            MOV #%1010,R14
BEGIN       SUB #$0001,R14
            LO2HI

            DUP U.
            HI2LO
            CMP #0,R14
0= UNTIL    MOV @R15+,R14
            MOV @R1+,R13
            MOV @R13+,R0
ENDCODE

TEST5  ; you should see :  9 8 7 6 5 4 3 2 1 0 -->


: BYTES_TABLE_IDX
CREATE
0 DO I C,
LOOP
DOES>
+
;

8 BYTES_TABLE_IDX BYTES_TABLE

2 BYTES_TABLE C@ . ; you should see 2 -->


VARIABLE BYTES_TABLE1

$0201 BYTES_TABLE1 !

CODE IDX_TEST1
    MOV.B   BYTES_TABLE1(R14),R14
COLON
    U.
;

0 IDX_TEST1     ; you should see 1 -->

CODE TEST6
            MOV 0(R15),0(R15)
            MOV @R13+,R0
ENDCODE


1 TEST6 .       ; you should see 1 -->





CREATE TABLE0
0 C,
1 C,
2 C,
3 C,


CREATE TABLE10
$10 C,
$11 C,
$12 C,
$13 C,



CREATE TABLE20
$20 C,
$21 C,
$22 C,
$23 C,


CREATE TABLE


TABLE 2 - CONSTANT PFA_TABLE


CODE REDIRECT       ; <table> --    redirects TABLE to argument <table>
MOV R14,&PFA_TABLE
MOV @R15+,R14
MOV @R13+,R0
ENDCODE


CODE REDIRECT0      ; --            redirects TABLE to TABLE0
MOV #TABLE0,&PFA_TABLE
MOV @R13+,R0
ENDCODE


CODE REDIRECT10     ; --            redirects TABLE to TABLE10
MOV #TABLE10,&PFA_TABLE
MOV @R13+,R0
ENDCODE


CODE REDIRECT20     ; --            redirects TABLE to TABLE20
MOV #TABLE20,&PFA_TABLE
MOV @R13+,R0
ENDCODE


' TABLE0 10 DUMP

' TABLE10 10 DUMP

' TABLE20 10 DUMP


TABLE0 REDIRECT TABLE 10 DUMP

TABLE10 REDIRECT TABLE 10 DUMP

TABLE20 REDIRECT TABLE 10 DUMP


REDIRECT0 TABLE 10 DUMP

REDIRECT10 TABLE 10 DUMP

REDIRECT20 TABLE 10 DUMP


TABLE0 PFA_TABLE ! TABLE 10 DUMP

TABLE10 PFA_TABLE ! TABLE 10 DUMP

TABLE20 PFA_TABLE ! TABLE 10 DUMP




; -----------------------------------------------------------------------
; create a primary DEFERred assembly word
; -----------------------------------------------------------------------

    CODE TRUC
    MOV #$409E,R0
    ENDCODE

    CODENNM
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R13+,R0
    ENDCODE     ; leaves its execution address (CFA) on stack

DUP .           ; see it --> 

IS TRUC         ; TRUC becomes a primary DEFERred word
                ; with its default action (DUP) located at its BODY addresse.

TRUC .          ; display R14 value -->

' DROP IS TRUC  ; TRUC is redirected to DROP

; TRUC          ; The generated error displays stack empty! in reverse video, removes the TRUC definition and restarts the interpretation after the end of the file. And as you see, FastForth is able to display long lines, interesting, doesn't it? -->

' TRUC >BODY IS TRUC    ; TRUC is reinitialized with its default action

TRUC .          ; display R14 value -->

