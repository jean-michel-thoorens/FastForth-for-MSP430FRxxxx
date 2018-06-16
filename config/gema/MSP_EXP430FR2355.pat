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
!
!
! ======================================================================
! MSP430FR2355 Config
! ======================================================================

@define{@read{@mergepath{@inpath{};MSP430FR2355.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}
!@define{@read{@mergepath{@inpath{};RemoveComments.pat;}}}

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
TERM_TX=\$8!            P4.3 = TX
TERM_RX=\$4!            P4.2 = RX
TERM_TXRX=\$0C!

TERM_REN=\$227!
TERM_SEL=\$22D!
TERM_IE=\$23B!
TERM_IFG=\$23D!
TERM_Vec=\$FFE2!        UCA1
Deep_RST=\$8!           TX pin = pin for FORTH Deep_RST
Deep_RST_IN=\$220!

RTS=1!                  P2.0
CTS=2!                  P2.1
HANDSHAKIN=\$201!
HANDSHAKOUT=\$203!

SD_CD=\$10!             P4.4 as SD_CD
SD_CDIN=\$221!
SD_CS=\$20!             P2.5 as SD_CS     
SD_CSOUT=\$203!
SD_CSDIR=\$205!

SD_SEL=\$22D!           P4SEL0 to configure UCB1
SD_REN=\$227!           P4REN to configure pullup resistors
SD_BUS=\$7000!          pins P4.5 as UCB1CLK, P4.6 as UCB1SIMO & P4.7 as UCB1SOMI


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
LCD_TIM_CCTL2=\$386!     TB0CCTL2
LCD_TIM_CCR0=\$392!     TB0CCR0
LCD_TIM_CCR2=\$396!     TB0CCR2
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
I2CMM_SEL1=\$20C!
I2CMM_Vec=\$FFE0!       UCB0
MMSDA=4!                P1.2
MMSCL=8!                P1.3
MM_BUS=\$0C!

!hardware I2C_Master
I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL1=\$20C!
I2CM_Vec=\$FFE0!        UCB0
MSDA=4!                 P1.2
MSCL=8!                 P1.3
M_BUS=\$0C!

!hardware I2C_Slave
I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL1=\$20C!
I2CS_Vec=\$FFE0!        UCB0
SSDA=4!                 P1.2
SSCL=8!                 P1.3
S_BUS=\$0C!

