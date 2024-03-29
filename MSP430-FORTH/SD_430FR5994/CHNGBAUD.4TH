
; ------------
; CHNGBAUD.4th for MSP_EXP430FR5994
; ------------

    CODE I2CTERM_ABORT
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

I2CTERM_ABORT

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] DUP [IF]
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

    [UNDEFINED] DROP [IF]
    CODE DROP
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] OVER [IF]
    CODE OVER
    MOV R14,-2(R15)
    MOV @R15,R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CR [IF]

    CODE CR
    MOV #[THEN],R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] 1+ [IF]
    CODE 1+
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] U/ [IF]
    CODE U/
    SUB #2,R15
    MOV #0,0(R15)
    CALL #<#+8
    MOV @R15,R14
    ADD #4,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] >R [IF]
    CODE >R
    PUSH R14
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] R> [IF]
    CODE R>
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] = [IF]
    CODE =
    SUB @R15+,R14
    0<> IF
        AND #0,R14
    ELSE
        XOR #-1,R14
    THEN
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] < [IF]
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

    [UNDEFINED] IF [IF]
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

    [UNDEFINED] ELSE [IF]
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

    [UNDEFINED] DO [IF]
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

    [UNDEFINED] CASE [IF]
    : CASE 0 ; IMMEDIATE

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
    0 DO
        POSTPONE THEN
    LOOP
    ; IMMEDIATE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

    [UNDEFINED] S_ [IF]
    CODE S_
    SUB #2,R15
    MOV R14,0(R15)
    MOV #$20,R14
    MOV #S"+10,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ESC [IF]
    CODE ESC
    CMP #0,&$1DB4
    0= IF MOV @R13+,R0
    THEN
    COLON
    $1B
    POSTPONE LITERAL
    POSTPONE EMIT
    POSTPONE S_
    POSTPONE TYPE
    ; IMMEDIATE
    [THEN]

    : BAD_MHz
    $20 DUP EMIT
            ABORT" only for 1, 2, 4, 8, 12, 16, 20, 24 MHz MCLK!"
    ;

    : OVER_BDS
    $20 DUP EMIT ESC [7m
                ." with MCLK = " $1800 @ 1000 U/ .
            ABORT" MHz ? don't dream!"
    ;

    : CHNGBAUD
    RST_RET
    ECHO
    ESC [8;42;80t
    41 0 DO CR LOOP
    ESC [H

    $1800 @ DUP >R
    ." target MCLK = " 1000 U/ . ." MHz" CR
    ." choose your baudrate:" CR
    ."   0 --> 6 MBds" CR
    ."   1 --> 5 MBds" CR
    ."   2 --> 4 MBds" CR
    ."   3 --> 3 MBds" CR
    ."   4 --> 1843200 Bds" CR
    ."   5 --> 921600 Bds" CR
    ."   6 --> 460800 Bds" CR
    ."   7 --> 230400 Bds" CR
    ."   8 --> 115200 Bds" CR
    ."   9 --> 57600 Bds" CR
    ."   A --> 38400 Bds" CR
    ."   B --> 19200 Bds" CR
    ."   C --> 9600 Bds" CR
    ."   D --> DMX interface (250000 Bds)" CR
    ."   M --> MIDI interface (31250 Bds)" CR
    ." other --> quit" CR
    ." your choice: "
    KEY
    CASE
    #'0' OF  ." 6 MBds"
            R> CASE
                #24000  OF $4  $0       ENDOF
                #20000  OF $3  $4900    ENDOF
                20000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'1' OF  ." 5 MBds"
            R> CASE
                #24000  OF $4  $EE00    ENDOF
                #20000  OF $4  $0       ENDOF
                20000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'2' OF  ." 4 MBds"
            R> CASE
                #24000  OF $6  $0       ENDOF
                #20000  OF $5  $0       ENDOF
                #16000  OF $4  $0       ENDOF
                16000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'3' OF  ." 3 MBds"
            R> CASE
                #24000  OF $8  $0       ENDOF
                #20000  OF $6  $D600    ENDOF
                #16000  OF $5  $4900    ENDOF
                #12000  OF $4  $0       ENDOF
                12000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'4' OF  ." 1843200 Bds"
            R> CASE
                #24000  OF $0D $0200    ENDOF
                #20000  OF $0A $DF00    ENDOF
                #16000  OF $8  $D600    ENDOF
                #12000  OF $6  $AA00    ENDOF
                #8000   OF $5  $9200    ENDOF
                8000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'5' OF  ." 921600 Bds"
            R> CASE
                #24000  OF $1  $00A1    ENDOF
                #20000  OF $1  $B751    ENDOF
                #16000  OF $11 $4A00    ENDOF
                #12000  OF $0D $0200    ENDOF
                #8000   OF $8  $D600    ENDOF
                #4000   OF $4  $4900    ENDOF
                4000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'6' OF  ." 460800 Bds"
            R> CASE
                #24000  OF $3  $0241    ENDOF
                #20000  OF $2  $92B1    ENDOF
                #16000  OF $2  $BB21    ENDOF
                #12000  OF $1  $00A1    ENDOF
                #8000   OF $11 $4A00    ENDOF
                #4000   OF $8  $D600    ENDOF
                #2000   OF $4  $4900    ENDOF
                2000 <
                IF OVER_BDS
                THEN BAD_MHz
            ENDCASE
        ENDOF
    #'7' OF  ." 230400 Bds"
            R> CASE
                #24000  OF $6  $2081    ENDOF
                #20000  OF $5  $EE61    ENDOF
                #16000  OF $4  $5551    ENDOF
                #12000  OF $3  $0241    ENDOF
                #8000   OF $2  $BB21    ENDOF
                #4000   OF $11 $4A00    ENDOF
                #2000   OF $8  $D600    ENDOF
                #1000   OF $4  $4900    ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'8' OF  ." 115200 Bds"
            R> CASE
                #24000  OF $0D $4901    ENDOF
                #20000  OF $0A $AD01    ENDOF
                #16000  OF $8  $F7A1    ENDOF
                #12000  OF $6  $2081    ENDOF
                #8000   OF $4  $5551    ENDOF
                #4000   OF $2  $BB21    ENDOF
                #2000   OF $11 $4A00    ENDOF
                #1000   OF $8  $D600    ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'9' OF  ." 57600 Bds"
            R> CASE
                #24000  OF $1A $D601    ENDOF
                #20000  OF $15 $00A1    ENDOF
                #16000  OF $11 $DD51    ENDOF
                #12000  OF $0D $4901    ENDOF
                #8000   OF $8  $F7A1    ENDOF
                #4000   OF $4  $5551    ENDOF
                #2000   OF $2  $BB21    ENDOF
                #1000   OF $11 $4A00    ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'A' OF  ." 38400 Bds"
            R> CASE
                #24000  OF $27 $0011    ENDOF
                #20000  OF $20 $BF01    ENDOF
                #16000  OF $1A $D601    ENDOF
                #12000  OF $13 $5581    ENDOF
                #8000   OF $0D $4901    ENDOF
                #4000   OF $6  $2081    ENDOF
                #2000   OF $3  $0241    ENDOF
                #1000   OF $1  $00A1    ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'B' OF  ." 19200 Bds"
            R> CASE
                #24000  OF $4E $0021    ENDOF
                #20000  OF $41 $D611    ENDOF
                #16000  OF $34 $4911    ENDOF
                #12000  OF $27 $0011    ENDOF
                #8000   OF $1A $D601    ENDOF
                #4000   OF $0D $4901    ENDOF
                #2000   OF $6  $2081    ENDOF
                #1000   OF $3  $0241    ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'C' OF  ." 9600 Bds"
            R> CASE
                #24000  OF $9C $0041    ENDOF
                #20000  OF $82 $2531    ENDOF
                #16000  OF $68 $D621    ENDOF
                #12000  OF $4E $0021    ENDOF
                #8000   OF $34 $4911    ENDOF
                #4000   OF $1A $D601    ENDOF
                #2000   OF $13 $4901    ENDOF
                #1000   OF $6  $2081    ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'D' OF  ." DMX interface (250000 Bds)"
            R> CASE
                #24000  OF $6  $1       ENDOF
                #20000  OF $5  $1       ENDOF
                #16000  OF $4  $1       ENDOF
                #12000  OF $3  $1       ENDOF
                #8000   OF $2  $1       ENDOF
                #4000   OF $10 $0       ENDOF
                #2000   OF $8  $0       ENDOF
                #1000   OF $4  $0       ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
    #'M' OF  ." MIDI interface (31250 Bds)"
            R> CASE
                #24000  OF $30 $1       ENDOF
                #20000  OF $28 $1       ENDOF
                #16000  OF $20 $1       ENDOF
                #12000  OF $18 $1       ENDOF
                #8000   OF $10 $1       ENDOF
                #4000   OF $8  $1       ENDOF
                #2000   OF $4  $1       ENDOF
                #1000   OF $2  $1       ENDOF
                BAD_MHz
            ENDCASE
        ENDOF
        ABORT" "
    ENDCASE
    $1804 !
    $1802 !
    CR ESC [7m
    ." Change baudrate in Teraterm, save its setup, then hit a key."
    ESC [0m
    CR
    KEY
    0 SYS
    ;

    CHNGBAUD
