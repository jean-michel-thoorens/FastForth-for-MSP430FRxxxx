; -*- coding: utf-8 -*-
; ThingsInLast.inc

;-------------------------------------------------------------------------------
; IT'S FINISH : RESOLVE ASSEMBLY PTR
;-------------------------------------------------------------------------------

ROMDICT         ; init DDP with this current address
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

    .org 0FFFEh
    .word reset