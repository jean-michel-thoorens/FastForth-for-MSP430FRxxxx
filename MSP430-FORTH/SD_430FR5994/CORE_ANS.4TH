
    CODE ABORT_CORE_ANS
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    ;

    ABORT_CORE_ANS

    [UNDEFINED] BC!
    [IF]
    CODE BC!
    BIC @R15+,0(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] BS!
    [IF]
    CODE BS!
    BIS @R15+,0(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    $8000 $180E BC!

    RST_RET

; ----------------------------------
; CORE_ANS.4th for MSP_EXP430FR5994
; ----------------------------------

    MARKER {CORE_ANS}

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #$4032,R0
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

    [UNDEFINED] EXIT
    [IF]
    CODE EXIT
    MOV @R1+,R13
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

    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    PUSH R14
    MOV @R15,R14
    MOV @R1+,0(R15)
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

    [UNDEFINED] NIP
    [IF]
    CODE NIP
    ADD #2,R15
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

    [UNDEFINED] C!
    [IF]
    CODE C!
    MOV.B @R15+,0(R14)
    ADD #1,R15
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] C,
    [IF]
    CODE C,
    MOV &$1DC8,R10
    MOV.B R14,0(R10)
    ADD #1,&$1DC8
    MOV @R15+,R14
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

    [UNDEFINED] 0<>
    [IF]
    CODE 0<>
    SUB #1,R14
    SUBC R14,R14
    XOR #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 0<
    [IF]
    CODE 0<
BW1 ADD R14,R14
    SUBC R14,R14
    XOR #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]


    [UNDEFINED] S>D
    [IF]
    : S>D
    DUP 0<
    ;
    [THEN]

    [UNDEFINED] =
    [IF]
    CODE =
    SUB @R15+,R14
    SUB #1,R14
    SUBC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] U<
    [IF]

    CODE U<
    SUB @R15+,R14
    U< ?GOTO FW1
    0<> IF
BW1 MOV #-1,R14
    THEN
    MOV @R13+,R0
    ENDCODE

    CODE U>
    SUB @R15+,R14
    U< ?GOTO BW1
FW1 AND #0,R14
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

    [UNDEFINED] J
    [IF]
    CODE J
    SUB #2,R15
    MOV R14,0(R15)
    MOV 4(R1),R14
    SUB 6(R1),R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] UNLOOP
    [IF]
    CODE UNLOOP
    ADD #4,R1
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] LEAVE
    [IF]
    CODE LEAVE
    MOV &$1DC8,R10
    MOV #UNLOOP,0(R10)
    MOV #$40B2,2(R10)
    ADD #6,&$1DC8
    ADD #2,&$1C00
    ADD #4,R10
    MOV &$1C00,R9
    MOV R10,0(R9)
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] AND
    [IF]
    CODE AND
    AND @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] OR
    [IF]
    CODE OR
    BIS @R15+,R14
    AND #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] XOR
    [IF]
    CODE XOR
    XOR @R15+,R14
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

    [UNDEFINED] 1-
    [IF]
    CODE 1-
    SUB #1,R14
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

    [UNDEFINED] NEGATE
    [IF]
    CODE NEGATE
    XOR #-1,R14
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] ABS
    [IF]
    CODE ABS
    CMP #0,R14
    0>= IF
        MOV @R13+,R0
    THEN
    MOV #NEGATE,R0
    ENDCODE
    [THEN]

    [UNDEFINED] LSHIFT
    [IF]
    CODE LSHIFT
    MOV @R15+,R10
    AND #$1F,R14
    0<> IF
        BEGIN
            ADD R10,R10
            SUB #1,R14
        0= UNTIL
    THEN
    MOV R10,R14
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
    S< ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2*
    [IF]
    CODE 2*
    ADD R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 2/
    [IF]
    CODE 2/
    RRA R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    RST_SET

    CODE TSTBIT
    MOV @R15+,R9
    AND @R9,R14
    MOV @R13+,R0
    ENDCODE

    $180E 1 TSTBIT
    RST_RET

    [IF]
    CODE UM*
    MOV @R15,&$4C0
BW1 MOV R14,&$4C8
    MOV &$4E4,0(R15)
    MOV &$4E6,R14
    MOV @R13+,R0
    ENDCODE

    CODE M*
    MOV @R15,&$4C2
    GOTO BW1
    ENDCODE

    [ELSE]  ; MSP430FRxxxx with hardware_MPY
        [UNDEFINED] M* [IF]
    CODE M*
    MOV @R15,R12
    CMP #0,R12
    S< IF
        XOR #-1,0(R15)
        ADD #1,0(R15)
    THEN
    XOR R14,R12
    CMP #0,R14
    S< IF
        XOR #-1,R14
        ADD #1,R14
    THEN
    PUSHM #2,R13
    LO2HI
    UM*
    HI2LO
    POPM #2,R13
    CMP #0,R12
    S< IF
        XOR #-1,0(R15)
        XOR #-1,R14
        ADD #1,0(R15)
        ADDC #0,R14
    THEN
    MOV @R13+,R0
    ENDCODE
        [THEN]
    [THEN]  ;  endof hardware_MPY


    [UNDEFINED] UM/MOD
    [IF]
    CODE UM/MOD
    PUSH #DROP
    MOV #$403E,R0
    ENDCODE
    [THEN]



    $180E @ 0<  ; test the switch: $8000 / SYMETRIC DIVISION
    [IF]
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
        PUSHM  #2,R12
        CALL #$403E
        MOV @R15+,R14
        POPM  #2,R12
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
    [ELSE]
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
        PUSHM  #2,R12
        CALL #$403E
        MOV @R15+,R14
        POPM  #2,R12
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

    [UNDEFINED] *
    [IF]
    : *
    M* DROP
    ;
    [THEN]

    [UNDEFINED] /MOD
    [IF]
    : /MOD
    >R DUP 0< R>
        [ $180E @ 0< ]
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    ;
    [THEN]

    [UNDEFINED] /
    [IF]
    : /
    >R DUP 0< R>
        [ $180E @ 0< ]
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    NIP
    ;
    [THEN]

    [UNDEFINED] MOD
    [IF]
    : MOD
    >R DUP 0< R>
        [ $180E @ 0< ]
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    DROP
    ;
    [THEN]

    [UNDEFINED] */MOD
    [IF]
    : */MOD
    >R M* R>
        [ $180E @ 0< ]
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    ;
    [THEN]

    [UNDEFINED] */
    [IF]
    : */
    >R M* R>
        [ $180E @ 0< ]
        [IF]    FM/MOD
        [ELSE]  SM/REM
        [THEN]
    NIP
    ;
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

    [UNDEFINED] R@
    [IF]
    CODE R@
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] TUCK
    [IF]
    : TUCK SWAP OVER ;
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
    MOV R14,-2(R15)
    MOV @R15,-4(R15)
    SUB #4,R15
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

    [UNDEFINED] ALIGNED
    [IF]
    CODE ALIGNED
    BIT #1,R14
    ADDC #0,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] ALIGN
    [IF]
    CODE ALIGN
    BIT #1,&$1DC8
    ADDC #0,&$1DC8
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CHARS
    [IF]
    CODE CHARS
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CHAR+
    [IF]
    CODE CHAR+
    ADD #1,R14
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

    [UNDEFINED] CELL+
    [IF]
    CODE CELL+
    ADD #2,R14
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

    [UNDEFINED] +!
    [IF]
    CODE +!
    ADD @R15+,0(R14)
    MOV @R15+,R14
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

    [UNDEFINED] FILL
    [IF]
    CODE FILL
    MOV @R15+,R9
    MOV @R15+,R10
    CMP #0,R9
    0<> IF
        BEGIN
            MOV.B R14,0(R10)
            ADD #1,R10
            SUB #1,R9
        0= UNTIL
    THEN
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] HEX
    [IF]
    CODE HEX
    MOV #$10,&$1DBE
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

    [UNDEFINED] (   ; )
    [IF]
    : (
    ')' WORD DROP
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] .(  ; "
    [IF]
    CODE .(         ; "
    MOV #0,&$1DC0
    COLON
    ')' WORD
    COUNT TYPE
    HI2LO
    MOV #$20,&$1DC0
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] EXECUTE
    [IF]
    CODE EXECUTE
    PUSH R14
    MOV @R15+,R14
    MOV @R1+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] EVALUATE
    [IF]
    CODE EVALUATE
    MOV #$1DC2,R9
    MOV @R9+,R12
    MOV @R9+,R11
    MOV @R9+,R10
    PUSHM #4,R13
    LO2HI
    [ ' \ 8 + , ]
    HI2LO
    MOV @R1+,&$1DC6
    MOV @R1+,&$1DC4
    MOV @R1+,&$1DC2
    MOV @R1+,R13
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] RECURSE
    [IF]
    CODE RECURSE
    MOV &$1DC8,R9
    MOV &$1DB8,0(R9)
    ADD #2,&$1DC8
    MOV @R13+,R0
    ENDCODE IMMEDIATE
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

    [UNDEFINED] STATE
    [IF]
    $1DBC CONSTANT STATE
    [THEN]

    [UNDEFINED] BASE
    [IF]
    $1DBE  CONSTANT BASE
    [THEN]

    [UNDEFINED] >IN
    [IF]
    $1DC6 CONSTANT >IN
    [THEN]

    [UNDEFINED] PAD
    [IF]
    $1CE4 CONSTANT PAD
    [THEN]

    [UNDEFINED] BL
    [IF]
    $20 CONSTANT BL
    [THEN]

    [UNDEFINED] SPACE
    [IF]
    : SPACE
    $20 EMIT ;
    [THEN]

    [UNDEFINED] SPACES
    [IF]
    : SPACES
    BEGIN
        ?DUP
    WHILE
        $20 EMIT
        1-
    REPEAT
    ;
    [THEN]

    [UNDEFINED] DEFER
    [IF]
    : DEFER
    CREATE
    HI2LO
    MOV #$4030,-4(R10)
    MOV #$40B4,-2(R10)
    MOV @R1+,R13
    MOV @R13+,R0
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

    [UNDEFINED] TO
    [IF]
    CODE TO
    BIS #$200,R2
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] VALUE
    [IF]
    : VALUE
    CREATE ,
    DOES>
    HI2LO
    MOV @R1+,R13
    BIT #$200,R2
    0= IF
        MOV @R14,R14
        MOV @R13+,R0
    THEN
    BIC #$200,R2
    MOV #!,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CASE
    [IF]

    : CASE 0
    ; IMMEDIATE

    : OF
    1+
    >R
    POSTPONE OVER POSTPONE =
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
    0 DO POSTPONE THEN
    LOOP
    ; IMMEDIATE
    [THEN]

    RST_SET

    ECHO
; CORE_ANS.4th for MSP_EXP430FR5994 is loaded

