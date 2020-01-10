!MSP430fr5739.pat

! ----------------------------------------------
! MSP430FR5739 MEMORY MAP
! ----------------------------------------------
! 0000-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
! 1800-187F = info B (FRAM 128 B)
! 1880-18FF = info A (FRAM 128 B)
! 1900-19FF = N/A (mirrored into info A/B)
! 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
! 1A80-1BFF = unused (385 B)
! 1C00-1FFF = RAM (1 KB)
! 2000-C1FF = unused (41472 B)
! C200-FF7F = code memory (FRAM 15743 B)
! FF80-FFFF = interrupt vectors (FRAM 127 B)
! ----------------------------------------------

! ============================================
! BSL
! ============================================
BSL1=\$1000!

! ============================================
! FRAM INFO
! ============================================
INFO_ORG=\$1800!
INFO_LEN=\$0100!

! You can check the addresses below by comparing their values in DTCforthMSP430FRxxxx.lst
! those addresses are usable with the symbolic assembler

! ============================================
! FastForth INFO(DCBA) memory map (256 bytes):
! ============================================

INI_THREAD=\$1800!      .word THREADS
TERMBRW_RST=\$1802!     .word TERMBRW_RST
TERMMCTLW_RST=\$1804!   .word TERMMCTLW_RST
FREQ_KHZ=\$1806!        .word FREQUENCY

SAVE_SYSRSTIV=\$1808!   to enable SYSRSTIV read
LPM_MODE=\$180A!        LPM0+GIE is the default mode
INIDP=\$180C!           define RST_STATE, init by wipe
INIVOC=\$180E!          define RST_STATE, init by wipe
VERSION=\$1810!
KERNEL_ADDON=\$1812!
RXON=\$1814!
RXOFF=\$1816!
ReadSectorWX=\$1818!    call with W = SectorLO  X = SectorHI
WriteSectorWX=\$181A!   call with W = SectorLO  X = SectorHI
TERMINAL_INT=\$181C!    value for TERMINAL vector

! ---------------------------------------
! FAT16 FileSystemInfos 
! ---------------------------------------
FATtype=\$182C!
BS_FirstSectorL=\$182E!
BS_FirstSectorH=\$1830!
OrgFAT1=\$1832!
FATSize=\$1834!
OrgFAT2=\$1836!
OrgRootDir=\$1838!
OrgClusters=\$183A!         Sector of Cluster 0
SecPerClus=\$183C!

! ---------------------------------------
! SD command
! ---------------------------------------
SD_CMD_FRM=\$183E!  6 bytes SD_CMDx inverted frame \${CRC,ll,LL,hh,HH,CMD}
SD_CMD_FRM0=\$183E! CRC:ll  word access
SD_CMD_FRM1=\$183F! ll      byte access
SD_CMD_FRM2=\$1840! LL:hh   word access
SD_CMD_FRM3=\$1841! hh      byte access
SD_CMD_FRM4=\$1842! HH:CMD  word access
SD_CMD_FRM5=\$1843! CMD     byte access
SectorL=\$1844!     2 words
SectorH=\$1846!

! ---------------------------------------
! BUFFER management
! ---------------------------------------
BufferPtr=\$1848! 
BufferLen=\$184A!

! ---------------------------------------
! FAT entry
! ---------------------------------------
ClusterL=\$184C!     16 bits wide (FAT16)
ClusterH=\$184E!     16 bits wide (FAT16)
NewClusterL=\$1850!  16 bits wide (FAT16) 
NewClusterH=\$1852!  16 bits wide (FAT16) 
CurFATsector=\$1854!

! ---------------------------------------
! DIR entry
! ---------------------------------------
DIRclusterL=\$1856!  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$1858!  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$185A!  

! ---------------------------------------
! Handle Pointer
! ---------------------------------------
CurrentHdl=\$185C!  contains the address of the last opened file structure, or 0

! ---------------------------------------
! Load file operation
! ---------------------------------------
pathname=\$185E!    address of pathname string
EndOfPath=\$1860!

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
HandleMax=5!
HandleLenght=28!
FirstHandle=\$1862!
HandleEnd=\$18EE!

SD_END=\$18EE!
SD_LEN=\$C2!

! ============================================
! FRAM TLV
! ============================================
TLV_ORG=\$1A00!         Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN=\$0080!
DEVICEID=\$1A04!

! ============================================
! RAM
! ============================================
RAM_ORG=\$1C00!
RAM_LEN=\$0400!

! ---------------------------------------
! FORTH RAM areas :
! ---------------------------------------
LSTACK_SIZE=\#16! words
PSTACK_SIZE=\#48! words
RSTACK_SIZE=\#48! words
PAD_LEN=\#84! bytes
TIB_LEN=\#84! bytes
HOLD_SIZE=\#34! bytes

!SD_card Input Buffer = PAD
SDIB_I2CADR=\$1CE0!
SDIB_I2CCNT=\$1CE2!
SDIB_ORG=\$1CE4!
SDIB_LEN=\$54!

! ----------------------------------------------
! FastForth RAM memory map (= 1k):
! ----------------------------------------------
LEAVEPTR=\$1C00!    \ Leave-stack pointer, init by QUIT
LSATCK=\$1C00!      \ leave stack,      grow up
PSTACK=\$1C80!      \ parameter stack,  grow down
RSTACK=\$1CE0!      \ Return stack,     grow down

PAD_I2CADR=\$1CE0!  \ RX I2C address
PAD_I2CCNT=\$1CE2!  \ count max
PAD_ORG=\$1CE4!     \ user scratch pad buffer, 84 bytes, grow up

TIB_I2CADR=\$1D38!  \ TX I2C address 
TIB_I2CCNT=\$1D3A!  \ count of bytes
TIB_ORG=\$1D3C!     \ Terminal input buffer, 84 bytes, grow up

HOLDS_ORG=\$1D90!   \ a good address for HOLDS
HOLD_BASE=\$1DB2!   \ BASE HOLD area, grow down

! ----------------------
! NOT SAVED VARIABLES
! ----------------------

HP=\$1DB2!              HOLD ptr
CAPS=\$1DB4!            CAPS ON/OFF flag, must be set to -1 before first reset !
LAST_NFA=\$1DB6!
LAST_THREAD=\$1DB8!
LAST_CFA=\$1DBA!
LAST_PSP=\$1DBC!

STATEADR=\$1DBE!          Interpreter state

SOURCE_LEN=\$1DC0!      len of input stream
SOURCE_ORG=\$1DC2!      adr of input stream
TOIN=\$1DC4!            >IN
DP=\$1DC6!              dictionary ptr

LASTVOC=\$1DC8!         keep VOC-LINK
CONTEXT=\$1DCA!         CONTEXT dictionnary space (8 CELLS)
CURRENT=\$1DDA!         CURRENT dictionnary ptr

BASEADR=\$1DDC!           numeric base, must be defined before first reset !
LINE=\$1DDE!            line in interpretation, activated with NOECHO, desactivated with ECHO
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

! ============================================
! FRAM MAIN
! ============================================
MAIN_ORG=\$C200!        Code space start
MAIN_LEN=\$3E00!        15.5 k FRAM
! ----------------------------------------------

SLEEP=\$C200! 
BODYSLEEP=\$C204!
LIT=\$C20E! 
NEXT_ADR=\$C216!
XSQUOTE=\$C218! 
HEREADR=\$C22C!
QTBRAN=\$C238! 
BRAN=\$C23E! 
QFBRAN=\$C242! 
SKIPBRAN=\$C248! 
XDO=\$C24C! 
XPLOOP=\$C25C! 
XLOOP=\$C26E! 
MUSMOD=\$C274!          unsigned 32/16 division
SETIB=\$C2BA!           Set Input Buffer with org len values, reset >IN 
REFILL=\$C2CA!          accept one line from input and leave org len of input buffer
CIB_ADR=\$C2D8!         contents currently TIB_ORG; may be redirected to SDIB_ORG
XDODOES=\$C2E2!         restore rDODOES: MOV #XDODOES,rDODOES
XDOCON=\$C2F0!          restore rDOCON: MOV #XDOCON,rDOCON
XDOCOL=\$C2FC!          restore rDOCOL: MOV #XDOCOL,rDOCOL      only for DTC model = 1

! to find DTC value, download \MSP430-FORTH\FastForthSpecs.4th
! if DTC = 1, restore rDOCOL as this : MOV #xdocol,rDOCOL
! if DTC = 2, restore rDOCOL as this : MOV #EXIT,rDOCOL
! if DTC = 3, nothing to do, R7 is free for use.
! ----------------------------------------------
! Interrupt Vectors and signatures - MSP430FR5739
! ----------------------------------------------
FRAM_FULL=\$FF30!       80 bytes are sufficient considering what can be compiled in one line and WORD use.
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2=\$FF82!       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84!
BSL_SIG2=\$FF86!
JTAG_PASSWORD=\$FF88!   256 bits
BSL_PASSWORD=\$FFE0!    256 bits
VECT_ORG=\$FFCE!        FFCE-FFFF
VECT_LEN=\$32!


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
ADC10_B_VEC=\$FFEC!
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
CSCTL0_H=\$161!     \ 
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
SYSBERRIV=\$198!    \ Bus Error vector generator  
SYSUNIV=\$19A!      \ User NMI vector generator   
SYSSNIV=\$19C!      \ System NMI vector generator 
SYSRSTIV=\$19E!     \ Reset vector generator      

REFCTL=\$1b0!       \ Shared reference control 

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
TBCLR=4!
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
TB0R=\$3D0!         \ TB0 counter register        
TB0CCR0=\$3D2!      \ Capture/compare register 0  
TB0CCR1=\$3D4!      \ Capture/compare register 1  
TB0CCR2=\$3D6!      \ Capture/compare register 2  
TB0EX0=\$3E0!       \ TB0 expansion register 0    
TB0IV=\$3EE!        \ TB0 interrupt vector        

TB1CTL=\$400!       \ TB1 control                 
TB1CCTL0=\$402!     \ Capture/compare control 0   
TB1CCTL1=\$404!     \ Capture/compare control 1   
TB1CCTL2=\$406!     \ Capture/compare control 2   
TB1R=\$410!         \ TB1 counter register        
TB1CCR0=\$412!      \ Capture/compare register 0  
TB1CCR1=\$414!      \ Capture/compare register 1  
TB1CCR2=\$416!      \ Capture/compare register 2  
TB1EX0=\$420!       \ TB1 expansion register 0    
TB1IV=\$42E!        \ TB1 interrupt vector        

TB2CTL=\$440!       \ TB2 control                 
TB2CCTL0=\$442!     \ Capture/compare control 0   
TB2CCTL1=\$444!     \ Capture/compare control 1   
TB2CCTL2=\$446!     \ Capture/compare control 2   
TB2R=\$450!         \ TB2 counter register        
TB2CCR0=\$452!      \ Capture/compare register 0  
TB2CCR1=\$454!      \ Capture/compare register 1  
TB2CCR2=\$456!      \ Capture/compare register 2  
TB2EX0=\$460!       \ TB2 expansion register 0    
TB2IV=\$46E!        \ TB2 interrupt vector        

! RTC_B
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

DMA0CTL=\$500!      \ DMA channel 0 control                   
DMA0SAL=\$502!      \ DMA channel 0 source address low        
DMA0SAH=\$504!      \ DMA channel 0 source address high       
DMA0DAL=\$506!      \ DMA channel 0 destination address low   
DMA0DAH=\$508!      \ DMA channel 0 destination address high  
DMA0SZ=\$50A!       \ DMA channel 0 transfer size             
DMA1CTL=\$510!      \ DMA channel 1 control                   
DMA1SAL=\$512!      \ DMA channel 1 source address low        
DMA1SAH=\$514!      \ DMA channel 1 source address high       
DMA1DAL=\$516!      \ DMA channel 1 destination address low   
DMA1DAH=\$518!      \ DMA channel 1 destination address high  
DMA1SZ=\$51A!       \ DMA channel 1 transfer size             
DMA2CTL=\$520!      \ DMA channel 2 control                   
DMA2SAL=\$522!      \ DMA channel 2 source address low        
DMA2SAH=\$524!      \ DMA channel 2 source address high       
DMA2DAL=\$526!      \ DMA channel 2 destination address low   
DMA2DAH=\$528!      \ DMA channel 2 destination address high  
DMA2SZ=\$52A!       \ DMA channel 2 transfer size             
DMACTL0=\$530!      \ DMA module control 0                    
DMACTL1=\$532!      \ DMA module control 1                    
DMACTL2=\$534!      \ DMA module control 2                    
DMACTL3=\$536!      \ DMA module control 3                    
DMACTL4=\$538!      \ DMA module control 4                    
DMAIV=\$53A!        \ DMA interrupt vector                    

MPUCTL0=\$5A0!      \ MPU control 0             
MPUCTL1=\$5A2!      \ MPU control 1             
MPUSEG=\$5A4!       \ MPU Segmentation Register 
MPUSAM=\$5A6!       \ MPU access management     

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

ADC10CTL0=\$700!    \ ADC10_B Control register 0               
ADC10CTL1=\$702!    \ ADC10_B Control register 1               
ADC10CTL2=\$704!    \ ADC10_B Control register 2               
ADC10LO=\$706!      \ ADC10_B Window Comparator Low Threshold  
ADC10HI=\$708!      \ ADC10_B Window Comparator High Threshold 
ADC10MCTL0=\$70A!   \ ADC10_B Memory Control Register 0        
ADC10MEM0=\$712!    \ ADC10_B Conversion Memory Register       
ADC10IE=\$71A!      \ ADC10_B Interrupt Enable                 
ADC10IFG=\$71C!     \ ADC10_B Interrupt Flags                  
ADC10IV=\$71E!      \ ADC10_B Interrupt Vector Word            

ADCON=\$10!
ADCSTART=\$03!

CDIFG=1!
CDIIFG=2!

CDCTL0=\$8C0!       \ Comparator_D control register 0     
CDCTL1=\$8C2!       \ Comparator_D control register 1     
CDCTL2=\$8C4!       \ Comparator_D control register 2     
CDCTL3=\$8C6!       \ Comparator_D control register 3     
CDINT=\$8CC!        \ Comparator_D interrupt register     
CDIV=\$8CE!         \ Comparator_D interrupt vector word  
