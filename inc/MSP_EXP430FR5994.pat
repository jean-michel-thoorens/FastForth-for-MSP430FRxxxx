
@set-syntax{C;\;}!  replace ! by semicolon

; MSP_EXP430FR5994.pat

\.f=\.4th for MSP_EXP430FR5994;      to change file type

; ========================
; remove comments
; ========================
\\*\n=
\s\\*\n=\n

; ======================================================================
; MSP430FR5994 Config
; ======================================================================

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR5994.pat;}}}

; ======================================================================
; MSP_EXP430FR5994 board
; ======================================================================

; J101 Target     <---> eZ-FET
; GND             14-13   GND
; +5V             12-11
; 3V3             10-9
; P2.1 UCA0_RX     8-7         <---- TX   UARTtoUSB bridge
;                                +--4k7-< DeepRST <-- GND
;                                |
; P2.0 UCA0_TX     6-5         <-+-> RX   UARTtoUSB bridge
; /RST             4-3
; TEST             2-1


; P5.6    - sw1                <--- LCD contrast + (finger :-)
; P5.5    - sw2                <--- LCD contrast - (finger ;-)
; RST     - sw3

; P1.0    - led1 red
; P1.1    - led2 green

; J1 - left ext.
; 3v3
; P1.2/TA1.1/TA0CLK/COUT/A2/C2 <--- OUT IR_Receiver (1 TSOP32236)
; P6.1/UCA3RXD/UCA3SOMI        ------------------------->  4 LCD_RS
; P6.0/UCA3TXD/UCA3SIMO        ------------------------->  5 LCD_R/W
; P6.2/UCA3CLK                 ------------------------->  6 LCD_EN0
; P1.3/TA1.2/UCB0STE/A3/C3
; P5.2/UCB1CLK/TA4CLK
; P6.3/UCA3STE
; P7.1/UCB2SOMI/UCB2SCL        ---> SCL I2C MASTER/SLAVE
; P7.0/UCB2SIMO/UCB2SDA        <--> SDA I2C MASTER/SLAVE

; J3 - left int.
; 5V
; GND
; P3.0/A12/C12                 <------------------------> 11 LCD_DB4
; P3.1/A13/C13                 <------------------------> 12 LCD_DB5
; P3.2/A14/C14                 <------------------------> 13 LCD_DB5
; P3.3/A15/C15                 <------------------------> 14 LCD_DB7
; P1.4/TB0.1/UCA0STE/A4/C4
; P1.5/TB0.2/UCA0CLK/A5/C5     >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
; P4.7
; P8.0

; J4 - right int.
; P3.7/TB0.6
; P3.6/TB0.5
; P3.5/TB0.4/COUT
; P3.4/TB0.3/SMCLK
; P7.3/UCB2STE/TA4.1
; P2.6/TB0.1/UCA1RXD/UCA1SOMI
; P2.5/TB0.0/UCA1TXD/UCA1SIMO
; P4.3/A11
; P4.2/A10       RTS ----> CTS  UARTtoUSB bridge (optional hardware control flow)
; P4.1/A9        CTS <---- RTS  UARTtoUSB bridge (optional hardware control flow)

; J2 - right ext.
; GND
; P5.7/UCA2STE/TA4.1/MCLK
; P4.4/TB0.5
; P5.3/UCB1STE
; /RST
; P5.0/UCB1SIMO/UCB1SDA
; P5.1/UCB1SOMI/UCB1SCL
; P8.3
; P8.2                          <--> SDA I2C SOFTWARE MASTER
; P8.1                          <--> SCL I2C SOFTWARE MASTER


; SD_CARD
; P7.2/UCB2CLK                        <--- SD_CD
; P1.6/TB0.3/UCB0SIMO/UCB0SDA/TA0.0   ---> SD_MOSI
; P1.7/TB0.4/UCB0SOMI/UCB0SCL/TA1.0   <--- SD_MISO
; P4.0/A8                             ---> SD_CS
; P2.2/TB0.2/UCB0CLK                  ---> SD_CLK



; XTAL LF 32768 Hz
; PJ.4/LFXIN
; PJ.5/LFXOUT

; XTAL HF
; PJ.6/HFXIN
; PJ.7/HFXOUT

; -----------------------------------------------
; LCD config
; -----------------------------------------------

;       <-------+---0V0---------->  1 LCD_Vss
;       >------ | --3V6-----+---->  2 LCD_Vdd
;               |           |
;             |___    470n ---
;               ^ |        ---
;              / \ BAT54    |
;              ---          |
;          100n |    2k2    |
; TB0.2 >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
;       ------------------------->  4 LCD_RS
;       ------------------------->  5 LCD_R/W
;       ------------------------->  6 LCD_EN0
;       <------------------------> 11 LCD_DB4
;       <------------------------> 12 LCD_DB5
;       <------------------------> 13 LCD_DB5
;       <------------------------> 14 LCD_DB7




; FFB4-FFFF 37 vectors + reset
; 0FFB4h - LEA_Vec        
; 0FFB6h - P8_Vec         
; 0FFB8h - P7_Vec         
; 0FFBAh - eUSCI_B3_Vec   
; 0FFBCh - eUSCI_B2_Vec   
; 0FFBEh - eUSCI_B1_Vec   
; 0FFC0h - eUSCI_A3_Vec   
; 0FFC2h - eUSCI_A2_Vec   
; 0FFC4h - P6_Vec         
; 0FFC6h - P5_Vec         
; 0FFC8h - TA4_x_Vec      
; 0FFCAh - TA4_0_Vec      
; 0FFCCh - AES_Vec        
; 0FFCEh - RTC_C_Vec      
; 0FFD0h - P4_Vec=        
; 0FFD2h - P3_Vec=        
; 0FFD4h - TA3_x_Vec      
; 0FFD6h - TA3_0_Vec      
; 0FFD8h - P2_Vec         
; 0FFDAh - TA2_x_Vec      
; 0FFDCh - TA2_0_Vec      
; 0FFDEh - P1_Vec=        
; 0FFE0h - TA1_x_Vec      
; 0FFE2h - TA1_0_Vec      
; 0FFE4h - DMA_Vec        
; 0FFE6h - eUSCI_A1_Vec   
; 0FFE8h - TA0_x_Vec      
; 0FFEAh - TA0_0_Vec      
; 0FFECh - ADC12_B_Vec    
; 0FFEEh - eUSCI_B0_Vec   
; 0FFF0h - eUSCI_A0_Vec   
; 0FFF2h - WDT_Vec        
; 0FFF4h - TB0_x_Vec      
; 0FFF6h - TB0_0_Vec      
; 0FFF8h - COMP_E_Vec     
; 0FFFAh - U_NMI_Vec      
; 0FFFCh - S_NMI_Vec      
; 0FFFEh - RST_Vec        


; ----------------------------------------------------------------------
; MSP430FR5994 Peripheral File Map
; ----------------------------------------------------------------------
;SFR_SFR         .equ 0100h           ; Special function
;PMM_SFR         .equ 0120h           ; PMM
;FRAM_SFR        .equ 0140h           ; FRAM control
;CRC16_SFR       .equ 0150h
;RAM_SFR         .equ 0158h
;WDT_A_SFR       .equ 015Ch           ; Watchdog
;CS_SFR          .equ 0160h           ; Clock System
;SYS_SFR         .equ 0180h           ; SYS
;REF_SFR         .equ 01B0h           ; REF
;PA_SFR          .equ 0200h           ; PORT1/2
;PB_SFR          .equ 0220h           ; PORT3/4
;PC_SFR          .equ 0240h           ; PORT3/4
;PD_SFR          .equ 0260h           ; PORT3/4
;PJ_SFR          .equ 0320h           ; PORTJ
;TA0_SFR         .equ 0340h
;TA1_SFR         .equ 0380h
;TB0_SFR         .equ 03C0h
;TA2_SFR         .equ 0400h
;CTIO0_SFR       .equ 0430h           ; Capacitive Touch IO
;TA3_SFR         .equ 0440h
;CTIO1_SFR       .equ 0470h           ; Capacitive Touch IO
;RTC_C_SFR       .equ 04A0h
;MPY_SFR         .equ 04C0h
;DMA_CTRL_SFR    .equ 0500h
;DMA_CHN0_SFR    .equ 0510h
;DMA_CHN1_SFR    .equ 0520h
;DMA_CHN2_SFR    .equ 0530h
;DMA_CHN3_SFR    .equ 0540h
;DMA_CHN4_SFR    .equ 0550h
;DMA_CHN5_SFR    .equ 0560h
;MPU_SFR         .equ 05A0h           ; memory protect unit
;eUSCI_A0_SFR    .equ 05C0h           ; eUSCI_A0
;eUSCI_A1_SFR    .equ 05E0h           ; eUSCI_A1
;eUSCI_A2_SFR    .equ 0600h           ; eUSCI_A1
;eUSCI_A3_SFR    .equ 0620h           ; eUSCI_A1
;eUSCI_B0_SFR    .equ 0640h           ; eUSCI_B0
;eUSCI_B1_SFR    .equ 0680h           ; eUSCI_B1
;eUSCI_B2_SFR    .equ 06C0h           ; eUSCI_B2
;eUSCI_B3_SFR    .equ 0700h           ; eUSCI_B3
;TA4_SFR         .equ 07C0h
;ADC12_B_SFR     .equ 0800h
;COMP_E_SFR      .equ 08C0h
;CRC32_SFR       .equ 0980h
;AES_SFR         .equ 09C0h
;LEA_SFR         .equ 0A80h

; ============================================
; FAST FORTH configuration :
; ============================================
BUS_TERM=3;         ; P2.0 = TX, P2.1 = RX

TERM_VEC=\$FFF0;    \ UCA0
UCSWRST=1;          eUSCI Software Reset
WAKE_UP=1;          \ RX int
RX=1;               RX flag IFG
TX=2;               Tx flag IFG

TERM_IN=\$201;
TERM_REN=\$207;
TERM_SEL=\$20D;     ; SEL1

TERM_CTLW0=\$5C0;    \ eUSCI_A0 control word 0
TERM_CTLW1=\$5C2;    \ eUSCI_A0 control word 1
TERM_BRW=\$5C6;
TERM_BR0=\$5C6;      \ eUSCI_A0 baud rate 0
TERM_BR1=\$5C7;      \ eUSCI_A0 baud rate 1
TERM_MCTLW=\$5C8;    \ eUSCI_A0 modulation control
TERM_STATW=\$5CA;    \ eUSCI_A0 status
TERM_RXBUF=\$5CC;    \ eUSCI_A0 receive buffer
TERM_TXBUF=\$5CE;    \ eUSCI_A0 transmit buffer
TERM_IE=\$5DA;       \ eUSCI_A0 interrupt enable
TERM_IFG=\$5DC;      \ eUSCI_A0 interrupt flags
TERM_IV=\$5DE;       \ eUSCI_A0 interrupt vector word

RTS=4;              ; P4.2
CTS=2;              ; P4.1
HANDSHAKIN=\$221;
HANDSHAKOUT=\$223;

CD_SD=4;            ; P7.2 as Card Detect
SD_CDIN=\$260;

CS_SD=1;            ; P4.0 as Card Select
SD_CSOUT=\$223;
SD_CSDIR=\$225;

SD_SEL1=\$20C;      ; word access, to configure UCB0
SD_REN=\$206;       ; word access, to configure pullup resistors
BUS_SD=\$04C0;      ; pins P2.2 as UCB0CLK, P1.6 as UCB0SIMO & P1.7 as UCB0SOMI

SD_CTLW0=\$640;    \ eUSCI_B0 control word 0
SD_CTLW1=\$642;    \ eUSCI_B0 control word 1
SD_BRW=\$646;
SD_BR0=\$646;      \ eUSCI_B0 bit rate 0
SD_BR1=\$647;      \ eUSCI_B0 bit rate 1
SD_STATW=\$648;    \ eUSCI_B0 status word
SD_NT0=\$649;      \ eUSCI_B0 hardware count
SD_TBCNT=\$64A;    \ eUSCI_B0 byte counter threshold
SD_RXBUF=\$64C;    \ eUSCI_B0 receive buffer
SD_TXBUF=\$64E;    \ eUSCI_B0 transmit buffer
SD_I2COA0=\$654;   \ eUSCI_B0 I2C own address 0
SD_I2COA1=\$656;   \ eUSCI_B0 I2C own address 1
SD_I2COA2=\$658;   \ eUSCI_B0 I2C own address 2
SD_I2COA3=\$65A;   \ eUSCI_B0 I2C own address 3
SD_ADDRX=\$65C;    \ eUSCI_B0 received address
SD_ADDMASK=\$65E;  \ eUSCI_B0 address mask
SD_I2CSA=\$660;    \ eUSCI_B0 I2C slave address
SD_IE=\$66A;       \ eUSCI_B0 interrupt enable
SD_IFG=\$66C;      \ eUSCI_B0 interrupt flags
SD_IV=\$66E;       \ eUSCI_B0 interrupt vector word


LFXT_OUT=\$322;          PJ
LFXT_DIR=\$324;          PJ
LFXT_SEL=\$32A;          PJSEL0
LFXIN=\$10;              PJ.4
LFXOUT=\$20;             PJ.5  

; FAST FORTH I/O :
LED1_OUT=\$202;
LED1_DIR=\$204;
LED1=1;                 P1.0
LED2_OUT=\$202;
LED2_DIR=\$204;
LED2=2;                 P1.1

SW1_IN=\$240;
SW1=\$40;               P5.6
SW2_IN=\$240;
SW2=\$20;               P5.5

; ============================================
; UARTI2CS APPLICATION
; ============================================
;I2C_Soft_Master
I2CSM_IN=\$261;
I2CSM_OUT=\$263;
I2CSM_DIR=\$265;
I2CSM_REN=\$267;
SM_SDA=4;               P8.2
SM_SCL=2;               P8.1
SM_BUS=6;

;500_ms_INT TIMER
TIM_CTL=\$3C0;          TB0
TIM_CCTL2=\$3C6;
TIM_CCR0=\$3D2;
TIM_CCR2=\$3D6;
T_OUT2=\$20;            P1.5 <--- TB0.2
T_OUT2_DIR=\$204;       P1DIR
T_OUT2_SEL=\$20C;       P1SEL1
INT_IN=\$10;            P1.4
INT_IN_IE=\$21A;        P1IE
INT_IN_IFG=\$21C;       P1IFG
INT_IN_VEC=\$FFDE;      P1VEC

;local variables
OLD_STOP_APP=\{UARTI2CS\};
OLD_HARD_APP=\{UARTI2CS\}\+2;
OLD_BACKGRND_APP=\{UARTI2CS\}\+4;
OLD_TERM_VEC=\{UARTI2CS\}+6;     <-- TERM_VEC
OLD_INT_IN_VEC=\{UARTI2CS\}+8;   <-- INT_IN_VEC
UARTI2CS_ADR=\{UARTI2CS\}\+10;  <-- I2C_Slave_Addr<<1
TIMER_CONF=\{UARTI2CS\}\+12;    <-- TIM_CTL configuration
COLLISION_DLY=\{UARTI2CS\}\+14; <-- 20 us resolution delay after I2C collision
DUPLEX_MODE=\{UARTI2CS\}\+15;   <-- flag = 4 --> NOECHO, <> 4 --> ECHO, -1 = I2C link lost

; ============================================
; RC5toLCD APPLICATION
; ============================================
LCDVo_DIR=\$204;
LCDVo_SEL=\$20A;        SEL0
LCDVo=\$20;             P1.5
;LCD timer
LCD_TIM_CTL=\$3C0;      TB0CTL
LCD_TIM_CCTLn=\$3C6;    TB0CCTL2
LCD_TIM_CCR0=\$3D2;     TB0CCR0
LCD_TIM_CCRn=\$3D6;     TB0CCR2
LCD_TIM_EX0=\$3E0;      TB0EX0
;LCD command bus
LCD_CMD_IN=\$241;
LCD_CMD_OUT=\$243;
LCD_CMD_DIR=\$245;
LCD_CMD_REN=\$247;
LCD_RS=2;               P6.1
LCD_RW=1;               P6.0
LCD_EN=4;               P6.2
LCD_CMD=7;
;LCD data bus
LCD_DB_IN=\$220;
LCD_DB_OUT=\$222;
LCD_DB_DIR=\$224;
LCD_DB_REN=\$226;
LCD_DB=\$0F;            P3.3210
;WATCHDOG timer
WDT_TIM_CTL=\$340;      TA0CTL
WDT_TIM_CCTL0=\$342;    TA0CCTL0
WDT_TIM_CCR0=\$352;     TA0CCR0
WDT_TIM_EX0=\$360;      TA0EX0
WDT_TIM_0_VEC=\$FFEA;   TA0_0_VEC
;IR_RC5
IR_IN=\$200;
IR_OUT=\$202;
IR_DIR=\$204;
IR_REN=\$206;
IR_IES=\$208;
IR_IE=\$20A;
IR_IFG=\$20C;
IR_VEC=\$FFDE;          P1 int
RC5_=RC5_;
RC5=4;                  P1.2
;IR_RC5 timer
RC5_TIM_CTL=\$380;      TA1CTL
RC5_TIM_R=\$390;        TA1R
RC5_TIM_EX0=\$3A0;      TA1EX0
; --------------------------------------------

I2CSMM_IN=\$261;
I2CSMM_OUT=\$263;
I2CSMM_DIR=\$265;
I2CSMM_REN=\$267;
SMM_SDA=4;               P8.2
SMM_SCL=2;               P8.1
SMM_BUS=6;

I2CMM_IN=\$260;
I2CMM_OUT=\$262;
I2CMM_DIR=\$264;
I2CMM_REN=\$266;
I2CMM_SEL=\$26A;        SEL0
I2CMM_VEC=\$FFBC;       UCB2_VEC
MM_SDA=1;                P7.0
MM_SCL=2;                P7.1
MM_BUS=3;

I2CM_IN=\$260;
I2CM_OUT=\$262;
I2CM_DIR=\$264;
I2CM_REN=\$266;
I2CM_SEL=\$26A;        SEL0
I2CM_VEC=\$FFBC;       UCB2_VEC
M_SDA=1;                 P7.0
M_SCL=2;                 P7.1
M_BUS=3;

I2CS_IN=\$260;
I2CS_OUT=\$262;
I2CS_DIR=\$264;
I2CS_REN=\$266;
I2CS_SEL=\$26A;        SEL0
I2CS_VEC=\$FFBC;       UCB2_VEC
S_SDA=1;                 P7.0
S_SCL=2;                 P7.1
S_BUS=3;

I2CM_CTLW0=\$6C0;   USCI_B2 Control Word Register 0
I2CM_CTLW1=\$6C2;   USCI_B2 Control Word Register 1
I2CM_BRW=\$6C6;     USCI_B2 Baud Word Rate 0
I2CM_STATW=\$6C8;   USCI_B2 status word
I2CM_TBCNT=\$6CA;   USCI_B2 byte counter threshold
I2CM_RXBUF=\$6CC;   USCI_B2 Receive Buffer 8
I2CM_TXBUF=\$6CE;   USCI_B2 Transmit Buffer 8
I2CM_I2COA0=\$6D4;  USCI_B2 I2C Own Address 0
I2CM_ADDRX=\$6DC;   USCI_B2 Received Address Register
I2CM_I2CSA=\$6E0;   USCI_B2 I2C Slave Address
I2CM_IE=\$6EA;      USCI_B2 Interrupt Enable
I2CM_IFG=\$6EC;     USCI_B2 Interrupt Flags Register

I2CS_CTLW0=\$6C0;   USCI_B2 Control Word Register 0
I2CS_CTLW1=\$6C2;   USCI_B2 Control Word Register 1
I2CS_BRW=\$6C6;     USCI_B2 Baud Word Rate 0
I2CS_STATW=\$6C8;   USCI_B2 status word
I2CS_TBCNT=\$6CA;   USCI_B2 byte counter threshold
I2CS_RXBUF=\$6CC;   USCI_B2 Receive Buffer 8
I2CS_TXBUF=\$6CE;   USCI_B2 Transmit Buffer 8
I2CS_I2COA0=\$6D4;  USCI_B2 I2C Own Address 0
I2CS_ADDRX=\$6DC;   USCI_B2 Received Address Register
I2CS_I2CSA=\$6E0;   USCI_B2 I2C Slave Address
I2CS_IE=\$6EA;      USCI_B2 Interrupt Enable
I2CS_IFG=\$6EC;     USCI_B2 Interrupt Flags Register
