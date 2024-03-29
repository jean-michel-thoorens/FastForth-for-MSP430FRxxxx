
; --------------------------------
; SD_TEST.4th for MSP_EXP430FR5994
; --------------------------------

    CODE ABORT_SD_TEST
    SUB #4,R15
    MOV R14,2(R15)
    [UNDEFINED] WRITE  
    [IF]
        MOV #-1,0(R15)
    [ELSE]
        MOV #0,0(R15)
    [THEN]
    MOV &$180A,R14
    SUB #401,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.1 please!"
    ABORT" build FastForth with SD_CARD_READ_WRITE addon!"
    RST_RET
    ;

    ABORT_SD_TEST

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] EXIT
    [IF]
    CODE EXIT
    MOV @R1+,R13
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

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 0=
    [IF]
    CODE 0=
    SUB #1,R14
    SUBC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] IF
    [IF]
    CODE IF
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$1DBE,R14
    ADD #4,&$1DBE
    MOV #[THEN]+$52,0(R14)
    ADD #2,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE THEN
    MOV &$1DBE,0(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ELSE
    [IF]
    CODE ELSE
    ADD #4,&$1DBE
    MOV &$1DBE,R10
    MOV #[THEN]+$58,-4(R10)
    MOV R10,0(R14)
    SUB #2,R10
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] BEGIN
    [IF]
    CODE BEGIN
    MOV #BEGIN,R0
    ENDCODE IMMEDIATE

    CODE UNTIL
    MOV #[THEN]+$52,R9
BW1 ADD #4,&$1DBE
    MOV &$1DBE,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE AGAIN
    MOV #[THEN]+$58,R9
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
    ADD #2,&$1DBE
    MOV &$1DBE,R14
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
BW2 ADD #4,&$1DBE
    MOV &$1DBE,R10
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

    [UNDEFINED] MAX
    [IF]
    CODE MAX
    CMP @R15,R14
    S< ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
    ENDCODE

    CODE MIN
    CMP @R15,R14
    S< ?GOTO BW1
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

    [UNDEFINED] OVER
    [IF]
    CODE OVER
    MOV R14,-2(R15)
    MOV @R15,R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

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
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1+,R14
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

    [UNDEFINED] STATE
    [IF]
    $1DB4 CONSTANT STATE
    [THEN]

    [UNDEFINED] CR
    [IF]

    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] BASE
    [IF]
    $1DB6  CONSTANT BASE
    [THEN]

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #BEGIN,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DROP
    [IF]
    CODE DROP
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 1+
    [IF]
    CODE 1+
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] =
    [IF]
    CODE =
    SUB @R15+,R14
    0<> IF
        AND #0,R14
        MOV @R13+,R0
    THEN
    XOR #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CASE
    [IF]
    : CASE
    0
    ; IMMEDIATE

    : OF
    1+	
    >R	
    POSTPONE OVER
    POSTPONE =
    POSTPONE IF	
    POSTPONE DROP	
    R>	
    ; IMMEDIATE

    : ENDOF
    >R	
    POSTPONE ELSE
    R>	
    ; IMMEDIATE

    : ENDCASE
    POSTPONE DROP
    0 DO
        POSTPONE THEN
    LOOP
    ; IMMEDIATE
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

; --------------------------
; end of definitions we need
; --------------------------

    CODE DUMP
    PUSH R13
    PUSH &BASE
    MOV #$10,&BASE
    ADD @R15,R14
    LO2HI
    SWAP
    DO
        I 4 U.R SPACE
        I 8 + I
        DO I C@ 3 U.R LOOP
        SPACE
        I $10 + I 8 +
        DO I C@ 3 U.R LOOP
        SPACE SPACE
        I $10 + I
        DO I C@ $7E MIN $20 MAX EMIT LOOP
        CR
    $10 +LOOP
    R> BASE !
    ;


    CODE SD_EMIT
    MOV &$201E,R8
    MOV.B R14,$1E00(R8)
    MOV @R15+,R14
    ADD #1,R8
    MOV R8,&$201E
    CMP #$200,R8
    U>= IF
        CALL #WRITE+$4
    THEN
    MOV @R13+,R0
    ENDCODE

    : WRITEDUMP        
    ['] SD_EMIT IS EMIT
    $4000 HERE OVER - DUMP
    ['] EMIT >BODY IS EMIT
    CLOSE
    ;

    CODE START_TIMER
    MOV #%01_0010_0100,&$3C0
    MOV @R13+,R0
    ENDCODE

    CODE DISPLAY_TIME
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$3D0,2(R15)
    MOV #0,&$3C0
    MOV #0,0(R15)
    MOV #33,R14
    CALL #<#+8
    MOV @R15+,R14
    ADD #2,R15
    COLON
    ECHO ." , done in " U. ." ms"
    ;

    : SD_TEST
    ECHO
    $0D EMIT
    CR
    ." ----------" CR
    ." SD_TESTS  " CR
    ." ----------" CR
    ." ? Fast Forth Specs" CR
    ." 0 Set date and time (MSP430FR5xxx)" CR
    ." 1 Load {UTILITY} words" CR
    ." 2 Load {SD_TOOLS} words" CR
    ." 3 Load {CORE_ANS} words" CR
    ." 4 Execute ANS core tests" CR
    ." 5 Load a source file to compile 10k program" CR
    ." 6 Read it only (51k)" CR
    ." 7 write FORTH dump in YOURFILE.TXT" CR
    ." 8 append FORTH dump to YOURFILE.TXT" CR
    ." 9 delete YOURFILE.TXT" CR
    ." your choice: "
    KEY DUP $0D = 
                IF KEY DROP ." 'CR'"
                ELSE DUP EMIT
                THEN
    RST_RET
    NOECHO
    CASE
    '?' OF  CR LOAD" FF_SPECS.4TH"  ENDOF
    '0' OF  CR LOAD" RTC.4TH"       ENDOF
    '1' OF  CR LOAD" UTILITY.4TH"   ENDOF
    '2' OF  CR LOAD" SD_TOOLS.4TH"  ENDOF
    '3' OF  CR LOAD" CORE_ANS.4TH"  ENDOF
    '4' OF  CR LOAD" CORETEST.4TH"  ENDOF
    '5' OF  CR LOAD" PROG10K.4TH"   ENDOF

    '6' OF  START_TIMER
            READ" PROG10K.4TH"
            BEGIN READ UNTIL
            DISPLAY_TIME            ENDOF
    '7' OF  START_TIMER
            WRITE" YOURFILE.TXT"
            WRITEDUMP DISPLAY_TIME  ENDOF
    '8' OF  START_TIMER
            APPEND" YOURFILE.TXT"
            WRITEDUMP DISPLAY_TIME  ENDOF
    '9' OF  START_TIMER
            DEL" YOURFILE.TXT"
            DISPLAY_TIME            ENDOF
    ENDCASE
    ;

SD_TEST
