! -*- coding: utf-8 -*-
! MSP_EXP430FR5994.pat
!
! Fast Forth For Texas Instrument MSP_EXP430FR5994
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
! MSP430FR5994 Config
! ======================================================================

@define{@read{/config/gema/MSP430FR5994.pat}}
@define{@read{/config/gema/MSP430FR5x6x_FastForth.pat}}
@define{@read{/config/gema/FastForthREGtoTI.pat}}
@define{@read{/config/gema/RemoveComments.pat}}

! ======================================================================
! MSP_EXP430FR5994 board
! ======================================================================

! J101 Target     <---> eZ-FET
! GND             14-13   GND
! +5V             12-11
! 3V3             10-9
! P2.1 UCA0_RX     8-7         <---- TX   UARTtoUSB bridge
!                                +--4k7-< DeepRST <-- GND
!                                |            
! P2.0 UCA0_TX     6-5         <-+-> RX   UARTtoUSB bridge
! /RST             4-3
! TEST             2-1


! P5.6    - sw1                <--- LCD contrast + (finger :-)
! P5.5    - sw2                <--- LCD contrast - (finger ;-)
! RST     - sw3 

! P1.0    - led1 red
! P1.1    - led2 green

! J1 - left ext.
! 3v3
! P1.2/TA1.1/TA0CLK/COUT/A2/C2 <--- OUT IR_Receiver (1 TSOP32236)     
! P6.1/UCA3RXD/UCA3SOMI        ------------------------->  4 LCD_RS
! P6.0/UCA3TXD/UCA3SIMO        ------------------------->  5 LCD_R/W
! P6.2/UCA3CLK                 ------------------------->  6 LCD_EN0
! P1.3/TA1.2/UCB0STE/A3/C3            
! P5.2/UCB1CLK/TA4CLK
! P6.3/UCA3STE
! P7.1/UCB2SOMI/UCB2SCL        ---> SCL I2C MASTER/SLAVE
! P7.0/UCB2SIMO/UCB2SDA        <--> SDA I2C MASTER/SLAVE

! J3 - left int.
! 5V
! GND
! P3.0/A12/C12                 <------------------------> 11 LCD_DB4   
! P3.1/A13/C13                 <------------------------> 12 LCD_DB5
! P3.2/A14/C14                 <------------------------> 13 LCD_DB5
! P3.3/A15/C15                 <------------------------> 14 LCD_DB7
! P1.4/TB0.1/UCA0STE/A4/C4
! P1.5/TB0.2/UCA0CLK/A5/C5     >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)    
! P4.7
! P8.0

! J4 - right int.
! P3.7/TB0.6                          
! P3.6/TB0.5                          
! P3.5/TB0.4/COUT                     
! P3.4/TB0.3/SMCLK
! P7.3/UCB2STE/TA4.1       RTS ----> CTS  UARTtoUSB bridge (optional hardware control flow)
! P2.6/TB0.1/UCA1RXD/UCA1SOMI 
! P2.5/TB0.0/UCA1TXD/UCA1SIMO 
! P4.3/A11
! P4.2/A10
! P4.1/A9

! J2 - right ext.
! GND
! P5.7/UCA2STE/TA4.1/MCLK
! P4.4/TB0.5
! P5.3/UCB1STE
! /RST
! P5.0/UCB1SIMO/UCB1SDA
! P5.1/UCB1SOMI/UCB1SCL
! P8.3
! P8.2                          <--> SDA I2C SOFTWARE MASTER
! P8.1                          <--> SCL I2C SOFTWARE MASTER


! SD_CARD
! P7.2/UCB2CLK                        <--- SD_CD
! P1.6/TB0.3/UCB0SIMO/UCB0SDA/TA0.0   ---> SD_MOSI
! P1.7/TB0.4/UCB0SOMI/UCB0SCL/TA1.0   <--- SD_MISO
! P4.0/A8                             ---> SD_CS
! P2.2/TB0.2/UCB0CLK                  ---> SD_CLK



! XTAL LF 32768 Hz
! PJ.4/LFXIN
! PJ.5/LFXOUT

! XTAL HF
! PJ.6/HFXIN
! PJ.7/HFXOUT

! -----------------------------------------------
! LCD config
! -----------------------------------------------

!       <-------+---0V0---------->  1 LCD_Vss
!       >------ | --3V6-----+---->  2 LCD_Vdd
!               |           |
!             |___    470n ---
!               ^ |        ---
!              / \ BAT54    |
!              ---          |
!          100n |    2k2    |
! TB0.2 >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
!       ------------------------->  4 LCD_RS
!       ------------------------->  5 LCD_R/W
!       ------------------------->  6 LCD_EN0
!       <------------------------> 11 LCD_DB4
!       <------------------------> 12 LCD_DB5
!       <------------------------> 13 LCD_DB5
!       <------------------------> 14 LCD_DB7




LED1_OUT=\$202!
led1=1!             P1.0

LED2_OUT=\$202!
led2=2!             P1.1

SW1_IN=\$240!
SW1=\$40!           P5.6

SW2_IN=\$240!
SW2=\$20!           P5.5

LCDVo_DIR=\$204!
LCDVo_SEL=\$20A!      SEL0
LCDVo=\$20!         P1.5

LCD_CMD_IN=\$241!
LCD_CMD_OUT=\$243!
LCD_CMD_DIR=\$245!
LCD_CMD_REN=\$247!
LCD_RS=2!           P6.1
LCD_RW=1!           P6.0
LCD_EN=4!           P6.2
LCD_CMD=7!

LCD_DB_IN=\$220!
LCD_DB_OUT=\$222!
LCD_DB_DIR=\$224!
LCD_DB_REN=\$226!
LCD_DB=\$0F!        P3.3210


IR_IN=\$200!  
IR_OUT=\$202! 
IR_DIR=\$204! 
IR_REN=\$206! 
IR_IES=\$208!
IR_IE=\$20A!
IR_IFG=\$20C!
IR_Vec=\$FFDE!        P1 int
RC5_=RC5_!
RC5=4!              P1.2


SD_CS=1!            P4.0
SD_CSIN=\$221!

SD_CD=4!            P7.2
SD_CDIN=\$260!

I2CSM_IN=\$261!
I2CSM_OUT=\$263!
I2CSM_DIR=\$265!
I2CSM_REN=\$267!
SMSDA=4!         P8.2
SMSCL=2!         P8.1
SM_BUS=6!

I2CSMM_IN=\$261!
I2CSMM_OUT=\$263!
I2CSMM_DIR=\$265!
I2CSMM_REN=\$267!
SMMSDA=4!        P8.2
SMMSCL=2!        P8.1
SMM_BUS=6!

I2CMM_IN=\$260!
I2CMM_OUT=\$262!
I2CMM_DIR=\$264!
I2CMM_REN=\$266!
I2CMM_SEL1=\$26C!
I2CMM_Vec=\$FFBC!     UCB2_Vec
MMSDA=1!            P7.0
MMSCL=2!            P7.1
MM_BUS=3!

I2CM_IN=\$260!
I2CM_OUT=\$262!
I2CM_DIR=\$264!
I2CM_REN=\$266!
I2CM_SEL1=\$26C!
I2CM_Vec=\$FFBC!
MSDA=1!             P7.0
MSCL=2!             P7.1
M_BUS=3!

I2CS_IN=\$260!
I2CS_OUT=\$262!
I2CS_DIR=\$264!
I2CS_REN=\$266!
I2CS_SEL1=\$26C!
I2CS_Vec=\$FFBC!
SSDA=1!             P7.0
SSCL=2!             P7.1
S_BUS=3!

