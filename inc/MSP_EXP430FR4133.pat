
@set-syntax{C;\;}!  replace ! by semicolon

; MSP_EXP430FR4133.pat
;
\.f=\.4th for MSP_EXP430FR4133;      to change file type
; ========================
; remove comments
; ========================
\\*\n=
\s\\*\n=\n
; ======================================================================
; MSP430FR4133 Config
; ======================================================================

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR4133.pat;}}}

; ======================================================================
; MSP_EXP430FR4133 board
; ======================================================================
;
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
;
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
;
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
;
; switch-keys:
; S1 - P1.2
; S2 - P2.6
; S3 - RST
;
; LEDS:
; LED1 - P1.0/TXD
; LED2 - P4.0
;
; XTAL LF 32768 Hz
; Y4 - P4.1 XIN
; Y4 - P4.2 XOUT
;
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
;
;
;
;
;
;
; ===================================================================================
; in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
; then wire VCC and GND of bridge onto J13 connector
; ===================================================================================
;
; ---------------------------------------------------
; MSP  - MSP-EXP430FR4133 LAUNCHPAD <--> OUTPUT WORLD
; ---------------------------------------------------
;
;                                 +-4k7-< DeepRST <-- GND
;                                 |
; P1.0 - UCA0 TXD       J101.8  --+-> RX  UARTtoUSB bridge
; P1.1 - UCA0 RXD       J101.10 <---- TX  UARTtoUSB bridge
; P2.3 - RTS            J101.14 ----> CTS UARTtoUSB bridge (if TERMINALCTSRTS option)
;  VCC -                J101.16 <---- VCC (optional supply from UARTtoUSB bridge - WARNING ; 3.3V !)
;  GND -                J101.20 <---> GND (optional supply from UARTtoUSB bridge)
;
; P1.0 - STRAP JP1 MUST BE REMOVED     (LED red)
;        =========================
;
; P4.0 - LED green
;
; P1.2 - Switch SW1              <--- LCD contrast + (finger :-)
; P2.6 - Switch SW2              <--- LCD contrast - (finger ;-)
;
;
;  GND -                 J2.1   <-------+---0V0---------->  1 LCD_Vss
;  VCC -                 J1.1   >------ | --3V6-----+---->  2 LCD_Vdd
;                                       |           |
;                                      ___    470n ---
;                                       ^          ---
;                                      / \ 1n4148   |
;                                      ---          |
;                                  100n |    2k2    |
; P1.6 - TA0.2           J2.18  >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P1.3 -                 J2.13  ------------------------->  4 LCD_RS
; P1.4 -                 J2.12  ------------------------->  5 LCD_R/W
; P1.5 -                 J2.11  ------------------------->  6 LCD_EN
; P5.0 -                 J2.17  <------------------------> 11 LCD_DB4
; P5.1 -                 J1.7   <------------------------> 12 LCD_DB5
; P5.2 -                 J2.15  <------------------------> 13 LCD_DB5
; P5.3 -                 J2.14  <------------------------> 14 LCD_DB7
;
;
; P1.7 -                J2.19   <---- OUT IR_Receiver (1 TSOP32236)
;
; P4.1 - LFXIN  32768Hz quartz
; P4.2 - LFXOUT 32768Hz quartz
;
;  VCC -                J1.1    ----> VCC SD_CardAdapter
;  GND -                J2.1    <---> GND SD_CardAdapter
; P5.1 -  UCB0 CLK      J1.7    ----> CLK SD_CardAdapter (SCK)
; P8.1 -                J1.2    ----> CS  SD_CardAdapter (Card Select)
; P5.2 -  UCB0 TXD/SIMO J2.15   ----> SDI SD_CardAdapter (MOSI)
; P5.3 -  UCB0 RXD/SOMI J2.14   <---- SDO SD_CardAdapter (MISO)
; P8.0 -                J1.6    <---- CD  SD_CardAdapter (Card Detect)
;
;
;
; P8.2 - Soft I2C_Master J1.9   ----> SDA software I2C Master
; P8.3 - Soft I2C_Master J1.10  <---> SCL software I2C Master


; ----------------------------------------------------------------------
; EXP430FR4133 Peripheral File Map
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
;PD_SFR          .equ 0260h           ; PORT7/8
;CTIO0_SFR       .equ 02E0h           ; Capacitive Touch IO
;TA0_SFR         .equ 0300h
;TA1_SFR         .equ 0340h
;RTC_SFR         .equ 03C0h
;eUSCI_A0_SFR    .equ 0500h           ; eUSCI_A0
;eUSCI_B0_SFR    .equ 0540h           ; eUSCI_B0
;LCD_SFR         .equ 0600h
;BACK_MEM_SFR    .equ 0660h
;ADC10_B_SFR     .equ 0700h

;LCD_VEC=\$FFE2;
;P2_VEC=\$FFE4;
;P1_VEC=\$FFE6;
;ADC10_B_VEC=\$FFE8;
;EUSCI_B0_VEC=\$FFEA;
;EUSCI_A0_VEC=\$FFEC;
;WDT_VEC=\$FFEE;
;RTC_VEC=\$FFF0;
;TA1_X_VEC=\$FFF2;
;TA1_0_VEC=\$FFF4;
;TA0_X_VEC=\$FFF6;
;TA0_0_VEC=\$FFF8;
;U_NMI_VEC=\$FFFA;
;S_NMI_VEC=\$FFFC;
;RST_VEC=\$FFFE;

; ============================================
; FAST FORTH configuration :
; ============================================
;TERMINAL
BUS_TERM=3;         ; P1.0 = TX, P1.1 = RX
TERM_IN=\$200;
TERM_REN=\$206;
TERM_SEL=\$20A;     \ SEL0

TERM_VEC=\$FFEC;    \ UCA0
UCSWRST=1;          eUSCI Software Reset
WAKE_UP=1;          \ RX int
RX=1;               RX flag IFG
TX=2;               Tx flag IFG

TERM_CTLW0=\$500;    \ eUSCI_A control word 0
TERM_CTLW1=\$502;    \ eUSCI_A control word 1
TERM_BRW=\$506;
TERM_BR0=\$506;      \ eUSCI_A baud rate 0
TERM_BR1=\$507;      \ eUSCI_A baud rate 1
TERM_MCTLW=\$508;    \ eUSCI_A modulation control
TERM_STATW=\$50A;    \ eUSCI_A status
TERM_RXBUF=\$50C;    \ eUSCI_A receive buffer
TERM_TXBUF=\$50E;    \ eUSCI_A transmit buffer
TERM_IE=\$51A;       \ eUSCI_A interrupt enable
TERM_IFG=\$51C;      \ eUSCI_A interrupt flags
TERM_IV=\$51E;       \ eUSCI_A interrupt vector word

RTS=8;              ; P2.3
CTS=\$10;           ; P2.4
HANDSHAKIN=\$201;
HANDSHAKOUT=\$203;


LFXT_OUT=\$223;     P4
LFXT_DIR=\$225;     P4
LFXT_SEL=\$22B;     P4SEL0
LFXIN=\$2;          P4.1
LFXOUT=\$4;         P4.2

;LEDs
; ----
invert LED numbers because LED1=TXD ;
LED2_OUT=\$202;
LED2_DIR=\$204;
LED2=\$01;          P1.0 red LED
LED1_OUT=\$223;
LED1_DIR=\$225;
LED1=\$01;          P4.0 green LED, warning ; wired with UART RX ;

;switches
 ;--------
SW1_IN=\$200;
SW1=\$04;           P1.2 = S1
SW2_IN=\$201;
SW2=\$40;           P2.6 = S2

; ============================================
; UARTI2CS APPLICATION
; ============================================
I2CSM_IN=\$261;
I2CSM_OUT=\$263;
I2CSM_DIR=\$265;
I2CSM_REN=\$267;
SM_SDA=\$04;             P8.2  SDA software MASTER
SM_SCL=\$08;             P8.3  SCL software MASTER
SM_BUS=\$0C;

;500_ms_INT TIMER
TIM_CTL=\$300;          TA0
TIM_CCTL2=\$306;
TIM_CCR0=\$312;
TIM_CCR2=\$316;
T_OUT2=\$40;            P1.6 <--- TA0.2
T_OUT2_DIR=\$204;       P1DIR
T_OUT2_SEL=\$20C;       P1SEL1
INT_IN=\$80;            P1.7
INT_IN_IE=\$21A;        P1IE
INT_IN_IFG=\$21C;       P1IFG
INT_IN_VEC=\$FFE6;      P1VEC

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

; ============================================
; RC5toLCD APPLICATION
; ============================================
;LCD Vo driver
; -------------
LCDVo_DIR=\$204;        P1.6 = LCDVo
LCDVo_SEL=\$20A;        SEL0
LCDVo=\$40;
;LCD timer
LCD_TIM_CTL=\$300;      TA0CTL
LCD_TIM_CCTLn=\$306;    TA0CCTL2
LCD_TIM_CCR0=\$312;     TA0CCR0
LCD_TIM_CCRn=\$316;     TA0CCR2
LCD_TIM_EX0=\$320;      TA0EX0
;LCD command bus
 ;---------------
LCD_CMD_IN=\$200;
LCD_CMD_OUT=\$202;
LCD_CMD_DIR=\$204;
LCD_CMD_REN=\$206;
LCD_RS=\$08;            P1.3 LCD_RS
LCD_RW=\$10;            P1.4 LCD_RW
LCD_EN=\$20;            P1.5 LCD_EN
LCD_CMD=\$38;
;LCD data bus
; ------------
LCD_DB_IN=\$240;
LCD_DB_OUT=\$242;
LCD_DB_DIR=\$244;
LCD_DB_REN=\$246;
LCD_DB=\$0F;        P5.0-3 LCD_DATA_BUS
;IR_RC5 input
; ------------
IR_IN=\$200;
IR_OUT=\$202;
IR_DIR=\$204;
IR_REN=\$206;
IR_IES=\$218;
IR_IE=\$21A;
IR_IFG=\$21C;
IR_VEC=\$FFE6;          P1 int
RC5=\$80;               P1.7 IR_RC5
;IR_RC5 timer
IR_TIM_CTL=\$340;       TA1CTL
IR_TIM_CCTLn=\$346;     TA1CCTL2
IR_TIM_R=\$350;         TA1R
IR_TIM_CCR0=\$352;      TA1CCR0
IR_TIM_CCRn=\$356;      TA1CCR2
IR_TIM_EX0=\$360;       TA1EX0
; --------------------------------------------

I2CSMM_IN=\$261;
I2CSMM_OUT=\$263;
I2CSMM_DIR=\$265;
I2CSMM_REN=\$267;
SMM_SDA=\$04;            P8.2  SDA software MULTI_MASTER
SMM_SCL=\$08;            P8.3  SCL software MULTI_MASTER
SMM_BUS=\$0C;

I2CMM_IN=\$240;
I2CMM_OUT=\$242;
I2CMM_DIR=\$244;
I2CMM_REN=\$246;
I2CMM_SEL=\$24A;        SEL0
I2CMM_VEC=\$FFEA;       UCB0_VEC
MM_SDA=\$04;             P5.2  SDA hadware MULTI_MASTER
MM_SCL=\$08;             P5.3  SCL hadware MULTI_MASTER
MM_BUS=\$0C;

I2CM_IN=\$240;
I2CM_OUT=\$242;
I2CM_DIR=\$244;
I2CM_REN=\$246;
I2CM_SEL=\$24A;         SEL0
I2CM_VEC=\$FFEA;        UCB0_VEC
M_SDA=\$04;              P5.2  SDA hadware MASTER
M_SCL=\$08;              P5.3  SCL hadware MASTER
M_BUS=\$0C;

I2CS_IN=\$240;
I2CS_OUT=\$242;
I2CS_DIR=\$244;
I2CS_REN=\$246;
I2CS_SEL=\$24A;         SEL0
I2CS_VEC=\$FFEA;        UCB0_VEC
S_SDA=\$04;              P5.2  SDA hadware SLAVE
S_SCL=\$08;              P5.3  SCL hadware SLAVE
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


CD_SD=2;        ; P8.1 as Card Detect
SD_CDIN=\$261;

CS_SD=1;        ; P8.0 as Card Select
SD_CSOUT=\$263;
SD_CSDIR=\$265;

BUS_SD=\$000E;  ; pins P5.1 as UCB0CLK, P5.2 as UCB0SIMO & P5.3 as UCB0SOMI
SD_SEL=\$24A;   ; PCSEL0 to configure UCB0
SD_REN=\$246;   ; PCREN to configure pullup resistors

