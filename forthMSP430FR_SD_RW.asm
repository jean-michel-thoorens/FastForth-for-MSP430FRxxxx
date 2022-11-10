 ; -*- coding: utf-8 -*-
; DTCforthMSP430FR5xxxSD_RW.asm

; and only for FR5xxx and FR6xxx with RTC_B or RTC_C hardware if you want write file with date and time.

; ======================================================================
; READ" primitive as part of OpenPathName
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; ======================================================================

; ----------------------------------;
OPEN_1W                             ;
    CMP     #1,W                    ; open_type = READ" ?
    JNZ     OPEN_2W                 ; no : goto next step
; ----------------------------------;
;OPEN_READ                          ;
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNZ     OPEN_Error              ; no
    MOV     @IP+,PC                 ; no more to do
; ----------------------------------;

;Z READ            -- f
; sequentially read a file opened by READ".
; sectors are loaded in SD_BUF and BufferLen leave the count of loaded bytes.
; when the last sector of file is loaded in buffer, the handle is automatically closed and flag is true (<>0).
; to call Read_File in assembly : CALL &READ+$0C

; ==================================;
    FORTHWORD "READ"                ; -- fl     closed flag
; ==================================;
    SUB     #2,PSP                  ;
    MOV     TOS,0(PSP)              ;
    MOV     &CurrentHdl,TOS         ;
    CALL    #Read_File              ;SWX
    SUB     &CurrentHdl,TOS         ; -- fl     if true (if Z=0) handle is closed
    MOV     @IP+,PC                 ;
; ----------------------------------;


; ==================================;
FreeAllClusters                     ;SWXY input: HDLL_FirstClus(T), output:
; ==================================;FATs are updated
    CALL #HDLFrstClus2FATsecWofstY  ;WXY    output: W = FATsector, Y=FAToffset
    PUSH    W                       ;       R-- FATsector ptr
; ----------------------------------;
LoadFAT1sectorWloop                 ;
; ----------------------------------;
    CALL    #ReadFAT1SectorW        ;SWX
; ----------------------------------;
GetAndFreeCluster                   ;
; ----------------------------------;
    MOV     SD_BUF(Y),W             ; get [clusterLO]
    MOV     #0,SD_BUF(Y)            ; free CLusterLO
    MOV     SD_BUF+2(Y),X           ; get [clusterHI]
    MOV     #0,SD_BUF+2(Y)          ; free CLusterHI
    AND     #00FFFh,X               ; select 12 bits significant
    CMP     #00FFFh,X               ; [ClusterHI] was = 0FFFh?
    JNE     SearchNextCluster2free  ; no
    CMP     #-1,W                   ; [ClusterLO] was = FFFFh? last cluster used for this file
    JZ      EndOfFileCluster        ; yes
; ----------------------------------;
SearchNextCluster2free              ;
; ----------------------------------;
    MOV     W,&ClusterL             ;
    MOV     X,&ClusterH             ;
    CALL #ClusterHLtoFAT1sectWofstY ;WXY    W = new FATsector, new FAToffset
    CMP     @RSP,W                  ; new FATsector = FATsector ptr ?
    JZ      GetAndFreeCluster       ; yes loop back
    MOV     W,X                     ; no:   swap previous new FATsectors:
    MOV     @RSP,W                  ;       W = previous FATsector
    MOV     X,0(RSP)                ;       R-- new FATsector
    CALL    #SaveSectorWtoFATs      ;SWXY update FATs from SD_BUF to W = previous FATsector
    MOV     @RSP,W                  ;       W = new FATsector
    JMP     LoadFAT1sectorWloop     ; loop back with W = new FATsector, new FAToffset
; ----------------------------------;
EndOfFileCluster                    ;
; ----------------------------------;
    MOV     @RSP+,W                 ; W = new FATsector
; ==================================;
SaveSectorWtoFATs                   ;SWXY W = FATsector loaded in SD_buf
; ==================================;
    MOV     W,Y                     ; Y = W
    ADD     &OrgFAT1,W              ; update FAT#1
    CALL    #WriteFATsectorW        ;SWX
    MOV     Y,W                     ; W = FATsector
    ADD     &OrgFAT2,W              ; update FAT#2
WriteFATsectorW                     ;
    MOV     #0,X                    ;
    MOV     #WriteSectorWX,PC       ;SWX then RET
; ----------------------------------;


; parse all FAT sectors until free cluster is found
; this New Cluster is marked as the end's one (-1)

; input : W = FATSector, Y = FAToffset
; use SWX registers
; output: updated (ClusterHL, FATsector, W = FATsector), SD_BUF = [new FATsector]
;         SectorHL is unchanged, FATS are updated.
;         S = 2 --> Disk FULL error
; ==================================;
SearchMarkNewClusterHL              ;SWXY <== WRITE_FILE, OPEN_WRITE_CREATE, OPEN_OVERWRITE
; ==================================;
    MOV     #20h,S                  ; preset disk full return error
    PUSH    W                       ;3  R-- FATsector
; ----------------------------------;
LoadFATsectorLoop                   ;
; ----------------------------------;
    MOV     @RSP,W                  ;2
    CMP     W,&FATSize              ;3
    JZ      OPWC_DiskFull           ;2 FATsector = FATSize ===> abort disk full
    CALL    #ReadFAT1SectorW        ;SWX load FAT_buf with (new) FATsector
; ----------------------------------;
SearchFreeClusterLoop               ;
; ----------------------------------;
    CMP     #0,SD_BUF+2(Y)          ;3 cluster address hi word = 0 ?
    JNZ     SearchNextNewCluster    ;2
    CMP     #0,SD_BUF(Y)            ;3 Cluster address lo word = 0 ?
    JZ      FreeClusterFound        ;2
SearchNextNewCluster                ;
    ADD     #4,Y                    ;1 increment SD_BUF offset by size of Cluster address
    CMP     #BytsPerSec,Y           ;2
    JNC     SearchFreeClusterLoop   ;2  18/15~   loopback while X U< BytsPerSec
;IncrementFATsector                 ;1
    ADD     #1,0(RSP)               ;3 increment FATsector
    MOV     #0,Y                    ;  clear FAToffset
    JMP     LoadFATsectorLoop       ;5  34/23~    loopback
; ----------------------------------;
FreeClusterFound                    ; X =  cluster number low word in SD_BUF = FAToffset
; ----------------------------------;
    MOV     #0,S                    ; clear error
    MOV     #-1,SD_BUF(Y)           ; mark New Cluster low word as end cluster (0xFFFF) in SD_BUF
    MOV.B   @RSP,W                  ; W = 0:FATsectorLo
    MOV     #0FFFh,SD_BUF+2(Y)      ; mark New Cluster high word as end cluster (0x0FFF) in SD_BUF
; ----------------------------------;
;FAT32ClustAdrToClustNum             ; convert FAT32 cluster address to cluster number (CluNum = CluAddr / 4)
; ----------------------------------;
    RRA     Y                       ; Y = FATOffset>>1, (bytes to words conversion)
    SWPB    W                       ; W = FATsectorLo:0
    ADD     W,Y                     ; Y = FATsectorLo:FATOffset>>1
    MOV.B   1(RSP),W                ; W = FATsectorHi
    RRA     W                       ; W = FATsectorHi>>1
    RRC     Y                       ; Y = (FATsectorLo:FAToffset>>1)>>1 = FATsectorLo>>1:FAToffset>>2
    MOV     W,&ClusterH             ; ClusterH =  FATsectorHi>>1
    MOV     Y,&ClusterL             ; ClusterL = FATsectorLo>>1:FAToffset>>2
; ----------------------------------;
    MOV     @RSP,W                  ; W = FATsector of new cluster
    CALL    #SaveSectorWtoFATs      ;SWXY W = FATsector loaded in SD_buf
    MOV     @RSP+,W                 ; W = FATsector of New Cluster
    MOV     @RSP+,PC                ; RET
; ----------------------------------;

; ======================================================================
; DEL" primitive as part of OpenPathName
;;;; All "DEL"eted clusters are freed
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing (no message if open error)
; ======================================================================
OPEN_2W                             ;
    CMP     #2,W                    ; open_type = DEL ?
    JNZ     OPEN_4W                 ; no : goto next step
; ----------------------------------;
; 1- open file                      ; done
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNE     DEL_END                 ; no: don't send message, don't abort
; ----------------------------------;
; 2- Delete DIR entry               ;
; ----------------------------------;
    MOV.B   #0E5h,SD_BUF(Y)         ;       mark DIRentry as deleted
    CALL    #WriteSectorHL          ;SWX    update SectorHL=DIRsector
;; ----------------------------------;
;; 3- free all file clusters         ;
;; ----------------------------------;
;    CALL    #FreeAllClusters        ;SWXY input: HDLL_FirstClus(T), output: FATS are updated
; ----------------------------------;
; 4- Close Handle                   ;
; ----------------------------------;
    CALL    #CloseHandle            ;
; ----------------------------------;
DEL_END                             ;
    MOV @IP+,PC                     ;4
; ----------------------------------;

;-----------------------------------------------------------------------
; WRITE" (CREATE part) subroutines
;-----------------------------------------------------------------------


; FAT16/32 format for date and time in a DIR entry
; create time :     offset 0Dh = 0 to 200 centiseconds, not used.
;                   offset 0Eh = 0bhhhhhmmmmmmsssss, with : s=seconds*2, m=minutes, h=hours
; access time :     offset 14h = always 0, not used as date
; modified time :   ofsset 16h = 0bhhhhhmmmmmmsssss, with : s=seconds*2, m=minutes, h=hours
; dates :    offset 10, 12, 18 = 0byyyyyyymmmmddddd, with : y=year-1980, m=month, d=day

; ==================================;
GetYMDHMSforDIR                     ; output: X=date, W=TIME
; ==================================;
    .IFDEF    LF_XTAL               ;
    .IFNDEF   RTC                   ; select RTC_B or RTC_C, not RTC
; ----------------------------------;
    BIT.B   #RTCHOLD,&RTCCTL1       ; rtc is running ?
    JNZ     SD_RW_RET               ; no
WaitRTC                             ; yes
    BIT.B   #RTCRDY,&RTCCTL1        ; rtc values are valid ?
    JZ      WaitRTC                 ; no
    MOV.B   &RTCSEC,W               ; yes
    RRA.B   W                       ; 2 seconds accuracy time
    MOV.B   &RTCDAY,X               ;
    MOV.B   #32,&MPY                ; common MPY for minutes and months
    MOV.B   &RTCMIN,&OP2            ;
    ADD     &RES0,W                 ;
    MOV.B   &RTCMON,&OP2            ;
    ADD     &RES0,X                 ;
    MOV.B   &RTCHOUR,&MPY           ;
    MOV     #2048,&OP2              ;
    ADD     &RES0,W                 ;
    MOV     &RTCYEAR,&MPY           ;
    SUB     #1980,&MPY              ;
    MOV     #512,&OP2               ;
    ADD     &RES0,X                 ;
    .ELSEIF
    MOV     #0,X                    ; X=DATE
    MOV     #0,W                    ; W=TIME
    .ENDIF
    .ENDIF
SD_RW_RET                           ;
    MOV     @RSP+,PC                ;
; ----------------------------------;


; when create filename, forbidden chars are skipped
ForbiddenChars ; 15 forbidden chars table + dot char
    .byte '"','*','+',',','/',':',';','<','=','>','?','[','\\',']','|','.'

; ==================================;
OPWC_SkipDot                        ;
; ==================================;
    CMP     #4,X                    ;
    JNC     FillDIRentryName        ; X U< 4 : no need spaces to complete name entry
    SUB     #3,X                    ;
    CALL    #OPWC_CompleteWithSpaces; complete name entry
    MOV     #3,X                    ;
; ==================================;
FillDIRentryName                    ;SWXY use
; ==================================;
    MOV.B   @T+,W                   ; W = char of pathname
    MOV.B   W,SD_BUF(Y)             ;     to DIRentry
    CMP     T,&PathName_END         ; EOS < PTR ?
    JNC     OPWC_CompleteWithSpaces ; yes
; ----------------------------------;
;SkipForbiddenChars                  ;
; ----------------------------------;
    PUSH    IP                      ;3
    MOV     #15,IP                  ;2 forbidden chars count
    MOV     #ForbiddenChars,S       ;2 here, S is free
ForbiddenCharLoop                   ;
    CMP.B   @S+,W                   ;2
    JZ      FillDIRentryName        ;2 skip forbidden char
    SUB     #1,IP                   ;1
    JNZ     ForbiddenCharLoop       ;2
    MOV     @RSP+,IP                ;2
; ----------------------------------;
    CMP.B   @S,W                    ;1 46 (0x2E)
    JZ      OPWC_SkipDot            ;2 skip '.'
; ----------------------------------;
    SUB     #33,W                   ;
    JL      FillDIRentryName        ; skip char =< SPACE char
    ADD     #1,Y                    ; increment DIRentry ptr
    SUB     #1,X                    ; decrement count of chars entry
    JNZ     FillDIRentryName        ;
; ----------------------------------;
OPWC_CompleteWithSpaces             ; 0 to n spaces !
; ----------------------------------;
    CMP     #0,X                    ;
    JZ      OPWC_CWS_End            ;
; ----------------------------------;
OPWC_CompleteWithSpaceloop          ;
; ----------------------------------;
    MOV.B   #' ',SD_BUF(Y)          ; remplace dot by char space
    ADD     #1,Y                    ; increment DIRentry ptr in buffer
    SUB     #1,X                    ; dec countdown of chars space
    JNZ OPWC_CompleteWithSpaceloop  ;
OPWC_CWS_End                        ;
    MOV @RSP+,PC                    ;
; ----------------------------------;

;-----------------------------------------------------------------------
; WRITE subroutines
;-----------------------------------------------------------------------


;Z WRITE            --
; write sequentially the SD_buffer in the post incremented SectorHL.
; The first SectorHL is initialized by WRITE".
; the last sector will be processed by CLOSE
; All used registers must be initialized.
; to call Write_File in assembly : CALL #WRITE+4

; ==================================;
    FORTHWORD "WRITE"               ; encapsulate Write_File
; ==================================;
    PUSH #WRITE_END                 ;
; ----------------------------------;

; ==================================;
Write_File                          ;STWXY <== WRITE, SD_EMIT, TERM2SD", BUT NOT CLOSE !
; ==================================;
    MOV     #BytsPerSec,&BufferPtr  ; write always all the buffer, the last written buffer will be processed directly by CloseHandle
    MOV     &CurrentHdl,T           ;
    CALL    #WriteSD_Buf            ;SWX write SD_BUF and update Handle informations only for DIRentry update
    MOV     #0,&BufferPtr           ; reset buffer pointer
; ----------------------------------;
;PostIncrementSector                 ;
; ----------------------------------;
    ADD.B   #1,HDLB_ClustOfst(T)    ; increment current Cluster offset
    CMP.B &SecPerClus,HDLB_ClustOfst(T) ; out of bound ?
    JNC     Write_File_End          ; no,
; ----------------------------------;
    CALL    #HDLcurClus2FATsecWofstY;WXY  Output: FATsector W=FATsector, Y=FAToffset
    CALL    #GetNewCluster          ;
; ==================================;
HDLSetCurClustSetFrstSect           ;
; ==================================;
    MOV.B   #0,HDLB_ClustOfst(T)    ; clear current Cluster offset
    MOV     #4,HDLB_Token(T)        ; and clear ClustOfst
; ==================================;
HDLSetCurClustSetCurSect            ;
; ==================================;
    MOV &ClusterL,HDLL_CurClust(T)  ; update handle with new cluster
    MOV &ClusterH,HDLH_CurClust(T)  ;
; ----------------------------------;
Write_File_End                      ;
    MOV #ClusterHL2sectorHL,PC      ;W set current SectorHL to be written, then RET
; ----------------------------------;

; ----------------------------------;
WRITE_END
    MOV @IP+,PC                     ;
; ----------------------------------;

; ======================================================================
; WRITE" primitive as part of OpenPathName
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: Current Sector is set else abort on WRITE error
; error 4  : InvalidPathname
; error 8  : DiskFull
; ======================================================================
OPEN_4W                             ;
    CMP     #4,W                    ; open_type = WRITE" ?
    JNZ     OPEN_8W                 ; no : goto next step
; ----------------------------------;
; 1 try to open                     ; done
; ----------------------------------;
; 2 select error "no such file"     ;
; ----------------------------------;
    CMP     #2,S                    ; "no such file" error ?
    JZ      OPEN_WRITE_CREATE       ; yes, Handle is to be created !
    CMP     #0,S                    ; already opened file ?
    JZ      OPEN_OVERWRITE          ; yes, handle is created
; ----------------------------------;
OPWC_Write_Errors                   ;
OPWC_InvalidPathname                ; S = $10
OPWC_DiskFull                       ; S = $20
; ----------------------------------;
OPW_Error                           ; set ECHO, type Pathname, type #error, type "< WriteError"; no return
    MOV #SD_CARD_FILE_ERROR,PC      ;
; ----------------------------------;

; ======================================================================
; WRITE" primitive as part of OpenPathName
; input from open:  W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstCluster
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl,
; output: nothing (no message if open error)
; ======================================================================

; ==================================;
OPEN_WRITE_CREATE                   ; a new Handle is to be created
; ==================================;
; 1- open file                      ; done
; ----------------------------------;
; 2 get free cluster                ;
; ----------------------------------;
    MOV     #0,W                    ; init FATsector = 0, search new cluster
    MOV     #8,Y                    ; init FAToffset to point Cluster 2
    CALL    #SearchMarkNewClusterHL ;WXY  output: updated (ClusterHL, FATsector, W = FATsector)
; ----------------------------------;
; 3 init DIRentryAttributes         ;
; ----------------------------------;
    CALL    #ReadSectorHL           ; reload DIRsector
    MOV     &DIREntryOfst,Y         ; Y = entry offset (first free entry in DIR)
    MOV.B   #20h,SD_BUF+0Bh(Y)      ; file attribute = file
    CALL    #GetYMDHMSforDIR        ;WX  X=DATE,  W=TIME
    MOV     W,SD_BUF+0Eh(Y)         ; time of creation
    MOV     X,SD_BUF+10h(Y)         ; date of creation      20/08/2001
    MOV     &ClusterH,SD_BUF+14h(Y) ; as first Cluster Hi
    MOV     &ClusterL,SD_BUF+1Ah(Y) ; as first cluster LO
    MOV     #0,SD_BUF+1Ch(Y)        ; set file_sizeLO  = 0
    MOV     #0,SD_BUF+1Eh(Y)        ; set file_sizeHI  = 0
; ----------------------------------;
; 4 create DIRentryName             ; file name format "xxxxxxxx.yyy"
; ----------------------------------;
    MOV     #10h,S                  ; preset pathname error
    MOV     &PathName_PTR,T         ; here, PathName_PTR is set to file name
    CMP     T,&PathName_END         ; end of string reached ?
    JZ      OPWC_InvalidPathname    ; yes write error $10
    CMP.B   #'.',0(T)               ; forbidden "." in first
    JZ      OPWC_InvalidPathname    ; write error $10
    MOV     #11,X                   ; X=countdown of chars entry
    CALL    #FillDIRentryName       ;STWXY
; ----------------------------------;
; 5 update DIRsector                ;
; ----------------------------------;
    CALL    #WriteSectorHL          ;SWX update DIRsector
; ----------------------------------;
; 7 Get free handle                 ;
; ----------------------------------;
    MOV     #4,W                    ; get handle for write
    CALL    #GetFreeHandle          ; output : CurCluster and CurSector are set
    MOV     @IP+,PC                 ; --
; ----------------------------------;

; ==================================;
OPEN_OVERWRITE                      ; handle exists
; ==================================;
; free all file clusters            ;
; ----------------------------------;
    CALL    #FreeAllClusters        ;SWXY input: HDLL_FirstClus(T)
    MOV     #0,HDLL_CurSize(T)      ; clear currentSize
    MOV     #0,HDLH_CurSize(T)      ;
    CALL #HDLFrstClus2FATsecWofstY  ;WXY    output: W = FATsector, Y=FAToffset
    CALL    #SearchMarkNewClusterHL ;SWXY input: W = FATsector, Y = FAToffset output: ClusterHL, W = updated new FATsector loaded in SD_BUF
    CALL #HDLSetCurClustSetFrstSect ;
    MOV     @IP+,PC                 ; --
; ----------------------------------;

; ======================================================================
; APPEND" primitive as part of OpenPathName
; input from open:  SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; error 2  : DiskFull
; ======================================================================
OPEN_8W                             ;
    CMP     #2,S                    ; "no such file" error ?
    JZ      OPEN_WRITE_CREATE       ; if yes, handle is to be created
    CMP     #0,S                    ; already opened file ?
    JNZ     OPWC_Write_Errors       ; no
; ==================================;
;OPEN_WRITE_APPEND                  ; yes, handle is already created
; ==================================;
;SearchLastClust                    ;SWXY input: HDLL_FirstClus(T)
; ----------------------------------;
    CALL #HDLFrstClus2FATsecWofstY  ;WXY    output: W = FATsector, Y=FAToffset
; ----------------------------------;
;SrchFAT1sectorWloop                 ;
; ----------------------------------;
    MOV     W,&FATsector            ;       FATsector memory
    CALL    #ReadFAT1SectorW        ;SWX
; ----------------------------------;
SearchClusterLoop                   ; in: ClusterHL
; ----------------------------------;
    MOV     SD_BUF(Y),W             ; get [clusterLO]
    MOV     SD_BUF+2(Y),X           ; get [clusterHI]
    CMP     #0FFFh,X                ; [ClusterHI] = 0FFFh?
    JNE     SearchNextCluster       ; no
    CMP     #-1,W                   ; [ClusterLO] = FFFFh?
    JZ      LastClusterFound        ; LastClusterFound = ClusterHL 
; ----------------------------------;
SearchNextCluster                   ;
; ----------------------------------;
    MOV     W,&ClusterL             ;
    MOV     X,&ClusterH             ;
    CALL #ClusterHLtoFAT1sectWofstY ;WXY    W = new FATsector, new FAToffset
    CMP     W,&FATsector            ; new FATsector = prev FATsector ?
    JZ      SearchClusterLoop       ; yes loop back
    JMP     LoadFAT1sectorWloop     ; loop back with W = new FATsector
; ----------------------------------;
LastClusterFound                    ; in ClusterHL
; ----------------------------------;
    MOV     HDLL_CurSize(T),W       ; 
    MOV     W,Y                     ;
; ----------------------------------;
; Compute Y = SD_Buf ptr            ; example :  Y = $A313 bytes
; ----------------------------------;
    MOV     #1FFh,X                 ; mask for sector
    BIC     X,HDLL_CurSize(T)       ; HDLL_CurSize = $A200 bytes
    AND     X,Y                     ; remainder  Y = $0113 bytes
    MOV     Y,&BufferPtr            ; init Buffer Pointer with $0113
; ----------------------------------;
; Compute W = Cluster offset        ;
; ----------------------------------;
    MOV.B   &SecPerClus,X           ;
    SUB     #1,X                    ; mask for Cluster offset, max = 0b0011_1111, for 4k clusters: 0b0000_0111
    SWPB    W                       ; W.B = 0bxxxx_xxx?
    RRA.B   W                       ; W.B = 0b?xxx_xxxx
    AND     X,W                     ; W.B = 0b00xx_xxxx max, for 4k clusters: 0b0000_0xxx
    MOV.B W,HDLB_ClustOfst(T)       ; W.B = Cluster offset
    CALL #HDLSetCurClustSetCurSect  ;
    CALL    #ReadSectorHL           ; load SectorHL to be updated in SD_buf
; ----------------------------------;
    MOV @IP+,PC                     ;
; ----------------------------------;


    .IFDEF TERMINALBAUDRATE ; if UART_TERMINAL

; first TERATERM sends the command TERM2SD" file.ext" to FastForth which returns XOFF at the end of the line.
; then when XON is sent below, TERATERM sends "file.ext" up to XOFF sent by TERM2SD" (slices of 512 bytes),
; then TERATERM sends char EOT that closes the file on SD_CARD.

; ==================================;
    FORTHWORD "TERM2SD\34"          ;
; ==================================;
    mDOCOL                          ;
    .word   NOBOOT                  ; on ne tente pas le diable...
    .word   WRITEDQ                 ;  if already exist Free All Clusters else create it as WRITE file
; ----------------------------------;
    mNEXTADR                        ;
    MOV     @RSP+,IP                ;
; ----------------------------------;
T2S_GetSliceLoop                    ;   tranfert by slices of 512 bytes from terminal input to file on SD_CARD via SD_BUF
; ----------------------------------;
    MOV     #0,W                    ;1  clear W = BufferPtr
    CALL    #UART_RXON              ;   use no registers
; ----------------------------------;
T2S_Get_a_Char_Loop                 ;
; ----------------------------------;
    BIT     #RX_TERM,&TERM_IFG      ;3 new char in TERMRXBUF ?
    JZ      T2S_Get_a_Char_Loop     ;2
    MOV.B   &TERM_RXBUF,X           ;3
    CMP.B   #4,X                    ;1 EOT sent by TERATERM ?
    JZ      T2S_End_Of_File         ;2 yes
; ----------------------------------;
    MOV.B   X,SD_BUF(W)             ;3
    ADD     #1,W                    ;1
    CMP     #BytsPerSec-1,W         ;2
    JZ      T2S_XOFF                ;2 W = BytsPerSec-1    send XOFF after RX 511th char
    JNC     T2S_Get_a_Char_Loop     ;2 W < BytsPerSec-1    21 cycles char loop (476 kBds/MHz)
; ----------------------------------;
;T2S_WriteFile                      ;2 W = BytsPerSec
; ----------------------------------;
    CALL    #Write_File             ;STWXY write all the buffer
    JMP     T2S_GetSliceLoop        ;2
; ----------------------------------;
T2S_XOFF                            ;  27 cycles between XON and XOFF
; ----------------------------------;
    CALL    #UART_RXOFF             ;4  use no registers
    JMP     T2S_Get_a_Char_Loop     ;2  loop back once to get char sent by TERMINAL during XOFF time
; ----------------------------------;
T2S_End_Of_File                     ;  wait CR before sending XOFF
; ----------------------------------;
T2S_Wait_CR                         ; warning! EOT must be followed by CR+LF (TERM2SD" used with I2C_FastForth)
; ----------------------------------;
    CMP.B   #0Dh,&TERM_RXBUF        ; also clears RX_IFG !
    JZ      T2S_Wait_CR             ; wait CR
; ----------------------------------;
    CALL    #UART_RXOFF             ;4  use no registers
; ----------------------------------;
T2S_Wait_LF                         ; warning! EOT must be followed by CR+LF (TERM2SD" used with I2C_FastForth)
; ----------------------------------;
    CMP.B   #0Ah,&TERM_RXBUF        ; also clears RX_IFG !
    JZ      T2S_Wait_LF             ; wait LF
; ----------------------------------;
    MOV     W,&BufferPtr            ;3
    CALL    #CloseHandle            ;4
    MOV     #ECHO,PC                ; then NEXT_ADR
; ----------------------------------;

    .ELSE ; if I2C_TERMINAL

; first TERATERM sends the command TERM2SD" file.ext" to I2C_FastForth.
; then when RXON is sent below, I2C_Master sends "file.ext" line by line
; then TERATERM sends char EOT that closes the file on SD_CARD.

; ==================================;
    FORTHWORD "TERM2SD\34"          ; here, I2C_Master is reSTARTed in RX mode
; ==================================;
    mDOCOL                          ;
    .word   NOBOOT                  ; on ne tente pas le diable...
    .word   NOECHO                  ;
    .word   WRITEDQ                 ; if already exist FreeAllClusters else create it as WRITE file
; ----------------------------------;
    mNEXTADR                        ;
    MOV     @RSP+,IP                ;
; ----------------------------------;
    MOV     #0,W                    ; clear W = SD_Buf_Ptr
; ----------------------------------;
T2S_GetLineLoop                     ; tranfert line by line from terminal input to SD_BUF
; ----------------------------------;
    CALL    #I2C_ACCEPT             ; use Y reg; send I2C Ctrl_Char $00 to request I2C_Master to switch from RX to TX
; ----------------------------------;
T2S_Get_a_Char_Loop                 ;
; ----------------------------------;
;T2S_Q_BufferFull                    ; test it before to take data in RX buffer and so to do SCL strech low during Write_File !!!!
; ----------------------------------;
    CMP     #BytsPerSec,W           ;2 buffer full ?
    JNC     T2S_Get_a_Char          ;2 no
; ----------------------------------;
;T2S_WriteFile                       ;  tranfert all 512 bytes of SD_BUF to the opened file in SD_CARD
; ----------------------------------;  SCL is stretched low by Slave (it's my)
    CALL    #Write_File             ;STWXY Write_File write always all the buffer
    MOV     #0,W                    ;  reset SD_Buf_Ptr
; ----------------------------------;
T2S_Get_a_Char                      ;
; ----------------------------------;
    BIT     #RX_TERM,&TERM_IFG      ;3 new char in TERMRXBUF ?
    JZ      T2S_Get_a_Char          ;2 no
    MOV.B   &TERM_RXBUF,X           ;3 SCL is released here
; ----------------------------------;
    CMP.B   #4,X                    ;1 EOT sent by TERMINAL (teraterm.exe) ?
    JZ      T2S_End_Of_File         ;2 yes
    MOV.B   X,SD_BUF(W)             ;3
    ADD     #1,W                    ;1
; ----------------------------------;
;T2S_Q_Char_LF                      ; when Master send the Ack on char 'LF', it reStarts automatically in RX mode
; ----------------------------------;
    CMP.B   #0Ah,X                  ;1 Char LF received ?
    JNZ     T2S_Get_a_Char_Loop     ;2 no, 22 cycles loop back (< 1us @ 24 MHz)
; ----------------------------------;
T2S_Send_CR                         ; because I2C_Master doesn't echo it on TERMINAL
; ----------------------------------;
    BIT     #TX_TERM,&TERM_IFG      ;
    JZ      T2S_Send_CR             ; wait TX buffer empty
    MOV.B   #0Dh,&TERM_TXBUF        ; send CR to beautify TERMINAL display (if ECHO is ON, obviously)
; ----------------------------------;
T2S_Send_LF                         ; because I2C_Master doesn't echo it on TERMINAL
; ----------------------------------;
    BIT     #TX_TERM,&TERM_IFG      ;
    JZ      T2S_Send_LF             ; wait TX buffer empty
    MOV.B   #0Ah,&TERM_TXBUF        ; send LF to beautify TERMINAL display (if ECHO is ON, obviously)
; ----------------------------------;
    JMP     T2S_GetLineLoop         ;
; ----------------------------------;
T2S_End_Of_File                     ;
; ----------------------------------;
T2S_Wait_LF                         ; warning! EOT is followed by CR+LF, because I2C_Master uses LF to switch from TX to RX
; ----------------------------------;
    CMP.B   #0Ah,&TERM_RXBUF        ; and also clears RX_IFG for CR char!
    JNZ     T2S_Wait_LF             ;
; ----------------------------------; here I2C_Master switches from TX to RX
    MOV     W,&BufferPtr            ; to add it to HDLL_CurSize
    CALL    #CloseHandle            ; tranfert SD_BUF to last sector of opened file in SD_CARD then close it
    MOV     #ECHO,PC                ; then NEXT_ADR
; ----------------------------------;

    .ENDIF
