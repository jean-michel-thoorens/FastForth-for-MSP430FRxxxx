

    FORTHWORD "{FIXPOINT}"
    mNEXT

; https://forth-standard.org/standard/core/HOLDS
; Adds the string represented by addr u to the pictured numeric output string
; compilation use: <# S" string" HOLDS #>
; free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
; (2 supplementary bytes are room for sign - and decimal point)
; perfect to display all a line on LCD 2x20 chars...
; C HOLDS    addr u --
    FORTHWORD "HOLDS"
HOLDS       MOV @PSP+,X     ; 2
HOLDS1      ADD TOS,X       ; 1 src
            MOV &HP,Y       ; 3 dst
HOLDSLOOP   SUB #1,X        ; 1 src-1
            SUB #1,TOS      ; 1 cnt-1
            JLO HOLDSNEXT   ; 2
            SUB #1,Y        ; 1 dst-1
            MOV.B @X,0(Y)   ; 4
            JMP HOLDSLOOP   ; 2
HOLDSNEXT   MOV Y,&HP       ; 3
            MOV @PSP+,TOS   ; 2
            mNEXT            ; 4  15 words

        FORTHWORD "F+"      ; -- d1lo d1hi d2lo d2hi
        ADD @PSP+,2(PSP)    ; -- sumlo  d1hi d2hi
        ADDC @PSP+,TOS      ; -- sumlo sumhi
        MOV @IP+,PC

        FORTHWORD "F-"      ; -- d1lo d1hi d2lo d2hi
        SUB @PSP+,2(PSP)    ; -- diflo d1hi d2hi
        SUBC TOS,0(PSP)     ; -- diflo difhi d2hi
        MOV @PSP+,TOS
        MOV @IP+,PC


       FORTHWORD "F/"      ; s15.16 / s15.16 --> s15.16 result
FDIV    MOV 2(PSP),S        ;
        XOR TOS,S           ; MDhi XOR MRhi --> S keep sign of result
        MOV #0,T            ; DVDlo = 0
        MOV 4(PSP),Y        ; DVDlo --> DVDhi
        MOV 2(PSP),X        ; DVDhi --> REMlo
        BIT #8000,X         ; MD < 0 ? 
        JZ FDIV1            ; no
        XOR #-1,Y           ; lo
        XOR #-1,X           ; hi
        ADD #1,Y            ; lo
        ADDC #0,X           ; hi
FDIV1   BIT #8000,TOS
        JZ FDIV2
        XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
FDIV2   
; unsigned 32-BIT DIVIDEND : 32-BIT DIVISOR --> 32-BIT QUOTIENT, 32-BIT REMAINDER
; DVDhi|DVDlo : DVRhi|DVRlo --> QUOThi|QUOTlo, REMAINDER
;            FORTHWORD "UD/MOD"
;            MOV 4(PSP),T   ; DVDlo
;            MOV 2(PSP),Y   ; DVDhi
;            MOV #0,X       ; REMlo = 0
Q6432       PUSHM  #4,R7    ; PUSHM R7,R4
            MOV #0,W        ; REMhi = 0
            MOV @PSP,R6     ; DIVlo
            MOV #32,R5      ; init loop count
Q321        CMP TOS,W       ;1 REMhi <> DIVhi ?
            JNZ Q322        ;2 yes
            CMP R6,X        ;1 REMlo U< DIVlo ?
Q322        JLO Q323        ;2 yes: REM U< DIV
            SUB R6,X        ;1 no:  REMlo - DIVlo  (carry is set)
            SUBC TOS,W      ;1      REMhi - DIVhi
Q323        ADDC R7,R7      ;1 RLC quotLO
            ADDC R4,R4      ;1 RLC quotHI
            SUB #1,R5       ;1 Decrement loop counter
            JN Q6432END     ;2 loop back if count>=0    
            ADD T,T         ;1 RLA DVDlo
            ADDC Y,Y        ;1 RLC DVDhi
            ADDC X,X        ;1 RLC REMlo
            ADDC W,W        ;1 RLC REMhi
            JNC Q321        ; 
            SUB R6,X        ;1 REMlo - DIVlo
            SUBC TOS,W      ;1 REMhi - DIVhi
            BIS #1,SR
            JMP Q323
Q6432END
;            MOV X,4(PSP)   ; REMlo    
;            MOV W,2(PSP)   ; REMhi
            ADD #4,PSP      ; skip REMlo REMhi
    
            MOV R7,0(PSP)   ; QUOTlo
            MOV R4,TOS      ; QUOThi
            POPM  #4,R7     ; POPM R4 R5 R6 R7
;            MOV @IP+,PC    ; 33 words

FDIVSGN AND #-1,S       ; clear V, set N
        JGE FDIVEND     ; if positive
        XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
FDIVEND MOV @IP+,PC 

    .IFDEF MPY ; hardware multiplier

; F#S    Qlo Qhi -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
    FORTHWORD "F#S"
FNUMS       MOV @PSP,X              ; -- Qlo Qhi    X = Qlo
            MOV TOS,0(PSP)          ; -- Qhi Qhi
            SUB #2,PSP              ; -- Qhi x Qhi
            MOV X,0(PSP)            ; -- Qhi Qlo Qhi
            MOV #4,T                ; -- Qhi Qlo x      T = limit for base 16
            CMP #10,&BASE
            JNZ FNUMS2
            ADD #1,T                ;                   T = limit for base 10
FNUMS2      MOV #0,S                ;                   S = count
FNUMSLOOP   MOV @PSP,&MPY           ;                   Load 1st operand
            MOV &BASE,&OP2          ;                   Load 2nd operand
            MOV &RES0,0(PSP)        ; -- Qhi Qlo' x     low result on stack
            MOV &RES1,TOS           ; -- Qhi Qlo' digit high result in TOS
            CMP #10,TOS             ;                   digit to char
            JLO FNUMS2CHAR
            ADD #7,TOS
FNUMS2CHAR  ADD #30h,TOS
            MOV.B TOS,HOLDS_ORG(S)  ; -- Qhi Qlo' char  char to string
            ADD #1,S                ;                   count+1
            CMP T,S                 ;2                  count=limit ?
            JLO FNUMSLOOP           ;                   loop back if U<
            MOV T,TOS               ; -- Qhi Qlo' limit
            MOV #0,0(PSP)           ; -- Qhi 0 limit
            MOV #HOLDS_ORG,X        ; -- Qhi 0 len      X= org
            JMP HOLDS1
            
            FORTHWORD "F*"      ; signed s15.16 multiplication --> s15.16 result
            MOV 4(PSP),&MPYS32L ; 5 Load 1st operand
            MOV 2(PSP),&MPYS32H ; 5
            MOV @PSP,&OP2L      ; 4 load 2nd operand
            MOV TOS,&OP2H       ; 3
            ADD #4,PSP          ; 1 remove 2 cells
            NOP2                ; 2
            NOP2                ; 2 wait 8 cycles after write OP2L before reading RES1
            MOV &RES1,0(PSP)    ; 5
            MOV &RES2,TOS       ; 5
            MOV @IP+,PC

    .ELSE ; no hardware multiplier

; F#S    Qlo Qhi -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
    FORTHWORD "F#S"
; create a counted string at PAD+CPL+2
; with digit high result of Qdlo * base
; UMstar use S,T,W,X,Y
; mov &BASE,S , jmp UMSTAR1 without hardware MPY
; result: digit in tos (high) to convert in digit
; 
FNUMS       MOV @PSP,X              ; -- Qlo Qhi    X = Qlo
            MOV TOS,0(PSP)          ; -- Qhi Qhi
            SUB #2,PSP              ; -- Qhi x Qhi
            MOV X,0(PSP)            ; -- Qhi Qlo Qhi
            MOV #4,TOS              ; -- Qhi Qlo limit      TOS = count for base 16
            CMP #10,&BASE
            JNZ FNUMS2
            ADD #1,TOS              ;                   TOS = limit for base 10
FNUMS2      PUSHM  #2,TOS           ;                   PUSHM TOS,IP  TOS=limit IP count
            MOV #FNUMSNEXT,IP       ; -- Qhi Qlo limit
            MOV #0,S
FNUMSLOOP   PUSH S                  ;                   R-- limit IP count
            MOV &BASE,TOS           ; -- Qhi Qlo base
            MOV #UMSTAR,PC 
FNUMSNEXT   FORTHtoASM              ; -- Qhi QloRem digit
            SUB #2,IP
            CMP #10,TOS             ;                   digit to char
            JLO FNUMS2CHAR
            ADD #7,TOS
FNUMS2CHAR  ADD #30h,TOS
            MOV @RSP+,S             ;                       R-- limit IP
            MOV.B TOS,HOLDS_ORG(S)  ; -- Qhi Qlorem char    char to stringto string
            ADD #1,S                ;                       count+1
            CMP 2(RSP),S            ;3                      count=limit ?
            JLO FNUMSLOOP           ;                       no
            POPM  #2,TOS            ; -- Qhi Qlorem limit   POPM IP,TOS
            MOV #0,0(PSP)           ; -- Qhi 0 limit
            MOV #HOLDS_ORG,X        ; -- Qhi 0 len          X= org
            JMP HOLDS1
            
; unsigned multiply 32*32 = 64
; don't use S reg (keep sign)
        FORTHWORD "UDM*"
UDMT    PUSH IP         ; 3
        PUSHM  #4,R7     ; 6 PUSHM R7,R4     save R7 ~ R4 regs
        MOV 4(PSP),IP   ; 3 MDlo
        MOV 2(PSP),T    ; 3 MDhi
        MOV @PSP,W      ; 2 MRlo
        MOV #0,R4       ; 1 MDLO=0
        MOV #0,R5       ; 1 MDHI=0
        MOV #0,4(PSP)   ; 3 RESlo=0
        MOV #0,2(PSP)   ; 3 REShi=0
        MOV #0,R6       ; 1 RESLO=0
        MOV #0,R7       ; 1 RESHI=0
        MOV #1,X        ; 1 BIT TEST REGlo
        MOV #0,Y        ; 1 BIT TEST2 REGhi
UDMT1   CMP #0,X
        JNZ UDMT2       ; 2
        BIT Y,TOS       ; 1 TEST ACTUAL BIT MRhi
        JMP UDMT3
UDMT2   BIT X,W         ; 1 TEST ACTUAL BIT MRlo
UDMT3   JZ UDMT4        ; 
        ADD IP,4(PSP)   ; 3 IF 1: ADD MDlo TO RESlo
        ADDC T,2(PSP)   ; 3      ADDC MDhi TO REShi
        ADDC R4,R6      ; 1      ADDC MDLO TO RESLO        
        ADDC R5,R7      ; 1      ADDC MDHI TO RESHI
UDMT4   ADD IP,IP       ; 1 (RLA LSBs) MDlo *2
        ADDC T,T        ; 1 (RLC MSBs) MDhi *2
        ADDC R4,R4      ; 1 (RLA LSBs) MDLO *2
        ADDC R5,R5      ; 1 (RLC MSBs) MDHI *2
        ADD X,X         ; 1 (RLA) NEXT BIT TO TEST
        ADDC Y,Y        ; 1 (RLA) NEXT BIT TO TEST
        JLO UDMT1       ; 2 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
        MOV R6,0(PSP)   ; 3
        MOV R7,TOS      ; 1 high result in TOS
        POPM  #4,R7     ; 6  POPM R4 R5 R6 R7
        MOV @RSP+,IP    ; 2
        MOV @IP+,PC


        FORTHWORD "F*"      ; s15.16 * s15.16 --> s15.16 result
        MOV 2(PSP),S        ;
        XOR TOS,S           ; MDhi XOR MRhi --> S keep sign of result
        BIT #8000,2(PSP)    ; MD < 0 ? 
        JZ FSTAR1           ; no
        XOR #-1,2(PSP)
        XOR #-1,4(PSP)
        ADD #1,4(PSP)
        ADDC #0,2(PSP)
FSTAR1   mDOCOL
        .word DABBS,UDMT
        FORTHtoASM          ; -- RES0 RES1 RES2 RES3 
        MOV @RSP+,IP
        MOV @PSP+,TOS       ; -- RES0 RES1 RES2
        MOV @PSP+,0(PSP)    ; -- RES1 RES2
        JMP FDIVSGN         ; goto end of F/ to process sign of result


    .ENDIF

        FORTHWORD "F."      ; display a Q15.16 number
        mDOCOL
        .word   LESSNUM,DUP,TOR,DABBS
        .word   FNUMS,lit,',',HOLD,NUMS
        .word   RFROM,SIGN,NUMGREATER,TYPE,SPACE,EXIT
        
        FORTHWORD "S>F"     ; convert a signed number to a Q15.16 (signed) number
        SUB #2,PSP
        MOV #0,0(PSP)
        MOV @IP+,PC

; https://forth-standard.org/standard/core/TwoFetch
; 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
            FORTHWORD "2@"
TWOFETCH    
        SUB #2,PSP
        MOV 2(TOS),0(PSP)
        MOV @TOS,TOS
        MOV @IP+,PC


; https://forth-standard.org/standard/double/TwoCONSTANT
; udlo/dlo/Flo udhi/dhi/Qhi --         create a double or a Q15.16 CONSTANT
        FORTHWORD "2CONSTANT"
        mDOCOL
        .word CREATE
        .word COMMA,COMMA       ; compile udhi/dhi/Qhi then udlo/dlo/Qlo
        .word DOES
        .word TWOFETCH
        .word EXIT

