
@set-syntax{C;\;}!  replace ! by semicolon
; virtual MSP_EXP430FR5972.pat from MSP_EXP430FR6989.pat
;
\.f=\.4th for MSP_EXP430FR5972;      to change file type
;
;========================
; remove comments
;========================
\\*\n=
\s\\*\n=\n
; ======================================================================
; MSP430FR6989 Config
; ======================================================================
@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR5972.pat;}}}
@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FRxxxx.pat;}}}
@reset-syntax{}; enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR5xxx.pat;}}}
@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}

; ======================================================================
; MSP_EXP430FR5972 board
; ======================================================================

; ---------------------------------------------------
; MSP  - MSP-EXP430FR5972 virtual LAUNCHPAD <--> OUTPUT WORLD
; ---------------------------------------------------
; P1.0 - LED1 red
; P9.7 - LED2 green
;
; P1.1 - Switch S1              <--- LCD contrast + (finger :-)
; P1.2 - Switch S2              <--- LCD contrast - (finger ;-)
;
;  GND                          <-------+---0V0---------->  1 LCD_Vss
;  VCC                          >------ | --3V3-----+---->  2 LCD_Vdd
;                                       |           |
;                                     |___    470n ---
;                                       ^ |        ---
;                                      / \ BAT54    |
;                                      ---          |
;                                  100n |    2k2    |
; P3.6 - UCA1 CLK TB0.2         >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P7.0/                         <------------------------> 11 LCD_DB4
; P7.1/                         <------------------------> 12 LCD_DB5
; P7.2/                         <------------------------> 13 LCD_DB5
; P7.3/                         <------------------------> 14 LCD_DB7
; P9.4/A12/C12                  ------------------------->  4 LCD_RS
; P9.5/A13/C13                  ------------------------->  5 LCD_R/W
; P9.6/A14/C14                  ------------------------->  6 LCD_EN
;
;                                 +--4k7-< DeepRST <-- GND
;                                 |
; P3.4 - UCA1 TXD               <-+-> RX  UARTtoUSB bridge
; P3.5 - UCA1 RXD               <---- TX  UARTtoUSB bridge
; P3.0 - RTS                    ----> CTS UARTtoUSB bridge (optional hardware control flow)
;  VCC -                        <---- VCC (optional supply from UARTtoUSB bridge - WARNING ; 3.3V ;)
;  GND -                        <---> GND (optional supply from UARTtoUSB bridge)
;
;  VCC -                        ----> VCC SD_CardAdapter
;  GND -                        <---> GND SD_CardAdapter
; P2.2 -  UCA0 CLK              ----> CLK SD_CardAdapter (SCK)
; P2.6 -                        ----> CS  SD_CardAdapter (Card Select)
; P2.0 -  UCA0 TXD/SIMO         ----> SDI SD_CardAdapter (MOSI)
; P2.1 -  UCA0 RXD/SOMI         <---- SDO SD_CardAdapter (MISO)
; P2.7 -                        <---- CD  SD_CardAdapter (Card Detect)
;
; P4.0 -                        <---- OUT IR_Receiver (1 TSOP32236)
;  VCC -                        ----> VCC IR_Receiver (2 TSOP32236)
;  GND -                        <---> GND IR_Receiver (3 TSOP32236)
;
; P1.3 -                        <---> SDA software I2C Master
; P1.5 -                        ----> SCL software I2C Master
;
; P1.4 -UCB0 CLK TA1.0          <---> free
;
; P1.6 -UCB0 SDA/SIMO           <---> SDA hardware I2C Master or Slave
; P1.7 -UCB0 SCL/SOMI           ----> SCL hardware I2C Master or Slave
;
; P3.0 -UCB1 CLK                ----> free (if UARTtoUSB with software control flow)
; P3.1 -UCB1 SDA/SIMO           <---> free
; P3.2 -UCB1 SCL/SOMI           ----> free
; P3.3 -         TA1.1          <---> free
;
; PJ.4 - LFXI 32768Hz quartz
; PJ.5 - LFXO 32768Hz quartz
; PJ.6 - HFXI
; PJ.7 - HFXO


; ============================================
; FORTH I/O :
; ============================================
BUS_TERM=\$30;      \ P3.5 = RX, P3.4 = TX

TERM_IN=\$220;
TERM_REN=\$226;
TERM_SEL=\$22C;     \ SEL0

TERM_VEC=\$FFE4;    \ UCA1
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


; ============================================
; APPLICATION I/O :
; ============================================
LED1_OUT=\$202;
LED1=1;      P1.0

LED2_OUT=\$282;
LED2=\$80;      P9.7

SW1_IN=\$200;
SW1=2;       P1.1

WIPE_IN=\$200;      ; pin as FORTH Deep_RST
IO_WIPE=2;          ; P1.1 = S1

SW2_IN=\$200;
SW2=4;       P1.2

LCDVo_DIR=\$224;
LCDVo_SEL=\$22C;  SEL1
LCDVo=\$40;     P3.6

;LCD timer
LCD_TIM_CTL=\$3C0;      TB0CTL
LCD_TIM_CCTLn=\$3C6;    TB0CCTL2
LCD_TIM_CCR0=\$3D2;     TB0CCR0
LCD_TIM_CCRn=\$3D6;     TB0CCR2
LCD_TIM_EX0=\$3E0;      TB0EX0

LCD_CMD_IN=\$221;
LCD_CMD_OUT=\$223;
LCD_CMD_DIR=\$225;
LCD_CMD_REN=\$227;
LCD_RS=2;    P4.1
LCD_RW=4;    P4.2
LCD_EN=8;    P4.3
LCD_CMD=\$0E;

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

IR_IN=\$221;
IR_OUT=\$223;
IR_DIR=\$225;
IR_REN=\$227;
IR_IES=\$239;
IR_IE=\$23B;
IR_IFG=\$23D;
RC5_=RC5_;
RC5=1;       P4.0
IR_Vec=\$FFCC;    P4 int

I2CSM_IN=\$200;
I2CSM_OUT=\$202;
I2CSM_DIR=\$204;
I2CSM_REN=\$206;
SM_SDA=8;     P1.3
SM_SCL=\$20;     P1.5
SM_BUS=\$28;

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
