!MSP430fr5948.pat

! ----------------------------------------------
! MSP430fr5948 MEMORY MAP
! ----------------------------------------------
! 0000-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
! 1800-19FF = INFO 512 B FRAM
! 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
! 1C00-23FF = RAM 2 KB
! 4400-FF7F = MAIN FRAM
! FF80-FFFF = interrupt vectors (FRAM 128 B)
! ----------------------------------------------

! ============================================
! BSL
! ============================================
BSL1=\$1000!

! ============================================
! FRAM INFO
! ============================================
INFO_ORG=\$1800!
INFO_LEN=\$0200!

! You can check the addresses below by comparing their values in DTCforthMSP430FRxxxx.lst
! those addresses are usable with the symbolic assembler
! ----------------------------------------------
! FastForth INFO
! ----------------------------------------------
FREQ_KHZ=\$1800!        FREQUENCY (in kHz)
TERMBRW_RST=\$1802!     TERMBRW_RST
TERMMCTLW_RST=\$1804!   TERMMCTLW_RST
I2CSLAVEADR=\$1802!     I2C_SLAVE address
I2CSLAVEADR1=\$1804!
LPM_MODE=\$1806!        LPM_MODE value, LPM0+GIE is the default value
USERSTIV=\$1808!        user SYS variable, defines software RESET, DEEP_RST, INIT_HARWARE, etc.
VERSION=\$180A!
THREADS=\$180C!         THREADS
KERNEL_ADDON=\$180E!    BIT15=FLOORED DIVISION
!                       BIT14=LF_XTAL
!                       BIT13=UART CTS
!                       BIT12=UART RTS
!                       BIT11=UART XON/XOFF
!                       BIT10=UART half duplex
!                       BIT9=I2C_TERMINAL
!                       BIT8=Q15.16 input
!                       BIT7=DOUBLE input
!                       BIT6=assembler 20 bits
!                       BIT5=assembler 16 bits
!                       BIT4=assembler 16 bits with 20 bits addr
!                       BIT3=vocabulary set
!                       BIT2=
!                       BIT1=
!                       BIT0=
!
DEEP_ORG=\$1810!        MOV #DEEP_ORG,X
DEEP_TERM_VEC=\$1810!   to DEEP_INIT TERMINAL vector
DEEP_COLD=\$1812!       to DEEP_INIT COLD_APP
DEEP_SOFT=\$1814!       to DEEP_INIT SOFT_APP
DEEP_HARD=\$1816!       to DEEP_INIT HARD_APP
DEEP_SLEEP=\$1818!      to DEEP_INIT SLEEP_APP
DEEP_DP=\$181A!         to DEEP_INIT RST_DP
DEEP_LASTVOC=\$181C!    to DEEP_INIT RST_LASTVOC
DEEP_CURRENT=\$181E!    to DEEP_INIT RST_CURRENT
DEEP_CONTEXT=\$1820!    to DEEP_INIT RST_CONTEXT
!
PUC_ABORT_ORG=\$1822!   MOV #PUC_ABORT_ORG,X
INIT_ACCEPT=\$1822!     to INIT PFA_ACCEPT
INIT_EMIT=\$1824!       to INIT PFA_EMIT
INIT_KEY=\$1826!        to INIT PFA_KEY
INIT_CIB=\$1828!        to INIT CIB_ORG
FORTH_ORG=\$182A!       MOV #FORTH_ORG,X        \to preserve the state of DEFERed words
INIT_RSP=\$182A!        to INIT RSP
INIT_DOCOL=\$182C!      to INIT rDOCOL   (R4) to restore rDOCOL: MOV &INIT_DOCOL,rDOCOL
INIT_DODOES=\$182E!     to INIT rDODOES  (R5)
INIT_DOCON=\$1830!      to INIT rDOCON   (R6)
INIT_DOVAR=\$1832!      to INIT rDOVAR   (R7)
INIT_CAPS=\$1834!       to INIT CAPS
INIT_BASE=\$1836!       to INIT BASE
INIT_LEAVE=\$1838!      to INIT LEAVEPTR
!
RST_ORG=\$183A!
RST_LEN=\$10!
COLD_APP=\$183A!        COLD_APP
SOFT_APP=\$183C!        SOFT_APP
HARD_APP=\$183E!        HARD_APP
SLEEP_APP=\$1840!       SLEEP_APP
RST_DP=\$1842!          RST_RET value for (RAM) DDP
RST_LASTVOC=\$1844!     RST_RET value for (RAM) LASTVOC
RST_CURRENT=\$1846!     RST_RET value for (RAM) CURRENT
RST_CONTEXT=\$1848!     RST_RET value for (RAM) CONTEXT (8 CELLS)
!
! $185A = free EPROM
!
! ============================================
! FRAM TLV
! ============================================
TLV_ORG=\$1A00!      ; Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN=\$0100!      ;
DEVICEID=\$1A04!

! ============================================
! RAM
! ============================================
RAM_ORG=\$1C00!
RAM_LEN=\$0800!

! ---------------------------------------
! FORTH RAM areas :
! ---------------------------------------
LSTACK_SIZE=\#16! words
PSTACK_SIZE=\#48! words
RSTACK_SIZE=\#48! words
PAD_LEN=\#84! bytes
CIB_LEN=\#84! bytes
HOLD_SIZE=\#34! bytes

! ---------------------------------------
! FastForth RAM memory map (>= 1k)
! ---------------------------------------
LEAVEPTR=\$1C00!        Leave-stack pointer, init by QUIT
LSATCK=\$1C00!          leave stack,      grow up
PSTACK=\$1C80!          parameter stack,  grow down
RSTACK=\$1CE0!          Return stack,     grow down
!
PAD_I2CADR=\$1CE0!      RX I2C address
PAD_I2CCNT=\$1CE2!      count max
PAD_ORG=\$1CE4!         user scratch pad buffer, 84 bytes, grow up
!
TIB_I2CADR=\$1D38!      TX I2C address
TIB_I2CCNT=\$1D3A!      count of bytes
TIB_ORG=\$1D3C!         Terminal input buffer, 84 bytes, grow up
!
HOLDS_ORG=\$1D90!       base address for HOLDS
HOLD_BASE=\$1DB2!       BASE HOLD area, grow down
!
HP=\$1DB2!              HOLD ptr
LAST_NFA=\$1DB4!
LAST_THREAD=\$1DB6!
LAST_CFA=\$1DB8!
LAST_PSP=\$1DBA!
!
STATEADR=\$1DBC!        Interpreter state
BASEADR=\$1DBE!         base
CAPS=\$1DC0!            CAPS ON/OFF
!
SOURCE_LEN=\$1DC2!      len of input stream
SOURCE_ORG=\$1DC4!      adr of input stream
TOIN=\$1DC6!            >IN
DP=\$1DC8!              dictionary ptr
!
LASTVOC=\$1DCA!         keep VOC-LINK
CURRENT=\$1DCC!         CURRENT dictionnary ptr
CONTEXT=\$1DCE!         CONTEXT dictionnary space (8 CELLS)
!
! ---------------------------------------
!1DE0! 28 RAM bytes free
! ---------------------------------------

! ---------------------------------------
! SD buffer
! ---------------------------------------
SD_BUF_I2ADR=\$1DFC!
SD_BUF_I2CNT=\$1DFE!
SD_BUF=\$1E00!      \ SD_Card buffer
BUFEND=\$2000!

! ---------------------------------------
! FAT16 FileSystemInfos
! ---------------------------------------
FATtype=\$2002!
BS_FirstSectorL=\$2004!
BS_FirstSectorH=\$2006!
OrgFAT1=\$2008!
FATSize=\$200A!
OrgFAT2=\$200C!
OrgRootDir=\$200E!
OrgClusters=\$2010!         Sector of Cluster 0
SecPerClus=\$2012!

! ---------------------------------------
! SD command
! ---------------------------------------
SD_CMD_FRM=\$2014!  6 bytes SD_CMDx inverted frame \${CRC,ll,LL,hh,HH,CMD}
SD_CMD_FRM0=\$2014! CRC:ll  word access
SD_CMD_FRM1=\$2015! ll      byte access
SD_CMD_FRM2=\$2016! LL:hh   word access
SD_CMD_FRM3=\$2017! hh      byte access
SD_CMD_FRM4=\$2018! HH:CMD  word access
SD_CMD_FRM5=\$2019! CMD     byte access
SectorL=\$201A!     2 words
SectorH=\$201C!

! ---------------------------------------
! BUFFER management
! ---------------------------------------
BufferPtr=\$201E!
BufferLen=\$2020!

! ---------------------------------------
! FAT entry
! ---------------------------------------
ClusterL=\$2022!     16 bits wide (FAT16)
ClusterH=\$2024!     16 bits wide (FAT16)
LastFATsector=\$2026!   Set by FreeAllClusters, used by OPEN_OVERWRITE
LastFAToffset=\$2028!   Set by FreeAllClusters, used by OPEN_OVERWRITE
FATsector=\$202A!       used by APPEND"

! ---------------------------------------
! DIR entry
! ---------------------------------------
DIRclusterL=\$202C!  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$202E!  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$2030!

! ---------------------------------------
! Handle Pointer
! ---------------------------------------
CurrentHdl=\$2032!  contains the address of the last opened file structure, or 0

! ---------------------------------------
! Load file operation
! ---------------------------------------
pathname=\$2034!
EndOfPath=\$2036!

! ---------------------------------------
! Handle structure
! ---------------------------------------
! three handle tokens :
! token = 0 : free handle
! token = 1 : file to read
! token = 2 : file updated (write)
! token =-1 : LOAD"ed file (source file)

! offset values
HDLW_PrevHDL=0!     previous handle ; used by LOAD"
HDLB_Token=2!       token
HDLB_ClustOfst=3!   Current sector offset in current cluster (Byte)
HDLL_DIRsect=4!     Dir SectorL (Long)
HDLH_DIRsect=6!
HDLW_DIRofst=8!     BUFFER offset of Dir entry
HDLL_FirstClus=10!  File First ClusterLo (identify the file)
HDLH_FirstClus=12!  File First ClusterHi (byte)
HDLL_CurClust=14!   Current ClusterLo
HDLH_CurClust=16!   Current ClusterHi (T as 3Th byte)
HDLL_CurSize=18!    written size / not yet read size (Long)
HDLH_CurSize=20!    written size / not yet read size (Long)
HDLW_BUFofst=22!    BUFFER offset ; used by LOAD" and by WRITE"
HDLW_PrevLEN=24!    previous LEN
HDLW_PrevORG=26!    previous ORG


!OpenedFirstFile     ; "openedFile" structure
HandleMax=8!
HandleLenght=28!
FirstHandle=\$2038!
HandleEnd=\$2118!

!SD_card Input Buffer
SDIB_I2CADR=\$2118!
SDIB_I2CCNT=\$211A!
SDIB_ORG=\$251C!
SDIB_LEN=\$54!

SD_END=\$2170!
SD_LEN=\$16E!

! ============================================
! FRAM MAIN
! ============================================
MAIN_ORG=\$4400!        Code space start
MAIN_LEN=\$BC00!        47 k FRAM
! ----------------------------------------------

SLEEP=\$4400!               CODE_WITHOUT_RETURN, CPU shutdown
LIT=\$440A!                 CODE compiled by LITERAL
XSQUOTE=\$441E!             CODE compiled by S" and S_
HEREXEC=\$4432!             CODE HERE and BEGIN execute address
MUSMOD=\$443E!              asm CODE 32/16 unsigned division, used by ?NUMBER, UM/MOD
MDIV1DIV2=\$4450!           asm CODE input for 48/16 unsigned division with DVDhi=0, see DOUBLE M*/
MDIV1=\$4458!               asm CODE input for 48/16 unsigned division, see DOUBLE M*/
RET_ADR=\$4482!             asm CODE of INIT_SOFT_PFA and MARKER+8 definitions,
SETIB=\$4484!               CODE Set Input Buffer with org & len values, reset >IN pointer
REFILL=\$4494!              CODE accept one line from input and leave org len of input buffer
CIB_ORG=\$44A0!             [CIB_ORG] = TIB_ORG by default; may be redirected to SDIB_ORG
QFBRAN=\$44AC!              CODE compiled by IF UNTIL
BRAN=\$44B2!                CODE compiled by ELSE REPEAT AGAIN
NEXT_ADR=\$44B4!            CODE NEXT instruction (MOV @IP+,PC)
XDODOES=\$44B6!             to restore rDODOES: MOV #XDODOES,rDODOES
XDOCON=\$44C4!              to restore rDOCON: MOV #XDOCON,rDOCON
!                           to restore rDOVAR: MOV &INIT_DOVAR,rDOVAR
!                           to restore rDOCOL: MOV &INIT_DOCOL,rDOCOL
INIT_FORTH=\$44D0!          asm CODE common part of RST and QABORT, starts FORTH engine
QABORT=\$4508!              CODE_WITHOUT_RETURN run-time part of ABORT"
ABORT_TERM=\$4512!          CODE_WITHOUT_RETURN, called by QREVEAL and INTERPRET
!-------------------------------------------------------------------------------
! UART FASTFORTH
!-------------------------------------------------------------------------------
UART_INIT_TERM=\$4554!      asm CODE, content of WARM+2 by default (WARM starts with: CALL &HARD_APP)
UART_COLD_TERM=\$457E!      asm CODE, content of COLD+2 by default (COLD starts with: CALL &STOP_APP)
UART_INIT_SOFT=\$4584!      asm CODE, content of SLEEP+2 (by default, SLEEP starts with: CALL &SOFT_APP)
UART_WARM=\$4586!           WARM address
UART_RXON=KEY\+\$8!         asm CODE, content of SLEEP+2 (by default, SLEEP starts with: CALL &SLEEP_APP)
UART_RXOFF=ACCEPT\+\$2A!    asm CODE, called by ACCEPT after 'CR' and before 'LF'.
!-------------------------------------------------------------------------------
! I2C FASTFORTH
!-------------------------------------------------------------------------------
I2C_ACCEPT=\$4544!          asm CODE, default content of SLEEP_APP (SLEEP starts with: CALL &SLEEP_APP)
I2C_CTRL_CH=\$4546!         asm CODE, used as is: MOV.B #CTRL_CHAR,Y
!                                                 CALL #I2C_CTRL_CH
I2C_COLD_TERM=\$4550!       asm CODE, default content of STOP_APP (COLD starts with: CALL &STOP_APP)
I2C_INIT_SOFT=\$4550!       asm CODE, default content of SOFT_APP (INIT_FORTH starts with: CALL &SOFT_APP)
I2C_INIT_TERM=\$4552!       asm CODE, default content of HARD_APP (WARM starts with: CALL &HARD_APP)
I2C_WARM=\$457A!            WARM address
!-------------------------------------------------------------------------------
NOPUC=SYS\+\$0A!            NOPUC               with FORTH: ' SYS 10 +
COLD=SYS\+\$16!             COLD address                    ' SYS 22 +
ABORT=ALLOT\+\$8!           CODE_WITHOUT_RETURN             ' ALLOT 8 +
QUIT=ALLOT\+\$0E!           CODE_WITHOUT_RETURN             ' ALLOT 14 +

! ----------------------------------------------
! Interrupt Vectors and signatures - MSP430FR5948
! ----------------------------------------------
FRAM_FULL=\$FF40!       64 bytes are sufficient considering what can be compiled in one line and WORD use.
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2=\$FF82!       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84!
BSL_SIG2=\$FF86!
I2CSLA0=\$FFA2!         UCBxI2COA0 default value address
I2CSLA1=\$FFA4!         UCBxI2COA1 default value address
I2CSLA2=\$FFA6!         UCBxI2COA2 default value address
I2CSLA3=\$FFA8!         UCBxI2COA3 default value address
JTAG_PASSWORD=\$FF88!   256 bits
BSL_PASSWORD=\$FFE0!    256 bits
VECT_ORG=\$FFCC!        FFCC-FFFF
VECT_LEN=\$34!


AES_VEC=\$FFCC!
RTC_VEC=\$FFCE!
P4_VEC=\$FFD0!
P3_VEC=\$FFD2!
TB2_X_VEC=\$FFD4!
TB2_0_VEC=\$FFD6!
P2_VEC=\$FFD8!
TB1_X_VEC=\$FFDA!
TB1_0_VEC=\$FFDC!
P1_VEC=\$FFDE!
TA1_X_VEC=\$FFE0!
TA1_0_VEC=\$FFE2!
DMA_VEC=\$FFE4!
EUSCI_A1_VEC=\$FFE6!
TA0_X_VEC=\$FFE8!
TA0_0_VEC=\$FFEA!
ADC12_B_VEC=\$FFEC!
EUSCI_B0_VEC=\$FFEE!
EUSCI_A0_VEC=\$FFF0!
WDT_VEC=\$FFF2!
TB0_X_VEC=\$FFF4!
TB0_0_VEC=\$FFF6!
COMP_D_VEC=\$FFF8!
U_NMI_VEC=\$FFFA!
S_NMI_VEC=\$FFFC!
RST_VEC=\$FFFE!

! ============================================
! Special Fonction Registers (SFR)
! ============================================

SFRIE1=\$100!       \ SFR enable register
SFRIFG1=\$102!      \ SFR flag register
SFRRPCR=\$104!      \ SFR reset pin control

PMMCTL0=\$120!      \ PMM Control 0
PMMIFG=\$12A!       \ PMM interrupt flags
PM5CTL0=\$130!      \ PM5 Control 0

FRCTLCTL0=\$140!    \ FRAM control 0
GCCTL0=\$144!       \ General control 0
GCCTL1=\$146!       \ General control 1

CRC16DI=\$150!      \ CRC data input
CRCDIRB=\$152!      \ CRC data input reverse byte
CRCINIRES=\$154!    \ CRC initialization and result
CRCRESR=\$156!      \ CRC result reverse byte

WDTCTL=\$15C!        \ WDT control register

CSCTL0=\$160!       \ CS control 0
CSCTL1=\$162!       \ CS control 1
CSCTL2=\$164!       \ CS control 2
CSCTL3=\$166!       \ CS control 3
CSCTL4=\$168!       \ CS control 4
CSCTL5=\$16A!       \ CS control 5
CSCTL6=\$16C!       \ CS control 6

SYSCTL=\$180!       \ System control
SYSJMBC=\$186!      \ JTAG mailbox control
SYSJMBI0=\$188!     \ JTAG mailbox input 0
SYSJMBI1=\$18A!     \ JTAG mailbox input 1
SYSJMBO0=\$18C!     \ JTAG mailbox output 0
SYSJMBO1=\$18E!     \ JTAG mailbox output 1
SYSUNIV=\$19A!      \ User NMI vector generator
SYSSNIV=\$19C!      \ System NMI vector generator
SYSRSTIV=\$19E!     \ Reset vector generator

REFCTL=\$1B0!       \ Shared reference control

PAIN=\$200!
PAOUT=\$202!
PADIR=\$204!
PAREN=\$206!
PASEL0=\$20A!
PASEL1=\$20C!
PASELC=\$216!
PAIES=\$218!
PAIE=\$21A!
PAIFG=\$21C!

P1IN=\$200!
P1OUT=\$202!
P1DIR=\$204!
P1REN=\$206!
P1SEL0=\$20A!
P1SEL1=\$20C!
P1IV=\$20E!
P1SELC=\$216!
P1IES=\$218!
P1IE=\$21A!
P1IFG=\$21C!

P2IN=\$201!
P2OUT=\$203!
P2DIR=\$205!
P2REN=\$207!
P2SEL0=\$20B!
P2SEL1=\$20D!
P2SELC=\$217!
P2IES=\$219!
P2IE=\$21B!
P2IFG=\$21D!
P2IV=\$21E!

PBIN=\$220!
PBOUT=\$222!
PBDIR=\$224!
PBREN=\$226!
PBSEL0=\$22A!
PBSEL1=\$22C!
PBSELC=\$236!
PBIES=\$238!
PBIE=\$23A!
PBIFG=\$23C!

P3IN=\$220!
P3OUT=\$222!
P3DIR=\$224!
P3REN=\$226!
P3SEL0=\$22A!
P3SEL1=\$22C!
P3IV=\$22E!
P3SELC=\$236!
P3IES=\$238!
P3IE=\$23A!
P3IFG=\$23C!

P4IN=\$221!
P4OUT=\$223!
P4DIR=\$225!
P4REN=\$227!
P4SEL0=\$22B!
P4SEL1=\$22D!
P4SELC=\$237!
P4IES=\$239!
P4IE=\$23B!
P4IFG=\$23D!
P4IV=\$23E!

PJIN=\$320!
PJOUT=\$322!
PJDIR=\$324!
PJREN=\$326!
PJSEL0=\$32A!
PJSEL1=\$32C!
PJSELC=\$336!


TACLR=4!
TAIFG=1!
TBCLR=2!
TBIFG=1!
CCIFG=1!

TA0CTL=\$340!       \ TA0 control
TA0CCTL0=\$342!     \ Capture/compare control 0
TA0CCTL1=\$344!     \ Capture/compare control 1
TA0CCTL2=\$346!     \ Capture/compare control 2
TA0R=\$350!         \ TA0 counter register
TA0CCR0=\$352!      \ Capture/compare register 0
TA0CCR1=\$354!      \ Capture/compare register 1
TA0CCR2=\$356!      \ Capture/compare register 2
TA0EX0=\$360!       \ TA0 expansion register 0
TA0IV=\$36E!        \ TA0 interrupt vector

TA1CTL=\$380!       \ TA1 control
TA1CCTL0=\$382!     \ Capture/compare control 0
TA1CCTL1=\$384!     \ Capture/compare control 1
TA1CCTL2=\$386!     \ Capture/compare control 2
TA1R=\$390!         \ TA1 counter register
TA1CCR0=\$392!      \ Capture/compare register 0
TA1CCR1=\$394!      \ Capture/compare register 1
TA1CCR2=\$396!      \ Capture/compare register 2
TA1EX0=\$3A0!       \ TA1 expansion register 0
TA1IV=\$3AE!        \ TA1 interrupt vector

TB0CTL=\$3C0!       \ TB0 control
TB0CCTL0=\$3C2!     \ Capture/compare control 0
TB0CCTL1=\$3C4!     \ Capture/compare control 1
TB0CCTL2=\$3C6!     \ Capture/compare control 2
TB0CCTL3=\$3C8!     \ Capture/compare control 3
TB0CCTL4=\$3CA!     \ Capture/compare control 4
TB0CCTL5=\$3CC!     \ Capture/compare control 5
TB0CCTL6=\$3CE!     \ Capture/compare control 6
TB0R=\$3D0!         \ TB0 counter register
TB0CCR0=\$3D2!      \ Capture/compare register 0
TB0CCR1=\$3D4!      \ Capture/compare register 1
TB0CCR2=\$3D6!      \ Capture/compare register 2
TB0CCR3=\$3D8!      \ Capture/compare register 3
TB0CCR5=\$3DA!      \ Capture/compare register 4
TB0CCR5=\$3DC!      \ Capture/compare register 5
TB0CCR6=\$3DE!      \ Capture/compare register 6
TB0EX0=\$3E0!       \ TB0 expansion register 0
TB0IV=\$3EE!        \ TB0 interrupt vector

TA2CTL=\$400!       \ TA2 control
TA2CCTL0=\$402!     \ Capture/compare control 0
TA2CCTL1=\$404!     \ Capture/compare control 1
TA2R=\$410!         \ TA2 counter register
TA2CCR0=\$412!      \ Capture/compare register 0
TA2CCR1=\$414!      \ Capture/compare register 1
TA2EX0=\$420!       \ TA2 expansion register 0
TA2IV=\$42E!        \ TA2 interrupt vector

TA3CTL=\$440!       \ TA3 control
TA3CCTL0=\$442!     \ Capture/compare control 0
TA3CCTL1=\$444!     \ Capture/compare control 1
TA3R=\$450!         \ TA3 counter register
TA3CCR0=\$452!      \ Capture/compare register 0
TA3CCR1=\$454!      \ Capture/compare register 1
TA3EX0=\$460!       \ TA3 expansion register 0
TA3IV=\$46E!        \ TA3 interrupt vector

!                   \ RTC_B
RTCCTL0=\$4A0!      \ RTC control 0
RTCCTL1=\$4A1!      \ RTC control 1
RTCCTL2=\$4A2!      \ RTC control 2
RTCCTL3=\$4A3!      \ RTC control 3
RTCPS0CTL=\$4A8!    \ RTC prescaler 0 control
RTCPS1CTL=\$4AA!    \ RTC prescaler 1 control
RTCPS0=\$4AC!       \ RTC prescaler 0
RTCPS1=\$4AD!       \ RTC prescaler 1
RTCIV=\$4AE!        \ RTC interrupt vector word
RTCSEC=\$4B0!       \ RTC seconds, RTC counter register 1 RTCSEC,
RTCMIN=\$4B1!       \ RTC minutes, RTC counter register 2 RTCMIN,
RTCHOUR=\$4B2!      \ RTC hours, RTC counter register 3 RTCHOUR,
RTCDOW=\$4B3!       \ RTC day of week, RTC counter register 4 RTCDOW,
RTCDAY=\$4B4!       \ RTC days
RTCMON=\$4B5!       \ RTC month
RTCYEAR=\$4B6!
RTCYEARL=\$4B6!     \ RTC year low
RTCYEARH=\$4B7!     \ RTC year high
RTCAMIN=\$4B8!      \ RTC alarm minutes
RTCAHOUR=\$4B9!     \ RTC alarm hours
RTCADOW=\$4BA!      \ RTC alarm day of week
RTCADAY=\$4BB!      \ RTC alarm days
BIN2BCD=\$4BC!      \ Binary-to-BCD conversion register
BCD2BIN=\$4BE!      \ BCD-to-binary conversion register
RTCHOLD=\$40!
RTCRDY=\$10!

MPY=\$4C0!          \ 16-bit operand 1 - multiply
MPYS=\$4C2!         \ 16-bit operand 1 - signed multiply
MAC=\$4C4!          \ 16-bit operand 1 - multiply accumulate
MACS=\$4C6!         \ 16-bit operand 1 - signed multiply accumulate
OP2=\$4C8!          \ 16-bit operand 2
RESLO=\$4CA!        \ 16 x 16 result low word
RESHI=\$4CC!        \ 16 x 16 result high word
SUMEXT=\$4CE!       \ 16 x 16 sum extension register
MPY32L=\$4D0!       \ 32-bit operand 1 - multiply low word
MPY32H=\$4D2!       \ 32-bit operand 1 - multiply high word
MPYS32L=\$4D4!      \ 32-bit operand 1 - signed multiply low word
MPYS32H=\$4D6!      \ 32-bit operand 1 - signed multiply high word
MAC32L=\$4D8!       \ 32-bit operand 1 - multiply accumulate low word
MAC32H=\$4DA!       \ 32-bit operand 1 - multiply accumulate high word
MACS32L=\$4DC!      \ 32-bit operand 1 - signed multiply accumulate low word
MACS32H=\$4DE!      \ 32-bit operand 1 - signed multiply accumulate high word
OP2L=\$4E0!         \ 32-bit operand 2 - low word
OP2H=\$4E2!         \ 32-bit operand 2 - high word
RES0=\$4E4!         \ 32 x 32 result 0 - least significant word
RES1=\$4E6!         \ 32 x 32 result 1
RES2=\$4E8!         \ 32 x 32 result 2
RES3=\$4EA!         \ 32 x 32 result 3 - most significant word
MPY32CTL0=\$4EC!    \ MPY32 control register 0

DMAIFG=8!

DMACTL0=\$500!      \ DMA module control 0
DMACTL1=\$502!      \ DMA module control 1
DMACTL2=\$504!      \ DMA module control 2
DMACTL3=\$506!      \ DMA module control 3
DMACTL4=\$508!      \ DMA module control 4
DMAIV=\$50A!        \ DMA interrupt vector

DMA0CTL=\$510!      \ DMA channel 0 control
DMA0SAL=\$512!      \ DMA channel 0 source address low
DMA0SAH=\$514!      \ DMA channel 0 source address high
DMA0DAL=\$516!      \ DMA channel 0 destination address low
DMA0DAH=\$518!      \ DMA channel 0 destination address high
DMA0SZ=\$51A!       \ DMA channel 0 transfer size

DMA1CTL=\$520!      \ DMA channel 1 control
DMA1SAL=\$522!      \ DMA channel 1 source address low
DMA1SAH=\$524!      \ DMA channel 1 source address high
DMA1DAL=\$526!      \ DMA channel 1 destination address low
DMA1DAH=\$528!      \ DMA channel 1 destination address high
DMA1SZ=\$52A!       \ DMA channel 1 transfer size

DMA2CTL=\$530!      \ DMA channel 2 control
DMA2SAL=\$532!      \ DMA channel 2 source address low
DMA2SAH=\$534!      \ DMA channel 2 source address high
DMA2DAL=\$536!      \ DMA channel 2 destination address low
DMA2DAH=\$538!      \ DMA channel 2 destination address high
DMA2SZ=\$53A!       \ DMA channel 2 transfer size


MPUCTL0=\$5A0!      \ MPU control 0
MPUCTL1=\$5A2!      \ MPU control 1
MPUSEGB2=\$5A4!     \ MPU Segmentation Border2
MPUSEGB1=\$5A6!     \ MPU Segmentation Border1
MPUSAM=\$5A8!       \ MPU access management
MPUIPC0=\$5AA!      \ MPU IP control 0
MPUIPSEGB2=\$5AC!   \ MPU IP Encapsulation Segment Border 2
MPUIPSEGB1=\$5AE!   \ MPU IP Encapsulation Segment Border 1

UCA0CTLW0=\$5C0!    \ eUSCI_A control word 0
UCA0CTLW1=\$5C2!    \ eUSCI_A control word 1
UCA0BRW=\$5C6!
UCA0BR0=\$5C6!      \ eUSCI_A baud rate 0
UCA0BR1=\$5C7!      \ eUSCI_A baud rate 1
UCA0MCTLW=\$5C8!    \ eUSCI_A modulation control
UCA0STAT=\$5CA!     \ eUSCI_A status
UCA0RXBUF=\$5CC!    \ eUSCI_A receive buffer
UCA0TXBUF=\$5CE!    \ eUSCI_A transmit buffer
UCA0ABCTL=\$5D0!    \ eUSCI_A LIN control
UCA0IRTCTL=\$5D2!   \ eUSCI_A IrDA transmit control
UCA0IRRCTL=\$5D3!   \ eUSCI_A IrDA receive control
UCA0IE=\$5DA!       \ eUSCI_A interrupt enable
UCA0IFG=\$5DC!      \ eUSCI_A interrupt flags
UCA0IV=\$5DE!       \ eUSCI_A interrupt vector word

UCA1CTLW0=\$5E0!    \ eUSCI_A control word 0
UCA1CTLW1=\$5E2!    \ eUSCI_A control word 1
UCA1BRW=\$5E6!
UCA1BR0=\$5E6!      \ eUSCI_A baud rate 0
UCA1BR1=\$5E7!      \ eUSCI_A baud rate 1
UCA1MCTLW=\$5E8!    \ eUSCI_A modulation control
UCA1STAT=\$5EA!     \ eUSCI_A status
UCA1RXBUF=\$5EC!    \ eUSCI_A receive buffer
UCA1TXBUF=\$5EE!    \ eUSCI_A transmit buffer
UCA1ABCTL=\$5F0!    \ eUSCI_A LIN control
UCA1IRTCTL=\$5F2!   \ eUSCI_A IrDA transmit control
UCA1IRRCTL=\$5F3!   \ eUSCI_A IrDA receive control
UCA1IE=\$5FA!       \ eUSCI_A interrupt enable
UCA1IFG=\$5FC!      \ eUSCI_A interrupt flags
UCA1IV=\$5FE!       \ eUSCI_A interrupt vector word

UCB0CTLW0=\$640!    \ eUSCI_B control word 0
UCB0CTLW1=\$642!    \ eUSCI_B control word 1
UCB0BRW=\$646!
UCB0BR0=\$646!      \ eUSCI_B bit rate 0
UCB0BR1=\$647!      \ eUSCI_B bit rate 1
UCB0STATW=\$648!    \ eUSCI_B status word
UCBCNT0=\$649!      \ eUSCI_B hardware count
UCB0TBCNT=\$64A!    \ eUSCI_B byte counter threshold
UCB0RXBUF=\$64C!    \ eUSCI_B receive buffer
UCB0TXBUF=\$64E!    \ eUSCI_B transmit buffer
UCB0I2COA0=\$654!   \ eUSCI_B I2C own address 0
UCB0I2COA1=\$656!   \ eUSCI_B I2C own address 1
UCB0I2COA2=\$658!   \ eUSCI_B I2C own address 2
UCB0I2COA3=\$65A!   \ eUSCI_B I2C own address 3
UCB0ADDRX=\$65C!    \ eUSCI_B received address
UCB0ADDMASK=\$65E!  \ eUSCI_B address mask
UCB0I2CSA=\$660!    \ eUSCI I2C slave address
UCB0IE=\$66A!       \ eUSCI interrupt enable
UCB0IFG=\$66C!      \ eUSCI interrupt flags
UCB0IV=\$66E!       \ eUSCI interrupt vector word

UCTXACK=\$20!
UCTR=\$10!


ADC12CTL0=\$800!    \ ADC12_B Control 0
ADC12CTL1=\$802!    \ ADC12_B Control 1
ADC12CTL2=\$804!    \ ADC12_B Control 2
ADC12CTL3=\$806!    \ ADC12_B Control 3
ADC12LO=\$808!      \ ADC12_B Window Comparator Low Threshold Register
ADC12HI=\$80A!      \ ADC12_B Window Comparator High Threshold Register
ADC12IFGR0=\$80C!   \ ADC12_B Interrupt Flag Register 0
ADC12IFGR1=\$80E!   \ ADC12_B Interrupt Flag Register 1
ADC12IFGR2=\$810!   \ ADC12_B Interrupt Flag Register 2
ADC12IER0=\$812!    \ ADC12_B Interrupt Enable Register 0
ADC12IER1=\$814!    \ ADC12_B Interrupt Enable Register 1
ADC12IER2=\$816!    \ ADC12_B Interrupt Enable Register 2
ADC12IV=\$818!      \ ADC12_B Interrupt Vector
ADC12MCTL0=\$820!   \ ADC12_B Memory Control 0
ADC12MCTL1=\$822!   \ ADC12_B Memory Control 1
ADC12MCTL2=\$824!   \ ADC12_B Memory Control 2
ADC12MCTL3=\$826!   \ ADC12_B Memory Control 3
ADC12MCTL4=\$828!   \ ADC12_B Memory Control 4
ADC12MCTL5=\$82A!   \ ADC12_B Memory Control 5
ADC12MCTL6=\$82C!   \ ADC12_B Memory Control 6
ADC12MCTL7=\$82E!   \ ADC12_B Memory Control 7
ADC12MCTL8=\$830!   \ ADC12_B Memory Control 8
ADC12MCTL9=\$832!   \ ADC12_B Memory Control 9
ADC12MCTL10=\$834!  \ ADC12_B Memory Control 10
ADC12MCTL11=\$836!  \ ADC12_B Memory Control 11
ADC12MCTL12=\$838!  \ ADC12_B Memory Control 12
ADC12MCTL13=\$83A!  \ ADC12_B Memory Control 13
ADC12MCTL14=\$83C!  \ ADC12_B Memory Control 14
ADC12MCTL15=\$83E!  \ ADC12_B Memory Control 15
ADC12MCTL16=\$840!  \ ADC12_B Memory Control 16
ADC12MCTL17=\$842!  \ ADC12_B Memory Control 17
ADC12MCTL18=\$844!  \ ADC12_B Memory Control 18
ADC12MCTL19=\$846!  \ ADC12_B Memory Control 19
ADC12MCTL20=\$848!  \ ADC12_B Memory Control 20
ADC12MCTL21=\$84A!  \ ADC12_B Memory Control 21
ADC12MCTL22=\$84C!  \ ADC12_B Memory Control 22
ADC12MCTL23=\$84E!  \ ADC12_B Memory Control 23
ADC12MCTL24=\$850!  \ ADC12_B Memory Control 24
ADC12MCTL25=\$852!  \ ADC12_B Memory Control 25
ADC12MCTL26=\$854!  \ ADC12_B Memory Control 26
ADC12MCTL27=\$856!  \ ADC12_B Memory Control 27
ADC12MCTL28=\$858!  \ ADC12_B Memory Control 28
ADC12MCTL29=\$85A!  \ ADC12_B Memory Control 29
ADC12MCTL30=\$85C!  \ ADC12_B Memory Control 30
ADC12MCTL31=\$85E!  \ ADC12_B Memory Control 31
ADC12MEM0=\$860!    \ ADC12_B Memory 0
ADC12MEM1=\$862!    \ ADC12_B Memory 1
ADC12MEM2=\$864!    \ ADC12_B Memory 2
ADC12MEM3=\$866!    \ ADC12_B Memory 3
ADC12MEM4=\$868!    \ ADC12_B Memory 4
ADC12MEM5=\$86A!    \ ADC12_B Memory 5
ADC12MEM6=\$86C!    \ ADC12_B Memory 6
ADC12MEM7=\$86E!    \ ADC12_B Memory 7
ADC12MEM8=\$870!    \ ADC12_B Memory 8
ADC12MEM9=\$872!    \ ADC12_B Memory 9
ADC12MEM10=\$874!   \ ADC12_B Memory 10
ADC12MEM11=\$876!   \ ADC12_B Memory 11
ADC12MEM12=\$878!   \ ADC12_B Memory 12
ADC12MEM13=\$87A!   \ ADC12_B Memory 13
ADC12MEM14=\$87C!   \ ADC12_B Memory 14
ADC12MEM15=\$87E!   \ ADC12_B Memory 15
ADC12MEM16=\$880!   \ ADC12_B Memory 16
ADC12MEM17=\$882!   \ ADC12_B Memory 17
ADC12MEM18=\$884!   \ ADC12_B Memory 18
ADC12MEM19=\$886!   \ ADC12_B Memory 19
ADC12MEM20=\$888!   \ ADC12_B Memory 20
ADC12MEM21=\$88A!   \ ADC12_B Memory 21
ADC12MEM22=\$88C!   \ ADC12_B Memory 22
ADC12MEM23=\$88E!   \ ADC12_B Memory 23
ADC12MEM24=\$890!   \ ADC12_B Memory 24
ADC12MEM25=\$892!   \ ADC12_B Memory 25
ADC12MEM26=\$894!   \ ADC12_B Memory 26
ADC12MEM27=\$896!   \ ADC12_B Memory 27
ADC12MEM28=\$898!   \ ADC12_B Memory 28
ADC12MEM29=\$89A!   \ ADC12_B Memory 29
ADC12MEM30=\$89C!   \ ADC12_B Memory 30
ADC12MEM31=\$89E!   \ ADC12_B Memory 31

ADCON=\$10!
ADCSTART=\$03!

CDIFG=1!
CDIIFG=2!

CDCTL0=\$8C0!       \ Comparator_E control register 0
CDCTL1=\$8C2!       \ Comparator_E control register 1
CDCTL2=\$8C4!       \ Comparator_E control register 2
CDCTL3=\$8C6!       \ Comparator_E control register 3
CDINT=\$8CC!        \ Comparator_E interrupt register
CDIV=\$8CE!         \ Comparator_E interrupt vector word


AESACTL0=\$9C0!     \ AES accelerator control register 0
AESASTAT=\$9C4!     \ AES accelerator status register
AESAKEY=\$9C6!      \ AES accelerator key register
AESADIN=\$9C8!      \ AES accelerator data in register
AESADOUT=\$9CA!     \ AES accelerator data out register
AESAXDIN=\$9CC!     \ AES accelerator XORed data in register
AESAXIN =\$9CE!     \ AES accelerator XORed data in register (no trigger)

