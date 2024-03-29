
@set-syntax{C;\;}!  replace ! by semicolon

;MSP430fr6989.pat

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FRxxxx.pat;}}}

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};MSP430FR5xxx.pat;}}}

@reset-syntax{}; to enable good interpreting of next line
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}

; ----------------------------------------------
; MSP430FR6989 MEMORY MAP
; ----------------------------------------------
; 0000-0005 = reserved ROM
; 0006-001F = tiny RAM 26 bytes
; 0020-0FFF = peripherals (4 KB)
; 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
; 1800-19FF = FRAM INFO  512 B
; 1A00-1AFF = TLV device descriptor info (FRAM 256 B)
; 1B00-1BFF = ROM boot memory
; 1C00-23FF = RAM (2 KB)
; 4400-FF7F = code memory (FRAM 48 kB)
; FF80-FFFF = interrupt vectors (FRAM 127 B)
; ----------------------------------------------


; ============================================
; TINY RAM
; ============================================
TinyRAM_ORG=\$06;
TinyRAM_LEN=\$20;

; ============================================
; BSL
; ============================================
BSL1=\$1000;

; ============================================
; FRAM INFO
; ============================================
INFO_ORG=\$1800;
INFO_LEN=\$0200;

; See MSP430FRxxxx.pat

; ============================================
; FRAM TLV
; ============================================

; See MSP430FRxxxx.pat

; ============================================
; RAM
; ============================================
RAM_ORG=\$1C00;
RAM_LEN=\$0800;

; ---------------------------------------
; FORTH RAM areas :
; ---------------------------------------

; See MSP430FR5xxx.pat

; ----------------------------------------------
; FRAM
; ----------------------------------------------
MAIN_ORG=\$4400;        Code space start
MAIN_LEN=\$24000;       127 k FRAM

; See MSP430FRxxxx.pat for other addresses

; ----------------------------------------------
; Interrupt Vectors and signatures - MSP430FR6989
; ----------------------------------------------
MAIN_LEN=\$1FC00;       127 k FRAM
FRAM_FULL=\$FF40;       64 bytes are sufficient considering what can be compiled in one line and WORD use.
SIGNATURES=\$FF80;      JTAG/BSL signatures
JTAG_SIG1=\$FF80;       if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2=\$FF82;       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84;
BSL_SIG2=\$FF86;
I2CSLA0=\$FFA2;         UCBxI2COA0 default value address
I2CSLA1=\$FFA4;         UCBxI2COA1 default value address
I2CSLA2=\$FFA6;         UCBxI2COA2 default value address
I2CSLA3=\$FFA8;         UCBxI2COA3 default value address
JTAG_PASSWORD=\$FF88;   256 bits
BSL_PASSWORD=\$FFE0;    256 bits
VECT_ORG=\$FFC6;        FFC6-FFFF
VECT_LEN=\$3A;


AES_VEC=\$FFC6;
RTC_VEC=\$FFC8;
LCD_VEC=\$FFCA;
P4_VEC=\$FFCC;
P3_VEC=\$FFCE;
TA3_X_VEC=\$FFD0;
TA3_0_VEC=\$FFD2;
P2_VEC=\$FFD4;
TA2_X_VEC=\$FFD6;
TA2_0_VEC=\$FFD8;
P1_VEC=\$FFDA;
TA1_X_VEC=\$FFDC;
TA1_0_VEC=\$FFDE;
DMA_VEC=\$FFE0;
EUSCI_B1_VEC=\$FFE2;
EUSCI_A1_VEC=\$FFE4;
TA0_X_VEC=\$FFE6;
TA0_0_VEC=\$FFE8;
ADC12_B_VEC=\$FFEA;
EUSCI_B0_VEC=\$FFEC;
EUSCI_A0_VEC=\$FFEE;
ESI_VEC=\$FFF0;
WDT_VEC=\$FFF2;
TB0_X_VEC=\$FFF4;
TB0_0_VEC=\$FFF6;
COMP_E_VEC=\$FFF8;
U_NMI_VEC=\$FFFA;
S_NMI_VEC=\$FFFC;
RST_VEC=\$FFFE;

; ============================================
; Special Fonction Registers (SFR)
; ============================================

SFRIE1=\$100;       \ SFR enable register
SFRIFG1=\$102;      \ SFR flag register
SFRRPCR=\$104;      \ SFR reset pin control

PMMCTL0=\$120;      \ PMM Control 0
PMMIFG=\$12A;       \ PMM interrupt flags
PM5CTL0=\$130;      \ PM5 Control 0

FRCTLCTL0=\$140;    \ FRAM control 0
GCCTL0=\$144;       \ General control 0
GCCTL1=\$146;       \ General control 1

CRC16DI=\$150;      \ CRC data input
CRCDIRB=\$152;      \ CRC data input reverse byte
CRCINIRES=\$154;    \ CRC initialization and result
CRCRESR=\$156;      \ CRC result reverse byte

RCCTL0=\$158;       \ RAM controller control 0

WDTCTL=\$15C;        \ WDT control register

CSCTL0=\$160;       \ CS control 0
CSCTL1=\$162;       \ CS control 1
CSCTL2=\$164;       \ CS control 2
CSCTL3=\$166;       \ CS control 3
CSCTL4=\$168;       \ CS control 4
CSCTL5=\$16A;       \ CS control 5
CSCTL6=\$16C;       \ CS control 6

SYSCTL=\$180;       \ System control
SYSJMBC=\$186;      \ JTAG mailbox control
SYSJMBI0=\$188;     \ JTAG mailbox input 0
SYSJMBI1=\$18A;     \ JTAG mailbox input 1
SYSJMBO0=\$18C;     \ JTAG mailbox output 0
SYSJMBO1=\$18E;     \ JTAG mailbox output 1
SYSUNIV=\$19A;      \ User NMI vector generator
SYSSNIV=\$19C;      \ System NMI vector generator
SYSRSTIV=\$19E;     \ Reset vector generator

REFCTL=\$1B0;       \ Shared reference control

PAIN=\$200;
PAOUT=\$202;
PADIR=\$204;
PAREN=\$206;
PASEL0=\$20A;
PASEL1=\$20C;
PASELC=\$216;
PAIES=\$218;
PAIE=\$21A;
PAIFG=\$21C;

P1IN=\$200;
P1OUT=\$202;
P1DIR=\$204;
P1REN=\$206;
P1SEL0=\$20A;
P1SEL1=\$20C;
P1IV=\$20E;
P1SELC=\$216;
P1IES=\$218;
P1IE=\$21A;
P1IFG=\$21C;

P2IN=\$201;
P2OUT=\$203;
P2DIR=\$205;
P2REN=\$207;
P2SEL0=\$20B;
P2SEL1=\$20D;
P2SELC=\$217;
P2IES=\$219;
P2IE=\$21B;
P2IFG=\$21D;
P2IV=\$21E;

PBIN=\$220;
PBOUT=\$222;
PBDIR=\$224;
PBREN=\$226;
PBSEL0=\$22A;
PBSEL1=\$22C;
PBSELC=\$236;
PBIES=\$238;
PBIE=\$23A;
PBIFG=\$23C;

P3IN=\$220;
P3OUT=\$222;
P3DIR=\$224;
P3REN=\$226;
P3SEL0=\$22A;
P3SEL1=\$22C;
P3IV=\$22E;
P3SELC=\$236;
P3IES=\$238;
P3IE=\$23A;
P3IFG=\$23C;

P4IN=\$221;
P4OUT=\$223;
P4DIR=\$225;
P4REN=\$227;
P4SEL0=\$22B;
P4SEL1=\$22D;
P4SELC=\$237;
P4IES=\$239;
P4IE=\$23B;
P4IFG=\$23D;
P4IV=\$23E;

PCIN=\$240;
PCOUT=\$242;
PCDIR=\$244;
PCREN=\$246;
PCSEL0=\$24A;
PCSEL1=\$24C;
PCSELC=\$256;

P5IN=\$240;
P5OUT=\$242;
P5DIR=\$244;
P5REN=\$246;
P5SEL0=\$24A;
P5SEL1=\$24C;
P5SELC=\$256;

P6IN=\$241;
P6OUT=\$243;
P6DIR=\$245;
P6REN=\$247;
P6SEL0=\$24B;
P6SEL1=\$24D;
P6SELC=\$257;

PDIN=\$260;
PDOUT=\$262;
PDDIR=\$264;
PDREN=\$266;
PDSEL0=\$26A;
PDSEL1=\$26C;
PDSELC=\$276;

P7IN=\$260;
P7OUT=\$262;
P7DIR=\$264;
P7REN=\$266;
P7SEL0=\$26A;
P7SEL1=\$26C;
P7SELC=\$276;

P8IN=\$261;
P8OUT=\$263;
P8DIR=\$265;
P8REN=\$267;
P8SEL0=\$26B;
P8SEL1=\$26D;
P8SELC=\$277;

PEIN=\$280;
PEOUT=\$282;
PEDIR=\$284;
PEREN=\$286;
PESEL0=\$28A;
PESEL1=\$28C;
PESELC=\$296;

P9IN=\$280;
P9OUT=\$282;
P9DIR=\$284;
P9REN=\$286;
P9SEL0=\$28A;
P9SEL1=\$28C;
P9SELC=\$296;

P10IN=\$281;
P10OUT=\$283;
P10DIR=\$285;
P10REN=\$287;
P10SEL0=\$28B;
P10SEL1=\$28D;
P10SELC=\$297;

PJIN=\$320;
PJOUT=\$322;
PJDIR=\$324;
PJREN=\$326;
PJSEL0=\$32A;
PJSEL1=\$32C;
PJSELC=\$336;


TACLR=4;
TAIFG=1;
TBCLR=2;
TBIFG=1;
CCIFG=1;

TA0CTL=\$340;       \ TA0 control
TA0CCTL0=\$342;     \ Capture/compare control 0
TA0CCTL1=\$344;     \ Capture/compare control 1
TA0CCTL2=\$346;     \ Capture/compare control 2
TA0CCTL3=\$348;     \ Capture/compare control 3
TA0CCTL4=\$34A;     \ Capture/compare control 4
TA0R=\$350;         \ TA0 counter register
TA0CCR0=\$352;      \ Capture/compare register 0
TA0CCR1=\$354;      \ Capture/compare register 1
TA0CCR2=\$356;      \ Capture/compare register 2
TA0CCR2=\$358;      \ Capture/compare register 3
TA0CCR2=\$35A;      \ Capture/compare register 4
TA0EX0=\$360;       \ TA0 expansion register 0
TA0IV=\$36E;        \ TA0 interrupt vector

TA1CTL=\$380;       \ TA1 control
TA1CCTL0=\$382;     \ Capture/compare control 0
TA1CCTL1=\$384;     \ Capture/compare control 1
TA1CCTL2=\$386;     \ Capture/compare control 2
TA1R=\$390;         \ TA1 counter register
TA1CCR0=\$392;      \ Capture/compare register 0
TA1CCR1=\$394;      \ Capture/compare register 1
TA1CCR2=\$396;      \ Capture/compare register 2
TA1EX0=\$3A0;       \ TA1 expansion register 0
TA1IV=\$3AE;        \ TA1 interrupt vector

TB0CTL=\$3C0;       \ TB0 control
TB0CCTL0=\$3C2;     \ Capture/compare control 0
TB0CCTL1=\$3C4;     \ Capture/compare control 1
TB0CCTL2=\$3C6;     \ Capture/compare control 2
TB0CCTL3=\$3C8;     \ Capture/compare control 3
TB0CCTL4=\$3CA;     \ Capture/compare control 4
TB0CCTL5=\$3CC;     \ Capture/compare control 5
TB0CCTL6=\$3CE;     \ Capture/compare control 6
TB0R=\$3D0;         \ TB0 counter register
TB0CCR0=\$3D2;      \ Capture/compare register 0
TB0CCR1=\$3D4;      \ Capture/compare register 1
TB0CCR2=\$3D6;      \ Capture/compare register 2
TB0CCR3=\$3D8;      \ Capture/compare register 3
TB0CCR5=\$3DA;      \ Capture/compare register 4
TB0CCR5=\$3DC;      \ Capture/compare register 5
TB0CCR6=\$3DE;      \ Capture/compare register 6
TB0EX0=\$3E0;       \ TB0 expansion register 0
TB0IV=\$3EE;        \ TB0 interrupt vector

TA2CTL=\$400;       \ TA2 control
TA2CCTL0=\$402;     \ Capture/compare control 0
TA2CCTL1=\$404;     \ Capture/compare control 1
TA2R=\$410;         \ TA2 counter register
TA2CCR0=\$412;      \ Capture/compare register 0
TA2CCR1=\$414;      \ Capture/compare register 1
TA2EX0=\$420;       \ TA2 expansion register 0
TA2IV=\$42E;        \ TA2 interrupt vector

CAPTIO0CTL=\$43E;   \ Capacitive Touch IO 0 control

TA3CTL=\$440;       \ TA3 control
TA3CCTL0=\$442;     \ Capture/compare control 0
TA3CCTL1=\$444;     \ Capture/compare control 1
TA3CCTL2=\$446;     \ Capture/compare control 2
TA3CCTL3=\$448;     \ Capture/compare control 3
TA3CCTL4=\$44A;     \ Capture/compare control 4
TA3R=\$450;         \ TA3 counter register
TA3CCR0=\$452;      \ Capture/compare register 0
TA3CCR1=\$454;      \ Capture/compare register 1
TA3CCR2=\$456;      \ Capture/compare register 2
TA3CCR3=\$458;      \ Capture/compare register 3
TA3CCR4=\$45A;      \ Capture/compare register 4
TA3EX0=\$460;       \ TA3 expansion register 0
TA3IV=\$46E;        \ TA3 interrupt vector

CAPTIO1CTL=\$47E;   \ Capacitive Touch IO 1 control

;                   \ RTC_C
RTCCTL0_L=\$4A0;    \ RTCCTL0_L
RTCCTL0_H=\$4A1;    \ RTCCTL0_H
RTCCTL1=\$4A2;      \ RTCCTL1
RTCCTL3=\$4A3;      \ RTCCTL3
RTCPS0CTL=\$4A8;    \ RTC prescaler 0 control
RTCPS1CTL=\$4AA;    \ RTC prescaler 1 control
RTCPS=\$4AC;        \ RTC prescaler
RT0PS=\$4AC;        \ RTC prescaler 0
RT1PS=\$4AD;        \ RTC prescaler 1
RTCIV=\$4AE;        \ RTC interrupt vector word
RTCSEC=\$4B0;       \ RTC seconds, RTC counter register 1 RTCSEC,
RTCCNT1=\$4B0;      \ Real-Time Counter 1
RTCMIN=\$4B1;       \ RTC minutes, RTC counter register 2 RTCMIN,
RTCCNT2=\$4B1;      \ Real-Time Counter 2
RTCHOUR=\$4B2;      \ RTC hours, RTC counter register 3 RTCHOUR,
RTCCNT3=\$4B2;      \ Real-Time Counter 3
RTCDOW=\$4B3;       \ RTC day of week, RTC counter register 4 RTCDOW,
RTCCNT4=\$4B3;      \ Real-Time Counter 4
RTCDAY=\$4B4;       \ RTC days
RTCMON=\$4B5;       \ RTC month
RTCYEAR=\$4B6;
RTCYEARL=\$4B6;     \ RTC year low
RTCYEARH=\$4B7;     \ RTC year high
RTCAMIN=\$4B8;      \ RTC alarm minutes
RTCAHOUR=\$4B9;     \ RTC alarm hours
RTCADOW=\$4BA;      \ RTC alarm day of week
RTCADAY=\$4BB;      \ RTC alarm days
BIN2BCD=\$4BC;      \ Binary-to-BCD conversion register
BCD2BIN=\$4BE;      \ BCD-to-binary conversion register

RTCHOLD=\$40;
RTCRDY=\$10;

MPY=\$4C0;          \ 16-bit operand 1 - multiply
MPYS=\$4C2;         \ 16-bit operand 1 - signed multiply
MAC=\$4C4;          \ 16-bit operand 1 - multiply accumulate
MACS=\$4C6;         \ 16-bit operand 1 - signed multiply accumulate
OP2=\$4C8;          \ 16-bit operand 2
RESLO=\$4CA;        \ 16 x 16 result low word
RESHI=\$4CC;        \ 16 x 16 result high word
SUMEXT=\$4CE;       \ 16 x 16 sum extension register
MPY32L=\$4D0;       \ 32-bit operand 1 - multiply low word
MPY32H=\$4D2;       \ 32-bit operand 1 - multiply high word
MPYS32L=\$4D4;      \ 32-bit operand 1 - signed multiply low word
MPYS32H=\$4D6;      \ 32-bit operand 1 - signed multiply high word
MAC32L=\$4D8;       \ 32-bit operand 1 - multiply accumulate low word
MAC32H=\$4DA;       \ 32-bit operand 1 - multiply accumulate high word
MACS32L=\$4DC;      \ 32-bit operand 1 - signed multiply accumulate low word
MACS32H=\$4DE;      \ 32-bit operand 1 - signed multiply accumulate high word
OP2L=\$4E0;         \ 32-bit operand 2 - low word
OP2H=\$4E2;         \ 32-bit operand 2 - high word
RES0=\$4E4;         \ 32 x 32 result 0 - least significant word
RES1=\$4E6;         \ 32 x 32 result 1
RES2=\$4E8;         \ 32 x 32 result 2
RES3=\$4EA;         \ 32 x 32 result 3 - most significant word
MPY32CTL0=\$4EC;    \ MPY32 control register 0

DMAIFG=8;

DMACTL0=\$500;      \ DMA module control 0
DMACTL1=\$502;      \ DMA module control 1
DMACTL2=\$504;      \ DMA module control 2
DMACTL3=\$506;      \ DMA module control 3
DMACTL4=\$508;      \ DMA module control 4
DMAIV=\$50A;        \ DMA interrupt vector

DMA0CTL=\$510;      \ DMA channel 0 control
DMA0SAL=\$512;      \ DMA channel 0 source address low
DMA0SAH=\$514;      \ DMA channel 0 source address high
DMA0DAL=\$516;      \ DMA channel 0 destination address low
DMA0DAH=\$518;      \ DMA channel 0 destination address high
DMA0SZ=\$51A;       \ DMA channel 0 transfer size

DMA1CTL=\$520;      \ DMA channel 1 control
DMA1SAL=\$522;      \ DMA channel 1 source address low
DMA1SAH=\$524;      \ DMA channel 1 source address high
DMA1DAL=\$526;      \ DMA channel 1 destination address low
DMA1DAH=\$528;      \ DMA channel 1 destination address high
DMA1SZ=\$52A;       \ DMA channel 1 transfer size

DMA2CTL=\$530;      \ DMA channel 2 control
DMA2SAL=\$532;      \ DMA channel 2 source address low
DMA2SAH=\$534;      \ DMA channel 2 source address high
DMA2DAL=\$536;      \ DMA channel 2 destination address low
DMA2DAH=\$538;      \ DMA channel 2 destination address high
DMA2SZ=\$53A;       \ DMA channel 2 transfer size


MPUCTL0=\$5A0;      \ MPU control 0
MPUCTL1=\$5A2;      \ MPU control 1
MPUSEGB2=\$5A4;     \ MPU Segmentation Border2
MPUSEGB1=\$5A6;     \ MPU Segmentation Border1
MPUSAM=\$5A8;       \ MPU access management
MPUIPC0=\$5AA;      \ MPU IP control 0
MPUIPSEGB2=\$5AC;   \ MPU IP Encapsulation Segment Border 2
MPUIPSEGB1=\$5AE;   \ MPU IP Encapsulation Segment Border 1

UCA0CTLW0=\$5C0;    \ eUSCI_A control word 0
UCA0CTLW1=\$5C2;    \ eUSCI_A control word 1
UCA0BRW=\$5C6;
UCA0BR0=\$5C6;      \ eUSCI_A baud rate 0
UCA0BR1=\$5C7;      \ eUSCI_A baud rate 1
UCA0MCTLW=\$5C8;    \ eUSCI_A modulation control
UCA0STAT=\$5CA;     \ eUSCI_A status
UCA0RXBUF=\$5CC;    \ eUSCI_A receive buffer
UCA0TXBUF=\$5CE;    \ eUSCI_A transmit buffer
UCA0ABCTL=\$5D0;    \ eUSCI_A LIN control
UCA0IRTCTL=\$5D2;   \ eUSCI_A IrDA transmit control
UCA0IRRCTL=\$5D3;   \ eUSCI_A IrDA receive control
UCA0IE=\$5DA;       \ eUSCI_A interrupt enable
UCA0IFG=\$5DC;      \ eUSCI_A interrupt flags
UCA0IV=\$5DE;       \ eUSCI_A interrupt vector word

UCA1CTLW0=\$5E0;    \ eUSCI_A control word 0
UCA1CTLW1=\$5E2;    \ eUSCI_A control word 1
UCA1BRW=\$5E6;
UCA1BR0=\$5E6;      \ eUSCI_A baud rate 0
UCA1BR1=\$5E7;      \ eUSCI_A baud rate 1
UCA1MCTLW=\$5E8;    \ eUSCI_A modulation control
UCA1STAT=\$5EA;     \ eUSCI_A status
UCA1RXBUF=\$5EC;    \ eUSCI_A receive buffer
UCA1TXBUF=\$5EE;    \ eUSCI_A transmit buffer
UCA1ABCTL=\$5F0;    \ eUSCI_A LIN control
UCA1IRTCTL=\$5F2;   \ eUSCI_A IrDA transmit control
UCA1IRRCTL=\$5F3;   \ eUSCI_A IrDA receive control
UCA1IE=\$5FA;       \ eUSCI_A interrupt enable
UCA1IFG=\$5FC;      \ eUSCI_A interrupt flags
UCA1IV=\$5FE;       \ eUSCI_A interrupt vector word


UCB0CTLW0=\$640;    \ eUSCI_B control word 0
UCB0CTLW1=\$642;    \ eUSCI_B control word 1
UCB0BRW=\$646;
UCB0BR0=\$646;      \ eUSCI_B bit rate 0
UCB0BR1=\$647;      \ eUSCI_B bit rate 1
UCB0STATW=\$648;    \ eUSCI_B status word
UCBCNT0=\$649;      \ eUSCI_B hardware count
UCB0TBCNT=\$64A;    \ eUSCI_B byte counter threshold
UCB0RXBUF=\$64C;    \ eUSCI_B receive buffer
UCB0TXBUF=\$64E;    \ eUSCI_B transmit buffer
UCB0I2COA0=\$654;   \ eUSCI_B I2C own address 0
UCB0I2COA1=\$656;   \ eUSCI_B I2C own address 1
UCB0I2COA2=\$658;   \ eUSCI_B I2C own address 2
UCB0I2COA3=\$65A;   \ eUSCI_B I2C own address 3
UCB0ADDRX=\$65C;    \ eUSCI_B received address
UCB0ADDMASK=\$65E;  \ eUSCI_B address mask
UCB0I2CSA=\$660;    \ eUSCI I2C slave address
UCB0IE=\$66A;       \ eUSCI interrupt enable
UCB0IFG=\$66C;      \ eUSCI interrupt flags
UCB0IV=\$66E;       \ eUSCI interrupt vector word

UCB1CTLW0=\$680;    \ eUSCI_B control word 0
UCB1CTLW1=\$682;    \ eUSCI_B control word 1
UCB1BRW=\$686;
UCB1BR0=\$686;      \ eUSCI_B bit rate 0
UCB1BR1=\$687;      \ eUSCI_B bit rate 1
UCB1STATW=\$688;    \ eUSCI_B status word
UCB1NT0=\$689;      \ eUSCI_B hardware count
UCB1TBCNT=\$68A;    \ eUSCI_B byte counter threshold
UCB1RXBUF=\$68C;    \ eUSCI_B receive buffer
UCB1TXBUF=\$68E;    \ eUSCI_B transmit buffer
UCB1I2COA0=\$694;   \ eUSCI_B I2C own address 0
UCB1I2COA1=\$696;   \ eUSCI_B I2C own address 1
UCB1I2COA2=\$698;   \ eUSCI_B I2C own address 2
UCB1I2COA3=\$69A;   \ eUSCI_B I2C own address 3
UCB1ADDRX=\$69C;    \ eUSCI_B received address
UCB1ADDMASK=\$69E;  \ eUSCI_B address mask
UCB1I2CSA=\$6A0;    \ eUSCI I2C slave address
UCB1IE=\$6AA;       \ eUSCI interrupt enable
UCB1IFG=\$6AC;      \ eUSCI interrupt flags
UCB1IV=\$6AE;       \ eUSCI interrupt vector word

UCTXACK=\$20;
UCTR=\$10;


ADC12CTL0=\$800;    \ ADC12_B Control 0
ADC12CTL1=\$802;    \ ADC12_B Control 1
ADC12CTL2=\$804;    \ ADC12_B Control 2
ADC12CTL3=\$806;    \ ADC12_B Control 3
ADC12LO=\$808;      \ ADC12_B Window Comparator Low Threshold Register
ADC12HI=\$80A;      \ ADC12_B Window Comparator High Threshold Register
ADC12IFGR0=\$80C;   \ ADC12_B Interrupt Flag Register 0
ADC12IFGR1=\$80E;   \ ADC12_B Interrupt Flag Register 1
ADC12IFGR2=\$810;   \ ADC12_B Interrupt Flag Register 2
ADC12IER0=\$812;    \ ADC12_B Interrupt Enable Register 0
ADC12IER1=\$814;    \ ADC12_B Interrupt Enable Register 1
ADC12IER2=\$816;    \ ADC12_B Interrupt Enable Register 2
ADC12IV=\$818;      \ ADC12_B Interrupt Vector
ADC12MCTL0=\$820;   \ ADC12_B Memory Control 0
ADC12MCTL1=\$822;   \ ADC12_B Memory Control 1
ADC12MCTL2=\$824;   \ ADC12_B Memory Control 2
ADC12MCTL3=\$826;   \ ADC12_B Memory Control 3
ADC12MCTL4=\$828;   \ ADC12_B Memory Control 4
ADC12MCTL5=\$82A;   \ ADC12_B Memory Control 5
ADC12MCTL6=\$82C;   \ ADC12_B Memory Control 6
ADC12MCTL7=\$82E;   \ ADC12_B Memory Control 7
ADC12MCTL8=\$830;   \ ADC12_B Memory Control 8
ADC12MCTL9=\$832;   \ ADC12_B Memory Control 9
ADC12MCTL10=\$834;  \ ADC12_B Memory Control 10
ADC12MCTL11=\$836;  \ ADC12_B Memory Control 11
ADC12MCTL12=\$838;  \ ADC12_B Memory Control 12
ADC12MCTL13=\$83A;  \ ADC12_B Memory Control 13
ADC12MCTL14=\$83C;  \ ADC12_B Memory Control 14
ADC12MCTL15=\$83E;  \ ADC12_B Memory Control 15
ADC12MCTL16=\$840;  \ ADC12_B Memory Control 16
ADC12MCTL17=\$842;  \ ADC12_B Memory Control 17
ADC12MCTL18=\$844;  \ ADC12_B Memory Control 18
ADC12MCTL19=\$846;  \ ADC12_B Memory Control 19
ADC12MCTL20=\$848;  \ ADC12_B Memory Control 20
ADC12MCTL21=\$84A;  \ ADC12_B Memory Control 21
ADC12MCTL22=\$84C;  \ ADC12_B Memory Control 22
ADC12MCTL23=\$84E;  \ ADC12_B Memory Control 23
ADC12MCTL24=\$850;  \ ADC12_B Memory Control 24
ADC12MCTL25=\$852;  \ ADC12_B Memory Control 25
ADC12MCTL26=\$854;  \ ADC12_B Memory Control 26
ADC12MCTL27=\$856;  \ ADC12_B Memory Control 27
ADC12MCTL28=\$858;  \ ADC12_B Memory Control 28
ADC12MCTL29=\$85A;  \ ADC12_B Memory Control 29
ADC12MCTL30=\$85C;  \ ADC12_B Memory Control 30
ADC12MCTL31=\$85E;  \ ADC12_B Memory Control 31
ADC12MEM0=\$860;    \ ADC12_B Memory 0
ADC12MEM1=\$862;    \ ADC12_B Memory 1
ADC12MEM2=\$864;    \ ADC12_B Memory 2
ADC12MEM3=\$866;    \ ADC12_B Memory 3
ADC12MEM4=\$868;    \ ADC12_B Memory 4
ADC12MEM5=\$86A;    \ ADC12_B Memory 5
ADC12MEM6=\$86C;    \ ADC12_B Memory 6
ADC12MEM7=\$86E;    \ ADC12_B Memory 7
ADC12MEM8=\$870;    \ ADC12_B Memory 8
ADC12MEM9=\$872;    \ ADC12_B Memory 9
ADC12MEM10=\$874;   \ ADC12_B Memory 10
ADC12MEM11=\$876;   \ ADC12_B Memory 11
ADC12MEM12=\$878;   \ ADC12_B Memory 12
ADC12MEM13=\$87A;   \ ADC12_B Memory 13
ADC12MEM14=\$87C;   \ ADC12_B Memory 14
ADC12MEM15=\$87E;   \ ADC12_B Memory 15
ADC12MEM16=\$880;   \ ADC12_B Memory 16
ADC12MEM17=\$882;   \ ADC12_B Memory 17
ADC12MEM18=\$884;   \ ADC12_B Memory 18
ADC12MEM19=\$886;   \ ADC12_B Memory 19
ADC12MEM20=\$888;   \ ADC12_B Memory 20
ADC12MEM21=\$88A;   \ ADC12_B Memory 21
ADC12MEM22=\$88C;   \ ADC12_B Memory 22
ADC12MEM23=\$88E;   \ ADC12_B Memory 23
ADC12MEM24=\$890;   \ ADC12_B Memory 24
ADC12MEM25=\$892;   \ ADC12_B Memory 25
ADC12MEM26=\$894;   \ ADC12_B Memory 26
ADC12MEM27=\$896;   \ ADC12_B Memory 27
ADC12MEM28=\$898;   \ ADC12_B Memory 28
ADC12MEM29=\$89A;   \ ADC12_B Memory 29
ADC12MEM30=\$89C;   \ ADC12_B Memory 30
ADC12MEM31=\$89E;   \ ADC12_B Memory 31

ADCON=\$10;
ADCSTART=\$03;

CDIFG=1;
CDIIFG=2;

CDCTL0=\$8C0;       \ Comparator_E control register 0
CDCTL1=\$8C2;       \ Comparator_E control register 1
CDCTL2=\$8C4;       \ Comparator_E control register 2
CDCTL3=\$8C6;       \ Comparator_E control register 3
CDINT=\$8CC;        \ Comparator_E interrupt register
CDIV=\$8CE;         \ Comparator_E interrupt vector word

CRC32DIW0=\$980;        \ CRC32 data input
CRC32DIRBW0=\$986;      \ CRC32 data input reverse
CRC32INIRESW0=\$988;    \ CRC32 initialization and result word 0
CRC32INIRESW1=\$98A;    \ CRC32 initialization and result word 1
CRC32RESRW1=\$98;       \ CRC32 result reverse word 1
CRC32RESRW1=\$98E;      \ CRC32 result reverse word 0
CRC16DIW0=\$990;        \ CRC16 data input
CRC16DIRBW0=\$996;      \ CRC16 data input reverse
CRC16INIRESW0=\$998;    \ CRC16 initialization and result word 0
CRC16RESRW1=\$99E;      \ CRC16 result reverse word 0


AESACTL0=\$9C0;     \ AES accelerator control register 0
AESASTAT=\$9C4;     \ AES accelerator status register
AESAKEY=\$9C6;      \ AES accelerator key register
AESADIN=\$9C8;      \ AES accelerator data in register
AESADOUT=\$9CA;     \ AES accelerator data out register
AESAXDIN=\$9CC;     \ AES accelerator XORed data in register
AESAXIN =\$9CE;     \ AES accelerator XORed data in register (no trigger)


LCDCCTL0=\$A00;     \ LCD_C control register 0
LCDCCTL1=\$A02;     \ LCD_C control register 1
LCDCBLKCTL=\$A04;   \ LCD_C blinking control register
LCDCMEMCTL=\$A06;   \ LCD_C memory control register
LCDCVCTL=\$A08;     \ LCD_C voltage control register
LCDCPCTL0=\$A0A;    \ LCD_C port control 0
LCDCPCTL1=\$A0C;    \ LCD_C port control 1
LCDCPCTL2=\$A0E;    \ LCD_C port control 2
LCDCCPCTL=\$A12;    \ LCD_C charge pump ctrl register
LCDCIV=\$A1E;       \ LCD_C interrupt vector
LCDM1=\$A20;        \ LCD_C memory 1
LCDM2=\$A21;        \ LCD_C memory 2
LCDM3=\$A22;        \ LCD_C memory 3
LCDM4=\$A23;        \ LCD_C memory 4
LCDM5=\$A24;        \ LCD_C memory 5
LCDM6=\$A25;        \ LCD_C memory 6
LCDM7=\$A26;        \ LCD_C memory 7
LCDM8=\$A27;        \ LCD_C memory 8
LCDM9=\$A28;        \ LCD_C memory 9
LCDM10=\$A29;       \ LCD_C memory 10
LCDM11=\$A2A;       \ LCD_C memory 11
LCDM12=\$A2B;       \ LCD_C memory 12
LCDM13=\$A2C;       \ LCD_C memory 13
LCDM14=\$A2D;       \ LCD_C memory 14
LCDM15=\$A2E;       \ LCD_C memory 15
LCDM16=\$A2F;       \ LCD_C memory 16
LCDM17=\$A30;       \ LCD_C memory 17
LCDM18=\$A31;       \ LCD_C memory 18
LCDM19=\$A32;       \ LCD_C memory 19
LCDM20=\$A33;       \ LCD_C memory 20
LCDM21=\$A34;       \ LCD_C memory 21
LCDM22=\$A35;       \ LCD_C memory 22
LCDM23=\$A36;       \ LCD_C memory 23
LCDM24=\$A37;       \ LCD_C memory 24
LCDM25=\$A38;       \ LCD_C memory 25
LCDM26=\$A39;       \ LCD_C memory 26
LCDM27=\$A3A;       \ LCD_C memory 27
LCDM28=\$A3B;       \ LCD_C memory 28
LCDM29=\$A3C;       \ LCD_C memory 29
LCDM30=\$A3D;       \ LCD_C memory 30
LCDM31=\$A3E;       \ LCD_C memory 31
LCDM32=\$A3F;       \ LCD_C memory 32
LCDM33=\$A40;       \ LCD_C memory 33
LCDM34=\$A41;       \ LCD_C memory 34
LCDM35=\$A42;       \ LCD_C memory 35
LCDM36=\$A43;       \ LCD_C memory 36
LCDM37=\$A44;       \ LCD_C memory 37
LCDM38=\$A45;       \ LCD_C memory 38
LCDM39=\$A46;       \ LCD_C memory 39
LCDM40=\$A47;       \ LCD_C memory 40
LCDM41=\$A48;       \ LCD_C memory 41
LCDM42=\$A49;       \ LCD_C memory 42
LCDM43=\$A4A;       \ LCD_C memory 43
LCDBM1=\$A40;       \ LCD_C blinking memory 1
LCDBM2=\$A41;       \ LCD_C blinking memory 2
LCDBM3=\$A42;       \ LCD_C blinking memory 3
LCDBM4=\$A43;       \ LCD_C blinking memory 4
LCDBM5=\$A44;       \ LCD_C blinking memory 5
LCDBM6=\$A45;       \ LCD_C blinking memory 6
LCDBM7=\$A46;       \ LCD_C blinking memory 7
LCDBM8=\$A47;       \ LCD_C blinking memory 8
LCDBM9=\$A48;       \ LCD_C blinking memory 9
LCDBM10=\$A49;      \ LCD_C blinking memory 10
LCDBM11=\$A4A;      \ LCD_C blinking memory 11
LCDBM12=\$A4B;      \ LCD_C blinking memory 12
LCDBM13=\$A4C;      \ LCD_C blinking memory 13
LCDBM14=\$A4D;      \ LCD_C blinking memory 14
LCDBM15=\$A4E;      \ LCD_C blinking memory 15
LCDBM16=\$A4F;      \ LCD_C blinking memory 16
LCDBM17=\$A50;      \ LCD_C blinking memory 17
LCDBM18=\$A51;      \ LCD_C blinking memory 18
LCDBM19=\$A52;      \ LCD_C blinking memory 19
LCDBM20=\$A53;      \ LCD_C blinking memory 20
LCDBM21=\$A54;      \ LCD_C blinking memory 21
LCDBM22=\$A55;      \ LCD_C blinking memory 22


ESIDEBUG1=\$D00;    \ ESI debug register 1
ESIDEBUG2=\$D02;    \ ESI debug register 2
ESIDEBUG3=\$D04;    \ ESI debug register 3
ESIDEBUG4=\$D06;    \ ESI debug register 4
ESIDEBUG5=\$D08;    \ ESI debug register 5
ESICNT0=\$D10;      \ ESI PSM counter 0
ESICNT1=\$D12;      \ ESI PSM counter 1
ESICNT2=\$D14;      \ ESI PSM counter 2
ESICNT3=\$D16;      \ ESI oscillator counter register
ESIIV=\$D1A;        \ ESI interrupt vector
ESIINT1=\$D1C;      \ ESI interrupt register 1
ESIINT2=\$D1E;      \ ESI interrupt register 2
ESIAFE=\$D20;       \ ESI AFE control register
ESIPPU=\$D22;       \ ESI PPU control register
ESITSM=\$D24;       \ ESI TSM control register
ESIPSM=\$D26;       \ ESI PSM control register
ESIOSC=\$D28;       \ ESI oscillator control register
ESICTL=\$D2A;       \ ESI control register
ESITHR1=\$D2C;      \ ESI PSM counter threshold register 1
ESITHR2=\$D2E;      \ ESI PSM counter threshold register 2
ESIADMEM1=\$D30;    \ ESI A/D conversion memory 1
ESIADMEM2=\$D32;    \ ESI A/D conversion memory 2
ESIADMEM3=\$D34;    \ ESI A/D conversion memory 3
ESIADMEM4=\$D36;    \ ESI A/D conversion memory 4
ESIDAC1R0=\$D40;    \ ESI DAC1 register 0
ESIDAC1R1=\$D42;    \ ESI DAC1 register 1
ESIDAC1R2=\$D44;    \ ESI DAC1 register 2
ESIDAC1R3=\$D46;    \ ESI DAC1 register 3
ESIDAC1R4=\$D48;    \ ESI DAC1 register 4
ESIDAC1R5=\$D4A;    \ ESI DAC1 register 5
ESIDAC1R6=\$D4C;    \ ESI DAC1 register 6
ESIDAC1R7=\$D4E;    \ ESI DAC1 register 7
ESIDAC2R0=\$D50;    \ ESI DAC2 register 0
ESIDAC2R1=\$D52;    \ ESI DAC2 register 1
ESIDAC2R2=\$D54;    \ ESI DAC2 register 2
ESIDAC2R3=\$D56;    \ ESI DAC2 register 3
ESIDAC2R4=\$D58;    \ ESI DAC2 register 4
ESIDAC2R5=\$D5A;    \ ESI DAC2 register 5
ESIDAC2R6=\$D5C;    \ ESI DAC2 register 6
ESIDAC2R7=\$D5E;    \ ESI DAC2 register 7
ESITSM0=\$D60;      \ ESI TSM 0
ESITSM1=\$D62;      \ ESI TSM 1
ESITSM2=\$D64;      \ ESI TSM 2
ESITSM3=\$D66;      \ ESI TSM 3
ESITSM4=\$D68;      \ ESI TSM 4
ESITSM5=\$D6A;      \ ESI TSM 5
ESITSM6=\$D6C;      \ ESI TSM 6
ESITSM7=\$D6E;      \ ESI TSM 7
ESITSM8=\$D70;      \ ESI TSM 8
ESITSM9=\$D72;      \ ESI TSM 9
ESITSM10=\$D74;     \ ESI TSM 10
ESITSM11=\$D76;     \ ESI TSM 11
ESITSM12=\$D78;     \ ESI TSM 12
ESITSM13=\$D7A;     \ ESI TSM 13
ESITSM14=\$D7C;     \ ESI TSM 14
ESITSM15=\$D7E;     \ ESI TSM 15
ESITSM16=\$D80;     \ ESI TSM 16
ESITSM17=\$D82;     \ ESI TSM 17
ESITSM18=\$D84;     \ ESI TSM 18
ESITSM19=\$D86;     \ ESI TSM 19
ESITSM20=\$D88;     \ ESI TSM 20
ESITSM21=\$D8A;     \ ESI TSM 21
ESITSM22=\$D8C;     \ ESI TSM 22
ESITSM23=\$D8E;     \ ESI TSM 23
ESITSM24=\$D90;     \ ESI TSM 24
ESITSM25=\$D92;     \ ESI TSM 25
ESITSM26=\$D94;     \ ESI TSM 26
ESITSM27=\$D96;     \ ESI TSM 27
ESITSM28=\$D98;     \ ESI TSM 28
ESITSM29=\$D9A;     \ ESI TSM 29
ESITSM30=\$D9C;     \ ESI TSM 30
ESITSM31=\$D9E;     \ ESI TSM 31


ESI_RAM=\$E00;
