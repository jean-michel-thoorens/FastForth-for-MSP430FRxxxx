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


    FORTHWORD "{ANS_COMP}"
    mNEXT

    .IFNDEF ARITHMETIC
    .include "ADDON/ARITHMETIC.asm"
    .ENDIF
    .IFNDEF ALIGNMENT
    .include "ADDON/ALIGNMENT.asm"
    .ENDIF
    .IFNDEF PORTABILITY
    .include "ADDON/PORTABILITY.asm"
    .ENDIF
    .IFNDEF DOUBLE
    .include "ADDON/DOUBLE.asm"
    .ENDIF

;https://forth-standard.org/standard/core/AND
;C AND    x1 x2 -- x3           logical AND
            FORTHWORD "AND"
ANDD        AND     @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/OR
;C OR     x1 x2 -- x3           logical OR
            FORTHWORD "OR"
ORR         BIS     @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/XOR
;C XOR    x1 x2 -- x3           logical XOR
            FORTHWORD "XOR"
XORR        XOR     @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/INVERT
;C INVERT   x1 -- x2            bitwise inversion
            FORTHWORD "INVERT"
INVERT      XOR     #-1,TOS
            mNEXT

;https://forth-standard.org/standard/core/LSHIFT
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

;https://forth-standard.org/standard/core/RSHIFT
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

;https://forth-standard.org/standard/core/TwoTimes
;C 2*      x1 -- x2         arithmetic left shift
            FORTHWORD "2*"
TWOTIMES    ADD     TOS,TOS
            mNEXT

;https://forth-standard.org/standard/core/TwoDiv
;C 2/      x1 -- x2        arithmetic right shift
            FORTHWORD "2/"
TWODIV      RRA     TOS
            mNEXT

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

;https://forth-standard.org/standard/core/PlusStore
;C +!     n/u a-addr --       add to memory
            FORTHWORD "+!"
PLUSSTORE   ADD     @PSP+,0(TOS)
            MOV     @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/CHAR
;C CHAR   -- char           parse ASCII character
            FORTHWORD "CHAR"
CHARR       mDOCOL
            .word   FBLANK,WORDD,ONEPLUS,CFETCH,EXIT

;https://forth-standard.org/standard/core/BracketCHAR
;C [CHAR]   --          compile character literal
            FORTHWORDIMM "[CHAR]"        ; immediate
BRACCHAR    mDOCOL
            .word   CHARR
            .word   lit,lit,COMMA
            .word   COMMA,EXIT

;https://forth-standard.org/standard/core/FILL
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

;https://forth-standard.org/standard/core/HEX
            FORTHWORD "HEX"
HEX         MOV     #16,&BASE
            mNEXT

;https://forth-standard.org/standard/core/DECIMAL
            FORTHWORD "DECIMAL"
DECIMAL     MOV     #10,&BASE
            mNEXT

;https://forth-standard.org/standard/core/p
;C (                \  --     paren ; skip input until )
            FORTHWORDIMM "\40"      ; immediate
PARENT       mDOCOL
            .word   lit,')',WORDD,DROP,EXIT

;https://forth-standard.org/standard/core/Dotp
; .(                \  --     dotparen ; type comment immediatly.
            FORTHWORDIMM ".\40"        ; immediate
DOTPAREN    mDOCOL

    .IFDEF LOWERCASE
            .word   CAPS_OFF
            .word   lit,')',WORDD
            .word   CAPS_ON
            .word   COUNT,TYPE
            .word   EXIT
    .ELSE

            .word   lit,')',WORDD
            .word   COUNT,TYPE
            .word   EXIT
    .ENDIF ; LOWERCASE

;https://forth-standard.org/standard/core/SOURCE
;C SOURCE   -- adr u    current input buffer
            FORTHWORD "SOURCE"
            SUB     #4,PSP
            MOV     TOS,2(PSP)
            MOV     &SOURCE_LEN,TOS
            MOV     &SOURCE_ADR,0(PSP)
            mNEXT

;https://forth-standard.org/standard/core/toIN
;C >IN     -- a-addr       holds offset in input stream
            FORTHWORD ">IN"
FTOIN       mDOCON
            .word   TOIN    ; VARIABLE address in RAM space


    .IFNDEF PAD
;https://forth-standard.org/standard/core/PAD
; PAD           --  pad address
            FORTHWORD "PAD"
PAD         mDOCON
            .WORD    PAD_ORG

    .ENDIF