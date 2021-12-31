; -*- coding: utf-8 -*-
; TargetInit.asm
; to Init I/O, Clock, FRAM, RTC, ... only for FastForth and SD_options use
    .IFDEF MSP_EXP430FR5739
    .include "MSP_EXP430FR5739.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MSP_EXP430FR5969
    .include "MSP_EXP430FR5969.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MSP_EXP430FR5994
    .include "MSP_EXP430FR5994.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MSP_EXP430FR6989
    .INCLUDE "MSP_EXP430FR6989.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MSP_EXP430FR4133
    .INCLUDE "MSP_EXP430FR4133.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MSP_EXP430FR2433
    .include "MSP_EXP430FR2433.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MSP_EXP430FR2355
    .include "MSP_EXP430FR2355.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF LP_MSP430FR2476
    .include "LP_MSP430FR2476.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF CHIPSTICK_FR2433
    .include "CHIPSTICK_FR2433.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .save
    .listing off
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
; add here your target.asm item:
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    .restore
    .IFDEF MY_MSP430FR5734
    .include "MY_MSP430FR5734.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MY_MSP430FR5738
    .include "MY_MSP430FR5738.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MY_MSP430FR5738_1
    .include "MY_MSP430FR5738.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MY_MSP430FR5738_2
    .include "MY_MSP430FR5738.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MY_MSP430FR5948
    .include "MY_MSP430FR5948.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF MY_MSP430FR5948_1
    .include "MY_MSP430FR5948_1.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX_2021_03_02
    .include "JMJ_BOX_2021_03_02.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX_2021_05_04
    .include "JMJ_BOX_2021_05_04.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX
    .include "MY_MSP430FR5738.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX_2018_10_29
    .include "JMJ_BOX_2018_10_29.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX_2018_08
    .include "MY_MSP430FR5738.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX_GUILLAUME
    .include "MY_MSP430FR5738_2.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF JMJ_BOX_FAVRE
    .include "MY_MSP430FR5738_2.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF PA8_PA_MSP430
    .include "MY_MSP430FR5738_2.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF PA_PA_MSP430
    .include "MY_MSP430FR5738_2.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
    .IFDEF PA_Core_MSP430
    .include "MY_MSP430FR5948_1.asm" ; choose always Px0 to Px3 as RTS pin!!!
    .ENDIF
