
@set-syntax{C;\;}!  replace ! by semicolon

; MSP_EXP430FR5739.pat
;
\.f=\.4th for MSP_EXP430FR5739;      to change file type

; ========================
; remove comments
; ========================
\\*\n=
\s\\*\n=\n
; ======================================================================
; MSP430FR5739 Config
; ======================================================================

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR5739.pat;}}}
;
; ======================================================================
; MSP_EXP430FR5739 board
; ======================================================================

; blue LEDs (Px.y ---> resistor ---> LED ---> GND)
; PJ.0 - LED1
; PJ.1 - LED2
; PJ.2 - LED3
; PJ.3 - LED4
; P3.4 - LED5
; P3.5 - LED6
; P3.6 - LED7
; P3.7 - LED8
;
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
;
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
;
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
;
; Accelerometer:
; P2.7 - VS
; P3.0 - XOUT
; P3.1 - YOUT
; P3.2 - ZOUT
;
; LDR and NTC:
; P2.7 - VS
; P3.3 - LDR
; P1.4 - NTC
;
; RST - reset
;
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
;  VCC -                        <---- VCC (optional supply from UARTtoUSB bridge - WARNING ; 3.3V !)
;  GND -                        <---> GND (optional supply from UARTtoUSB bridge)
;
; VCC  -                 RF.2
; VSS  -                 RF.1
; P2.2 -                 RF.16  <---- CD  SD_CardAdapter (Card Detect)
; P2.3 -                 RF.10  ----> CS  SD_CardAdapter (Card Select)
; P2.4 - UCA1 CLK        RF.14  ----> CLK SD_CardAdapter (SCK)
; P2.5 - UCA1 TXD/SIMO   RF.7   ----> SDI SD_CardAdapter (MOSI)
; P2.6 - UCA1 RXD/SOMI   RF.5   <---- SDO SD_CardAdapter (MISO)
;
; P2.7 -                 RF.9   <---- OUT IR_Receiver (1 TSOP32236)
;
; P1.7 - UCB0 SCL/SOMI   SV2.1  <---> SCL I2C MASTER/SLAVE
; P1.6 - UCB0 SDA/SIMO   SV2.2  <---> SDA I2C MASTER/SLAVE

; ----------------------------------------------------------------------
; MSP430FR5739 Peripheral File Map
; ----------------------------------------------------------------------
;SFR_SFR         .equ 0100h           ; Special function
;PMM_SFR         .equ 0120h           ; PMM
;FRAM_SFR        .equ 0140h           ; FRAM control
;CRC16_SFR       .equ 0150h
;WDT_A_SFR       .equ 015Ch           ; Watchdog
;CS_SFR          .equ 0160h
;SYS_SFR         .equ 0180h           ; SYS
;REF_SFR         .equ 01B0h           ; REF
;PA_SFR          .equ 0200h           ; PORT1/2
;PB_SFR          .equ 0220h           ; PORT3/4
;PJ_SFR          .equ 0320h           ; PORTJ
;TA0_SFR         .equ 0340h
;TA1_SFR         .equ 0380h
;TB0_SFR         .equ 03C0h
;TB1_SFR         .equ 0400h
;TB2_SFR         .equ 0440h
;RTC_B_SFR       .equ 04A0h
;MPY_SFR         .equ 04C0h
;DMA_CTRL_SFR    .equ 0500h
;DMA_CHN0_SFR    .equ 0510h
;DMA_CHN1_SFR    .equ 0520h
;DMA_CHN2_SFR    .equ 0530h
;MPU_SFR         .equ 05A0h           ; memory protect unit
;eUSCI_A0_SFR    .equ 05C0h           ; eUSCI_A0
;eUSCI_A1_SFR    .equ 05E0h           ; eUSCI_A1
;eUSCI_B0_SFR    .equ 0640h           ; eUSCI_B0
;ADC10_B_SFR     .equ 0700h
;COMP_D_SFR      .equ 08C0h

; ----------------------------------------------
; Interrupt Vectors  - MSP430FR57xx
; ----------------------------------------------
; FFCE-FFFF 24 vectors + reset
; 0FFCEh  -  RTC_B
; 0FFD0h  -  I/O Port 4
; 0FFD2h  -  I/O Port 3
; 0FFD4h  -  TB2_1
; 0FFD6h  -  TB2_0
; 0FFD8h  -  I/O Port 2
; 0FFDAh  -  TB1_1
; 0FFDCh  -  TB1_0
; 0FFDEh  -  I/O Port 1
; 0FFE0h  -  TA1_1
; 0FFE2h  -  TA1_0
; 0FFE4h  -  DMA
; 0FFE6h  -  eUSCI_A1
; 0FFE8h  -  TA0_1
; 0FFEAh  -  TA0_0
; 0FFECh  -  ADC10_B
; 0FFEEh  -  eUSCI_B0
; 0FFF0h  -  eUSCI_A0
; 0FFF2h  -  Watchdog
; 0FFF4h  -  TB0_1
; 0FFF6h  -  TB0_0
; 0FFF8h  -  COMP_D
; 0FFFAh  -  userNMI
; 0FFFCh  -  sysNMI
; 0FFFEh  -  reset

; ============================================
; FAST FORTH configuration :
; ============================================
;TERMINAL
BUS_TERM=3;         \ P2.0 = TX, P2.1 = RX
TERM_IN=\$201;
TERM_REN=\$207;
TERM_SEL=\$20D;

TERM_VEC=\$FFF0;    \ UCA0
WAKE_UP=1;          \ RX int
RX=1;               RX flag IFG
TX=2;               Tx flag IFG

TERM_CTLW0=\$5C0;    \ eUSCI_A control word 0
TERM_CTLW1=\$5C2;    \ eUSCI_A control word 1
TERM_BRW=\$5C6;
TERM_BR0=\$5C6;      \ eUSCI_A baud rate 0
TERM_BR1=\$5C7;      \ eUSCI_A baud rate 1
TERM_MCTLW=\$5C8;    \ eUSCI_A modulation control
TERM_STATW=\$5CA;     \ eUSCI_A status
TERM_RXBUF=\$5CC;    \ eUSCI_A receive buffer
TERM_TXBUF=\$5CE;    \ eUSCI_A transmit buffer
TERM_ABCTL=\$5D0;    \ eUSCI_A LIN control
TERM_IRTCTL=\$5D2;   \ eUSCI_A IrDA transmit control
TERM_IRRCTL=\$5D3;   \ eUSCI_A IrDA receive control
TERM_IE=\$5DA;       \ eUSCI_A interrupt enable
TERM_IFG=\$5DC;      \ eUSCI_A interrupt flags
TERM_IV=\$5DE;       \ eUSCI_A interrupt vector word

RTS=4;
CTS=8;
HANDSHAKIN=\$201;
HANDSHAKOUT=\$203;

LFXT_OUT=\$322;          PJ
LFXT_DIR=\$324;          PJ
LFXT_SEL=\$32A;          PJSEL0
LFXIN=\$10;              PJ.4
LFXOUT=\$20;             PJ.5  

; FAST FORTH I/O :
LED1_OUT=\$322;
LED1_DIR=\$324;
LED1=\$01;              PJ.0
LED2_OUT=\$322;
LED2_DIR=\$324;
LED2=\$02;              PJ.1

SW1_IN=\$221;
SW1=\$01;               P4.0 = S1
SW2_IN=\$221;
SW2=\$02;               P4.1 = S2

; ============================================
; UARTI2CS APPLICATION
; ============================================
I2CSM_IN=\$221;
I2CSM_OUT=\$223;
I2CSM_DIR=\$225;
I2CSM_REN=\$207;
SM_SDA=1;               P4.0
SM_SCL=2;               P4.1
SM_BUS=3;

;500_ms_INT TIMER
TIM_CTL=\$340;          TA0
TIM_CCTL2=\$346;
TIM_CCR0=\$352;
TIM_CCR2=\$356;
T_OUT2=2;               P1.1 <--- TA0.2
T_OUT2_DIR=\$204;       P1DIR
T_OUT2_SEL=\$20C;       P1SEL1
INT_IN=1;               P1.0
INT_IN_IE=\$21A;        P1IE
INT_IN_IFG=\$21C;       P1IFG
INT_IN_VEC=\$FFDE;      P1VEC

;local variables
OLD_STOP_APP=\{UARTI2CS\};
OLD_HARD_APP=\{UARTI2CS\}\+\$2;
OLD_BACKGRND_APP=\{UARTI2CS\}\+\$4;
OLD_TERM_VEC=\{UARTI2CS\}+\$6;      <-- TERM_VEC
OLD_INT_IN_VEC=\{UARTI2CS\}+\$8;    <-- INT_IN_VEC
UARTI2CS_ADR=\{UARTI2CS\}\+\$0A;    <-- I2C_Slave_Addr<<1
TIMER_CONF=\{UARTI2CS\}\+\$0C;      <-- TIM_CTL configuration
COLLISION_DLY=\{UARTI2CS\}\+\$0E;   <-- 20 us resolution delay after I2C collision
DUPLEX_MODE=\{UARTI2CS\}\+\$0F;     <-- flag = 4 --> NOECHO, <> 4 --> ECHO, -1 = I2C link lost

; ============================================
; RC5toLCD APPLICATION
; ============================================
LCDVo_DIR=\$204;
LCDVo_SEL=\$20A;        SEL0
LCDVo=\$20;             P1.5
;LCD command bus
LCD_CMD_IN=\$220;
LCD_CMD_OUT=\$222;
LCD_CMD_DIR=\$224;
LCD_CMD_REN=\$226;
LCD_RS=\$10;            P3.4
LCD_RW=\$20;            P3.5
LCD_EN=\$40;            P3.6
LCD_CMD=\$70;
;LCD command bus
LCD_DB_IN=\$200;
LCD_DB_OUT=\$202;
LCD_DB_DIR=\$204;
LCD_DB_REN=\$206;
LCD_DB=\$0F;            P1.0-3
;LCD timer
LCD_TIM_CTL=\$3C0;      TB0CTL
LCD_TIM_CCTLn=\$3C6;    TB0CCTL2
LCD_TIM_CCR0=\$3D2;     TB0CCR0
LCD_TIM_CCRn=\$3D6;     TB0CCR2
LCD_TIM_EX0=\$3E0;      TB0EX0
;WATCHDOG timer
WDT_TIM_CTL=\$340;      TA0CTL
WDT_TIM_CCTL0=\$342;    TA0CCTL0
WDT_TIM_CCR0=\$352;     TA0CCR0
WDT_TIM_EX0=\$360;      TA0EX0
WDT_TIM_0_VEC=\$FFEA;     TA0_0_VEC
;IR_RC5
IR_IN=\$201;
IR_OUT=\$203;
IR_DIR=\$205;
IR_REN=\$207;
IR_IES=\$219;
IR_IE=\$21B;
IR_IFG=\$21D;
RC5_=RC5_;
RC5=\$40;               P2.6
IR_VEC=\$FFD8;          P2 int
;IR_RC5 timer
RC5_TIM_CTL=\$380;       TA1CTL
RC5_TIM_R=\$390;         TA1R
RC5_TIM_EX0=\$3A0;       TA1EX0
; --------------------------------------------

I2CSMM_IN=\$221;
I2CSMM_OUT=\$223;
I2CSMM_DIR=\$225;
I2CSMM_REN=\$227;
SMM_SDA=1;              P4.0
SMM_SCL=2;              P4.1
SMM_BUS=3;

I2CMM_IN=\$200
I2CMM_OUT=\$202
I2CMM_DIR=\$204
I2CMM_REN=\$206
I2CMM_SEL=\$20C;        SEL1
I2CMM_VEC=\$FFEE;       eUSCIB0_INT
MM_SDA=\$40;             P1.6
MM_SCL=\$80;             P1.7
MM_BUS=\$C0

I2CM_IN=\$200
I2CM_OUT=\$202
I2CM_DIR=\$204
I2CM_REN=\$206
I2CM_SEL=\$20C;         SEL1
I2CM_VEC=\$FFEE;        eUSCIB0_INT
M_SDA=\$40;              P1.6
M_SCL=\$80;              P1.7
M_BUS=\$C0

I2CS_IN=\$200
I2CS_OUT=\$202
I2CS_DIR=\$204
I2CS_REN=\$206
I2CS_SEL=\$20C;         SEL1
I2CS_VEC=\$FFEE;        eUSCIB0_INT
S_SDA=\$40;              P1.6
S_SCL=\$80;              P1.7
S_BUS=\$C0

LED1_OUT=\$322;
LED1_DIR=\$324;
LED1=1;         PJ.0 LED1 BLUE

LED2_OUT=\$322;
LED2_DIR=\$324;
LED2=2;         PJ.1 LED2 BLUE




UCSWRST=1;          eUSCI Software Reset
UCTXIE=2;           eUSCI Transmit Interrupt Enable
UCRXIE=1;           eUSCI Receive Interrupt Enable
UCTXIFG=2;          eUSCI Transmit Interrupt Flag
UCRXIFG=1;          eUSCI Receive Interrupt Flag
UCTXIE0=2;          eUSCI_B Transmit Interrupt Enable
UCRXIE0=1;          eUSCI_B Receive Interrupt Enable
UCTXIFG0=2;         eUSCI_B Transmit Interrupt Flag
UCRXIFG0=1;         eUSCI_B Receive Interrupt Flag

I2CM_CTLW0=\$640;   USCI_B0 Control Word Register 0
I2CM_CTLW1=\$642;   USCI_B0 Control Word Register 1
I2CM_BRW=\$646;     USCI_B0 Baud Word Rate 0
I2CM_STATW=\$648;   USCI_B0 status word
I2CM_TBCNT=\$64A;   USCI_B0 byte counter threshold
I2CM_RXBUF=\$64C;   USCI_B0 Receive Buffer 8
I2CM_TXBUF=\$64E;   USCI_B0 Transmit Buffer 8
I2CM_I2COA0=\$654;  USCI_B0 I2C Own Address 0
I2CM_ADDRX=\$65C;   USCI_B0 Received Address Register
I2CM_I2CSA=\$660;   USCI_B0 I2C Slave Address
I2CM_IE=\$66A;      USCI_B0 Interrupt Enable
I2CM_IFG=\$66C;     USCI_B0 Interrupt Flags Register

I2CS_CTLW0=\$640;   USCI_B0 Control Word Register 0
I2CS_CTLW1=\$642;   USCI_B0 Control Word Register 1
I2CS_BRW=\$646;     USCI_B0 Baud Word Rate 0
I2CS_STATW=\$648;   USCI_B0 status word
I2CS_TBCNT=\$64A;   USCI_B0 byte counter threshold
I2CS_RXBUF=\$64C;   USCI_B0 Receive Buffer 8
I2CS_TXBUF=\$64E;   USCI_B0 Transmit Buffer 8
I2CS_I2COA0=\$654;  USCI_B0 I2C Own Address 0
I2CS_ADDRX=\$65C;   USCI_B0 Received Address Register
I2CS_I2CSA=\$660;   USCI_B0 I2C Slave Address
I2CS_IE=\$66A;      USCI_B0 Interrupt Enable
I2CS_IFG=\$66C;     USCI_B0 Interrupt Flags Register


CD_SD=4;                P2.2 as Card Detect
SD_CDIN=\$201;

CS_SD=8;                P2.3 as Card Select
SD_CSOUT=\$203;
SD_CSDIR=\$205;

BUS_SD=\$70;            pins P2.4 as UCB0CLK, P2.5 as UCB0SIMO & P2.6 as UCB0SOMI
SD_SEL=\$20D;           to configure UCB0
SD_REN=\$207;           to configure pullup resistors


