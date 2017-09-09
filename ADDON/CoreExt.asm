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

;https://forth-standard.org/standard/core/DotR
;CE .R

;https://forth-standard.org/standard/core/Zerone
;CE 0<>

;https://forth-standard.org/standard/core/Zeromore
;CE 0>

;https://forth-standard.org/standard/core/TwotoR
;CE 2>R

;https://forth-standard.org/standard/core/TwoRfrom
;CE 2R>

;https://forth-standard.org/standard/core/TwoRFetch
;CE 2R@

;https://forth-standard.org/standard/core/ColonNONAME
;CE :NONAME

;https://forth-standard.org/standard/core/ne
;CE <>

;https://forth-standard.org/standard/core/qDO
;CE ?DO

;https://forth-standard.org/standard/core/ACTION-OF
;CE ACTION-OF
;    STATE @ IF 
;        POSTPONE ['] POSTPONE DEFER@ 
;    ELSE 
;        ' DEFER@ 
;    THEN ; IMMEDIATE

        FORTHWORDIMM "ACTION-OF" 
        mDOCOL
        .word STATE,FETCH,QBRAN,AOF1 
        .word BRACKETTICK,COMMA,DEFER@,COMMA,EXIT
AOF1    .word TICK,DEFER@,EXIT 

;https://forth-standard.org/standard/core/BUFFERColon
;CE BUFFER:
        FORTHWORD "BUFFER" ; ( u "<name>" -- ; -- addr ) 
        mDOCOL
        .word CREATE,ALLOT,EXIT 

;Z (C")     -- c-addr run-time code for C"
; get address and length of string.
XCQUOTE:    SUB     #2,PSP          ; 1 -- x TOS      ; push old TOS on stack
            MOV     TOS,0(PSP)      ; 3 -- TOS x        ; and reserve one cell on stack
            MOV     IP,TOS          ; 2 -- c-addr       ;
            MOV.B   @IP+,W
            ADD     W,IP            ; 1 -- addr u       IP=addr+u=addr(end_of_string)
            BIT     #1,IP           ; 1 -- addr u       IP=addr+u   Carry set/clear if odd/even
            ADDC    #0,IP           ; 1 -- addr u       IP=addr+u aligned
            mNEXT                   ; 4  16~

;https://forth-standard.org/standard/core/Cq
;CE C"
            FORTHWORDIMM "C\34"        ; immediate
CQUOTE:     mDOCOL
            .word   lit,XCQUOTE,COMMA
            .word   BRAN,SQUOTE1

;https://forth-standard.org/standard/core/CASE
; CE CASE 

;https://forth-standard.org/standard/core/COMPILEComma
;CE COMPILE,
        FORTHWORD "COMPILE,"
        MOV #COMMA,PC

;https://forth-standard.org/standard/core/DEFERStore
;C DEFER!       xt CFA_DEFER --     ; store xt to the address after DODEFER
            FORTHWORD "DEFER!"
DEFERSTORE: MOV     @PSP+,2(TOS)    ; -- CFA_DEFER          xt --> [CFA_DEFER+2]
            MOV     @PSP+,TOS       ; --
            mNEXT

;https://forth-standard.org/standard/core/DEFERFetch
;CE DEFER@
        FORTHWORD "DEFER@"
DEFER@  ADD #2,TOS
        MNEXT

;https://forth-standard.org/standard/core/ENDCASE
;CE ENDCASE

;https://forth-standard.org/standard/core/ENDOF
;CE ENDOF

;https://forth-standard.org/standard/core/HOLDS
;CE HOLDS

;https://forth-standard.org/standard/core/MARKER
;CE MARKER

;https://forth-standard.org/standard/core/OF
;CE OF

;https://forth-standard.org/standard/core/PARSE
;CE PARSE

;https://forth-standard.org/standard/core/PARSE-NAME
;CE PARSE-NAME

;https://forth-standard.org/standard/core/PICK
;CE PICK

;https://forth-standard.org/standard/core/REFILL
;CE REFILL

;https://forth-standard.org/standard/core/RESTORE-INPUT
;CE RESTORE-INPUT

;https://forth-standard.org/standard/core/ROLL
;CE ROLL

;https://forth-standard.org/standard/core/SAVE-INPUT
;CE SAVE-INPUT

;https://forth-standard.org/standard/core/SOURCE-ID
;CE SOURCE-ID

;https://forth-standard.org/standard/core/Seq
;CE S\"

;https://forth-standard.org/standard/core/TO
;CE TO
        FORTHWORD "TO"
        MOV #IS,PC

;https://forth-standard.org/standard/core/TRUE
;CE TRUE

;https://forth-standard.org/standard/core/TUCK
;CE TUCK

;https://forth-standard.org/standard/core/UDotR
;CE U.R

;https://forth-standard.org/standard/core/Umore
;CE U>

;https://forth-standard.org/standard/core/UNUSED
;CE UNUSED  

;https://forth-standard.org/standard/core/VALUE
;CE VALUE
        FORTHWORD "VALUE"
        MOV #CONSTANT,PC

;https://forth-standard.org/standard/core/WITHIN
;CE WITHIN

;https://forth-standard.org/standard/core/BracketCOMPILE
;CE [COMPILE]


