
; ------------------------------------------------------------------------------
; UTILITY.4th
; ------------------------------------------------------------------------------


[UNDEFINED] {TOOLS} [IF]

PWR_STATE

MARKER {TOOLS} 

[UNDEFINED] ? [IF]
CODE ?          
    MOV @R14,R14
    MOV #U.,R0
ENDCODE
[THEN]

[UNDEFINED] SPACE [IF]
: SPACE
$20 EMIT ;
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

[UNDEFINED] .S [IF]
CODE .S
    MOV     R14,-2(R15)
    MOV     R15,R14
    SUB     #2,R14
    MOV     R14,-6(R15)
    MOV     #$1C80,R14
    SUB     #2,R14
BW1 MOV     R14,-4(R15)
    SUB     #6,R15
    SUB     @R15,R14
    RRA     R14
COLON
    $3C EMIT
    .
    $08 EMIT
    $3E EMIT SPACE
    2DUP 1+
    U< IF 
        DROP DROP EXIT
    THEN
    $1DDC @ >R
    $10 $1DDC !
    DO 
        I @ U.
    2 +LOOP
    R> $1DDC !
;
[THEN]

[UNDEFINED] .RS [IF]
CODE .RS
    MOV     R14,-2(R15)
    MOV     R1,-6(R15)
    MOV     #$1CE0,R14
    GOTO    BW1
ENDCODE
[THEN]

[UNDEFINED] + [IF]
CODE +
ADD @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] C@ [IF]
CODE C@
MOV.B @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] AND [IF]
CODE AND
AND @R15+,R14
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

[UNDEFINED] WORDS [IF]
: WORDS
CR 
$1DCA @ $1CE4
$1800 @ DUP +
MOVE
BEGIN
    0 DUP
    $1800 @ DUP + 0
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
    DUP
    COUNT $7F AND
    TYPE
    C@ $0F AND
    $10 SWAP - SPACES
REPEAT
DROP
;
[THEN]

[UNDEFINED] MAX [IF]
    CODE MAX
        CMP @R15,R14
        S< ?GOTO FW1
BW1     ADD #2,R15
        MOV @R13+,R0
    ENDCODE

    CODE MIN
        CMP @R15,R14
        S< ?GOTO BW1
FW1     MOV @R15+,R14
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

[UNDEFINED] U.R [IF]
: U.R
>R  <# 0 # #S #>  
R> OVER - 0 MAX SPACES TYPE
;
[THEN]

[UNDEFINED] DUMP [IF]
CODE DUMP
PUSH R13
PUSH &$1DDC
MOV #$10,&$1DDC
ADD @R15,R14
LO2HI
  SWAP 2DUP
  U. U.
  $FFF0 AND
  DO  CR
    I 4 U.R SPACE
      I 8 + I
      DO I C@ 3 U.R LOOP
      SPACE
      I $10 + I 8 +
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I
      DO I C@ $7E MIN $20 MAX EMIT LOOP
  $10 +LOOP
  R> $1DDC !
;
[THEN]

RST_HERE

[THEN]
