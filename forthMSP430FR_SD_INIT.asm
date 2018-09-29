; -*- coding: utf-8 -*-
; forthMSP430FR_SD_INIT.asm

; http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
; Copyright (C) <2017>  <J.M. THOORENS>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; ===========================================================
; ABOUT INIT SD_CARD AND HOW TO SELECT FAT16/FAT32 FORMAT
; ===========================================================
; FAT16/FAT32 selection is made via the ID of partition in EBP
; because SD must be always FAT16 and SDHC must be always FAT32
; this is automatically done when we format the SD_Card !


; =====================================================================
; goal : accept 64 MB up to 64 GB SD_CARD
; =====================================================================
; thus FAT and RootClus logical sectors are word addressable.

; FAT is a little endian structure.
; CMD frame is sent as big endian.

; we assume that SDSC Card (up to 2GB) is FAT16 with a byte addressing
; and that SDHC Card (4GB up to 64GB) is FAT32 with a sector addressing (sector = 512 bytes)
; for SDHC Card = 64 GB, cluster = 64 sectors ==> max clusters = 20 0000h ==> FAT size = 16384 sectors
; ==> FAT1 and FAT2 can be addressed with a single word.

; ref. https://en.wikipedia.org/wiki/Extended_boot_record
; ref. https://en.wikipedia.org/wiki/Partition_type

; Formatage FA16 d'une SDSC Card 2GB
; First sector of physical drive (sector 0) content :
; ---------------------------------------------------
; dec@| HEX@
; 446 |0x1BE    : partition table first record  ==> logical drive 0       
; 462 |0x1CE    : partition table 2th record    ==> logical drive 1
; 478 |0x1DE    : partition table 3th record    ==> logical drive 2
; 494 |0x1EE    : partition table 4th record    ==> logical drive 3

; partition of first record content :
; ---------------------------------------------------
; 450 |0x1C2 = 0x0E         : type FAT16 using LBA addressing
; 454 |0x1C6 = 89 00 00 00  : FirstSector (of logical drive 0) BS_FirstSector  = 137


; Partition type Description
; 0	    empty / unused
; 1	    FAT12
; 4	    FAT16 for partitions <= 32 MiB
; 5	    extended partition
; 6	    FAT16 for partitions > 32 MiB
; 11	FAT32 for partitions <= 2 GiB
; 12	Same as type 11 (FAT32), but using LBA addressing, which removes size constraints
; 14	Same as type 6 (FAT16), but using LBA addressing
; 15	Same as type 5, but using LBA addressing
; ref. https://www.compuphase.com/mbr_fat.htm#BOOTSECTOR

; FirstSector of logical drive (sector 0) content :
; -------------------------------------------------
; dec@| HEX@ =  HEX                                                       decimal
; 11  | 0x0B = 00 02        : 512 bytes/sector          BPB_BytsPerSec  = 512
; 13  | 0x0D = 40           : 64 sectors/cluster        BPB_SecPerClus  = 64
; 14  | 0x0E = 01 00        : 2 reserved sectors        BPB_RsvdSecCnt  = 1
; 16  | 0x10 = 02           : 2 FATs                    BPB_NumFATs     = 2 (always 2)
; 17  | 0x11 = 00 02        : 512 entries/directory     BPB_RootEntCnt  = 512
; 19  | 0x13 = 00 00        : BPB_TotSec16 (if < 65535) BPB_TotSec16    = 0
; 22  | 0x16 = EB 00        : 235 sectors/FAT (FAT16)   BPB_FATSize     = 235
; 32  | 0x20 = 77 9F 3A 00  : ‭3841911‬ total sectors     BPB_TotSec32    = ‭3841911‬
; 54  | 0x36 = "FAT16"                                  BS_FilSysType   (not used)

; all values below are evaluated in logical sectors
; FAT1           = BPB_RsvdSecCnt = 1
; FAT2           = BPB_RsvdSecCnt + BPB_FATSz32 = 1 + 235 = 236
; OrgRootDirL    = BPB_RsvdSecCnt + (BPB_FATSize * BPB_NumFATs) = 471
; RootDirSize    = BPB_RootEntCnt * 32 / BPB_BytsPerSec         = 32 sectors
; OrgDatas       = OrgRootDir + RootDirSize                     = 503
; OrgCluster     = OrgRootDir - 2*BPB_SecPerClus                = 375 (virtual value)
; FirstSectorOfCluster(n) = OrgCluster + n*BPB_SecPerClus       ==> cluster(3) = 705

; ====================================================================================

; Formatage FA32 d'une SDSC Card 8GB
; First sector of physical drive (sector 0) content :
; ---------------------------------------------------
; dec@| HEX@
; 446 |0x1BE    : partition table first record  ==> logical drive 0       
; 462 |0x1CE    : partition table 2th record    ==> logical drive 1
; 478 |0x1DE    : partition table 3th record    ==> logical drive 2
; 494 |0x1EE    : partition table 4th record    ==> logical drive 3

; partition record content :
; ---------------------------------------------------
; 450 |0x1C2 = 0x0C         : type FAT32 using LBA addressing
; 454 |0x1C6 = 00 20 00 00  : FirstSector (of logical drive 0) = BS_FirstSector = 8192

; 
; FirstSector of logical block (sector 0) content :
; -------------------------------------------------
; dec@| HEX@ =  HEX                                                       decimal
; 11  | 0x0B = 00 02        : 512 bytes/sector          BPB_BytsPerSec  = 512
; 13  | 0x0D = 08           : 8 sectors/cluster         BPB_SecPerClus  = 8
; 14  | 0x0E = 20 00        : 32 reserved sectors       BPB_RsvdSecCnt  = 32
; 16  | 0x10 = 02           : 2 FATs                    BPB_NumFATs     = 2 (always 2)
; 17  | 0x11 = 00 00        : 0                         BPB_RootEntCnt  = 0 (always 0 for FAT32)

; 32  | 0x20 = 00 C0 EC 00  : BPB_TotSec32              BPB_TotSec32    = 15515648
; 36  | 0x24 = 30 3B 00 00  : BPB_FATSz32               BPB_FATSz32     = 15152
; 40  | 0x28 = 00 00        : BPB_ExtFlags              BPB_ExtFlags 
; 44  | 0x2C = 02 00 00 00  : BPB_RootClus              BPB_RootClus    = 2
; 48  | 0x30 = 01 00        : BPB_FSInfo                BPB_FSInfo      = 1
; 50  | 0x33 = 06 00        : BPB_BkBootSec             BPB_BkBootSec   = 6
; 82  | 0x52 = "FAT32"      : BS_FilSysType             BS_FilSysType   (not used)

; 
; all values below are evaluated in logical sectors
; FAT1           = BPB_RsvdSecCnt = 32
; FAT2           = BPB_RsvdSecCnt + BPB_FATSz32 = 32 + 15152 = 15184
; OrgRootDirL    = BPB_RsvdSecCnt + BPB_FATSz32 * BPB_NumFATs = 32 + 15152*2 = 30336
; OrgCluster     = OrgRootDir - 2*BPB_SecPerClus = 30320
; RootDirSize    = BPB_RootEntCnt * 32 / BPB_BytsPerSec         = 0
; OrgDatas       = OrgRootDir + RootDirSize                     = 30336
; FirstSectorOfCluster(n) = OrgCluster + n*BPB_SecPerClus       ==> cluster(6) = 30368

; ===========================================================
; 1- Init eUSCI dedicated to SD_Card SPI driver
; ===========================================================

    MOV #0A981h,&SD_CTLW0           ; UCxxCTL1  = CKPH, MSB, MST, SPI_3, SMCLK  + UCSWRST
    MOV #FREQUENCY*3,&SD_BRW        ; UCxxBRW init SPI CLK = 333 kHz ( < 400 kHz) for SD_Card init
    BIS.B #SD_CS,&SD_CSDIR          ; SD_CS as output high
    BIS #SD_BUS,&SD_SEL             ; Configure pins as SIMO, SOMI & SCK (PxDIR.y are controlled by eUSCI module)
;    BIC #SD_BUS,&SD_REN             ; disable pullup resistors for SIMO/SOMI/SCK pins
    BIC #1,&SD_CTLW0                ; release eUSCI from reset

; ===========================================================
; 2- Init SD_Card
; ===========================================================

SD_POWER_ON
    MOV     #8,X                    ; send 64 clk on SD_clk
    CALL    #SPI_X_GET              ;
    BIC.B   #SD_CS,&SD_CSOUT        ; preset SD_CS output low to switch in SPI mode
    MOV     #4,S                    ; preset error 4R1
; ----------------------------------;
INIT_CMD0                           ; all SD area is 0 filled
; ----------------------------------;
    MOV     #95h,&SD_CMD_FRM        ; $(95 00 00 00 00 00)
    MOV     #4000h,&SD_CMD_FRM+4    ; $(95 00 00 00 00 40); send CMD0 
; ----------------------------------;
SEND_CMD0                           ; CMD0 : GO_IDLE_STATE expected SPI_R1 response = 1 = idle state
; ----------------------------------;
    CALL    #sendCommandIdleRet     ;X
    JZ      INIT_CMD8               ; if idle state
SD_INIT_ERROR                       ;
    MOV     #SD_CARD_ERROR,PC       ; ReturnError = $04R1, case of defectuous card (or insufficient SD_POWER_ON clk)
; ----------------------------------; see forthMSP430FR_SD_lowLvl.asm
INIT_CMD8                           ; mandatory if SD_Card >= V2.x     [11:8]supply voltage(VHS)
; ----------------------------------;
    CALL    #SPI_GET                ; (needed to pass SanDisk ultra 8GB "HC I")
    CMP.B   #-1,W                   ; FFh expected value <==> MISO = high level
    JNE     INIT_CMD8               ; loop back while yet busy
    MOV     #0AA87h,&SD_CMD_FRM     ; $(87 AA ...)  (CRC:CHECK PATTERN)
    MOV     #1,&SD_CMD_FRM+2        ; $(87 AA 01 00 ...)  (CRC:CHECK PATTERN:VHS set as 2.7to3.6V:0)
    MOV     #4800h,&SD_CMD_FRM+4    ; $(87 AA 01 00 00 48)
; ----------------------------------;
SEND_CMD8                           ; CMD8 = SEND_IF_COND; expected R1 response (first byte of SPI R7) = 01h : idle state
; ----------------------------------;
    CALL    #sendCommandIdleRet     ;X time out occurs with SD_Card V1.x (and all MMC_card) 
; ----------------------------------;
    MOV     #4,X                    ; skip end of SD_Card V2.x type R7 response (4 bytes), because useless
    CALL    #SPI_X_GET              ;WX
; ----------------------------------;
INIT_ACMD41                         ; no more CRC needed from here
; ----------------------------------;
    MOV     #1,&SD_CMD_FRM          ; $(01 00 ...   set stop bit
    MOV     #0,&SD_CMD_FRM+2        ; $(01 00 00 00 ...
;    MOV.B   #16,Y                   ; init 16 * ACMD41 repeats (power on fails with SanDisk ultra 8GB "HC I" and Transcend 2GB)
;    MOV.B   #32,Y                   ; init 32 * ACMD41 repeats ==> ~400ms time out
    MOV.B   #-1,Y                   ; init 255 * ACMD41 repeats ==> ~3 s time out
; ----------------------------------;
SEND_ACMD41                         ; send CMD55+CMD41
; ----------------------------------;
    MOV     #8,S                    ; preset error 8R1 for ACMD41
INIT_CMD55                          ;
    MOV     #7700h,&SD_CMD_FRM+4    ; $(01 00 00 00 00 77)
SEND_CMD55                          ; CMD55 = APP_CMD; expected SPI_R1 response = 1 : idle
    CALL    #sendCommandIdleRet     ;X
SEND_CMD41                          ; CMD41 = APP OPERATING CONDITION
    MOV     #6940h,&SD_CMD_FRM+4    ; $(01 00 00 00 40 69) (30th bit = HCS = High Capacity Support request)
    CALL    #WaitIdleBeforeSendCMD  ; wait until idle (needed to pass SanDisk ultra 8GB "HC I") then send Command CMD41
    JZ      SetBLockLength          ; if SD_Card ready (R1=0)
    SUB.B   #1,Y                    ; else decr time out delay
    JNZ     INIT_CMD55              ; then loop back while count of repeat not reached
    JMP     SD_INIT_ERROR           ; ReturnError on time out : unusable card
; ----------------------------------;
setBLockLength                      ; set block = 512 bytes (buffer size), usefull only for FAT16 SD Cards
; ----------------------------------;
    ADD     S,S                     ; preset error $10 for CMD16
SEND_CMD16                          ; CMD16 = SET_BLOCKLEN
    MOV     #02h,&SD_CMD_FRM+2      ; $(01 00 02 00 ...)
    MOV     #5000h,&SD_CMD_FRM+4    ; $(01 00 02 00 00 50) 
    CALL    #WaitIdleBeforeSendCMD  ; wait until idle then send CMD16
    JNZ     SD_INIT_ERROR           ; if W = R1 <> 0, ReturnError = $20R1 ; send command ko
; ----------------------------------;
SetHighSpeed                        ; end of SD init ==> SD_CLK = SMCLK
; ----------------------------------;
    BIS     #1,&SD_CTLW0            ; Software reset
    MOV     #0,&SD_BRW              ; UCxxBRW = 0 ==> SPI_CLK = MCLK
    BIC     #1,&SD_CTLW0            ; release from reset
; ----------------------------------;
Read_EBP_FirstSector                ; W=0, BS_FirstSectorHL=0
; ----------------------------------;
    CALL    #readSectorW            ; read physical first sector
    MOV     #SD_BUF,Y               ;
    MOV     454(Y),&BS_FirstSectorL ; so, sectors become logical
    MOV     456(Y),&BS_FirstSectorH ; 
    MOV.B   450(Y),W                ; W = partition ID 
; ----------------------------------;
TestPartitionID                     ;
; ----------------------------------;
    MOV     #1,&FATtype             ; preset FAT16
FAT16_CHS_LBA_Test                  ;
    SUB.B   #6,W                    ; ID=06h Partition FAT16 using CHS & LBA ?
    JZ      Read_MBR_FirstSector    ; W = 0
FAT16_LBA_Test                      ;
    SUB.B   #8,W                    ; ID=0Eh Partition FAT16 using LBA ?
    JZ      Read_MBR_FirstSector    ; W = 0
; ----------------------------------;
    MOV     #2,&FATtype             ; set FAT32
FAT32_LBA_Test                      ;
    ADD.B   #2,W                    ; ID=0Ch Partition FAT32 using LBA ?
    JZ      Read_MBR_FirstSector    ; W = 0
FAT32_CHS_LBA_Test                  ;
    ADD.B   #1,W                    ; ID=0Bh Partition FAT32 using CHS & LBA ?
    JZ      Read_MBR_FirstSector    ; W = 0
    ADD     #0200Bh,W               ;
    MOV     W,S                     ;
    MOV     #SD_CARD_ID_ERROR,PC    ; S = ReturnError = $20xx with xx = partition ID 
; ----------------------------------; see: https://en.wikipedia.org/wiki/Partition_type
Read_MBR_FirstSector                ; read first logical sector
; ----------------------------------;
    CALL    #readSectorW            ; ...with the good CMD17 bytes/sectors frame ! (good switch FAT16/FAT32)
; ----------------------------------;
FATxx_SetFileSystem                 ;
; ----------------------------------;
    MOV.B   13(Y),&SecPerClus       ;
    MOV     14(Y),X                 ;3 X = BPB_RsvdSecCnt
    MOV     X,&OrgFAT1              ;3 set OrgFAT1
    MOV     22(Y),W                 ; W = BPB_FATsize
    CMP     #0,W                    ; BPB_FATsize <> 0 ?
    JNZ     Set_FATsize             ; yes
    MOV     36(Y),W                 ; W = BPB_FATSz32
Set_FATsize                         ;
    MOV     W,&FATSize              ; limited to 16384 sectors....
    ADD     W,X                     ;
    MOV     X,&OrgFAT2              ; X = OrgFAT1 + FATsize = OrgFAT2
    ADD     W,X                     ; X = OrgFAT2 + FATsize = FAT16 OrgRootDir | FAT32 OrgDatas
    CMP     #2,&FATtype             ; FAT32?
    JZ      FATxx_SetFileSystemNext ; yes
FAT16_SetRootCluster                ;
    MOV     X,&OrgRootDIR           ; only FAT16 use, is a sector used by ComputeClusFrstSect
    ADD     #32,X                   ; OrgRootDir + RootDirSize = OrgDatas
FATxx_SetFileSystemNext             ;
    SUB     &SecPerClus,X           ; OrgDatas - SecPerClus*2 = OrgClusters
    SUB     &SecPerClus,X           ; no borrow expected
    MOV     X,&OrgClusters          ; X = virtual cluster 0 address (clusters 0 and 1 don't exist)
    MOV     &FATtype,&DIRClusterL   ; init DIRcluster as RootDIR
; ----------------------------------;


