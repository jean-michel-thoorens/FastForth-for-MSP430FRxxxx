; -*- coding: utf-8 -*-
; http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
; Copyright (C) <2017>  <J.M. THOORENS>
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


;;Z SKIP      char -- addr               ; skip all occurring character 'char' in input stream
;            FORTHWORD "SKIP"            ; used by assembler to parse input stream
SKIP:       MOV     #SOURCE_LEN,Y       ;
            MOV     @Y+,X               ; -- char       X=length
            MOV     @Y,W                ; -- char       X=length    W=org
            ADD     W,X                 ; -- char       X=End       W=org
            ADD     &TOIN,W             ; -- char       X=End       W=ptr
SKIPLOOP:   CMP     W,X                 ; -- char       ptr=End ?
            JZ      SKIPEND             ; -- char       yes
            CMP.B   @W+,TOS             ; -- char       does character match?
            JZ      SKIPLOOP            ; -- char       yes
SKIPNEXT:   SUB     #1,W                ; -- char
SKIPEND:    MOV     W,TOS               ; -- addr
            SUB     @Y,W                ; -- addr       W=Ptr-Org=Toin
            MOV     W,&TOIN             ;
            mNEXT

; https://forth-standard.org/standard/double/TwoCONSTANT
; udlo/dlo/Flo udhi/dhi/Qhi --         create a double or a Q15.16 CONSTANT
        FORTHWORD "2CONSTANT"
TWOCONSTANT 
        mDOCOL
        .word CREATE
        .word COMMA,COMMA       ; compile udhi/dhi/Qhi then udlo/dlo/Qlo
        .word DOES
PFA2CTE FORTHtoASM              ; equ 2@
        SUB #2,PSP
        MOV 2(TOS),0(PSP)
        MOV @TOS,TOS
        mSEMI

; https://forth-standard.org/standard/double/TwoVARIABLE
        FORTHWORD "2VARIABLE"
        mDOCOL
        .word CREATE
        .word lit,4,ALLOT
        .word DOES
PFA2VAR .word EXIT

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search argument "xxxx", IP is free
; ----------------------------------------------------------------------

SearchARG                               ; separator -- n|d or abort" not found"
; ----------------------------------------------------------------------
; Search ARG of "#xxxx,"                ; <== PARAM10
; Search ARG of "&xxxx,"                ; <== PARAM111
; Search ARG of "xxxx(REG),"            ; <== PARAM130
; Search ARG of ",&xxxx"                ; <== PARAM111 <== PARAM20
; Search ARG of ",xxxx(REG)"            ; <== PARAM210
            PUSHM #2,S                  ;                   PUSHM S,T
            ASMtoFORTH                  ; -- separator      search word first
            .word   WORDD,FIND          ; -- addr
            .word   QTBRAN,SearchARGW   ; -- addr           if word found
            .word   QNUMBER             ;
            .word   QFBRAN,NotFound      ; -- addr           ABORT if not found
FSearchEnd  .word   SearchEnd           ; -- value          goto SearchEnd if number found
SearchARGW  FORTHtoASM                  ; -- xt             xt = CFA
            MOV     @TOS,X              ;
QDOVAR      CMP     #DOVAR,X
            JNZ     QDOCON
            ADD     #2,TOS              ; -- PFA            remplace CFA by PFA for VARIABLE words
            JMP     SearchEnd
QDOCON      CMP     #DOCON,X
            JNZ     QDODOES
            MOV     2(TOS),TOS          ; -- cte            remplace CFA by [PFA] for CONSTANT (and CREATEd) words
            JMP     SearchEnd           ;
QDODOES     CMP     #DODOES,X
            JNZ     SearchEnd
            ADD     #4,TOS              ; -- BODY           leave BODY address for DOES words
            CMP     #PFA2CTE,2(X)       ;                   PFA = 2CONSTANT DOES ?
            JZ      DOESDOUBLE
            CMP     #PFA2VAR,2(X)       ;                   PFA = 2VARIABLE DOES ?
            JNZ     SearchEnd
DOESDOUBLE  CALL    #PFA2CTE+2          ; -- Lo Hi          2@
            FORTHtoASM
SearchEnd   POPM    #2,S                ;                   POPM T,S
            RET                         ;

; Arg_Double_to_single conversion needed only for OPCODE type V|VI, 2th pass.
ARGD2S      BIT #UF9,SR         ; -- Lo Hi
            JZ ARGD2SEND
            MOV @PSP+,TOS       ; -- Lo         skip hi
ARGD2SEND   RET

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search REG
; ----------------------------------------------------------------------

; compile $xxxx of $xxxx(REG) then SearchREG
; ----------------------------------------------------------------------
ComputeARGParenREG              ; sep -- Rn
; compute REG of "xxxx(REG),"   ;               <== PARAM130, sep=','
; compute REG of ",xxxx(REG)"   ;               <== PARAM210, sep=' '
            MOV #'(',TOS        ; -- "("        as WORD separator to find xxxx of "xxxx(REG),"
            CALL #SearchARG     ; -- xxxx       aborted if not found
            CALL #ARGD2S        ;               skip arg_hi if DOUBLE
            MOV &DDP,X
            ADD #2,&DDP
            MOV TOS,0(X)        ; -- xxxx       compile xxxx
            MOV #')',TOS        ; -- ")"        prepare separator to search REG of "xxxx(REG)"

; search REG of "xxxx(REG),"    separator = ')' 
; search REG of ",xxxx(REG)"    separator = ')' 
; search REG of "@REG,"         separator = ',' <== PARAM120
; search REG of "@REG+,"        separator = '+' <== PARAM121
; search REG of "REG,"          separator = ',' <== PARAM13
; search REG of ",REG"          separator = BL  <== PARAM21
SearchREG                       ; sep -- Rn
            PUSHM #2,S          ;               PUSHM S,T
            PUSH &TOIN          ; -- sep        save >IN
            ADD #1,&TOIN        ;               skip "R"
            ASMtoFORTH          ;               search xx of Rxx
            .word WORDD,QNUMBER ;
            .word QFBRAN,NOTaREG ; -- xxxx       if Not a Number
            FORTHtoASM          ; -- Rn         number is found
            ADD #2,RSP          ;               remove >IN
            CMP #16,TOS         ; -- Rn       
            JHS BOUNDERROR      ;               abort if Rn out of bounds
            JLO SearchEnd       ; -- Rn         Z=0 ==> found

NOTaREG     FORTHtoASM          ; -- addr       Z=1
            MOV @RSP+,&TOIN     ; -- addr       restore >IN
            JMP SearchEnd       ; -- addr       Z=1 ==> not a register 


; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET FIRST OPERAND
; ----------------------------------------------------------------------

; PARAM1 is used for OPCODES type I (double operand) and OPCODES type II (single operand) instructions
; PARAM1 is used for OPCODES type V (double operand) and OPCODES type VI (single operand) extended instructions

; PARAM1     separator --                   ; parse input buffer until separator and compute first operand of opcode
                                            ; sep is comma for src and space for dst .

PARAM1      mDOCOL                          ; -- sep        OPCODES types I|V sep = ','  OPCODES types II|VI sep = ' '
            .word   FBLANK,SKIP             ; -- sep addr
            FORTHtoASM                      ; -- sep addr
            MOV     #0,S                    ; -- sep addr   reset ASMTYPE
            MOV     &DDP,T                  ; -- sep addr   HERE --> OPCODEADR (opcode is preset to its address !)
            ADD     #2,&DDP                 ; -- sep addr   cell allot for opcode
            MOV.B   @TOS,W                  ; -- sep addr   W=first char of instruction code
            MOV     @PSP+,TOS               ; -- sep        W=c-addr
            CMP.B   #'#',W                  ; -- sep        W=first char
            JNE     PARAM11

; "#" found : case of "#xxxx,"
PARAM10     ADD     #1,&TOIN                ; -- sep        skip # prefix
            CALL    #SearchARG              ; -- xxxx       abort if not found
            CALL #ARGD2S                    ;               skip arg_hi

PARAM100    CMP #0,TOS                      ; -- xxxx       = 0 ?
            JNE PARAM101
; case of "#0,"
            MOV #0300h,S                    ; -- 0          example : MOV #0,dst <=> MOV R3,dst
            JMP PARAMENDOF

PARAM101    CMP #1,TOS                      ; -- xxxx       = 1 ?
            JNE PARAM102
; case of "#1,"
            MOV #0310h,S                    ; -- 1          example : MOV #1,dst <=> MOV 0(R3),dst
            JMP PARAMENDOF

PARAM102    CMP #2,TOS                      ; -- xxxx       = 2 ?
            JNE PARAM104
; case of "#2,"
            MOV #0320h,S                    ; -- 2          ASMTYPE = 0320h  example : MOV #2, <=> MOV @R3,
            JMP PARAMENDOF

PARAM104    CMP #4,TOS                      ; -- xxxx       = 4 ?
            JNE PARAM108
; case of "#4,"
            MOV #0220h,S                    ; -- 4          ASMTYPE = 0220h  example : MOV #4, <=> MOV @R2,
            JMP PARAMENDOF

PARAM108    CMP #8,TOS                      ; -- xxxx       = 8 ?
            JNE PARAM10M1
; case of "#8,"
            MOV #0230h,S                    ; -- 8          ASMTYPE = 0230h  example : MOV #8, <=> MOV @R2+,
            JMP PARAMENDOF

PARAM10M1   CMP #-1,TOS                     ; -- xxxx       = -1 ?
            JNE PARAM1000
; case of "#-1,"
            MOV #0330h,S                    ; -- -1         ASMTYPE = 0330h  example : MOV #-1 <=> MOV @R3+,
            JMP PARAMENDOF

; case of all others "#xxxx,"               ; -- xxxx
PARAM1000   MOV #0030h,S                    ; -- xxxx       add immediate code type : @PC+,

; case of "&xxxx,"                          ;               <== PARAM110
; case of ",&xxxx"                          ;               <== PARAM20
StoreArg    MOV &DDP,X                      ; -- xxxx
            ADD #2,&DDP                     ;               cell allot for arg

StoreTOS                                    ;               <== TYPE1DOES
   MOV TOS,0(X)                             ;               compile arg
; endcase of all "&xxxx"                    ;
; endcase of all "#xxxx"                    ;               <== PARAM101,102,104,108,10M1
; endcase of all "REG"|"@REG"|"@REG+"       ;               <== PARAM124
PARAMENDOF  MOV @PSP+,TOS                   ; --
            MOV @RSP+,IP
            mNEXT                           ; --
; ------------------------------------------

PARAM11     CMP.B   #'&',W                  ; -- sep
            JNE     PARAM12

; case of "&xxxx,"                          ; -- sep        search for "&xxxx,"
PARAM110    MOV     #0210h,S                ; -- sep        set code type : xxxx(SR) with AS=0b01 ==> x210h (and SR=0 !)

; case of "&xxxx,"
; case of ",&xxxx"                          ;               <== PARAM20
PARAM111    ADD     #1,&TOIN                ; -- sep        skip "&" prefix
            CALL    #SearchARG              ; -- arg        abort if not found
            CALL    #ARGD2S                 ;               skip arg_hi
            JMP     StoreArg                ; --            then ret
; ------------------------------------------

PARAM12     CMP.B   #'@',W                  ; -- sep
            JNE     PARAM13

; case of "@REG,"|"@REG+,"
PARAM120    MOV     #0020h,S                ; -- sep        init ASMTYPE with indirect code type : AS=0b10
            ADD     #1,&TOIN                ; -- sep        skip "@" prefix
            CALL    #SearchREG              ;               Z = not found
            JNZ     PARAM123                ; -- value      REG of "@REG," found

; case of "@REG+,"                          ; -- addr       REG of "@REG" not found, search REG of "@REG+"
PARAM121    ADD     #0010h,S                ;               change ASMTYPE from @REG to @REG+ type
            MOV     #'+',TOS                ; -- "+"        as WORD separator to find REG of "@REG+,"
            CALL    #SearchREG              ; -- value|addr X = flag
            
; case of "@REG+,"                          ;
; case of "xxxx(REG),"                      ;               <== PARAM130
                                            ;               case of double separator:   +, and ),
PARAM122    CMP     &SOURCE_LEN,&TOIN       ;               test OPCODE II parameter ending by REG+ or (REG) without comma,
            JZ      PARAM123                ;               i.e. >IN = SOURCE_LEN : don't skip char CR !
            ADD     #1,&TOIN                ; -- 000R       skip "," ready for the second operand search

; case of "@REG+,"
; case of "xxxx(REG),"
; case of "@REG,"                           ; -- 000R       <== PARAM120
; case of "REG,"                            ; -- 000R       <== PARAM13
PARAM123    SWPB    TOS                     ; -- 0R00       swap bytes because it's not a dst REG typeI (not a 2 ops inst.)

; case of "@REG+,"                          ; -- 0R00                   (src REG typeI)
; case of "xxxx(REG),"                      ; -- 0R00                   (src REG typeI or dst REG typeII)
; case of "@REG,"                           ; -- 0R00                   (src REG typeI)
; case of "REG,"                            ; -- 0R00                   (src REG typeI or dst REG typeII)
; case of ",REG"                            ; -- 000R       <== PARAM21     (dst REG typeI)
; case of ",xxxx(REG)"                      ; -- 000R       <== PARAM210    (dst REG typeI)
PARAM124    ADD     TOS,S                   ; -- 0R00|000R
            JMP     PARAMENDOF
; ------------------------------------------

; case of "REG,"|"xxxx(REG),"               ;               first, searg REG of "REG,"
PARAM13     CALL    #SearchREG              ; -- sep        save >IN for second parsing (case of "xxxx(REG),")
            JNZ     PARAM123                ; -- 000R       REG of "REG," found, S=ASMTYPE=0

; case of "xxxx(REG),"                      ; -- c-addr     "REG," not found
PARAM130    ADD     #0010h,S                ;               AS=0b01 for indexing address
            CALL    #ComputeARGparenREG     ;               compile xxxx and search REG of "(REG)"
            JMP     PARAM122                ; 

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET 2th OPERAND
; ----------------------------------------------------------------------

INITPARAM2                                  ; for OPCODES TYPE III
            MOV     #0,S                    ;                       init ASMTYPE=0
            MOV     &DDP,T                  ;                       T=OPCODEADR
            ADD     #2,&DDP                 ;                       make room for opcode

; PARAM2 is used for OPCODES type I (double operand) instructions
; PARAM2 is used for OPCODES type V (double operand) extended instructions

; PARAM2     --                             ; parse input buffer until BL and compute this 2th operand
PARAM2      mDOCOL                          ;
            .word   FBLANK,SKIP             ;               skip space(s) between "arg1," and "arg2" if any; use not S,T.
            FORTHtoASM                      ; -- c-addr     search for '&' of "&xxxx
            CMP.B   #'&',0(TOS)             ;
            MOV     #20h,TOS                ; -- ' '        as WORD separator to find xxxx of ",&xxxx"
            JNE     PARAM21                 ;               '&' not found

; case of ",&xxxx"                          ;
PARAM20     ADD     #0082h,S                ;               change ASMTYPE : AD=1, dst = R2
            JMP     PARAM111                ; -- ' '
; ------------------------------------------

; case of ",REG"|",xxxx(REG)                ; -- ' '        first, search REG of ",REG"
PARAM21     CALL    #SearchREG              ;
            JNZ     PARAM124                ; -- 000R       REG of ",REG" found

; case of ",xxxx(REG)                       ; -- addr       REG not found
PARAM210    ADD     #0080h,S                ;               set AD=1
            CALL    #ComputeARGparenREG     ;               compile argument xxxx and search REG of "(REG)"
            JMP     PARAM124                ; -- 000R       REG of "(REG) found


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
TYPE1DOES                                   ; -- BODYDOES
            .word   lit,','                 ; -- BODYDOES ','        char separator for PARAM1
            .word   PARAM1                  ; -- BODYDOES
            .word   PARAM2                  ; -- BODYDOES            char separator (BL) included in PARAM2
            FORTHtoASM                      ;
MAKEOPCODE  MOV     @TOS,TOS                ; -- opcode             part of instruction
            BIS     S,TOS                   ; -- opcode             opcode is complete
            MOV     T,X                     ; -- opcode             X= OPCODEADR to compile opcode
            JMP     StoreTOS                ; --                    then EXIT

            asmword "MOV"
            mDODOES
            .word   TYPE1DOES,4000h

            asmword "MOV.B"
            mDODOES
            .word   TYPE1DOES,4040h

            asmword "ADD"
            mDODOES
            .word   TYPE1DOES,5000h

            asmword "ADD.B"
            mDODOES
            .word   TYPE1DOES,5040h

            asmword "ADDC"
            mDODOES
            .word   TYPE1DOES,6000h

            asmword "ADDC.B"
            mDODOES
            .word   TYPE1DOES,6040h

            asmword "SUBC"
            mDODOES
            .word   TYPE1DOES,7000h

            asmword "SUBC.B"
            mDODOES
            .word   TYPE1DOES,7040h

            asmword "SUB"
            mDODOES
            .word   TYPE1DOES,8000h

            asmword "SUB.B"
            mDODOES
            .word   TYPE1DOES,8040h

            asmword "CMP"
            mDODOES
            .word   TYPE1DOES,9000h

            asmword "CMP.B"
            mDODOES
            .word   TYPE1DOES,9040h

            asmword "DADD"
            mDODOES
            .word   TYPE1DOES,0A000h

            asmword "DADD.B"
            mDODOES
            .word   TYPE1DOES,0A040h

            asmword "BIT"
            mDODOES
            .word   TYPE1DOES,0B000h

            asmword "BIT.B"
            mDODOES
            .word   TYPE1DOES,0B040h

            asmword "BIC"
            mDODOES
            .word   TYPE1DOES,0C000h

            asmword "BIC.B"
            mDODOES
            .word   TYPE1DOES,0C040h

            asmword "BIS"
            mDODOES
            .word   TYPE1DOES,0D000h

            asmword "BIS.B"
            mDODOES
            .word   TYPE1DOES,0D040h

            asmword "XOR"
            mDODOES
            .word   TYPE1DOES,0E000h

            asmword "XOR.B"
            mDODOES
            .word   TYPE1DOES,0E040h

            asmword "AND"
            mDODOES
            .word   TYPE1DOES,0F000h

            asmword "AND.B"
            mDODOES
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

TYPE2DOES                                   ; -- BODYDOES
            .word   FBLANK                  ; -- BODYDOES ' '   char separator for PARAM1
            .word   PARAM1                  ; -- BODYDOES
            FORTHtoASM                      ;
            MOV     S,W                     ;
            AND     #0070h,S                ;                   keep B/W & AS infos in ASMTYPE
            SWPB    W                       ;                   (REG org --> REG dst)
            AND     #000Fh,W                ;                   keep REG
BIS_ASMTYPE BIS     W,S                     ; -- BODYDOES       add it in ASMTYPE
            JMP     MAKEOPCODE              ; -- then end

            asmword "RRC"          ; Rotate Right through Carry ( word)
            mDODOES
            .word   TYPE2DOES,1000h

            asmword "RRC.B"         ; Rotate Right through Carry ( byte)
            mDODOES
            .word   TYPE2DOES,1040h

            asmword "SWPB"          ; Swap bytes
            mDODOES
            .word   TYPE2DOES,1080h

            asmword "RRA"
            mDODOES
            .word   TYPE2DOES,1100h

            asmword "RRA.B"
            mDODOES
            .word   TYPE2DOES,1140h

            asmword "SXT"
            mDODOES
            .word   TYPE2DOES,1180h

            asmword "PUSH"
            mDODOES
            .word   TYPE2DOES,1200h

            asmword "PUSH.B"
            mDODOES
            .word   TYPE2DOES,1240h

            asmword "CALL"
            mDODOES
            .word   TYPE2DOES,1280h


BOUNDERRWM1 ADD     #1,W                    ; <== RRAM|RRUM|RRCM|RLAM error
BOUNDERRORW MOV     W,TOS                   ; <== PUSHM|POPM|ASM_branch error
BOUNDERROR                                  ; <== REG number error
            mDOCOL                          ; -- n      n = value out of bounds
            .word   DOT,XSQUOTE
            .byte   13,"out of bounds"
            .word   QABORTYES



; ----------------------------------------------------------------

TYPE3DOES                                   ; -- BODYDOES
            .word   FBLANK,SKIP             ;                       skip spaces if any
            FORTHtoASM                      ; -- PFADOES c-addr
            ADD     #1,&TOIN                ;                       skip "#"
            MOV     #',',TOS                ; -- PFADOES ","
            ASMtoFORTH
            .word   WORDD,QNUMBER
            .word   QFBRAN,NotFound         ;                       ABORT
            .word   INITPARAM2              ; -- PFADOES 0x000N     S=ASMTYPE = 0x000R
            FORTHtoASM
            MOV     TOS,W                   ; -- BODYDOES n         W = n
            MOV     @PSP+,TOS               ; -- BODYDOES
            SUB     #1,W                    ;                       W = n floored to 0
            JN      BOUNDERRWM1
            MOV     @TOS,X                  ;                       X=OPCODE
            RLAM    #4,X                    ;                       OPCODE bit 1000h --> C
            JNC     RxxMINSTRU              ;                       if bit 1000h = 0
PxxxINSTRU  MOV     S,Y                     ;                       S=REG, Y=REG to test
            RLAM    #3,X                    ;                       OPCODE bit 0200h --> C                  
            JNC     PUSHMINSTRU             ;                       W=n-1 Y=REG
POPMINSTRU  SUB     W,S                     ;                       to make POPM opcode, compute first REG to POP; TI is complicated....
PUSHMINSTRU SUB     W,Y                     ;                       Y=REG-(n-1)
            CMP     #16,Y
            JHS     BOUNDERRWM1             ;                       JC=JHS    (U>=)
            RLAM    #4,W                    ;                       W = n << 4      
            JMP     BIS_ASMTYPE             ; BODYDOES --            
RxxMINSTRU  CMP     #4,W                    ;
            JHS     BOUNDERRWM1             ;                       JC=JHS    (U>=)
            SWPB    W                       ; -- BODYDOES           W = n << 8
            RLAM    #2,W                    ;                       W = N << 10
            JMP     BIS_ASMTYPE             ; BODYDOES --

; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES TYPE III : PUSHM|POPM|RLAM|RRAM|RRUM|RRCM
; --------------------------------------------------------------------------------

            asmword "RRCM.A"
            mDODOES
            .word   TYPE3DOES,0040h

            asmword "RRCM"
            mDODOES
            .word   TYPE3DOES,0050h

            asmword "RRAM.A"
            mDODOES
            .word   TYPE3DOES,0140h

            asmword "RRAM"
            mDODOES
            .word   TYPE3DOES,0150h

            asmword "RLAM.A"
            mDODOES
            .word   TYPE3DOES,0240h

            asmword "RLAM"
            mDODOES
            .word   TYPE3DOES,0250h

            asmword "RRUM.A"
            mDODOES
            .word   TYPE3DOES,0340h

            asmword "RRUM"
            mDODOES
            .word   TYPE3DOES,0350h

            asmword "PUSHM.A"
            mDODOES
            .word   TYPE3DOES,1400h

            asmword "PUSHM"
            mDODOES
            .word   TYPE3DOES,1500h

            asmword "POPM.A"
            mDODOES
            .word   TYPE3DOES,1600h

            asmword "POPM"
            mDODOES
            .word   TYPE3DOES,1700h

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

CODE_JMP    mDOCON                      ; branch always
            .word   3C00h

            asmword "S>="               ; if >= assertion (opposite of jump if < )
            mDOCON
            .word   3800h

            asmword "S<"                ; if < assertion
            mDOCON
            .word   3400h

            asmword "0>="               ; if 0>= assertion  ; use only with IF UNTIL WHILE !
            mDOCON
            .word   3000h

            asmword "0<"                ; jump if 0<        ; use only with ?JMP ?GOTO !
            mDOCON
            .word   3000h

            asmword "U<"                ; if U< assertion
            mDOCON
            .word   2C00h

            asmword "U>="               ; if U>= assertion
            mDOCON
            .word   2800h

            asmword "0<>"               ; if <>0 assertion
            mDOCON
            .word   2400h

            asmword "0="                ; if =0 assertion
            mDOCON
            .word   2000h

;ASM IF      OPCODE -- @OPCODE1
            asmword "IF"
ASM_IF      MOV     &DDP,W
            MOV     TOS,0(W)            ; compile incomplete opcode
            ADD     #2,&DDP
            MOV     W,TOS
            mNEXT

;ASM THEN     @OPCODE --        resolve forward branch
            asmword "THEN"
ASM_THEN    MOV     &DDP,W              ; -- @OPCODE    W=dst
            MOV     TOS,Y               ;               Y=@OPCODE
ASM_THEN1   MOV     @PSP+,TOS           ; --
            MOV     Y,X                 ;
            ADD     #2,X                ; --        Y=@OPCODE   W=dst   X=src+2
            SUB     X,W                 ; --        Y=@OPCODE   W=dst-src+2=displacement*2 (bytes)
            RRA     W                   ; --        Y=@OPCODE   W=displacement (words)
            CMP     #512,W
            JC      BOUNDERRORW         ; (JHS) unsigned branch if u> 511
            BIS     W,0(Y)              ; --       [@OPCODE]=OPCODE completed
            mNEXT

;C ELSE     @OPCODE1 -- @OPCODE2    branch for IF..ELSE
            asmword "ELSE"
ASM_ELSE    MOV     &DDP,W              ; --        W=HERE
            MOV     #3C00h,0(W)         ;           compile unconditionnal branch
            ADD     #2,&DDP             ; --        DP+2
            SUB     #2,PSP
            MOV     W,0(PSP)            ; -- @OPCODE2 @OPCODE1
            JMP     ASM_THEN            ; -- @OPCODE2

;C BEGIN    -- @BEGIN                   same as FORTH counterpart

;C UNTIL    @BEGIN OPCODE --   resolve conditional backward branch
            asmword "UNTIL"
ASM_UNTIL   MOV     @PSP+,W             ;  -- OPCODE           W=dst
ASM_UNTIL1  MOV     TOS,Y
            MOV     @PSP+,TOS           ;  --
            MOV     &DDP,X              ;  --       Y=OPCODE   X=HERE  W=dst
            SUB     #2,W                ;  --       Y=OPCODE   X=HERE  W=dst-2
            SUB     X,W                 ;  --       Y=OPCODE   X=src   W=src-dst-2=displacement (bytes)
            RRA     W                   ;  --       Y=OPCODE   X=HERE  W=displacement (words)
            CMP     #-512,W
            JL      BOUNDERRORW         ; signed branch if < -512
            AND     #3FFh,W             ;  --       Y=OPCODE   X=HERE  W=troncated negative displacement (words)
            BIS     W,Y                 ;  --       Y=OPCODE (completed)
            MOV     Y,0(X)
            ADD     #2,&DDP
            mNEXT

;X AGAIN    @BEGIN --      uncond'l backward branch
;   unconditional backward branch
            asmword "AGAIN"
ASM_AGAIN   mDOCOL                      ; -- @BEGIN
            .word   CODE_JMP            ; -- @BEGIN opcode
            .word   ASM_UNTIL           ; --
            .word   EXIT                ; --

;C WHILE    @BEGIN OPCODE -- @WHILE @BEGIN
            asmword "WHILE"
ASM_WHILE   mDOCOL                      ; -- @BEGIN OPCODE
            .word   ASM_IF              ; -- @BEGIN @WHILE
            .word   SWAP                ; -- @WHILE @BEGIN
            .word   EXIT

;C REPEAT   @WHILE @BEGIN --     resolve WHILE loop
            asmword "REPEAT"
ASM_REPEAT  mDOCOL                      ; -- @WHILE @BEGIN
            .word   CODE_JMP            ; -- @WHILE @BEGIN opcode
            .word   ASM_UNTIL           ; -- @WHILE
            .word   ASM_THEN            ; --
            .word   EXIT

; ------------------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : branch up to 3 backward labels and up to 3 forward labels
; ------------------------------------------------------------------------------------------
; used for non canonical branchs, as BASIC language: "goto line x"
; when a branch to label is resolved, it's ready for new use

BACKWARDDOES        ;
    FORTHtoASM
    MOV @RSP+,IP
    MOV @TOS,TOS
    MOV TOS,Y       ; Y = ASMBWx
    MOV @PSP+,TOS   ; 
    MOV @Y,W        ;               W = [ASMBWx]
    CMP #0,W        ;               W = 0 ?
    MOV #0,0(Y)     ;               preset [ASMBWx] = 0 for next use
BACKWUSE            ; -- OPCODE
    JNZ ASM_UNTIL1
BACKWSET            ; --
    MOV &DDP,0(Y)   ;               [ASMBWx] = DDP
    mNEXT

; backward label 1
            asmword "BW1"
            mdodoes
            .word BACKWARDDOES
            .word ASMBW1    ; in RAM

; backward label 2
            asmword "BW2"
            mdodoes
            .word BACKWARDDOES
            .word ASMBW2    ; in RAM

; backward label 3
            asmword "BW3"
            mdodoes
            .word BACKWARDDOES
            .word ASMBW3    ; in RAM

FORWARDDOES
    FORTHtoASM
    MOV @RSP+,IP
    MOV &DDP,W      ;
    MOV @TOS,TOS
    MOV @TOS,Y      ;               Y=[ASMFWx]
    CMP #0,Y        ;               ASMFWx = 0 ? (FWx is free?)
    MOV #0,0(TOS)   ;               preset [ASMFWx] for next use
FORWUSE             ; PFA -- @OPCODE
    JNZ ASM_THEN1   ;               no
FORWSET             ; OPCODE PFA -- 
    MOV @PSP+,0(W)  ; -- PFA        compile incomplete opcode
    ADD #2,&DDP     ;               increment DDP
    MOV W,0(TOS)    ;               store @OPCODE into ASMFWx
    MOV @PSP+,TOS   ;   --
    mNEXT


; forward label 1
            asmword "FW1"
            mdodoes
            .word FORWARDDOES
            .word ASMFW1    ; in RAM

; forward label 2
            asmword "FW2"
            mdodoes
            .word FORWARDDOES
            .word ASMFW2    ; in RAM

; forward label 3
            asmword "FW3"
            mdodoes
            .word FORWARDDOES
            .word ASMFW3    ; in RAM


; invert FORTH conditionnal branch      FORTH_JMP_OPCODE -- LABEL_JMP_OPCODE
INVJMP      CMP #3000h,TOS  
            JZ INVJMPEND    ; case of JN, do nothing
            XOR #0400h,TOS  ; case of: JNZ<-->JZ  JNC<-->JC  JL<-->JGE
            BIT #1000h,TOS  ; 3xxxh case ?
            JZ  INVJMPEND   ; no
            XOR #0800h,TOS  ; complementary action for JL<-->JGE
INVJMPEND   mNEXT

;ASM    GOTO <label>                   --       unconditionnal branch to label
            asmword "GOTO"
            mDOCOL
            .word   CODE_JMP,TICK   ;  -- OPCODE CFA<label>
            .word   EXECUTE,EXIT

;ASM    <cond> ?GOTO <label>    OPCODE --       conditionnal branch to label
            asmword "?GOTO"
            mDOCOL
            .word   INVJMP,TICK     ;  -- OPCODE CFA<label>
            .word   EXECUTE,EXIT

; ----------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : branch to a previous definition
; ----------------------------------------------------------------

;ASM    JMP <word>          ;        --       unconditionnal branch to a previous definition
            asmword "JMP"
JUMP        mDOCOL
            .word   TICK            ; -- @BACKWARD
            .word   ASM_AGAIN,EXIT


;ASM    <cond> ?JMP <word>  ;  OPCODE --       conditionnal branch to a previous definition
            asmword "?JMP"
            mDOCOL
            .word   INVJMP,TICK,SWAP    ; 
            .word   ASM_UNTIL,EXIT

; ===============================================================
; Extended assembler
; ===============================================================

; Adda|Cmpa|Mova|Suba first argument process ACMS1

ACMS1   mDOCOL                  ; -- BODYDOES ','   
        .word   FBLANK,SKIP     ; -- BODYDOES ',' addr
        FORTHtoASM              ;
        MOV.B @TOS,X            ;                   X=first char of opcode string
        MOV @PSP+,TOS           ; -- BODYDOES ','
        MOV @PSP+,S             ; -- ','            S=BODYDOES
        MOV @S,S                ;                   S=opcode
        MOV &DDP,T              ;                   T=DDP
        ADD #2,&DDP             ;                   make room for opcode
;-------------------------------;
ACMS10  CMP.B #'R',X            ; -- ','    
        JNZ ACMS11              ;
ACMS101 CALL #SearchREG         ; -- Rn         src
ACMS102 RLAM #4,TOS             ;               8<<src
        RLAM #4,TOS             ;
ACMS103 BIS S,TOS               ;               update opcode with src|dst
        MOV TOS,0(T)            ;               save opcode
        MOV T,TOS               ; -- OPCODE_addr
        mSEMI                   ;
;-------------------------------;
ACMS11  CMP.B #'#',X            ; -- ','        X=addr
        JNE MOVA12              ;
        BIC #40h,S              ;               set #opcode
ACMS111 ADD #1,&TOIN            ;               skip '#'|'&'
        ADD #2,&DDP             ;               make room for low #$xxxx|&$xxxx|$xxxx(REG)
        CALL #SearchARG         ; -- Lo Hi
        MOV @PSP+,2(T)          ; -- Hi         store $xxxx of #$x.xxxx|&$x.xxxx|$x.xxxx(REG)
        AND #0Fh,TOS            ; -- Hi         sel Hi src
        JMP ACMS102             ;
;-------------------------------;
MOVA12  CMP.B #'&',X            ; -- ','        case of MOVA &$x.xxxx
        JNZ MOVA13              ;
        XOR #00E0h,S            ;               set MOVA &$x.xxxx, opcode                 
        JMP ACMS111             ;
;-------------------------------;
MOVA13  BIC #00F0h,S            ;               set MOVA @REG, opcode
        CMP.B #'@',X            ; -- ','
        JNZ MOVA14              ;
        ADD #1,&TOIN            ;               skip '@'
        CALL #SearchREG         ; -- Rn 
        JNZ ACMS102             ;               if @REG found
;-------------------------------;
        BIS #0010h,S            ;               set @REG+ opcode
        MOV #'+',TOS            ; -- '+'
MOVA131 CALL #SearchREG         ; -- Rn         case of MOVA @REG+,|MOVA $x.xxxx(REG),
        CMP &SOURCE_LEN,&TOIN   ;               test TYPE II first parameter ending by @REG+ (REG) without comma,
        JZ ACMS102              ;               i.e. may be >IN = SOURCE_LEN: don't skip char CR !
        ADD #1,&TOIN            ;               skip "," ready for the second operand search
        JMP ACMS102             ;
;-------------------------------;
MOVA14  BIS #0030h,S            ;               set xxxx(REG), opcode
        ADD #2,&DDP             ; -- ','        make room for first $xxxx of $0.xxxx(REG),
        MOV #'(',TOS            ; -- "("        as WORD separator to find xxxx of "xxxx(REG),"
        CALL #SearchARG         ; -- Lo Hi
        MOV @PSP+,2(T)          ; -- Hi         store $xxxx as 2th word
        MOV #')',TOS            ; -- ')'
        JMP MOVA131             ;

; Adda|Cmpa|Mova|Suba 2th argument process ACMS2

;-------------------------------;
ACMS2   mDOCOL                  ; -- OPCODE_addr 
        .word FBLANK,SKIP       ; -- OPCODE_addr addr
        FORTHtoASM              ;
        MOV @PSP+,T             ; -- addr       T=OPCODE_addr
        MOV @T,S                ;               S=opcode
        MOV.B @TOS,X            ; -- addr       X=first char of string instruction         
        MOV.B #' ',TOS          ; -- ' '
;-------------------------------;
ACMS21  CMP.B #'R',X            ; -- ' '
        JNZ MOVA22              ;
ACMS211 CALL #SearchREG         ; -- Rn
        JMP ACMS103             ;
;-------------------------------;
MOVA22  BIC #0F0h,S             ;
        ADD #2,&DDP             ; -- ' '        make room for $xxxx
        CMP.B #'&',X            ;
        JNZ MOVA23              ;
        BIS #060h,S             ;               set ,&$x.xxxx opcode
        ADD #1,&TOIN            ;               skip '&'
        CALL #SearchARG         ; -- Lo Hi
        MOV @PSP+,2(T)          ; -- Hi         store $xxxx as 2th word
        JMP ACMS103             ;               update opcode with dst $x and write opcode
;-------------------------------;
MOVA23  BIS #070h,S             ;               set ,xxxx(REG) opcode
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

TYPE4DOES   .word   lit,','     ; -- BODYDOES ","        char separator for PARAM1
            .word   ACMS1       ; -- OPCODE_addr
            .word   ACMS2       ; -- OPCODE_addr
            .word   DROP,EXIT

            asmword "MOVA"
            mDODOES
            .word   TYPE4DOES,00C0h

            asmword "CMPA"
            mDODOES
            .word   TYPE4DOES,00D0h

            asmword "ADDA"
            mDODOES
            .word   TYPE4DOES,00E0h

            asmword "SUBA"
            mDODOES
            .word   TYPE4DOES,00F0h


; --------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER:  OPCODE TYPE III bis: CALLA (without extended word)
; --------------------------------------------------------------------------------
; absolute and immediate instructions must be written as $x.xxxx  (DOUBLE numbers)
; indexed instructions must be written as $.xxxx(REG) (DOUBLE numbers)
; --------------------------------------------------------------------------------

        asmword "CALLA"
        mDOCOL
        .word FBLANK,SKIP   ; -- addr
        FORTHtoASM
        MOV &DDP,T          ;           T = DDP
        ADD #2,&DDP         ;           make room for opcode
        MOV.B @TOS,TOS      ; -- char   First char of opcode
CALLA0  MOV #134h,S         ;           134h<<4 = 1340h = opcode for CALLA Rn
        CMP.B #'R',TOS   
        JNZ CALLA1
CALLA01 MOV.B #' ',TOS      ;        
CALLA02 CALL #SearchREG     ; -- Rn
CALLA03 RLAM #4,S           ;           (opcode>>4)<<4 = opcode
        BIS TOS,S           ;           update opcode
        MOV S,0(T)          ;           store opcode
        MOV @PSP+,TOS
        mSEMI
;---------------------------;
CALLA1  ADD #2,S            ;           136h<<4 = opcode for CALLA @REG
        CMP.B #'@',TOS      ; -- char   Search @REG
        JNZ CALLA2          ;
        ADD #1,&TOIN        ;           skip '@'
        MOV.B #' ',TOS      ; -- ' '
        CALL #SearchREG     ;
        JNZ  CALLA03        ;           if REG found, update opcode
;---------------------------;
        ADD #1,S            ;           137h<<4 = opcode for CALLA @REG+
        MOV #'+',TOS        ; -- '+'
        JMP CALLA02         ;
;---------------------------;
CALLA2  ADD #2,&DDP         ;           make room for xxxx of #$x.xxxx|&$x.xxxx|$0.xxxx(REG)
        CMP.B #'#',TOS      ;
        JNZ CALLA3
        MOV #13Bh,S         ;           13Bh<<4 = opcode for CALLA #$x.xxxx
CALLA21 ADD #1,&TOIN        ;           skip '#'|'&'
CALLA22 CALL #SearchARG     ; -- Lo Hi
        MOV @PSP+,2(T)      ; -- Hi     store #$xxxx|&$xxxx
        JMP CALLA03         ;           update opcode with $x. and store opcode
;---------------------------;
CALLA3  CMP.B #'&',TOS   
        JNZ CALLA4          ;
        ADD #2,S            ;           138h<<4 = opcode for CALLA &$x.xxxx
        JMP CALLA21
;---------------------------;
CALLA4  MOV.B #'(',TOS      ; -- "("
        SUB #1,S            ;           135h<<4 = opcode for CALLA $0.xxxx(REG)
CALLA41 CALL #SearchARG     ; -- Lo Hi
        MOV @PSP+,2(T)      ; -- Hi     store $xxxx 
        MOV #')',TOS        ; -- ')'
        JMP CALLA02         ;           search Rn and update opcode
    


; PRMX1 is used for OPCODES type V (double operand) and OPCODES type VI (single operand) extended instructions

PRMX1   mDOCOL                  ; -- sep            OPCODES type V|VI separator = ','|' '
        .word FBLANK,SKIP       ; -- sep addr
        FORTHtoASM              ;
        MOV.B @TOS,X            ; -- sep addr       X= first char of opcode string
        MOV @PSP+,TOS           ; -- sep
        MOV #1800h,S            ;                   init S=Extended word
;-------------------------------;
PRMX10  CMP.B #'R',X            ; -- sep
        JNZ PRMX11              ;
PRMX101 CALL #SearchREG         ; -- Rn             Rn of REG; call SearchREG only to update >IN
PRMX102 MOV S,TOS               ; -- EW             update Extended word
PRMX103 mSEMI                   ; -- Ext_Word
;-------------------------------;
PRMX11  MOV #0,&RPT_WORD        ;                   clear RPT
        CMP.B #'#',X            ; -- sep
        JNZ PRMX12
PRMX111 ADD #1,&TOIN            ; -- sep            skip '#'
PRMX112 CALL #SearchARG         ; -- Lo Hi          search $x.xxxx of #x.xxxx,
        ADD #2,PSP              ; -- Hi             pop unused low word
PRMX113 AND #0Fh,TOS            ;                   
PRMX114 RLAM #3,TOS
        RLAM #4,TOS             ; -- 7<<Hi
PRMX115 BIS TOS,S               ;                   update extended word with srcHi
        JMP PRMX102
;-------------------------------;
PRMX12  CMP.B #'&',X            ; -- sep
        JZ PRMX111
;-------------------------------;                   search REG of @REG,|@REG+,
PRMX13  CMP.B #'@',X            ; -- sep
        JNZ PRMX14
PRMX131 ADD #1,&TOIN            ; -- sep            skip '@'
PRMX132 CALL #SearchREG         ; -- Rn             Rn of @REG,
        JNZ PRMX102             ;                   if Rn found
;-------------------------------;
        MOV #'+',TOS            ; -- '+'
PRMX133 ADD #1,&TOIN            ;                   skip '@'
        CALL #SearchREG         ; -- Rn             Rn of @REG+,
PRMX134 CMP &SOURCE_LEN,&TOIN   ;                   test case of TYPE VI first parameter without ','
        JZ PRMX102              ;                   don't take the risk of skipping CR !
        ADD #1,&TOIN            ;                   skip ',' ready to search 2th operand
        JMP PRMX102             ;
;-------------------------------;
PRMX14  MOV #'(',TOS            ; -- '('            to find $x.xxxx of "x.xxxx(REG),"
        CALL #SearchARG         ; -- Lo Hi                  
        MOV TOS,0(PSP)          ; -- Hi Hi
PRMX141 MOV #')',TOS            ; -- Hi ')'
        CALL #SearchREG         ; -- Hi Rn
        MOV @PSP+,TOS           ; -- Hi
        AND #0Fh,TOS
        BIS TOS,S
        JMP PRMX134
;-------------------------------;

; PRMX2 is used for OPCODES type V (double operand) extended instructions
        
;-------------------------------;
PRMX2   mDOCOL                  ; -- Extended_Word 
        .word   FBLANK,SKIP     ; -- Extended_Word addr
        FORTHtoASM              ;
        MOV @PSP+,S             ; -- addr     S=Extended_Word
        MOV.B @TOS,X            ; -- addr     X=first char of code instruction
        MOV #' ',TOS            ; -- ' '
;-------------------------------;
PRMX20  CMP.B #'R',X            ; -- ' '
        JZ  PRMX102             ;               extended word not to be updated  
;-------------------------------;
PRMX21  MOV #0,&RPT_WORD        ;
        CMP.B #'&',X            ;
        JNZ PRMX22              ;
PRMX211 ADD #1,&TOIN            ; -- ' '      skip '&'
PRMX212 CALL #SearchARG         ; -- Lo Hi
PRMX213 ADD #2,PSP              ; -- hi       pop low word
        AND #0Fh,TOS            ; -- Hi
        JMP PRMX115             ;               update Extended word with dst_Hi
;-------------------------------;
PRMX22  MOV #'(',TOS            ; -- '('      as WORD separator to find xxxx of "xxxx(REG)"
        CALL #SearchARG         ; -- Lo Hi    search x.xxxx of x.xxxx(REG)
        JMP PRMX213

; UPDATE_eXtendedWord
;-------------------------------;
UPDATE_XW                       ;   BODYDOES Extended_Word -- BODYDOES+2    >IN R--
            MOV &DDP,T          ;
            ADD #2,&DDP         ;                   make room for extended word
            MOV TOS,S           ;                   S = Extended_Word
            MOV @PSP+,TOS       ; -- BODYDOES
            BIS &RPT_WORD,S     ;                   update Extended_word with RPT_WORD
            MOV #0,&RPT_WORD    ;                   clear RPT before next instruction
            BIS @TOS+,S         ; -- BODYDOES+2     update Extended_word with [BODYDOES] = A/L bit
            MOV S,0(T)          ;                   store extended word
            MOV @RSP+,&TOIN     ;                   >IN R--     restore >IN at the start of instruction string
            mNEXT               ;
;-------------------------------;

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

TYPE5DOES                                   ; -- BODYDOES
            .word   LIT,TOIN,FETCH,TOR      ; R-- >IN                    save >IN for 2th pass
            .word   lit,','                 ; -- BODYDOES ','            char separator for PRMX1
            .word   PRMX1                   ; -- BODYDOES Extended_Word
            .word   PRMX2                   ; -- BODYDOES Extended_Word
            .word   UPDATE_XW               ; -- BODYDOES+2              >IN is restored ready for 2th pass
            .word   BRAN,TYPE1DOES          ; -- BODYDOES+2              2th pass: completes instruction with opcode = [BODYDOES+2]

            asmword "MOVX"
            mDODOES
            .word   TYPE5DOES,40h,4000h       ; [PFADOES]=TYPE5DOES, [BODYDOES]=A/L bit, [BODYDOES+2]=OPCODE,

            asmword "MOVX.A"
            mDODOES
            .word   TYPE5DOES,0,4040h

            asmword "MOVX.B"
            mDODOES
            .word   TYPE5DOES,40h,4040h
                             
            asmword "ADDX"
            mDODOES          
            .word   TYPE5DOES,40h,5000h
                             
            asmword "ADDX.A"
            mDODOES          
            .word   TYPE5DOES,0,5040h
                             
            asmword "ADDX.B"
            mDODOES          
            .word   TYPE5DOES,40h,5040h
                             
            asmword "ADDCX"  
            mDODOES          
            .word   TYPE5DOES,40h,6000h
                             
            asmword "ADDCX.A"
            mDODOES          
            .word   TYPE5DOES,0,6040h
                             
            asmword "ADDCX.B"
            mDODOES          
            .word   TYPE5DOES,40h,6040h
                             
            asmword "SUBCX"  
            mDODOES          
            .word   TYPE5DOES,40h,7000h

            asmword "SUBCX.A"
            mDODOES
            .word   TYPE5DOES,0,7040h
                             
            asmword "SUBCX.B"
            mDODOES          
            .word   TYPE5DOES,40h,7040h
                             
            asmword "SUBX"   
            mDODOES          
            .word   TYPE5DOES,40h,8000h
                             
            asmword "SUBX.A" 
            mDODOES          
            .word   TYPE5DOES,0,8040h
                             
            asmword "SUBX.B" 
            mDODOES          
            .word   TYPE5DOES,40h,8040h
                             
            asmword "CMPX"   
            mDODOES          
            .word   TYPE5DOES,40h,9000h
                             
            asmword "CMPX.A" 
            mDODOES          
            .word   TYPE5DOES,0,9040h
                             
            asmword "CMPX.B" 
            mDODOES          
            .word   TYPE5DOES,40h,9040h

            asmword "DADDX"
            mDODOES
            .word   TYPE5DOES,40h,0A000h
                             
            asmword "DADDX.A"
            mDODOES          
            .word   TYPE5DOES,0,0A040h
                             
            asmword "DADDX.B"
            mDODOES          
            .word   TYPE5DOES,40h,0A040h
                             
            asmword "BITX"   
            mDODOES          
            .word   TYPE5DOES,40h,0B000h
                             
            asmword "BITX.A" 
            mDODOES          
            .word   TYPE5DOES,0,0B040h
                             
            asmword "BITX.B" 
            mDODOES          
            .word   TYPE5DOES,40h,0B040h
                             
            asmword "BICX"   
            mDODOES          
            .word   TYPE5DOES,40h,0C000h
                             
            asmword "BICX.A" 
            mDODOES          
            .word   TYPE5DOES,0,0C040h
                             
            asmword "BICX.B" 
            mDODOES          
            .word   TYPE5DOES,40h,0C040h

            asmword "BISX"
            mDODOES
            .word   TYPE5DOES,40h,0D000h
                             
            asmword "BISX.A" 
            mDODOES          
            .word   TYPE5DOES,0,0D040h
                             
            asmword "BISX.B" 
            mDODOES          
            .word   TYPE5DOES,40h,0D040h
                             
            asmword "XORX"   
            mDODOES          
            .word   TYPE5DOES,40h,0E000h
                             
            asmword "XORX.A" 
            mDODOES          
            .word   TYPE5DOES,0,0E040h
                             
            asmword "XORX.B" 
            mDODOES          
            .word   TYPE5DOES,40h,0E040h
                             
            asmword "ANDX"   
            mDODOES          
            .word   TYPE5DOES,40h,0F000h
                             
            asmword "ANDX.A" 
            mDODOES          
            .word   TYPE5DOES,0,0F040h
                             
            asmword "ANDX.B" 
            mDODOES          
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

TYPE6DOES                                   ; -- BODYDOES
            .word   LIT,TOIN,FETCH,TOR      ;                       save >IN for 2th pass
            .word   FBLANK                  ; -- BODYDOES ' '
            .word   PRMX1                   ; -- BODYDOES Extended_Word  
            .word   UPDATE_XW               ; -- BODYDOES+2
            .word   BRAN,TYPE2DOES          ; -- BODYDOES+2         pass 2: completes instruction with opcode = [BODYDOES+2]

            asmword "RRCX"              ; ZC=0; RRCX Rx,Rx may be repeated by prefix RPT #n|Rn
            mDODOES
            .word   TYPE6DOES,40h,1000h
                             
            asmword "RRCX.A"            ; ZC=0; RRCX.A Rx may be repeated by prefix RPT #n|Rn 
            mDODOES          
            .word   TYPE6DOES,0,1040h
                             
            asmword "RRCX.B"            ; ZC=0; RRCX.B Rx may be repeated by prefix RPT #n|Rn
            mDODOES          
            .word   TYPE6DOES,40h,1040h
                             
            asmword "RRUX"              ; ZC=1; RRUX Rx may be repeated by prefix RPT #n|Rn
            mDODOES          
            .word   TYPE6DOES,140h,1000h
                             
            asmword "RRUX.A"            ; ZC=1; RRUX.A Rx may be repeated by prefix RPT #n|Rn 
            mDODOES          
            .word   TYPE6DOES,100h,1040h
                             
            asmword "RRUX.B"            ; ZC=1; RRUX.B Rx may be repeated by prefix RPT #n|Rn 
            mDODOES          
            .word   TYPE6DOES,140h,1040h

            asmword "SWPBX"
            mDODOES          
            .word   TYPE6DOES,40h,1080h
                             
            asmword "SWPBX.A"
            mDODOES          
            .word   TYPE6DOES,0,1080h
                             
            asmword "RRAX"
            mDODOES          
            .word   TYPE6DOES,40h,1100h
                             
            asmword "RRAX.A"
            mDODOES          
            .word   TYPE6DOES,0,1140h
                             
            asmword "RRAX.B"
            mDODOES          
            .word   TYPE6DOES,40h,1140h

            asmword "SXTX"
            mDODOES
            .word   TYPE6DOES,40h,1180h
                             
            asmword "SXTX.A" 
            mDODOES          
            .word   TYPE6DOES,0,1180h
                             
            asmword "PUSHX"  
            mDODOES          
            .word   TYPE6DOES,40h,1200h
                             
            asmword "PUSHX.A"
            mDODOES          
            .word   TYPE6DOES,0,1240h
                             
            asmword "PUSHX.B"
            mDODOES          
            .word   TYPE6DOES,40h,1240h

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, RPT instruction before REG|REG,REG eXtended instructions
; ----------------------------------------------------------------------

        asmword "RPT"       ; RPT #n | RPT [Rn]     repeat n | [Rn] times modulo 16
        mdocol
        .word FBLANK,SKIP
        FORTHtoASM          ; -- addr
        MOV @TOS,X          ;           X=char
        MOV.B #' ',TOS      ; -- ' '    as separator
        CMP.B #'R',X
        JNZ RPT1
        CALL #SearchREG     ; -- Rn
        JZ RPT1             ;           if not found
        BIS #80h,TOS        ; -- $008R  R=Rn
        JMP RPT2
RPT1    CALL #SearchARG     ; -- $xxxx
        AND #0Fh,TOS        ; -- $000x
RPT2    MOV TOS,&RPT_WORD
        MOV @PSP+,TOS
        mSEMI
            
