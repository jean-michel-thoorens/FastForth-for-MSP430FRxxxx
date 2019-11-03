
; -----------------------------------------------------
; FIXPOINT.4th 
; -----------------------------------------------------

; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------

PWR_STATE

[DEFINED] {FIXPOINT} [IF]  {FIXPOINT} [THEN]

[UNDEFINED] {FIXPOINT} [IF]

[UNDEFINED] MARKER [IF]
: MARKER
CREATE
HI2LO
MOV &$1DC8,0(R10)
SUB #2,R8
MOV R8,2(R10)
ADD #4,&$1DC6
LO2HI
DOES>
HI2LO
MOV @R1+,R13
MOV @R14+,&$180E
MOV @R14,&$180C
MOV @R15+,R14
MOV #RST_STATE,R0
ENDCODE
[THEN]

MARKER {FIXPOINT}

[UNDEFINED] + [IF]
CODE +
ADD @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] @ [IF]
CODE @
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] ! [IF]
CODE !
MOV @R15+,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] R> [IF]
CODE R>
MOV R6,R0
ENDCODE
[THEN]

[UNDEFINED] = [IF]
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

[UNDEFINED] U< [IF]
CODE U<
SUB @R15+,R14
0<> IF
    MOV #-1,R14
    U< IF
        AND #0,R14
    THEN
THEN
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] HOLDS [IF]
CODE HOLDS
BW3         MOV @R15+,R9
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
[THEN]

[UNDEFINED] DABS [IF]
CODE DABS
AND #-1,R14
S< IF
    XOR #-1,0(R15)
    XOR #-1,R14
    ADD #1,0(R15)
    ADDC #0,R14
THEN
MOV @R13+,R0
ENDCODE
[THEN]

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

$1A00 4 + @ $81F3 U<
$81EF $1A00 4 + @ U< 
= [IF]   ; MSP430FR413x subfamily without hardware_MPY

CODE F/
            PUSHM #4,R7    
            MOV @R15+,R6
            MOV @R15+,R9
            MOV #0,R10
            MOV @R15,R8
            MOV #0,R11
            MOV R9,R12
            XOR R14,R12
            AND #-1,R9
S< IF       XOR #-1,R8
            XOR #-1,R9
            ADD #1,R8
            ADDC #0,R9
THEN        AND #-1,R14
S< IF       XOR #-1,R6
            XOR #-1,R14
            ADD #1,R6
            ADDC #0,R14
THEN
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
            MOV R7,0(R15)
            MOV R4,R14
            POPM #4,R7
BW1         AND #-1,R12
S< IF       XOR #-1,0(R15)
            XOR #-1,R14
            ADD #1,0(R15)
            ADDC #0,R14
THEN        MOV @R13+,R0
ENDCODE

[UNDEFINED] F#S [IF]
CODE F#S 
            MOV 2(R15),R9
            MOV @R15,2(R15)
            MOV R9,0(R15)
            PUSHM #2,R14
            MOV #0,R12
BEGIN       PUSH R12
            MOV &$1DDC,R14
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
U>= UNTIL   
            POPM #2,R14
            MOV #0,0(R15)
            SUB #2,R15
            MOV #$1D90,0(R15)
            GOTO BW3
ENDCODE
[THEN]

CODE UDM*
            PUSH R13
            PUSHM #4,R7
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
            POPM #4,R7
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

[ELSE] ; else if hardware multiplier

CODE F/
            PUSHM #4,R7
            MOV @R15+,R6
            MOV @R15+,R9
            MOV #0,R10
            MOV @R15,R8
            MOV #0,R11
            MOV R9,R12
            XOR R14,R12
            AND #-1,R9
S< IF       XOR #-1,R8
            XOR #-1,R9
            ADD #1,R8
            ADDC #0,R9
THEN        AND #-1,R14
S< IF       XOR #-1,R6
            XOR #-1,R14
            ADD #1,R6
            ADDC #0,R14
THEN    
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
FW1         AND #-1,R12
S< IF       XOR #-1,R7
            XOR #-1,R4
            ADD #1,R7
            ADDC #0,R4
THEN        MOV R7,0(R15)
            MOV R4,R14
            POPM #4,R7
            MOV @R13+,R0
ENDCODE

[UNDEFINED] F#S [IF]
CODE F#S
            MOV 2(R15),R9
            MOV @R15,2(R15)
            MOV R9,0(R15)
            MOV R14,R11
            MOV #0,R12
BEGIN       MOV @R15,&$4C0
            MOV &$1DDC,&$4C8
            MOV &$4E4,0(R15)
            MOV &$4E6,R14
            CMP #10,R14
    U>= IF  ADD #7,R14
    THEN    ADD #$30,R14
            MOV.B R14,$1D90(R12)
            ADD #1,R12
            CMP R11,R12
0= UNTIL    MOV #0,0(R15)
            MOV R11,R14
            SUB #2,R15
            MOV #$1D90,0(R15)
            GOTO BW3
ENDCODE
[THEN]

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

[UNDEFINED] F. [IF]
CODE F.
MOV R14,R12
MOV #4,R11
MOV &$1DDC,R10
CMP ##10,R10
0= IF
    ADD #1,R11
ELSE
    CMP #%10,R10
    0= IF
        MOV #16,R11
    THEN
THEN
PUSHM #3,R13
LO2HI
    <# DABS
    R> F#S
    $2C HOLD
    #S
    R> SIGN #>
    TYPE $20 EMIT
;

CODE S>F
    SUB #2,R15
    MOV #0,0(R15)
    MOV @R13+,R0
ENDCODE
[THEN]

RST_HERE

[THEN]

[UNDEFINED] 2CONSTANT [IF]
: 2CONSTANT
CREATE , ,
DOES>
HI2LO
SUB #2,R15
MOV 2(R14),0(R15)
MOV @R14,R14
MOV @R1+,R13
MOV @R13+,R0
ENDCODE
;
[THEN]

ECHO

; -----------------------
; (volatile) tests
; -----------------------

3,14159 2CONSTANT PI
PI -1,0 F* 2CONSTANT -PI

$10 $1DDC !  PI F. 
            -PI F.
%10 $1DDC !  PI F. 
            -PI F.
#10 $1DDC !  PI F. 
            -PI F.

PI 2,0 F* F.      
PI -2,0 F* F.    
-PI 2,0 F* F.    
-PI -2,0 F* F.    

PI 2,0 F/ F.      
PI -2,0 F/ F.    
-PI 2,0 F/ F.    
-PI -2,0 F/ F.    

32767,99999 1,0 F* F. 
32767,99999 1,0 F/ F. 
32767,99999 2,0 F/ F. 
32767,99999 4,0 F/ F. 
32767,99999 8,0 F/ F. 
32767,99999 16,0 F/ F.

-32767,0 -1,0 F* F.   
-32767,0 -1,0 F/ F.   
-32767,0 -2,0 F/ F.   
-32767,0 -4,0 F/ F.   
-32767,0 -8,0 F/ F.   
-32767,0 -16,0 F/ F.  
-32767,0 -32,0 F/ F.  
-32767,0 -64,0 F/ F.  

; SQRT(32768)^2 = 32768
181,01933598375 181,01933598375 F* F.  
181,01933598375 -181,01933598375 F* F.
-181,01933598375 181,01933598375 F* F.
-181,01933598375 -181,01933598375 F* F.


