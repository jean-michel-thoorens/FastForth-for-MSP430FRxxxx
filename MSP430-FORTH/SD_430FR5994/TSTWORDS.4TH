
    CODE ABORT_TSTWORDS
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #400,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.0 please!"
    RST_RET
    ;

    ABORT_TSTWORDS

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] 0=
    [IF]
    CODE 0=
    SUB #1,R14
    SUBC R14,R14
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

    [UNDEFINED] ELSE
    [IF]
    CODE ELSE
    ADD #4,&$1DC0
    MOV &$1DC0,R10
    MOV #$409C,-4(R10)
    MOV R10,0(R14)
    SUB #2,R10
    MOV R10,R14
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

; --------------------------
; end of definitions we need
; --------------------------

ECHO

; -----------------------------------------------------------------------
; test some assembler words and show how to mix FORTH/ASSEMBLER routines
; -----------------------------------------------------------------------

LOAD" \misc\TestASM.4th"

ECHO

; -------------------------------------
; here we returned in the TestWords.4th
; -------------------------------------

: LOOP_TEST 8 0 DO I . LOOP
;

LOOP_TEST


: LOOP_TEST1
    BEGIN   DUP U. 1 -
    ?DUP
    0= UNTIL
;
: FIND_TEST
   $20 WORD
       50000 0
       DO
           DUP
           FIND DROP DROP
       LOOP
    FIND
    0=  IF ABORT" <-- not found !"
        ELSE ABORT" <-- found !"
        THEN
 ;

