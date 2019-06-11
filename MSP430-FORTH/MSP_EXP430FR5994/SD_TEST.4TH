
; -----------
; SD_TEST.4th
; -----------

PWR_STATE

[UNDEFINED] {SD_TEST} [IF]

MARKER {SD_TEST}

[UNDEFINED] PLUS [IF]
CODE +
ADD @R15+,R14
MOV @R13+,R0
ENDCODE
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

[UNDEFINED] C@ [IF]
CODE C@
MOV.B @R14,R14
MOV @R13+,R0
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
  SWAP
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


CODE SD_EMIT
CMP #512,&$201E
U>= IF
    MOV #WRITE,R9
    CALL 2(R9)
THEN
MOV &$201E,R8
MOV.B R14,$1E00(R8)
ADD #1,&$201E
MOV @R15+,R14
MOV @R13+,R0
ENDCODE

: SD_TEST
PWR_HERE
CR
." 0 Set date and time" CR
." 1 Load {TOOLS} words" CR
." 2 Load {SD_TOOLS} words" CR
." 3 Load {ANS_COMP} words" CR
." 4 Load ANS core tests" CR
." 5 Load a 100k program " CR
." 6 Read only this source file" CR
." 7 append a dump of FORTH to YOURFILE.TXT" CR
." 8 delete YOURFILE.TXT" CR
." 9 Load TST_WORDS" CR
." your choice : "
KEY
48 - ?DUP
0= IF
    ." LOAD RTC.4TH" CR
    LOAD" RTC.4TH"
ELSE 1 - ?DUP
    0= IF
        ." LOAD UTILITY.4TH" CR
        LOAD" UTILITY.4TH"
    ELSE 1 - ?DUP
        0= IF
            ." LOAD SD_TOOLS.4TH" CR
            LOAD" SD_TOOLS.4TH"
        ELSE 1 - ?DUP
            0= IF
                ." LOAD ANS_COMP.4TH" CR
                LOAD" ANS_COMP.4TH"
            ELSE 1 - ?DUP
                0= IF
                    ." LOAD CORETEST.4TH" CR
                    LOAD" CORETEST.4TH"
                    PWR_STATE
                ELSE 1 - ?DUP
                    0= IF
                        ." LOAD PROG100K.4TH" CR
                        NOECHO
                        LOAD" PROG100K.4TH"
                    ELSE 1 - ?DUP
                        0= IF
                            ." READ PROG100K.4TH" CR
                            READ" PROG100K.4TH"
                            BEGIN
                                READ
                            UNTIL
                        ELSE 1 - ?DUP
                            0= IF
                                ." WRITE YOURFILE.TXT" CR
                                WRITE" YOURFILE.TXT"
                                ['] SD_EMIT IS EMIT
                                $4000 HERE OVER - DUMP
                                ['] EMIT >BODY IS EMIT
                                CLOSE
                            ELSE 1 - ?DUP
                                0= IF
                                    ." DEL YOURFILE.TXT" CR
                                    DEL" YOURFILE.TXT"
                                ELSE 1 - ?DUP
                                    0= IF
                                        ." LOAD TSTWORDS.4TH" CR
                                        LOAD" TSTWORDS.4TH"
                                    ELSE
                                        ." abort" CR EXIT
                                    THEN                                        
                                THEN
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
THEN
;

RST_HERE

[THEN]

ECHO SD_TEST
