; -*- coding: utf-8 -*-
;
; ----------------------------------------------------------------------
;forthMSP430FR_EXTD_ASM.asm
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
;       MOV(.B) #0, dst is coded as follow  : MOV(.B) R3, dst           ; 1 cycle,  one word    As=00   register mode
;       MOV(.B) #1, dst is coded as follow  : MOV(.B) 0(R3), dst        ; 2 cycles, one word    AS=01   x(reg)   mode
;       MOV(.B) #2, dst is coded as follow  : MOV(.B) @R3, dst          ; 2 cycles, one word    AS=10   @reg     mode
;       MOV(.B) #4, dst is coded as follow  : MOV(.B) @R2, dst          ; 2 cycles, one word    AS=10   @reg     mode
;       MOV(.B) #8, dst is coded as follow  : MOV(.B) @R2+, dst         ; 2 cycles, one word    AS=11   @reg+    mode
;       MOV(.B) #-1,dst is coded as follow  : MOV(.B) @R3+, dst         ; 2 cycles, one word    AS=11
;       MOV(.B) #xxxx,dst is coded a follow : MOV(.B) @PC+, dst         ; 2 cycles, two words   AS=11   @reg+    mode
;       MOV(.B) &EDE,&TON is coded as follow: MOV(.B) EDE(R2),TON(R2)   ; (R2=0), three words   AS=01, AD=1 x(reg) mode
; ----------------------------------------------------------------------

; PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
; PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0

; example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
;
; POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
; POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15

; example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack


;;Z SKIP      char -- addr               ; skip all occurring character 'char'
;            FORTHWORD "SKIP"            ; used by assembler to parse input stream
SKIP        MOV #SOURCE_LEN,Y       ;2
            MOV TOS,W               ; -- char           W=char
            MOV @Y+,X               ;2 -- char           W=char  X=buf_length
            MOV @Y,TOS              ;2 -- Start_buf_adr  W=char  X=buf_length
            ADD TOS,X               ; -- Start_buf_adr  W=char  X=Start_buf_adr+buf_length=End_buf_addr
            ADD &TOIN,TOS           ; -- Parse_Adr      W=char  X=End_buf_addr
SKIPLOOP    CMP TOS,X               ; -- Parse_Adr      W=char  X=End_buf_addr
            JZ SKIPEND              ; -- Parse_Adr      if end of buffer
            CMP.B @TOS+,W           ; -- Parse_Adr      does character match?
            JZ SKIPLOOP             ; -- Parse_Adr+1
SKIPNEXT    SUB #1,TOS              ; -- addr
SKIPEND     MOV TOS,W               ;
            SUB @Y,W                ; -- addr           W=Parse_Addr-Start_buf_adr=Toin
            MOV W,&TOIN             ;
            MOV @IP+,PC             ; 4

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search argument "xxxx", IP is free
; ----------------------------------------------------------------------

; SearchARG                           ; separator -- n|d or abort" not found"
; ; Search ARG of "#xxxx,"            ; <== PARAM10
; ; Search ARG of "&xxxx,"            ; <== PARAM111
; ; Search ARG of "xxxx(REG),"        ; <== PARAM130
; ; Search ARG of ",&xxxx"            ; <== PARAM111 <== PARAM20
; ; Search ARG of ",xxxx(REG)"        ; <== PARAM210
;             PUSHM #2,S              ;                   PUSHM S,T as OPCODE, OPCODEADR
;             ASMtoFORTH              ; -- separator      search word first
;             .word   WORDD,FIND      ; -- addr
;             .word   ZEROEQUAL
;             .word   QFBRAN,ARGWORD  ; -- addr           if Word found
;             .word   QNUMBER         ;
;             .word   QFBRAN,NotFound ; -- addr           ABORT if not found
; FSearchEnd  .word   SearchEnd       ; -- value          goto SearchEnd if number found
; ARGWORD     .word   $+2             ; -- CFA
;             MOV     @TOS+,S         ; -- PFA            S=DOxxx
; QDOVAR      SUB     #DOVAR,S        ;                   DOxxx = 1287h = DOVAR
; ISDOVAR     JZ      SearchEnd       ; -- addr           PFA = adr of VARIABLE
; QDOCON      ADD     #1,S            ;                   DOxxx = 1286h = DOCON
;             JNZ     ISOTHER         ;
; ISDOCON     MOV     @TOS,TOS        ;
;             JMP     SearchEnd       ; -- cte
; ISOTHER     SUB     #2,TOS          ; -- CFA
; SearchEnd   POPM    #2,S            ;                   POPM T,S
;             MOV     @RSP+,PC        ; RET

SearchARG                           ; separator -- n|d or abort" not found"
; Search ARG of "#xxxx,"            ; <== PARAM10
; Search ARG of "&xxxx,"            ; <== PARAM111
; Search ARG of "xxxx(REG),"        ; <== ComputeARGpREG <== PARAM130
; Search ARG of ",&xxxx"            ; <== PARAM111 <== PARAM20
; Search ARG of ",xxxx(REG)"        ; <== ComputeARGpREG <== PARAM210
            PUSHM #2,S              ;                   PUSHM S,T as OPCODE,OPCODEADR
            PUSH TOS                ;                   push sep, for SrchARGPO
            PUSH &TOIN              ;                   push TOIN, for SrchARGPO
;-----------------------------------;
            ASMtoFORTH              ; -- sep            sep =  ','|'('|' '
            .word   WORDD,FIND      ; -- addr           search word first
            .word   ZEROEQUAL
            .word   QFBRAN,ARGWORD  ; -- addr           if Word found
            .word   QNUMBER         ;
            .word   QFBRAN,SrchARGPO; -- addr           search ARG Plus Offset if not found
            .word   SrchNext        ; -- value          goto SrchNext if number found
ARGWORD     .word   $+2             ; -- CFA
            MOV @TOS+,S             ; -- PFA            S=DOxxx
QDOVAR      SUB #1287h,S            ;                   DOxxx = 1287h = CALL R7 = rDOVAR
ISDOVAR     JZ SrchNext             ; -- addr           PFA = adr of VARIABLE
QDOCON      ADD #1,S                ;                   DOxxx = 1286h = DOCON
            JNZ ISOTHER             ;
ISDOCON     MOV @TOS,TOS            ;
            JMP SrchNext            ; -- cte
ISOTHER     SUB #2,TOS              ; -- CFA
SrchNext    ADD #4,RSP              ;                   remove TOIN,sep
SearchEnd   POPM #2,S               ;                   POPM T,S
            MOV @RSP+,PC            ; RET

;-----------------------------------;
; search for ARGUMENT16+OFFSET      ; up to $FFFF only (FORTH area)
;-----------------------------------;
SrchARGPO   .word $+2
            MOV @RSP+,&TOIN         ;                   TOIN back
            MOV @RSP+,TOS           ; -- sep
            ASMtoFORTH              ;
            .word   LIT,'+'         ; -- sep '+'        search argument
            .word   WORDD,FIND      ; -- sep CFA
            .word   ZEROEQUAL       ;
            .word   QFBRAN,SrchOffst;
            .word   QNUMBER         ; -- sep number
            .word   QFBRAN,NotFound ;                   see INTERPRET
SrchOffst   .word   SWAP            ; -- CFA|number sep
            .word   WORDD,QNUMBER   ;                   Search 'Offset,'|'Offset('|'Offset'
            .word   QFBRAN,NotFound ;                   see INTERPRET
            .word   $+2             ; -- CFA|number offset
            ADD @PSP+,TOS           ; -- (CFA|number + offset)
            JMP SearchEnd           ;

; Arg_Double_to_single conversion needed only for OPCODE type V|VI, 2th pass.
ARGD2S      BIT #UF9,SR             ; -- Lo Hi
            JZ ARGD2SEND
            MOV @PSP+,TOS           ; -- Lo         skip hi
ARGD2SEND   MOV @RSP+,PC            ;

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search REG
; ----------------------------------------------------------------------

; compute arg of "xxxx(REG),"       ;               <== PARAM130, sep=','
; compute arg of ",xxxx(REG)"       ;               <== PARAM210, sep=' '
ComputeARGParenREG                  ; sep -- Rn
            MOV #'(',TOS            ; -- "("        as WORD separator to find xxxx of "xxxx(REG),"
            CALL #SearchARG         ; -- xxxx       aborted if not found
            CALL #ARGD2S            ;               skip arg_hi if DOUBLE
            MOV &DDP,X
            ADD #2,&DDP
            MOV TOS,0(X)            ; -- xxxx       compile xxxx
            MOV #')',TOS            ; -- ")"        prepare separator to search REG of "xxxx(REG)"

; search REG of "xxxx(REG),"    separator = ')' 
; search REG of ",xxxx(REG)"    separator = ')' 
; search REG of "@REG,"         separator = ',' <== PARAM120
; search REG of "@REG+,"        separator = '+' <== PARAM121
; search REG of "REG,"          separator = ',' <== PARAM13
; search REG of ",REG"          separator = BL  <== PARAM21

SearchREG   PUSHM #2,S              ;               PUSHM S,T as OPCODE, OPCODEADR
            CMP &SOURCE_LEN,&TOIN   ;               bad case of ,xxxx without prefix &
            JNZ SearchREG1          ;
            MOV #BAD_CSP,PC         ;               génère une erreur bidon
SearchREG1  PUSH &TOIN              ; -- sep        save >IN
            ADD #1,&TOIN            ;               skip "R"
            ASMtoFORTH              ;               search xx of Rxx
            .word WORDD,QNUMBER     ;
            .word QFBRAN,NOTaREG    ; -- xxxx       if Not a Number
            .word   $+2             ; -- Rn         number is found
            ADD #2,RSP              ;               remove >IN
            CMP #16,TOS             ; -- Rn       
            JC  BOUNDERROR          ;               abort if Rn out of bounds
            JNC SearchEnd           ; -- Rn         Z=0 ==> found

NOTaREG     .word   $+2             ; -- addr       Z=1
            MOV @RSP+,&TOIN         ; -- addr       restore >IN
            JMP SearchEnd           ; -- addr       Z=1 ==> not a register 

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET FIRST OPERAND
; ----------------------------------------------------------------------

; PARAM1 is used for OPCODES type I (double operand) and OPCODES type II (single operand) instructions
; PARAM1 is used for OPCODES type V (double operand) and OPCODES type VI (single operand) extended instructions

; PARAM1     separator --           ; parse input buffer until separator and compute first operand of opcode
                                    ; sep is comma for src and space for dst .
PARAM1      mDOCOL                  ; -- sep        OPCODES types I|V sep = ','  OPCODES types II|VI sep = ' '
            .word   FBLANK,SKIP     ; -- sep addr
            .word   $+2             ; -- sep addr
            MOV     #0,S            ; -- sep addr   reset OPCODE
            MOV     &DDP,T          ; -- sep addr   HERE --> OPCODEADR (opcode is preset to its address !)
            ADD     #2,&DDP         ; -- sep addr   cell allot for opcode
            MOV.B   @TOS,W          ; -- sep addr   W=first char of instruction code
            MOV     @PSP+,TOS       ; -- sep        W=c-addr
            CMP.B   #'#',W          ; -- sep        W=first char
            JNE     PARAM11
; "#" found : case of "#xxxx,"
PARAM10     ADD #1,&TOIN            ; -- sep        skip # prefix
            CALL #SearchARG         ; -- xxxx       abort if not found
            CALL #ARGD2S            ;               skip arg_hi of OPCODE type V
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
            MOV #0330h,S            ; -- -1         OPCODE = 0330h : MOV #-1,dst is coded MOV @R3+,dst
            CMP #-1,TOS             ; -- xxxx       #-1 ?
            JZ PARAMENDOF
            MOV #0030h,S            ; -- xxxx       for all other cases : MOV @PC+,dst
; case of "&xxxx,"                  ;               <== PARAM110
; case of ",&xxxx"                  ;               <== PARAM20
StoreArg    MOV &DDP,X              ;
            ADD #2,&DDP             ;               cell allot for arg
StoreTOS                            ;               <== TYPE1DOES
            MOV TOS,0(X)            ;               compile arg
; endcase of all "&xxxx"            ;
; endcase of all "#xxxx"            ;               <== PARAM101,102,104,108,10M1
; endcase of all "REG"|"@REG"|"@REG+"               <== PARAM124
PARAMENDOF  MOV @PSP+,TOS           ; --
            MOV @RSP+,IP            ;
            MOV @IP+,PC                   ; --            S=OPCODE,T=OPCODEADR
; ----------------------------------;
PARAM11     CMP.B   #'&',W          ; -- sep
            JNE     PARAM12
; case of "&xxxx,"                  ; -- sep        search for "&xxxx,"
PARAM110    MOV     #0210h,S        ; -- sep        set code type : xxxx(SR) with AS=0b01 ==> x210h (and SR=0 !)
; case of "&xxxx,"
; case of ",&xxxx"                  ;               <== PARAM20
PARAM111    ADD     #1,&TOIN        ; -- sep        skip "&" prefix
            CALL    #SearchARG      ; -- arg        abort if not found
            CALL    #ARGD2S         ;               skip argD_hi of opcode type V
            JMP     StoreArg        ; --            then ret
; ----------------------------------;
PARAM12     CMP.B   #'@',W          ; -- sep
            JNE     PARAM13
; case of "@REG,"|"@REG+,"
PARAM120    MOV     #0020h,S        ; -- sep        init OPCODE with indirect code type : AS=0b10
            ADD     #1,&TOIN        ; -- sep        skip "@" prefix
            CALL    #SearchREG      ;               Z = not found
            JNZ     PARAM123        ; -- value      REG of "@REG," found
; case of "@REG+,"                  ; -- addr       REG of "@REG" not found, search REG of "@REG+"
PARAM121    ADD     #0010h,S        ;               change OPCODE from @REG to @REG+ type
            MOV     #'+',TOS        ; -- "+"        as WORD separator to find REG of "@REG+,"
            CALL    #SearchREG      ; -- value|addr X = flag
; case of "@REG+,"                  ;
; case of "xxxx(REG),"              ;               <== PARAM130
                                    ;               case of double separator:   +, and ),
PARAM122    CMP &SOURCE_LEN,&TOIN   ;               test OPCODE II parameter ending by REG+ or (REG) without comma,
            JZ      PARAM123        ;               i.e. >IN = SOURCE_LEN : don't skip char CR !
            ADD     #1,&TOIN        ; -- 000R       skip "," ready for the second operand search
; case of "@REG+,"
; case of "xxxx(REG),"
; case of "@REG,"                   ; -- 000R       <== PARAM120
; case of "REG,"                    ; -- 000R       <== PARAM13
PARAM123    SWPB    TOS             ; -- 0R00       swap bytes because it's not a dst REG typeI (not a 2 ops inst.)
; case of "@REG+,"                  ; -- 0R00                   (src REG typeI)
; case of "xxxx(REG),"              ; -- 0R00                   (src REG typeI or dst REG typeII)
; case of "@REG,"                   ; -- 0R00                   (src REG typeI)
; case of "REG,"                    ; -- 0R00                   (src REG typeI or dst REG typeII)
; case of ",REG"                    ; -- 000R       <== PARAM21     (dst REG typeI)
; case of ",xxxx(REG)"              ; -- 000R       <== PARAM210    (dst REG typeI)
PARAM124    ADD     TOS,S           ; -- 0R00|000R
            JMP     PARAMENDOF
; ----------------------------------;
; case of "REG,"|"xxxx(REG),"       ;               first, searg REG of "REG,"
PARAM13     CALL    #SearchREG      ; -- sep        save >IN for second parsing (case of "xxxx(REG),")
            JNZ     PARAM123        ; -- 000R       REG of "REG," found, S=OPCODE=0
; case of "xxxx(REG),"              ; -- c-addr     "REG," not found
PARAM130    ADD     #0010h,S        ;               AS=0b01 for indexing address
            CALL #ComputeARGparenREG;               compile xxxx and search REG of "(REG)"
            JMP     PARAM122        ; 

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET 2th OPERAND
; ----------------------------------------------------------------------

PARAM3                              ; for OPCODES TYPE III
            MOV     #0,S            ;                       init OPCODE=0
            MOV     &DDP,T          ;                       T=OPCODEADR
            ADD     #2,&DDP         ;                       make room for opcode
; ----------------------------------;
PARAM2      mDOCOL                  ;               parse input buffer until BL and compute this 2th operand
            .word   FBLANK,SKIP     ;               skip space(s) between "arg1," and "arg2" if any; use not S,T.
            .word   $+2             ; -- c-addr     search for '&' of "&xxxx
            CMP.B   #'&',0(TOS)     ;
            MOV     #20h,TOS        ; -- ' '        as WORD separator to find xxxx of ",&xxxx"
            JNE     PARAM21         ;               '&' not found
; case of ",&xxxx"                  ;
PARAM20     ADD     #0082h,S        ;               change OPCODE : AD=1, dst = R2
            JMP     PARAM111        ; -- ' '
; ----------------------------------;
; case of ",REG"|",xxxx(REG)        ; -- ' '        first, search REG of ",REG"
PARAM21     CALL    #SearchREG      ;
            JNZ     PARAM124        ; -- 000R       REG of ",REG" found
; case of ",xxxx(REG)               ; -- addr       REG not found
PARAM210    ADD     #0080h,S        ;               set AD=1
            CALL #ComputeARGparenREG;               compile argument xxxx and search REG of "(REG)"
            JMP     PARAM124        ; -- 000R       REG of "(REG) found

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: OPCODE TYPE 0 : zero operand     f:-)
; ----------------------------------------------------------------------
            asmword "RETI"
            mDOCOL
            .word   lit,1300h,COMMA,EXIT

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: OPCODES TYPE I : double operand
; ----------------------------------------------------------------------
;                                               OPCODE(FEDC)
; OPCODE(code) for TYPE I                          = 0bxxxx             opcode I
;                                                   OPCODE(BA98)
;                                                      = 0bxxxx         src register
;                                                       OPCODE(7)       AD (dst addr type)
;                                                          = 0b0        register
;                                                          = 0b1        x(Rn),&adr
;                                                        OPCODE(6)      size
; OPCODE(B)  for TYPE I or TYPE II                          = 0b0       word
;                                                           = 0b1       byte
;                                                         OPCODE(54)    AS (src addr type)
; OPCODE(AS) for TYPE I or OPCODE(AD) for TYPE II            = 0b00     register
;                                                            = 0b01     x(Rn),&adr
;                                                            = 0b10     @Rn
;                                                            = 0b11     @Rn+
;                                                           OPCODE(3210)
; OPCODE(dst) for TYPE I or TYPE II                            = 0bxxxx dst register
; ----------------------------------------------------------------------

; TYPE1DOES     -- BODYDOES      search and compute PARAM1 & PARAM2 as src and dst operands then compile instruction
TYPE1DOES   .word   lit,',',PARAM1  ; -- BODYDOES
            .word   PARAM2          ; -- BODYDOES           char separator (BL) included in PARAM2
            .word   $+2             ;
MAKEOPCODE  MOV     T,X             ; -- opcode             X= OPCODEADR to compile opcode
            MOV     @TOS,TOS        ; -- opcode             part of instruction
            BIS     S,TOS           ; -- opcode             opcode is complete
            JMP     StoreTOS        ; --                    then EXIT

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
;                                               OPCODE(FEDCBA987)       opcodeII
; OPCODE(code) for TYPE II                         = 0bxxxxxxxxx
;                                                        OPCODE(6)      size
; OPCODE(B)  for TYPE I or TYPE II                          = 0b0       word
;                                                           = 0b1       byte
;                                                         OPCODE(54)    (dst addr type)
; OPCODE(AS) for TYPE I or OPCODE(AD) for TYPE II            = 0b00     register
;                                                            = 0b01     x(Rn),&adr
;                                                            = 0b10     @Rn
;                                                            = 0b11     @Rn+
;                                                           OPCODE(3210)
; OPCODE(dst) for TYPE I or TYPE II                            = 0bxxxx dst register
; ----------------------------------------------------------------------

TYPE2DOES   .word   FBLANK,PARAM1   ; -- BODYDOES
            .word   $+2             ;
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
            mDOCOL                  ; -- n      n = value out of bounds
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

            asmword "0<"            ; jump if 0<        ; use only with ?JMP ?GOTO !
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
ASM_IF      MOV     &DDP,W
            MOV     TOS,0(W)        ; compile incomplete opcode
            ADD     #2,&DDP
            MOV     W,TOS
            MOV @IP+,PC

;ASM THEN     @OPCODE --        resolve forward branch
            asmword "THEN"
ASM_THEN    MOV     &DDP,W          ; -- @OPCODE    W=dst
            MOV     TOS,Y           ;               Y=@OPCODE
ASM_THEN1   MOV     @PSP+,TOS       ; --
            MOV     Y,X             ;
            ADD     #2,X            ; --        Y=@OPCODE   W=dst   X=src+2
            SUB     X,W             ; --        Y=@OPCODE   W=dst-src+2=displacement*2 (bytes)
            RRA     W               ; --        Y=@OPCODE   W=displacement (words)
            CMP     #512,W
            JC      BOUNDERRORW     ; (JHS) unsigned branch if u> 511
            BIS     W,0(Y)          ; --       [@OPCODE]=OPCODE completed
            MOV @IP+,PC

;C ELSE     @OPCODE1 -- @OPCODE2    branch for IF..ELSE
            asmword "ELSE"
ASM_ELSE    MOV     &DDP,W          ; --        W=HERE
            MOV     #3C00h,0(W)     ;           compile unconditionnal branch
            ADD     #2,&DDP         ; --        DP+2
            SUB     #2,PSP
            MOV     W,0(PSP)        ; -- @OPCODE2 @OPCODE1
            JMP     ASM_THEN        ; -- @OPCODE2

; BEGIN     -- BEGINadr             initialize backward branch
            asmword "BEGIN"
            MOV #HERE,PC

;C UNTIL    @BEGIN OPCODE --   resolve conditional backward branch
            asmword "UNTIL"
ASM_UNTIL   MOV     @PSP+,W         ;  -- OPCODE                        W=@BEGIN
ASM_UNTIL1  MOV     TOS,Y           ;               Y=OPCODE            W=@BEGIN
ASM_UNTIL2  MOV     @PSP+,TOS       ;  --
            MOV     &DDP,X          ;  --           Y=OPCODE    X=HERE  W=dst
            SUB     #2,W            ;  --           Y=OPCODE    X=HERE  W=dst-2
            SUB     X,W             ;  --           Y=OPCODE    X=src   W=src-dst-2=displacement (bytes)
            RRA     W               ;  --           Y=OPCODE    X=HERE  W=displacement (words)
            CMP     #-512,W
            JL      BOUNDERRORW     ; signed branch if < -512
            AND     #3FFh,W         ;  --           Y=OPCODE   X=HERE  W=troncated negative displacement (words)
            BIS     W,Y             ;  --           Y=OPCODE (completed)
            MOV     Y,0(X)
            ADD     #2,&DDP
            MOV @IP+,PC

;X AGAIN    @BEGIN --      uncond'l backward branch
;   unconditional backward branch
            asmword "AGAIN"
ASM_AGAIN   MOV TOS,W               ;               W=@BEGIN
            MOV #3C00h,Y            ;               Y = asmcode JMP
            JMP ASM_UNTIL2          ;

;C WHILE    @BEGIN OPCODE -- @WHILE @BEGIN
            asmword "WHILE"
ASM_WHILE   mDOCOL                  ; -- @BEGIN OPCODE
            .word   ASM_IF,SWAP,EXIT

;C REPEAT   @WHILE @BEGIN --     resolve WHILE loop
            asmword "REPEAT"
ASM_REPEAT  mDOCOL                  ; -- @WHILE @BEGIN
            .word   ASM_AGAIN,ASM_THEN,EXIT

; ------------------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : branch up to 3 backward labels and up to 3 forward labels
; ------------------------------------------------------------------------------------------
; used for non canonical branchs, as BASIC language: "goto line x"
; labels BWx and FWx must be set at the beginning of line (>IN < 8).
; FWx at the beginning of a line can resolve only one previous GOTO|?GOTO  FWx.
; BWx at the beginning of a line can be resolved by any subsequent GOTO|?GOTO BWx.

BACKWDOES   .word   $+2
            MOV @RSP+,IP            ;
            MOV TOS,Y               ; -- PFA        Y = ASMBWx addr
            MOV @PSP+,TOS           ; --
            MOV @Y,W                ;               W = LABEL
            CMP #8,&TOIN            ;               are we colon 8 or more ?
BACKWUSE    JC  ASM_UNTIL1          ;               yes, use this label  
BACKWSET    MOV &DDP,0(Y)           ;               no, set LABEL = DP
            MOV @IP+,PC

; backward label 1
            asmword "BW1"
            CALL rDODOES
            .word BACKWDOES
            .word 0
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

FORWDOES    .word   $+2
            MOV @RSP+,IP
            MOV &DDP,W              ;
            MOV @TOS,Y              ; -- PFA        Y=[ASMFWx]
            CMP #8,&TOIN            ;               are we colon 8 or more ?
FORWUSE     JNC ASM_THEN1           ;               no: resolve FWx with W=DDP, Y=ASMFWx
FORWSET     MOV @PSP+,0(W)          ;               yes compile incomplete opcode
            ADD #2,&DDP             ;                   increment DDP
            MOV W,0(TOS)            ;                   store @OPCODE into ASMFWx
            MOV @PSP+,TOS           ;   --
            MOV @IP+,PC

; forward label 1
            asmword "FW1"
            CALL rDODOES
            .word FORWDOES
            .word 0
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

;ASM    <cond> ?GOTO <label>    OPCODE --       conditionnal branch to label
            asmword "?GOTO"
INVJMP      CMP #3000h,TOS          ; invert code jump process
            JZ GOTONEXT             ; case of JN, do nothing
            XOR #0400h,TOS          ; case of: JNZ<-->JZ  JNC<-->JC  JL<-->JGE
            BIT #1000h,TOS          ; 3xxxh case ?
            JZ  GOTONEXT            ; no
            XOR #0800h,TOS          ; complementary action for JL<-->JGE
GOTONEXT    mDOCOL
            .word   TICK            ;  -- OPCODE CFA<label>
            .word   EXECUTE,EXIT

;ASM    GOTO <label>                   --       unconditionnal branch to label
            asmword "GOTO"
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #3C00h,TOS          ; asmcode JMP
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

TYPE3DOES   .word   FBLANK,SKIP     ;                       skip spaces if any
            .word   $+2             ; -- BODYDOES c-addr
            ADD     #1,&TOIN        ;                       skip "#"
            MOV     #',',TOS        ; -- BODYDOES ","
            ASMtoFORTH
            .word   WORDD,QNUMBER
            .word   QFBRAN,NotFound ;                       ABORT
            .word   PARAM3          ; -- BODYDOES 0x000N    S=OPCODE = 0x000R
            .word   $+2
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
            SWPB    W               ; -- BODYDOES           W = n << 8
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
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

            asmword "CALLA"
            mDOCOL
            .word FBLANK,SKIP       ; -- addr
            .word   $+2
            MOV &DDP,T              ;           T = DDP
            ADD #2,&DDP             ;           make room for opcode
            MOV.B @TOS,TOS          ; -- char   First char of opcode
CALLA0      MOV #134h,S             ;           134h<<4 = 1340h = opcode for CALLA Rn
            CMP.B #'R',TOS   
            JNZ CALLA1
CALLA01     MOV.B #' ',TOS          ;        
CALLA02     CALL #SearchREG         ; -- Rn
CALLA03     RLAM #4,S               ;           (opcode>>4)<<4 = opcode
            BIS TOS,S               ;           update opcode
            MOV S,0(T)              ;           store opcode
            MOV @PSP+,TOS
            MOV @RSP+,IP 
            MOV @IP+,PC
;-----------------------------------;
CALLA1      ADD #2,S                ;           136h<<4 = opcode for CALLA @REG
            CMP.B #'@',TOS          ; -- char   Search @REG
            JNZ CALLA2              ;
            ADD #1,&TOIN            ;           skip '@'
            MOV.B #' ',TOS          ; -- ' '
            CALL #SearchREG         ;
            JNZ  CALLA03            ;           if REG found, update opcode
;-----------------------------------;
            ADD #1,S                ;           137h<<4 = opcode for CALLA @REG+
            MOV #'+',TOS            ; -- '+'
            JMP CALLA02             ;
;-----------------------------------;
CALLA2      ADD #2,&DDP             ;           make room for xxxx of #$x.xxxx|&$x.xxxx|$0.xxxx(REG)
            CMP.B #'#',TOS          ;
            JNZ CALLA3
            MOV #13Bh,S             ;           13Bh<<4 = opcode for CALLA #$x.xxxx
CALLA21     ADD #1,&TOIN            ;           skip '#'|'&'
CALLA22     CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi     store #$xxxx|&$xxxx
            JMP CALLA03             ;           update opcode with $x. and store opcode
;-----------------------------------;
CALLA3      CMP.B #'&',TOS   
            JNZ CALLA4              ;
            ADD #2,S                ;           138h<<4 = opcode for CALLA &$x.xxxx
            JMP CALLA21
;-----------------------------------;
CALLA4      MOV.B #'(',TOS          ; -- "("
            SUB #1,S                ;           135h<<4 = opcode for CALLA $0.xxxx(REG)
CALLA41     CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi     store $xxxx 
            MOV #')',TOS            ; -- ')'
            JMP CALLA02             ;           search Rn and update opcode
    

; ===============================================================
; to allow data access beyond $FFFF
; ===============================================================

; MOVA (#$x.xxxx|&$x.xxxx|$.xxxx(Rs)|Rs|@Rs|@Rs+ , &|Rd|$.xxxx(Rd)) 
; ADDA (#$x.xxxx|Rs , Rd) 
; CMPA (#$x.xxxx|Rs , Rd) 
; SUBA (#$x.xxxx|Rs , Rd) 

; first argument process ACMS1
;-----------------------------------;
ACMS1       mDOCOL                  ; -- BODYDOES ','   
            .word   FBLANK,SKIP     ; -- BODYDOES ',' addr
            .word   $+2             ;
            MOV.B @TOS,X            ;                   X=first char of opcode string
            MOV @PSP+,TOS           ; -- BODYDOES ','
            MOV @PSP+,S             ; -- ','            S=BODYDOES
            MOV @S,S                ;                   S=opcode
            MOV &DDP,T              ;                   T=DDP
            ADD #2,&DDP             ;                   make room for opcode
;-----------------------------------;
ACMS10      CMP.B #'R',X            ; -- ','    
            JNZ ACMS11              ;
ACMS101     CALL #SearchREG         ; -- Rn         src
ACMS102     RLAM #4,TOS             ;               8<<src
            RLAM #4,TOS             ;
ACMS103     BIS S,TOS               ;               update opcode with src|dst
            MOV TOS,0(T)            ;               save opcode
            MOV T,TOS               ; -- OPCODE_addr
            MOV @RSP+,IP 
            MOV @IP+,PC             ;
;-----------------------------------;
ACMS11      CMP.B #'#',X            ; -- ','        X=addr
            JNE MOVA12              ;
            BIC #40h,S              ;               set #opcode
ACMS111     ADD #1,&TOIN            ;               skip '#'|'&'
            ADD #2,&DDP             ;               make room for low #$xxxx|&$xxxx|$xxxx(REG)
            CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi         store $xxxx of #$x.xxxx|&$x.xxxx|$x.xxxx(REG)
            AND #0Fh,TOS            ; -- Hi         sel Hi src
            JMP ACMS102             ;
;-----------------------------------;
MOVA12      CMP.B #'&',X            ; -- ','        case of MOVA &$x.xxxx
            JNZ MOVA13              ;
            XOR #00E0h,S            ;               set MOVA &$x.xxxx, opcode                 
            JMP ACMS111             ;
;-----------------------------------;
MOVA13      BIC #00F0h,S            ;               set MOVA @REG, opcode
            CMP.B #'@',X            ; -- ','
            JNZ MOVA14              ;
            ADD #1,&TOIN            ;               skip '@'
            CALL #SearchREG         ; -- Rn 
            JNZ ACMS102             ;               if @REG found
;-----------------------------------;
            BIS #0010h,S            ;               set @REG+ opcode
            MOV #'+',TOS            ; -- '+'
MOVA131     CALL #SearchREG         ; -- Rn         case of MOVA @REG+,|MOVA $x.xxxx(REG),
            CMP &SOURCE_LEN,&TOIN   ;               test TYPE II first parameter ending by @REG+ (REG) without comma,
            JZ ACMS102              ;               i.e. may be >IN = SOURCE_LEN: don't skip char CR !
            ADD #1,&TOIN            ;               skip "," ready for the second operand search
            JMP ACMS102             ;
;-----------------------------------;
MOVA14      BIS #0030h,S            ;               set xxxx(REG), opcode
            ADD #2,&DDP             ; -- ','        make room for first $xxxx of $0.xxxx(REG),
            MOV #'(',TOS            ; -- "("        as WORD separator to find xxxx of "xxxx(REG),"
            CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi         store $xxxx as 2th word
            MOV #')',TOS            ; -- ')'
            JMP MOVA131             ;

; 2th argument process ACMS2
;-----------------------------------;
ACMS2       mDOCOL                  ; -- OPCODE_addr 
            .word FBLANK,SKIP       ; -- OPCODE_addr addr
            .word   $+2             ;
            MOV @PSP+,T             ; -- addr       T=OPCODE_addr
            MOV @T,S                ;               S=opcode
            MOV.B @TOS,X            ; -- addr       X=first char of string instruction         
            MOV.B #' ',TOS          ; -- ' '
;-----------------------------------;
ACMS21      CMP.B #'R',X            ; -- ' '
            JNZ MOVA22              ;
ACMS211     CALL #SearchREG         ; -- Rn
            JMP ACMS103             ;
;-----------------------------------;
MOVA22      BIC #0F0h,S             ;
            ADD #2,&DDP             ; -- ' '        make room for $xxxx
            CMP.B #'&',X            ;
            JNZ MOVA23              ;
            BIS #060h,S             ;               set ,&$x.xxxx opcode
            ADD #1,&TOIN            ;               skip '&'
            CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi         store $xxxx as 2th word
            JMP ACMS103             ;               update opcode with dst $x and write opcode
;-----------------------------------;
MOVA23      BIS #070h,S             ;               set ,xxxx(REG) opcode
            MOV #'(',TOS            ; -- "("        as WORD separator to find xxxx of "xxxx(REG),"
            CALL #SearchARG         ; -- Lo Hi
            MOV @PSP+,2(T)          ; -- Hi         write $xxxx of ,$0.xxxx(REG) as 2th word
            MOV #')',TOS            ; -- ")"        as WORD separator to find REG of "xxxx(REG),"
            JMP ACMS211

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES IV 2 operands: Adda|Cmpa|Mova|Suba (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

TYPE4DOES   .word   lit,','         ; -- BODYDOES ","        char separator for PARAM1
            .word   ACMS1           ; -- OPCODE_addr
            .word   ACMS2           ; -- OPCODE_addr
            .word   DROP,EXIT

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


; PRMX1 is used for OPCODES type V (double operand) and OPCODES type VI (single operand) extended instructions

PRMX1       mDOCOL                  ; -- sep            OPCODES type V|VI separator = ','|' '
            .word FBLANK,SKIP       ; -- sep addr
            .word   $+2             ;
            MOV.B @TOS,X            ; -- sep addr       X= first char of opcode string
            MOV @PSP+,TOS           ; -- sep
            MOV #1800h,S            ;                   init S=Extended word
;-----------------------------------;
PRMX10      CMP.B #'R',X            ; -- sep
            JNZ PRMX11              ;
PRMX101     CALL #SearchREG         ; -- Rn             Rn of REG; call SearchREG only to update >IN
PRMX102     MOV S,TOS               ; -- EW             update Extended word
PRMX103     MOV @RSP+,IP 
            MOV @IP+,PC             ; -- Ext_Word
;-----------------------------------;
PRMX11      MOV #0,&RPT_WORD        ;                   clear RPT
            CMP.B #'#',X            ; -- sep
            JNZ PRMX12
PRMX111     ADD #1,&TOIN            ; -- sep            skip '#'
PRMX112     CALL #SearchARG         ; -- Lo Hi          search $x.xxxx of #x.xxxx,
            ADD #2,PSP              ; -- Hi             pop unused low word
PRMX113     AND #0Fh,TOS            ;                   
PRMX114     RLAM #3,TOS
            RLAM #4,TOS             ; -- 7<<Hi
PRMX115     BIS TOS,S               ;                   update extended word with srcHi
            JMP PRMX102
;-----------------------------------;
PRMX12      CMP.B #'&',X            ; -- sep
            JZ PRMX111
;-----------------------------------;
PRMX13      CMP.B #'@',X            ; -- sep
            JNZ PRMX14
PRMX131     ADD #1,&TOIN            ; -- sep            skip '@'
PRMX132     CALL #SearchREG         ; -- Rn             Rn of @REG,
            JNZ PRMX102             ;                   if Rn found
;-----------------------------------;
            MOV #'+',TOS            ; -- '+'
PRMX133     ADD #1,&TOIN            ;                   skip '@'
            CALL #SearchREG         ; -- Rn             Rn of @REG+,
PRMX134     CMP &SOURCE_LEN,&TOIN   ;                   test case of TYPE VI first parameter without ','
            JZ PRMX102              ;                   don't take the risk of skipping CR !
            ADD #1,&TOIN            ;                   skip ',' ready to search 2th operand
            JMP PRMX102             ;
;-----------------------------------;
PRMX14      MOV #'(',TOS            ; -- '('            to find $x.xxxx of "x.xxxx(REG),"
            CALL #SearchARG         ; -- Lo Hi                  
            MOV TOS,0(PSP)          ; -- Hi Hi
PRMX141     MOV #')',TOS            ; -- Hi ')'
            CALL #SearchREG         ; -- Hi Rn
            MOV @PSP+,TOS           ; -- Hi
            AND #0Fh,TOS
            BIS TOS,S
            JMP PRMX134
;-----------------------------------;

; PRMX2 is used for OPCODES type V (double operand) extended instructions
        
;-----------------------------------;
PRMX2       mDOCOL                  ; -- Extended_Word 
            .word   FBLANK,SKIP     ; -- Extended_Word addr
            .word   $+2             ;
            MOV @PSP+,S             ; -- addr     S=Extended_Word
            MOV.B @TOS,X            ; -- addr     X=first char of code instruction
            MOV #' ',TOS            ; -- ' '
;-----------------------------------;
PRMX20      CMP.B #'R',X            ; -- ' '
            JZ  PRMX102             ;               extended word not to be updated  
;-----------------------------------;
PRMX21      MOV #0,&RPT_WORD        ;
            CMP.B #'&',X            ;
            JNZ PRMX22              ;
PRMX211     ADD #1,&TOIN            ; -- ' '      skip '&'
PRMX212     CALL #SearchARG         ; -- Lo Hi
PRMX213     ADD #2,PSP              ; -- hi       pop low word
            AND #0Fh,TOS            ; -- Hi
            JMP PRMX115             ;               update Extended word with dst_Hi
;-----------------------------------;
PRMX22      MOV #'(',TOS            ; -- '('      as WORD separator to find xxxx of "xxxx(REG)"
            CALL #SearchARG         ; -- Lo Hi    search x.xxxx of x.xxxx(REG)
            JMP PRMX213
    
;; UPDATE_eXtendedWord
;;-----------------------------------;
;UPDATE_XW                           ;   BODYDOES Extended_Word -- BODYDOES+2    >IN R--
;            MOV &DDP,T              ;
;            ADD #2,&DDP             ;                   make room for extended word
;            MOV TOS,S               ;                   S = Extended_Word
;            MOV @PSP+,TOS           ; -- BODYDOES
;            BIS &RPT_WORD,S         ;                   update Extended_word with RPT_WORD
;            MOV #0,&RPT_WORD        ;                   clear RPT before next instruction
;            BIS @TOS+,S             ; -- BODYDOES+2     update Extended_word with [BODYDOES] = A/L bit
;            MOV S,0(T)              ;                   store extended word
;            MOV @RSP+,&TOIN         ;                   >IN R--     restore >IN at the start of instruction string
;            MOV @IP+,PC             ;
;;-----------------------------------;

;-----------------------------------;
; UPDATE_eXtendedWord
;-----------------------------------;
UPDATE_XW                           ;   BODYDOES >IN Extended_Word -- BODYDOES+2
            MOV @PSP+,&TOIN         ; -- BODYDOES EW    restore >IN at the start of instruction string
            MOV &DDP,T              ;
            ADD #2,&DDP             ;                   make room for extended word
            MOV TOS,S               ;                   S = Extended_Word
            MOV @PSP+,TOS           ;
            BIS &RPT_WORD,S         ;                   update Extended_word with RPT_WORD
            MOV #0,&RPT_WORD        ;                   clear RPT before next instruction
            BIS @TOS+,S             ; -- BODYDOES+2     update Extended_word with [BODYDOES] = A/L bit
            MOV S,0(T)              ;                   store extended word
            MOV @IP+,PC             ;
;-----------------------------------;

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES V extended double operand
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------


; these instructions below are processed in two pass:
; pass 1: extended word process by TYPE5DOES with [BODYDOES] value
; pass 2: instruction process by TYPE1DOES with [BODYDOES+2] value
; all numeric arguments must be written as DOUBLE numbers (including a point) : $x.xxxx

TYPE5DOES                               ; -- BODYDOES
;            .word   LIT,TOIN,FETCH,TOR  ;               R-- >IN      save >IN for 2th pass
;            .word   lit,','             ; -- BODYDOES ','            char separator for PRMX1
;            .word   PRMX1,PRMX2         ; -- BODYDOES Extended_Word
;            .word   UPDATE_XW           ; -- BODYDOES+2              >IN is restored ready for 2th pass
;            .word   BRAN,TYPE1DOES      ; -- BODYDOES+2              2th pass: completes instruction with opcode = [BODYDOES+2]
            .word   LIT,TOIN,FETCH      ; -- BODYDOES >IN
            .word   lit,','             ; -- BODYDOES >IN ','            char separator for PRMX1
            .word   PRMX1,PRMX2         ; -- BODYDOES >IN Extended_Word
            .word   UPDATE_XW           ; -- BODYDOES+2              >IN is restored ready for 2th pass
            .word   BRAN,TYPE1DOES      ; -- BODYDOES+2              2th pass: completes instruction with opcode = [BODYDOES+2]

            asmword "MOVX"
            CALL rDODOES
            .word   TYPE5DOES   ; [PFADOES] = TYPE5DOES
            .word   40h         ; [BODYDOES] = A/L bit
            .word   4000h       ; [BODYDOES+2] = OPCODE
            asmword "MOVX.A"
            CALL rDODOES
            .word   TYPE5DOES,0,4040h
            asmword "MOVX.B"
            CALL rDODOES
            .word   TYPE5DOES,40h,4040h
            asmword "ADDX"
            CALL rDODOES          
            .word   TYPE5DOES,40h,5000h
            asmword "ADDX.A"
            CALL rDODOES          
            .word   TYPE5DOES,0,5040h
            asmword "ADDX.B"
            CALL rDODOES          
            .word   TYPE5DOES,40h,5040h
            asmword "ADDCX"  
            CALL rDODOES          
            .word   TYPE5DOES,40h,6000h
            asmword "ADDCX.A"
            CALL rDODOES          
            .word   TYPE5DOES,0,6040h
            asmword "ADDCX.B"
            CALL rDODOES          
            .word   TYPE5DOES,40h,6040h
            asmword "SUBCX"  
            CALL rDODOES          
            .word   TYPE5DOES,40h,7000h
            asmword "SUBCX.A"
            CALL rDODOES
            .word   TYPE5DOES,0,7040h
            asmword "SUBCX.B"
            CALL rDODOES          
            .word   TYPE5DOES,40h,7040h
            asmword "SUBX"   
            CALL rDODOES          
            .word   TYPE5DOES,40h,8000h
            asmword "SUBX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,8040h
            asmword "SUBX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,8040h
            asmword "CMPX"   
            CALL rDODOES          
            .word   TYPE5DOES,40h,9000h
            asmword "CMPX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,9040h
            asmword "CMPX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,9040h
            asmword "DADDX"
            CALL rDODOES
            .word   TYPE5DOES,40h,0A000h
            asmword "DADDX.A"
            CALL rDODOES          
            .word   TYPE5DOES,0,0A040h
            asmword "DADDX.B"
            CALL rDODOES          
            .word   TYPE5DOES,40h,0A040h
            asmword "BITX"   
            CALL rDODOES          
            .word   TYPE5DOES,40h,0B000h
            asmword "BITX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,0B040h
            asmword "BITX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,0B040h
            asmword "BICX"   
            CALL rDODOES          
            .word   TYPE5DOES,40h,0C000h
            asmword "BICX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,0C040h
            asmword "BICX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,0C040h
            asmword "BISX"
            CALL rDODOES
            .word   TYPE5DOES,40h,0D000h
            asmword "BISX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,0D040h
            asmword "BISX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,0D040h
            asmword "XORX"   
            CALL rDODOES          
            .word   TYPE5DOES,40h,0E000h
            asmword "XORX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,0E040h
            asmword "XORX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,0E040h
            asmword "ANDX"   
            CALL rDODOES          
            .word   TYPE5DOES,40h,0F000h
            asmword "ANDX.A" 
            CALL rDODOES          
            .word   TYPE5DOES,0,0F040h
            asmword "ANDX.B" 
            CALL rDODOES          
            .word   TYPE5DOES,40h,0F040h

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES VI extended single operand (take count of RPT)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

; these instructions below are processed in two pass:
; pass 1: extended word process by TYPE6DOES with [BODYDOES] value
; pass 2: instruction process by TYPE2DOES with [BODYDOES+2] value
; all numeric arguments must be written as DOUBLE numbers (including a point) : $x.xxxx

TYPE6DOES                               ; -- BODYDOES
;            .word   LIT,TOIN,FETCH,TOR  ;               R-- >IN      save >IN for 2th pass
;            .word   FBLANK              ; -- BODYDOES ' '
;            .word   PRMX1               ; -- BODYDOES Extended_Word  
;            .word   UPDATE_XW           ; -- BODYDOES+2
;            .word   BRAN,TYPE2DOES      ; -- BODYDOES+2         pass 2: completes instruction with opcode = [BODYDOES+2]
            .word   LIT,TOIN,FETCH      ; -- BODYDOES >IN
            .word   FBLANK              ; -- BODYDOES >IN ' '
            .word   PRMX1               ; -- BODYDOES >IN Extended_Word  
            .word   UPDATE_XW           ; -- BODYDOES+2
            .word   BRAN,TYPE2DOES      ; -- BODYDOES+2         pass 2: completes instruction with opcode = [BODYDOES+2]

            asmword "RRCX"              ; ZC=0; RRCX Rx,Rx may be repeated by prefix RPT #n|Rn
            CALL rDODOES
            .word   TYPE6DOES,40h,1000h
            asmword "RRCX.A"            ; ZC=0; RRCX.A Rx may be repeated by prefix RPT #n|Rn 
            CALL rDODOES          
            .word   TYPE6DOES,0,1040h
            asmword "RRCX.B"            ; ZC=0; RRCX.B Rx may be repeated by prefix RPT #n|Rn
            CALL rDODOES          
            .word   TYPE6DOES,40h,1040h
            asmword "RRUX"              ; ZC=1; RRUX Rx may be repeated by prefix RPT #n|Rn
            CALL rDODOES          
            .word   TYPE6DOES,140h,1000h
            asmword "RRUX.A"            ; ZC=1; RRUX.A Rx may be repeated by prefix RPT #n|Rn 
            CALL rDODOES          
            .word   TYPE6DOES,100h,1040h
            asmword "RRUX.B"            ; ZC=1; RRUX.B Rx may be repeated by prefix RPT #n|Rn 
            CALL rDODOES          
            .word   TYPE6DOES,140h,1040h
            asmword "SWPBX"
            CALL rDODOES          
            .word   TYPE6DOES,40h,1080h
            asmword "SWPBX.A"
            CALL rDODOES          
            .word   TYPE6DOES,0,1080h
            asmword "RRAX"
            CALL rDODOES          
            .word   TYPE6DOES,40h,1100h
            asmword "RRAX.A"
            CALL rDODOES          
            .word   TYPE6DOES,0,1140h
            asmword "RRAX.B"
            CALL rDODOES          
            .word   TYPE6DOES,40h,1140h
            asmword "SXTX"
            CALL rDODOES
            .word   TYPE6DOES,40h,1180h
            asmword "SXTX.A" 
            CALL rDODOES          
            .word   TYPE6DOES,0,1180h
            asmword "PUSHX"  
            CALL rDODOES          
            .word   TYPE6DOES,40h,1200h
            asmword "PUSHX.A"
            CALL rDODOES          
            .word   TYPE6DOES,0,1240h
            asmword "PUSHX.B"
            CALL rDODOES          
            .word   TYPE6DOES,40h,1240h

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, RPT instruction before REG|REG,REG eXtended instructions
; ----------------------------------------------------------------------
; RPT #1 is coded 0 in repetition count field (count n-1)
; please note that "RPT Rn" with [Rn]=0 has same effect as "RPT #1"

RPT_WORD    .word 0

            asmword "RPT"           ; RPT #n | RPT Rn     repeat n | [Rn]+1 times modulo 16
            mdocol
            .word FBLANK,SKIP
            .word   $+2             ; -- addr
            MOV @TOS,X              ;           X=char
            MOV.B #' ',TOS          ; -- ' '    as separator
            CMP.B #'R',X
            JNZ RPT1
            CALL #SearchREG         ; -- Rn
            JZ RPT1                 ;           if not found
            BIS #80h,TOS            ; -- $008R  R=Rn
            JMP RPT2
RPT1        CALL #SearchARG         ; -- $xxxx
            SUB #1,TOS              ; -- n-1
            AND #0Fh,TOS            ; -- $000x
RPT2        MOV TOS,&RPT_WORD
            MOV @PSP+,TOS
            MOV @RSP+,IP 
            MOV @IP+,PC
