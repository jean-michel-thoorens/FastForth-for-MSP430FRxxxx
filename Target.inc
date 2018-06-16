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
    .ELSEIF FREQUENCY = 16
FREQ    .set " 16MHz"
    .ELSEIF FREQUENCY = 24
FREQ    .set " 24MHz"
    .ENDIF


;-----------------------------------------------------------------------
; DEVICE I/O, MEMORY, SFR, vectors and FORTH I/O declarations
;-----------------------------------------------------------------------


    OUTRADIX  10

    .IFDEF TERMINALBAUDRATE
    .warning "TERMINAL \{TERMINALBAUDRATE} bds"
    .endif
    .warning "frequency = \{FREQUENCY} MHz"


    .IFDEF MSP_EXP430FR5739
    .warning "Code for MSP_EXP430FR5739"
DEVICE = "MSP430FR5739"
;CHIP  .equ 5739
LF_XTAL
UCA0_UART
TERMVEC     .equ 0FFF0h      ;  eUSCI_A0
UCB0_SD
HRDWMPY
RTC_B 
    .include "MSP430FR57xx.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR5969
    .warning "Code for MSP_EXP430FR5969"
DEVICE = "MSP430FR5969"
;CHIP  .equ 5969
LF_XTAL
UCA0_UART
TERMVEC     .equ 0FFF0h      ;  eUSCI_A0
UCA1_SD
HRDWMPY
RTC_B 
    .include "MSP430FR5x6x.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR5994
    .warning "Code for MSP_EXP430FR5994"
DEVICE = "MSP430FR5994"
;CHIP  .equ 5994
LF_XTAL
UCA0_UART
TERMVEC     .equ 0FFF0h      ;  eUSCI_A0
UCB0_SD
HRDWMPY
RTC_C 
    .include "MSP430FR5x6x.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR6989
    .warning "Code for MSP_EXP430FR6989"
DEVICE = "MSP430FR6989"
;CHIP  .equ 6989
LF_XTAL
UCA1_UART
TERMVEC     .equ 0FFE4h      ;  eUSCI_A1
UCA0_SD
HRDWMPY
RTC_C 
    .INCLUDE "MSP430FR5x6x.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR4133
    .warning "Code for MSP_EXP430FR4133"
DEVICE = "MSP430FR4133"
;CHIP  .equ 4133
LF_XTAL
UCA0_UART
TERMVEC     .equ 0FFECh      ;  eUSCI_A0
UCB0_SD
RTC     ; define type of RTC
    .INCLUDE "MSP430FR2x4x.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2433
    .warning "Code for MSP_EXP430FR2433"
DEVICE = "MSP430FR2433"
;CHIP  .equ 2433
LF_XTAL
UCA0_UART
TERMVEC     .equ 0FFE4h      ;  eUSCI_A0
UCA1_SD
;UCB0_I2CM                   ; for TERM2IIC add-on
HRDWMPY
RTC     ; define type of RTC
    .include "MSP430FR2x4x.inc"
    .ENDIF

    .IFDEF CHIPSTICK_FR2433
    .warning "Code for CHIPSTICK_FR2433"
DEVICE = "MSP430FR2433"
;CHIP  .equ 2433
UCA0_UART
TERMVEC     .equ 0FFE4h      ;  eUSCI_A0
UCB0_SD
HRDWMPY
RTC     ; define type of RTC
    .include "MSP430FR2x4x.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2355
    .warning "Code for MSP_EXP430FR2355"
DEVICE = "MSP430FR2355"
;CHIP  .equ 2355
LF_XTAL
UCA1_UART
TERMVEC     .equ 0FFE2h      ;  eUSCI_A1
UCB1_SD
HRDWMPY
RTC     ; define type of RTC
    .include "MSP430FR2x4x.inc"
    .ENDIF


; define RAM = 1k for MSP430FR57xx devices
    .IF (charfromstr(DEVICE,8) = '5') & (charfromstr(DEVICE,9) = '7') 
RAM_1K
    .ENDIF

FRAM_FULL   .equ SIGNATURES-50h ; set to protect JTAG and BSL signatures against overwrite.
                                ; notice that ALLOT memory space beyond SIGNATURES don't corrupt it,
                                ; so 80 bytes are sufficient considering what can be compiled in one line and WORD use.
                                ; good practice: one line reserved for each ALLOT command.


