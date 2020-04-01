; -*- coding: utf-8 -*-
; LP_MSP430FR2476.asm

; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; ===================================================================================

;     J101 Target    J101    eZ-FET             UARTtoUSB
;
;            DVSS 14 o--o 13 GND  
;             5V0 12 o--o 11 5V0
;            DVCC 10 o--o 9  3V3
;    P1.5 UCA0_RX  8 o--o 7  <------------ TX   UARTtoUSB
;    P1.4 UCA0_TX  6 o--o 5  <---------+-> RX   UARTtoUSB
;     SBWTDIO/RST  4 o--o 3            |         _   
;      SBWTCK/TST  2 o--o 1            +--4k7---o o-- GND
;                                             DeepRST
; SD_Card socket
;  VCC -                       ----> VCC  SD_CardAdapter
;  GND -                       <---> GND  SD_CardAdapter
; P2.4 - UCA1 CLK       J2     ----> CLK  SD_CardAdapter (SCK)  
; P2.6 - UCA1 TXD/SIMO  J1     ----> SDI  SD_CardAdapter (MOSI)
; P2.5 - UCA1 RXD/SOMI  J1     <---- SDO  SD_CardAdapter (MISO)
; P1.6 -                J4     ----> CS   SD_CardAdapter (Card Select)
; P1.7 -                J4     <---- CD   SD_CardAdapter (Card Detect)
; 
; ======================================================================
; LP_MSP430FR2476 board
; ======================================================================

; J1 - left ext.
; 3v3
; P1.6/UCA0CLK/TA1CLK/TDI/TCLK/A6     
; P2.5/UCA1RXD/UCA1SOMI/CAP1.2
; P2.6/UCA1TXD/UCA1SIMO/CAP1.3
; P2.2/SYNC/ACLK/COMP0.1
; P5.4/UCB1STE/TA3CLK/A11            
; P3.5/UCB1CLK/TB0TRG/CAP3.1
; P4.5/UCB0SOMI/UCB0SCL/TA3.2         
; P1.3/UCB0SOMI/UCB0SCL/MCLK/A3
; P1.2/UCB0SIMO/UCB0SDA/TA0.2/A2/VEREF-
;
;
; J3 - left int.
; 5V
; GND
; P1.7/UCA0STE/SMCLK/TDO/A7
; P4.3/UCB1SOMI/UCB1SCL/TB0.5/A8
; P4.4/UCB1SIMO/UCB1SDA/TB0.6/A9
; P5.3/UCB1CLK/TA3.0/A10                      
; P1.0/UCB0STE/TA0CLK/A0/VEREF+     -<J7>- LED1
; P1.1/UCB0CLK/TA0.1/COMP0.0/A1     --- TEMPERATURE SENSOR ---<J9>--- 3V3
; P5.7/TA2.1/COMP0.2 
; P3.7/TA3.2/CAP2.0
;
; J4 - right int.
; P5.2/UCA0TXD/UCA0SIMO/TB0.4                       
; P5.1/UCA0RXD/UCA0SOMI/TB0.3       -<J8>- LED2Red
; P5.0/UCA0CLK/TB0.2                -<J8>- LED2Green
; P4.7/UCA0STE/TB0.1                -<J8>- LED2Blue
; P6.0/TA2.2/COMP0.3
; P3.3/TA2.1/CAP0.1
; P6.1/TB0CLK
; P6.2/TB0.0
; P4.1/TA3.0/CAP2.2
; P3.1/UCA1STE/CAP1.0
;
; J2 - right ext.
; GND
; P4.6/UCB0SIMO/UCB0SDA/TA3.1
; P2.1/XIN
; P2.0/XOUT
; /RST/SBWTDIO
; P3.2/UCB1SIMO/UCB1SDA/CAP3.2
; P3.6/UCB1SOMI/UCB1SCL/CAP3.3
; P4.2/TA3CLK/CAP2.3
; P2.7/UCB1STE/CAP3.0
; P2.4/UCA1CLK/CAP1.1
;
; switch-keys:
; P4.0/TA3.1/CAP2.1                 - S1 
; P2.3/TA2.0/CAP0.2                 - S2 
; /RST                              - S3
;
; XTAL LF 32768 Hz
; P2.0/XOUT
; P2.1/XIN
;
;
; Clocks:
; 8 MHz DCO intern
;
;
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT1 usage
; P1.0 - green LED2

LED2_OUT    .equ    P1OUT
LED2_DIR    .equ    P1DIR
LED2        .equ    1


; PORTx default wanted state : pins as input with pullup resistor

            BIS     #-1,&PAREN      ; all pins with pull up/down resistors
            MOV     #0FFFEh,&PAOUT  ; all pins with pull up resistors  else P1.0 (LED2)

    .IFDEF UCA0_TERM
; P1.4  UCA0-TXD    --> USB2UART RXD    
; P1.5  UCA0-RXD    <-- USB2UART TXD 
TERM_IN     .equ P1IN
TERM_SEL    .equ P1SEL0
TERM_REN    .equ P1REN
TXD         .equ 10h      ; P1.4 = TX
RXD         .equ 20h      ; P1.5 = RX
BUS_TERM    .equ 30h
    .ENDIF

CD_SD       .equ 080h   ; P1.7 as Card Detect
SD_CDIN     .equ P1IN

CS_SD       .equ 040h   ; P1.6 as Card Select 
SD_CSOUT    .equ P1OUT
SD_CSDIR    .equ P1DIR

    .IFDEF UCA1_SD
BUS_SD      .equ 7000h  ; pins P2.4 as UCA1CLK, P2.6 as UCA1SIMO & P2.5 as UCA1SOMI
SD_SEL      .equ PASEL0 ; to configure UCA1
SD_REN      .equ PAREN  ; to configure pullup resistors
    .ENDIF

; P2.3/TA2.0/CAP0.2                 - S2 
SW2_IN      .equ    P2IN
SW2         .equ    8

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------
; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

            BIS     #-1,&PBREN      ; all pins 1 with pull up/down resistors
            MOV     #07FFFh,&PBOUT  ; all pins with pull up resistors else P4.7 (LED2B)

; PORT3 usage

    .IFDEF UCB1_TERM        ;
TERM_SEL    .equ    P3SEL0
TERM_REN    .equ    P3REN
TERM_OUT    .equ    P3OUT
BUS_TERM    .equ    0Ch     ; P3.2=SDA P3.3=SCL
    .ENDIF

; PORT4 usage

; S1 - P4.0
SW1_IN      .equ    P4IN
SW1         .equ    1       ; P4.0 = S1
WIPE_IN     .equ    P4IN
IO_WIPE     .equ    1       ; P4.0 = S1 = FORTH Deep_RST pin


; LED2B - J8 - P4.7

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------
; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT5 usage

; LED2R - J8 - P5.1  red LED1
; LED2G - J8 - P5.0

LED1_OUT    .equ P5OUT
LED1_DIR    .equ P5DIR
LED1        .equ 2

; PORT6 usage

HANDSHAKOUT .equ    P6OUT
HANDSHAKIN  .equ    P6IN
RTS         .equ    2           ; P6.1
CTS         .equ    4           ; P6.2

;            BIS     #00003h,&PCDIR  ; all pins 0 as input else P5.0 (LED2G) P5.1 (LED2R)
;            MOV     #0FFFCh,&PCOUT  ; all pins high  else P5.0 (LED2G) P5.1 (LED2R)
;            BIS     #0FFFCh,&PCREN  ; all pins with pull resistors else P5.0 (LED2G) P5.1 (LED2R)

            BIS     #-1,&PCREN      ; all pins with pull up/down resistors
            MOV     #0FFFCh,&PCOUT  ; all pins with pull up resistors else P5.0 (LED2G) P5.1 (LED2R)

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge 
; configure RTS as output high to disable RX TERM during start FORTH
            BIS.B #RTS,&P6DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge 
; configure CTS as input low (true) to avoid lock when CTS is not wired
            BIC.B #CTS,&P6OUT   ; CTS input pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF  FREQUENCY > 8
            MOV.B   #0A5h,&FRCTL0_H ; enable FRCTL0 access
            MOV.B   #10h,&FRCTL0    ; 1 waitstate @ 16 MHz
            MOV.B   #01h,&FRCTL0_H  ; disable FRCTL0 access
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

; CS code for MSP430FR2476

; to measure REFO frequency, output ACLK on P2.2: 
;    BIS.B #4,&P2SEL1
;    BIS.B #4,&P2DIR
; result : REFO = xx.xx kHz

    .IF FREQUENCY = 0.5

;            MOV     #058h,&CSCTL0       ; preset DCO = measured value @ 0x180 (88)
;            MOV     #0001h,&CSCTL1      ; Set 1MHZ DCORSEL,disable DCOFTRIM,Modulation
            MOV     #1ED1h,&CSCTL0      ; preset MOD=31, DCO = measured value @ 0x180 (209)
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
;            MOV     #001Dh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Dh
                                        ; fCOCLKDIV = 32768 x (29+1) = 0.983 MHz ; measured : 0.989MHz
            MOV     #001Eh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Eh
                                        ; fCOCLKDIV = 32768 x (30+1) = 1.015 MHz ; measured : 1.013MHz
;            MOV     #001Fh,&CSCTL2      ; Set FLLD=0 (DCOCLKCDIV=DCO),set FLLN=1Fh
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
                                        ; fCOCLKDIV = 32768 x (59+1) = 1.966 MHz ; measured :  MHz
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
            MOV     #1EFFh,&CSCTL0      ; preset MOD=31, DCO=255  
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
;            MOV     #0000h,&CSCTL3      ; FLL select XT1, FLLREFDIV=0 (default value)
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

