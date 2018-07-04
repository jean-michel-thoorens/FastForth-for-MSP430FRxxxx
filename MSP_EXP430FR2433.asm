; -*- coding: utf-8 -*-

; Fast Forth For Texas Instrument MSP430FR5739
; Tested on MSP-EXP430FR2433 launchpad
;
; Copyright (C) <2017>  <J.M. THOORENS>
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
; INIT MSP-EXP430FR2433 board
; ======================================================================

; J101 (7xjumper)
; "SBWTCK"   ---> TEST
; "SBWTDIO"  ---> RST
; "TXD"      <--- P1.4  == UCA0TXD <-- UCA0TXDBUf
; "RXD"      ---> P1.5  == UCA0RXD --> UCA0RXDBUF
; "3V3"      <--> 3V3
; "5V0"      <--> 5V0
; "GND"      <--> GND


; SW1 -- P2.3
; SW2 -- P2.7

; LED1 - P1.0
; LED2 - P1.1

; I/O pins on J1:
; J1.1 - 3V3
; J1.2 - P1.0
; J1.3 - P1.5
; J1.4 - P1.4
; J1.5 - P1.6
; J1.6 - P1.7
; J1.7 - P2.4
; J1.8 - P2.7
; J1.9 - P1.3
; J1.10- P1.2

; I/O pins on J2:
; J2.11 - P2.0
; J2.12 - P2.1
; J2.13 - P3.1
; J2.14 - P2.5
; J2.15 - P2.6
; J2.16 - RST
; J2.17 - P3.2
; J2.18 - P2.2
; J2.19 - P1.1
; J2.20 - GND

; LFXTAL - P2.0
; LFXTAL - P2.1

; ======================================================================
; MSP-EXP430FR2433 LAUNCHPAD    <--> OUTPUT WORLD
; ======================================================================

;                                 +--4k7-< DeepRST switch <-- GND 
;                                 |
; P1.4  - UCA0 TXD    J101.6 -  <-+-> RX  UARTtoUSB bridge
; P1.5  - UCA0 RXD    J101.8 -  <---- TX  UARTtoUSB bridge
; P1.0  - RTS         J1.2   -  ----> CTS UARTtoUSB bridge (TERMINAL4WIRES)
; P1.1  - CTS         J2.19  -  <---- RTS UARTtoUSB bridge (TERMINAL5WIRES)

; P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C Master_Slave
; P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C Master_Slave
        
; P2.2  - ACLK        J2.18  -  <---- TSSOP32236 (IR RC5) 

; P2.0  -             J2.11  -  ----> SD_CS (Card Select)
; P2.1  -             J2.12  -  <---- SD_CD (Card Detect)
; P2.4  - UCA1 CLK    J1.7   -  ----> SD_CLK
; P2.5  - UCA1 SOMI   J2.14  -  <---- SD_SDO
; P2.6  - UCA1 SIMO   J2.15  -  ----> SD_SDI
        
; P3.1  -             J2.13  -  ----> SCL I2C Soft_Master
; P3.2  -             J2.17  -  <---> SDA I2C Soft_Master
        

; P2.0  -             J2.11  -  <---- I2CTERM_SLA0
; P2.1  -             J2.12  -  <---- I2CTERM_SLA1
; P2.2  - ACLK        J2.18  -  <---- I2CTERM_SLA2 

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
; LED1 - P1.0
; LED2 - P1.1
; P1.4  - TXD TERMINAL + DEEP_RST
; P1.5  - RXD TERMINAL
; P1.0  - RTS TERMINAL     
; P1.1  - CTS TERMINAL     


    .IFDEF UCA0_TERM
TXD         .equ 10h        ; P1.4 = TXD + FORTH Deep_RST pin
RXD         .equ 20h        ; P1.5
TERM_BUS    .equ 30h
TERM_IN     .equ P1IN
TERM_SEL    .equ P1SEL0
TERM_REN    .equ P1REN
    .ENDIF

    .IFDEF UCA1_SD
SD_SEL      .equ PASEL0     ; to configure UCA1
SD_REN      .equ PAREN      ; to configure pullup resistors
SD_BUS      .equ 07000h     ; pins P2.4 as UCA1CLK, P2.5 as UCA1SOMI & P2.6 as UCA1SIMO
    .ENDIF

; P2.1                <--- SD_CD (Card Detect)
SD_CD           .equ  2
SD_CDIN         .equ  P2IN
; P2.0                ---> SD_CS (Card Select)
SD_CS           .equ  1
SD_CSOUT        .equ P2OUT
SD_CSDIR        .equ P2DIR


    .IFDEF UCA1_TERM
TXD         .equ 40h        ; P2.6 = TXD + FORTH Deep_RST pin
RXD         .equ 20h        ; P2.5
TERM_BUS    .equ 60h
TERM_IN     .equ P2IN       ; TERMINAL TX  pin as FORTH Deep_RST 
TERM_SEL    .equ P2SEL0
TERM_REN    .equ P2REN
    .ENDIF

            MOV #-1,&PAREN      ; all inputs with pull resistors
            BIS #00003h,&PADIR  ; all pins as input else LED1/LED2 as output
            MOV #0FFFCh,&PAOUT  ; all pins with pullup resistors and LED1/LED2 = output low

    .IFDEF TERMINAL4WIRES
; RTS output must be wired to the CTS input of UART2USB bridge 
; configure RTS as output high to disable RX TERM during start FORTH
; notice that this pin RTS may be permanently wired on SBWTCK (TEST) without disturbing SBW 2 wires programming
HANDSHAKOUT .equ    P1OUT
HANDSHAKIN  .equ    P1IN
RTS         .equ    1           ; P1.0 bit position

            BIS #1,&PAOUT       ; P1.0 RTS as output high

        .IFDEF TERMINAL5WIRES

; CTS input must be wired to the RTS output of UART2USB bridge 
; configure CTS as input low
CTS         .equ    2           ; P1.1 bit position
            BIC  #2,&PADIR      ; CTS input pull down resistor

        .ENDIF  ; TERMINAL5WIRES

    .ENDIF  ; TERMINAL4WIRES

          
    .IFDEF UCB0_TERM        ; for MSP_EXP430FR2433_I2C
I2CM_BUS        .equ    0Ch   ; P1.2=SDA P1.3=SCL
I2CM_SEL        .equ    P1SEL0
I2CM_REN        .equ    P1REN
I2CM_OUT        .equ    P1OUT
    .ENDIF

    .IFDEF  UCB0_I2CM   ; for TERM2IIC add-on
I2CT_BUS        .equ    0Ch   ; P1.2=SDA P1.3=SCL
I2CT_SEL        .equ    P1SEL0
I2CT_REN        .equ    P1REN
I2CT_OUT        .equ    P1OUT
    .ENDIF

I2CT_SLA_BUS    .equ   07h     ; P2.0 P2.1 P2.1
I2CT_SLA_IN     .equ   P2IN
I2CT_SLA_OUT    .equ   P2OUT
I2CT_SLA_DIR    .equ   P2DIR
I2CT_SLA_REN    .equ   P2REN



; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage
            MOV.B #-1,&P3OUT  ; OUT1 for all pins
            BIS.B #-1,&P3REN  ; all pins with pull resistors


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

;    .IF FREQUENCY = 0.5
;
;            MOV #0D6h,&CSCTL0          ; preset DCO = 0xD6 (measured value @ 0x180 ; to measure, type 0x180 @ U.)
;
;            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
;; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;;            MOV     #100Dh,&CSCTL2      ; Set FLLD=1 (DCOCLKCDIV=DCO/2),set FLLN=0Dh
;                                        ; fCOCLKDIV = 32768 x (13+1) = 0.459 MHz ; measured :  MHz
;;            MOV     #100Eh,&CSCTL2      ; Set FLLD=1 (DCOCLKCDIV=DCO/2),set FLLN=0Eh
;                                        ; fCOCLKDIV = 32768 x (14+1) = 0.491 MHz ; measured :  MHz
;            MOV     #100Fh,&CSCTL2      ; Set FLLD=1 (DCOCLKCDIV=DCO/2),set FLLN=0Fh
;                                        ; fCOCLKDIV = 32768 x (15+1) = 0.524 MHz ; measured :  MHz
;; =====================================
;            MOV     #8,X
;
;    .ELSEIF FREQUENCY = 1
;
;            MOV #00B4h,&CSCTL0          ; preset DCO = 0xB4 (measured value @ 0x180 ; to measure, type HEX 0x180 ?)
;
;            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
;; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;;            MOV     #001Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Dh
;                                        ; fCOCLKDIV = 32768 x (29+1) = 0.983 MHz ; measured : 0.989MHz
;            MOV     #001Eh,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Eh
;                                        ; fCOCLKDIV = 32768 x (30+1) = 1.015 MHz ; measured : 1.013MHz
;;            MOV     #001Fh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Fh
;                                        ; fCOCLKDIV = 32768 x (31+1) = 1.049 MHz ; measured : 1.046MHz
;; =====================================
;            MOV     #16,X
;
;    .ELSEIF FREQUENCY = 2
;
;            MOV #00B4h,&CSCTL0          ; preset DCO = 0xB4 (measured value @ 0x180 ; to measure, type HEX 0x180 ?)
;
;            MOV     #0003h,&CSCTL1      ; Set 2MHZ DCORSEL,disable DCOFTRIM,Modulation
;; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;;            MOV     #003Bh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Bh
;                                        ; fCOCLKDIV = 32768 x (59+1) = 1.996 MHz ; measured :  MHz
;;            MOV     #003Ch,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Ch
;                                        ; fCOCLKDIV = 32768 x (60+1) = 1.998 MHz ; measured :  MHz
;            MOV     #003Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Dh
;                                        ; fCOCLKDIV = 32768 x (61+1) = 2.031 MHz ; measured :  MHz
;; =====================================
;            MOV     #32,X
;
;    .ELSEIF FREQUENCY = 4
;
;            MOV #00D2h,&CSCTL0          ; preset DCO = 0xD2 (measured value @ 0x180)
;
;            MOV     #0005h,&CSCTL1      ; Set 4MHZ DCORSEL,disable DCOFTRIM,Modulation
;; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;;            MOV     #0078h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=78h
;                                        ; fCOCLKDIV = 32768 x (120+1) = 3.965 MHz ; measured : 3.96MHz
;
;            MOV     #0079h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=79h
;                                        ; fCOCLKDIV = 32768 x (121+1) = 3.997 MHz ; measured : 3.99MHz
;
;;            MOV     #007Ah,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=7Ah
;                                        ; fCOCLKDIV = 32768 x (122+1) = 4.030 MHz ; measured : 4.020MHz
;; =====================================
;            MOV     #64,X
;
;    .ELSEIF FREQUENCY = 8
;
;
;            MOV #00F3h,&CSCTL0          ; preset DCO = 0xF2 (measured value @ 0x180)
;
;            MOV     #0007h,&CSCTL1      ; Set 8MHZ DCORSEL,disable DCOFTRIM,Modulation
;; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;;            MOV     #00F2h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F2h
;                                        ; fCOCLKDIV = 32768 x (242+1) = 7.963 MHz ; measured : 7.943MHz
;;            MOV     #00F3h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F3h
;                                        ; fCOCLKDIV = 32768 x (243+1) = 7.995 MHz ; measured : 7.976MHz
;            MOV     #00F4h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F4h
;                                        ; fCOCLKDIV = 32768 x (244+1) = 8.028 MHz ; measured : 8.009MHz
;
;;            MOV     #00F5h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F5h
;                                        ; fCOCLKDIV = 32768 x (245+1) = 8.061 MHz ; measured : 8.042MHz
;
;;            MOV     #00F8h,&CSCTL2      ; don't work with cp2102 (by low value)
;;            MOV     #00FAh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=FAh
;
;; =====================================
;            MOV     #128,X
;
;    .ELSEIF FREQUENCY = 16
;
;            MOV #0129h,&CSCTL0          ; preset DCO = 0x129 (measured value @ 0x180)
;
;            MOV     #000Bh,&CSCTL1      ; Set 16MHZ DCORSEL,disable DCOFTRIM,Modulation
;; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;;            MOV     #01E6h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E6h
;                                        ; fCOCLKDIV = 32768 x 486+1) = 15.958 MHz ; measured : 15.92MHz
;;            MOV     #01E7h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E7h
;                                        ; fCOCLKDIV = 32768 x 487+1) = 15.991 MHz ; measured : 15.95MHz
;;            MOV     #01E8h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E8h
;                                        ; fCOCLKDIV = 32768 x 488+1) = 16.023 MHz ; measured : 15.99MHz
;            MOV     #01E9h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E9h
;                                        ; fCOCLKDIV = 32768 x 489+1) = 16.056 MHz ; measured : 16.02MHz
;; =====================================
;            MOV     #256,X

    .IF FREQUENCY = 0.5

;            MOV     #058h,&CSCTL0       ; preset DCO = measured value @ 0x180 (88)
;            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
            MOV     #1ED1h,&CSCTL0       ; preset MOD=31, DCO = measured value @ 0x180 (209)
            MOV     #00B0h,&CSCTL1      ; Set 1MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
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

;            MOV     #100h,&CSCTL0       ; preset DCO = 256 
;            MOV     #00B1h,&CSCTL1      ; Set 1MHZ DCORSEL,enable DCOFTRIM=3h ,disable Modulation
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B0h,&CSCTL1      ; Set 1MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
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

;            MOV     #100h,&CSCTL0       ; preset DCO = 256 
;            MOV     #00B3h,&CSCTL1      ; Set 2MHZ DCORSEL,enable DCOFTRIM=3h ,disable Modulation
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B2h,&CSCTL1      ; Set 2MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #003Bh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Bh
                                        ; fCOCLKDIV = 32768 x (59+1) = 1.996 MHz ; measured :  MHz
            MOV     #003Ch,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Ch
                                        ; fCOCLKDIV = 32768 x (60+1) = 1.998 MHz ; measured :  MHz
;            MOV     #003Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Dh
                                        ; fCOCLKDIV = 32768 x (61+1) = 2.031 MHz ; measured :  MHz
; =====================================
            MOV     #32,X

    .ELSEIF FREQUENCY = 4

;            MOV     #100h,&CSCTL0       ; preset DCO = 256 
;            MOV     #00B5h,&CSCTL1      ; Set 4MHZ DCORSEL,enable DCOFTRIM=3h ,disable Modulation
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B4h,&CSCTL1      ; Set 4MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
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

;            MOV     #100h,&CSCTL0       ; preset DCO = 256 
;            MOV     #00B7h,&CSCTL1      ; Set 8MHZ DCORSEL,enable DCOFTRIM=3h ,disable Modulation
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B6h,&CSCTL1      ; Set 8MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #00F2h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F2h
                                        ; fCOCLKDIV = 32768 x (242+1) = 7.963 MHz ; measured : 7.943MHz
;            MOV     #00F3h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F3h
                                        ; fCOCLKDIV = 32768 x (243+1) = 7.995 MHz ; measured : 7.976MHz
            MOV     #00F4h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F4h
                                        ; fCOCLKDIV = 32768 x (244+1) = 8.028 MHz ; measured : 8.009MHz

;            MOV     #00F5h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F5h
                                        ; fCOCLKDIV = 32768 x (245+1) = 8.061 MHz ; measured : 8.042MHz

;            MOV     #00F8h,&CSCTL2      ; don't work with cp2102 (by low value)
;            MOV     #00FAh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=FAh

; =====================================
            MOV     #128,X

    .ELSEIF FREQUENCY = 12

;            MOV     #100h,&CSCTL0       ; preset DCO = 256 
;            MOV     #00B9h,&CSCTL1      ; Set 12MHZ DCORSEL,enable DCOFTRIM=3h ,disable Modulation
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B8h,&CSCTL1      ; Set 12MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #016Ch,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E6h
                                        ; fCOCLKDIV = 32768 x 364+1) = 12.960 MHz ; measured : 11.xxxMHz
;            MOV     #016Dh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E7h
                                        ; fCOCLKDIV = 32768 x 365+1) = 11.993 MHz ; measured : 11.xxxMHz
            MOV     #016Eh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E8h
                                        ; fCOCLKDIV = 32768 x 366+1) = 12.025 MHz ; measured : 12.xxxMHz
;            MOV     #016Fh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E9h
                                        ; fCOCLKDIV = 32768 x 367+1) = 12.058 MHz ; measured : 12.xxxMHz
; =====================================
            MOV     #192,X

    .ELSEIF FREQUENCY = 16

;            MOV     #100h,&CSCTL0       ; preset DCO = 256 
;            MOV     #00BBh,&CSCTL1      ; Set 16MHZ DCORSEL,enable DCOFTRIM=3h ,disable Modulation
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00BAh,&CSCTL1      ; Set 16MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ===================================== ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #01E6h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E6h
                                        ; fCOCLKDIV = 32768 x 486+1) = 15.958 MHz ; measured : 15.92MHz
;            MOV     #01E7h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E7h
                                        ; fCOCLKDIV = 32768 x 487+1) = 15.991 MHz ; measured : 15.95MHz
            MOV     #01E8h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E8h
                                        ; fCOCLKDIV = 32768 x 488+1) = 16.023 MHz ; measured : 15.99MHz
;            MOV     #01E9h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E9h
                                        ; fCOCLKDIV = 32768 x 489+1) = 16.056 MHz ; measured : 16.02MHz
; =====================================
            MOV     #256,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,12,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
;           MOV     #0000h,&CSCTL3      ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4      ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
    .ELSE
            BIS     #0010h,&CSCTL3      ; FLL select REFCLOCK
;           MOV     #0100h,&CSCTL4      ; ACLOCK select REFO, MCLK & SMCLK select DCOCLKDIV (default value)
    .ENDIF

            BIS &SYSRSTIV,&SAVE_SYSRSTIV; store volatile SYSRSTIV preserving a pending request for DEEP_RST
            CMP #2,&SAVE_SYSRSTIV       ; POWER ON ?
            JZ      ClockWaitX          ; yes
            .word   0749h               ; no  RRUM #1,X --> wait anyway 250 ms because FLL lock time = 200 ms
ClockWaitX  MOV     #5209,Y             ; wait 0.5s before starting after POR

ClockWaitY  SUB     #1,Y                ;1
            JNZ     ClockWaitY          ;2 5209x3 = 15625 cycles delay = 15.625ms @ 1MHz
            SUB     #1,X                ; x 32 @ 1 MHZ = 500ms
            JNZ     ClockWaitX          ; time to stabilize power source ( 500ms )

;WAITFLL     BIT #300h,&CSCTL7         ; wait FLL lock
;            JNZ WAITFLL
