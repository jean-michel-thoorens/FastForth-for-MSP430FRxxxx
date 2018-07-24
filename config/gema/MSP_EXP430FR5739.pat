! -*- coding: utf-8 -*-
! MSP_EXP430FR5739.pat
!
! Fast Forth For Texas Instrument MSP_EXP430FR5739
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
! MSP430FR5739 Config
! ======================================================================

@define{@read{@mergepath{@inpath{};MSP430FR5739.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}
!@define{@read{@mergepath{@inpath{};RemoveComments.pat;}}}

! ======================================================================
! MSP_EXP430FR5739 board
! ======================================================================

! blue LEDs (Px.y ---> resistor ---> LED ---> GND)
! PJ.0 - LED1
! PJ.1 - LED2
! PJ.2 - LED3
! PJ.3 - LED4
! P3.4 - LED5
! P3.5 - LED6
! P3.6 - LED7
! P3.7 - LED8
!
! I/O pins on SV1:
! P1.0 - SV1.1
! P1.1 - SV1.2
! P1.2 - SV1.3
! P3.0 - SV1.4
! P3.1 - SV1.5
! P3.2 - SV1.6
! P3.3 - SV1.7
! P1.3 - SV1.8
! P1.4 - SV1.9
! P1.5 - SV1.10
! P4.0 - SV1.11
! GND  - SV1.12
!
! I/O pins on SV2:
! P1.7 - SV2.1
! P1.6 - SV2.2
! P3.7 - SV2.3
! P3.6 - SV2.4
! P3.5 - SV2.5
! P3.4 - SV2.6
! P2.2 - SV2.7
! P2.1 - SV2.8
! P2.6 - SV2.9
! P2.5 - SV2.10
! P2.0 - SV2.11
! VCC  - SV2.12
!
! I/O pins on RF:
! GND  - RF.1
! VCC  - RF.2
! P2.0 - RF.3
! P1.0 - RF.4
! P2.6 - RF.5
! P1.1 - RF.6
! P2.5 - RF.7
! P1.2 - RF.8
! P2.7 - RF.9
! P2.3 - RF.10
! P4.0 - RF.11
! GND  - RF.12
! P4.1 - RF.13
! P2.4 - RF.14
! P1.7 - RF.15
! P2.2 - RF.16
! P1.3 - RF.17
! P1.6 - RF.18
!
! Accelerometer:
! P2.7 - VS
! P3.0 - XOUT
! P3.1 - YOUT
! P3.2 - ZOUT
!
! LDR and NTC:
! P2.7 - VS
! P3.3 - LDR
! P1.4 - NTC
!
! RST - reset
!
! ======================================================================
! MSP-EXP430FR5739 LAUNCHPAD    <--> OUTPUT WORLD
! ======================================================================
!
! P4.0 - Switch S1              <--- LCD contrast + (finger :-)
! P4.1 - Switch S2              <--- LCD contrast - (finger :-)
!                                   
!  GND                          <-------+---0V0---------->  1 LCD_Vss
!  VCC                          >------ | --3V6-----+---->  2 LCD_Vdd
!                                       |           |
!                                     |___    470n ---
!                                       ^ |        ---
!                                      / \ BAT54    |
!                                      ---          |
!                                  100n |    2k2    |
! P1.5 - UCB0 CLK  TB0.2 SV1.10 >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P3.4 -                 SV2.6  ------------------------->  4 LCD_RS
! P3.5 -                 SV2.5  ------------------------->  5 LCD_R/W
! P3.6 -                 SV2.4  ------------------------->  6 LCD_EN
! P1.0 -                 SV1.1  <------------------------> 11 LCD_DB4
! P1.1 -                 SV1.2  <------------------------> 12 LCD_DB5
! P1.2 -                 SV1.3  <------------------------> 13 LCD_DB5
! P1.3 -                 SV1.8  <------------------------> 14 LCD_DB7
!
! PJ.4 - LFXI 32768Hz quartz  
! PJ.5 - LFXO 32768Hz quartz  
! PJ.6 - HFXI 
! PJ.7 - HFXO 
!                                 +--4k7-< DeepRST <-- GND 
!                                 |
! P2.0 -  UCA0 TXD       SV2.11 --+-> RX  UARTtoUSB bridge
! P2.1 -  UCA0 RXD       SV2.8  <---- TX  UARTtoUSB bridge
!  VCC -                        <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
!  GND -                        <---> GND (optional supply from UARTtoUSB bridge)
!        
! VCC  -                 RF.2 
! VSS  -                 RF.1 
! P2.2 -                 RF.16  <---- CD  SD_CardAdapter (Card Detect)
! P2.3 -                 RF.10  ----> CS  SD_CardAdapter (Card Select)
! P2.4 - UCA1 CLK        RF.14  ----> CLK SD_CardAdapter (SCK)  
! P2.5 - UCA1 TXD/SIMO   RF.7   ----> SDI SD_CardAdapter (MOSI)
! P2.6 - UCA1 RXD/SOMI   RF.5   <---- SDO SD_CardAdapter (MISO)
!
! P2.7 -                 RF.9   <---- OUT IR_Receiver (1 TSOP32236)
!
! P1.7 - UCB0 SCL/SOMI   SV2.1  <---> SCL I2C MASTER/SLAVE
! P1.6 - UCB0 SDA/SIMO   SV2.2  <---> SDA I2C MASTER/SLAVE

! ============================================
! FORTH I/O :
! ============================================
TERM_TX=1!              P2.0 = TX also Deep_RST pin
TERM_RX=2!              P2.1 = RX
TERM_BUS=3!

TERM_IN=\$201!
TERM_REN=\$207!
TERM_SEL=\$20D!
TERM_IE=\$21B!
TERM_IFG=\$21D!

RTS=4!
CTS=8!
HANDSHAKIN=\$201!
HANDSHAKOUT=\$203!

SD_CD=4!                P2.2 as SD_CD
SD_CS=8!                P2.3 as SD_CS     
SD_CDIN=\$201!
SD_CSOUT=\$203!
SD_CSDIR=\$205!

SD_SEL=\$20D!           to configure UCB0
SD_REN=\$207!           to configure pullup resistors
SD_BUS=\$70!            pins P2.4 as UCB0CLK, P2.5 as UCB0SIMO & P2.6 as UCB0SOMI


! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$322!
LED1=\$01!              PJ.0

LED2_OUT=\$322!
LED2=\$02!              PJ.1

SW1_IN=\$221!
SW1=\$01!               P4.0

SW2_IN=\$221!
SW2=\$02!               P4.1

LCDVo_DIR=\$204!
LCDVo_SEL=\$20A!        SEL0
LCDVo=\$20!             P1.5

LCD_CMD_IN=\$220!
LCD_CMD_OUT=\$222!
LCD_CMD_DIR=\$224!
LCD_CMD_REN=\$226!
LCD_RS=\$10!            P3.4
LCD_RW=\$20!            P3.5
LCD_EN=\$40!            P3.6
LCD_CMD=\$70!

LCD_DB_IN=\$200!
LCD_DB_OUT=\$202!
LCD_DB_DIR=\$204!
LCD_DB_REN=\$206!
LCD_DB=\$0F!            P1.0-3
!LCD timer
LCD_TIM_CTL=\$3C0!      TB0CTL
LCD_TIM_CCTL2=\$3C6!    TB0CCTL2
LCD_TIM_CCR0=\$3D2!     TB0CCR0
LCD_TIM_CCR2=\$3D6!     TB0CCR2
LCD_TIM_EX0=\$3E0!      TB0EX0


!WATCHDOG timer
WDT_TIM_CTL=\$340!      TA0CTL
WDT_TIM_CCTL0=\$342!    TA0CCTL0
WDT_TIM_CCR0=\$352!     TA0CCR0
WDT_TIM_EX0=\$360!      TA0EX0
WDT_TIM_0_Vec=\$FFEA!     TA0_0_Vec

IR_IN=\$201!  
IR_OUT=\$203! 
IR_DIR=\$205! 
IR_REN=\$207! 
IR_IES=\$219!
IR_IE=\$21B!
IR_IFG=\$21D!
RC5_=RC5_!
RC5=\$40!               P2.6
IR_Vec=\$FFD8!          P2 int
!IR_RC5 timer
RC5_TIM_CTL=\$380!       TA1CTL
RC5_TIM_R=\$390!         TA1R
RC5_TIM_EX0=\$3A0!       TA1EX0

I2CSM_IN=\$200!
I2CSM_OUT=\$202!
I2CSM_DIR=\$204!
I2CSM_REN=\$206!
SMSDA=\$40!             P1.6
SMSCL=\$80!             P1.7
SM_BUS=\$C0!

I2CSMM_IN=\$200!
I2CSMM_OUT=\$202!
I2CSMM_DIR=\$204!
I2CSMM_REN=\$206!
SMMSDA=\$40!            P1.6
SMMSCL=\$80!            P1.7
SMM_BUS=\$C0!

I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL=\$20C!        SEL1
I2CMM_Vec=\$FFEE!       UCB0
MMSDA=\$40!             P1.6
MMSCL=\$80!             P1.7
MM_BUS=\$C0!

I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL=\$20C!         SEL1
I2CM_Vec=\$FFEE!        UCB0
MSDA=\$40!              P1.6
MSCL=\$80!              P1.7
M_BUS=\$C0!

I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL=\$20C!         SEL1
I2CS_Vec=\$FFEE!        UCB0
SSDA=\$40!              P1.6
SSCL=\$80!              P1.7
S_BUS=\$C0!

