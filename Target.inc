; Targe.inc

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
LF_XTAL
UCA0_UART
UCB0_SD
    .include "MSP430FR57xx.inc"
    .ENDIF ;  MSP_EXP430FR5739

    .IFDEF MSP_EXP430FR5969
    .warning "Code for MSP_EXP430FR5969"
DEVICE = "MSP430FR5969"
LF_XTAL
UCA0_UART
UCA1_SD
    .include "MSP430FR5x6x.inc"
    .ENDIF ; MSP_EXP430FR5969

    .IFDEF MSP_EXP430FR5994
    .warning "Code for MSP_EXP430FR5994"
DEVICE = "MSP430FR5994"
LF_XTAL
UCA0_UART
UCB0_SD
    .include "MSP430FR5x6x.inc"
    .ENDIF ; MSP_EXP430FR5994

    .IFDEF MSP_EXP430FR6989
    .warning "Code for MSP_EXP430FR6989"
DEVICE = "MSP430FR6989"
LF_XTAL
UCA1_UART
UCA0_SD
    .INCLUDE "MSP430FR5x6x.inc"
    .ENDIF ; MSP_EXP430FR6989

    .IFDEF MSP_EXP430FR4133
    .warning "Code for MSP_EXP430FR4133"
DEVICE = "MSP430FR4133"
LF_XTAL
UCA0_UART
UCB0_SD
    .INCLUDE "MSP430FR2x4x.inc"
    .ENDIF ; MSP_EXP430FR4133

    .IFDEF CHIPSTICK_FR2433
    .warning "Code for CHIPSTICK_FR2433"
DEVICE = "MSP430FR2433"
UCA0_UART
UCB0_SD
    .include "MSP430FR2x4x.inc"
    .ENDIF ; CHIPSTICK_FR2433


    .IFDEF MY_MSP430FR5738
    .warning "Code for MY_MSP430FR5738"
DEVICE = "MSP430FR5738"
LF_XTAL
UCA0_UART
UCB0_SD
    .include "MSP430FR57xx.inc"
    .ENDIF ; MY_MSP430FR5738

    .IFDEF MY_MSP430FR5734
    .warning "Code for MY_MSP430FR5734"
DEVICE = "MSP430FR5734"
UCA0_UART
    .include "MSP430FR57xx.inc"
    .ENDIF ; MY_MSP430FR5734_1

    .IFDEF MY_MSP430FR5738_1
    .warning "Code for MY_MSP430FR5738_1"
DEVICE = "MSP430FR5738"
LF_XTAL
UCA0_UART
UCB0_SD
    .include "MSP430FR57xx.inc"
    .ENDIF ; MY_MSP430FR5738_1

    .IFDEF MY_MSP430FR5948
    .warning "Code for MY_MSP430FR5948"
DEVICE = "MSP430FR5948"
UCA0_UART
UCA1_SD
    .include "MSP430FR5x6x.inc"
    .ENDIF ; MY_MSP430FR5948

    .IFDEF MY_MSP430FR5948_1
    .warning "Code for MY_MSP430FR5948_1"
DEVICE = "MSP430FR5948"
LF_XTAL
UCA0_UART
UCA1_SD
    .include "MSP430FR5x6x.inc"
    .ENDIF ; MY_MSP430FR5948_1

    .IFDEF JMJ_BOX
    .warning "Code for JMJ_BOX"
DEVICE = "MSP430FR5738"
UCA0_UART
    .include "MSP430FR57xx.inc"
    .ENDIF ; JMJ_BOX

    .IFDEF PA8_PA_MSP430
    .warning "Code for PA8_PA_MSP430"
DEVICE = "MSP430FR5738"
UCA0_UART
    .include "MSP430FR57xx.inc"
    .ENDIF ; PA8_PA_MSP430

    .IFDEF PA_PA_MSP430
    .warning "Code for PA_PA_MSP430"
DEVICE = "MSP430FR5738"
UCA0_UART
    .include "MSP430FR57xx.inc"
    .ENDIF ; PA_PA_MSP430

    .IFDEF PA_Core_MSP430
    .warning "Code for PA_Core_MSP430"
DEVICE = "MSP430FR5948"
UCA0_UART
    .include "MSP430FR5x6x.inc"
    .ENDIF ; PA_Core_MSP430

    .IF (charfromstr(DEVICE,8) = '5') & (charfromstr(DEVICE,9) = '7') 
RAM_1K
    .ENDIF