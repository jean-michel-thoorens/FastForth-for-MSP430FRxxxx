!MSP430FR5x6x_FastForth.pat

! =================================================
! MSP430FR5x6x DEVICES HAVE SPECIFIC RAM ADDRESSES!
! =================================================


! ============================================
! SR bits :
! ============================================
\#C=\#1!        = SR(0) Carry flag
\#Z=\#2!        = SR(1) Zero flag
\#N=\#4!        = SR(2) Negative flag
GIE=8!          = SR(3) Enable Int
CPUOFF=\$10!    = SR(4) CPUOFF    
OSCOFF=\$20!    = SR(5) OSCOFF
SCG0=\$40!      = SR(6) SCG0     
SCG1=\$80!      = SR(7) SCG1
V=\$100!        = SR(8) oVerflow flag
UF1=\$200!      = SR(9) User Flag 1 used by ?NUMBER --> INTERPRET --> LITERAL to process double numbers, else free for use.  
UF2=\$400!      = SR(10) User Flag 2  
UF3=\$800!      = SR(11) User Flag 3  

C\@=C\@
C\!=C\!
C\,=C\,

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
RET=MOV \@R1+,R0!
NOP=MOV 0,R3!       \ one word one cycle
NOP2=\$3C00 ,!      \ compile JMP 0: one word two cycles
NOP3=MOV R0,R0!     \ one word three cycles
NEXT=MOV \@R13+,R0!



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
FREQ_KHZ=\$1804!        .word FREQUENCY*1000
HECTOBAUDS=\$1806!      .word TERMINALBAUDRATE/100
! ----------------------
! SAVED VARIABLES
! ----------------------
SAVE_SYSRSTIV=\$1808!   to enable SYSRSTIV read
LPM_MODE=\$180A!        LPM0+GIE is the default mode
INIDP=\$180C!           define RST_STATE, init by wipe
INIVOC=\$180E!          define RST_STATE, init by wipe

XON=\$1810!
XOFF=\$1812!

ReadSectorWX=\$1814!    call with W = SectorLO  X = SectorHI
WriteSectorWX=\$1816!   call with W = SectorLO  X = SectorHI


! ============================================
! FastForth RAM memory map (>= 2k):
! ============================================
LSATCK=\$1C00!      \ leave stack,      grow up
PSTACK=\$1C80!      \ parameter stack,  grow down
RSTACK=\$1CE0!      \ Return stack,     grow down
PAD=\$1CE2!         \ user scratch pad buffer, grow up
TIB=\$1D38!         \ Terminal input buffer, grow up
BASE_HOLD=\$1DAA!   \ BASE HOLD area, grow down

! ----------------------
! NOT SAVED VARIABLES
! ----------------------

HP=\$1DAA!              HOLD ptr
LEAVEPTR=\$1DAC!        Leave-stack pointer, init by QUIT

LAST_NFA=\$1DAE!
LAST_THREAD=\$1DB0!
LAST_CFA=\$1DB2!
LAST_CSP=\$1DB4!

STATE=\$1DB6!           Interpreter state

ASM_CURRENT=\$1DB8!     preserve CURRENT when create assembler words
OPCODE=\$1DBA!          OPCODE adr
ASMTYPE=\$1DBC!         keep the opcode complement

SOURCE_LEN=\$1DBE!      len of input stream
SOURCE_ADR=\$1DC0!      adr of input stream
\>IN=\$1DC2!            >IN
DP=\$1DC4!              dictionary ptr
LASTVOC=\$1DC6!         keep VOC-LINK
CURRENT=\$1DC8!         CURRENT dictionnary ptr
CONTEXT=\$1DCA!         CONTEXT dictionnary space (8 CELLS)

BASE=\$1DDA!            numeric base, must be defined before first reset !
CAPS=\$1DDC!            CAPS ON/OFF flag, must be set to -1 before first reset !


BUFFER=\$1E00!      \ SD_Card buffer
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
NewClusterL=\$2026!  16 bits wide (FAT16) 
NewClusterH=\$2028!  16 bits wide (FAT16) 
FATsector=\$202A!   not used
CurFATsector=\$202C! 

! ---------------------------------------
! DIR entry
! ---------------------------------------
DIRclusterL=\$202E!  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$2030!  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$2032!  
pathname=\$2034!    address of pathname string

! ---------------------------------------
! Handle Pointer
! ---------------------------------------
CurrentHdl=\$2036!  contains the address of the last opened file structure, or 0

! ---------------------------------------
! Load file operation
! ---------------------------------------
SAVEtsLEN=\$2038!              of previous ACCEPT
SAVEtsPTR=\$203A!              of previous ACCEPT
MemSectorL=\$203C!             double word current Sector of previous LOAD"ed file
MemSectorH=\$203E!

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

HandleMax=8!
HandleLenght=24!

!OpenedFirstFile     ; "openedFile" structure 
FirstHandle=\$2040!
HandleOutOfBound=\$2100!

SDIB=\$2100!