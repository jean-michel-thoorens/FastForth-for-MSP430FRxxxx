!MSP430FR2x4x_FastForth.pat

! ===========================================================
! MSP430FR2xxx and FR4xxx DEVICES HAVE SPECIFIC RAM ADDRESSES
! ===========================================================


! ================================================
! SR bits : only SR(11:0) are PUSHed by interrupts
! ================================================
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
! FastForth RAM memory map (>= 1k):
! ============================================
LSATCK=\$2000!      \ leave stack,      grow up
PSTACK=\$2080!      \ parameter stack,  grow down
RSTACK=\$20E0!      \ Return stack,     grow down
PAD=\$20E2!         \ user scratch pad buffer, grow up
TIB=\$2138!         \ Terminal input buffer, grow up
BASE_HOLD=\$21AA!   \ BASE HOLD area, grow down

! ----------------------
! NOT SAVED VARIABLES
! ----------------------

HP=\$21AA!              HOLD ptr
LEAVEPTR=\$21AC!        Leave-stack pointer, init by QUIT

LAST_NFA=\$21AE!
LAST_THREAD=\$21B0!
LAST_CFA=\$21B2!
LAST_CSP=\$21B4!

STATE=\$21B6!           Interpreter state

ASM_CURRENT=\$21B8!     preserve CURRENT when create assembler words
OPCODE=\$21BA!          OPCODE adr
ASMTYPE=\$21BC!         keep the opcode complement

SOURCE_LEN=\$21BE!      len of input stream
SOURCE_ADR=\$21C0!      adr of input stream
\>IN=\$21C2!            >IN
DP=\$21C4!              dictionary ptr
LASTVOC=\$21C6!         keep VOC-LINK
CURRENT=\$21C8!         CURRENT dictionnary ptr
CONTEXT=\$21CA!         CONTEXT dictionnary space (8 CELLS)

BASE=\$21DA!            numeric base, must be defined before first reset !
CAPS=\$21DC!            CAPS ON/OFF flag, must be set to -1 before first reset !


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
FATsector=\$242A!   not used
CurFATsector=\$242C!

! ---------------------------------------
! DIR entry
! ---------------------------------------
DIRclusterL=\$242E!  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$2430!  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$2432!  
pathname=\$2434!    address of pathname string

! ---------------------------------------
! Handle Pointer
! ---------------------------------------
CurrentHdl=\$2436!  contains the address of the last opened file structure, or 0

! ---------------------------------------
! Load file operation
! ---------------------------------------
SAVEtsLEN=\$2438!              of previous ACCEPT
SAVEtsPTR=\$243A!              of previous ACCEPT
MemSectorL=\$243C!             double word current Sector of previous LOAD"ed file
MemSectorH=\$243E!

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
FirstHandle=\$2440!
HandleOutOfBound=\$2500!

SDIB=\$2500!