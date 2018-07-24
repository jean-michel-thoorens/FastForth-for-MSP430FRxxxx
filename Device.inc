; Target.inc

; define if Terminal half duplex
    .IFDEF UARTtoI2C
    .IFNDEF HALFDUPLEX
HALFDUPLEX
    .ENDIF
    .ENDIF



    .IFDEF SD_CARD_LOADER 
    .IFDEF BOOTLOADER
    .IFDEF CONDCOMP
BOOTLOAD
    .ELSE 
        .WARNING "SD Boot Loader requires conditional compilation addon"
CONDCOMP
BOOTLOAD
    .ENDIF
    .ENDIF
    .ENDIF

; define FREQ  used in WARM message (6)
    .IF     FREQUENCY = 0.25
FREQ    .set " .2MHz"
    .ELSEIF FREQUENCY = 0.5
FREQ    .set " .5MHz"
    .ELSEIF FREQUENCY = 1
FREQ    .set "  1MHz"
    .ELSEIF FREQUENCY = 2
FREQ    .set "  2MHz"
    .ELSEIF FREQUENCY = 4
FREQ    .set "  4MHz"
    .ELSEIF FREQUENCY = 8
FREQ    .set "  8MHz"
    .ELSEIF FREQUENCY = 12
FREQ    .set " 12MHz"
    .ELSEIF FREQUENCY = 16
FREQ    .set " 16MHz"
    .ELSEIF FREQUENCY = 20
FREQ    .set " 20MHz"
    .ELSEIF FREQUENCY = 24
FREQ    .set " 24MHz"
    .ELSE   
FREQ    .set "ERRMHz"
    .ENDIF


FRAM_FULL   .equ SIGNATURES-50h ; set to protect JTAG and BSL signatures against overwrite.
                                ; notice that ALLOT memory space beyond SIGNATURES don't corrupt it,
                                ; so 80 bytes are sufficient considering what can be compiled in one line and WORD use.
                                ; good practice: one line reserved for each ALLOT command.


;-----------------------------------------------------------------------
; DEVICE I/O, MEMORY, SFR, vectors and minimum FORTH I/O declarations
;-----------------------------------------------------------------------


    OUTRADIX  10

    .IFDEF TERMINALBAUDRATE
    .warning "TERMINAL \{TERMINALBAUDRATE} bds"
    .endif
    .warning "frequency = \{FREQUENCY} MHz"


    .IFDEF MSP_EXP430FR5739
    .warning "Code for MSP_EXP430FR5739"
LF_XTAL
UCA0_TERM
UCB0_SD
    .include "MSP430FR5739.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR5969
    .warning "Code for MSP_EXP430FR5969"
LF_XTAL
UCA0_TERM
UCA1_SD
    .include "MSP430FR5969.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR5994
    .warning "Code for MSP_EXP430FR5994"
LF_XTAL
UCA0_TERM
UCB0_SD
    .include "MSP430FR5994.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR6989
    .warning "Code for MSP_EXP430FR6989"
LF_XTAL
UCA1_TERM
UCA0_SD
    .INCLUDE "MSP430FR6989.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR4133
    .warning "Code for MSP_EXP430FR4133"
LF_XTAL
UCA0_TERM
UCB0_SD
    .INCLUDE "MSP430FR4133.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2433
    .warning "Code for MSP_EXP430FR2433"
LF_XTAL
UCA0_TERM
UCA1_SD
    .include "MSP430FR2433.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2433_I2C
    .warning "Code for MSP_EXP430FR2433_I2C"
LF_XTAL
UCA1_SD
UCB0_TERM
    .include "MSP430FR2433.inc"
    .ENDIF

    .IFDEF CHIPSTICK_FR2433
    .warning "Code for CHIPSTICK_FR2433"
UCA0_TERM 
UCB0_SD
    .include "MSP430FR2433.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2355
    .warning "Code for MSP_EXP430FR2355"
LF_XTAL
UCA1_TERM
UCB1_SD
    .include "MSP430FR2355.inc"
    .ENDIF




