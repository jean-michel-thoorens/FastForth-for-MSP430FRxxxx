; Target.asm

; to Init I/O, Clock, FRAM, RTC, ... only for FastForth and SD_options use
    .IFDEF MSP_EXP430FR5739
    .include "MSP_EXP430FR5739.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR5969
    .include "MSP_EXP430FR5969.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR5994
    .include "MSP_EXP430FR5994.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR6989
    .INCLUDE "MSP_EXP430FR6989.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR4133
    .INCLUDE "MSP_EXP430FR4133.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR2433
    .include "MSP_EXP430FR2433.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR2355
    .include "MSP_EXP430FR2355.asm"
    .ENDIF
    .IFDEF MSP_EXP430FR2433_I2C
    .include "MSP_EXP430FR2433.asm"
    .ENDIF
    .IFDEF CHIPSTICK_FR2433
    .include "CHIPSTICK_FR2433.asm"
    .ENDIF







    .IFDEF MY_MSP430FR5738
    .include "MY_MSP430FR5738.asm" ; basic init module
    .ENDIF
    .IFDEF MY_MSP430FR5738_1
    .include "MY_MSP430FR5738_1.asm"
    .ENDIF
    .IFDEF MY_MSP430FR5738_2
    .include "MY_MSP430FR5738_2.asm"
    .ENDIF
    .IFDEF MY_MSP430FR5948
    .include "MY_MSP430FR5948.asm"
    .ENDIF
    .IFDEF MY_MSP430FR5948_1
    .include "MY_MSP430FR5948_1.asm"
    .ENDIF
    .IFDEF JMJ_BOX
    .include "MY_MSP430FR5738_2.asm" 
    .ENDIF
    .IFDEF JMJ_BOX_2018_08
    .include "MY_MSP430FR5738_2.asm" 
    .ENDIF
    .IFDEF JMJ_BOX_GUILLAUME
    .include "MY_MSP430FR5738_2.asm" 
    .ENDIF
    .IFDEF JMJ_BOX_FAVRE
    .include "MY_MSP430FR5738_2.asm" 
    .ENDIF
    .IFDEF PA8_PA_MSP430
    .include "MY_MSP430FR5738_2.asm"
    .ENDIF
    .IFDEF PA_PA_MSP430
    .include "MY_MSP430FR5738_2.asm"
    .ENDIF
    .IFDEF PA_Core_MSP430
    .include "MY_MSP430FR5948_1.asm" ; all I/O are inputs with pullup resistor
    .ENDIF
