; -*- coding: utf-8 -*-

            FORTHWORD "{FIXPOINT}"
            MOV @IP+,PC

    .IFNDEF DABS
DABS        AND #-1,TOS         ; clear V, set N
            JGE DABSEND         ; if positive (N=0)
            XOR #-1,0(PSP)      ;4
            XOR #-1,TOS         ;1
            ADD #1,0(PSP)       ;4
            ADDC #0,TOS         ;1
DABSEND     MOV @IP+,PC
    .ENDIF

; https://forth-standard.org/standard/core/HOLDS
; Adds the string represented by addr u to the pictured numeric output string
; compilation use: <# S" string" HOLDS #>
; free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
; (2 supplementary bytes are room for sign - and decimal point)
; perfect to display all a line on LCD 2x20 chars...
; C HOLDS    addr u --
            FORTHWORD "HOLDS"
HOLDS       MOV @PSP+,X         ; 2
HOLDS1      ADD TOS,X           ; 1 src
            MOV &HP,Y           ; 3 dst
HOLDSLOOP   SUB #1,X            ; 1 src-1
            SUB #1,TOS          ; 1 cnt-1
            JNC HOLDSNEXT       ; 2
            SUB #1,Y            ; 1 dst-1
            MOV.B @X,0(Y)       ; 4
            JMP HOLDSLOOP       ; 2
HOLDSNEXT   MOV Y,&HP           ; 3
            MOV @PSP+,TOS       ; 2
            MOV @IP+,PC         ; 4  15 words

            FORTHWORD "F+"          ; -- d1lo d1hi d2lo d2hi
            ADD @PSP+,2(PSP)    ; -- sumlo  d1hi d2hi
            ADDC @PSP+,TOS      ; -- sumlo sumhi
            MOV @IP+,PC

            FORTHWORD "F-"          ; -- d1lo d1hi d2lo d2hi
            SUB @PSP+,2(PSP)    ; -- diflo d1hi d2hi
            SUBC TOS,0(PSP)     ; -- diflo difhi d2hi
            MOV @PSP+,TOS
            MOV @IP+,PC

    .IFNDEF MPY ; no hardware multiplier

; unsigned multiply 32*32 = 64
; don't use S reg (keep sign)
            FORTHWORD "UDM*"
UDMT        PUSH IP             ; 3
            PUSHM #4,rDOVAR     ; 6 save rDOVAR to rDOCOL regs to use M to R alias
            MOV 4(PSP),IP       ; 3 MDlo
            MOV 2(PSP),T        ; 3 MDhi
            MOV @PSP,W          ; 2 MRlo
            MOV #0,M            ; 1 MDLO=0
            MOV #0,P            ; 1 MDHI=0
            MOV #0,4(PSP)       ; 3 RESlo=0
            MOV #0,2(PSP)       ; 3 REShi=0
            MOV #0,Q            ; 1 RESLO=0
            MOV #0,R            ; 1 RESHI=0
            MOV #1,X            ; 1 BIT TEST REGlo
            MOV #0,Y            ; 1 BIT TEST2 REGhi
UDMT1       CMP #0,X
            JNZ UDMT2           ; 2
            BIT Y,TOS           ; 1 TEST ACTUAL BIT MRhi
            JMP UDMT3
UDMT2       BIT X,W             ; 1 TEST ACTUAL BIT MRlo
UDMT3       JZ UDMT4            ; 
            ADD IP,4(PSP)       ; 3 IF 1: ADD MDlo TO RESlo
            ADDC T,2(PSP)       ; 3      ADDC MDhi TO REShi
            ADDC M,Q            ; 1      ADDC MDLO TO RESLO        
            ADDC P,R            ; 1      ADDC MDHI TO RESHI
UDMT4       ADD IP,IP           ; 1 (RLA LSBs) MDlo *2
            ADDC T,T            ; 1 (RLC MSBs) MDhi *2
            ADDC M,M            ; 1 (RLC LSBs) MDLO *2
            ADDC P,P            ; 1 (RLC MSBs) MDHI *2
            ADD X,X             ; 1 (RLA) NEXT BIT TO TEST
            ADDC Y,Y            ; 1 (RLC) NEXT BIT TO TEST
            JNC UDMT1           ; 2 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
            MOV Q,0(PSP)        ; 3
            MOV R,TOS           ; 1 high result in TOS
            POPM #4,rDOVAR      ; 6 restore rDOCOL to rDOVAR
            MOV @RSP+,IP        ; 2
            MOV @IP+,PC


            FORTHWORD "F*"          ; s15.16 * s15.16 --> s15.16 result
            MOV 2(PSP),S        ;
            XOR TOS,S           ; MDhi XOR MRhi --> S keep sign of result
            BIT #8000h,2(PSP)   ; MD < 0 ? 
            JZ FSTAR1           ; no
            XOR #-1,2(PSP)
            XOR #-1,4(PSP)
            ADD #1,4(PSP)
            ADDC #0,2(PSP)
FSTAR1       mDOCOL
            .word DABS,UDMT
            .word   $+2         ; -- RES0 RES1 RES2 RES3 
            MOV @RSP+,IP
            MOV @PSP+,TOS       ; -- RES0 RES1 RES2
            MOV @PSP+,0(PSP)    ; -- RES1 RES2
FSTARSIGN   AND #-1,S           ; clear V, set N
            JGE FSTAREND        ; if positive
            XOR #-1,0(PSP)
            XOR #-1,TOS
            ADD #1,0(PSP)
            ADDC #0,TOS
FSTAREND    MOV @IP+,PC 


            FORTHWORD "F/"          ; s15.16 / s15.16 --> s15.16 result
FDIV        PUSHM #4,rDOVAR     ; 6 save rDOVAR to rDOCOL regs to use M to R alias
            MOV @PSP+,M         ; DIVlo
            MOV @PSP+,X         ; DVDhi --> REMlo
            MOV #0,W            ; REMhi = 0
            MOV @PSP,Y          ; DVDlo --> DVDhi
            MOV #0,T            ; DVDlo = 0
            MOV X,S             ;
            XOR TOS,S           ; MDhi XOR MRhi --> S keep sign of result
            AND #-1,X           ; MD < 0 ? 
            JGE FDIV1           ; no
            XOR #-1,Y           ; lo
            XOR #-1,X           ; hi
            ADD #1,Y            ; lo
            ADDC #0,X           ; hi
FDIV1       AND #-1,TOS
            JGE FDIV2
            XOR #-1,M
            XOR #-1,TOS
            ADD #1,M
            ADDC #0,TOS
FDIV2   
; unsigned 32-BIT DIVIDEND : 32-BIT DIVISOR --> 32-BIT QUOTIENT, 32-BIT REMAINDER
; DVDhi|DVDlo : DVRhi|DVRlo --> QUOThi|QUOTlo, REMAINDER
;            FORTHWORD "UD/MOD"
;            MOV 4(PSP),T       ; DVDlo
;            MOV 2(PSP),Y       ; DVDhi
;            MOV #0,X           ; REMlo = 0
Q6432       MOV #32,P           ; init loop count
Q321        CMP TOS,W           ;1 REMhi <> DIVhi ?
            JNZ Q322            ;2 yes
            CMP M,X             ;1 REMlo U< DIVlo ?
Q322        JNC Q323            ;2 yes: REM U< DIV
            SUB M,X             ;1 no:  REMlo - DIVlo  (carry is set)
            SUBC TOS,W          ;1      REMhi - DIVhi
Q323        ADDC R,R            ;1 RLC quotLO
            ADDC Q,Q            ;1 RLC quotHI
            SUB #1,P            ;1 Decrement loop counter
            JN Q6432END         ;2 loop back if count>=0    
            ADD T,T             ;1 RLA DVDlo
            ADDC Y,Y            ;1 RLC DVDhi
            ADDC X,X            ;1 RLC REMlo
            ADDC W,W            ;1 RLC REMhi
            JNC Q321            ; 
            SUB M,X             ;1 REMlo - DIVlo
            SUBC TOS,W          ;1 REMhi - DIVhi
            BIS #1,SR
            JMP Q323
Q6432END
;            MOV X,4(PSP)       ; REMlo    
;            MOV W,2(PSP)       ; REMhi
;            ADD #4,PSP         ; skip REMlo REMhi
            MOV R,0(PSP)        ; QUOTlo
            MOV Q,TOS           ; QUOThi
            POPM #4,rDOVAR      ; 6 restore rDOCOL to rDOVAR
;            MOV @IP+,PC        ; 33 words
            JMP FSTARSIGN       ; goto end of F/ to process sign of result

; F#S    Qlo Qhi u -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
;                             with u digits
            FORTHWORD "F#S"
; create a counted string at PAD+CPL+2
; with digit high result of Qdlo * base
; UMstar use S,T,W,X,Y
; mov &BASE,S , jmp UMSTAR1 without hardware MPY
; result: digit in tos (high) to convert in digit
FNUMS       MOV @PSP,S          ; -- Qlo Qhi len        S = Qhi
            MOV #0,T            ;                       T = count
            PUSHM #3,IP         ;                       R-- IP Qhi count
            MOV 2(PSP),0(PSP)   ; -- Qlo Qlo len
            MOV TOS,2(PSP)      ; -- len Qlo len
            MOV #FNUMSNEXT,IP   ;
FNUMSLOOP   MOV &BASE,TOS       ; -- len Qlo base
            MOV #UMSTAR,PC 
FNUMSNEXT   .word   $+2         ; -- len RESlo digit
            SUB #2,IP
            CMP #10,TOS         ;                       digit to char
            JNC FNUMS2CHAR
            ADD #7,TOS
FNUMS2CHAR  ADD #30h,TOS        ; -- len RESlo char
            MOV @RSP,T          ;                       T=count
            MOV.B TOS,HOLDS_ORG(T)  ;                   char to string_org(T)
            ADD #1,T            ;                       count+1
            MOV T,0(RSP)        ;
            CMP 2(PSP),T        ; -- len RESlo char     count=len ?
            JNZ FNUMSLOOP       ;                       no
            POPM #3,IP          ;                       S=Qhi, T=len
            MOV T,TOS           ; -- len RESlo len
            MOV S,2(PSP)        ; -- Qhi RESlo len
            MOV #0,0(PSP)       ; -- Qhi 0 len
            MOV #HOLDS_ORG,X    ; -- Qhi 0 len          X= org
            JMP HOLDS1
            
    .ELSEIF ; hardware multiplier

            FORTHWORD "F*"          ; signed s15.16 multiplication --> s15.16 result
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

            FORTHWORD "F/"           ; s15.16 / s15.16 --> s15.16 result
FDIV        PUSHM #4,rDOVAR     ; 6 PUSHM rDOVAR to rDOCOL to use M to R alias
            MOV @PSP+,M         ; DIVlo
            MOV @PSP+,X         ; DVDhi --> REMlo
            MOV #0,W            ; REMhi = 0
            MOV @PSP,Y          ; DVDlo --> DVDhi
            MOV #0,T            ; DVDlo = 0
            MOV X,S             ;
            XOR TOS,S           ; MDhi XOR MRhi --> S keep sign of result
            AND #-1,X           ; MD < 0 ? 
            JGE FDIV1           ; no
            XOR #-1,Y           ; lo
            XOR #-1,X           ; hi
            ADD #1,Y            ; lo
            ADDC #0,X           ; hi
FDIV1       AND #-1,TOS
            JGE FDIV2
            XOR #-1,M
            XOR #-1,TOS
            ADD #1,M
            ADDC #0,TOS
FDIV2   
; unsigned 32-BIT DIVIDEND : 32-BIT DIVISOR --> 32-BIT QUOTIENT, 32-BIT REMAINDER
; DVDhi|DVDlo : DVRhi|DVRlo --> QUOThi|QUOTlo, REMAINDER
;            FORTHWORD "UD/MOD"
;            MOV 4(PSP),T       ; DVDlo
;            MOV 2(PSP),Y       ; DVDhi
;            MOV #0,X           ; REMlo = 0
Q6432       MOV #32,P           ; init loop count
Q321        CMP TOS,W           ;1 REMhi <> DIVhi ?
            JNZ Q322            ;2 yes
            CMP M,X             ;1 REMlo U< DIVlo ?
Q322        JNC Q323            ;2 yes: REM U< DIV
            SUB M,X             ;1 no:  REMlo - DIVlo  (carry is set)
            SUBC TOS,W          ;1      REMhi - DIVhi
Q323        ADDC R,R            ;1 RLC quotLO
            ADDC Q,Q            ;1 RLC quotHI
            SUB #1,P            ;1 Decrement loop counter
            JN Q6432END         ;2 loop back if count>=0    
            ADD T,T             ;1 RLA DVDlo
            ADDC Y,Y            ;1 RLC DVDhi
            ADDC X,X            ;1 RLC REMlo
            ADDC W,W            ;1 RLC REMhi
            JNC Q321            ; 
            SUB M,X             ;1 REMlo - DIVlo
            SUBC TOS,W          ;1 REMhi - DIVhi
            BIS #1,SR
            JMP Q323
Q6432END
;            MOV X,4(PSP)       ; REMlo    
;            MOV W,2(PSP)       ; REMhi    
;            MOV @IP+,PC        ; 33 words
            AND #-1,S           ; clear V, set N
            JGE FDIVEND         ; if positive
            XOR #-1,R
            XOR #-1,Q
            ADD #1,R
            ADDC #0,Q
FDIVEND     MOV R,0(PSP)        ; QUOTlo
            MOV Q,TOS           ; QUOThi
            POPM #4,rDOVAR      ; 6 restore rDOCOL to rDOVAR
            MOV @IP+,PC 

; F#S    Qlo Qhi u -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
;                             with u digits
            FORTHWORD "F#S"
FNUMS       MOV 2(PSP),X        ; -- Qlo Qhi u      X = Qlo
            MOV @PSP,2(PSP)     ; -- Qhi Qhi u
            MOV X,0(PSP)        ; -- Qhi Qlo u
            MOV TOS,T           ;                   T = limit
            MOV #0,S            ;                   S = count
FNUMSLOOP   MOV @PSP,&MPY       ;                   Load 1st operand
            MOV &BASE,&OP2      ;                   Load 2nd operand
            MOV &RES0,0(PSP)    ; -- Qhi Qlo' x     low result on stack
            MOV &RES1,TOS       ; -- Qhi Qlo' digit high result in TOS
            CMP #10,TOS         ;                   digit to char
            JNC FNUMS2CHAR
            ADD #7,TOS
FNUMS2CHAR  ADD #30h,TOS
            MOV.B TOS,HOLDS_ORG(S)  ; -- Qhi Qlo' char  char to string
            ADD #1,S            ;                   count+1
            CMP T,S             ;2                  countU<len ?
            JNZ FNUMSLOOP       ;                   loop back if yes
            MOV T,TOS           ; -- Qhi Qlo' len
            MOV #0,0(PSP)       ; -- Qhi 0 len
            MOV #HOLDS_ORG,X    ; -- Qhi 0 len      X= org
            JMP HOLDS1
            
    .ENDIF ; of hardware MPY

            FORTHWORD "F."          ; display a Q15.16 number with 4 digits after comma
            MOV TOS,S           ; S = sign
            MOV #4,T            ; T = 4     preset 4 digits for base 16 by default
            MOV &BASE,W
            CMP #0Ah,W
            JNZ FDOT1           ;           if not base 10
            ADD #1,T            ; T = 5     set 5 digits
            JMP FDOT2
FDOT1       CMP #2,W            ;
            JNZ FDOT2           ;           if not base 2
            MOV #10h,T          ; T = 16    set 16 digits
FDOT2       PUSHM #3,IP         ;                   R-- IP S=sign T=#digit
            ASMtoFORTH
            .word   LESSNUM     ; -- uQlo Qhi
            .word   DABS        ; -- uQlo uQhi      R-- IP sign #digit
            .word   RFROM       ; -- uQlo uQhi u    R-- IP sign
            .word   FNUMS       ; -- uQhi 0     
            .word   LIT,2Ch,HOLD;                   $2C = char ','
            .word   NUMS        ; -- 0 0
            .word   RFROM       ; -- 0 0 Qhi        R-- IP
            .word   SIGN        ; -- 0 0 
            .word   NUMGREATER  ; -- addr len 
            .word   TYPE        ; --
            .word   FBLANK,EMIT ; --      
            .word   EXIT

            FORTHWORD "S>F"         ; convert a signed number to a Q15.16 (signed) number
            SUB #2,PSP
            MOV #0,0(PSP)
            MOV @IP+,PC
