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


    .IFNDEF ARITHMETIC
ARITHMETIC
    .ENDIF

;https://forth-standard.org/standard/core/StoD
;C S>D    n -- d          single -> double prec.
            FORTHWORD "S>D"
STOD:       SUB     #2,PSP
            MOV     TOS,0(PSP)
            JMP     ZEROLESS

    .IFDEF MPY

;https://forth-standard.org/standard/core/UMTimes
;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
            FORTHWORD "UM*"
UMSTAR      MOV @PSP,&MPY       ; Load 1st operand
            MOV TOS,&OP2        ; Load 2nd operand
            MOV &RES0,0(PSP)    ; low result on stack
            MOV &RES1,TOS       ; high result in TOS
            mNEXT

;https://forth-standard.org/standard/core/MTimes
;C M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
            FORTHWORD "M*"
MSTAR       MOV     @PSP,&MPYS
            MOV     TOS,&OP2
            MOV     &RES0,0(PSP)
            MOV     &RES1,TOS
            mNEXT

    .ELSE

;https://forth-standard.org/standard/core/MTimes
;C M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
            FORTHWORD "M*"
MSTAR:      MOV     TOS,S           ; TOS= n2
            XOR     @PSP,S          ; S contains sign of result
            CMP     #0,0(PSP)       ; n1 > -1 ?
            JGE     u1n2MSTAR       ; yes
            XOR     #-1,0(PSP)      ; no : n1 --> u1
            ADD     #1,0(PSP)       ;
u1n2MSTAR   CMP     #0,TOS          ; n2 <= -1 ?
            JGE     u1u2MSTAR       ; no
            XOR     #-1,TOS         ; y: n2 --> u2 
            ADD     #1,TOS          ;
u1u2MSTAR   ;.word   151Dh           ;           PUSHM IP,S (1+1 push,IP=0Dh)
            PUSHM   #2,IP
            ASMtoFORTH
            .word UMSTAR            ; UMSTAR use S,T,W,X,Y
            FORTHtoASM
;            .word   171Ch           ;           POPM S,IP (1+1 pop,S=0Ch)
            POPM  #2,IP
            CMP     #0,S            ; result > -1 ?
            JGE     MSTARend        ; yes
            XOR     #-1,0(PSP)      ; no : ud --> d
            XOR     #-1,TOS
            ADD     #1,0(PSP)
            ADDC    #0,TOS
MSTARend    mNEXT

    .ENDIF ;MPY

;https://forth-standard.org/standard/core/SMDivREM
;C SM/REM   d1lo d1hi n2 -- n3 n4  symmetric signed div
            FORTHWORD "SM/REM"
SMSLASHREM  MOV TOS,S           ;1            S=divisor
            MOV @PSP,T          ;2            T=rem_sign
            CMP #0,TOS          ;1            n2 >= 0 ?
            JGE d1u2SMSLASHREM  ;2            yes
            XOR #-1,TOS         ;1
            ADD #1,TOS          ;1
d1u2SMSLASHREM                  ;   -- d1 u2
            CMP #0,0(PSP)       ;3           d1hi >= 0 ?
            JGE ud1u2SMSLASHREM ;2           yes
            XOR #-1,2(PSP)      ;4           d1lo
            XOR #-1,0(PSP)      ;4           d1hi
            ADD #1,2(PSP)       ;4           d1lo+1
            ADDC #0,0(PSP)      ;4           d1hi+C
ud1u2SMSLASHREM                 ;   -- ud1 u2
;           .word 151Ch          ;4          PUSHM S,T (1+1 push,S=0Ch)
            PUSHM  #2,S
            CALL #MUSMOD
            MOV @PSP+,TOS
;           .word 171Bh          ;4          POPM T,S (1+1 pop,T=0Bh)
            POPM  #2,S
            CMP #0,T            ;1  -- ur uq  T=rem_sign>=0?
            JGE SMSLASHREMnruq  ;2           yes
            XOR #-1,0(PSP)      ;3
            ADD #1,0(PSP)       ;3
SMSLASHREMnruq
            XOR S,T             ;1           S=divisor T=quot_sign
            CMP #0,T            ;1  -- nr uq  T=quot_sign>=0?
            JGE SMSLASHREMnrnq  ;2           yes
NEGAT       XOR #-1,TOS         ;1
            ADD #1,TOS          ;1
SMSLASHREMnrnq                  ;   -- nr nq  S=divisor
            mNEXT               ;4 34 words

;https://forth-standard.org/standard/core/FMDivMOD
;C FM/MOD   d1 n1 -- r q   floored signed div'n
            FORTHWORD "FM/MOD"
FMSLASHMOD  PUSH    IP
            MOV     #FMSLASHMOD1,IP
            JMP     SMSLASHREM
FMSLASHMOD1 FORTHtoASM              ; -- remainder quotient       S=divisor
            CMP     #0,0(PSP)       ;
            JZ      FMSLASHMODEND
            CMP     #1,TOS          ; quotient < 1 ?
            JGE     FMSLASHMODEND   ;
QUOTLESSONE ADD     S,0(PSP)        ; add divisor to remainder
            SUB     #1,TOS          ; decrement quotient
FMSLASHMODEND
            MOV     @RSP+,IP
            mNEXT                   ;

;https://forth-standard.org/standard/core/NEGATE
;C NEGATE   x1 -- x2            two's complement
            FORTHWORD "NEGATE"
            JMP NEGAT 

;https://forth-standard.org/standard/core/ABS
;C ABS     n1 -- +n2     absolute value
            FORTHWORD "ABS"
ABBS        CMP     #0,TOS       ; 1
            JN      NEGAT 
            mNEXT

;https://forth-standard.org/standard/core/Times
;C *      n1 n2 -- n3       signed multiply
            FORTHWORD "*"
STAR:       mDOCOL
            .word   MSTAR,DROP,EXIT

;https://forth-standard.org/standard/core/DivMOD
;C /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
            FORTHWORD "/MOD"
SLASHMOD:   mDOCOL
            .word   TOR,STOD,RFROM,FMSLASHMOD,EXIT

;https://forth-standard.org/standard/core/Div
;C /      n1 n2 -- n3       signed divide
            FORTHWORD "/"
SLASH:      mDOCOL
            .word   TOR,STOD,RFROM,FMSLASHMOD,NIP,EXIT

;https://forth-standard.org/standard/core/MOD
;C MOD    n1 n2 -- n3       signed remainder
            FORTHWORD "MOD"
MODD:       mDOCOL
            .word   TOR,STOD,RFROM,FMSLASHMOD,DROP,EXIT

;https://forth-standard.org/standard/core/TimesDivMOD
;C */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
            FORTHWORD "*/MOD"
SSMOD:      mDOCOL
            .word   TOR,MSTAR,RFROM,FMSLASHMOD,EXIT

;https://forth-standard.org/standard/core/TimesDiv
;C */     n1 n2 n3 -- n4        n1*n2/n3
            FORTHWORD "*/"
STARSLASH   mDOCOL
            .word   TOR,MSTAR,RFROM,FMSLASHMOD,NIP,EXIT



