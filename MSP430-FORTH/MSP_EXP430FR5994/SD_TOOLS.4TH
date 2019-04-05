
; ---------------------------------------------------------------
; SD_TOOLS.4th : BASIC TOOLS for SD Card : DIR FAT SECTOR CLUSTER
; ---------------------------------------------------------------

PWR_STATE

: DEFINED! ECHO 1 ABORT" already loaded!" ;

[DEFINED] {SD_TOOLS} [IF] DEFINED!

[ELSE]

MARKER {SD_TOOLS}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE

CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
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

[UNDEFINED] AND [IF]

CODE AND
AND @R15+,R14
MOV @R13+,R0
ENDCODE

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

CODE SECTOR
    MOV     R14,R9
    MOV     @R15,R10
    CALL    &$1818
COLON
    <# #S #> TYPE SPACE
    $1E00 $200 DUMP CR ;

CODE FAT
    SUB     #4,R15
    MOV     R14,2(R15)
    MOV     &$2008,0(R15)
    MOV     #0,R14
    JMP     SECTOR
ENDCODE

CODE CLUSTER
    MOV.B &$2012,R10
    MOV @R15,R9
    RRA R10
    U< IF
        BEGIN
            ADD R9,R9
            ADDC R14,R14
            RRA R10
        U>= UNTIL
    THEN
    ADD     &$2010,R9
    MOV     R9,0(R15)      
    ADDC    #0,R14
    JMP     SECTOR
ENDCODE

CODE DIR
    SUB     #4,R15
    MOV     R14,2(R15)
    MOV     &$202C,0(R15)
    MOV     &$202E,R14
    JMP     CLUSTER
ENDCODE


RST_HERE

[THEN]
ECHO
; added : FAT to DUMP first sector of FAT1 and DIR for that of current DIRectory.
; added : SECTOR to DUMP a sector and CLUSTER for first sector of a cluster:
;         include a decimal point to force 32 bits number, example : .2 CLUSTER

