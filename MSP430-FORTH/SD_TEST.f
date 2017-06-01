
\ how to test SD_CARD driver on your target (excepted MSP-EXP430FR4133 without hardware multiplier) :


\ connect the launchpad to your PC on a free USB port
\ on the launchpad remove the jumpers GND, RX, TX of programming port (don't remove TST, RST and VCC jumpers)
\ connect the PL2303TA/HXD cable to your PC on another free USB port
\ wire PL2303TA/HXD to the programming port of your launchpad : GND <-> GND, RX <-- TX, TX --> RX
\ start TERATERM, select PL2303TA/HXD port 
\ configure TERATERM as indicated in forthMSP430FR.asm

\ if you have a MSP-EXP430FR5994, program your launchpad with MSP_EXP430FR5994_3Mbds_SD_CARD.txt via TI interface:
\   to do, drag and drop this file onto MSP430FR5994prog.bat

\ else edit forthMSP430FR.asm with scite editor

\   with (SHIFT+F8), set param1 as your DEVICE and param2 as your TARGET
\   uncomment your target,
\   set DTC .equ 1
\       FREQUENCY   .equ 16
\       THREADS     .equ 16
\       TERMINALBAUDRATE    .equ 3000000
\         
\   uncomment   TERMINALXONXOFF
\               LF_XTAL
\               MSP430ASSEMBLER
\               SD_CARD_LOADER
\               SD_CARD_READ_WRITE
 
\ compile for your target (CTRL+0)
\ then program your target via TI interface (CTRL+1).


\ format FAT16 or FAT32 a SD_CARD memory (max 64GB)
\ create folder \MISC on this SD_CARD memory (FastForth don't do yet)
\ put it in the target SD slot wired as described in MSP430-FORTH\target.pat,

\ type COLD from the console input to reset FAST FORTH,


\ with Send_File.4th_to_SD_CARD_target.bat (or from scite editor, menu tools), send to SD_CARD:
\   CORETSTH.4th
\   TSTWORDS.4th

\ with Send_File.4th_to_SD_CARD_target.bat, send to SD_CARD\MISC:
\   TESTASM.4TH (don't forget to add path \MISC on the 2th window opened by TERATERM)

\ and if don't know how to do, double clic on this bat file.


\ with Send_file.f_to_SD_CARD_target.bat, send to SD_CARD: (on SD_CARD files will have 4th extension)
\   SD_TOOLS.f
\   SD_TEST.f
\   PROG10k.f
\   RTC.f



\ then, from input terminal (TERATERM),
\ LOAD" RTC.4th",  type (with spaces) Day Month Year, then type Hours Minutes Seconds (or Hours Minutes),
\ LOAD" SD_TEST.4TH" that load this file.



LOAD" SD_TOOLS.4TH"
RST_HERE
NOECHO

\ we can see interest of preprocessing that allows the use of the PROGRAMSTART address, not recognized by FASTFORTH
\ in the preprocessed file SD_TEST.4th, PROGRAMSTART will be replaced by its value.
\ PROGRAMSTART is defined in \config\gema\MSP430FR_FastForth.pat

: SD_TEST
    ECHO CR
    ."    1 Load ANS core tests" CR
    ."    2 Load, compile and run a 10k program "
            ." from its source file (quiet mode)" CR
    ."    3 Read only this source file (quiet mode)" CR
    ."    4 Write a dump of the FORTH kernel to yourfile.txt" CR
    ."    5 append a dump of the FORTH kernel to yourfile.txt" CR
    ."    6 Load truc (test error)" CR
    ."    your choice : "
    KEY
    48 - 
    DUP 1 = 
    IF  .
\        LOAD" COMPHMPY.4TH"    \ bug, bug, bug: only 2th line is executed
\        LOAD" CORETST1.4TH"    \ why ?
        LOAD" CORETSTH.4TH"     \ so CORETSTH.4TH is the sum of two previous files
    ELSE DUP 2 =
        IF  .
            LOAD" Prog10k.4th"
        ELSE DUP 3 =
            IF  .
                READ" Prog10k.4th"
                BEGIN
                    READ
                UNTIL
            ELSE DUP 4 =
                IF  .
                    DEL" yourfile.txt"
                    WRITE" yourfile.txt"
                    ['] SD_EMIT IS EMIT
                    PROGRAMSTART HERE OVER - DUMP
                    ['] (EMIT) IS EMIT
                    CLOSE
                ELSE DUP 5 =
                    IF  .
                        WRITE" yourfile.txt"
                        ['] SD_EMIT IS EMIT
                        PROGRAMSTART HERE OVER - DUMP
                        ['] (EMIT) IS EMIT
                        CLOSE
                    ELSE DUP 6 =
                        IF  .
                            LOAD" truc"
                        ELSE 
                            DROP ." ?"
                            CR ."    loading TSTWORDS.4th..."
                            LOAD" TSTWORDS.4TH"
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
    CR ." It's done..."
;

PWR_HERE

SD_TEST
