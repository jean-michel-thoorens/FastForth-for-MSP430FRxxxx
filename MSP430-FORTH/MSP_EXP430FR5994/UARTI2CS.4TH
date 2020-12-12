; ----------------------------------------------------------------------
; UARTI2CS.4th for MSP_EXP430FR5994
; ----------------------------------------------------------------------

CODE ABORT_UARTI2CS
SUB #4,R15
MOV R14,2(R15)
MOV &$1812,R14
BIT #$7800,R14
0<> IF MOV #0,R14 THEN
MOV R14,0(R15)
MOV &$180E,R14
SUB #308,R14
COLON
$0D EMIT
ABORT" FastForth V3.8 please!"
ABORT" <-- Ouch! unexpected I2C_FastForth target!"
PWR_STATE
;

ABORT_UARTI2CS

[DEFINED] {UARTI2CS} 
[IF] {UARTI2CS}
[THEN]

MARKER {UARTI2CS}
8 ALLOT

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

HDNCODE I2CSTOP
BIS.B #2,&$265
MOV R0,R0
BIS.B #4,&$265
MOV R0,R0
BIC.B #2,&$265
MOV R0,R0
BIC.B #4,&$265
MOV @R1+,R0
ENDCODE

HDNCODE STOP_U2I
BW1
CMP #$40AA,&{UARTI2CS}+8
0<> IF
    CALL #I2CSTOP
    MOV #6,R10
    BIC.B R10,&$265
    BIS.B R10,&$263
    BIS.B R10,&$267
    MOV #0,&$3C0
    MOV #{UARTI2CS}+10,R10
    MOV #$40AA,-2(R10)
    MOV @R10+,&WARM+2
    MOV @R10+,&$FFF0
    MOV @R10+,&$FFF4
    MOV #1,R14
THEN
MOV @R1+,R0
ENDCODE



HDNCODE U2I_TERM_INT
ADD #4,R1
MOV &{UARTI2CS}+16,R10
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
CALL #$41C8
BEGIN
    BIT #1,&$5DC
0<> UNTIL
BW2
MOV.B &$5CC,R12
MOV.B R12,0(R11)
BW3
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
GOTO FW1
ENDCODE


HDNCODE HALF_S_INT
ADD #4,R1
FW1
BW3
CMP #0,&$1812
0>= IF
  MOV #%0001_0101_0110,&$3C0
ELSE
  MOV #%0001_1101_0110,&$3C0
THEN
BEGIN
    BIC.B #2,&$265
    BIT #8,&$5CA
    0<> ?GOTO BW1
    BIS.B   #4,&$265
    MOV.B   &I2CS_ADR,R8
    BIS.B   #1,R8
    $3C00 ,
    BIS.B   #2,&$265
    MOV.B #8,R10
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
    0<> IF
        CALL #I2CSTOP
        MOV #$4000,R0
    THEN
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
            MOV #0,&{UARTI2CS}+16
            0= IF
                MOV #-1,&{UARTI2CS}+16
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
        MOV #0,&{UARTI2CS}+16
        CALL #$41C6
        BEGIN
            BIC #1,&$5DC
            MOV &$1800,R8
            BEGIN MOV #32,R10
                BEGIN SUB #1,R10
                0= UNTIL
                SUB #1,R8
            0= UNTIL
            BIT #1,&$5DC
        0= UNTIL
    THEN
REPEAT
CALL #I2CSTOP
CMP.B #1,R9
0= IF
    MOV #$1CE4,R11
    CALL #$41C6
    BEGIN
        BIT #1,&$5DC
    0<> UNTIL
    CALL #$41C8
    GOTO BW2
THEN
MOV #$4000,R0
ENDCODE

HDNCODE INI_U2I
CALL &{UARTI2CS}+10
CMP #$0E,R14
0<> IF
    CMP #$0A,R14
    U>= ?GOTO BW1
THEN
BIT.B #$20,&$240
0= ?GOTO BW1
MOV #0,&$1808
MOV #$800,&$3D2
BIC.B #6,&$267
BIC.B #6,&$263
GOTO BW3
ENDCODE

: UARTI2CS
CR I2CS_ADR !
HI2LO
CMP #$40AA,&{UARTI2CS}+8
0= IF
    MOV #STOP_U2I,&{UARTI2CS}+8
    MOV &WARM+2,&{UARTI2CS}+10
    MOV &$FFF0,&{UARTI2CS}+12
    MOV &$FFF4,&{UARTI2CS}+14

    MOV #0,&{UARTI2CS}+16
    MOV #INI_U2I,&WARM+2
    MOV #U2I_TERM_INT,&$FFF0
    MOV #HALF_S_INT,&$FFF4

THEN
MOV #WARM,R0
ENDCODE           

RST_HERE ECHO
18 UARTI2CS     ; TERATERM(Alt-B) or I2C_Master($20+RST) to quit
