; -*- coding: utf-8 -*-
; MSP-EXP430FR5969.inc

; Fast Forth For Texas Instrument MSP430FR5969
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



; ======================================================================
; INIT MSP-EXP430FR5969 board
; ======================================================================

;
; J21 : external target
; ---------------------
; P1 - RX0  - P2.1
; P2 - VCC
; P3 - TEST - TEST
; P4 - RST  - RST
; P5 - GND
; P6 - TX0  - P2.0


; J3: JTAG
; --------
; P1 - TDO  - PJ.0
; P2 - V_debug
; P3 - TDI  - PJ.1
; P4 - V_ext
; P5 - TMS  - PJ.2
; P6 - NC
; P7 - TCK  - PJ.3
; P8 - TEST - TEST
; P9 - GND
; P10- CTS  - P4.0
; P11- RST  - RESET
; P12- TX0  - P2.0
; P13- RTS  - P4.1
; P14- RX0  - P2.1


; J13   eZ-FET <-> target
; -----------------------
; P1 <-> P2 - NC
; P3 <-> P4 - TEST  - TEST
; P5 <-> P6 - RST   - RST
; P7 <-> P8 - TX0   - P2.0 ---> RX UARTtoUSB
; P9 <->P10 - RX0   - P2.1 <--- TX UARTtoUSB
; P11<->P12 - CTS   - P4.0
; P13<->P14 - RTS   - P4.1
; P15<->P16 - VCC   - VDD
; P17<->P18 - 5V
; P19<->P20 - GND   - VSS

; Launchpad Header Left J4
; ------------------------
; P1 - VCC
; P2 - P4.2
; P3 - P2.6 UCA1 RX/SOMI ---> SD_SDO
; P4 - P2.5 UCA1 TX/SIMO <--- SD_SDI
; P5 - P4.3              ---> SD_SS
; P6 - P2.4 UCA1     CLK ---> SD_CLK
; P7 - P2.2 TB0.2 UCB0CLK
; P8 - P3.4
; P9 - P3.5
; P10- P3.6

; Launchpad Header Right J5
; -------------------------
; P11- P1.3
; P12- P1.4
; P13- P1.5
; P14- P1.6  UCB0 SIMO/SDA
; P15- P1.7  UCB0 SOMI/SCL
; P16- RST
; P17- NC
; P18- P3.0
; P19- P1.2
; P20- GND


; switch-keys:
; S1 - P4.5
; S2 - P1.1
; S3 - RST

; LEDS:
; LED1 - J6 - P4.6
; LED2 -      P1.0

; XTAL LF 32768 Hz
; Y4 - PJ.4
; Y4 - PJ.5

; XTAL HF
; Y1 - PJ.6
; Y1 - PJ.7

; Clocks:
; 8 MHz DCO intern



; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; ===================================================================================

; -----------------------------------------------
; MSP430FR5969        LAUNCHPAD <--> OUTPUT WORLD
; -----------------------------------------------
; P4.6 - J6 - LED1 red
; P1.0 - LED2 green

; P4.5 - Switch S1              <--- LCD contrast + (finger :-)
; P1.1 - Switch S2              <--- LCD contrast - (finger ;-)
                                    
;  GND -                 J1.2   <-------+---0V0---------->  1 LCD_Vss
;  VCC -                 J1.3   >------ | --3V6-----+---->  2 LCD_Vdd
;                                       |           |
;                                     |___    470n ---
;                                       ^ |        ---
;                                      / \ BAT54    |
;                                      ---          |
;                                  100n |    2k2    |
; P2.2 - UCB0 CLK TB0.2  J4.7   >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P3.4 -                 J4.8   ------------------------->  4 LCD_RS
; P3.5 -                 J4.9   ------------------------->  5 LCD_R/W
; P3.6 -                 J4.10  ------------------------->  6 LCD_EN0
; PJ.0 -                 J3.1   <------------------------> 11 LCD_DB4
; PJ.1 -                 J3.3   <------------------------> 12 LCD_DB5
; PJ.2 -                 J3.5   <------------------------> 13 LCD_DB5
; PJ.3 -                 J3.7   <------------------------> 14 LCD_DB7
         
;                                 +--4k7-< DeepRST <-- GND 
;                                 |
; P2.0 - UCA0 TXD        J13.8  <-+-> RX   UARTtoUSB bridge
; P2.1 - UCA0 RXD        J13.10 <---- TX   UARTtoUSB bridge
; P4.1 - RTS             J13.14 ----> CTS  UARTtoUSB bridge (optional hardware control flow)
;  VCC -                 J13.16 <---- VCC  (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
;  GND -                 J13.20 <---> GND  (optional supply from UARTtoUSB bridge)
         
;  VCC -                 J11.1  ----> VCC  SD_CardAdapter
;  GND -                 J12.3  <---> GND  SD_CardAdapter
; P2.4 - UCA1 CLK        J4.6   ----> CLK  SD_CardAdapter (SCK)  
; P4.3 -                 J4.5   ----> CS   SD_CardAdapter (Card Select)
; P2.5 - UCA1 TXD/SIMO   J4.4   ----> SDI  SD_CardAdapter (MOSI)
; P2.6 - UCA1 RXD/SOMI   J4.3   <---- SDO  SD_CardAdapter (MISO)
; P4.2 -                 J4.2   <---- CD   SD_CardAdapter (Card Detect)
         
; P4.0 -                 J3.10  <---- OUT  IR_Receiver (1 TSOP32236)
;  VCC -                 J3.2   ----> VCC  IR_Receiver (2 TSOP32236)
;  GND -                 J3.9   <---> GND  IR_Receiver (3 TSOP32236)
         
; P1.2 -                 J5.19  <---> SDA  I2C SOFTWARE MASTER
; P1.3 -                 J5.11  <---> SCL  I2C SOFTWARE MASTER
; P1.4 -           TB0.1 J5.12  <---> free
; P1.5 - UCA0 CLK  TB0.2 J5.13  <---> free
; P1.7 - UCB0 SCL/SOMI   J5.14  ----> SCL  I2C MASTER/SLAVE
; P1.6 - UCB0 SDA/SIMO   J5.15  <---> SDA  I2C MASTER/SLAVE
; P3.0 -                 J5.7   <---- free

; PJ.4 - LFXI 32768Hz quartz  
; PJ.5 - LFXO 32768Hz quartz  
; PJ.6 - HFXI 
; PJ.7 - HFXO 
  
; P2.3 - NC
; P2.7 - NC
; P3.1 - NC
; P3.2 - NC
; P3.3 - NC
; P3.7 - NC
; P4.4 - NC
; P4.7 - NC



; ----------------------------------------------------------------------
; INIT order : LOCK I/O, WDT, GPIOs, FRAM, Clock, UARTs
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------

;              BIS     #LOCKLPM5,&PM5CTL0 ; unlocked by WARM

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

        MOV #WDTPW+WDTHOLD+WDTCNTCL,&WDTCTL    ; stop WDT

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT1 usage
; P1.0 - LED2 green   output low
; P1.1 - Switch S2    input with pullup resistor

; PORT2 usage


Deep_RST_IN .equ P2IN  ; TERMINAL TX  pin as FORTH Deep_RST 
Deep_RST    .equ 1     ; P2.0
TERM_TXRX   .equ 003h
TERM_SEL    .equ P2SEL1
TERM_REN    .equ P2REN

; PORTx default wanted state : pins as input with pullup resistor

            BIS     #1,&PADIR   ; all pins 0 as input else P1.0 (LED2)
            MOV     #0FFFEh,&PAOUT  ; all pins high  else P1.0 (LED2)
            SUB     #2,&PAREN   ; all pins 1 with pull resistors else P1.0 (LED2)

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------
; PB = P4:P3

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage

; PORT4 usage
; P4.5 - switch S1
; P4.6 - LED1 red

    .IFDEF TERMINAL4WIRES

; RTS output is wired to the CTS input of UART2USB bridge 
; configure RTS as output high to disable RX TERM during start FORTH

HANDSHAKOUT .equ  P4OUT
HANDSHAKIN  .equ  P4IN
RTS         .equ  2 ; P4.1

            BIS #04200h,&PBDIR  ; all pins as input else P4.1 (RTS), P4.6 (LED1)
            BIS #-1,&PBREN      ; all inputs with resistor

        .IFDEF TERMINAL5WIRES

CTS         .equ  1 ; P4.0 

            MOV #0BEFFh,&PBOUT  ; that acts as pull up , P4.6 (LED1) output LOW, RTS output HIGH, CTS input LOW

        .ELSEIF

            MOV #0BFFFh,&PBOUT  ; that acts as pull up , P4.6 (LED1) output LOW, RTS output HIGH

        .ENDIF  ; TERMINAL5WIRES

    .ELSEIF
            BIS #04000h,&PBDIR  ; all pins as input else P4.6 (LED1)
            BIS #-1,&PBREN      ; all inputs with resistor
            MOV #0BFFFh,&PBOUT  ; that acts as pull up, P4.6 (LED1) output LOW

    .ENDIF  ; TERMINAL4WIRES


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B #-1,&PJOUT    ; pullup resistors
            BIS.B #-1,&PJREN    ; enable pullup/pulldown resistors

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF FREQUENCY = 16
            MOV.B   #0A5h, &FRCTL0_H     ; enable FRCTL0 access
            MOV.B   #10h, &FRCTL0         ; 1 waitstate @ 16 MHz
            MOV.B   #01h, &FRCTL0_H       ; disable FRCTL0 access
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).
; Startup clock system in max. DCO setting ~8MHz

            MOV.B   #CSKEY,&CSCTL0_H ;  Unlock CS registers

    .IF FREQUENCY = 0.25
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_32 + DIVM_32,&CSCTL3
            MOV     #2,X

    .ELSEIF FREQUENCY = 0.5
            MOV     #0,&CSCTL1                  ; Set 1MHZ DCO setting
            MOV     #DIVA_2 + DIVS_2 + DIVM_2,&CSCTL3             ; set all dividers as 2
            MOV     #4,X

    .ELSEIF FREQUENCY = 1
            MOV     #0,&CSCTL1                  ; Set 1MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #8,X

    .ELSEIF FREQUENCY = 2
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3
            MOV     #16,X

    .ELSEIF FREQUENCY = 4
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #32,X

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL2+DCOFSEL1,&CSCTL1  ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #64,X

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL+DCOFSEL2,&CSCTL1   ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #128,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSEIF
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #01h, &CSCTL0_H                               ; Lock CS Registers

            BIS &SYSRSTIV,&SAVE_SYSRSTIV; store volatile SYSRSTIV preserving a pending request for DEEP_RST
            CMP #2,&SAVE_SYSRSTIV   ; POWER ON ?
            JZ      ClockWaitX      ; yes
            .word   0759h           ; no  RRUM #2,X --> wait only 125 ms
ClockWaitX  MOV     #41666,Y        ; wait 0.5s before starting after POWER ON
ClockWaitY  SUB     #1,Y            ;
            JNZ     ClockWaitY      ; 41666x3 = 125000 cycles delay = 125ms @ 1MHz
            SUB     #1,X            ; x 4 @ 1 MHZ
            JNZ     ClockWaitX      ; time to stabilize power source ( 1s )

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : REF
; ----------------------------------------------------------------------

            BIS   #8, &REFCTL

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : RTC REGISTERS
; ----------------------------------------------------------------------

    .IFDEF LF_XTAL
; LFXIN : PJ.4, LFXOUT : PJ.5
    BIS.B   #010h,&PJSEL0   ; SEL0 for only LFXIN
    BIC.B   #RTCHOLD,&RTCCTL1 ; Clear RTCHOLD = start RTC_B
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : SYS REGISTERS
; ----------------------------------------------------------------------

; SYS code                                  
; see COLD word

