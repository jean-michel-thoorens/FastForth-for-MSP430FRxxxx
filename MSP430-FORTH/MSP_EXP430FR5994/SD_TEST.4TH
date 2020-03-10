
; -----------
; SD_TEST.4th for MSP_EXP430FR5994
; -----------

PWR_STATE

[DEFINED] {SD_TEST} [IF]  {SD_TEST} [THEN]

MARKER {SD_TEST}

[UNDEFINED] EXIT [IF]
CODE EXIT
MOV @R1+,R13
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

[UNDEFINED] >BODY [IF]
CODE >BODY
ADD #4,R14
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

[UNDEFINED] BEGIN [IF]
CODE BEGIN
    MOV #$402C,R0
ENDCODE IMMEDIATE

CODE UNTIL
    MOV #$4042,R9
BW1 ADD #4,&$1DC6
    MOV &$1DC6,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R13+,R0
ENDCODE IMMEDIATE

CODE AGAIN
MOV #$403E,R9
GOTO BW1
ENDCODE IMMEDIATE

: WHILE
POSTPONE IF SWAP
; IMMEDIATE

: REPEAT
POSTPONE AGAIN POSTPONE THEN
; IMMEDIATE
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

[UNDEFINED] - [IF]
CODE -
SUB @R15+,R14
XOR #-1,R14
ADD #1,R14
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

[UNDEFINED] @ [IF]
CODE @
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] C@ [IF]
CODE C@
MOV.B @R14,R14
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

[UNDEFINED] OVER [IF]
CODE OVER
MOV R14,-2(R15)
MOV @R15,R14
SUB #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

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

[UNDEFINED] STATE [IF]
$1DBE CONSTANT STATE
[THEN]

[UNDEFINED] IS [IF]
CODE DEFER!
MOV @R15+,2(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE

: IS
STATE @
IF  POSTPONE ['] POSTPONE DEFER! 
ELSE ' DEFER! 
THEN
; IMMEDIATE
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

[UNDEFINED] HERE [IF]
CODE HERE
MOV #BEGIN,R0
ENDCODE
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
." 3 Load {CORE_COMP} words" CR
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
                ." LOAD CORECOMP.4TH" CR
                LOAD" CORECOMP.4TH"
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
