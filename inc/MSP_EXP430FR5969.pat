! -*- coding: utf-8 -*-
! MSP_EXP430FR5969.pat
!
\.f=\.4th for MSP_EXP430FR5969!      to change file type
!
!========================
! remove comments        
!========================
\\*\n=
\s\\*\n=\n
! ======================================================================
! MSP430FR5969 Config
! ======================================================================
@define{@read{@mergepath{@inpath{};MSP430FR5969.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}

! ======================================================================
! MSP_EXP430FR5969 board
! ======================================================================

! J3: JTAG
! --------
! P1 - TDO  - PJ.0
! P2 - V_debug
! P3 - TDI  - PJ.1
! P4 - V_ext
! P5 - TMS  - PJ.2
! P6 - NC
! P7 - TCK  - PJ.3
! P8 - TEST - TEST
! P9 - GND
! P10- CTS  - P4.0
! P11- RST  - RESET
! P12- TX0  - P2.0
! P13- RTS  - P4.1
! P14- RX0  - P2.1

! Launchpad Header Left J4
! ------------------------
! P1 - VCC
! P2 - P4.2
! P3 - P2.6 UCA1 RX/SOMI
! P4 - P2.5 UCA1 TX/SIMO
! P5 - P4.3             
! P6 - P2.4 UCA1     CLK
! P7 - P2.2 TB0.2 UCB0CLK
! P8 - P3.4
! P9 - P3.5
! P10- P3.6

! Launchpad Header Right J5
! -------------------------
! P11- P1.3
! P12- P1.4
! P13- P1.5
! P14- P1.6  UCB0 SIMO/SDA
! P15- P1.7  UCB0 SOMI/SCL
! P16- RST
! P17- NC
! P18- P3.0
! P19- P1.2
! P20- GND

!    J13    eZ-FET <=> target
! ---------------------------
! P1     P2     NC     NC
! P3 <-> P4   TEST <-> TEST
! P5 <-> P6    RST <-> RST
! P7     P8    TX0     P2.0 (no strap)
! P9    P10    RX0     P2.1 (no strap)
! P11   P12    CTS     P4.0 (no strap)
! P13   P14    RTS     P4.1 (no strap)
! P15<->P16     V+ <-> VCC 
! P17   P18     5V          (no strap)
! P19---P20    GND-----VSS

! J21 : external target
! ---------------------
! P1 - RX0  - P2.1
! P2 - VCC
! P3 - TEST - TEST
! P4 - RST  - RST
! P5 - GND
! P6 - TX0  - P2.0


! -----------------------------------------------
! MSP430FR5969        LAUNCHPAD <--> OUTPUT WORLD
! -----------------------------------------------

! J13 jumpers : device <-> eZ-FET
! -------------------------------
!  P2   P1          NC     NC  
!  P4<->P3        TEST <-> TEST
!  P6<->P5         RST <-> RST 
!  P8   P7        P2.0     TX0  (no jumper)
! P10   P9        P2.1     RX0  (no jumper)
! P12   P11       P4.0     CTS  (no jumper)
! P14   P13       P4.1     RTS  (no jumper)
! P16<->P15        VCC <-> V+  
! P18   P17         5V     5V   (no jumper)
! P20---P19        VSS-----GND  

! P4.6 - J6 - LED1 red
! P1.0 - LED2 green
!
! P4.5 - Switch S1              <--- LCD contrast + (finger :-)
! P1.1 - Switch S2              <--- LCD contrast - (finger ;-)
!                                   
!  GND -                 J1.2   <-------+---0V0---------->  1 LCD_Vss
!  VCC -                 J1.3   >------ | --3V6-----+---->  2 LCD_Vdd
!                                       |           |
!                                      ___    470n ---
!                                       ^          ---
!                                      / \ 1n4148   |
!                                      ---          |
!                                  100n |    2k2    |
! P2.2 - UCB0 CLK TB0.2  J4.7   >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P3.4 -                 J4.8   ------------------------->  4 LCD_RS
! P3.5 -                 J4.9   ------------------------->  5 LCD_R/W
! P3.6 -                 J4.10  ------------------------->  6 LCD_EN
! PJ.0 -                 J3.1   <------------------------> 11 LCD_DB4
! PJ.1 -                 J3.3   <------------------------> 12 LCD_DB5
! PJ.2 -                 J3.5   <------------------------> 13 LCD_DB6
! PJ.3 -                 J3.7   <------------------------> 14 LCD_DB7
!        
!                                 +--4k7-< DeepRST <-- GND 
!                                 |
! P2.0 - UCA0 TXD        J13.8  <-+-> RX   UARTtoUSB bridge
! P2.1 - UCA0 RXD        J13.10 <---- TX   UARTtoUSB bridge
! P4.1 - RTS             J13.14 ----> CTS  UARTtoUSB bridge (optional hardware control flow)
!  VCC -                 J13.16 <---- VCC  (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
!  GND -                 J13.20 <---> GND  (optional supply from UARTtoUSB bridge)
!        
!  VCC -                 J11.1  ----> VCC  SD_CardAdapter
!  GND -                 J12.3  <---> GND  SD_CardAdapter
! P2.4 - UCA1 CLK        J4.6   ----> CLK  SD_CardAdapter (SCK)  
! P4.3 -                 J4.5   ----> CS   SD_CardAdapter (Card Select)
! P2.5 - UCA1 TXD/SIMO   J4.4   ----> SDI  SD_CardAdapter (MOSI)
! P2.6 - UCA1 RXD/SOMI   J4.3   <---- SDO  SD_CardAdapter (MISO)
! P4.2 -                 J4.2   <---- CD   SD_CardAdapter (Card Detect)
!
! P4.0 -                 J3.10  <---- OUT  IR_Receiver (1 TSOP32236) ----┌───┐
!  VCC -                 J3.2   ----> VCC  IR_Receiver (2 TSOP32236) ----│ ○ │
!  GND -                 J3.9   <---> GND  IR_Receiver (3 TSOP32236) ----└───┘
!
! P1.2 -                 J5.19  <---> SDA  I2C SOFTWARE MASTER
! P1.3 -                 J5.11  <---> SCL  I2C SOFTWARE MASTER
! P1.4 -           TB0.1 J5.12  <---> free
! P1.5 - UCA0 CLK  TB0.2 J5.13  <---> free
! P1.7 - UCB0 SCL/SOMI   J5.14  ----> SCL  I2C MASTER/SLAVE
! P1.6 - UCB0 SDA/SIMO   J5.15  <---> SDA  I2C MASTER/SLAVE
! P3.0 -                 J5.7   <---- free
!
! PJ.4 - LFXI 32768Hz quartz  
! PJ.5 - LFXO 32768Hz quartz  
! PJ.6 - HFXI 
! PJ.7 - HFXO 
! 
! P2.3 - NC
! P2.7 - NC
! P3.1 - NC
! P3.2 - NC
! P3.3 - NC
! P3.7 - NC
! P4.4 - NC
! P4.7 - NC

! -------------+------+------+------+------++---+---+---+---+---------+
! SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current | @ 8MHz
! -------------+------+------+------+------++---+---+---+---+---------+
! LPM0 = $18   |  0   |  0   |  0   |  1   || 1 | x | x | x |  160uA  | default mode
! LPM1 = $58   |  0   |  1   |  0   |  1   || 1 | x | x | x |  115uA  |
! LPM2 = $98   |  1   |  0   |  0   |  1   || 1 | x | x | x |  0.9uA  | 32768Hz XTAL is running
! LPM3 = $D8   |  1   |  1   |  0   |  1   || 1 | x | x | x |  0.6uA  | 32768Hz XTAL is running
! LPM4 = $F8   |  1   |  1   |  1   |  1   || 1 | x | x | x |  0.5uA  |
! -------------+------+------+------+------++---+---+---+---+---------+

! ============================================
! FORTH I/O :
! ============================================
!TERMINAL 
BUS_TERM=3!         \ P2.0 = TX, P2.1 = RX

TERM_IN=\$201!
TERM_REN=\$207!
TERM_SEL=\$20D!

TERM_VEC=\$FFF0!    \ UCA0
WAKE_UP=1!          \ RX int

TERM_CTLW0=\$5C0!    \ eUSCI_A control word 0        
TERM_CTLW1=\$5C2!    \ eUSCI_A control word 1        
TERM_BRW=\$5C6!         
TERM_BR0=\$5C6!      \ eUSCI_A baud rate 0           
TERM_BR1=\$5C7!      \ eUSCI_A baud rate 1           
TERM_MCTLW=\$5C8!    \ eUSCI_A modulation control    
TERM_STAT=\$5CA!     \ eUSCI_A status                
TERM_RXBUF=\$5CC!    \ eUSCI_A receive buffer        
TERM_TXBUF=\$5CE!    \ eUSCI_A transmit buffer       
TERM_ABCTL=\$5D0!    \ eUSCI_A LIN control           
TERM_IRTCTL=\$5D2!   \ eUSCI_A IrDA transmit control 
TERM_IRRCTL=\$5D3!   \ eUSCI_A IrDA receive control  
TERM_IE=\$5DA!       \ eUSCI_A interrupt enable      
TERM_IFG=\$5DC!      \ eUSCI_A interrupt flags       
TERM_IV=\$5DE!       \ eUSCI_A interrupt vector word 

RTS=2!              ; P4.1
CTS=1!              ; P4.0
HANDSHAKIN=\$221!
HANDSHAKOUT=\$223!

CD_SD=4!            P4.2 as Card Detect
SD_CDIN=\$221!

CS_SD=8!            P4.3 as Card Select     
SD_CSOUT=\$223!
SD_CSDIR=\$225!

BUS_SD=\$70!    ; pins P2.4 as UCB0CLK, P2.5 as UCB0SIMO & P2.6 as UCB0SOMI
SD_SEL=\$20D!   ; to configure UCB0
SD_REN=\$207!   ; to configure pullup resistors


! ============================================
! APPLICATION I/O :
! ============================================
! init state : output low
LED1_OUT=\$223
LED1_DIR=\$225
LED1=\$40!          P4.6

! init state : output low
LED2_OUT=\$202
LED2_DIR=\$204
LED2=\$01!          P1.0

! init state : input with pullup resistor
SW1_IN=\$221
SW1=\$20!           P4.5 = S1 

WIPE_IN=\$221
IO_WIPE=\$20!       P4.5 = S1 = FORTH Deep_RST pin  

! init state : input with pullup resistor
SW2_IN=\$200
SW2=\$02!           P1.1 = S2

LCDVo_DIR=\$205!    P2
LCDVo_SEL=\$20B!    SEL0
LCDVo=\$04
!LCD timer
LCD_TIM_CTL=\$3C0!      TB0CTL
LCD_TIM_CCTLn=\$3C6!    TB0CCTL2
LCD_TIM_CCR0=\$3D2!     TB0CCR0
LCD_TIM_CCRn=\$3D6!     TB0CCR2
LCD_TIM_EX0=\$3E0!      TB0EX0

LCD_CMD_IN=\$220!   P3
LCD_CMD_OUT=\$222
LCD_CMD_DIR=\$224
LCD_CMD_REN=\$226
LCD_RS=\$10
LCD_RW=\$20
LCD_EN=\$40
LCD_CMD=\$70

LCD_DB_IN=\$320!    PJ
LCD_DB_OUT=\$322
LCD_DB_DIR=\$324
LCD_DB_REN=\$326
LCD_DB=\$0F


!WATCHDOG timer
WDT_TIM_CTL=\$340!      TA0CTL
WDT_TIM_CCTL0=\$342!    TA0CCTL0
WDT_TIM_CCR0=\$352!     TA0CCR0
WDT_TIM_EX0=\$360!      TA0EX0
WDT_TIM_0_VEC=\$FFEA!   TA0_0_VEC

IR_IN=\$221
IR_OUT=\$223
IR_DIR=\$225
IR_REN=\$227
IR_IES=\$239
IR_IE=\$23B
IR_IFG=\$23D
IR_VEC=\$FFD0!          P4 int
RC5=\$01!               P4.0
!IR_RC5 timer
RC5_TIM_CTL=\$380!      TA1CTL
RC5_TIM_R=\$390!        TA1R
RC5_TIM_EX0=\$3A0!      TA1EX0


I2CSM_IN=\$200
I2CSM_OUT=\$202
I2CSM_DIR=\$204
I2CSM_REN=\$206
SM_SDA=\$04!             P1.2
SM_SCL=\$08!             P1.3
SM_BUS=\$0C

I2CSMM_IN=\$200
I2CSMM_OUT=\$202
I2CSMM_DIR=\$204
I2CSMM_REN=\$206
SMM_SDA=\$04!            P1.2
SMM_SCL=\$08!            P1.3
SMM_BUS=\$0C

I2CMM_IN=\$200
I2CMM_OUT=\$202
I2CMM_DIR=\$204
I2CMM_REN=\$206
I2CMM_SEL=\$20C!        SEL1
I2CMM_VEC=\$FFEE!       eUSCIB0_INT
MM_SDA=\$40!             P1.6
MM_SCL=\$80!             P1.7
MM_BUS=\$C0

I2CM_IN=\$200
I2CM_OUT=\$202
I2CM_DIR=\$204
I2CM_REN=\$206
I2CM_SEL=\$20C!         SEL1
I2CM_VEC=\$FFEE!        eUSCIB0_INT
M_SDA=\$40!              P1.6
M_SCL=\$80!              P1.7
M_BUS=\$C0

I2CS_IN=\$200
I2CS_OUT=\$202
I2CS_DIR=\$204
I2CS_REN=\$206
I2CS_SEL=\$20C!         SEL1
I2CS_VEC=\$FFEE!        eUSCIB0_INT
S_SDA=\$40!              P1.6
S_SCL=\$80!              P1.7
S_BUS=\$C0

UCSWRST=1!          eUSCI Software Reset
UCTXIE=2!           eUSCI Transmit Interrupt Enable
UCRXIE=1!           eUSCI Receive Interrupt Enable
UCTXIFG=2!          eUSCI Transmit Interrupt Flag
UCRXIFG=1!          eUSCI Receive Interrupt Flag
UCTXIE0=2!          eUSCI_B Transmit Interrupt Enable
UCRXIE0=1!          eUSCI_B Receive Interrupt Enable
UCTXIFG0=2!         eUSCI_B Transmit Interrupt Flag
UCRXIFG0=1!         eUSCI_B Receive Interrupt Flag

I2CM_CTLW0=\$640!   USCI_B0 Control Word Register 0
I2CM_CTLW1=\$642!   USCI_B0 Control Word Register 1
I2CM_BRW=\$646!     USCI_B0 Baud Word Rate 0
I2CM_STATW=\$648!   USCI_B0 status word 
I2CM_TBCNT=\$64A!   USCI_B0 byte counter threshold  
I2CM_RXBUF=\$64C!   USCI_B0 Receive Buffer 8
I2CM_TXBUF=\$64E!   USCI_B0 Transmit Buffer 8
I2CM_I2COA0=\$654!  USCI_B0 I2C Own Address 0
I2CM_ADDRX=\$65C!   USCI_B0 Received Address Register 
I2CM_I2CSA=\$660!   USCI_B0 I2C Slave Address
I2CM_IE=\$66A!      USCI_B0 Interrupt Enable
I2CM_IFG=\$66C!     USCI_B0 Interrupt Flags Register

I2CS_CTLW0=\$640!   USCI_B0 Control Word Register 0
I2CS_CTLW1=\$642!   USCI_B0 Control Word Register 1
I2CS_BRW=\$646!     USCI_B0 Baud Word Rate 0
I2CS_STATW=\$648!   USCI_B0 status word 
I2CS_TBCNT=\$64A!   USCI_B0 byte counter threshold  
I2CS_RXBUF=\$64C!   USCI_B0 Receive Buffer 8
I2CS_TXBUF=\$64E!   USCI_B0 Transmit Buffer 8
I2CS_I2COA0=\$654!  USCI_B0 I2C Own Address 0
I2CS_ADDRX=\$65C!   USCI_B0 Received Address Register 
I2CS_I2CSA=\$660!   USCI_B0 I2C Slave Address
I2CS_IE=\$66A!      USCI_B0 Interrupt Enable
I2CS_IFG=\$66C!     USCI_B0 Interrupt Flags Register

