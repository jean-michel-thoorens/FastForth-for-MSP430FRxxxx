; -*- coding: utf-8 -*-

; Fast Forth For Texas Instrument MSP430FR4133
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
; INIT MSP-EXP430FR4133 board
; ======================================================================

; my USBtoUart :
; http://www.ebay.fr/itm/CP2102-USB-UART-Board-mini-Data-Transfer-Convertor-Module-Development-Board-/251433941479

; for sd card socket be carefull : pin CD must be present !
; http://www.ebay.com/itm/2-PCS-SD-Card-Module-Slot-Socket-Reader-For-Arduino-MCU-/181211954262?pt=LH_DefaultDomain_0&hash=item2a3112fc56


; J101   eZ-FET <-> target
; -----------------------
; P1 <-> P2 - NC
; P3 <-> P4 - TEST  - TEST
; P5 <-> P6 - RST   - RST
; P7 <-> P8 - TX1   - P1.0 UCA0 TXD ---> RX UARTtoUSB module
; P9 <->P10 - RX1   - P1.1 UCA0 RXD <--- TX UARTtoUSB module
; P11<->P12 - CTS   - P2.4
; P13<->P14 - RTS   - P2.3
; P15<->P16 - VCC   - 3V3
; P17<->P18 - 5V
; P19<->P20 - GND   - VSS

; Launchpad Header Left J1
; ------------------------
; P1 - 3V3
; P2 - P8.1 ACLK/A9
; P3 - P1.1 UCA0 RXD
; P4 - P1.0 UCA0 TXD
; P5 - P2.7    
; P6 - P8.0 SMCLK/A8
; P7 - P5.1 UCB0 CLK
; P8 - P2.5
; P9 - P8.2 TA1CLK
; P10- P8.3 TA1.2

; Launchpad Header Right J2
; -------------------------
; P1 - GND
; P2 - P1.7 TA0.1/TDO/A7
; P3 - P1.6 TA0.2/TDI/TCLK/A6
; P4 - P5.0 UCB0STE
; P5 - RST
; P6 - P5.2 UCB0SIMO/UCB0SDA
; P7 - P5.3 UCB0SOMI/UCB0SCL
; P8 - P1.3 UCA0STE/A3
; P9 - P1.4 MCLK/TCK/A4
; P10- P1.5 TA0CLK/TMS/A5

; switch-keys:
; S1 - P1.2
; S2 - P2.6
; S3 - RST

; LEDS:
; LED1 - P1.0/TXD
; LED2 - P4.0

; XTAL LF 32768 Hz
; Y4 - P4.1 XIN
; Y4 - P4.2 XOUT

; LCD
; L0  - P7.0
; L1  - P7.1
; L2  - P7.2
; L3  - P7.3
; L4  - P7.4
; L5  - P7.5
; L6  - P7.6
; L7  - P7.7
; L8  - P3.0
; L9  - P3.1
; L10 - P3.2
; L11 - P3.3
; L12 - P3.4
; L13 - P3.5
; L14 - P3.6
; L15 - P3.7
; L16 - P6.0
; L17 - P6.1
; L18 - P6.2
; L19 - P6.3
; L20 - P6.4
; L21 - P6.5
; L22 - P6.6
; L23 - P6.7
; L24 - P2.0
; L25 - P2.1
; L26 - P2.2
; L36 - P5.4
; L37 - P5.5
; L38 - P5.6
; L39 - P5.7






; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; then wire VCC and GND of bridge onto J13 connector
; ===================================================================================

; ---------------------------------------------------
; MSP  - MSP-EXP430FR4133 LAUNCHPAD <--> OUTPUT WORLD
; ---------------------------------------------------
; P1.0 - LED1 red 
; P4.0 - LED2 green
;
; P1.2 - S1
; P2.6 - S2 
;                                 +-4k7-< DeepRST <-- GND 
;                                 |
; P1.0 - UCA0 TXD       J101.8  --+-> RX  UARTtoUSB bridge
; P1.1 - UCA0 RXD       J101.10 <---- TX  UARTtoUSB bridge
; P2.3 - RTS            J101.14 ----> CTS UARTtoUSB bridge (if TERMINALCTSRTS option)
;  VCC -                J101.16 <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
;  GND -                J101.20 <---> GND (optional supply from UARTtoUSB bridge)
;                     
; P2.7 -                J1.5    <---- OUT IR_Receiver (1 TSOP32236)
; 
; P4.1 - LFXI 32768Hz quartz  
; P4.2 - LFXO 32768Hz quartz  
;
; P5.2 - UCB0 SDA/SIMO  J2.6    <---> SDA I2C Slave
; P5.3 - UCB0 SCL/SOMI  J2.7    <---- SCL I2C Slave
;       
; P5.1 - UCB0 CLK       J1.7    ----> orange    SD_CLK
; P5.2 - UCB0 SDA/SIMO  J2.6    ----> grey      SD_SDI
; P5.3 - UCB0 SCL/SOMI  J2.7    <---- purple    SD_SDO
; P8.0 -                J1.6    <---- violin    SD_CD (Card Detect)
; P8.1 -                J1.2    ----> brown     SD_CS (Card Select)
;       
; P8.2 - Soft I2C_Master J1.9   ----> SDA software I2C Master
; P8.3 - Soft I2C_Master J1.10  <---> SCL software I2C Master


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


; PORT1 usage

; P1.0 - TX0 --> JP1 --> red LED1 --> GND
; P1.1 - RX0

Deep_RST_IN .equ P1IN  ; TERMINAL TX  pin as FORTH Deep_RST 
Deep_RST    .equ 1     ; TX
TERM_TXRX   .equ 003h  ; TX RX
TERM_SEL    .equ P1SEL0
TERM_REN    .equ P1REN


    .IFDEF TERMINALCTSRTS

; RTS output is wired to the CTS input of UART2USB bridge 
; CTS is not used by FORTH terminal
; configure RTS as output high to disable RX TERM during start FORTH

HANDSHAKOUT .set    P2OUT
HANDSHAKIN  .set    P2IN
RTS         .set    8       ; P2.3 bit position
;CTS         .set    10h     ; P2.4 bit position

            BIS #00800h,&PADIR  ; all pins as input else RTS P2.3
            BIS #-1,&PAREN      ; all input pins with resistor
            MOV #-1,&PAOUT      ; that acts as pull up, and P2.3 as output HIGH

    .ELSEIF

; PORTx default wanted state : pins as input with pullup resistor

            MOV #-1,&PAOUT  ; OUT1 for all pins
            BIS #-1,&PAREN  ; all pins with pullup resistors

    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; P3 configuration :

; P4 configuration :
; P4.0 - LED2 green
; P4.1 - LFXI 32768Hz quartz  
; P4.2 - LFXO 32768Hz quartz  
  
; PORTx default wanted state : pins as input with pullup resistor

            MOV #00100h,&PBDIR   ; all pins as inputs else P4.0
            MOV #0FEFFh,&PBOUT   ; OUT1 for all pins else P4
            BIS #0FEFFh,&PBREN   ; pullup for all pins resistors else P4.0

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PCOUT    ; all pins OUT1
            BIS     #-1,&PCREN    ; all pins with pull resistors

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7/8
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PDOUT    ; all pins OUT1
            BIS     #-1,&PDREN    ; all pins with pull resistors

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF FREQUENCY = 16
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

; CS code for EXP430FR4133

; to measure REFO frequency, output ACLK on P8.1:
;    BIS.B #2,&P8SEL0
;    BIS.B #2,&P8DIR
; result : REFO = ? kHz


; ===================================================================
; need to adjust FLLN (and DCO) for each device of MSP430fr2xxx family ?
; (no problem with MSP430FR5xxx families without FLL).
; ===================================================================

    .IF     FREQUENCY = 0.5

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
            MOV     #2,X

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
            MOV     #4,X

    .ELSEIF FREQUENCY = 2

            MOV #00B4h,&CSCTL0          ; preset DCO = 0xB4 (measured value @ 0x180 ; to measure, type HEX 0x180 ?)

            MOV     #0003h,&CSCTL1      ; Set 2MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #003Bh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Bh
                                        ; fCOCLKDIV = 32768 x (59+1) = 1.996 MHz ; measured :  MHz
            MOV     #003Ch,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Ch
                                        ; fCOCLKDIV = 32768 x (60+1) = 1.998 MHz ; measured :  MHz
;            MOV     #003Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Dh
                                        ; fCOCLKDIV = 32768 x (61+1) = 2.031 MHz ; measured :  MHz
; =====================================
            MOV     #8,X

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
            MOV     #16,X

    .ELSEIF FREQUENCY = 8

            MOV #00F2h,&CSCTL0          ; preset DCO = 0xF2 (measured value @ 0x180)

            MOV     #0007h,&CSCTL1      ; Set 8MHZ DCORSEL,disable DCOFTRIM,Modulation
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #00F2h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F2h
                                        ; fCOCLKDIV = 32768 x (242+1) = 7.963 MHz ; measured : 7.943MHz
;            MOV     #00F3h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F3h
                                        ; fCOCLKDIV = 32768 x (243+1) = 7.995 MHz ; measured : 7.976MHz
            MOV     #00F4h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F4h
                                        ; fCOCLKDIV = 32768 x (244+1) = 8.028 MHz ; measured : 8.009MHz

;            MOV     #00F5h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F5h
                                        ; fCOCLKDIV = 32768 x (245+1) = 8.061 MHz ; measured : 8.042MHz
                                        ; works with cp2102 and pl2303TA
; =====================================
            MOV     #32,X

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
            MOV     #64,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
;            MOV     #0000h,&CSCTL3      ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4      ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
    .ELSE
            MOV     #0010h,&CSCTL3      ; FLL select REFCLOCK, FLLREFDIV=0
;           MOV     #0100h,&CSCTL4      ; ACLOCK select REFO, MCLK & SMCLK select DCOCLKDIV (default value)
    .ENDIF


            BIS &SYSRSTIV,&SAVE_SYSRSTIV; store volatile SYSRSTIV with preserving a pending request for DEEP_RST
            CMP #2,&SAVE_SYSRSTIV   ; POWER ON ?
            JZ      ClockWaitX      ; yes : wait 600ms to stabilize power source
            .word   0359h           ; no  : RRUM #1,X --> wait still 300 ms...
                                    ;       ...because FLL lock time = 280 ms

ClockWaitX  MOV     #50000,Y        ;
ClockWaitY  SUB     #1,Y            ; 3 cycles loop
            JNZ     ClockWaitY      ; 50000x3 = 150000 cycles delay = 150ms @ 1MHz
            SUB     #1,X            ;
            JNZ     ClockWaitX      ;


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : RTC REGISTERS
; ----------------------------------------------------------------------

    .IFDEF LF_XTAL
; LFXIN : P4.1, LFXOUT : P4.2
    MOV  #0600h,&PBSEL0   ; SEL0 for only P4.1,P4.2
    .ENDIF




