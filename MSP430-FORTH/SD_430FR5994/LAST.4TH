
; -----------
; SD_TEST.4th for MSP_EXP430FR5994
; -----------

    CODE ABORT_SD_TEST
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    [UNDEFINED] WRITE 
    [IF]
        1 ABORT" no SD_CARD_READ_WRITE addon!"
    [THEN]
    RST_RET
    ;

    ABORT_SD_TEST

    MARKER {SD_TEST}

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
    MOV &$1DC8,R14
    ADD #4,&$1DC8
    MOV #$40AC,0(R14)
    ADD #2,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE THEN
    MOV &$1DC8,0(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ELSE 
    [IF]
    CODE ELSE
    ADD #4,&$1DC8
    MOV &$1DC8,R10
    MOV #$40B2,-4(R10)
    MOV R10,0(R14)
    SUB #2,R10
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] BEGIN 
    [IF]
    CODE BEGIN
    MOV #$4032,R0
    ENDCODE IMMEDIATE

    CODE UNTIL
    MOV #$40AC,R9
BW1 ADD #4,&$1DC8
    MOV &$1DC8,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE AGAIN
    MOV #$40B2,R9
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
    ADD #2,&$1DC8
    MOV &$1DC8,R14
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
BW2 ADD #4,&$1DC8
    MOV &$1DC8,R10
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
    $1DBC CONSTANT STATE
    [THEN]

    [UNDEFINED] CR 
    [IF]
    
    CODE CR
    MOV #$40B4,R0
    ENDCODE
    
    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] U.R 
    [IF]
    : U.R
    >R  <# 0 # #S #>  
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    [UNDEFINED] BASE 
    [IF]
    $1DBE  CONSTANT BASE
    [THEN]

    [UNDEFINED] DUMP 
    [IF]
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

    [UNDEFINED] = [IF]
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

    CODE SD_EMIT
    CMP #$200,&$201E
    U>= IF
        CALL &WRITE+2
    THEN
    MOV &$201E,R8
    MOV.B R14,$1E00(R8)
    ADD #1,&$201E
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE

: DOESWRITE
    ['] SD_EMIT IS EMIT
    $4000 HERE OVER - DUMP
    ['] EMIT >BODY IS EMIT
    CLOSE
    ." , done"
;

    : SD_TEST
    ECHO
    $0D EMIT
    ." ? Fast Forth Specifs" CR
    ." 0 Set date and time" CR
    ." 1 Load {UTILTY} words" CR
    ." 2 Load {SD_TOOLS} words" CR
    ." 3 Load {CORE_COMP} words" CR
    ." 4 Load ANS core tests" CR
    ." 5 Load a 10k program " CR
    ." 6 Read only this source file" CR
    ." 7 write FORTH dump in YOURFILE.TXT" CR
    ." 8 append FORTH dump to YOURFILE.TXT" CR
    ." 9 Load TST_WORDS" CR
    ." your choice : "
    KEY DUP EMIT CR
    {SD_TEST}
    CASE
    '?' OF  LOAD" FF_SPECS.4TH" ENDOF
    '0' OF  LOAD" RTC.4TH"      ENDOF
    '1' OF  LOAD" UTILITY.4TH"  ENDOF
    '2' OF  LOAD" SD_TOOLS.4TH" ENDOF
    '3' OF  LOAD" CORE_ANS.4TH" ENDOF
    '4' OF  LOAD" CORETEST.4TH" ENDOF 
    '5' OF  LOAD" PROG10K.4TH"  ENDOF
    '6' OF  READ" PROG10K.4TH"
            BEGIN READ
            UNTIL ." , done"    ENDOF
    '7' OF  ECHO
            WRITE" YOURFILE.TXT"
            DOESWRITE           ENDOF
    '8' OF  ECHO
            APPEND" YOURFILE.TXT"
            DOESWRITE           ENDOF
    '9' OF  LOAD" TSTWORDS.4TH" ENDOF
    ENDCASE
    ;

    [THEN]

SD_TEST
