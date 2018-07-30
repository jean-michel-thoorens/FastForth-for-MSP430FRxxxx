!MSP430FR4133.pat

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
! C400-FF7F = code memory (FRAM 15232 B)
! FF80-FFFF = interrupt vectors (FRAM 127 B)
! ----------------------------------------------
INFOSTART=\$1800!
INFOBSTART=\$1800!
INFOBEND=\$19FF!
INFOEND=\$19FF!
TLVSTAT=\$1A00!         Device Descriptor Info (Tag-Lenght-Value)
TLVEND=\$1A7F! 
RAMSTART=\$2000!
RAMEND=\$27FF!
PROGRAMSTART=\$C400!    Code space start
FRAM_FULL=\$FF30!       80 bytes are sufficient considering what can be compiled in one line and WORD use.
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2=\$FF82!       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84!  
BSL_SIG2=\$FF86!  
JTAG_PASSWORD=\$FF88!   256 bits
INTVECT=\$FFE2!         FFE2-FFFF
BSL_PASSWORD=\$FFE0!    256 bits


LCD_Vec=\$FFE2!
P2_Vec=\$FFE4!
P1_Vec=\$FFE6!
ADC10_B_Vec=\$FFE8!
eUSCI_B0_Vec=\$FFEA!
eUSCI_A0_Vec=\$FFEC!
WDT_Vec=\$FFEE!
RTC_Vec=\$FFF0!
TA1_x_Vec=\$FFF2!
TA1_0_Vec=\$FFF4!
TA0_x_Vec=\$FFF6!
TA0_0_Vec=\$FFF8!
U_NMI_Vec=\$FFFA!
S_NMI_Vec=\$FFFC!
RST_Vec=\$FFFE!




!MSP430FR2xxx.pat

LPM4=\$F8! SR(LPM4+GIE)
LPM3=\$D8! SR(LPM3+GIE)
LPM2=\$98! SR(LPM2+GIE)
LPM1=\$58! SR(LPM1+GIE)
LPM0=\$18! SR(LPM0+GIE)


! ============================================
! SR bits :
! ============================================
\#C=\#1!        = SR(0) Carry flag
\#Z=\#2!        = SR(1) Zero flag
\#N=\#4!        = SR(2) Negative flag
\#GIE=\#8!      = SR(3) Enable Int
\#CPUOFF=\#\$10!= SR(4) CPUOFF    
\#OSCOFF=\#\$20!= SR(5) OSCOFF
\#SCG0=\#\$40!  = SR(6) SCG0     
\#SCG1=\#\$80!  = SR(7) SCG1
\#V=\#\$100!    = SR(8) oVerflow flag
\#UF9=\#\$200!  = SR(9) User Flag 1 used by ?NUMBER --> INTERPRET --> LITERAL to process double numbers, else free for use.  
\#UF10=\#\$400! = SR(10) User Flag 2  
\#UF11=\#\$800! = SR(11) User Flag 3  

! ============================================
! PORTx, Reg  bits :
! ============================================
BIT0=1!
BIT1=2!
BIT2=4!
BIT3=8!
BIT4=\$10!
BIT5=\$20!
BIT6=\$40!
BIT7=\$80!
BIT8=\$100!
BIT9=\$200!
BIT10=\$400!
BIT11=\$800!
BIT12=\$1000!
BIT13=\$2000!
BIT14=\$4000!
BIT15=\$8000!

! ============================================
! symbolic codes :
! ============================================
RET=MOV \@R1+,R0!   \ MOV @RSP+,PC
NOP=MOV \#0,R3!     \                one word one cycle
NOP2=\$3C00 ,!      \ compile JMP 0  one word two cycles
NOP3=MOV R0,R0!     \ MOV PC,PC      one word three cycles
NEXT=MOV \@R13+,R0! \ MOV @IP+,PC   
SEMI=MOV \@R1+,R13\nMOV \@R13+,R0!


! ===========================================================
! MSP430FR2xxx and FR4xxx DEVICES HAVE SPECIFIC RAM ADDRESSES
! ===========================================================


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
GPFLAGS=\$1810!

RXON=\$1812!
RXOFF=\$1814!
ReadSectorWX=\$1816!    call with W = SectorLO  X = SectorHI
WriteSectorWX=\$1818!   call with W = SectorLO  X = SectorHI

! ============================================
! FORTH RAM areas :
! ============================================

LSTACK_SIZE=\#16! words
PSTACK_SIZE=\#48! words
RSTACK_SIZE=\#48! words
PAD_LEN=\#84! bytes
TIB_LEN=\#84! bytes
HOLD_SIZE=\#34! bytes

! ============================================
! FastForth RAM memory map (>= 1k):
! ============================================


LEAVEPTR=\$2000!    \ Leave-stack pointer, init by QUIT
LSATCK=\$2000!      \ leave stack,      grow up
PSTACK=\$2080!      \ parameter stack,  grow down
RSTACK=\$20E0!      \ Return stack,     grow down

PAD_I2CADR=\$20E0!  \ RX I2C address
PAD_I2CCNT=\$20E2!  \ count max
PAD_ORG=\$20E4!     \ user scratch pad buffer, 84 bytes, grow up

TIB_I2CADR=\$2138!  \ TX I2C address 
TIB_I2CCNT=\$213A!  \ count of bytes
TIB_ORG=\$213C!     \ Terminal input buffer, 84 bytes, grow up

HOLDS_ORG=\$2190!   \ a good address for HOLDS
BASE_HOLD=\$21B2!   \ BASE HOLD area, grow down

! ----------------------
! NOT SAVED VARIABLES
! ----------------------

HP=\$21B2!              HOLD ptr
CAPS=\$21B4!            CAPS ON/OFF flag, must be set to -1 before first reset !
LAST_NFA=\$21B6!
LAST_THREAD=\$21B8!
LAST_CFA=\$21BA!
LAST_PSP=\$21BC!

!STATE=\$21BE!           Interpreter state

SOURCE_LEN=\$21C0!      len of input stream
SOURCE_ADR=\$21C2!      adr of input stream
TOIN=\$21C4!            >IN
DP=\$21C6!              dictionary ptr

LASTVOC=\$21C8!         keep VOC-LINK
CONTEXT=\$21CA!         CONTEXT dictionnary space (8 CELLS)
CURRENT=\$21DA!         CURRENT dictionnary ptr

!BASE=\$21DC!           numeric base, must be defined before first reset !
LINE=\$21DE!            line in interpretation, activated with NOECHO, desactivated with ECHO
! ---------------------------------------
!21E0! 14 RAM bytes free conditionnaly
! ---------------------------------------
!SAV_CURRENT=\$21E0!    preserve CURRENT when create assembler words
!ASMBW1=\$21E2          assembler backward reference 1
!ASMBW2=\$21E4          assembler backward reference 2
!ASMBW3=\$21E6          assembler backward reference 3
!ASMFW1=\$21E8          assembler forward reference 1
!ASMFW2=\$21EA          assembler forward reference 2
!ASMFW3=\$21EC          assembler forward reference 3
! ---------------------------------------
!21EE! 14 RAM bytes free
! ---------------------------------------

! ---------------------------------------
! SD buffer
! ---------------------------------------
SD_BUF_I2ADR=\$21FC!
SD_BUF_I2CNT=\$21FE!
SD_BUF=\$2200!      \ SD_Card buffer
BUFEND=\$2400!

! ---------------------------------------
! FAT16 FileSystemInfos 
! ---------------------------------------
FATtype=\$2402!
BS_FirstSectorL=\$2404!
BS_FirstSectorH=\$2406!
OrgFAT1=\$2408!
FATSize=\$240A!
OrgFAT2=\$240C!
OrgRootDir=\$240E!
OrgClusters=\$2410!         Sector of Cluster 0
SecPerClus=\$2412!

! ---------------------------------------
! SD command
! ---------------------------------------
SD_CMD_FRM=\$2414!  6 bytes SD_CMDx inverted frame \${CRC,ll,LL,hh,HH,CMD}
SD_CMD_FRM0=\$2414! CRC:ll  word access
SD_CMD_FRM1=\$2415! ll      byte access
SD_CMD_FRM2=\$2416! LL:hh   word access
SD_CMD_FRM3=\$2417! hh      byte access
SD_CMD_FRM4=\$2418! HH:CMD  word access
SD_CMD_FRM5=\$2419! CMD     byte access
SectorL=\$241A!     2 words
SectorH=\$241C!

! ---------------------------------------
! BUFFER management
! ---------------------------------------
BufferPtr=\$241E! 
BufferLen=\$2420!

! ---------------------------------------
! FAT entry
! ---------------------------------------
ClusterL=\$2422!     16 bits wide (FAT16)
ClusterH=\$2424!     16 bits wide (FAT16)
NewClusterL=\$2426!  16 bits wide (FAT16) 
NewClusterH=\$2428!  16 bits wide (FAT16) 
CurFATsector=\$242A!

! ---------------------------------------
! DIR entry
! ---------------------------------------
DIRclusterL=\$242C!  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$242E!  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$2430!  

! ---------------------------------------
! Handle Pointer
! ---------------------------------------
CurrentHdl=\$2432!  contains the address of the last opened file structure, or 0

! ---------------------------------------
! Load file operation
! ---------------------------------------
pathname=\$2434!
EndOfPath=\$2436!

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


!OpenedFirstFile     ; "openedFile" structure 
HandleMax=8!
HandleLenght=24!
FirstHandle=\$2438!
HandleEnd=\$24F8!

!Stack of return IP for LOADed files, preincrement stack structure
LOADPTR=\$24F8!
LOAD_STACK=\$24FA!
LOAD_STACK_END=\$2530!

!SD_card Input Buffer
SDIB_I2CADR=\$2530!
SDIB_I2CCNT=\$2532!
SDIB_ORG=\$2534!

SD_END_DATA=\$2588!


! ============================================
! Special Fonction Registers (SFR)
! ============================================



SFRIE1=\$100!       \ SFR enable register
SFRIFG1=\$102!      \ SFR flag register
SFRRPCR=\$104!      \ SFR reset pin control

PMMCTL0=\$120!      \ PMM Control 0
PMMCTL1=\$122!      \ PMM Control 0
PMMCTL2=\$124!      \ PMM Control 0
PMMIFG=\$12A!       \ PMM interrupt flags 
PM5CTL0=\$130!      \ PM5 Control 0

SYSCTL=\$140!       \ System control 
SYSBSLC=\$142!      \ Bootstrap loader configuration area             
SYSJMBC=\$146!      \ JTAG mailbox control        
SYSJMBI0=\$148!     \ JTAG mailbox input 0        
SYSJMBI1=\$14A!     \ JTAG mailbox input 1        
SYSJMBO0=\$14C!     \ JTAG mailbox output 0       
SYSJMBO1=\$14E!     \ JTAG mailbox output 1       
SYSUNIV=\$15A!      \ User NMI vector generator   
SYSSNIV=\$15C!      \ System NMI vector generator 
SYSRSTIV=\$15E!     \ Reset vector generator      
SYSCFG0=\$160!      \ System configuration 0 
SYSCFG1=\$162!      \ System configuration 1 
SYSCFG2=\$164!      \ System configuration 2 

CSCTL0=\$180!       \ CS control 0 
CSCTL1=\$182!       \ CS control 1 
CSCTL2=\$184!       \ CS control 2 
CSCTL3=\$186!       \ CS control 3 
CSCTL4=\$188!       \ CS control 4 
CSCTL5=\$18A!       \ CS control 5 
CSCTL6=\$18C!       \ CS control 6 
CSCTL7=\$18E!       \ CS control 7 
CSCTL8=\$190!       \ CS control 8 


FRCTLCTL0=\$1A0!    \ FRAM control 0    
GCCTL0=\$1A4!       \ General control 0 
GCCTL1=\$1A6!       \ General control 1 

CRC16DI=\$1C0!      \ CRC data input                  
CRCDIRB=\$1C2!      \ CRC data input reverse byte     
CRCINIRES=\$1C4!    \ CRC initialization and result   
CRCRESR=\$1C6!      \ CRC result reverse byte  

WDTCTL=\$1CC!        \ WDT control register


PAIN=\$200!
PAOUT=\$202!
PADIR=\$204!
PAREN=\$206!
PASEL0=\$20A!
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
P1IES=\$218!
P1IE=\$21A!
P1IFG=\$21C!

P2IN=\$201!
P2OUT=\$203!
P2DIR=\$205!
P2REN=\$207!
P2IES=\$219!
P2IE=\$21B!
P2IFG=\$21D!
P2IV=\$21E!

PBIN=\$220!
PBOUT=\$222!
PBDIR=\$224!
PBREN=\$226!
PBSEL0=\$22A!

P3IN=\$220!
P3OUT=\$222!
P3DIR=\$224!
P3REN=\$226!

P4IN=\$221!
P4OUT=\$223!
P4DIR=\$225!
P4REN=\$227!
P4SEL0=\$22B!

PCIN=\$240!
PCOUT=\$242!
PCDIR=\$244!
PCREN=\$246!
PCSEL0=\$24A!
PCSEL1=\$24C!

P5IN=\$240!
P5OUT=\$242!
P5DIR=\$244!
P5REN=\$246!
P5SEL0=\$24A!

P6IN=\$241!
P6OUT=\$243!
P6DIR=\$245!
P6REN=\$247!

PDIN=\$260!
PDOUT=\$262!
PDDIR=\$264!
PDREN=\$266!
PDSEL0=\$26A!

P7IN=\$260!
P7OUT=\$262!
P7DIR=\$264!
P7REN=\$266!

P8IN=\$261!
P8OUT=\$263!
P8DIR=\$265!
P8REN=\$267!
P8SEL0=\$26B!

CAPTIO0CTL=\$2EE!   \ Capacitive Touch IO 0 control      



TACLR=4!
TAIFG=1!
CCIFG=1!

TA0CTL=\$300!       \ TA0 control                 
TA0CCTL0=\$302!     \ Capture/compare control 0   
TA0CCTL1=\$304!     \ Capture/compare control 1   
TA0CCTL2=\$306!     \ Capture/compare control 2   
TA0R=\$310!         \ TA0 counter register        
TA0CCR0=\$312!      \ Capture/compare register 0  
TA0CCR1=\$314!      \ Capture/compare register 1  
TA0CCR2=\$316!      \ Capture/compare register 2  
TA0EX0=\$320!       \ TA0 expansion register 0    
TA0IV=\$32E!        \ TA0 interrupt vector        

TA1CTL=\$340!       \ TA1 control                 
TA1CCTL0=\$342!     \ Capture/compare control 0   
TA1CCTL1=\$344!     \ Capture/compare control 1   
TA1CCTL2=\$346!     \ Capture/compare control 2   
TA1R=\$350!         \ TA1 counter register        
TA1CCR0=\$352!      \ Capture/compare register 0  
TA1CCR1=\$354!      \ Capture/compare register 1  
TA1CCR2=\$356!      \ Capture/compare register 2  
TA1EX0=\$360!       \ TA1 expansion register 0    
TA1IV=\$36E!        \ TA1 interrupt vector        

RTCCTL=\$3C0!       \ RTC control                                  
RTCIV=\$3C4!        \ RTC interrupt vector word                       
RTCMOD=\$3C8!       \ RTC modulo                                       
RTCCNT=\$3CC!       \ RTC counter register    


UCA0CTLW0=\$500!    \ eUSCI_A control word 0        
UCA0CTLW1=\$502!    \ eUSCI_A control word 1        
UCA0BRW=\$506!         
UCA0BR0=\$506!      \ eUSCI_A baud rate 0           
UCA0BR1=\$507!      \ eUSCI_A baud rate 1           
UCA0MCTLW=\$508!    \ eUSCI_A modulation control    
UCA0STAT=\$50A!     \ eUSCI_A status                
UCA0RXBUF=\$50C!    \ eUSCI_A receive buffer        
UCA0TXBUF=\$50E!    \ eUSCI_A transmit buffer       
UCA0ABCTL=\$510!    \ eUSCI_A LIN control           
UCA0IRTCTL=\$512!   \ eUSCI_A IrDA transmit control 
UCA0IRRCTL=\$513!   \ eUSCI_A IrDA receive control  
UCA0IE=\$51A!       \ eUSCI_A interrupt enable      
UCA0IFG=\$51C!      \ eUSCI_A interrupt flags       
UCA0IV=\$51E!       \ eUSCI_A interrupt vector word 


UCB0CTLW0=\$540!    \ eUSCI_B control word 0          
UCB0CTLW1=\$542!    \ eUSCI_B control word 1 
UCB0BRW=\$546!         
UCB0BR0=\$546!      \ eUSCI_B bit rate 0              
UCB0BR1=\$547!      \ eUSCI_B bit rate 1              
UCB0STATW=\$548!    \ eUSCI_B status word 
UCBCNT0=\$549!      \ eUSCI_B hardware count           
UCB0TBCNT=\$54A!    \ eUSCI_B byte counter threshold  
UCB0RXBUF=\$54C!    \ eUSCI_B receive buffer          
UCB0TXBUF=\$54E!    \ eUSCI_B transmit buffer         
UCB0I2COA0=\$554!   \ eUSCI_B I2C own address 0       
UCB0I2COA1=\$556!   \ eUSCI_B I2C own address 1       
UCB0I2COA2=\$558!   \ eUSCI_B I2C own address 2       
UCB0I2COA3=\$55A!   \ eUSCI_B I2C own address 3       
UCB0ADDRX=\$55C!    \ eUSCI_B received address        
UCB0ADDMASK=\$55E!  \ eUSCI_B address mask            
UCB0I2CSA=\$560!    \ eUSCI I2C slave address         
UCB0IE=\$56A!       \ eUSCI interrupt enable          
UCB0IFG=\$56C!      \ eUSCI interrupt flags           
UCB0IV=\$56E!       \ eUSCI interrupt vector word     

UCTXACK=\$20!
UCTR=\$10!

LCDCTL0=\$600!      \ LCD control register 0   
LCDCTL1=\$602!      \ LCD control register 1   
LCDBLKCTL=\$604!    \ LCD blink control register     
LCDMEMCTL=\$606!    \ LCD memory control register     
LCDVCTL=\$608!      \ LCD voltage control register   
LCDPCTL0=\$60A!     \ LCD port control 0    
LCDPCTL1=\$60C!     \ LCD port control 1    
LCDPCTL2=\$60E!     \ LCD port control 2    
LCDCSS0=\$614!      \ LCD COM/SEG select register   
LCDCSS1=\$616!      \ LCD COM/SEG select register   
LCDCSS2=\$618!      \ LCD COM/SEG select register   
LCDIV=\$61E!        \ LCD interrupt vector 
LCDM0=\$620!        \ LCD memory 0 
LCDM1=\$621!        \ LCD memory 1 
LCDM2=\$622!        \ LCD memory 2 
LCDM3=\$623!        \ LCD memory 3 
LCDM4=\$624!        \ LCD memory 4 
LCDM5=\$625!        \ LCD memory 5 
LCDM6=\$626!        \ LCD memory 6 
LCDM7=\$627!        \ LCD memory 7 
LCDM8=\$628!        \ LCD memory 8 
LCDM9=\$629!        \ LCD memory 9 
LCDM10=\$62A!       \ LCD memory 10 
LCDM11=\$62B!       \ LCD memory 11 
LCDM12=\$62C!       \ LCD memory 12 
LCDM13=\$62D!       \ LCD memory 13 
LCDM14=\$62E!       \ LCD memory 14 
LCDM15=\$62F!       \ LCD memory 15 
LCDM16=\$630!       \ LCD memory 16 
LCDM17=\$631!       \ LCD memory 17 
LCDM18=\$632!       \ LCD memory 18 
LCDM19=\$633!       \ LCD memory 19  
LCDM20=\$634!       \ LCD memory 20 
LCDM21=\$635!       \ LCD memory 21 
LCDM22=\$636!       \ LCD memory 22 
LCDM23=\$637!       \ LCD memory 23 
LCDM24=\$638!       \ LCD memory 24 
LCDM25=\$639!       \ LCD memory 25 
LCDM26=\$63A!       \ LCD memory 26 
LCDM27=\$63B!       \ LCD memory 27 
LCDM28=\$63C!       \ LCD memory 28 
LCDM29=\$63D!       \ LCD memory 29  
LCDM30=\$63E!       \ LCD memory 30 
LCDM31=\$63F!       \ LCD memory 31 
LCDM32=\$640!       \ LCD memory 32 
LCDM33=\$641!       \ LCD memory 33 
LCDM34=\$642!       \ LCD memory 34 
LCDM35=\$643!       \ LCD memory 35 
LCDM36=\$644!       \ LCD memory 36 
LCDM37=\$645!       \ LCD memory 37 
LCDM38=\$646!       \ LCD memory 38 
LCDM39=\$647!       \ LCD memory 39  
LCDBM0=\$640!       \ LCD blinking memory 0 
LCDBM1=\$641!       \ LCD blinking memory 1 
LCDBM2=\$642!       \ LCD blinking memory 2 
LCDBM3=\$643!       \ LCD blinking memory 3 
LCDBM4=\$644!       \ LCD blinking memory 4 
LCDBM5=\$645!       \ LCD blinking memory 5 
LCDBM6=\$646!       \ LCD blinking memory 6 
LCDBM7=\$647!       \ LCD blinking memory 7 
LCDBM8=\$648!       \ LCD blinking memory 8 
LCDBM9=\$649!       \ LCD blinking memory 9 
LCDBM10=\$64A!      \ LCD blinking memory 10 
LCDBM11=\$64B!      \ LCD blinking memory 11 
LCDBM12=\$64C!      \ LCD blinking memory 12 
LCDBM13=\$64D!      \ LCD blinking memory 13 
LCDBM14=\$64E!      \ LCD blinking memory 14 
LCDBM15=\$64F!      \ LCD blinking memory 15 
LCDBM16=\$650!      \ LCD blinking memory 16 
LCDBM17=\$651!      \ LCD blinking memory 17 
LCDBM18=\$652!      \ LCD blinking memory 18 
LCDBM19=\$653!      \ LCD blinking memory 19 


BAKMEM0=\$660!      \ Backup Memory 0     
BAKMEM1=\$662!      \ Backup Memory 1     
BAKMEM2=\$664!      \ Backup Memory 2     
BAKMEM3=\$666!      \ Backup Memory 3     
BAKMEM4=\$668!      \ Backup Memory 4     
BAKMEM5=\$66A!      \ Backup Memory 5     
BAKMEM6=\$66C!      \ Backup Memory 6     
BAKMEM7=\$66E!      \ Backup Memory 7     
BAKMEM8=\$670!      \ Backup Memory 8     
BAKMEM9=\$672!      \ Backup Memory 9     
BAKMEM10=\$674!     \ Backup Memory 10    
BAKMEM11=\$676!     \ Backup Memory 11    
BAKMEM12=\$678!     \ Backup Memory 12    
BAKMEM13=\$67A!     \ Backup Memory 13    
BAKMEM14=\$67C!     \ Backup Memory 14    
BAKMEM15=\$67E!     \ Backup Memory 15    



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

