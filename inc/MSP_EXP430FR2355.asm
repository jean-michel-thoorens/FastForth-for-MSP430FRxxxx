; -*- coding: utf-8 -*-

; ======================================================================
; INIT MSP-EXP430FR2355 board
; ======================================================================

; J101 (7xjumper)
; "SBWTCK"   ---> TEST
; "SBWTDIO"  ---> RST
; "TXD"      <--- P4.3  == UCA0TXD <-- UCA0TXDBUf
; "RXD"      ---> P4.2  == UCA0RXD --> UCA0RXDBUF
; "3V3"      <--> 3V3
; "5V0"      <--> 5V0
; "GND"      <--> GND


; SW1 -- P4.1
; SW2 -- P2.3

; LED1 - P1.0   (red)
; LED2 - P6.6   (green)

; I/O pins on J1:
; J1.1  - 3V3
; J1.2  - P1.5
; J1.3  - P1.6
; J1.4  - P1.7
; J1.5  - P3.6
; J1.6  - P5.2
; J1.7  - P4.5
; J1.8  - P3.4
; J1.9  - P1.3
; J1.10 - P1.2

; I/O pins on J3:
; J3.21 - 5V0
; J3.22 - GND
; J3.23 - P1.4 A4 SEED
; J3.24 - P5.3 A11
; J3.25 - P5.1 A9
; J3.26 - P5.0 A8
; J3.27 - P5.4
; J3.28 - P1.1 A1 SEED
; J3.29 - P3.5 OA3O
; J3.30 - P3.1 OA2O


; I/O pins on J2:
; J2.11 - P3.0
; J2.12 - P2.5
; J2.13 - P4.4
; J2.14 - P4.7
; J2.15 - P4.6
; J2.16 - RST
; J2.17 - P4.0
; J2.18 - P2.2
; J2.19 - P2.0
; J2.20 - GND

; I/O pins on J4:
; J2.31 - P3.2
; J2.32 - P3.3
; J2.33 - P2.4
; J2.34 - P3.7
; J2.35 - P6.4
; J2.36 - P6.3
; J2.37 - P6.2
; J2.38 - P6.1
; J2.39 - P6.0
; J2.40 - 2.1

; LFXTAL XOUT- P2.6
; LFXTAL XIN - P2.7

; ======================================================================
; MSP-EXP430FR2355 LAUNCHPAD    <--> OUTPUT WORLD
; ======================================================================

;                                 +--4k7-< DeepRST switch <-- GND 
;                                 |
; P4.3  - UCA1 TXD    J101.6 -  <-+-> RX  UARTtoUSB bridge
; P4.2  - UCA1 RXD    J101.8 -  <---- TX  UARTtoUSB bridge
; P2.0  - RTS         J2.19  -  ----> CTS UARTtoUSB bridge (TERMINAL4WIRES)
; P2.1  - CTS         J4.40  -  <---- RTS UARTtoUSB bridge (TERMINAL5WIRES)

; P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C Master_Slave
; P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C Master_Slave
        
; P2.2  -             J2.18  -  <---- TSSOP32236 (IR RC5) 

; P2.5  -             J2.13  -  <---- SD_CD (Card Detect)
; P4.4  -             J2.12  -  ----> SD_CS (Card Select)
; P4.5  - UCB1 CLK    J1.7   -  ----> SD_CLK
; P4.6  - UCB1 SIMO   J2.15  -  ----> SD_SDI
; P4.7  - UCB1 SOMI   J2.14  -  <---- SD_SDO
        
; P6.0  -             J4.39  -  ----> SCL I2C Soft_Master
; P6.1  -             J4.38  -  <---> SDA I2C Soft_Master

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTA usage

LED1_OUT    .equ    P1OUT
LED1_DIR    .equ    P1DIR
LED1        .equ    1           ;  P1.0 LED1 red

    .IFDEF UCB0_TERM            ;
TERM_SEL    .equ    P1SEL0
TERM_REN    .equ    P1REN
TERM_OUT    .equ    P1OUT
BUS_TERM    .equ    0Ch         ; P1.2=SDA, P1.3=SCL
    .ENDIF

;               P1.0  -   LED1 red
; UART RTS      P2.0  -   J2.19     ---->   CTS UARTtoUSB bridge (TERMINAL4WIRES)
; UART CTS      P2.1  -   J4.40     <----   RTS UARTtoUSB bridge (TERMINAL5WIRES)
;               P2.3  -   SW2
;               P2.5  -   J2.10     <----   SD_CD (Card Detect)

            BIS #-1,&PAREN      ; all inputs with pull up/down resistors
            MOV #0FFFEh,&PAOUT  ; all pins with pullup resistors else LED1

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge 
; configure RTS as output high (false) to disable RX TERM during start FORTH
HANDSHAKOUT .equ    P2OUT
HANDSHAKIN  .equ    P2IN
RTS         .equ    1           ; P2.0
            BIS.B #RTS,&P2DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge 
; configure CTS as input low (true) to avoid lock when CTS is not wired
CTS         .equ    2           ; P2.1
            BIC.B #CTS,&P2OUT   ; CTS input resistor is pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES


SW2_IN      .equ P2IN
SW2         .equ 8              ; P2.3 = S2 

SD_CDIN     .equ  P2IN
CD_SD       .equ  20h           ; P2.5

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3-4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTB usage

;               P4.1    -   SW1
; UCA1 RXD      P4.2    -   J101.8  <----   TX  UARTtoUSB bridge
; UCA1 TXD      P4.3    -   J101.6  ---->   RX  UARTtoUSB bridge
;               P4.4    -   J2.9    ---->   SD_CS(Card Select)
; UCB1 CLK      P4.5    -   J1.7    ---->   SD_CLK
; UCB1 SIMO     P4.6    -   J2.15   ---->   SD_SDI
; UCB1 SOMI     P4.7    -   J2.14   <----   SD_SDO

            BIS #-1,&PBREN  ; all pins with pull resistors
            MOV #-1,&PBOUT  ; pullup resistors for all pins

SW1_IN      .equ P4IN
SW1         .equ 2      ; P4.1 = S1 

WIPE_IN     .equ P4IN
IO_WIPE     .equ 2      ; P4.1 = S1 = FORTH Deep_RST pin 

    .IFDEF UCA1_TERM
; UCA1 RXD      P4.2    -   J101.8  <----   TX  UARTtoUSB bridge
; UCA1 TXD      P4.3    -   J101.6  ---->   RX  UARTtoUSB bridge
TERM_IN     .equ P4IN
TERM_REN    .equ P4REN
TERM_SEL    .equ P4SEL0
RXD         .equ 4      ; P4.2 = RXD
TXD         .equ 8      ; P4.3 = TXD
BUS_TERM    .equ 0Ch
    .ENDIF

    .IFDEF UCB1_SD
SD_CSOUT    .equ P4OUT
SD_CSDIR    .equ P4DIR
CS_SD       .equ 10h    ; P4.4

SD_SEL      .equ PBSEL0 ; to configure UCB1
SD_REN      .equ PBREN  ; to configure pullup resistors
BUS_SD      .equ 0E000h ; pins P4.5 as UCA1CLK, P4.6 as UCA1SIMO & P4.7 as UCA1SOMI
    .ENDIF
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5-6
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT6 usage
LED2_OUT    .equ    P6OUT
LED2_DIR    .equ    P6DIR
LED2        .equ    40h         ;  P6.6 LED2 green

            BIS.B #-1,&P6REN    ; all pins with pull up/down resistors
            MOV.B #0BFh,&P6OUT  ; all pins with pull up resistors else P6.6

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF (FREQUENCY >8 ) && ( FREQUENCY <= 16)
            MOV.B   #0A5h, &FRCTL0_H     ; enable FRCTL0 access
            MOV.B   #10h, &FRCTL0         ; 1 waitstate @ 16 MHz
            MOV.B   #01h, &FRCTL0_H       ; disable FRCTL0 access
    .ELSEIF FREQUENCY > 16
            MOV.B   #0A5h, &FRCTL0_H     ; enable FRCTL0 access
            MOV.B   #20h, &FRCTL0         ; 2 waitstate @ 24 MHz
            MOV.B   #01h, &FRCTL0_H       ; disable FRCTL0 access
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET SYS config
; ----------------------------------------------------------------------

    MOV #0A500h,&SYSCFG0    ; enable write MAIN + INFO

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; CS code for MSP430FR2355

; to measure SMCLK frequency, wires SMCLK on P1.0: 
;    BIS.B #1,&P1SEL1
;    BIS.B #1,&P1DIR

; to measure REFO frequency, wires ACLK on P1.1: 
;    BIS.B #2,&P1SEL1
;    BIS.B #2,&P1DIR

; =====================================
    .IF FREQUENCY = 1
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B0h,&CSCTL1      ; Set 1MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #001Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Dh
                                        ; fCOCLKDIV = 32768 x (29+1) = 0.983 MHz ; measured : 0.989MHz
            MOV     #001Eh,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Eh
                                        ; fCOCLKDIV = 32768 x (30+1) = 1.015 MHz ; measured : 1.013MHz
;            MOV     #001Fh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Fh
                                        ; fCOCLKDIV = 32768 x (31+1) = 1.049 MHz ; measured : 1.046MHz
; =====================================
    .ELSEIF FREQUENCY = 2
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B2h,&CSCTL1      ; Set 2MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #003Bh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Bh
                                        ; fCOCLKDIV = 32768 x (59+1) = 1.966 MHz ; measured :  MHz
            MOV     #003Ch,&CSCTL2         ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Ch
                                        ; fCOCLKDIV = 32768 x (60+1) = 1.998 MHz ; measured :  MHz
;            MOV     #003Dh,&CSCTL2        ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=3Dh
                                        ; fCOCLKDIV = 32768 x (61+1) = 2.031 MHz ; measured :  MHz
; =====================================
    .ELSEIF FREQUENCY = 4
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B4h,&CSCTL1      ; Set 4MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #0078h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=78h
                                        ; fCOCLKDIV = 32768 x (120+1) = 3.965 MHz ; measured : 3.96MHz
            MOV     #0079h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=79h
                                        ; fCOCLKDIV = 32768 x (121+1) = 3.997 MHz ; measured : 3.99MHz
;            MOV     #007Ah,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=7Ah
                                        ; fCOCLKDIV = 32768 x (122+1) = 4.030 MHz ; measured : 4.020MHz
; =====================================
    .ELSEIF FREQUENCY = 8
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B6h,&CSCTL1      ; Set 8MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
            MOV     #00F3h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F3h
                                        ; fCOCLKDIV = 32768 x (243+1) = 7.995 MHz ; measured : 7.976MHz
;            MOV     #00F4h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F4h
                                        ; fCOCLKDIV = 32768 x (244+1) = 8.028 MHz ; measured : 8.009MHz
;            MOV     #00F5h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=F5h
                                        ; fCOCLKDIV = 32768 x (245+1) = 8.061 MHz ; measured : 8.042MHz
; =====================================
    .ELSEIF FREQUENCY = 12
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00B8h,&CSCTL1      ; Set 12MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
            MOV     #016Dh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E7h
                                        ; fCOCLKDIV = 32768 x 365+1) = 11.993 MHz ; measured : 11.xxxMHz
;            MOV     #016Eh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E8h
                                        ; fCOCLKDIV = 32768 x 366+1) = 12.025 MHz ; measured : 12.xxxMHz
;            MOV     #016Fh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E9h
                                        ; fCOCLKDIV = 32768 x 367+1) = 12.058 MHz ; measured : 12.xxxMHz
; =====================================
    .ELSEIF FREQUENCY = 16
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00BAh,&CSCTL1      ; Set 16MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #01E7h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E7h
                                        ; fCOCLKDIV = 32768 x 487+1) = 15.991 MHz ; measured : 15.95MHz
            MOV     #01E8h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E8h
                                        ; fCOCLKDIV = 32768 x 488+1) = 16.023 MHz ; measured : 15.99MHz
;            MOV     #01E9h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1E9h
                                        ; fCOCLKDIV = 32768 x 489+1) = 16.056 MHz ; measured : 16.02MHz
; =====================================
    .ELSEIF FREQUENCY = 20
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00BCh,&CSCTL1      ; Set 20MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #0261h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=261h
                                        ; fCOCLKDIV = 32768 x 609+1) = 19.988 MHz ; measured : 19.xxxMHz
            MOV     #0262h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=262h
                                        ; fCOCLKDIV = 32768 x 610+1) = 20.021 MHz ; measured : 20.xxxMHz
;            MOV     #0263h,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=263h
                                        ; fCOCLKDIV = 32768 x 611+1) = 20.054 MHz ; measured : 20.xxxMHz
; =====================================
    .ELSEIF FREQUENCY = 24
            MOV     #1EFFh,&CSCTL0       ; preset MOD=31, DCO=255  
            MOV     #00BEh,&CSCTL1      ; Set 24MHZ DCORSEL,enable DCOFTRIM=3h ,enable Modulation to reduce EMI
; ------------------------------------- ;  fCOCLKDIV = REFO x (FLLN+1)
;            MOV     #02DBh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=2DBh
                                        ; fCOCLKDIV = 32768 x 731+1) = 23.986 MHz ; measured : 23.xxxMHz
            MOV     #02DCh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=2DCh
                                        ; fCOCLKDIV = 32768 x 732+1) = 24.019 MHz ; measured : 23.xxxMHz
;            MOV     #02DDh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=2DDh
                                        ; fCOCLKDIV = 32768 x 733+1) = 24.051 MHz ; measured : 24.xxxMHz
; =====================================
    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,12,16,20,24 MHz"
    .ENDIF

    .IFDEF LF_XTAL
; because LOCKLPM5 is ON, XT1 is replaced by REFO automaticaly until WARM clears LOCKLPM5
;           MOV     #0000h,&CSCTL3      ; FLL select XT1, FLLREFDIV=0 (default value)
            MOV     #0000h,&CSCTL4      ; ACLOCK select XT1, MCLK & SMCLK select DCOCLKDIV
            BIS.B   #0C0h,&P2SEL1       ; P2.6 as XOUT, P2.7 as XIN
    .ELSE
            BIS     #0010h,&CSCTL3      ; FLL select REFCLOCK
;            MOV     #0100h,&CSCTL4      ; ACLOCK select REFOCLK, MCLK & SMCLK select DCOCLKDIV (default value)
    .ENDIF

            MOV     #92,X           ; 96* 3 ms = 288 ms delay, because FLL lock time = 200 ms
ClockWaitX  MOV     &FREQ_KHZ,Y     ;
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 FREQ_KHZ x 3 ==> 3ms
            SUB     #1,X            ;
            JNZ     ClockWaitX      ;
