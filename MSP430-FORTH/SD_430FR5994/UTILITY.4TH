

; --------------------------------
; UTILITY.4th for MSP_EXP430FR5994
; --------------------------------

    CODE ABORT_UTILITY
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    RST_RET
    ;

    ABORT_UTILITY

    MARKER {UTILITY} 

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

    [UNDEFINED] U< 
    [IF]
    CODE U<
    SUB @R15+,R14
    0<> IF
        MOV #-1,R14
        U< IF
            AND #0,R14
        THEN
    THEN
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

    [UNDEFINED] BEGIN [IF]
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

    [UNDEFINED] 2DUP 
    [IF]
    CODE 2DUP
    MOV R14,-2(R15)
    MOV @R15,-4(R15)
    SUB #4,R15
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

    [UNDEFINED] C@ 
    [IF]
    CODE C@
    MOV.B @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] AND 
    [IF]
    CODE AND
    AND @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] ROT 
    [IF]
    CODE ROT
    MOV @R15,R10
    MOV R14,0(R15)
    MOV 2(R15),R14
    MOV R10,2(R15)
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

    [UNDEFINED] OVER 
    [IF]
    CODE OVER
    MOV R14,-2(R15)
    MOV @R15,R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] MOVE
    [IF]
    CODE MOVE
    MOV R14,R10
    MOV @R15+,R8
    MOV @R15+,R9
    MOV @R15+,R14
    CMP #0,R10
    0<> IF
        CMP R9,R8
        0= ?GOTO FW1
        U< IF
            BEGIN
                MOV.B @R9+,0(R8)
                ADD #1,R8
                SUB #1,R10
            0= UNTIL
            MOV @R13+,R0
        ELSE
            ADD R10,R8
            ADD R10,R9
            BEGIN
                SUB #1,R9
                SUB #1,R8
                MOV.B @R9,0(R8)
                SUB #1,R10
            0= UNTIL
        THEN
    THEN
FW1 MOV @R13+,R0
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

    [UNDEFINED] BASE 
    [IF]
    $1DBE  CONSTANT BASE
    [THEN]

    [UNDEFINED] .S 
    [IF]
    CODE .S
    MOV     R14,-2(R15)
    MOV     R15,R14
    SUB     #2,R14
    MOV     R14,-6(R15)
    MOV     #$1C80,R14
    SUB     #2,R14
BW1 MOV     R14,-4(R15)
    SUB     #6,R15
    SUB     @R15,R14
    RRA     R14
    COLON
    $3C EMIT
    .
    $08 EMIT
    $3E EMIT SPACE
    2DUP 1+
    U< IF 
        DROP DROP EXIT
    THEN
    BASE @ >R
    $10 BASE !
    DO 
        '$' EMIT
        I @ U.
    2 +LOOP
    R> BASE !
    ;
    [THEN]

    [UNDEFINED] .RS 
    [IF]
    CODE .RS
    MOV     R14,-2(R15)
    MOV     R1,-6(R15)
    MOV     #$1CE0,R14
    GOTO    BW1
    ENDCODE
    [THEN]

    [UNDEFINED] ? 
    [IF]
    CODE ?          
    MOV @R14,R14
    MOV #U.,R0
    ENDCODE
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

    [UNDEFINED] 2/ 
    [IF]
    CODE 2/
    RRA R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] WORDS 
    [IF]
    : WORDS
    CR 
    $1DCE @ $1CE4
    $180C @ DUP +
    MOVE
    BEGIN
        0 DUP
        $180C @ DUP + 0
            DO
            DUP I $1CE4 + @
                U< IF
                    DROP DROP
                    I DUP 
                    $1CE4 + @
                THEN
            2 +LOOP
        ?DUP
    WHILE
        DUP
        2 - @
        ROT
        $1CE4 +
        !
        COUNT 2/
        DUP >R TYPE
        R> $10 SWAP - SPACES
    REPEAT
    DROP
    ;
    [THEN]

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
    PUSH &$1DBE
    MOV #$10,&$1DBE
    ADD @R15,R14
    LO2HI
    SWAP
    $FFF0 AND
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
    R> BASE  !
    ;
    [THEN]

    RST_SET

    [THEN] ECHO ; endof [UNDEFINED] {TOOLS}

