
; ---------------------------------------------------------
; UARTI2CS.4th for MSP_EXP430FR5994
; ---------------------------------------------------------

    CODE ABORT_UARTI2CS
    SUB #4,R15
    MOV R14,2(R15)
    MOV &$180E,R14
    BIT #$3C00,R14
    0<> IF MOV #0,R14 THEN
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    ABORT" <-- Ouch! unexpected I2C_FastForth target!"
    RST_RET
    ;

    ABORT_UARTI2CS

    MARKER {UARTI2CS}
    10 ALLOT

    [UNDEFINED] TSTBIT  
    [IF]
    CODE TSTBIT
    MOV @R15+,R9
    AND @R9,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    HDNCODE I2CM_STOP
    BIS.B #2,&$265
    MOV R0,R0
    BIS.B #4,&$265
    MOV R0,R0
    BIC.B #2,&$265
    MOV R0,R0
    BIC.B #4,&$265
    MOV @R1+,R0
    ENDCODE

    CODE REMOVE_U2I
BW1
    BIC.B #1,&$202
    BIC.B #1,&$204
    BIC.B #2,&$202
    BIC.B #2,&$204
    CALL #I2CM_STOP
    MOV #6,R10
    BIC.B R10,&$265
    BIS.B R10,&$263
    BIS.B R10,&$267
    MOV #0,&$3C0
    BIC.B #$80,&$20C
    BIC.B #$80,&$204
    BIC.B #$40,&$21A
    CMP #$4082,&{UARTI2CS}-2
    0<> IF
        MOV #{UARTI2CS},R10
        MOV #$4082,-2(R10)
        MOV @R10+,&$183E
        MOV @R10+,&$1840
        MOV @R10+,&$FFF0
        MOV @R10+,&$FFDE
    THEN
    MOV #1,R14
    MOV #$4186+4,R0
    ENDCODE

    HDNCODE I2CM_START
    BIS.B   #4,&$265
    BIS.B   &{UARTI2CS}+8,R9
    MOV R0,R0
    BIS.B   #2,&$265
    MOV.B #8,R10
    BEGIN
        ADD.B R9,R9
        U>= IF
            BIC.B #4,&$265
        ELSE
            BIS.B #4,&$265
        THEN
        BIC.B #2,&$265
        BIT.B #4,&$261
        BIS.B #2,&$265
        0= IF
            BIT.B #4,&$265
            0= IF
                BIS.B #6,&$265
                BIC.B #6,&I2CSM_IES
                BEGIN
                    BIT.B #6,&I2CSM_IFG
                    BIC.B #6,&I2CSM_IFG
                    0<> IF
                        MOV #9,R10
                    ELSE
                        $3C00 ,
                        $3C00 ,
                    THEN
                SUB #1,R10
                0= UNTIL
                ADD #2,R1
                MOV @R1+,R0
            THEN
        THEN
        SUB #1,R10
    0= UNTIL
    BIC.B #4,&$265
    BIC.B #2,&$265
    BEGIN
        BIT.B #2,&$261
    0<> UNTIL
    BIT.B #4,&$261
    BIS.B #2,&$265
    MOV @R1+,0(R1)
    MOV @R1+,R0
    ENDCODE


    HDNCODE U2I_TERM_INT
    ADD #4,R1
    BEGIN
        MOV.B &$5CC,R8
        MOV.B R8,$1CE4(R11)
        ADD #1,R11
        CMP.B R8,R12
    0<> WHILE
        CMP #4,R10
        0<> IF
            BEGIN
                BIT #2,&$5DC
            0<> UNTIL
            MOV.B R8,&$5CE
        THEN
        BEGIN
            BIT #1,&$5DC
        0<> UNTIL
    REPEAT
    CALL #ACCEPT+$2A
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
BW2
    MOV.B &$5CC,R12
    MOV.B R12,$1CE4(R11)
    PUSH R0
    MOV #0,R9
    CALL #I2CM_START
    0<> ?GOTO FW2
    BIS.B #1,&$202
    MOV #$1CE4,R8
    BEGIN
        MOV.B @R8,R9
        MOV.B #8,R10
        BEGIN
            ADD.B R9,R9
            U>= IF
                BIC.B #4,&$265
            ELSE
                BIS.B #4,&$265
            THEN
            BIC.B #2,&$265
            BEGIN
                BIT.B #2,&$261
            0<> UNTIL
            BIS.B #2,&$265
            SUB #1,R10
        0= UNTIL
        BIC.B #4,&$265
        BIC.B #2,&$265
        BEGIN
            BIT.B #2,&$261
        0<> UNTIL
        BIT.B #4,&$261
        BIS.B #2,&$265
    0= WHILE
        CMP.B @R8+,R12
    0= UNTIL
    THEN
    BIC.B #1,&$202
    GOTO FW1
    ENDCODE

    HDNCODE 500MS_INT
    ADD #4,R1
FW1
FW2
    PUSH R0
    BEGIN
        BIT #8,&$5CA
        0<> ?GOTO BW1
        BIT.B #$20,&$240
        0= ?GOTO BW1
        BIC.B #2,&$265
        MOV #1,R9
            CALL #I2CM_START
        0<> IF
            CALL #I2CM_STOP
            MOV #'.',&$5CE
            MOV #$4000,R0
        THEN
        BIS.B #2,&$202
        BEGIN
            BEGIN
                BIC.B #4,&$265
                MOV.B #8,R10
                BEGIN
                    BIC.B #2,&$265
                    BIT.B #4,&$261
                    BIS.B #2,&$265
                    ADDC.B R9,R9
                    SUB #1,R10
                0= UNTIL
                CMP.B #-1,R9
                0= IF
                    MOV #2,R9
                THEN
                CMP.B #8,R9
            U>= WHILE
                BIS.B #4,&$265
                BIC.B #2,&$265
                BEGIN
                    BIT.B #2,&$261
                0<> UNTIL
                BIS.B #2,&$265
                CMP.B #4,&{UARTI2CS}+9
                0<> IF
                    BEGIN
                        BIT #2,&$5DC
                    0<> UNTIL
                    MOV.B R9,&$5CE
                THEN
            REPEAT
            CMP.B #4,R9
            U>= IF
                MOV.B R9,&{UARTI2CS}+9
                BIS.B #4,&$265
            THEN
            BIC.B #2,&$265
            BEGIN
                BIT.B #2,&$261
            0<> UNTIL
            BIT.B #4,&$261
            BIS.B #2,&$265
        0<> UNTIL
        CMP.B #2,R9
    U>= WHILE
        0= IF
            MOV.B #0,&{UARTI2CS}+9
            CALL #KEY+$8
            BEGIN
                BIC #1,&$5DC
                MOV &$1800,R9
               BEGIN MOV #65,R10
                   BEGIN SUB #1,R10
                   0= UNTIL
                   SUB #1,R9
               0= UNTIL
                BIT #1,&$5DC
            0= UNTIL
        THEN    
    REPEAT
    CALL #I2CM_STOP
    BIC.B #2,&$202
    CMP.B #0,R9
    0= IF
        MOV #$4000,R0
    THEN
    CALL #KEY+$8
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
    CALL #ACCEPT+$2A
    MOV #0,R11
    GOTO BW2
    ENDCODE

    HDNCODE SLEEP_U2I
    $180E $4000 TSTBIT
    [IF]    MOV #%1_1001_0100,&$3C0 ; if ACLK=LFXTAL
    [ELSE]  MOV #%1_0001_0100,&$3C0 ; if ACLK=VLO
    [THEN]
    MOV.B &{UARTI2CS}+9,R10
    MOV #$0D,R12
    MOV #0,R11
    BIC #$40,&$21C
    MOV &{UARTI2CS}+2,R0
    ENDCODE

    HDNCODE INIT_U2I
    MOV #4096,&$3D2
    MOV #$60,&$3C6
    MOV #4095,&$3D6
    BIS.B #$80,&$204
    BIS.B #$80,&$20C
    BIS.B #$40,&$21A  
    BIC.B #6,&$267
    BIC.B #6,&$263
    BIS.B #1,&$204
    BIS.B #2,&$204
    CALL &{UARTI2CS}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    BIS.B #$40,&$21C
    MOV #ALLOT+$8,R0
    ENDCODE

    : UARTI2CS
    $0D EMIT $0A EMIT
    HI2LO
    MOV @R1+,R13
    BEGIN
        BIT #1,&$5CA
    0= UNTIL
    CMP #$4082,&{UARTI2CS}-2
    0= IF
        MOV #REMOVE_U2I,&{UARTI2CS}-2
        MOV &$183E,&{UARTI2CS}
        MOV &$1840,&{UARTI2CS}+2
        MOV &$FFF0,&{UARTI2CS}+4
        MOV &$FFDE,&{UARTI2CS}+6
        MOV R14,&{UARTI2CS}+8
    THEN
    MOV #0,R14
    MOV #INIT_U2I,&$183E
    MOV #SLEEP_U2I,&$1840
    MOV #U2I_TERM_INT,&$FFF0
    MOV #500MS_INT,&$FFDE
    MOV #INIT_U2I,R0
    ENDCODE

    RST_SET ECHO    

    $12 UARTI2CS   ; TERATERM(Alt-B) or USB_to_I2C_bridge(SW2) to quit
