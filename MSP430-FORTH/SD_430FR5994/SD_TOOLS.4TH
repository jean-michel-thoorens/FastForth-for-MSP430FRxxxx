

; ---------------------------------------------------------------
; SD_TOOLS.4th for MSP_EXP430FR5994
; BASIC TOOLS for SD Card : DIR FAT SECTOR. CLUSTER.
; ---------------------------------------------------------------

    CODE ABORT_SD_TOOLS
    SUB #4,R15
    MOV R14,2(R15)
    [UNDEFINED] LOAD"   \ "
    [IF]
        MOV #-1,0(R15)
    [ELSE]
        MOV #0,0(R15)
    [THEN]
    MOV &$180A,R14
    SUB #400,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.0 please!"
    ABORT" Build FastForth with SD_CARD_LOADER addon!"
    RST_RET
    ;

    ABORT_SD_TOOLS

    [DEFINED] {SD_TOOLS} 
    [IF] {SD_TOOLS}
    [THEN]
    [UNDEFINED] {SD_TOOLS}
    [IF]
    MARKER {SD_TOOLS}

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] HERE [IF]
    CODE HERE
    MOV #BEGIN,R0
    ENDCODE
    [THEN]

    [UNDEFINED] + [IF]
    CODE +
    ADD @R15+,R14
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

    [UNDEFINED] -
    [IF]
    CODE -
    SUB @R15+,R14
    XOR #-1,R14
    ADD #1,R14
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

    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #$409E,R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
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
    PUSH &$1DB6
    MOV #$10,&$1DB6
    ADD @R15,R14
    LO2HI
    SWAP
    CR
    4 SPACES $10 0
    DO I 3 U.R  LOOP
    DO  CR
        I 4 U.R
        I $10 + I
        DO I C@ 3 U.R LOOP
        SPACE SPACE
        I $10 + I
        DO I C@ $7E MIN $20 MAX EMIT LOOP
    $10 +LOOP
    R> $1DB6 !
    ;
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE SECTOR.
BW1 MOV     R14,R9
    MOV     @R15,R10
    CALL    #RD_SECT
    COLON
    SPACE <# #S #> TYPE
    $1E00 $200 DUMP CR ;

    CODE CLUSTER.
BW2 BIT.B   #4,&$260
    0<> IF
        MOV #COLD,R0
    THEN
    MOV.B &$2012,R10
    MOV @R15,R9
    BEGIN
        RRA R10
    U< WHILE
        ADD R9,R9
        ADDC R14,R14
    REPEAT
    ADD     &$2010,R9
    MOV     R9,0(R15)
    ADDC    #0,R14
    GOTO    BW1
    ENDCODE

    CODE FAT
    SUB     #4,R15
    MOV     R14,2(R15)
    MOV     &$2008,0(R15)
    MOV     #0,R14
    GOTO    BW1
    ENDCODE

    CODE DIR
    SUB     #4,R15
    MOV     R14,2(R15)
    MOV     &$202C,0(R15)
    MOV     &$202E,R14
    CMP     #0,R14
    0<>     ?GOTO BW2
    CMP     #1,0(R15)
    0<>     ?GOTO BW2
    MOV     &$200E,0(R15)
    GOTO    BW1
    ENDCODE

    RST_SET 

    [THEN]

    ECHO
