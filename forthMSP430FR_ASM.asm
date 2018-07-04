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
;forthMSP430FR_asm.asm
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

; PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8, R7, R6, R5, R4 (TI's reg)
; or          : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4 (FastForth reg)
; example : PUSHM IP,Y or PUSHM R13,R8

; POPM  order :  R4, R5, R6, R7, R8, R9,R10,R11,R12,R13,R14,R15 (TI's reg)
; or          :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP (FastForth reg)
; example : POPM Y,IP or POPM R8,R13

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : STRUCTURE
; ----------------------------------------------------------------------

;X  ASSEMBLER       --              ; set ASSEMBLER the first context vocabulary
    .IFDEF VOCABULARY_SET
            FORTHWORD "ASSEMBLER"
    .ENDIF ; VOCABULARY_SET
ASSEMBLER       mDODOES             ; leave ASSEMBLER_BODY on the stack and run VOCDOES
                .word   VOCDOES
ASSEMBLER_BODY  .word   lastasmword ; here is the structure created by VOCABULARY
    .SWITCH THREADS
    .CASE   2
                .word   lastasmword1
    .CASE   4
                .word   lastasmword1
                .word   lastasmword2
                .word   lastasmword3
    .CASE   8
                .word   lastasmword1
                .word   lastasmword2
                .word   lastasmword3
                .word   lastasmword4
                .word   lastasmword5
                .word   lastasmword6
                .word   lastasmword7
    .CASE   16
                .word   lastasmword1
                .word   lastasmword2
                .word   lastasmword3
                .word   lastasmword4
                .word   lastasmword5
                .word   lastasmword6
                .word   lastasmword7
                .word   lastasmword8
                .word   lastasmword9
                .word   lastasmword10
                .word   lastasmword11
                .word   lastasmword12
                .word   lastasmword13
                .word   lastasmword14
                .word   lastasmword15
    .CASE   32
                .word   lastasmword1
                .word   lastasmword2
                .word   lastasmword3
                .word   lastasmword4
                .word   lastasmword5
                .word   lastasmword6
                .word   lastasmword7
                .word   lastasmword8
                .word   lastasmword9
                .word   lastasmword10
                .word   lastasmword11
                .word   lastasmword12
                .word   lastasmword13
                .word   lastasmword14
                .word   lastasmword15
                .word   lastasmword16
                .word   lastasmword17
                .word   lastasmword18
                .word   lastasmword19
                .word   lastasmword20
                .word   lastasmword21
                .word   lastasmword22
                .word   lastasmword23
                .word   lastasmword24
                .word   lastasmword25
                .word   lastasmword26
                .word   lastasmword27
                .word   lastasmword28
                .word   lastasmword29
                .word   lastasmword30
                .word   lastasmword31
    .ELSECASE
    .ENDCASE
                .word   voclink
voclink         .set    $-2

             FORTHWORDIMM "HI2LO"   ; immediate, switch to low level, add ASSEMBLER context, set interpretation state
            mDOCOL
HI2LO       .word   HERE,CELLPLUS,COMMA
            .word   LEFTBRACKET
HI2LONEXT   .word   ALSO,ASSEMBLER
            .word   EXIT

;             FORTHWORDIMM "SEMIC"   ; same as HI2LO, plus restore IP; counterpart of COLON
;            mDOCOL
;            .word   HI2LO
;            .word   LIT,413Dh,COMMA ; compile MOV @RSP+,IP
;            .word   EXIT

           FORTHWORD "CODE"     ; a CODE word must be finished with ENDCODE
ASMCODE     CALL #HEADER        ;
            SUB #4,&DDP         ;
            mDOCOL
            .word   SAVE_PSP
            .word   BRAN,HI2LONEXT


            asmword "ENDCODE"   ; restore previous context and test PSP balancing
ENDCODE     mDOCOL
            .word   PREVIOUS,QREVEAL
            .word   EXIT

            FORTHWORD "ASM"     ; used to define an assembler word which is not executable by FORTH interpreter
                                ; i.e. typically an assembler word called by CALL and ended by RET
                                ; ASM words are only usable in another ASSEMBLER words
                                ; an ASM word must be finished with ENDASM
            MOV     &CURRENT,&SAV_CURRENT
            MOV     #ASSEMBLER_BODY,&CURRENT
            JMP     ASMCODE

            asmword "ENDASM"    ; end of an ASM word
            MOV     &SAV_CURRENT,&CURRENT
            JMP     ENDCODE


            asmword "COLON"     ; compile DOCOL, remove ASSEMBLER from CONTEXT, switch to compilation state
            MOV &DDP,W

    .SWITCH DTC
    .CASE 1
            MOV #DOCOL1,0(W)    ; compile CALL xDOCOL
            ADD #2,&DDP

    .CASE 2
            MOV #DOCOL1,0(W)    ; compile PUSH IP
COLON1      MOV #DOCOL2,2(W)    ; compile CALL rEXIT
            ADD #4,&DDP

    .CASE 3 ; inlined DOCOL
            MOV #DOCOL1,0(W)    ; compile PUSH IP
COLON1      MOV #DOCOL2,2(W)    ; compile MOV PC,IP
            MOV #DOCOL3,4(W)    ; compile ADD #4,IP
            MOV #NEXT,6(W)      ; compile MOV @IP+,PC
            ADD #8,&DDP         ;
    .ENDCASE ; DTC

COLON2      MOV #-1,&STATE      ; enter in compile state
            MOV #PREVIOUS,PC    ; restore previous state of CONTEXT


            asmword "LO2HI"     ; same as COLON but without saving IP
    .SWITCH DTC
    .CASE 1                     ; compile 2 words
            MOV &DDP,W
            MOV #12B0h,0(W)     ; compile CALL #EXIT, 2 words  4+6=10~
            MOV #EXIT,2(W)
            ADD #4,&DDP
            JMP COLON2
    .ELSECASE                   ; CASE 2 : compile 1 word, CASE 3 : compile 3 words
            SUB #2,&DDP         ; to skip PUSH IP
            MOV &DDP,W
            JMP COLON1
    .ENDCASE

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

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search argument "xxxx", IP is free
; ----------------------------------------------------------------------

; Search ARG of "#xxxx,"                    ; <== PARAM10
; Search ARG of "&xxxx,"                    ; <== PARAM111
; Search ARG of "xxxx(REG),"                ; <== PARAM130
; Search ARG of ",&xxxx"                    ; <== PARAM111 <== PARAM20
; Search ARG of ",xxxx(REG)"                ; <== PARAM210
SearchARG   ASMtoFORTH                      ; -- separator      search word first
            .word   WORDD,FIND              ; -- c-addr
            .word   QZBRAN,SearchARGW       ; -- c-addr         if found
            .word   QNUMBER                 ;
            .word   QBRAN,NotFound          ; -- c-addr
            .word   AsmSrchEnd              ; -- value          goto end if number found
SearchARGW  FORTHtoASM                      ; -- xt             xt = CFA
            MOV     @TOS,X
QDOVAR      CMP     #DOVAR,X
            JNZ     QDOCON
            ADD     #2,TOS                  ; remplace CFA by PFA for VARIABLE words
            RET
QDOCON      CMP     #DOCON,X
            JNZ     QDODOES
            MOV     2(TOS),TOS              ; remplace CFA by [PFA] for CONSTANT (and CREATEd) words
            RET
QDODOES     CMP     #DODOES,X
            JNZ     AsmSrchEnd
            ADD     #4,TOS                  ; leave BODY address for DOES words
AsmSrchEnd  RET                             ;

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : search REG
; ----------------------------------------------------------------------

; STOre ARGument xxxx of "xxxx(REG),"       ; <== PARAM130
; STOre ARGument xxxx of ",xxxx(REG)"       ; <== PARAM210
StoARGsearchREG
            MOV &DDP,X
            ADD #2,&DDP
            MOV TOS,0(X)                    ; -- xxxx       compile xxxx
            MOV #')',TOS                    ; -- ")"        prepare separator to search REG of "xxxx(REG)"

; search REG of "xxxx(REG),"    separator = ')'  ;
; search REG of ",xxxx(REG)"    separator = ')'  ;
; search REG of "@REG,"         separator = ','  ; <== PARAM120
; search REG of "@REG+,"        separator = '+'  ; <== PARAM121
; search REG of "REG,"          separator = ','  ; <== PARAM13
; search REG of ",REG"          separator = ' '  ; <== PARAM21

SearchREG   PUSH    &TOIN                   ; -- separator  save >IN
            ADD     #1,&TOIN                ;               skip "R"
            ASMtoFORTH                      ;               search xx of Rxx
            .word   WORDD,QNUMBER           ;
            .word   QBRAN,notREG            ; -- xxxx       if number found
            FORTHtoASM                      ; -- c-addr     if number not found
            ADD     #2,RSP                  ;           remove >IN
            CMP     #16,TOS                 ; -- 000R   register > 15 ?
            JHS     BOUNDERROR              ;           yes : abort
            RET                             ; -- 000R   Z=0 ==> found

notREG      FORTHtoASM                      ; -- c-addr
            MOV     @RSP+,&TOIN             ; -- c-addr          restore >IN
            BIS     #Z,SR                   ;           Z=1 ==> not found
            RET                             ; -- c_addr

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET FIRST OPERAND
; ----------------------------------------------------------------------

; PARAM1     separator --                   ; parse input buffer until separator and compute first operand of opcode
                                            ; sep is comma for src and space for dst .

PARAM1      mDOCOL                          ; -- sep
            .word   FBLANK,SKIP             ; -- sep c-addr
            FORTHtoASM                      ; -- sep c-addr
            MOV     #0,&ASMTYPE             ; -- sep c-addr        reset ASMTYPE
            MOV     &DDP,&OPCODE            ; -- sep c-addr        HERE --> OPCODE (opcode is preset to its address !)
            ADD     #2,&DDP                 ; -- sep c-addr        cell allot for opcode
            MOV     TOS,W                   ; -- sep c-addr        W=c-addr
            MOV     @PSP+,TOS               ; -- sep               W=c-addr
            CMP.B   #'#',0(W)               ; -- sep               W=c-addr
            JNE     PARAM11

; "#" found : case of "#xxxx,"
PARAM10     ADD     #1,&TOIN                ; -- sep        skip # prefix
            CALL    #SearchARG              ; -- xxxx       abort if not found

PARAM100    CMP #0,TOS                      ; -- xxxx       = 0 ?
            JNE PARAM101
; case of "#0,"
            MOV #0300h,&ASMTYPE             ; -- 0          example : MOV #0,dst <=> MOV R3,dst
            JMP PARAMENDOF

PARAM101    CMP #1,TOS                      ; -- xxxx       = 1 ?
            JNE PARAM102
; case of "#1,"
            MOV #0310h,&ASMTYPE             ; -- 1          example : MOV #1,dst <=> MOV 0(R3),dst
            JMP PARAMENDOF

PARAM102    CMP #2,TOS                      ; -- xxxx       = 2 ?
            JNE PARAM104
; case of "#2,"
            MOV #0320h,&ASMTYPE             ; -- 2          ASMTYPE = 0320h  example : MOV #2, <=> MOV @R3,
            JMP PARAMENDOF

PARAM104    CMP #4,TOS                      ; -- xxxx       = 4 ?
            JNE PARAM108
; case of "#4,"
            MOV #0220h,&ASMTYPE             ; -- 4          ASMTYPE = 0220h  example : MOV #4, <=> MOV @SR,
            JMP PARAMENDOF

PARAM108    CMP #8,TOS                      ; -- xxxx       = 8 ?
            JNE PARAM10M1
; case of "#8,"
            MOV #0230h,&ASMTYPE             ; -- 8          ASMTYPE = 0230h  example : MOV #8, <=> MOV @SR+,
            JMP PARAMENDOF

PARAM10M1   CMP #-1,TOS                     ; -- xxxx       = -1 ?
            JNE PARAM1000
; case of "#-1,"
            MOV #0330h,&ASMTYPE             ; -- -1         ASMTYPE = 0330h  example : XOR #-1 <=> XOR @R3+,
            JMP PARAMENDOF

; case of all others "#xxxx,"               ; -- xxxx
PARAM1000   MOV #0030h,&ASMTYPE             ; -- xxxx       add immediate code type : @PC+,

; case of "&xxxx,"                          ; <== PARAM110
; case of ",&xxxx"                          ; <== PARAM20
StoreArg    MOV &DDP,X                      ; -- xxxx
            ADD #2,&DDP                     ;               cell allot for arg

StoreTOS                                    ; <== TYPE1DOES
   MOV TOS,0(X)                             ;               compile arg
; endcase of all "&xxxx"                    ;
; endcase of all "#xxxx"                    ; <== PARAM101,102,104,108,10M1
; endcase of all "REG"|"@REG"|"@REG+"       ; <== PARAM124
PARAMENDOF  MOV @PSP+,TOS                   ; --
            MOV @RSP+,IP
            mNEXT                           ; --
; ------------------------------------------

PARAM11     CMP.B   #'&',0(W)               ; -- sep
            JNE     PARAM12

; case of "&xxxx,"                          ; -- sep        search for "&xxxx,"
PARAM110    MOV     #0210h,&ASMTYPE         ; -- sep        set code type : xxxx(SR) with AS=0b01 ==> x210h (and SR=0 !)

; case of "&xxxx,"
; case of ",&xxxx"                          ; <== PARAM20
PARAM111    ADD     #1,&TOIN                ; -- sep        skip "&" prefix
            CALL    #SearchARG              ; -- arg        abort if not found
            JMP     StoreArg                ; --            then ret
; ------------------------------------------

PARAM12     CMP.B   #'@',0(W)               ; -- sep
            JNE     PARAM13

; case of "@REG,"|"@REG+,"
PARAM120    MOV     #0020h,&ASMTYPE         ; -- sep        init ASMTYPE with indirect code type : AS=0b10
            ADD     #1,&TOIN                ; -- sep        skip "@" prefix
            CALL    #SearchREG              ;               Z = not found
            JNZ     PARAM123                ; -- value      REG of "@REG," found

; case of "@REG+,"                          ; -- c-addr     REG of "@REG" not found, search REG of "@REG+"
PARAM121    ADD     #0010h,&ASMTYPE         ;               change ASMTYPE from @REG to @REG+ type
            MOV     #'+',TOS                ; -- "+"        as WORD separator to find REG of "@REG+,"
            CALL    #SearchREG              ; -- value|c-addr   X = flag

; case of "@REG+,"                          ;
; case of "xxxx(REG),"                      ; <== PARAM130
PARAM122    JZ      REGnotFound             ; -- c-addr
            CMP     &SOURCE_LEN,&TOIN       ;               test OPCODE II parameter ending by REG+ or (REG) without comma,
            JZ      PARAM123                ;               i.e. >IN = SOURCE_LEN : don't skip char CR !
            ADD     #1,&TOIN                ; -- 000R       skip "," ready for the second operand search

; case of "@REG+,"
; case of "xxxx(REG),"
; case of "@REG,"                           ; <== PARAM120
; case of "REG,"                            ; <== PARAM13
PARAM123    SWPB    TOS                     ; 000R -- 0R00  swap bytes because it's not a dst REG typeI (not a 2 ops inst.)

; case of "@REG+,"                          ; -- 0R00                   (src REG typeI)
; case of "xxxx(REG),"                      ; -- 0R00                   (src REG typeI or dst REG typeII)
; case of "@REG,"                           ; -- 0R00                   (src REG typeI)
; case of "REG,"                            ; -- 0R00                   (src REG typeI or dst REG typeII)
; case of ",REG"                            ; -- 000R   <== PARAM21     (dst REG typeI)
; case of ",xxxx(REG)"                      ; -- 000R   <== PARAM210    (dst REG typeI)
PARAM124    ADD     TOS,&ASMTYPE            ; -- 0R00|000R
            JMP     PARAMENDOF
; ------------------------------------------

; case of "REG,"|"xxxx(REG),"               ;               first, searg REG of "REG,"
PARAM13     CALL    #SearchREG              ; -- sep        save >IN for second parsing (case of "xxxx(REG),")
            JNZ     PARAM123                ; -- 000R       REG of "REG," found, ASMTYPE=0

; case of "xxxx(REG),"                      ; -- c-addr     "REG," not found
PARAM130    ADD     #0010h,&ASMTYPE         ;               AS=0b01 for indexing address
            MOV     #'(',TOS                ; -- "("        as WORD separator to find xxxx of "xxxx(REG),"
            CALL    #SearchARG              ; -- xxxx       aborted if not found
            CALL    #StoARGsearchREG        ;               compile xxxx and search REG of "(REG)"
            JMP     PARAM122                ; 

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER : INTERPRET 2th OPERAND
; ----------------------------------------------------------------------

; PARAM2     --                             ; parse input buffer until BL and compute this 2th operand
PARAM2      mDOCOL                          ;
            .word   FBLANK,SKIP             ;               skip space(s) between "arg1," and "arg2" if any
            FORTHtoASM                      ; -- c-addr     search for '&' of "&xxxx
            CMP.B   #'&',0(TOS)             ;
            MOV     #20h,TOS                ; -- " "        as WORD separator to find xxxx of ",&xxxx"
            JNE     PARAM21                 ;               '&' not found

; case of ",&xxxx"                          ;
PARAM20     ADD     #0082h,&ASMTYPE         ;               change ASMTYPE : AD=1, dst = R2
            JMP     PARAM111                ; -- " "
; ------------------------------------------

; case of ",REG"|",xxxx(REG)                ; -- " "        first, search REG of ",REG"
PARAM21     CALL    #SearchREG              ;
            JNZ     PARAM124                ; -- 000R       REG of ",REG" found

; case of ",xxxx(REG)                       ; -- c-addr     REG not found
PARAM210    ADD     #0080h,&ASMTYPE         ;               set AD=1
            MOV     #'(',TOS                ; -- "("        as WORD separator to find xxxx of ",xxxx(REG)"
            CALL    #SearchARG              ; -- xxxx       aborted if not found
            CALL    #StoARGsearchREG        ;               compile argument xxxx and search REG of "(REG)"
            JNZ     PARAM124                ; -- 000R       REG of "(REG) found
REGnotFound MOV     #NotFound,IP            ; -- c-addr     abort
            mNEXT


; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER: OPCODES TYPE 0 : zero operand     f:-)
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

; TYPE1DOES     -- PFADOES      search and compute PARAM1 & PARAM2 as src and dst operands then compile instruction
TYPE1DOES                                   ; -- PFADOES
            .word   lit,','                 ; -- PFADOES ","        char separator for PARAM1
            .word   PARAM1                  ; -- PFADOES
            .word   PARAM2                  ; -- PFADOES            char separator (BL) included in PARAM2
            FORTHtoASM                      ; -- PFADOES
MAKEOPCODE  MOV     @TOS,TOS                ; -- opcode             part of instruction
            BIS     &ASMTYPE,TOS            ; -- opcode             opcode is complete
            MOV     &OPCODE,X               ; -- opcode             X= addr to compile opcode
            JMP     StoreTOS                ;                       then EXIT

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

; TYPE2DOES     -- PFADOES          search and compute PARAM1 as dst operand then compile instruction
TYPE2DOES                                   ; -- PFADOES
            .word   FBLANK                  ;               char separator for PARAM1
            .word   PARAM1
            FORTHtoASM                      ; -- PFADOES
            MOV     &ASMTYPE,W              ;
            AND     #0070h,&ASMTYPE         ;             keep B/W & AS infos in ASMTYPE
            SWPB    W                       ;             (REG org --> REG dst)
            AND     #000Fh,W                ;             keep REG
BIS_ASMTYPE BIS     W,&ASMTYPE              ; -- PFADOES  add it in ASMTYPE
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

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES TYPE III : PUSHM POPM
; ----------------------------------------------------------------------
; syntax :  PUSHM R13,R9    ; R-- R13 R12 R11 R10 R9    (first >= last)
;           POPM  R9,R13    ; R--                       (last >= first)
; this syntax is more explicit than TI's one and can reuse typeI template

; PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8, R7, R6, R5, R4 (TI's reg)
; or          : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4 (FastForth reg)
; example : PUSHM IP,Y or PUSHM R13,R8

; POPM  order :  R4, R5, R6, R7, R8, R9,R10,R11,R12,R13,R14,R15 (TI's reg)
; or          :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP (FastForth reg)
; example : POPM Y,IP or POPM R8,R13

; TYPE3DOES     -- PFADOES       parse input stream to search :"   REG, REG " as operands of PUSHM|POPM then compile instruction
TYPE3DOES                                   ; -- PFADOES
            .word   lit,','                 ; -- PFADOES ","        char separator for PARAM1
            .word   PARAM1                  ; -- PFADOES            ASMTYPE contains : 0x0S00    S=REGsrc
            .word   PARAM2                  ; -- PFADOES            ASMTYPE contains : 0x0S0D    D=REGdst
            FORTHtoASM                      ; -- PFADOES
            MOV.B   &ASMTYPE,X              ;                       X=REGdst
            MOV.B   &ASMTYPE+1,W            ;                       W=REGsrc
            MOV     W,&ASMTYPE              ;                       ASMTYPE = 0x000S
            CMP     #1500h,0(TOS)           ; -- PFADOES            PUSHM ?
            JNZ     POPMCASEOF
PUSHMCASEOF SUB     X,W                     ; -- PFADOES            PUSHM : REGsrc - REGdst = n-1
            JMP     TYPE3QERR
POPMCASEOF  SUB     W,X                     ; -- PFADOES            POPM  : REGdst - REGsrc = n-1
            MOV     X,W
TYPE3QERR   CMP     #16,W
            JHS     BOUNDERRORW             ; -- PFADOES            (u>=)
            .word   0E5Ah                   ;                       RLAM #4,R10 --> RLAM #4,W
            JMP     BIS_ASMTYPE             ; --            then end

BOUNDERRWM1 ADD     #1,W                    ; <== RRAM|RRUM|RRCM|RLAM error
BOUNDERRORW MOV     W,TOS                   ; <== PUSHM|POPM|ASM_branch error
BOUNDERROR                                  ; <== REG number error
            mDOCOL                          ; -- n      n = value out of bounds
            .word   DOT,XSQUOTE
            .byte   13,"out of bounds"
            .word   QABORTYES

            asmword "PUSHM"
ASM_PUSHM   mDODOES
            .word   TYPE3DOES,01500h

            asmword "POPM"
ASM_POPM    mDODOES
            .word   TYPE3DOES,01700h

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx ASSEMBLER, OPCODES TYPE IV : RLAM|RRAM|RRUM|RRCM
; ----------------------------------------------------------------------

; TYPE4DOES      -- PFADOES        parse input stream to search : "   #N, REG " as operands of RLAM|RRAM|RRUM|RRCM
TYPE4DOES                                   ; -- PFADOES
            .word   FBLANK,SKIP             ;                       skip spaces if any
            FORTHtoASM                      ; -- PFADOES c-addr
            MOV     #0,&ASMTYPE             ;                       init ASMTYPE=0
            MOV     &DDP,&OPCODE            ;                       init OPCODE=DP
            ADD     #2,&DDP                 ;                       make room for opcode
            ADD     #1,&TOIN                ;                       skip "#"
            MOV     #',',TOS                ; -- PFADOES ","
            ASMtoFORTH
            .word   WORDD,QNUMBER
            .word   QBRAN,NotFound
            .word   PARAM2                  ; -- PFADOES 0x000N     ASMTYPE = 0x000R
            FORTHtoASM
            MOV     TOS,W                   ; -- PFADOES 0x000N     W = 0x000N
            MOV     @PSP+,TOS               ; -- PFADOES
            SUB     #1,W                    ;                       W = N floored to 0
            CMP     #4,W                    ;
            JHS     BOUNDERRWM1             ;                       JC=JHS    (U>=)
            SWPB    W                       ; -- PFADOES            W = N << 8
            .word   065Ah                   ; RLAM #2,R10           W = N << 10
            JMP     BIS_ASMTYPE             ; --

            asmword "RRCM"
            mDODOES
            .word   TYPE4DOES,0050h

            asmword "RRAM"
            mDODOES
            .word   TYPE4DOES,0150h

            asmword "RLAM"
            mDODOES
            .word   TYPE4DOES,0250h

            asmword "RRUM"
            mDODOES
            .word   TYPE4DOES,0350h

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

            asmword "S>="               ; if >= assertion
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
ASM_THEN    MOV     &DDP,W              ; -- @OPCODE   W=dst
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
    MOV TOS,Y       ; Y = CLRBWx
    MOV @PSP+,TOS   ; 
    MOV @Y,W        ;               W = [CLRBWx]
    CMP #0,W        ;               W = 0 ?
    JNZ BACKWUSE
BACKWSET            ; --
    MOV &DDP,0(Y)   ;               [CLRBWx] = DDP
    mNEXT
BACKWUSE            ; -- OPCODE
    MOV #0,0(Y)     ;               [CLRBWx] = 0 for next use
    JMP ASM_UNTIL1  ;               resolve backward branch with W

; backward label 1
            asmword "BW1"
            mdodoes
            .word BACKWARDDOES
CLRBW1      .word 0

; backward label 2
            asmword "BW2"
            mdodoes
            .word BACKWARDDOES
CLRBW2      .word 0

; backward label 3
            asmword "BW3"
            mdodoes
            .word BACKWARDDOES
CLRBW3      .word 0

FORWARDDOES
    FORTHtoASM
    MOV @RSP+,IP
    MOV &DDP,W      ;
    MOV @TOS,Y      ;               Y=[CLRFWx]
    CMP #0,Y        ;               Y = 0 ? (FWx is free?)
    JNZ FORWUSE     ;               no
FORWSET             ; OPCODE PFA -- 
    MOV @PSP+,0(W)  ; -- PFA        compile incomplete opcode
    ADD #2,&DDP     ;               increment DDP
    MOV W,0(TOS)    ;               store @OPCODE into CLRFWx
    MOV @PSP+,TOS   ;   --
    mNEXT
FORWUSE             ; PFA -- @OPCODE
    MOV #0,0(TOS)   ;               reset PFA for next use
    JMP ASM_THEN1   ;               resolve forward branch with Y


; forward label 1
            asmword "FW1"
            mdodoes
            .word FORWARDDOES
CLRFW1      .word 0

; forward label 2
            asmword "FW2"
            mdodoes
            .word FORWARDDOES
CLRFW2      .word 0

; forward label 3
            asmword "FW3"
            mdodoes
            .word FORWARDDOES
CLRFW3      .word 0


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



