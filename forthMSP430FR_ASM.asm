; -*- coding: utf-8 -*-

; ----------------------------------------------------------------------
;forthMSP430FR_asm.asm 1584 bytes
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
;       MOV(.B) SR,dst   is coded as follow : MOV(.B) R2,dst            ; 1 cycle,  one word    AS=00   (register mode)
;       MOV(.B) #0,dst   is coded as follow : MOV(.B) R3,dst            ; 1 cycle,  one word    AS=00   (register mode)
;       MOV(.B) &EDE,dst is coded as follow : MOV(.B) EDE(R2),dst       ; 3 cycles, two words   AS=01   ( x(reg)  mode)
;       MOV(.B) #1,dst   is coded as follow : MOV(.B) (R3),dst          ; 1 cycle,  one word    AS=01   ( x(reg)  mode)
;       MOV(.B) #4,dst   is coded as follow : MOV(.B) @R2,dst           ; 1 cycle,  one word    AS=10   ( @reg    mode)
;       MOV(.B) #2,dst   is coded as follow : MOV(.B) @R3,dst           ; 1 cycle,  one word    AS=10   ( @reg    mode)
;       MOV(.B) #8,dst   is coded as follow : MOV(.B) @R2+,dst          ; 1 cycle,  one word    AS=11   ( @reg+   mode)
;       MOV(.B) #-1,dst  is coded as follow : MOV(.B) @R3+,dst          ; 1 cycle,  one word    AS=11   ( @reg+   mode)
; ----------------------------------------------------------------------
;       MOV(.B) #xxxx,dst is coded as follow: MOV(.B) @PC+,dst          ; 2 cycles, two words   AS=11   ( @reg+   mode)
; ----------------------------------------------------------------------

; PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
; PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0

; example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
;
; POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
; POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15

; example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search argument "xxxx"
; ----------------------------------------------------------------------

; common code for maxi 3 successive SearchARG: SearchARG, SearchARG+Offset, SearchARG-offset
; leave PFA of VARIABLE, [PFA] of CONSTANT, User_Parameter_Field_Address of MARKER_DOES, CFA for all others.
; if the ARGument is not found after those three SearchARg, the 'not found' error is issued by SrchOfst.
SearchARGn  PUSH &TOIN              ;                   push TOIN, for next SearchARGn if any
            mASM2FORTH              ; -- sep            sep =  ','|'('|' '
            .word WORDD,FIND        ; -- addr           search string name first
            .word QFBRAN,SrchArgNum ; -- addr           if string name not found
COMPUTEARG  mNEXTADR                ; -- CFA            of named definition
            MOV @TOS+,S             ; -- PFA            S=DOxxx
QDOVAR      SUB #1287h,S            ;                   CFA = DOxxx = 1287h = CALL R7 = rDOVAR
ISDOVAR     JZ ARGFOUND             ; -- addr           PFA = adr of VARIABLE
QDOCON      ADD #1,S                ;                   CFA = DOxxx = 1286h = DOCON
            JNZ QMARKER             ;
ISDOCON     MOV @TOS,TOS            ; -- cte
            JMP ARGFOUND            ; -- cte
QMARKER     CMP #MARKER_DOES,0(TOS) ; -- PFA            search if PFA = [MARKER_DOES]
            JNZ ISOTHER             ; -- PFA
        .IFDEF VOCABULARY_SET       ; -- PFA
            ADD #30,TOS             ; -- UPFA+2         skip room for DP, CURRENT, CONTEXT(8), null_word, LASTVOC, RET_ADR 2+(2+2+16+2+2+2) +2 bytes
        .ELSE                       ;
            ADD #8,TOS              ; -- UPFA+2         skip room for DP, RET_ADR  2+(2+2) +2 bytes
        .ENDIF                      ;
ISOTHER     SUB #2,TOS              ; -- CFA|UPFA       UPFA = MARKER_DOES User_Parameter_Field_Address
ARGFOUND    ADD #2,RSP              ;                   remove TOIN
SEARCHRET   MOV @RSP+,PC            ;24                 SR(Z)=0 if ARG found

SrchArgNum  .word QNUMBER           ;
            .word QFBRAN,ARGNOTFOUND; -- addr           with SR(Z)=1
            .word ARGFOUND          ; -- value          no return
ARGNOTFOUND mNEXTADR                ; -- x
            MOV @RSP+,&TOIN         ;                   restore TOIN
            MOV @RSP+,PC            ;32                 SR(Z)=1 if ARG not found

SearchIndex
; Search index of "xxxx(REG),"      ; <== ComputeIDXpREG <== PARAM13
; Search index of ",xxxx(REG)"      ; <== ComputeIDXpREG <== PARAM21
            SUB #1,&TOIN            ;               move >IN back one (unskip 'R')
            MOV #'(',TOS            ; addr -- "("   as WORD separator to find xxxx of "xxxx(REG),"
SearchARG                           ; sep -- n|d    or abort" not found"
; Search ARG of "#xxxx,"            ; <== PARAM101
; Search ARG of "&xxxx,"            ; <== PARAM111
; Search ARG of ",&xxxx"            ; <== PARAM111 <== PARAM201
            MOV TOS,W
            PUSHM #4,IP             ; -- sep        PUSHM IP,S,T,W as IP_RET,OPCODE,OPCODEADR,sep
            CALL #SearchARGn        ;               first search argument without offset
            JNZ SrchEnd             ; -- ARG        if ARG found
SearchArgPo MOV #'+',TOS            ; -- '+'
            CALL #SearchARGn        ;               2th search argument with '+' as separator
            JNZ ArgPlusOfst         ; -- ARG        if ARG of ARG+offset found
SearchArgMo MOV #'-',TOS            ; -- '-'
            CALL #SearchARGn        ;               3th search argument with '-' as separator
            SUB #1,&TOIN            ;               to handle offset with its minus sign
ArgPlusOfst PUSH TOS                ; -- ARG        save ARG on stack
            MOV 2(RSP),TOS          ; -- sep        reload offset sep
SrchOfst    mASM2FORTH              ;
            .word WORDD,QNUMBER     ; -- Ofst|c-addr flag
            .word QFBRAN,NotFound   ; -- c-addr     no return, see INTERPRET
            mNEXTADR                ; -- Ofst
            ADD @RSP+,TOS           ; -- Arg+Ofst
SrchEnd     POPM #4,IP              ;               POPM W,T,S,IP     common return for SearchARG and SearchRn
            MOV @RSP+,PC            ;66

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search REG
; ----------------------------------------------------------------------
; compute index of "xxxx(REG),"     ;               <== PARAM13, sep=','
; compute index of ",xxxx(REG)"     ;               <== PARAM210, sep=' '
ComputeIDXpREG                      ; addr -- Rn|addr
            CALL #SearchIndex       ; -- xxxx       aborted if not found
            MOV &DP,X
            MOV TOS,0(X)            ; -- xxxx       compile ARG xxxx
            ADD #2,&DP
            MOV #')',TOS            ; -- ")"        prepare separator to search REG of "xxxx(REG)"
; search REG of "xxxx(REG),"    separator = ')'
; search REG of ",xxxx(REG)"    separator = ')'
; search REG of "@REG,"         separator = ',' <== PARAM120
; search REG of "@REG+,"        separator = '+' <== PARAM121
SkipRSearchRn
            ADD #1,&TOIN            ;               skip "R" in input buffer
; search REG of "REG,"          separator = ',' <== PARAM13
; search REG of ",REG"          separator = BL  <== PARAM21
SearchRn    MOV &TOIN,W             ;
            PUSHM #4,IP             ;               PUSHM IP,S,T,W as IP_RET,OPCODE,OPCODEADR,TOIN
            mASM2FORTH              ;               search xx of Rxx
            .word WORDD,QNUMBER     ;
            .word QFBRAN,REGNOTFOUND; -- xxxx       SR(Z)=1 if Not a Number
            mNEXTADR                ; -- Rn         number is found
            CMP #16,TOS             ; -- Rn
            JNC SrchEnd             ; -- Rn         SR(Z)=0, Rn found,
            JC  BOUNDERROR          ;               abort if Rn out of bounds

REGNOTFOUND mNEXTADR                ; -- addr       SR(Z)=1, (case of @REG not found),
            MOV @RSP,&TOIN          ; -- addr       restore TOIN, ready for next SearchRn
            JMP SrchEnd             ; -- addr       SR(Z)=1 ==> not a register

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET FIRST OPERAND
; ----------------------------------------------------------------------
; PARAM1     separator --           ; parse input buffer until separator and compute first operand of opcode
                                    ; sep is comma for src and space for dst .
PARAM1      JNZ PARAM10             ; -- sep        if prefix <> 'R'
            CALL #SearchRn          ;               case of "REG,"
            JMP PARAM123            ; -- 000R       REG of "REG," found, S=OPCODE=0
; ----------------------------------;
PARAM10     CMP.B #'#',W            ; -- sep        W=first char
            JNE PARAM11
PARAM101    CALL #SearchARG         ; -- xxxx       abort if not found
            MOV #0300h,S            ;               OPCODE = 0300h : MOV #0,dst is coded MOV R3,dst
            CMP #0,TOS              ; -- xxxx       #0 ?
            JZ PARAMENDOF
            MOV #0310h,S            ;               OPCODE = 0310h : MOV #1,dst is coded MOV 0(R3),dst
            CMP #1,TOS              ; -- xxxx       #1 ?
            JZ PARAMENDOF
            MOV #0320h,S            ;               OPCODE = 0320h : MOV #2,dst is coded MOV @R3,dst
            CMP #2,TOS              ; -- xxxx       #2 ?
            JZ PARAMENDOF
            MOV #0220h,S            ;               OPCODE = 0220h : MOV #4,dst is coded MOV @R2,dst
            CMP #4,TOS              ; -- xxxx       #4 ?
            JZ PARAMENDOF
            MOV #0230h,S            ;               OPCODE = 0230h : MOV #8,dst is coded MOV @R2+,dst
            CMP #8,TOS              ; -- xxxx       #8 ?
            JZ PARAMENDOF
            MOV #0330h,S            ;               OPCODE = 0330h : MOV #-1,dst is coded MOV @R3+,dst
            CMP #-1,TOS             ; -- xxxx       #-1 ?
            JZ PARAMENDOF
            MOV #0030h,S            ; -- xxxx       for all other cases : MOV @PC+,dst
; endcase of "&xxxx,"               ;               <== PARAM111
; endcase of ",&xxxx"               ;               <== PARAM111 <== PARAM201
StoreArg    MOV &DP,X               ;
            ADD #2,&DP              ;               cell allot for arg
            MOV TOS,0(X)            ;               compile arg
; endcase of all "#xxxx,"           ;
; endcase of all "&xxxx"            ;
; endcase of all "xxxx(REG)"|"@REG"|"@REG+"               <== PARAM124
PARAMENDOF  MOV @PSP+,TOS           ; --
            MOV @IP+,PC             ; --            S=OPCODE,T=OPCODEADR
; ----------------------------------;
PARAM11     CMP.B   #'&',W          ; -- sep
            JNE     PARAM12
; case of "&xxxx,"                  ; -- sep        search for "&xxxx,"
PARAM110    MOV     #0210h,S        ; -- sep        set code type : xxxx(R2) with AS=0b01 ==> x210h
; case of "&xxxx,"|",&xxxx"         ;               <== PARAM201
PARAM111    CALL    #SearchARG      ; -- arg        abort if not found
            JMP     StoreArg        ; --            then ret
; ----------------------------------;
PARAM12     CMP.B   #'@',W          ; -- sep
            JNE     PARAM13
; case of "@REG,"|"@REG+,"
PARAM120    MOV     #0020h,S        ; -- sep        init OPCODE with indirect code type : AS=0b10
            CALL    #SkipRSearchRn  ;               Z = not found
            JNZ     PARAM123        ; -- Rn         REG of "@REG," found
; case of "@REG+,"                  ; -- addr       search REG of "@REG+"
PARAM121    BIS     #0010h,S        ;               change OPCODE from @REG to @REG+ type
            MOV     #'+',TOS        ; -- sep
            CALL    #SearchRn       ; -- Rn
; case of "@REG+,"|"xxxx(REG),"     ;               <== PARAM13
PARAM122                            ;               case of double separator:   +, and ),
            CMP &SOURCE_LEN,&TOIN   ;               test OPCODE II parameter ending by REG+ or (REG) without comma,
            JZ      PARAM123        ;               i.e. >IN = SOURCE_LEN : don't skip char CR !
            ADD     #1,&TOIN        ; -- 000R       skip "," ready for the second operand search
; case of "@REG+,"|"xxxx(REG),"     ;
; case of "@REG,"                   ; -- 000R       <== PARAM120
; case of "REG,"                    ; -- 000R       <== PARAM1
PARAM123    SWPB    TOS             ; -- 0R00       swap bytes because it's not a dst REG typeI (not a 2 ops inst.)
; case of ",REG"                    ; -- 000R       <== PARAM2  (dst REG typeI)
; case of ",xxxx(REG)"              ; -- 000R       <== PARAM21 (dst REG typeI)
PARAM124    ADD     TOS,S           ; -- 0R00|000R
            JMP     PARAMENDOF
; ----------------------------------;
; case of "xxxx(REG),"              ; -- sep
PARAM13     BIS     #0010h,S        ;               AS=0b01 for indexing address
            CALL    #ComputeIDXpREG ;               compile index xxxx and search REG of "(REG)"
            JMP     PARAM122        ; -- Rn
; ----------------------------------;

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET 2th OPERAND
; ----------------------------------------------------------------------
PARAM2      JNZ PARAM20             ; -- sep        if prefix <> 'R'
            CALL #SearchRn          ; -- sep        case of ",REG"
            JMP     PARAM124        ; -- 000R       REG of ",REG" found
; ----------------------------------;
PARAM20     CMP.B   #'&',W          ;
            JNZ     PARAM21         ;               '&' not found
; case of ",&xxxx"                  ;
PARAM201    BIS     #0082h,S        ;               change OPCODE : AD=1, dst = R2
            JMP     PARAM111        ; -- ' '
; ----------------------------------;
; case of ",xxxx(REG)               ; -- sep
PARAM21     BIS     #0080h,S        ;               set AD=1
            CALL    #ComputeIDXpREG ;               compile index xxxx and search REG of ",xxxx(REG)"
            JMP     PARAM124        ; -- 000R       REG of ",xxxx(REG) found

; ----------------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: reset OPCODE in S reg, set OPCODE addr in T reg,
; move Prefix in W reg, skip prefix in input buffer. Flag SR(Z)=1 if prefix = 'R'.
; ----------------------------------------------------------------------------------------
InitAndSkipPrfx
            MOV #0,S                ;                   reset OPCODE
            MOV &DP,T               ;                   HERE --> OPCODEADR
            ADD #2,&DP              ;                   cell allot for opcode
; SkipPrfx                          ; --                skip all occurring char 'BL' plus one prefix
SkipPrfx    MOV #20h,W              ; --                W=BL
            MOV &TOIN,X             ; --
            ADD &SOURCE_ORG,X       ;
SKIPLOOP    CMP.B @X+,W             ; --                W=BL  does character match?
            JZ SKIPLOOP             ; --
            MOV.B -1(X),W           ;                   W=prefix
            SUB &SOURCE_ORG,X       ; --
            MOV X,&TOIN             ; --                >IN points after prefix
            CMP.B #'R',W            ;                   preset SR(Z)=1 if prefix = 'R'
            MOV @IP+,PC             ; 4

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: OPCODE TYPE 0 : zero operand      :-)
; ----------------------------------------------------------------------
            asmword "RETI"
            mDOCOL
            .word   lit,1300h,COMMA,EXIT

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: OPCODES TYPE I : double operand
; ----------------------------------------------------------------------
;               OPCODE(FEDC)
; OPCODE(code)     = 0bxxxx             opcode
;                   OPCODE(BA98)
;                      = 0bxxxx         src_register,
;                       OPCODE(7)       AD (dst addr type)
;                          = 0b0        ,register
;                          = 0b1        ,x(Rn),&adr
;                        OPCODE(6)      size
; OPCODE(B)                 = 0b0       word
;                           = 0b1       byte
;                         OPCODE(54)    AS (src addr type)
; OPCODE(AS)                 = 0b00     register,
;                            = 0b01     x(Rn),&adr,
;                            = 0b10     @Rn,
;                            = 0b11     @Rn+,
;                           OPCODE(3210)
; OPCODE(dst)                  = 0bxxxx ,dst_register
; ----------------------------------------------------------------------

; TYPE1DOES     -- BODYDOES      search and compute PARAM1 & PARAM2 as src and dst operands then compile instruction
TYPE1DOES   .word   lit,','
            .word   InitAndSkipPrfx ;                       init S=0, T=DP, DP=DP+2 then skip prefix, SR(Z)=1 if prefix = 'R'
            .word   PARAM1          ; -- BODYDOES
            .word   BL,SkipPrfx     ;                       SR(Z)=1 if prefix = 'R'
            .word   PARAM2          ; -- BODYDOES
            mNEXTADR                ;
MAKEOPCODE  MOV     @RSP+,IP
            BIS     @TOS,S          ; -- opcode             generic opcode + customized S
            MOV     S,0(T)          ; -- opcode             store completed opcode
            JMP     PARAMENDOF      ; --                    then EXIT

            asmword "MOV"
            CALL rDODOES
            .word   TYPE1DOES,4000h
            asmword "MOV.B"
            CALL rDODOES
            .word   TYPE1DOES,4040h
            asmword "ADD"
            CALL rDODOES
            .word   TYPE1DOES,5000h
            asmword "ADD.B"
            CALL rDODOES
            .word   TYPE1DOES,5040h
            asmword "ADDC"
            CALL rDODOES
            .word   TYPE1DOES,6000h
            asmword "ADDC.B"
            CALL rDODOES
            .word   TYPE1DOES,6040h
            asmword "SUBC"
            CALL rDODOES
            .word   TYPE1DOES,7000h
            asmword "SUBC.B"
            CALL rDODOES
            .word   TYPE1DOES,7040h
            asmword "SUB"
            CALL rDODOES
            .word   TYPE1DOES,8000h
            asmword "SUB.B"
            CALL rDODOES
            .word   TYPE1DOES,8040h
            asmword "CMP"
            CALL rDODOES
            .word   TYPE1DOES,9000h
            asmword "CMP.B"
            CALL rDODOES
            .word   TYPE1DOES,9040h
            asmword "DADD"
            CALL rDODOES
            .word   TYPE1DOES,0A000h
            asmword "DADD.B"
            CALL rDODOES
            .word   TYPE1DOES,0A040h
            asmword "BIT"
            CALL rDODOES
            .word   TYPE1DOES,0B000h
            asmword "BIT.B"
            CALL rDODOES
            .word   TYPE1DOES,0B040h
            asmword "BIC"
            CALL rDODOES
            .word   TYPE1DOES,0C000h
            asmword "BIC.B"
            CALL rDODOES
            .word   TYPE1DOES,0C040h
            asmword "BIS"
            CALL rDODOES
            .word   TYPE1DOES,0D000h
            asmword "BIS.B"
            CALL rDODOES
            .word   TYPE1DOES,0D040h
            asmword "XOR"
            CALL rDODOES
            .word   TYPE1DOES,0E000h
            asmword "XOR.B"
            CALL rDODOES
            .word   TYPE1DOES,0E040h
            asmword "AND"
            CALL rDODOES
            .word   TYPE1DOES,0F000h
            asmword "AND.B"
            CALL rDODOES
            .word   TYPE1DOES,0F040h

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES TYPE II : single operand
; ----------------------------------------------------------------------
;               OPCODE(FEDCBA987)
; OPCODE(code)     = 0bxxxxxxxxx
;                        OPCODE(6)      size
; OPCODE(B)                 = 0b0       word
;                           = 0b1       byte
;                         OPCODE(54)    (dst addr type)
; OPCODE(AS)                 = 0b00     register
;                            = 0b01     x(Rn),&adr
;                            = 0b10     @Rn
;                            = 0b11     @Rn+
;                           OPCODE(3210)
; OPCODE(dst)                  = 0bxxxx dst register
; ----------------------------------------------------------------------

TYPE2DOES                           ; -- BODYDOES
            .word   BL              ; -- BODYDOES ' '
            .word   InitAndSkipPrfx ;
            .word   PARAM1          ; -- BODYDOES
            mNEXTADR                ;
            MOV     S,W             ;
            AND     #0070h,S        ;                   keep B/W & AS infos in OPCODE
            SWPB    W               ;                   (REG org --> REG dst)
            AND     #000Fh,W        ;                   keep REG
BIS_ASMTYPE BIS     W,S             ; -- BODYDOES       add it in OPCODE
            JMP     MAKEOPCODE      ; -- then end

            asmword "RRC"           ; Rotate Right through Carry ( word)
            CALL rDODOES
            .word   TYPE2DOES,1000h
            asmword "RRC.B"         ; Rotate Right through Carry ( byte)
            CALL rDODOES
            .word   TYPE2DOES,1040h
            asmword "SWPB"          ; Swap bytes
            CALL rDODOES
            .word   TYPE2DOES,1080h
            asmword "RRA"
            CALL rDODOES
            .word   TYPE2DOES,1100h
            asmword "RRA.B"
            CALL rDODOES
            .word   TYPE2DOES,1140h
            asmword "SXT"
            CALL rDODOES
            .word   TYPE2DOES,1180h
            asmword "PUSH"
            CALL rDODOES
            .word   TYPE2DOES,1200h
            asmword "PUSH.B"
            CALL rDODOES
            .word   TYPE2DOES,1240h
            asmword "CALL"
            CALL rDODOES
            .word   TYPE2DOES,1280h

BOUNDERRWM1 ADD     #1,W            ; <== RRAM|RRUM|RRCM|RLAM error
BOUNDERRORW MOV     W,TOS           ; <== PUSHM|POPM|ASM_branch error
BOUNDERROR                          ; <== REG number error
            mASM2FORTH              ; -- n      n = value out of bounds
            .word   DOT,XSQUOTE
            .byte 13,"out of bounds"
            .word   ABORT_TERM

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, CONDITIONAL BRANCHS
; ----------------------------------------------------------------------
;                       ASSEMBLER       FORTH         OPCODE(FEDC)
; OPCODE(code) for TYPE JNE,JNZ         0<>, <>     = 0x20xx + (offset AND 3FF) ; branch if Z = 0
; OPCODE(code) for TYPE JEQ,JZ          0=, =       = 0x24xx + (offset AND 3FF) ; branch if Z = 1
; OPCODE(code) for TYPE JNC,JLO         U<          = 0x28xx + (offset AND 3FF) ; branch if C = 0
; OPCODE(code) for TYPE JC,JHS          U>=         = 0x2Cxx + (offset AND 3FF) ; branch if C = 1
; OPCODE(code) for TYPE JN              0<          = 0x30xx + (offset AND 3FF) ; branch if N = 1
; OPCODE(code) for TYPE JGE             >=          = 0x34xx + (offset AND 3FF) ; branch if (N xor V) = 0
; OPCODE(code) for TYPE JL              <           = 0x38xx + (offset AND 3FF) ; branch if (N xor V) = 1
; OPCODE(code) for TYPE JMP                         = 0x3Cxx + (offset AND 3FF)

            asmword "S>="           ; if >= assertion (opposite of jump if < )
            CALL rDOCON
            .word   3800h

            asmword "S<"            ; if < assertion
            CALL rDOCON
            .word   3400h

            asmword "0>="           ; if 0>= assertion  ; use only with IF UNTIL WHILE !
            CALL rDOCON
            .word   3000h

            asmword "0<"            ; jump if 0<        ; use only with ?GOTO !
            CALL rDOCON
            .word   3000h

            asmword "U<"            ; if U< assertion
            CALL rDOCON
            .word   2C00h

            asmword "U>="           ; if U>= assertion
            CALL rDOCON
            .word   2800h

            asmword "0<>"           ; if <>0 assertion
            CALL rDOCON
            .word   2400h

            asmword "0="            ; if =0 assertion
            CALL rDOCON
            .word   2000h

;ASM IF      OPCODE -- @OPCODE1
            asmword "IF"
ASM_IF      MOV     &DP,W
            MOV     TOS,0(W)        ; compile incomplete opcode
            ADD     #2,&DP
            MOV     W,TOS
            MOV     @IP+,PC

;ASM THEN     @OPCODE --        resolve forward branch
            asmword "THEN"
ASM_THEN    MOV     &DP,W           ; -- @OPCODE    W=dst
            MOV     TOS,Y           ;               Y=@OPCODE
ASM_THEN1   MOV     @PSP+,TOS       ; --
            MOV     Y,X             ;
            ADD     #2,X            ; --        Y=@OPCODE   W=dst   X=src+2
            SUB     X,W             ; --        Y=@OPCODE   W=dst-src+2=displacement*2 (bytes)
            RRA     W               ; --        Y=@OPCODE   W=displacement (words)
            CMP     #512,W
            JC      BOUNDERRORW     ; (JHS) unsigned branch if u> 511
            BIS     W,0(Y)          ; --       [@OPCODE]=OPCODE completed
            MOV     @IP+,PC

; ELSE      @OPCODE1 -- @OPCODE2    branch for IF..ELSE
            asmword "ELSE"
ASM_ELSE    MOV     &DP,W           ; --        W=HERE
            MOV     #3C00h,0(W)     ;           compile unconditionnal branch
            ADD     #2,&DP          ; --        DP+2
            SUB     #2,PSP
            MOV     W,0(PSP)        ; -- @OPCODE2 @OPCODE1
            JMP     ASM_THEN        ; -- @OPCODE2

; BEGIN     -- BEGINadr             initialize backward branch
            asmword "BEGIN"
            MOV #HEREXEC,PC

; UNTIL     @BEGIN OPCODE --   resolve conditional backward branch
            asmword "UNTIL"
ASM_UNTIL   MOV     @PSP+,W         ;  -- OPCODE                        W=@BEGIN
ASM_UNTIL1  MOV     TOS,Y           ;               Y=OPCODE            W=@BEGIN
ASM_UNTIL2  MOV     @PSP+,TOS       ;  --
            MOV     &DP,X           ;  --           Y=OPCODE    X=HERE  W=dst
            SUB     #2,W            ;  --           Y=OPCODE    X=HERE  W=dst-2
            SUB     X,W             ;  --           Y=OPCODE    X=src   W=src-dst-2=displacement (bytes)
            RRA     W               ;  --           Y=OPCODE    X=HERE  W=displacement (words)
            CMP     #-512,W
            JL      BOUNDERRORW     ; signed branch if < -512
            AND     #3FFh,W         ;  --           Y=OPCODE   X=HERE  W=troncated negative displacement (words)
            BIS     W,Y             ;  --           Y=OPCODE (completed)
            MOV     Y,0(X)
            ADD     #2,&DP
            MOV     @IP+,PC

; AGAIN     @BEGIN --      uncond'l backward branch
;   unconditional backward branch
            asmword "AGAIN"
ASM_AGAIN   MOV TOS,W               ;               W=@BEGIN
            MOV #3C00h,Y            ;               Y = asmcode JMP
            JMP ASM_UNTIL2          ;

; WHILE     @BEGIN OPCODE -- @WHILE @BEGIN
            asmword "WHILE"
ASM_WHILE   mDOCOL                  ; -- @BEGIN OPCODE
            .word   ASM_IF,SWAP,EXIT

; REPEAT    @WHILE @BEGIN --     resolve WHILE loop
            asmword "REPEAT"
ASM_REPEAT  mDOCOL                  ; -- @WHILE @BEGIN
            .word   ASM_AGAIN,ASM_THEN,EXIT

; ------------------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : branch up to 3 backward labels and up to 3 forward labels
; ------------------------------------------------------------------------------------------
; used for non canonical branchs, as BASIC language: "goto line x"
; labels BWx and FWx must be respectively set and used at the beginning of line (>IN < 8).
; FWx at the beginning of a line can resolve only one previous GOTO|?GOTO FWx.
; BWx at the beginning of a line can be resolved by any subsequent GOTO|?GOTO BWx.

;BACKWDOES   FORTHtoASM
;            MOV @RSP+,IP
;            MOV @TOS,TOS
;            MOV @TOS,Y              ; Y = ASMBWx
;            MOV @PSP+,TOS           ;
;            MOV @Y,W                ;               W = [BWx]
;            CMP #8,&TOIN            ;               are we colon 8 or more ?
;BACKWUSE    JHS ASM_UNTIL1          ;               yes, use this label
;BACKWSET    MOV &DP,0(Y)            ;               no, set LABEL = DP
;            mNEXT

;; backward label 1
;            asmword "BW1"
;            mdodoes
;            .word BACKWDOES
;            .word ASMBW1            ; in RAM

BACKWDOES   mNEXTADR
            MOV @RSP+,IP            ;
            MOV TOS,Y               ; -- BODY       Y = BWx addr
            MOV @PSP+,TOS           ; --
            MOV @Y,W                ;               W = LABEL
            CMP #8,&TOIN            ;               are we colon 8 or more ?
BACKWUSE    JC ASM_UNTIL1           ;               yes, use this label
BACKWSET    MOV &DP,0(Y)            ;               no, set LABEL = DP
            MOV @IP+,PC

; backward label 1
            asmword "BW1"
            CALL rDODOES            ; CFA
            .word BACKWDOES         ; PFA
            .word 0                 ; BODY
; backward label 2
            asmword "BW2"
            CALL rDODOES
            .word BACKWDOES
            .word 0
; backward label 3
            asmword "BW3"
            CALL rDODOES
            .word BACKWDOES
            .word 0

;FORWDOES    mNEXTADR
;            MOV @RSP+,IP
;            MOV &DP,W               ;
;            MOV @TOS,TOS
;            MOV @TOS,Y              ; -- BODY       Y=@OPCODE of FWx
;            MOV #0,0(TOS)           ;               V3.9: clear @OPCODE of FWx to erratic 2th resolution
;            CMP #8,&TOIN            ;               are we colon 8 or more ?
;FORWUSE     JNC ASM_THEN1           ;               no: resolve FWx with W=DP, Y=@OPCODE
;FORWSET     MOV @PSP+,0(W)          ;               yes compile incomplete opcode
;            ADD #2,&DP              ;                   increment DP
;            MOV W,0(TOS)            ;                   store @OPCODE into ASMFWx
;            MOV @PSP+,TOS           ;   --
;            MOV @IP+,PC
;
;; forward label 1
;            asmword "FW1"
;            CALL rDODOES            ; CFA
;            .word FORWDOES          ;
;            .word ASMFW1            ; in RAM

FORWDOES    mNEXTADR
            MOV @RSP+,IP
            MOV &DP,W               ;
            MOV @TOS,Y              ; -- BODY       Y=@OPCODE of FWx
            MOV #0,0(TOS)           ;               V3.9: clear @OPCODE of FWx to avoid jmp resolution without label
            CMP #8,&TOIN            ;               are we colon 8 or more ?
FORWUSE     JNC ASM_THEN1           ;               no: resolve FWx with W=DP, Y=@OPCODE
FORWSET     MOV @PSP+,0(W)          ;               yes compile opcode (without displacement)
            ADD #2,&DP              ;                   increment DP
            MOV W,0(TOS)            ;                   store @OPCODE into BODY of FWx
            MOV @PSP+,TOS           ; --
            MOV @IP+,PC

; forward label 1
            asmword "FW1"
            CALL rDODOES            ; CFA
            .word FORWDOES          ; PFA
            .word 0                 ; BODY
; forward label 2
            asmword "FW2"
            CALL rDODOES
            .word FORWDOES
            .word 0
; forward label 3
            asmword "FW3"
            CALL rDODOES
            .word FORWDOES
            .word 0

;ASM    GOTO <label>                   --       unconditionnal branch to label
            asmword "GOTO"
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #3C00h,TOS          ;  -- JMP_OPCODE
GOTONEXT    mDOCOL
            .word   TICK            ;  -- OPCODE CFA<label>
            .word   EXECUTE,EXIT

;ASM    <cond> ?GOTO <label>    OPCODE --       conditionnal branch to label
            asmword "?GOTO"
INVJMP      CMP #3000h,TOS          ; invert code jump process
            JZ GOTONEXT             ; case of JN, do nothing
            XOR #0400h,TOS          ; case of: JNZ<-->JZ  JNC<-->JC  JL<-->JGE
            BIT #1000h,TOS          ; 3xxxh case ?
            JZ  GOTONEXT            ; no
            XOR #0800h,TOS          ; complementary action for JL<-->JGE
            JMP GOTONEXT

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES TYPE III : PUSHM|POPM|RLAM|RRAM|RRUM|RRCM
; --------------------------------------------------------------------------------
; PUSHM, syntax:    PUSHM #n,REG  with 0 < n < 17
; POPM syntax:       POPM #n,REG  with 0 < n < 17


; PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
; PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0

; example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
;
; POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
; POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15

; example : POPM #6,IP   pulls Y,X,W,T,S,IP registers from return stack

; RxxM syntax: RxxM #n,REG  with 0 < n < 5

TYPE3DOES                           ; -- BODYDOES
            .word   SkipPrfx        ;
            .word   LIT,','         ; -- BODYDOES ','
            .word   WORDD,QNUMBER   ;
            .word   QFBRAN,NotFound ;                       see INTERPRET
            .word   BL              ; -- BODYDOES n ' '
            .word   InitAndSkipPrfx ; -- BODYDOES n ' '
            .word   PARAM2          ; -- BODYDOES n         S=OPCODE = 0x000R
            mNEXTADR
            MOV     TOS,W           ; -- BODYDOES n         W = n
            MOV     @PSP+,TOS       ; -- BODYDOES
            SUB     #1,W            ;                       W = n floored to 0
            JN      BOUNDERRWM1
            MOV     @TOS,X          ;                       X=OPCODE
            RLAM    #4,X            ;                       OPCODE bit 1000h --> C
            JNC     RxxMINSTRU      ;                       if bit 1000h = 0
PxxxINSTRU  MOV     S,Y             ;                       S=REG, Y=REG to test
            RLAM    #3,X            ;                       OPCODE bit 0200h --> C
            JNC     PUSHMINSTRU     ;                       W=n-1 Y=REG
POPMINSTRU  SUB     W,S             ;                       to make POPM opcode, compute first REG to POP; TI is complicated....
PUSHMINSTRU SUB     W,Y             ;                       Y=REG-(n-1)
            CMP     #16,Y
            JC      BOUNDERRWM1     ;                       JC=JHS    (U>=)
            RLAM    #4,W            ;                       W = n << 4
            JMP     BIS_ASMTYPE     ; BODYDOES --
RxxMINSTRU  CMP     #4,W            ;
            JC      BOUNDERRWM1     ;                       JC=JHS    (U>=)
            SWPB    W               ;                       W = n << 8
            RLAM    #2,W            ;                       W = N << 10
            JMP     BIS_ASMTYPE     ; BODYDOES --

            asmword "RRCM"
            CALL rDODOES
            .word   TYPE3DOES,0050h
            asmword "RRAM"
            CALL rDODOES
            .word   TYPE3DOES,0150h
            asmword "RLAM"
            CALL rDODOES
            .word   TYPE3DOES,0250h
            asmword "RRUM"
            CALL rDODOES
            .word   TYPE3DOES,0350h
            asmword "PUSHM"
            CALL rDODOES
            .word   TYPE3DOES,1500h
            asmword "POPM"
            CALL rDODOES
            .word   TYPE3DOES,1700h


    .IFDEF EXTENDED_MEM
            asmword "RRCM.A"
            CALL rDODOES
            .word   TYPE3DOES,0040h
            asmword "RRAM.A"
            CALL rDODOES
            .word   TYPE3DOES,0140h
            asmword "RLAM.A"
            CALL rDODOES
            .word   TYPE3DOES,0240h
            asmword "RRUM.A"
            CALL rDODOES
            .word   TYPE3DOES,0340h
            asmword "PUSHM.A"
            CALL rDODOES
            .word   TYPE3DOES,1400h
            asmword "POPM.A"
            CALL rDODOES
            .word   TYPE3DOES,1600h

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER:  OPCODE TYPE III bis: CALLA (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers with dot)
; indexed instructions must be written as $xxxx(REG)
; --------------------------------------------------------------------------------
            asmword "CALLA"
            mDOCOL
            .word   BL              ; -- sep
            .word   InitAndSkipPrfx ; -- sep    SR(Z)=1 if prefix = 'R'
            mNEXTADR
            MOV @RSP+,IP
CALLA0      MOV #134h,S             ;           134h<<4 = 1340h = opcode for CALLA Rn
            JNZ CALLA1              ; -- sep    if prefix <> 'R'
CALLA01     CALL #SearchRn          ; -- Rn
CALLA02     RLAM #4,S               ;           (opcode>>4)<<4 = opcode
            BIS TOS,S               ;           update opcode with Rn|$x
            MOV S,0(T)              ;           store opcode
            MOV @PSP+,TOS           ; --
            MOV @IP+,PC             ;
;-----------------------------------;
CALLA1      ADD #2,S                ; -- sep    136h<<4 = opcode for CALLA @REG
            CMP.B #'@',W            ;           Search @REG
            JNZ CALLA2              ;
CALLA11     CALL #SkipRSearchRn     ;
            JNZ  CALLA02            ;           if REG found, update opcode
;-----------------------------------;
            ADD #1,S                ;           137h<<4 = opcode for CALLA @REG+
            MOV #'+',TOS            ; -- sep
            JMP CALLA01             ;
;-----------------------------------;
CALLA2      ADD #2,&DP              ; -- sep    make room for xxxx of #$x.xxxx|&$x.xxxx|$xxxx(REG)
            CMP.B #'#',W            ;
            JNZ CALLA3
            MOV #13Bh,S             ;           13Bh<<4 = opcode for CALLA #$x.xxxx
CALLA21     CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi     store $xxxx of #$x.xxxx|&$x.xxxx
            JMP CALLA02             ;           update opcode with $x. and store opcode
;-----------------------------------;
CALLA3      CMP.B #'&',W            ; -- sep
            JNZ CALLA4              ;
            ADD #2,S                ;           138h<<4 = opcode for CALLA &$x.xxxx
            JMP CALLA21
;-----------------------------------;
CALLA4      SUB #1,S                ;           135h<<4 = opcode for CALLA $xxxx(REG)
CALLA41     CALL #SearchIndex       ; -- n
            MOV TOS,2(T)            ; -- n      store $xxxx of $xxxx(REG)
            MOV #')',TOS            ; -- sep
            JMP CALLA11             ;           search Rn and update opcode

; ===============================================================
; to allow data access beyond $FFFF
; ===============================================================

; MOVA #$x.xxxx|&$x.xxxx|$xxxx(Rs)|Rs|@Rs|@Rs+ , &$x.xxxx|$xxxx(Rd)|Rd
; ADDA (#$x.xxxx|Rs , Rd)
; CMPA (#$x.xxxx|Rs , Rd)
; SUBA (#$x.xxxx|Rs , Rd)

; first argument process ACMS1
;-----------------------------------;
ACMS1       MOV @PSP+,S             ; -- sep        S=BODYDOES
            MOV @S,S                ;               S=opcode
;-----------------------------------;
ACMS10      JNZ ACMS11              ; -- sep        if prefix <> 'R'
ACMS101     CALL #SearchRn          ; -- Rn
ACMS102     RLAM #4,TOS             ;               8<<src
            RLAM #4,TOS             ;
ACMS103     BIS S,TOS               ;               update opcode with src|dst
            MOV TOS,0(T)            ;               save opcode
            MOV T,TOS               ; -- OPCODE_addr
            MOV @IP+,PC             ;
;-----------------------------------;
ACMS11      CMP.B #'#',W            ; -- sep        X=addr
            JNE MOVA12              ;
            BIC #40h,S              ;               set #opcode
ACMS111     ADD #2,&DP              ;               make room for low #$xxxx|&$xxxx|$xxxx(REG)
            CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi         store $xxxx of #$x.xxxx|&$x.xxxx|$xxxx(REG)
            AND #0Fh,TOS            ; -- Hi         sel Hi src
            JMP ACMS102             ;
;-----------------------------------;
MOVA12      CMP.B #'&',W            ; -- sep         case of MOVA &$x.xxxx
            JNZ MOVA13              ;
            XOR #00E0h,S            ;               set MOVA &$x.xxxx, opcode
            JMP ACMS111             ;
;-----------------------------------;
MOVA13      BIC #00F0h,S            ;               set MOVA @REG, opcode
            CMP.B #'@',W            ; -- sep
            JNZ MOVA14              ;
            CALL #SkipRSearchRn     ; -- Rn
            JNZ ACMS102             ;               if @REG found
            BIS #0010h,S            ;               set @REG+ opcode
            MOV #'+',TOS            ; -- '+'
MOVA131     CALL #SearchRn          ; -- Rn         case of MOVA @REG+,|MOVA $x.xxxx(REG),
MOVA132     ADD #1,&TOIN            ;               skip "," ready for the second operand search
            JMP ACMS102             ;
;-----------------------------------;
MOVA14      BIS #0030h,S            ; -- sep        set xxxx(REG), opcode
            ADD #2,&DP              ;               make room for first $xxxx of $xxxx(REG),
            CALL #SearchIndex       ; -- n
            MOV TOS,2(T)            ; -- n          store $xxxx as 2th word
            MOV #')',TOS            ; -- ')'
            CALL #SkipRSearchRn     ; -- Rn
            JMP MOVA132             ;

; 2th argument process ACMS2
;-----------------------------------; -- OPCODE_addr sep
ACMS2       MOV @PSP+,T             ; -- sep        T=OPCODE_addr
            MOV @T,S                ;               S=opcode
;-----------------------------------;
ACMS21      JNZ MOVA22              ; -- sep        if prefix <> 'R'
ACMS211     CALL #SearchRn          ; -- Rn
            JMP ACMS103             ;
;-----------------------------------;
MOVA22      BIC #0F0h,S             ; -- sep
            ADD #2,&DP              ;               make room for $xxxx
            CMP.B #'&',W            ;
            JNZ MOVA23              ;
            BIS #060h,S             ;               set ,&$x.xxxx opcode
            CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi         store $xxxx as 2th word
            JMP ACMS103             ;               update opcode with dst $x and write opcode
;-----------------------------------;
MOVA23      BIS #070h,S             ;               set ,xxxx(REG) opcode
            CALL #SearchIndex       ; -- n
            MOV TOS,2(T)            ; -- n          write $xxxx of ,$xxxx(REG) as 2th word
            MOV #')',TOS            ; -- ")"        as WORD separator to find REG of "xxxx(REG),"
            CALL #SkipRSearchRn     ; -- Rn
            JMP ACMS103

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES IV 2 operands: Adda|Cmpa|Mova|Suba (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------
TYPE4DOES   .word   lit,','         ; -- BODYDOES ","        char separator for PARAM1
            .word   InitAndSkipPRFX ;                       SR(Z)=1 if prefix = 'R'
            .word   ACMS1           ; -- OPCODE_addr
            .word   BL,SkipPRFX     ;                       SR(Z)=1 if prefix = 'R'
            .word   ACMS2           ; -- OPCODE_addr
            .word   DROPEXIT

            asmword "MOVA"
            CALL rDODOES
            .word   TYPE4DOES,00C0h
            asmword "CMPA"
            CALL rDODOES
            .word   TYPE4DOES,00D0h
            asmword "ADDA"
            CALL rDODOES
            .word   TYPE4DOES,00E0h
            asmword "SUBA"
            CALL rDODOES
            .word   TYPE4DOES,00F0h
    .ENDIF ; EXTENDED_MEM
