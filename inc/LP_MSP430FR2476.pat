! -*- coding: utf-8 -*-
! LP_MSP430FR2476.pat
!
\.f=\.4th for LP_MSP430FR2476!      to change file type
!
!========================
! remove comments        
!========================
\\*\n=
\s\\*\n=\n
! ======================================================================
! LP_MSP430FR2476 Config
! ======================================================================
@define{@read{@mergepath{@inpath{};MSP430FR2476.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}


! ======================================================================
! LP_MSP430FR2476 board
! ======================================================================
!
! ===================================================================================
! in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
! ===================================================================================
!                    
!     J101 Target    J101    eZ-FET             UARTtoUSB
!
!            DVSS 14 o--o 13 GND  
!             5V0 12 o--o 11 5V0
!            DVCC 10 o--o 9  3V3
!    P1.5 UCA0_RX  8 o--o 7  <------------ TX   UARTtoUSB
!    P1.4 UCA0_TX  6 o--o 5  <---------+-> RX   UARTtoUSB
!     SBWTDIO/RST  4 o--o 3            |         _   
!      SBWTCK/TST  2 o--o 1            +--4k7---o o-- GND
!                                             DeepRST
! J1 - left ext.
! 3v3
! P1.6/UCA0CLK/TA1CLK/TDI/TCLK/A6     
! P2.5/UCA1RXD/UCA1SOMI/CAP1.2
! P2.6/UCA1TXD/UCA1SIMO/CAP1.3
! P2.2/SYNC/ACLK/COMP0.1
! P5.4/UCB1STE/TA3CLK/A11            
! P3.5/UCB1CLK/TB0TRG/CAP3.1
! P4.5/UCB0SOMI/UCB0SCL/TA3.2         
! P1.3/UCB0SOMI/UCB0SCL/MCLK/A3
! P1.2/UCB0SIMO/UCB0SDA/TA0.2/A2/VEREF-
!
!
! J3 - left int.
! 5V
! GND
! P1.7/UCA0STE/SMCLK/TDO/A7
! P4.3/UCB1SOMI/UCB1SCL/TB0.5/A8
! P4.4/UCB1SIMO/UCB1SDA/TB0.6/A9
! P5.3/UCB1CLK/TA3.0/A10                      
! P1.0/UCB0STE/TA0CLK/A0/VEREF+     - J7 - LED1
! P1.1/UCB0CLK/TA0.1/COMP0.0/A1     - TEMPERATURE SENSOR
! P5.7/TA2.1/COMP0.2 
! P3.7/TA3.2/CAP2.0
!
! J4 - right int.
! P5.2/UCA0TXD/UCA0SIMO/TB0.4                       
! P5.1/UCA0RXD/UCA0SOMI/TB0.3       - J8 - LED2R          
! P5.0/UCA0CLK/TB0.2                - J8 - LED2G
! P4.7/UCA0STE/TB0.1                - J8 - LED2B
! P6.0/TA2.2/COMP0.3
! P3.3/TA2.1/CAP0.1
! P6.1/TB0CLK
! P6.2/TB0.0
! P4.1/TA3.0/CAP2.2
! P3.1/UCA1STE/CAP1.0
!
! J2 - right ext.
! GND
! P4.6/UCB0SIMO/UCB0SDA/TA3.1
! P2.1/XIN
! P2.0/XOUT
! /RST
! P3.2/UCB1SIMO/UCB1SDA/CAP3.2
! P3.6/UCB1SOMI/UCB1SCL/CAP3.3
! P4.2/TA3CLK/CAP2.3
! P2.7/UCB1STE/CAP3.0
! P2.4/UCA1CLK/CAP1.1
!
! switch-keys:
! P4.0/TA3.1/CAP2.1                 - S1 
! P2.3/TA2.0/CAP0.2                 - S2 
! /RST                              - S3
!
! XTAL LF 32768 Hz
! P2.0/XOUT
! P2.1/XIN
!
!
! Clocks:
! 8 MHz DCO intern
!
!
!
! ===================================================================================
! in case of 3.3V powered by UARTtoUSB bridge, open J13 straps {RST,TST,V+,5V} BEFORE
! ===================================================================================
!
! -----------------------------------------------
! MSP430FR5969        LAUNCHPAD <--> OUTPUT WORLD
! -----------------------------------------------
!
! ----------------------------------------
! Temperature sensor : jumper J9 removed !
! ----------------------------------------
!
! P4.0 - Switch S1             <--- LCD contrast + (finger :-)
! P2.3 - Switch S2             <--- LCD contrast - (finger ;-)
!                                  
!  GND -                       <-------+---0V0---------->  1 LCD_Vss
!  VCC -                       >------ | --3V6-----+---->  2 LCD_Vdd
!                                      |           |
!                                    |___    470n ---
!                                      ^ |        ---
!                                     / \ BAT54    |
!                                     ---          |
!                                 100n |    2k2    |
! P4.7 - TB0.1          J4     >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
! P5.0 -                J4     ----------orange--------->  4 LCD_RS
! P5.1 -                J4     ----------blue----------->  5 LCD_R/W
! P5.2 -                J4     ----------black---------->  6 LCD_EN
! P1.0 -                J3     <---------brown----------> 11 LCD_DB4
! P1.1 -                J3     <---------red------------> 12 LCD_DB5
! P1.2 -                J1     <---------orange---------> 13 LCD_DB5
! P1.3 -                J1     <---------yellow---------> 14 LCD_DB7
!        
!                                +--4k7-< DeepRST <-- GND 
!                                |
! P1.4 - UCA0 TXD      J101.8  <-+->white--> RX   UARTtoUSB bridge
! P1.5 - UCA0 RXD      J101.10 <----green--- TX   UARTtoUSB bridge
!  VCC -               J101.16 <---- VCC  (optional supply from UARTtoUSB bridge - WARNING ! 3.3V !)
!  GND -               J101.20 <---> GND
! P6.1 - RTS           J4      ----blue----> CTS  UARTtoUSB bridge (optional hardware control flow)
! P6.2 - CTS           J4      ---yellow---> RTS  UARTtoUSB bridge (optional hardware control flow)
!        
!
!  VCC -                       ----> VCC  SD_CardAdapter
!  GND -                       <---> GND  SD_CardAdapter
! P2.4 - UCA1 CLK       J2     ----> CLK  SD_CardAdapter (SCK)  
! P2.6 - UCA1 TXD/SIMO  J1     ----> SDI  SD_CardAdapter (MOSI)
! P2.5 - UCA1 RXD/SOMI  J1     <---- SDO  SD_CardAdapter (MISO)
! P1.6 -                J4     ----> CS   SD_CardAdapter (Card Select)
! P1.7 -                J4     <---- CD   SD_CardAdapter (Card Detect)
!                                                                   
!
! P2.2 -                J3.10  <---- OUT  IR_Receiver (1 TSOP32236) ───┐
!                                                                      └┌───┐
!  VCC -                       ----> VCC  IR_Receiver (2 TSOP32236) ────| O |
!                                                                      ┌└───┘
!  GND -                       <---> GND  IR_Receiver (3 TSOP32236) ───┘
!
! P4.3 - UCB1 SCL/SOMI  J3     ----> SCL  I2C MASTER/SLAVE
! P4.4 - UCB1 SDA/SIMO  J3     <---> SDA  I2C MASTER/SLAVE

! P3.3 -                J4     ----> SCL  SOFTWARE I2C MASTER
! P3.2 -                J2     <---> SDA  SOFTWARE I2C MASTER



! ============================================
! FORTH I/O :
! ============================================
!TERMINAL 
BUS_TERM=\$30!      ; P1.4 = TX, P1.5 = RX

TERM_IN=\$200!
TERM_REN=\$206!
TERM_SEL=\$20A!     \SEL0

TERM_VEC=\$FFE4!    \ UCA0
WAKE_UP=1!          \ RX int

TERM_CTLW0=\$500!   \ eUSCI_A control word 0        
TERM_CTLW1=\$502!   \ eUSCI_A control word 1        
TERM_BRW=\$506!         
TERM_BR0=\$506!     \ eUSCI_A baud rate 0           
TERM_BR1=\$507!     \ eUSCI_A baud rate 1           
TERM_MCTLW=\$508!   \ eUSCI_A modulation control    
TERM_STATW=\$50A!   \ eUSCI_A status                
TERM_RXBUF=\$50C!   \ eUSCI_A receive buffer        
TERM_TXBUF=\$50E!   \ eUSCI_A transmit buffer       
TERM_ABCTL=\$510!   \ eUSCI_A LIN control           
TERM_IRTCTL=\$512!  \ eUSCI_A IrDA transmit control 
TERM_IRRCTL=\$513!  \ eUSCI_A IrDA receive control  
TERM_IE=\$51A!      \ eUSCI_A interrupt enable      
TERM_IFG=\$51C!     \ eUSCI_A interrupt flags       
TERM_IV=\$51E!      \ eUSCI_A interrupt vector word 

RTS=2!                  P6.1
CTS=4!                  P6.2
HANDSHAKIN=\$241!
HANDSHAKOUT=\$243!

CD_SD=\$80!             P1.7 as Card Detect
SD_CDIN=\$200!

CS_SD=\$40!             P1.6 as Card Select     
SD_CSOUT=\$202!
SD_CSDIR=\$204!

BUS_SD=\$7000!          pins P2.4 as UCA1CLK, P2.6 as UCA1SIMO & P2.5 as UCA1SOMI
SD_SEL=\$20A!           PASEL0 to configure UCA1
SD_REN=\$206!           PAREN to configure pullup resistors

! ============================================
! APPLICATION I/O :
! ============================================
LED2_OUT=\$202!
LED2_DIR=\$204!
LED2=1!                 P1.0 green led

LED1_OUT=\$242!
LED1_DIR=\$244!
LED1=2!                 P5.1 red led

SW1_IN=\$221!
SW1=1!                  P4.0 = S1 
WIPE_IN\$221!
IO_WIPE=1!              P4.0 = S1 = FORTH Deep_RST pin

SW2_IN=\$201!
SW2=8!                  P2.3 S2


!LCD_Vo PWM
LCDVo_DIR=\$225!        P4
LCDVo_SEL=\$22D!        SEL1
LCDVo=\$80!             P4.7 as TB0.1
!LCD command bus
LCD_CMD_IN=\$240!       P5
LCD_CMD_OUT=\$242
LCD_CMD_DIR=\$244
LCD_CMD_REN=\$246
LCD_RS=1!               P5.0
LCD_RW=2!               P5.1
LCD_EN=4!               P5.2
LCD_CMD=\$32!
!LCD data bus
LCD_DB_IN=\$200!        P1
LCD_DB_OUT=\$202!
LCD_DB_DIR=\$204!
LCD_DB_REN=\$206!
LCD_DB=\$0F!            P1.3210
!LCD timer
LCD_TIM_CTL=\$480!      TB0CTL
LCD_TIM_CCTLn=\$484!    TB0CCTL1
LCD_TIM_CCR0=\$492!     TB0CCR0
LCD_TIM_CCRn=\$494!     TB0CCR1
LCD_TIM_EX0=\$4A0!      TB0EX0


!WATCHDOG timer
WDT_TIM_CTL=\$380!      TA0CTL
WDT_TIM_CCTL0=\$382!    TA0CCTL0
WDT_TIM_CCR0=\$392!     TA0CCR0
WDT_TIM_EX0=\$3A0!      TA0EX0
WDT_TIM_0_VEC=\$FFF8!   TA0_0_VEC


!IR_RC5
RC5_=RC5_!
IR_IN=\$201!  
IR_OUT=\$203! 
IR_DIR=\$205! 
IR_REN=\$209! 
IR_IES=\$219!
IR_IE=\$21B!
IR_IFG=\$21D!
IR_VEC=\$FFD4!          P2 int
RC5=4!                  P2.2
!IR_RC5 timer
RC5_TIM_CTL=\$3C0!       TA1CTL
RC5_TIM_R=\$3D0!         TA1R
RC5_TIM_EX0=\$3E0!       TA1EX0

!Software I2C_Master
I2CSM_IN=\$220!
I2CSM_OUT=\$222!
I2CSM_DIR=\$224!
I2CSM_REN=\$226!
SMSDA=4!                P3.2
SMSCL=8!                P3.3
SM_BUS=\$0C!    

!Software I2C_Multi_Master
I2CSMM_IN=\$220!
I2CSMM_OUT=\$222!
I2CSMM_DIR=\$224!
I2CSMM_REN=\$226!
SMMSDA=4!               P3.2
SMMSCL=8!               P3.3
SMM_BUS=\$0C!    

!hardware I2C_Multi_Master
I2CMM_IN=\$221!
I2CMM_OUT=\$223!
I2CMM_DIR=\$225!
I2CMM_REN=\$227!
I2CMM_SEL=\$22B!        SEL0
I2CMM_VEC=\$FFDA!       UCB1
MMSCL=8!                P4.3
MMSDA=\$10!             P4.4
MM_BUS=\$18!

!hardware I2C_Master
I2CM_IN=\$221!
I2CM_OUT=\$223!
I2CM_DIR=\$225!
I2CM_REN=\$227!
I2CM_SEL=\$22B!         SEL0
I2CM_VEC=\$FFDA!        UCB1
MSCL=8!                 P4.3
MSDA=\$10!              P4.4
M_BUS=\$18!

!hardware I2C_Slave
I2CS_IN=\$221!
I2CS_OUT=\$223!
I2CS_DIR=\$225!
I2CS_REN=\$227!
I2CS_SEL=\$22B!         SEL0
I2CS_VEC=\$FFDA!        UCB1
SSCL=8!                 P4.3
SSDA=\$10!              P4.4
S_BUS=\$18!

UCSWRST=1!          eUSCI Software Reset
UCTXIE=2!           eUSCI Transmit Interrupt Enable
UCRXIE=1!           eUSCI Receive Interrupt Enable
UCTXIFG=2!          eUSCI Transmit Interrupt Flag
UCRXIFG=1!          eUSCI Receive Interrupt Flag
UCTXIE0=2!          eUSCI_B Transmit Interrupt Enable
UCRXIE0=1!          eUSCI_B Receive Interrupt Enable
UCTXIFG0=2!         eUSCI_B Transmit Interrupt Flag
UCRXIFG0=1!         eUSCI_B Receive Interrupt Flag

I2CM_CTLW0=\$580!   USCI_B1 Control Word Register 0
I2CM_CTLW1=\$582!   USCI_B1 Control Word Register 1
I2CM_BRW=\$586!     USCI_B1 Baud Word Rate 0
I2CM_STATW=\$588!   USCI_B1 status word 
I2CM_TBCNT=\$58A!   USCI_B1 byte counter threshold  
I2CM_RXBUF=\$58C!   USCI_B1 Receive Buffer 8
I2CM_TXBUF=\$58E!   USCI_B1 Transmit Buffer 8
I2CM_I2COA0=\$594!  USCI_B1 I2C Own Address 0
I2CM_ADDRX=\$59C!   USCI_B1 Received Address Register 
I2CM_I2CSA=\$5A0!   USCI_B1 I2C Slave Address
I2CM_IE=\$5AA!      USCI_B1 Interrupt Enable
I2CM_IFG=\$5AC!     USCI_B1 Interrupt Flags Register

I2CS_CTLW0=\$580!   USCI_B1 Control Word Register 0
I2CS_CTLW1=\$582!   USCI_B1 Control Word Register 1
I2CS_BRW=\$586!     USCI_B1 Baud Word Rate 0
I2CS_STATW=\$588!   USCI_B1 status word 
I2CS_TBCNT=\$58A!   USCI_B1 byte counter threshold  
I2CS_RXBUF=\$58C!   USCI_B1 Receive Buffer 8
I2CS_TXBUF=\$58E!   USCI_B1 Transmit Buffer 8
I2CS_I2COA0=\$594!  USCI_B1 I2C Own Address 0
I2CS_ADDRX=\$59C!   USCI_B1 Received Address Register 
I2CS_I2CSA=\$5A0!   USCI_B1 I2C Slave Address
I2CS_IE=\$5AA!      USCI_B1 Interrupt Enable
I2CS_IFG=\$5AC!     USCI_B1 Interrupt Flags Register

