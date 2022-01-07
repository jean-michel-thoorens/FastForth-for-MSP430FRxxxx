
    CODE ABORT_DOUBLE
    SUB #4,R15
    MOV R14,2(R15)
    MOV &$180E,R14
    BIT #$80,R14
    0<> IF MOV #0,R14 THEN
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    ABORT" build FastForth with DOUBLE_INPUT addon !"
    RST_RET
    ;

    ABORT_DOUBLE

; -----------------------------------------------------
; DOUBLE.4th for MSP_EXP430FR5994
; -----------------------------------------------------

    MARKER {DOUBLE}

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

    [UNDEFINED] 0<
    [IF]
    CODE 0<
    ADD R14,R14
    SUBC R14,R14
    XOR #-1,R14
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

    [UNDEFINED] NIP
    [IF]
    CODE NIP
    ADD #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] UM/MOD
    [IF]
    CODE UM/MOD
        PUSH #DROP
        MOV #$403E,R0
    ENDCODE
    [THEN]

    $180E @ 0<   ; test the switch: $8000 / SYMETRIC DIVISION
    [IF]                ; $8000 DIVISION
    [UNDEFINED] FM/MOD
    [IF]
    CODE FM/MOD
    MOV R14,R12
    MOV @R15,R11
    CMP #0,R14
    S< IF
        XOR #-1,R14
        ADD #1,R14
    THEN
    CMP #0,0(R15)
    S< IF
        XOR #-1,2(R15)
        XOR #-1,0(R15)
        ADD #1,2(R15)
        ADDC #0,0(R15)
    THEN
    PUSHM #3,R13
    LO2HI
        UM/MOD
    HI2LO
    POPM #3,R13
    CMP #0,R11
    S< IF
        XOR #-1,0(R15)
        ADD #1,0(R15)
    THEN
    XOR R12,R11
    CMP #0,R11
    S< IF
        XOR #-1,R14
        ADD #1,R14
    THEN

    CMP #0,0(R15)
    0<> IF
        CMP #1,R14
        S< IF
        ADD R12,0(R15)
        SUB #1,R14
        THEN
    THEN
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [ELSE]              ; SYMETRIC DIVISION
    [UNDEFINED] SM/REM
    [IF]
    CODE SM/REM
    MOV R14,R12
    MOV @R15,R11
    CMP #0,R14
    S< IF
        XOR #-1,R14
        ADD #1,R14
    THEN
    CMP #0,0(R15)
    S< IF
        XOR #-1,2(R15)
        XOR #-1,0(R15)
        ADD #1,2(R15)
        ADDC #0,0(R15)
    THEN
    PUSHM #3,R13
    LO2HI
        UM/MOD
    HI2LO
    POPM #3,R13
    CMP #0,R11
    S< IF
        XOR #-1,0(R15)
        ADD #1,0(R15)
    THEN
    XOR R12,R11
    CMP #0,R11
    S< IF
        XOR #-1,R14
        ADD #1,R14
    THEN
    MOV @R13+,R0
    ENDCODE
    [THEN]
    [THEN]

    [UNDEFINED] /
    [IF]
    : /
    >R DUP 0< R>
    [ $180E @ 0< ] [IF]
        FM/MOD
    [ELSE]
        SM/REM
    [THEN]
    NIP
    ;
    [THEN]

    [UNDEFINED] @
    [IF]
    CODE @
    MOV @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] !
    [IF]
    CODE !
    MOV @R15+,0(R14)
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

    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    MOV @R15,R10
    MOV R14,0(R15)
    MOV R10,R14
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

    [UNDEFINED] -
    [IF]
    CODE -
    SUB @R15+,R14
    XOR #-1,R14
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] <
    [IF]
    CODE <
    SUB @R15+,R14
    S< ?GOTO FW1
    0<> IF
BW1 MOV #-1,R14
    THEN
    MOV @R13+,R0
    ENDCODE

    CODE >
    SUB @R15+,R14
    S< ?GOTO BW1
FW1 AND #0,R14
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

    [UNDEFINED] TO
    [IF]
    CODE TO
    BIS #$200,R2
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DOES>
    [IF]
    CODE DOES>
    MOV &$1DB8,R10
    MOV #$1285,0(R10)
    MOV R13,2(R10)
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE
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

    [UNDEFINED] 2@
    [IF]
    CODE 2@
    SUB #2,R15
    MOV 2(R14),0(R15)
    MOV @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2!
    [IF]
    CODE 2!
    MOV @R15+,0(R14)
    MOV @R15+,2(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2DUP
    [IF]
    CODE 2DUP
    SUB #4,R15
    MOV R14,2(R15)
    MOV 4(R15),0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2DROP
    [IF]
    CODE 2DROP
    ADD #2,R15
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2SWAP
    [IF]
    CODE 2SWAP
    MOV @R15,R10
    MOV 4(R15),0(R15)
    MOV R10,4(R15)
    MOV R14,R10
    MOV 2(R15),R14
    MOV R10,2(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2OVER
    [IF]
    CODE 2OVER
    SUB #4,R15
    MOV R14,2(R15)
    MOV 8(R15),0(R15)
    MOV 6(R15),R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2>R
    [IF]
    CODE 2>R
    PUSH @R15+
    PUSH R14
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2R@
    [IF]
    CODE 2R@
    SUB #4,R15
    MOV R14,2(R15)
    MOV @R1,R14
    MOV 2(R1),0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2R>
    [IF]
    CODE 2R>
    SUB #4,R15
    MOV R14,2(R15)
    MOV @R1+,R14
    MOV @R1+,0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]


    [UNDEFINED] D.
    [IF]
    CODE D.
    MOV R14,R12
    MOV #U.+10,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2ROT
    [IF]
    CODE 2ROT
    MOV 8(R15),R9
    MOV 6(R15),R8
    MOV 4(R15),8(R15)
    MOV 2(R15),6(R15)
    MOV @R15,4(R15)
    MOV R14,2(R15)
    MOV R9,0(R15)
    MOV R8,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D>S
    [IF]
    CODE D>S
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D0=
    [IF]
    CODE D0=
    CMP #0,R14
    MOV #0,R14
    0= IF
        CMP #0,0(R15)
        0= IF
            MOV #-1,R14
        THEN
    THEN
    ADD #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D0<
    [IF]
    CODE D0<
    CMP #0,R14
    MOV #0,R14
    S< IF
        MOV #-1,R14
    THEN
    ADD #2,R15
    AND #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D=
    [IF]
    CODE D=
    CMP R14,2(R15)
    MOV #0,R14
    0= IF
        CMP @R15,4(R15)
        0= IF
        MOV #-1,R14
        THEN
    THEN
    ADD #6,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D<
    [IF]
    CODE D<
    CMP R14,2(R15)
    MOV #0,R14
    S< IF
        MOV #-1,R14
    THEN
    0= IF
        CMP @R15,4(R15)
        U< IF
            MOV #-1,R14
        THEN
    THEN
    ADD #6,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DU<
    [IF]
    CODE DU<
    CMP R14,2(R15)
    MOV #0,R14
    U< IF
        MOV #-1,R14
    THEN
    0= IF
        CMP @R15,4(R15)
        U< IF
            MOV #-1,R14
        THEN
    THEN
    ADD #6,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D+
    [IF]
    CODE D+
BW1 ADD @R15+,2(R15)
    ADDC @R15+,R14
    MOV @R13+,R0
    ENDCODE

    CODE M+
    SUB #2,R15
    CMP #0,R14
    MOV R14,0(R15)
    MOV #-1,R14
    0>= IF
        MOV #0,R14
    THEN
    GOTO BW1
    ENDCODE
    [THEN]

    [UNDEFINED] D-
    [IF]
    CODE D-
    SUB @R15+,2(R15)
    SUBC R14,0(R15)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DNEGATE
    [IF]
    CODE DNEGATE
    XOR #-1,0(R15)
    XOR #-1,R14
    ADD #1,0(R15)
    ADDC #0,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DABS
    [IF]
    CODE DABS
    CMP #0,R14
    0>= IF
        MOV @R13+,R0
    THEN
    MOV #DNEGATE,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D2/
    [IF]
    CODE D2/
    RRA R14
    RRC 0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] D2*
    [IF]
    CODE D2*
    ADD @R15,0(R15)
    ADDC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DMAX
    [IF]
    : DMAX
    2OVER 2OVER
    D< IF
        2>R 2DROP 2R>
    ELSE
        2DROP
    THEN
    ;
    [THEN]

    [UNDEFINED] DMIN
    [IF]
    : DMIN
    2OVER 2OVER
    D< IF
        2DROP
    ELSE
        2>R 2DROP 2R>
    THEN
    ;
    [THEN]

    RST_SET

    CODE TSTBIT
    MOV @R15+,R9
    AND @R9,R14
    MOV @R13+,R0
    ENDCODE

    $180E 1 TSTBIT

    RST_RET

    [IF]   ; MSP430FRxxxx with hardware_MPY

        [UNDEFINED] M*/
        [IF]
    CODE M*/
    MOV 4(R15),&$4D4
    MOV 2(R15),&$4D6
    MOV @R15+,&$4C8
    MOV R14,R11
    MOV R0,R0
    MOV &$4E4,R12
    MOV &$4E6,R14
    MOV &$4E8,R10
    MOV #0,R6
    CMP #0,R10
    S< IF
        XOR #-1,R12
        XOR #-1,R14
        XOR #-1,R10
        ADD #1,R12
        ADDC #0,R14
        ADDC #0,R10
        MOV #-1,R6
    THEN

    [ELSE]  ; no hardware multiplier
        [UNDEFINED] M*/
        [IF]
    CODE M*/
    MOV #0,R6
    CMP #0,2(R15)
    S< IF
        XOR #-1,4(R15)
        XOR #-1,2(R15)
        ADD #1,4(R15)
        ADDC #0,2(R15)
        MOV #-1,R6
    THEN
    CMP #0,0(R15)
    S< IF
        XOR #-1,0(R15)
        ADD #1,0(R15)
        XOR #-1,R6
    THEN
                MOV 4(R15),R8
                MOV 2(R15),R11
                MOV @R15+,R12
                MOV #0,R5
                MOV #0,2(R15)
                MOV #0,0(R15)
                MOV #0,R10
                MOV #1,R9
    BEGIN       BIT R9,R12
        0<> IF  ADD R8,2(R15)
                ADDC R11,0(R15)
                ADDC R5,R10
        THEN    ADD R8,R8
                ADDC R11,R11
                ADDC R5,R5
                ADD R9,R9
    U>= UNTIL
    MOV R14,R11
    MOV @R15,R14
    MOV 2(R15),R12
        [THEN]

        [THEN]  ; endcase of software/hardware_MPY

    MOV #32,R5
    CMP #0,R10
    0= IF
        MOV R14,R10
        CALL #$4050
    ELSE
        CALL #$4058
    THEN
    MOV @R15+,0(R15)
    CMP #0,R6
    0<> IF
        XOR #-1,0(R15)
        XOR #-1,R14
        ADD #1,0(R15)
        ADDC #0,R14
        CMP #0,&$180E
        S< IF
            CMP #0,R10
            0<> IF
                SUB #1,0(R15)
                SUBC #0,R14
            THEN
        THEN
    THEN
    MOV #$40B6,R5
    MOV #$40C4,R6
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2VARIABLE
    [IF]
    : 2VARIABLE
    CREATE
    HI2LO
    ADD #4,&$1DC8
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2CONSTANT
    [IF]
    : 2CONSTANT
    CREATE
    , ,
    DOES>
    2@
    ;
    [THEN]

    [UNDEFINED] 2VALUE
    [IF]
    : 2VALUE
    CREATE , ,
    DOES>
    HI2LO
    MOV @R1+,R13
    BIT #$200,R2
    0= IF
        MOV #2@,R0
    THEN
    BIC #$200,R2
    MOV #2!,R0
    ENDCODE
    [THEN]


    [UNDEFINED] 2LITERAL
    [IF]
        CODE 2LITERAL
        BIS #$200,R2
        MOV #LITERAL,R0
        ENDCODE IMMEDIATE
    [THEN]


    [UNDEFINED] D.R
    [IF]
    : D.R
    >R SWAP OVER DABS <# #S ROT SIGN #>
    R> OVER - SPACES TYPE
    ;
    [THEN]

    RST_SET

; Complement to pass DOUBLE TESTS

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

    [UNDEFINED] CELLS
    [IF]
    CODE CELLS
    ADD R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DEPTH
    [IF]
    CODE DEPTH
    MOV R14,-2(R15)
    MOV #$1C80,R14
    SUB R15,R14
    RRA R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
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

    [UNDEFINED] 0=
    [IF]
    CODE 0=
    SUB #1,R14
    SUBC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] SOURCE
    [IF]
    CODE SOURCE
    SUB #4,R15
    MOV R14,2(R15)
    MOV &$1DC2,R14
    MOV &$1DC4,0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] >IN
    [IF]
    $1DC6 CONSTANT >IN
    [THEN]

    [UNDEFINED] 1+
    [IF]
    CODE 1+
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CHAR
    [IF]
    : CHAR
        $20 WORD 1+ C@
    ;
    [THEN]

    [UNDEFINED] [CHAR]
    [IF]
    : [CHAR]
        CHAR POSTPONE LITERAL
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] 2/
    [IF]
    CODE 2/
    RRA R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] INVERT
    [IF]
    CODE INVERT
    XOR #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] RSHIFT
    [IF]
    CODE RSHIFT
    MOV @R15+,R10
    AND #$1F,R14
    0<> IF
        BEGIN
            BIC #1,R2
            RRC R10
            SUB #1,R14
        0= UNTIL
    THEN
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] S>D
    [IF]
    : S>D
        DUP 0<
    ;
    [THEN]

    [UNDEFINED] 1-
    [IF]
    CODE 1-
    SUB #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] NEGATE
    [IF]
    CODE NEGATE
    XOR #-1,R14
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #$4032,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CHARS
    [IF]
    CODE CHARS
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
        0<> IF
            U< IF
                BEGIN
                    MOV.B @R9+,0(R8)
                    ADD #1,R8
                    SUB #1,R10
                0= UNTIL
                MOV @R13+,R0
            THEN
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
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DECIMAL
    [IF]
    CODE DECIMAL
    MOV #$0A,&$1DBE
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] BASE
    [IF]
    $1DBE CONSTANT BASE
    [THEN]

    [UNDEFINED] ( ; )
    [IF]
    : (
    ')' WORD DROP
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] .( ; "
    [IF]
    CODE .(        ; "
    MOV #0,&$1DC0
    COLON
    ')' WORD
    COUNT TYPE
    $20 $1DC0 !
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] CR
    [IF]
    DEFER CR

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]


 0 CONSTANT FALSE
-1 CONSTANT TRUE

VARIABLE VERBOSE
    FALSE VERBOSE !

VARIABLE ACTUAL-DEPTH
CREATE ACTUAL-RESULTS 20 CELLS ALLOT

: T{
    ;

: ->
    DEPTH DUP ACTUAL-DEPTH !
    ?DUP IF
        0 DO ACTUAL-RESULTS I CELLS + ! LOOP
    THEN ;

: }T

    DEPTH ACTUAL-DEPTH @ = IF
        DEPTH ?DUP IF
        0 DO
            ACTUAL-RESULTS I CELLS + @
            = 0= IF TRUE ABORT" INCORRECT RESULT" THEN
        LOOP
        THEN
    ELSE
        TRUE ABORT" WRONG NUMBER OF RESULTS"
    THEN ;

: TESTING
    SOURCE VERBOSE @
    IF DUP >R TYPE CR R> >IN !
    ELSE >IN ! DROP [CHAR] * EMIT
    THEN ;


DECIMAL

0 INVERT        CONSTANT 1SD
1SD 1 RSHIFT    CONSTANT MAX-INTD
MAX-INTD INVERT CONSTANT MIN-INTD
MAX-INTD 2/     CONSTANT HI-INT
MIN-INTD 2/     CONSTANT LO-INT


ECHO

TESTING interpreter and compiler reading double numbers, with/without prefixes

T{ 1. -> 1 0 }T
T{ -2. -> -2 -1 }T
T{ : RDL1 3. ; RDL1 -> 3 0 }T
T{ : RDL2 -4. ; RDL2 -> -4 -1 }T

VARIABLE OLD-DBASE
DECIMAL BASE @ OLD-DBASE !
T{ #12346789. -> 12346789. }T
T{ #-12346789. -> -12346789. }T
T{ $12aBcDeF. -> 313249263. }T
T{ $-12AbCdEf. -> -313249263. }T
T{ %10010110. -> 150. }T
T{ %-10010110. -> -150. }T
T{ BASE @ OLD-DBASE @ = -> TRUE }T

16 OLD-DBASE ! 16 BASE !
T{ #12346789. -> BC65A5. }T
T{ #-12346789. -> -BC65A5. }T
T{ $12aBcDeF. -> 12AbCdeF. }T
T{ $-12AbCdEf. -> -12ABCDef. }T
T{ %10010110. -> 96. }T
T{ %-10010110. -> -96. }T
T{ BASE @ OLD-DBASE @ = -> TRUE }T

DECIMAL
T{ : dnmp  #8327. $-2cbe. %011010111. ; dnmp -> 8327. -11454. 215. }T

TESTING 2CONSTANT

T{ 1 2 2CONSTANT 2C1 -> }T
T{ 2C1 -> 1 2 }T
T{ : CD1 2C1 ; -> }T
T{ CD1 -> 1 2 }T
T{ : CD2 2CONSTANT ; -> }T
T{ -1 -2 CD2 2C2 -> }T
T{ 2C2 -> -1 -2 }T
T{ 4 5 2CONSTANT 2C3 IMMEDIATE 2C3 -> 4 5 }T
T{ : CD6 2C3 2LITERAL ; CD6 -> 4 5 }T


1SD MAX-INTD 2CONSTANT MAX-2INT
0   MIN-INTD 2CONSTANT MIN-2INT
MAX-2INT 2/  2CONSTANT HI-2INT
MIN-2INT 2/  2CONSTANT LO-2INT

TESTING DNEGATE

T{ 0. DNEGATE -> 0. }T
T{ 1. DNEGATE -> -1. }T
T{ -1. DNEGATE -> 1. }T
T{ MAX-2INT DNEGATE -> MIN-2INT SWAP 1+ SWAP }T
T{ MIN-2INT SWAP 1+ SWAP DNEGATE -> MAX-2INT }T

TESTING D+ with small integers

T{  0.  5. D+ ->  5. }T
T{ -5.  0. D+ -> -5. }T
T{  1.  2. D+ ->  3. }T
T{  1. -2. D+ -> -1. }T
T{ -1.  2. D+ ->  1. }T
T{ -1. -2. D+ -> -3. }T
T{ -1.  1. D+ ->  0. }T

TESTING D+ with mid range integers

T{  0  0  0  5 D+ ->  0  5 }T
T{ -1  5  0  0 D+ -> -1  5 }T
T{  0  0  0 -5 D+ ->  0 -5 }T
T{  0 -5 -1  0 D+ -> -1 -5 }T
T{  0  1  0  2 D+ ->  0  3 }T
T{ -1  1  0 -2 D+ -> -1 -1 }T
T{  0 -1  0  2 D+ ->  0  1 }T
T{  0 -1 -1 -2 D+ -> -1 -3 }T
T{ -1 -1  0  1 D+ -> -1  0 }T
T{ MIN-INTD 0 2DUP D+ -> 0 1 }T
T{ MIN-INTD S>D MIN-INTD 0 D+ -> 0 0 }T

TESTING D+ with large double integers

T{ HI-2INT 1. D+ -> 0 HI-INT 1+ }T
T{ HI-2INT 2DUP D+ -> 1SD 1- MAX-INTD }T
T{ MAX-2INT MIN-2INT D+ -> -1. }T
T{ MAX-2INT LO-2INT D+ -> HI-2INT }T
T{ HI-2INT MIN-2INT D+ 1. D+ -> LO-2INT }T
T{ LO-2INT 2DUP D+ -> MIN-2INT }T

TESTING D- with small integers

T{  0.  5. D- -> -5. }T
T{  5.  0. D- ->  5. }T
T{  0. -5. D- ->  5. }T
T{  1.  2. D- -> -1. }T
T{  1. -2. D- ->  3. }T
T{ -1.  2. D- -> -3. }T
T{ -1. -2. D- ->  1. }T
T{ -1. -1. D- ->  0. }T

TESTING D- with mid-range integers

T{  0  0  0  5 D- ->  0 -5 }T
T{ -1  5  0  0 D- -> -1  5 }T
T{  0  0 -1 -5 D- ->  1  4 }T
T{  0 -5  0  0 D- ->  0 -5 }T
T{ -1  1  0  2 D- -> -1 -1 }T
T{  0  1 -1 -2 D- ->  1  2 }T
T{  0 -1  0  2 D- ->  0 -3 }T
T{  0 -1  0 -2 D- ->  0  1 }T
T{  0  0  0  1 D- ->  0 -1 }T
T{ MIN-INTD 0 2DUP D- -> 0. }T
T{ MIN-INTD S>D MAX-INTD 0 D- -> 1 1SD }T

TESTING D- with large integers

T{ MAX-2INT MAX-2INT D- -> 0. }T
T{ MIN-2INT MIN-2INT D- -> 0. }T
T{ MAX-2INT HI-2INT  D- -> LO-2INT DNEGATE }T
T{ HI-2INT  LO-2INT  D- -> MAX-2INT }T
T{ LO-2INT  HI-2INT  D- -> MIN-2INT 1. D+ }T
T{ MIN-2INT MIN-2INT D- -> 0. }T
T{ MIN-2INT LO-2INT  D- -> LO-2INT }T

TESTING D0< D0=

T{ 0. D0< -> FALSE }T
T{ 1. D0< -> FALSE }T
T{ MIN-INTD 0 D0< -> FALSE }T
T{ 0 MAX-INTD D0< -> FALSE }T
T{ MAX-2INT  D0< -> FALSE }T
T{ -1. D0< -> TRUE }T
T{ MIN-2INT D0< -> TRUE }T

T{ 1. D0= -> FALSE }T
T{ MIN-INTD 0 D0= -> FALSE }T
T{ MAX-2INT  D0= -> FALSE }T
T{ -1 MAX-INTD D0= -> FALSE }T
T{ 0. D0= -> TRUE }T
T{ -1. D0= -> FALSE }T
T{ 0 MIN-INTD D0= -> FALSE }T

TESTING D2* D2/

T{ 0. D2* -> 0. D2* }T
T{ MIN-INTD 0 D2* -> 0 1 }T
T{ HI-2INT D2* -> MAX-2INT 1. D- }T
T{ LO-2INT D2* -> MIN-2INT }T

T{ 0. D2/ -> 0. }T
T{ 1. D2/ -> 0. }T
T{ 0 1 D2/ -> MIN-INTD 0 }T
T{ MAX-2INT D2/ -> HI-2INT }T
T{ -1. D2/ -> -1. }T
T{ MIN-2INT D2/ -> LO-2INT }T

TESTING D< D=

T{  0.  1. D< -> TRUE  }T
T{  0.  0. D< -> FALSE }T
T{  1.  0. D< -> FALSE }T
T{ -1.  1. D< -> TRUE  }T
T{ -1.  0. D< -> TRUE  }T
T{ -2. -1. D< -> TRUE  }T
T{ -1. -2. D< -> FALSE }T
T{ 0 1   1. D< -> FALSE }T
T{ 1.  0 1  D< -> TRUE  }T
T{ 0 -1 1 -2 D< -> FALSE }T
T{ 1 -2 0 -1 D< -> TRUE  }T
T{ -1. MAX-2INT D< -> TRUE }T
T{ MIN-2INT MAX-2INT D< -> TRUE }T
T{ MAX-2INT -1. D< -> FALSE }T
T{ MAX-2INT MIN-2INT D< -> FALSE }T
T{ MAX-2INT 2DUP -1. D+ D< -> FALSE }T
T{ MIN-2INT 2DUP  1. D+ D< -> TRUE  }T
T{ MAX-INTD S>D 2DUP 1. D+ D< -> TRUE }T

T{ -1. -1. D= -> TRUE  }T
T{ -1.  0. D= -> FALSE }T
T{ -1.  1. D= -> FALSE }T
T{  0. -1. D= -> FALSE }T
T{  0.  0. D= -> TRUE  }T
T{  0.  1. D= -> FALSE }T
T{  1. -1. D= -> FALSE }T
T{  1.  0. D= -> FALSE }T
T{  1.  1. D= -> TRUE  }T

T{ 0 -1 0 -1 D= -> TRUE  }T
T{ 0 -1 0  0 D= -> FALSE }T
T{ 0 -1 0  1 D= -> FALSE }T
T{ 0  0 0 -1 D= -> FALSE }T
T{ 0  0 0  0 D= -> TRUE  }T
T{ 0  0 0  1 D= -> FALSE }T
T{ 0  1 0 -1 D= -> FALSE }T
T{ 0  1 0  0 D= -> FALSE }T
T{ 0  1 0  1 D= -> TRUE  }T

T{ MAX-2INT MIN-2INT D= -> FALSE }T
T{ MAX-2INT 0. D= -> FALSE }T
T{ MAX-2INT MAX-2INT D= -> TRUE }T
T{ MAX-2INT HI-2INT  D= -> FALSE }T
T{ MAX-2INT MIN-2INT D= -> FALSE }T
T{ MIN-2INT MIN-2INT D= -> TRUE }T
T{ MIN-2INT LO-2INT  D=  -> FALSE }T
T{ MIN-2INT MAX-2INT D= -> FALSE }T

TESTING 2LITERAL 2VARIABLE

T{ : CD3 [ MAX-2INT ] 2LITERAL ; -> }T
T{ CD3 -> MAX-2INT }T
T{ 2VARIABLE 2V1 -> }T
T{ 0. 2V1 2! -> }T
T{ 2V1 2@ -> 0. }T
T{ -1 -2 2V1 2! -> }T
T{ 2V1 2@ -> -1 -2 }T
T{ : CD4 2VARIABLE ; -> }T
T{ CD4 2V2 -> }T
T{ : CD5 2V2 2! ; -> }T
T{ -2 -1 CD5 -> }T
T{ 2V2 2@ -> -2 -1 }T
T{ 2VARIABLE 2V3 IMMEDIATE 5 6 2V3 2! -> }T
T{ 2V3 2@ -> 5 6 }T
T{ : CD7 2V3 [ 2@ ] 2LITERAL ; CD7 -> 5 6 }T
T{ : CD8 [ 6 7 ] 2V3 [ 2! ] ; 2V3 2@ -> 6 7 }T

TESTING DMAX DMIN

T{  1.  2. DMAX -> 2. }T
T{  1.  0. DMAX -> 1. }T
T{  1. -1. DMAX -> 1. }T
T{  1.  1. DMAX -> 1. }T
T{  0.  1. DMAX -> 1. }T
T{  0. -1. DMAX -> 0. }T
T{ -1.  1. DMAX -> 1. }T
T{ -1. -2. DMAX -> -1. }T

T{ MAX-2INT HI-2INT  DMAX -> MAX-2INT }T
T{ MAX-2INT MIN-2INT DMAX -> MAX-2INT }T
T{ MIN-2INT MAX-2INT DMAX -> MAX-2INT }T
T{ MIN-2INT LO-2INT  DMAX -> LO-2INT  }T

T{ MAX-2INT  1. DMAX -> MAX-2INT }T
T{ MAX-2INT -1. DMAX -> MAX-2INT }T
T{ MIN-2INT  1. DMAX ->  1. }T
T{ MIN-2INT -1. DMAX -> -1. }T


T{  1.  2. DMIN ->  1. }T
T{  1.  0. DMIN ->  0. }T
T{  1. -1. DMIN -> -1. }T
T{  1.  1. DMIN ->  1. }T
T{  0.  1. DMIN ->  0. }T
T{  0. -1. DMIN -> -1. }T
T{ -1.  1. DMIN -> -1. }T
T{ -1. -2. DMIN -> -2. }T

T{ MAX-2INT HI-2INT  DMIN -> HI-2INT  }T
T{ MAX-2INT MIN-2INT DMIN -> MIN-2INT }T
T{ MIN-2INT MAX-2INT DMIN -> MIN-2INT }T
T{ MIN-2INT LO-2INT  DMIN -> MIN-2INT }T

T{ MAX-2INT  1. DMIN ->  1. }T
T{ MAX-2INT -1. DMIN -> -1. }T
T{ MIN-2INT  1. DMIN -> MIN-2INT }T
T{ MIN-2INT -1. DMIN -> MIN-2INT }T

TESTING D>S DABS

T{  1234  0 D>S ->  1234 }T
T{ -1234 -1 D>S -> -1234 }T
T{ MAX-INTD  0 D>S -> MAX-INTD }T
T{ MIN-INTD -1 D>S -> MIN-INTD }T

T{  1. DABS -> 1. }T
T{ -1. DABS -> 1. }T
T{ MAX-2INT DABS -> MAX-2INT }T
T{ MIN-2INT 1. D+ DABS -> MAX-2INT }T

TESTING M+ M*/

T{ HI-2INT   1 M+ -> HI-2INT   1. D+ }T
T{ MAX-2INT -1 M+ -> MAX-2INT -1. D+ }T
T{ MIN-2INT  1 M+ -> MIN-2INT  1. D+ }T
T{ LO-2INT  -1 M+ -> LO-2INT  -1. D+ }T


: ?$8000 [ -3 2 / -2 = ] LITERAL IF 1. D- THEN ;

T{  5.  7 11 M*/ ->  3. }T
T{  5. -7 11 M*/ -> -3. ?$8000 }T
T{ -5.  7 11 M*/ -> -3. ?$8000 }T
T{ -5. -7 11 M*/ ->  3. }T
T{ MAX-2INT  8 16 M*/ -> HI-2INT }T
T{ MAX-2INT -8 16 M*/ -> HI-2INT DNEGATE ?$8000 }T
T{ MIN-2INT  8 16 M*/ -> LO-2INT }T
T{ MIN-2INT -8 16 M*/ -> LO-2INT DNEGATE }T
T{ MAX-2INT MAX-INTD MAX-INTD M*/ -> MAX-2INT }T
T{ MAX-2INT MAX-INTD 2/ MAX-INTD M*/ -> MAX-INTD 1- HI-2INT NIP }T
T{ MIN-2INT LO-2INT NIP 1+ DUP 1- NEGATE M*/ -> 0 MAX-INTD 1- }T
T{ MIN-2INT LO-2INT NIP 1- MAX-INTD M*/ -> MIN-INTD 3 + HI-2INT NIP 2 + }T
T{ MAX-2INT LO-2INT NIP DUP NEGATE M*/ -> MAX-2INT DNEGATE }T
T{ MIN-2INT MAX-INTD DUP M*/ -> MIN-2INT }T

TESTING D. D.R

MAX-2INT 71 73 M*/ 2CONSTANT DBL1
MIN-2INT 73 79 M*/ 2CONSTANT DBL2

: D>ASCII  ( D -- CADDR U )
   DUP >R <# DABS #S R> SIGN #>    ( -- CADDR1 U )
   HERE SWAP 2DUP 2>R CHARS DUP ALLOT MOVE 2R>
;

DBL1 D>ASCII 2CONSTANT "DBL1"
DBL2 D>ASCII 2CONSTANT "DBL2"

: DOUBLEOUTPUT
   CR ." You should see lines duplicated:" CR
   5 SPACES "DBL1" TYPE CR
   5 SPACES DBL1 D. CR
   8 SPACES "DBL1" DUP >R TYPE CR
   5 SPACES DBL1 R> 3 + D.R CR
   5 SPACES "DBL2" TYPE CR
   5 SPACES DBL2 D. CR
   10 SPACES "DBL2" DUP >R TYPE CR
   5 SPACES DBL2 R> 5 + D.R CR
;

T{ DOUBLEOUTPUT -> }T

TESTING 2ROT DU< (Double Number extension words)

T{ 1. 2. 3. 2ROT -> 2. 3. 1. }T
T{ MAX-2INT MIN-2INT 1. 2ROT -> MIN-2INT 1. MAX-2INT }T

T{  1.  1. DU< -> FALSE }T
T{  1. -1. DU< -> TRUE  }T
T{ -1.  1. DU< -> FALSE }T
T{ -1. -2. DU< -> FALSE }T
T{ 0 1   1. DU< -> FALSE }T
T{ 1.  0 1  DU< -> TRUE  }T
T{ 0 -1 1 -2 DU< -> FALSE }T
T{ 1 -2 0 -1 DU< -> TRUE  }T

T{ MAX-2INT HI-2INT  DU< -> FALSE }T
T{ HI-2INT  MAX-2INT DU< -> TRUE  }T
T{ MAX-2INT MIN-2INT DU< -> TRUE }T
T{ MIN-2INT MAX-2INT DU< -> FALSE }T
T{ MIN-2INT LO-2INT  DU< -> TRUE }T

TESTING 2VALUE

T{ 1111 2222 2VALUE 2VAL -> }T
T{ 2VAL -> 1111 2222 }T
T{ 3333 4444 TO 2VAL -> }T
T{ 2VAL -> 3333 4444 }T
T{ : TO-2VAL TO 2VAL ; 5555 6666 TO-2VAL -> }T
T{ 2VAL -> 5555 6666 }T


CR .( End of Double-Number word tests) CR
