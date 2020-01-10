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


    .IFNDEF MAX

;https://forth-standard.org/standard/core/MAX
;C MAX    n1 n2 -- n3       signed maximum
            FORTHWORD "MAX"
MAX:        CMP @PSP,TOS        ; n2-n1
            JL SELn1            ; n2<n1
SELn2:      ADD #2,PSP
            MOV @IP+,PC

;https://forth-standard.org/standard/core/MIN
;C MIN    n1 n2 -- n3       signed minimum
            FORTHWORD "MIN"
MIN:        CMP @PSP,TOS        ; n2-n1
            JL SELn2            ; n2<n1
SELn1:      MOV @PSP+,TOS
            MOV @IP+,PC

    .ENDIF

    .IFNDEF SPACE
;https://forth-standard.org/standard/core/SPACE
;C SPACE   --               output a space
            FORTHWORD "SPACE"
SPACE       SUB #2,PSP              ;1
            MOV TOS,0(PSP)          ;3
            MOV #20h,TOS            ;2
            MOV #EMIT,PC            ;17~  23~

;https://forth-standard.org/standard/core/SPACES
;C SPACES   n --            output n spaces
            FORTHWORD "SPACES"
SPACES      CMP #0,TOS
            JZ SPACESNEXT2
            PUSH IP
            MOV #SPACESNEXT,IP
            JMP SPACE               ;25~
SPACESNEXT  .word   $+2
            SUB #2,IP               ;1
            SUB #1,TOS              ;1
            JNZ SPACE               ;25~ ==> 27~ by space ==> 2.963 MBds @ 8 MHz
            MOV @RSP+,IP            ;
SPACESNEXT2 MOV @PSP+,TOS           ; --         drop n
            MOV @IP+,PC             ;

    .ENDIF

    .IFNDEF II
; https://forth-standard.org/standard/core/I
; I        -- n   R: sys1 sys2 -- sys1 sys2
;                  get the innermost loop index
            FORTHWORD "I"
II          SUB #2,PSP              ;1 make room in TOS
            MOV TOS,0(PSP)          ;3
            MOV @RSP,TOS            ;2 index = loopctr - fudge
            SUB 2(RSP),TOS          ;3
            MOV @IP+,PC             ;4 13~
    .ENDIF

        .IFNDEF OVER
;https://forth-standard.org/standard/core/OVER
;C OVER    x1 x2 -- x1 x2 x1
            FORTHWORD "OVER"
OVER        MOV TOS,-2(PSP)         ; 3 -- x1 (x2) x2
            MOV @PSP,TOS            ; 2 -- x1 (x2) x1
            SUB #2,PSP              ; 1 -- x1 x2 x1
            MOV @IP+,PC             ; 4
        .ENDIF

    .IFNDEF TOR
; https://forth-standard.org/standard/core/toR
; >R    x --   R: -- x   push to return stack
            FORTHWORD ">R"
TOR         PUSH TOS
            MOV @PSP+,TOS
            MOV @IP+,PC
    .ENDIF

    .IFNDEF UDOTR
;https://forth-standard.org/standard/core/UDotR
;X U.R      u n --      display u unsigned in n width
            FORTHWORD "U.R"
UDOTR       mDOCOL
            .word   TOR,LESSNUM,lit,0,NUM,NUMS,NUMGREATER
            .word   RFROM,OVER,MINUS,lit,0,MAX,SPACES,TYPE
            .word   EXIT
    .ENDIF

        .IFNDEF CFETCH
;https://forth-standard.org/standard/core/CFetch
;C C@     c-addr -- char   fetch char from memory
            FORTHWORD "C@"
CFETCH      MOV.B @TOS,TOS          ;2
            MOV @IP+,PC             ;4
        .ENDIF

    .IFNDEF PLUS
;https://forth-standard.org/standard/core/Plus
;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
            FORTHWORD "+"
PLUS        ADD @PSP+,TOS
            MOV @IP+,PC
    .ENDIF

    .IFNDEF DUMP
;https://forth-standard.org/standard/tools/DUMP
            FORTHWORD "DUMP"
DUMP        PUSH IP
            PUSH &BASE                      ; save current base
            MOV #10h,&BASE                  ; HEX base
            ADD @PSP,TOS                    ; -- ORG END
            ASMtoFORTH
            .word   SWAP                    ; -- END ORG
            .word   xdo                     ; --
DUMP1       .word   CR
            .word   II,lit,4,UDOTR,SPACE    ; generate address

            .word   II,lit,8,PLUS,II,xdo    ; display first 8 bytes
DUMP2       .word   II,CFETCH,lit,3,UDOTR
            .word   xloop,DUMP2             ; bytes display loop
            .word   SPACE
            .word   II,lit,10h,PLUS,II,lit,8,PLUS,xdo    ; display last 8 bytes
DUMP3       .word   II,CFETCH,lit,3,UDOTR
            .word   xloop,DUMP3             ; bytes display loop
            .word   SPACE,SPACE
            .word   II,lit,10h,PLUS,II,xdo  ; display 16 chars
DUMP4       .word   II,CFETCH
            .word   lit,7Eh,MIN,FBLANK,MAX,EMIT
            .word   xloop,DUMP4             ; chars display loop
            .word   lit,10h,xploop,DUMP1    ; line loop
            .word   RFROM,lit,BASE,STORE    ; restore current base
            .word   EXIT

    .ENDIF

    FORTHWORD "{SD_TOOLS}"
    MOV @IP+,PC

; read logical sector and dump it 
; ----------------------------------;
            FORTHWORD "SECTOR"      ; sector. --            don't forget to add decimal point to your sector number (if < 65536)
; ----------------------------------;
SECTOR      MOV TOS,X               ; X = SectorH
            MOV @PSP,W              ; W = sectorL
            CALL #readSectorWX      ; W = SectorLO  X = SectorHI
DisplaySector
            mDOCOL                  ;
            .word   LESSNUM,NUMS
            .word   NUMGREATER      ; ud --            display the double number
            .word   TYPE,SPACE      ;
            .word   lit,SD_BUF
            .word   lit,200h,DUMP   ;    
            .word   EXIT            ;
; ----------------------------------;

; ----------------------------------;
; read first sector of Cluster and dump it
; ----------------------------------;
            FORTHWORD "CLUSTER"     ; cluster.  --         don't forget to add decimal point to your sector number (if < 65536)
; ----------------------------------;
CLUSTER     BIT.B #CD_SD,&SD_CDIN   ; test Card Detect: memory card present ?
            JZ CD_CLUST_OK          ;
            MOV #COLD,PC            ; no: force COLD
CD_CLUST_OK MOV.B &SecPerClus,W     ; SecPerClus(54321) = multiplicator
            MOV @PSP,X              ; X = ClusterL
            JMP CLUSTER1            ;
CLUSTERLOOP ADD X,X                 ; (RLA) shift one left MULTIPLICANDlo16
            ADDC TOS,TOS            ; (RLC) shift one left MULTIPLICANDhi8
CLUSTER1    RRA W                   ; shift one right multiplicator
            JNC CLUSTERLOOP         ; if not carry
            ADD &OrgClusters,X      ; add OrgClusters = sector of virtual cluster 0 (word size)
            MOV X,0(PSP)            
            ADDC #0,TOS             ; don't forget carry
            JMP SECTOR              ; jump to a defined word
; ----------------------------------;

; dump FAT1 first sector
; ----------------------------------;
            FORTHWORD "FAT"         ;VWXY Display first FATsector
; ----------------------------------;
            SUB #4,PSP              ;
            MOV TOS,2(PSP)          ;
            MOV &OrgFAT1,0(PSP)     ;
            MOV #0,TOS              ; FATsectorHI = 0
            JMP SECTOR              ;
; ----------------------------------;


; dump current DIR first sector
; ----------------------------------;
            FORTHWORD "DIR"         ;
; ----------------------------------;
            SUB #4,PSP              ;
            MOV TOS,2(PSP)          ;           save TOS
            MOV &DIRclusterL,0(PSP) ;
            MOV &DIRclusterH,TOS    ;
            CMP #0,TOS
            JNZ CLUSTER
            CMP #1,0(PSP)           ; cluster 1 ?
            JNZ CLUSTER       
            MOV &OrgRootDir,0(PSP)  ; if yes, special case of FAT16 OrgRootDir        
            JMP SECTOR
; ----------------------------------;

