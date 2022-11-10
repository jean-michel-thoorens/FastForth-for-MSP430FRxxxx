
; -----------------------------------
; PROG10K.4th for MSP_EXP430FR5994
; -----------------------------------

; load and compile 10kb (9 x RC52LCD)



    CODE ABORT_RC5TOLCD
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #401,R14
    COLON
    $0D EMIT
    ABORT" FastForth V4.1 please!"
    RST_RET
    ;

    ABORT_RC5TOLCD

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_SET 

    MARKER {RC5TOLCD}
    8 ALLOT




; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

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


    [UNDEFINED] CR
    [IF]
    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    CODE 20_US
    BEGIN
        MOV &{RC5TOLCD}+6,R9
        SUB #2,R9
        BEGIN
            MOV #0,R3
            SUB #1,R9
        0=  UNTIL
        MOV #0,R3
        SUB #1,R14
    0= UNTIL
    MOV @R15+,R14
    MOV @R1+,R13
    ENDCODE

    CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
    0= IF
        AND.B #$0F,R14
        MOV.B R14,&$222
        BIC.B #4,&$243
        MOV @R15+,R14
        MOV @R13+,R0
    THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
    ENDCODE

    CODE LCD_WRC
    BIS.B #2,&$243
BW1 SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
    COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US
    ;

    CODE LCD_WRF
    BIC.B #2,&$243
    GOTO BW1
    ENDCODE

    : LCD_CLEAR $01 LCD_WRF 100 20_us ;
    : LCD_HOME $02 LCD_WRF 100 20_us ;

    HDNCODE WDT_INT
    BIT.B #$20,&$240
    0= IF
        CMP #19,&$3D6
        U< IF
            ADD #1,&$3D6
        THEN
    ELSE
        BIT.B #$40,&$240
        0= IF
            CMP #3,&$3D6
            U>= IF
            SUB #1,&$3D6
            THEN
        THEN
    THEN
    RETI
    ENDCODE

    HDNCODE RC5_INT
    MOV #1778,R9
    MOV #14,R10
    BEGIN
      MOV #%1011100100,&$380
        RRUM    #1,R9
        MOV     R9,R8
        RRUM    #1,R8
        ADD     R9,R8
        BEGIN
            CMP R8,&$390
        U>= UNTIL
        BIT.B   #4,&$200
        ADDC    R11,R11
        MOV.B   &$200,&$208
        BIC.B   #4,&$20C
        SUB     #1,R10
    0<> WHILE
        ADD R9,R8
        BEGIN
            MOV &$390,R9
            CMP R8,R9
            U>= ?GOTO FW1
            BIT.B #4,&$20C
        0<> UNTIL
    REPEAT
    BIC #$30,&$380
    RLAM    #1,R11
    MOV.B   R11,R9
    RRUM    #2,R9
    BIT     #$4000,R11
    0= IF   BIS #$40,R9
    THEN
    RRUM    #3,R11
    XOR     @R1,R11
    BIT     #$400,R11
    0= ?GOTO FW2
    XOR #$400,0(R1)
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1DB6,2(R15)
    MOV #$10,&$1DB6
    MOV R9,0(R15)
    MOV #0,R14
    LO2HI
    LCD_CLEAR
    <# # #S #36 HOLD #>
    ['] LCD_WRC IS EMIT
    TYPE
    ['] EMIT >BODY IS EMIT
    HI2LO
    MOV @R15+,&$1DB6
    MOV @R15+,R14
FW1 BIC #$30,&$380
FW2 BIC #%1111_1000,0(R1)
    RETI
    ENDCODE

    HDNCODE STOP_R2L
    CMP #WDT_INT,&$FFEA
    0= IF
        BIC.B #4,&$20A
        BIC.B #4,&$20C
        MOV #0,&$3C0
        MOV #0,&$340
        MOV #0,&$342
        MOV #{RC5TOLCD},R10
        MOV #<#+$4C,-2(R10)
        MOV @R10+,&$1842
        MOV @R10+,&$FFEA
        MOV @R10+,&$FFDE
    THEN
    MOV @R1+,R0
    ENDCODE

    CODE STOP
BW1 CALL #STOP_R2L
    COLON
    ECHO
    ." type START to start RC5toLCD"
    ;

    HDNCODE INIT_R2L
    MOV #%10_1101_0100,&$3C0
    $1800 @ 16000 =
    [IF]
        MOV #1,&$3A0
        MOV #1,&$3E0
    [THEN]
    $1800 @ 24000 =
    [IF]
        MOV #2,&$3A0
        MOV #2,&$3E0
    [THEN]
        MOV #19,&$3D2
    MOV #%0110_0000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #%01_0001_0100,&$340
    MOV ##3276,&$352
    MOV #%10000,&$342
    CALL &{RC5TOLCD}
    CMP #$0E,R14
    0<> IF
        CMP #$0A,R14
        U>= ?GOTO BW1
    THEN
    CMP #4,R14
    0= ?GOTO BW1
    LO2HI
    #1000 20_US
    %011 TOP_LCD
    #205 20_US
    %011 TOP_LCD
    #5 20_US
    %011 TOP_LCD
    #2 20_US
    %010 TOP_LCD
    #2 20_US
    %00101000 LCD_WRF
    %1000 LCD_WRF
    LCD_CLEAR
    %0110 LCD_WRF
    %1100 LCD_WRF
    LCD_CLEAR
    HI2LO
    MOV @R1+,R0
    ENDCODE

    CODE START
    CMP #WDT_INT,&$FFEA
    0= IF
        MOV @R13+,R0
    THEN
    MOV #STOP_R2L,&{RC5TOLCD}-2
       MOV &$1842,&{RC5TOLCD}
       MOV #INIT_R2L,&$1842
    MOV &$FFEA,&{RC5TOLCD}+2
    MOV #WDT_INT,&$FFEA
    MOV &$FFDE,&{RC5TOLCD}+4
    MOV #RC5_INT,&$FFDE
    SUB #6,R15
    MOV R14,4(R15)
    MOV &$1800,2(R15)
    MOV #0,0(R15)
    MOV #200,R14
    CALL #<#+8
    MOV @R15,&{RC5TOLCD}+6
    ADD #4,R15
    MOV @R15+,R14
    CALL #INIT_R2L
    LO2HI
    ." RC5toLCD is running,"
    ."  Type STOP to quit."
    HI2LO
    MOV #ALLOT+8,R0
    ENDCODE

RST_RET 


