
; -----------
; SD_TEST.f
; -----------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, SD_CARD_READ_WRITE
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\
\
\ how to test SD_CARD driver on your launchpad:
\
\
\ remove the jumpers RX, TX of programming port (don't remove GND, TST, RST and VCC)
\ wire PL2303TA/HXD: GND <-> GND, RX <-- TX, TX --> RX
\ connect it to your PC on a free USB port
\ connect the PL2303TA/HXD cable to your PC on another free USB port
\ configure TERATERM as indicated in forthMSP430FR.asm
\
\
\ if you have a MSP-EXP430FR5994 launchpad, program it with MSP_EXP430FR5994_3Mbds_SD_CARD.txt
\ to do, drag and drop this file onto prog.bat
\ nothing else to do!
\
\
\ else edit forthMSP430FR.asm with scite editor
\   uncomment your target, copy it
\   paste it into (SHIFT+F8) param1
\   set DTC .equ 1
\       FREQUENCY   .equ 16
\       THREADS     .equ 16
\       TERMINALBAUDRATE    .equ 3000000
\         
\   uncomment:  CONDCOMP
\               MSP430ASSEMBLER
\               SD_CARD_LOADER
\               SD_CARD_READ_WRITE
\ 
\   compile for your target (CTRL+0)
\
\   program your target via TI interface (CTRL+1)
\
\   then wire your SD_Card module as described in your MSP430-FORTH\target.pat file
\
\
\
\ format FAT16 or FAT32 a SD_CARD memory (max 64GB) with "FRxxxx" in the disk name
\ drag and drop \MSP430_COND\MISC folder on the root of this SD_CARD memory (FastForth doesn't do yet)
\ put it in your target SD slot
\ if no reset, type COLD from the console input (teraterm) to reset FAST FORTH
\
\ with MSP430FR5xxx or MSP430FR6xxx targets, you can first set RTC:
\ by downloading RTC.f with SendSourceFileToTarget.bat
\ then terminal input asks you to type (with spaces) (DMY), then (HMS),
\ So, subsequent copied files will be dated:
\
\ with CopySourceFileToTarget_SD_Card.bat (or better, from scite editor, menu tools):
\
\   copy TESTASM.4TH        to \MISC\TESTASM.4TH    (add path \MISC in the window opened by TERATERM)
\   copy TSTWORDS.4TH       to \TSTWORDS.4TH
\   copy CORETEST.4TH       to \CORETEST.4TH
\   copy SD_TOOLS.f         to \SD_TOOLS.4TH
\   copy SD_TEST.f          to \SD_TEST.4TH
\   copy PROG100k.f         to \PROG100k.4TH
\   copy RTC.f              to \RTC.4TH             ( doesn't work with if FR2xxx or FR4xxx)

PWR_STATE

[UNDEFINED] {SD_TEST} [IF]   \

MARKER {SD_TEST}

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] MAX [IF]   \ MAX and MIN are defined in {ANS_COMP}
    CODE MAX    \    n1 n2 -- n3       signed maximum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO FW1    \ n2<n1
    BW1 ADD #2,PSP
        MOV @IP+,PC
    ENDCODE

    CODE MIN    \    n1 n2 -- n3       signed minimum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO BW1    \ n2<n1
    FW1 MOV @PSP+,TOS
        MOV @IP+,PC
    ENDCODE
[THEN]

[UNDEFINED] U.R [IF]    \ defined in {UTILITY}
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
>R  <# 0 # #S #>  
R> OVER - 0 MAX SPACES TYPE
;
[THEN]

[UNDEFINED] DUMP [IF]    \ defined in {UTILITY}
\ https://forth-standard.org/standard/tools/DUMP
CODE DUMP                   \ adr n  --   dump memory
PUSH IP
PUSH &BASE                  \ save current base
MOV #$10,&BASE              \ HEX base
ADD @PSP,TOS                \ -- ORG END
LO2HI
  SWAP OVER OVER            \ -- END ORG END ORG 
  U.  U.                 \ -- END ORG        display org end 
  $FFF0 AND                 \ -- END ORG_modulo_16
  DO  CR                    \ generate line
    I 7 U.R SPACE           \ generate address
      I $10 + I             \ display 16 bytes
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I             \ display 16 chars
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> BASE !                 \ restore current base
;
[THEN]

: SD_TEST
PWR_HERE    \ remove all volatile programs from MAIN memory
ECHO CR
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
                                READ    \ sequentially read 512 bytes
                            UNTIL       \ prog10k.4TH is closed
                        ELSE 1 - ?DUP
                            0= IF
                                ." WRITE YOURFILE.TXT" CR
                                WRITE" YOURFILE.TXT"
                                ['] SD_EMIT IS EMIT
                                MAIN_ORG HERE OVER - DUMP
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

SD_TEST
