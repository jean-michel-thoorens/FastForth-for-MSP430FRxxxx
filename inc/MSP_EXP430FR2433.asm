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

WIPE_IN     .equ    P2IN
IO_WIPE     .equ    8           ; P2.3 = S1 = FORTH Deep_RST pin

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

; ===================================================================
; need to adjust FLLN (and DCO) for each device of MSP430fr2xxx family ?
; (no problem with MSP430FR5xxx families without FLL).
; ===================================================================

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

            BIS.B   #03,&P2SEL0         ; P2.0 as XOUT, P2.1 as XIN

    .ELSE
            BIS     #0010h,&CSCTL3      ; FLL select REFCLOCK
            MOV     #0200h,&CSCTL4      ; ACLOCK select VLOCLK, MCLK & SMCLK select DCOCLKDIV (default value)
    .ENDIF

            BIS &SYSRSTIV,&SAVE_SYSRSTIV; store volatile SYSRSTIV preserving a pending request for DEEP_RST
;            MOV &SAVE_SYSRSTIV,TOS  ;
;            CMP #2,TOS              ; POWER ON ?
;            JZ      ClockWaitX      ; yes
;            RRUM    #1,X            ; wait only 250 ms
ClockWaitX  MOV     #5209,Y         ; wait 0.5s before starting after POR
                                    ;       ...because FLL lock time = 280 ms
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 5209x3 = 15625 cycles delay = 15.625ms @ 1MHz
            SUB     #1,X            ; x 32 @ 1 MHZ = 500ms
            JNZ     ClockWaitX      ; time to stabilize power source ( 500ms )

;WAITFLL     BIT #300h,&CSCTL7       ; wait FLL lock
;            JNZ WAITFLL
