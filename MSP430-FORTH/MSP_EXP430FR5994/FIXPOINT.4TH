
; -----------------------------------------------------
; FIXPOINT.4th for MSP_EXP430FR5994 
; -----------------------------------------------------

; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------

PWR_STATE

[DEFINED] {FIXPOINT} [IF]  {FIXPOINT} [THEN]

[UNDEFINED] {FIXPOINT} [IF]

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

[UNDEFINED] HOLDS [IF]
CODE HOLDS
            MOV @R15+,R9
BW3         ADD R14,R9
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

CODE UDM*
            PUSH R13
            PUSHM #4,R7
            MOV 4(R15),R13
            MOV 2(R15),R11
            MOV @R15,R10
            MOV #0,R7
            MOV #0,R6
            MOV #0,4(R15)
            MOV #0,2(R15)
            MOV #0,R5
            MOV #0,R4
            MOV #1,R9
            MOV #0,R8
BEGIN       CMP #0,R9    
    0<> IF  BIT R9,R10
    ELSE    BIT R8,R14
    THEN
    0<> IF  ADD R13,4(R15)
            ADDC R11,2(R15)
            ADDC R7,R5
            ADDC R6,R4
    THEN    ADD R13,R13
            ADDC R11,R11
            ADDC R7,R7
            ADDC R6,R6
            ADD R9,R9
            ADDC R8,R8
U>= UNTIL   MOV R5,0(R15)
            MOV R4,R14
            POPM #4,R7
            MOV @R1+,R13
            MOV @R13+,R0
ENDCODE

CODE F*
            MOV 2(R15),R12
            XOR R14,R12
            BIT #$8000,2(R15)
0<> IF      XOR #-1,2(R15)
            XOR #-1,4(R15)
            ADD #1,4(R15)
            ADDC #0,2(R15)
THEN        COLON
            DABS UDM*
            HI2LO
            MOV @R1+,R13
            MOV @R15+,R14
            MOV @R15+,0(R15)
BW2         AND #-1,R12
S< IF       XOR #-1,0(R15)
            XOR #-1,R14
            ADD #1,0(R15)
            ADDC #0,R14
THEN        MOV @R13+,R0
ENDCODE

CODE F/
            PUSHM #4,R7
            MOV @R15+,R7
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
S< IF       XOR #-1,R7
            XOR #-1,R14
            ADD #1,R7
            ADDC #0,R14
THEN
            MOV #32,R6
BW1         CMP R14,R10
    0= IF   CMP R7,R9
    THEN
    U>= IF  SUB R7,R9
            SUBC R14,R10
    THEN
    BEGIN   ADDC R4,R4
            ADDC R5,R5
            SUB #1,R6
            0< ?GOTO FW1
            ADD R11,R11
            ADDC R8,R8
            ADDC R9,R9
            ADDC R10,R10
            U< ?GOTO BW1
            SUB R7,R9
            SUBC R14,R10
            BIS #1,R2
    AGAIN
FW1
            MOV R4,0(R15)
            MOV R5,R14
            POPM #4,R7
            GOTO BW2
ENDCODE

[UNDEFINED] F#S [IF]
CODE F#S
            MOV @R15,R12
            MOV #0,R11
            PUSHM #3,R13
            MOV 2(R15),0(R15)
            MOV R14,2(R15)
BEGIN       MOV &$1DDC,R14
            LO2HI
            UM*
            HI2LO
            CMP #10,R14
    U>= IF  ADD #7,R14
    THEN    ADD #$30,R14
            MOV @R1,R11
            MOV.B R14,$1D90(R11)
            ADD #1,R11
            MOV R11,0(R1)
            CMP 2(R15),R11
U>= UNTIL   POPM #3,R13
            MOV R11,R14
            MOV R12,2(R15)
            MOV #0,0(R15)
            MOV #$1D90,R9
            GOTO BW3
ENDCODE
[THEN]

[ELSE] ; hardware multiplier

CODE F/
            PUSHM #4,R7
            MOV @R15+,R7
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
S< IF       XOR #-1,R7
            XOR #-1,R14
            ADD #1,R7
            ADDC #0,R14
THEN    
            MOV #32,R6
BW1         CMP R14,R10
    0= IF   CMP R7,R9
    THEN
    U>= IF  SUB R7,R9
            SUBC R14,R10
    THEN
BW2         ADDC R4,R4
            ADDC R5,R5
            SUB #1,R6
            0< ?GOTO FW1
            ADD R11,R11
            ADDC R8,R8
            ADDC R9,R9
            ADDC R10,R10
            U< ?GOTO BW1
            SUB R7,R9
            SUBC R14,R10
            BIS #1,R2
            GOTO BW2
FW1         AND #-1,R12
S< IF       XOR #-1,R4
            XOR #-1,R5
            ADD #1,R4
            ADDC #0,R5
THEN        MOV R4,0(R15)
            MOV R5,R14
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
0= UNTIL    MOV R11,R14
            MOV #0,0(R15)
            MOV #$1D90,R9
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
CMP #$0A,R10
0= IF
    ADD #1,R11
ELSE
    CMP #2,R10
    0= IF
        MOV #$10,R11
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

; -----------------------
; complements (volatile) for tests below
; -----------------------

[UNDEFINED] ! [IF]
CODE !
MOV @R15+,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DOES> [IF]
CODE DOES> 
MOV &$1DBA,R10
MOV #$1285,0(R10)
MOV R13,2(R10)
MOV @R1+,R13
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
[THEN]

[UNDEFINED] D. [IF]
CODE D.
MOV #U.,R10
ADD #10,R10
MOV R10,R0
ENDCODE
[THEN]

[UNDEFINED] BASE [IF]
$1DDC CONSTANT BASE
[THEN]

ECHO

; -----------------------
; (volatile) tests for FIXPOINT.asm|FIXPOINT.4th for MSP_EXP430FR5994
; -----------------------

3,14159 2CONSTANT PI
PI -1,0 F* 2CONSTANT -PI

PI D.   ; D. is not appropriate -->
-PI D.  ; D. is not appropriate -->

PI F.   ; good value! ------------>
-PI F.  ; good value! ------------>

$10 BASE  !  PI F. 
            -PI F.
%10 BASE  !  PI F. 
            -PI F.
#10 BASE  !  PI F. 
            -PI F.

PI 2,0 F* F.      
PI -2,0 F* F.    
-PI 2,0 F* F.    
-PI -2,0 F* F.    

PI 2,0 F/ F.      
PI -2,0 F/ F.    
-PI 2,0 F/ F.    
-PI -2,0 F/ F.    

32768,0 1,0 F* F.   ; overflow! -->
32768,0 1,0 F/ F.   ; overflow! -->
-32768,0 -1,0 F* F. ; overflow! -->
-32768,0 -1,0 F/ F. ; overflow! -->

32767,99999 1,0 F* F. 
32767,99999 1,0 F/ F. 
32767,99999 2,0 F/ F. 
32767,99999 4,0 F/ F. 
32767,99999 8,0 F/ F. 
32767,99999 16,0 F/ F.

-32768,0 -2,0 F/ F.   
-32768,0 -4,0 F/ F.   
-32768,0 -8,0 F/ F.   
-32768,0 -16,0 F/ F.  
-32768,0 -32,0 F/ F.  
-32768,0 -64,0 F/ F.  

-3276,80 -1,0 F/ F.   
-327,680 -1,0 F/ F.   
-32,7680 -1,0 F/ F.   
-3,27680 -1,0 F/ F.   
-0,32768 -1,0 F/ F.   

; SQRT(32768)^2 = 32768
181,01933598375 181,01933598375 F* F.  
181,01933598375 -181,01933598375 F* F.
-181,01933598375 181,01933598375 F* F.
-181,01933598375 -181,01933598375 F* F.
