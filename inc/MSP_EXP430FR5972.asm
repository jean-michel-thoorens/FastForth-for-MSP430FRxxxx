; -*- coding: utf-8 -*-

; ======================================================================
; INIT MSP-EXP430FR5972 virtual board
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

; Clocks:
; 8 MHz DCO intern

; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; then wire VCC and GND of bridge onto J13 connector
; ===================================================================================

; ---------------------------------------------------
; MSP  - MSP-EXP430FR5972 virtual LAUNCHPAD <--> OUTPUT WORLD
; ---------------------------------------------------
; P1.0 - LED1 red
; P9.7 - LED2 green

; P1.1 - Switch S1              <--- LCD contrast + (finger :-)
; P1.2 - Switch S2              <--- LCD contrast - (finger ;-)

;  GND                          <-------+---0V0---------->  1 LCD_Vss
;  VCC                          >------ | --3V3-----+---->  2 LCD_Vdd
;                                       |           |
;                                     |___    470n ---
;                                       ^ |        ---
;                                      / \ BAT54    |
;                                      ---          |
;                                  100n |    2k2    |
; P3.6 - UCA1 CLK TB0.2         >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P7.0/                         <------------------------> 11 LCD_DB4
; P7.1/                         <------------------------> 12 LCD_DB5
; P7.2/                         <------------------------> 13 LCD_DB5
; P7.3/                         <------------------------> 14 LCD_DB7
; P9.4/A12/C12                  ------------------------->  4 LCD_RS
; P9.5/A13/C13                  ------------------------->  5 LCD_R/W
; P9.6/A14/C14                  ------------------------->  6 LCD_EN

;                                 +--4k7-< DeepRST <-- GND
;                                 |
; P3.4 - UCA1 TXD               <-+-> RX  UARTtoUSB bridge
; P3.5 - UCA1 RXD               <---- TX  UARTtoUSB bridge
; P3.0 - RTS                    ----> CTS UARTtoUSB bridge (optional hardware control flow)
;  VCC -                        <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
;  GND -                        <---> GND (optional supply from UARTtoUSB bridge)

;  VCC -                        ----> VCC SD_CardAdapter
;  GND -                        <---> GND SD_CardAdapter
; P2.2 -  UCA0 CLK              ----> CLK SD_CardAdapter (SCK)
; P2.6 -                        ----> CS  SD_CardAdapter (Card Select)
; P2.0 -  UCA0 TXD/SIMO         ----> SDI SD_CardAdapter (MOSI)
; P2.1 -  UCA0 RXD/SOMI         <---- SDO SD_CardAdapter (MISO)
; P2.7 -                        <---- CD  SD_CardAdapter (Card Detect)

; P4.0 -                        <---- OUT IR_Receiver (1 TSOP32236)
;  VCC -                        ----> VCC IR_Receiver (2 TSOP32236)
;  GND -                        <---> GND IR_Receiver (3 TSOP32236)

; P1.3 -                        <---> SDA software I2C Master
; P1.5 -                        ----> SCL software I2C Master

; P1.4 -UCB0 CLK TA1.0          <---> free

; P1.6 -UCB0 SDA/SIMO           <---> SDA hardware I2C Master or Slave
; P1.7 -UCB0 SCL/SOMI           ----> SCL hardware I2C Master or Slave

; P3.0 -UCB1 CLK                ----> free (if UARTtoUSB with software control flow)
; P3.1 -UCB1 SDA/SIMO           <---> free
; P3.2 -UCB1 SCL/SOMI           ----> free
; P3.3 -         TA1.1          <---> free

; PJ.4 - LFXI 32768Hz quartz
; PJ.5 - LFXO 32768Hz quartz
; PJ.6 - HFXI
; PJ.7 - HFXO


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTA usage
    .IFDEF UCA0_SD
SD_SEL      .equ PASEL0 ; to configure UCB0
SD_REN      .equ PAREN  ; to configure pullup resistors
BUS_SD      .equ 0700h  ; pins P2.2 as UCA0CLK, P2.0 as UCA0SIMO & P2.1 as UCA0SOMI
    .ENDIF ;UCA0_SD

; PORT1 usage
; P1.0 - LED1 red   output low
LED1_OUT    .equ    P1OUT
LED1_DIR    .equ    P1DIR
LED1        .equ    1       ;  P1.0 LED1 red

; P1.1 - Switch S1
SW1_IN      .set P1IN       ; port
SW1         .set 2          ; P1.1 = S1

WIPE_IN     .equ    P1IN
IO_WIPE     .equ    2       ; P1.1 = S1 = FORTH Deep_RST pin

; P1.2 - Switch S2
SW2_IN      .set P1IN       ; port
SW2         .set 4          ; P1.2 = S2

; P1.6 -UCB0 SDA/SIMO   J2.15   <---> SDA hardware I2C Master or Slave
; P1.7 -UCB0 SCL/SOMI   J2.14   ----> SCL hardware I2C Master or Slave
    .IFDEF UCB0_TERM
TERM_IN     .equ    P1IN
TERM_SEL    .equ    P1SEL1
TERM_REN    .equ    P1REN
SDA         .equ    40h        ; P1.6 = SDA
SCL         .equ    80h        ; P1.7 = SCL
BUS_TERM    .equ    0C0h
    .ENDIF



; PORT2 usage

SD_CDIN     .equ P2IN
SD_CSOUT    .equ P2OUT
SD_CSDIR    .equ P2DIR
CS_SD       .equ 40h    ; P2.6 Chip Select
CD_SD       .equ 80h    ; P2.7 Card Detect

; PORTx default wanted state : pins as input with pullup resistor

            BIS     #-1,&PAREN     ; all pins with pull up/down resistor
            MOV     #-2,&PAOUT    ; all pins with pullup resistors else P1.0

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?
; PORTx default wanted state : pins as input with pullup resistor

; PORT3 usage
; P3.0 = RTS
; P3.1 = CTS
; P3.4 = TX1
; P3.5 = RX1

HANDSHAKOUT .equ    P3OUT
HANDSHAKIN  .equ    P3IN
RTS         .equ    1       ; P3.0
CTS         .equ    2       ; P3.1

    .IFDEF UCA1_TERM
TERM_IN     .equ    P3IN   ;
TERM_REN    .equ    P3REN
TERM_SEL    .equ    P3SEL0
TXD         .equ    10h    ; P3.4 = TXD
RXD         .equ    20h    ; P3.4 = RXD
BUS_TERM    .equ    30h    ; P3.5 = RX
    .ENDIF ;UCA1_TERM

; PORT4 usage

            MOV #-1,&PBREN  ; all pins as input with resistor
            MOV #-1,&PBOUT  ; all pins as input with resistor

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge
; configure RTS as output high to disable RX TERM during start FORTH
            BIS.B #RTS,&P3DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge
; configure CTS as input low (true) to avoid lock when CTS is not wired
            BIC.B #CTS,&P3OUT   ; CTS input pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT5 usage

; PORT6 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PCREN    ; all pins with pull resistors
            MOV     #-1,&PCOUT    ; all pins 1


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT7 usage

; PORT8 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B   #-1,&P7REN    ; all pins with pull resistors
            MOV.B   #-1,&P7OUT    ; all pins 1



; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT9
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT9 usage
; P9.7 Green LED2 as output low
LED2_OUT    .equ    P9OUT
LED2_DIR    .equ    P9DIR
LED2        .equ    80h        ;  P9.7 LED2 green


; PORT10 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B   #-1,&P9REN  ; all pins with pull resistors else P9.7
            MOV.B   #7Fh,&P9OUT ; all pins high else P9.7

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTJ usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B   #-1,&PJREN    ; enable pullup/pulldown resistors
            MOV.B   #-1,&PJOUT    ; pullup resistors

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF  FREQUENCY > 8
            MOV.B   #0A5h, &FRCTL0_H     ; enable FRCTL0 access
            MOV.B   #10h, &FRCTL0         ; 1 waitstate @ 16 MHz
            MOV.B   #01h, &FRCTL0_H       ; disable FRCTL0 access
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).

            MOV.B   #CSKEY,&CSCTL0_H    ;  Unlock CS registers
    .IF FREQUENCY = 1
            MOV     #0,&CSCTL1                          ; Set 1MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF FREQUENCY = 2
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3

    .ELSEIF FREQUENCY = 4
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL2+DCOFSEL1,&CSCTL1         ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF FREQUENCY = 12
            MOV     #DCORSEL+DCOFSEL2+DCOFSEL1,&CSCTL1  ; Set 24MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3   ;

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL+DCOFSEL2,&CSCTL1           ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0

    .ELSEIF
    .error "bad frequency setting, only 1,2,4,8,12,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSE
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #01h, &CSCTL0_H                               ; Lock CS Registers

            MOV     #64,X           ; 64* 3 ms = 192 ms delay (by default of specification)
ClockWaitX  MOV     &FREQ_KHZ,Y     ;
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 FREQ_KHZ x 3~ ==> 3ms
            SUB     #1,X            ;
            JNZ     ClockWaitX      ;

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

