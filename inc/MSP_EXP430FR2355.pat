! -*- coding: utf-8 -*-
! MSP_EXP430FR2355.pat
!
! Copyright (C) <2018>  <J.M. THOORENS>
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.
!
\.f=\.4th!      to change file type
!
!========================
! remove comments        
!========================
\\*\n=
\s\\*\n=\n
! ======================================================================
! MSP430FR2355 Config
! ======================================================================
@define{@read{@mergepath{@inpath{};MSP430FR2355.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}

! ======================================================================
! INIT MSP-EXP430FR2355 board
! ======================================================================
!
! J101 (7xjumper)
! "SBWTCK"   ---> TEST
! "SBWTDIO"  ---> RST
! "TXD"      <--- P4.3  == UCA0TXD <-- UCA0TXDBUf
! "RXD"      ---> P4.2  == UCA0RXD --> UCA0RXDBUF
! "3V3"      <--> 3V3
! "5V0"      <--> 5V0
! "GND"      <--> GND
!
!
! SW1 -- P4.1
! SW2 -- P2.3
!
! LED1 - P1.0   (red)
! LED2 - P6.6   (green)
!
! I/O pins on J1:
! J1.1  - 3V3
! J1.2  - P1.5
! J1.3  - P1.6
! J1.4  - P1.7
! J1.5  - P3.6
! J1.6  - P5.2
! J1.7  - P4.5
! J1.8  - P3.4
! J1.9  - P1.3
! J1.10 - P1.2
!
! I/O pins on J3:
! J3.21 - 5V0
! J3.22 - GND
! J3.23 - P1.4 A4 SEED
! J3.24 - P5.3 A11
! J3.25 - P5.1 A9
! J3.26 - P5.0 A8
! J3.27 - P5.4
! J3.28 - P1.1 A1 SEED
! J3.29 - P3.5 OA3O
! J3.30 - P3.1 OA2O
!
!
! I/O pins on J2:
! J2.11 - P3.0
! J2.12 - P2.5
! J2.13 - P4.4
! J2.14 - P4.7
! J2.15 - P4.6
! J2.16 - RST
! J2.17 - P4.0
! J2.18 - P2.2
! J2.19 - P2.0
! J2.20 - GND
!
! I/O pins on J4:
! J2.31 - P3.2
! J2.32 - P3.3
! J2.33 - P2.4
! J2.34 - P3.7
! J2.35 - P6.4
! J2.36 - P6.3
! J2.37 - P6.2
! J2.38 - P6.1
! J2.39 - P6.0
! J2.40 - 2.1
!
! LFXTAL XOUT- P2.6
! LFXTAL XIN - P2.7


!
! ======================================================================
! MSP_EXP430FR2355 LAUNCHPAD    <--> OUTPUT WORLD
! ======================================================================
!
!                                 +--4k7-< DeepRST switch <-- GND 
!                                 |
! P4.3  - UCA1 TXD    J101.6 -  <-+-> RX  UARTtoUSB bridge
! P4.2  - UCA1 RXD    J101.8 -  <---- TX  UARTtoUSB bridge
! P2.0  - RTS         J2.19  -  ----> CTS UARTtoUSB bridge (TERMINAL4WIRES)
! P2.1  - CTS         J4.40  -  <---- RTS UARTtoUSB bridge (TERMINAL5WIRES)
!
! P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C Master_Slave
! P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C Master_Slave
!       
! P2.2  -             J2.18  -  <---- TSSOP32236 (IR RC5) 
!
! P2.5  -             J2.12  -  ----> SD_CS (Card Select)
! P4.4  -             J2.13  -  <---- SD_CD (Card Detect)
! P4.5  - UCB1 CLK    J1.7   -  ----> SD_CLK
! P4.7  - UCB1 SOMI   J2.14  -  <---- SD_SDO
! P4.6  - UCB1 SIMO   J2.15  -  ----> SD_SDI
!       
! P3.2  -             J4.38  -  <---> SDA I2C Soft_Master
! P3.3  -             J4.39  -  ----> SCL I2C Soft_Master

! GND   <-------+---0V0---------->  1 LCD_Vss
! VCC   <------ | --3V6-----+---->  2 LCD_Vdd
!               |           |
!             |___    470n ---
!               ^ |        ---
!              / \ BAT54    |
!              ---          |
!          100n |    2k2    |
! P1.7  >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P1.5  >------------------------>  4 LCD_RS
! P1.4  >------------------------>  5 LCD_R/W
! P1.1  >------------------------>  6 LCD_EN

! P6.0  <------------------------> 11 LCD_DB4
! P6.1  <------------------------> 12 LCD_DB5
! P6.2  <------------------------> 13 LCD_DB5
! P6.3  <------------------------> 14 LCD_DB7        

! P4.1                        ---> S2 LCD contrast +
! P2.3                        ---> S1 LCD contrast -


! ============================================
! FORTH I/O :
! ============================================
!TERMINAL 
TERM_TX=\$8!            P4.3 = TX also Deep_RST pin
TERM_RX=\$4!            P4.2 = RX
TERM_BUS=\$0C!

TERM_IN=\$221!          P4
TERM_REN=\$227!
TERM_SEL=\$22B!     \ SEL0
TERM_Vec=\$FFE2!        UCA1

TERM_CTLW0=\$580!   \ eUSCI_A1 control word 0
TERM_CTLW1=\$582!   \ eUSCI_A1 control word 1
TERM_BRW=\$586!
TERM_BR0=\$586!     \ eUSCI_A1 baud rate 0
TERM_BR1=\$587!     \ eUSCI_A1 baud rate 1
TERM_MCTLW=\$588!   \ eUSCI_A1 modulation control
TERM_STATW=\$58A!   \ eUSCI_A1 status
TERM_RXBUF=\$58C!   \ eUSCI_A1 receive buffer
TERM_TXBUF=\$58E!   \ eUSCI_A1 transmit buffer
TERM_ABCTL=\$590!   \ eUSCI_A1 LIN control
TERM_IRTCTL=\$592!  \ eUSCI_A1 IrDA transmit control
TERM_IRRCTL=\$593!  \ eUSCI_A1 IrDA receive control
TERM_IE=\$59A!      \ eUSCI_A1 interrupt enable
TERM_IFG=\$59C!     \ eUSCI_A1 interrupt flags
TERM_IV=\$59E!      \ eUSCI_A1 interrupt vector word

RTS=1!                  P2.0
CTS=2!                  P2.1
HANDSHAKIN=\$201!
HANDSHAKOUT=\$203!

! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$202!
LED1=1!                 P1.0

LED2_OUT=\$243!
LED2=2!                 P6.6

SW1_IN=\$221!
SW1=2!                  P4.1    

SW2_IN=\$201!
SW2=8!                  P2.3


!LCD_Vo PWM
LCDVo_DIR=\$204!        P1
LCDVo_SEL=\$20C!        SEL1
LCDVo=\$80!             P1.7 as TB0.2
!LCD command bus
LCD_CMD_IN=\$200!       P1
LCD_CMD_OUT=\$202
LCD_CMD_DIR=\$204
LCD_CMD_REN=\$206
LCD_RS=\$20!            P1.5
LCD_RW=\$10!            P1.4
LCD_EN=2!               P1.1
LCD_CMD=\$32!
!LCD data bus
LCD_DB_IN=\$341!        P6
LCD_DB_OUT=\$343
LCD_DB_DIR=\$345
LCD_DB_REN=\$347
LCD_DB=\$0F!            P6.3210
!LCD timer
LCD_TIM_CTL=\$380!      TB0CTL
LCD_TIM_CCTLn=\$386!    TB0CCTL2
LCD_TIM_CCR0=\$392!     TB0CCR0
LCD_TIM_CCRn=\$396!     TB0CCR2
LCD_TIM_EX0=\$3A0!      TB0EX0


!WATCHDOG timer
WDT_TIM_CTL=\$3C2!      TB1CTL
WDT_TIM_CCTL0=\$3C2!    TB1CCTL0
WDT_TIM_CCR0=\$3D2!     TB1CCR0
WDT_TIM_EX0=\$3E0!      TB1EX0
WDT_TIM_0_Vec=\$FFF4!   TB1_0_Vec


!IR_RC5
RC5_=RC5_!
IR_IN=\$201!  
IR_OUT=\$203! 
IR_DIR=\$205! 
IR_REN=\$209! 
IR_IES=\$219!
IR_IE=\$21B!
IR_IFG=\$21D!
IR_Vec=\$FFD2!          P2 int
RC5=4!                  P2.2
!IR_RC5 timer
RC5_TIM_CTL=\$400!       TB2CTL
RC5_TIM_R=\$410!         TB2R
RC5_TIM_EX0=\$420!       TB2EX0

!Software I2C_Master
I2CSM_IN=\$220!
I2CSM_OUT=\$222!
I2CSM_DIR=\$224!
I2CSM_REN=\$226!
SMSDA=4!                P3.2
SMSCL=8!                P3.3
SM_BUS=\$03!    

!Software I2C_Multi_Master
I2CSMM_IN=\$220!
I2CSMM_OUT=\$222!
I2CSMM_DIR=\$224!
I2CSMM_REN=\$226!
SMMSDA=4!               P3.2
SMMSCL=8!               P3.3
SMM_BUS=\$0C!    

!hardware I2C_Multi_Master
I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL=\$20A!        SEL0
I2CMM_Vec=\$FFE0!       UCB0
MMSDA=4!                P1.2
MMSCL=8!                P1.3
MM_BUS=\$0C!

!hardware I2C_Master
I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL=\$20A!         SEL0
I2CM_Vec=\$FFE0!        UCB0
MSDA=4!                 P1.2
MSCL=8!                 P1.3
M_BUS=\$0C!

!hardware I2C_Slave
I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL=\$20A!         SEL0
I2CS_Vec=\$FFE0!        UCB0
SSDA=4!                 P1.2
SSCL=8!                 P1.3
S_BUS=\$0C!

UCSWRST=1!          eUSCI Software Reset
UCTXIE=2!           eUSCI Transmit Interrupt Enable
UCRXIE=1!           eUSCI Receive Interrupt Enable
UCTXIFG=2!          eUSCI Transmit Interrupt Flag
UCRXIFG=1!          eUSCI Receive Interrupt Flag
UCTXIE0=2!          eUSCI_B Transmit Interrupt Enable
UCRXIE0=1!          eUSCI_B Receive Interrupt Enable
UCTXIFG0=2!         eUSCI_B Transmit Interrupt Flag
UCRXIFG0=1!         eUSCI_B Receive Interrupt Flag

I2CM_CTLW0=\$540!   USCI_B0 Control Word Register 0
I2CM_CTLW1=\$542!   USCI_B0 Control Word Register 1
I2CM_BRW=\$546!     USCI_B0 Baud Word Rate 0
I2CM_STATW=\$548!   USCI_B0 status word 
I2CM_TBCNT=\$54A!   USCI_B0 byte counter threshold  
I2CM_RXBUF=\$54C!   USCI_B0 Receive Buffer 8
I2CM_TXBUF=\$54E!   USCI_B0 Transmit Buffer 8
I2CM_I2COA0=\$554!  USCI_B0 I2C Own Address 0
I2CM_ADDRX=\$55C!   USCI_B0 Received Address Register 
I2CM_I2CSA=\$560!   USCI_B0 I2C Slave Address
I2CM_IE=\$56A!      USCI_B0 Interrupt Enable
I2CM_IFG=\$56C!     USCI_B0 Interrupt Flags Register

I2CS_CTLW0=\$540!   USCI_B0 Control Word Register 0
I2CS_CTLW1=\$542!   USCI_B0 Control Word Register 1
I2CS_BRW=\$546!     USCI_B0 Baud Word Rate 0
I2CS_STATW=\$548!   USCI_B0 status word 
I2CS_TBCNT=\$54A!   USCI_B0 byte counter threshold  
I2CS_RXBUF=\$54C!   USCI_B0 Receive Buffer 8
I2CS_TXBUF=\$54E!   USCI_B0 Transmit Buffer 8
I2CS_I2COA0=\$554!  USCI_B0 I2C Own Address 0
I2CS_ADDRX=\$55C!   USCI_B0 Received Address Register 
I2CS_I2CSA=\$560!   USCI_B0 I2C Slave Address
I2CS_IE=\$56A!      USCI_B0 Interrupt Enable
I2CS_IFG=\$56C!     USCI_B0 Interrupt Flags Register

SD_CD=\$10!             P4.4 as SD_CD
SD_CDIN=\$221!
SD_CS=\$20!             P2.5 as SD_CS     
SD_CSOUT=\$203!
SD_CSDIR=\$205!

SD_SEL=\$22B!           P4SEL0 to configure UCB1
SD_REN=\$227!           P4REN to configure pullup resistors
SD_BUS=\$7000!          pins P4.5 as UCB1CLK, P4.6 as UCB1SIMO & P4.7 as UCB1SOMI


