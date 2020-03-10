
; ----------
; CORDIC.4th for MSP_EXP430FR5994
; ----------
; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------

[DEFINED] {CORDIC} [IF] {CORDIC} [THEN]

MARKER {CORDIC}



CREATE T_ARCTAN
11520 ,
6801 ,
3593 ,
1824 ,
916 ,
458 ,
229 ,
115 ,
57 ,
29 ,
14 ,
7 ,
4 ,
2 ,
1 ,

CREATE T_SCALE
46340 ,
41448 ,
40211 ,
39900 ,
39822 ,
39803 ,
39798 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,

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

$81EF $1A04 @ U< 
$1A04 @ $81F3 U<
= [IF]   ; MSP430FR413x subfamily without hardware_MPY

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

ASM XSCALE
SUB #4,R15
MOV R14,2(R15)
MOV R9,0(R15)
MOV T_SCALE(R10),R14
MOV @R15,R12
CMP #0,R12
S< IF
    XOR #-1,0(R15)
    ADD #1,0(R15)
THEN
PUSHM #6,R13
LO2HI
UM*       
HI2LO
POPM #6,R13
CMP #0,R12
S< IF
    XOR #-1,0(R15)
    XOR #-1,R14
    ADD #1,0(R15)
    ADDC #0,R14
THEN
MOV R14,R9
ADD #2,R15
MOV @R15+,R14
MOV @R1+,R0
ENDASM



[ELSE] ; hardware multiplier

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

ASM XSCALE
MOV R9,&$4C0
MOV T_SCALE(R10),&$4C8
MOV &$4E6,R9
MOV @R1+,R0
ENDASM

[THEN]  ; endcase of hardware multiplier


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

[THEN]

CODE POL2REC
PUSH R13
MOV @R15+,R8
SWPB R8
AND #$00FF,R8
SWPB R14
AND #$FF00,R14
BIS R8,R14
MOV #-1,R13
MOV @R15,R9
MOV #0,R8
 BEGIN
    ADD #1,R13
    MOV R9,R12
    MOV R8,R11
    MOV #0,R10
    GOTO FW1
    BEGIN
        RRA R12
        RRA R11
        ADD #1,R10
FW1     CMP R13,R10
    0= UNTIL
    ADD R10,R10
    CMP #0,R14
    0>= IF
        SUB R11,R9
        ADD R12,R8
        SUB T_ARCTAN(R10),R14
    ELSE
        ADD R11,R9
        SUB R12,R8
        ADD T_ARCTAN(R10),R14
    THEN
    CMP #0,R14
    0<> WHILE
        CMP #14,R13
 0= UNTIL
    THEN
CALL #XSCALE
MOV R9,0(R15)
MOV R8,R9
CALL #XSCALE
MOV R9,R14
MOV @R1+,R13
MOV @R13+,R0
ENDCODE


CODE REC2POL
MOV @R15,R9
MOV R14,R8
MOV R8,R11
CMP #0,R11
S< IF
    XOR #-1,R11
    ADD #1,R11
THEN
MOV #-1,R14
MOV R9,R12
ADD R11,R12
0= IF 
    LO2HI 
        ABORT" null inputs"
    HI2LO
THEN
CMP R9,R11
U< IF
    MOV R9,R11
THEN
CMP #16384,R11
    U>= IF
    LO2HI
        ABORT" x or |y| >= 16384"
    HI2LO
    THEN
MOV #1,R12
RLAM #3,R11
GOTO FW1
BEGIN
    ADD R9,R9
    ADD R8,R8
    ADD R12,R12
    ADD R11,R11
FW1
U>= UNTIL
PUSHM #2,R13
MOV #-1,R13
MOV #0,R14
 BEGIN
    ADD #1,R13
    MOV R9,R12
    MOV R8,R11
    MOV #0,R10
    GOTO FW1
    BEGIN
        RRA R12
        RRA R11
        ADD #1,R10
FW1     CMP R13,R10
    0= UNTIL
    ADD R10,R10
    CMP #0,R8
    0>= IF
        ADD R11,R9
        SUB R12,R8
        ADD T_ARCTAN(R10),R14
    ELSE
        SUB R11,R9
        ADD R12,R8
        SUB T_ARCTAN(R10),R14
    THEN
    CMP #0,R8
    0<> WHILE
    CMP #14,R13
 0= UNTIL
    THEN
CALL #XSCALE
POPM #2,R13
GOTO FW1                
BEGIN
    RRA R9
FW1 RRA R12
U>= UNTIL
MOV R9,0(R15)
MOV R14,R8
SWPB R14
AND #$00FF,R14
SXT R14
SWPB R8
AND #$FF00,R8
SUB #2,R15
MOV R8,0(R15)
MOV @R13+,R0
ENDCODE

PWR_HERE

[UNDEFINED] SWAP [IF]
CODE SWAP
MOV @R15,R10
MOV R14,0(R15)
MOV R10,R14
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

: 1000CORDIC
500 0 DO
    POL2REC REC2POL
LOOP 
;

ECHO

; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------

10000 89,0 POL2REC . .  ; sin, cos --> 
10000 75,0 POL2REC . .  ; sin, cos --> 
10000 60,0 POL2REC . .  ; sin, cos --> 
10000 45,0 POL2REC . .  ; sin, cos --> 
10000 30,0 POL2REC . .  ; sin, cos --> 
10000 15,0 POL2REC . .  ; sin, cos --> 
10000 1,0 POL2REC . .   ; sin, cos --> 
16384 30,0 POL2REC SWAP . . ; x, y --> 
16384 45,0 POL2REC SWAP . . ; x, y --> 
16384 60,0 POL2REC SWAP . . ; x, y --> 


2  1  REC2POL F. .          ; phase module --> 
2 -1  REC2POL F. .          ; phase module --> 
20  10  REC2POL F. .        ; phase module --> 
20 -10  REC2POL F. .        ; phase module --> 
200 100 REC2POL F. .        ; phase module --> 
100 -100 REC2POL F. .       ; phase module --> 
2000 1000 REC2POL F. .      ; phase module --> 
1000 -1000 REC2POL F. .     ; phase module --> 
16000 8000 REC2POL F. .     ; phase module --> 
16000 -8000 REC2POL F. .    ; phase module --> 
16000 0 REC2POL F. .        ; phase module --> 
0 16000 REC2POL F. .        ; phase module --> 


10000 89,0 POL2REC REC2POL   ROT . F. 
10000 75,0 POL2REC REC2POL   ROT . F. 
10000 60,0 POL2REC REC2POL   ROT . F. 
10000 45,0 POL2REC REC2POL   ROT . F. 
10000 30,0 POL2REC REC2POL   ROT . F. 
10000 26,565 POL2REC REC2POL ROT . F. 
10000 15,0 POL2REC REC2POL   ROT . F. 
10000 14,036 POL2REC REC2POL ROT . F. 
10000 7,125 POL2REC REC2POL  ROT . F. 
10000 1,0 POL2REC REC2POL    ROT . F. 

10000 89,0   1000CORDIC      ROT . F.
10000 75,0   1000CORDIC      ROT . F.
10000 60,0   1000CORDIC      ROT . F.
10000 45,0   1000CORDIC      ROT . F.
10000 30,0   1000CORDIC      ROT . F.
10000 26,565 1000CORDIC      ROT . F.
10000 15,0   1000CORDIC      ROT . F.
10000 14,036 1000CORDIC      ROT . F.
10000 7,125  1000CORDIC      ROT . F.
10000 1,0    1000CORDIC      ROT . F.

PWR_STATE
