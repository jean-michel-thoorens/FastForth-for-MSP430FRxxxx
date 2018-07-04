; -*- coding: utf-8 -*-
; CHIPSTICK_FR2433.inc

; Fast Forth For Texas Instrument CHIPSTICK MSP430FR2433
;
; Copyright (C) <2016>  <J.M. THOORENS>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; ======================================================================
; INIT CHIPSTICK MSP430FR2433
; ======================================================================

; my USBtoUart :
; http://www.ebay.fr/itm/CP2102-USB-UART-Board-mini-Data-Transfer-Convertor-Module-Development-Board-/251433941479

; for sd card socket be carefull : pin CD must be present !
; http://www.ebay.com/itm/2-PCS-SD-Card-Module-Slot-Socket-Reader-For-Arduino-MCU-/181211954262?pt=LH_DefaultDomain_0&hash=item2a3112fc56


; ChipStick PROG Header
; ------------------------
; PR1 - GND
; PR2 - TEST
; PR3 - VCC
; PR4 - UART0 RX
; PR5 - UART0 TX   
; PR6 - /RST

; ChipStick Header PL1
; ------------------------
; P1 - 24 - 3V3
; P2 - 20 - P3.2
; P3 -  4 - P1.5 UCA0 RXD
; P4 -  3 - P1.4 UCA0 TXD
; P5 -  5 - P1.6 UCA0 CLK    
; P6 - 13 - P2.3 
; P7 - 12 - P3.0
; P8 -  7 - P1.0 UCB0 STE
; P9 -  8 - P1.1 UCB0 CLK
; P10-  9 - P1.2 UCB0 SIMO/SDA

; ChipStick Header PL2
; -------------------------
; P1 - 23 - GND
; P2 - 22 - P2.1 XIN
; P3 - 21 - P2.0 XOUT
; P4 -  2 - TEST
; P5 -  1 - /RST
; P6 - 17 - P2.6 UCA1 TX/SIMO
; P7 - 16 - P2.5 UCA1 RX/SOMI
; P8 - 15 - P2.4 UCA1 CLK
; P9 - 11 - P2.2
; P10- 10 - P1.3 UCB0 SOMI/SCL

; LEDS:
; LED1 - 14 - P3.1 UCA1 STE

; switch-keys:
; RST


; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; then wire VCC and GND of bridge onto J13 connector
; ===================================================================================

; ---------------------------------------------------
; CHIPSTICK_FR2433 <--> OUTPUT WORLD
; ---------------------------------------------------
; P3.1 -                        LED1

; P2.1  -             PL2.2  -  SW1
; P2.0  -             PL2.3  -  SW2 

;                                 +--4k7-< DeepRST <-- GND 
;                                 |
; P1.4  - UCA0 TXD    PL1.4  -  <-+-> RX  UARTtoUSB bridge
; P1.5  - UCA0 RXD    PL1.3  -  <---- TX  UARTtoUSB bridge
; P3.2  - RTS         PL1.2  -  ----> CTS UARTtoUSB bridge (if TERMINALCTSRTS option)

; P3.0  -             PL1.7  -  ----> /CS SPI_RAM
; P1.1  - UCB0 CLK    PL1.9  -  ----> CLK SPI_RAM
; P1.2  - UCB0 SIMO   PL1.10 -  ----> SI  SPI_RAM
; P1.3  - UCB0 SOMI   PL2.10 -  <---- S0  SPI_RAM
        
        
; P1.1  - UCB0 CLK    PL1.9  -  ----> SD_CLK
; P1.2  - UCB0 SIMO   PL1.10 -  ----> SD_SDI
; P1.3  - UCB0 SOMI   PL2.10 -  <---- SD_SDO
; P2.3  -             PL1.6  -  <---- SD_CD (Card Detect)
; P2.2  -             PL2.9  -  ----> SD_CS (Card Select)
        
; P1.2  - UCB0 SDA    PL1.10 -  <---> SDA I2C Slave
; P1.3  - UCB0 SCL    PL2.10 -  ----> SCL I2C Slave
        
; P2.2  -             PL2.9  -  ----> SCL I2C SoftMaster
; P2.0  -             PL2.3  -  <---> SDA I2C SoftMaster
        
; P1.0  - UCB0 STE    PL1.8  -  <---- TSSOP32236 (IR RC5) 

; ----------------------------------------------------------------------
; INIT order : WDT, GPIOs, FRAM, Clock, UARTs...
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------

;              BIS     #LOCKLPM5,&PM5CTL0 ; unlocked by WARM

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

; WDT code
        MOV #WDTPW+WDTHOLD+WDTCNTCL,&WDTCTL    ; stop WDT

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTx default wanted state : pins as input with pullup resistor

            MOV #-1,&PAOUT  ; OUT1 for all pins
            BIS #-1,&PAREN  ; all pins with pull resistors
          
; PORT1 usage
    .IFDEF UCA0_TERM
TXD         .equ 10h        ; P1.4 = TXD + FORTH Deep_RST pin
RXD         .equ 20h        ; P1.5
TERM_BUS    .equ 30h
TERM_IN     .equ P1IN
TERM_SEL    .equ P1SEL0
TERM_REN    .equ P1REN
    .ENDIF

; PORT2 usage
    .IFDEF UCB0_SD
SD_SEL      .equ PASEL0     ; to configure UCB0
SD_REN      .equ PAREN      ; to configure pullup resistors
SD_BUS      .equ 000Eh      ; pins P1.1 as UCB0CLK, P1.2 as UCB0SIMO & P1.3 as UCB0SOMI
    .ENDIF

SD_CD       .equ 8          ; P2.3 as SD_CD
SD_CS       .equ 4          ; P2.2 as SD_CS     
SD_CDIN     .equ P2IN
SD_CSOUT    .equ P2OUT
SD_CSDIR    .equ P2DIR


    .IFDEF UCA1_TERM
RXD         .equ 20h        ; P2.5
TXD         .equ 40h        ; P2.6 = TXD + FORTH Deep_RST pin
TERM_BUS    .equ 60h
TERM_IN     .equ P2IN       ; TERMINAL TX  pin as FORTH Deep_RST 
TERM_SEL    .equ P2SEL0
TERM_REN    .equ P2REN
    .ENDIF


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage
; P3.1 -           LED1

; RTS output is wired to the CTS input of UART2USB bridge 
; CTS is not used by FORTH terminal
; configure RTS as output high to disable RX TERM during start FORTH

    .IFDEF TERMINAL4WIRES
HANDSHAKOUT .equ    P3OUT
HANDSHAKIN  .equ    P3IN
RTS         .equ    4       ; P3.2 bit position

            BIS.B #006h,&P3DIR  ; all pins as input else P3.1 LED1 and P3.2 RTS as output
            BIS.B #-1,&P3REN    ; all inputs with pull resistors

        .IFDEF TERMINAL5WIRES

CTS         .equ    1       ; P3.0 bit position

            MOV.B #0FCh,&P3OUT  ; all pins with pullup resistors and LED1 output low, CTS input low

        .ELSEIF

            MOV.B #0FDh,&P3OUT  ; all pins with pullup resistors and LED1 = output low

        .ENDIF  ; TERMINAL5WIRES

    .ELSEIF

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B #001h,&P3DIR  ; all pins as input else LED1 as output
            BIS.B #-1,&P3REN    ; all inputs with pull resistors
            MOV.B #0FDh,&P3OUT  ; all pins with pullup resistors and LED1 = output low

    .ENDIF  ; TERMINAL4WIRES

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF FREQUENCY = 16
NWAITS            = 1
            MOV.B   #0A5h, &FRCTL0_H     ; enable FRCTL0 access
            MOV.B   #10h, &FRCTL0         ; 1 waitstate @ 16 MHz
            MOV.B   #01h, &FRCTL0_H       ; disable FRCTL0 access
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET SYS config
; ----------------------------------------------------------------------

; SYS code                                  
;    BIC #1,&SYSCFG0 ; enable write program in FRAM
    MOV #0A500h,&SYSCFG0 ; enable write MAIN and INFO

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; CS code for EXP430FR2433

; to measure REFO frequency, output ACLK on P2.2: 
;    BIS.B #4,&P2SEL1
;    BIS.B #4,&P2DIR
; result : REFO = 32.69kHz

; ===================================================================
; need to adjust FLLN (and DCO) for each device of MSP430fr2xxx family ?
; (no problem with MSP430FR5xxx families without FLL).
; ===================================================================

    .IF FREQUENCY = 0.25

            MOV #0D6h,&CSCTL0          ; preset DCO = 0xD6 (measured value @ 0x180 ; to measure, type 0x180 @ U.)

            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #200Dh,&CSCTL2      ; Set FLLD=2 (DCOCLKCDIV=DCO/4),set FLLN=0Dh
                                        ; fCOCLKDIV = 32768 x (13+1) = 0.459 MHz ; measured :  MHz
;            MOV     #200Eh,&CSCTL2      ; Set FLLD=2 (DCOCLKCDIV=DCO/4),set FLLN=0Eh
                                        ; fCOCLKDIV = 32768 x (14+1) = 0.491 MHz ; measured :  MHz
            MOV     #200Fh,&CSCTL2      ; Set FLLD=2 (DCOCLKCDIV=DCO/4),set FLLN=0Fh
                                        ; fCOCLKDIV = 32768 x (15+1) = 0.524 MHz ; measured :  MHz
; =====================================
            MOV     #4,X

    .ELSEIF FREQUENCY = 0.5

            MOV #0D6h,&CSCTL0          ; preset DCO = 0xD6 (measured value @ 0x180 ; to measure, type 0x180 @ U.)

            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #100Dh,&CSCTL2      ; Set FLLD=1 (DCOCLKCDIV=DCO/2),set FLLN=0Dh
                                        ; fCOCLKDIV = 32768 x (13+1) = 0.459 MHz ; measured :  MHz
;            MOV     #100Eh,&CSCTL2      ; Set FLLD=1 (DCOCLKCDIV=DCO/2),set FLLN=0Eh
                                        ; fCOCLKDIV = 32768 x (14+1) = 0.491 MHz ; measured :  MHz
            MOV     #100Fh,&CSCTL2      ; Set FLLD=1 (DCOCLKCDIV=DCO/2),set FLLN=0Fh
                                        ; fCOCLKDIV = 32768 x (15+1) = 0.524 MHz ; measured :  MHz
; =====================================
            MOV     #8,X

    .ELSEIF FREQUENCY = 1

            MOV #00B4h,&CSCTL0          ; preset DCO = 0xB4 (measured value @ 0x180 ; to measure, type HEX 0x180 ?)

            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #001Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Dh
                                        ; fCOCLKDIV = 32768 x (29+1) = 0.983 MHz ; measured : 0.989MHz
            MOV     #001Eh,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Eh
                                        ; fCOCLKDIV = 32768 x (30+1) = 1.015 MHz ; measured : 1.013MHz
;            MOV     #001Fh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Fh
                                        ; fCOCLKDIV = 32768 x (31+1) = 1.049 MHz ; measured : 1.046MHz
; =====================================
            MOV     #16,X

    .ELSEIF FREQUENCY = 2

            MOV #00B4h,&CSCTL0          ; preset DCO = 0xB4 (measured value @ 0x180 ; to measure, type HEX 0x180 ?)

            MOV     #0003h,&CSCTL1      ; Set 2MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #003Bh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Bh
                                        ; fCOCLKDIV = 32768 x (59+1) = 1.996 MHz ; measured :  MHz
;            MOV     #003Ch,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Ch
                                        ; fCOCLKDIV = 32768 x (60+1) = 1.998 MHz ; measured :  MHz
            MOV     #003Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Dh
                                        ; fCOCLKDIV = 32768 x (61+1) = 2.031 MHz ; measured :  MHz
; =====================================
            MOV     #32,X

    .ELSEIF FREQUENCY = 4

            MOV #00D2h,&CSCTL0          ; preset DCO = 0xD2 (measured value @ 0x180)

            MOV     #0005h,&CSCTL1      ; Set 4MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #0078h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=78h
                                        ; fCOCLKDIV = 32768 x (120+1) = 3.965 MHz ; measured : 3.96MHz

            MOV     #0079h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=79h
                                        ; fCOCLKDIV = 32768 x (121+1) = 3.997 MHz ; measured : 3.99MHz

;            MOV     #007Ah,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=7Ah
                                        ; fCOCLKDIV = 32768 x (122+1) = 4.030 MHz ; measured : 4.020MHz
; =====================================
            MOV     #64,X

    .ELSEIF FREQUENCY = 8


            MOV #00F3h,&CSCTL0          ; preset DCO = 0xF2 (measured value @ 0x180)

            MOV     #0007h,&CSCTL1      ; Set 8MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #00F2h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F2h
                                        ; fCOCLKDIV = 32768 x (242+1) = 7.963 MHz ; measured : 7.943MHz
;            MOV     #00F3h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F3h
                                        ; fCOCLKDIV = 32768 x (243+1) = 7.995 MHz ; measured : 7.976MHz
;            MOV     #00F4h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F4h
                                        ; fCOCLKDIV = 32768 x (244+1) = 8.028 MHz ; measured : 8.009MHz

;            MOV     #00F5h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F5h
                                        ; fCOCLKDIV = 32768 x (245+1) = 8.061 MHz ; measured : 8.042MHz

;            MOV     #00F8h,&CSCTL2      ; don't work with cp2102 (by low value)
;            MOV     #00FAh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=FAh
; ===================================================================
; CHIPSTICK_FR2433 : TLV area corrupted when welding ? 
; ===================================================================
            MOV     #00FCh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=FCh
                                        ; fCOCLKDIV = 32768 x (252+1) = 8.290 MHz  <============ why ?

; =====================================
            MOV     #128,X

    .ELSEIF FREQUENCY = 16

            MOV #0129h,&CSCTL0          ; preset DCO = 0x129 (measured value @ 0x180)

            MOV     #000Bh,&CSCTL1      ; Set 16MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #01E6h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E6h
                                        ; fCOCLKDIV = 32768 x 486+1) = 15.958 MHz ; measured : 15.92MHz
;            MOV     #01E7h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E7h
                                        ; fCOCLKDIV = 32768 x 487+1) = 15.991 MHz ; measured : 15.95MHz
;            MOV     #01E8h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E8h
                                        ; fCOCLKDIV = 32768 x 488+1) = 16.023 MHz ; measured : 15.99MHz
            MOV     #01E9h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E9h
                                        ; fCOCLKDIV = 32768 x 489+1) = 16.056 MHz ; measured : 16.02MHz
; =====================================
            MOV     #256,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
;           MOV     #0000h,&CSCTL3      ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4      ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
    .ELSE
            BIS     #0010h,&CSCTL3      ; FLL select REFCLOCK
;           MOV     #0100h,&CSCTL4      ; ACLOCK select REFO, MCLK & SMCLK select DCOCLKDIV (default value)
    .ENDIF

            BIS &SYSRSTIV,&SAVE_SYSRSTIV; store volatile SYSRSTIV preserving a pending request for DEEP_RST
;            CMP #2,&SAVE_SYSRSTIV   ; POWER ON ?
;            JZ      ClockWaitX      ; yes
;            .word   0759h           ; no  RRUM #2,X --> wait only 125 ms
ClockWaitX  MOV     #5209,Y         ; wait 0.5s before starting after POR
                                    ;       ...because FLL lock time = 280 ms
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 5209x3 = 15625 cycles delay = 15.625ms @ 1MHz
            SUB     #1,X            ; x 32 @ 1 MHZ = 500ms
            JNZ     ClockWaitX      ; time to stabilize power source ( 500ms )

;WAITFLL     BIT #300h,&CSCTL7         ; wait FLL lock
;            JNZ WAITFLL
