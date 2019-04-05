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
u1u2MSTAR   PUSHM   #2,IP           ;           PUSHM IP,S
            ASMtoFORTH
            .word UMSTAR            ; UMSTAR use S,T,W,X,Y
            FORTHtoASM
            POPM    #2,IP           ;           POPM S,IP
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
            PUSHM  #2,S          ;4         PUSHM S,T
            CALL #MUSMOD
            MOV @PSP+,TOS
            POPM  #2,S          ;4          POPM T,S
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



;https://forth-standard.org/standard/core/ALIGNED
;C ALIGNED  addr -- a-addr       align given addr
            FORTHWORD "ALIGNED"
ALIGNED     BIT     #1,TOS
            ADDC    #0,TOS
            mNEXT

;https://forth-standard.org/standard/core/ALIGN
;C ALIGN    --                         align HERE
            FORTHWORD "ALIGN"
ALIGNN      BIT     #1,&DDP   ; 3
            ADDC    #0,&DDP   ; 4
            mNEXT

;https://forth-standard.org/standard/core/CHARS
;C CHARS    n1 -- n2            chars->adrs units
            FORTHWORD "CHARS"
            mNEXT

;https://forth-standard.org/standard/core/CHARPlus
;C CHAR+    c-addr1 -- c-addr2   add char size
            FORTHWORD "CHAR+"
            ADD     #1,TOS
            mNEXT

;https://forth-standard.org/standard/core/CELLS
;C CELLS    n1 -- n2            cells->adrs units
            FORTHWORD "CELLS"
            ADD     TOS,TOS
            mNEXT

;https://forth-standard.org/standard/core/CELLPlus
;C CELL+    a-addr1 -- a-addr2      add cell size
            FORTHWORD "CELL+"
            ADD     #2,TOS
            mNEXT

; https://forth-standard.org/standard/core/StoD
; S>D    n -- d          single -> double prec.
            FORTHWORD "S>D"
            SUB #2,PSP
            MOV TOS,0(PSP)
            JMP ZEROLESS

; https://forth-standard.org/standard/core/TwoFetch
; 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
            FORTHWORD "2@"
TWOFETCH    SUB     #2, PSP
            MOV     2(TOS),0(PSP)
            MOV     @TOS,TOS
            mNEXT

; https://forth-standard.org/standard/core/TwoStore
; 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
            FORTHWORD "2!"
TWOSTORE    MOV     @PSP+,0(TOS)
            MOV     @PSP+,2(TOS)
            MOV     @PSP+,TOS
            mNEXT

; https://forth-standard.org/standard/core/TwoDUP
; 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
            FORTHWORD "2DUP"
            SUB     #4,PSP          ; -- x1 x x x2
            MOV     TOS,2(PSP)      ; -- x1 x2 x x2
            MOV     4(PSP),0(PSP)   ; -- x1 x2 x1 x2
            mNEXT

; https://forth-standard.org/standard/core/TwoDROP
; 2DROP  x1 x2 --          drop 2 cells
            FORTHWORD "2DROP"
            ADD     #2,PSP
            MOV     @PSP+,TOS
            mNEXT

; https://forth-standard.org/standard/core/TwoSWAP
; 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
            FORTHWORD "2SWAP"
            MOV     @PSP,W          ; -- x1 x2 x3 x4    W=x3
            MOV     4(PSP),0(PSP)   ; -- x1 x2 x1 x4
            MOV     W,4(PSP)        ; -- x3 x2 x1 x4
            MOV     TOS,W           ; -- x3 x2 x1 x4    W=x4
            MOV     2(PSP),TOS      ; -- x3 x2 x1 x2    W=x4
            MOV     W,2(PSP)        ; -- x3 x4 x1 x2
            mNEXT

; https://forth-standard.org/standard/core/TwoOVER
; 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
            FORTHWORD "2OVER"
            SUB     #4,PSP          ; -- x1 x2 x3 x x x4
            MOV     TOS,2(PSP)      ; -- x1 x2 x3 x4 x x4
            MOV     8(PSP),0(PSP)   ; -- x1 x2 x3 x4 x1 x4
            MOV     6(PSP),TOS      ; -- x1 x2 x3 x4 x1 x2
            mNEXT

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
DOTPAREN    MOV #0,&CAPS
            mDOCOL
            .word   lit,')',WORDD
            .word   COUNT,TYPE
            .word   FBLANK,LIT,CAPS,STORE
            .word   EXIT

;https://forth-standard.org/standard/core/SOURCE
;C SOURCE   -- adr u    current input buffer
            FORTHWORD "SOURCE"
            SUB     #4,PSP
            MOV     TOS,2(PSP)
            MOV     &SOURCE_LEN,TOS
            MOV     &SOURCE_ORG,0(PSP)
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
