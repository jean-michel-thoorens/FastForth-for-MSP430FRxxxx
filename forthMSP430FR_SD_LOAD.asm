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
    JMP     ReadSectorWX            ;SWX read FAT1SectorW, W = 0
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
    ADD &OrgClusters,X              ;3 OrgClusters = sector of virtual_cluster_0, word size
    ADDC #0,Y                       ;1
    MOV X,&SectorL                  ;3 low result
    MOV Y,&SectorH                  ;3 high result
    POPM  #3,W                      ;5 POPM Y,X,W
; ----------------------------------;32~ + 5~ by 2* shift
    .ENDIF ; MPY
; ----------------------------------;
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
    MOV #4,S                        ; prepare file already open error
    MOV #FirstHandle,T              ;
    MOV #0,X                        ; X = init previous handle as 0
; ----------------------------------;
SearchHandleLoop                    ;
; ----------------------------------;
    CMP.B   #0,HDLB_Token(T)        ; free handle ?
    JZ      FreeHandleFound         ; yes
;AlreadyOpenTest                    ; no
    CMP     &ClusterH,HDLH_FirstClus(T);
    JNE     SearchNextHandle        ;
    CMP     &ClusterL,HDLL_FirstClus(T);
    JZ      OPEN_Error              ; error 4: Already Open abort ===>
SearchNextHandle                    ;
    MOV     T,X                     ; handle is occupied, keep it in X as previous handle
    ADD     #HandleLenght,T         ;
    CMP     #HandleEnd,T            ;
    JNZ     SearchHandleLoop        ;
    MOV     #8,S                    ;
    JMP     OPEN_Error              ; error 8 = no more handle error, abort ===>
; ----------------------------------;
FreeHandleFound                     ; T = new handle, X = previous handle
; ----------------------------------;
    MOV     #0,S                    ; prepare Happy End (no error)
    MOV     T,&CurrentHdl           ;
    MOV     X,HDLW_PrevHDL(T)       ; link to previous handle
; ----------------------------------;
;CheckCaseOfPreviousToken           ;
; ----------------------------------;
    CMP     #0,X                    ; existing previous handle?
    JZ      InitHandle              ; no
    ADD     &TOIN,HDLW_BUFofst(X)   ; in previous handle, add interpret offset to Buffer offset
; ----------------------------------;
;CheckCaseOfLoadFileToken           ;
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
    JZ      HandleRET      	    ;
    JGE HDLCurClusPlsOfst2sectorHL  ; set ClusterHL and SectorHL for all WRITE requests
; ----------------------------------;
    MOV     #0,HDLW_BUFofst(T)      ; < 2, is a READ or a LOAD request
    CMP.B   #-1,W                   ;
    JZ      ReplaceInputBuffer      ; case of first loaded file
    JL      SaveAcceptContext       ; case of other loaded file
    JMP     SetBufLenLoadCurSector  ; case of READ file
; ----------------------------------;
ReplaceInputBuffer                  ;
; ----------------------------------;
    MOV #SDIB_ORG,&CIB_ORG          ; set SD Input Buffer as Current Input Buffer before return to QUIT
    MOV #SD_ACCEPT,&PFAACCEPT       ; redirect ACCEPT to SD_ACCEPT before return to QUIT
; ----------------------------------;
SaveAcceptContext                   ; (see CloseHandle)
; ----------------------------------;
    MOV &SOURCE_LEN,HDLW_PrevLEN(T) ;
    MOV &SOURCE_ORG,HDLW_PrevORG(T) ;
    MOV &TOIN,HDLW_PrevTOIN(T)      ;
    JMP SetBufLenLoadCurSector      ; then RET
; ----------------------------------;


; sequentially load in SD_BUF bytsPerSec bytes of a file opened as read or load
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
    JC      TokenToCloseTest        ; yes because all the file is already read
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
    JMP     ReadSectorWX            ; SWX then RET with W = 0, SR(Z) = 1
; ----------------------------------;


; ==================================;
CloseHandle                         ; <== CLOSE, TERM2SD", OPEN_DEL
; ==================================;
    MOV &CurrentHdl,T               ;
    CMP #0,T                        ; no handle?
    JZ HandleRet               		; RET
; ----------------------------------;
    .IFDEF SD_CARD_READ_WRITE
; ----------------------------------;
    CMP.B #4,HDLB_Token(T)          ; WRITE file ?
    JL TokenToCloseTest             ; no, case of DEL READ LOAD file
;; ----------------------------------; optionnal
;    MOV &BufferPtr,W                ;
;RemFillZero                         ;the remainder of sector
;    CMP     #BytsPerSec,W           ;2 buffer full ?
;    JZ      UpdateWriteSector       ;2 remainding of buffer is full filled with $FF
;    MOV.B   #-1,SD_BUF(W)           ;3
;    ADD     #1,W                    ;1
;    JMP     RemFillZero             ;2
; ----------------------------------;
;UpdateWriteSector                  ; case of any WRITE file
; ----------------------------------;
    CALL #WriteSD_Buf               ;SWX
; ----------------------------------;
;Load Update DirEntry               ;SWXY
; ----------------------------------;
    MOV     HDLL_DIRsect(T),W       ;
    MOV     HDLH_DIRsect(T),X       ;
    CALL    #ReadSectorWX           ;SWX SD_buffer = DIRsector
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
    .ENDIF
; ==================================;
TokenToCloseTest                    ; <== Read_File
; ==================================;
    CMP.B #-1,HDLB_Token(T)         ;
    JZ RestoreDefaultACCEPT         ;
    JL LoadFileToClose              ;
; ----------------------------------;
;CaseOfAnyReadWriteDelFileIsClosed  ; token >= -1
; ----------------------------------;
    JMP CloseHandleRightNow         ; then RET
; ----------------------------------;
RestoreDefaultACCEPT                ;
; ----------------------------------;
    MOV #TIB_ORG,&CIB_ORG           ; restore TIB as Current Input Buffer and..
    MOV #BODYACCEPT,&PFAACCEPT      ; restore default ACCEPT for next line (next loop of QUIT)
; ----------------------------------;
LoadFileToClose                     ; R-- SD_ACCEPT(SDA_InitSrcAddr)
; ----------------------------------;
    MOV #SDA_RetOfCloseHandle,0(RSP); R-- SD_ACCEPT(SDA_RetOfCloseHandle)
; ----------------------------------;
;RestorePreviousContext             ;   ready for the next QUIT loop          
; ----------------------------------;
    MOV HDLW_PrevLEN(T),&SOURCE_LEN ;
    MOV HDLW_PrevORG(T),&SOURCE_ORG ;
    MOV HDLW_PrevTOIN(T),&TOIN      ;
; ----------------------------------;
CloseHandleRightNow                 ;
; ----------------------------------;
    MOV.B #0,HDLB_Token(T)          ; release the handle
    MOV @T,T                        ; T = previous handle
    MOV T,&CurrentHdl               ; becomes current handle
    CMP #0,T                        ; no more handle ?
    JZ HandleRet               		; with SR(Z) = 1
; ----------------------------------;
RestorePreviousLoadedBuffer         ;
; ----------------------------------;
    MOV HDLW_BUFofst(T),&BufferPtr  ; restore previous BufferPtr
    CALL #SetBufLenLoadCurSector    ; then reload previous buffer
    BIC #Z,SR                       ; force SR(Z) = 0
; ----------------------------------;
HandleRet                      		;
; ----------------------------------;
    MOV @RSP+,PC                    ; SR(Z) state is used by SD_ACCEPT(SDA_RetOfCloseHandle)
; ----------------------------------;

; ----------------------------------;
SDA_EOF_IP  .word SDA_EndOfFile     ; defines return address from ECHO|NOECHO to SD_ACCEPT
; ----------------------------------;
SDA_RetOfCloseHandle                ; -- SDIB_org SDIB_end SDIB_ptr   R-- closed_handle      Z = 1 if no more handle
; ----------------------------------;
    MOV #SDA_EOF_IP,IP              ;
    JZ EchoForDefaultAccept         ;
    MOV #NOECHO,PC                  ;
EchoForDefaultAccept                ;
    MOV #ECHO,PC                    ;
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
;OPEN_COMP                          ;
    mDOCOL                          ; if compile state                              R-- LOAD"_return
    .word   lit,lit,COMMA,COMMA     ; compile open_type as literal
    .word   SQUOTE                  ; compile string_exec + string
    .word   lit,ParenOpen,COMMA     ; compile (OPEN)
    .word   EXIT                    ;
; ----------------------------------;
OPEN_EXEC                           ;
    mDOCOL                          ; if exec state
    .word   lit,'"',WORDD,COUNT     ; -- open_type addr cnt
    mNEXTADR                        ;
    MOV     @RSP+,IP                ;
; ----------------------------------;
ParenOpen                           ; -- open_type addr cnt         execution of OPEN_COMP: IP points to OPEN_COMP(EXIT),
; ----------------------------------;                               case of OPEN_EXEC: IP points to INTERPRET(INTLOOP).
    MOV #0,S                        ;
    BIT.B #CD_SD,&SD_CDIN           ;                               SD_memory in SD_Card module ?
    JZ Q_SD_not_init                ;                               yes
    BIC #BUS_SD,&SD_SEL             ;                               no, hide SIMO, SOMI & SCK pins (SD not initialized memory)
Q_SD_not_init                       ;          
    BIT #BUS_SD,&SD_SEL             ;                               is SD init by SYS ? 
    JNZ OPEN_LetUsGo                ;                               no --> with TOS = -1 does abort
    MOV #NO_SD_CARD,PC              ;                               S = 0 --> error 0
; ----------------------------------;
OPEN_LetUsGo                        ;
; ----------------------------------;
    MOV     #1,S                    ;                       error 1
    CMP     #0,TOS                  ;                       cnt = 0 ?
    JZ      OPEN_Error              ;                       yes: error 1 ===>
    MOV     @PSP+,rDOCON            ; -- open_type cnt      rDOCON = addr = pathname PTR
    ADD     rDOCON,TOS              ; -- open_type EOS      TOS = EOS (End Of String) = pathname end
    .IFDEF SD_CARD_READ_WRITE       ;
    MOV     TOS,&PathName_END       ; for WRITE CREATE part
    .ENDIF
    MOV     &DIRClusterL,&ClusterL  ; set DIR cluster
    MOV     &DIRClusterH,&ClusterH  ;
; ----------------------------------;
;OPN_AntiSlashFirstTest              ;
; ----------------------------------;
    CMP.B   #'\\',0(rDOCON)         ; "\" as first char ?
    JNZ     OPN_SearchInDIR         ; no
    ADD     #1,rDOCON               ; yes : skip '\' char
    MOV     #0,&ClusterH            ;
    JMP     OPN_AntiSlashFirstNext  ;
; ----------------------------------;
OPN_SearchInDIR                     ; <=== dir found in path
; ----------------------------------;
    MOV     rDOCON,&PathName_PTR    ; save Pathname ptr
; ----------------------------------;
OPN_LoadDIRcluster                  ; <=== next DIR cluster loopback
; ----------------------------------;
    CALL    #ClusterHLtoFrstSectorHL; output: first Sector of this cluster
    MOV     &SecPerClus,rDODOES     ; set sectors count down
; ----------------------------------;
OPN_LoadDIRsector                   ; <=== next DIR Sector loopback
; ----------------------------------;
    CALL    #ReadSectorHL           ;SWX,
    MOV     #2,S                    ; prepare error 2
; ----------------------------------; W = 0 = DIREntryOfst
OPN_SearchDIRentry                  ; <=== next DIR_Entry loopback
; ----------------------------------;
    MOV     W,&DIREntryOfst         ; update DIREntryOfst
    CMP.B   #0,SD_BUF(W)            ; free entry ?
    JZ      OPN_NoSuchFile          ; NoSuchFile error = 2 ===>
    MOV     W,Y                     ; 1         W = DIREntryOfst, Y = Entry_name pointer
    MOV     #8,X                    ; count of chars in entry name
; ----------------------------------;
OPN_CompareName                     ;
; ----------------------------------;
    MOV.B   @rDOCON+,T              ;
    CMP.B   T,SD_BUF(Y)             ; compare Pathname with DirEntry1to8, char by char
    JNZ     OPN_CompareNameNext     ;
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     OPN_CompareName         ;
    MOV.B   @rDOCON+,T              ; 9th char of Pathname should be '.'
    JZ      OPN_CompareNameDone     ; if X = 0
; ----------------------------------;
OPN_CompareNameNext                 ; remainder of 8 chars of DIR_entry name must be spaces
; ----------------------------------;
    CMP.B   #32,SD_BUF(Y)           ; parse DIR entry up to 8th chars
    JNZ     OPN_DIRentryMismatch    ; if a char of DIR entry name <> space
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     OPN_CompareNameNext     ;
; ----------------------------------;
OPN_CompareNameDone                 ; T = "." or FirstNotEqualChar
; ----------------------------------;
    CMP.B   #'\\',T                 ; FirstNotEqualChar of Pathname = "\" ?
    JZ      OPN_EntryFound          ;
; ----------------------------------;
    MOV     #3,X                    ; to compare 3 char extension
    CMP.B   #'.',T                  ; FirstNotEqualChar of Pathname = dot ?
    JNZ     OPN_CompExtensionNext   ; if not
; ----------------------------------;
OPN_CompareExtension                ;
; ----------------------------------;
    CMP.B   @rDOCON+,SD_BUF(Y)      ; compare Pathname_ext(char) with DirEntry9to11(char)
    JNZ     OPN_CompExtensionNext   ;
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     OPN_CompareExtension    ;
    JZ      OPN_CompExtensionDone   ;
; ----------------------------------;
OPN_CompExtensionNext               ; remainder of 8 chars of DIR_entry extension must be spaces
; ----------------------------------;
    CMP.B   #32,SD_BUF(Y)           ; parse DIR entry up to 11th chars
    JNZ     OPN_DIRentryMismatch    ; if a char of DIR entry extension <> space
    ADD     #1,Y                    ;
    SUB     #1,X                    ;
    JNZ     OPN_CompExtensionNext   ;
; ----------------------------------;
OPN_CompExtensionDone               ;
; ----------------------------------;
    CMP.B   #'.',-2(rDOCON)         ; LastCharEqual = dot ? (case of Pathname = "..\" which matches with first DIR entry = ".")
    JZ      OPN_DIRentryMismatch    ; to compare with 2th DIR entry, the good one.
    CMP     TOS,rDOCON              ; EOS reached ?
    JC      OPN_EntryFound          ; yes
; ----------------------------------;
OPN_DIRentryMismatch                ;
; ----------------------------------;
    MOV     &PathName_PTR,rDOCON    ; reload PathName_PTR as it was at last OPN_SearchInDIR
    ADD     #32,W                   ; W = DIREntryOfst + DIRentrySize
    CMP     #512,W                  ; out of sector bound ?
    JNZ     OPN_SearchDIRentry      ; no, loopback for search next DIR entry in same sector
; ----------------------------------;
    ADD     #1,&SectorL             ;
    ADDC    #0,&SectorH             ;
    SUB     #1,rDODOES              ; count of Dir sectors reached ?
    JNZ     OPN_LoadDIRsector       ; no, loopback to load next DIR sector in same cluster
; ----------------------------------;
    CALL #ClusterHLtoFAT1sectWofstY ; load FATsector in SD_Buffer, set Y = FAToffset
    CMP     #-1,0(Y)                ; last DIR cluster ?
    JNZ     OPN_SetNextDIRcluster   ;
    CMP     #0FFFh,2(Y)             ;
    .IFNDEF SD_CARD_READ_WRITE      ;
    JZ      OPN_NoSuchFile          ; yes, NoSuchFile error = 2 ===>
    .ELSE                           ;
    JNZ     OPN_SetNextDIRcluster   ; no
;OPN_QcreateDIRentry                 ; -- open_type EOS
    CMP     #4,0(PSP)               ;               open type = WRITE" or APPEND" ?
    JNC     OPN_NoSuchFile          ; no: NoSuchFile error = 2 ===>
;OPN_AddDIRcluster                   ; yes
    PUSH    #OPN_LoadDIRcluster     ; as RETurn of GetNewCluster: ===> loopback to load this new DIR cluster
; ==================================;
GetNewCluster                       ; called by Write_File
; ==================================;
    PUSH    Y                       ; push previous FAToffset
    PUSH    W                       ; push previous FATsector
    CALL    #SearchMarkNewClusterHL ;SWXY input: W = FATsector Y = FAToffset, output: ClusterHL, W = FATsector of New cluster
    CMP     @RSP,W                  ; previous and new clusters are in same FATsector?
    JZ      LinkClusters            ;     yes
; ----------------------------------;
;UpdateNewClusterFATs                ;
; ----------------------------------;
    MOV     @RSP,W                  ; W = previous FATsector
    CALL    #ReadFAT1SectorW        ;SWX  reload previous FATsector in buffer to link clusters
; ----------------------------------;
LinkClusters                        ;
; ----------------------------------;
    MOV     @RSP+,W                 ; W = previous FATsector
    MOV     @RSP+,Y                 ; Y = previous FAToffset
    MOV     &ClusterL,SD_BUF(Y)     ; store new cluster to current cluster address in previous FATsector buffer
    MOV     &ClusterH,SD_BUF+2(Y)   ;
    JMP     SaveSectorWtoFATs       ;SWXY update FATs from SD_BUF to W = previous FATsector, then RET
; ==================================;
    .ENDIF ; SD_CARD_READ_WRITE     ;
; ----------------------------------;
OPN_SetNextDIRcluster               ;
; ----------------------------------;
    MOV     @Y+,&ClusterL           ;
    MOV     @Y,&ClusterH            ;
    JMP     OPN_LoadDIRcluster      ; ===> loop back to load this new DIR cluster
; ----------------------------------;

; ----------------------------------;
OPN_EntryFound                      ; Y points on the file attribute (11th byte of entry)
; ----------------------------------;
;    MOV     W,&DIREntryOfst         ;
    MOV     SD_BUF+14H(W),&ClusterH ; first clusterH of file
    MOV     SD_BUF+1Ah(W),&ClusterL ; first clusterL of file
    BIT.B   #10h,SD_BUF+0Bh(W)      ; test if Directory or File
    JZ      OPN_FileFound           ; is a file
; ----------------------------------;
;OPN_DIRfound                        ; entry is a DIRECTORY
; ----------------------------------;
    CMP     #0,&ClusterH            ; case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        ;
    CMP     #0,&ClusterL            ; case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        ;
OPN_AntiSlashFirstNext
    MOV     #2,&ClusterL            ; set clusterL as RootDIR cluster
OPN_DIRfoundNext                    ;
    CMP     TOS,rDOCON              ; EOS reached ?
    JNC     OPN_SearchInDIR         ; no: (rDOCON points after "\") ==> loop back
; ----------------------------------;
;OPN_SetCurrentDIR                   ; -- open_type ptr  PathName_PTR is set on name of this DIR
; ----------------------------------;
    MOV     &ClusterL,&DIRClusterL  ;
    MOV     &ClusterH,&DIRclusterH  ;
    MOV     #0,0(PSP)               ; -- open_type ptr      set open_type = 0 = DIR
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
    CMP     #0,W                    ;
    JNZ     OPEN_QLOAD              ;
    MOV @IP+,PC                     ; nothing else to do
; ----------------------------------;


; ======================================================================
; LOAD" primitive as part of Open_File
; input from open:  S = OpenError, W = open_type, SectorHL = DIRsectorHL,
;                   Buffer = [DIRsector], ClusterHL = FirstClusterHL
;       from open(GetFreeHandle): Y = DIRentry, T = CurrentHdl
; output: nothing else abort on error
; ======================================================================

; ----------------------------------;
OPEN_QLOAD                          ;
; ----------------------------------;
    .IFDEF SD_CARD_READ_WRITE       ;
    CMP.B   #-1,W                   ; open_type = LOAD"
    JNZ     OPEN_1W                 ; next step
    .ENDIF                          ;
; ----------------------------------; here W is free
;OPEN_LOAD                           ;
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNZ     OPEN_Error              ; no
    MOV #NOECHO,PC                  ; return to QUIT5 then SD_ACCEPT
;    MOV @IP+,PC                     ;
; ----------------------------------;

; ----------------------------------;
OPEN_Error                          ; S= error
; ----------------------------------;
; Error 1  : PathNameNotFound       ; S = error 1
; Error 2  : NoSuchFile             ; S = error 2
; Error 4  : alreadyOpen            ; S = error 4
; Error 8  : NomoreHandle           ; S = error 8
; ----------------------------------;
    MOV #SD_CARD_FILE_ERROR,PC      ;
; ----------------------------------;

; to enable bootstrap: BOOT
; to disable bootstrap: NOBOOT

; XBOOT          [SYSRSTIV|USERSTIV] --
; here we are after INIT_FORTH
; performs bootstrap from SD_CARD\BOOT.4th file, ready to test SYSRSTIV|USERSYS value
XBOOT       CALL &HARD_APP          ; WARM first calls HARD_APP (which includes INIT_HARD_SD)
            MOV #PSTACK-2,PSP       ; preserve SYSRSTIV|USERSYS in TOS for BOOT.4TH tests
            MOV #0,0(PSP)           ; set TOS = 0 for the next of XBOOT
            mASM2FORTH              ;
            .word XSQUOTE           ; -- SYSRSTIV|USERSYS addr u
            .byte 15,"LOAD\34 BOOT.4TH\34"  ; LOAD" BOOT.4TH" issues error 2 if no such file...
            .word BRAN,QUIT4        ; to interpret this string, then loop back to QUIT1/QUIT2
; ----------------------------------;

; ==================================;
            FORTHWORD "BOOT"        ; to enable BOOT
; ==================================;
            MOV #XBOOT,&PUCNEXT     ; inserts XBOOT in PUC chain.
            MOV @IP+,PC

; ==================================;
            FORTHWORD "NOBOOT"      ; to disable BOOT
; ==================================;
NOBOOT      MOV #WARM,&PUCNEXT      ; removes XBOOT from PUC chain.
            MOV @IP+,PC             ;
