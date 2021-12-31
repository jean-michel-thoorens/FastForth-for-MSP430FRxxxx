
; ---------------------------------
; FF_SPECS.4th for MSP_EXP430FR5994
; ---------------------------------

    CODE ABORT_FF_SPECS
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    RST_RET
    ;

    ABORT_FF_SPECS

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

    [UNDEFINED] DROP
    [IF]
    CODE DROP
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
    [THEN]
    
    [UNDEFINED] WHILE
    [IF]
    : WHILE
    POSTPONE IF SWAP
    ; IMMEDIATE
    [THEN]
    
    [UNDEFINED] REPEAT
    [IF]
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

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #$4032,R0
    ENDCODE
    [THEN]

    [UNDEFINED] C@
    [IF]
    CODE C@
    MOV.B @R14,R14
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
            SUB #1,R14
        0= UNTIL
        MOV @R1+,R13
    THEN
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

    [UNDEFINED] UM/MOD
    [IF]
    CODE UM/MOD
    PUSH #DROP
    MOV #$403E,R0
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

    [UNDEFINED] CR
    [IF]

    CODE CR
    MOV #$40B4,R0
    ENDCODE
    
    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR

    [THEN]

    : WORDS
    $1CE4
    $180C @ 2*
    MOVE
    BEGIN
        0 DUP
        $180C @ 2* 0
            DO
            DUP I $1CE4 + @
                U< IF
                    DROP DROP
                    I DUP $1CE4 + @
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
        $10 R> - SPACES
    REPEAT
    DROP
    ;

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

    [UNDEFINED] S_
    [IF]
    CODE S_
    MOV #0,&$1DC0
    COLON
    $401E ,
    $20 WORD
    HI2LO
    MOV.B @R14,R14
    ADD #1,R14
    BIT #1,R14
    ADDC R14,&$1DC8
    MOV @R15+,R14
    MOV @R1+,R13
    MOV #$20,&$1DC0
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ESC
    [IF]
    CODE ESC
    CMP #0,&$1DBC
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

    [DEFINED] FORTH
    [IF]
    CODE BODY>SQNFA
    SUB #2,R15
    SUB #4,R14
    MOV R14,R8
    MOV R8,R9
    BEGIN
        SUB #2,R9
        MOV R9,0(R15)
        MOV.B @R9+,R14
        RRA R14
        MOV R14,R10       
        BIT #1,R10
        0= IF         
            ADD #1,R10
        THEN
        ADD R9,R10
        CMP R10,R8
    0<> WHILE
        MOV @R15,R9
    REPEAT
    MOV R9,0(R15)
    MOV @R13+,R0
    ENDCODE
    [THEN]

    : SPECS
    RST_RET
    ECHO
    ESC [8;42;80t

    ESC [7m
    CR ." FastForth V"
    $180A @         
    0 <# # $08 HOLD # '.' HOLD #S #> TYPE
    ."  for MSP430FR"
    HERE
    $1A04 @
    CASE

    $8102   OF  ." 5738,"   $C200   ENDOF
    $8103   OF  ." 5739,"   $C200   ENDOF
    $810D   OF  ." 5986,"   $4400   ENDOF
    $8160   OF  ." 5948,"   $4400   ENDOF
    $8169   OF  ." 5969,"   $4400   ENDOF
    $81A8   OF  ." 6989,"   $4400   ENDOF
    $81F0   OF  ." 4133,"   $C400   ENDOF
    $8240   OF  ." 2433,"   $C400   ENDOF
    $825D   OF  ." 5972,"   $4400   ENDOF
    $82A1   OF  ." 5994,"   $4000   ENDOF
    $82A6   OF  ." 5962,"   $4000   ENDOF
    $830C   OF  ." 2355,"   $8000   ENDOF
    $830D   OF  ." 2353,"   $C000   ENDOF
    $831E   OF  ." 2155,"   $8000   ENDOF
    $831D   OF  ." 2153,"   $C000   ENDOF
    $832A   OF  ." 2476,"   $8000   ENDOF
    $832B   OF  ." 2475,"   $8000   ENDOF
    $833C   OF  ." 2633,"   $C400   ENDOF
    $833D   OF  ." 2533,"   $C400   ENDOF
    ABORT" xxxx <-- unrecognized device!"
    ENDCASE
    ['] ['] DUP @ $1284 =
    IF ."  DTC=1," DROP
    ELSE 2 + @ $1284 =
        IF ."  DTC=2,"
        ELSE ."  DTC=3,"
        THEN
    THEN
    $20 EMIT 
    $180C @ U. $08 EMIT
    ." -Entry word set, "
    $1800 @ 0 1000 UM/MOD U.
    ?DUP IF $08 EMIT ',' EMIT U.
    THEN ." MHz, "
    - U. ." bytes"
    ESC [0m

    CR
    ." /COUNTED-STRING   = 255" CR 
    ." /HOLD             = 34" CR
    ." /PAD              = 84" CR
    ." ADDRESS-UNIT-BITS = 16" CR
    ." FLOORED DIVISION  = "
    $180E @
    0< IF ." true"
    ELSE  ." false"
    THEN    CR
    ." MAX-CHAR          = 255" CR
    ." MAX-N             = 32767" CR
    ." MAX-U             = 65535" CR
    ." MAX-D             = 2147483647" CR
    ." MAX-UD            = 4294967295" CR
    ." STACK-CELLS       = 48" CR
    ." RETURN-STACK-CELLS= 48" CR
    ." Definitions are forced to UPPERCASE." CR

    CR ESC [7m ." Kernel add-ons" ESC [0m CR
    $180E @
    2*  DUP 0< IF ." 32.768kHz LF XTAL" CR THEN
    2*  DUP 0< IF ." /RTS /CTS " 2*
            ELSE  2* DUP
                0< IF ." /RTS " THEN
            THEN
    2*  DUP 0< IF ." XON/XOFF "  THEN
    2*  DUP 0< IF ." Half-Duplex "  THEN
    2*  DUP 0< IF ." I2C_Master TERMINAL"
            ELSE  ." UART TERMINAL" THEN CR
    2*  DUP 0< IF 2* DUP 0< IF ." DOUBLE and "
                         THEN  ." Q15.16 numbers handling" CR
            ELSE  2* DUP 0< IF ." DOUBLE numbers handling" CR
                         THEN                       
            THEN                    
    2*  DUP 0< IF ." MSP430_X assembler with TI's syntax" 
                    CR 2* 2*
            ELSE
                2*  DUP                   
                0< IF ." MSP430 Assembler"
                    2*  DUP
                    0< IF ." , 20bits extended addresses,"
                    THEN
                ELSE 2*
                THEN
                ."  with TI's syntax" CR
            THEN DROP
    [DEFINED] FORTH [IF] ." word-set management" CR 
    [THEN]
    [DEFINED] LOAD" [IF] ." SD_CARD Load" CR
    [THEN]
    [DEFINED] BOOT  [IF] ." SD_CARD Bootloader" CR 
    [THEN]
    [DEFINED] READ" [IF] ." SD_CARD Read/Write" CR 
    [THEN]

    $1DCA
    BEGIN
        @ ?DUP
    WHILE
        DUP $180C @ 2* -
        CR ESC [7m 
        [DEFINED] FORTH
        [IF] DUP BODY>SQNFA
        [ELSE]  OVER @
                IF S" hidden"
                ELSE S" FORTH"
                THEN
        [THEN]
        TYPE ."  word-set"
        ESC [0m CR        
        WORDS CR
    REPEAT

    CR ESC [7m ." EXTENSIONS" ESC [0m
    [DEFINED] {CORE_ANS} [IF] CR  ." core ANS94"
    [THEN]
    [DEFINED] {DOUBLE}   [IF] CR  ." DOUBLE word set"
    [THEN]
    [DEFINED] {UTILITY}  [IF] CR ." UTILITY" 
    [THEN]
    [DEFINED] {FIXPOINT} [IF] CR ." Q15.16 ADD SUB MUL DIV" 
    [THEN]
    [DEFINED] {CORDIC}   [IF] CR ." CORDIC engine"
    [THEN]
    [DEFINED] {SD_TOOLS} [IF] CR ." SD_TOOLS" 
    [THEN]
    [DEFINED] {RTC}      [IF] CR ." RTC utility" 
    [THEN]
    [DEFINED] {UARTI2CS} [IF] CR ." UART to I2C_FastForth bridge" 
    [THEN]
    CR
    0 SYS
    ;

SPECS
