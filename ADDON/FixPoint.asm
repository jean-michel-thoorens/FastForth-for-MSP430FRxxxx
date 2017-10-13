

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
Q6432       .word 1537h     ; PUSHM R7,R4
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
            .word 1734h     ; POPM R4,R7
;            MOV @IP+,PC    ; 33 words

FDIVSGN AND #-1,S       ; clear V, set N
        JGE FDIVEND     ; if positive
        XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
FDIVEND MOV @IP+,PC 

    .IFDEF MPY ; hardware multiplier

; F#S    Shi Qlo -- Shi 0   convert fractionnal part of S15Q16 fixed point number (direct order)
    FORTHWORD "F#S"
QUMS        SUB #2,PSP              ; -- Shi x Qlo
            MOV TOS,0(PSP)          ; -- Shi Qlo x
            MOV #4,T                ; -- Shi Qlo x      T = limit for base 16
            CMP #10,&BASE
            JNZ QUMS2
            ADD #1,T                ;                   T = limit for base 10
QUMS2       MOV #0,S                ;                   S = count
QUMSLOOP    MOV @PSP,&MPY           ;                   Load 1st operand
            MOV &BASE,&OP2          ;                   Load 2nd operand
            MOV &RES0,0(PSP)        ; -- Shi Qlo' x     low result on stack
            MOV &RES1,TOS           ; -- Shi Qlo' digit high result in TOS
            CMP #10,TOS             ;                   digit to char
            JLO QUMS2CHAR
            ADD #7,TOS
QUMS2CHAR   ADD #30h,TOS
            MOV.B TOS,HOLDS_ORG(S)  ; -- Shi Qlo' char  char to string
            ADD #1,S                ;                   count+1
            CMP T,S                 ;2                  count=limit ?
            JLO QUMSLOOP            ;                   loop back if U<
            MOV T,TOS               ; -- Shi Qlo' limit
            MOV #0,0(PSP)           ; -- Shi 0 limit
            MOV #HOLDS_ORG,X        ; -- Shi 0 len      X= org
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

; F#S    Shi Qlo -- Shi 0   convert fractionnal part of S15Q16 fixed point number (direct order)
    FORTHWORD "F#S"
; create a counted string at PAD+CPL+2
; with digit high result of Qdlo * base
; UMstar use S,T,W,X,Y
; mov &BASE,S , jmp UMSTAR1 without hardware MPY
; result: digit in tos (high) to convert in digit
; 
QUMS        SUB #2,PSP              ; -- Shi x Qlo
            MOV TOS,0(PSP)          ; -- Shi Qlo x
            MOV #4,TOS              ; -- Shi Qlo x      T = limit for base 16
            CMP #10,&BASE
            JNZ QUMS2
            ADD #1,TOS              ;                   T = limit for base 10
QUMS2       .word 151Eh             ;                   PUSHM TOS,IP  TOS=limit IP count
            MOV #QUMSNEXT,IP        ; -- Shi Qlo x
            MOV #0,S
QUMSLOOP    PUSH S                  ;                   R-- limit IP count
            MOV &BASE,TOS           ; -- Shi Qlo base
            MOV #UMSTAR,PC 
QUMSNEXT    FORTHtoASM              ; -- Shi QloRem digit
            SUB #2,IP
            CMP #10,TOS             ;                   digit to char
            JLO QUMS2CHAR
            ADD #7,TOS
QUMS2CHAR   ADD #30h,TOS
            MOV @RSP+,S             ;                       R-- limit IP
            MOV.B TOS,HOLDS_ORG(S)  ; -- Shi Qlorem char    char to stringto string
            ADD #1,S                ;                       count+1
            CMP 2(RSP),S            ;3                      count=limit ?
            JLO QUMSLOOP            ;                       no
            .word 171Dh             ; -- Shi Qlorem limit   POPM IP,TOS ;
            MOV #0,0(PSP)           ; -- Shi 0 limit
            MOV #HOLDS_ORG,X        ; -- Shi 0 len          X= org
            JMP HOLDS1
            
; unsigned multiply 32*32 = 64
; don't use S reg (keep sign)
        FORTHWORD "UDM*"
UDMS    PUSH IP         ; 3
        .word 1537h     ; 6 PUSHM R7,R4     save R7 ~ R4 regs
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
UDMS1   CMP #0,X
        JNZ UDMS2       ; 2
        BIT Y,TOS       ; 1 TEST ACTUAL BIT MRhi
        JMP UDMS3
UDMS2   BIT X,W         ; 1 TEST ACTUAL BIT MRlo
UDMS3   JZ UDMS4        ; 
        ADD IP,4(PSP)   ; 3 IF 1: ADD MDlo TO RESlo
        ADDC T,2(PSP)   ; 3      ADDC MDhi TO REShi
        ADDC R4,R6      ; 1      ADDC MDLO TO RESLO        
        ADDC R5,R7      ; 1      ADDC MDHI TO RESHI
UDMS4   ADD IP,IP       ; 1 (RLA LSBs) MDlo *2
        ADDC T,T        ; 1 (RLC MSBs) MDhi *2
        ADDC R4,R4      ; 1 (RLA LSBs) MDLO *2
        ADDC R5,R5      ; 1 (RLC MSBs) MDHI *2
        ADD X,X         ; 1 (RLA) NEXT BIT TO TEST
        ADDC Y,Y        ; 1 (RLA) NEXT BIT TO TEST
        JLO UDMS1       ; 2 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
        MOV R6,0(PSP)   ; 3
        MOV R7,TOS      ; 1 high result in TOS
        .word 1734h     ; 6  POPM R4,R7  restore R4 ~ R7 regs
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
        .word DABBS,UDMS
        FORTHtoASM          ; -- RES0 RES1 RES2 RES3 
        MOV @RSP+,IP
        MOV @PSP+,TOS       ; -- RES0 RES1 RES2
        MOV @PSP+,0(PSP)    ; -- RES1 RES2
        JMP FDIVSGN         ; goto end of F/ to process sign of result


    .ENDIF

        FORTHWORD "F."      ; display a s15q16 number
        mDOCOL
        .word   LESSNUM,DUP,TOR,DABBS
        .word   SWAP,QUMS,lit,',',HOLD,NUMS
        .word   RFROM,SIGN,NUMGREATER,TYPE,SPACE,EXIT
        
        FORTHWORD "S>F"     ; convert a signed number to a s15q16 (signed) number
        SUB #2,PSP
        MOV #0,0(PSP)
        MOV @IP+,PC

        FORTHWORD "D>F"     ; convert a signed double number (-32768|32767) to a s15q16 (signed) number
        MOV @PSP,TOS
        MOV #0,0(PSP)
        MOV @IP+,PC

; https://forth-standard.org/standard/double/TwoCONSTANT
; udlo/dlo/Flo udhi/dhi/Shi --         create a double or a s15q16 CONSTANT
        FORTHWORD "2CONSTANT"
        mDOCOL
        .word CREATE
        .word SWAP,COMMA,COMMA  ; compile udlo/dlo/Flo then udhi/dhi/Shi
        .word DOES
        FORTHtoASM
        SUB #2,PSP          ; -- x PFA
        MOV @TOS+,0(PSP)    ; -- lo PFA+2
        MOV @TOS,TOS        ; -- lo hi
        MOV @RSP+,IP
        MOV @IP+,PC

