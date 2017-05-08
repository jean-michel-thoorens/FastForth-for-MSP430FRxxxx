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



; read logical sector and dump it 
; ----------------------------------;
    FORTHWORD "SECT_D"              ; sector. --            don't forget to add decimal point to your sector number (if < 65536)
; ----------------------------------;
SECT_D
    MOV     TOS,X                   ; X = SectorH
    MOV     @PSP,W                  ; W = sectorL
    CALL    #readSectorWX           ; W = SectorLO  X = SectorHI
DisplaySector
    mDOCOL                          ;
    .word   UDDOT                   ; ud --            display the double number
    .word   lit,1E00h,lit,200h,DUMP ;    
    .word   EXIT                    ;
; ----------------------------------;

; TIP : How to identify FAT16 or FAT32 SD_Card ?
; 1 CLUSTER <==> FAT16 RootDIR
; 2 CLUSTER <==> FAT32 RootDIR
; ----------------------------------;
; read first sector of Cluster and dump it
; ----------------------------------;
            FORTHWORD "CLUST_D"     ; cluster.  --         don't forget to add decimal point to your sector number (if < 65536)
; ----------------------------------;
    MOV     TOS,&ClusterH           ;
    MOV     @PSP,&ClusterL          ;
Clust_ClustProcess
    CALL    #ComputeClusFrstSect    ;
    MOV     &SectorL,0(PSP)         ;
    MOV     &SectorH,TOS            ;
    JMP     SECT_D                  ;
; ----------------------------------;

; dump FAT1 sector of last entry
; ----------------------------------;
            FORTHWORD "FAT_D"       ;VWXY Display FATsector
; ----------------------------------;
    SUB     #4,PSP                  ;
    MOV     TOS,2(PSP)              ;
    MOV     &FATsector,0(PSP)       ; FATsectorLO
    ADD     &OrgFAT1,0(PSP)         ;
    MOV     #0,TOS                  ; FATsectorHI = 0
    JMP     SECT_D                  ;
; ----------------------------------;

;; dump FAT1 sector of last entry
;; ----------------------------------;
;            FORTHWORD "FAT1_D"      ; Display FATsector
;; ----------------------------------;
;    MOV     &OrgFAT1,Y              ;
;AddFATsector                        ;
;    ADD     &FATsector,Y            ; FATsectorLO
;    SUB     #4,PSP                  ;
;    MOV     TOS,2(PSP)              ; save TOS
;    MOV     Y,0(PSP)                ;
;    MOV     #0,TOS                  ; FATsectorHI = 0
;    JMP     SECT_D                  ;
;; ----------------------------------;
;
;; dump FAT1 sector of last entry
;; ----------------------------------;
;            FORTHWORD "FAT2_D"      ; Display FATsector
;; ----------------------------------;
;    MOV     &OrgFAT2,Y              ;
;    JMP     AddFATsector            ;
;; ----------------------------------;



; dump DIR sector of opened file or first sector of current DIR by default
; ----------------------------------;
            FORTHWORD "DIR_D"       ; Display DIR sector of CurrentHdl or CurrentDir sector by default 
; ----------------------------------;
    SUB     #4,PSP                  ;
    MOV     TOS,2(PSP)              ;           save TOS
    MOV     &DIRClusterL,&ClusterL  ;
    MOV     &DIRClusterH,&ClusterH  ;
    JMP     Clust_ClustProcess      ;
; ----------------------------------;

