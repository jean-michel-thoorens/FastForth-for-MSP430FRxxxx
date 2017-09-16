; Target.inc

;-----------------------------------------------------------------------
; DEVICE I/O, MEMORY, SFR, vectors and FORTH I/O declarations
;-----------------------------------------------------------------------


FRAM_FULL   .equ SIGNATURES-50h ; set to protect JTAG and BSL signatures against overwrite.
                                ; notice that ALLOT memory space beyond SIGNATURES don't corrupt it,
                                ; so 80 bytes are sufficient considering what can be compiled in one line and WORD use.
                                ; good practice: one line reserved for each ALLOT command.




    OUTRADIX  10
    .warning "TERMINAL \{TERMINALBAUDRATE} bds"
    .warning "frequency = \{FREQUENCY} MHz"


    .IFDEF MSP_EXP430FR5739
    .warning "Code for MSP_EXP430FR5739"
DEVICE = "MSP430FR5739"
;CHIP  .equ 5739
LF_XTAL
UCA0_UART
UCB0_SD
    .include "MSP430FR57xx.inc"
    .ENDIF ;  MSP_EXP430FR5739

    .IFDEF MSP_EXP430FR5969
    .warning "Code for MSP_EXP430FR5969"
DEVICE = "MSP430FR5969"
;CHIP  .equ 5969
LF_XTAL
UCA0_UART
UCA1_SD
    .include "MSP430FR5x6x.inc"
    .ENDIF ; MSP_EXP430FR5969

    .IFDEF MSP_EXP430FR5994
    .warning "Code for MSP_EXP430FR5994"
DEVICE = "MSP430FR5994"
;CHIP  .equ 5994
LF_XTAL
UCA0_UART
UCB0_SD
    .include "MSP430FR5x6x.inc"
    .ENDIF ; MSP_EXP430FR5994

    .IFDEF MSP_EXP430FR6989
    .warning "Code for MSP_EXP430FR6989"
DEVICE = "MSP430FR6989"
;CHIP  .equ 6989
LF_XTAL
UCA1_UART
UCA0_SD
    .INCLUDE "MSP430FR5x6x.inc"
    .ENDIF ; MSP_EXP430FR6989

    .IFDEF MSP_EXP430FR4133
    .warning "Code for MSP_EXP430FR4133"
DEVICE = "MSP430FR4133"
;CHIP  .equ 4133
LF_XTAL
UCA0_UART
UCB0_SD
    .INCLUDE "MSP430FR2x4x.inc"
    .ENDIF ; MSP_EXP430FR4133

    .IFDEF CHIPSTICK_FR2433
    .warning "Code for CHIPSTICK_FR2433"
DEVICE = "MSP430FR2433"
;CHIP  .equ 2433
UCA0_UART
UCB0_SD
    .include "MSP430FR2x4x.inc"
    .ENDIF ; CHIPSTICK_FR2433



; define RAM = 1k for MSP430FR57xx devices
    .IF (charfromstr(DEVICE,8) = '5') & (charfromstr(DEVICE,9) = '7') 
RAM_1K
    .ENDIF