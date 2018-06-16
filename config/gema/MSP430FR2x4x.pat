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

! ----------------------
! KERNEL CONSTANTS
! ----------------------
INI_THREAD=\$1800!      .word THREADS
TERMINAL_INT=\$1802!    .word TERMINAL_INT
FREQ_KHZ=\$1804!        .word FREQUENCY
HECTOBAUDS=\$1806!      .word TERMINALBAUDRATE/100
! ----------------------
! SAVED VARIABLES
! ----------------------
SAVE_SYSRSTIV=\$1808!   to enable SYSRSTIV read
LPM_MODE=\$180A!        LPM0+GIE is the default mode
INIDP=\$180C!           define RST_STATE, init by wipe
INIVOC=\$180E!          define RST_STATE, init by wipe

RXON=\$1810!
RXOFF=\$1812!

ReadSectorWX=\$1814!    call with W = SectorLO  X = SectorHI
WriteSectorWX=\$1816!   call with W = SectorLO  X = SectorHI
GPFLAGS=\$1818!


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

SAV_CURRENT=\$21C0!     preserve CURRENT when create assembler words
OPCODE=\$21C2!          OPCODE adr
ASMTYPE=\$21C4!         keep the opcode complement

SOURCE_LEN=\$21C6!      len of input stream
SOURCE_ADR=\$21C8!      adr of input stream
TOIN=\$21CA!            >IN
DP=\$21CC!              dictionary ptr
LASTVOC=\$21CE!         keep VOC-LINK
CONTEXT=\$21D0!         CONTEXT dictionnary space (8 CELLS)
CURRENT=\$21E0!         CURRENT dictionnary ptr

!BASE=\$21E2!           numeric base, must be defined before first reset !
LINE=\$21E4!           line in interpretation, activated with NOECHO, desactivated with ECHO
! ---------------------------------------
!21E6! 22 RAM bytes free
! ---------------------------------------

! ---------------------------------------
! SD buffer
! ---------------------------------------
SD_BUF_I2ADR=\$21FC!
SD_BUF_I2CNT=\$21FE!
BUFFER=\$2200!      \ SD_Card buffer
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
FirstHandle=\$2440!
HandleEnd=\$2500!

!Stack of return IP for LOADed files, preincrement stack structure
LOADPTR=\$2500!
LOAD_STACK=\$2502!
LOAD_STACK_END=\$2538!

!SD_card Input Buffer
SDIB_I2CADR=\$2538!
SDIB_I2CCNT=\$253A!
SDIB_ORG=\$253C!

SD_END_DATA=\$2590!


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
SYSCFG3=\$166!      \ System configuration 3 

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
PASEL1=\$20C!
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
P2SEL0=\$20B!
P2SEL1=\$20D!
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
PBIES=\$238!
PBIE=\$23A!
PBIFG=\$23C!

P3IN=\$220!
P3OUT=\$222!
P3DIR=\$224!
P3REN=\$226!
P3IV=\$22E!
P3SEL0=\$22A!
P3SEL1=\$22C!
P3IES=\$238!
P3IE=\$23A!
P3IFG=\$23C!

P4IN=\$221!
P4OUT=\$223!
P4DIR=\$225!
P4REN=\$227!
P4SEL0=\$22B!
P4SEL1=\$22D!
P4IES=\$239!
P4IE=\$23B!
P4IFG=\$23D!
P4IV=\$23E!

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
P5SEL1=\$24C!

P6IN=\$241!
P6OUT=\$243!
P6DIR=\$245!
P6REN=\$247!
P6SEL0=\$249!
P6SEL1=\$24B!


PDIN=\$260!
PDOUT=\$262!
PDDIR=\$264!
PDREN=\$266!
PDSEL0=\$26A!
PDSEL1=\$26C!

P7IN=\$260!
P7OUT=\$262!
P7DIR=\$264!
P7REN=\$266!
P7SEL0=\$26A!
P7SEL1=\$26C!

P8IN=\$261!
P8OUT=\$263!
P8DIR=\$265!
P8REN=\$267!
P8SEL0=\$26B!

CAPTIO0CTL=\$2EE!   \ Capacitive Touch IO 0 control      

RTCCTL=\$300!       \ RTC control                                  
RTCIV=\$304!        \ RTC interrupt vector word                       
RTCMOD=\$308!       \ RTC modulo                                       
RTCCNT=\$30C!       \ RTC counter register    


TACLR=4!
TAIFG=1!
CCIFG=1!

TA0CTL=\$380!       \ TA0 control                 
TA0CCTL0=\$382!     \ Capture/compare control 0   
TA0CCTL1=\$384!     \ Capture/compare control 1   
TA0CCTL2=\$386!     \ Capture/compare control 2   
TA0R=\$390!         \ TA0 counter register        
TA0CCR0=\$392!      \ Capture/compare register 0  
TA0CCR1=\$394!      \ Capture/compare register 1  
TA0CCR2=\$396!      \ Capture/compare register 2  
TA0EX0=\$3A0!       \ TA0 expansion register 0    
TA0IV=\$3AE!        \ TA0 interrupt vector        

TA1CTL=\$3C0!       \ TA1 control                 
TA1CCTL0=\$3C2!     \ Capture/compare control 0   
TA1CCTL1=\$3C4!     \ Capture/compare control 1   
TA1CCTL2=\$3C6!     \ Capture/compare control 2   
TA1R=\$3D0!         \ TA1 counter register        
TA1CCR0=\$3D2!      \ Capture/compare register 0  
TA1CCR1=\$3D4!      \ Capture/compare register 1  
TA1CCR2=\$3D6!      \ Capture/compare register 2  
TA1EX0=\$3E0!       \ TA1 expansion register 0    
TA1IV=\$3EE!        \ TA1 interrupt vector        

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

TB0CTL=\$380!       \ TB0 control                 
TB0CCTL0=\$382!     \ Capture/compare control 0   
TB0CCTL1=\$384!     \ Capture/compare control 1   
TB0CCTL2=\$386!     \ Capture/compare control 2   
TB0R=\$390!         \ TB0 counter register        
TB0CCR0=\$392!      \ Capture/compare register 0  
TB0CCR1=\$394!      \ Capture/compare register 1  
TB0CCR2=\$396!      \ Capture/compare register 2  
TB0EX0=\$3A0!       \ TB0 expansion register 0    
TB0IV=\$3AE!        \ TB0 interrupt vector        

TB1CTL=\$3C0!       \ TB1 control                 
TB1CCTL0=\$3C2!     \ Capture/compare control 0   
TB1CCTL1=\$3C4!     \ Capture/compare control 1   
TB1CCTL2=\$3C6!     \ Capture/compare control 2   
TB1R=\$3D0!         \ TB0 counter register        
TB1CCR0=\$3D2!      \ Capture/compare register 0  
TB1CCR1=\$3D4!      \ Capture/compare register 1  
TB1CCR2=\$3D6!      \ Capture/compare register 2  
TB1EX0=\$3E0!       \ TB0 expansion register 0    
TB1IV=\$3EE!        \ TB0 interrupt vector        

TB2CTL=\$400!       \ TB2 control                 
TB2CCTL0=\$402!     \ Capture/compare control 0   
TB2CCTL1=\$404!     \ Capture/compare control 1   
TB2CCTL2=\$406!     \ Capture/compare control 2   
TB2R=\$410!         \ TB0 counter register        
TB2CCR0=\$412!      \ Capture/compare register 0  
TB2CCR1=\$414!      \ Capture/compare register 1  
TB2CCR2=\$416!      \ Capture/compare register 2  
TB2EX0=\$420!       \ TB0 expansion register 0    
TB2IV=\$42E!        \ TB0 interrupt vector        

TB3CTL=\$440!       \ TB3 control                 
TB3CCTL0=\$442!     \ Capture/compare control 0   
TB3CCTL1=\$444!     \ Capture/compare control 1   
TB3CCTL2=\$446!     \ Capture/compare control 2   
TB3CCTL3=\$448!     \ Capture/compare control 3   
TB3CCTL4=\$44A!     \ Capture/compare control 4   
TB3CCTL6=\$44C!     \ Capture/compare control 5   
TB3CCTL6=\$44E!     \ Capture/compare control 6   
TB3R=\$450!         \ TB0 counter register        
TB3CCR0=\$452!      \ Capture/compare register 0  
TB3CCR1=\$454!      \ Capture/compare register 1  
TB3CCR2=\$456!      \ Capture/compare register 2  
TB3CCR3=\$456!      \ Capture/compare register 3  
TB3CCR4=\$456!      \ Capture/compare register 4  
TB3CCR5=\$456!      \ Capture/compare register 5  
TB3CCR6=\$456!      \ Capture/compare register 6  
TB3EX0=\$460!       \ TB0 expansion register 0    
TB3IV=\$46E!        \ TB0 interrupt vector        



MPY=\$4C0!          \ 16-bit operand 1 � multiply                     
MPYS=\$4C2!         \ 16-bit operand 1 � signed multiply              
MAC=\$4C4!          \ 16-bit operand 1 � multiply accumulate          
MACS=\$4C6!         \ 16-bit operand 1 � signed multiply accumulate   
OP2=\$4C8!          \ 16-bit operand 2                                
RESLO=\$4CA!        \ 16 � 16 result low word                         
RESHI=\$4CC!        \ 16 � 16 result high word                        
SUMEXT=\$4CE!       \ 16 � 16 sum extension register                  
MPY32L=\$4D0!       \ 32-bit operand 1 � multiply low word            
MPY32H=\$4D2!       \ 32-bit operand 1 � multiply high word           
MPYS32L=\$4D4!      \ 32-bit operand 1 � signed multiply low word     
MPYS32H=\$4D6!      \ 32-bit operand 1 � signed multiply high word    
MAC32L=\$4D8!       \ 32-bit operand 1 � multiply accumulate low word         
MAC32H=\$4DA!       \ 32-bit operand 1 � multiply accumulate high word        
MACS32L=\$4DC!      \ 32-bit operand 1 � signed multiply accumulate low word  
MACS32H=\$4DE!      \ 32-bit operand 1 � signed multiply accumulate high word 
OP2L=\$4E0!         \ 32-bit operand 2 � low word                 
OP2H=\$4E2!         \ 32-bit operand 2 � high word                
RES0=\$4E4!         \ 32 � 32 result 0 � least significant word   
RES1=\$4E6!         \ 32 � 32 result 1                            
RES2=\$4E8!         \ 32 � 32 result 2                            
RES3=\$4EA!         \ 32 � 32 result 3 � most significant word    
MPY32CTL0=\$4EC!    \ MPY32 control register 0                    



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

UCA1CTLW0=\$520!    \ eUSCI_A control word 0        
UCA1CTLW1=\$522!    \ eUSCI_A control word 1        
UCA1BRW=\$526!         
UCA1BR0=\$526!      \ eUSCI_A baud rate 0           
UCA1BR1=\$527!      \ eUSCI_A baud rate 1           
UCA1MCTLW=\$528!    \ eUSCI_A modulation control    
UCA1STAT=\$52A!     \ eUSCI_A status                
UCA1RXBUF=\$52C!    \ eUSCI_A receive buffer        
UCA1TXBUF=\$52E!    \ eUSCI_A transmit buffer       
UCA1ABCTL=\$530!    \ eUSCI_A LIN control           
UCA1IRTCTL=\$532!   \ eUSCI_A IrDA transmit control 
UCA1IRRCTL=\$533!   \ eUSCI_A IrDA receive control  
UCA1IE=\$53A!       \ eUSCI_A interrupt enable      
UCA1IFG=\$53C!      \ eUSCI_A interrupt flags       
UCA1IV=\$53E!       \ eUSCI_A interrupt vector word 


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


ICCSC=\$6C00!    \ Interrupt Compare Controller Status and Control Register
ICCMVS=\$6C02!   \ Interrupt Compare Controller Mask Virtual Stack Register
ICCILSR0=\$6C04! \ Interrupt Compare Controller Interrupt Level Setting Register 0
ICCILSR1=\$6C06! \ Interrupt Compare Controller Interrupt Level Setting Register 1
ICCILSR2=\$6C08! \ Interrupt Compare Controller Interrupt Level Setting Register 2
ICCILSR3=\$6C0A! \ Interrupt Compare Controller Interrupt Level Setting Register 3
ICCILSR4=\$6C0C! \ Interrupt Compare Controller Interrupt Level Setting Register 4
ICCILSR5=\$6C0E! \ Interrupt Compare Controller Interrupt Level Setting Register 5
ICCILSR6=\$6C10! \ Interrupt Compare Controller Interrupt Level Setting Register 6
ICCILSR7=\$6C12! \ Interrupt Compare Controller Interrupt Level Setting Register 7



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



CP0CTL0=\$8E0!      \ Comparator control 0            
CP0CTL1=\$8E2!      \ Comparator control 1            
CP0INT=\$8E6!       \ Comparator interrupt            
CP0IV=\$8E8!        \ Comparator interrupt vector     
CP0DACCTL=\$8EA!    \ Comparator built-in DAC control 
CP0DACDATA=\$8EC!   \ Comparator built-in DAC data    

CP1CTL0=\$900!      \ Comparator control 0            
CP1CTL1=\$902!      \ Comparator control 1            
CP1INT=\$906!       \ Comparator interrupt            
CP1IV=\$908!        \ Comparator interrupt vector     
CP1DACCTL=\$90A!    \ Comparator built-in DAC control 
CP1DACDATA=\$90C!   \ Comparator built-in DAC data    

SAC0OA=\$0C80!    SAC0 OA control         
SAC0PGA=\$0C82!    SAC0 PGA control        
SAC0DAC=\$0C84!    SAC0 DAC control        
SAC0DAT=\$0C86!    SAC0 DAC data           
SAC0DATSTS=\$0C88!    SAC0 DAC status         
SAC0IV=\$0C8A!    SAC0 interrupt vector   

SAC1OA=\$0C90!    SAC1 OA control         
SAC1PGA=\$0C92!    SAC1 PGA control        
SAC1DAC=\$0C94!    SAC1 DAC control        
SAC1DAT=\$0C96!    SAC1 DAC data           
SAC1DATSTS=\$0C98!    SAC1 DAC status         
SAC1IV=\$0C9A!    SAC1 interrupt vector   

SAC2OA=\$0CA0!    SAC2 OA control         
SAC2PGA=\$0CA2!    SAC2 PGA control        
SAC2DAC=\$0CA4!    SAC2 DAC control        
SAC2DAT=\$0CA6!    SAC2 DAC data           
SAC2DATSTS=\$0CA8!    SAC2 DAC status         
SAC2IV=\$0CAA!    SAC2 interrupt vector   

SAC3OA=\$0CB0!    SAC3 OA control         
SAC3PGA=\$0CB2!    SAC3 PGA control        
SAC3DAC=\$0CB4!    SAC3 DAC control        
SAC3DAT=\$0CB6!    SAC3 DAC data           
SAC3DATSTS=\$0CB8!    SAC3 DAC status         
SAC3IV=\$0CBA!    SAC3 interrupt vector   



   

