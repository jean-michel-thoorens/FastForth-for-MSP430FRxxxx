; -*- coding: utf-8 -*-

; Fast Forth For Texas Instrument MSP430FR6989
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
; INIT MSP-EXP430FR6989 board
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
; P7 <-> P8 - TX1   - P3.4 UCA1 TXD ---> RX UARTtoUSB module
; P9 <->P10 - RX1   - P3.5 UCA1 RXD <--- TX UARTtoUSB module
; P11<->P12 - CTS   - P3.1
; P13<->P14 - RTS   - P3.0
; P15<->P16 - VCC   - 3V3
; P17<->P18 - 5V
; P19<->P20 - GND   - VSS

; Launchpad Header Left J1
; ------------------------
; P1 - 3V3
; P2 - P9.2 ESICH2
; P3 - P4.3 UCA0 RXD
; P4 - P4.2 UCA0 TXD
; P5 - P3.2 UCB1 SCL    
; P6 - P9.3 ESICH3
; P7 - P1.4 UCB0 CLK
; P8 - P2.0 TB0.6
; P9 - P4.1 UCB1 SCL
; P10- P4.0 UCB1 SDA

; Launchpad Header Left J3
; ------------------------
; P21 - 5V0
; P22 - GND
; P23 - P8.4 A7
; P24 - P8.5 A6
; P25 - P8.6 A5
; P26 - P8.7 A4
; P27 - P9.0 A8
; P28 - P9.1 A9
; P29 - P9.5 A13
; P30 - P9.6 A14

; Launchpad Header Right J2
; -------------------------
; P20- GND
; P19- P2.1 TB0.5
; P18- P1.5 TA0.0 UCA0 CLK
; P17- P9.4 ESIC10
; P16- RST
; P15- P1.6 UCB0 SDA
; P14- P1.7 UCB0 SCL
; P13- P2.5 TB0.4
; P12- P2.4 TB0.3
; P11- P4.7 TA1.2 UCB1 SOMI/SCL

; Launchpad Header Right J4
; -------------------------
; P40- P2.7 TB0.6
; P39- P2.6 TB0.5
; P38- P3.3 TA1.1
; P37- P3.6 TB0.2
; P36- P3.7 TB0.3
; P35- P2.2 UCA0 CLK
; P34- P1.3 TA1.2
; P33- P3.0 UCB1 CLK
; P32- P3.1 UCB1 SIMO/SDA
; P31- P2.3


; switch-keys:
; S1 - P1.1
; S2 - P1.2
; S3 - RST

; LEDS:
; LED1 - J7 - P1.0
; LED2 - J8 - P9.7

; XTAL LF 32768 Hz
; Y4 - PJ.4
; Y4 - PJ.5

; LCD
; 1  - P8.3
; 2  - P8.2
; 3  - P8.1
; 4  - P8.0
; 5  - P5.6
; 6  - P5.5
; 7  - P5.4
; 8  - P7.1
; 9  - P4.6
; 10 - P4.5
; 11 - P4.4
; 12 - P5.7
; 13 - P5.2
; 14 - P5.1
; 15 - P5.8
; 16 - P10.2
; 17 - P10.1
; 18 - P7.6
; 19 - P7.5
; 20 - P6.7
; 21 - P6.6
; 22 - P6.5
; 23 - P6.4
; 24 - P6.3
; 25 - NC
; 26 - NC
; 27 - NC
; 28 - NC
; 29 - NC
; 30 - NC
; 31 - NC
; 32 - P10.0
; 33 - P7.7
; 34 - P5.3
; 35 - P7.3
; 36 - P7.2
; 37 - P7.1
; 38 - P7.0


; Clocks:
; 8 MHz DCO intern



; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; then wire VCC and GND of bridge onto J13 connector
; ===================================================================================

; ---------------------------------------------------
; MSP  - MSP-EXP430FR6989 LAUNCHPAD <--> OUTPUT WORLD
; ---------------------------------------------------
; P1.0 - LED1 red
; P9.7 - LED2 green

; P1.1 - Switch S1              <--- LCD contrast + (finger :-)
; P1.2 - Switch S2              <--- LCD contrast - (finger ;-)
                                    
; note : ESI1.1 = lowest left pin
; note : ESI1.2 is not connected to 3.3V
;  GND/ESIVSS -          ESI1.3 <-------+---0V0---------->  1 LCD_Vss
;  VCC/ESIVCC -          ESI1.4 >------ | --3V3-----+---->  2 LCD_Vdd
;                                       |           |
;                                     |___    470n ---
;                                       ^ |        ---
;                                      / \ BAT54    |
;                                      ---          |
;                                  100n |    2k2    |
; P3.6 - UCA1 CLK TB0.2 J4.37   >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P9.0/ESICH0 -         ESI1.14 <------------------------> 11 LCD_DB4
; P9.1/ESICH1 -         ESI1.13 <------------------------> 12 LCD_DB5
; P9.2/ESICH2 -         ESI1.12 <------------------------> 13 LCD_DB5
; P9.3/ESICH3 -         ESI1.11 <------------------------> 14 LCD_DB7
; P9.4/ESICI0 -         ESI1.10 ------------------------->  4 LCD_RS
; P9.5/ESICI1 -         ESI1.9  ------------------------->  5 LCD_R/W
; P9.6/ESICI2 -         ESI1.8  ------------------------->  6 LCD_EN

;                                 +--4k7-< DeepRST <-- GND 
;                                 |
; P3.4 - UCA1 TXD       J101.8  <-+-> RX  UARTtoUSB bridge
; P3.5 - UCA1 RXD       J101.10 <---- TX  UARTtoUSB bridge
; P3.0 - RTS            J101.14 ----> CTS UARTtoUSB bridge (optional hardware control flow)
;  VCC -                J101.16 <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
;  GND -                J101.20 <---> GND (optional supply from UARTtoUSB bridge)

;  VCC -                J1.1    ----> VCC SD_CardAdapter
;  GND -                J2.20   <---> GND SD_CardAdapter
; P2.2 -  UCA0 CLK      J4.35   ----> CLK SD_CardAdapter (SCK)  
; P2.6 -                J4.39   ----> CS  SD_CardAdapter (Card Select)
; P2.0 -  UCA0 TXD/SIMO J1.8    ----> SDI SD_CardAdapter (MOSI)
; P2.1 -  UCA0 RXD/SOMI J2.19   <---- SDO SD_CardAdapter (MISO)
; P2.7 -                J4.40   <---- CD  SD_CardAdapter (Card Detect)

; P4.0 -                J1.10   <---- OUT IR_Receiver (1 TSOP32236)
;  VCC -                J6.1    ----> VCC IR_Receiver (2 TSOP32236)
;  GND -                J6.2    <---> GND IR_Receiver (3 TSOP32236)

; P1.3 -                J4.34   <---> SDA software I2C Master
; P1.5 -                J2.18   ----> SCL software I2C Master

; P1.4 -UCB0 CLK TA1.0  J1.7    <---> free

; P1.6 -UCB0 SDA/SIMO   J2.15   <---> SDA hardware I2C Master or Slave
; P1.7 -UCB0 SCL/SOMI   J2.14   ----> SCL hardware I2C Master or Slave

; P3.0 -UCB1 CLK        J4.33   ----> free (if UARTtoUSB with software control flow)
; P3.1 -UCB1 SDA/SIMO   J4.32   <---> free
; P3.2 -UCB1 SCL/SOMI   J1.5    ----> free
; P3.3 -         TA1.1  J1.5    <---> free

; PJ.4 - LFXI 32768Hz quartz  
; PJ.5 - LFXO 32768Hz quartz  
; PJ.6 - HFXI 
; PJ.7 - HFXO 
  

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

        MOV #WDTPW+WDTHOLD+WDTCNTCL,&WDTCTL    ; stop WDT

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT1 usage
; P1.0 - LED1 red   output low
; P1.1 - Switch S1
; P1.2 - Switch S2
SWITCHIN    .set P1IN   ; port
S1          .set 2      ; P1.1 bit position

; PORT2 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #1,&PADIR     ; all pins as input else P1.0
            MOV     #-2,&PAOUT    ; all pins with pullup resistors else P1.0 output low
            SUB     #2,&PAREN     ; all pins with pull resistors else P1.0

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage
; P3.0 = RTS
; P3.1 = CTS
; P3.4 = TX1
; P3.5 = RX1

Deep_RST_IN .equ P3IN   ; TERMINAL TX  pin as FORTH Deep_RST 
Deep_RST    .equ 10h    ; P3.4 = TX
TERM_TXRX   .equ 30h    ; P3.5 = RX
TERM_SEL    .equ P3SEL0
TERM_REN    .equ P3REN

; PORT4 usage

; PORTx default wanted state : pins as input with pullup resistor

    .IFDEF TERMINALCTSRTS
; RTS output is wired to the CTS input of UART2USB bridge 
; CTS is not used by FORTH terminal
; configure RTS as output high to disable RX TERM during start FORTH

RTS         .equ  1 ; P3.0
;CTS         .equ  2 ; P3.1 
HANDSHAKOUT .equ  P3OUT
HANDSHAKIN  .equ  P3IN

            BIS #00001h,&PBDIR  ; all pins as input else P3.0 (RTS)
            BIS #-1,&PBREN      ; all inputs with resistor
            MOV #-1,&PBOUT      ; that acts as pull up, P3.0 as output HIGH

    .ELSEIF
            BIS #-1,&PBREN      ; all inputs with resistor
            MOV #-1,&PBOUT      ; that acts as pull up

    .ENDIF
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT5 usage

; PORT6 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PCOUT    ; all pins 1
            BIS     #-1,&PCREN    ; all pins with pull resistors


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7/8
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT7 usage

; PORT8 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PDOUT    ; all pins 1
            BIS     #-1,&PDREN    ; all pins with pull resistors



; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT9/10
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT9 usage
; P9.7 Green LED2 as output low

; PORT10 usage
    
; PORTx default wanted state : pins as input with pullup resistor

            MOV     #00080h,&PEDIR    ; all pins as input else P9.7
            MOV     #0FF7Fh,&PEOUT    ; all pins high else P9.7
            BIS     #0FF7Fh,&PEREN    ; all pins with pull resistors else P9.7

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTJ usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B   #-1,&PJOUT    ; pullup resistors
            BIS.B   #-1,&PJREN    ; enable pullup/pulldown resistors

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
; This value is closer to 10MHz on untrimmed parts

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
    .ELSE
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

            MOV   #REFTCOFF, &REFCTL


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : RTC_C REGISTERS
; ----------------------------------------------------------------------

    .IFDEF LF_XTAL
; LFXIN : PJ.4, LFXOUT : PJ.5
    BIS.B   #010h,&PJSEL0   ; SEL0 for only LXIN
    BIC.B   #RTCHOLD,&RTCCTL1 ; Clear RTCHOLD = start RTC_B
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : SYS REGISTERS
; ----------------------------------------------------------------------

; SYS code                                  
; see COLD word


