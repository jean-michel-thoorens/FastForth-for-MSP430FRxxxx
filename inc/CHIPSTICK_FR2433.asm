; -*- coding: utf-8 -*-
; CHIPSTICK_FR2433.inc

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
; P3 -  4 - P1.5 UCA0 RX/SOMI
; P4 -  3 - P1.4 UCA0 TX/SIMO
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

    .IFDEF UCB0_TERM        ;
TERM_SEL    .equ    P1SEL0
TERM_REN    .equ    P1REN
TERM_OUT    .equ    P1OUT
BUS_TERM    .equ    0Ch     ; P1.2=SDA P1.3=SCL
    .ENDIF

    .IFDEF UCB0_SD
SD_SEL      .equ PASEL0     ; to configure UCB0
SD_REN      .equ PAREN      ; to configure pullup resistors
BUS_SD      .equ 000Eh      ; pins P1.1 as UCB0CLK, P1.2 as UCB0SIMO & P1.3 as UCB0SOMI
    .ENDIF

    .IFDEF UCA0_TERM
TERM_IN     .equ P1IN
TERM_SEL    .equ P1SEL0
TERM_REN    .equ P1REN
TXD         .equ 10h        ; P1.4
RXD         .equ 20h        ; P1.5
BUS_TERM    .equ 30h
    .ENDIF

SW1_IN     .equ    P1IN
SW1        .equ    10h     ; P1.4 = FORTH Deep_RST pin

    .IFDEF UCA0_SD
BUS_SD    .equ 0070h        ; pins P1.4,P1.5,P1.6
SD_SEL    .equ PASEL0
SD_REN    .equ PAREN
    .ENDIF

; PORT2 usage
CD_SD       .equ 8          ; P2.3 as Card Detect
SD_CDIN     .equ P2IN

CS_SD       .equ 4          ; P2.2 as Card Select
SD_CSOUT    .equ P2OUT
SD_CSDIR    .equ P2DIR

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage
; P3.1 -           LED1

HANDSHAKOUT .equ    P3OUT
HANDSHAKIN  .equ    P3IN
CTS         .equ    1           ; P3.0
RTS         .equ    4           ; P3.2

; RTS output is wired to the CTS input of UART2USB bridge
; CTS is not used by FORTH terminal
; configure RTS as output high to disable RX TERM during start FORTH

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B #001h,&P3DIR  ; all pins as input else LED1 as output
            BIS.B #-1,&P3REN    ; all inputs with pull resistors
            MOV.B #0FDh,&P3OUT  ; all pins with pullup resistors and LED1 = output low

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
; FRAM config
; ----------------------------------------------------------------------

    .IF FREQUENCY >8
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

    .IFDEF LF_XTAL
;           MOV     #0000h,&CSCTL3  ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4  ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
            BIS.B   #03,&P2SEL0     ; P2.0 as XOUT, P2.1 as XIN
    .ELSE
            BIS     #0010h,&CSCTL3  ; FLL select REFCLOCK
            MOV     #0200h,&CSCTL4  ; ACLOCK select VLOCLK, MCLK & SMCLK select DCOCLKDIV (default value)
    .ENDIF
            BIC.B   #-1,&CSCTL1     ; clear DCORSEL (Set 1MHZ DCORSEL), DCOFTRIM=0, ENable MODulation to reduce EMI
    .IF FREQUENCY = 1               ; nothing else to do
    .ELSEIF FREQUENCY = 2
            BIS.B   #2,&CSCTL1      ; Set 2MHZ DCORSEL
    .ELSEIF FREQUENCY = 4
            BIS.B   #4,&CSCTL1      ; Set 4MHZ DCORSEL
    .ELSEIF FREQUENCY = 8
            BIS.B   #6,&CSCTL1      ; Set 8MHZ DCORSEL
    .ELSEIF FREQUENCY = 12
            BIS.B   #8,&CSCTL1      ; Set 12MHZ DCORSEL
    .ELSEIF FREQUENCY = 16
            BIS.B   #10,&CSCTL1     ; Set 16MHZ DCORSEL
    .ELSEIF
    .error "bad frequency setting, only 1,2,4,8,12,16 MHz"
    .ENDIF
;            MOV #INT(FREQUENCY*1000000/32768)-1,&CSCTL2; set FLLD=0 (DCOCLKCDIV=DCO),set FLLN for frequency slight lower
            MOV #INT(FREQUENCY*1000000/32768),&CSCTL2; set FLLD=0 (DCOCLKCDIV=DCO),set FLLN for frequency slight upper
            MOV     #128,X          ; 128* 3 ms = 384 ms delay, because FLL lock time = 280 ms
ClockWaitX  MOV     &FREQ_KHZ,Y     ;
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 FREQ_KHZ x 3 ==> 3ms
            SUB     #1,X            ;
            JNZ     ClockWaitX      ;
