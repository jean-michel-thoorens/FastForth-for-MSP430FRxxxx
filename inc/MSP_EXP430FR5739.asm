; -*- coding: utf-8 -*-

; ----------------------------------------------------------------------
; MSP_EXP430FR739.asm
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
; P1.6 - UCB0 SDA/SIMO   SV2.2  <---> SDA I2C MASTER/SLAVE
; P1.7 - UCB0 SCL/SOMI   SV2.1  <---> SCL I2C MASTER/SLAVE


; Clocks:
; 8 MHz DCO intern



; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK I/O as high impedance state
; ----------------------------------------------------------------------

    BIS #LOCKLPM5,&PM5CTL0 ; unlocked by WARM

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION PAIN=PORT2:PORT1
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT 1  usage
; P1.4 is used as analog input from NTC voltage divider

    .IFDEF UCB0_TERM
TERM_IN     .equ    P1IN
TERM_SEL    .equ    P1SEL1
TERM_REN    .equ    P1REN
SDA         .equ    40h        ; P1.6 = SDA
SCL         .equ    80h        ; P1.7 = SCL
BUS_TERM    .equ    0C0h
    .ENDIF

    .IFDEF UCA0_TERM
TERM_IN     .equ    P2IN
TERM_SEL    .equ    P2SEL1
TERM_REN    .equ    P2REN
TXD         .equ    1          ; P2.0 = TXD
RXD         .equ    2          ; P2.1 = RXD
BUS_TERM    .equ    3
    .ENDIF

    .IFDEF UCA1_SD
SD_SEL      .equ    PASEL1     ; to configure UCB0
SD_REN      .equ    PAREN      ; to configure pullup resistors
BUS_SD      .equ    7000h      ; pins P2.4 as UCB0CLK, P2.5 as UCB0SIMO & P2.6 as UCB0SOMI
    .ENDIF

SD_CDIN     .equ    P2IN
SD_CSOUT    .equ    P2OUT
SD_CSDIR    .equ    P2DIR
CD_SD       .equ    4          ; P2.2
CS_SD       .equ    8          ; P2.3

HANDSHAKOUT .equ    P2OUT
HANDSHAKIN  .equ    P2IN
RTS         .equ    4           ; P2.2
CTS         .equ    8           ; P2.3

; RTS output is wired to the CTS input of UART2USB bridge
; configure RTS as output high to disable RX TERM during start FORTH

; P2.7 is used to power the accelerometer and NTC voltage divider ==> output low = power OFF

    MOV #-1,&PAREN      ; all pins inputs with pull up/down resistor
    MOV #07FEFh,&PAOUT  ; all input pins with pull up resistor else P2.7 and P1.4

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge
; configure RTS as output high to disable RX TERM during start FORTH
            BIS.B #RTS,&P2DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge
; configure CTS as input low (true) to avoid lock when CTS is not wired
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

SW1_IN      .equ P4IN
SW1         .equ 1          ; P4.0 = S1

SW2_IN      .equ P4IN
SW2         .equ 2          ; P4.1 = S2


; PORTx default wanted state : pins as input with pullup resistor

    MOV #-1,&PBREN      ; all pins inputs with pull up/down resistor
    BIS #0FF08h,&PBOUT  ; all pins with pull up resistor else blues LEDs and ADC inputs

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?


; PJ FastForth usage
; PJ.0 to PJ.3 are  blues LEDs : set as output low = OFF

LED1_OUT    .equ    PJOUT
LED1_DIR    .equ    PJDIR
LED1        .equ    1           ;  PJ.0 LED1 blue

LED2_OUT    .equ    PJOUT
LED2_DIR    .equ    PJDIR
LED2        .equ    2           ;  PJ.1 LED2 blue

; PORTx default wanted state : pins as input with pullup resistor else leds output low

    BIS.B #-1,&PJREN    ; all pins inputs with pull up/down resistor
    MOV.B #0F0h,&PJOUT  ; all pins with pull up resistor else blues LEDs


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).

            MOV.B   #CSKEY,&CSCTL0_H ;  Unlock CS registers

    .IF FREQUENCY = 1
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_8 + DIVM_8,&CSCTL3

    .ELSEIF FREQUENCY = 2
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_4 + DIVM_4,&CSCTL3

    .ELSEIF FREQUENCY = 4
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF FREQUENCY = 10
            MOV     #DCORSEL+DCOFSEL1,&CSCTL1           ; Set 20 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3   ; then SMCLK/2 MCLK/2
            MOV     #160,X

    .ELSEIF FREQUENCY = 12
            MOV     #DCORSEL+DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 24 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3   ; then SMCLK/2 MCLK/2

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL,&CSCTL1                    ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF FREQUENCY = 20
            MOV     #DCORSEL+DCOFSEL1,&CSCTL1           ; Set 20 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF FREQUENCY = 24
            MOV     #DCORSEL+DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 24 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF
    .error "bad frequency setting, only 1,2,4,8,12,16,20,24 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSE
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #01h, &CSCTL0_H                     ; Lock CS Registers

            MOV     #64,X           ; 64* 3 ms = 192 ms delay (by default of specification)
ClockWaitX  MOV     &FREQ_KHZ,Y     ;
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 FREQ_KHZ x 3 ==> 3ms
            SUB     #1,X            ;
            JNZ     ClockWaitX      ;

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
