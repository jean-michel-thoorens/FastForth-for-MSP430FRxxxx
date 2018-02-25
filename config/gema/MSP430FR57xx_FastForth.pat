!MSP430FR57xx_FastForth.pat

! =================================================
! MSP430FR57xx DEVICES HAVE SPECIFIC RAM ADDRESSES!
! =================================================


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


! ---------------------------------------
! FAT16 FileSystemInfos 
! ---------------------------------------
FATtype=\$181A!
BS_FirstSectorL=\$181C!
BS_FirstSectorH=\$181E!
OrgFAT1=\$1820!
FATSize=\$1822!
OrgFAT2=\$1824!
OrgRootDir=\$1826!
OrgClusters=\$1828!         Sector of Cluster 0
SecPerClus=\$182A!

! ---------------------------------------
! SD command
! ---------------------------------------
SD_CMD_FRM=\$182C!  6 bytes SD_CMDx inverted frame \${CRC,ll,LL,hh,HH,CMD}
SD_CMD_FRM0=\$182C! CRC:ll  word access
SD_CMD_FRM1=\$182D! ll      byte access
SD_CMD_FRM2=\$182E! LL:hh   word access
SD_CMD_FRM3=\$182F! hh      byte access
SD_CMD_FRM4=\$1830! HH:CMD  word access
SD_CMD_FRM5=\$1831! CMD     byte access
SectorL=\$1832!     2 words
SectorH=\$1834!

! ---------------------------------------
! BUFFER management
! ---------------------------------------
BufferPtr=\$1836! 
BufferLen=\$1838!

! ---------------------------------------
! FAT entry
! ---------------------------------------
ClusterL=\$183A!     16 bits wide (FAT16)
ClusterH=\$183C!     16 bits wide (FAT16)
NewClusterL=\$183E!  16 bits wide (FAT16) 
NewClusterH=\$1840!  16 bits wide (FAT16) 
CurFATsector=\$1842!

! ---------------------------------------
! DIR entry
! ---------------------------------------
DIRclusterL=\$1844!  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$1846!  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$1848!  

! ---------------------------------------
! Handle Pointer
! ---------------------------------------
CurrentHdl=\$184A!  contains the address of the last opened file structure, or 0

! ---------------------------------------
! Load file operation
! ---------------------------------------
pathname=\$184C!    address of pathname string
EndOfPath=\$184E!

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
HandleMax=5!
HandleLenght=24!
FirstHandle=\$1858!
HandleEnd=\$18D0!

!Stack of return IP for LOADed files, preincrement stack structure
LOADPTR=\$18D0!
LOAD_STACK=\$18D2!
LOAD_STACK_END=\$18F6!

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
! FastForth RAM memory map (= 1k):
! ============================================

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
BASE_HOLD=\$1DB2!   \ BASE HOLD area, grow down

! ----------------------
! NOT SAVED VARIABLES
! ----------------------

HP=\$1DB2!              HOLD ptr
CAPS=\$1DB4!            CAPS ON/OFF flag, must be set to -1 before first reset !
LAST_NFA=\$1DB6!
LAST_THREAD=\$1DB8!
LAST_CFA=\$1DBA!
LAST_PSP=\$1DBC!

!STATE=\$1DBE!          Interpreter state

SAV_CURRENT=\$1DC0!     preserve CURRENT when create assembler words
OPCODE=\$1DC2!          OPCODE adr
ASMTYPE=\$1DC4!         keep the opcode complement

SOURCE_LEN=\$1DC6!      len of input stream
SOURCE_ADR=\$1DC8!      adr of input stream
!\>IN=\$1DCA!            >IN
DP=\$1DCC!              dictionary ptr
LASTVOC=\$1DCE!         keep VOC-LINK
CONTEXT=\$1DD0!         CONTEXT dictionnary space (8 CELLS)
CURRENT=\$1DE0!         CURRENT dictionnary ptr

!BASE=\$1DE2!           numeric base, must be defined before first reset !
!LINE=\$1DE4!           line in interpretation, activated with NOECHO, desactivated with ECHO

! ---------------------------------------
!1DE6! 22 bytes RAM free
! ---------------------------------------

! ---------------------------------------
! SD buffer
! ---------------------------------------
SD_BUF_I2ADR=\$1DFC!
SD_BUF_I2CNT=\$1DFE!
BUFFER=\$1E00!      \ SD_Card buffer
BUFEND=\$2000!

