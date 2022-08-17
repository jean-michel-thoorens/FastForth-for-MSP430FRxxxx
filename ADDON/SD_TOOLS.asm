; -*- coding: utf-8 -*-

    FORTHWORD "{SD_TOOLS}"
    MOV @IP+,PC

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
    .IFNDEF XDO
; Primitive XDO; compiled by DO
;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2      run-time code for DO
;                                               n1|u1=limit, n2|u2=index
XDO         MOV #8000h,X    ;2 compute 8000h-limit = "fudge factor"
            SUB @PSP+,X     ;2
            MOV TOS,Y       ;1 loop ctr = index+fudge
            ADD X,Y         ;1 Y = INDEX
            PUSHM #2,X      ;4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
            MOV @PSP+,TOS   ;2
            MOV @IP+,PC     ;4

            FORTHWORDIMM "DO"       ; immediate
; https://forth-standard.org/standard/core/DO
; DO       -- DOadr   L: -- 0
DO          SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            ADD #2,&DP             ;   make room to compile xdo
            MOV &DP,TOS            ; -- HERE+2
            MOV #XDO,-2(TOS)        ;   compile xdo
            ADD #2,&LEAVEPTR        ; -- HERE+2     LEAVEPTR+2
            MOV &LEAVEPTR,W         ;
            MOV #0,0(W)             ; -- HERE+2     L-- 0
            MOV @IP+,PC

; Primitive XLOOP; compiled by LOOP
;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates, clean up the
; return stack and skip the branch.  Else take the inline branch.
; Note that LOOP terminates when index=8000h.
XLOOP       ADD #1,0(RSP)   ;4 increment INDEX
XLOOPNEXT   BIT #100h,SR    ;2 is overflow bit set?
            JZ XLOOPDO      ;2 no overflow = loop
            ADD #4,RSP      ;1 empties RSP
            ADD #2,IP       ;1 overflow = loop done, skip branch ofs
            MOV @IP+,PC     ;4 14~ taken or not taken xloop/loop
XLOOPDO     MOV @IP,IP
            MOV @IP+,PC     ;4 14~ taken or not taken xloop/loop

            FORTHWORDIMM "LOOP"     ; immediate
; https://forth-standard.org/standard/core/LOOP
; LOOP    DOadr --         L-- an an-1 .. a1 0
LOO         MOV #XLOOP,X
LOOPNEXT    ADD #4,&DP             ; make room to compile two words
            MOV &DP,W
            MOV X,-4(W)             ; xloop --> HERE
            MOV TOS,-2(W)           ; DOadr --> HERE+2
; resolve all "leave" adr
LEAVELOOP   MOV &LEAVEPTR,TOS       ; -- Adr of top LeaveStack cell
            SUB #2,&LEAVEPTR        ; --
            MOV @TOS,TOS            ; -- first LeaveStack value
            CMP #0,TOS              ; -- = value left by DO ?
            JZ LOOPEND
            MOV W,0(TOS)            ; move adr after loop as UNLOOP adr
            JMP LEAVELOOP
LOOPEND     MOV @PSP+,TOS
            MOV @IP+,PC

; Primitive XPLOOP; compiled by +LOOP
;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates, clean up the
; return stack and skip the branch. Else take the inline branch.
XPLOO       ADD TOS,0(RSP)  ;4 increment INDEX by TOS value
            MOV @PSP+,TOS   ;2 get new TOS, doesn't change flags
            JMP XLOOPNEXT   ;2

            FORTHWORDIMM "+LOOP"    ; immediate
; https://forth-standard.org/standard/core/PlusLOOP
; +LOOP   adrs --   L-- an an-1 .. a1 0
PLUSLOOP    MOV #XPLOO,X
            JMP LOOPNEXT

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
        .IFNDEF CR
            FORTHWORD "CR"
; https://forth-standard.org/standard/core/CR
; CR      --               send CR to the output device
CR          MOV @PC+,PC
            .word BODYCR
BODYCR      mDOCOL                  ;  send CR+LF to the default output device
            .word   XSQUOTE
            .byte   2,0Dh,0Ah
            .word   TYPE,EXIT

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
            PUSH &BASEADR                   ; save current base
            MOV #10h,&BASEADR               ; HEX base
            ADD @PSP,TOS                    ; -- ORG END
            mASM2FORTH
            .word   SWAP                    ; -- END ORG
            .word   CR,LIT,4,SPACES         ; display line of byte order
            .word   LIT,10h,LIT,0,xdo
DUMP1       .word   II,LIT,3,UDOTR
            .word   xloop,DUMP1             ; -- END ORG
            .word   xdo                     ; --
DUMP2       .word   CR                      ; display a dump line
            .word   II,lit,4,UDOTR,SPACE    ; generate address
            .word   II,lit,10h,PLUS,II,xdo  ; display 16 bytes
DUMP3       .word   II,CFETCH,lit,3,UDOTR
            .word   xloop,DUMP3             ; bytes display loop
            .word   SPACE,SPACE             ; display 2 spaces
            .word   II,lit,10h,PLUS,II,xdo  ; display 16 chars
DUMP4       .word   II,CFETCH
            .word   lit,7Eh,MIN,BL,MAX,EMIT
            .word   xloop,DUMP4             ; chars display loop
            .word   lit,10h,xploo,DUMP2     ; line loop
            .word   RFROM,lit,BASEADR,STORE ; restore current base
            .word   EXIT
    .ENDIF

; read logical sector and dump it
; ----------------------------------;
            FORTHWORD "SECTOR."     ; sector. --            don't forget to add decimal point to your sector number (if < 65536)
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
            FORTHWORD "CLUSTER."    ; cluster.  --         don't forget to add decimal point to your sector number (if < 65536)
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
            JMP CLUSTER
; ----------------------------------;
