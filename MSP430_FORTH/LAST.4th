PWR_STATE

[DEFINED] {FIXPOINT} [IF] {FIXPOINT} [THEN]

[DEFINED] ASM [UNDEFINED] {FIXPOINT} AND [IF]

MARKER {FIXPOINT}

CODE HOLDS
            MOV @R15+,R9
            ADD R14,R9
            MOV &$1DB2,R8
BEGIN       SUB #1,R9
            SUB #1,R14
U>= WHILE   SUB #1,R8
            MOV.B @R9,0(R8)
REPEAT      MOV R8,&$1DB2
            MOV @R15+,R14
            MOV @R13+,R0
ENDCODE

CODE F+
    ADD @R15+,2(R15)
    ADDC @R15+,R14
    MOV @R13+,R0
ENDCODE

CODE F-
    SUB @R15+,2(R15)
    SUBC R14,0(R15)
    MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

CODE F/
        MOV 2(R15),R12
        XOR R14,R12
        MOV #0,R11
        MOV 4(R15),R8
        MOV 2(R15),R9
        BIT #8000,R9
0<> IF  XOR #-1,R8
        XOR #-1,R9
        ADD #1,R8
        ADDC #0,R9
THEN    BIT #8000,R14
0<> IF  XOR #-1,0(R15)
        XOR #-1,R14
        ADD #1,0(R15)
        ADDC #0,R14
THEN
            PUSHM R7,R4
            MOV #0,R10
            MOV @R15,R6
            MOV #32,R5
BW1         CMP R14,R10
    0= IF   CMP R6,R9
    THEN
    U>= IF  SUB R6,R9
            SUBC R14,R10
    THEN
BW2         ADDC R7,R7
            ADDC R4,R4
            SUB #1,R5
            0< ?GOTO FW1
            ADD R11,R11
            ADDC R8,R8
            ADDC R9,R9
            ADDC R10,R10
            U< ?GOTO BW1
            SUB R6,R9
            SUBC R14,R10
            BIS #1,R2
            GOTO BW2
FW1
            ADD #4,R15
            MOV R7,0(R15)
            MOV R4,R14
            POPM R4,R7
BW1     AND #-1,R12
S< IF   XOR #-1,0(R15)
        XOR #-1,R14
        ADD #1,0(R15)
        ADDC #0,R14
THEN    MOV @R13+,R0
ENDCODE

$1A04 C@ $EF > [IF] ; test tag value MSP430FR413x subfamily without hardware_MPY 

CODE F#S 
            MOV @R15,R9
            MOV R14,0(R15)
            SUB #2,R15
            MOV R9,0(R15)
            MOV #4,R14
            CMP #10,&BASE
0= IF       ADD #1,R14
THEN        PUSHM R14,R13
            MOV #0,R12
BEGIN       PUSH R12
            MOV &BASE,R14
            LO2HI
            UM*
            HI2LO
            SUB #2,R13
            CMP #10,R14
    U>= IF  ADD #7,R14
    THEN    ADD #$30,R14
            MOV @R1+,R12
            MOV.B R14,$1D90(R12)
            ADD #1,R12
            CMP 2(R1),R12
U>= UNTIL   POPM R13,R14
            MOV #0,0(R15)
            SUB #2,R15
            MOV #$1D90,0(R15)
            JMP HOLDS
ENDCODE

CODE UDM*
            PUSH R13
            PUSHM R7,R4
            MOV 4(R15),R13
            MOV 2(R15),R11
            MOV @R15,R10
            MOV #0,R4
            MOV #0,R5
            MOV #0,4(R15)
            MOV #0,2(R15)
            MOV #0,R6
            MOV #0,R7
            MOV #1,R9
            MOV #0,R8
BEGIN       CMP #0,R9    
    0<> IF  BIT R9,R10
    ELSE    BIT R8,R14
    THEN
    0<> IF  ADD R13,4(R15)
            ADDC R11,2(R15)
            ADDC R4,R6
            ADDC R5,R7
    THEN    ADD R13,R13
            ADDC R11,R11
            ADDC R4,R4
            ADDC R5,R5
            ADD R9,R9
            ADDC R8,R8
U>= UNTIL   MOV R6,0(R15)
            MOV R7,R14
            POPM R4,R7
            MOV @R1+,R13
            MOV @R13+,R0
ENDCODE

CODE F*
    MOV 2(R15),R12
    XOR R14,R12
    BIT #$8000,2(R15)
0<> IF  XOR #-1,2(R15)
        XOR #-1,4(R15)
        ADD #1,4(R15)
        ADDC #0,2(R15)
THEN
    COLON
    DABS UDM*
    HI2LO
    MOV @R1+,R13
    MOV @R15+,R14
    MOV @R15+,0(R15)
    GOTO BW1
ENDCODE

[ELSE]

CODE F#S
            MOV @R15,R9
            MOV R14,0(R15)
            SUB #2,R15
            MOV R9,0(R15)
            MOV #4,R11
            CMP #10,&BASE
0= IF       ADD #1,R11
THEN        MOV #0,R12
BEGIN       MOV @R15,&$4C0
            MOV &BASE,&$4C8
            MOV &$4E4,0(R15)
            MOV &$4E6,R14
            CMP #10,R14
    U>= IF  ADD #7,R14
    THEN    ADD #$30,R14
            MOV.B R14,$1D90(R12)
            ADD #1,R12
            CMP R11,R12
U>= UNTIL   MOV R11,R14
            MOV #0,0(R15)
            SUB #2,R15
            MOV #$1D90,0(R15)
            JMP HOLDS
ENDCODE

CODE F*
    MOV 4(R15),&$4D4
    MOV 2(R15),&$4D6
    MOV @R15,&$4E0
    MOV R14,&$4E2
    ADD #4,R15
    MOV &$4E6,0(R15)
    MOV &$4E8,R14
    MOV @R13+,R0
ENDCODE

[THEN]

: F.
    <# DUP >R DABS
    F#S
    $2C HOLD #S
    R> SIGN #>
    TYPE SPACE
;

CODE S>F
    SUB #2,R15
    MOV #0,0(R15)
    MOV @R13+,R0
ENDCODE

[UNDEFINED] 2CONSTANT [IF]

CODE 2@
SUB #2,R15
MOV 2(R14),0(R15)
MOV @R14,R14
MOV @R13+,R0
ENDCODE

: 2CONSTANT
CREATE
, ,
DOES>
2@
;

[THEN]

ECHO
PWR_HERE

; -----------------------
; (volatile) tests
; -----------------------
3,14159 2CONSTANT PI
PI -1,0 F* 2CONSTANT -PI

PI 2,0 F/ F.  
PI 2,0 F* F.  
PI -2,0 F/ F.
PI -2,0 F* F.
-PI 2,0 F/ F.
-PI 2,0 F* F.
-PI -2,0 F/ F.
-PI -2,0 F* F.
