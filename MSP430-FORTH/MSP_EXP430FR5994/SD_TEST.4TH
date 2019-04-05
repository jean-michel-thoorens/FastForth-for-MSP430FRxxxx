
; -----------
; SD_TEST.4th
; -----------

PWR_STATE

[UNDEFINED] {SD_TEST} [IF]

MARKER {SD_TEST}

[UNDEFINED] AND [IF]
CODE AND
AND @R15+,R14
MOV @R13+,R0
ENDCODE
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
  U.  U.
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
