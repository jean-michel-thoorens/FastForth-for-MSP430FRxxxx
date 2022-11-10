; -*- coding: utf-8 -*-
;
; to see kernel options, download FastForthSpecs.f
; FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, DOUBLE_INPUT
;
; TARGET SELECTION ( = the name of ;INC;target.pat file without the extension)
; MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
; MSP_EXP430FR4133  MSP_EXP430FR2433    CHIPSTICK_FR2433    MSP_EXP430FR2355
; LP_MSP430FR2476
;
; from scite editor : copy your target selection in (shift+F8) parameter 1:
;
; OR
;
; drag and drop this file onto SendSourceFileToTarget.bat
; then select your TARGET when asked.
;
;
; REGISTERS USAGE
; rDODOES to rEXIT must be saved before use and restored after
; scratch registers Y to S are free for use
; under interrupt, IP is free for use
;
; FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
;
; ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
;
; ASSEMBLER conditionnal usage with ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<
;

; -----------------------------------------------------
; DOUBLE.asm
; -----------------------------------------------------

    FORTHWORD "{DOUBLE}"
            MOV @IP+,PC

    .IFNDEF TOR
; https://forth-standard.org/standard/core/toR
; >R    x --   R: -- x   push to return stack
            FORTHWORD ">R"
TOR         PUSH TOS
            MOV @PSP+,TOS
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
        .IFNDEF ROT
;https://forth-standard.org/standard/core/ROT
;C ROT    x1 x2 x3 -- x2 x3 x1
            FORTHWORD "ROT"
ROT         MOV @PSP,W      ; 2 fetch x2
            MOV TOS,0(PSP)  ; 3 store x3
            MOV 2(PSP),TOS  ; 3 fetch x1
            MOV W,2(PSP)    ; 3 store x2
            MOV @IP+,PC     ; 4

        .ENDIF
    .IFNDEF SPACE
;https://forth-standard.org/standard/core/SPACE
;C SPACE   --               output a space
            FORTHWORD "SPACE"
SPACE       SUB #2,PSP              ;1
            MOV TOS,0(PSP)          ;3
            MOV #20h,TOS            ;2
            MOV #EMIT,PC            ;17~  23~

    .ENDIF
    .IFNDEF SPACES
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
    .IFNDEF TWOFETCH
; https://forth-standard.org/standard/core/TwoFetch
; 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
            FORTHWORD "2@"
TWOFETCH    SUB #2, PSP
            MOV 2(TOS),0(PSP)
            MOV @TOS,TOS
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TWOSTORE
; https://forth-standard.org/standard/core/TwoStore
; 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
            FORTHWORD "2!"
TWOSTORE    MOV @PSP+,0(TOS)
            MOV @PSP+,2(TOS)
            MOV @PSP+,TOS
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TWODUP
; https://forth-standard.org/standard/core/TwoDUP
; 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
            FORTHWORD "2DUP"
TWODUP      MOV TOS,-2(PSP)     ; 3
            MOV @PSP,-4(PSP)    ; 4
            SUB #4,PSP          ; 1
            MOV @IP+,PC         ; 4

    .ENDIF
    .IFNDEF TWODROP
; https://forth-standard.org/standard/core/TwoDROP
; 2DROP  x1 x2 --          drop 2 cells
            FORTHWORD "2DROP"
TWODROP     ADD #2,PSP
            MOV @PSP+,TOS
            MOV @IP+,PC
 
   .ENDIF
    .IFNDEF TWOSWAP
; https://forth-standard.org/standard/core/TwoSWAP
; 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
            FORTHWORD "2SWAP"
TWOSWAP     MOV @PSP,W          ; -- x1 x2 x3 x4    W=x3
            MOV 4(PSP),0(PSP)   ; -- x1 x2 x1 x4
            MOV W,4(PSP)        ; -- x3 x2 x1 x4
            MOV TOS,W           ; -- x3 x2 x1 x4    W=x4
            MOV 2(PSP),TOS      ; -- x3 x2 x1 x2    W=x4
            MOV W,2(PSP)        ; -- x3 x4 x1 x2
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TwoOVER
; https://forth-standard.org/standard/core/TwoOVER
; 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
            FORTHWORD "2OVER"
TwoOVER     SUB #4,PSP          ; -- x1 x2 x3 x x x4
            MOV TOS,2(PSP)      ; -- x1 x2 x3 x4 x x4
            MOV 8(PSP),0(PSP)   ; -- x1 x2 x3 x4 x1 x4
            MOV 6(PSP),TOS      ; -- x1 x2 x3 x4 x1 x2
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TWOTOR
; https://forth-standard.org/standard/core/TwotoR
; ( x1 x2 -- ) ( R: -- x1 x2 )   Transfer cell pair x1 x2 to the return stack.
            FORTHWORD "2>R"
TWOTOR      PUSH @PSP+
            PUSH TOS
            MOV @PSP+,TOS
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TWORFETCH
; https://forth-standard.org/standard/core/TwoRFetch
; ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 ) Copy cell pair x1 x2 from the return stack.
            FORTHWORD "2R@"
TWORFETCH   SUB #4,PSP
            MOV TOS,2(PSP)
            MOV @RSP,TOS
            MOV 2(RSP),0(PSP)
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TwoRfrom
; https://forth-standard.org/standard/core/TwoRfrom
; ( -- x1 x2 ) ( R: x1 x2 -- )  Transfer cell pair x1 x2 from the return stack
            FORTHWORD "2R>"
TWORFROM    SUB #4,PSP
            MOV TOS,2(PSP)
            MOV @RSP+,TOS
            MOV @RSP+,0(PSP)
            MOV @IP+,PC
    .ENDIF

; ===============================================
; DOUBLE word set
; ===============================================
    .IFNDEF DDOT
; ; https://forth-standard.org/standard/double/Dd
; ; D.     dlo dhi --           display d (signed)
;             FORTHWORD "D."
;             MOV TOS,S       ; S will be pushed as sign
;             MOV #UDOT+10,PC   ; U. + 10 = D.

; https://forth-standard.org/standard/double/Dd
; D.     dlo dhi --           display d (signed)
            FORTHWORD "D."
            MOV TOS,S               ;1 S will be pushed as sign by UDOTNEXT
            CMP #0,S                ;1
            JGE DDOTNEXT            ;2
            XOR #-1,0(PSP)          ;4
            XOR #-1,TOS             ;1
            ADD #1,0(PSP)           ;4
            ADDC #0,TOS             ;1
DDOTNEXT    MOV #UDOTNEXT,PC        ;3

    .ENDIF
    .IFNDEF TwoROT
; https://forth-standard.org/standard/double/TwoROT
; Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the top of the stack.
            FORTHWORD "2ROT"
TWOROT      MOV 8(PSP),X        ; 3
            MOV 6(PSP),Y        ; 3
            MOV 4(PSP),8(PSP)   ; 5
            MOV 2(PSP),6(PSP)   ; 5
            MOV @PSP,4(PSP)     ; 4
            MOV TOS,2(PSP)      ; 3
            MOV X,0(PSP)        ; 3
            MOV Y,TOS           ; 1
            MOV @IP+,PC

    .ENDIF
    .IFNDEF DtoS
; https://forth-standard.org/standard/double/DtoS
; D>S    d -- n          double prec -> single.
            FORTHWORD "D>S"
DTOS        MOV @PSP+,TOS
            MOV @IP+,PC

    .ENDIF
    .IFNDEF DZEQU
; https://forth-standard.org/standard/double/DZeroEqual
            FORTHWORD "D0="
DZEROEQUAL  ADD #2,PSP
            CMP #0,TOS
            MOV #0,TOS
            JNZ DSETFLAG
            CMP #0,-2(PSP)
            JNZ DSETFLAG
DTRUE       MOV #-1,TOS
DSETFLAG    AND #-1,TOS         ;  to set N, Z flags
            MOV @IP+,PC

; https://forth-standard.org/standard/double/DZeroless
            FORTHWORD "D0<"
DZEROLESS   ADD #2,PSP
            CMP #0,TOS
            MOV #0,TOS
            JGE DSETFLAG
            JL DTRUE

; https://forth-standard.org/standard/double/DEqual
            FORTHWORD "D="
            ADD #6,PSP          ; 2
            CMP TOS,-4(PSP)     ; 3 ud1H - ud2H
            MOV #0,TOS          ; 1
            JNZ DSETFLAG        ; 2
            CMP -6(PSP),-2(PSP) ; 4 ud1L - ud2L
            JZ DTRUE            ; 2
            JMP DSETFLAG

; https://forth-standard.org/standard/double/Dless
; flag is true if and only if d1 is less than d2
            FORTHWORD "D<"
DLESS       ADD #6,PSP          ; 2
            CMP TOS,-4(PSP)     ; 3 d1H - d2H
            MOV #0,TOS          ; 1
            JGE DLESS2          ; 2
DLESS1      MOV #-1,TOS         ;
DLESS2      JNZ DSETFLAG        ; 2
            CMP -6(PSP),-2(PSP) ; 4 d1L - d2L
            JNC DTRUE           ; 2
            JMP DSETFLAG        ; 2

; https://forth-standard.org/standard/double/DUless
; flag is true if and only if ud1 is less than ud2
            FORTHWORD "DU<"
DULESS      ADD #6,PSP          ; 2
            CMP TOS,-4(PSP)     ; 3 ud1H - ud2H
            MOV #0,TOS          ; 1
            JC DLESS2           ; 2
            JNC DLESS1

    .ENDIF ; DZEQU
    .IFNDEF DPlus
; https://forth-standard.org/standard/double/DPlus
            FORTHWORD "D+"
DPLUS       ADD @PSP+,2(PSP)
            ADDC @PSP+,TOS
            MOV @IP+,PC         ; 4

    .ENDIF
    .IFNDEF MPLUS
; https://forth-standard.org/standard/double/MPlus
            FORTHWORD "M+"
MPLUS       SUB #2,PSP
            CMP #0,TOS
            MOV TOS,0(PSP)
            MOV #-1,TOS
            JL DPLUS
            MOV #0,TOS
            JMP DPLUS

    .ENDIF
    .IFNDEF DMinus
; https://forth-standard.org/standard/double/DMinus
            FORTHWORD "D-"
            SUB @PSP+,2(PSP)
            SUBC TOS,0(PSP)
            MOV @PSP+,TOS
            MOV @IP+,PC         ; 4

    .ENDIF
    .IFNDEF DNEGATE
; https://forth-standard.org/standard/double/DNEGATE
            FORTHWORD "DNEGATE"
DNEGATE     XOR #-1,0(PSP)
            XOR #-1,TOS
            ADD #1,0(PSP)
            ADDC #0,TOS
            MOV @IP+,PC         ; 4

; https://forth-standard.org/standard/double/DABS
; DABS     d1 -- |d1|     absolute value
            FORTHWORD "DABS"
DABS        CMP #0,TOS       ;  1
            JL DNEGATE
            MOV @IP+,PC

    .ENDIF
    .IFNDEF DTwoDiv
; https://forth-standard.org/standard/double/DTwoDiv
            FORTHWORD "D2/"
DTWODIV     RRA TOS
            RRC 0(PSP)
            MOV @IP+,PC         ; 4

    .ENDIF
    .IFNDEF DTwoTimes
; https://forth-standard.org/standard/double/DTwoTimes
DTWOTIMES   FORTHWORD "D2*"
            ADD @PSP,0(PSP)
            ADDC TOS,TOS
            MOV @IP+,PC         ; 4

    .ENDIF
    .IFNDEF DMAX
; https://forth-standard.org/standard/double/DMAX
            FORTHWORD "DMAX"                ; -- d1 d2
            mDOCOL
            .word   TWOOVER,TWOOVER         ; -- d1 d2 d1 d2
            .word   DLESS,QFBRAN,DMAX1      ; -- d1 d2
            .word   TWOTOR,TWODROP,TWORFROM ; -- d2
            .word   BRAN,DMAX2              ; -- d1 d2
DMAX1       .word   TWODROP                 ; -- d1
DMAX2       .word   EXIT

    .ENDIF
    .IFNDEF DMIN
; https://forth-standard.org/standard/double/DMIN
            FORTHWORD "DMIN"                ; -- d1 d2
            mDOCOL
            .word   TWOOVER,TWOOVER         ; -- d1 d2 d1 d2
            .word   DLESS,QFBRAN,DMIN1      ; -- d1 d2
            .word   TWODROP                 ; -- d1
            .word   BRAN,DMIN2              ; -- d1 d2
DMIN1       .word   TWOTOR,TWODROP,TWORFROM ; -- d2
DMIN2       .word   EXIT

    .ENDIF
    .IFNDEF MTIMESDIV
;   https://forth-standard.org/standard/double/MTimesDiv
            FORTHWORD "M*/"                ; d1 * n1 / +n2 -- d2
MTIMESDIV   
        .IFDEF HMPY
            MOV 4(PSP),&MPYS32L     ; 5             Load 1st operand    d1lo
            MOV 2(PSP),&MPYS32H     ; 5                                 d1hi
            MOV @PSP+,&OP2          ; 4 -- d1 n2    load 2nd operand    n1
            MOV TOS,T               ; T = DIV
            NOP3
            MOV &RES0,S             ; 3 S = RESlo
            MOV &RES1,TOS           ; 3 TOS = RESmi
            MOV &RES2,W             ; 3 W = REShi
            MOV #0,rDOCON           ; clear sign flag
            CMP #0,W                ; negative product ?
            JGE MTIMESDIV1          ; no
            XOR #-1,S               ; compute ABS value if yes
            XOR #-1,TOS
            XOR #-1,W
            ADD #1,S
            ADDC #0,TOS
            ADDC #0,W
            MOV #-1,rDOCON          ; set sign flag
MTIMESDIV1
        .ELSE
            MOV #0,rDOCON           ; rDOCON = sign
            CMP #0,2(PSP)           ; d1 < 0 ?
            JGE MTIMESDIV2          ; no
            XOR #-1,4(PSP)          ; compute ABS value if yes
            XOR #-1,2(PSP)
            ADD #1,4(PSP)
            ADDC #0,2(PSP)
            MOV #-1,rDOCON
MTIMESDIV2                          ; ud1
            CMP #0,0(PSP)           ; n1 < 0 ?
            JGE MTIMESDIV3          ; no
            XOR #-1,0(PSP)
            ADD #1,0(PSP)           ; u1
            XOR #-1,rDOCON
; let's process UM*     -- ud1lo ud1hi u1 +n2
MTIMESDIV3  MOV 4(PSP),Y            ; 3 uMDlo
            MOV 2(PSP),T            ; 3 uMDhi
            MOV @PSP+,S             ; 2 uMRlo        -- ud1lo ud1hi +n2
            MOV #0,rDODOES          ; 1 uMDlo=0
            MOV #0,2(PSP)           ; 3 uRESlo=0
            MOV #0,0(PSP)           ; 3 uRESmi=0     -- uRESlo uRESmi +n2
            MOV #0,W                ; 1 uREShi=0
            MOV #1,X                ; 1 BIT TEST REGlo
MTIMESDIV4  BIT X,S                 ; 1 test actual bit in uMRlo
            JZ MTIMESDIV5
            ADD Y,2(PSP)            ; 3 IF 1: ADD uMDlo TO uRESlo
            ADDC T,0(PSP)           ; 3      ADDC uMDmi TO uRESmi
            ADDC rDODOES,W          ; 1      ADDC uMRlo TO uREShi
MTIMESDIV5  ADD Y,Y                 ; 1 (RLA LSBs) uMDlo *2
            ADDC T,T                ; 1 (RLC MSBs) uMDhi *2
            ADDC rDODOES,rDODOES    ; 1 (RLA LSBs) uMDlo *2
            ADD X,X                 ; 1 (RLA) NEXT BIT TO TEST
            JNC MTIMESDIV4          ; 1 IF BIT IN CARRY: FINISHED   W=uREShi
;           TOS     +n2
;           W       REShi
;           0(PSP)  RESmi
;           2(PSP)  RESlo
            MOV TOS,T
            MOV @PSP,TOS
            MOV 2(PSP),S
        .ENDIF  ; endcase of software/hardware_MPY
;           process division
;           reg     input           output
;           ------------------------------
;           S       = DVD(15-0)
;           TOS     = DVD(31-16)
;           W       = DVD(47-32)    REM
;           T       = DIV(15-0)
;           X       = Don't care    QUOTlo
;           Y       = Don't care    QUOThi
;           rDODOES = count
;           rDOCON  = sign
;           2(PSP)                  REM
;           0(PSP)                  QUOTlo
;           TOS                     QUOThi
            MOV #32,rDODOES         ; 2  init loop count
            CMP #0,W                ; DVDhi = 0 ?
            JNZ MTIMESDIV6          ; if no
            MOV TOS,W               ; DVDmi --> DVDhi
            CALL #MDIV1DIV2         ; with loop count / 2
            JMP MTIMESDIV7
MTIMESDIV6  CALL #MDIV1             ; -- urem ud2lo ud2hi
MTIMESDIV7  MOV @PSP+,0(PSP)        ; -- d2lo d2hi
            CMP #0,rDOCON           ; RES sign is set ?
            JZ MTIMESDIV8           ; no            
            XOR #-1,0(PSP)          ; DNEGATE quot
            XOR #-1,TOS
            ADD #1,0(PSP)
            ADDC #0,TOS
            CMP #0,&FORTHADDON      ; floored/symetric division flag test
            JGE MTIMESDIV8          ; if not(floored division and quot<0)
            CMP #0,W                ; remainder <> 0 ?
            JZ MTIMESDIV8           ; if not(floored division, quot<0 and remainder <>0)
            SUB #1,0(PSP)           ; decrement quotient
            SUBC #0,TOS
MTIMESDIV8  MOV #XDODOES,rDODOES
            MOV #XDOCON,rDOCON
            MOV @IP+,PC             ; 52 words

    .ENDIF  ;
    .IFNDEF TwoVARIABLE
; https://forth-standard.org/standard/double/TwoVARIABLE
            FORTHWORD "2VARIABLE" ;  --
TwoVARIABLE mDOCOL
            .word   CREATE
            mNEXTADR
            ADD #4,&DP
            MOV @RSP+,IP
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TwoCONSTANT
; https://forth-standard.org/standard/double/TwoCONSTANT
            FORTHWORD "2CONSTANT"   ;  udlo/dlo/Flo udhi/dhi/Shi --         to create double or s15q16 CONSTANT
TwoCONSTANT mDOCOL
            .word CREATE
            .word COMMA,COMMA       ; compile Shi then Flo
            .word DOES
            .word TWOFETCH          ; execution part
            .word EXIT

    .ENDIF
    .IFNDEF TO
; https://forth-standard.org/standard/core/TO
; TO name Run-time: ( x -- )
; Assign the value x to named VALUE.
            FORTHWORD "TO"
            BIS #UF9,SR
            MOV @IP+,PC

    .ENDIF
    .IFNDEF TwoVALUE
; https://forth-standard.org/standard/double/TwoVALUE
            FORTHWORD "2VALUE"      ; x1 x2 "<spaces>name" --
TwoVALUE    mDOCOL
            .word CREATE            ; compile Shi then Flo
            .word COMMA,COMMA       ; compile Shi then Flo
            .word DOES
            mNEXTADR
            MOV @RSP+,IP
            BIT #UF9,SR             ; flag set by TO
            JNZ TwoVALUESTO
            MOV #TwoFetch,PC              ; execute TwoFetch
TwoVALUESTO BIC #UF9,SR             ; clear flag
            MOV #TwoStore,PC              ; execute TwoStore

    .ENDIF
    .IFNDEF TwoLITERAL
; https://forth-standard.org/standard/double/TwoLITERAL
            FORTHWORDIMM "2LITERAL"
TwoLITERAL  BIS #UF9,SR             ; see LITERAL
            MOV #LITERAL,PC

    .ENDIF
    .IFNDEF DDotR
; https://forth-standard.org/standard/double/DDotR
; D.R       d n --
            FORTHWORD "D.R"
            mDOCOL
            .word TOR,SWAP,OVER,DABS,LESSNUM,NUMS,ROT,SIGN,NUMGREATER
            .word RFROM,OVER,MINUS,SPACES,TYPE
            .word EXIT
    .ENDIF
