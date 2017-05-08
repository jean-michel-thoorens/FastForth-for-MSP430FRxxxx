; ------------------------------------------------------------------------
; BASIC TOOLS for SD Card : {DIR FAT SECTOR CLUSER} DUMP ; include UTILITY
; ------------------------------------------------------------------------

CODE ?
    MOV @R14,R14
    MOV #U.,R0
ENDCODE

CODE SP@
    SUB #2,R15
    MOV R14,0(R15)
    MOV R15,R14
    MOV @R13+,R0
ENDCODE
: .S
$3C EMIT
DEPTH .
8 EMIT
$3E EMIT SPACE
SP@  $1C80 OVER OVER U<
IF  2 -
    DO I @ U.
    -2 +LOOP
ELSE
    DROP DROP
THEN
;

: WORDS
$1DDA @
#10 $1DDA !
CR ."    "
$1800 @ DUP
1 = IF DROP ." monothread"
    ELSE . ." threads"
    THEN ."  vocabularies"
$1DDA !
$1DCA
BEGIN
    DUP 
    2 + SWAP
    @ ?DUP
WHILE
CR ."    "
    DUP $1CE2 $1800 @ DUP +
    MOVE
    BEGIN
        0 DUP
        $1800 @ DUP + 0 DO
        DUP I $1CE2 + @
        U< IF 
            DROP DROP I DUP $1CE2 + @
        THEN
        2 +LOOP
        ?DUP
    WHILE
        DUP
        2 - @
        ROT
        $1CE2 +
        !
                DUP
            COUNT $7F AND TYPE
                C@ $0F AND
                $10 SWAP - SPACES
    REPEAT

    DROP DROP
    CR         
REPEAT
DROP
;

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

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

: DUMP
  $1DDA @ >R $10 $1DDA !
  SWAP $FFF0 AND SWAP
  OVER + SWAP
  DO  CR
    I 7 U.R SPACE
      I $10 + I
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> $1DDA !
;

CODE SECT_D
    MOV     R14,R9
    MOV     @R15,R10
    CALL    &$1814
COLON
    UD.
    $1E00 $200 DUMP CR ;

CODE CLUST_D
    MOV     R14,&$2024
    MOV     @R15,&$2022
BW1 MOV     &$2010,&$4E4
    MOV     #0,&$4E6
    MOV     &$2022,&$4D8
    MOV     &$2024,&$4DA
    MOV     &$2012,&$4C8
    MOV     &$4E4,0(R15)
    MOV     &$4E6,R14
    JMP     SECT_D
ENDCODE

CODE FAT_D
    SUB     #4,R15
    MOV     R14,2(R15)
    MOV     &$202A,0(R15)
    ADD     &$2008,0(R15)
    MOV     #0,R14
    JMP     SECT_D
ENDCODE

CODE DIR_D
    SUB     #4,R15
    MOV     R14,2(R15)
    CMP     #1,&$202E
    0= IF
        CMP.B   #0,&$2030
        0=  IF
            MOV #0,R14
            MOV &$200E,0(R15)
            JMP SECT_D                
        THEN
    THEN
    MOV     &$202E,&$2022
    MOV     &$2030,&$2024
    GOTO    BW1
ENDCODE

ECHO
            ; added : UTILITY : ? SP@ .S WORDS MAX MIN U.R DUMP 
            ; added : FAT_D to DUMP first sector of FAT1 and DIR_D for that of current DIRectory.
            ; added : SECT_D to DUMP a sector and CLUST_D for first sector of a cluster
            ;         include a decimal point to force 32 bits number, example : 2. CLUST_D

PWR_HERE    ; to protect this app against a RESET, type: RST_HERE
