! -*- coding: utf-8 -*-
! MSP_EXP430FR6989.pat
!
! Fast Forth For Texas Instrument MSP_EXP430FR6989
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
! MSP430FR6989 Config
! ======================================================================

@define{@read{/config/gema/MSP430FR6989.pat}}
@define{@read{/config/gema/MSP430FR5x6x_FastForth.pat}}
@define{@read{/config/gema/FastForthREGtoTI.pat}}
@define{@read{/config/gema/RemoveComments.pat}}

! ======================================================================
! MSP_EXP430FR6989 board
! ======================================================================

! ---------------------------------------------------
! MSP  - MSP-EXP430FR6989 LAUNCHPAD <--> OUTPUT WORLD
! ---------------------------------------------------
! P1.0 - LED1 red
! P9.7 - LED2 green
!
! P1.1 - Switch S1              <--- LCD contrast + (finger :-)
! P1.2 - Switch S2              <--- LCD contrast - (finger ;-)
!                                   
! note : ESI1.1 = lowest left pin
! note : ESI1.2 is not connected to 3.3V
!  GND                     J6.2 <-------+---0V0---------->  1 LCD_Vss
!  VCC                     J6.1 >------ | --3V3-----+---->  2 LCD_Vdd
!                                       |           |
!                                     |___    470n ---
!                                       ^ |        ---
!                                      / \ BAT54    |
!                                      ---          |
!                                  100n |    2k2    |
! P3.6 - UCA1 CLK TB0.2 J4.37   >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P9.0/ESICH0 -         ESI1.14 <------------------------> 11 LCD_DB4 brown
! P9.1/ESICH1 -         ESI1.13 <------------------------> 12 LCD_DB5 red
! P9.2/ESICH2 -         ESI1.12 <------------------------> 13 LCD_DB5 orange
! P9.3/ESICH3 -         ESI1.11 <------------------------> 14 LCD_DB7 yellow
! P4.1                          ------------------------->  4 LCD_RS  yellow
! P4.2                          ------------------------->  5 LCD_R/W green
! P4.3                          ------------------------->  6 LCD_EN  blue
!
!                                 +--4k7-< DeepRST <-- GND 
!                                 |
! P3.4 - UCA1 TXD       J101.8  <-+-> RX  UARTtoUSB bridge
! P3.5 - UCA1 RXD       J101.10 <---- TX  UARTtoUSB bridge
! P3.0 - RTS            J101.14 ----> CTS UARTtoUSB bridge (optional hardware control flow)
!  VCC -                J101.16 <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
!  GND -                J101.20 <---> GND (optional supply from UARTtoUSB bridge)
!
!  VCC -                J1.1    ----> VCC SD_CardAdapter
!  GND -                J2.20   <---> GND SD_CardAdapter
! P2.2 -  UCA0 CLK      J4.35   ----> CLK SD_CardAdapter (SCK)  
! P2.6 -                J4.39   ----> CS  SD_CardAdapter (Card Select)
! P2.0 -  UCA0 TXD/SIMO J1.8    ----> SDI SD_CardAdapter (MOSI)
! P2.1 -  UCA0 RXD/SOMI J2.19   <---- SDO SD_CardAdapter (MISO)
! P2.7 -                J4.40   <---- CD  SD_CardAdapter (Card Detect)
!
! P4.0 -                J1.10   <---- OUT IR_Receiver (1 TSOP32236)
!  VCC -                J1.1    ----> VCC IR_Receiver (2 TSOP32236)
!  GND -                J2.20   <---> GND IR_Receiver (3 TSOP32236)
!
! P1.3 -                J4.34   <---> SDA software I2C Master
! P1.5 -                J2.18   ----> SCL software I2C Master
!
! P1.4 -UCB0 CLK TA1.0  J1.7    <---> free
!
! P1.6 -UCB0 SDA/SIMO   J2.15   <---> SDA hardware I2C Master or Slave
! P1.7 -UCB0 SCL/SOMI   J2.14   ----> SCL hardware I2C Master or Slave
!
! P3.0 -UCB1 CLK        J4.33   ----> free (if UARTtoUSB with software control flow)
! P3.1 -UCB1 SDA/SIMO   J4.32   <---> free
! P3.2 -UCB1 SCL/SOMI   J1.5    ----> free
! P3.3 -         TA1.1  J1.5    <---> free
!
! PJ.4 - LFXI 32768Hz quartz  
! PJ.5 - LFXO 32768Hz quartz  
! PJ.6 - HFXI 
! PJ.7 - HFXO 


LED1_OUT=\$202!
LED1=1!      P1.0

LED2_OUT=\$282!
LED2=\$80!      P9.7

SW1_IN=\$200!
SW1=2!       P1.1

SW2_IN=\$200!
SW2=4!       P1.2

LCDVo_DIR=\$224!
LCDVo_SEL=\$22C!  SEL1
LCDVo=\$40!     P3.6

LCD_CMD_IN=\$221!
LCD_CMD_OUT=\$223!
LCD_CMD_DIR=\$225!
LCD_CMD_REN=\$227!
LCD_RS=2!    P4.1
LCD_RW=4!    P4.2
LCD_EN=8!    P4.3
LCD_CMD=\$0E!

LCD_DB_IN=\$280!
LCD_DB_OUT=\$282!
LCD_DB_DIR=\$284!
LCD_DB_REN=\$286!
LCD_DB=\$0F!    P9.3-0


IR_IN=\$221!  
IR_OUT=\$223! 
IR_DIR=\$225! 
IR_REN=\$227! 
IR_IES=\$239!
IR_IE=\$23B!
IR_IFG=\$23D!
RC5_=RC5_!
RC5=1!       P4.0
IR_Vec=\$FFCC!    P4 int

I2CSM_IN=\$200!
I2CSM_OUT=\$202!
I2CSM_DIR=\$204!
I2CSM_REN=\$206!
SMSDA=8!     P1.3
SMSCL=\$20!     P1.5
SM_BUS=\$28!     

I2CSMM_IN=\$200!
I2CSMM_OUT=\$202!
I2CSMM_DIR=\$204!
I2CSMM_REN=\$206!
SMMSDA=8!    P1.3
SMMSCL=\$20!    P1.5
SMM_BUS=\$28!    

I2CMM_IN=\$200!
I2CMM_OUT=\$202!
I2CMM_DIR=\$204!
I2CMM_REN=\$206!
I2CMM_SEL=\$20C!  SEL1
I2CMM_Vec=\$FFEC!
MMSDA=\$40!     P1.6
MMSCL=\$80!     P1.7
MM_BUS=\$C0!    

I2CM_IN=\$200!
I2CM_OUT=\$202!
I2CM_DIR=\$204!
I2CM_REN=\$206!
I2CM_SEL=\$20C!
I2CM_Vec=\$FFEC!
MSDA=\$40!      P1.6
MSCL=\$80!      P1.7
M_BUS=\$C0!    

I2CS_IN=\$200!
I2CS_OUT=\$202!
I2CS_DIR=\$204!
I2CS_REN=\$206!
I2CS_SEL=\$20C!
I2CS_Vec=\$FFEC!
SSDA=\$40!      P1.6
SSCL=\$80!      P1.7
S_BUS=\$C0!

