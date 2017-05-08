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


    .IFNDEF ALIGNMENT
    .include "ADDON\ALIGNMENT.asm"
    .ENDIF
    .IFNDEF ARITHMETIC
    .include "ADDON\ARITHMETIC.asm"
    .ENDIF
    .IFNDEF PORTABILITY
    .include "ADDON\PORTABILITY.asm"
    .ENDIF
    .IFNDEF DOUBLE
    .include "ADDON\DOUBLE.asm"
    .ENDIF

;C INVERT   x1 -- x2            bitwise inversion
            FORTHWORD "INVERT"
INVERT      XOR     #-1,TOS
            mNEXT

;C LSHIFT  x1 u -- x2    logical L shift u places
            FORTHWORD "LSHIFT"
LSHIFT      MOV     @PSP+,W
            AND     #1Fh,TOS        ; no need to shift more than 16
            JZ      LSH_X
LSH_1:      ADD     W,W
            SUB     #1,TOS
            JNZ     LSH_1
LSH_X:      MOV     W,TOS
            mNEXT

;C RSHIFT  x1 u -- x2    logical R shift u places
            FORTHWORD "RSHIFT"
RSHIFT      MOV     @PSP+,W
            AND     #1Fh,TOS        ; no need to shift more than 16
            JZ      RSH_X
RSH_1:      BIC     #1,SR           ; CLRC
            RRC     W
            SUB     #1,TOS
            JNZ     RSH_1
RSH_X:      MOV     W,TOS
            mNEXT

;C 1+      n1/u1 -- n2/u2       add 1 to TOS
            FORTHWORD "1+"
ONEPLUS     ADD     #1,TOS
            mNEXT

;C 1-      n1/u1 -- n2/u2     subtract 1 from TOS
            FORTHWORD "1-"
ONEMINUS    SUB     #1,TOS
            mNEXT

;C 2*      x1 -- x2         arithmetic left shift
            FORTHWORD "2*"
TWOSTAR     ADD     TOS,TOS
            mNEXT

;C 2/      x1 -- x2        arithmetic right shift
            FORTHWORD "2/"
TWOSLASH    RRA     TOS
            mNEXT

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

;C +!     n/u a-addr --       add to memory
            FORTHWORD "+!"
PLUSSTORE   ADD     @PSP+,0(TOS)
            MOV     @PSP+,TOS
            mNEXT

;C CHAR   -- char           parse ASCII character
            FORTHWORD "CHAR"
CHARR       mDOCOL
            .word   FBLANK,WORDD,ONEPLUS,CFETCH,EXIT

;C [CHAR]   --          compile character literal
            FORTHWORDIMM "[CHAR]"        ; immediate
BRACCHAR    mDOCOL
            .word   CHARR
            .word   lit,lit,COMMA
            .word   COMMA,EXIT

;C FILL   c-addr u char --  fill memory with char
            FORTHWORD "FILL"
FILL        MOV     @PSP+,X     ; count
            MOV     @PSP+,W     ; address
            CMP     #0,X
            JZ      FILL_X
FILL_1:     MOV.B   TOS,0(W)    ; store char in memory
            ADD     #1,W
            SUB     #1,X
            JNZ     FILL_1
FILL_X:     MOV     @PSP+,TOS   ; pop new TOS
            mNEXT

            FORTHWORD "HEX"
HEX         MOV     #16,&BASE
            mNEXT

            FORTHWORD "DECIMAL"
DECIMAL     MOV     #10,&BASE
            mNEXT

;C (                \  --     paren ; skip input until )
            FORTHWORDIMM "\40"      ; immediate
LPAREN      mDOCOL
            .word   lit,')',WORDD,DROP,EXIT

    .IFDEF LOWERCASE

; .(                \  --     dotparen ; type comment immediatly.
            FORTHWORDIMM ".\40"        ; immediate
DOTLPAREN   mDOCOL
            .word   CAPS_OFF
            .word   lit,')',WORDD
            .word   CAPS_ON
            .word   COUNT,TYPE
            .word   EXIT
    .ELSE

; .(                \  --     dotparen ; type comment immediatly.
            FORTHWORDIMM ".\40"        ; immediate
DOTLPAREN   mDOCOL
            .word   lit,')',WORDD
            .word   COUNT,TYPE
            .word   EXIT
    .ENDIF ; LOWERCASE

;C SOURCE   -- adr u    current input buffer
            FORTHWORD "SOURCE"
            SUB     #4,PSP
            MOV     TOS,2(PSP)
            MOV     &SOURCE_LEN,TOS
            MOV     &SOURCE_ADR,0(PSP)
            mNEXT

; >BODY     -- PFA      leave PFA of created word
            FORTHWORD ">BODY"
            ADD     #4,TOS
            mNEXT
