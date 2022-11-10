
@set-syntax{C;\;}!  tell GEMA to replace default Comment separator '!' by ';'

;MSP430fr2xxx.pat
;
; ============================================
; RAM
; ============================================
;
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
SOURCE_LEN=\$21B8;      len of input stream
SOURCE_ORG=\$21BA;      adr of input stream
TOIN=\$21BC;            >IN
;
DP=\$21BE;              dictionary ptr
LASTVOC=\$21C0;         keep VOC-LINK
CURRENT=\$21C2;         CURRENT dictionnary ptr
CONTEXT=\$21C4;         CONTEXT dictionnary space (8 + Null CELLS)
;
; ---------------------------------------
; RAM_ORG + $218 : may be shared between FORTH compiler and user application
; ---------------------------------------
LAST_NFA=\$21D6;
LAST_THREAD=\$21D8;
LAST_CFA=\$21DA;
LAST_PSP=\$21DC;
ASMBW1=\$21DE;          3 backward labels
ASMBW2=\$21E0;
ASMBW3=\$21E2;
ASMFW1=\$21E4;          3 forward labels
ASMFW2=\$21E6;
ASMFW3=\$21E8;
PREV_TOIN=\$21EA;
; ---------------------------------------
; RAM_ORG + $1EC RAM free 
; ---------------------------------------
;
; ---------------------------------------
; RAM_ORG + $1EC RAM free 
; ---------------------------------------
;
; ---------------------------------------
; RAM_ORG + $1FC: SD  RAM
; ---------------------------------------
SD_ORG=\$21FC
SD_LEN=\$374;

; ---------------------------------------
; RAM_ORG + $1FC: SD buffer
; ---------------------------------------
SD_BUF_I2ADR=\$21FC;
SD_BUF_I2CNT=\$21FE;
SD_BUF=\$2200;      \ SD_Card buffer
SD_BUF_END=\$2400;
;
; ---------------------------------------
; FAT32 FileSystemInfos
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
;
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
;
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
HDLW_BUFofst=22;    SD BUFFER offset ; used by LOAD" and by WRITE"
HDLW_PrevLEN=24;    interpret_buffer_LEN of previous handle
HDLW_PrevORG=26;    interpret_buffer_ORG of previous handle
HDLW_PrevTOIN=28;   interpret_buffer_PTR of previous handle
HDLW_PrevQYEMIT=30; echo state of previous handle


;OpenedFirstFile     ; "openedFile" structure
HandleMax=8;
HandleLenght=32;
FirstHandle=\$2438;
HandleEnd=\$2538;

;SD_card Input Buffer
SDIB_I2CADR=\$2538;
SDIB_I2CCNT=\$253A;
SDIB_ORG=\$253C;
SDIB_LEN=\$54;
