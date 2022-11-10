
@set-syntax{C;\;}!  replace ! by semicolon

; MSP_EXP430FR2433.pat
;
\.f=\.4th for MSP_EXP430FR2433;      to change file type
;
; ========================
; remove comments
; ========================
\\*\n=
\s\\*\n=\n

; ======================================================================
; MSP430FR2433 Config
; ======================================================================

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR2433.pat;}}}

; ======================================================================
; INIT MSP-EXP430FR2433 board
; ======================================================================
;
; J101 (7xjumper)
; "SBWTCK"   ---> TEST
; "SBWTDIO"  ---> RST
; "TXD"      <--- P1.4  == UCA0TXD <-- UCA0TXDBUf
; "RXD"      ---> P1.5  == UCA0RXD --> UCA0RXDBUF
; "3V3"      <--> 3V3
; "5V0"      <--> 5V0
; "GND"      <--> GND
;
;
; SW1 -- P2.3
; SW2 -- P2.7
;
; LED1 - P1.0
; LED2 - P1.1
;
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
;
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
;
;
; ======================================================================
; MSP-EXP430FR2433 LAUNCHPAD    <--> OUTPUT WORLD
; ======================================================================
;
;                                 +--4k7-< DeepRST switch <-- GND
;                                 |
; P1.4  - UCA0 TXD    J101.6 -  <-+-> RX  UARTtoUSB bridge
; P1.5  - UCA0 RXD    J101.8 -  <---- TX  UARTtoUSB bridge
; P1.0  - RTS         J1.2   -  ----> CTS UARTtoUSB bridge (TERMINAL4WIRES)
; P1.1  - CTS         J2.19  -  <---- RTS UARTtoUSB bridge (TERMINAL5WIRES)
;
;
; P2.4  - UCA1 CLK    J1.7   -  ----> SD_CLK
; P2.6  - UCA1 SIMO   J2.15  -  ----> SD_SDI
; P2.5  - UCA1 SOMI   J2.14  -  <---- SD_SDO
; P2.1  -             J2.12  -  <---- SD_CD (Card Detect)
; P2.0  -             J2.11  -  ----> SD_CS (Card Select)
;
; P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C Slave
; P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C Slave
;
; P3.1  -             J2.13  -  ----> SCL I2C SoftMaster
; P3.2  -             J2.17  -  <---> SDA I2C SoftMaster
;
; P2.2  - ACLK        J2.18  -  <---- TSSOP32236 (IR RC5)



;P2_VEC=\$FFDA;
;P1_VEC=\$FFDC;
;ADC10_B_VEC=\$FFDE;
;EUSCI_B0_VEC=\$FFE0;
;EUSCI_A1_VEC=\$FFE2;
;EUSCI_A0_VEC=\$FFE4;
;WDT_VEC=\$FFE6;
;RTC_VEC=\$FFE8;
;TA3_X_VEC=\$FFEA;
;TA3_0_VEC=\$FFEC;
;TA2_X_VEC=\$FFEE;
;TA2_0_VEC=\$FFF0;
;TA1_X_VEC=\$FFF2;
;TA1_0_VEC=\$FFF4;
;TA0_X_VEC=\$FFF6;
;TA0_0_VEC=\$FFF8;
;U_NMI_VEC=\$FFFA;
;S_NMI_VEC=\$FFFC;
;RST_VEC=\$FFFE;

; ----------------------------------------------------------------------
; MSP430FR2433 Peripheral File Map
; ----------------------------------------------------------------------
;SFR_SFR         .equ 0100h           ; Special function
;PMM_SFR         .equ 0120h           ; PMM
;SYS_SFR         .equ 0140h           ; SYS
;CS_SFR          .equ 0180h           ; Clock System
;FRAM_SFR        .equ 01A0h           ; FRAM control
;CRC16_SFR       .equ 01C0h
;WDT_A_SFR       .equ 01CCh           ; Watchdog
;PA_SFR          .equ 0200h           ; PORT1/2
;PB_SFR          .equ 0220h           ; PORT3
;RTC_SFR         .equ 0300h
;TA0_SFR         .equ 0380h
;TA1_SFR         .equ 03C0h
;TA2_SFR         .equ 0400h
;TA3_SFR         .equ 0440h
;MPY_SFR         .equ 04C0h
;eUSCI_A0_SFR    .equ 0500h           ; eUSCI_A0
;eUSCI_A1_SFR    .equ 0520h           ; eUSCI_A1
;eUSCI_B0_SFR    .equ 0540h           ; eUSCI_B0
;BACK_MEM_SFR    .equ 0660h
;ADC10_B_SFR     .equ 0700h
; ============================================
; FAST FORTH configuration :
; ============================================
;TERMINAL
BUS_TERM=\$30;      ; P1.4 = TX, P1.5 = RX

TERM_IN=\$200;
TERM_REN=\$206;
TERM_SEL=\$20A;     \SEL0

TERM_VEC=\$FFE4;    \ UCA0
UCSWRST=1;          eUSCI Software Reset
WAKE_UP=1;          \ RX int
RX=1;               RX flag IFG
TX=2;               Tx flag IFG

TERM_CTLW0=\$500;   \ eUSCI_A control word 0
TERM_CTLW1=\$502;   \ eUSCI_A control word 1
TERM_BRW=\$506;
TERM_BR0=\$506;     \ eUSCI_A baud rate 0
TERM_BR1=\$507;     \ eUSCI_A baud rate 1
TERM_MCTLW=\$508;   \ eUSCI_A modulation control
TERM_STATW=\$50A;   \ eUSCI_A status
TERM_RXBUF=\$50C;   \ eUSCI_A receive buffer
TERM_TXBUF=\$50E;   \ eUSCI_A transmit buffer
TERM_IE=\$51A;      \ eUSCI_A interrupt enable
TERM_IFG=\$51C;     \ eUSCI_A interrupt flags
TERM_IV=\$51E;      \ eUSCI_A interrupt vector word

RTS=1;              P1.0
CTS=2;              P1.1
HANDSHAKIN=\$200;
HANDSHAKOUT=\$202;

LFXT_OUT=\$203;    P2
LFXT_DIR=\$205;    P2
LFXT_SEL=\$20B;    P2SEL0
LFXIN=\$2;         P2.1
LFXOUT=\$1;        P2.0

; FORTH I/O :
LED1_OUT=\$202;
LED1_DIR=\$204;
LED1=1;             P1.0 LED1 red
LED2_OUT=\$202;
LED2_DIR=\$204;
LED2=2;             P1.1 LED2 green

SW1_IN=\$201;
SW1=8;              P2.3 = S1
SW2_IN=\$201;
SW2=\$80;           P2.7

;IR_RC5
IR_IN=\$201;
IR_OUT=\$203;
IR_DIR=\$205;
IR_REN=\$209;
IR_IES=\$219;
IR_IE=\$21B;
IR_IFG=\$21D;
IR_VEC=\$FFDA;      P2 int
RC5_=RC5_;
RC5=4;              P2.2

; ============================================
; UARTI2CS APPLICATION
; ============================================
;I2C_Soft_Master
I2CSM_IN=\$220;
I2CSM_OUT=\$222;
I2CSM_DIR=\$224;
I2CSM_REN=\$226;
SM_SDA=4;               P3.2
SM_SCL=2;               P3.1
SM_BUS=\$06;

;500_ms_INT TIMER
TIM_CTL=\$380;          TA0
TIM_CCTL2=\$386;
TIM_CCR0=\$392;
TIM_CCR2=\$396;
T_OUT2=4;               P1.2 <--- TA0.2
T_OUT2_DIR=\$204;       P1DIR
T_OUT2_SEL=\$20C;       P1SEL1
INT_IN=8;               P1.3
INT_IN_IE=\$21A;        P1IE
INT_IN_IFG=\$21C;       P1IFG
INT_IN_VEC=\$FFDC;      P1VEC

;local variables
OLD_STOP_APP=\{UARTI2CS\};
OLD_HARD_APP=\{UARTI2CS\}\+2;
OLD_BACKGRND_APP=\{UARTI2CS\}\+4;
OLD_TERM_VEC=\{UARTI2CS\}+6;     <-- TERM_VEC
OLD_INT_IN_VEC=\{UARTI2CS\}+8;   <-- INT_IN_VEC
UARTI2CS_ADR=\{UARTI2CS\}\+10;  <-- I2C_Slave_Addr<<1
TIMER_CONF=\{UARTI2CS\}\+12;    <-- TIM_CTL configuration
COLLISION_DLY=\{UARTI2CS\}\+14; <-- 20 us resolution delay after I2C collision
DUPLEX_MODE=\{UARTI2CS\}\+15;   <-- flag = 4 --> NOECHO, <> 4 --> ECHO, -1 = I2C link lost

; --------------------------------------------

;I2C_Soft_Multi_Master
I2CSMM_IN=\$220;
I2CSMM_OUT=\$222;
I2CSMM_DIR=\$224;
I2CSMM_REN=\$226;
SMM_SDA=4;            P3.2
SMM_SCL=2;            P3.1
SMM_BUS=\$06;

;I2C_Multi_Master
I2CMM_IN=\$200;
I2CMM_OUT=\$202;
I2CMM_DIR=\$204;
I2CMM_REN=\$206;
I2CMM_SEL=\$20A;    SEL0
I2CMM_VEC=\$FFE0;   UCB0_VEC
MM_SDA=\$04;         P1.2
MM_SCL=\$08;         P1.3
MM_BUS=\$0C;

;I2C_Master
I2CM_IN=\$200;
I2CM_OUT=\$202;
I2CM_DIR=\$204;
I2CM_REN=\$206;
I2CM_SEL=\$20A;     SEL0
I2CM_VEC=\$FFE0;    UCB0_VEC
M_SDA=\$04;          P1.2
M_SCL=\$08;          P1.3
M_BUS=\$0C;

;I2C_Slave
I2CS_IN=\$200;
I2CS_OUT=\$202;
I2CS_DIR=\$204;
I2CS_REN=\$206;
I2CS_SEL=\$20A;     SEL0
I2CS_VEC=\$FFE0;    UCB0_VEC
S_SDA=\$04;          P1.2
S_SCL=\$08;          P1.3
S_BUS=\$0C;

I2CM_CTLW0=\$540;   USCI_B0 Control Word Register 0
I2CM_CTLW1=\$542;   USCI_B0 Control Word Register 1
I2CM_BRW=\$546;     USCI_B0 Baud Word Rate 0
I2CM_STATW=\$548;   USCI_B0 status word
I2CM_TBCNT=\$54A;   USCI_B0 byte counter threshold
I2CM_RXBUF=\$54C;   USCI_B0 Receive Buffer 8
I2CM_TXBUF=\$54E;   USCI_B0 Transmit Buffer 8
I2CM_I2COA0=\$554;  USCI_B0 I2C Own Address 0
I2CM_ADDRX=\$55C;   USCI_B0 Received Address Register
I2CM_I2CSA=\$560;   USCI_B0 I2C Slave Address
I2CM_IE=\$56A;      USCI_B0 Interrupt Enable
I2CM_IFG=\$56C;     USCI_B0 Interrupt Flags Register

I2CS_CTLW0=\$540;   USCI_B0 Control Word Register 0
I2CS_CTLW1=\$542;   USCI_B0 Control Word Register 1
I2CS_BRW=\$546;     USCI_B0 Baud Word Rate 0
I2CS_STATW=\$548;   USCI_B0 status word
I2CS_TBCNT=\$54A;   USCI_B0 byte counter threshold
I2CS_RXBUF=\$54C;   USCI_B0 Receive Buffer 8
I2CS_TXBUF=\$54E;   USCI_B0 Transmit Buffer 8
I2CS_I2COA0=\$554;  USCI_B0 I2C Own Address 0
I2CS_ADDRX=\$55C;   USCI_B0 Received Address Register
I2CS_I2CSA=\$560;   USCI_B0 I2C Slave Address
I2CS_IE=\$56A;      USCI_B0 Interrupt Enable
I2CS_IFG=\$56C;     USCI_B0 Interrupt Flags Register

CD_SD=2;        ; P2.1 as Card Detect
SD_CDIN=\$201;

CS_SD=1;        ; P2.0 as Card Select
SD_CSOUT=\$203;
SD_CSDIR=\$205;

BUS_SD=\$7000;  ; pins P2.4 as UCB0CLK, P2.6 as UCB0SIMO & P25 as UCB0SOMI
SD_SEL=\$20A;   ; PASEL0 to configure UCB0
SD_REN=\$206;   ; PAREN to configure pullup resistors

