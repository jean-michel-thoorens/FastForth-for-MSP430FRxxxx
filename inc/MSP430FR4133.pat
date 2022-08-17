@set-syntax{C;\;}!  replace ! by semicolon
;MSP430FR4133.pat

; ----------------------------------------------
; MSP430FR4133 MEMORY MAP
; ----------------------------------------------
; 0000-0FFF = peripherals (4 KB)
; 1000-13FF = ROM bootstrap loader BSL0.1 (2x512 B)
; 1800-19FF = INFO 512 B
; 1A00-1A23 = TLV device descriptor info (FRAM 35 B)
; 2000-27FF = RAM (2 KB)
; C400-FF7F = code memory (FRAM 15232 B)
; FF80-FFFF = interrupt vectors (FRAM 127 B)
; ----------------------------------------------

; ============================================
; BSL
; ============================================
BSL1=\$1000;

; ============================================
; FRAM INFO
; ============================================
INFO_ORG =\$1800;
INFO_LEN=\$0200;

; See MSP430FRxxxx.pat

; ============================================
; FRAM TLV
; ============================================

; See MSP430FRxxxx.pat

; ============================================
; RAM
; ============================================
RAM_ORG=\$2000;
RAM_LEN=\$0800;

; ---------------------------------------
; FORTH RAM areas :
; ---------------------------------------

; See MSP430FRxxxx.pat

; ---------------------------------------
; FastForth RAM memory map (>= 1k):
; ---------------------------------------
LEAVEPTR=\$2000;        Leave-stack pointer, init by QUIT
LSATCK=\$2000;          leave stack,      grow up
PSTACK=\$2080;          parameter stack,  grow down
RSTACK=\$20E0;          Return stack,     grow down
;
PAD_I2CADR=\$20E0;      RX I2C address
PAD_I2CCNT=\$20E2;      count max
PAD_ORG=\$20E4;         user scratch pad buffer, 84 bytes, grow up
;
TIB_I2CADR=\$2138;      TX I2C address
TIB_I2CCNT=\$213A;      count of bytes
TIB_ORG=\$213C;         Terminal input buffer, 84 bytes, grow up
;
HOLDS_ORG=\$2190;       base address for HOLDS
HOLD_BASE=\$21B2;       BASE HOLD area, grow down
;
HP=\$21B2;              HOLD ptr
STATEADR=\$21B4;        Interpreter state
BASEADR=\$21B6;         base
CAPS=\$21B8;            CAPS ON/OFF
SOURCE_LEN=\$21BA;      len of input stream
SOURCE_ORG=\$21BC;      adr of input stream
TOIN=\$21BE;            >IN
;
DP=\$21C0;              dictionary ptr
LASTVOC=\$21C2;         keep VOC-LINK
CURRENT=\$21C4;         CURRENT dictionnary ptr
CONTEXT=\$21C6;         CONTEXT dictionnary space (8 + Null CELLS)
;
; ---------------------------------------
; RAM_ORG + $1D8 : may be shared between FORTH compiler and user application
; ---------------------------------------
LAST_NFA=\$21D8;
LAST_THREAD=\$21DA;
LAST_CFA=\$21DC;
LAST_PSP=\$21DE;
ASMBW1=\$21E0;          3 backward labels
ASMBW2=\$21E2;
ASMBW3=\$21E4;
ASMFW1=\$21E6;          3 forward labels
ASMFW2=\$21E8;
ASMFW3=\$21EA;
;
; ---------------------------------------
; RAM_ORG + $1EC RAM free 
; ---------------------------------------
;
; ---------------------------------------
; RAM_ORG + $1FC: SD buffer
; ---------------------------------------
SD_BUF_I2ADR=\$21FC;
SD_BUF_I2CNT=\$21FE;
SD_BUF=\$2200;      \ SD_Card buffer
BUFEND=\$2400;

; ---------------------------------------
; FAT16 FileSystemInfos
; ---------------------------------------
FATtype=\$2402;
BS_FirstSectorL=\$2404;
BS_FirstSectorH=\$2406;
OrgFAT1=\$2408;
FATSize=\$240A;
OrgFAT2=\$240C;
OrgRootDir=\$240E;
OrgClusters=\$2410;         Sector of Cluster 0
SecPerClus=\$2412;

; ---------------------------------------
; SD command
; ---------------------------------------
SD_CMD_FRM=\$2414;  6 bytes SD_CMDx inverted frame \${CRC,ll,LL,hh,HH,CMD}
SD_CMD_FRM0=\$2414; CRC:ll  word access
SD_CMD_FRM1=\$2415; ll      byte access
SD_CMD_FRM2=\$2416; LL:hh   word access
SD_CMD_FRM3=\$2417; hh      byte access
SD_CMD_FRM4=\$2418; HH:CMD  word access
SD_CMD_FRM5=\$2419; CMD     byte access
SectorL=\$241A;     2 words
SectorH=\$241C;

; ---------------------------------------
; BUFFER management
; ---------------------------------------
BufferPtr=\$241E;
BufferLen=\$2420;

; ---------------------------------------
; FAT entry
; ---------------------------------------
ClusterL=\$2422;     16 bits wide (FAT16)
ClusterH=\$2424;     16 bits wide (FAT16)
LastFATsector=\$2426;   Set by FreeAllClusters, used by OPEN_OVERWRITE
LastFAToffset=\$2428;   Set by FreeAllClusters, used by OPEN_OVERWRITE
FATsector=\$242A;       used by APPEND"

; ---------------------------------------
; DIR entry
; ---------------------------------------
DIRclusterL=\$242C;  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$242E;  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$2430;

; ---------------------------------------
; Handle Pointer
; ---------------------------------------
CurrentHdl=\$2432;  contains the address of the last opened file structure, or 0

; ---------------------------------------
; Load file operation
; ---------------------------------------
pathname=\$2434;
EndOfPath=\$2436;

; ---------------------------------------
; Handle structure
; ---------------------------------------
; three handle tokens :
; token = 0 : free handle
; token = 1 : file to read
; token = 2 : file updated (write)
; token =-1 : LOAD"ed file (source file)

; offset values
HDLW_PrevHDL=0;     previous handle ; used by LOAD"
HDLB_Token=2;       token
HDLB_ClustOfst=3;   Current sector offset in current cluster (Byte)
HDLL_DIRsect=4;     Dir SectorL (Long)
HDLH_DIRsect=6;
HDLW_DIRofst=8;     BUFFER offset of Dir entry
HDLL_FirstClus=10;  File First ClusterLo (identify the file)
HDLH_FirstClus=12;  File First ClusterHi (byte)
HDLL_CurClust=14;   Current ClusterLo
HDLH_CurClust=16;   Current ClusterHi (T as 3Th byte)
HDLL_CurSize=18;    written size / not yet read size (Long)
HDLH_CurSize=20;    written size / not yet read size (Long)
HDLW_BUFofst=22;    BUFFER offset ; used by LOAD" and by WRITE"
HDLW_PrevLEN=24;    previous LEN
HDLW_PrevORG=26;    previous ORG


;OpenedFirstFile     ; "openedFile" structure
HandleMax=8;
HandleLenght=28;
FirstHandle=\$2438;
HandleEnd=\$2518;

;SD_card Input Buffer
SDIB_I2CADR=\$2518;
SDIB_I2CCNT=\$251A;
SDIB_ORG=\$251C;

SD_END=\$2570;
SD_LEN=\$16E;

; ============================================
; FRAM MAIN
; ============================================
MAIN_ORG=\$C400;        Code space start
; ----------------------------------------------
\#LIT=\#\$C400;             asm CODE run time of LITERAL
\#XSQUOTE=\#\$C414;         asm CODE run time of QUOTE
\#MUSMOD=\#\$C428;          asm CODE 32/16 unsigned division, used by ?NUMBER, UM/MOD
\#MDIV1DIV2=\#\$C43A;       asm CODE input for 48/16 unsigned division with DVDhi=0, see DOUBLE M*/
\#MDIV1=\#\$C442;           asm CODE input for 48/16 unsigned division, see DOUBLE M*/
\#RET_ADR=\#\$C46C;         asm CODE of INIT_SOFT_PFA and MARKER+8 definitions,
\#SETIB=\#\$C46E;           CODE Set Input Buffer with org & len values, reset >IN pointer
\#REFILL=\#\$C47E;          CODE accept one line from input and leave org len of input buffer
\#CIB_ORG=\#\$C48A;         [CIB_ORG] = TIB_ORG by default; may be redirected to SDIB_ORG
\#QFBRAN=\#\$C496;          CODE compiled by IF UNTIL
\#BRAN=\#\$C49C;            CODE compiled by ELSE REPEAT AGAIN
\#NEXT_ADR=\#\$C49E;        CODE NEXT instruction (MOV @IP+,PC)
\#XDODOES=\#\$C4A0;         to restore rDODOES: MOV #XDODOES,rDODOES
\#XDOCON=\#\$C4AE;          to restore rDOCON: MOV #XDOCON,rDOCON
;                           to restore rDOVAR: MOV &INIT_DOVAR,rDOVAR
;                           to restore rDOCOL: MOV &INIT_DOCOL,rDOCOL
\#INIT_FORTH=\#\$C4BA;
\#ABORT_TERM=\#\$C500;      CALL #ABORT_TERM to discard pending download
\#UART_WARM=\#\$C572;       WARM address for UART TERMINAL
\#I2C_WARM=\#\$C55C;        WARM address for I2C TERMINAL

; See MSP430FRxxxx.pat for other addresses

; ----------------------------------------------
; Interrupt Vectors and signatures - MSP430FR4133
; ----------------------------------------------
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
VECT_ORG=\$FFE2;         FFE2-FFFF
VECT_LEN=\$1E;

LCD_VEC=\$FFE2;
P2_VEC=\$FFE4;
P1_VEC=\$FFE6;
ADC10_B_VEC=\$FFE8;
EUSCI_B0_VEC=\$FFEA;
EUSCI_A0_VEC=\$FFEC;
WDT_VEC=\$FFEE;
RTC_VEC=\$FFF0;
TA1_X_VEC=\$FFF2;
TA1_0_VEC=\$FFF4;
TA0_X_VEC=\$FFF6;
TA0_0_VEC=\$FFF8;
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
PMMCTL1=\$122;      \ PMM Control 0
PMMCTL2=\$124;      \ PMM Control 0
PMMIFG=\$12A;       \ PMM interrupt flags
PM5CTL0=\$130;      \ PM5 Control 0

SYSCTL=\$140;       \ System control
SYSBSLC=\$142;      \ Bootstrap loader configuration area
SYSJMBC=\$146;      \ JTAG mailbox control
SYSJMBI0=\$148;     \ JTAG mailbox input 0
SYSJMBI1=\$14A;     \ JTAG mailbox input 1
SYSJMBO0=\$14C;     \ JTAG mailbox output 0
SYSJMBO1=\$14E;     \ JTAG mailbox output 1
SYSUNIV=\$15A;      \ User NMI vector generator
SYSSNIV=\$15C;      \ System NMI vector generator
SYSRSTIV=\$15E;     \ Reset vector generator
SYSCFG0=\$160;      \ System configuration 0
SYSCFG1=\$162;      \ System configuration 1
SYSCFG2=\$164;      \ System configuration 2

CSCTL0=\$180;       \ CS control 0
CSCTL1=\$182;       \ CS control 1
CSCTL2=\$184;       \ CS control 2
CSCTL3=\$186;       \ CS control 3
CSCTL4=\$188;       \ CS control 4
CSCTL5=\$18A;       \ CS control 5
CSCTL6=\$18C;       \ CS control 6
CSCTL7=\$18E;       \ CS control 7
CSCTL8=\$190;       \ CS control 8


FRCTLCTL0=\$1A0;    \ FRAM control 0
GCCTL0=\$1A4;       \ General control 0
GCCTL1=\$1A6;       \ General control 1

CRC16DI=\$1C0;      \ CRC data input
CRCDIRB=\$1C2;      \ CRC data input reverse byte
CRCINIRES=\$1C4;    \ CRC initialization and result
CRCRESR=\$1C6;      \ CRC result reverse byte

WDTCTL=\$1CC;        \ WDT control register


PAIN=\$200;
PAOUT=\$202;
PADIR=\$204;
PAREN=\$206;
PASEL0=\$20A;
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
P1IES=\$218;
P1IE=\$21A;
P1IFG=\$21C;

P2IN=\$201;
P2OUT=\$203;
P2DIR=\$205;
P2REN=\$207;
P2IES=\$219;
P2IE=\$21B;
P2IFG=\$21D;
P2IV=\$21E;

PBIN=\$220;
PBOUT=\$222;
PBDIR=\$224;
PBREN=\$226;
PBSEL0=\$22A;

P3IN=\$220;
P3OUT=\$222;
P3DIR=\$224;
P3REN=\$226;

P4IN=\$221;
P4OUT=\$223;
P4DIR=\$225;
P4REN=\$227;
P4SEL0=\$22B;

PCIN=\$240;
PCOUT=\$242;
PCDIR=\$244;
PCREN=\$246;
PCSEL0=\$24A;
PCSEL1=\$24C;

P5IN=\$240;
P5OUT=\$242;
P5DIR=\$244;
P5REN=\$246;
P5SEL0=\$24A;

P6IN=\$241;
P6OUT=\$243;
P6DIR=\$245;
P6REN=\$247;

PDIN=\$260;
PDOUT=\$262;
PDDIR=\$264;
PDREN=\$266;
PDSEL0=\$26A;

P7IN=\$260;
P7OUT=\$262;
P7DIR=\$264;
P7REN=\$266;

P8IN=\$261;
P8OUT=\$263;
P8DIR=\$265;
P8REN=\$267;
P8SEL0=\$26B;

CAPTIO0CTL=\$2EE;   \ Capacitive Touch IO 0 control



TACLR=4;
TAIFG=1;
CCIFG=1;

TA0CTL=\$300;       \ TA0 control
TA0CCTL0=\$302;     \ Capture/compare control 0
TA0CCTL1=\$304;     \ Capture/compare control 1
TA0CCTL2=\$306;     \ Capture/compare control 2
TA0R=\$310;         \ TA0 counter register
TA0CCR0=\$312;      \ Capture/compare register 0
TA0CCR1=\$314;      \ Capture/compare register 1
TA0CCR2=\$316;      \ Capture/compare register 2
TA0EX0=\$320;       \ TA0 expansion register 0
TA0IV=\$32E;        \ TA0 interrupt vector

TA1CTL=\$340;       \ TA1 control
TA1CCTL0=\$342;     \ Capture/compare control 0
TA1CCTL1=\$344;     \ Capture/compare control 1
TA1CCTL2=\$346;     \ Capture/compare control 2
TA1R=\$350;         \ TA1 counter register
TA1CCR0=\$352;      \ Capture/compare register 0
TA1CCR1=\$354;      \ Capture/compare register 1
TA1CCR2=\$356;      \ Capture/compare register 2
TA1EX0=\$360;       \ TA1 expansion register 0
TA1IV=\$36E;        \ TA1 interrupt vector

RTCCTL=\$3C0;       \ RTC control
RTCIV=\$3C4;        \ RTC interrupt vector word
RTCMOD=\$3C8;       \ RTC modulo
RTCCNT=\$3CC;       \ RTC counter register


UCA0CTLW0=\$500;    \ eUSCI_A control word 0
UCA0CTLW1=\$502;    \ eUSCI_A control word 1
UCA0BRW=\$506;
UCA0BR0=\$506;      \ eUSCI_A baud rate 0
UCA0BR1=\$507;      \ eUSCI_A baud rate 1
UCA0MCTLW=\$508;    \ eUSCI_A modulation control
UCA0STAT=\$50A;     \ eUSCI_A status
UCA0RXBUF=\$50C;    \ eUSCI_A receive buffer
UCA0TXBUF=\$50E;    \ eUSCI_A transmit buffer
UCA0ABCTL=\$510;    \ eUSCI_A LIN control
UCA0IRTCTL=\$512;   \ eUSCI_A IrDA transmit control
UCA0IRRCTL=\$513;   \ eUSCI_A IrDA receive control
UCA0IE=\$51A;       \ eUSCI_A interrupt enable
UCA0IFG=\$51C;      \ eUSCI_A interrupt flags
UCA0IV=\$51E;       \ eUSCI_A interrupt vector word


UCB0CTLW0=\$540;    \ eUSCI_B control word 0
UCB0CTLW1=\$542;    \ eUSCI_B control word 1
UCB0BRW=\$546;
UCB0BR0=\$546;      \ eUSCI_B bit rate 0
UCB0BR1=\$547;      \ eUSCI_B bit rate 1
UCB0STATW=\$548;    \ eUSCI_B status word
UCBCNT0=\$549;      \ eUSCI_B hardware count
UCB0TBCNT=\$54A;    \ eUSCI_B byte counter threshold
UCB0RXBUF=\$54C;    \ eUSCI_B receive buffer
UCB0TXBUF=\$54E;    \ eUSCI_B transmit buffer
UCB0I2COA0=\$554;   \ eUSCI_B I2C own address 0
UCB0I2COA1=\$556;   \ eUSCI_B I2C own address 1
UCB0I2COA2=\$558;   \ eUSCI_B I2C own address 2
UCB0I2COA3=\$55A;   \ eUSCI_B I2C own address 3
UCB0ADDRX=\$55C;    \ eUSCI_B received address
UCB0ADDMASK=\$55E;  \ eUSCI_B address mask
UCB0I2CSA=\$560;    \ eUSCI I2C slave address
UCB0IE=\$56A;       \ eUSCI interrupt enable
UCB0IFG=\$56C;      \ eUSCI interrupt flags
UCB0IV=\$56E;       \ eUSCI interrupt vector word

UCTXACK=\$20;
UCTR=\$10;

LCDCTL0=\$600;      \ LCD control register 0
LCDCTL1=\$602;      \ LCD control register 1
LCDBLKCTL=\$604;    \ LCD blink control register
LCDMEMCTL=\$606;    \ LCD memory control register
LCDVCTL=\$608;      \ LCD voltage control register
LCDPCTL0=\$60A;     \ LCD port control 0
LCDPCTL1=\$60C;     \ LCD port control 1
LCDPCTL2=\$60E;     \ LCD port control 2
LCDCSS0=\$614;      \ LCD COM/SEG select register
LCDCSS1=\$616;      \ LCD COM/SEG select register
LCDCSS2=\$618;      \ LCD COM/SEG select register
LCDIV=\$61E;        \ LCD interrupt vector
LCDM0=\$620;        \ LCD memory 0
LCDM1=\$621;        \ LCD memory 1
LCDM2=\$622;        \ LCD memory 2
LCDM3=\$623;        \ LCD memory 3
LCDM4=\$624;        \ LCD memory 4
LCDM5=\$625;        \ LCD memory 5
LCDM6=\$626;        \ LCD memory 6
LCDM7=\$627;        \ LCD memory 7
LCDM8=\$628;        \ LCD memory 8
LCDM9=\$629;        \ LCD memory 9
LCDM10=\$62A;       \ LCD memory 10
LCDM11=\$62B;       \ LCD memory 11
LCDM12=\$62C;       \ LCD memory 12
LCDM13=\$62D;       \ LCD memory 13
LCDM14=\$62E;       \ LCD memory 14
LCDM15=\$62F;       \ LCD memory 15
LCDM16=\$630;       \ LCD memory 16
LCDM17=\$631;       \ LCD memory 17
LCDM18=\$632;       \ LCD memory 18
LCDM19=\$633;       \ LCD memory 19
LCDM20=\$634;       \ LCD memory 20
LCDM21=\$635;       \ LCD memory 21
LCDM22=\$636;       \ LCD memory 22
LCDM23=\$637;       \ LCD memory 23
LCDM24=\$638;       \ LCD memory 24
LCDM25=\$639;       \ LCD memory 25
LCDM26=\$63A;       \ LCD memory 26
LCDM27=\$63B;       \ LCD memory 27
LCDM28=\$63C;       \ LCD memory 28
LCDM29=\$63D;       \ LCD memory 29
LCDM30=\$63E;       \ LCD memory 30
LCDM31=\$63F;       \ LCD memory 31
LCDM32=\$640;       \ LCD memory 32
LCDM33=\$641;       \ LCD memory 33
LCDM34=\$642;       \ LCD memory 34
LCDM35=\$643;       \ LCD memory 35
LCDM36=\$644;       \ LCD memory 36
LCDM37=\$645;       \ LCD memory 37
LCDM38=\$646;       \ LCD memory 38
LCDM39=\$647;       \ LCD memory 39
LCDBM0=\$640;       \ LCD blinking memory 0
LCDBM1=\$641;       \ LCD blinking memory 1
LCDBM2=\$642;       \ LCD blinking memory 2
LCDBM3=\$643;       \ LCD blinking memory 3
LCDBM4=\$644;       \ LCD blinking memory 4
LCDBM5=\$645;       \ LCD blinking memory 5
LCDBM6=\$646;       \ LCD blinking memory 6
LCDBM7=\$647;       \ LCD blinking memory 7
LCDBM8=\$648;       \ LCD blinking memory 8
LCDBM9=\$649;       \ LCD blinking memory 9
LCDBM10=\$64A;      \ LCD blinking memory 10
LCDBM11=\$64B;      \ LCD blinking memory 11
LCDBM12=\$64C;      \ LCD blinking memory 12
LCDBM13=\$64D;      \ LCD blinking memory 13
LCDBM14=\$64E;      \ LCD blinking memory 14
LCDBM15=\$64F;      \ LCD blinking memory 15
LCDBM16=\$650;      \ LCD blinking memory 16
LCDBM17=\$651;      \ LCD blinking memory 17
LCDBM18=\$652;      \ LCD blinking memory 18
LCDBM19=\$653;      \ LCD blinking memory 19


BAKMEM0=\$660;      \ Backup Memory 0
BAKMEM1=\$662;      \ Backup Memory 1
BAKMEM2=\$664;      \ Backup Memory 2
BAKMEM3=\$666;      \ Backup Memory 3
BAKMEM4=\$668;      \ Backup Memory 4
BAKMEM5=\$66A;      \ Backup Memory 5
BAKMEM6=\$66C;      \ Backup Memory 6
BAKMEM7=\$66E;      \ Backup Memory 7
BAKMEM8=\$670;      \ Backup Memory 8
BAKMEM9=\$672;      \ Backup Memory 9
BAKMEM10=\$674;     \ Backup Memory 10
BAKMEM11=\$676;     \ Backup Memory 11
BAKMEM12=\$678;     \ Backup Memory 12
BAKMEM13=\$67A;     \ Backup Memory 13
BAKMEM14=\$67C;     \ Backup Memory 14
BAKMEM15=\$67E;     \ Backup Memory 15



ADC10CTL0=\$700;    \ ADC10_B Control register 0
ADC10CTL1=\$702;    \ ADC10_B Control register 1
ADC10CTL2=\$704;    \ ADC10_B Control register 2
ADC10LO=\$706;      \ ADC10_B Window Comparator Low Threshold
ADC10HI=\$708;      \ ADC10_B Window Comparator High Threshold
ADC10MCTL0=\$70A;   \ ADC10_B Memory Control Register 0
ADC10MEM0=\$712;    \ ADC10_B Conversion Memory Register
ADC10IE=\$71A;      \ ADC10_B Interrupt Enable
ADC10IFG=\$71C;     \ ADC10_B Interrupt Flags
ADC10IV=\$71E;      \ ADC10_B Interrupt Vector Word

ADCON=\$10;
ADCSTART=\$03;

