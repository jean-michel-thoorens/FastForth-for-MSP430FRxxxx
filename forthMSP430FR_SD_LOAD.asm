; -*- coding: utf-8 -*-
; forthMSP430FR_SD_LOAD.asm

; Tested with MSP-EXP430FR5969 launchpad
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


; used variables : BufferPtr, BufferLen

;-----------------------------------------------------------------------
; SD card OPEN, LOAD subroutines
;-----------------------------------------------------------------------

; rules for registers use
; S = error
; T = CurrentHdl, pathname
; W = SectorL, (RTC) TIME
; X = SectorH, (RTC) DATE
; Y = BufferPtr, (DIR) EntryOfst, FAToffset


; ----------------------------------;
HDLCurClusToFAT1sectWofstY          ;WXY Input: T=currentHandle, Output: W=FATsector, Y=FAToffset, Cluster=HDL_CurCluster
; ----------------------------------;
    MOV HDLL_CurClust(T),&ClusterL  ;
    MOV HDLH_CurClust(T),&ClusterH  ;
; ----------------------------------;
ClusterToFAT1sectWofstY             ;WXY Input : Cluster ; Output: W = FATsector, Y = FAToffset
; ----------------------------------;
    MOV.B   &ClusterL+1,W           ;3 W = ClusterLoHI
    MOV.B   &ClusterL,Y             ;3 Y = ClusterLoLo
    CMP     #1,&FATtype             ;3 FAT16?
    JZ      CTF1S_end               ;2 yes

; input : Cluster n, max = 7FFFFF (SDcard up to 256 GB)
; ClusterLoLo*4 = displacement in 512 bytes sector   ==> FAToffset
; ClusterHiLo&ClusterLoHi +C  << 1 = relative FATsector + orgFAT1       ==> FATsector
; ----------------------------------;
    MOV.B   &ClusterH,X             ;  X = 0:ClusterHiLo
    SWPB    X                       ;  X = ClusterHiLo:0
    ADD     X,W                     ;  W = ClusterHiLo:ClusterLoHi  
; ----------------------------------;
    SWPB    Y                       ;  Y = ClusterLoLo:0
    ADD     Y,Y                     ;1 Y = ClusterLoLo:0 << 1 + carry for FATsector
    ADDC    W,W                     ;  W = ClusterHiLo:ClusterLoHi << 1 = ClusterHiLo:ClusterL / 128
    SWPB    Y
CTF1S_end
    ADD     Y,Y                     ;  Y = 0:ClusterLoLo << 1
    RET                             ;4
; ----------------------------------;


; use no registers
; ----------------------------------; Input : Cluster, output: Sector = Cluster_first_sector
ComputeClusFrstSect                 ; If Cluster = 1 ==> RootDirectory ==> SectorL = OrgRootDir
; ----------------------------------; Output: SectorL of Cluster
    MOV     #0,&SectorH             ;
    MOV     &OrgRootDir,&SectorL    ;
    CMP.B   #0,&ClusterH            ; clusterH <> 0 ?
    JNE     CCFS_AllOthers          ; yes
    CMP     #1,&ClusterL            ; clusterHL = 1 ? (FAT16 specificity)
    JZ      CCFS_RET                ; yes, sectorL for FAT16 OrgRootDIR is done
CCFS_AllOthers                      ;
; ----------------------------------;
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
; ----------------------------------; Cluster24<<SecPerClus{1,2,4,8,16,32,64} --> ClusFrstSect
;    .word 0152Ah                    ;6 PUSHM W,X,Y
    PUSHM  #3,W
    MOV.B &SecPerClus,W             ;3 SecPerClus(5-1) = multiplicator
    MOV &ClusterL,X                 ;3 Cluster(16-1) --> MULTIPLICANDlo
    MOV.B &ClusterH,Y               ;3 Cluster(21-17) -->  MULTIPLICANDhi
;    RRA W                           ;1 bit1 test
;    JC  CCFS_NEXT                   ;2 case of SecPerClus=1
    JMP CCFS_ENTRY
CCFS_LOOP                           ;
    ADD X,X                         ;1 (RLA) shift one left MULTIPLICANDlo16
    ADDC Y,Y                        ;1 (RLC) shift one left MULTIPLICANDhi8
CCFS_ENTRY
    RRA W                           ;1 shift one right multiplicator
    JNC CCFS_LOOP                   ;2 C = 0 loop back
CCFS_NEXT                           ;  C = 1, it's done
    ADD &OrgClusters,X              ;3 OrgClusters = sector of virtual cluster 0, word size
    ADDC #0,Y                       ;1
    MOV X,&SectorL                  ;3 low result
    MOV Y,&SectorH                  ;3 high result
;    .word 01728h                    ;6 POPM Y,X,W
    POPM  #3,W
; ----------------------------------;34~ + 5~ by loop
    .ENDIF ; MPY
; ----------------------------------;
CCFS_RET                            ;
    RET                             ;
; ----------------------------------;


; ----------------------------------;
ComputeHDLcurrentSector             ; input: currentHandle, output: Cluster, Sector
; ----------------------------------;
    MOV   HDLL_CurClust(T),&ClusterL;
    MOV   HDLH_CurClust(T),&ClusterH;
    CALL  #ComputeClusFrstSect      ;
    MOV.B   HDLB_ClustOfst(T),W     ;
    ADD     W,&SectorL              ;
    ADDC    #0,&SectorH             ;
    RET                             ;
; ----------------------------------;




; ----------------------------------; input : X = countdown_of_spaces, Y = name pointer in buffer
ParseEntryNameSpaces                ;XY
; ----------------------------------; output: Z flag, Y is set after the last space char
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
    RET                             ; 
; ----------------------------------; 


; sequentially load in SD_BUF bytsPerSec bytes of a file opened as read or as load
; if previous bufferLen had a size < bytsPerSec, closes the file.
; if new bufferLen have a size <= BufferPtr, closes the file.
; reload previous LOADed file if exist.
; HDLL_CurSize leaves the not yet read size 
; All used registers must be initialized. 
; ==================================;
Read_File                           ; <== SD_ACCEPT, READ
; ==================================;
    MOV     &CurrentHdl,T           ;
    MOV     #0,&BufferPtr           ; reset BufferPtr (the buffer is already read)
    CMP     #bytsPerSec,&BufferLen  ;
    JNZ     CloseHandleT            ; because this last and incomplete sector is already read
    SUB #bytsPerSec,HDLL_CurSize(T) ; HDLL_CurSize is decremented of one sector lenght
    SUBC    #0,HDLH_CurSize(T)      ;
    ADD.B   #1,HDLB_ClustOfst(T)    ; current cluster offset is incremented
    CMP.B &SecPerClus,HDLB_ClustOfst(T) ; Cluster Bound reached ?
    JLO SetBufLenAndLoadCurSector   ; no
; ----------------------------------;
;SearchNextCluster                  ; yes
; ----------------------------------;
    MOV.B   #0,HDLB_ClustOfst(T)    ; reset Current_Cluster sectors offset
    CALL #HDLCurClusToFAT1sectWofstY;WXY  Output: W=FATsector, Y=FAToffset, Cluster=HDL_CurCluster
    CALL    #ReadFAT1SectorW        ;SWX (< 65536)
    MOV     #0,HDLH_CurClust(T)     ;
    MOV SD_BUF(Y),HDLL_CurClust(T)  ;
    CMP     #1,&FATtype             ; FAT16?
    JZ SetBufLenAndLoadCurSector    ;
    MOV SD_BUF+2(Y),HDLH_CurClust(T);
; ==================================;
SetBufLenAndLoadCurSector           ;WXY <== previous handle reLOAD
; ==================================;
    MOV     #bytsPerSec,&BufferLen  ; preset BufferLen
    CMP     #0,HDLH_CurSize(T)      ; CurSize > 65535 ?
    JNZ     LoadHDLcurrentSector    ; yes
    CMP HDLL_CurSize(T),&BufferPtr  ; BufferPtr >= CurSize ? (BufferPtr = 0 or see RestorePreviousLoadedFileContext)
    JHS      CloseHandleT           ; yes
    CMP #bytsPerSec,HDLL_CurSize(T) ; CurSize >= 512 ?
    JHS     LoadHDLcurrentSector    ; yes
    MOV HDLL_CurSize(T),&BufferLen  ; no: adjust BufferLen
; ==================================;
LoadHDLcurrentSector                ; <=== OPEN_WRITE_APPEND
; ==================================;
    CALL #ComputeHDLcurrentSector   ; use no registers
; ==================================;
ReadSector                          ;
; ==================================;
    MOV     &SectorL,W              ; Low
    MOV     &SectorH,X              ; High
    JMP     ReadSectorWX            ; then RET
; ----------------------------------;


; if first open_load token, save DefaultInputStream
; if other open_load token, decrement token, save previous context

; OPEN subroutine
; Input : EntryOfst, Cluster = EntryOfst(HDLL_FirstClus())
; init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus,HDLL_CurClust,HDLL_CurSize)
; Output: Cluster = first Cluster of file, X = CurrentHdl
; ----------------------------------; input : Cluster, EntryOfst
GetFreeHandle                       ;STWXY init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus = HDLL_CurClust,HDLL_CurSize)
; ----------------------------------; output : T = new CurrentHdl
    MOV     #8,S                    ; prepare file already open error
    MOV     #FirstHandle,T          ;
    MOV     #0,X                    ; X = init previous handle as 0
; ----------------------------------;
SearchHandleLoop                    ;
; ----------------------------------;
    CMP.B   #0,HDLB_Token(T)        ; free handle ?
    JZ      FreeHandleFound         ; yes
AlreadyOpenTest                     ; no
    CMP     &ClusterH,HDLH_FirstClus(T);
    JNE     SearchNextHandle        ;
    CMP     &ClusterL,HDLL_FirstClus(T);
    JZ      InitHandleRET           ; error 8: Already Open abort ===> 
SearchNextHandle                    ;
    MOV     T,X                     ; handle is occupied, keep it in X as previous handle
    ADD     #HandleLenght,T         ;
    CMP     #HandleEnd,T            ;
    JNZ     SearchHandleLoop        ;
    ADD     S,S                     ; 16 = no more handle error, abort ===>
InitHandleRET                       ;
    RET                             ;
; ----------------------------------;
FreeHandleFound                     ; T = new handle, X = previous handle
; ----------------------------------;
    MOV     #0,S                    ; prepare Happy End (no error)
    MOV     T,&CurrentHdl           ;
    MOV     X,HDLW_PrevHDL(T)       ; link to previous handle
; ----------------------------------;
CheckCaseOfLoadFileToken            ;
; ----------------------------------;
    CMP.B   #0,X                    ; existing previous handle?
    JZ      InitHandle              ; no
    ADD     &TOIN,HDLW_BUFofst(X)   ; in previous handle, add interpret offset to Buffer offset
    CMP.B   #0,W                    ; open_type is LOAD (-1) ?
    JGE     InitHandle              ; W>=0, no
    CMP.B   #0,HDLB_Token(X)        ; previous token is negative? (open_load type)
    JGE     InitHandle              ; no
    ADD.B   HDLB_Token(X),W         ; LOAD token = previous LOAD token -1
; ----------------------------------;
InitHandle                          ;
; ----------------------------------;
    MOV.B   W,HDLB_Token(T)         ; marks handle as open type: <0=LOAD, 1=READ, 2=WRITE, 4=DEL
    MOV.B   #0,HDLB_ClustOfst(T)    ; clear ClustOfst
    MOV     &SectorL,HDLL_DIRsect(T); init handle DIRsectorL
    MOV     &SectorH,HDLH_DIRsect(T); 
    MOV     &EntryOfst,Y            ;
    MOV     Y,HDLW_DIRofst(T)       ; init handle SD_BUF offset of DIR entry
    MOV SD_BUF+26(Y),HDLL_FirstClus(T); init handle firstcluster of file (to identify file)
    MOV SD_BUF+20(Y),HDLH_FirstClus(T)
    MOV SD_BUF+26(Y),HDLL_CurClust(T)  ; init handle CurrentCluster
    MOV SD_BUF+20(Y),HDLH_CurClust(T) 
    MOV SD_BUF+28(Y),HDLL_CurSize(T); init handle LOW currentSizeL
    MOV SD_BUF+30(Y),HDLH_CurSize(T);
    MOV     #0,&BufferPtr           ; reset BufferPtr all type of files
    CMP.B   #2,W                    ; is a WRITE file handle?
    JZ      ComputeHDLcurrentSector ; = 2, is a WRITE file
    JGE     InitHandleRET           ; > 2, is a file to be deleted
    MOV     #0,HDLW_BUFofst(T)      ; < 2, is a READ or a LOAD file
    CMP.B   #-1,W                   ;
    JZ      ReplaceInputBuffer      ; case of first loaded file
    JL      SaveBufferContext       ; case of other loaded file
    JMP SetBufLenAndLoadCurSector   ; case of READ file
; ----------------------------------;
ReplaceInputBuffer                  ;
; ----------------------------------;
    MOV     #SDIB_ORG,&FCIB+2       ; set SD Input Buffer as Current Input Buffer before return to QUIT
    MOV     #SD_ACCEPT,&ACCEPT+2    ; redirect ACCEPT to SD_ACCEPT before return to QUIT
    MOV     #LOAD_STACK,&LOADPTR    ; init LOADPTR
; ----------------------------------;
SaveBufferContext                   ;           CPL is same, not saved
; ----------------------------------;
    MOV     &LOADPTR,Y              ;
    ADD     #6,&LOADPTR             ;
    MOV     &TOIN,X                 ;3 X = >IN (pointing after the file to load filename)
    MOV     &SOURCE_LEN,W           ;3 W = CPL
    SUB     X,W                     ;1 W = CPL - >IN
    MOV     W,0(Y)                  ;3 save remaining lenght to be interpreted (see CloseHandleT) 
    ADD     &SOURCE_ADR,X           ;3 X = CIB + >IN
    MOV     X,2(Y)                  ;5 save ORG
    MOV     IP,4(Y)                 ;3 save IP
    JMP SetBufLenAndLoadCurSector   ;           then RET
; ----------------------------------;


; ==================================;
CloseHandleT                        ; <== CLOSE, Read_File, TERM2SD", OPEN_DEL
; ==================================;
    MOV     &CurrentHdl,T           ;
    CMP     #0,T                    ; no handle?
    JZ      InitHandleRET           ; RET
; ----------------------------------;
    .IFDEF SD_CARD_READ_WRITE
    CMP.B   #2,HDLB_Token(T)        ; open as write (updated) file ?
    JNZ     CloseHandleHere         ; no
    CALL    #WriteBuffer            ;SWXY
    CALL    #OPWW_UpdateDirectory   ;SWXY
    .ENDIF                          ;
; ----------------------------------;
CloseHandleHere                     ;
; ----------------------------------;
    MOV.B   HDLB_Token(T),W         ; to test W=token below
    MOV.B   #0,HDLB_Token(T)        ; close handle
; ----------------------------------;
    MOV     T,X                     ; X = closed handle
    MOV     @T,T                    ; T = previous handle
    MOV     T,&CurrentHdl           ; becomes current handle
; ----------------------------------;
CheckCaseOfCloseLoadedFile          ;
; ----------------------------------;
    CMP.B   #-1,W                   ;
    JNZ     CheckPreviousLoadedFile ;
; ----------------------------------;
RestorePreviousBuffer               ; W=-1: this LOADed file to close had not a parent file
; ----------------------------------;
    MOV     #TIB_ORG,&FCIB+2        ;     restore TIB as Current Input Buffer for next line (next QUIT)
    MOV     #BODYACCEPT,&ACCEPT+2   ;     restore (ACCEPT) for next line (next QUIT)
    JMP     RestoreBufferContext    ;
; ----------------------------------;
CheckPreviousLoadedFile             ;
; ----------------------------------;
    CMP     #0,T                    ; previous handle ?
    JZ      InitHandleRET           ; no
    CMP.B   #0,HDLB_Token(T)        ; test previous handle token
    JGE     InitHandleRET           ; case of READ, WRITE, DEL without previous loaded file
; ----------------------------------;
RestorePreviousLoadedFileContext    ; here the calling routine is always SD_ACCEPT
; ----------------------------------;
    MOV HDLW_BUFofst(T),&BufferPtr  ; restore previous BufferPtr
    CALL #SetBufLenAndLoadCurSector ;
; ----------------------------------;
RestoreBufferContext                ; -- org CPL len'   R-- CIB_PTR RET_to_SD_ACCEPT
; ----------------------------------;
    ADD     #4,RSP                  ;                   remove RET_to_SD_ACCEPT and CIB ptr from return stack
    ADD     #2,PSP                  ; -- org len'       current values
; ----------------------------------;
    SUB     #6,&LOADPTR             ;
    MOV     &LOADPTR,W              ;
    MOV     @W+,TOS                 ;
    MOV     @W+,0(PSP)              ; -- org len'       previous values
    MOV     @W+,IP                  ;
    mNEXT                           ;                   return to interpret
; ----------------------------------;


    .IFDEF SD_CARD_READ_WRITE

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

; ----------------------------------;
    FORTHWORDIMM "READ\34"          ; immediate
; ----------------------------------;
READDQ
    MOV.B   #1,W                    ; W = OpenType
    JMP     Open_File               ;
; ----------------------------------;

;Z WRITE" pathame"   --       immediate
; open or create the file designed by pathname.
; an error occurs if the file is already opened.
; the last sector of the file is loaded in buffer, and bufferPtr leave the address of the first free byte.
; compile state : compile WRITE" pathname"
; exec state : open or create entry selected by pathname
; ----------------------------------;
    FORTHWORDIMM "WRITE\34"         ; immediate
; ----------------------------------;
WRITEDQ
    MOV.B   #2,W                    ; W = OpenType
    JMP     Open_File               ;
; ----------------------------------;


;Z DEL" pathame"   --       immediate
; compile state : compile DEL" pathname"
; exec state : DELETE entry selected by pathname

; ----------------------------------;
    FORTHWORDIMM "DEL\34"           ; immediate
; ----------------------------------;
DELDQ
    MOV.B   #4,W                    ; W = OpenType
    JMP     Open_File               ;
; ----------------------------------;


;Z CLOSE      --     
; close current handle
; ----------------------------------;
    FORTHWORD "CLOSE"               ;
; ----------------------------------;
    CALL    #CloseHandleT           ;
    mNEXT                           ;
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

; ----------------------------------;
    FORTHWORDIMM "LOAD\34"          ; immediate
; ----------------------------------;
    MOV.B   #-1,W                   ; W = OpenType
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
; ----------------------------------;
Open_File                           ; --
; ----------------------------------;
    SUB     #2,PSP                  ;
    MOV     TOS,0(PSP)              ;
    MOV     W,TOS                   ; -- Open_type (0=LOAD", 1=READ", 2=WRITE", 4=DEL")
    CMP     #0,&STATE               ;
    JZ      OPEN_EXEC               ;
; ----------------------------------;
OPEN_COMP                           ;
    mDOCOL                          ; if compile state
    .word   lit,lit,COMMA,COMMA     ; compile open_type as literal
    .IFDEF LOWERCASE                ;
    .word   CAPS_ON                 ;
    .ENDIF                          ;
    .word   SQUOTE                  ; compile string_exec + string
    .word   lit,ParenOpen,COMMA     ; compile (OPEN)
    .word   EXIT                    ;
; ----------------------------------;
OPEN_EXEC                           ;
    mDOCOL                          ; if exec state
    .word   lit,'"',WORDD,COUNT     ; -- open_type addr u
    FORTHtoASM                      ;
    MOV     @RSP+,IP                ;
; ----------------------------------;
ParenOpen                           ; -- open_type HERE             HERE as pathname ptr
; ----------------------------------;
    MOV     @PSP+,rDOCON            ; rDOCON = addr = pathname PTR
    ADD     rDOCON,TOS              ; TOS = EOS (End Of String) = pathname end
    .IFDEF SD_CARD_READ_WRITE       ;
    MOV     TOS,&EndOfPath          ; for WRITE CREATE part
    .ENDIF
; ----------------------------------;
OPN_PathName                        ;
; ----------------------------------;
    MOV     #1,S                    ; error 1
    MOV     &DIRClusterL,&ClusterL  ;
    MOV     &DIRclusterH,&ClusterH  ;
    CMP     rDOCON,TOS              ; PTR = EOS ? (end of pathname ?)
    JZ      OPN_NoPathName          ; yes: error 1 ===>
; ----------------------------------;
    CMP.B   #':',1(rDOCON)          ; A: B: C: ... in pathname ?
    JNZ     OPN_AntiSlashStartTest  ; no
    ADD     #2,rDOCON               ; yes : skip drive because not used, only one SD_card
; ----------------------------------;
OPN_AntiSlashStartTest              ;
    CMP.B   #'\\',0(rDOCON)          ; "\" as first char ?
    JNZ     OPN_SearchDirSector     ; no
    ADD     #1,rDOCON               ; yes : skip '\' char
    MOV     &FATtype,&ClusterL      ;       FATtype = 1 as FAT16 RootDIR, FATtype = 2 = FAT32RootDIR
    MOV     #0,&ClusterH            ;
; ----------------------------------;
OPN_EndOfStringTest                 ; <=== dir found in path
; ----------------------------------;
    CMP     rDOCON,TOS              ; PTR = EOS ? (end of pathname ?)
    JZ      OPN_SetCurrentDIR       ; yes
; ----------------------------------;
OPN_SearchDirSector                 ;
; ----------------------------------;
    MOV     rDOCON,&Pathname        ; save Pathname ptr
    CALL    #ComputeClusFrstSect    ; output: SectorHL
    MOV     #32,rDODOES             ; preset countdown for FAT16 RootDIR sectors
    CMP     #2,&FATtype             ; FAT32?
    JZ      OPN_SetDirSectors       ; yes
    CMP     &ClusterL,&FATtype      ; FAT16 AND RootDIR ?
    JZ      OPN_LoadDIRsector       ; yes
OPN_SetDirSectors                   ;
    MOV     &SecPerClus,rDODOES     ;
; ----------------------------------;
OPN_LoadDIRsector                   ; <=== Dir Sector loopback
; ----------------------------------;
    CALL    #ReadSector             ;SWX
; ----------------------------------;
    MOV     #2,S                    ; prepare no such file error
    MOV     #0,W                    ; init entries count
; ----------------------------------;
OPN_SearchDIRentry                  ; <=== DIR Entry loopback
; ----------------------------------;
    MOV     W,Y                     ; 1
;    .word   0E58h                   ; 5 RLAM #4,Y --> * 16
    RLAM.W  #4,Y
    ADD     Y,Y                     ; 1           --> * 2
    MOV     Y,&EntryOfst            ; EntryOfst points to first free entry
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
    CMP.B   #'.',-1(rDOCON)         ; FirstNotEqualChar of Pathname = dot ?
    JZ      OPN_DotFound            ;
; ----------------------------------;
OPN_DotNotFound                     ; 
; ----------------------------------;
    ADD     #3,X                    ; for next cases not equal chars of entry until 11 must be spaces
    CALL    #ParseEntryNameSpaces   ; for X + 3 chars
    JNZ     OPN_DIRentryMismatch    ; if a char entry <> space  
    CMP.B   #'\\',-1(rDOCON)        ; FirstNotEqualChar of Pathname = "\" ?
    JZ      OPN_EntryFound          ;
    CMP     rDOCON,TOS              ; EOS exceeded ?
    JLO     OPN_EntryFound          ; yes
; ----------------------------------;
OPN_DIRentryMismatch                ;
; ----------------------------------;
    MOV     &pathname,rDOCON        ; reload Pathname
    ADD     #1,W                    ; inc entry
    CMP     #16,W                   ; 16 entry in a sector
    JNZ     OPN_SearchDIRentry      ; ===> loopback for search next DIR entry
; ----------------------------------;
    ADD     #1,&SectorL             ;
    ADDC    #0,&SectorH             ;
    SUB     #1,rDODOES              ; dec count of Dir sectors
    JNZ     OPN_LoadDIRsector       ; ===> loopback for search next DIR sector
; ----------------------------------;
    MOV     #4,S                    ;
    JMP     OPN_EndOfDIR            ; error 4 ===> 
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
    JHS     OPN_DIRentryMismatch    ; no, loop back   
    CMP.B   #'\\',-1(rDOCON)        ; FirstNotEqualChar = "\" ?
    JNZ     OPN_DIRentryMismatch    ;
    CALL    #ParseEntryNameSpaces   ; parse X spaces, X{0,...,3}
    JNZ     OPN_DIRentryMismatch    ; if a char entry <> space, loop back
; ----------------------------------;
OPN_EntryFound                      ; Y points on the file attribute (11th byte of entry)
; ----------------------------------;
    MOV     &EntryOfst,Y            ; reload DIRentry
    MOV     SD_BUF+26(Y),&ClusterL  ; first clusterL of file
    MOV     SD_BUF+20(Y),&ClusterH  ; first clusterT of file, always 0 if FAT16
OPN_EntryFoundNext
    BIT.B   #10h,SD_BUF+11(Y)       ; test if Directory or File
    JZ      OPN_FileFound           ;
; ----------------------------------;
OPN_DIRfound                        ; entry is a DIRECTORY
; ----------------------------------;
    CMP     #0,&ClusterH            ; case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        ;
    CMP     #0,&ClusterL            ; case of ".." entry, when parent directory is root
    JNZ     OPN_DIRfoundNext        ;
    MOV     &FATtype,&ClusterL      ; set cluster as RootDIR cluster
OPN_DIRfoundNext                    ;
    CMP     rDOCON,TOS              ; EOS exceeded ?
    JHS     OPN_EndOfStringTest     ; no: (we presume that FirstNotEqualChar = "\") ==> loop back
; ----------------------------------;
OPN_SetCurrentDIR                   ; -- open_type ptr
; ----------------------------------;
    MOV     &ClusterL,&DIRClusterL  ;
    MOV     &ClusterH,&DIRclusterH  ;
    MOV     #0,0(PSP)               ; -- open_type ptr      open_type = 0 
    JMP     OPN_Dir
; ----------------------------------;
OPN_FileFound                       ; -- open_type ptr
; ----------------------------------;
    MOV     @PSP,W                  ;   
    CALL    #GetFreeHandle          ;STWXY init handle(HDLL_DIRsect,HDLW_DIRofst,HDLL_FirstClus = HDLL_CurClust,HDLL_CurSize)
; ----------------------------------; output : T = CurrentHdl*, S = ReturnError, Y = DIRentry offset
OPN_NomoreHandle                    ; S = error 16
OPN_alreadyOpen                     ; S = error 8
OPN_EndOfDIR                        ; S = error 4
OPN_NoSuchFile                      ; S = error 2
OPN_NoPathName                      ; S = error 1
OPN_Dir
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
    JNZ     OPEN_QREAD              ; next step
    .ENDIF                          ;
; ----------------------------------; here W is free
OPEN_LOAD                           ;
; ----------------------------------;
    CMP     #0,S                    ; open file happy end ?
    JNZ     OPEN_Error              ; no
    MOV     @RSP+,IP                ; return to sender (QUIT) to get new line.
OPEN_LOAD_END
    mNEXT                           ;
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
    .word   XSQUOTE                 ;
    .byte   11,"< OpenError"        ;
SD_ERROR
    .word   ECHO                    ;
    .word   HERE,COUNT,TYPE,SPACE   ;
    .word   BRAN,SD_QABORTYES       ; to insert S error as flag, no return
; ----------------------------------;







