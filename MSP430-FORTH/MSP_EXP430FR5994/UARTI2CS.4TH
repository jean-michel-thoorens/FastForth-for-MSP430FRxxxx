
; ----------------------------------------------------------------------
; UARTI2CS.4th for MSP_EXP430FR5994
; ----------------------------------------------------------------------
[UNDEFINED] @ [IF]
CODE @
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] AND [IF]
CODE AND
AND @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 0= [IF]
CODE 0=
SUB #1,R14
SUBC R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

: I2CTERM_ABORT
$0D EMIT
1 ABORT" <-- Ouch! unexpected target with I2C TERMINAL"
;

$1812 @ $7800 AND 0= [IF] ; unexpected I2C TERMINAL ?
I2CTERM_ABORT
[THEN]

PWR_STATE

[DEFINED] {UARTI2CS} [IF] {UARTI2CS} [THEN]

MARKER {UARTI2CS}

[UNDEFINED] < [IF]
CODE <
        SUB @R15+,R14
        S< ?GOTO FW1
        0<> IF
BW1         MOV #-1,R14
        THEN
        MOV @R13+,R0
ENDCODE

CODE >
        SUB @R15+,R14
        S< ?GOTO BW1
FW1     AND #0,R14
        MOV @R13+,R0
ENDCODE
[THEN]

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

$FFA2 CONSTANT I2CS_ADR

ASM QUIT_I2C
BW1
    BIS.B #6,&$267
    BIC.B #6,&$265
    BIS.B #6,&$263
    MOV #$5A88,&$15C
    BIC #1,&$100
    MOV #COLD,&$FFF2
    MOV #0,&$3C0
    MOV #COLD,&TB0_x_VEC
    MOV &$181C,&$FFF0
    MOV #WARM,R9
    ADD #4,R9
    MOV R9,-2(R9)
    MOV #COLD,R0
ENDASM

ASM WDT_INT
BIT #8,&$5CA
0<> IF
    ADD #4,R1
    GOTO BW1
THEN
RETI
ENDASM


ASM TERM_INT
ADD #4,R1
MOV &$1CE0,R10
MOV #$1CE4,R11
MOV #$0D,R12
BEGIN
    MOV.B &$5CC,R8
    ADD #1,R11
    MOV.B R8,-1(R11)
    CMP.B R8,R12
0<> WHILE
    CMP #0,R10
    0= IF
        BEGIN
            BIT #2,&$5DC
        0<> UNTIL
        MOV.B R8,&$5CE
    THEN
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
REPEAT
CALL &$1816
BEGIN
    BIT #1,&$5DC
0<> UNTIL
BW1
MOV.B &$5CC,R12
MOV.B R12,0(R11)
BIS.B   #4,&$265
MOV.B   &I2CS_ADR,R9
MOV     #$1CE4,R8
MOV R0,R0
BIS.B   #2,&$265
BEGIN
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
    MOV R0,R0
    BIT.B #4,&$261
    BIS.B #2,&$265
0= WHILE
    CMP R12,R11
0<> WHILE
    MOV.B @R8+,R9
    MOV R9,R11
REPEAT
THEN
    MOV R0,R0
    BIC.B #2,&$265
GOTO FW1
ENDASM

ASM TxIFG_INT
ADD #4,R1
FW1
BW3
$1812 @ 0 <
[IF]
    MOV #%0001_1101_0110,&$3C0
[ELSE]
    MOV #%0001_0101_0110,&$3C0
[THEN]
BEGIN
    BEGIN
        BIT #8,&$5CA
        0<> IF
            MOV #QUIT_I2C,R0
        THEN
        BIS.B   #4,&$265
        MOV.B   &I2CS_ADR,R8
        BIS.B   #1,R8
        $3C00 ,
        BIS.B   #2,&$265
        MOV.B   #8,R10
        BEGIN
            ADD.B R8,R8
            U>= IF
               BIC.B #4,&$265
            ELSE
               BIS.B #4,&$265
            THEN
            BIC.B #2,&$265
            MOV R0,R0
            BIS.B #2,&$265
            SUB #1,R10
        0= UNTIL
        BIC.B   #4,&$265
        BIC.B   #2,&$265
        BEGIN
            BIT.B #2,&$261
        0<> UNTIL
        BIT.B   #4,&$261
        BIS.B   #2,&$265
    0<> WHILE
        MOV R0,R0
        BIS.B #4,&$265
        MOV R0,R0
        BIC.B #2,&$265
        MOV R0,R0
        MOV R0,R0
        BIC.B #4,&$265
        CMP.B #4,R9
        U>= IF
            MOV #$4000,R0
        THEN
    REPEAT
    BEGIN
        BEGIN
            BIC.B #4,&$265
            MOV.B #8,R10
            BEGIN
               BIC.B #2,&$265
               MOV R0,R0
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
            BEGIN
                BIT #2,&$5DC
            0<> UNTIL
            BIS.B #4,&$265
            BIC.B #2,&$265
            BEGIN
                BIT.B #2,&$261
            0<> UNTIL
            MOV.B R9,&$5CE
            BIS.B #2,&$265
        REPEAT
        CMP.B #4,R9
        U>= IF
            0= IF
                MOV #1,&$1CE0
            ELSE
                MOV #0,&$1CE0
            THEN
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
        MOV #0,&$1CE0
        CALL &$1814
        BEGIN
            BIC #1,&$5DC
            MOV &$1806,R8
            BEGIN MOV #32,R10
                BEGIN SUB #1,R10
                0= UNTIL
                SUB #1,R8
            0= UNTIL
            BIT #1,&$5DC
        0= UNTIL
    THEN
REPEAT
BIS.B #4,&$265
BIC.B #2,&$265
MOV R0,R0
MOV #$1CE4,R11
BIC.B #4,&$265
CMP.B #1,R9
0= IF
    CALL &$1814
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
    CALL &$1816
    GOTO BW1
THEN
MOV #$4000,R0
ENDASM


ASM I2C_WARM
CMP #4,&$1808
0= IF
    BIT.B #$20,&$240
    0= IF
        MOV #QUIT_I2C,R0
    THEN
THEN
CMP #$10,&$1808
U>= IF
    MOV #QUIT_I2C,R0
THEN
MOV #0,&$1808
MOV #%0101_1010_0101_1111,&$15C
BIS #1,&$100
MOV #WDT_INT,&$FFF2
MOV #$800,&$3D2
MOV #TxIFG_INT,&TB0_x_VEC
MOV #TERM_INT,&$FFF0
BIC.B #6,&$267
BIC.B #6,&$263
BIC #1,&$130
MOV.B #4,R9
GOTO BW3
ENDASM

: UARTI2CS
CR
HI2LO
MOV @R1+,R13
MOV R14,&I2CS_ADR
MOV @R15+,R14
MOV #WARM,R9
MOV #I2C_WARM,2(R9)
MOV R9,R0
ENDCODE

RST_HERE ECHO

#16 UARTI2CS    ; Alt-B (TERATERM) or S2+RESET (I2C_Master) to quit

; Since there is no difference in behaviour whether the TERMINAL is connected to the Master
; or bridged to any Slave, WARM is the convenient way to check which target is connected to,
; because, as any ABORT message, WARM displays first the decimal I2C address if applicable:
WARM
