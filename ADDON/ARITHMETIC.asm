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


;https://forth-standard.org/standard/core/NIP
;CE NIP    x1 x2 -- x2
            FORTHWORD "NIP"
NIP         ADD     #2,PSP          ; 1
            mNEXT                   ; 4

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
            JGE     u1MSTARn2       ; yes
            XOR     #-1,0(PSP)      ; no : n1 --> u1
            ADD     #1,0(PSP)       ;
u1MSTARn2   CMP     #0,TOS          ; n2 > -1 ?
            JGE     u1MSTARu2       ; yes
            XOR     #-1,TOS         ; no : n2 --> u2 
            ADD     #1,TOS          ;
u1MSTARu2   
           .word    151Dh           ; -- ud1lo ud1hi adr count          PUSHM IP,S (1+1 push,IP=D)
            MOV     #MSTARud,IP
            MOV     #UMSTAR,PC      ; UMSTAR use S,T,W,X,Y
MSTARud     FORTHtoASM
           .word    171Ch           ; -- ud1lo ud1hi adr count          POPM S,IP (1+1 pop,S=C)
            CMP     #0,S            ; result > -1 ?
            JGE     MSTARend        ; yes
            XOR     #-1,0(PSP)      ; no : ud --> d
            XOR     #-1,TOS
            ADD     #1,0(PSP)
            ADDC    #0,TOS
MSTARend    mNEXT

    .ENDIF ;MPY

; TOS = DIVISOR
; S   = DIVIDENDlo
; W   = DIVIDENDhi
; X   = count
; Y   = QUOTIENT
; T.I. UNSIGNED DIVISION SUBROUTINE 32-BIT BY 16-BIT
; DVDhi|DVDlo : DIVISOR -> QUOT in Y, REM in DVDhi
; RETURN: CARRY = 0: OK CARRY = 1: QUOTIENT > 16 BITS

;https://forth-standard.org/standard/core/UMDivMOD
;C UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->16
            FORTHWORD "UM/MOD"
UMSLASHMOD  MOV @PSP+,W     ;2 W = DIVIDENDhi
            MOV @PSP,S      ;2 S = DIVIDENDlo
            MOV #0,Y        ;1 CLEAR RESULT
            MOV #16,X       ;2 INITIALIZE LOOP COUNTER
DIV1:       CMP TOS,W       ;1 dividendHI-divisor
            JNC DIV2        ;2 jump if U<
            SUB TOS,W       ;1
DIV2:       ADDC Y,Y        ;1 RLC quotient
            SUB #1,X        ;1 Decrement loop counter
            JN DIV3         ;2 If 0< --> end
            ADD S,S         ;1 RLA
            ADDC W,W        ;1 RLC
            JNC DIV1        ;2 jump if U<   14~ loop
            SUB TOS,W       ;1
            BIS #1,SR       ;1 SETC
            JMP DIV2        ;2              14~ loop
DIV3        MOV W,0(PSP)    ;3 remainder on stack
            MOV Y,TOS       ;1 quotient in TOS
            mNEXT           ;4 23 words  240 cycles

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
           .word 151Dh          ;4  -- ud1lo ud1hi adr count          PUSHM IP,S (1+1 push,IP=D)
        MOV #SMSLASHREMu3u4,IP  ;2
            JMP UMSLASHMOD      ;2 UM/MOD use S,W,X,Y, not T
SMSLASHREMu3u4
            FORTHtoASM          ;240   -- u3 u4
           .word 171Ch          ;4  -- ud1lo ud1hi adr count          POPM S,IP (1+1 pop,S=C)
            CMP #0,T            ;1  -- u3 u4  T=rem_sign>=0?
            JGE SMSLASHREMn3u4  ;2           yes
            XOR #-1,0(PSP)      ;3
            ADD #1,0(PSP)       ;3
SMSLASHREMn3u4
            XOR S,T             ;1           S=divisor T=quot_sign
            CMP #0,T            ;1  -- n3 u4  T=quot_sign>=0?
            JGE SMSLASHREMn3n4  ;2           yes
            XOR #-1,TOS         ;1
            ADD #1,TOS          ;1
SMSLASHREMn3n4                  ;   -- n3 n4  S=divisor
            mNEXT               ;4 36 words

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



