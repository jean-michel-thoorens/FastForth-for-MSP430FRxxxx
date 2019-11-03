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
\.f=\.4th!      to change file type

!========================
! remove comments        
!========================
\\*\n=
\s\\*\n=\n
! ======================================================================
! MSP430FR5994 Config
! ======================================================================
@define{@read{@mergepath{@inpath{};MSP430FR5994.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}

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
! P7.3/UCB2STE/TA4.1
! P2.6/TB0.1/UCA1RXD/UCA1SOMI 
! P2.5/TB0.0/UCA1TXD/UCA1SIMO 
! P4.3/A11
! P4.2/A10       RTS ----> CTS  UARTtoUSB bridge (optional hardware control flow)
! P4.1/A9        CTS <---- RTS  UARTtoUSB bridge (optional hardware control flow)

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




! ============================================
! FORTH I/O :
! ============================================
TXD=1!              ; P2.0 = TX also FORTH Deep_RST pin
RXD=2!              ; P2.1 = RX
TERM_BUS=3!

TERM_IN=\$201!
TERM_REN=\$207!
TERM_SEL=\$20D!
TERM_IE=\$21B!
TERM_IFG=\$21D!

TERM_CTLW0=\$5C0!    \ eUSCI_A control word 0        
TERM_CTLW1=\$5C2!    \ eUSCI_A control word 1        
TERM_BRW=\$5C6!         
TERM_BR0=\$5C6!      \ eUSCI_A baud rate 0           
TERM_BR1=\$5C7!      \ eUSCI_A baud rate 1           
TERM_MCTLW=\$5C8!    \ eUSCI_A modulation control    
TERM_STATW=\$5CA!     \ eUSCI_A status                
TERM_RXBUF=\$5CC!    \ eUSCI_A receive buffer        
TERM_TXBUF=\$5CE!    \ eUSCI_A transmit buffer       
TERM_ABCTL=\$5D0!    \ eUSCI_A LIN control           
TERM_IRTCTL=\$5D2!   \ eUSCI_A IrDA transmit control 
TERM_IRRCTL=\$5D3!   \ eUSCI_A IrDA receive control  
TERM_IE=\$5DA!       \ eUSCI_A interrupt enable      
TERM_IFG=\$5DC!      \ eUSCI_A interrupt flags       
TERM_IV=\$5DE!       \ eUSCI_A interrupt vector word 

RTS=4!              ; P4.2
CTS=2!              ; P4.1
HANDSHAKIN=\$221!
HANDSHAKOUT=\$223!

SD_CD=4!            ; P7.2 as SD_CD
SD_CDIN=\$260!

SD_CS=1!            ; P4.0 as SD_CS     
SD_CSOUT=\$223!
SD_CSDIR=\$225!

SD_SEL1=\$20C!      ; word access, to configure UCB0
SD_REN=\$206!       ; word access, to configure pullup resistors
SD_BUS=\$04C0!      ; pins P2.2 as UCB0CLK, P1.6 as UCB0SIMO & P1.7 as UCB0SOMI

SD_CTLW0=\$640!    \ eUSCI_B control word 0          
SD_CTLW1=\$642!    \ eUSCI_B control word 1 
SD_BRW=\$646!         
SD_BR0=\$646!      \ eUSCI_B bit rate 0              
SD_BR1=\$647!      \ eUSCI_B bit rate 1              
SD_STATW=\$648!    \ eUSCI_B status word 
SD_NT0=\$649!      \ eUSCI_B hardware count           
SD_TBCNT=\$64A!    \ eUSCI_B byte counter threshold  
SD_RXBUF=\$64C!    \ eUSCI_B receive buffer          
SD_TXBUF=\$64E!    \ eUSCI_B transmit buffer         
SD_I2COA0=\$654!   \ eUSCI_B I2C own address 0       
SD_I2COA1=\$656!   \ eUSCI_B I2C own address 1       
SD_I2COA2=\$658!   \ eUSCI_B I2C own address 2       
SD_I2COA3=\$65A!   \ eUSCI_B I2C own address 3       
SD_ADDRX=\$65C!    \ eUSCI_B received address        
SD_ADDMASK=\$65E!  \ eUSCI_B address mask            
SD_I2CSA=\$660!    \ eUSCI I2C slave address         
SD_IE=\$66A!       \ eUSCI interrupt enable          
SD_IFG=\$66C!      \ eUSCI interrupt flags           
SD_IV=\$66E!       \ eUSCI interrupt vector word     


! ============================================
! APPLICATION I/O :
! ============================================
LED1_OUT=\$202!
led1=1!                 P1.0

LED2_OUT=\$202!
led2=2!                 P1.1

SW1_IN=\$240!
SW1=\$40!               P5.6

SW2_IN=\$240!
SW2=\$20!               P5.5

LCDVo_DIR=\$204!
LCDVo_SEL=\$20A!        SEL0
LCDVo=\$20!             P1.5
!LCD timer
LCD_TIM_CTL=\$3C0!      TB0CTL
LCD_TIM_CCTLn=\$3C6!    TB0CCTL2
LCD_TIM_CCR0=\$3D2!     TB0CCR0
LCD_TIM_CCRn=\$3D6!     TB0CCR2
LCD_TIM_EX0=\$3E0!      TB0EX0


LCD_CMD_IN=\$241!
LCD_CMD_OUT=\$243!
LCD_CMD_DIR=\$245!
LCD_CMD_REN=\$247!
LCD_RS=2!               P6.1
LCD_RW=1!               P6.0
LCD_EN=4!               P6.2
LCD_CMD=7!

LCD_DB_IN=\$220!
LCD_DB_OUT=\$222!
LCD_DB_DIR=\$224!
LCD_DB_REN=\$226!
LCD_DB=\$0F!            P3.3210


!WATCHDOG timer
WDT_TIM_CTL=\$340!      TA0CTL
WDT_TIM_CCTL0=\$342!    TA0CCTL0
WDT_TIM_CCR0=\$352!     TA0CCR0
WDT_TIM_EX0=\$360!      TA0EX0
WDT_TIM_0_Vec=\$FFEA!   TA0_0_Vec

IR_IN=\$200!  
IR_OUT=\$202! 
IR_DIR=\$204! 
IR_REN=\$206! 
IR_IES=\$208!
IR_IE=\$20A!
IR_IFG=\$20C!
IR_Vec=\$FFDE!          P1 int
RC5_=RC5_!
RC5=4!                  P1.2
!IR_RC5 timer
RC5_TIM_CTL=\$380!      TA1CTL
RC5_TIM_R=\$390!        TA1R
RC5_TIM_EX0=\$3A0!      TA1EX0


I2CSM_IN=\$261!
I2CSM_OUT=\$263!
I2CSM_DIR=\$265!
I2CSM_REN=\$267!
SMSDA=4!                P8.2
SMSCL=2!                P8.1
SM_BUS=6!

I2CSMM_IN=\$261!
I2CSMM_OUT=\$263!
I2CSMM_DIR=\$265!
I2CSMM_REN=\$267!
SMMSDA=4!               P8.2
SMMSCL=2!               P8.1
SMM_BUS=6!

I2CMM_IN=\$260!
I2CMM_OUT=\$262!
I2CMM_DIR=\$264!
I2CMM_REN=\$266!
I2CMM_SEL=\$26A!        SEL0
I2CMM_Vec=\$FFBC!       UCB2_Vec
MMSDA=1!                P7.0
MMSCL=2!                P7.1
MM_BUS=3!

I2CM_IN=\$260!
I2CM_OUT=\$262!
I2CM_DIR=\$264!
I2CM_REN=\$266!
I2CM_SEL=\$26A!        SEL0
I2CM_Vec=\$FFBC!       UCB2_Vec
MSDA=1!                 P7.0
MSCL=2!                 P7.1
M_BUS=3!

I2CS_IN=\$260!
I2CS_OUT=\$262!
I2CS_DIR=\$264!
I2CS_REN=\$266!
I2CS_SEL=\$26A!        SEL0
I2CS_Vec=\$FFBC!       UCB2_Vec
SSDA=1!                 P7.0
SSCL=2!                 P7.1
S_BUS=3!

UCSWRST=1!          eUSCI Software Reset
UCTXIE=2!           eUSCI Transmit Interrupt Enable
UCRXIE=1!           eUSCI Receive Interrupt Enable
UCTXIFG=2!          eUSCI Transmit Interrupt Flag
UCRXIFG=1!          eUSCI Receive Interrupt Flag
UCTXIE0=2!          eUSCI_B Transmit Interrupt Enable
UCRXIE0=1!          eUSCI_B Receive Interrupt Enable
UCTXIFG0=2!         eUSCI_B Transmit Interrupt Flag
UCRXIFG0=1!         eUSCI_B Receive Interrupt Flag

I2CM_CTLW0=\$6C0!   USCI_B2 Control Word Register 0
I2CM_CTLW1=\$6C2!   USCI_B2 Control Word Register 1
I2CM_BRW=\$6C6!     USCI_B2 Baud Word Rate 0
I2CM_STATW=\$6C8!   USCI_B2 status word 
I2CM_TBCNT=\$6CA!   USCI_B2 byte counter threshold  
I2CM_RXBUF=\$6CC!   USCI_B2 Receive Buffer 8
I2CM_TXBUF=\$6CE!   USCI_B2 Transmit Buffer 8
I2CM_I2COA0=\$6D4!  USCI_B2 I2C Own Address 0
I2CM_ADDRX=\$6DC!   USCI_B2 Received Address Register 
I2CM_I2CSA=\$6E0!   USCI_B2 I2C Slave Address
I2CM_IE=\$6EA!      USCI_B2 Interrupt Enable
I2CM_IFG=\$6EC!     USCI_B2 Interrupt Flags Register

I2CS_CTLW0=\$6C0!   USCI_B2 Control Word Register 0
I2CS_CTLW1=\$6C2!   USCI_B2 Control Word Register 1
I2CS_BRW=\$6C6!     USCI_B2 Baud Word Rate 0
I2CS_STATW=\$6C8!   USCI_B2 status word 
I2CS_TBCNT=\$6CA!   USCI_B2 byte counter threshold  
I2CS_RXBUF=\$6CC!   USCI_B2 Receive Buffer 8
I2CS_TXBUF=\$6CE!   USCI_B2 Transmit Buffer 8
I2CS_I2COA0=\$6D4!  USCI_B2 I2C Own Address 0
I2CS_ADDRX=\$6DC!   USCI_B2 Received Address Register 
I2CS_I2CSA=\$6E0!   USCI_B2 I2C Slave Address
I2CS_IE=\$6EA!      USCI_B2 Interrupt Enable
I2CS_IFG=\$6EC!     USCI_B2 Interrupt Flags Register
