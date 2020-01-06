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


            FORTHWORD "{TOOLS}"
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
            MOV @IP+,PC               ;4
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
            .word   lit,2,xploop,STKDISPL2
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
            .word   lit,07Fh,ANDD,TYPE  ; -- NFA NFA 
            .word   CFETCH,lit,0Fh,ANDD
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
WORDS3      .word   DUP
            .word   II,PAD,PLUS,FETCH       ;   old MAX NFA U< NFA ?
            .word   ULESS,QFBRAN,WORDS4      ;   no
            .word   DROP,DROP,II            ;   yes, replace old MAX of NFA by new MAX of NFA 
            .word   DUP,PAD,PLUS,FETCH      ;
WORDS4      .word   LIT,2,xploop,WORDS3     ;   2 +LOOP
            .word   QDUP                    ;   MAX of NFA = 0 ?
            .word   QFBRAN,WORDS5            ; WHILE
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
            .word   RFROM,lit,BASE,STORE       ; restore current base
            .word   EXIT

