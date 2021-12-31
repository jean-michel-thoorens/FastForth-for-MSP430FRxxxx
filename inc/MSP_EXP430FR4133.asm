; -*- coding: utf-8 -*-

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
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

            BIS #-1,&PAREN      ; all input pins with resistor
            BIS #-1,&PAOUT      ; all pins with PULLUP resistor

; PORT1 usage

; P1.0 - TX0 --> JP1 --> red LED1 --> GND
; P1.1 - RX0

SW1_IN      .equ    P1IN
SW1         .equ    4       ; P1.2 = S1

WIPE_IN     .equ    P1IN
IO_WIPE     .equ    4       ; P1.2 = S1 = FORTH Deep_RST pin

    .IFDEF UCA0_TERM
TERM_IN     .equ    P1IN
TERM_REN    .equ    P1REN
TERM_SEL    .equ    P1SEL0
TXD         .equ    1       ; P1.0 = TXD
RXD         .equ    2       ; P1.1
BUS_TERM    .equ    003h    ; TX RX
    .ENDIF

HANDSHAKOUT .set    P2OUT
HANDSHAKIN  .set    P2IN
RTS         .set    8           ; P2.3 bit position
CTS         .set    10h         ; P2.4 bit position

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge
; configure RTS as output high to disable RX TERM during start FORTH
            BIS.B #RTS,&P2DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
            BIC.B #CTS,&P2OUT   ; CTS input pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES

SW2_IN      .equ    P2IN
SW2         .equ    40h     ; P2.6 = S2

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

            BIS #0FEFFh,&PBREN   ; pullup for all pins resistors else P4.0
            MOV #-1,&PBOUT   ; OUT1 for all pins else P4

; P3 configuration :

; P4 configuration :
; P4.0 - LED2 green
; P4.1 - LFXI 32768Hz quartz
; P4.2 - LFXO 32768Hz quartz

LED2_OUT    .equ    P4OUT
LED2_DIR    .equ    P4IN
LED2        .equ    1           ;  P4.0 LED2 green

; PORTx default wanted state : pins as input with pullup resistor

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

            BIS     #-1,&PCREN    ; all pins with pull resistors
            MOV     #-1,&PCOUT    ; all pins OUT1

; PORTC usage
    .IFDEF UCB0_TERM
TERM_IN         .equ P5IN
TERM_REN        .equ P5REN
TERM_SEL        .equ P5SEL0
SDA             .equ 4
SCL             .equ 8
BUS_TERM        .equ 0Ch
    .ENDIF

    .IFDEF UCB0_SD
SD_SEL      .equ PCSEL0 ; to configure UCB0
SD_REN      .equ PCREN  ; to configure pullup resistors
BUS_SD      .equ 000Eh  ; pins P5.1 as UCB0CLK, P5.2 as UCB0SIMO & P5.3 as UCB0SOMI
    .ENDIF
; PORTx default wanted state : pins as input with pullup resistor

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7/8
; ----------------------------------------------------------------------

            BIS     #-1,&PDREN    ; all pins with pull resistors
            MOV     #-1,&PDOUT    ; all pins OUT1

SD_CDIN     .equ P8IN
SD_CSOUT    .equ P8OUT
SD_CSDIR    .equ P8DIR
CD_SD       .equ 1        ; P8.0
CS_SD       .equ 2        ; P8.1

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTx default wanted state : pins as input with pullup resistor

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF  FREQUENCY > 8
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

    .IFDEF LF_XTAL
;           MOV     #0000h,&CSCTL3      ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4      ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
            BIS.B   #06,&P4SEL0         ; P4.2 as XOUT, P4.1 as XIN
    .ELSE
            BIS     #0010h,&CSCTL3      ; FLL select REFCLOCK
;            MOV     #0100h,&CSCTL4      ; ACLOCK select REFO, MCLK & SMCLK select DCOCLKDIV (default value)
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
            MOV     #64,X               ; 64* 3 ms = 192 ms delay, because FLL lock time = 120 ms
ClockWaitX  MOV     &FREQ_KHZ,Y         ;
ClockWaitY  SUB     #1,Y                ;1
            JNZ     ClockWaitY          ;2 FREQ_KHZ x 3 ==> 3ms
            SUB     #1,X                ;
            JNZ     ClockWaitX          ;
