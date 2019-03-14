
; ------------------------------------------------------------------------------
; UTILITY.4th
; ------------------------------------------------------------------------------

PWR_STATE

[UNDEFINED] {TOOLS} [IF]

MARKER {TOOLS} 

[UNDEFINED] ? [IF]
CODE ?          
    MOV @R14,R14
    MOV #U.,R0
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
    OVER OVER >
    0= IF 
        DROP DROP EXIT
    THEN
    DO 
        I @ U.
    2 +LOOP
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

[UNDEFINED] WORDS [IF]

[UNDEFINED] AND [IF]

CODE AND
AND @R15+,R14
MOV @R13+,R0
ENDCODE

[THEN]

[UNDEFINED] PAD [IF]

$1CE4 CONSTANT PAD

[THEN]


[UNDEFINED] WORDS [IF]
: WORDS
CR 
$1DCA @ PAD
$1800 @ DUP +
MOVE
BEGIN
    0.
    $1800 @ DUP + 0
        DO
        DUP I PAD + @
            U< IF
                DROP DROP
                I DUP PAD + @
            THEN
        2 +LOOP
    ?DUP
WHILE
    DUP
    2 - @
    ROT
    PAD +
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
    BW1 ADD #2,R15
        MOV @R13+,R0
    ENDCODE

    CODE MIN
        CMP @R15,R14
        S< ?GOTO BW1
    FW1 MOV @R15+,R14
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
PUSH &BASE
MOV #$10,&BASE
ADD @R15,R14
LO2HI
  SWAP OVER OVER
  U. U.
  $FFF0 AND
  DO  CR
    I 7 U.R SPACE
      I $10 + I
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> BASE !
;
[THEN]

RST_HERE

[THEN]

ECHO
