; -*- coding: utf-8 -*-
; http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
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


    .IFNDEF UTILITY

    .IFNDEF ANS_CORE_COMPLIANT

;https://forth-standard.org/standard/core/MAX
;C MAX    n1 n2 -- n3       signed maximum
            FORTHWORD "MAX"
MAX:        CMP     @PSP,TOS    ; n2-n1
            JL      SELn1       ; n2<n1
SELn2:      ADD     #2,PSP
            mNEXT

;https://forth-standard.org/standard/core/MIN
;C MIN    n1 n2 -- n3       signed minimum
            FORTHWORD "MIN"
MIN:        CMP     @PSP,TOS    ; n2-n1
            JL      SELn2       ; n2<n1
SELn1:      MOV     @PSP+,TOS
            mNEXT

    .ENDIF ;  ANS_CORE_COMPLIANT

;https://forth-standard.org/standard/core/UDotR
;X U.R      u n --      display u unsigned in n width
            FORTHWORD "U.R"
UDOTR       mDOCOL
            .word   TOR,LESSNUM,lit,0,NUM,NUMS,NUMGREATER
            .word   RFROM,OVER,MINUS,lit,0,MAX,SPACES,TYPE
            .word   EXIT

;https://forth-standard.org/standard/tools/DUMP
            FORTHWORD "DUMP"
DUMP        PUSH    IP
            PUSH    &BASE
            MOV     #10h,&BASE
            ADD     @PSP,TOS                ; compute end address
            AND     #0FFF0h,0(PSP)          ; compute start address
            ASMtoFORTH
            .word   SWAP,xdo                ; generate line
DUMP1       .word   CR
            .word   II,lit,7,UDOTR,SPACE    ; generate address
            .word   II,lit,10h,PLUS,II,xdo  ; display 16 bytes
DUMP2       .word   II,CFETCH,lit,3,UDOTR
            .word   xloop,DUMP2
            .word   SPACE,SPACE
            .word   II,lit,10h,PLUS,II,xdo  ; display 16 chars
DUMP3       .word   II,CFETCH
            .word   lit,7Eh,MIN,FBLANK,MAX,EMIT
            .word   xloop,DUMP3
            .word   lit,10h,xploop,DUMP1
            .word   RFROM,FBASE,STORE
            .word   EXIT

    .ENDIF ; UTILITY

    FORTHWORD "{SD_TOOLS}"
    mNEXT

; read logical sector and dump it 
; ----------------------------------;
    FORTHWORD "SECTOR"              ; sector. --            don't forget to add decimal point to your sector number (if < 65536)
; ----------------------------------;
SECTOR
    MOV     TOS,X                   ; X = SectorH
    MOV     @PSP,W                  ; W = sectorL
    CALL    #readSectorWX           ; W = SectorLO  X = SectorHI
DisplaySector
    mDOCOL                          ;
    .word   LESSNUM,NUMS,NUMGREATER ; ud --            display the double number
    .word   TYPE,SPACE              ;
    .word   lit,BUFFER,lit,200h,DUMP;    
    .word   EXIT                    ;
; ----------------------------------;

; TIP : How to identify FAT16 or FAT32 SD_Card ?
; 1 CLUSTER <==> FAT16 RootDIR
; 2 CLUSTER <==> FAT32 RootDIR
; ----------------------------------;
; read first sector of Cluster and dump it
; ----------------------------------;
            FORTHWORD "CLUSTER"     ; cluster.  --         don't forget to add decimal point to your sector number (if < 65536)
; ----------------------------------;
    MOV     TOS,&ClusterH           ;
    MOV     @PSP,&ClusterL          ;
Clust_ClustProcess
    CALL    #ComputeClusFrstSect    ;
    MOV     &SectorL,0(PSP)         ;
    MOV     &SectorH,TOS            ;
    JMP     SECTOR                  ;
; ----------------------------------;

; dump FAT1 sector of last entry
; ----------------------------------;
            FORTHWORD "FAT"         ;VWXY Display first FATsector
; ----------------------------------;
    SUB     #4,PSP                  ;
    MOV     TOS,2(PSP)              ;
    MOV     &OrgFAT1,0(PSP)         ;
    MOV     #0,TOS                  ; FATsectorHI = 0
    JMP     SECTOR                  ;
; ----------------------------------;

;; dump FAT1 sector of last entry
;; ----------------------------------;
;            FORTHWORD "FAT"      ; Display FATsector
;; ----------------------------------;
;    MOV     &OrgFAT1,Y              ;
;FAT1_Next                           ;
;    SUB     #4,PSP                  ;
;    MOV     TOS,2(PSP)              ; save TOS
;    MOV     Y,0(PSP)                ;
;    MOV     #0,TOS                  ; FATsectorHI = 0
;    JMP     SECTOR                  ;
;; ----------------------------------;
;
;; dump FAT1 sector of last entry
;; ----------------------------------;
;            FORTHWORD "FAT2"        ; Display FATsector
;; ----------------------------------;
;    MOV     &OrgFAT2,Y              ;
;    JMP     FAT1_Next               ;
;; ----------------------------------;



; dump DIR sector of opened file or first sector of current DIR by default
; ----------------------------------;
            FORTHWORD "DIR"         ; Display DIR sector of CurrentHdl or CurrentDir sector by default 
; ----------------------------------;
    SUB     #4,PSP                  ;
    MOV     TOS,2(PSP)              ;           save TOS
    MOV     &DIRClusterL,&ClusterL  ;
    MOV     &DIRClusterH,&ClusterH  ;
    JMP     Clust_ClustProcess      ;
; ----------------------------------;

