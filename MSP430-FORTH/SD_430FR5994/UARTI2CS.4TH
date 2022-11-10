
; UARTI2CS.4th for MSP_EXP430FR5994

    CODE ABORT_UARTI2CS
    SUB #4,R15
    MOV R14,2(R15)
    MOV &$180E,R14
    BIT #$3C00,R14
    0<> IF MOV #0,R14 THEN
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #401,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.1 please!"
    ABORT" <-- Ouch! unexpected I2C_FastForth target!"
    RST_RET
    ;

    ABORT_UARTI2CS

    MARKER {UARTI2CS}
    16 ALLOT

    [UNDEFINED] = [IF]
    CODE =
    SUB @R15+,R14
    SUB #1,R14
    SUBC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] TSTBIT [IF]
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

    HDNCODE REMOVE_U2I
BW1
    [DEFINED] LEDS [IF]
    BIC.B #1,&$202
    BIC.B #1,&$204
    BIC.B #2,&$202
    BIC.B #2,&$204
    [THEN]
    CALL #I2CM_STOP
    BIS.B #6,&$263
    BIS.B #6,&$267
    MOV #0,&$3C0
    BIC.B #$20,&$20C
    BIC.B #$20,&$204
    BIC.B #$10,&$21A
    CMP #<#+$4C,&{UARTI2CS}-2
    0<> IF
        MOV #{UARTI2CS},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$183C
        MOV @R10+,&$1842
        MOV @R10+,&$1844
        MOV @R10+,&$FFF0
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    HDNCODE STOP_U2I
    CALL #I2CM_STOP
    MOV &{UARTI2CS},R0
    ENDCODE

    HDNCODE BACKGRND_U2I
    BIT #8,&$5CA
    0<> ?GOTO FW1
    BIT.B #$40,&$240
    0= IF
FW1     MOV #1,R14
        MOV #SYS+$0E,0(R1)
        GOTO BW1
    THEN
    BIC.B #$10,&$21C
    MOV #$0D,R12
    MOV #0,R11
    MOV.B &{UARTI2CS}+15,R8
    MOV &{UARTI2CS}+4,R0
    ENDCODE

    HDNCODE HARD_U2I
BW3 MOV &{UARTI2CS}+12,&$3C0
    MOV #4096,&$3D2
    MOV #$60,&$3C6
    MOV #4096,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20C
    BIS.B #$10,&$21A
    BIC.B #6,&$267
    BIC.B #6,&$263
    BIC.B #6,&I2CSM_IES
    [DEFINED] LEDS [IF]
    BIS.B #1,&$204
    BIS.B #2,&$204
    [THEN]
    CALL &{UARTI2CS}+2
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    MOV #ALLOT+8,0(R1)
    MOV @R1+,R0
    ENDCODE

    HDNCODE I2CM_START
    BIS.B   #4,&$265
    BIS     &{UARTI2CS}+10,R9
    BIS.B   #2,&$265
    MOV.B #8,R10
    BEGIN
        ADD.B R9,R9
        U< IF
            BIS.B #4,&$265
            BIC.B #2,&$265
            MOV R0,R0
        ELSE
            BIC.B #4,&$265
            BIC.B #2,&$265
            BIT.B #4,&$261
            0= IF
                BEGIN
                    BIT #2,&$5DC
                0<> UNTIL
                MOV.B #'c',&$5CE
                BEGIN
                    BIT.B #2,&$261
                0<> UNTIL
                BEGIN
                   BIC.B #6,&I2CSM_IFG
                   MOV R0,R0
                   MOV.B &{UARTI2CS}+14,R10
                   BEGIN
                      MOV #0,R3
                      SUB #1,R10
                   0= UNTIL
                   BIT.B #6,&I2CSM_IFG
                0= UNTIL
                ADD #2,R1
                MOV @R1,R0
            THEN
        THEN
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
    MOV @R1+,0(R1)
    MOV @R1+,R0
    ENDCODE

    HDNCODE U2I_TERM_INT
    ADD #4,R1
    BEGIN
        MOV.B &$5CC,R10
        ADD #1,R11
        CMP.B R12,R10
    0<> WHILE
        CMP ##84+1,R11
        U< IF
            MOV.B R10,$1CE4-3(R11)
        THEN
        CMP.B #4,R8
        0<> IF
            BEGIN
                BIT #2,&$5DC
            0<> UNTIL
            MOV.B R10,&$5CE
        THEN
        BEGIN
            BIT #1,&$5DC
        0<> UNTIL
    REPEAT
    CALL #ACCEPT+$26
    MOV.B R10,$1CE4-3(R11)
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
BW2
    MOV.B &$5CC,R12
    MOV.B R12,$1CE4-2(R11)
    PUSH R0
    MOV #0,R9
    CALL #I2CM_START
    0<> ?GOTO FW2
    [DEFINED] LEDS [IF]
    BIS.B #1,&$202
    [THEN]
    MOV #$1CE4-2,R11
    BEGIN
        MOV.B @R11,R9
        MOV.B #7,R10
        BEGIN
            ADD.B R9,R9
            U>= IF
                BIC.B #4,&$265
            ELSE
                BIS.B #4,&$265
            $3C00 ,
            THEN
            BIC.B #2,&$265
            MOV R0,R0
            BIS.B #2,&$265
            SUB #1,R10
        0= UNTIL
        ADD.B R9,R9
        U>= IF
            BIC.B #4,&$265
        ELSE
            BIS.B #4,&$265
            $3C00 ,
        THEN
        BIC.B #2,&$265
        BEGIN
            BIT.B #2,&$261
        0<> UNTIL
        BIS.B #2,&$265
        BIC.B #4,&$265
        BIC.B #2,&$265
        MOV R0,R0
        BIT.B #4,&$261
        BIS.B #2,&$265
    0= WHILE
        CMP.B @R11+,R12
    0= UNTIL
    THEN
    [DEFINED] LEDS [IF]
    BIC.B #1,&$202
    [THEN]
    GOTO FW1
    ENDCODE

    HDNCODE 500MS_INT
    ADD #4,R1
FW1
FW2
    PUSH R0
    BEGIN
        BIC.B #2,&$265
        MOV #1,R9
        CALL #I2CM_START
        0<> IF
            CALL #I2CM_STOP
            MOV.B #'.',&$5CE
            MOV.B #-1,&{UARTI2CS}+15
            MOV #ACCEPT+$1C,R0
        THEN
        CMP.B #-1,R8
        0= IF
            MOV.B #1,&{UARTI2CS}+15
            MOV.B #$0D,&$5CE
            BEGIN
                BIT #2,&$5DC
            0<> UNTIL
            MOV.B #$0A,&$5CE
        THEN
        [DEFINED] LEDS [IF]
        BIS.B #2,&$202
        [THEN]
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
            0<> WHILE
                CMP.B #8,R9
            U>= WHILE
                BIS.B #4,&$265
                BIC.B #2,&$265
                BEGIN
                    BIT.B #2,&$261
                0<> UNTIL
                BIS.B #2,&$265
                CMP.B #4,R8
                0<> IF
                    BEGIN
                        BIT #2,&$5DC
                    0<> UNTIL
                    MOV.B R9,&$5CE
                THEN
            REPEAT
                CMP.B #4,R9
                U>= IF
                   MOV.B R9,R8
                   MOV.B R8,&{UARTI2CS}+15
                   BIS.B #4,&$265
                THEN
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
        BIC.B #2,&$265
        CALL #KEY+8
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
        MOV.B #0,R8
    REPEAT
    CALL #I2CM_STOP
    [DEFINED] LEDS [IF]
    BIC.B #2,&$202
    [THEN]
    CMP.B #0,R9
    0= IF
        MOV #ACCEPT+$1C,R0
    THEN
    CALL #KEY+8
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
    CALL #ACCEPT+$26
    MOV #0,R11
    GOTO BW2
    ENDCODE

    CODE START_U2I
    SUB #2,R15
    MOV R14,0(R15)
    COLON
    $0D EMIT $0A EMIT
    ." Connect to I2C_SLAVE at @"
    . $08 EMIT
     ." , TERATERM(Alt-B) "
    ." or I2C_MASTER(SW1) to quit..."
    HI2LO
    MOV @R1+,R13
    BEGIN
        BIT #1,&$5CA
    0= UNTIL
    CMP #<#+$4C,&{UARTI2CS}-2
    0= IF
        MOV #REMOVE_U2I,&{UARTI2CS}-2
        MOV &$183C,&{UARTI2CS}
        MOV #STOP_U2I,&$183C
        MOV &$1842,&{UARTI2CS}+2
        MOV #HARD_U2I,&$1842
        MOV &$1844,&{UARTI2CS}+4
        MOV #BACKGRND_U2I,&$1844
        MOV &$FFF0,&{UARTI2CS}+6
        MOV #U2I_TERM_INT,&$FFF0
        MOV &$FFDE,&{UARTI2CS}+8
        MOV #500MS_INT,&$FFDE
        MOV R14,&{UARTI2CS}+10
        $180E $4000 TSTBIT
        [IF]   MOV #$0194,&{UARTI2CS}+12
        [ELSE] MOV #$0114,&{UARTI2CS}+12
        [THEN]
        $1800 @ 24000 =
        [IF]   MOV #116,&{UARTI2CS}+14
        [ELSE] $1800 @ 16000 =
          [IF]   MOV #76,&{UARTI2CS}+14
          [ELSE] MOV #36,&{UARTI2CS}+14
          [THEN]
        [THEN]
    THEN
    MOV #0,R14
    GOTO BW3
    ENDCODE

RST_SET ECHO

#18 START_U2I
