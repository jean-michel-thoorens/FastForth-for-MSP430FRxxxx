
; -----------------------------------------------------
; DOUBLE.4th for MSP_EXP430FR5994
; -----------------------------------------------------

; -----------------------------------------------------------
; requires DOUBLE_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------

PWR_STATE

[DEFINED] {DOUBLE} [IF]  {DOUBLE} [THEN]

MARKER {DOUBLE}

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

[UNDEFINED] C@ [IF]
CODE C@
MOV.B @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] SWAP [IF]
CODE SWAP
MOV @R15,R10
MOV R14,0(R15)
MOV R10,R14
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

[UNDEFINED] ROT [IF]
CODE ROT
MOV @R15,R10
MOV R14,0(R15)
MOV 2(R15),R14
MOV R10,2(R15)
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] - [IF]
CODE -
SUB @R15+,R14
XOR #-1,R14
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

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

[UNDEFINED] IF [IF]
CODE IF
SUB #2,R15
MOV R14,0(R15)
MOV &$1DC6,R14
ADD #4,&$1DC6
MOV #$4042,0(R14)
ADD #2,R14
MOV @R13+,R0
ENDCODE IMMEDIATE

CODE THEN
MOV &$1DC6,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
CODE ELSE
ADD #4,&$1DC6
MOV &$1DC6,R10
MOV #$403E,-4(R10)
MOV R10,0(R14)
SUB #2,R10
MOV R10,R14
MOV @R13+,R0
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] TO [IF]
CODE TO
BIS #$400,R2
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

[UNDEFINED] SPACES [IF]
CODE SPACES
CMP #0,R14
0<> IF
    PUSH R13
    BEGIN
        LO2HI
        $20 EMIT
        HI2LO
        SUB #2,R13 
        SUB #1,R14
    0= UNTIL
    MOV @R1+,R13
THEN
MOV @R15+,R14
MOV @R13+,R0              
ENDCODE
[THEN]

[UNDEFINED] 2@ [IF]
CODE 2@
SUB #2,R15
MOV 2(R14),0(R15)
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2! [IF]
CODE 2!
MOV @R15+,0(R14)
MOV @R15+,2(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2DUP [IF]
CODE 2DUP
SUB #4,R15
MOV R14,2(R15)
MOV 4(R15),0(R15)
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2DROP [IF]
CODE 2DROP
ADD #2,R15
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2SWAP [IF]
CODE 2SWAP
MOV @R15,R10
MOV 4(R15),0(R15)
MOV R10,4(R15)
MOV R14,R10
MOV 2(R15),R14
MOV R10,2(R15)
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2OVER [IF]
CODE 2OVER
SUB #4,R15
MOV R14,2(R15)
MOV 8(R15),0(R15)
MOV 6(R15),R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2>R [IF]
CODE 2>R
PUSH @R15+
PUSH R14
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2R@ [IF]
CODE 2R@
SUB #4,R15
MOV R14,2(R15)
MOV @R1,R14
MOV 2(R1),0(R15)
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2R> [IF]
CODE 2R>
SUB #4,R15
MOV R14,2(R15)
MOV @R1+,R14
MOV @R1+,0(R15)
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

[UNDEFINED] 2ROT [IF]
CODE 2ROT
MOV 8(R15),R9
MOV 6(R15),R8
MOV 4(R15),8(R15)
MOV 2(R15),6(R15)
MOV @R15,4(R15)
MOV R14,2(R15)
MOV R9,0(R15)
MOV R8,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D>S [IF]
CODE D>S
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D0= [IF]
CODE D0=
CMP #0,R14
MOV #0,R14
0= IF
    CMP #0,0(R15)
    0= IF
        MOV #-1,R14
    THEN
THEN
ADD #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D0< [IF]
CODE D0<
CMP #0,R14
MOV #0,R14
S< IF
    MOV #-1,R14
THEN
ADD #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D= [IF]
CODE D=
CMP R14,2(R15)
MOV #0,R14
0= IF
    CMP @R15,4(R15)
    0= IF
    MOV #-1,R14
    THEN
THEN
ADD #6,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D< [IF]
CODE D<
CMP R14,2(R15)
MOV #0,R14
S< IF
    MOV #-1,R14
THEN
0= IF
    CMP @R15,4(R15)
    S< IF
        MOV #-1,R14
    THEN
THEN
ADD #6,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DU< [IF]
CODE DU<
CMP R14,2(R15)
MOV #0,R14
U< IF
    MOV #-1,R14
THEN
0= IF
    CMP @R15,4(R15)
    U< IF
        MOV #-1,R14
    THEN
THEN
ADD #6,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D+ [IF]
CODE D+
BW1 ADD @R15+,2(R15)
    ADDC @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] M+ [IF]
CODE M+
SUB #2,R15
CMP #0,R14
MOV R14,0(R15)
MOV #-1,R14
0>= IF
    MOV #0,R14
THEN
GOTO BW1
ENDCODE
[THEN]

[UNDEFINED] D- [IF]
CODE D-
SUB @R15+,2(R15)
SUBC R14,0(R15)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DNEGATE [IF]
CODE DNEGATE
XOR #-1,0(R15)
XOR #-1,R14
ADD #1,0(R15)
ADDC #0,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DABS [IF]
CODE DABS
CMP #0,R14
0>= IF
    MOV @R13+,R0
THEN
MOV #DNEGATE,R0
ENDCODE
[THEN]

[UNDEFINED] D2/ [IF]
CODE D2/
RRA R14
RRC 0(R15)
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] D2* [IF]
CODE D2*
ADD @R15,0(R15)
ADDC R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DMAX [IF]
: DMAX
2OVER 2OVER
D< IF
    2>R 2DROP 2R>
ELSE
    2DROP
THEN
;
[THEN]

[UNDEFINED] DMIN [IF]
: DMIN
2OVER 2OVER
D< IF
    2DROP
ELSE 2>R 2DROP 2R>
THEN
;

$1A04 C@ $EF > [IF] ; test tag value for MSP430FR413x devices without hardware_MPY 

[UNDEFINED] M*/ [IF]
CODE M*/
BIC #$200,R2
CMP #0,2(R15)
S< IF
    XOR #-1,4(R15)
    XOR #-1,2(R15)
    ADD #1,4(R15)
    ADDC #0,2(R15)
    BIS #$200,R2
THEN
CMP #0,0(R15)
S< IF
    XOR #-1,0(R15)
    ADD #1,0(R15)
    BIT #$200,R2
    0= IF 
        BIS #$200,R2
    ELSE
        BIC #$200,R2
    THEN
THEN
            MOV 4(R15),R8
            MOV 2(R15),R11
            MOV @R15+,R12
            MOV #0,R5
            MOV #0,2(R15)
            MOV #0,0(R15)
            MOV #0,R10
            MOV #1,R9
BEGIN       BIT R9,R12
    0<> IF  ADD R8,2(R15)
            ADDC R11,0(R15)
            ADDC R5,R10
    THEN    ADD R8,R8
            ADDC R11,R11
            ADDC R5,R5
            ADD R9,R9
U>= UNTIL
MOV R14,R11
MOV @R15,R14
MOV 2(R15),R12

MOV #32,R5
CALL #$408E
MOV @R15+,0(R15)
BIT #$200,R2
0<> IF
    XOR #-1,0(R15)
    XOR #-1,R14
    ADD #1,0(R15)
    ADDC #0,R14
    BIC #$200,R2
    CMP #0,R10
    0<> IF
        SUB #1,0(R15)
        SUBC #0,R14 
    THEN
THEN                
MOV @R13+,R0
ENDCODE
[THEN]

[ELSE]

[UNDEFINED] M*/ [IF]
CODE M*/
MOV 4(R15),&$4D4
MOV 2(R15),&$4D6
MOV @R15+,&$4C8
MOV R14,R11
MOV R0,R0
MOV &$4E4,R12
MOV &$4E6,R14
MOV &$4E8,R10
BIC #$200,R2
CMP #0,R10
S< IF
    XOR #-1,R12
    XOR #-1,R14
    XOR #-1,R10
    ADD #1,R12
    ADDC #0,R14
    ADDC #0,R10
    BIS #$200,R2
THEN
MOV #32,R5
CALL #$408E
MOV @R15+,0(R15)
BIT #$200,R2
0<> IF
    XOR #-1,0(R15)
    XOR #-1,R14
    ADD #1,0(R15)
    ADDC #0,R14
    BIC #$200,R2
    CMP #0,R10
    0<> IF
        SUB #1,0(R15)
        SUBC #0,R14 
    THEN
THEN                
MOV @R13+,R0
ENDCODE
[THEN]

[THEN]  ; end of software/hardware_MPY

[UNDEFINED] 2VARIABLE [IF]
: 2VARIABLE
CREATE 
HI2LO
ADD #4,&$1DC6
MOV @R1+,R13
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 2CONSTANT [IF]
: 2CONSTANT
CREATE
, ,
DOES>
2@
;
[THEN]

[UNDEFINED] 2VALUE [IF]
: 2VALUE
CREATE , ,
DOES>
HI2LO
MOV @R1+,R13
BIT #$200,R2
0= IF
   MOV #2@,R0
THEN 
BIC #$200,R2
MOV #2!,R0
ENDCODE
[THEN]

[UNDEFINED] 2LITERAL [IF]
CODE 2LITERAL
BIS #$200,R2
MOV #LITERAL,R0
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] D.R [IF]
: D.R
>R SWAP OVER DABS <# #S ROT SIGN #> 
R> OVER - SPACES TYPE 
;
[THEN]

[THEN]

RST_HERE


[UNDEFINED] VARIABLE [IF]
: VARIABLE
CREATE 
HI2LO
MOV @R1+,R13
ADD #2,&$1DC6
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

[UNDEFINED] CELLS [IF]
CODE CELLS
ADD R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] ALLOT [IF]
CODE ALLOT
ADD R14,&$1DC6
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DEPTH [IF]
CODE DEPTH
MOV R14,-2(R15)
MOV #$1C80,R14
SUB R15,R14
RRA R14
SUB #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

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

[UNDEFINED] DO [IF]
CODE DO
SUB #2,R15
MOV R14,0(R15)
ADD #2,&$1DC6
MOV &$1DC6,R14
MOV #$404C,-2(R14)
ADD #2,&$1C00
MOV &$1C00,R10
MOV #0,0(R10)
MOV @R13+,R0
ENDCODE IMMEDIATE

CODE LOOP
    MOV #$406E,R9
BW1 ADD #4,&$1DC6
    MOV &$1DC6,R10
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

CODE +LOOP
MOV #$405C,R9
GOTO BW1
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] I [IF]
CODE I
SUB #2,R15
MOV R14,0(R15)
MOV @R1,R14
SUB 2(R1),R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] + [IF]
CODE +
ADD @R15+,R14
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

[UNDEFINED] 0= [IF]
CODE 0=
SUB #1,R14
SUBC R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] SOURCE [IF]
CODE SOURCE
SUB #4,R15
MOV R14,2(R15)
MOV &$1DC0,R14
MOV &$1DC2,0(R15)
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] >IN [IF]
$1DC4 CONSTANT >IN
[THEN]

[UNDEFINED] SWAP [IF]
CODE SWAP
MOV @R15,R10
MOV R14,0(R15)
MOV R10,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DROP [IF]
CODE DROP
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 1+ [IF]
CODE 1+
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] CHAR [IF]
: CHAR
    $20 WORD 1+ C@
;
[THEN]

[UNDEFINED] [CHAR] [IF]
: [CHAR]
    CHAR POSTPONE LITERAL
; IMMEDIATE
[THEN]

[UNDEFINED] 2/ [IF]
CODE 2/
RRA R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] INVERT [IF]
CODE INVERT
XOR #-1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] RSHIFT [IF]
CODE RSHIFT
            MOV @R15+,R10
            AND #$1F,R14
0<> IF
    BEGIN   BIC #1,R2
            RRC R10
            SUB #1,R14
    0= UNTIL
THEN        MOV R10,R14
            MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 0< [IF]
CODE 0<
ADD R14,R14
SUBC R14,R14
XOR #-1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] S>D [IF]
: S>D
    DUP 0<
;
[THEN]

[UNDEFINED] 1- [IF]
CODE 1-
SUB #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] UM/MOD [IF]
CODE UM/MOD
    PUSH #DROP
    MOV #$4074,R0
ENDCODE
[THEN]

[UNDEFINED] SM/REM [IF]
CODE SM/REM
MOV R14,R12
MOV @R15,R11
CMP #0,R14
S< IF
    XOR #-1,R14
    ADD #1,R14
THEN
CMP #0,0(R15)
S< IF
    XOR #-1,2(R15)
    XOR #-1,0(R15)
    ADD #1,2(R15)
    ADDC #0,0(R15)
THEN
PUSHM #3,R13
LO2HI
    UM/MOD
HI2LO
POPM #3,R13
CMP #0,R11
S< IF
    XOR #-1,0(R15)
    ADD #1,0(R15)
THEN
XOR R12,R11
CMP #0,R11
S< IF
    XOR #-1,R14
    ADD #1,R14
THEN
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] FM/MOD [IF]
: FM/MOD
SM/REM
HI2LO
CMP #0,0(R15)
0<> IF
    CMP #1,R14
    S< IF
      ADD R12,0(R15)
      SUB #1,R14
    THEN
THEN
MOV @R1+,R13
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] NIP [IF]
CODE NIP
ADD #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] / [IF]
: /
>R DUP 0< R> FM/MOD NIP
;
[THEN]

[UNDEFINED] NEGATE [IF]
CODE NEGATE
XOR #-1,R14
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] HERE [IF]
CODE HERE
MOV #$402C,R0
ENDCODE
[THEN]

[UNDEFINED] CHARS [IF]
CODE CHARS
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] MOVE [IF]
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

 0 CONSTANT FALSE
-1 CONSTANT TRUE

VARIABLE VERBOSE
    FALSE VERBOSE !


VARIABLE ACTUAL-DEPTH
CREATE ACTUAL-RESULTS 20 CELLS ALLOT

: T{
    ;

: ->
    DEPTH DUP ACTUAL-DEPTH !
    ?DUP IF
        0 DO ACTUAL-RESULTS I CELLS + ! LOOP
    THEN ;

: }T

    DEPTH ACTUAL-DEPTH @ = IF
        DEPTH ?DUP IF
        0 DO
            ACTUAL-RESULTS I CELLS + @
            = 0= IF TRUE ABORT" INCORRECT RESULT" THEN
        LOOP
        THEN
    ELSE
        TRUE ABORT" WRONG NUMBER OF RESULTS"
    THEN ;

: TESTING
    SOURCE VERBOSE @
    IF DUP >R TYPE CR R> >IN !
    ELSE >IN ! DROP [CHAR] * EMIT
    THEN ;

-1 CONSTANT 1S
0 CONSTANT <FALSE>
-1 CONSTANT <TRUE>
0 INVERT 1 RSHIFT           CONSTANT MAX-INT    ; 011...1
0 INVERT 1 RSHIFT INVERT    CONSTANT MIN-INT    ; 100...0
MAX-INT 2/                  CONSTANT HI-INT     ; 001...1 
MIN-INT 2/                  CONSTANT LO-INT     ; 110...0
-1 MAX-INT                  2CONSTANT MAX-2INT  ; 011...1 
0 MIN-INT                   2CONSTANT MIN-2INT  ; 100...0 
MAX-2INT 2/                 2CONSTANT HI-2INT   ; 001...1
MIN-2INT 2/                 2CONSTANT LO-2INT   ; 110...0

ECHO

; --------------------------------------------------------------------------------
; DOUBLE tests
; --------------------------------------------------------------------------------

T{ 1 2 2CONSTANT 2c1 -> }T 
T{ 2c1 -> 1 2 }T
T{ : cd1 2c1 ; -> }T 
T{ cd1 -> 1 2 }T

T{ : cd2 2CONSTANT ; -> }T 
T{ -1 -2 cd2 2c2 -> }T 
T{ 2c2 -> -1 -2 }T

T{ 4 5 2CONSTANT 2c3 IMMEDIATE 2c3 -> 4 5 }T 
T{ : cd6 2c3 2LITERAL ; cd6 -> 4 5 }T

T{ 2VARIABLE 2v1 -> }T 
T{ 0. 2v1 2! ->    }T 
T{    2v1 2@ -> 0. }T 
T{ -1 -2 2v1 2! ->       }T 
T{       2v1 2@ -> -1 -2 }T
T{ : cd2 2VARIABLE ; -> }T 
T{ cd2 2v2 -> }T 
T{ : cd3 2v2 2! ; -> }T 
T{ -2 -1 cd3 -> }T 
T{ 2v2 2@ -> -2 -1 }T

T{ 2VARIABLE 2v3 IMMEDIATE 5 6 2v3 2! -> }T 
T{ 2v3 2@ -> 5 6 }T

T{ : cd1 [ MAX-2INT ] 2LITERAL ; -> }T
T{ cd1 -> MAX-2INT }T
T{ 2VARIABLE 2v4 IMMEDIATE 5 6 2v4 2! -> }T 
T{ : cd7 2v4 [ 2@ ] 2LITERAL ; cd7 -> 5 6 }T 
T{ : cd8 [ 6 7 ] 2v4 [ 2! ] ; 2v4 2@ -> 6 7 }T

T{ 1 2 2VALUE t2val -> }T 
T{ t2val -> 1 2 }T 
T{ 3 4 TO t2val -> }T 
T{ t2val -> 3 4 }T 
: sett2val t2val 2SWAP TO t2val ; 
T{ 5 6 sett2val t2val -> 3 4 5 6 }T

T{  0.  5. D+ ->  5. }T
T{ -5.  0. D+ -> -5. }T 
T{  1.  2. D+ ->  3. }T 
T{  1. -2. D+ -> -1. }T 
T{ -1.  2. D+ ->  1. }T 
T{ -1. -2. D+ -> -3. }T 
T{ -1.  1. D+ ->  0. }T
T{  0  0  0  5 D+ ->  0  5 }T
T{ -1  5  0  0 D+ -> -1  5 }T 
T{  0  0  0 -5 D+ ->  0 -5 }T 
T{  0 -5 -1  0 D+ -> -1 -5 }T 
T{  0  1  0  2 D+ ->  0  3 }T 
T{ -1  1  0 -2 D+ -> -1 -1 }T 
T{  0 -1  0  2 D+ ->  0  1 }T 
T{  0 -1 -1 -2 D+ -> -1 -3 }T 
T{ -1 -1  0  1 D+ -> -1  0 }T

T{ MIN-INT 0 2DUP D+ -> 0 1 }T 
T{ MIN-INT S>D MIN-INT 0 D+ -> 0 0 }T

T{  HI-2INT       1. D+ -> 0 HI-INT 1+ }T
T{  HI-2INT     2DUP D+ -> 1S 1- MAX-INT }T 
T{ MAX-2INT MIN-2INT D+ -> -1. }T 
T{ MAX-2INT  LO-2INT D+ -> HI-2INT }T 
T{  LO-2INT     2DUP D+ -> MIN-2INT }T 
T{  HI-2INT MIN-2INT D+ 1. D+ -> LO-2INT }T

T{  0.  5. D- -> -5. }T
T{  5.  0. D- ->  5. }T 
T{  0. -5. D- ->  5. }T 
T{  1.  2. D- -> -1. }T 
T{  1. -2. D- ->  3. }T 
T{ -1.  2. D- -> -3. }T 
T{ -1. -2. D- ->  1. }T 
T{ -1. -1. D- ->  0. }T 
T{  0  0  0  5 D- ->  0 -5 }T
T{ -1  5  0  0 D- -> -1  5 }T 
T{  0  0 -1 -5 D- ->  1  4 }T 
T{  0 -5  0  0 D- ->  0 -5 }T 
T{ -1  1  0  2 D- -> -1 -1 }T 
T{  0  1 -1 -2 D- ->  1  2 }T 
T{  0 -1  0  2 D- ->  0 -3 }T 
T{  0 -1  0 -2 D- ->  0  1 }T 
T{  0  0  0  1 D- ->  0 -1 }T
T{ MIN-INT 0 2DUP D- -> 0. }T 
T{ MIN-INT S>D MAX-INT 0 D- -> 1 1S }T 
T{ MAX-2INT max-2INT D- -> 0. }T
T{ MIN-2INT min-2INT D- -> 0. }T 
T{ MAX-2INT  hi-2INT D- -> lo-2INT DNEGATE }T 
T{  HI-2INT  lo-2INT D- -> max-2INT }T 
T{  LO-2INT  hi-2INT D- -> min-2INT 1. D+ }T 
T{ MIN-2INT min-2INT D- -> 0. }T 
T{ MIN-2INT  lo-2INT D- -> lo-2INT }T

T{                0. D0< -> <FALSE> }T 
T{                1. D0< -> <FALSE> }T 
T{  MIN-INT        0 D0< -> <FALSE> }T 
T{        0  MAX-INT D0< -> <FALSE> }T 
T{          MAX-2INT D0< -> <FALSE> }T 
T{               -1. D0< -> <TRUE>  }T 
T{          MIN-2INT D0< -> <TRUE>  }T

T{               1. D0= -> <FALSE> }T 
T{ MIN-INT        0 D0= -> <FALSE> }T 
T{         MAX-2INT D0= -> <FALSE> }T 
T{      -1  MAX-INT D0= -> <FALSE> }T 
T{               0. D0= -> <TRUE>  }T 
T{              -1. D0= -> <FALSE> }T 
T{       0  MIN-INT D0= -> <FALSE> }T

T{              0. D2* -> 0. D2* }T 
T{ MIN-INT       0 D2* -> 0 1 }T 
T{         HI-2INT D2* -> MAX-2INT 1. D- }T 
T{         LO-2INT D2* -> MIN-2INT }T

T{       0. D2/ -> 0.        }T 
T{       1. D2/ -> 0.        }T 
T{      0 1 D2/ -> MIN-INT 0 }T 
T{ MAX-2INT D2/ -> HI-2INT   }T 
T{      -1. D2/ -> -1.       }T 
T{ MIN-2INT D2/ -> LO-2INT   }T

T{       0.       1. D< -> <TRUE>  }T 
T{       0.       0. D< -> <FALSE> }T 
T{       1.       0. D< -> <FALSE> }T 
T{      -1.       1. D< -> <TRUE>  }T 
T{      -1.       0. D< -> <TRUE>  }T 
T{      -2.      -1. D< -> <TRUE>  }T 
T{      -1.      -2. D< -> <FALSE> }T 
T{      -1. MAX-2INT D< -> <TRUE>  }T 
T{ MIN-2INT MAX-2INT D< -> <TRUE>  }T 
T{ MAX-2INT      -1. D< -> <FALSE> }T 
T{ MAX-2INT MIN-2INT D< -> <FALSE> }T
T{ MAX-2INT 2DUP -1. D+ D< -> <FALSE> }T 
T{ MIN-2INT 2DUP  1. D+ D< -> <TRUE>  }T

T{      -1.      -1. D= -> <TRUE>  }T 
T{      -1.       0. D= -> <FALSE> }T 
T{      -1.       1. D= -> <FALSE> }T 
T{       0.      -1. D= -> <FALSE> }T 
T{       0.       0. D= -> <TRUE>  }T 
T{       0.       1. D= -> <FALSE> }T 
T{       1.      -1. D= -> <FALSE> }T 
T{       1.       0. D= -> <FALSE> }T 
T{       1.       1. D= -> <TRUE>  }T
T{   0   -1    0  -1 D= -> <TRUE>  }T 
T{   0   -1    0   0 D= -> <FALSE> }T 
T{   0   -1    0   1 D= -> <FALSE> }T 
T{   0    0    0  -1 D= -> <FALSE> }T 
T{   0    0    0   0 D= -> <TRUE>  }T 
T{   0    0    0   1 D= -> <FALSE> }T 
T{   0    1    0  -1 D= -> <FALSE> }T 
T{   0    1    0   0 D= -> <FALSE> }T 
T{   0    1    0   1 D= -> <TRUE>  }T

T{ MAX-2INT MIN-2INT D= -> <FALSE> }T 
T{ MAX-2INT       0. D= -> <FALSE> }T 
T{ MAX-2INT MAX-2INT D= -> <TRUE>  }T 
T{ MAX-2INT HI-2INT  D= -> <FALSE> }T 
T{ MAX-2INT MIN-2INT D= -> <FALSE> }T 
T{ MIN-2INT MIN-2INT D= -> <TRUE>  }T 
T{ MIN-2INT LO-2INT  D= -> <FALSE> }T 
T{ MIN-2INT MAX-2INT D= -> <FALSE> }T

T{    1234  0 D>S ->  1234   }T 
T{   -1234 -1 D>S -> -1234   }T 
T{ MAX-INT  0 D>S -> MAX-INT }T 
T{ MIN-INT -1 D>S -> MIN-INT }T


T{       1. DABS -> 1.       }T 
T{      -1. DABS -> 1.       }T 
T{ MAX-2INT DABS -> MAX-2INT }T 
T{ MIN-2INT 1. D+ DABS -> MAX-2INT }T

T{       1.       2. DMAX ->  2.      }T 
T{       1.       0. DMAX ->  1.      }T 
T{       1.      -1. DMAX ->  1.      }T 
T{       1.       1. DMAX ->  1.      }T 
T{       0.       1. DMAX ->  1.      }T 
T{       0.      -1. DMAX ->  0.      }T 
T{      -1.       1. DMAX ->  1.      }T 
T{      -1.      -2. DMAX -> -1.      }T
T{ MAX-2INT  HI-2INT DMAX -> MAX-2INT }T 
T{ MAX-2INT MIN-2INT DMAX -> MAX-2INT }T 
T{ MIN-2INT MAX-2INT DMAX -> MAX-2INT }T 
T{ MIN-2INT  LO-2INT DMAX -> LO-2INT  }T

T{ MAX-2INT       1. DMAX -> MAX-2INT }T 
T{ MAX-2INT      -1. DMAX -> MAX-2INT }T 
T{ MIN-2INT       1. DMAX ->  1.      }T 
T{ MIN-2INT      -1. DMAX -> -1.      }T

T{       1.       2. DMIN ->  1.      }T 
T{       1.       0. DMIN ->  0.      }T 
T{       1.      -1. DMIN -> -1.      }T 
T{       1.       1. DMIN ->  1.      }T 
T{       0.       1. DMIN ->  0.      }T 
T{       0.      -1. DMIN -> -1.      }T 
T{      -1.       1. DMIN -> -1.      }T 
T{      -1.      -2. DMIN -> -2.      }T
T{ MAX-2INT  HI-2INT DMIN -> HI-2INT  }T 
T{ MAX-2INT MIN-2INT DMIN -> MIN-2INT }T 
T{ MIN-2INT MAX-2INT DMIN -> MIN-2INT }T 
T{ MIN-2INT  LO-2INT DMIN -> MIN-2INT }T

T{ MAX-2INT       1. DMIN ->  1.      }T 
T{ MAX-2INT      -1. DMIN -> -1.      }T 
T{ MIN-2INT       1. DMIN -> MIN-2INT }T 
T{ MIN-2INT      -1. DMIN -> MIN-2INT }T

T{   0. DNEGATE ->  0. }T 
T{   1. DNEGATE -> -1. }T 
T{  -1. DNEGATE ->  1. }T 
T{ max-2int DNEGATE -> min-2int SWAP 1+ SWAP }T 
T{ min-2int SWAP 1+ SWAP DNEGATE -> max-2int }T

T{       1.       2. 3. 2ROT ->       2. 3.       1. }T 
T{ MAX-2INT MIN-2INT 1. 2ROT -> MIN-2INT 1. MAX-2INT }T

T{       1.       1. DU< -> <FALSE> }T 
T{       1.      -1. DU< -> <TRUE>  }T 
T{      -1.       1. DU< -> <FALSE> }T 
T{      -1.      -2. DU< -> <FALSE> }T
T{ MAX-2INT  HI-2INT DU< -> <FALSE> }T 
T{  HI-2INT MAX-2INT DU< -> <TRUE>  }T 
T{ MAX-2INT MIN-2INT DU< -> <TRUE>  }T 
T{ MIN-2INT MAX-2INT DU< -> <FALSE> }T 
T{ MIN-2INT  LO-2INT DU< -> <TRUE>  }T

T{ HI-2INT   1 M+ -> HI-2INT   1. D+ }T 
T{ MAX-2INT -1 M+ -> MAX-2INT -1. D+ }T 
T{ MIN-2INT  1 M+ -> MIN-2INT  1. D+ }T 
T{ LO-2INT  -1 M+ -> LO-2INT  -1. D+ }T

-3 2 / . ; if floored you see -2 --> 
: ?floored [ -3 2 / -2 = ] LITERAL IF 1. D- THEN ;

T{       5.       7             11 M*/ ->  3. }T 
T{       5.      -7             11 M*/ -> -3. ?floored }T 
T{      -5.       7             11 M*/ -> -3. ?floored }T 
T{      -5.      -7             11 M*/ ->  3. }T 

T{ MAX-2INT       8             16 M*/ -> HI-2INT }T 
T{ MIN-2INT       8             16 M*/ -> LO-2INT }T 
T{ MAX-2INT      -8             16 M*/ -> HI-2INT DNEGATE ?floored }T
T{ MIN-2INT      -8             16 M*/ -> LO-2INT DNEGATE }T

T{ MAX-2INT MAX-INT        MAX-INT M*/ -> MAX-2INT }T 
T{ MAX-2INT MAX-INT 2/     MAX-INT M*/ -> MAX-INT 1- HI-2INT NIP }T 
T{ MIN-2INT LO-2INT NIP DUP NEGATE M*/ -> MIN-2INT }T 
T{ MIN-2INT LO-2INT NIP 1- MAX-INT M*/ -> MIN-INT 3 + HI-2INT NIP 2 + }T 
T{ MAX-2INT LO-2INT NIP DUP NEGATE M*/ -> MAX-2INT DNEGATE }T 
T{ MIN-2INT MAX-INT            DUP M*/ -> MIN-2INT }T

MAX-2INT 71 73 M*/ 2CONSTANT dbl1 
MIN-2INT 73 79 M*/ 2CONSTANT dbl2
: d>ascii
   DUP >R <# DABS #S R> SIGN #>
   HERE SWAP 2DUP 2>R CHARS DUP ALLOT MOVE 2R> 
;

dbl1 d>ascii 2CONSTANT "dbl1" 
dbl2 d>ascii 2CONSTANT "dbl2"

: DoubleOutput 
   CR ." You should see lines duplicated:" CR 
   5 SPACES "dbl1" TYPE CR 
   5 SPACES dbl1 D. CR 
   8 SPACES "dbl1" DUP >R TYPE CR 
   5 SPACES dbl1 R> 3 + D.R CR 
   5 SPACES "dbl2" TYPE CR 
   5 SPACES dbl2 D. CR 
   10 SPACES "dbl2" DUP >R TYPE CR 
   5 SPACES dbl2 R> 5 + D.R CR 
;

T{ DoubleOutput -> }T
