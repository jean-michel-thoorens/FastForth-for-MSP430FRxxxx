
@set-syntax{C;\;}!  replace ! by semicolon

; MSP_EXP430FR6989.pat
;
\.f=\.4th for MSP_EXP430FR6989;      to change file type

; ========================
; remove comments
; ========================
\\*\n=
\s\\*\n=\n

; ======================================================================
; MSP430FR6989 Config
; ======================================================================

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR6989.pat;}}}

; ======================================================================
; MSP_EXP430FR6989 board
; ======================================================================

; ---------------------------------------------------
; MSP  - MSP-EXP430FR6989 LAUNCHPAD <--> OUTPUT WORLD
; ---------------------------------------------------
; P1.0 - LED1 red
; P9.7 - LED2 green
;
; P1.1 - Switch S1              <--- LCD contrast + (finger :-)
; P1.2 - Switch S2              <--- LCD contrast - (finger ;-)
;
; note : ESI1.1 = lowest left pin
; note : ESI1.2 is not connected to 3.3V
;  GND                     J6.2 <-------+---0V0---------->  1 LCD_Vss
;  VCC                     J6.1 >------ | --3V3-----+---->  2 LCD_Vdd
;                                       |           |
;                                     |___    470n ---
;                                       ^ |        ---
;                                      / \ BAT54    |
;                                      ---          |
;                                  100n |    2k2    |
; P3.6 - UCA1 CLK TB0.2 J4.37   >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P9.0/ESICH0 -         ESI1.14 <------------------------> 11 LCD_DB4 brown
; P9.1/ESICH1 -         ESI1.13 <------------------------> 12 LCD_DB5 red
; P9.2/ESICH2 -         ESI1.12 <------------------------> 13 LCD_DB5 orange
; P9.3/ESICH3 -         ESI1.11 <------------------------> 14 LCD_DB7 yellow
; P4.1                          ------------------------->  4 LCD_RS  yellow
; P4.2                          ------------------------->  5 LCD_R/W green
; P4.3                          ------------------------->  6 LCD_EN  blue
;
;                                 +--4k7-< DeepRST <-- GND
;                                 |
; P3.4 - UCA1 TXD       J101.8  <-+-> RX  UARTtoUSB bridge
; P3.5 - UCA1 RXD       J101.10 <---- TX  UARTtoUSB bridge
; P3.0 - RTS            J101.14 ----> CTS UARTtoUSB bridge (optional hardware control flow)
;  VCC -                J101.16 <---- VCC (optional supply from UARTtoUSB bridge - WARNING ; 3.3V !)
;  GND -                J101.20 <---> GND (optional supply from UARTtoUSB bridge)
;
;  VCC -                J1.1    ----> VCC SD_CardAdapter
;  GND -                J2.20   <---> GND SD_CardAdapter
; P2.2 -  UCA0 CLK      J4.35   ----> CLK SD_CardAdapter (SCK)
; P2.6 -                J4.39   ----> CS  SD_CardAdapter (Card Select)
; P2.0 -  UCA0 TXD/SIMO J1.8    ----> SDI SD_CardAdapter (MOSI)
; P2.1 -  UCA0 RXD/SOMI J2.19   <---- SDO SD_CardAdapter (MISO)
; P2.7 -                J4.40   <---- CD  SD_CardAdapter (Card Detect)
;
; P4.0 -                J1.10   <---- OUT IR_Receiver (1 TSOP32236)
;  VCC -                J1.1    ----> VCC IR_Receiver (2 TSOP32236)
;  GND -                J2.20   <---> GND IR_Receiver (3 TSOP32236)
;
; P1.3 -                J4.34   <---> SDA software I2C Master
; P1.5 -                J2.18   ----> SCL software I2C Master
;
; P1.4 -UCB0 CLK TA1.0  J1.7    <---> free
;
; P1.6 -UCB0 SDA/SIMO   J2.15   <---> SDA hardware I2C Master or Slave
; P1.7 -UCB0 SCL/SOMI   J2.14   ----> SCL hardware I2C Master or Slave
;
; P3.0 -UCB1 CLK        J4.33   ----> free (if UARTtoUSB with software control flow)
; P3.1 -UCB1 SDA/SIMO   J4.32   <---> free (if UARTtoUSB with software control flow)
; P3.2 -UCB1 SCL/SOMI   J1.5    ----> free
; P3.3 -         TA1.1  J1.5    <---> free
;
; PJ.4 - LFXI 32768Hz quartz
; PJ.5 - LFXO 32768Hz quartz
; PJ.6 - HFXI
; PJ.7 - HFXO


; FFC6-FFFF 28 vectors + reset
; 0FFC6h  -  AES
; 0FFC8h  -  RTC_C
; 0FFCAh  -  LCD_C
; 0FFCCh  -  I/O Port 4
; 0FFCEh  -  I/O Port 3
; 0FFD0h  -  TA3_x
; 0FFD2h  -  TA3_0
; 0FFD4h  -  I/O Port P2
; 0FFD6h  -  TA2_x
; 0FFD8h  -  TA2_0
; 0FFDAh  -  I/O Port P1
; 0FFDCh  -  TA1_x
; 0FFDEh  -  TA1_0
; 0FFE0h  -  DMA
; 0FFE2h  -  eUSCI_B1
; 0FFE4h  -  eUSCI_A1
; 0FFE6h  -  TA0_x
; 0FFE8h  -  TA0_0
; 0FFEAh  -  ADC12_B
; 0FFECh  -  eUSCI_B0
; 0FFEEh  -  eUSCI_A0
; 0FFF0h  -  Extended Scan IF
; 0FFF2h  -  Watchdog
; 0FFF4h  -  TB0_x
; 0FFF6h  -  TB0_0
; 0FFF8h  -  COMP_E
; 0FFFAh  -  userNMI
; 0FFFCh  -  sysNMI
; 0FFFEh  -  reset

; ----------------------------------------------------------------------
; EXP430FR6989 Peripheral File Map
; ----------------------------------------------------------------------
;SFR_SFR         .set 0100h           ; Special function
;PMM_SFR         .set 0120h           ; PMM
;FRAM_SFR        .set 0140h           ; FRAM control
;CRC16_SFR       .set 0150h
;RAMC_SFR        .set 0158h           ; RAM controller
;WDT_A_SFR       .set 015Ch           ; Watchdog
;CS_SFR          .set 0160h           ; Clock System
;SYS_SFR         .set 0180h           ; SYS
;REF_SFR         .set 01B0h           ; shared REF
;PA_SFR          .set 0200h           ; PORT1/2
;PB_SFR          .set 0220h           ; PORT3/4
;PC_SFR          .set 0240h           ; PORT5/6
;PD_SFR          .set 0260h           ; PORT7/8
;PE_SFR          .set 0280h           ; PORT9/10
;PJ_SFR          .set 0320h           ; PORTJ
;TA0_SFR         .set 0340h
;TA1_SFR         .set 0380h
;TB0_SFR         .set 03C0h
;TA2_SFR         .set 0400h
;CTIO0_SFR       .set 0430h           ; Capacitive Touch IO
;TA3_SFR         .set 0440h
;CTIO1_SFR       .set 0470h           ; Capacitive Touch IO
;RTC_C_SFR       .set 04A0h
;MPY_SFR         .set 04C0h
;DMA_CTRL_SFR    .set 0500h
;DMA_CHN0_SFR    .set 0510h
;DMA_CHN1_SFR    .set 0520h
;DMA_CHN2_SFR    .set 0530h
;MPU_SFR         .set 05A0h           ; memory protect unit
;eUSCI_A0_SFR    .set 05C0h           ; eUSCI_A0
;eUSCI_A1_SFR    .set 05E0h           ; eUSCI_A1
;eUSCI_B0_SFR    .set 0640h           ; eUSCI_B0
;eUSCI_B1_SFR    .set 0680h           ; eUSCI_B1
;ADC12_B_SFR     .set 0800h
;COMP_E_SFR      .set 08C0h
;CRC32_SFR       .set 0980h
;AES_SFR         .set 09C0h
;LCD_SFR         .set 0A00h
;ESI_SFR         .set 0D00h
;ESI_RAM         .set 0E00h          ; 128 bytes


; ============================================
; FAST FORTH configuration :
; ============================================
BUS_TERM=\$30;      \ P3.5 = RX, P3.4 = TX

TERM_IN=\$220;
TERM_REN=\$226;
TERM_SEL=\$22C;     \ SEL0

TERM_VEC=\$FFE4;    \ UCA1
UCSWRST=1;          eUSCI Software Reset
WAKE_UP=1;          \ RX int
RX=1;               RX flag IFG
TX=2;               Tx flag IFG

TERM_CTLW0=\$5E0;   \ eUSCI_A control word 0
TERM_CTLW1=\$5E2;   \ eUSCI_A control word 1
TERM_BRW=\$5E6;
TERM_BR0=\$5E6;     \ eUSCI_A baud rate 0
TERM_BR1=\$5E7;     \ eUSCI_A baud rate 1
TERM_MCTLW=\$5E8;   \ eUSCI_A modulation control
TERM_STAT=\$5EA;    \ eUSCI_A status
TERM_RXBUF=\$5EC;   \ eUSCI_A receive buffer
TERM_TXBUF=\$5EE;   \ eUSCI_A transmit buffer
TERM_ABCTL=\$5F0;   \ eUSCI_A LIN control
TERM_IRTCTL=\$5F2;  \ eUSCI_A IrDA transmit control
TERM_IRRCTL=\$5F3;  \ eUSCI_A IrDA receive control
TERM_IE=\$5FA;      \ eUSCI_A interrupt enable
TERM_IFG=\$5FC;     \ eUSCI_A interrupt flags
TERM_IV=\$5FE;      \ eUSCI_A interrupt vector word

RTS=1;              ; P3.0
CTS=2;              ; P3.1
HANDSHAKIN=\$220;
HANDSHAKOUT=\$222;

CD_SD=\$80;        ; P2.7 as Card Detect
SD_CDIN=\$201;

CS_SD=\$40;        ; P2.6 as Card Select
SD_CSOUT=\$203;
SD_CSDIR=\$205;

BUS_SD=\$07;    ; pins P2.2 as UCB0CLK, P2.0 as UCB0SIMO & P2.1 as UCB0SOMI
SD_SEL=\$20C;   ; to configure UCB0
SD_REN=\$206;   ; to configure pullup resistors

LFXT_OUT=\$322;          PJ
LFXT_DIR=\$324;          PJ
LFXT_SEL=\$32A;          PJSEL0
LFXIN=\$10;              PJ.4
LFXOUT=\$20;             PJ.5  

; FAST FORTH I/O :
LED1_OUT=\$202;
LED1_DIR=\$204;
LED1=1;         P1.0
LED2_OUT=\$282;
LED2_DIR=\$287;
LED2=\$80;      P9.7

SW1_IN=\$200;
SW1=2;          P1.1
SW2_IN=\$200;
SW2=4;          P1.2

; ============================================
; UARTI2CS APPLICATION
; ============================================
;I2C_Soft_Master
I2CSM_IN=\$200;
I2CSM_OUT=\$202;
I2CSM_DIR=\$204;
I2CSM_REN=\$206;
SM_SDA=8;               P1.3
SM_SCL=\$20;            P1.5
SM_BUS=\$28;

;500_ms_INT TIMER
TIM_CTL=\$3C0;          TB0
TIM_CCTL2=\$3C6;
TIM_CCR0=\$3D2;
TIM_CCR2=\$3D6;
T_OUT2=\$40;            P3.6 <--- TB0.2
T_OUT2_DIR=\$224;       P3DIR
T_OUT2_SEL=\$22C;       P3SEL1
INT_IN=\$80;            P3.7
INT_IN_IE=\$23A;        P3IE
INT_IN_IFG=\$23C;       P3IFG
INT_IN_VEC=\$FFCE;      P3VEC

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

; ============================================
; RC5toLCD APPLICATION
; ============================================
LCDVo_DIR=\$224;
LCDVo_SEL=\$22C;  SEL1
LCDVo=\$40;     P3.6
;LCD timer
LCD_TIM_CTL=\$3C0;      TB0CTL
LCD_TIM_CCTLn=\$3C6;    TB0CCTL2
LCD_TIM_CCR0=\$3D2;     TB0CCR0
LCD_TIM_CCRn=\$3D6;     TB0CCR2
LCD_TIM_EX0=\$3E0;      TB0EX0
;LCD command bus
LCD_CMD_IN=\$221;
LCD_CMD_OUT=\$223;
LCD_CMD_DIR=\$225;
LCD_CMD_REN=\$227;
LCD_RS=2;    P4.1
LCD_RW=4;    P4.2
LCD_EN=8;    P4.3
LCD_CMD=\$0E;
;LCD data bus
LCD_DB_IN=\$280;
LCD_DB_OUT=\$282;
LCD_DB_DIR=\$284;
LCD_DB_REN=\$286;
LCD_DB=\$0F;    P9.3-0
;WATCHDOG timer
WDT_TIM_CTL=\$340;      TA0CTL
WDT_TIM_CCTL0=\$342;    TA0CCTL0
WDT_TIM_CCR0=\$352;     TA0CCR0
WDT_TIM_EX0=\$360;      TA0EX0
WDT_TIM_0_Vec=\$FFE8;   TA0_0_Vec
;IR_RC5
IR_IN=\$221;
IR_OUT=\$223;
IR_DIR=\$225;
IR_REN=\$227;
IR_IES=\$239;
IR_IE=\$23B;
IR_IFG=\$23D;
RC5_=RC5_;
RC5=1;              P4.0
IR_Vec=\$FFCC;      P4 int
; --------------------------------------------

I2CSMM_IN=\$200;
I2CSMM_OUT=\$202;
I2CSMM_DIR=\$204;
I2CSMM_REN=\$206;
SMM_SDA=8;    P1.3
SMM_SCL=\$20;    P1.5
SMM_BUS=\$28;
RC5_TIM_CTL=\$380;      TA1CTL
RC5_TIM_R=\$390;        TA1R
RC5_TIM_EX0=\$3A0;      TA1EX0


I2CMM_IN=\$200;
I2CMM_OUT=\$202;
I2CMM_DIR=\$204;
I2CMM_REN=\$206;
I2CMM_SEL=\$20A;    SEL0
I2CMM_Vec=\$FFEC;   UCBO_Vec
MM_SDA=\$40;         P1.6
MM_SCL=\$80;         P1.7
MM_BUS=\$C0;

I2CM_IN=\$200;
I2CM_OUT=\$202;
I2CM_DIR=\$204;
I2CM_REN=\$206;
I2CM_SEL=\$20A;     SEL0
I2CM_Vec=\$FFEC;    UCBO_Vec
M_SDA=\$40;          P1.6
M_SCL=\$80;          P1.7
M_BUS=\$C0;

I2CS_IN=\$200;
I2CS_OUT=\$202;
I2CS_DIR=\$204;
I2CS_REN=\$206;
I2CS_SEL=\$20A;     SEL0
I2CS_Vec=\$FFEC;    UCBO_Vec
S_SDA=\$40;          P1.6
S_SCL=\$80;          P1.7
S_BUS=\$C0;

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
