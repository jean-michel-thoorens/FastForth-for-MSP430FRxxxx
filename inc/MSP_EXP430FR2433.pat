! -*- coding: utf-8 -*-
! MSP_EXP430FR2433.pat
!
!
! FastForth declarations for MSP-EXP430FR2433 launchpad
!
! Copyright (C) <2016>  <J.M. THOORENS>
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
! MSP430FR2433 Config
! ======================================================================
@define{@read{@mergepath{@inpath{};MSP430FR2433.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}

! ======================================================================
! INIT MSP-EXP430FR2433 board
! ======================================================================
!
! J101 (7xjumper)
! "SBWTCK"   ---> TEST
! "SBWTDIO"  ---> RST
! "TXD"      <--- P1.4  == UCA0TXD <-- UCA0TXDBUf
! "RXD"      ---> P1.5  == UCA0RXD --> UCA0RXDBUF
! "3V3"      <--> 3V3
! "5V0"      <--> 5V0
! "GND"      <--> GND
!
!
! SW1 -- P2.3
! SW2 -- P2.7
!
! LED1 - P1.0
! LED2 - P1.1
!
! I/O pins on J1:
! J1.1 - 3V3
! J1.2 - P1.0
! J1.3 - P1.5
! J1.4 - P1.4
! J1.5 - P1.6
! J1.6 - P1.7
! J1.7 - P2.4
! J1.8 - P2.7
! J1.9 - P1.3
! J1.10- P1.2
!
! I/O pins on J2:
! J2.11 - P2.0
! J2.12 - P2.1
! J2.13 - P3.1
! J2.14 - P2.5
! J2.15 - P2.6
! J2.16 - RST
! J2.17 - P3.2
! J2.18 - P2.2
! J2.19 - P1.1
! J2.20 - GND
!
!
! ======================================================================
! MSP-EXP430FR2433 LAUNCHPAD    <--> OUTPUT WORLD
! ======================================================================
!
!                                 +--4k7-< DeepRST switch <-- GND 
!                                 |
! P1.4  - UCA0 TXD    J101.6 -  <-+-> RX  UARTtoUSB bridge
! P1.5  - UCA0 RXD    J101.8 -  <---- TX  UARTtoUSB bridge
! P1.0  - RTS         J1.2   -  ----> CTS UARTtoUSB bridge (TERMINAL4WIRES)
! P1.1  - CTS         J2.19  -  <---- RTS UARTtoUSB bridge (TERMINAL5WIRES)
!
!
! P2.4  - UCA1 CLK    J1.7   -  ----> SD_CLK
! P2.6  - UCA1 SIMO   J2.15  -  ----> SD_SDI
! P2.5  - UCA1 SOMI   J2.14  -  <---- SD_SDO
! P2.1  -             J2.12  -  <---- SD_CD (Card Detect)
! P2.0  -             J2.11  -  ----> SD_CS (Card Select)
!       
! P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C Slave
! P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C Slave
!       
! P3.1  -             J2.13  -  ----> SCL I2C SoftMaster
! P3.2  -             J2.17  -  <---> SDA I2C SoftMaster
!       
! P2.2  - ACLK        J2.18  -  <---- TSSOP32236 (IR RC5) 



! ============================================
! FORTH I/O :
! ============================================
TERM_TX=\$10!          ; P1.4 = TX also Deep_RST pin
TERM_RX=\$20!          ; P1.5 = RX
TERM_BUS=\$30!

TERM_IN=\$200!
TERM_REN=\$206!
TERM_SEL=\$20A!     \ SEL0
TERM_IE=\$21A!
TERM_IFG=\$21C!

TERM_CTLW0=\$500!    \ eUSCI_A control word 0        
TERM_CTLW1=\$502!    \ eUSCI_A control word 1        
TERM_BRW=\$506!         
TERM_BR0=\$506!      \ eUSCI_A baud rate 0           
TERM_BR1=\$507!      \ eUSCI_A baud rate 1           
TERM_MCTLW=\$508!    \ eUSCI_A modulation control    
TERM_STATW=\$50A!     \ eUSCI_A status                
TERM_RXBUF=\$50C!    \ eUSCI_A receive buffer        
TERM_TXBUF=\$50E!    \ eUSCI_A transmit buffer       
TERM_ABCTL=\$510!    \ eUSCI_A LIN control           
TERM_IRTCTL=\$512!   \ eUSCI_A IrDA transmit control 
TERM_IRRCTL=\$513!   \ eUSCI_A IrDA receive control  
TERM_IE=\$51A!       \ eUSCI_A interrupt enable      
TERM_IFG=\$51C!      \ eUSCI_A interrupt flags       
TERM_IV=\$51E!       \ eUSCI_A interrupt vector word 

RTS=1!              P1.0
CTS=2!              P1.1
HANDSHAKIN=\$200!
HANDSHAKOUT=\$202!

! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$202!
LED1_DIR=\$204!
LED1=1!             P1.0 LED1 red

LED2_OUT=\$202!
LED2_DIR=\$204!
LED2=2!             P1.1 LED2 green

SW1_IN=\$201!
SW1=8!              P2.3 = S1    

WIPE_IN=\$201!
IO_WIPE=8!          P2.3 = S1 = FORTH Deep_RST pin    

SW2_IN=\$201!
SW2=\$80!           P2.7


!IR_RC5
IR_IN=\$201!  
IR_OUT=\$203! 
IR_DIR=\$205! 
IR_REN=\$209! 
IR_IES=\$219!
IR_IE=\$21B!
IR_IFG=\$21D!
IR_VEC=\$FFDA!      P2 int
RC5_=RC5_!
RC5=4!              P2.2

!I2C_Soft_Master
I2CSM_IN=\$220!
I2CSM_OUT=\$222!
I2CSM_DIR=\$224!
I2CSM_REN=\$226!
SMSDA=4!            P3.2
SMSCL=2!            P3.1
SM_BUS=\$06!    

!I2C_Soft_Multi_Master
I2CSMM_IN=\$220!
I2CSMM_OUT=\$222!
I2CSMM_DIR=\$224!
I2CSMM_REN=\$226!
SMMSDA=4!            P3.2
SMMSCL=2!            P3.1
SMM_BUS=\$06!    

!I2C_Multi_Master
I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL=\$20A!    SEL0   
I2CMM_VEC=\$FFE0!   UCB0_VEC
MMSDA=\$04!         P1.2
MMSCL=\$08!         P1.3
MM_BUS=\$0C!

!I2C_Master
I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL=\$20A!     SEL0
I2CM_VEC=\$FFE0!    UCB0_VEC
MSDA=\$04!          P1.2
MSCL=\$08!          P1.3
M_BUS=\$0C!

!I2C_Slave
I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL=\$20A!     SEL0
I2CS_VEC=\$FFE0!    UCB0_VEC
SSDA=\$04!          P1.2
SSCL=\$08!          P1.3
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

CD_SD=2!        ; P2.1 as Card Detect
SD_CDIN=\$201!

CS_SD=1!        ; P2.0 as Card Select    
SD_CSOUT=\$203!
SD_CSDIR=\$205!

BUS_SD=\$7000!  ; pins P2.4 as UCB0CLK, P2.6 as UCB0SIMO & P25 as UCB0SOMI
SD_SEL=\$20A!   ; PASEL0 to configure UCB0
SD_REN=\$206!   ; PAREN to configure pullup resistors

