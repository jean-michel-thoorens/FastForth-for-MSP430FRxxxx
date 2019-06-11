; -*- coding: utf-8 -*-

; Fast Forth For Texas Instrument MSP430FR5739
; Tested on MSP-EXP430FR5739 launchpad
;
; Copyright (C) <2014>  <J.M. THOORENS>
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

; ----------------------------------------------------------------------
; MSP_EXP430FR739.inc 
; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; MSP430FR57xx BOOTSTRAP
; ----------------------------------------------------------------------
; BSL for MSP430FR573x devices
; BSL Version 00.04.31.71
; RAM erased 0x1C00-0x1FFF
; Buffer size for Core Commands : 260 bytes
; Notable Information
; 1. TX and RX pins are noted in the device data sheet
; 2. A mass erase command or incorrect password triggers a BSL reset. 
;    This resets the BSL state to the default settings (9600 baud, password locked)
; Known Bugs
; 1. The baud rate of 115k cannot be ensured across all clock, voltage, and temperature variations
; ----------------------------------------------------------------------
; ======================================================================
; INIT MSP-EXP430FR5739 board
; ======================================================================

; J3 (5xjumper), silkscreen printing:
; "TEST" - FR5739 pin19 = TEST
; "RST"  - FR5739 pin20 = RST
; "RXD"  - FR5739 pin22 = P2.1 == UCA0RXD --> UCA0RXDBUF
; "TXD"  - FR5739 pin21 = P2.0 == UCA0TXD <-- UCA0TXDBUf
; "VCC"  - + upper side

; 8x blue LEDs in a row.   (portpinX->---resistor---LED---GND)
; PJ.0 - LED1
; PJ.1 - LED2
; PJ.2 - LED3
; PJ.3 - LED4
; P3.4 - LED5
; P3.5 - LED6
; P3.6 - LED7
; P3.7 - LED8

; I/O pins on SV1:
; P1.0 - SV1.1
; P1.1 - SV1.2
; P1.2 - SV1.3
; P3.0 - SV1.4
; P3.1 - SV1.5
; P3.2 - SV1.6
; P3.3 - SV1.7
; P1.3 - SV1.8
; P1.4 - SV1.9
; P1.5 - SV1.10
; P4.0 - SV1.11
; GND  - SV1.12

; I/O pins on SV2:
; P1.7 - SV2.1
; P1.6 - SV2.2
; P3.7 - SV2.3
; P3.6 - SV2.4
; P3.5 - SV2.5
; P3.4 - SV2.6
; P2.2 - SV2.7
; P2.1 - SV2.8
; P2.6 - SV2.9
; P2.5 - SV2.10
; P2.0 - SV2.11
; VCC  - SV2.12

; I/O pins on RF:
; GND  - RF.1
; VCC  - RF.2
; P2.0 - RF.3
; P1.0 - RF.4
; P2.6 - RF.5
; P1.1 - RF.6
; P2.5 - RF.7
; P1.2 - RF.8
; P2.7 - RF.9
; P2.3 - RF.10
; P4.0 - RF.11
; GND  - RF.12
; P4.1 - RF.13
; P2.4 - RF.14
; P1.7 - RF.15
; P2.2 - RF.16
; P1.3 - RF.17
; P1.6 - RF.18

; Accelerometer:
; P2.7 - VS
; P3.0 - XOUT
; P3.1 - YOUT
; P3.2 - ZOUT

; LDR and NTC:
; P2.7 - VS
; P3.3 - LDR
; P1.4 - NTC

; RST - reset

; ======================================================================
; MSP-EXP430FR5739 LAUNCHPAD    <--> OUTPUT WORLD
; ======================================================================
;
; P4.0 - Switch S1              <--- LCD contrast + (finger :-)
; P4.1 - Switch S2              <--- LCD contrast - (finger :-)
;                                   
;  GND                          <-------+---0V0---------->  1 LCD_Vss
;  VCC                          >------ | --3V6-----+---->  2 LCD_Vdd
;                                       |           |
;                                     |___    470n ---
;                                       ^ |        ---
;                                      / \ BAT54    |
;                                      ---          |
;                                  100n |    2k2    |
; P1.5 - UCB0 CLK  TB0.2 SV1.10 >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P3.4 -                 SV2.6  ------------------------->  4 LCD_RS
; P3.5 -                 SV2.5  ------------------------->  5 LCD_R/W
; P3.6 -                 SV2.4  ------------------------->  6 LCD_EN
; P1.0 -                 SV1.1  <------------------------> 11 LCD_DB4
; P1.1 -                 SV1.2  <------------------------> 12 LCD_DB5
; P1.2 -                 SV1.3  <------------------------> 13 LCD_DB5
; P1.3 -                 SV1.8  <------------------------> 14 LCD_DB7
;
; PJ.4 - LFXI 32768Hz quartz  
; PJ.5 - LFXO 32768Hz quartz  
; PJ.6 - HFXI 
; PJ.7 - HFXO 
;                                 +--4k7-< DeepRST <-- GND 
;                                 |
; P2.0 -  UCA0 TXD       SV2.11 --+-> RX  UARTtoUSB bridge
; P2.1 -  UCA0 RXD       SV2.8  <---- TX  UARTtoUSB bridge
;  VCC -                        <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
;  GND -                        <---> GND (optional supply from UARTtoUSB bridge)
;        
; ---------------------------------------------------------------------------
; SD_CardAdapter not compatible with HARDWARE flow control for FORTH TERMINAL
; ---------------------------------------------------------------------------
; VCC  -                 RF.2 
; VSS  -                 RF.1 
; P2.2 -                 RF.16  <---- CD  SD_CardAdapter (Card Detect) / RTS
; P2.3 -                 RF.10  ----> CS  SD_CardAdapter (Card Select) / CTS
; P2.4 - UCA1 CLK        RF.14  ----> CLK SD_CardAdapter (SCK)  
; P2.5 - UCA1 TXD/SIMO   RF.7   ----> SDI SD_CardAdapter (MOSI)
; P2.6 - UCA1 RXD/SOMI   RF.5   <---- SDO SD_CardAdapter (MISO)
;
; P2.7 -                 RF.9   <---- OUT IR_Receiver (1 TSOP32236)
;
; P1.7 - UCB0 SCL/SOMI   SV2.1  <---> SCL I2C MASTER/SLAVE
; P1.6 - UCB0 SDA/SIMO   SV2.2  <---> SDA I2C MASTER/SLAVE


; Clocks:
; 8 MHz DCO intern



; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK I/O as high impedance state
; ----------------------------------------------------------------------

    BIS #LOCKLPM5,&PM5CTL0 ; unlocked by WARM

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

; WDT code
    MOV #WDTPW+WDTHOLD+WDTCNTCL,&WDTCTL    ; stop WDT

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION PAIN=PORT2:PORT1
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT 1  usage
; P1.4 is used as analog input from NTC voltage divider



    .IFDEF UCA0_TERM
TERM_IN     .equ P2IN
TXD         .equ 1          ; P2.0 = TXD + FORTH Deep_RST pin
RXD         .equ 2          ; P2.1 = RXD
TERM_BUS    .equ 3
TERM_SEL    .equ P2SEL1
TERM_REN    .equ P2REN
    .ENDIF

    .IFDEF UCB0_SD
SD_SEL      .equ PASEL1     ; to configure UCB0
SD_REN      .equ PAREN      ; to configure pullup resistors
SD_BUS      .equ 7000h      ; pins P2.4 as UCB0CLK, P2.5 as UCB0SIMO & P2.6 as UCB0SOMI
SD_CD       .equ 4          ; P2.2 as SD_CD
SD_CS       .equ 8          ; P2.3 as SD_CS     
SD_CDIN     .equ P2IN
SD_CSOUT    .equ P2OUT
SD_CSDIR    .equ P2DIR
    .ENDIF


; RTS output is wired to the CTS input of UART2USB bridge 
; configure RTS as output high to disable RX TERM during start FORTH

; P2.7 is used to power the accelerometer and NTC voltage divider ==> output low = power OFF

    MOV #-1,&PAREN      ; all pins inputs with pull up/down resistor
    MOV #07FEFh,&PAOUT  ; all input pins with pull up resistor else P2.7 and P1.4

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge 
; configure RTS as output high to disable RX TERM during start FORTH
HANDSHAKOUT .equ    P2OUT
HANDSHAKIN  .equ    P2IN
RTS         .equ    4           ; P2.2
            BIS.B #RTS,&P2DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge 
; configure CTS as input low (true) to avoid lock when CTS is not wired
CTS         .equ    8           ; P2.3
            BIC.B #CTS,&P2OUT   ; CTS input pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------
; PB = P4:P3

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; P3 FastForth usage
; P3.0 to P3.2 are accelerometer analog outputs

; P3.4 to P3.7 are blues LEDs : set output low = OFF

; P4 FastForth usage
; P4.0 Switch S1
; P4.1 switch S2

SWITCHIN    .equ P4IN
S1          .equ 1

; PORTx default wanted state : pins as input with pullup resistor

    MOV #-1,&PBREN      ; all pins inputs with pull up/down resistor
    BIS #0FF08h,&PBOUT  ; all pins with pull up resistor else blues LEDs and ADC inputs

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?


; PJ FastForth usage
; PJ.0 to PJ.3 are  blues LEDs : set as output low = OFF

; PORTx default wanted state : pins as input with pullup resistor else leds output low

    BIS.B #-1,&PJREN    ; all pins inputs with pull up/down resistor
    MOV.B #0F0h,&PJOUT  ; all pins with pull up resistor else blues LEDs


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).

            MOV.B   #CSKEY,&CSCTL0_H ;  Unlock CS registers

    .IF FREQUENCY = 0.25
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_32 + DIVM_32,&CSCTL3
            MOV     #4,X

    .ELSEIF FREQUENCY = 0.5
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_16 + DIVM_16,&CSCTL3
            MOV     #8,X

    .ELSEIF FREQUENCY = 1
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_8 + DIVM_8,&CSCTL3
            MOV     #16,X

    .ELSEIF FREQUENCY = 2
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_4 + DIVM_4,&CSCTL3
            MOV     #32,X

    .ELSEIF FREQUENCY = 4
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3
            MOV     #64,X

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #128,X

    .ELSEIF FREQUENCY = 10
            MOV     #DCORSEL+DCOFSEL1,&CSCTL1           ; Set 20 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3   ; then SMCLK/2 MCLK/2
            MOV     #160,X

    .ELSEIF FREQUENCY = 12
            MOV     #DCORSEL+DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 24 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3   ; then SMCLK/2 MCLK/2
            MOV     #192,X

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL,&CSCTL1                    ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #256,X

    .ELSEIF FREQUENCY = 20
            MOV     #DCORSEL+DCOFSEL1,&CSCTL1           ; Set 20 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #320,X

    .ELSEIF FREQUENCY = 24
            MOV     #DCORSEL+DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 24 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #384,X

    .ELSEIF
    .error "bad frequency setting, only 0.25,0.5,1,2,4,8,12,16,20,24 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSE
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #01h, &CSCTL0_H                     ; Lock CS Registers

            BIS &SYSRSTIV,&SAVE_SYSRSTIV    ; store volatile SYSRSTIV preserving a pending request for DEEP_RST
;            MOV &SAVE_SYSRSTIV,TOS  ;
;            CMP #2,TOS              ; POWER ON ?
;            JZ      ClockWaitX      ; yes
;            RRUM    #2,X            ; wait only 125 ms
ClockWaitX  MOV     #5209,Y         ; wait 0.5s before starting after POWER ON
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 5209x3 = 15625 cycles delay = 15.625ms @ 1MHz
            SUB     #1,X            ; x 32 @ 1 MHZ = 500ms
            JNZ     ClockWaitX      ; time to stabilize power source ( 500ms )

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : REF
; ----------------------------------------------------------------------

            BIS.W   #REFTCOFF, &REFCTL  ; Turn off temp.
            BIC.W   #REFON, &REFCTL


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : RTC REGISTERS
; ----------------------------------------------------------------------
    .IFDEF LF_XTAL
; LFXIN : PJ.4, LFXOUT : PJ.5
    BIS.B   #010h,&PJSEL0   ; SEL0 for only LFXIN
    BIC.B   #RTCHOLD,&RTCCTL1 ; Clear RTCHOLD = start RTC_B
    .ENDIF

