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


    FORTHWORD "{UTILITY}"
    mNEXT

;https://forth-standard.org/standard/tools/DotS
            FORTHWORD ".S"      ; --            print <depth> of Param Stack and stack contents if not empty
DOTS        MOV     TOS,-2(PSP) ; -- TOS ( tos x x )
            MOV     PSP,TOS
            SUB     #2,TOS      ; to take count that TOS is first cell
            MOV     TOS,-6(PSP) ; -- TOS ( tos x  PSP )
            MOV     #PSTACK,TOS ; -- P0  ( tos x  PSP )
            SUB     #2,TOS      ; to take count that TOS is first cell
DOTS1       MOV     TOS,-4(PSP) ; -- S0  ( tos S0 SP )
            SUB     #6,PSP      ; -- S0 SP S0
            SUB     @PSP,TOS    ; -- S0 SP S0-SP
            RRA     TOS         ; -- S0 SP #cells
            mDOCOL
            .word   lit,'<',EMIT
            .word   DOT                 ; display #cells
            .word   lit,08h,EMIT        ; backspace
            .word   lit,'>',EMIT,SPACE
            .word   OVER,OVER,GREATER
            .word   QZBRAN,STKDISPL1
            .word   DROP,DROP,EXIT
STKDISPL1   .word   xdo
STKDISPL2   .word   II,FETCH,UDOT
            .word   lit,2,xploop,STKDISPL2
            .word   EXIT


            FORTHWORD ".RS"     ; --           print <depth> of Return Stack and stack contents if not empty
            MOV     TOS,-2(PSP) ; -- TOS ( tos x x ) 
            MOV     RSP,-6(PSP) ; -- TOS ( tos x  RSP )
            MOV     #RSTACK,TOS ; -- R0  ( tos x  RSP )
            JMP     DOTS1

;https://forth-standard.org/standard/tools/q
;Z  ?       adr --             display the content of adr
            FORTHWORD "?"
            MOV     @TOS,TOS
            MOV     #UDOT,PC

;https://forth-standard.org/standard/tools/WORDS
;X WORDS        --      list all words in first vocabulary in CONTEXT. 38 words
            FORTHWORD "WORDS"
WORDS       mDOCOL
            .word   CR
            .word   lit,3,SPACES

    .SWITCH THREADS
    .CASE   1

;; vvvvvvvv   may be skipped    vvvvvvvv
;            .word   XSQUOTE                ; type # of threads in vocabularies
;            .byte   23,"monothread vocabularies"
;            .word   TYPE
;            .word   CR     
;            .word   lit,3,SPACES
;; ^^^^^^^^   may be skipped    ^^^^^^^^

            .word   LIT,CONTEXT,FETCH   ; -- VOC_BODY
WORDS1      .word   FETCH               ; -- NFA
            .word   QDUP                ; -- 0 | -- NFA NFA 
            .word   QBRAN,WORDS2        ; -- NFA
            .word   DUP,DUP,COUNT       ; -- NFA NFA addr count 
            .word   lit,07Fh,ANDD,TYPE  ; -- NFA NFA 
            .word   CFETCH,lit,0Fh,ANDD
            .word   lit,10h,SWAP,MINUS
            .word   SPACES
            .word   lit,2,MINUS         ; NFA -- LFA
            .word   BRAN,WORDS1
WORDS2      .word   EXIT                ; --


    .ELSECASE

;; vvvvvvvv   may be skipped    vvvvvvvv
;            .word   FBASE,FETCH             
;            .word   LIT,0Ah,FBASE,STORE
;            .word   LIT,THREADS,DOT
;            .word   XSQUOTE                ; type # of threads in vocabularies
;            .byte   20,"threads vocabularies"
;            .word   TYPE
;            .word   FBASE,STORE
;            .word   CR     
;            .word   lit,3,SPACES
;; ^^^^^^^^   may be skipped    ^^^^^^^^

            .word   LIT,CONTEXT,FETCH
            .word   PAD,LIT,THREADS,DUP,PLUS
            .word   MOVE
                                            ; BEGIN
WORDS2      .word   LIT,0,DUP               
            .word   LIT,THREADS,DUP,PLUS    ;   I = ptr = thread*2
            .word   LIT,0
            .word   xdo                     ;   DO
WORDS3      .word   DUP
            .word   II,PAD,PLUS,FETCH       ;   old MAX NFA U< NFA ?
            .word   ULESS,QBRAN,WORDS4      ;   no
            .word   DROP,DROP,II            ;   yes, replace old MAX of NFA by new MAX of NFA 
            .word   DUP,PAD,PLUS,FETCH      ;
WORDS4      .word   LIT,2,xploop,WORDS3     ;   2 +LOOP
            .word   QDUP                    ;   MAX of NFA = 0 ?
            .word   QBRAN,WORDS5            ; WHILE
            .word   DUP,LIT,2,MINUS,FETCH   ;   replace NFA MAX by its [LFA]
            .word   ROT,PAD,PLUS,STORE   
            .word   DUP,COUNT               ;   display NFA MAX in 10 chars format
            .word   lit,07Fh,ANDD,TYPE
            .word   CFETCH,lit,0Fh,ANDD
            .word   lit,10h,SWAP,MINUS
            .word   SPACES
            .word   BRAN,WORDS2             ; REPEAT
WORDS5      .word   DROP
            .word   EXIT

    .ENDCASE


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

    .ENDIF

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

