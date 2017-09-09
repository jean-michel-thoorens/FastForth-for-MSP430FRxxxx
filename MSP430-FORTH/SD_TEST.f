
\ how to test SD_CARD driver on your launchpad:


\ remove the jumpers RX, TX of programming port (don't remove GND, TST, RST and VCC)
\ wire PL2303TA/HXD: GND <-> GND, RX <-- TX, TX --> RX
\ connect it to your PC on a free USB port
\ connect the PL2303TA/HXD cable to your PC on another free USB port
\ configure TERATERM as indicated in forthMSP430FR.asm


\ if you have a MSP-EXP430FR5994 launchpad, program it with MSP_EXP430FR5994_3Mbds_SD_CARD.txt
\ to do, drag and drop this file onto prog.bat
\ nothing else to do!


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




\ format FAT16 or FAT32 a SD_CARD memory (max 64GB) with "FRxxxx" in the disk name
\ drag and drop \CONDCOMP\MISC folder on the root of this SD_CARD memory (FastForth doesn't do yet)
\ put it in your target SD slot
\ if no reset, type COLD from the console input (teraterm) to reset FAST FORTH

\ with MSP430FR5xxx or MSP430FR6xxx targets, you can first set RTC:
\ by downloading RTC.f with SendSourceFileToTarget.bat
\ then terminal input asks you to type (with spaces) (DMY), then (HMS) (or (HM)),
\ So, subsequent copied files will be dated:

\ with CopySourceFileToTarget_SD_Card.bat (or better, from scite editor, menu tools):

\   copy TESTASM.4TH        to \MISC\TESTASM.4TH    (add path \MISC in the window opened by TERATERM)
\   copy TSTWORDS.4TH       to \TSTWORDS.4TH
\   copy CORETEST_xMPY.4TH  to \CORETEST.4TH        (x=S for FR4133, else x=H; suppr _xMPY in the window opened by TERATERM)
\   copy SD_TOOLS.f         to \SD_TOOLS.4TH
\   copy SD_TEST.f          to \SD_TEST.4TH
\   copy PROG10k.f          to \PROG10k.4TH
\   copy RTC.f              to \RTC.4TH             ( doesn't work with if FR2xxx or FR4xxx)




: SD_TEST
    ECHO CR
    ."    1 Load ANS core tests" CR
    ."    2 Load, compile and run a 10k program "
            ." from its source file (quiet mode)" CR
    ."    3 Read only this source file (quiet mode)" CR
    ."    4 Write a dump of the FORTH kernel to yourfile.txt" CR
    ."    5 append a dump of the FORTH kernel to yourfile.txt" CR
    ."    6 Load truc (test error)" CR
    ."    7 Set date and time" CR
    ."    your choice : "
    KEY
    48 - 
    DUP 1 = 
    IF  .
        LOAD" CORETEST.4TH"
    ELSE DUP 2 =
        IF  .
            LOAD" PROG10K.4TH"
        ELSE DUP 3 =
            IF  .
                READ" PROG10K.4TH"
                BEGIN
                    READ    \ sequentially read 512 bytes
                UNTIL       \ prog10k.4TH is closed
            ELSE DUP 4 =
                IF  .
                    DEL" YOURFILE.TXT"
                    WRITE" YOURFILE.TXT"
                    ['] SD_EMIT IS EMIT
                    PROGRAMSTART HERE OVER - DUMP
                    ['] (EMIT) IS EMIT
                    CLOSE
                ELSE DUP 5 =
                    IF  .
                        WRITE" YOURFILE.TXT"
                        ['] SD_EMIT IS EMIT
                        PROGRAMSTART HERE OVER - DUMP
                        ['] (EMIT) IS EMIT
                        CLOSE
                    ELSE DUP 6 =
                        IF  .
                            LOAD" truc"
                        ELSE DUP 7 =
                            IF  .
                                LOAD" RTC.4TH"
                            ELSE 
                                DROP ." ?"
                                CR ."    loading TSTWORDS.4TH..."
                                LOAD" TSTWORDS.4TH"
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
;

;      It's done..."

SD_TEST
