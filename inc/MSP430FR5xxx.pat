@set-syntax{C;\;}!  replace ! by semicolon

;MSP430fr5xxx.pat

; ============================================
; RAM
; ============================================

; ----------------------------------------------
; FORTH RAM areas :
; ----------------------------------------------
LSTACK_SIZE=\#16; words
PSTACK_SIZE=\#48; words
RSTACK_SIZE=\#48; words
PAD_LEN=\#84; bytes
CIB_LEN=\#84; bytes
HOLD_SIZE=\#34; bytes
;
; ----------------------------------------------
; FastForth RAM memory map (>= 1k):
; ----------------------------------------------
LEAVEPTR=\$1C00;        Leave-stack pointer, init by QUIT
LSATCK=\$1C00;          leave stack,      grow up
PSTACK=\$1C80;          parameter stack,  grow down
RSTACK=\$1CE0;          Return stack,     grow down
;
PAD_I2CADR=\$1CE0;      RX I2C address
PAD_I2CCNT=\$1CE2;      count max
PAD_ORG=\$1CE4;         user scratch pad buffer, 84 bytes, grow up
;
TIB_I2CADR=\$1D38;      TX I2C address 
TIB_I2CCNT=\$1D3A;      count of bytes
TIB_ORG=\$1D3C;         Terminal input buffer, 84 bytes, grow up
;
HOLDS_ORG=\$1D90;       base address for HOLDS
HOLD_BASE=\$1DB2;       BASE HOLD area, grow down
;
HP=\$1DB2;              HOLD ptr
STATEADR=\$1DB4;        Interpreter state
BASEADR=\$1DB6;         base
SOURCE_LEN=\$1DB8;      len of input stream
SOURCE_ORG=\$1DBA;      adr of input stream
TOIN=\$1DBC;            >IN
;
DP=\$1DBE;              dictionary ptr
LASTVOC=\$1DC0;         keep VOC-LINK
CURRENT=\$1DC2;         CURRENT dictionnary ptr
CONTEXT=\$1DC4;         CONTEXT dictionnary space (8 + Null CELLS)
;
; ---------------------------------------
; RAM_ORG + $1D8 : may be shared between FORTH compiler and user application
; ---------------------------------------
LAST_NFA=\$1DD6;
LAST_THREAD=\$1DD8;
LAST_CFA=\$1DDA;
LAST_PSP=\$1DDC;
ASMBW1=\$1DDE;          3 backward labels
ASMBW2=\$1DE0;
ASMBW3=\$1DE2;
ASMFW1=\$1DE4;          3 forward labels
ASMFW2=\$1DE6;
ASMFW3=\$1DE8;
; ---------------------------------------
; RAM_ORG + $1EA RAM free 
; ---------------------------------------
;
; ---------------------------------------
; RAM_ORG + $1FC: SD RAM
; ---------------------------------------
SD_ORG=\$21FC;
SD_LEN=\$374;

; ---------------------------------------
; RAM_ORG + $1FC: SD buffer
; ---------------------------------------
SD_BUF_I2ADR=\$1DFC;
SD_BUF_I2CNT=\$1DFE;
SD_BUF=\$1E00;      \ SD_Card buffer
SD_BUF_END=\$2000;
; ---------------------------------------
; FAT16 FileSystemInfos 
; ---------------------------------------
FATtype=\$2002;
BS_FirstSectorL=\$2004;
BS_FirstSectorH=\$2006;
OrgFAT1=\$2008;
FATSize=\$200A;
OrgFAT2=\$200C;
OrgRootDir=\$200E;
OrgClusters=\$2010;         Sector of Cluster 0
SecPerClus=\$2012;
; ---------------------------------------
; SD command
; ---------------------------------------
SD_CMD_FRM=\$2014;  6 bytes SD_CMDx inverted frame \${CRC,ll,LL,hh,HH,CMD}
SD_CMD_FRM0=\$2014; CRC:ll  word access
SD_CMD_FRM1=\$2015; ll      byte access
SD_CMD_FRM2=\$2016; LL:hh   word access
SD_CMD_FRM3=\$2017; hh      byte access
SD_CMD_FRM4=\$2018; HH:CMD  word access
SD_CMD_FRM5=\$2019; CMD     byte access
SectorL=\$201A;     2 words
SectorH=\$201C;
; ---------------------------------------
; BUFFER management
; ---------------------------------------
BufferPtr=\$201E; 
BufferLen=\$2020;
; ---------------------------------------
; FAT entry
; ---------------------------------------
ClusterL=\$2022;     16 bits wide (FAT16)
ClusterH=\$2024;     16 bits wide (FAT16)
LastFATsector=\$2026;   Set by FreeAllClusters, used by OPEN_OVERWRITE
LastFAToffset=\$2028;   Set by FreeAllClusters, used by OPEN_OVERWRITE
FATsector=\$202A;       used by APPEND"
; ---------------------------------------
; DIR entry
; ---------------------------------------
DIRclusterL=\$202C;  contains the Cluster of current directory ; 1 if FAT16 root directory
DIRclusterH=\$202E;  contains the Cluster of current directory ; 1 if FAT16 root directory
EntryOfst=\$2030;  
; ---------------------------------------
; Handle Pointer
; ---------------------------------------
CurrentHdl=\$2032;  contains the address of the last opened file structure, or 0
; ---------------------------------------
; Load file operation
; ---------------------------------------
pathname=\$2034;
EndOfPath=\$2036;
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
HDLW_BUFofst=22;    SD BUFFER offset ; used by LOAD" and by WRITE"
HDLW_PrevLEN=24;    interpret_buffer_LEN of previous handle
HDLW_PrevORG=26;    interpret_buffer_ORG of previous handle
HDLW_PrevTOIN=28;   interpret_buffer_PTR of previous handle
HDLW_PrevQYEMIT=30; echo state of previous handle


;OpenedFirstFile     ; "openedFile" structure 
HandleMax=8;
HandleLenght=32;
FirstHandle=\$2038;
HandleEnd=\$2138;

;SD_card Input Buffer
SDIB_I2CADR=\$2138;
SDIB_I2CCNT=\$213A;
SDIB_ORG=\$213C;
SDIB_LEN=\$54;
