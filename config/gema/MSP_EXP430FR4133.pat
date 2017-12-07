! -*- coding: utf-8 -*-
! MSP_EXP430FR4133.pat
!
! Fast Forth For Texas Instrument MSP_EXP430FR4133
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
! MSP430FR4133 Config
! ======================================================================

@define{@read{@mergepath{@inpath{};MSP430FR4133.pat;}}}
@define{@read{@mergepath{@inpath{};MSP430FR2x4x_FastForth.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}
@define{@read{@mergepath{@inpath{};RemoveComments.pat;}}}

! ======================================================================
! MSP_EXP430FR4133 board
! ======================================================================
!
! J101   eZ-FET <-> target
! -----------------------
! P1 <-> P2 - NC
! P3 <-> P4 - TEST  - TEST
! P5 <-> P6 - RST   - RST
! P7 <-> P8 - TX1   - P1.0 UCA0 TXD ---> RX UARTtoUSB module
! P9 <->P10 - RX1   - P1.1 UCA0 RXD <--- TX UARTtoUSB module
! P11<->P12 - CTS   - P2.4
! P13<->P14 - RTS   - P2.3
! P15<->P16 - VCC   - 3V3
! P17<->P18 - 5V
! P19<->P20 - GND   - VSS
!
! Launchpad Header Left J1
! ------------------------
! P1 - 3V3
! P2 - P8.1 ACLK/A9
! P3 - P1.1 UCA0 RXD
! P4 - P1.0 UCA0 TXD
! P5 - P2.7    
! P6 - P8.0 SMCLK/A8
! P7 - P5.1 UCB0 CLK
! P8 - P2.5
! P9 - P8.2 TA1CLK
! P10- P8.3 TA1.2
!
! Launchpad Header Right J2
! -------------------------
! P1 - GND
! P2 - P1.7 TA0.1/TDO/A7
! P3 - P1.6 TA0.2/TDI/TCLK/A6
! P4 - P5.0 UCB0STE
! P5 - RST
! P6 - P5.2 UCB0SIMO/UCB0SDA
! P7 - P5.3 UCB0SOMI/UCB0SCL
! P8 - P1.3 UCA0STE/A3
! P9 - P1.4 MCLK/TCK/A4
! P10- P1.5 TA0CLK/TMS/A5
!
! switch-keys:
! S1 - P1.2
! S2 - P2.6
! S3 - RST
!
! LEDS:
! LED1 - P1.0/TXD
! LED2 - P4.0
!
! XTAL LF 32768 Hz
! Y4 - P4.1 XIN
! Y4 - P4.2 XOUT
!
! LCD
! L0  - P7.0
! L1  - P7.1
! L2  - P7.2
! L3  - P7.3
! L4  - P7.4
! L5  - P7.5
! L6  - P7.6
! L7  - P7.7
! L8  - P3.0
! L9  - P3.1
! L10 - P3.2
! L11 - P3.3
! L12 - P3.4
! L13 - P3.5
! L14 - P3.6
! L15 - P3.7
! L16 - P6.0
! L17 - P6.1
! L18 - P6.2
! L19 - P6.3
! L20 - P6.4
! L21 - P6.5
! L22 - P6.6
! L23 - P6.7
! L24 - P2.0
! L25 - P2.1
! L26 - P2.2
! L36 - P5.4
! L37 - P5.5
! L38 - P5.6
! L39 - P5.7
!
!
!
!
!
!
! ===================================================================================
! in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
! then wire VCC and GND of bridge onto J13 connector
! ===================================================================================
!
! ---------------------------------------------------
! MSP  - MSP-EXP430FR4133 LAUNCHPAD <--> OUTPUT WORLD
! ---------------------------------------------------
!
!                                 +-4k7-< DeepRST <-- GND 
!                                 |
! P1.0 - UCA0 TXD       J101.8  --+-> RX  UARTtoUSB bridge
! P1.1 - UCA0 RXD       J101.10 <---- TX  UARTtoUSB bridge
! P2.3 - RTS            J101.14 ----> CTS UARTtoUSB bridge (if TERMINALCTSRTS option)
!  VCC -                J101.16 <---- VCC (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
!  GND -                J101.20 <---> GND (optional supply from UARTtoUSB bridge)
!
! P1.0 - STRAP JP1 MUST BE REMOVED     (LED red) 
!        =========================
!
! P4.0 - LED green
!
! P1.2 - Switch SW1              <--- LCD contrast + (finger :-)
! P2.6 - Switch SW2              <--- LCD contrast - (finger ;-) 
!
!                                   
!  GND -                 J2.1   <-------+---0V0---------->  1 LCD_Vss
!  VCC -                 J1.1   >------ | --3V6-----+---->  2 LCD_Vdd
!                                       |           |
!                                      ___    470n ---
!                                       ^          ---
!                                      / \ 1n4148   |
!                                      ---          |
!                                  100n |    2k2    |
! P1.6 - TA0.2           J2.18  >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P1.3 -                 J2.13  ------------------------->  4 LCD_RS
! P1.4 -                 J2.12  ------------------------->  5 LCD_R/W
! P1.5 -                 J2.11  ------------------------->  6 LCD_EN
! P5.0 -                 J2.17  <------------------------> 11 LCD_DB4
! P5.1 -                 J1.7   <------------------------> 12 LCD_DB5
! P5.2 -                 J2.15  <------------------------> 13 LCD_DB5
! P5.3 -                 J2.14  <------------------------> 14 LCD_DB7
!        
!                     
! P1.7 -                J2.19   <---- OUT IR_Receiver (1 TSOP32236)
! 
! P4.1 - LFXIN  32768Hz quartz  
! P4.2 - LFXOUT 32768Hz quartz  
! 
!  VCC -                J1.1    ----> VCC SD_CardAdapter
!  GND -                J2.1    <---> GND SD_CardAdapter
! P5.1 -  UCB0 CLK      J1.7    ----> CLK SD_CardAdapter (SCK)  
! P8.1 -                J1.2    ----> CS  SD_CardAdapter (Card Select)
! P5.2 -  UCB0 TXD/SIMO J2.15   ----> SDI SD_CardAdapter (MOSI)
! P5.3 -  UCB0 RXD/SOMI J2.14   <---- SDO SD_CardAdapter (MISO)
! P8.0 -                J1.6    <---- CD  SD_CardAdapter (Card Detect)
!
!
!       
! P8.2 - Soft I2C_Master J1.9   ----> SDA software I2C Master
! P8.3 - Soft I2C_Master J1.10  <---> SCL software I2C Master


! ============================================
! FORTH I/O :
! ============================================
TERM_TX=1!          ; P1.0 = TX
TERM_RX=2!          ; P1.1 = RX
TERM_TXRX=3!

TERM_REN=\$206!
TERM_SEL=\$20C!
TERM_IE=\$21A!
TERM_IFG=\$21C!
Deep_RST=1!         ; = TX pin
Deep_RST_IN=\$200!  ; TERMINAL TX  pin as FORTH Deep_RST

RTS=8!              ; P2.3
CTS=\$10!           ; P2.4
HANDSHAKIN=\$201!
HANDSHAKOUT=\$203!


SD_CS=2!        ; P8.1 as SD_CS     
SD_CD=1!        ; P8.0 as SD_CD
SD_CDIN=\$261!
SD_CSOUT=\$263!
SD_CSDIR=\$265!

SD_SEL1=\$24C!  ; to configure UCB0
SD_REN=\$246!   ; to configure pullup resistors
SD_BUS=\$0E!    ; pins P5.1 as UCB0CLK, P5.2 as UCB0SIMO & P5.3 as UCB0SOMI


! ============================================
! APPLICATION I/O :
! ============================================
!LEDs
!----
invert LED numbers because LED1=TXD !
LED2_OUT=\$202!
LED2=\$01!          P1.0 red LED
LED1_OUT=\$223!
LED1=\$01!          P4.0 green LED

!switches
!--------
SW1_IN=\$200!
SW1=\$04!           P1.2 SW1
SW2_IN=\$201!
SW2=\$40!           P2.6 SW2

!LCD Vo driver
!-------------
LCDVo_DIR=\$204!      P1.6 = LCDVo
LCDVo_SEL=\$20A!      SEL0
LCDVo=\$40!
! FR4133 hasn't TB0: let TA0 addresses for TA0.2=LCDVo on P1.6
TB0CTL=\$300!
TB0CCTL2=\$306!
TB0CCR0=\$312!
TB0CCR2=\$316!
TB0EX0=\$320!

!LCD command bus
!---------------
LCD_CMD_IN=\$200!
LCD_CMD_OUT=\$202!
LCD_CMD_DIR=\$204!
LCD_CMD_REN=\$206!
LCD_RS=\$08!        P1.3 LCD_RS
LCD_RW=\$10!        P1.4 LCD_RW
LCD_EN=\$20!        P1.5 LCD_EN
LCD_CMD=\$38!

!LCD data bus
!------------
LCD_DB_IN=\$240!
LCD_DB_OUT=\$242!
LCD_DB_DIR=\$244!
LCD_DB_REN=\$246!
LCD_DB=\$0F!        P5.0-3 LCD_DATA_BUS

!IR_RC5 input
!------------
IR_IN=\$200!  
IR_OUT=\$202! 
IR_DIR=\$204! 
IR_REN=\$206! 
IR_IES=\$218!
IR_IE=\$21A!
IR_IFG=\$21C!
IR_Vec=\$FFE6!    P1 int
RC5=\$80!               P1.7 IR_RC5
! replace TA0 addrs by TA1 addrs because TA0 used for LCDVo
TA0CTL=\$340!
TA0CCTL2=\$346!
TA0R=\$350!
TA0CCR0=\$352!
TA0CCR2=\$356!
TA0EX0=\$360!


I2CSM_IN=\$261!
I2CSM_OUT=\$263!
I2CSM_DIR=\$265!
I2CSM_REN=\$267!
SMSDA=\$04!         P8.2  SDA software MASTER
SMSCL=\$08!         P8.3  SCL software MASTER
SM_BUS=\$0C!

I2CSMM_IN=\$261!
I2CSMM_OUT=\$263!
I2CSMM_DIR=\$265!
I2CSMM_REN=\$267!
SMMSDA=\$04!        P8.2  SDA software MULTI_MASTER
SMMSCL=\$08!        P8.3  SCL software MULTI_MASTER
SMM_BUS=\$0C!

I2CMM_IN=\$240!
I2CMM_OUT=\$242!
I2CMM_DIR=\$244!
I2CMM_REN=\$246!
I2CMM_SEL=\$24A!     SEL0
I2CMM_Vec=\$FFEA!
MMSDA=\$04!         P5.2  SDA hadware MULTI_MASTER
MMSCL=\$08!         P5.3  SCL hadware MULTI_MASTER
MM_BUS=\$0C!

I2CM_IN=\$240!
I2CM_OUT=\$242!
I2CM_DIR=\$244!
I2CM_REN=\$246!
I2CM_SEL=\$24A!     SEL0
I2CM_Vec=\$FFEA!
MSDA=\$04!        P5.2  SDA hadware MASTER
MSCL=\$08!        P5.3  SCL hadware MASTER
M_BUS=\$0C!

I2CS_IN=\$240!
I2CS_OUT=\$242!
I2CS_DIR=\$244!
I2CS_REN=\$246!
I2CS_SEL=\$24A!     SEL0
I2CS_Vec=\$FFEA!
SSDA=\$04!        P5.2  SDA hadware SLAVE
SSCL=\$08!        P5.3  SCL hadware SLAVE
S_BUS=\$0C!

