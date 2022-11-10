; -*- coding: utf-8 -*-

    FORTHWORD "{CORE_ANS}"
    MOV @IP+,PC

            FORTHWORD "ABORT"
            MOV #ABORT,PC

            FORTHWORD "QUIT"
            MOV #QUIT,PC

;-------------------------------------------------------------------------------
; COMPARAISON OPERATIONS
;-------------------------------------------------------------------------------
            FORTHWORD "0<"
; https://forth-standard.org/standard/core/Zeroless
; 0<     n -- flag      true if TOS negative
ZLESS       ADD TOS,TOS     ;1 set carry if TOS negative
            SUBC TOS,TOS    ;1 TOS=-1 if carry was clear
EQUALTRUE   XOR #-1,TOS     ;1 TOS=-1 if carry was set
            MOV @IP+,PC     ;

; https://forth-standard.org/standard/core/ZeroEqual
; 0=     n/u -- flag    return true if TOS=0
            FORTHWORD "0="
            SUB #1,TOS      ; borrow (clear cy) if TOS was 0
            SUBC TOS,TOS    ; TOS=-1 if borrow was set
            MOV @IP+,PC

            FORTHWORD "0<>"
; https://forth-standard.org/standard/core/Zerone
; 0<>     n/u -- flag    return true if TOS<>0
            SUB #1,TOS      ; 1 borrow (clear cy) if TOS was 0
            SUBC TOS,TOS    ; 1 TOS=-1 if borrow was set
            XOR #-1,TOS     ; 1
            MOV @IP+,PC

            FORTHWORD "="
; https://forth-standard.org/standard/core/Equal
; =      x1 x2 -- flag         test x1=x2
EQUAL       SUB @PSP+,TOS   ;2
            JZ EQUALTRUE    ;2 flag Z will be = 0
            AND #0,TOS      ;1 flag Z = 1
            MOV @IP+,PC     ;4

        .IFNDEF LESS
            FORTHWORD "<"
;https://forth-standard.org/standard/core/less
;C <      n1 n2 -- flag        test n1<n2, signed
LESS        SUB @PSP+,TOS   ;1 TOS=n2-n1
            JZ LESSEND      ;2 flag Z = 1
            JL TOSFALSE     ;2 signed jump
TOSTRUE     MOV #-1,TOS     ;1 flag Z = 0
LESSEND     MOV @IP+,PC     ;4

            FORTHWORD ">"
;https://forth-standard.org/standard/core/more
;C >     n1 n2 -- flag         test n1>n2, signed
MORE        SUB @PSP+,TOS   ;2 TOS=n2-n1
            JL TOSTRUE      ;2 --> +5
TOSFALSE    AND #0,TOS      ;1 flag Z = 1
            MOV @IP+,PC     ;4

        .ENDIF
        .IFNDEF ULESS
; https://forth-standard.org/standard/core/Uless
; U<    u1 u2 -- flag       test u1<u2, unsigned
            FORTHWORD "U<"
ULESS       SUB @PSP+,TOS   ; 2 u2-u1
            JZ  UTOSEND
            JNC UTOSFALSE
UTOSTRUE    MOV #-1,TOS     ;1 flag Z = 0
UTOSEND     MOV @IP+,PC     ;4

; https://forth-standard.org/standard/core/Umore
; U>     n1 n2 -- flag
            FORTHWORD "U>"
            SUB @PSP+,TOS   ; 2
            JNC UTOSTRUE    ; 2 flag = true, Z = 0
UTOSFALSE   AND #0,TOS      ;1 flag Z = 1
            MOV @IP+,PC     ;4

        .ENDIF
;-------------------------------------------------------------------------------
; STACK OPERATIONS
;-------------------------------------------------------------------------------
        .IFNDEF QDUP
; https://forth-standard.org/standard/core/DUP
; DUP      x -- x x      duplicate top of stack
            FORTHWORD "DUP"
QDUPNEXT    SUB #2,PSP      ; 2  push old TOS..
            MOV TOS,0(PSP)  ; 3  ..onto stack
QDUPEND     MOV @IP+,PC     ; 4

; https://forth-standard.org/standard/core/qDUP
; ?DUP     x -- 0 | x x    DUP if nonzero
            FORTHWORD "?DUP"
QDUP        CMP #0,TOS
            JNZ QDUPNEXT
            JZ QDUPEND

        .ENDIF
; https://forth-standard.org/standard/core/SWAP
; SWAP     x1 x2 -- x2 x1    swap top two items
            FORTHWORD "SWAP"
            MOV @PSP,W      ; 2
            MOV TOS,0(PSP)  ; 3
            MOV W,TOS       ; 1
            MOV @IP+,PC     ; 4

            FORTHWORD "DROP"
; https://forth-standard.org/standard/core/DROP
; DROP     x --          drop top of stack
DROP1       MOV @PSP+,TOS   ; 2
            MOV @IP+,PC     ; 4

        .IFNDEF OVER
;https://forth-standard.org/standard/core/OVER
;C OVER    x1 x2 -- x1 x2 x1
            FORTHWORD "OVER"
OVER        MOV TOS,-2(PSP)     ; 3 -- x1 (x2) x2
            MOV @PSP,TOS        ; 2 -- x1 (x2) x1
            SUB #2,PSP          ; 1 -- x1 x2 x1
            MOV @IP+,PC               ; 4

        .ENDIF
            FORTHWORD "NIP"
; https://forth-standard.org/standard/core/NIP
; NIP      x1 x2 -- x2         Drop the first item below the top of stack
NIP1        ADD #2,PSP      ; 1
            MOV @IP+,PC     ; 4

            FORTHWORD "ROT"
;https://forth-standard.org/standard/core/ROT
;C ROT    x1 x2 x3 -- x2 x3 x1
ROT         MOV @PSP,W      ; 2 fetch x2
            MOV TOS,0(PSP)  ; 3 store x3
            MOV 2(PSP),TOS  ; 3 fetch x1
            MOV W,2(PSP)    ; 3 store x2
            MOV @IP+,PC     ; 4

; https://forth-standard.org/standard/core/Rfrom
; R>    -- x    R: x --   pop from return stack
            FORTHWORD "R>"
RFROM1      SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3
            MOV @RSP+,TOS   ; 2
            MOV @IP+,PC     ; 4

            FORTHWORD "R@"
;https://forth-standard.org/standard/core/RFetch
;C R@    -- x     R: x -- x   fetch from rtn stk
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV @RSP,TOS
            MOV @IP+,PC

    .IFNDEF TOR
; https://forth-standard.org/standard/core/toR
; >R    x --   R: -- x   push to return stack
            FORTHWORD ">R"
TOR         PUSH TOS
            MOV @PSP+,TOS
            MOV @IP+,PC

    .ENDIF
; https://forth-standard.org/standard/core/TUCK
; TUCK  ( x1 x2 -- x2 x1 x2 )
            FORTHWORD "TUCK"
            mDOCOL
            .word SWAP,OVER,EXIT

; https://forth-standard.org/standard/core/DEPTH
; DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
            FORTHWORD "DEPTH"
            MOV TOS,-2(PSP)
            MOV #PSTACK,TOS
            SUB PSP,TOS     ; PSP-S0--> TOS
            RRA TOS         ; TOS/2   --> TOS
            SUB #2,PSP      ; post decrement stack...
            MOV @IP+,PC

;-------------------------------------------------------------------------------
; RETURN from high level word
;-------------------------------------------------------------------------------
            FORTHWORD "EXIT"
; https://forth-standard.org/standard/core/EXIT
; EXIT     --      exit a colon definition; CALL #EXIT performs mASM2FORTH (10 cycles)
;                                           JMP #EXIT performs EXIT
            MOV @RSP+,IP    ; 2 pop previous IP (or next PC) from return stack
            MOV @IP+,PC     ; 4 = NEXT
                            ; 6 (ITC-2)

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
SPACESNEXT  mNEXTADR
            SUB #2,IP               ;1
            SUB #1,TOS              ;1
            JNZ SPACE               ;25~ ==> 27~ by space ==> 2.963 MBds @ 8 MHz
            MOV @RSP+,IP            ;
SPACESNEXT2 MOV @PSP+,TOS           ; --         drop n
            MOV @IP+,PC             ;

        .ENDIF
        .IFNDEF CR
            FORTHWORD "CR"
; https://forth-standard.org/standard/core/CR
; CR      --               send CR to the output device
CR          MOV @PC+,PC
            .word BODYCR
BODYCR      mDOCOL                  ;  send CR+LF to the default output device
            .word   LIT,0Dh,EMIT
            .word   LIT,0Ah,EMIT
            .word   EXIT

        .ENDIF
;-------------------------------------------------------------------------------
; ARITHMETIC OPERATIONS
;-------------------------------------------------------------------------------

        .IFNDEF ANDD
;https://forth-standard.org/standard/core/AND
;C AND    x1 x2 -- x3           logical AND
            FORTHWORD "AND"
ANDD        AND @PSP+,TOS
            MOV @IP+,PC

        .ENDIF
;https://forth-standard.org/standard/core/OR
;C OR     x1 x2 -- x3           logical OR
            FORTHWORD "OR"
ORR         BIS @PSP+,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/XOR
;C XOR    x1 x2 -- x3           logical XOR
            FORTHWORD "XOR"
XORR        XOR @PSP+,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/INVERT
;C INVERT   x1 -- x2            bitwise inversion
            FORTHWORD "INVERT"
            XOR #-1,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/LSHIFT
;C LSHIFT  x1 u -- x2    logical L shift u places
            FORTHWORD "LSHIFT"
LSHIFT      MOV @PSP+,W
            AND #1Fh,TOS        ; no need to shift more than 16
            JZ LSH_X
LSH_1       ADD W,W
            SUB #1,TOS
            JNZ LSH_1
LSH_X       MOV W,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/RSHIFT
;C RSHIFT  x1 u -- x2    logical R shift u places
            FORTHWORD "RSHIFT"
RSHIFT      MOV @PSP+,W
            AND #1Fh,TOS        ; no need to shift more than 16
            JZ RSH_X
RSH_1       BIC #1,SR           ; CLRC
            RRC W
            SUB #1,TOS
            JNZ RSH_1
RSH_X       MOV W,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/TwoTimes
;C 2*      x1 -- x2         arithmetic left shift
            FORTHWORD "2*"
TWOTIMES    ADD TOS,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/TwoDiv
;C 2/      x1 -- x2        arithmetic right shift
            FORTHWORD "2/"
TWODIV      RRA TOS
            MOV @IP+,PC

        .IFNDEF MAX
;https://forth-standard.org/standard/core/MAX
;C MAX    n1 n2 -- n3       signed maximum
            FORTHWORD "MAX"
MAX         CMP @PSP,TOS    ; n2-n1
            JL SELn1        ; n2<n1
SELn2       ADD #2,PSP
            MOV @IP+,PC

;https://forth-standard.org/standard/core/MIN
;C MIN    n1 n2 -- n3       signed minimum
            FORTHWORD "MIN"
MIN         CMP @PSP,TOS    ; n2-n1
            JL SELn2        ; n2<n1
SELn1       MOV @PSP+,TOS
            MOV @IP+,PC

        .ENDIF
            FORTHWORD "1+"
; https://forth-standard.org/standard/core/OnePlus
; 1+      n1/u1 -- n2/u2       add 1 to TOS
            ADD #1,TOS
            MOV @IP+,PC

            FORTHWORD "1-"
; https://forth-standard.org/standard/core/OneMinus
; 1-      n1/u1 -- n2/u2     subtract 1 from TOS
ONEMINUS1   SUB #1,TOS
            MOV @IP+,PC

            FORTHWORD "+"
;https://forth-standard.org/standard/core/Plus
;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
            ADD @PSP+,TOS
            MOV @IP+,PC

; https://forth-standard.org/standard/core/Minus
; -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
            FORTHWORD "-"
            SUB @PSP+,TOS   ; 2  -- n2-n1 ( = -n3)
            XOR #-1,TOS     ; 1
            ADD #1,TOS      ; 1  -- n3 = -(n2-n1) = n1-n2
            MOV @IP+,PC

    .IFDEF MPY
;https://forth-standard.org/standard/core/UMTimes
;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
            FORTHWORD "UM*"
UMSTAR      MOV @PSP,&MPY       ; Load 1st operand
            MOV TOS,&OP2        ; Load 2nd operand
            MOV &RES0,0(PSP)    ; low result on stack
            MOV &RES1,TOS       ; high result in TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/MTimes
;C M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
            FORTHWORD "M*"
MSTAR       MOV @PSP,&MPYS
            MOV TOS,&OP2
            MOV &RES0,0(PSP)
            MOV &RES1,TOS
            MOV @IP+,PC

    .ELSE

        .IFNDEF UMSTAR
            FORTHWORD "UM*"
; T.I. UNSIGNED MULTIPLY SUBROUTINE: U1 x U2 -> Ud
; https://forth-standard.org/standard/core/UMTimes
; UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
UMSTAR      MOV @PSP,S          ;2 ud1lo
UMSTAR1     MOV #0,T            ;1 ud1hi=0
            MOV #0,X            ;1 RESlo=0
            MOV #0,Y            ;1 REShi=0
            MOV #1,W            ;1 BIT TEST REGISTER
UMSTARLOOP  BIT W,TOS           ;1 TEST ACTUAL BIT MRlo
            JZ UMSTARNEXT       ;2 IF 0: DO NOTHING
            ADD S,X             ;1 IF 1: ADD ud1lo TO RESlo
            ADDC T,Y            ;1      ADDC ud1hi TO REShi
UMSTARNEXT  ADD S,S             ;1 (RLA LSBs) ud1lo x 2
            ADDC T,T            ;1 (RLC MSBs) ud1hi x 2
            ADD W,W             ;1 (RLA) NEXT BIT TO TEST
            JNC UMSTARLOOP      ;2 IF BIT IN CARRY: FINISHED    10~ loop
            MOV X,0(PSP)        ;3 low result on stack
            MOV Y,TOS           ;1 high result in TOS
            MOV @IP+,PC         ;4 17 words
        .ENDIF


;https://forth-standard.org/standard/core/MTimes
;C M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
            FORTHWORD "M*"
MSTAR       MOV TOS,S           ; TOS= n2
            XOR @PSP,S          ; S contains sign of result
            CMP #0,0(PSP)       ; n1 > -1 ?
            JGE u1n2MSTAR       ; yes
            XOR #-1,0(PSP)      ; no : n1 --> u1
            ADD #1,0(PSP)       ;
u1n2MSTAR   CMP #0,TOS          ; n2 <= -1 ?
            JGE u1u2MSTAR       ; no
            XOR #-1,TOS         ; y: n2 --> u2
            ADD #1,TOS          ;
u1u2MSTAR   PUSHM #2,IP         ;           PUSHM IP,S
            mASM2FORTH
            .word UMSTAR        ; UMSTAR use S,T,W,X,Y
            mNEXTADR
            POPM #2,IP          ;           POPM S,IP
            CMP #0,S            ; result > -1 ?
            JGE MSTARend        ; yes
            XOR #-1,0(PSP)      ; no : ud --> d
            XOR #-1,TOS
            ADD #1,0(PSP)
            ADDC #0,TOS
MSTARend    MOV @IP+,PC

    .ENDIF ;MPY

;https://forth-standard.org/standard/core/UMDivMOD
; UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
            FORTHWORD "UM/MOD"
UMSLASHMOD  PUSH #DROP          ;3 as return address for MU/MOD
            MOV #MUSMOD,PC

    .IFNDEF FLOORED_DIVISION
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
            MOV @IP+,PC         ;4 34 words

        .ELSE   ; FLOORED_DIVISION
;https://forth-standard.org/standard/core/FMDivMOD
;C FM/MOD   d1 n1 -- r q   floored signed div'n
            FORTHWORD "FM/MOD"
FMSLASHMOD  MOV TOS,S           ;1            S=divisor
            MOV @PSP,T          ;2            T=rem_sign
            CMP #0,TOS          ;1            n2 >= 0 ?
            JGE d1u2FMSLASHMOD  ;2            yes
            XOR #-1,TOS         ;1
            ADD #1,TOS          ;1
d1u2FMSLASHMOD                  ;   -- d1 u2
            CMP #0,0(PSP)       ;3           d1hi >= 0 ?
            JGE ud1u2FMSLASHMOD ;2           yes
            XOR #-1,2(PSP)      ;4           d1lo
            XOR #-1,0(PSP)      ;4           d1hi
            ADD #1,2(PSP)       ;4           d1lo+1
            ADDC #0,0(PSP)      ;4           d1hi+C
ud1u2FMSLASHMOD                 ;   -- ud1 u2
            PUSHM  #2,S          ;4         PUSHM S,T
            CALL #MUSMOD
            MOV @PSP+,TOS
            POPM  #2,S          ;4          POPM T,S
            CMP #0,T            ;1  -- ur uq  T=rem_sign>=0?
            JGE FMSLASHMODnruq  ;2           yes
            XOR #-1,0(PSP)      ;3
            ADD #1,0(PSP)       ;3
FMSLASHMODnruq
            XOR S,T             ;1           S=divisor T=quot_sign
            CMP #0,T            ;1  -- nr uq  T=quot_sign>=0?
            JGE FMSLASHMODnrnq  ;2           yes
NEGAT       XOR #-1,TOS         ;1
            ADD #1,TOS          ;1
FMSLASHMODnrnq                  ;   -- nr nq  S=divisor

            CMP #0,0(PSP)       ;
            JZ FMSLASHMODEND
            CMP #1,TOS          ; quotient < 1 ?
            JGE FMSLASHMODEND   ;
QUOTLESSONE ADD S,0(PSP)        ; add divisor to remainder
            SUB #1,TOS          ; decrement quotient
FMSLASHMODEND
            MOV @RSP+,IP
            MOV @IP+,PC         ;
        .ENDIF

;https://forth-standard.org/standard/core/NEGATE
;C NEGATE   x1 -- x2            two's complement
            FORTHWORD "NEGATE"
            JMP NEGAT

;https://forth-standard.org/standard/core/ABS
;C ABS     n1 -- +n2     absolute value
            FORTHWORD "ABS"
            CMP #0,TOS           ; 1
            JN NEGAT
            MOV @IP+,PC

;https://forth-standard.org/standard/core/Times
;C *      n1 n2 -- n3       signed multiply
            FORTHWORD "*"
STAR        mDOCOL
            .word   MSTAR,DROP,EXIT

;https://forth-standard.org/standard/core/DivMOD
;C /MOD   n1 n2 -- n3 n4    signed divide/rem'dr
            FORTHWORD "/MOD"
SLASHMOD    mDOCOL
            .word   TOR,STOD,RFROM
        .IFNDEF FLOORED_DIVISION
            .word SMSLASHREM
        .ELSE
            .word FMSLASHMOD
        .ENDIF
            .word EXIT

;https://forth-standard.org/standard/core/Div
;C /      n1 n2 -- n3       signed divide
            FORTHWORD "/"
SLASH       mDOCOL
            .word   TOR,STOD,RFROM
        .IFNDEF FLOORED_DIVISION
            .word SMSLASHREM
        .ELSE
            .word FMSLASHMOD
        .ENDIF
            .word NIP,EXIT

;https://forth-standard.org/standard/core/MOD
;C MOD    n1 n2 -- n3       signed remainder
            FORTHWORD "MOD"
MODD        mDOCOL
            .word   TOR,STOD,RFROM
        .IFNDEF FLOORED_DIVISION
            .word SMSLASHREM
        .ELSE
            .word FMSLASHMOD
        .ENDIF
            .word DROP,EXIT

;https://forth-standard.org/standard/core/TimesDivMOD
;C */MOD  n1 n2 n3 -- n4 n5    n1*n2/n3, rem&quot
            FORTHWORD "*/MOD"
SSMOD       mDOCOL
            .word   TOR,MSTAR,RFROM
        .IFNDEF FLOORED_DIVISION
            .word SMSLASHREM
        .ELSE
            .word FMSLASHMOD
        .ENDIF
            .word EXIT

;https://forth-standard.org/standard/core/TimesDiv
;C */     n1 n2 n3 -- n4        n1*n2/n3
            FORTHWORD "*/"
STARSLASH   mDOCOL
            .word   TOR,MSTAR,RFROM
        .IFNDEF FLOORED_DIVISION
            .word SMSLASHREM
        .ELSE
            .word FMSLASHMOD
        .ENDIF
            .word NIP,EXIT

;----------------------------------------------------------------------
; DOUBLE OPERATORS
;----------------------------------------------------------------------

; https://forth-standard.org/standard/core/StoD
; S>D    n -- d          single -> double prec.
            FORTHWORD "S>D"
STOD        SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #ZEROLESS,PC

; https://forth-standard.org/standard/core/TwoFetch
; 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
            FORTHWORD "2@"
TWOFETCH    SUB #2, PSP
            MOV 2(TOS),0(PSP)
            MOV @TOS,TOS
            MOV @IP+,PC

; https://forth-standard.org/standard/core/TwoStore
; 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
            FORTHWORD "2!"
TWOSTORE    MOV @PSP+,0(TOS)
            MOV @PSP+,2(TOS)
            MOV @PSP+,TOS
            MOV @IP+,PC

    .IFNDEF TWODUP
; https://forth-standard.org/standard/core/TwoDUP
; 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
            FORTHWORD "2DUP"
TWODUP      MOV TOS,-2(PSP)     ; 3
            MOV @PSP,-4(PSP)    ; 4
            SUB #4,PSP          ; 1
            MOV @IP+,PC         ; 4
    .ENDIF

; https://forth-standard.org/standard/core/TwoDROP
; 2DROP  x1 x2 --          drop 2 cells
            FORTHWORD "2DROP"
            ADD #2,PSP
            MOV @PSP+,TOS
            MOV @IP+,PC

; https://forth-standard.org/standard/core/TwoSWAP
; 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
            FORTHWORD "2SWAP"
            MOV @PSP,W          ; -- x1 x2 x3 x4    W=x3
            MOV 4(PSP),0(PSP)   ; -- x1 x2 x1 x4
            MOV W,4(PSP)        ; -- x3 x2 x1 x4
            MOV TOS,W           ; -- x3 x2 x1 x4    W=x4
            MOV 2(PSP),TOS      ; -- x3 x2 x1 x2    W=x4
            MOV W,2(PSP)        ; -- x3 x4 x1 x2
            MOV @IP+,PC

; https://forth-standard.org/standard/core/TwoOVER
; 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
            FORTHWORD "2OVER"
            SUB #4,PSP          ; -- x1 x2 x3 x x x4
            MOV TOS,2(PSP)      ; -- x1 x2 x3 x4 x x4
            MOV 8(PSP),0(PSP)   ; -- x1 x2 x3 x4 x1 x4
            MOV 6(PSP),TOS      ; -- x1 x2 x3 x4 x1 x2
            MOV @IP+,PC

;-------------------------------------------------------------------------------
; MEMORY OPERATIONS
;-------------------------------------------------------------------------------
        .IFNDEF CFETCH
;https://forth-standard.org/standard/core/CFetch
; C@     c-addr -- char   fetch char from memory
            FORTHWORD "C@"
CFETCH      MOV.B @TOS,TOS      ;2
            MOV @IP+,PC         ;4

        .ENDIF
        .IFNDEF CSTORE
;https://forth-standard.org/standard/core/CStore
; C!      char c-addr --    store char in memory
            FORTHWORD "C!"
            MOV.B @PSP+,0(TOS)  ;4
            ADD #1,PSP          ;1
            MOV @PSP+,TOS       ;2
            MOV @IP+,PC

        .ENDIF
        .IFNDEF CCOMMA
;https://forth-standard.org/standard/core/CComma
; C,   char --        append char
            FORTHWORD "C,"
            MOV &DP,W
            MOV.B TOS,0(W)
            ADD #1,&DP
            MOV @PSP+,TOS
            MOV @IP+,PC

        .ENDIF
;https://forth-standard.org/standard/core/PlusStore
;C +!     n/u a-addr --       add to memory
            FORTHWORD "+!"
PLUSSTORE   ADD @PSP+,0(TOS)
            MOV @PSP+,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/ALIGNED
;C ALIGNED  addr -- a-addr       align given addr
            FORTHWORD "ALIGNED"
            BIT #1,TOS
            ADDC #0,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/ALIGN
;C ALIGN    --                         align HERE
            FORTHWORD "ALIGN"
            BIT #1,&DP    ; 3
            ADDC #0,&DP   ; 4
            MOV @IP+,PC

;https://forth-standard.org/standard/core/CHARS
;C CHARS    n1 -- n2            chars->adrs units
            FORTHWORD "CHARS"
            MOV @IP+,PC

;https://forth-standard.org/standard/core/CHARPlus
;C CHAR+    c-addr1 -- c-addr2   add char size
            FORTHWORD "CHAR+"
            ADD #1,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/CELLS
;C CELLS    n1 -- n2            cells->adrs units
            FORTHWORD "CELLS"
            ADD TOS,TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/CELLPlus
;C CELL+    a-addr1 -- a-addr2      add cell size
            FORTHWORD "CELL+"
            ADD #2,TOS
            MOV @IP+,PC

; ------------------------------------------------------------------------------
; CONTROL STRUCTURES
; ------------------------------------------------------------------------------
; THEN and BEGIN compile nothing
; DO compile one word
; IF, ELSE, AGAIN, UNTIL, WHILE, REPEAT, LOOP & +LOOP compile two words
; LEAVE compile three words

            FORTHWORDIMM "IF"       ; immediate
; https://forth-standard.org/standard/core/IF
; IF       -- IFadr    initialize conditional forward branch
IFF         SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            MOV &DP,TOS            ; -- HERE
            ADD #4,&DP             ;           compile one word, reserve one word
            MOV #QFBRAN,0(TOS)      ; -- HERE   compile QFBRAN
            ADD #2,TOS              ; -- HERE+2=IFadr
            MOV @IP+,PC

            FORTHWORDIMM "ELSE"     ; immediate
; https://forth-standard.org/standard/core/ELSE
; ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
ELSS        ADD #4,&DP             ; make room to compile two words
            MOV &DP,W              ; W=HERE+4
            MOV #BRAN,-4(W)
            MOV W,0(TOS)            ; HERE+4 ==> [IFadr]
            SUB #2,W                ; HERE+2
            MOV W,TOS               ; -- ELSEadr
            MOV @IP+,PC

            FORTHWORDIMM "THEN"     ; immediate
; https://forth-standard.org/standard/core/THEN
; THEN     IFadr --                resolve forward branch
THEN        MOV &DP,0(TOS)         ; -- IFadr
            MOV @PSP+,TOS           ; --
            MOV @IP+,PC

            FORTHWORDIMM "BEGIN"    ; immediate
; https://forth-standard.org/standard/core/BEGIN
; BEGIN    -- BEGINadr             initialize backward branch
            MOV #HERE,PC            ; -- HERE

            FORTHWORDIMM "UNTIL"    ; immediate
; https://forth-standard.org/standard/core/UNTIL
; UNTIL    BEGINadr --             resolve conditional backward branch
UNTIL       MOV #QFBRAN,X
UNTIL1      ADD #4,&DP             ; compile two words
            MOV &DP,W              ; W = HERE
            MOV X,-4(W)             ; compile Bran or QFBRAN at HERE
            MOV TOS,-2(W)           ; compile bakcward adr at HERE+2
            MOV @PSP+,TOS
            MOV @IP+,PC

            FORTHWORDIMM "AGAIN"    ; immediate
; https://forth-standard.org/standard/core/AGAIN
;X AGAIN    BEGINadr --             resolve uncondionnal backward branch
AGAIN       MOV #BRAN,X
            JMP UNTIL1

            FORTHWORDIMM "WHILE"    ; immediate
; https://forth-standard.org/standard/core/WHILE
; WHILE    BEGINadr -- WHILEadr BEGINadr
WHILE       mDOCOL
            .word   IFF,SWAP,EXIT

            FORTHWORDIMM "REPEAT"   ; immediate
; https://forth-standard.org/standard/core/REPEAT
; REPEAT   WHILEadr BEGINadr --     resolve WHILE loop
REPEAT      mDOCOL
            .word   AGAIN,THEN,EXIT

; Primitive XDO; compiled by DO
;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2      run-time code for DO
;                                               n1|u1=limit, n2|u2=index
XDO         MOV #8000h,X    ;2 compute 8000h-limit = "fudge factor"
            SUB @PSP+,X     ;2
            MOV TOS,Y       ;1 loop ctr = index+fudge
            ADD X,Y         ;1 Y = INDEX
            PUSHM #2,X      ;4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
            MOV @PSP+,TOS   ;2
            MOV @IP+,PC     ;4

            FORTHWORDIMM "DO"       ; immediate
; https://forth-standard.org/standard/core/DO
; DO       -- DOadr   L: -- 0
            SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            ADD #2,&DP             ;   make room to compile xdo
            MOV &DP,TOS            ; -- HERE+2
            MOV #XDO,-2(TOS)        ;   compile xdo
            ADD #2,&LEAVEPTR        ; -- HERE+2     LEAVEPTR+2
            MOV &LEAVEPTR,W         ;
            MOV #0,0(W)             ; -- HERE+2     L-- 0
            MOV @IP+,PC

    .IFNDEF II
            FORTHWORD "I"
; https://forth-standard.org/standard/core/I
; I        -- n   R: sys1 sys2 -- sys1 sys2
;                  get the innermost loop index
II          SUB #2,PSP              ;1 make room in TOS
            MOV TOS,0(PSP)          ;3
            MOV @RSP,TOS            ;2 index = loopctr - fudge
            SUB 2(RSP),TOS          ;3
            MOV @IP+,PC             ;4 13~

    .ENDIF
; Primitive XLOOP; compiled by LOOP
;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates, clean up the
; return stack and skip the branch.  Else take the inline branch.
; Note that LOOP terminates when index=8000h.
XLOOP       ADD #1,0(RSP)   ;4 increment INDEX
XLOOPNEXT   BIT #100h,SR    ;2 is overflow bit set?
            JZ XLOOPDO      ;2 no overflow = loop
            ADD #4,RSP      ;1 empties RSP
            ADD #2,IP       ;1 overflow = loop done, skip branch ofs
            MOV @IP+,PC     ;4 14~ taken or not taken xloop/loop
XLOOPDO     MOV @IP,IP
            MOV @IP+,PC     ;4 14~ taken or not taken xloop/loop


            FORTHWORDIMM "LOOP"     ; immediate
; https://forth-standard.org/standard/core/LOOP
; LOOP    DOadr --         L-- an an-1 .. a1 0
LOO         MOV #XLOOP,X
LOOPNEXT    ADD #4,&DP             ; make room to compile two words
            MOV &DP,W
            MOV X,-4(W)             ; xloop --> HERE
            MOV TOS,-2(W)           ; DOadr --> HERE+2
; resolve all "leave" adr
LEAVELOOP   MOV &LEAVEPTR,TOS       ; -- Adr of top LeaveStack cell
            SUB #2,&LEAVEPTR        ; --
            MOV @TOS,TOS            ; -- first LeaveStack value
            CMP #0,TOS              ; -- = value left by DO ?
            JZ LOOPEND
            MOV W,0(TOS)            ; move adr after loop as UNLOOP adr
            JMP LEAVELOOP
LOOPEND     MOV @PSP+,TOS
            MOV @IP+,PC

; Primitive XPLOOP; compiled by +LOOP
;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates, clean up the
; return stack and skip the branch. Else take the inline branch.
XPLOO       ADD TOS,0(RSP)  ;4 increment INDEX by TOS value
            MOV @PSP+,TOS   ;2 get new TOS, doesn't change flags
            JMP XLOOPNEXT   ;2

            FORTHWORDIMM "+LOOP"    ; immediate
; https://forth-standard.org/standard/core/PlusLOOP
; +LOOP   adrs --   L-- an an-1 .. a1 0
PLUSLOOP    MOV #XPLOO,X
            JMP LOOPNEXT

            FORTHWORDIMM "CASE"
; https://forth-standard.org/standard/core/CASE
; CASE      ; -- #of-1
            mDOCOL
            .word LIT,0
            .word EXIT

            FORTHWORDIMM "OF"
; https://forth-standard.org/standard/core/OF
; OF        ; #of-1 -- orgOF #of
            mDOCOL
            .word ONEPLUS           ; count OFs
            .word TOR               ; move off the stack in case the control-flow stack is the data stack.
            .word LIT,OVER,COMMA
            .word LIT,EQUAL,COMMA   ; copy and test case value
            .word IFF         	    ; add orig to control flow stack
            .word LIT,DROP,COMMA    ; discards case value if =
            .word RFROM             ; we can bring count back now
            .word EXIT

            FORTHWORDIMM "ENDOF"
; https://forth-standard.org/standard/core/ENDOF
; ENDOF     ; orgOF #of -- orgENDOF #of
            mDOCOL
            .word TOR                ; move off the stack in case the control-flow stack is the data stack.
            .word ELSS
            .word RFROM              ; we can bring count back now
            .word EXIT

            FORTHWORDIMM "ENDCASE"
; https://forth-standard.org/standard/core/ENDCASE
; ENDCASE   ; orgENDOF1..orgENDOFn #of --
            mDOCOL
            .word LIT,DROP,COMMA
            .word LIT,0,XDO
ENDCASELOOP .word THEN
            .word XLOOP,ENDCASELOOP
            .word EXIT

;https://forth-standard.org/standard/core/CHAR
;C CHAR   -- char           parse ASCII character
            FORTHWORD "CHAR"
CHARR       mDOCOL
            .word   BL,WORDD,ONEPLUS,CFETCH,EXIT

;https://forth-standard.org/standard/core/BracketCHAR
;C [CHAR]   --          compile character literal
            FORTHWORDIMM "[CHAR]"        ; immediate
            mDOCOL
            .word   CHARR
            .word   lit,lit,COMMA
            .word   COMMA,EXIT

            .IFNDEF MOVE
; https://forth-standard.org/standard/core/MOVE
; MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
            FORTHWORD "MOVE"
MOVE        MOV TOS,W           ; W = cnt
            MOV @PSP+,Y         ; Y = addr2 = dst
            MOV @PSP+,X         ; X = addr1 = src
            MOV @PSP+,TOS       ; pop new TOS
            CMP #0,W            ; count = 0 ?
            JZ MOVEND           ; if 0, already done !
            CMP X,Y             ; dst = src ?
            JZ MOVEND           ; already done !
            JC MOVEDOWN         ; U< if src > dst
MOVEUPLOOP  MOV.B @X+,0(Y)      ; copy W bytes
            ADD #1,Y
            SUB #1,W
            JNZ MOVEUPLOOP
            MOV @IP+,PC         ; out 1 of MOVE ====>
MOVEDOWN    ADD W,Y             ; copy W bytes beginning with the end
            ADD W,X
MOVEDOWNLOO SUB #1,X
            SUB #1,Y
            MOV.B @X,0(Y)
            SUB #1,W
            JNZ MOVEDOWNLOO
MOVEND      MOV @IP+,PC ; out 2 of MOVE ====>
            .ENDIF

;https://forth-standard.org/standard/core/FILL
;C FILL   c-addr u char --  fill memory with char
            FORTHWORD "FILL"
FILL        MOV @PSP+,X     ; count
            MOV @PSP+,W     ; address
            CMP #0,X
            JZ FILL_X
FILL_1      MOV.B TOS,0(W)    ; store char in memory
            ADD #1,W
            SUB #1,X
            JNZ FILL_1
FILL_X      MOV @PSP+,TOS   ; pop new TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/HEX
            FORTHWORD "HEX"
            MOV #16,&BASEADR
            MOV @IP+,PC

;https://forth-standard.org/standard/core/DECIMAL
            FORTHWORD "DECIMAL"
            MOV #10,&BASEADR
            MOV @IP+,PC

; https://forth-standard.org/standard/core/HERE
; HERE    -- addr      returns memory ptr
            FORTHWORD "HERE"
            MOV #HERE,PC

;https://forth-standard.org/standard/core/p
;C (                \  --     paren ; skip input until )
            FORTHWORDIMM "\40"      ; immediate
            mDOCOL
            .word   lit,')',WORDD,DROP,EXIT

;https://forth-standard.org/standard/core/Dotp
; .(                \  --     dotparen ; type comment immediatly.
            FORTHWORDIMM ".\40"        ; immediate
            MOV #0,T
            mDOCOL
            .word   lit,')',WORDD+4
            .word   COUNT,TYPE
            .word   EXIT

;https://forth-standard.org/standard/core/J
;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
            FORTHWORD "J"
JJ          SUB #2,PSP      ; make room in TOS
            MOV TOS,0(PSP)
            MOV 4(RSP),TOS  ; index = loopctr - fudge
            SUB 6(RSP),TOS
            MOV @IP+,PC

;https://forth-standard.org/standard/core/UNLOOP
;UNLOOP   --   R: sys1 sys2 --  drop loop parms
            FORTHWORD "UNLOOP"
UNLOOP      ADD #4,RSP
            MOV @IP+,PC

;https://forth-standard.org/standard/core/LEAVE
;C LEAVE    --    L: -- adrs
            FORTHWORDIMM "LEAVE"    ; immediate
LEAV        MOV &DP,W              ; compile three words
            MOV #UNLOOP,0(W)        ; [HERE] = UNLOOP
            MOV #BRAN,2(W)          ; [HERE+2] = BRAN
            ADD #6,&DP             ; [HERE+4] = After LOOP adr
            ADD #2,&LEAVEPTR
            ADD #4,W
            MOV &LEAVEPTR,X
            MOV W,0(X)              ; leave HERE+4 on LEAVEPTR stack
            MOV @IP+,PC

;https://forth-standard.org/standard/core/RECURSE
;C RECURSE  --      recurse to current definition (compile current definition)
            FORTHWORDIMM "RECURSE"  ; immediate
RECURSE     MOV &DP,X              ;
            MOV &LAST_CFA,0(X)      ;
            ADD #2,&DP             ;
            MOV @IP+,PC

            .IFNDEF TOBODY
; https://forth-standard.org/standard/core/toBODY
; >BODY     -- addr      leave BODY of a CREATEd word; also leave default ACTION-OF primary DEFERred word
            FORTHWORD ">BODY"
TOBODY      ADD #4,TOS
            MOV @IP+,PC

            .ENDIF
; https://forth-standard.org/standard/core/EXECUTE
; EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
            FORTHWORD "EXECUTE"
            PUSH TOS                ; 3 push xt
            MOV @PSP+,TOS           ; 2
            MOV @RSP+,PC            ; 4 xt --> PC

; https://forth-standard.org/standard/core/EVALUATE
; EVALUATE          ; i*x c-addr u -- j*x  interpret string
            FORTHWORD "EVALUATE"
            MOV #SOURCE_LEN,X       ; 2
            MOV @X+,S               ; 2 S = SOURCE_LEN
            MOV @X+,T               ; 2 T = SOURCE_ORG
            MOV @X+,W               ; 2 W = TOIN
            PUSHM #4,IP             ; 6 PUSHM IP,S,T,W
            mASM2FORTH
            .word   INTERPRET
            mNEXTADR
            MOV @RSP+,&TOIN         ; 4
            MOV @RSP+,&SOURCE_ORG   ; 4
            MOV @RSP+,&SOURCE_LEN   ; 4
            MOV @RSP+,IP
            MOV @IP+,PC

;https://forth-standard.org/standard/core/SOURCE
;C SOURCE   -- adr u   of  current input buffer
            FORTHWORD "SOURCE"
            SUB #4,PSP
            MOV TOS,2(PSP)
            MOV &SOURCE_LEN,TOS
            MOV &SOURCE_ORG,0(PSP)
            MOV @IP+,PC

;https://forth-standard.org/standard/core/STATE
;C STATE   -- a-addr       holds compiler state
            FORTHWORD "STATE"
            CALL rDOCON
            .word   STATE   ; VARIABLE address in RAM space

;https://forth-standard.org/standard/core/BASE
;C BASE    -- a-addr       holds conversion radix
            FORTHWORD "BASE"
            CALL rDOCON
            .word   BASEADR    ; VARIABLE address in RAM space

;https://forth-standard.org/standard/core/toIN
;C >IN     -- a-addr       holds offset in input stream
            FORTHWORD ">IN"
FTOIN       CALL rDOCON
            .word   TOIN    ; VARIABLE address in RAM space

; https://forth-standard.org/standard/core/BL
; BL      -- char            an ASCII space
            FORTHWORD "BL"
            CALL rDOCON
            .word 20h

    .IFNDEF PAD
;https://forth-standard.org/standard/core/PAD
; PAD           --  pad address
            FORTHWORD "PAD"
PAD         CALL rDOCON
            .WORD    PAD_ORG

    .ENDIF
; https://forth-standard.org/standard/core/VARIABLE
; VARIABLE <name>       --                      define a Forth VARIABLE
            FORTHWORD "VARIABLE"
            mDOCOL
            .word   CREATE
            mNEXTADR
            MOV #DOVAR,-4(W)        ;   CFA = CALL rDOVAR
            MOV @RSP+,IP
            MOV @IP+,PC

; https://forth-standard.org/standard/core/CONSTANT
; CONSTANT <name>     n --                      define a Forth CONSTANT
            FORTHWORD "CONSTANT"
            mDOCOL
            .word   CREATE
            mNEXTADR
            MOV TOS,-2(W)           ;   PFA = n
            MOV @PSP+,TOS
            MOV @RSP+,IP
            MOV @IP+,PC

; https://forth-standard.org/standard/core/DEFER
; Skip leading space delimiters. Parse name delimited by a space.
; Create a definition for name with the execution semantics defined below.
;
; name Execution:   --
; Execute the xt that name is set to execute, i.e. NEXT (nothing),
; until the phrase ' word IS name is executed, causing a new value of xt to be assigned to name.
            FORTHWORD "DEFER"
            mDOCOL
            .word   CREATE
            mNEXTADR
            MOV #4030h,-4(W)        ;4 first CELL = MOV @PC+,PC = BR #addr
            MOV #NEXT_ADR,-2(W)     ;3 second CELL              =   ...mNEXT : do nothing by default
            MOV @RSP+,IP
            MOV @IP+,PC

    .IFNDEF TO
; https://forth-standard.org/standard/core/TO
; TO name Run-time: ( x -- )
; Assign the value x to named VALUE.
            FORTHWORD "TO"
            BIS #UF9,SR
            MOV @IP+,PC

    .ENDIF
; https://forth-standard.org/standard/core/VALUE
; ( x "<spaces>name" -- )                      define a Forth VALUE
; Skip leading space delimiters. Parse name delimited by a space.
; Create a definition for name with the execution semantics defined below,
; with an initial value equal to x.
;
; name Execution: ( -- x )
; Place x on the stack. The value of x is that given when name was created,
; until the phrase x TO name is executed, causing a new value of x to be assigned to name.
            FORTHWORD "VALUE"
            mDOCOL
            .word CREATE,COMMA
            .word DOES
            mNEXTADR
            MOV @RSP+,IP
            BIT #UF9,SR         ; see TO
            JNZ STOREVALUE
            MOV @TOS,TOS        ; execute Fetch
            MOV @IP+,PC
STOREVALUE  BIC #UF9,SR         ; clear 'TO' flag
            MOV @PSP+,0(TOS)    ; 4 execute Store
            MOV @PSP+,TOS       ; 2
            MOV @IP+,PC         ; 4
