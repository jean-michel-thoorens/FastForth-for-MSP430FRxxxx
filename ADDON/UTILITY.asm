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


;X .S      --           print <number> of cells and stack contents if not empty
            FORTHWORD ".S"
DOTS        mDOCOL
            .word   lit,'<',EMIT
            .word   DEPTH,DOT
            .word   lit,08h,EMIT        ; backspace
            .word   lit,'>',EMIT,SPACE
            .word   SPFETCH,lit,PSTACK,ULESS
            .word   QBRAN,DOTS2
            .word   SPFETCH,lit,PSTACK-2,xdo
DOTS1:      .word   II,FETCH,UDOT
            .word   lit,-2
            .word   xploop,DOTS1
DOTS2:      .word   EXIT

;Z  ?       adr --             display the content of adr
            FORTHWORD "?"
            MOV     @TOS,TOS
            MOV     #UDOT,PC

;X WORDS        --      list all words in all dicts. 53 words
    .SWITCH THREADS
    .CASE   1

            FORTHWORD "WORDS"
WORDS       mDOCOL

; vvvvvvvv   may be skipped    vvvvvvvv
            .word   CR                     ; type # of threads in vocabularies
            .word   lit,3,SPACES
            .word   XSQUOTE
            .byte   23,"monothread vocabularies"
            .word   TYPE
; ^^^^^^^^   may be skipped    ^^^^^^^^

            .word   LIT,CONTEXT
WORDS1      .word   DUP,CELLPLUS,SWAP
            .word   FETCH,QDUP
            .word   QBRAN,WORDS5
            .word   CR
            .word   lit,3,SPACES
WORDS3      .word   FETCH,QDUP
            .word   QBRAN,WORDS4
            .word   DUP,DUP,COUNT
            .word   lit,07Fh,ANDD,TYPE
            .word   CFETCH,lit,0Fh,ANDD
            .word   lit,10h,SWAP,MINUS
            .word   SPACES,lit,2,MINUS
            .word   BRAN,WORDS3
WORDS4      .word   CR
            .word   BRAN,WORDS1
WORDS5      .word   DROP
            .word   EXIT


    .ELSECASE

            FORTHWORD "WORDS"
WORDS       mDOCOL

; vvvvvvvv   may be skipped    vvvvvvvv
            .word   FBASE,FETCH             
            .word   LIT,0Ah,FBASE,STORE
            .word   CR                     ; type # of threads in vocabularies
            .word   lit,3,SPACES
            .word   LIT,THREADS,DOT
            .word   XSQUOTE
            .byte   20,"threads vocabularies"
            .word   TYPE
            .word   FBASE,STORE
; ^^^^^^^^   may be skipped    ^^^^^^^^

            .word   LIT,CONTEXT
                                            ; BEGIN
WORDS1      .word   DUP,CELLPLUS,SWAP
            .word   FETCH,QDUP
            .word   QBRAN,WORDS6            ; 
            .word   CR
            .word   lit,3,SPACES

            .word   DUP,LIT,PAD             ; 
            .word   LIT,THREADS,DUP,PLUS
            .word   MOVE
                                            ; BEGIN
WORDS2      .word   LIT,0,DUP               
            .word   LIT,THREADS,DUP,PLUS    ; I = ptr = thread*2
            .word   LIT,0
            .word   xdo                     ; DO
WORDS3      .word   DUP
            .word   II,LIT,PAD,PLUS,FETCH   ; old MAX NFA U< NFA ?
            .word   ULESS,QBRAN,WORDS4      ; no
            .word   DROP,DROP,II            ; yes, replace old MAX of NFA by new MAX of NFA 
            .word   DUP,LIT,PAD,PLUS,FETCH  ;
WORDS4      .word   LIT,2,xploop,WORDS3     ; 2 +LOOP
            .word   QDUP                    ; MAX of NFA = 0 ?
            .word   QBRAN,WORDS5            ; WHILE
            .word   DUP,LIT,2,MINUS,FETCH   ; replace NFA MAX by its [LFA]
            .word   ROT,LIT,PAD,PLUS,STORE   
            .word   DUP,COUNT               ; display NFA MAX in 10 chars format
            .word   lit,07Fh,ANDD,TYPE
            .word   CFETCH,lit,0Fh,ANDD
            .word   lit,10h,SWAP,MINUS
            .word   SPACES
            .word   BRAN,WORDS2             ; REPEAT
WORDS5      .word   DROP,DROP
            .word   CR
            .word   BRAN,WORDS1             ; REPEAT
WORDS6      .word   DROP
            .word   EXIT

    .ENDCASE


    .IFNDEF ANS_CORE_COMPLIANT

;C MAX    n1 n2 -- n3       signed maximum
            FORTHWORD "MAX"
MAX:        CMP     @PSP,TOS    ; n2-n1
            JL      SELn1       ; n2<n1
SELn2:      ADD     #2,PSP
            mNEXT

;C MIN    n1 n2 -- n3       signed minimum
            FORTHWORD "MIN"
MIN:        CMP     @PSP,TOS    ; n2-n1
            JL      SELn2       ; n2<n1
SELn1:      MOV     @PSP+,TOS
            mNEXT

    .ENDIF

;X U.R      u n --      display u unsigned in n width
            FORTHWORD "U.R"
UDOTR       mDOCOL
            .word   TOR,LESSNUM,lit,0,NUM,NUMS,NUMGREATER
            .word   RFROM,OVER,MINUS,lit,0,MAX,SPACES,TYPE
            .word   EXIT

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

