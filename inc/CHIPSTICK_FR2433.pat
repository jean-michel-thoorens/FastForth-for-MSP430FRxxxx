! -*- coding: utf-8 -*-
! ChipStick_FR2433.pat
!
! Fast Forth For M. Ken Boak "ChipStick"
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

! ---------------------------------------------------
! CHIPSTICK_FR2433 <--> OUTPUT WORLD
! ---------------------------------------------------
! P3.1 -                        LED1
!
! P2.1  -             PL2.2  -  SW1
! P2.0  -             PL2.3  -  SW2 
!
!                                 +--4k7-< DeepRST <-- GND 
!                                 |
! P1.4  - UCA0 TXD    PL1.4  -  <-+-> RX  UARTtoUSB bridge
! P1.5  - UCA0 RXD    PL1.3  -  <---- TX  UARTtoUSB bridge
! P3.2  - RTS         PL1.2  -  ----> CTS UARTtoUSB bridge (if TERMINALCTSRTS option)
!       -
! P3.0  -             PL1.7  -  ----> /CS SPI_RAM
! P1.1  - UCB0 CLK    PL1.9  -  ----> CLK SPI_RAM
! P1.2  - UCB0 SIMO   PL1.10 -  ----> SI  SPI_RAM
! P1.3  - UCB0 SOMI   PL2.10 -  <---- S0  SPI_RAM
!       
!       
! P1.1  - UCB0 CLK    PL1.9  -  ----> SD_CLK
! P1.2  - UCB0 SIMO   PL1.10 -  ----> SD_SDI
! P1.3  - UCB0 SOMI   PL2.10 -  <---- SD_SDO
! P2.3  -             PL1.6  -  <---- SD_CD (Card Detect)
! P2.2  -             PL2.9  -  ----> SD_CS (Card Select)
!       
! P1.2  - UCB0 SDA    PL1.10 -  <---> SDA I2C Slave
! P1.3  - UCB0 SCL    PL2.10 -  ----> SCL I2C Slave
!       
! P2.2  -             PL2.9  -  ----> SCL I2C SoftMaster
! P2.0  -             PL2.3  -  <---> SDA I2C SoftMaster
!       
! P1.0  - UCB0 STE    PL1.8  -  <---- TSSOP32236 (IR RC5) 


! ============================================
! FORTH I/O :
! ============================================
TERM_TX=\$10!          ; P1.4 = TX also Deep_RST pin
TERM_RX=\$20!          ; P1.5 = RX
TERM_BUS=\$30!

TERM_IN=\$200!
TERM_REN=\$206!
TERM_SEL=\$20A!     SEL0
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

RTS=4!              ; P3.2
CTS=1!              ; P3.0
HANDSHAKIN=\$220!
HANDSHAKOUT=\$222!

! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$222!
LED1=\$02!          P3.1

SW1_IN=\$201!
SW1=\$02!           P2.1    

SW2_IN=\$201!
SW2=\$01!           P2.0


IR_IN=\$200!  
IR_OUT=\$202! 
IR_DIR=\$204! 
IR_REN=\$208! 
IR_IES=\$218!
IR_IE=\$21A!
IR_IFG=\$21C!
IR_VEC=\$FFDC!      P1 int
RC5_=RC5_!
RC5=\$01!           P1.0

I2CSM_IN=\$201!
I2CSM_OUT=\$203!
I2CSM_DIR=\$205!
I2CSM_REN=\$207!
SMSDA=\$01!         P2.0
SMSCL=\$04!         P2.2
SM_BUS=\$05!    

I2CSMM_IN=\$201!
I2CSMM_OUT=\$203!
I2CSMM_DIR=\$205!
I2CSMM_REN=\$207!
SMMSDA=\$01!        P2.0
SMMSCL=\$04!        P2.2
SMM_BUS=\$05!    

I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL=\$20A!    SEL0
I2CMM_VEC=\$FFE0!
MMSDA=\$04!         P1.2
MMSCL=\$08!         P1.3
MM_BUS=\$0C!

I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL=\$20A!     SEL0
I2CM_VEC=\$FFE0!
MSDA=\$04!          P1.2
MSCL=\$08!          P1.3
M_BUS=\$0C!

I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL=\$20A!     SEL0
I2CS_VEC=\$FFE0!
SSDA=\$40!          P1.2
SSCL=\$80!          P1.3
S_BUS=\$C0!


CD_SD=8!        ; P2.3 as Card Detect
SD_CDIN=\$201!

CS_SD=4!        ; P2.2 as Card Select     
SD_CSOUT=\$203!
SD_CSDIR=\$205!

BUS_SD=\$0E!    ; pins P1.1 as UCB0CLK, P1.2 as UCB0SIMO & P1.3 as UCB0SOMI
SD_SEL=\$20A!   ; PASEL0 to configure UCB0
SD_REN=\$206!   ; to configure pullup resistors

