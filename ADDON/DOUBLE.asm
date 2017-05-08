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


;C 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
            FORTHWORD "2@"
            SUB     #2, PSP
            MOV     2(TOS),0(PSP)
            MOV     @TOS,TOS
            mNEXT

;C 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
            FORTHWORD "2!"
            MOV     @PSP+,0(TOS)
            MOV     @PSP+,2(TOS)
            MOV     @PSP+,TOS
            mNEXT

;C 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
            FORTHWORD "2DUP"
            SUB     #4,PSP          ; -- x1 x x x2
            MOV     TOS,2(PSP)      ; -- x1 x2 x x2
            MOV     4(PSP),0(PSP)   ; -- x1 x2 x1 x2
            mNEXT

;C 2DROP  x1 x2 --          drop 2 cells
            FORTHWORD "2DROP"
            ADD     #2,PSP
            MOV     @PSP+,TOS
            mNEXT

;C 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
            FORTHWORD "2SWAP"
            MOV     @PSP,W          ; -- x1 x2 x3 x4    W=x3
            MOV     4(PSP),0(PSP)   ; -- x1 x2 x1 x4
            MOV     W,4(PSP)        ; -- x3 x2 x1 x4
            MOV     TOS,W           ; -- x3 x2 x1 x4    W=x4
            MOV     2(PSP),TOS      ; -- x3 x2 x1 x2    W=x4
            MOV     W,2(PSP)        ; -- x3 x4 x1 x2
            mNEXT

;C 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
            FORTHWORD "2OVER"
            SUB     #4,PSP          ; -- x1 x2 x3 x x x4
            MOV     TOS,2(PSP)      ; -- x1 x2 x3 x4 x x4
            MOV     8(PSP),0(PSP)   ; -- x1 x2 x3 x4 x1 x4
            MOV     6(PSP),TOS      ; -- x1 x2 x3 x4 x1 x2
            mNEXT
