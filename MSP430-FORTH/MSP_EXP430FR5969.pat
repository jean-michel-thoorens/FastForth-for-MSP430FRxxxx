! -*- coding: utf-8 -*-
! MSP_EXP430FR5969.pat
!
! Fast Forth For Texas Instrument MSP_EXP430FR5969
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
! MSP430FR5969 Config
! ======================================================================

@define{@read{/config/gema/MSP430FR5969.pat}}
@define{@read{/config/gema/MSP430FR5x6x_FastForth.pat}}
@define{@read{/config/gema/FastForthREGtoTI.pat}}
@define{@read{/config/gema/RemoveComments.pat}}

! ======================================================================
! MSP_EXP430FR5969 board
! ======================================================================

! J3: JTAG
! --------
! P1 - TDO  - PJ.0
! P2 - V_debug
! P3 - TDI  - PJ.1
! P4 - V_ext
! P5 - TMS  - PJ.2
! P6 - NC
! P7 - TCK  - PJ.3
! P8 - TEST - TEST
! P9 - GND
! P10- CTS  - P4.0
! P11- RST  - RESET
! P12- TX0  - P2.0
! P13- RTS  - P4.1
! P14- RX0  - P2.1

! Launchpad Header Left J4
! ------------------------
! P1 - VCC
! P2 - P4.2
! P3 - P2.6 UCA1 RX/SOMI
! P4 - P2.5 UCA1 TX/SIMO
! P5 - P4.3             
! P6 - P2.4 UCA1     CLK
! P7 - P2.2 TB0.2 UCB0CLK
! P8 - P3.4
! P9 - P3.5
! P10- P3.6

! Launchpad Header Right J5
! -------------------------
! P11- P1.3
! P12- P1.4
! P13- P1.5
! P14- P1.6  UCB0 SIMO/SDA
! P15- P1.7  UCB0 SOMI/SCL
! P16- RST
! P17- NC
! P18- P3.0
! P19- P1.2
! P20- GND

!    J13    eZ-FET <=> target
! ---------------------------
! P1     P2     NC     NC
! P3 <-> P4   TEST <-> TEST
! P5 <-> P6    RST <-> RST
! P7     P8    TX0     P2.0 (no strap)
! P9    P10    RX0     P2.1 (no strap)
! P11   P12    CTS     P4.0 (no strap)
! P13   P14    RTS     P4.1 (no strap)
! P15<->P16     V+ <-> VCC 
! P17   P18     5V          (no strap)
! P19---P20    GND-----VSS

! J21 : external target
! ---------------------
! P1 - RX0  - P2.1
! P2 - VCC
! P3 - TEST - TEST
! P4 - RST  - RST
! P5 - GND
! P6 - TX0  - P2.0


! -----------------------------------------------
! MSP430FR5969        LAUNCHPAD <--> OUTPUT WORLD
! -----------------------------------------------

! J13 jumpers : device <-> eZ-FET
! -------------------------------
!  P2   P1          NC     NC  
!  P4<->P3        TEST <-> TEST
!  P6<->P5         RST <-> RST 
!  P8   P7        P2.0     TX0  (no jumper)
! P10   P9        P2.1     RX0  (no jumper)
! P12   P11       P4.0     CTS  (no jumper)
! P14   P13       P4.1     RTS  (no jumper)
! P16<->P15        VCC <-> V+  
! P18   P17         5V     5V   (no jumper)
! P20---P19        VSS-----GND  

! P4.6 - J6 - LED1 red
! P1.0 - LED2 green
!
! P4.5 - Switch S1              <--- LCD contrast + (finger :-)
! P1.1 - Switch S2              <--- LCD contrast - (finger ;-)
!                                   
!  GND -                 J1.2   <-------+---0V0---------->  1 LCD_Vss
!  VCC -                 J1.3   >------ | --3V6-----+---->  2 LCD_Vdd
!                                       |           |
!                                      ___    470n ---
!                                       ^          ---
!                                      / \ 1n4148   |
!                                      ---          |
!                                  100n |    2k2    |
! P2.2 - UCB0 CLK TB0.2  J4.7   >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P3.4 -                 J4.8   ------------------------->  4 LCD_RS
! P3.5 -                 J4.9   ------------------------->  5 LCD_R/W
! P3.6 -                 J4.10  ------------------------->  6 LCD_EN
! PJ.0 -                 J3.1   <------------------------> 11 LCD_DB4
! PJ.1 -                 J3.3   <------------------------> 12 LCD_DB5
! PJ.2 -                 J3.5   <------------------------> 13 LCD_DB5
! PJ.3 -                 J3.7   <------------------------> 14 LCD_DB7
!        
!                                 +--4k7-< DeepRST <-- GND 
!                                 |
! P2.0 - UCA0 TXD        J13.8  <-+-> RX   UARTtoUSB bridge
! P2.1 - UCA0 RXD        J13.10 <---- TX   UARTtoUSB bridge
! P4.1 - RTS             J13.14 ----> CTS  UARTtoUSB bridge (optional hardware control flow)
!  VCC -                 J13.16 <---- VCC  (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
!  GND -                 J13.20 <---> GND  (optional supply from UARTtoUSB bridge)
!        
!  VCC -                 J11.1  ----> VCC  SD_CardAdapter
!  GND -                 J12.3  <---> GND  SD_CardAdapter
! P2.4 - UCA1 CLK        J4.6   ----> CLK  SD_CardAdapter (SCK)  
! P4.3 -                 J4.5   ----> CS   SD_CardAdapter (Card Select)
! P2.5 - UCA1 TXD/SIMO   J4.4   ----> SDI  SD_CardAdapter (MOSI)
! P2.6 - UCA1 RXD/SOMI   J4.3   <---- SDO  SD_CardAdapter (MISO)
! P4.2 -                 J4.2   <---- CD   SD_CardAdapter (Card Detect)
!        
! P4.0 -                 J3.10  <---- OUT  IR_Receiver (1 TSOP32236)
!  VCC -                 J3.2   ----> VCC  IR_Receiver (2 TSOP32236)
!  GND -                 J3.9   <---> GND  IR_Receiver (3 TSOP32236)
!        
! P1.2 -                 J5.19  <---> SDA  I2C SOFTWARE MASTER
! P1.3 -                 J5.11  <---> SCL  I2C SOFTWARE MASTER
! P1.4 -           TB0.1 J5.12  <---> free
! P1.5 - UCA0 CLK  TB0.2 J5.13  <---> free
! P1.7 - UCB0 SCL/SOMI   J5.14  ----> SCL  I2C MASTER/SLAVE
! P1.6 - UCB0 SDA/SIMO   J5.15  <---> SDA  I2C MASTER/SLAVE
! P3.0 -                 J5.7   <---- free
!
! PJ.4 - LFXI 32768Hz quartz  
! PJ.5 - LFXO 32768Hz quartz  
! PJ.6 - HFXI 
! PJ.7 - HFXO 
! 
! P2.3 - NC
! P2.7 - NC
! P3.1 - NC
! P3.2 - NC
! P3.3 - NC
! P3.7 - NC
! P4.4 - NC
! P4.7 - NC

! ============================================
! FORTH I/O :
! ============================================
TERM_TX=1!          ; P2.0 = TX
TERM_RX=2!          ; P2.1 = RX
TERM_TXRX=3!

TERM_REN=\$207!
TERM_SEL=\$20D!
TERM_IE=\$21B!
TERM_IFG=\$21D!
Deep_RST=1!         ; = TX pin
Deep_RST_IN=\$201!  ; TERMINAL TX  pin as FORTH Deep_RST

RTS=2!              ; P4.1
CTS=1!              ; P4.0
HANDSHAKIN=\$221!
HANDSHAKOUT=\$223!

SD_CD=4!        ; P4.2 as SD_CD
SD_CS=8!        ; P4.3 as SD_CS     
SD_CDIN=\$221!
SD_CSOUT=\$223!
SD_CSDIR=\$225!

SD_SEL1=\$20D!  ; to configure UCB0
SD_REN=\$207!   ; to configure pullup resistors
SD_BUS=\$70!    ; pins P2.4 as UCB0CLK, P2.5 as UCB0SIMO & P2.6 as UCB0SOMI


! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$223
LED1=\$40!          P4.6

LED2_OUT=\$202
lLED2=\$01!         P1.0

SW1_IN=\$221
SW1=\$20!           P4.5

SW2_IN=\$200
SW2=\$02!           P1.1

LCDVo_DIR=\$205!    P2
LCDVo_SEL=\$20B!    SEL0
LCDVo=\$04

LCD_CMD_IN=\$220!   P3
LCD_CMD_OUT=\$222
LCD_CMD_DIR=\$224
LCD_CMD_REN=\$226
LCD_RS=\$10
LCD_RW=\$20
LCD_EN=\$40
LCD_CMD=\$70

LCD_DB_IN=\$320!    PJ
LCD_DB_OUT=\$322
LCD_DB_DIR=\$324
LCD_DB_REN=\$326
LCD_DB=\$0F


IR_IN=\$221
IR_OUT=\$223
IR_DIR=\$225
IR_REN=\$227
IR_IES=\$239
IR_IE=\$23B
IR_IFG=\$23D
IR_Vec=\$FFD0!      P4 int
RC5=\$01!           P4.0

I2CSM_IN=\$200
I2CSM_OUT=\$202
I2CSM_DIR=\$204
I2CSM_REN=\$206
SMSDA=\$04!         P1.2
SMSCL=\$08!         P1.3
SM_BUS=\$0C

I2CSMM_IN=\$200
I2CSMM_OUT=\$202
I2CSMM_DIR=\$204
I2CSMM_REN=\$206
SMMSDA=\$04!        P1.2
SMMSCL=\$08!        P1.3
SMM_BUS=\$0C

I2CMM_IN=\$200
I2CMM_OUT=\$202
I2CMM_DIR=\$204
I2CMM_REN=\$206
I2CMM_SEL=\$20C!    SEL1
I2CMM_Vec=\$FFEE!   eUSCIB0_INT
MMSDA=\$40!         P1.6
MMSCL=\$80!         P1.7
MM_BUS=\$C0

I2CM_IN=\$200
I2CM_OUT=\$202
I2CM_DIR=\$204
I2CM_REN=\$206
I2CM_SEL=\$20C
I2CM_Vec=\$FFEE!    eUSCIB0_INT
MSDA=\$40!          P1.6
MSCL=\$80!          P1.7
M_BUS=\$C0

I2CS_IN=\$200
I2CS_OUT=\$202
I2CS_DIR=\$204
I2CS_REN=\$206
I2CS_SEL=\$20C
I2CS_Vec=\$FFEE!    eUSCIB0_INT
SSDA=\$40!          P1.6
SSCL=\$80!          P1.7
S_BUS=\$C0

