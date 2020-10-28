 ; -*- coding: utf-8 -*-
; DTCforthMSP430FR5xxxSD_RW.asm

; ======================================================================
; READ" primitive as part of OpenPathName
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; ======================================================================

; ----------------------------------;
OPEN_QREAD                          ;
    CMP     #1,W                    ; open_type = READ" ?
    JNZ     OPEN_QWRITE             ; no : goto next step
; ----------------------------------;
OPEN_READ                           ;
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNZ     OPEN_Error              ; no
    MOV @IP+,PC                     ;
; ----------------------------------;

;Z READ            -- f
; sequentially read a file opened by READ".
; sectors are loaded in SD_BUF and BufferLen leave the count of loaded bytes.
; when the last sector of file is loaded in buffer, the handle is automatically closed and flag is true (<>0).

; ----------------------------------;
    FORTHWORD "READ"                ; -- fl     closed flag
; ----------------------------------;
READ
    SUB     #2,PSP                  ;
    MOV     TOS,0(PSP)              ;
    MOV     &CurrentHdl,TOS         ;
    CALL    #Read_File              ;SWX
READ_END
    SUB     &CurrentHdl,TOS         ; -- fl     if fl <>0 (if Z=0) handle is closed
    MOV @IP+,PC                     ;
; ----------------------------------;


;-----------------------------------------------------------------------
; WRITE" (CREATE part) subroutines
;-----------------------------------------------------------------------

; parse all FAT sectors until free cluster is found 
; this NewCluster is marked as the end's one (-1)


; input : CurFATsector
; use SWX registers
; output: W = new FATsector, SD_BUF = [new FATsector], NewCluster
;         SectorL is unchanged, FATS are not updated.
;         S = 2 --> Disk FULL error
; ----------------------------------;
SearchNewCluster                    ; <== CREATE file, WRITE_File
; ----------------------------------;
    MOV     #2,S                    ; preset disk full return error
    PUSH    &CurFATsector           ; last known free cluster sector
    MOV     &FATtype,Y              ;
    ADD     Y,Y                     ;  Y = bytes size of Cluster number (2 or 4)
; ----------------------------------;
LoadFATsectorInBUF                  ; <== IncrementFATsector
; ----------------------------------;
    MOV     @RSP,W                  ; W = FATsector
    CMP     W,&FATSize              ;
    JZ      OPW_Error               ; FATsector = FATSize ===> abort disk full
    ADD     &OrgFAT1,W              ;
    MOV     #0,X                    ;
    CALL    #ReadSectorWX           ;SWX (< 65536)
    MOV     #0,X                    ; init FAToffset
; ----------------------------------;
SearchFreeClustInBUF                ; <== SearchNextCluster
; ----------------------------------;
    CMP     #2,Y                    ; FAT16 Cluster size ?
    JZ      ClusterLowWordTest      ; yes
ClusterHighWordTest                 ;
    CMP     #0,SD_BUF+2(X)          ; cluster address hi word = 0 ?
    JNZ     SearchNextNewCluster    ;
ClusterLowWordTest                  ;
    CMP     #0,SD_BUF(X)            ; Cluster address lo word = 0 ?
    JZ      GNC_FreeClusterFound    ; 
SearchNextNewCluster                ;
    ADD     Y,X                     ; increment SD_BUF offset by size of Cluster address
    CMP     #BytsPerSec,X           ;
    JNE     SearchFreeClustInBUF    ; loopback while X < BytsPerSec
IncrementFATsector                  ;
    ADD     #1,0(RSP)               ; increment FATsector
    JMP     LoadFATsectorInBUF      ; loopback
; ----------------------------------;
GNC_FreeClusterFound                ; Y =  cluster number low word in SD_BUF = FATsector
; ----------------------------------;
    MOV     #0,S                    ; clear error
    MOV.B   @RSP,W                  ; W = 0:FATsectorLo
    MOV     #-1,SD_BUF(X)           ; mark NewCluster low word as end cluster (0xFFFF) in SD_BUF
    CMP     #2,Y                    ; Y = FAT16 size of Cluster number ?
    JZ      FAT16EntryToClusterNum  ; yes
    MOV     #0FFFh,SD_BUF+2(X)      ; no: mark NewCluster high word as end cluster (0x0FFF) in SD_BUF
; ----------------------------------;
FAT32EntryToClusterNum              ; convert FAT32 cluster address to cluster number
; ----------------------------------;
    RRA     X                       ; X = FATOffset>>1, FAToffset is byte size
    SWPB    W                       ; W = FATsectorLo:0
    ADD     W,X                     ; X = FATsectorLo:FATOffset>>1
    MOV.B   1(RSP),W                ; W = FATsectorHi
    RRA     W                       ; W = FATsectorHi>>1
    RRC     X                       ; X = (FATsectorLo:FAToffset>>1)>>1 = FATsectorLo>>1:FAToffset>>2
    MOV     W,&NewClusterH          ; NewClusterH =  FATsectorHi>>1
    MOV     X,&NewClusterL          ; NewClusterL = FATsectorLo>>1:FAToffset>>2
    JMP     SearchNewClusterEnd     ; max cluster = 7FFFFF ==> 1FFFFFFF sectors ==> 256 GB
; ----------------------------------;
FAT16EntryToClusterNum              ; convert FAT16 address of Cluster in cluster number
; ----------------------------------;
    RRA     X                       ; X = Offset>>1, offset is word < 256
    MOV.B   X,&NewClusterL          ; X = NewCluster numberLO (byte)
    MOV.B   W,&NewClusterL+1        ; W = NewCluster numberHI (byte)
    MOV     #0,&NewClusterH         ;
; ----------------------------------;
SearchNewClusterEnd                 ;
; ----------------------------------;
    MOV     @RSP+,W                 ; W = FATsector
    MOV     W,&CurFATsector         ; refresh CurrentFATsector
    MOV @RSP+,PC                             ;
; ----------------------------------;


; update FATs with SD_BUF content.
; input : FATsector, FAToffset, SD_BUF = [FATsector]
; use : SWX registers
; ----------------------------------; else update FATsector of the old cluster
UpdateFATsSectorW                   ;
; ----------------------------------;
    PUSH    W                       ;
    ADD     &OrgFAT1,W              ; update FAT#1
    MOV     #0,X                    ;
    CALL    #WriteSectorWX          ; write a logical sector
    MOV     @RSP+,W                 ;
    ADD     &OrgFAT2,W              ; update FAT#2
    MOV     #0,X                    ;
    CALL    #WriteSectorWX          ; write a logical sector
; ----------------------------------;



; FAT16/32 format for date and time in a DIR entry
; create time :     offset 0Dh = 0 to 200 centiseconds, not used.
;                   offset 0Eh = 0bhhhhhmmmmmmsssss, with : s=seconds*2, m=minutes, h=hours
; access time :     offset 14h = always 0, not used as date
; modified time :   ofsset 16h = 0bhhhhhmmmmmmsssss, with : s=seconds*2, m=minutes, h=hours
; dates :    offset 10, 12, 18 = 0byyyyyyymmmmddddd, with : y=year-1980, m=month, d=day

; ----------------------------------; input:
GetYMDHMSforDIR                     ;X=date, W=TIME
; ----------------------------------;
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
    MOV @RSP+,PC                             ;
; ----------------------------------;


; when create filename, forbidden chars are skipped
ForbiddenChars ; 15 forbidden chars table + dot char
    .byte '"','*','+',',','/',':',';','<','=','>','?','[','\\',']','|','.'

; ----------------------------------;
OPWC_SkipDot                        ;
; ----------------------------------;
    CMP     #4,X                    ;
    JL      FillDIRentryName        ; X < 4 : no need spaces to complete name entry
    SUB     #3,X                    ;
    CALL    #OPWC_CompleteWithSpaces; complete name entry 
    MOV     #3,X                    ; 
; ----------------------------------;

; ----------------------------------;
FillDIRentryName                    ;SWXY use
; ----------------------------------;
    MOV.B   @T+,W                   ; W = char of pathname
    MOV.B   W,SD_BUF(Y)             ;     to DIRentry
;    CMP     #0,W                    ; end of stringZ ?
;    JZ      OPWC_CompleteWithSpaces ;
    CMP     T,&EndOfPath            ; EOS < PTR ?
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
    MOV @RSP+,PC                             ;
; ----------------------------------;




; ======================================================================
; WRITE" primitive as part of OpenPathName
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; error 1  : PathNameNotFound
; error 2  : NoSuchFile       
; error 4  : DirectoryFull  
; error 8  : AlreadyOpen    
; error 16 : NomoreHandle   
; ======================================================================

; ----------------------------------;
OPEN_QWRITE                         ;
    CMP     #2,W                    ; open_type = WRITE" ?
    JNZ     OPEN_QDEL               ; no : goto next step
; ----------------------------------;
; 1 try to open                     ; done
; ----------------------------------;
; 2 select error "no such file"     ;
; ----------------------------------;
    CMP     #2,S                    ; "no such file" error ?
    JZ      OPEN_WRITE_CREATE       ; yes
    CMP     #0,S                    ; no open file error ?
    JZ      OPEN_WRITE_APPEND       ; yes
; ----------------------------------;
; Write errors                      ;
; ----------------------------------;
OPWC_InvalidPathname                ; S = 1
OPWC_DiskFull                       ; S = 2 
OPWC_DirectoryFull                  ; S = 4
OPWC_AlreadyOpen                    ; S = 8
OPWC_NomoreHandle                   ; S = 16
; ----------------------------------;
OPW_Error                           ; set ECHO, type Pathname, type #error, type "< WriteError"; no return
    mDOCOL                          ;
    .word   XSQUOTE                 ;
    .byte   12,"< WriteError",0     ;
    .word   BRAN,ABORT_SD           ; to insert S error as flag, no return
; ----------------------------------;


; ======================================================================
; WRITE" (CREATE part) primitive as part of OpenPathName
; input from open:  S = NoSuchFile, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
; output: nothing else abort on error:
; error 1  : InvalidPathname
; error 2  : DiskFull       
; error 4  : DirectoryFull  
; error 8  : AlreadyOpen    
; error 16 : NomoreHandle   
; ======================================================================

; ----------------------------------;
OPEN_WRITE_CREATE                   ;
; ----------------------------------;
; 3 get free cluster                ;
; ----------------------------------; input: FATsector
    CALL    #SearchNewCluster       ;SWXY output:  W = new FATsector loaded in buffer,NewCluster 
    MOV     &NewClusterL,&ClusterL  ;
    MOV     &NewClusterH,&ClusterH  ;
    CALL    #UpdateFATsSectorW      ;SWX update FATs with buffer
; ----------------------------------;
    CALL    #ReadSector             ; reload DIRsector
    MOV     &EntryOfst,Y            ; reload entry offset (first free entry in DIR)
; ----------------------------------;
; 4 init DIRentryAttributes         ;
; ----------------------------------;
OPWC_SetEntryAttribute              ; (cluster=DIRcluster!)
    MOV.B   #20h,SD_BUF+11(Y)       ; file attribute = file
    CALL    #GetYMDHMSforDIR        ;WX  X=DATE,  W=TIME
    MOV     #0,SD_BUF+12(Y)         ; nt reserved = 0 and centiseconds are 0
    MOV     W,SD_BUF+14(Y)          ; time of creation
    MOV     X,SD_BUF+16(Y)          ; date of creation      20/08/2001
    MOV     X,SD_BUF+18(Y)          ; date of access        20/08/2001
    MOV     &ClusterH,SD_BUF+20(Y)  ; as first Cluster Hi 
    MOV     &ClusterL,SD_BUF+26(Y)  ; as first cluster LO   
    MOV     #0,SD_BUF+28(Y)         ; file lenghtLO  = 0 
    MOV     #0,SD_BUF+30(Y)         ; file lenghtHI  = 0 
; ----------------------------------;
; 5 create DIRentryName             ;
; ----------------------------------;
    MOV     #1,S                    ; preset pathname error
    MOV     &Pathname,T             ; here, pathname is "xxxxxxxx.yyy" format
;    CMP.B   #0,0(T)                 ; forbidden null string
    CMP     T,&EndOfPath            ;
    JZ      OPWC_InvalidPathname    ; write error 1
    CMP.B   #'.',0(T)               ; forbidden "." in first
    JZ      OPWC_InvalidPathname    ; write error 1
    MOV     #11,X                   ; X=countdown of chars entry
    CALL    #FillDIRentryName       ;STWXY
; ----------------------------------;
; 6 save DIRsector                  ;
; ----------------------------------;
    CALL    #WriteSector            ;SWX update DIRsector
; ----------------------------------;
; 7 Get free handle                 ;
; ----------------------------------;
    MOV     #2,W                    ;
    CALL    #GetFreeHandle          ; output : S = handle error, CurCluster and CurSector are set
; ----------------------------------;
    CMP     #0,S                    ; no error ?
    JNZ     OPWC_NomoreHandle       ; ==> abort with error 16
    MOV @IP+,PC                           ; --
; ----------------------------------;

;-----------------------------------------------------------------------
; WRITE" subroutines
;-----------------------------------------------------------------------

; SectorL is unchanged
; ----------------------------------;
OPWW_UpdateDirectory                ; <== CloseHandleT
; ----------------------------------; Input : current Handle
    MOV     HDLL_DIRsect(T),W       ;
    MOV     HDLH_DIRsect(T),X       ;
    CALL    #readSectorWX           ;SWX buffer = DIRsector
    CALL    #GetYMDHMSforDIR        ; X=DATE,  W=TIME
    MOV     HDLW_DIRofst(T),Y       ; Y = DirEntryOffset
    MOV     X,SD_BUF+18(Y)          ; access date
    MOV     W,SD_BUF+22(Y)          ; modified time
    MOV     X,SD_BUF+24(Y)          ; modified date
OPWW_UpdateEntryFileSize            ;
    MOV HDLL_CurSize(T),SD_BUF+28(Y); save new filesize
    MOV HDLH_CurSize(T),SD_BUF+30(Y);
    MOV     HDLL_DIRsect(T),W       ; 
    MOV     HDLH_DIRsect(T),X       ;
    MOV     #WriteSectorWX,PC       ;SWX then RET
; ----------------------------------;

; this subroutine is called by Write_File (bufferPtr=512) and CloseHandleT (0 =< BufferPtr =< 512)
; ==================================; 
WriteBuffer                         ;STWXY input: T = CurrentHDL
; ==================================; 
    ADD &BufferPtr,HDLL_CurSize(T)  ; update handle CurrentSizeL
    ADDC    #0,HDLH_CurSize(T)      ;
; ==================================;
WriteSector                         ;SWX
; ==================================;
    MOV     &SectorL,W              ; Low
    MOV     &SectorH,X              ; High
    MOV     #WriteSectorWX,PC       ; ...then RET
; ----------------------------------;



; write sequentially the buffer in the post incremented SectorHL.
; The first time, SectorHL is initialized by WRITE".
; All used registers must be initialized.
; ==================================;
Write_File                          ; <== WRITE, SD_EMIT, TERM2SD"
; ==================================;
    MOV     #BytsPerSec,&BufferPtr  ; write always all the buffer
    MOV     &CurrentHdl,T           ;
    CALL    #WriteBuffer            ; write SD_BUF and update Handle informations only for DIRentry update 
    MOV     #0,&BufferPtr           ; reset buffer pointer
; ----------------------------------;
PostIncrementSector                 ;
; ----------------------------------;
    ADD.B   #1,HDLB_ClustOfst(T)    ; increment current Cluster offset
    CMP.B &SecPerClus,HDLB_ClustOfst(T) ; out of bound ?
    JNZ     Write_File_End          ; no, 
; ----------------------------------;
GetNewCluster                       ; input : T=CurrentHdl
; ----------------------------------;
    MOV.B   #0,HDLB_ClustOfst(T)    ; reset handle ClusterOffset
    CALL #HDLCurClusToFAT1sectWofstY;WXY Output: W=FATsector, Y=FAToffset, Cluster=HDL_CurCluster
    PUSH    Y                       ; push current FAToffset
    PUSH    W                       ; push current FATsector
    CALL    #SearchNewCluster       ;SWXY  output: W = new FATsector loaded in buffer, NewCluster 
    CMP     @RSP,W                  ; current and new clusters are in same FATsector?
    JZ      LinkClusters            ;     yes 
UpdateNewClusterFATs                ;
    CALL    #UpdateFATsSectorW      ;SWX  no: UpdateFATsSectorW with buffer of new FATsector
    MOV     @RSP,W                  ; W = current FATsector
    ADD     &OrgFAT1,W              ;
    MOV     #0,X                    ;
    CALL    #ReadSectorWX           ;SWX (< 65536)
LinkClusters                        ;
    MOV     @RSP+,W                 ; W = current FATsector
    MOV     @RSP+,Y                 ; pop current FAToffset
    MOV     &NewClusterL,SD_BUF(Y)  ; store new cluster to current cluster address in current FATsector buffer
    CMP     #1,&FATtype             ; FAT16?
    JZ UpdatePreviousClusterFATs    ; yes
    MOV     &NewClusterH,SD_BUF+2(Y);
UpdatePreviousClusterFATs           ;
    CALL    #UpdateFATsSectorW      ;SWX update FATS with current FATsector buffer
UpdateHandleCurCluster              ;
    MOV &NewClusterL,HDLL_CurClust(T)  ; update handle with new cluster
    MOV &NewClusterH,HDLH_CurClust(T) ;
;    CALL #ComputeHDLcurrentSector   ; set Cluster first Sector as next Sector to be written
;    MOV #OPWW_UpdateDirectory,PC    ; update DIRentry to avoid cluster lost, then RET
Write_File_End
    MOV #ComputeHDLcurrentSector,PC ; set current Cluster Sector as next Sector to be written then RET
; ----------------------------------;

;Z WRITE            -- 
; sequentially write the entire SD_BUF in a file opened by WRITE"
; ----------------------------------;
    FORTHWORD "WRITE"               ; in assembly : CALL &WRITE+2
; ----------------------------------;
    CALL #Write_File                ;
    MOV @IP+,PC                     ;
; ----------------------------------;


; ======================================================================
; WRITE" (APPEND part) primitive as part of OpenPathName
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; error 2  : DiskFull       
; ======================================================================

; ----------------------------------;
OPEN_WRITE_APPEND                   ;
; ----------------------------------;
; 1- open file                      ; done
; ----------------------------------;
; 2- compute missing Handle infos   ;
; ----------------------------------;
; 2.1- Compute Sectors count        ; Sectors = HDLL_CurSize/512
; ----------------------------------;
    MOV.B   HDLL_CurSize+1(T),Y     ;Y = 0:CurSizeLOHi
    MOV.B   HDLH_CurSize(T),X       ;X = 0:CurSizeHILo 
    SWPB    X                       ;X = CurSizeHIlo:0 
    ADD     Y,X                     ;X = CurSizeHIlo:CurSizeLOhi
    MOV.B   HDLH_CurSize+1(T),Y     ;Y:X = CurSize / 256
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
    MOV &CurrentHDL,T               ;3  reload Handle ptr  
; ----------------------------------;
; 2.3- Compute last Cluster         ; X = Clusters numberLO, Y = Clusters numberHI 
; ----------------------------------;
    ADD  HDLL_FirstClus(T),X        ;
    ADDC HDLH_FirstClus(T),Y        ;
    MOV X,HDLL_CurClust(T)          ;  update handle
    MOV Y,HDLH_CurClust(T)          ;
; ----------------------------------;
; 2.4- Compute Sectors offset       ;
; ----------------------------------;
    MOV.B W,HDLB_ClustOfst(T)       ;3  update handle with W = REMlo = sectors offset in last cluster
; ----------------------------------;
; 3- load last sector in SD_BUF     ;
; ----------------------------------;
    MOV HDLL_CurSize(T),W           ; example : W = 1013
    BIC #01FFh,HDLL_CurSize(T)      ; substract 13 from HDLL_CurSize, because loaded in buffer
    AND #01FFh,W                    ; W = 13
    MOV W,&BufferPtr                ; init Buffer Pointer with 13
    CALL #LoadHDLcurrentSector      ;SWX
    MOV @IP+,PC                     ; BufferPtr = first free byte offset
; ----------------------------------;


; ======================================================================
; DEL" primitive as part of OpenPathName
; All "DEL"eted clusters are freed
; If next DIRentry in same sector is free, DIRentry is freed, else hidden.
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing (no message if open error)
; ======================================================================


OPEN_QDEL                           ;
;    CMP     #4,W                    ;   open_type = DEL"
;    JNZ     OPEN_8W                 ;
; ----------------------------------;
OPEN_DEL                            ;
; ----------------------------------;
; 1- open file                      ; done
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNE     DEL_END                ; no: don't send message
; ----------------------------------;
; 2- Delete DIR entry               ; "delete" entry with 00h if next entry in same DIRsector is free, else "hide" entry with 05Eh
; ----------------------------------;
SelectFreeEntry                     ; nothing to do: S = 0 ready for free entry!
; ----------------------------------;
    CMP     #BytsPerSec-32,Y        ; Entry >= last entry in DIRsector ?
    JC      SelectHideEntry         ; yes:  next DIR entry is out of sector
    CMP.B   #0,SD_BUF+32(Y)         ; no:   next DIR entry in DIRsector is free?
    JZ      WriteDelEntry           ;       yes
; ----------------------------------;
SelectHideEntry                     ;       no
; ----------------------------------;
    MOV.B   #0E5h,S                 ;
; ----------------------------------;
WriteDelEntry
; ----------------------------------;
    MOV.B   S,SD_BUF(Y)             ; 
    CALL    #WriteSector            ;SWX  write SectorHL=DIRsector
; ----------------------------------;
; 3- free all file clusters         ; Cluster = FirstCluster
; ----------------------------------;
ComputeClusterSectWofstY            ;     
    CALL    #ClusterToFAT1sectWofstY;WXY    W = FATsector, Y=FAToffset
    MOV     W,&CurFATsector         ; update CurrentFATsector
; ----------------------------------;
LoadFAT1sector
; ----------------------------------;
    MOV     W,T                     ; T = W = current FATsector memory
    ADD     &OrgFAT1,W              ;
    MOV     #0,X                    ;
    CALL    #ReadSectorWX           ;SWX (< 65536)
; ----------------------------------;
GetAndFreeClusterLo                 ;
; ----------------------------------;
    MOV     SD_BUF(Y),W             ; get [clusterLO]
    MOV     #0,SD_BUF(Y)            ; free CLusterLO
ClusterTestSelect                   ;
    CMP     #1,&FATtype             ; FAT16 ?
    JZ      ClusterLoTest           ; yes
GetAndFreeClusterHi                 ;
    MOV     SD_BUF+2(Y),X           ; get [clusterHI]
    MOV     #0,SD_BUF+2(Y)          ; free CLusterHI
ClusterHiTest
    AND     #00FFFh,X               ; select 12 bits significant
    CMP     #00FFFh,X               ; [ClusterHI] was = 0FFFh?
    JNE     SearchNextCluster2free  ; no
ClusterLoTest                  
    CMP     #-1,W                   ; [ClusterLO] was = FFFFh?
    JZ      EndOfFileClusters       ; yes 
; ----------------------------------;
SearchNextCluster2free
; ----------------------------------;
    MOV     W,&ClusterL             ;
    MOV     X,&ClusterH             ;
    CALL    #ClusterToFAT1sectWofstY;WXY
    CMP     W,T                     ; new FATsector = current FATsector memory ?
    JZ      GetAndFreeClusterLo     ; yes loop back
    PUSH    W                       ; no: save new FATsector...
    MOV     T,W                     ; ...before update current FATsector
    CALL    #UpdateFATsSectorW      ;SWX
    MOV     @RSP+,W                 ; restore new current FATsector
    JMP     LoadFAT1sector          ; loop back with Y = FAToffset
; ----------------------------------;
EndOfFileClusters                   ;
; ----------------------------------;
    MOV     T,W                     ; T = W = current FATsector
    CALL    #UpdateFATsSectorW      ;SWX
; ----------------------------------;
; 3- Close Handle                   ;
; ----------------------------------;
    CALL    #CloseHandleT           ;
; ----------------------------------;
DEL_END                             ;
    MOV @IP+,PC                     ;4
; ----------------------------------;



    .IFNDEF TERMINAL_I2C ; if UART_TERMINAL

; first TERATERM sends the command TERM2SD" file.ext" to FastForth which returns XOFF at the end of the line.
; then when XON is sent below, TERATERM sends "file.ext" up to XOFF sent by TERM2SD" (slices of 512 bytes),
; then TERATERM sends char EOT that closes the file on SD_CARD.

    FORTHWORD "TERM2SD\34"
    mDOCOL
    .word   DELDQ                   ;                   DEL file if already exist
    .word   lit,2                   ; -- open_type
    .word   HERE,COUNT              ; -- open_type addr cnt
    .word   PARENOPEN               ;                   reopen same filepath but as write
    .word   $+2                     ;
    MOV     @RSP+,IP                ;
; ----------------------------------;
T2S_GetSliceLoop                    ;   tranfert by slices of 512 bytes terminal input to file on SD_CARD via SD_BUF 
; ----------------------------------;
    MOV     #0,W                    ;1  reset W = BufferPtr
    CALL    #RXON                   ;   use no registers
; ----------------------------------;
T2S_FillBufferLoop                  ;
; ----------------------------------;
    BIT     #RX_TERM,&TERM_IFG      ;3 new char in TERMRXBUF ?
    JZ      T2S_FillBufferLoop      ;2
    MOV.B   &TERM_RXBUF,X           ;3
    MOV.B   X,&TERM_TXBUF
    CMP.B   #4,X                    ;1 EOT sent by TERATERM ?
    JZ      T2S_End_Of_File                 ;2 yes
    MOV.B   X,SD_BUF(W)             ;3
    ADD     #1,W                    ;1
    CMP     #BytsPerSec-1,W         ;2
    JNC     T2S_FillBufferLoop      ;2 W < BytsPerSec-1    21 cycles char loop
    JZ      T2S_XOFF                ;2 W = BytsPerSec-1    send XOFF after RX 511th char
; ----------------------------------;
T2S_WriteFile                       ;2 W = BytsPerSec
; ----------------------------------;
    CALL    #Write_File             ;TSWXY write all the buffer
    JMP     T2S_GetSliceLoop        ;2 
; ----------------------------------;
T2S_XOFF                            ;  27 cycles between XON and XOFF
; ----------------------------------;
    CALL    #RXOFF                  ;4  use no registers
    JMP     T2S_FillBufferLoop      ;2  loop back once to get last char
; ----------------------------------;
T2S_End_Of_File                     ;
; ----------------------------------;
    CALL    #RXOFF                  ;4  use no registers
    MOV     W,&BufferPtr            ;3
    CALL    #CloseHandleT           ;4
    MOV @IP+,PC                     ;4
; ----------------------------------;

    .ELSE ; if I2C_TERMINAL

    FORTHWORD "TERM2SD\34"
    CALL    #WAITCHAREND            ; wait I2C_Master (re)START RX
    BIC     #WAKE_UP,&TERM_IFG      ; clear UCSTTIFG before next test
    mDOCOL
    .word   DELDQ                   ;                   DEL file if already exist
    .word   lit,2                   ; -- open_type
    .word   HERE,COUNT              ; -- open_type addr cnt
    .word   PARENOPEN               ;                   reopen same filepath but as write
    .word   $+2                     ;
; ----------------------------------;
    CALL    #RXON                   ;
    BIC     #WAKE_UP,&TERM_IFG      ; clear UCSTTIFG before next test
; ----------------------------------;
T2S_ClearBuffer
; ----------------------------------;
    MOV     #0,W                    ;1  reset W = BufferPtr
; ----------------------------------;
T2S_FillBufferLoop                  ;   move by slices of 512 bytes from TERMINAL input to file on SD_CARD via SD_BUF 
; ----------------------------------;
    BIT     #RX_TERM,&TERM_IFG      ;3 new char in TERMRXBUF ?
    JZ      T2S_FillBufferLoop      ;2 no
    MOV.B   &TERM_RXBUF,X           ;3
    CMP.B   #4,X                    ;1 EOT sent by TERATERM ?
    JZ      T2S_End_Of_File         ;2 yes
    MOV.B   X,SD_BUF(W)             ;3
    ADD     #1,W                    ;1
    CMP.B   #0Ah,X                  ;2 Char LF ?
    JNZ     T2S_Q_BufferFull        ;2 no
; ----------------------------------;
T2S_GetNewLine                      ; after LF sent, I2C_Master automaticaly (re)STARTs in RX mode
; ----------------------------------;
    CALL    #WAITCHAREND            ; wait I2C_Master (re)START RX
    BIC     #WAKE_UP,&TERM_IFG      ; clear UCSTTIFG before next test
    ASMtoFORTH
    .word   LIT,0Ah,EMIT            ; use Y reg
    .word   $+2                     ;
    CALL    #RXON                   ; tells I2C_Master to(re)START in TX mode and waits I2C_Master TX (re)STARTed,  use Y register
    BIC     #WAKE_UP,&TERM_IFG      ; clear UCSTTIFG before next test
; ----------------------------------;
T2S_Q_BufferFull                    ;
; ----------------------------------;
    CMP     #BytsPerSec,W           ;2 buffer full ?
    JNC     T2S_FillBufferLoop      ;2 no    21 cycles char loop
; ----------------------------------;
T2S_WriteFile                       ;2 yes
; ----------------------------------;
    CALL    #Write_File             ;4 TSWXY write all the buffer
    JMP     T2S_ClearBuffer         ;2 
; ----------------------------------;
T2S_End_Of_File                     ;
; ----------------------------------;
    MOV     @RSP+,IP                ; before CloseHandleT
    MOV     W,&BufferPtr            ;3
    CALL    #CloseHandleT           ;4
T2S_End_Of_EOT_Line                 ;
    BIT     #RX_TERM,&TERM_IFG      ;3 new char in TERMRXBUF ?
    JZ      T2S_End_Of_EOT_Line     ;2 no
    MOV.B   &TERM_RXBUF,X           ;3 
    CMP.B   #0Ah,X                  ;2 Char LF ?
    JNZ     T2S_End_Of_EOT_Line     ;    
    CALL    #WAITCHAREND            ; wait I2C_Master (re)START RX
    BIC     #WAKE_UP,&TERM_IFG      ; clear UCSTTIFG before next test...
    MOV     @IP+,PC                 ; ... i.e. ready for return to SLEEP via RXON.
; ----------------------------------;

    .ENDIF
