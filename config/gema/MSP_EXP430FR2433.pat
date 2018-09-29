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
@define{@read{@mergepath{@inpath{};RemoveComments.pat;}}}
!
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
! P1.2  - UCB0 SDA    J1.10  -  <---> SDA I2C Slave
! P1.3  - UCB0 SCL    J1.9   -  ----> SCL I2C Slave
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
TERM_SEL=\$20C!
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

RTS=1!              ; P1.0
CTS=2!              ; P1.1
HANDSHAKIN=\$200!
HANDSHAKOUT=\$202!

! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$202!
LED1=1!          P1.0

LED2_OUT=\$202!
LED2=2!          P1.1

SW1_IN=\$201!
SW1=8!           P2.3    

SW2_IN=\$201!
SW2=\$80!        P2.7


!IR_RC5
IR_IN=\$201!  
IR_OUT=\$203! 
IR_DIR=\$205! 
IR_REN=\$209! 
IR_IES=\$219!
IR_IE=\$21B!
IR_IFG=\$21D!
IR_Vec=\$FFDA!      P2 int
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
SMMSDA==4!            P3.2
SMMSCL==2!            P3.1
SMM_BUS=\$06!    

!I2C_Multi_Master
I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL1=\$20C!
I2CMM_Vec=\$FFE0!
MMSDA=\$04!         P1.2
MMSCL=\$08!         P1.3
MM_BUS=\$0C!

!I2C_Master
I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL1=\$20C!
I2CM_Vec=\$FFE0!
MSDA=\$04!          P1.2
MSCL=\$08!          P1.3
M_BUS=\$0C!

!I2C_Slave
I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL1=\$20C!
I2CS_Vec=\$FFE0!
SSDA=\$40!          P1.2
SSCL=\$80!          P1.3
S_BUS=\$C0!

SD_CD=2!        ; P2.1 as SD_CD
SD_CS=1!        ; P2.0 as SD_CS     
SD_CDIN=\$201!
SD_CSOUT=\$203!
SD_CSDIR=\$205!

SD_SEL=\$20D!   ; P2SEL0 to configure UCB0
SD_REN=\$207!   ; P2REN to configure pullup resistors
SD_BUS=\$070!   ; pins P2.4 as UCB0CLK, P2.6 as UCB0SIMO & P25 as UCB0SOMI

