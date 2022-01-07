; -*- coding: utf-8 -*-
; forthMSP430FR_SD_LOAD.asm

; Tested with MSP-EXP430FR5994 launchpad
; Copyright (C) <2019>  <J.M. THOORENS>
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


; used variables : BufferPtr, BufferLen

;-----------------------------------------------------------------------
; SD card OPEN, LOAD subroutines
;-----------------------------------------------------------------------

; ==================================;
ReadFAT1SectorW                     ;SWX (< 65536)
; ==================================;
    ADD     &OrgFAT1,W              ;
    MOV     #0,X                    ; FAT1_SectorHI = 0
    JMP     ReadSectorWX            ;SWX read FAT1SectorW
; ----------------------------------;

   .IFDEF SD_CARD_READ_WRITE

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
    JMP     WriteSectorWX           ; ...then RET
; ----------------------------------;

    .ENDIF

; rules for registers use
; S = error
; T = CurrentHdl, pathname
; W = SectorL, (RTC) TIME
; X = SectorH, (RTC) DATE
; Y = BufferPtr, (DIR) DIREntryOfst


; ==================================;
HDLcurClus2FATsecWofstY             ;WXY Input: T=Handle, HDL_CurClustHL  Output: ClusterHL, FATsector, W = FATsector, Y = FAToffset
; ==================================;
    MOV HDLL_CurClust(T),&ClusterL  ;
    MOV HDLH_CurClust(T),&ClusterH  ;
; ==================================;
ClusterHLtoFAT1sectWofstY           ;WXY Input : ClusterHL   Output: ClusterHL, FATsector, W = FATsector, Y = FAToffset
; ==================================;limited to $10000 sectors ==> $800000 clusters ==> 32GB for 4k clusters
    MOV.B &ClusterL+1,W             ;3 W = ClusterLoHI
    MOV.B &ClusterL,Y               ;3 Y = ClusterLOlo
; input : Cluster n, max = 7FFFFF,  (SD_card up to 256 GB with 64k clusters)
; ClusterLoLo*4 = displacement in 512 bytes sector   ==> FAToffset
; ClusterHiLo&ClusterLoHi +C  << 1 = relative FATsector + orgFAT1       ==> FATsector
; ----------------------------------;
    MOV.B &ClusterH,X               ;3 X = 0:ClusterHIlo
    SWPB X                          ;1 X = ClusterHIlo:0
    BIS X,W                         ;1 W = ClusterHIlo:ClusterLOhi
; ----------------------------------;
    SWPB Y                          ;1 Y = ClusterLOlo:0
    ADD Y,Y                         ;1 Y = ClusterLOlo:0 << 1  (carry report for FATsector)
    ADDC W,W                        ;1 FATsector = W = ClusterHIlo:ClusterLOhi<<1 + Carry
    SWPB Y                          ;1 Y = 0:ClusterLOlo
    ADD Y,Y                         ;1 FAToffset = Y = 0:ClusterLOlo<<2 for FAT32
    MOV @RSP+,PC                    ;4
; ----------------------------------;

; use no registers
; ==================================;
ClusterHLtoFrstSectorHL             ; Input : ClusterHL, output: first SectorHL of ClusterHL
; ==================================;
    .IFDEF MPY                      ; general case
; ----------------------------------;
    MOV     &ClusterL,&MPY32L       ;3
    MOV     &ClusterH,&MPY32H       ;3
    MOV     &SecPerClus,&OP2        ;5+3
    MOV     &RES0,&SectorL          ;5
    MOV     &RES1,&SectorH          ;5
    ADD     &OrgClusters,&SectorL   ;5 OrgClusters = sector of virtual cluster 0, word size
    ADDC    #0,&SectorH             ;3 32~
; ----------------------------------;
    .ELSEIF                         ; case of no hardware multiplier
; ----------------------------------; Cluster24<<SecPerClus --> ClusFrstSect; SecPerClus = {1,2,4,8,16,32,64}
    PUSHM  #3,W                     ;5 PUSHM W,X,Y
    MOV.B &SecPerClus,W             ;3 SecPerClus(5-1) = multiplicator
    MOV &ClusterL,X                 ;3 Cluster(16-1) --> MULTIPLICANDlo
    MOV.B &ClusterH,Y               ;3 Cluster(24-17) -->  MULTIPLICANDhi
    JMP CCFS_ENTRY                  ;
CCFS_LOOP                           ;
    ADD X,X                         ;1 (RLA) shift one left MULTIPLICANDlo16
    ADDC Y,Y                        ;1 (RLC) shift one left MULTIPLICANDhi8
CCFS_ENTRY
    RRA W                           ;1 shift one right multiplicator
    JNC CCFS_LOOP                   ;2 C = 0 loop back
CCFS_NEXT                           ;  C = 1, it's done
    ADD &OrgClusters,X              ;3 OrgClusters = sector of virtual_cluster_0, word size
    ADDC #0,Y                       ;1
    MOV X,&SectorL                  ;3 low result
    MOV Y,&SectorH                  ;3 high result
    POPM  #3,W                      ;5 POPM Y,X,W
; ----------------------------------;32~ + 5~ by 2* shift
    .ENDIF ; MPY
; ----------------------------------;
CCFS_RET                            ;
    MOV @RSP+,PC                    ;
; ----------------------------------;


; ==================================;
HDLCurClusPlsOfst2sectorHL          ;SWX input: HDL (CurClust, ClustOfst) output: SectorHL
; ==================================;
    MOV HDLL_CurClust(T),&ClusterL  ;
    MOV HDLH_CurClust(T),&ClusterH  ;
; ==================================;
ClusterHL2sectorHL                  ;W input: ClusterHL, ClustOfst output: SectorHL
; ==================================;
    CALL #ClusterHLtoFrstSectorHL   ;
    MOV.B HDLB_ClustOfst(T),W       ; byte to word conversion
    ADD W,&SectorL                  ;
    ADDC #0,&SectorH                ;
    MOV @RSP+,PC                    ;
; ----------------------------------;


; if first open_load token, save DefaultInputStream
; if other open_load token, decrement token, save previous context

; OPEN subroutine
; Input : DIREntryOfst, Cluster = DIREntryOfst(HDLL_FirstClus())
; init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus,HDLL_CurClust,HDLL_CurSize)
; Output: Cluster = first Cluster of file, X = CurrentHdl
; ==================================; input : Cluster, DIREntryOfst
GetFreeHandle                       ;STWXY init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus = HDLL_CurClust,HDLL_CurSize)
; ==================================; output : T = new CurrentHdl
    MOV #8,S                        ; prepare file already open error
    MOV #FirstHandle,T              ;
    MOV #0,X                        ; X = init previous handle as 0
; ----------------------------------;
SearchHandleLoop                    ;
; ----------------------------------;
    CMP.B   #0,HDLB_Token(T)        ; free handle ?
    JZ      FreeHandleFound         ; yes
AlreadyOpenTest                     ; no
    CMP     &ClusterH,HDLH_FirstClus(T);
    JNE     SearchNextHandle        ;
    CMP     &ClusterL,HDLL_FirstClus(T);
    JZ      OPEN_Error              ; error 8: Already Open abort ===>
SearchNextHandle                    ;
    MOV     T,X                     ; handle is occupied, keep it in X as previous handle
    ADD     #HandleLenght,T         ;
    CMP     #HandleEnd,T            ;
    JNZ     SearchHandleLoop        ;
    ADD     S,S                     ;
    JMP     OPEN_Error              ; error 16 = no more handle error, abort ===>
; ----------------------------------;
FreeHandleFound                     ; T = new handle, X = previous handle
; ----------------------------------;
    MOV     #0,S                    ; prepare Happy End (no error)
    MOV     T,&CurrentHdl           ;
    MOV     X,HDLW_PrevHDL(T)       ; link to previous handle
; ----------------------------------;
CheckCaseOfPreviousToken            ;
; ----------------------------------;
    CMP     #0,X                    ; existing previous handle?
    JZ      InitHandle              ; no
    ADD     &TOIN,HDLW_BUFofst(X)   ; in previous handle, add interpret offset to Buffer offset
; ----------------------------------;
CheckCaseOfLoadFileToken            ;
; ----------------------------------;
    CMP.B   #0,W                    ; open_type is LOAD (-1) ?
    JGE     InitHandle              ; W>=0, no
    CMP.B   #0,HDLB_Token(X)        ; previous token is negative? (open_load type)
    JGE     InitHandle              ; no
    ADD.B   HDLB_Token(X),W         ; LOAD token = previous LOAD token -1
; ----------------------------------;
InitHandle                          ;
; ----------------------------------;
    MOV.B   W,HDLB_Token(T)         ; marks handle as open type: <0=LOAD, 1=READ, 2=DEL, 4=WRITE, 8=APPEND
    MOV.B   #0,HDLB_ClustOfst(T)    ; clear ClustOfst
    MOV     &SectorL,HDLL_DIRsect(T); init handle DIRsectorL
    MOV     &SectorH,HDLH_DIRsect(T);
    MOV     &DIREntryOfst,Y         ;
    MOV     Y,HDLW_DIRofst(T)       ; init handle SD_BUF offset of DIR entry
    MOV SD_BUF+26(Y),HDLL_FirstClus(T); init handle firstcluster of file (to identify file)
    MOV SD_BUF+20(Y),HDLH_FirstClus(T); = 0 if new DIRentry (create write file)
    MOV SD_BUF+26(Y),HDLL_CurClust(T); init handle CurrentCluster
    MOV SD_BUF+20(Y),HDLH_CurClust(T); = 0 if new DIRentry (create write file)
    MOV SD_BUF+28(Y),HDLL_CurSize(T); init handle LOW currentSizeL
    MOV SD_BUF+30(Y),HDLH_CurSize(T); = 0 if new DIRentry (create write file)
    MOV     #0,&BufferPtr           ; reset BufferPtr all type of files
    CMP.B   #2,W                    ; del file request (2) ?
    JZ      InitHandleRET           ;
    JGE HDLCurClusPlsOfst2sectorHL  ; set ClusterHL and SectorHL for all WRITE requests
; ----------------------------------;
    MOV     #0,HDLW_BUFofst(T)      ; < 2, is a READ or a LOAD request
    CMP.B   #-1,W                   ;
    JZ      ReplaceInputBuffer      ; case of first loaded file
    JL      SaveBufferContext       ; case of other loaded file
    JMP     SetBufLenLoadCurSector  ; case of READ file
; ----------------------------------;
ReplaceInputBuffer                  ;
; ----------------------------------;
    MOV #SDIB_ORG,&CIB_ORG          ; set SD Input Buffer as Current Input Buffer before return to QUIT
    MOV #SD_ACCEPT,&PFAACCEPT       ; redirect ACCEPT to SD_ACCEPT before return to QUIT
; ----------------------------------;
SaveBufferContext                   ; (see CloseHandle)
; ----------------------------------;
    MOV &SOURCE_LEN,HDLW_PrevLEN(T) ; = CPL
    SUB &TOIN,HDLW_PrevLEN(T)       ; PREVLEN = CPL - >IN
    MOV &SOURCE_ORG,HDLW_PrevORG(T) ; = CIB
    ADD &TOIN,HDLW_PrevORG(T)       ; PrevORG = CIB + >IN
    JMP SetBufLenLoadCurSector      ; then RET
; ----------------------------------;
InitHandleRET                       ;
; ----------------------------------;
    MOV @RSP+,PC                    ;
; ----------------------------------;


; sequentially load in SD_BUF bytsPerSec bytes of a file opened as read or as load
; if new bufferLen have a size <= BufferPtr, closes the file then RET.
; if previous bufferLen had a size < bytsPerSec, closes the file and reloads previous LOADed file if exist.
; HDLL_CurSize leaves the not yet read size
; All used registers must be initialized.
; ==================================;
Read_File                           ; <== SD_ACCEPT, READ
; ==================================;
    MOV     &CurrentHdl,T           ;
    MOV     #0,&BufferPtr           ; reset BufferPtr (the buffer is already read)
; ----------------------------------;
    CMP     #bytsPerSec,&BufferLen  ;
    JNZ     CloseHandle             ; because this last and incomplete sector is already read
    SUB #bytsPerSec,HDLL_CurSize(T) ; HDLL_CurSize is decremented of one sector lenght
    SUBC    #0,HDLH_CurSize(T)      ;
    ADD.B   #1,HDLB_ClustOfst(T)    ; current cluster offset is incremented
    CMP.B &SecPerClus,HDLB_ClustOfst(T) ; Cluster Bound reached ?
    JNC     SetBufLenLoadCurSector  ; no
; ----------------------------------;
;SearchNextClusterInFAT1            ;
; ----------------------------------;
    MOV.B   #0,HDLB_ClustOfst(T)    ; reset Current_Cluster sectors offset
    CALL    #HDLcurClus2FATsecWofstY;WXY  Output: FATsector W=FATsector, Y=FAToffset
    CALL    #ReadFAT1SectorW        ;SWX (< 65536)
    MOV     #0,HDLH_CurClust(T)     ; preset HDLH_CurClust(T)=0 for FAT16
    MOV SD_BUF(Y),HDLL_CurClust(T)  ;
    MOV SD_BUF+2(Y),HDLH_CurClust(T); set HDLH_CurClust(T)=0 for FAT32
; ==================================;
SetBufLenLoadCurSector              ;WXY <== previous handle reLOAD with BufferPtr<>0
; ==================================;
    MOV     #bytsPerSec,&BufferLen  ; preset BufferLen
    CMP     #0,HDLH_CurSize(T)      ; CurSize > 65535 ?
    JNZ     LoadCurSectorHL         ; yes
    CMP HDLL_CurSize(T),&BufferPtr  ; BufferPtr >= CurSize ? (BufferPtr = 0 or see RestorePreviousLoadedBuffer)
    JC      CloseHandle             ; yes
    CMP #bytsPerSec,HDLL_CurSize(T) ; CurSize >= 512 ?
    JC      LoadCurSectorHL         ; yes
    MOV HDLL_CurSize(T),&BufferLen  ; no: adjust BufferLen
; ==================================;
LoadCurSectorHL                     ;
; ==================================;
    CALL #HDLCurClusPlsOfst2sectorHL;SWX
; ==================================;
ReadSectorHL                        ;
; ==================================;
    MOV     &SectorL,W              ; Low
    MOV     &SectorH,X              ; High
    JMP     ReadSectorWX            ; SWX then RET
; ----------------------------------;


; ----------------------------------;
CloseHandleT                        ;
; ----------------------------------;
    MOV.B #0,HDLB_Token(T)          ; release the handle
    MOV @T,T                        ; T = previous handle
    MOV T,&CurrentHdl               ; becomes current handle
    CMP #0,T                        ;
    JZ CloseHandleRet               ; if no more handle
; ----------------------------------;
RestorePreviousLoadedBuffer         ;
; ----------------------------------;
    MOV HDLW_BUFofst(T),&BufferPtr  ; restore previous BufferPtr
    CALL    #SetBufLenLoadCurSector ; then reload previous buffer
    BIC #Z,SR                       ;
; ----------------------------------;
CloseHandleRet                      ;
    MOV @RSP+,PC                    ; Z = 1 if no more handle
; ----------------------------------;

; ==================================;
CloseHandle                         ; <== CLOSE, Read_File, TERM2SD", OPEN_DEL
; ==================================;
    MOV &CurrentHdl,T               ;
    CMP #0,T                        ; no handle?
    JZ CloseHandleRet               ; RET
; ----------------------------------;
    .IFDEF SD_CARD_READ_WRITE
    CMP.B #4,HDLB_Token(T)          ; WRITE file ?
    JL TestClosedToken              ; no, case of DEL READ LOAD file
;; ----------------------------------; optionnal
;    MOV &BufferPtr,W                ;
;RemFillZero                         ;the remainder of sector
;    CMP     #BytsPerSec,W           ;2 buffer full ?
;    JZ      UpdateWriteSector       ;2 remainding of buffer is full filled with 0
;    MOV.B   #0,SD_BUF(W)            ;3
;    ADD     #1,W                    ;1
;    JMP     RemFillZero             ;2
;; ----------------------------------;
UpdateWriteSector
    CALL #WriteSD_Buf               ;SWX
; ----------------------------------;
;Load Update Save DirEntry          ;SWXY
; ----------------------------------;
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
    CALL    #WriteSectorWX          ;SWX
; ----------------------------------;
    .ENDIF                          ;
; ----------------------------------;
TestClosedToken                     ;
; ----------------------------------;
    CMP.B #0,HDLB_Token(T)          ;
; ----------------------------------;
CaseOfAnyReadWriteDelFileIsClosed   ; token >= 0
; ----------------------------------;
    JGE CloseHandleT                ; then RET
; ----------------------------------;
CaseOfAnyLoadedFileIsClosed         ; -- org' len'   R-- QUIT3 dst_ptr dst_len SD_ACCEPT
; ----------------------------------;
RestoreSD_ACCEPTContext             ;
; ----------------------------------;
    MOV HDLW_PrevLEN(T),TOS         ;
    MOV HDLW_PrevORG(T),0(PSP)      ; -- org len
; ----------------------------------;
ReturnOfSD_ACCEPT                   ;
; ----------------------------------;
    ADD #6,RSP                      ; R-- QUIT3     empties return stack
    MOV @RSP+,IP                    ;               skip return to SD_ACCEPT
; ----------------------------------;
    CALL #CloseHandleT              ;               Z = 1 if no more handle
; ----------------------------------;
CheckFirstLoadedFileIsClosed        ;
; ----------------------------------;
    JZ RestoreDefaultACCEPT         ;
    MOV #NOECHO,PC                  ; -- org len    if return to SD_ACCEPT
; ----------------------------------;
RestoreDefaultACCEPT                ;               if no more handle, first loaded file is closed...
; ----------------------------------;
    MOV #TIB_ORG,&CIB_ORG           ;               restore TIB as Current Input Buffer for next line (next QUIT)
    MOV #BODYACCEPT,&PFAACCEPT      ;               restore default ACCEPT for next line (next QUIT)
    MOV #ECHO,PC                    ; -- org len    if return to Terminal ACCEPT
; ----------------------------------;


; ==================================; input : X = countdown_of_spaces, Y = DIRsector_buffer ptr
ParseEntryNameSpaces                ;XY
; ==================================; output: Z flag, Y is set after the last space char
    CMP     #0,X                    ;
    JZ      PENSL_END               ;
; ----------------------------------;
ParseEntryNameSpacesLoop            ;
; ----------------------------------;
    CMP.B   #32,SD_BUF(Y)           ; SPACE ?
    JNZ     PENSL_END               ; no: RET
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     ParseEntryNameSpacesLoop;
PENSL_END                           ;
    MOV @RSP+,PC                    ;
; ----------------------------------;

   .IFDEF SD_CARD_READ_WRITE

; ==================================;
HDLFrstClus2FATsecWofstY            ;WXY Input: T=Handle, HDL_CurClustHL  Output: ClusterHL, FATsector, W = FATsector, Y = FAToffset
; ==================================;
    MOV HDLL_FirstClus(T),&ClusterL ;
    MOV HDLH_FirstClus(T),&ClusterH ;
    JMP ClusterHLtoFAT1sectWofstY   ;
; ----------------------------------;

;-----------------------------------------------------------------------
; SD_READ_WRITE FORTH words
;-----------------------------------------------------------------------

;Z READ"         --
; parse string until " is encountered, convert counted string in String
; then parse string until char '0'.
; media identifiers "A:", "B:" ... are ignored (only one SD_Card),
; char "\" as first one initializes rootDir as SearchDir.
; if file found, if not already open and if free handle...
; ...open the file as read and return the handle in CurrentHdl.
; then load first sector in buffer, bufferLen and bufferPtr are ready for read
; currentHdl keep handle that is flagged as "read".

; to read sequentially next sectors use READ word. A flag is returned : true if file is closed.
; the last sector so is in buffer.

; if pathname is a directory, change current directory.
; if an error is encountered, no handle is set, error message is displayed.

; READ" acts also as CD dos command :
;     - READ" a:\misc\" set a:\misc as current directory
;     - READ" a:\" reset current directory to root
;     - READ" ..\" change to parent directory

; to close all files type : WARM (or COLD, RESET)

; ==================================;
    FORTHWORDIMM "READ\34"          ; immediate
; ==================================;
READDQ
    MOV.B   #1,W                    ; W = READ request
    JMP     Open_File               ;
; ----------------------------------;

;Z DEL" pathame"   --       immediate
; ==================================;
    FORTHWORDIMM "DEL\34"           ; immediate
; ==================================;
DELDQ
    MOV.B   #2,W                    ; W = DEL request
    JMP     Open_File               ;
; ----------------------------------;

;Z WRITE" pathame"   --       immediate
; if file exist, free all clusters then switch handle to WRITE
; if "no such file", open a write handle
; ==================================;
    FORTHWORDIMM "WRITE\34"         ; immediate
; ==================================;
WRITEDQ
    MOV.B   #4,W                    ; W = WRITE request
    JMP     Open_File               ;
; ----------------------------------;

;Z APPEND" pathame"   --       immediate
; open the file designed by pathname.
; the last sector of the file is loaded in buffer, and bufferPtr leave the address of the first free byte.
; ==================================;
    FORTHWORDIMM "APPEND\34"        ; immediate
; ==================================;
APPENDQ
    MOV.B   #8,W                    ; W = APPEND request
    JMP     Open_File               ;
; ----------------------------------;

;Z CLOSE      --
; close current handle
; ==================================;
    FORTHWORD "CLOSE"               ;
; ==================================;
    CALL    #CloseHandle            ;
    MOV @IP+,PC                     ;
; ----------------------------------;

    .ENDIF ; SD_CARD_READ_WRITE

;-----------------------------------------------------------------------
; SD_CARD_LOADER FORTH word
;-----------------------------------------------------------------------

;Z LOAD" pathame"   --       immediate
; compile state : compile LOAD" pathname"
; exec state : open a file from SD card via its pathname
; see Open_File primitive for pathname conventions
; the opened file becomes the new input stream for INTERPRET
; this command is recursive, limited only by the count of free handles (up to 8)
; LOAD" acts also as dos command "CD" :
;     - LOAD" \misc\" set a:\misc as current directory
;     - LOAD" \" reset current directory to root
;     - LOAD" ..\" change to parent directory

; ==================================;
    FORTHWORDIMM "LOAD\34"          ; immediate
; ==================================;
    MOV.B   #-1,W                   ; W = LOAD request
; ----------------------------------;

; ======================================================================
; OPEN FILE primitive
; ======================================================================
; Open_File               --
; primitive for LOAD" READ" CREATE" WRITE" DEL"
; store OpenType on TOS,
; compile state : compile OpenType, compile SQUOTE and the string of provided pathname
; exec state :  open a file from SD card via its pathname
;               convert counted string found at HERE in a String then parse it
;                   media identifiers "A:", "B:" ... are ignored (only one SD_Card),
;                   char "\" as first one initializes rootDir as SearchDir.
;               if file found, if not already open and if free handle...
;                   ...open the file as read and return the handle in CurrentHdl.
;               if the pathname is a directory, change current directory, no handle is set.
;               if an error is encountered, no handle is set, an error message is displayed.
; ==================================;
Open_File                           ; --
; ==================================;
    SUB     #2,PSP                  ;
    MOV     TOS,0(PSP)              ;
    MOV     W,TOS                   ; -- Open_type (-1=LOAD", 1=READ", 2=DEL", 4=WRITE", 8=APPEND")
    CMP     #0,&STATE               ;
    JZ      OPEN_EXEC               ;
; ----------------------------------;
OPEN_COMP                           ;
    mDOCOL                          ; if compile state                              R-- LOAD"_return
    .word   lit,lit,COMMA,COMMA     ; compile open_type as literal
    .word   SQUOTE                  ; compile string_exec + string
    .word   lit,ParenOpen,COMMA     ; compile (OPEN)
    .word   EXIT                    ;
; ----------------------------------;
OPEN_EXEC                           ;
    mDOCOL                          ; if exec state
    .word   lit,'"',WORDD,COUNT     ; -- open_type addr cnt
    .word   $+2                     ;
    MOV     @RSP+,IP                ;
; ----------------------------------;
ParenOpen                           ; -- open_type addr cnt
; ----------------------------------;
    MOV     @PSP+,rDOCON            ; rDOCON = addr = pathname PTR
    ADD     rDOCON,TOS              ; TOS = EOS (End Of String) = pathname end
    .IFDEF SD_CARD_READ_WRITE       ;
    MOV     TOS,&PathName_END       ; for WRITE CREATE part
    .ENDIF
; ----------------------------------;
;OPN_PathName                       ;
; ----------------------------------;
    MOV     #2,&ClusterL            ; set root DIR cluster
    MOV     #0,&ClusterH            ;
    MOV     #1,S                    ; error 1
    CMP     rDOCON,TOS              ; PTR = EOS ? (end of pathname ?)
    JZ      OPEN_Error              ; yes: error 1 ===>
; ----------------------------------;
    CMP.B   #':',1(rDOCON)          ; A: B: C: ... in pathname ?
    JNZ     OPN_AntiSlashStartTest  ; no
    ADD     #2,rDOCON               ; yes : skip drive because not used, only one SD_card
; ----------------------------------;
OPN_AntiSlashStartTest              ;
    CMP.B   #'\\',0(rDOCON)         ; "\" as first char ?
    JNZ     OPN_SearchDirSector     ; no
    ADD     #1,rDOCON               ; yes : skip '\' char
; ----------------------------------;
OPN_EndOfStringTest                 ;
; ----------------------------------;
    CMP     rDOCON,TOS              ; PTR = EOS ? (end of pathname ?)
    JZ      OPN_SetCurrentDIR       ; if pathname ptr = end of string
; ----------------------------------;
OPN_SearchDirSector                 ; <=== dir found in path
; ----------------------------------;
    MOV     rDOCON,&PathName_PTR    ; save Pathname ptr
    CALL    #ClusterHLtoFrstSectorHL; output: SectorHL
    MOV     &SecPerClus,rDODOES     ; DIR sectors = one cluster sectors
; ----------------------------------;
OPN_LoadDIRsector                   ; <=== Dir Sector loopback
; ----------------------------------;
    CALL    #ReadSectorHL           ;SWX
; ----------------------------------;
    MOV     #2,S                    ; prepare no such file error
    MOV     #0,W                    ; init entries count
; ----------------------------------;
OPN_SearchDIRentry                  ; <=== DIR Entry loopback
; ----------------------------------;
    MOV     W,Y                     ; 1
    RLAM    #4,Y                    ;             --> * 16
    ADD     Y,Y                     ; 1           --> * 2
    MOV     Y,&DIREntryOfst         ; DIREntryOfst
    CMP.B   #0,SD_BUF(Y)            ; free entry ? (end of entries in DIR)
    JZ      OPN_NoSuchFile          ; error 2 NoSuchFile, used by create ===>
    MOV     #8,X                    ; count of chars in entry name
; ----------------------------------;
OPN_CompareName8chars               ;
; ----------------------------------;
    CMP.B   @rDOCON+,SD_BUF(Y)      ; compare Pathname(char) with DirEntry(char)
    JNZ     OPN_FirstCharMismatch   ;
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     OPN_CompareName8chars   ; loopback if chars 1 to 7 of string and DirEntry are equal
    ADD     #1,rDOCON               ; 9th char of Pathname is always a dot
; ----------------------------------;
OPN_FirstCharMismatch               ;
; ----------------------------------;
    CMP.B   #'.',-1(rDOCON)         ; FirstNotEqualChar of Pathname = dot ?
    JZ      OPN_DotFound            ;
; ----------------------------------;
OPN_DotNotFound                     ;
; ----------------------------------;
    ADD     #3,X                    ; for next cases not equal chars of DIRentry until 11 must be spaces
    CALL    #ParseEntryNameSpaces   ; for X + 3 chars
    JNZ     OPN_DIRentryMismatch    ; if a char entry <> space
    CMP.B   #'\\',-1(rDOCON)        ; FirstNotEqualChar of Pathname = "\" ?
    JZ      OPN_EntryFound          ;
    CMP     rDOCON,TOS              ; EOS exceeded ?
    JNC     OPN_EntryFound          ; yes
; ----------------------------------;
OPN_DIRentryMismatch                ;
; ----------------------------------;
    MOV     &PathName_PTR,rDOCON    ; reload PathName_PTR as it was at last OPN_SearchDirSector
    ADD     #1,W                    ; inc entry
    CMP     #16,W                   ; 16 entries in a sector
    JNZ     OPN_SearchDIRentry      ; ===> loopback for search next DIR entry
; ----------------------------------;
    ADD     #1,&SectorL             ;
    ADDC    #0,&SectorH             ;
    SUB     #1,rDODOES              ; dec count of Dir sectors
    JNZ     OPN_LoadDIRsector       ; ===> loopback for search next DIR sector
; ----------------------------------;
    MOV     #4,S                    ;
    JMP     OPEN_Error              ; ENd of DIR error 4 ===>
; ----------------------------------;

; ----------------------------------;
OPN_DotFound                        ; not equal chars of entry name until 8 must be spaces
; ----------------------------------;
    CMP.B   #'.',-2(rDOCON)         ; LastCharEqual = dot ?
    JZ      OPN_DIRentryMismatch    ; case of first DIR entry = "." and Pathname = "..\"
    CALL    #ParseEntryNameSpaces   ; parse X spaces, X{0,...,7}
    JNZ     OPN_DIRentryMismatch    ; if a char entry <> space
    MOV     #3,X                    ;
; ----------------------------------;
OPN_CompareExt3chars                ;
; ----------------------------------;
    CMP.B   @rDOCON+,SD_BUF(Y)      ; compare string(char) with DirEntry(char)
    JNZ     OPN_ExtNotEqualChar     ;
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     OPN_CompareExt3chars    ; nothing to do if chars equal
    JMP     OPN_EntryFound          ;
OPN_ExtNotEqualChar                 ;
    CMP     rDOCON,TOS              ; EOS exceeded ?
    JC      OPN_DIRentryMismatch    ; no, loop back
    CMP.B   #'\\',-1(rDOCON)        ; FirstNotEqualChar = "\" ?
    JNZ     OPN_DIRentryMismatch    ;
    CALL    #ParseEntryNameSpaces   ; parse X spaces, X{0,...,3}
    JNZ     OPN_DIRentryMismatch    ; if a char entry <> space, loop back
; ----------------------------------;
OPN_EntryFound                      ; Y points on the file attribute (11th byte of entry)
; ----------------------------------;
    MOV     &DIREntryOfst,Y         ; reload DIRentry
    MOV     SD_BUF+26(Y),&ClusterL  ; first clusterL of file
    MOV     SD_BUF+20(Y),&ClusterH  ; first clusterH of file
OPN_EntryFoundNext
    BIT.B   #10h,SD_BUF+11(Y)       ; test if Directory or File
    JZ      OPN_FileFound           ; is a file
; ----------------------------------;
OPN_DIRfound                        ; entry is a DIRECTORY
; ----------------------------------;
    CMP     #0,&ClusterH            ; case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        ;
    CMP     #0,&ClusterL            ; case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        ;
    MOV     #2,&ClusterL            ; set cluster as RootDIR cluster
OPN_DIRfoundNext                    ;
    CMP     rDOCON,TOS              ; EOS reached ?
    JNZ     OPN_SearchDirSector     ; no: (we presume that FirstNotEqualChar = "\") ==> loop back
; ----------------------------------;
OPN_SetCurrentDIR                   ; -- open_type ptr  PathName_PTR is set on name of this DIR
; ----------------------------------;
    MOV     &ClusterL,&DIRClusterL  ;
    MOV     &ClusterH,&DIRclusterH  ;
    MOV     #0,0(PSP)               ; -- open_type ptr      open_type = 0
    JMP     OPN_Dir
; ----------------------------------;
OPN_FileFound                       ; -- open_type ptr  PathName_PTR is set on name of file
; ----------------------------------;
    MOV     @PSP,W                  ;
    CALL    #GetFreeHandle          ;STWXY init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus = HDLL_CurClust,HDLL_CurSize)
; ----------------------------------; output : T = CurrentHdl*, S = ReturnError, Y = DIRentry offset
OPN_NoSuchFile                      ; S = error 2
OPN_Dir                             ;
    MOV     #xdodoes,rDODOES        ;                   restore rDODOES
    MOV     #xdocon,rDOCON          ;                   restore rDODOES
    MOV     @PSP+,W                 ; -- ptr            W = open_type
    MOV     @PSP+,TOS               ; --
; ----------------------------------; then go to selected OpenType subroutine (OpenType = W register)


; ======================================================================
; LOAD" primitive as part of Open_File
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; ======================================================================

; ----------------------------------;
OPEN_QDIR                           ;
; ----------------------------------;
    CMP     #0,W                    ;
    JZ      OPEN_LOAD_END           ; nothing to do
; ----------------------------------;
OPEN_QLOAD                          ;
; ----------------------------------;
    .IFDEF SD_CARD_READ_WRITE       ;
    CMP.B   #-1,W                   ; open_type = LOAD"
    JNZ     OPEN_1W                 ; next step
    .ENDIF                          ;
; ----------------------------------; here W is free
OPEN_LOAD                           ;
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNZ     OPEN_Error              ; no
OPEN_LOAD_END                       ;
    MOV #NOECHO,PC                  ;
;    MOV @IP+,PC                     ;
; ----------------------------------;

; ----------------------------------;
OPEN_Error                          ; S= error
; ----------------------------------;
; Error 1  : PathNameNotFound       ; S = error 1
; Error 2  : NoSuchFile             ; S = error 2
; Error 4  : DIRisFull              ; S = error 4
; Error 8  : alreadyOpen            ; S = error 8
; Error 16 : NomoreHandle           ; S = error 16
; ----------------------------------;
    mDOCOL                          ; set ECHO, type Pathname, type #error, type "< OpenError"; no return
    .word   ECHO                    ;
    .word   XSQUOTE                 ; don't use S register
    .byte   11,"< OpenError"        ;
    .word   BRAN,ABORT_SD           ; to insert S error as flag, no return
; ----------------------------------;

    .IFDEF BOOTLOADER
; to enable bootstrap: BOOT
; to disable bootstrap: NOBOOT

; XBOOT          [SYSRSTIV|USERSTIV] --
; here we are after INIT_FORTH
; performs bootstrap from SD_CARD\BOOT.4th file, ready to test SYSRSTIV|USERSYS value
XBOOT       CALL &HARD_APP          ; WARM first calls HARD_APP (which includes INIT_HARD_SD)
            BIT.B #CD_SD,&SD_CDIN   ; SD_memory in SD_Card socket ?
            JZ BOOT_YES             ; if yes
AbortBoot   MOV #WARM+4,PC          ; if no, resume with WARM+4, without return
; ----------------------------------;
BOOT_YES    MOV #PSTACK-2,PSP       ; preserve SYSRSTIV|USERSYS in TOS for BOOT.4TH tests
            MOV #0,0(PSP)           ; set 0 for next SYS use
            mDOCOL                  ;
    .word XSQUOTE                   ; -- SYSRSTIV|USERSYS addr u
    .byte 15,"LOAD\34 BOOT.4TH\34"  ; LOAD" BOOT.4TH" issues error 2 if no such file...
;    .byte 22,"NOECHO LOAD\34 BOOT.4TH\34"  ; LOAD" BOOT.4TH" issues error 2 if no such file...
    .word BRAN,QUIT4                ; to interpret this string, then loop back to QUIT
; ----------------------------------;

; ==================================;
            FORTHWORD "BOOT"        ; to enable BOOT
; ==================================;
            MOV #XBOOT,&PUCNEXT     ; inserts XBOOT in PUC chain.
            MOV @IP+,PC

; ==================================;
            FORTHWORD "NOBOOT"      ; to disable BOOT
; ==================================;
            MOV #WARM,&PUCNEXT      ; removes XBOOT from PUC chain.
            MOV @IP+,PC             ;
    .ENDIF
