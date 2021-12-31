 ; -*- coding: utf-8 -*-
; DTCforthMSP430FR5xxxSD_RW.asm

; and only for FR5xxx and FR6xxx with RTC_B or RTC_C hardware if you want write file with date and time.

; Tested with MSP-EXP430FR5969 launchpad
; Copyright (C) <2015>  <J.M. THOORENS>
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
OPEN_READ                           ;
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNZ     OPEN_Error              ; no
    MOV     @IP+,PC                 ; no more to do
; ----------------------------------;

;Z READ            -- f
; sequentially read a file opened by READ".
; sectors are loaded in SD_BUF and BufferLen leave the count of loaded bytes.
; when the last sector of file is loaded in buffer, the handle is automatically closed and flag is true (<>0).

; ==================================;
    FORTHWORD "READ"                ; -- fl     closed flag
; ==================================;
READ
    SUB     #2,PSP                  ;
    MOV     TOS,0(PSP)              ;
    MOV     &CurrentHdl,TOS         ;
    CALL    #Read_File              ;SWX
    SUB     &CurrentHdl,TOS         ; -- fl     if fl<>0 (if Z=0) handle is closed
    MOV     @IP+,PC                 ;
; ----------------------------------;


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
    MOV     #8,S                    ; preset disk full return error
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
ClusterHighWordTest                 ;
    CMP     #0,SD_BUF+2(Y)          ;3 cluster address hi word = 0 ?
    JNZ     SearchNextNewCluster    ;2
ClusterLowWordTest                  ;
    CMP     #0,SD_BUF(Y)            ;3 Cluster address lo word = 0 ?
    JZ      FreeClusterFound        ;2
SearchNextNewCluster                ;
    ADD     #4,Y                    ;1 increment SD_BUF offset by size of Cluster address
    CMP     #BytsPerSec,Y           ;2
    JNC     SearchFreeClusterLoop   ;2  18/15~   loopback while X U< BytsPerSec
IncrementFATsector                  ;1
    ADD     #1,0(RSP)               ;3 increment FATsector
    MOV     #0,Y                    ;  clear FAToffset
    JMP     LoadFATsectorLoop       ;5  34/23~    loopback
; ----------------------------------;
FreeClusterFound                    ; X =  cluster number low word in SD_BUF = FAToffset
; ----------------------------------;
    MOV     @RSP,&LastFATsector     ;
    MOV     Y,&LastFAToffset        ;
; ----------------------------------;
    MOV     #0,S                    ; clear error
    MOV     #-1,SD_BUF(Y)           ; mark New Cluster low word as end cluster (0xFFFF) in SD_BUF
    MOV.B   @RSP,W                  ; W = 0:FATsectorLo
    MOV     #0FFFh,SD_BUF+2(Y)      ; mark New Cluster high word as end cluster (0x0FFF) in SD_BUF
; ----------------------------------;
FAT32ClustAdrToClustNum             ; convert FAT32 cluster address to cluster number (CluNum = CluAddr / 4)
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


; ==================================;
FreeAllClusters                     ;SWXY input: HDLL_FirstClus(T), output:
; ==================================;FATs are updated
    MOV HDLL_FirstClus(T),ClusterL  ;
    MOV HDLH_FirstClus(T),ClusterH  ;
    CALL #ClusterHLtoFAT1sectWofstY ;WXY    output: W = FATsector, Y=FAToffset
    MOV     W,&LastFATsector        ;
    MOV     Y,&LastFAToffset        ;
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
GetAndFreeClusterHi                 ;
    MOV     SD_BUF+2(Y),X           ; get [clusterHI]
    MOV     #0,SD_BUF+2(Y)          ; free CLusterHI
ClusterHiTest
    AND     #00FFFh,X               ; select 12 bits significant
    CMP     #00FFFh,X               ; [ClusterHI] was = 0FFFh?
    JNE     SearchNextCluster2free  ; no
ClusterLoTest                       ;
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
    MOV     @RSP+,W                 ;
    MOV     #SaveSectorWtoFATs,PC   ; update FATs
; ----------------------------------;

; this subroutine is called by Write_File (bufferPtr=512) and CloseHandle (0 =< BufferPtr =< 512)
; ==================================;
WriteSD_Buf                         ;SWX input: T = CurrentHDL
; ==================================;
    ADD &BufferPtr,HDLL_CurSize(T)  ; update handle CurrentSizeL
    ADDC    #0,HDLH_CurSize(T)      ;
; ==================================;
WriteSectorHL                       ;SWX
; ==================================;
    MOV     &SectorL,W              ; Low
    MOV     &SectorH,X              ; High
    MOV     #WriteSectorWX,PC       ; ...then RET
; ----------------------------------;


; ======================================================================
; DEL" primitive as part of OpenPathName
; All "DEL"eted clusters are freed
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
    MOV.B   #0E5h,SD_BUF(Y)         ;
    CALL    #WriteSectorHL          ;SWX  write SectorHL=DIRsector
; ----------------------------------;
; 3- free all file clusters         ;
; ----------------------------------;
    CALL    #FreeAllClusters        ;SWXY input: HDLL_FirstClus(T), output: FATS are updated
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
    .IFNDEF   RTC                   ; RTC_B or RTC_C select
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
;    CMP     #0,W                    ; end of stringZ ?
;    JZ      OPWC_CompleteWithSpaces ;
    CMP     T,&PathName_END         ; EOS < PTR ?
    JNC     OPWC_CompleteWithSpaces ; yes
; ----------------------------------;
SkipForbiddenChars                  ;
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


; ==================================;
LoadUpdateSaveDirEntry              ;SWXY
; ==================================;
    MOV     HDLL_DIRsect(T),W       ;
    MOV     HDLH_DIRsect(T),X       ;
    CALL    #readSectorWX           ;SWX SD_buffer = DIRsector
    MOV     HDLW_DIRofst(T),Y       ; Y = DirEntryOffset
    CALL    #GetYMDHMSforDIR        ; X=DATE,  W=TIME
    MOV     X,SD_BUF+18(Y)          ; access date
    MOV     W,SD_BUF+22(Y)          ; modified time
    MOV     X,SD_BUF+24(Y)          ; modified date
    MOV HDLL_CurSize(T),SD_BUF+28(Y); save new filesize
    MOV HDLH_CurSize(T),SD_BUF+30(Y);
    MOV     HDLL_DIRsect(T),W       ;
    MOV     HDLH_DIRsect(T),X       ;
    MOV     #WriteSectorWX,PC       ;SWX then RET
; ----------------------------------;

;-----------------------------------------------------------------------
; WRITE" subroutines
;-----------------------------------------------------------------------


; write sequentially the buffer in the post incremented SectorHL.
; The first time, SectorHL is initialized by WRITE".
; All used registers must be initialized.
; ==================================;
Write_File                          ;STWXY <== WRITE, SD_EMIT, TERM2SD"
; ==================================;
    MOV     #BytsPerSec,&BufferPtr  ; write always all the buffer
    MOV     &CurrentHdl,T           ;
    CALL    #WriteSD_Buf            ;SWX write SD_BUF and update Handle informations only for DIRentry update
    MOV     #0,&BufferPtr           ; reset buffer pointer
; ----------------------------------;
PostIncrementSector                 ;
; ----------------------------------;
    ADD.B   #1,HDLB_ClustOfst(T)    ; increment current Cluster offset
    CMP.B &SecPerClus,HDLB_ClustOfst(T) ; out of bound ?
    JNC     Write_File_End          ; no,
; ----------------------------------;
    CALL    #HDLcurClus2FATsecWofstY;WXY  Output: FATsector W=FATsector, Y=FAToffset
    PUSH    Y                       ; push previous FAToffset
    PUSH    W                       ; push previous FATsector
; ----------------------------------;
GetNewCluster                       ; input : T=CurrentHdl
; ----------------------------------;
    CALL    #SearchMarkNewClusterHL ;SWXY input: W = FATsector Y = FAToffset, output: ClusterHL, W = FATsector of New cluster
    CMP     @RSP,W                  ; previous and new clusters are in same FATsector?
    JZ      LinkClusters            ;     yes
; ----------------------------------;
UpdateNewClusterFATs                ;
; ----------------------------------;
;    CALL    #SaveSectorWtoFATs      ;SWXY no: already done by SearchMarkNewClusterHL
    MOV     @RSP,W                  ; W = previous FATsector
    CALL    #ReadFAT1SectorW        ;SWX  reload previous FATsector in buffer to link clusters
; ----------------------------------;
LinkClusters                        ;
; ----------------------------------;
    MOV     @RSP+,W                 ; W = previous FATsector
    MOV     @RSP+,Y                 ; Y = previous FAToffset
    MOV     &ClusterL,SD_BUF(Y)     ; store new cluster to current cluster address in previous FATsector buffer
    MOV     &ClusterH,SD_BUF+2(Y)   ;
    CALL    #SaveSectorWtoFATs      ;SWXY update FATs from SD_BUF to W = previous FATsector
; ==================================;
HDLSetCurClustSetFrstSect           ;
; ==================================;
    MOV     #4,HDLB_Token(T)        ; and clear ClustOfst
; ==================================;
HDLSetCurClustSetCurSect            ;
; ==================================;
    MOV &ClusterL,HDLL_CurClust(T)  ; update handle with new cluster
    MOV &ClusterH,HDLH_CurClust(T)  ;
Write_File_End
    MOV #ClusterHL2sectorHL,PC      ;W set current SectorHL to be written then RET
; ----------------------------------;

;Z WRITE            --
; sequentially write the entire SD_BUF in a file opened by WRITE"
; ==================================;
    FORTHWORD "WRITE"               ; in assembly : CALL #WRITE,X   CALL 2(X)
; ==================================;
    CALL #Write_File                ;STWXY
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
    CMP     #0,S                    ; well opened file ?
    JZ      OPEN_OVERWRITE          ; yes
; ----------------------------------;
OPWC_Write_Errors                   ;
; ----------------------------------;
OPWC_InvalidPathname                ; S = 4
OPWC_DiskFull                       ; S = 8
; ----------------------------------;
OPW_Error                           ; set ECHO, type Pathname, type #error, type "< WriteError"; no return
    mDOCOL                          ;
    .word   XSQUOTE                 ;
    .byte   12,"< WriteError",0     ;
    .word   BRAN,ABORT_SD           ; to insert S error as flag, no return
; ----------------------------------;

; ======================================================================
; WRITE" primitive as part of OpenPathName
; All "DEL"eted clusters are freed
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
    MOV     #0,Y                    ; init FAToffset
    CALL    #SearchMarkNewClusterHL ;WXY  output: updated (ClusterHL, FATsector, W = FATsector), SD_BUF = [new FATsector]
; ----------------------------------;
; 3 init DIRentryAttributes         ;
; ----------------------------------;
    CALL    #ReadSectorHL           ; reload DIRsector
    MOV     &DIREntryOfst,Y         ; Y = entry offset (first free entry in DIR)
    MOV.B   #20h,SD_BUF+11(Y)       ; file attribute = file
    CALL    #GetYMDHMSforDIR        ;WX  X=DATE,  W=TIME
    MOV     #0,SD_BUF+12(Y)         ; nt reserved = 0 and centiseconds are 0
    MOV     W,SD_BUF+14(Y)          ; time of creation
    MOV     X,SD_BUF+16(Y)          ; date of creation      20/08/2001
;    MOV     X,SD_BUF+18(Y)          ; date of access        20/08/2001
    MOV     &ClusterH,SD_BUF+20(Y)  ; as first Cluster Hi
    MOV     &ClusterL,SD_BUF+26(Y)  ; as first cluster LO
    MOV     #0,SD_BUF+28(Y)         ; set file_sizeLO  = 0
    MOV     #0,SD_BUF+30(Y)         ; set file_sizeHI  = 0
; ----------------------------------;
; 4 create DIRentryName             ; file name format "xxxxxxxx.yyy"
; ----------------------------------;
    MOV     #4,S                    ; preset pathname error
    MOV     &PathName_PTR,T         ; here, PathName_PTR is set to file name
    CMP     T,&PathName_END         ; end of string reached ?
    JZ      OPWC_InvalidPathname    ; yes write error 1
    CMP.B   #'.',0(T)               ; forbidden "." in first
    JZ      OPWC_InvalidPathname    ; write error 1
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
    CALL    #FreeAllClusters        ;SWXY input: HDLL_FirstClus(T), output: FATS are updated
    MOV     #0,HDLL_CurSize(T)      ; clear currentSize
    MOV     #0,HDLH_CurSize(T)      ;
    MOV HDLL_FirstClus(T),ClusterL  ; Set ClusterHL
    MOV HDLH_FirstClus(T),ClusterH  ;
    CALL #ClusterHLtoFAT1sectWofstY ;WXY    output: W = FATsector, Y=FAToffset
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
    JZ      OPEN_WRITE_CREATE       ; yes
    CMP     #0,S                    ; well opened file ?
    JNZ     OPWC_Write_Errors       ; no
; ==================================;
OPEN_WRITE_APPEND                   ; yes
; ==================================;
; 1- open file                      ; done
; ----------------------------------;
    MOV.B  #4,HDLB_Token(T)         ; update HDLB_Token(T)
; ----------------------------------;
; 2.1- Compute Sectors count        ; Sectors = HDLL_CurSize/512
; ----------------------------------;
    MOV.B   HDLL_CurSize+1(T),Y     ;Y = 0:CurSizeLOHi (bytes)
    MOV.B   HDLH_CurSize(T),X       ;X = 0:CurSizeHILo
    SWPB    X                       ;X = CurSizeHIlo:0
    ADD     Y,X                     ;X = CurSizeHIlo:CurSizeLOhi
    MOV.B   HDLH_CurSize+1(T),Y     ;Y:X = CurSize / 256 (bytes)
; ----------------------------------;
; 2.2 Compute Clusters Count        ;
; ----------------------------------;
    MOV.B &SecPerClus,T             ;3 T = DIVISOR = SecPerClus = 0:SPClo
DIVSECPERSPC                        ;
    MOV #0,W                        ;1 W = 0:REMlo = 0
    MOV #8,S                        ;1 S = CNT
DIVSECPERSPC1                       ;
    RRA Y                           ;1 0>0:SEC_HI>C
    RRC X                           ;1 C>SEC_LO>C
    RRC.B W                         ;1 C>REMlo>C
    SUB #1,S                        ;1 CNT-1
    RRA T                           ;1 0>SPChi:SPClo>C
    JNC DIVSECPERSPC1               ;2 7~ loopback if carry clear
DIVSECPERSPC2                       ;
    RRA W                           ;1 0>0:REMlo>C
    SUB #1,S                        ;1 CNT-1
    JGE DIVSECPERSPC2               ;2 4~ loopback     Wlo = OFFSET, X = CLU_LO, Y = CLU_HI
; ----------------------------------;
; 2.3- Compute Current Cluster      ; X = ClusterCountLO, Y = ClusterCountHI
; ----------------------------------;
    MOV &CurrentHDL,T               ;3  reload Handle ptr
    ADD  HDLL_FirstClus(T),X        ;
    ADDC HDLH_FirstClus(T),Y        ;
    MOV X,HDLL_CurClust(T)          ;  update handle
    MOV Y,HDLH_CurClust(T)          ;
; ----------------------------------;
; 2.4- load current sectorHL        ;
; ----------------------------------;
    MOV.B W,HDLB_ClustOfst(T)       ;3  update handle with W = REM8 = sectors offset in last cluster
    CALL #LoadCurSectorHL           ;SWX in SD_buf
; ----------------------------------;
; 2.5- Compute SD_Buf ptr           ;
; ----------------------------------;
    MOV HDLL_CurSize(T),W           ; example :  W = $A313 bytes
    BIC #01FFh,HDLL_CurSize(T)      ; HDLL_CurSize = $A200 bytes
    AND #01FFh,W                    ; remainder  W = $0113 bytes
    MOV W,&BufferPtr                ; init Buffer Pointer with $0113
; ----------------------------------;
    MOV @IP+,PC                     ; BufferPtr = first free byte offset
; ----------------------------------;


    .IFNDEF TERMINAL_I2C ; if UART_TERMINAL

; first TERATERM sends the command TERM2SD" file.ext" to FastForth which returns XOFF at the end of the line.
; then when XON is sent below, TERATERM sends "file.ext" up to XOFF sent by TERM2SD" (slices of 512 bytes),
; then TERATERM sends char EOT that closes the file on SD_CARD.

; ==================================;
    FORTHWORD "TERM2SD\34"          ;
; ==================================;
    mDOCOL                          ;
    .word   WRITEDQ                 ;  if already exist FreeAllClusters else create it as WRITE file
    mNEXTADR                        ;
; ----------------------------------;
T2S_GetSliceLoop                    ;   tranfert by slices of 512 bytes from terminal input to file on SD_CARD via SD_BUF
; ----------------------------------;
    MOV     #0,W                    ;1  reset W = BufferPtr
    CALL    #RXON                   ;   use no registers
; ----------------------------------;
T2S_Get_a_Char_Loop                 ;
; ----------------------------------;
    BIT     #RX_TERM,&TERM_IFG      ;3 new char in TERMRXBUF ?
    JZ      T2S_Get_a_Char_Loop     ;2
    MOV.B   &TERM_RXBUF,X           ;3
    MOV.B   X,&TERM_TXBUF
    CMP.B   #4,X                    ;1 EOT sent by TERATERM ?
    JZ      T2S_End_Of_File         ;2 yes
    MOV.B   X,SD_BUF(W)             ;3
    ADD     #1,W                    ;1
    CMP     #BytsPerSec-1,W         ;2
    JZ      T2S_XOFF                ;2 W = BytsPerSec-1    send XOFF after RX 511th char
    JNC     T2S_Get_a_Char_Loop     ;2 W < BytsPerSec-1    21 cycles char loop (476 kBds/MHz)
; ----------------------------------;
T2S_WriteFile                       ;2 W = BytsPerSec
; ----------------------------------;
    CALL    #Write_File             ;STWXY write all the buffer
    JMP     T2S_GetSliceLoop        ;2
; ----------------------------------;
T2S_XOFF                            ;  27 cycles between XON and XOFF
; ----------------------------------;
    CALL    #RXOFF                  ;4  use no registers
    JMP     T2S_Get_a_Char_Loop     ;2  loop back once to get char sent by TERMINAL during XOFF time
; ----------------------------------;
T2S_End_Of_File                     ;  wait CR before sending XOFF
; ----------------------------------;
T2S_Wait_CR                         ; warning! EOT must be followed by CR+LF (TERM2SD" used with I2C_FastForth)
; ----------------------------------;
    CMP.B   #0Dh,&TERM_RXBUF        ; also clears RX_IFG !
    JZ      T2S_Wait_CR             ; wait CR
; ----------------------------------;
    CALL    #RXOFF                  ;4  use no registers
; ----------------------------------;
T2S_Wait_LF                         ; warning! EOT must be followed by CR+LF (TERM2SD" used with I2C_FastForth)
; ----------------------------------;
    CMP.B   #0Ah,&TERM_RXBUF        ; also clears RX_IFG !
    JZ      T2S_Wait_LF             ; wait LF
; ----------------------------------;
    MOV     W,&BufferPtr            ;3
    CALL    #CloseHandle            ;4
; ----------------------------------;
    MOV     @RSP+,IP                ;
    MOV     @IP+,PC                 ;4
; ----------------------------------;

    .ELSE ; if I2C_TERMINAL

; first TERATERM sends the command TERM2SD" file.ext" to I2C_FastForth.
; then when RXON is sent below, I2C_Master sends "file.ext" line by line
; then TERATERM sends char EOT that closes the file on SD_CARD.

; ==================================;
    FORTHWORD "TERM2SD\34"          ; here, I2C_Master is reSTARTed in RX mode
; ==================================;
    mDOCOL                          ;
    .word   WRITEDQ                 ; if already exist FreeAllClusters else create it as WRITE file
    mNEXTADR                        ;
; ----------------------------------;
    MOV     #0,W                    ; reset W = SD_Buf_Ptr
    MOV.B   #0Ah,IP                 ; IP = char 'LF'
; ----------------------------------;
T2S_GetLineLoop                     ; tranfert line by line from terminal input to SD_BUF
; ----------------------------------;
    CALL    #RXON                   ; use Y reg; send I2C Ctrl_Char $00 to request I2C_Master to switch from RX to TX
; ----------------------------------;
T2S_Get_a_Char_Loop                 ;
; ----------------------------------;
T2S_Q_BufferFull                    ; test it before to take data in RX buffer and so to do SCL strech low during Write_File !!!!
; ----------------------------------;
    CMP     #BytsPerSec,W           ;2 buffer full ?
    JNC     T2S_Get_a_Char          ;2 no
; ----------------------------------;
T2S_WriteFile                       ;  tranfert all 512 bytes of SD_BUF to the opened file in SD_CARD
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
T2S_Q_EOF                           ;
; ----------------------------------;
    CMP.B   #4,X                    ;1 EOF sent by TERMINAL (teraterm.exe) ?
    JZ      T2S_End_Of_File         ;2 yes
    MOV.B   X,SD_BUF(W)             ;3
    ADD     #1,W                    ;1
; ----------------------------------;
T2S_Q_Char_LF                       ; when Master send the Ack on char 'LF', it reStarts automatically in RX mode
; ----------------------------------;
    CMP.B   IP,X                    ;1 Char LF received ?
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
    MOV.B   IP,&TERM_TXBUF          ; send LF to beautify TERMINAL display (if ECHO is ON, obviously)
; ----------------------------------;
    JMP     T2S_GetLineLoop         ;
; ----------------------------------;
T2S_End_Of_File                     ;
; ----------------------------------;
T2S_Wait_LF                         ; warning! EOT is followed by CR+LF, because I2C_Master uses LF to switch from TX to RX
; ----------------------------------;
    CMP.B   IP,&TERM_RXBUF          ; and also clears RX_IFG !
    JNZ     T2S_Wait_LF             ;
; ----------------------------------; here I2C_Master switches from TX to RX
    MOV     W,&BufferPtr            ; to add it to HDLL_CurSize
    CALL    #CloseHandle            ;   tranfert SD_BUF to last sector of opened file in SD_CARD then close it
; ----------------------------------;
    MOV     @RSP+,IP                ;
    MOV     @IP+,PC                 ;
; ----------------------------------;

    .ENDIF
