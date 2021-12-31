; -*- coding: utf-8 -*-

ROMDICT         .equ $  ; init DDP with this current address
lastvoclink     .equ voclink
lastforthword   .equ forthlink
lastasmword     .equ asmlink

    .IF THREADS <> 1

lastforthword1  .equ forthlink1
lastforthword2  .equ forthlink2
lastforthword3  .equ forthlink3
lastforthword4  .equ forthlink4
lastforthword5  .equ forthlink5
lastforthword6  .equ forthlink6
lastforthword7  .equ forthlink7
lastforthword8  .equ forthlink8
lastforthword9  .equ forthlink9
lastforthword10 .equ forthlink10
lastforthword11 .equ forthlink11
lastforthword12 .equ forthlink12
lastforthword13 .equ forthlink13
lastforthword14 .equ forthlink14
lastforthword15 .equ forthlink15
lastforthword16 .equ forthlink16
lastforthword17 .equ forthlink17
lastforthword18 .equ forthlink18
lastforthword19 .equ forthlink19
lastforthword20 .equ forthlink20
lastforthword21 .equ forthlink21
lastforthword22 .equ forthlink22
lastforthword23 .equ forthlink23
lastforthword24 .equ forthlink24
lastforthword25 .equ forthlink25
lastforthword26 .equ forthlink26
lastforthword27 .equ forthlink27
lastforthword28 .equ forthlink28
lastforthword29 .equ forthlink29
lastforthword30 .equ forthlink30
lastforthword31 .equ forthlink31

lastasmword1    .equ asmlink1
lastasmword2    .equ asmlink2
lastasmword3    .equ asmlink3
lastasmword4    .equ asmlink4
lastasmword5    .equ asmlink5
lastasmword6    .equ asmlink6
lastasmword7    .equ asmlink7
lastasmword8    .equ asmlink8
lastasmword9    .equ asmlink9
lastasmword10   .equ asmlink10
lastasmword11   .equ asmlink11
lastasmword12   .equ asmlink12
lastasmword13   .equ asmlink13
lastasmword14   .equ asmlink14
lastasmword15   .equ asmlink15
lastasmword16   .equ asmlink16
lastasmword17   .equ asmlink17
lastasmword18   .equ asmlink18
lastasmword19   .equ asmlink19
lastasmword20   .equ asmlink20
lastasmword21   .equ asmlink21
lastasmword22   .equ asmlink22
lastasmword23   .equ asmlink23
lastasmword24   .equ asmlink24
lastasmword25   .equ asmlink25
lastasmword26   .equ asmlink26
lastasmword27   .equ asmlink27
lastasmword28   .equ asmlink28
lastasmword29   .equ asmlink29
lastasmword30   .equ asmlink30
lastasmword31   .equ asmlink31

    .ENDIF

;----------------
; 0FF40h = FRAM_FULL threshold = SIGNATURES - 40h
;----------------

;----------------
; 0FF80h = SIGNATURES AREA, Deep_RST erases only 8 words from 0FF80h to 0FF90h
;----------------
    .org 0FF80h     ; JTAG signature (2 words)
    .word -1
    .word -1
;    .org 0FF84h    ; BSL signature (2 words)
    .word -1
    .word -1
;    .org 0FF88h    ; FR5xxx|FR6xxx JTAG_PASSWORD, up to 0FFFFh
;    .org 0FF88h    ; FR5xxx|FR6xxx encapsulation signature (2 words)
;    .org 0FF88h    ; FR215x|FR235x|FR247x|FR267x  BLS config signature + BSL config (2 words)
    .word -1
    .word -1
    .word -1
    .word -1
;    .org 0FF90h    ; free (not erased by DEEP RESET)
    .word -1
    .word -1
    .word -1
    .word -1
    .word -1
    .word -1
    .word -1
    .word -1

;----------------
; FFA0h =  FR215x|FR235x|FR247x|FR267x BSL I2C Address, a good idea for I2C_SLAVE_ADR(s) area, isn't it?
;----------------
    .word 077h  ; --> FR215x|FR235x|FR247x|FR267x BSL I2C 7 bits address (without R/W flag)
    .word 10h   ; --> UCBxI2COA0 8 bits address (with R/W flag=0)
    .word 12h   ; --> UCBxI2COA1
    .word 14h   ; --> UCBxI2COA2
    .word 16h   ; --> UCBxI2COA3
    .word 0

;----------------
; FFACh = VECTORS AREA (lowest known vector interrupt)
;----------------
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
;    .org 0FFE0h ; BSL_PASSWORD, 32 bytes
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD
    .word COLD          ; USER_NMI vector, don't change this value !
    .word COLD          ; SYS_NMI vector
    .word RESET         ; RST vector, used once after programming, because RESET code changes RST PIN to USER_NMI PIN

    .org TERM_VEC       ; will generate overlap warning, don't care
    .word TERMINAL_INT  ; TERMINAL vector (UART or I2C_Slave)
