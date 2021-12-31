; -*- coding: utf-8 -*-

            FORTHWORD "{UTILITY}"
            MOV @IP+,PC

    .IFNDEF TOR
; https://forth-standard.org/standard/core/toR
; >R    x --   R: -- x   push to return stack
            FORTHWORD ">R"
TOR         PUSH TOS
            MOV @PSP+,TOS
            MOV @IP+,PC
    .ENDIF

        .IFNDEF ANDD
;https://forth-standard.org/standard/core/AND
;C AND    x1 x2 -- x3           logical AND
            FORTHWORD "AND"
ANDD        AND     @PSP+,TOS
            MOV @IP+,PC
        .ENDIF

        .IFNDEF CFETCH
;https://forth-standard.org/standard/core/CFetch
;C C@     c-addr -- char   fetch char from memory
            FORTHWORD "C@"
CFETCH      MOV.B @TOS,TOS      ;2
            MOV @IP+,PC         ;4
        .ENDIF

        .IFNDEF ULESS
; https://forth-standard.org/standard/core/Uless
; U<    u1 u2 -- flag       test u1<u2, unsigned
            FORTHWORD "U<"
ULESS       SUB @PSP+,TOS   ; 2 u2-u1
            JNC UTOSFALSE
            JZ  ULESSEND
UTOSTRUE    MOV #-1,TOS     ;1 flag Z = 0
ULESSEND    MOV @IP+,PC     ;4

; https://forth-standard.org/standard/core/Umore
; U>     n1 n2 -- flag
            FORTHWORD "U>"
            SUB @PSP+,TOS   ; 2
            JNC UTOSTRUE    ; 2 flag = true, Z = 0
UTOSFALSE   AND #0,TOS      ;1 flag Z = 1
            MOV @IP+,PC     ;4
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
            MOV @IP+,PC                   ;

        .ENDIF

    .IFNDEF TWODUP
; https://forth-standard.org/standard/core/TwoDUP
; 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
            FORTHWORD "2DUP"
TWODUP      MOV TOS,-2(PSP)     ; 3
            MOV @PSP,-4(PSP)    ; 4
            SUB #4,PSP          ; 1
            MOV @IP+,PC         ; 4
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

;https://forth-standard.org/standard/tools/DotS
            FORTHWORD ".S"      ; --            print <depth> of Param Stack and stack contents if not empty
DOTS        MOV TOS,-2(PSP)     ; -- TOS ( tos x x )
            MOV PSP,TOS
            SUB #2,TOS          ; to take count that TOS is first cell
            MOV TOS,-6(PSP)     ; -- TOS ( tos x  PSP )
            MOV #PSTACK,TOS     ; -- P0  ( tos x  PSP )
            SUB #2,TOS          ; to take count that TOS is first cell
DOTS1       MOV TOS,-4(PSP)     ; -- S0  ( tos S0 SP )
            SUB #6,PSP          ; -- S0 SP S0
            SUB @PSP,TOS        ; -- S0 SP S0-SP
            RRA TOS             ; -- S0 SP #cells
            mDOCOL
            .word   lit,'<',EMIT
            .word   DOT                 ; display #cells
            .word   lit,08h,EMIT        ; backspace
            .word   lit,'>',EMIT,SPACE
            .word   TWODUP,ONEPLUS,ULESS
            .word   QFBRAN,STKDISPL1
            .word   DROP,DROP,EXIT
STKDISPL1   .word   xdo
STKDISPL2   .word   II,FETCH,UDOT
            .word   lit,2,xploo,STKDISPL2
            .word   EXIT


            FORTHWORD ".RS"     ; --           print <depth> of Return Stack and stack contents if not empty
DOTRS       MOV TOS,-2(PSP)     ; -- TOS ( tos x x )
            MOV RSP,-6(PSP)     ; -- TOS ( tos x  RSP )
            MOV #RSTACK,TOS     ; -- R0  ( tos x  RSP )
            JMP DOTS1

;https://forth-standard.org/standard/tools/q
;Z  ?       adr --             display the content of adr
            FORTHWORD "?"
QUESTION    MOV @TOS,TOS
            MOV #UDOT,PC

        .IFNDEF QDUP
; https://forth-standard.org/standard/core/DUP
; DUP      x -- x x      duplicate top of stack
            FORTHWORD "DUP"
QDUPNEXT    SUB #2,PSP      ; 2  push old TOS..
            MOV TOS,0(PSP)  ; 3  ..onto stack
QDUPEND     MOV @IP+,PC     ; 4

; https://forth-standard.org/standard/core/qDUP
; ?DUP     x -- 0 | x x    DUP if nonzero
            FORTHWORD "?DUP"
QDUP        CMP #0,TOS
            JZ QDUPEND
            JNZ QDUPNEXT
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

    .IFNDEF TWODIV
;https://forth-standard.org/standard/core/TwoDiv
;C 2/      x1 -- x2        arithmetic right shift
            FORTHWORD "2/"
TWODIV      RRA TOS
            MOV @IP+,PC
    .ENDIF

    .SWITCH THREADS
    .CASE   1

;https://forth-standard.org/standard/tools/WORDS
;X WORDS        --      list all words in first vocabulary in CONTEXT. 38 words
            FORTHWORD "WORDS"
WORDS       mDOCOL
            .word   CR
            .word   LIT,CONTEXT,FETCH   ; -- VOC_BODY
WORDS1      .word   FETCH               ; -- NFA
            .word   QDUP                ; -- 0 | -- NFA NFA
            .word   QFBRAN,WORDS2        ; -- NFA
            .word   DUP,DUP,COUNT       ; -- NFA NFA addr count
            .word   TWODIV,ANDD,TYPE    ; -- NFA NFA
            .word   CFETCH,TWODIV
            .word   lit,0Fh,ANDD
            .word   lit,10h,SWAP,MINUS
            .word   SPACES
            .word   lit,2,MINUS         ; NFA -- LFA
            .word   BRAN,WORDS1
WORDS2      .word   EXIT                ; --

    .ELSECASE

        .IFNDEF PAD
;https://forth-standard.org/standard/core/PAD
; PAD           --  pad address
            FORTHWORD "PAD"
PAD         CALL rDOCON
            .WORD PAD_ORG
        .ENDIF

        .IFNDEF ROT
;https://forth-standard.org/standard/core/ROT
;C ROT    x1 x2 x3 -- x2 x3 x1
            FORTHWORD "ROT"
ROT         MOV @PSP,W          ; 2 fetch x2
            MOV TOS,0(PSP)      ; 3 store x3
            MOV 2(PSP),TOS      ; 3 fetch x1
            MOV W,2(PSP)        ; 3 store x2
            MOV @IP+,PC               ; 4
        .ENDIF

            .IFNDEF MOVE
; https://forth-standard.org/standard/core/MOVE
; MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
            FORTHWORD "MOVE"
MOVE        MOV TOS,W           ; W = cnt
            MOV @PSP+,Y         ; Y = addr2 = dst
            MOV @PSP+,X         ; X = addr1 = src
            MOV @PSP+,TOS       ; pop new TOS
            CMP #0,W            ; count = 0 ?
            JZ MOVEND           ; if 0, already done !
            CMP X,Y             ; dst = src ?
            JZ MOVEND           ; already done !
            JC MOVEDOWN         ; U< if src > dst
MOVEUPLOOP  MOV.B @X+,0(Y)      ; copy W bytes
            ADD #1,Y
            SUB #1,W
            JNZ MOVEUPLOOP
            MOV @IP+,PC         ; out 1 of MOVE ====>
MOVEDOWN    ADD W,Y             ; copy W bytes beginning with the end
            ADD W,X
MOVEDOWNLOO SUB #1,X
            SUB #1,Y
            MOV.B @X,0(Y)
            SUB #1,W
            JNZ MOVEDOWNLOO
MOVEND      MOV @IP+,PC ; out 2 of MOVE ====>
            .ENDIF

;https://forth-standard.org/standard/tools/WORDS
;X WORDS        --      list all words in first vocabulary in CONTEXT. 38 words
            FORTHWORD "WORDS"
WORDS       mDOCOL
            .word   CR
            .word   LIT,CONTEXT,FETCH
            .word   PAD,LIT,THREADS,DUP,PLUS
            .word   MOVE
                                            ; BEGIN
WORDS2      .word   LIT,0,DUP
            .word   LIT,THREADS,DUP,PLUS    ;   I = ptr = thread*2
            .word   LIT,0
            .word   xdo                     ;   DO
WORDS3      .word   DUP,II,PAD,PLUS,FETCH   ;   old MAX NFA U< NFA ?
            .word   ULESS,QFBRAN,WORDS4      ;   no
            .word   TWODROP,II              ;   yes, replace old MAX of NFA by new MAX of NFA
            .word   DUP,PAD,PLUS,FETCH      ;
WORDS4      .word   LIT,2,xploo,WORDS3      ;   2 +LOOP
            .word   QDUP                    ;   MAX of NFA = 0 ?
            .word   QFBRAN,WORDS5            ; WHILE
            .word   DUP,LIT,2,MINUS,FETCH   ;   replace NFA MAX by its [LFA]
            .word   ROT,PAD,PLUS,STORE
            .word   DUP,COUNT,TWODIV,TYPE   ;   display NFA MAX in 10 chars format
            .word   CFETCH,TWODIV
            .word   lit,0Fh,ANDD
            .word   lit,10h,SWAP,MINUS
            .word   SPACES
            .word   BRAN,WORDS2             ; REPEAT
WORDS5      .word   DROP
            .word   EXIT

    .ENDCASE


    .IFNDEF MAX

;https://forth-standard.org/standard/core/MAX
;C MAX    n1 n2 -- n3       signed maximum
            FORTHWORD "MAX"
MAX         CMP @PSP,TOS        ; n2-n1
            JL SELn1            ; n2<n1
SELn2       ADD #2,PSP
            MOV @IP+,PC

;https://forth-standard.org/standard/core/MIN
;C MIN    n1 n2 -- n3       signed minimum
            FORTHWORD "MIN"
MIN         CMP @PSP,TOS        ; n2-n1
            JL SELn2            ; n2<n1
SELn1       MOV @PSP+,TOS
            MOV @IP+,PC

    .ENDIF

    .IFNDEF PLUS
;https://forth-standard.org/standard/core/Plus
;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
            FORTHWORD "+"
PLUS        ADD @PSP+,TOS
            MOV @IP+,PC
    .ENDIF

        .IFNDEF OVER
;https://forth-standard.org/standard/core/OVER
;C OVER    x1 x2 -- x1 x2 x1
            FORTHWORD "OVER"
OVER        MOV TOS,-2(PSP)     ; 3 -- x1 (x2) x2
            MOV @PSP,TOS        ; 2 -- x1 (x2) x1
            SUB #2,PSP          ; 1 -- x1 x2 x1
            MOV @IP+,PC               ; 4
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

    .IFNDEF HERE
; https://forth-standard.org/standard/core/HERE
; HERE    -- addr      returns memory ptr
HERE       FORTHWORD "HERE"
            MOV #HEREXEC,PC
    .ENDIF

;https://forth-standard.org/standard/tools/DUMP
            FORTHWORD "DUMP"
DUMP        PUSH IP
            PUSH &BASEADR                   ; save current base
            MOV #10h,&BASEADR               ; HEX base
            ADD @PSP,TOS                    ; -- ORG END
            mASM2FORTH
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
            .word   lit,7Eh,MIN,BL,MAX,EMIT
            .word   xloop,DUMP4             ; chars display loop
            .word   lit,10h,xploo,DUMP1     ; line loop
            .word   RFROM,lit,BASEADR,STORE ; restore current base
            .word   EXIT

