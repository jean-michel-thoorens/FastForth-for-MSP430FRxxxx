
@set-syntax{C;\;}!  tell GEMA to replace default Comment separator '!' by ';'
; ========================
; MSP_EXP430FR2355.pat
; ========================
\.f=\.4th for MSP_EXP430FR2355; to change file type from generic to targeted

; ========================
; remove comments
; ========================
\\*\n=;       remove entire commented lines
\s\\*\n=\n;   remove comments at end of line

; ======================================================================
; MSP430FR2355 Config
; ======================================================================
@reset-syntax{}; enable good interpreting of next line
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}
@reset-syntax{}; enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FRxxxx.pat;}}}
@reset-syntax{}; enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR2xxx.pat;}}}
@reset-syntax{}; enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR2355.pat;}}}

; ======================================================================
; INIT MSP-EXP430FR2355 board
; ======================================================================
;
; J101 (7xjumper)
; "SBWTCK"   ---> TEST
; "SBWTDIO"  ---> RST
; "TXD"      <--- P4.3  == UCA0TXD <-- UCA0TXDBUf
; "RXD"      ---> P4.2  == UCA0RXD --> UCA0RXDBUF
; "3V3"      <--> 3V3
; "5V0"      <--> 5V0
; "GND"      <--> GND
;
;
; SW1 -- P4.1
; SW2 -- P2.3
;
; LED1 - P1.0   (red)
; LED2 - P6.6   (green)
;
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
;
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
;
;
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
;
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
;
; LFXTAL XOUT- P2.6
; LFXTAL XIN - P2.7


;
; ======================================================================
; MSP_EXP430FR2355 LAUNCHPAD    <--> OUTPUT WORLD
; ======================================================================
;
;                                 +--4k7-< DeepRST switch <-- GND
;                                 |
; P4.3  - UCA1 TXD    J101.6 -  <-+-> RX  UARTtoUSB bridge
; P4.2  - UCA1 RXD    J101.8 -  <---- TX  UARTtoUSB bridge
; P2.0  - RTS         J2.19  -  ----> CTS UARTtoUSB bridge (TERMINAL4WIRES)
; P2.1  - CTS         J4.40  -  <---- RTS UARTtoUSB bridge (TERMINAL5WIRES)
;
; P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C hardware Slave
; P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C hardware Slave
;
; P2.2  -             J2.18  -  <---- TSSOP32236 (IR RC5)
;
; P2.5  -             J2.12  -  ----> SD_CS (Card Select)
; P4.4  -             J2.13  -  <---- SD_CD (Card Detect)
; P4.5  - UCB1 CLK    J1.7   -  ----> SD_CLK
; P4.7  - UCB1 SOMI   J2.14  -  <---- SD_SDO
; P4.6  - UCB1 SIMO   J2.15  -  ----> SD_SDI
;
; P3.2  -             J4.38  -  <---> SDA I2C Soft_Master
; P3.3  -             J4.39  -  ----> SCL I2C Soft_Master

; GND   <-------+---0V0---------->  1 LCD_Vss
; VCC   <------ | --3V6-----+---->  2 LCD_Vdd
;               |           |
;             |___    470n ---
;               ^ |        ---
;              / \ BAT54    |
;              ---          |
;          100n |    2k2    |
; P1.7  >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P1.5  >------------------------>  4 LCD_RS
; P1.4  >------------------------>  5 LCD_R/W
; P1.1  >------------------------>  6 LCD_EN

; P6.0  <------------------------> 11 LCD_DB4
; P6.1  <------------------------> 12 LCD_DB5
; P6.2  <------------------------> 13 LCD_DB5
; P6.3  <------------------------> 14 LCD_DB7

; P4.1                        ---> S2 LCD contrast +
; P2.3                        ---> S1 LCD contrast -


; ----------------------------------------------------------------------
; MSP430FR2355 Peripheral File Map
; ----------------------------------------------------------------------
;SFR_SFR         .equ 0100h           ; Special function
;PMM_SFR         .equ 0120h           ; PMM
;SYS_SFR         .equ 0140h           ; SYS
;CS_SFR          .equ 0180h           ; Clock System
;FRAM_SFR        .equ 01A0h           ; FRAM control
;CRC16_SFR       .equ 01C0h
;WDT_A_SFR       .equ 01CCh           ; Watchdog
;PA_SFR          .equ 0200h           ; PORT1/2
;PB_SFR          .equ 0220h           ; PORT3/4
;PC_SFR          .equ 0240h           ; PORT5/6
;RTC_SFR         .equ 0300h
;TB0_SFR         .equ 0380h
;TB1_SFR         .equ 03C0h
;TB2_SFR         .equ 0400h
;TB3_SFR         .equ 0440h
;MPY_SFR         .equ 04C0h
;eUSCI_A0_SFR    .equ 0500h           ; eUSCI_A0
;eUSCI_B0_SFR    .equ 0540h           ; eUSCI_B0
;eUSCI_A1_SFR    .equ 0580h           ; eUSCI_A1
;eUSCI_B1_SFR    .equ 05C0h           ; eUSCI_B1
;BACK_MEM_SFR    .equ 0660h
;ICC_SFR         .equ 06C0h
;ADC10_B_SFR     .equ 0700h
;eCOMP0_SFR      .equ 08E0h
;eCOMP1_SFR      .equ 0900h
;SAC0_SFR        .equ 0C80h
;SAC1_SFR        .equ 0C90h
;SAC2_SFR        .equ 0CA0h
;SAC3_SFR        .equ 0CB0h

;P4_VEC=\$FFCE;
;P3_VEC=\$FFD0;
;P2_VEC=\$FFD2;
;P1_VEC=\$FFD4;
;SAC1SAC3_VEC=\$FFD6;
;SAC0SAC2_VEC=\$FFD8;
;ECOMPX_VEC=\$FFDA;
;ADC12_VEC=\$FFDC;
;EUSCI_B1_VEC=\$FFDE;
;EUSCI_B0_VEC=\$FFE0;
;EUSCI_A1_VEC=\$FFE2;
;EUSCI_A0_VEC=\$FFE4;
;WDT_VEC=\$FFE6;
;RTC_VEC=\$FFE8;
;TB3_X_VEC=\$FFEA;
;TB3_0_VEC=\$FFEC;
;TB2_X_VEC=\$FFEE;
;TB2_0_VEC=\$FFF0;
;TB1_X_VEC=\$FFF2;
;TB1_0_VEC=\$FFF4;
;TB0_X_VEC=\$FFF6;
;TB0_0_VEC=\$FFF8;
;U_NMI_VEC=\$FFFA;
;S_NMI_VEC=\$FFFC;
;RST_VEC=\$FFFE;

; ============================================
; FAST FORTH configuration :
; ============================================
;TERMINAL               P4.2 = RX, P4.3 = TX
BUS_TERM=\$0C
TERM_IN=\$221;          P4
TERM_REN=\$227
TERM_SEL=\$22B;         SEL0

TERM_VEC=\$FFE2;        vector for eUSCI_A1
UCSWRST=1;              eUSCI Software Reset
WAKE_UP=1;              UART RX interrupt
RX=1;                   RX flag IE|IFG
TX=2;                   Tx flag IE|IFG

RTS=1;                  P2.0
CTS=2;                  P2.1
HANDSHAKIN=\$201
HANDSHAKOUT=\$203

TERM_CTLW0=\$580;       eUSCI_A1 control word 0
TERM_CTLW1=\$582;       eUSCI_A1 control word 1
TERM_BRW=\$586;         eUSCI_A1 baud rate
TERM_MCTLW=\$588;       eUSCI_A1 modulation control
TERM_STATW=\$58A;       eUSCI_A1 status
TERM_RXBUF=\$58C;       eUSCI_A1 receive buffer
TERM_TXBUF=\$58E;       eUSCI_A1 transmit buffer
TERM_IE=\$59A;          eUSCI_A1 interrupt enable
TERM_IFG=\$59C;         eUSCI_A1 interrupt flags
TERM_IV=\$59E;          eUSCI_A1 interrupt vector word

LFXT_OUT=\$203;         P2
LFXT_DIR=\$205;         P2
LFXT_SEL=\$20D;         P2SEL1
LFXIN=\$80;             P2.7
LFXOUT=\$40;            P2.6

; FAST FORTH I/O :
LED1_OUT=\$202
LED1_DIR=\$204
LED1=1;                 P1.0 LED1 red
LED2_OUT=\$243
LED2_DIR=\$245
LED2=\$40;              P6.6 LED2 green

SW1_IN=\$221
SW1=2;                  P4.1 = S1
SW2_IN=\$201
SW2=8;                  P2.3 = S2

; ============================================
; COMMON UARTI2CS & RC5toLCD APPLICATIONs
; ============================================
;Software I2C_Master
I2CSM_IN=\$220
I2CSM_OUT=\$222
I2CSM_DIR=\$224
I2CSM_REN=\$226
I2CSM_IES=\$238
I2CSM_IFG=\$23C
SM_SDA=4;               P3.2
SM_SCL=8;               P3.3
SM_BUS=\$0C

; ============================================
; UARTI2CS APPLICATION
; ============================================
;500_ms_INT TIMER   =   TB0
TIM_CTL=\$380
TIM_CCTL2=\$386
TIM_CCR0=\$392
TIM_CCR2=\$396
T_OUT2=\$80;            P1.7 <--- TB0.2
T_OUT2_DIR=\$204;       P1DIR
T_OUT2_SEL=\$20C;       P1SEL1
INT_IN=\$40;            P1.6
INT_IN_IE=\$21A;        P1IE
INT_IN_IFG=\$21C;       P1IFG
INT_IN_VEC=\$FFD4;      P1VEC

;local variables
UARTI2CS_ADR=\{UARTI2CS\}\+10;  <-- I2C_Slave_Addr<<1
TIMER_CONF=\{UARTI2CS\}\+12;    <-- TIM_CTL configuration
COLLISION_DLY=\{UARTI2CS\}\+14; <-- 20 us resolution delay after I2C collision
DUPLEX_MODE=\{UARTI2CS\}\+15;   <-- flag = 4 --> NOECHO, <> 4 --> ECHO, -1 = I2C link lost
; ============================================
; RC5toLCD APPLICATION
; ============================================
;LCD_Vo PWM             P1
LCDVo_DIR=\$204
LCDVo_SEL=\$20C;        SEL1
LCDVo=\$80;             P1.7 as TB0.2

;LCD command bus        P1
LCD_CMD_IN=\$200
LCD_CMD_OUT=\$202
LCD_CMD_DIR=\$204
LCD_CMD_REN=\$206
LCD_RS=\$20;            P1.5
LCD_RW=\$10;            P1.4
LCD_EN=2;               P1.1
LCD_CMD=\$32;
;LCD data bus           P6
LCD_DB_IN=\$341
LCD_DB_OUT=\$343
LCD_DB_DIR=\$345
LCD_DB_REN=\$347
LCD_DB=\$0F;            P6.3210
;LCD timer              TB0
LCD_TIM_CTL=\$380
LCD_TIM_CCTLn=\$386;    TB0CCTL2
LCD_TIM_CCR0=\$392
LCD_TIM_CCRn=\$396;     TB0CCR2
LCD_TIM_EX0=\$3A0
;WATCHDOG timer         TB1
WDT_TIM_CTL=\$3C2
WDT_TIM_CCTL0=\$3C2
WDT_TIM_CCR0=\$3D2
WDT_TIM_EX0=\$3E0
WDT_TIM_0_VEC=\$FFF4;   TB1_0_VEC
;IR_RC5
RC5_=RC5_;
IR_IN=\$201;
IR_OUT=\$203;
IR_DIR=\$205;
IR_REN=\$209;
IR_IES=\$219;
IR_IE=\$21B;
IR_IFG=\$21D;
IR_VEC=\$FFD2;          P2 int
RC5=4;                  P2.2
;IR_RC5 timer
RC5_TIM_CTL=\$400;      TB2CTL
RC5_TIM_R=\$410;        TB2R
RC5_TIM_EX0=\$420;      TB2EX0
; --------------------------------------------

;Software I2C_Multi_Master
I2CSMM_IN=\$220;
I2CSMM_OUT=\$222;
I2CSMM_DIR=\$224;
I2CSMM_REN=\$226;
I2CSMM_IES=\$238;
I2CSMM_IFG=\$23C;
SMM_SDA=4;               P3.2
SMM_SCL=8;               P3.3
SMM_BUS=\$0C;

;hardware I2C_Multi_Master
I2CMM_IN=\$200;
I2CMM_OUT=\$202;
I2CMM_DIR=\$204;
I2CMM_REN=\$206;
I2CMM_SEL=\$20A;        SEL0
I2CMM_VEC=\$FFE0;       UCB0
MM_SDA=4;                P1.2
MM_SCL=8;                P1.3
MM_BUS=\$0C;

;hardware I2C_Master
I2CM_IN=\$200;
I2CM_OUT=\$202;
I2CM_DIR=\$204;
I2CM_REN=\$206;
I2CM_SEL=\$20A;         SEL0
I2CM_VEC=\$FFE0;        UCB0
M_SDA=4;                 P1.2
M_SCL=8;                 P1.3
M_BUS=\$0C;

;hardware I2C_Slave
I2CS_IN=\$200;
I2CS_OUT=\$202;
I2CS_DIR=\$204;
I2CS_REN=\$206;
I2CS_SEL=\$20A;         SEL0
I2CS_VEC=\$FFE0;        UCB0
S_SDA=4;                 P1.2
S_SCL=8;                 P1.3
S_BUS=\$0C;
I2CMM_VEC=\$FFE0;       UCB0

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

CD_SD=\$10;             P4.4 as Card Detect
SD_CDIN=\$221;

CS_SD=\$20;             P2.5 as Card Select
SD_CSOUT=\$203;
SD_CSDIR=\$205;

BUS_SD=\$7000;          pins P4.5 as UCB1CLK, P4.6 as UCB1SIMO & P4.7 as UCB1SOMI
SD_SEL=\$22B;           P4SEL0 to configure UCB1
SD_REN=\$227;           P4REN to configure pullup resistors


