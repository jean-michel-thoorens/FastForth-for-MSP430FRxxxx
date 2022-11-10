\ -*- coding: utf-8 -*-

SD_LOAD.f
\ ===========================================================
\ ABOUT INIT SD_CARD AND HOW TO SELECT FAT16/FAT32 FORMAT
\ ===========================================================
\ FAT16/FAT32 selection is made via the ID of partition in EBP
\ because SD must be always FAT16 and SDHC must be always FAT32
\ this is automatically done when we format the SD_Card !


\ =====================================================================
\ goal : accept 64 MB up to 64 GB SD_CARD
\ =====================================================================
\ thus FAT and RootClus logical sectors are word addressable.

\ FAT is a little endian structure.
\ CMD frame is sent as big endian.

\ we assume that SDSC Card (up to 2GB) is FAT16 with a byte addressing
\ and that SDHC Card (4GB up to 64GB) is FAT32 with a sector addressing (sector = 512 bytes)
\ for SDHC Card = 64 GB, cluster = 64 sectors ==> max clusters = 20 0000h ==> FAT size = 16384 sectors
\ ==> FAT1 and FAT2 can be addressed with a single word.

\ ref. https://en.wikipedia.org/wiki/Extended_boot_record
\ ref. https://en.wikipedia.org/wiki/Partition_type

\ Formatage FA16 d'une SDSC Card 2GB
\ First sector of physical drive (sector 0) content :
\ ---------------------------------------------------
\ dec@| HEX@
\ 446 |0x1BE    : partition table first record  ==> logical drive 0       
\ 462 |0x1CE    : partition table 2th record    ==> logical drive 1
\ 478 |0x1DE    : partition table 3th record    ==> logical drive 2
\ 494 |0x1EE    : partition table 4th record    ==> logical drive 3

\ partition of first record content :
\ ---------------------------------------------------
\ 450 |0x1C2 = 0x0E         : type FAT16 using LBA addressing
\ 454 |0x1C6 = 89 00 00 00  : FirstSector (of logical drive 0) BS_FirstSector  = 137


\ Partition type Description
\ 0	    empty / unused
\ 1	    FAT12
\ 4	    FAT16 for partitions <= 32 MiB
\ 5	    extended partition
\ 6	    FAT16 for partitions > 32 MiB
\ 11	FAT32 for partitions <= 2 GiB
\ 12	Same as type 11 (FAT32), but using LBA addressing, which removes size constraints
\ 14	Same as type 6 (FAT16), but using LBA addressing
\ 15	Same as type 5, but using LBA addressing
\ ref. https://www.compuphase.com/mbr_fat.htm#BOOTSECTOR

\ FirstSector of logical drive (sector 0) content :
\ -------------------------------------------------
\ dec@| HEX@ =  HEX                                                       decimal
\ 11  | 0x0B = 00 02        : 512 bytes/sector          BPB_BytsPerSec  = 512
\ 13  | 0x0D = 40           : 64 sectors/cluster        BPB_SecPerClus  = 64
\ 14  | 0x0E = 01 00        : 2 reserved sectors        BPB_RsvdSecCnt  = 1
\ 16  | 0x10 = 02           : 2 FATs                    BPB_NumFATs     = 2 (always 2)
\ 17  | 0x11 = 00 02        : 512 entries/directory     BPB_RootEntCnt  = 512
\ 19  | 0x13 = 00 00        : BPB_TotSec16 (if < 65535) BPB_TotSec16    = 0
\ 22  | 0x16 = EB 00        : 235 sectors/FAT (FAT16)   BPB_FATSize     = 235
\ 32  | 0x20 = 77 9F 3A 00  : ‭3841911‬ total sectors     BPB_TotSec32    = ‭3841911‬
\ 54  | 0x36 = "FAT16"                                  BS_FilSysType   (not used)

\ all values below are evaluated in logical sectors
\ FAT1           = BPB_RsvdSecCnt = 1
\ FAT2           = BPB_RsvdSecCnt + BPB_FATSz32 = 1 + 235 = 236
\ OrgRootDirL    = BPB_RsvdSecCnt + (BPB_FATSize * BPB_NumFATs) = 471
\ RootDirSize    = BPB_RootEntCnt * 32 / BPB_BytsPerSec         = 32 sectors
\ OrgDatas       = OrgRootDir + RootDirSize                     = 503
\ OrgCluster     = OrgRootDir - 2*BPB_SecPerClus                = 375 (virtual value)
\ FirstSectorOfCluster(n) = OrgCluster + n*BPB_SecPerClus       ==> cluster(3) = 705

\ ====================================================================================

\ Formatage FA32 d'une SDSC Card 8GB
\ First sector of physical drive (sector 0) content :
\ ---------------------------------------------------
\ dec@| HEX@
\ 446 |0x1BE    : partition table first record  ==> logical drive 0       
\ 462 |0x1CE    : partition table 2th record    ==> logical drive 1
\ 478 |0x1DE    : partition table 3th record    ==> logical drive 2
\ 494 |0x1EE    : partition table 4th record    ==> logical drive 3

\ partition record content :
\ ---------------------------------------------------
\ 450 |0x1C2 = 0x0C         : type FAT32 using LBA addressing
\ 454 |0x1C6 = 00 20 00 00  : FirstSector (of logical drive 0) = BS_FirstSector = 8192

\ 
\ FirstSector of logical block (sector 0) content :
\ -------------------------------------------------
\ dec@| HEX@ =  HEX                                                       decimal
\ 11  | 0x0B = 00 02        : 512 bytes/sector          BPB_BytsPerSec  = 512
\ 13  | 0x0D = 08           : 8 sectors/cluster         BPB_SecPerClus  = 8
\ 14  | 0x0E = 20 00        : 32 reserved sectors       BPB_RsvdSecCnt  = 32
\ 16  | 0x10 = 02           : 2 FATs                    BPB_NumFATs     = 2 (always 2)
\ 17  | 0x11 = 00 00        : 0                         BPB_RootEntCnt  = 0 (always 0 for FAT32)

\ 32  | 0x20 = 00 C0 EC 00  : BPB_TotSec32              BPB_TotSec32    = 15515648
\ 36  | 0x24 = 30 3B 00 00  : BPB_FATSz32               BPB_FATSz32     = 15152
\ 40  | 0x28 = 00 00        : BPB_ExtFlags              BPB_ExtFlags 
\ 44  | 0x2C = 02 00 00 00  : BPB_RootClus              BPB_RootClus    = 2
\ 48  | 0x30 = 01 00        : BPB_FSInfo                BPB_FSInfo      = 1
\ 50  | 0x33 = 06 00        : BPB_BkBootSec             BPB_BkBootSec   = 6
\ 82  | 0x52 = "FAT32"      : BS_FilSysType             BS_FilSysType   (not used)

\ 
\ all values below are evaluated in logical sectors
\ FAT1           = BPB_RsvdSecCnt = 32
\ FAT2           = BPB_RsvdSecCnt + BPB_FATSz32 = 32 + 15152 = 15184
\ OrgRootDirL    = BPB_RsvdSecCnt + BPB_FATSz32 * BPB_NumFATs = 32 + 15152*2 = 30336
\ OrgCluster     = OrgRootDir - 2*BPB_SecPerClus = 30320
\ RootDirSize    = BPB_RootEntCnt * 32 / BPB_BytsPerSec         = 0
\ OrgDatas       = OrgRootDir + RootDirSize                     = 30336
\ FirstSectorOfCluster(n) = OrgCluster + n*BPB_SecPerClus       ==> cluster(6) = 30368

\ SPI_GET and SPI_PUT are adjusted for SD_CLK = MCLK
\ PUT value must be a word or  byte:byte because little endian to big endian conversion


    MARKER {SD_APP}
\ CFA = DODOES
\ PFA = MARKER_DOES
\ BODY   = DP value before MARKER definition
\ BODY+2 = VOClink value before MARKER definition
\ BODY+4 = RET_ADR: by default MARKER_DOES does a call to RET_ADR (does nothing)
    10 ALLOT \ make room for:
\ {SD_APP}+10 = content of previous ....
\ {SD_APP}+12 = content of previous ....
\ {SD_APP}+14 = content of previous ....
\ {SD_APP}+16 = content of previous ....
\ {SD_APP}+18 = content of previous ....



\   ====================================\
    HDNCODE SPI_GET                     \ PUT(FFh) one time, output : W = received byte, X = 0
\   ====================================\
    MOV #1,X                            \
\   ====================================\
\   SPI_X_GET                           \ PUT(FFh) X times, output : W = last received byte, X = 0
\   ====================================\
    MOV #-1,W                           \
\   ====================================\
\   SPI_PUT                             \ PUT(W) X times, output : W = last received byte, X = 0
\   ====================================\
    BEGIN
        SWPB W                          \ 1 
        MOV.B W,&SD_TXBUF               \ 3 put W high byte then W low byte and so forth, that performs little to big endian conversion
        CMP #0,&SD_BRW                  \ 3 full speed ?
        0<> IF                          \ no
            BEGIN
                BIT #RX_SD,&SD_IFG      \ 3
            0<> UNTIL
                CMP.B #0,&SD_RXBUF      \ 3 clear RX_BUF flag
        THEN
\        NOP                             \  NOPx adjusted to avoid SD error
        SUB #1,X                        \ 1
    0= UNTIL                            \ 2 12~ loop
    MOV.B &SD_RXBUF,W                   \ 3
    MOV @RSP+,PC                        \ 4 X=0
    ENDCODE
\   ------------------------------------\

\ in SPI mode CRC is not required, but CMD frame must be ended with a stop bit
\   ====================================\
    HDNCODE REWR_CMD                    \ WX <=== CMD17 or CMD24 (read or write Sector CMD)
\   ====================================\
    BIC.B #CS_SD,&SD_CSOUT              \ set Chip Select low
    BIT.B #CD_SD,&SD_CDIN               \ test Card Detect: memory card present ?
    0<> IF                              \
        MOV #COLD,PC                    \ no: force COLD
    THEN                                \ yes
\   ------------------------------------\ input = logical sector...
    ADD &BS_FirstSectorL,W              \ 3
    ADDC &BS_FirstSectorH,X             \ 3
\   ------------------------------------\ ...output = physical sector
\   Compute CMD                         \
\   ------------------------------------\
    MOV #1,&SD_CMD_FRM                  \ 3 $(01 00 xx xx xx CMD) set stop bit in CMD frame
    CMP #1,&FATtype                     \ 3 FAT16 ? 
    0= IF                               \ 2 yes : CMD17/24 byte address = Sector * BPB_BytsPerSec
        ADD     W,W                     \ 1 shift left one Sector
        ADDC.B  X,X                     \ 1
        MOV     W,&SD_CMD_FRM+2         \ 3 $(01 00 ll LL xx CMD)
        MOV.B   X,&SD_CMD_FRM+4         \ 3 $(01 00 ll LL hh CMD) 
    ELSE                                \  FAT32 : CMD17/24 sector address
        MOV.B   W,&SD_CMD_FRM+1         \ 3 $(01 ll xx xx xx CMD)
        SWPB    W                       \ 1
        MOV.B   W,&SD_CMD_FRM+2         \ 3 $(01 ll LL xx xx CMD)
        MOV.B   X,&SD_CMD_FRM+3         \ 3 $(01 ll LL hh xx CMD)
        SWPB    X                       \ 1
        MOV.B   X,&SD_CMD_FRM+4         \ 3 $(01 ll LL hh HH CMD)
    THEN    
\   ====================================\
BW1 \   WaitIdleBeforeSendCMD           \ <=== CMD41, CMD1, CMD16 (forthMSP430FR_SD_INIT.asm)
\   ====================================\
    BEGIN                               \
        CALL #SPI_GET                   \
        ADD.B   #1,W                    \ expected value = FFh <==> MISO = 1 = SPI idle state
    0= UNTIL                            \ loop back if <> FFh
\   ====================================\ W = 0 = expected R1 response = ready, for CMD41,CMD16, CMD17, CMD24
BW2 \   sendCommand                     \ sendCommand = WaitIdleBeforeSendCMD+8
\   ====================================\
                                        \ input : SD_CMD_FRM : {CRC,byte_l,byte_L,byte_h,byte_H,CMD} 
                                        \         W = expected return value
                                        \ output  W is unchanged, flag Z is positionned
                                        \ reverts CMD bytes before send : $(CMD hh LL ll 00 CRC)
    MOV #5,X                            \ X = SD_CMD_FRM ptr AND countdown
\   ------------------------------------\
\   Send_CMD_PUT                        \ performs little endian --> big endian conversion
\   ------------------------------------\
    BEGIN
        MOV.B   SD_CMD_FRM(X),&SD_TXBUF \ 5 
        CMP     #0,&SD_BRW              \ 3 full speed ?
        0<> IF                          \ no
            BEGIN                       \  case of low speed during memCardInit
                BIT #RX_SD,&SD_IFG      \ 3
                JZ  Send_CMD_Loop       \ 2
            0<> UNTIL
            CMP.B #0,&SD_RXBUF          \ 3 to clear UCRXIFG
        THEN    
\        NOP                             \ 0 NOPx adjusted to avoid SD error
        SUB.B   #1,X                    \ 1
    U< UNTIL                            \ 2 don't skip SD_CMD_FRM(0) !
                                        \ host must provide height clock cycles to complete operation
                                        \ here X=255, so wait for CMD return expected value with PUT FFh 256 times
\    MOV #4,X                           \ to pass made in PRC SD_Card init 
\    MOV #16,X                          \ to pass Transcend SD_Card init
\    MOV #32,X                          \ to pass Panasonic SD_Card init
\    MOV #64,X                          \ to pass SanDisk SD_Card init
\   ------------------------------------\ expect W = return value during X = 255 times
    BEGIN
        SUB #1,X                        \ 1
    0>= WHILE                           \ 2 if out of loop, error on time out with flag Z = 0
        MOV.B   #-1,&SD_TXBUF           \ 3 PUT FFh
        CMP     #0,&SD_BRW              \ 3 full speed ?
        0<> IF                          \
            BEGIN                       \  case of low speed during memCardInit (CMD0,CMD8,ACMD41,CMD16)
                BIT #RX_SD,&SD_IFG      \ 3
            0<> UNTIL                   \ 2
        THEN
\        NOP                             \  NOPx adjusted to avoid SD_error
        CMP.B   &SD_RXBUF,W             \ 3 return value = ExpectedValue ?
    0= UNTIL                            \ 2 16~ full speed loop
    THEN                                \ WHILE resolution
    MOV @RSP+,PC                        \ W = expected value, unchanged
\   ------------------------------------\ flag Z = 1 <==> Returned value = expected value

\   ------------------------------------\
    HDNCODE CMD_IDLE                    \ <=== CMD0, CMD8, CMD55: W = 1 = R1 expected response = idle (forthMSP430FR_SD_INIT.asm)
\   ------------------------------------\
    MOV     #1,W                        \ expected R1 response (first byte of SPI R7) = 01h : idle state
    GOTO BW2                            \
\   ------------------------------------\


\ SD Error n°
\ High byte
\ 1   = CMD17    read error
\ 2   = CMD24    write error 
\ 4   = CMD0     time out (GO_IDLE_STATE)
\ 8   = ACMD41   time out (APP_SEND_OP_COND)
\ $10 = CMD16    time out (SET_BLOCKLEN)
\ $20 = not FAT16/FAT32 media, low byte = partition ID

\ low byte, if CMD R1 response : %0xxx_xxxx
\ 1th bit = In Idle state
\ 2th bit = Erase reset
\ 3th bit = Illegal command
\ 4th bit = Command CRC error
\ 5th bit = erase sequence error
\ 6th bit = address error
\ 7th bit = parameter error

\ Data Response Token
\ Every data block written to the card will be acknowledged by a data response token. 
\ It is one byte long and has the following format:
\ %xxxx_sss0 with bits(3-1) = Status
\The meaning of the status bits is defined as follows:
\'010' - Data accepted.
\'101' - Data rejected due to a CRC error.
\'110' - Data Rejected due to a Write Error

\ ----------------------------------\
CODE ABORT_SD                       \ <=== OPEN file errors from forthMSP430FR_SD_LOAD.asm
\ ----------------------------------\
    SUB #2,PSP                      \
    MOV TOS,0(PSP)                  \
    MOV #10h,&BASE                  \ select hex
    MOV S,TOS                       \
\    MOV #TIB_ORG,&CIB_ADR           \               restore TIB as Current Input Buffer
\    MOV #BODYACCEPT,&PFAACCEPT      \               restore default ACCEPT
    LO2HI                           \
    U. 
    HI2LO
    MOV #ABORT_TERM,PC              \ no return...
ENDCODE
\ ----------------------------------\

\ ----------------------------------\
CODE SD_ERROR                       \ <=== SD_INIT errors 4,8,$10
\ ----------------------------------\
    SWPB S                          \ High Level error in High byte
    ADD &SD_RXBUF,S                 \ add SPI(GET) return value as low byte error
BW3 \ SD_CARD_ID_ERROR                  \ <=== SD_INIT error $20 from forthMSP430FR_SD_LowLvl.asm
    BIS.B #CS_SD,&SD_CSOUT          \ Chip Select high
    COLON                           \
    S" < SD Error!"                 \ don't use S register
    ABORT_SD
    ;

\ ==================================\
    CODE READ_SWX                   \ Read Sector
\ ==================================\
    BIS #1,S                        \ preset sd_read error
    MOV.B #51h,&SD_CMD_FRM+5        \ CMD17 = READ_SINGLE_BLOCK
    CALL #REWR_CMD                  \ which performs logical sector to physical sector then little endian to big endian conversion
    0<> ?GOTO BW3                   \ SD_ERROR        \ time out error if R1 <> 0 
\   ------------------------------------\
    BEGIN                               \ wait SD_Card response FEh
\   ------------------------------------\
        CALL #SPI_GET                   \
        ADD.B #2,W                      \ 1 FEh expected value
    0= UNTIL
\   ------------------------------------\
    BEGIN                               \ get 512+1 bytes, write 512 bytes in SD_BUF
\   ------------------------------------\
        MOV.B   #-1,&SD_TXBUF           \ 3 put FF
        NOP                             \ 1 NOPx adjusted to avoid read SD_error
        ADD     #1,X                    \ 1
        CMP     #BytsPerSec+1,X         \ 2
    0<> WHILE
        MOV.B   &SD_RXBUF,SD_BUF-1(X)   \ 5
    REPEAT
\   ------------------------------------\
    MOV.B #-1,&SD_TXBUF                 \ 3 put only one FF because first CRC byte is already received...
\   ------------------------------------\
\   ReadWriteHappyEnd                   \ <==== WriteSector
\   ------------------------------------\
BW2 BIC #3,S                            \ reset read and write errors
    BIS.B #CS_SD,&SD_CSOUT              \ Chip Select high
    MOV @RSP+,PC                        \
    ENDCODE
\   ------------------------------------\

\    .IFDEF SD_CARD_READ_WRITE

\   ====================================\
    CODE WRITE_SWX                      \ Write Sector
\   ====================================\
    BIS     #2,S                        \ preset sd_write error
    MOV.B   #058h,SD_CMD_FRM+5          \ CMD24 = WRITE_SINGLE_BLOCK
    CALL    #CMD_RW                     \ which performs logical sector to physical sector then little endian to big endian conversions
    0<> ?GOTO BW3                       \ ReturnError = 2
    MOV     #2,X                        \ to put 16 bits value
    CALL    #SPI_PUT                    \ which performs little endian to big endian conversion
    BEGIN                               \ 11 cycles loop write, starts with X = 0
        MOV.B   SD_BUF(X),&SD_TXBUF     \ 5
        NOP                             \ 1 NOPx adjusted to avoid write SD_error
        ADD     #1,X                    \ 1
        CMP     #BytsPerSec,X           \ 2
    0= UNTIL
\   ------------------------------------\ CRC16 not used in SPI mode
    MOV     #3,X                        \ PUT 2 bytes to skip CRC16
    CALL    #SPI_X_GET                  \ + 1 byte to get data token in W
\   ------------------------------------\ CheckWriteState 
    BIC.B   #0E1h,W                     \ apply mask for Data response
    CMP.B   #4,W                        \ data accepted
    0= ?GOTO BW2                        \ goto ReadWriteHappyEnd
    GOTO BW3                            \ goto SD_ERROR
    ENDCODE
\ ----------------------------------\

\    .ENDIF \ SD_CARD_READ_WRITE

\ ===========================================================
\ Init SD_Card
\ ===========================================================
\ ----------------------------------\
    CODE INIT_SD
\ ----------------------------------\
    CALL #INIT_TERM                     \ which activates all previous I/O settings and set TOS = RSTIV_MEM.
\ ----------------------------------\
    CMP #0,TOS                          \ RSTIV_MEM = WARM ?
    0<> IF                              \ init if RSTIV_MEM <> WARM
\ ----------------------------------\
        BIT.B #CD_SD,&SD_CDIN           \ SD_memory in SD_Card module ?
\        JNZ INI_SD_END                  \ no
        0= IF                           \ yes
\ ----------------------------------\
            MOV #$0A981,&SD_CTLW0       \ UCxxCTL1  = CKPH, MSB, MST, SPI_3, SMCLK  + UCSWRST
            MOV #FREQUENCY*3,&SD_BRW    \ UCxxBRW init SPI CLK = 333 kHz ( < 400 kHz) for SD_Card initialisation
            BIS.B #CS_SD,&SD_CSDIR      \ SD Chip Select as output high
            BIS #BUS_SD,&SD_SEL         \ Configure pins as SIMO, SOMI & SCK (PxDIR.y are controlled by eUSCI module)
            BIC #1,&SD_CTLW0            \ release eUSCI from reset
\ ----------------------------------\
            MOV #SD_LEN,X               \                      
            BEGIN                       \ case of MSP430FR57xx : SD datas are in FRAM not initialized by RESET. 
                SUB #2,X                \ 1
                MOV #0,SD_ORG(X)        \ 3 
            0= UNTIL                    \ 2
\ ----------------------------------\
\ SD_POWER_ON
\ ----------------------------------\
            MOV #8,X                    \ send 64 clk on SD_clk
            CALL #SPI_X_GET             \
            BIC.B #CS_SD,&SD_CSOUT      \ preset Chip Select output low to switch in SPI mode
\ ----------------------------------\
\ INIT_CMD0                         \ all SD area is 0 filled
\ ----------------------------------\
            MOV #4,S                    \ preset error 4R1 for CMD0
            MOV #$95,&SD_CMD_FRM        \ $(95 00 00 00 00 00)
            MOV #$4000,&SD_CMD_FRM+4    \ $(95 00 00 00 00 40)\ send CMD0 
\ ----------------------------------\
\ SEND_CMD0                           \ CMD0 : GO_IDLE_STATE expected SPI_R1 response = 1 = idle state
\ ----------------------------------\
            CALL #sendCommandIdleRet     \ X
            0<> IF \      INIT_CMD8           \ if no idle state
                MOV #SD_ERROR,PC        \ ReturnError = $04R1, case of defectuous card (or insufficient SD_POWER_ON clk)
            THEN
\ ----------------------------------\ see forthMSP430FR_SD_lowLvl.asm
\ INIT_CMD8                           \ mandatory if SD_Card >= V2.x     [11:8]supply voltage(VHS)
\ ----------------------------------\
            BEGIN
                CALL #SPI_GET           \ (needed to pass SanDisk ultra 8GB "HC I")
                CMP.B #-1,W             \ FFh expected value <==> MISO = high level
\                JNE     INIT_CMD8           \ loop back while yet busy
            0= UNTIL
            MOV #$0AA87,&SD_CMD_FRM     \ $(87 AA ...)  (CRC:CHECK PATTERN)
            MOV #1,&SD_CMD_FRM+2        \ $(87 AA 01 00 ...)  (CRC:CHECK PATTERN:VHS set as 2.7to3.6V:0)
            MOV #$4800,&SD_CMD_FRM+4    \ $(87 AA 01 00 00 48)
\ ----------------------------------\
\ SEND_CMD8                           \ CMD8 = SEND_IF_COND\ expected R1 response (first byte of SPI R7) = 01h : idle state
\ ----------------------------------\
            CALL #sendCommandIdleRet     \X time out occurs with SD_Card V1.x (and all MMC_card) 
\ ----------------------------------\
            MOV #4,X                    \ skip end of SD_Card V2.x type R7 response (4 bytes), because useless
            CALL #SPI_X_GET             \WX
\ ----------------------------------\
INIT_ACMD41                         \ no more CRC needed from here
\ ----------------------------------\
            MOV #1,&SD_CMD_FRM          \ $(01 00 ...   set stop bit
            MOV #0,&SD_CMD_FRM+2        \ $(01 00 00 00 ...
\            MOV.B   #16,Y                   \ init 16 * ACMD41 repeats (power on fails with SanDisk ultra 8GB "HC I" and Transcend 2GB)
\            MOV.B   #32,Y                   \ init 32 * ACMD41 repeats ==> ~400ms time out
            MOV.B #-1,Y                 \ init 255 * ACMD41 repeats ==> ~3 s time out
            MOV #8,S                    \ preset error 8R1 for ACMD41
\ ----------------------------------\
\ SEND_ACMD41                         \ send CMD55+CMD41
\ ----------------------------------\
            BEGIN
\ INIT_CMD55                          \
                MOV #$7700,&SD_CMD_FRM+4    \ $(01 00 00 00 00 77)
\ SEND_CMD55                          \ CMD55 = APP_CMD\ expected SPI_R1 response = 1 : idle
                CALL #sendCommandIdleRet     \X
\ SEND_CMD41                          \ CMD41 = APP OPERATING CONDITION
                MOV #$6940,&SD_CMD_FRM+4    \ $(01 00 00 00 40 69) (30th bit = HCS = High Capacity Support request)
                CALL #WaitIdleBeforeSendCMD  \ wait until idle (needed to pass SanDisk ultra 8GB "HC I") then send Command CMD41
\    JZ      SetBLockLength          \ if SD_Card ready (R1=0)
            0<> WHILE                       \ if SD_Card not ready (R1<>0) 
                SUB.B #1,Y                    \ else decr time out delay
\    JNZ     INIT_CMD55              \ then loop back while count of repeat not reached
                0= IF
                    MOV #SD_ERROR,PC    \ ReturnError on time out : unusable card  (or insufficient Vdd SD)
                THEN
            REPEAT                          \
\ ----------------------------------\
\ setBLockLength                      \ set block = 512 bytes (buffer size), usefull only for FAT16 SD Cards
\ ----------------------------------\
            ADD S,S                     \ preset error $10 for CMD16
\ SEND_CMD16                          \ CMD16 = SET_BLOCKLEN
            MOV #$02,&SD_CMD_FRM+2      \ $(01 00 02 00 ...)
            MOV #$5000,&SD_CMD_FRM+4    \ $(01 00 02 00 00 50) 
            CALL #WaitIdleBeforeSendCMD  \ wait until idle then send CMD16
            0<> IF
                MOV #SD_ERROR,PC        \ if W = R1 <> 0, ReturnError = $20R1 \ send command ko
            THEN                        \
\ ----------------------------------\ W = R1 = 0
\ SwitchSPIhighSpeed                  \ end of SD init ==> SD_CLK = SMCLK
\ ----------------------------------\
            BIS #1,&SD_CTLW0            \ Software reset
            MOV #0,&SD_BRW              \ UCxxBRW = 0 ==> SPI_CLK = MCLK
            BIC #1,&SD_CTLW0            \ release from reset
\ ----------------------------------\
\ Read_EBP_FirstSector                \ W=0, BS_FirstSectorHL=0
\ ----------------------------------\
            MOV #0,X
            CALL #readSectorWX           \ read physical first sector
            MOV #SD_BUF,Y               \
            MOV 454(Y),&BS_FirstSectorL \ so, sectors become logical
            MOV 456(Y),&BS_FirstSectorH \ 
            MOV.B 450(Y),W              \ W = partition ID 
\ ----------------------------------\
\ TestPartitionID                   \
\ ----------------------------------\
            MOV #1,&FATtype         \ preset FAT16
\ FAT16_CHS_LBA_Test                \
            SUB.B #6,W              \ ID=06h Partition FAT16 > 32MB using CHS & LBA ?
            0<> IF                  \ no
\ FAT16_LBA_Test                    \
                SUB.B #8,W              \ ID=0Eh Partition FAT16 using LBA ?
                0<> IF                  \ no
\ ----------------------------------\
                    MOV #2,&FATtype         \ set FAT32
\ FAT32_LBA_Test                            \
                    ADD.B #2,W              \ ID=0Ch Partition FAT32 using LBA ?
                    0<> IF                  \ no
\ FAT32_CHS_LBA_Test                            \
                        ADD.B #1,W              \ ID=0Bh Partition FAT32 using CHS & LBA ?
                        0<> IF                  \ no
                            ADD.B #4,W              \ ID=07h assigned to FAT 32 by MiniTools Partition Wizard....
                            0<> IF                  \ no
                                ADD #0$200B,W           \
                                MOV W,S                 \
                                MOV #SD_CARD_ID_ERROR,PC    \ S = ReturnError = $20xx with xx = partition ID 
                            THEN
                        THEN
                    THEN
                THEN
            THEN
\ ----------------------------------\ see: https://en.wikipedia.org/wiki/Partition_type
\ Read_MBR_FirstSector              \ read first logical sector
\ ----------------------------------\ W = 0
            MOV #0,X
            CALL #READ_SWX          \ ...with the good CMD17 bytes/sectors frame ! (good switch FAT16/FAT32)
\ ----------------------------------\
\ FATxx_SetFileSystem               \
\ ----------------------------------\
            MOV.B 13(Y),&SecPerClus     \
            MOV 14(Y),X                 \ 3 X = BPB_RsvdSecCnt
            MOV X,&OrgFAT1              \ 3 set OrgFAT1
            MOV 22(Y),W                 \ W = BPB_FATsize
            CMP #0,W                    \ BPB_FATsize = 0 ?
            0= IF                       
                MOV 36(Y),W             \ W = BPB_FATSz32
            THEN
\ Set_FATsize                           \
            MOV W,&FATSize              \ limited to 16384 sectors....
            ADD W,X                     \
            MOV X,&OrgFAT2              \ X = OrgFAT1 + FATsize = OrgFAT2
            ADD W,X                     \ X = OrgFAT2 + FATsize = FAT16 OrgRootDir | FAT32 OrgDatas
            CMP #2,&FATtype             \ FAT32?
            0<> IF
\ FAT16_SetRootCluster                  \
                MOV X,&OrgRootDIR       \ only FAT16 use, is a sector used by CLS_SCT
                ADD #32,X               \ OrgRootDir + RootDirSize = OrgDatas
            THEN
            SUB &SecPerClus,X           \ OrgDatas - SecPerClus*2 = OrgClusters
            SUB &SecPerClus,X           \ no borrow expected
            MOV X,&OrgClusters          \ X = virtual cluster 0 address (clusters 0 and 1 don't exist)
            MOV &FATtype,&DIRClusterL   \ init DIRcluster as RootDIR
        THEN                            \
    THEN                                \
    MOV @RSP+,PC                        \ RET
    ENDCODE
\ ----------------------------------\

\ ----------------------------------\ 
    HDNCODE RST_ABORT_SD            \ common part of ?ABORT|RST
\ ----------------------------------\
    CALL #RET_ADR                   \ which does nothing
\ ----------------------------------\
    MOV &CurrentHdl,T               \
    GOTO FW1
    BEGIN
        MOV.B #0,HDLB_Token(T)      \
        MOV @T,T                    \
FW1     CMP #0,T                    \
    0= UNTIL
    MOV #TIB_ORG,&CIB_ADR           \ restore TIB as Current Input Buffer for next line (next QUIT)
    MOV #ACCEPT+4,&ACCEPT+2         \ restore default ACCEPT for next line (next QUIT)
    MOV @RSP+,PC                    \ RET
    ENDCODE
\ ----------------------------------\

\-----------------------------------------------------------------------
\ SD card OPEN, LOAD subroutines
\-----------------------------------------------------------------------

\ used variables : BufferPtr, BufferLen

\ rules for registers use
\ S = error
\ T = CurrentHdl, pathname
\ W = SectorL, (RTC) TIME
\ X = SectorH, (RTC) DATE
\ Y = BufferPtr, (DIR) EntryOfst, FAToffset


    HDNCODE CLS_FAT
\ ----------------------------------\
\ HDLCurClusToFAT1sectWofstY          \WXY Input: T=currentHandle, Output: W=FATsector, Y=FAToffset, Cluster=HDL_CurCluster
\ ----------------------------------\
    MOV HDLL_CurClust(T),&ClusterL  \
    MOV HDLH_CurClust(T),&ClusterH  \
\ ----------------------------------\
\   ClusterToFAT1sectWofstY             \WXY Input : Cluster \ Output: W = FATsector, Y = FAToffset
\ ----------------------------------\
    MOV.B &ClusterL+1,W             \ 3 W = ClusterLoHI
    MOV.B &ClusterL,Y               \ 3 Y = ClusterLoLo
    CMP #2,&FATtype                 \ 3 FAT32?
    0= IF                               \ yes
\    JZ CTF1S_end                    \ 2 yes

\ input : Cluster n, max = 7FFFFF (SDcard up to 256 GB)
\ ClusterLoLo*4 = displacement in 512 bytes sector   ==> FAToffset
\ ClusterHiLo&ClusterLoHi +C  << 1 = relative FATsector + orgFAT1       ==> FATsector
\ ----------------------------------\
        MOV.B &ClusterH,X           \  X = 0:ClusterHiLo
        SWPB X                      \  X = ClusterHiLo:0
        ADD X,W                     \  W = ClusterHiLo:ClusterLoHi  
\ ----------------------------------\
        SWPB Y                      \  Y = ClusterLoLo:0
        ADD Y,Y                     \ 1 Y = ClusterLoLo:0 << 1 + carry for FATsector
        ADDC W,W                    \  W = ClusterHiLo:ClusterLoHi << 1 = ClusterHiLo:ClusterL / 128
        SWPB Y   
\ CTF1S_end
    THEN
    ADD Y,Y                         \  Y = 0:ClusterLoLo << 1
    MOV @RSP+,PC                    \ 4
    ENDCODE
\ ----------------------------------\


\ use no registers
    HDNCODE CLS_SCT
\ ----------------------------------\ Input : Cluster, output: Sector = Cluster_first_sector
\   ComputeClusFrstSect                 \ If Cluster = 1 ==> RootDirectory ==> SectorL = OrgRootDir
\ ----------------------------------\ Output: SectorL of Cluster
    MOV     #0,&SectorH             \
    MOV     &OrgRootDir,&SectorL    \
    CMP.B   #0,&ClusterH            \ clusterH <> 0 ?
    0= IF    
        CMP     #1,&ClusterL            \ clusterHL = 1 ? (FAT16 specificity)
        0= IF                           \ yes, sectorL for FAT16 OrgRootDIR is done
            MOV @RSP+,PC
        THEN
    THEN

    TLV_ORG 4 + @ $81F3 U<
    $81EF TLV_ORG 4 + @ U< =        \ MSP430FR413x subfamily without hardware_MPY
    [IF]                            \ Cluster24<<SecPerClus --> ClusFrstSect\ SecPerClus = {1,2,4,8,16,32,64}                   
    PUSHM  #3,W                     \ 5 PUSHM W,X,Y
    MOV.B &SecPerClus,W             \ 3 SecPerClus(5-1) = multiplicator
    MOV &ClusterL,X                 \ 3 Cluster(16-1) --> MULTIPLICANDlo
    MOV.B &ClusterH,Y               \ 3 Cluster(24-17) -->  MULTIPLICANDhi
    GOTO FW1                        \
    BEGIN                           \
        ADD X,X                     \ 1 (RLA) shift one left MULTIPLICANDlo16
        ADDC Y,Y                    \ 1 (RLC) shift one left MULTIPLICANDhi8
FW1     RRA W                       \ 1 shift one right multiplicator
    U>= UNTIL                       \ 2 C = 0 loop back
    ADD &OrgClusters,X              \ 3 OrgClusters = sector of virtual_cluster_0, word size
    ADDC #0,Y                       \ 1
    MOV X,&SectorL                  \ 3 low result
    MOV Y,&SectorH                  \ 3 high result
    POPM  #3,W                      \ 5 POPM Y,X,W
\ ----------------------------------\
    [ELSE]                          ; hardware MPY, the general case
\ ----------------------------------\
    MOV     &ClusterL,&MPY32L       \ 3
    MOV     &ClusterH,&MPY32H       \ 3
    MOV     &SecPerClus,&OP2        \ 5+3
    MOV     &RES0,&SectorL          \ 5
    MOV     &RES1,&SectorH          \ 5
    ADD     &OrgClusters,&SectorL   \ 5 OrgClusters = sector of virtual cluster 0, word size
    ADDC    #0,&SectorH             \ 3 32~
\ ----------------------------------\
    [THEN]
\ ----------------------------------\32~ + 5~ by 2* shift
    MOV @RSP+,PC                    \
\ ----------------------------------\
    ENDCODE


    HDNCODE CUR_SCT
\ ----------------------------------\
\ ComputeHDLcurrentSector             \ input: currentHandle, output: Cluster, Sector
\ ----------------------------------\
    MOV HDLL_CurClust(T),&ClusterL  \
    MOV HDLH_CurClust(T),&ClusterH  \
    CALL #CLS_SCT                   \ Cluster --> its first sector
    MOV.B HDLB_ClustOfst(T),W       \
    ADD W,&SectorL                  \
    ADDC #0,&SectorH                \
    MOV @RSP+,PC                    \
\ ----------------------------------\
    ENDCODE

    HDNCODE LOAD_SCT
\ ==================================\
\ SetBufLenAndLoadCurSector           \WXY <== previous handle reLOAD with BufferPtr<>0
\ ==================================\
    MOV     #bytsPerSec,&BufferLen  \ preset BufferLen
    CMP     #0,HDLH_CurSize(T)      \ CurSize > 65535 ?
    JNZ     LoadHDLcurrentSector    \ yes
\    CMP HDLL_CurSize(T),&BufferPtr  \ BufferPtr >= CurSize ? (BufferPtr = 0 or see RestorePreviousLoadedBuffer)
\    JC       CLOSE_HDL              \ yes
    CMP #bytsPerSec,HDLL_CurSize(T) \ CurSize >= 512 ?
    JC      LoadHDLcurrentSector    \ yes
    MOV HDLL_CurSize(T),&BufferLen  \ no: adjust BufferLen
\ ==================================\
\ LoadHDLcurrentSector              \ <=== OPEN_WRITE_APPEND
\ ==================================\
    CALL #CUR_SCT                   \ use no registers
    MOV #READ_SECT,PC               \ SWX then RET
\ ----------------------------------\
    ENDCODE

    HDNCODE CLOSE_HDL
\ ==================================\
\ CloseHandleT                      \ <== CLOSE, Read_File, TERM2SD", OPEN_DEL
\ ==================================\
MOV &CurrentHdl,T                   \
CMP #0,T                            \ no handle?
0<> IF                              \
    CMP.B #2,HDLB_Token(T)          \ opened as write (updated) file ?
    0= IF
        CALL #WriteBuffer               \SWXY
        CALL #OPWW_UpdateDirectory      \SWXY
    ELSE
        CMP.B #-1,HDLB_Token(T)     \ token type = LOAD? 
        0= IF
\ ----------------------------------\
\ RestoreSD_ACCEPTContext           \
\ ----------------------------------\
            MOV HDLW_PrevLEN(T),TOS     \
            MOV HDLW_PrevORG(T),0(PSP)  \ -- org len
\ ----------------------------------\
\ RestoreReturnOfSD_ACCEPT          \
\ ----------------------------------\
            ADD #6,RSP              \ R-- QUIT3     empties return stack
            MOV @RSP+,IP            \               skip return to SD_ACCEPT
            CMP #0,HDLW_PrevHDL(T)  \
            0= IF                   \               no more token
                PUSH #ECHO  
                MOV #TIB_ORG,&CIB_ADR   \               restore TIB as Current Input Buffer for next line (next QUIT)
                MOV #ACCEPT+4,&ACCEPT+2 \               restore default ACCEPT for next line (next QUIT)
            ELSE
                PUSH #NOECHO
            THEN
        THEN
    THEN
    MOV.B #0,HDLB_Token(T)          \ release the handle
    MOV @T,T                        \ T = previous handle
    MOV T,&CurrentHdl               \ becomes current handle
    CMP #0,T                        \
    0<> IF                          \ if more handles
\ ----------------------------------\
\ RestorePreviousLoadedBuffer       \
\ ----------------------------------\
        MOV HDLW_BUFofst(T),&BufferPtr  \ restore previous BufferPtr
        CALL #LOAD_SCT                  \ then reload previous buffer
        BIC #Z,SR                       \ 
    THEN
THEN
    MOV @RSP+,PC                    \ Z = 1 if no more handle
\ ----------------------------------\
    ENDCODE

\ sequentially load in SD_BUF bytsPerSec bytes of a file opened as read or as load
\ if new bufferLen have a size <= BufferPtr, closes the file then RET.
\ if previous bufferLen had a size < bytsPerSec, closes the file and reloads previous LOADed file if exist.
\ HDLL_CurSize leaves the not yet read size 
\ All used registers must be initialized. 

    HDNCODE READ_FILE
\ ==================================\
\ Read_File                         \ <== SD_ACCEPT, READ
\ ==================================\
    MOV &CurrentHdl,T               \
    MOV #0,&BufferPtr               \ reset BufferPtr (the buffer is already read)
\ ----------------------------------\
    CMP     #bytsPerSec,&BufferLen  \
    JNZ     CLOSE_HDL               \ because this last and incomplete sector is already read
    SUB #bytsPerSec,HDLL_CurSize(T) \ HDLL_CurSize is decremented of one sector lenght
    SUBC    #0,HDLH_CurSize(T)      \
    ADD.B   #1,HDLB_ClustOfst(T)    \ current cluster offset is incremented
    CMP.B &SecPerClus,HDLB_ClustOfst(T) \ Cluster Bound reached ?
    JNC LOAD_SCT   \ no
\ ----------------------------------\
\SearchNextCluster                  \ yes
\ ----------------------------------\
    MOV.B   #0,HDLB_ClustOfst(T)    \ reset Current_Cluster sectors offset
    CALL #CLS_FAT\WXY  Output: W=FATsector, Y=FAToffset, Cluster=HDL_CurCluster
    ADD &OrgFAT1,W                  \
    MOV #0,X
    CALL    #ReadSectorWX           \SWX (< 65536)
    MOV     #0,HDLH_CurClust(T)     \
    MOV SD_BUF(Y),HDLL_CurClust(T)  \
    CMP     #1,&FATtype             \ FAT16?
    JZ LOAD_SCT    \
    MOV SD_BUF+2(Y),HDLH_CurClust(T) \
    MOV LOAD_SCT,PC
    ENDCODE



\ if first open_load token, save DefaultInputStream
\ if other open_load token, decrement token, save previous context

\ OPEN subroutine
\ Input : EntryOfst, Cluster = EntryOfst(HDLL_FirstClus())
\ init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus,HDLL_CurClust,HDLL_CurSize)
\ Output: Cluster = first Cluster of file, X = CurrentHdl

    HDNCODE NEW_HDL
\ ----------------------------------\ input : Cluster, EntryOfst
\ GetFreeHandle                       \STWXY init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus = HDLL_CurClust,HDLL_CurSize)
\ ----------------------------------\ output : T = new CurrentHdl
MOV #8,S                            \ prepare file already open error
MOV #FirstHandle,T                  \
MOV #0,X                            \ X = init previous handle as 0
\ ----------------------------------\
\ SearchHandleLoop                    \
\ ----------------------------------\
BEGIN
    CMP.B #0,HDLB_Token(T)          \ free handle ?
0<> WHILE                           \ no
\ AlreadyOpenTest                     \
    CMP &ClusterH,HDLH_FirstClus(T) \
    0= IF
        CMP &ClusterL,HDLL_FirstClus(T) \
        0= IF
            MOV @RSP+,PC            \ error 8: file already Open abort ===>
        THEN
    THEN
\ SearchNextHandle                    \
    MOV T,X                         \ handle is occupied, keep it in X as previous handle
    ADD #HandleLenght,T             \
    CMP #HandleEnd,T                \
    0= IF
        ADD S,S                     \ 16 = no more handle error
        MOV @RSP+,PC                \ abort ===>
    THEN
REPEAT
\ ----------------------------------\
\FreeHandleFound                     \ T = new handle, X = previous handle
\ ----------------------------------\
MOV #0,S                            \ prepare Happy End (no error)
MOV T,&CurrentHdl                   \
MOV X,HDLW_PrevHDL(T)               \ link to previous handle
\ ----------------------------------\
\ CheckCaseOfPreviousToken          \
\ ----------------------------------\
CMP #0,X                            \ existing previous handle?
0<> IF                              \ yes
    ADD &TOIN,HDLW_BUFofst(X)       \ in previous handle, add interpret offset to Buffer offset
\ ----------------------------------\
\ CheckCaseOfLoadFileToken            \
\ ----------------------------------\
    CMP.B #0,W                      \ open_type is LOAD (-1) ?
    S< IF                           \ yes
        CMP.B #0,HDLB_Token(X)      \ previous token is negative? (open_load type)
        S< IF                       \ yes
            ADD.B HDLB_Token(X),W   \ LOAD token = previous LOAD token -1
        THEN
    THEN
THEN
\ ----------------------------------\
\ InitHandle                          \
\ ----------------------------------\
MOV.B W,HDLB_Token(T)               \ marks handle as open type: <0=LOAD, 1=READ, 2=WRITE, 4=DEL
MOV.B #0,HDLB_ClustOfst(T)          \ clear ClustOfst
MOV &SectorL,HDLL_DIRsect(T)        \ init handle DIRsectorL
MOV &SectorH,HDLH_DIRsect(T)        \ 
MOV &EntryOfst,Y                    \
MOV Y,HDLW_DIRofst(T)               \ init handle SD_BUF offset of DIR entry
MOV SD_BUF+26(Y),HDLL_FirstClus(T)  \ init handle firstcluster of file (to identify file)
MOV SD_BUF+20(Y),HDLH_FirstClus(T)
MOV SD_BUF+26(Y),HDLL_CurClust(T)   \ init handle CurrentCluster
MOV SD_BUF+20(Y),HDLH_CurClust(T) 
MOV SD_BUF+28(Y),HDLL_CurSize(T)    \ init handle LOW currentSizeL
MOV SD_BUF+30(Y),HDLH_CurSize(T)    \
MOV #0,&BufferPtr                   \ reset BufferPtr all type of files
CMP.B #2,W                          \ is a WRITE file handle?
0= IF
    MOV CUR_SCT,PC                  \ = 2, is a WRITE file
THEN
S>= IF                              \ > 2, is a file to be deleted
    MOV @RSP+,PC                    \ RET
THEN
MOV #0,HDLW_BUFofst(T)              \ < 2, is a READ or a LOAD file
CMP.B #-1,W                         \
0= IF                               \ case of first loaded file: ReplaceInputBuffer
    MOV #SDIB_ORG,&CIB_ADR          \ set SD Input Buffer as Current Input Buffer before return to QUIT
    MOV #SD_ACCEPT,&ACCEPT+2        \ redirect ACCEPT to SD_ACCEPT before return to QUIT
THEN
S>= IF
MOV LOAD_SCT,PC                     \ case of READ file
THEN
\ ----------------------------------\
\ SaveBufferContext                   \ (see CLOSE_HDL) 
\ ----------------------------------\
MOV &SOURCE_LEN,HDLW_PrevLEN(T)     \ = CPL
SUB &TOIN,HDLW_PrevLEN(T)           \ PREVLEN = CPL - >IN
MOV &SOURCE_ORG,HDLW_PrevORG(T)     \ = CIB
ADD &TOIN,HDLW_PrevORG(T)           \ PrevORG = CIB + >IN
\ ----------------------------------\
MOV LOAD_SCT,PC                     \ then RET
    ENDCODE

    HDNCODE NAME_BL
\ ----------------------------------\ input : X = countdown_of_spaces, Y = name pointer in buffer
\ ParseEntryNameSpaces                \XY
\ ----------------------------------\ output: Z flag, Y is set after the last space char
CMP #0,X                            \
0<> IF 
    BEGIN
        CMP.B #32,SD_BUF(Y)         \ SPACE ? 
    0<> WHILE    
        ADD #1,Y                    \   inc pointer
        SUB #1,X                    \   dec countdown_of_spaces
    0= UNTIL
    THEN
THEN
MOV @RSP+,PC                        \ 
\ ----------------------------------\ 
    ENDCODE


CODE OPEN_ERROR
BW1
\   S = Error 1  : PathNameNotFound \
\   S = Error 2  : NoSuchFile       \
\   S = Error 4  : DIRisFull        \
\   S = Error 8  : alreadyOpen      \
\   S = Error 16 : NomoreHandle     \
\   ----------------------------------\
COLON                           \ set ECHO, type Pathname, type #error, type "< OpenError"\ no return
S" < OpenError"                 \
ABORT_SD                        \ to insert S error as flag, no return
;


\ ======================================================================
\ OPEN FILE primitive
\ ======================================================================
\ Open_File               --
\ primitive for LOAD" READ" CREATE" WRITE" DEL"
\ store OpenType on TOS,
\ compile state : compile OpenType, compile SQUOTE and the string of provided pathname
\ exec state :  open a file from SD card via its pathname
\               convert counted string found at HERE in a String then parse it
\                   media identifiers "A:", "B:" ... are ignored (only one SD_Card),
\                   char "\" as first one initializes rootDir as SearchDir.
\               if file found, if not already open and if free handle...
\                   ...open the file as read and return the handle in CurrentHdl.
\               if the pathname is a directory, change current directory, no handle is set.
\               if an error is encountered, no handle is set, an error message is displayed.

    HDNCODE OPEN_FILE
\ ----------------------------------\
\ Open_File                         \ -- open_type HERE             HERE as pathname ptr
\ ----------------------------------\
MOV @PSP+,rDOCON                    \ rDOCON = addr = pathname PTR
ADD rDOCON,TOS                      \ TOS = EOS (End Of String) = pathname end
MOV TOS,&EndOfPath                  \ for WRITE CREATE part
\ ----------------------------------\
\ OPN_PathName                        \
\ ----------------------------------\
MOV #1,S                            \ error 1
MOV &DIRClusterL,&ClusterL          \
MOV &DIRclusterH,&ClusterH          \
CMP rDOCON,TOS                      \ PTR = end of pathname ?
\   JZ      OPN_NoPathName          ;
0= ?GOTO BW1                        \ yes: error 1 ===> 
    CMP.B   #':',1(rDOCON)          \ A: B: C: ... in pathname ?
    0= IF
        ADD #2,rDOCON                \ yes : skip drive because not used, only one SD_card
    THEN
    CMP.B #'\',0(rDOCON)            \ "\" as first char ?
    0<> ?GOTO FW1
\    JNZ     OPN_SearchDirSector     \ no
    ADD     #1,rDOCON               \ yes : skip '\' char
    MOV     &FATtype,&ClusterL      \       FATtype = 1 as FAT16 RootDIR, FATtype = 2 = FAT32RootDIR
    MOV     #0,&ClusterH            \
\   OPN_EndOfStringTest             \ <=== dir found in path
BW2 CMP     rDOCON,TOS              \ PTR = EOS ? (end of pathname ?)
    0= ?GOTO FW3
\    JZ      OPN_SetCurrentDIR       \ yes
\   OPN_SearchDirSector                 \
FW1 MOV     rDOCON,&Pathname        \ save Pathname ptr
    CALL    #CLS_SCT    \ output: SectorHL
    MOV     #32,rDODOES             \ preset countdown for FAT16 RootDIR sectors
    CMP     #2,&FATtype             \ FAT32?
    JZ      OPN_SetDirSectors       \ yes
    0<> IF
        CMP     &ClusterL,&FATtype      \ FAT16 AND RootDIR ?
\        JZ      OPN_LoadDIRsector       \ yes
        0= ?GOTO FW1
\   OPN_SetDirSectors                   \
    THEN
    MOV     &SecPerClus,rDODOES     \
\   OPN_LoadDIRsector                   \ <=== Dir Sector loopback
BW2
FW1 CALL    #READ_SECT              \SWX
    MOV     #2,S                    \ prepare no such file error
    MOV     #0,W                    \ init entries count
\   OPN_SearchDIRentry                  \ <=== DIR Entry loopback
BW3 MOV     W,Y                     \ 1
    RLAM    #4,Y                    \             --> * 16
    ADD     Y,Y                     \ 1           --> * 2
    MOV     Y,&EntryOfst            \ EntryOfst points to first free entry
    CMP.B   #0,SD_BUF(Y)            \ free entry ? (end of entries in DIR)
\    JZ      OPN_NoSuchFile
    0= ?GOTO BW1                    \ error 2 NoSuchFile, used by create ===>
    MOV     #8,X                    \ count of chars in entry name
\   OPN_CompareName8chars 
    BEGIN                           \
        CMP.B   @rDOCON+,SD_BUF(Y)      \ compare Pathname(char) with DirEntry(char)
    0= WHILE
\        JNZ     OPN_FirstCharMismatch   \
        ADD     #1,Y                    \
        SUB     #1,X                    \
\        JNZ     OPN_CompareName8chars   \ loopback if chars 1 to 7 of string and DirEntry are equal
    0= UNTIL
    ADD     #1,rDOCON               \ 9th char of Pathname is always a dot
    THEN
\   OPN_FirstCharMismatch               \
    CMP.B   #'.',-1(rDOCON)         \ FirstNotEqualChar of Pathname = dot ?
    0<> IF                          \ OPN_DotNotFound 
        ADD     #3,X                    \ for next cases not equal chars of entry until 11 must be spaces
        CALL    #NAME_BL                \ for X + 3 chars
        JNZ     OPN_DIRentryMismatch    \ if a char entry <> space  
        CMP.B   #'\',-1(rDOCON)         \ FirstNotEqualChar of Pathname = "\" ?
\        JZ      OPN_EntryFound          \
        0= ?GOTO FW1
        CMP     rDOCON,TOS              \ EOS exceeded ?
\        JNC     OPN_EntryFound          \ yes
        U< ?GOTO FW2
\       OPN_DIRentryMismatch                \
        MOV     &pathname,rDOCON        \ reload Pathname
        ADD     #1,W                    \ inc entry
        CMP     #16,W                   \ 16 entry in a sector
        JNZ     OPN_SearchDIRentry      \ ===> loopback for search next DIR entry
        0<> ?GOTO BW3
        ADD     #1,&SectorL             \
        ADDC    #0,&SectorH             \
        SUB     #1,rDODOES              \ dec count of Dir sectors
        JNZ     OPN_LoadDIRsector       \ ===> loopback for search next DIR sector
        MOV     #4,S                    \
        GOTO BW1                        \ error 4 ===> 
    THEN
\   OPN_DotFound                        \ not equal chars of entry name until 8 must be spaces
    CMP.B   #'.',-2(rDOCON)         \ LastCharEqual = dot ?
    JZ      OPN_DIRentryMismatch    \ case of first DIR entry = "." and Pathname = "..\" 
    CALL    #NAME_BL   \ parse X spaces, X{0,...,7}
    JNZ     OPN_DIRentryMismatch    \ if a char entry <> space
    MOV     #3,X                    \
\   OPN_CompareExt3chars                \
    CMP.B   @rDOCON+,SD_BUF(Y)      \ compare string(char) with DirEntry(char)
    JNZ     OPN_ExtNotEqualChar     \
    ADD     #1,Y                    \
    SUB     #1,X                    \
    JNZ     OPN_CompareExt3chars    \ nothing to do if chars equal
    JMP     OPN_EntryFound          \
\   OPN_ExtNotEqualChar                 \
    CMP     rDOCON,TOS              \ EOS exceeded ?
    JC      OPN_DIRentryMismatch    \ no, loop back   
    CMP.B   #'\',-1(rDOCON)        \ FirstNotEqualChar = "\" ?
    JNZ     OPN_DIRentryMismatch    \
    CALL    #NAME_BL   \ parse X spaces, X{0,...,3}
    JNZ     OPN_DIRentryMismatch    \ if a char entry <> space, loop back
\   OPN_EntryFound                      \ Y points on the file attribute (11th byte of entry)
FW1 
FW2 MOV     &EntryOfst,Y            \ reload DIRentry
    MOV     SD_BUF+26(Y),&ClusterL  \ first clusterL of file
    MOV     SD_BUF+20(Y),&ClusterH  \ first clusterT of file, always 0 if FAT16
\   OPN_EntryFoundNext
    BIT.B   #10h,SD_BUF+11(Y)       \ test if Directory or File
    JZ      OPN_FileFound           \
\   OPN_DIRfound                        \ entry is a DIRECTORY
    CMP     #0,&ClusterH            \ case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        \
    CMP     #0,&ClusterL            \ case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        \
    MOV     &FATtype,&ClusterL      \ set cluster as RootDIR cluster
\   OPN_DIRfoundNext                    \
    CMP     rDOCON,TOS              \ EOS exceeded ?
    JC      OPN_EndOfStringTest     \ no: (we presume that FirstNotEqualChar = "\") ==> loop back
\   OPN_SetCurrentDIR                   \ -- open_type ptr
FW3 MOV     &ClusterL,&DIRClusterL  \
    MOV     &ClusterH,&DIRclusterH  \
    MOV     #0,0(PSP)               \ -- open_type ptr      open_type = 0 
    JMP     OPN_Dir
\   OPN_FileFound                       \ -- open_type ptr
    MOV     @PSP,W                  \   
    CALL    #NEW_HDL                \STWXY init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus = HDLL_CurClust,HDLL_CurSize)
\   --------------------------------\ output : T = CurrentHdl*, S = ReturnError, Y = DIRentry offset
    \ OPN_NomoreHandle                    \ S = error 16
    \ OPN_alreadyOpen                     \ S = error 8
    \ OPN_EndOfDIR                        \ S = error 4
    \ OPN_NoSuchFile                      \ S = error 2
    \ OPN_NoPathName, S = error 1
OPN_Dir
    MOV     #xdodoes,rDODOES        \                   restore rDODOES
    MOV     #xdocon,rDOCON          \                   restore rDODOES
    MOV     @PSP+,W                 \ -- ptr            W = open_type
    MOV     @PSP+,TOS               \ --
\ ----------------------------------\ then go to selected OpenType subroutine (OpenType = W register)
\OPEN_QDIR                           \
\ ----------------------------------\
    CMP     #0,W                    \
    JZ      OPEN_LOAD_END           \ nothing to do
\ ----------------------------------\
\OPEN_QLOAD                          \
\ ----------------------------------\
    .IFDEF SD_CARD_READ_WRITE       \
    CMP.B   #-1,W                   \ open_type = LOAD"
    JNZ     OPEN_QREAD              \ next step
    .ENDIF                          \
\ ----------------------------------\ here W is free
\OPEN_LOAD                           \
\ ----------------------------------\
MOV @IP+,PC                         \
    ENDCODE

\-----------------------------------------------------------------------
\ SD_CARD_LOADER FORTH word
\-----------------------------------------------------------------------

\Z LOAD" pathame"   --       immediate
\ compile state : compile LOAD" pathname"
\ exec state : open a file from SD card via its pathname
\ see Open_File primitive for pathname conventions 
\ the opened file becomes the new input stream for INTERPRET
\ this command is recursive, limited only by the count of free handles (up to 8)
\ LOAD" acts also as dos command "CD" : 
\     - LOAD" \misc\" set a:\misc as current directory
\     - LOAD" \" reset current directory to root
\     - LOAD" ..\" change to parent directory

\ ======================================================================
\ LOAD" primitive as part of Open_File
\ input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
\                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
\       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
\ output: nothing else abort on error
\ ======================================================================
    
    [UNDEFINED] S_ 
    [IF]
    CODE S_             \           Squote alias with blank instead quote separator
    MOV #0,&CAPS        \           turn CAPS OFF
    COLON
    XSQUOTE ,           \           compile run-time code
    $20 WORD            \ -- c-addr (= HERE)
    HI2LO
    MOV.B @TOS,TOS      \ -- len    compile string
    ADD #1,TOS          \ -- len+1
    BIT #1,TOS          \           C = ~Z
    ADDC TOS,&DP        \           store aligned DP
    MOV @PSP+,TOS       \ --
    MOV @RSP+,IP        \           pop paired with push COLON
    MOV #$20,&CAPS      \           turn CAPS ON (default state)
    MOV @IP+,PC         \ NEXT
    ENDCODE IMMEDIATE
    [THEN]

\ ----------------------------------\
    CODE LOAD                       \ immediate
\ ----------------------------------\
    MOV.B   #-1,W                   \ W = OpenType
\ ----------------------------------\
BW1 SUB #4,PSP                          \
    MOV TOS,2(PSP)                      \
    MOV W,0(PSP)                        \ -- Open_type (0=LOAD", 1=READ", 2=WRITE", 4=DEL")
    MOV &STATE,TOS                      \
    COLON                               \ if exec state
    IF 
        20 WORD COUNT                   \ -- open_type addr u
    ELSE                                \ compile OPEN_FILE
        LITERAL
        S_ [ 20 WORD DROP ]
    THEN
    OPEN_FILE
    ; IMMEDIATE

\   .IFDEF SD_CARD_READ_WRITE

\-----------------------------------------------------------------------
\ SD_READ_WRITE FORTH words
\-----------------------------------------------------------------------

\Z READ          --
\ parse string until " is encountered, convert counted string in String
\ then parse string until char '0'.
\ media identifiers "A:", "B:" ... are ignored (only one SD_Card),
\ char "\" as first one initializes rootDir as SearchDir.
\ if file found, if not already open and if free handle...
\ ...open the file as read and return the handle in CurrentHdl.
\ then load first sector in buffer, bufferLen and bufferPtr are ready for read
\ currentHdl keep handle that is flagged as "read".

\ to read sequentially next sectors use READ word. A flag is returned : true if file is closed.
\ the last sector so is in buffer.

\ if pathname is a directory, change current directory.
\ if an error is encountered, no handle is set, error message is displayed.

\ READ" acts also as CD dos command : 
\     - READ" a:\misc\" set a:\misc as current directory
\     - READ" a:\" reset current directory to root
\     - READ" ..\" change to parent directory

\ to close all files type : WARM (or COLD, RESET)

\ ----------------------------------\
    CODE READ                           \ "            
    MOV.B   #1,W                    \ W = OpenType
    GOTO BW1                        \
    ENDCODE IMMEDIATE

\Z WRITE" pathame"   --       immediate
\ open or create the file designed by pathname.
\ an error occurs if the file is already opened.
\ the last sector of the file is loaded in buffer, and bufferPtr leave the address of the first free byte.
\ compile state : compile WRITE" pathname"
\ exec state : open or create entry selected by pathname
\ ----------------------------------\
    CODE WRITE                          \ "
    MOV.B   #2,W                    \ W = OpenType
    GOTO BW1                        \
    ENDCODE IMMEDIATE


\Z DEL" pathame"   --       immediate
\ compile state : compile DEL" pathname"
\ exec state : DELETE entry selected by pathname

\ ----------------------------------\
    CODE DEL                            \ "
\ ----------------------------------\
    MOV.B   #4,W                    \ W = OpenType
    GOTO BW1                        \
    ENDCODE IMMEDIATE


\Z CLOSE      --     
\ close current handle
\ ----------------------------------\
    CODE CLOSE                         \
\ ----------------------------------\
    CALL    #CLOSE_HDL           \
    MOV @IP+,PC                     \
    ENDCODE

\    .ENDIF \ SD_CARD_READ_WRITE




\        .IFDEF BOOTLOADER
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    [UNDEFINED] = 
    [IF]
    CODE =
    SUB @PSP+,TOS   \ 2
    0<> IF          \ 2
        AND #0,TOS  \ 1
        MOV @IP+,PC \ 4
    THEN
    XOR #-1,TOS     \ 1 flag Z = 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
    [UNDEFINED] DUP
    [IF]
    CODE DUP
    BW1 SUB #2,PSP      \ 2  push old TOS..
        MOV TOS,0(PSP)  \ 3  ..onto stack
        MOV @IP+,PC     \ 4
    ENDCODE

\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
    CODE ?DUP
    CMP #0,TOS      \ 2  test for TOS nonzero
    0<> ?GOTO BW1    \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
[THEN]

\ https://forth-standard.org/standard/core/EVALUATE
\ EVALUATE          \ i*x c-addr u -- j*x  interpret string
    [UNDEFINED] EVALUATE 
    [IF]
    CODE EVALUATE
    MOV #SOURCE_LEN,X       \ 2
    MOV @X+,S               \ 2 S = SOURCE_LEN
    MOV @X+,T               \ 2 T = SOURCE_ORG
    MOV @X+,W               \ 2 W = TOIN
    PUSHM #4,IP             \ 6 PUSHM IP,S,T,W
    LO2HI
    INTERPRET
    HI2LO
    MOV @RSP+,&TOIN         \ 4
    MOV @RSP+,&SOURCE_ORG   \ 4
    MOV @RSP+,&SOURCE_LEN   \ 4
    MOV @RSP+,IP 
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ BOOT          RSTIV_MEM --        \ bootstrap on SD_CARD\BOOT.4th file
\                                   \ called by WARM
\  to enable bootstrap type: ' BOOT IS WARM
\ to disable bootstrap type: ' BOOT [PFA] IS WARM
    CODE BOOT
    MOV #INIT_SD,X          \ X = INIT_SD
    BIC #LOCKLPM5,&PM5CTL0  \ activate all previous I/O settings, mandatory for QSD_MEM.
    CMP #2,TOS              \ RSTIV_MEM <> WARM ?
    U< IF                   \ yes
        MOV @RSP+,PC        \ if RSTIV_MEM U< 2, return to BODYWARM
    THEN
    BIT.B #CD_SD,&SD_CDIN   \ SD_memory in SD_Card socket ?
    0<> IF                  \
        MOV 2(X),PC         \ if no, goto previous INIT: INIT TERMINAL only then ret to PFAWARM
    THEN
\---------------------------------------------------------------------------------
\ RESET 6: if RSTIV_MEM <> WARM, init TERM, init SD
\---------------------------------------------------------------------------------
    CALL X                  \ init TERM UC first then init SD card, TOS = RSTIV_MEM
\---------------------------------------------------------------------------------
\ END OF RESET
\---------------------------------------------------------------------------------
    MOV #PSTACK-2,PSP       \ to avoid error "Stack empty!"
    MOV #0,&STATE           \ )
    MOV #LSTACK,&LEAVEPTR   \ > same as QUIT
    MOV #RSTACK,RSP         \ )
    LO2HI                   \
    S_ LOAD" BOOT.4TH"        \ LOAD BOOT.4TH issues error 2 if no such file...
    EVALUATE                \ to interpret this string
    ;
