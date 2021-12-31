; -*- coding: utf-8 -*-

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

LED1_OUT    .equ    P1OUT
LED1_DIR    .equ    P1DIR
LED1        .equ    1           ;  P1.0 LED1 red

LED2_OUT    .equ    P1OUT
LED2_DIR    .equ    P1DIR
LED2        .equ    2           ;  P1.1 LED2 green

HANDSHAKOUT .equ    P1OUT
HANDSHAKIN  .equ    P1IN
RTS         .equ    1           ; P1.0
CTS         .equ    2           ; P1.1

    .IFDEF UCB0_TERM            ;
TERM_SEL    .equ    P1SEL0
TERM_REN    .equ    P1REN
TERM_OUT    .equ    P1OUT
BUS_TERM    .equ    0Ch         ; P1.2=SDA, P1.3=SCL
    .ENDIF

    .IFDEF UCB0_SD
SD_SEL      .equ    PASEL0      ; to configure UCB0
SD_REN      .equ    PAREN       ; to configure pullup resistors
BUS_SD      .equ    000Eh       ; pins P1.1 as UCB0CLK, P1.2 as UCB0SIMO & P1.3 as UCB0SOMI
    .ENDIF

    .IFDEF UCA0_TERM
TERM_IN     .equ    P1IN
TERM_SEL    .equ    P1SEL0
TERM_REN    .equ    P1REN
BUS_TERM    .equ    30h         ; P1.4=TX, P1.5=RX
    .ENDIF

    .IFDEF UCA0_SD
SD_SEL    .equ PASEL0
SD_REN    .equ PAREN
BUS_SD    .equ 0070h            ; pins P1.4,P1.5,P1.6
    .ENDIF



; PORT2 usage
SD_CSOUT    .equ    P2OUT
SD_CSDIR    .equ    P2DIR
CS_SD       .equ    1           ; P2.0  ---> CS_SD (Card Select)

SD_CDIN     .equ    P2IN
CD_SD       .equ    2           ; P2.1  <--- CD_SD (Card Detect)

    .IFDEF UCA1_TERM
TERM_IN     .equ    P2IN
TERM_SEL    .equ    P2SEL0
TERM_REN    .equ    P2REN
BUS_TERM    .equ    60h
    .ENDIF

SW1_IN      .equ    P2IN
SW1         .equ    8           ; P2.3 = S1

            MOV #-1,&PAREN      ; all inputs with pull up/down resistors
            MOV #0FFFCh,&PAOUT  ; all pins with pullup resistors else LED1/LED2

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge
; configure RTS as output high to disable RX TERM during start FORTH
            BIS.B #RTS,&P1DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge
; configure CTS as input low (true) to avoid lock when CTS is not wired
            BIC.B #CTS,&P1OUT   ; CTS input pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES

SW2_IN      .equ    P2IN
SW2         .equ    80h         ; P2.7 = S2


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage
            BIS.B #-1,&P3REN  ; all pins with pull up/down resistors
            MOV.B #-1,&P3OUT  ; all pins with pull up resistor


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

; CS code for EXP430FR2433

; to measure REFO frequency, output ACLK on P2.2:
;    BIS.B #4,&P2SEL1
;    BIS.B #4,&P2DIR
; result : REFO = 32.69kHz

    .IFDEF LF_XTAL
;           MOV     #0000h,&CSCTL3   ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4  ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
            BIS.B   #03,&P2SEL0     ; P2.0 as XOUT, P2.1 as XIN
    .ELSE
            BIS     #0010h,&CSCTL3  ; FLL select REFCLOCK
;            MOV     #0200h,&CSCTL4  ; ACLOCK select VLOCLK, MCLK & SMCLK select DCOCLKDIV (default value)
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
