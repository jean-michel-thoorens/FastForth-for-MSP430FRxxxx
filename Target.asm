; Target.asm

; to Init I/O, Clock, FRAM....
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
