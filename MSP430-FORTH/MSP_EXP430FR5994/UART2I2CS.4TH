
; ----------------------------------------------------------------------
; UART2I2CS.4th
; ----------------------------------------------------------------------





PWR_STATE

[DEFINED] {FF_I2C} [IF]  {FF_I2C} [THEN]

MARKER {FF_I2C}

[UNDEFINED] @ [IF]
CODE @
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] CONSTANT [IF]
: CONSTANT 
CREATE
HI2LO
MOV R14,-2(R10)
MOV @R15+,R14
MOV @R1+,R13
MOV @R13+,R0
ENDCODE
[THEN]

$1820 CONSTANT SLAVE_ADR


ASM QUIT_I2C
BW1
    BIS #3,&$266
    BIC #3,&$264
    BIS #3,&$262
    MOV #$5A88,&$15C
    BIC #1,&$100
    MOV &$FFFA,&$FFF2
    MOV &$181C,&TERM_VEC
    MOV #WARM,R9
    ADD #4,R9
    MOV R9,-2(R9)
    MOV R9,R0
ENDASM

ASM WDT_INT
BIT #8,&$5CA
0<> IF
    ADD #4,R1
    POPM #6,R13
    GOTO BW1
THEN
RETI
ENDASM



ASM TERM_INT
ADD #4,R1
POPM #6,R13
BEGIN
    BEGIN
        BEGIN
            BIT #1,&$5DC
        0<> UNTIL
BW1     MOV.B &$5CC,R9
        MOV.B R9,0(R11)
        CMP.B R12,R9
        0= ?GOTO FW1
        ADD #1,R11
        CMP.B #$0D,R9
    0<> WHILE
        CMP #0,R10
        0= IF
            MOV.B R9,&$5CE
        THEN
    REPEAT
    CALL &$1816
AGAIN
FW1
BW2
BIS.B   #1,&$264
MOV.B   &SLAVE_ADR,R9
BIC.B   #1,R9
MOV R0,R0
MOV R0,R0
BIS.B   #2,&$264
MOV R12,R11
XOR #-1,R11
BEGIN
    MOV.B #8,R10
    BEGIN
        ADD.B R9,R9
        U>= IF
            BIC.B #1,&$264
        ELSE
            BIS.B #1,&$264
            $3C00 ,
        THEN
        BIC.B #2,&$264
        BEGIN
            BIT.B #2,&$260
        0<> UNTIL
        BIS.B #2,&$264
        SUB #1,R10
    0= UNTIL
    BIC.B   #1,&$264
    BIC.B   #2,&$264
    BEGIN
        BIT.B #2,&$260
    0<> UNTIL
    BIT.B   #1,&$260
    BIS.B   #2,&$264
0= WHILE
    CMP.B R12,R11
0<> WHILE
    MOV.B @R8+,R9
    MOV R9,R11
REPEAT
THEN
    MOV R0,R0
    BIC.B #2,&$264
BW3
BEGIN
    BEGIN
        BIS.B   #1,&$264
        MOV.B   &SLAVE_ADR,R9
        BIS.B   #1,R9
        MOV R0,R0
        MOV R0,R0
        BIS.B   #2,&$264
        MOV.B   #8,R10
        BEGIN
            ADD.B R9,R9
            U>= IF
                BIC.B #1,&$264
            ELSE
                BIS.B #1,&$264
                $3C00 ,
            THEN
            BIC.B #2,&$264
            BEGIN
                BIT.B #2,&$260
            0<> UNTIL
            BIS.B #2,&$264
            SUB #1,R10
        0= UNTIL
        BIC.B   #1,&$264
        BIC.B   #2,&$264
        BEGIN
            BIT.B #2,&$260
        0<> UNTIL
        BIT.B   #1,&$260
        BIS.B   #2,&$264
    0<> WHILE
        MOV R0,R0
        BIS.B #1,&$264
        MOV R0,R0
        BIC.B #2,&$264
        MOV R0,R0
        MOV R0,R0
        BIC.B #1,&$264
        BIT #8,&$5CA
        0<> IF
            MOV #QUIT_I2C,R0
        THEN
    REPEAT
    BEGIN
        BEGIN
            MOV.B #8,R10
            BEGIN
                BIC.B #2,&$264
                BEGIN
                BIT.B #2,&$260
                0<> UNTIL
                BIT.B #1,&$260
                BIS.B #2,&$264
                ADDC.B R9,R9
                SUB #1,R10
            0= UNTIL
            CMP.B #8,R9
        U>= WHILE
            BEGIN
                BIT #2,&$5DC
            0<> UNTIL
            BIS.B #1,&$264
            BIC.B   #2,&$264
            BEGIN
                BIT.B #2,&$260
            0<> UNTIL
            MOV.B R9,&$5CE
            BIS.B #2,&$264
            BIC.B #1,&$264
        REPEAT
        CMP.B #4,R9
        U>= IF
            BIS.B #1,&$264
        THEN
        BIC.B   #2,&$264
        BEGIN
            BIT.B #2,&$260
        0<> UNTIL
        BIT.B   #1,&$260
        BIS.B   #2,&$264
    0= WHILE
        BIC.B #1,&$264
        CMP.B #4,R9
        0= IF
            MOV #1,&$1D38
        ELSE
            MOV #0,&$1D38
        THEN
    REPEAT
    CMP.B #2,R9
0= WHILE
    MOV #0,&$1D38
    CALL &$1814
    BEGIN
        BIC #1,&$5DC
        MOV &$1806,R8
        BEGIN MOV #32,R9
            BEGIN SUB #1,R9
            0= UNTIL
            SUB #1,R8
        0= UNTIL
        BIT #1,&$5DC
    0= UNTIL
REPEAT
BIC.B #2,&$264
MOV R0,R0
MOV R0,R0
BIC.B #1,&$264
CMP.B #1,R9
0= IF
    CALL &$1814
    MOV #$1D3A,R8
    MOV R8,R11
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
    MOV.B &$5CC,R9
    MOV.B R9,0(R11)
    MOV.B R9,R12
    CALL &$1816
    GOTO BW2
THEN
MOV #$1D3C,R8
MOV &$1D38,R10
MOV R8,R11
MOV #$0A,R12
PUSHM #6,R13
MOV #$4000,R0
ENDASM





ASM WARM_I2C
CMP #4,&$1808
0= IF
    MOV #QUIT_I2C,R0
THEN                
    CMP #$10,&$1808
    U>= IF
        MOV #QUIT_I2C,R0
    THEN
MOV #0,&$1808
MOV #%0101_1010_0101_1111,&$15C
BIS #1,&$100
MOV #WDT_INT,&$FFF2
BIS #IE_TERM,&$5DA
BIS.B #TERM_BUS,&$20D
MOV #TERM_INT,&TERM_VEC
BIC #3,&$266
BIC #3,&$262
BIC #1,&$130
GOTO BW3
ENDASM


CODE UART2I2CS
MOV @R1+,R13
MOV R14,&SLAVE_ADR
MOV @R15+,R14
MOV #WARM,R9
MOV #WARM_I2C,2(R9)
MOV R9,R0
ENDCODE

RST_HERE

; Since there is no difference in behavior whether the TERMINAL is connected to the Master
; or to a Slave, the convenient way to check which target is connected to is to execute WARM,
; because WARM displays first the decimal I2C address when TERMINAL is connected to I2C FastForth.

WARM

; v---- in forthMSP430FR.asm file search "I2CSLAVEADR" value used when compiling FastForth for TERMINAL_I2C
 $10 UART2I2CS

WARM

; remember: from scite menu or in the SendSourceFileToTarget.bat file, select the good target to download UART2I2CS
;           then select the good target to download sources file to the target running FastForth I2C
;           at the specified I2C address !

;           Alt-B to quit UART2I2CS

; ready for a cluster of FastForth(s) ?
