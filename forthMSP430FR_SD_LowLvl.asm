; -*- coding: utf-8 -*-
; forthMSP430FR_SD_lowLvl.asm

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

; =====================================================================
; goal : accept 64 MB up to 64 GB SD_CARD
; =====================================================================
; thus FAT and RootClus logical sectors are word addressable.

; FAT is a little endian structure.
; CMD frame is sent as big endian.

; we assume that SDSC Card (up to 2GB) is FAT16 with a byte addressing
; and that SDHC Card (4GB up to 32GB) is FAT32 with a sector addressing (sector = 512 bytes)

; ref. https://en.wikipedia.org/wiki/Extended_boot_record
; ref. https://en.wikipedia.org/wiki/Partition_type

; Formatage FA16 d'une SDSC Card 2GB
; First sector of physical drive (sector 0) content :
; ---------------------------------------------------
; dec@| HEX@ =  HEX                                                        decimal
; 446 |0x1BE          : partition table first record  ==> logical drive 0       
; 446 |0x1CE          : partition table 2th record    ==> logical drive 1
; 446 |0x1DE          : partition table 3th record    ==> logical drive 2
; 446 |0x1EE          : partition table 4th record    ==> logical drive 3

; partition record content :
; ---------------------------------------------------
; dec@|HEX@ =  HEX                                                        decimal
; 0   |0x00 =  0x00     : not bootable
; 1   |0x01 =  02 0C 00 : Org Cylinder/Head/Sector offset (CHS-addressing) = not used
; 4   |0x04 =  0x0E     : type FAT16 using LBA addressing                  = 14 ==> FAT16
; 5   |0x05 =  ED 3F EE : End Cylinder/Head/Sector offset (CHS-addressing) = not used
; 8   |0x08 =  00 20 00 00 : sector offset of logical drive                = 8192
; 12  |0x0C =  00 40 74 00 : sector size of logical drive                  = 7618560 sectors

; 450 |0x04 =  0x0E     : type FAT16 using LBA addressing                  = 14 ==> set FATtype = FAT16 with byte CMD addressing
; 454 |0x1C6 = 89 00    : FirstSector (of logical drive 0) BS_FirstSector  = 137


; ref. https://www.compuphase.com/mbr_fat.htm#BOOTSECTOR

; FirstSector of logical drive (sector 0) content :
; -------------------------------------------------
; dec@| HEX@ =  HEX                                                         decimal
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
; dec@| HEX@ =  HEX                                                        decimal
; 446 |0x1BE          : partition table first record  ==> logical block 0       
; 446 |0x1CE          : partition table 2th record    ==> logical block 1
; 446 |0x1DE          : partition table 3th record    ==> logical block 2
; 446 |0x1EE          : partition table 4th record    ==> logical block 3

; partition record content :
; ---------------------------------------------------
; dec@|HEX@ =  HEX                                                        decimal
; 0   |0x00 =  0x00     : not bootable
; 1   |0x01 =  82 03 00 : Org CHS offset (Cylinder/Head/Sector)         = not used
; 4   |0x04 =  0x0C     : type FAT32 using LBA addressing               = 12 ==> set FATtype = FAT32 with sector CMD addressing
; 5   |0x05 =  82 03 00 : End offset (Cylinder/Head/Sector offset)      = not used
; 8   |0x08 =  00 20 00 00 : sector offset of logical block             = 8192
; 12  |0x0C =  00 40 74 00 : sector size of logical block               = 7618560

; 454 |0x1C6 = 00 20 00 00 : FirstSector (of logical drive 0) BS_FirstSector  = 8192

; 
; FirstSector of logical block (sector 0) content :
; -------------------------------------------------
; dec@| HEX@ =  HEX                                                     decimal
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


; all values below are evaluated in sectors
; FAT1           = BS_FirstSector + BPB_RsvdSecCnt = 8192 + 32 = 8224
; FAT2           = BS_FirstSector + BPB_RsvdSecCnt + BPB_FATSz32 = 8192 + 32 + 15152 = 23376
; OrgRootDirL    = BS_FirstSector + BPB_RsvdSecCnt + (BPB_FATSz32 * BPB_NumFATs) = 8192 + 32 + 15152*2 = 38528
; OrgCluster     = OrgRootDir - 2*BPB_SecPerClus = 38512
; RootDirSize    = BPB_RootEntCnt * 32 / BPB_BytsPerSec         = 0
; OrgDatas       = OrgRootDir + RootDirSize                     = 38512
; FirstSectorOfCluster(n) = OrgCluster + n*BPB_SecPerClus       ==> cluster(6) = 38560



BytsPerSec      .equ 512

; all sectors are computed as logical, then physically translated at last time by RW_Sector_CMD

; in SPI mode CRC is not required, but CMD frame must be ended with a stop bit
; ==================================;
RW_Sector_CMD                       ;WX <=== CMD17 or CMD24 (read or write Sector CMD)
; ==================================;
    BIC.B   #SD_CS,&SD_CSOUT        ; SD_CS low
    BIT.B   #SD_CD,&SD_CDIN         ; memory card present ?
    JZ      ComputePhysicalSector   ; yes
    MOV     #COLD,PC                ; no: force COLD
; ----------------------------------;
ComputePhysicalSector               ;
; ----------------------------------;
    ADD     &BS_FirstSectorL,W      ;3
    ADDC    &BS_FirstSectorH,X      ;3
; ----------------------------------;
    MOV     #1,&SD_CMD_FRM          ;3 $(01 00 xx xx xx CMD) (set stop bit)
    CMP     #2,&FATtype             ;3 FAT32 ?          
    JZ      FAT32_CMD               ;2 yes
FAT16_CMD                           ;  FAT16 : CMD17/24 byte address = Sector * BPB_BytsPerSec
    ADD     W,W                     ;  shift left one SectorL
    ADDC.B  X,X                     ;
    MOV     W,&SD_CMD_FRM+2         ;  $(01 00 ll LL xx CMD)
    MOV.B   X,&SD_CMD_FRM+4         ;  $(01 00 ll LL hh CMD) 
    JMP     SDbusyLoop
FAT32_CMD                           ;  FAT32 : CMD17/24 sector address
    MOV.B   W,&SD_CMD_FRM+1         ;3 $(01 ll xx xx xx CMD)
    SWPB    W                       ;1
    MOV.B   W,&SD_CMD_FRM+2         ;3 $(01 ll LL xx xx CMD)
    MOV.B   X,&SD_CMD_FRM+3         ;3 $(01 ll LL hh xx CMD)
    SWPB    X                       ;1
    MOV.B   X,&SD_CMD_FRM+4         ;3 $(01 ll LL hh HH CMD)
; ==================================;
SDbusyLoop                          ; <=== CMD41, CMD1, CMD16 (R1 expected response = 0 = ready)
; ==================================;
    CALL #SPI_GET                   ;
    CMP.B   #-1,W                   ; FFh expected value <==> MISO = 1 = not busy
    JNE SDbusyLoop                  ; loop back while yet busy
    MOV     #0,W                    ; W = expected R1 response = ready = 0, for CMD41, CMD1, CMD16, CMD17, CMD24

; ==================================;
sendCommand                         ;X <=== CMD0, CMD8, CMD55 (W = R1 expected response = 1 = idle)
; ==================================;
                                    ; input : SD_CMD_FRM : {CRC,byte_l,byte_L,byte_h,byte_H,CMD} 
                                    ;         W = expected return value
                                    ; output  W is unchanged, flag Z is positionned
                                    ; reverts CMD bytes before send : $(CMD hh LL ll 00 CRC)
    MOV     #5,X                    ; X = SD_CMD_FRM index AND countdown
; ----------------------------------;
Send_CMD_PUT                        ; performs little endian --> big endian conversion
; ----------------------------------;
    MOV.B   SD_CMD_FRM(X),&SD_TXBUF ;5 
    CMP     #0,&SD_BRW              ;3 full speed ?
    JZ      FullSpeedSend           ;2 yes
Send_CMD_Loop                       ;  no: case of low speed during memCardInit
    BIT     #UCRXIFG,&SD_IFG        ;3
    JZ      Send_CMD_Loop           ;2
    CMP.B   #0,&SD_RXBUF            ;3 to clear UCRXIFG
FullSpeedSend                       ;
;   NOP                             ;0 NOPx adjusted to avoid SD error
    SUB.B   #1,X                    ;1
    JHS     Send_CMD_PUT            ;2 U>= : don't skip SD_CMD_FRM(0) !

                                    ; host must provide height clock cycles to complete operation
                                    ; here X=255, so wait for CMD return expected value with PUT FFh 256 times

;    MOV     #4,X                    ; to pass made in PRC SD_Card init 
;    MOV     #16,X                   ; to pass Transcend SD_Card init
;    MOV     #32,X                   ; to pass Panasonic SD_Card init
;    MOV     #64,X                   ; to pass SanDisk SD_Card init
;    MOV     #1000,X                 ; max value
; ----------------------------------;
Wait_Command_Response               ; expect W = return value during X = 255 delay time
; ----------------------------------;
    SUB     #1,X                    ;1
    JN      SPI_WAIT_RET            ;2 error on time out with SR(Z) = 0
    MOV.B   #-1,&SD_TXBUF           ;3 PUT FFh
    CMP     #0,&SD_BRW              ;3 full speed ?
    JZ      FullSpeedGET            ;2 yes
cardResp_Getloop                    ;  no: case of low speed during memCardInit
    BIT     #UCRXIFG,&SD_IFG        ;3
    JZ      cardResp_Getloop        ;2
FullSpeedGET                        ;
;    NOP2                           ;2 NOPx adjusted to avoid SD_error
    CMP.B   &SD_RXBUF,W             ;3 return value = ExpectedValue ?
    JNZ     Wait_Command_Response   ;2
SPI_WAIT_RET                        ; SR(Z) = 1 <==> Return value = expected value
    RET                             ; expected value = W is unchanged
; ----------------------------------;


; SPI_GET and SPI_PUT are adjusted for SD_CLK = MCLK
; PUT value must be a word or  byte:byte because little endian to big endian conversion

; ==================================;
SPI_GET                             ; PUT(FFh)
; ==================================; output : W = received byte, X = 0 always
    MOV #1,X                        ;1
; ==================================;
SPI_X_GET                           ; PUT(FFh) X time
; ==================================; output : W = last received byte, X = 0
    MOV #-1,W                       ;1
; ==================================;
SPI_PUT                             ; PUT(W) X time
; ==================================; output : W = last received byte, X = 0
            SWPB W                  ;1
            MOV.B W,&SD_TXBUF       ;3 put W high byte then W low byte and so forth that performs little to big endian conversion
            CMP #0,&SD_BRW          ;3 full speed ?
            JZ FullSpeedPut         ;2 
SPI_PUTWAIT BIT #UCRXIFG,&SD_IFG    ;3
            JZ SPI_PUTWAIT          ;2
            CMP.B #0,&SD_RXBUF      ;3 reset RX flag
FullSpeedPut
;           NOP                     ;0 NOPx adjusted to avoid SD error
            SUB #1,X                ;1
            JNZ SPI_PUT             ;2
SPI_PUT_END MOV.B &SD_RXBUF,W       ;3
            RET                     ;4
; ----------------------------------;

; ==================================;
readFAT1SectorW                     ; read a FAT1 sector
; ==================================;
    ADD     &OrgFAT1,W              ;
; ==================================;
readSectorW                         ; read a logical sector up to 65535 (case of FAT1,FAT2,RootDIR)
; ==================================;
    MOV     #0,X                    ;
; ==================================;
readSectorWX                        ; read a logical sector
; ==================================;
    BIS     #1,S                    ; preset sd_read error
    MOV.B   #51h,&SD_CMD_FRM+5      ; CMD17 = READ_SINGLE_BLOCK
    CALL    #RW_Sector_CMD          ; which performs logical sector to physical sector then little endian to big endian conversions
    JNE     SD_CARD_ERROR           ; time out error if R1 <> 0 
; ----------------------------------;
WaitFEhResponse                     ; wait SD_Card response FEh
; ----------------------------------;
    CALL #SPI_GET                   ;
    CMP.B   #-2,W                   ; FEh expected value
    JNZ WaitFEhResponse             ;
; ----------------------------------;
ReadSectorLoop                      ; 16 cycles loop read byte, starts with X = 0
; ----------------------------------;
    MOV.B   #-1,&SD_TXBUF           ; 3 put FF
    NOP3                            ; 3 NOPx adjusted to avoid read SD_error
    ADD     #1,X                    ; 1
    CMP     #BytsPerSec,X           ; 2
    MOV.B   &SD_RXBUF,BUFFER-1(X)   ; 5
    JNZ     ReadSectorLoop          ; 2
; ----------------------------------;
ReadSkipCRC16                       ; not used in SPI mode
; ----------------------------------;
    MOV     #2,X                    ;
    CALL    #SPI_X_GET              ;
; ----------------------------------;
ReadWriteHappyEnd                   ;
; ----------------------------------;
    BIC     #3,S                    ; reset read and write errors
    BIS.B   #SD_CS,&SD_CSOUT        ; SD_CS = high  
    RET                             ; 
; ----------------------------------;

    .IFDEF SD_CARD_READ_WRITE

; ==================================;
WriteSectorW                        ; write a logical sector up to 65535 (FAT1,FAT2,RootDIR)
; ==================================;
    MOV     #0,X                    ;
; ==================================;
WriteSectorWX                       ; write a logical sector
; ==================================;
    BIS     #2,S                    ; preset sd_write error
    MOV.B   #058h,SD_CMD_FRM+5      ; CMD24 = WRITE_SINGLE_BLOCK
    CALL    #RW_Sector_CMD          ; which performs logical sector to physical sector then little endian to big endian conversions
    JNE     SD_CARD_ERROR           ; ReturnError = 2
    MOV     #0FFFEh,W               ; PUT FFFEh as preamble requested for sector write
    MOV     #2,X                    ; to put 16 bits value
    CALL    #SPI_PUT                ; which performs little endian to big endian conversion
; ----------------------------------;
WriteSectorLoop                     ; 11 cycles loop write, starts with X = 0
; ----------------------------------;
    MOV.B   BUFFER(X),&SD_TXBUF     ; 5
    NOP                             ; 1 NOPx adjusted to avoid write SD_error
    ADD     #1,X                    ; 1
    CMP     #BytsPerSec,X           ; 2
    JNZ     WriteSectorLoop         ; 2
; ----------------------------------;
WriteSkipCRC16                      ; not used in SPI mode
; ----------------------------------;
    MOV     #3,X                    ; PUT 2 bytes to skip CRC16
    CALL    #SPI_X_GET              ; + 1 byte to get data token in W
; ----------------------------------;
CheckWriteState                     ;
; ----------------------------------;
    BIC.B   #0E1h,W                 ; apply mask for Data response
    CMP.B   #4,W                    ; data accepted
    JZ      ReadWriteHappyEnd       ;
; ----------------------------------;

    .ENDIF ; SD_CARD_READ_WRITE

; SD Error n°
; High byte
; 1  = CMD17    read error
; 2  = CMD24    write error 
; 4  = CMD0     time out (GO_IDLE_STATE)
; 8  = CMD1     time out (SEND_OP_COND), reserved for MMC_Card
; 10 = ACMD41   time out (APP_SEND_OP_COND)
; 20 = CMD16    time out (SET_BLOCKLEN)
; 40 = not FAT16/FAT32 media, low byte = partition ID

; low byte, if CMD R1 response : |0|7|6|5|4|3|2|1|
; 1th bit = In Idle state
; 2th bit = Erase reset
; 3th bit = Illegal command
; 4th bit = Command CRC error
; 5th bit = erase sequence error
; 6th bit = address error
; 7th bit = parameter error

; ----------------------------------;
SD_CARD_ERROR                       ; <=== SD_INIT errors 4,8,10,20,40
; ----------------------------------;
    BIS.B #SD_CS,&SD_CSOUT          ; SD_CS = high
    SWPB S                          ; High Level error in High byte
    ADD &SD_RXBUF,S                 ; add SPI(GET) return value to high level error
    mDOCOL                          ;
    .word   XSQUOTE                 ;
    .byte   11,"< SD Error!"        ;
; ----------------------------------;
SD_QABORTYES                        ; <=== OPEN/READ and WRITE errors
; ----------------------------------;
    FORTHtoASM                      ;
    SUB #4,PSP                      ;
    MOV TOS,2(PSP)                  ;
    MOV &BASE,0(PSP)                ;
    MOV #10h,&BASE                  ; select hex
    MOV S,TOS                       ;
    ASMtoFORTH                      ;
    .word   UDOT                    ;
    .word   FBASE,STORE             ; restore base
    .word   QABORTYES               ;
; ----------------------------------;

