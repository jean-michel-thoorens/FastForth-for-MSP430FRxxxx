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
!
!
! ======================================================================
! MSP430FR2433 Config
! ======================================================================

@define{@read{/config/gema/MSP430FR2433.pat}}
@define{@read{/config/gema/MSP430FR2x4x_FastForth.pat}}
@define{@read{/config/gema/FastForthREGtoTI.pat}}
@define{@read{/config/gema/RemoveComments.pat}}

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


LED1_OUT=\$222!
LED1=\$02!        P3.1

SW1_IN=\$201!
SW1=\$02!         P2.1    

SW2_IN=\$201!
SW2=\$01!         P2.0


IR_IN=\$200!  
IR_OUT=\$202! 
IR_DIR=\$204! 
IR_REN=\$208! 
IR_IES=\$218!
IR_IE=\$21A!
IR_IFG=\$21C!
IR_Vec=\$FFDC!    P1 int
RC5_=RC5_!
RC5=\$01!       P1.0

I2CSM_IN=\$201!
I2CSM_OUT=\$203!
I2CSM_DIR=\$205!
I2CSM_REN=\$207!
SMSDA=\$01!       P2.0
SMSCL=\$04!       P2.2
SM_BUS=\$05!    

I2CSMM_IN=\$201!
I2CSMM_OUT=\$203!
I2CSMM_DIR=\$205!
I2CSMM_REN=\$207!
SMMSDA=\$01!      P2.0
SMMSCL=\$04!      P2.2
SMM_BUS=\$05!    

I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL1=\$20C!
I2CMM_Vec=\$FFE0!
MMSDA=\$04!       P1.2
MMSCL=\$08!       P1.3
MM_BUS=\$0C!

I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL1=\$20C!
I2CM_Vec=\$FFE0!
MSDA=\$04!        P1.2
MSCL=\$08!        P1.3
M_BUS=\$0C!

I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL1=\$20C!
I2CS_Vec=\$FFE0!
SSDA=\$40!        P1.2
SSCL=\$80!        P1.3
S_BUS=\$C0!

