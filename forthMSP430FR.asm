;
;-------------------------------------------------------------------------------
; Vingt fois sur le métier remettez votre ouvrage,
; Polissez-le sans cesse, et le repolissez,
; Ajoutez quelquefois, et souvent effacez.               Boileau, L'Art poétique
;-------------------------------------------------------------------------------

;===============================================================================
; SCITE editor: copy https://www.scintilla.org/Sc531.exe to \prog\scite.exe
;               copy \config\SciTEUser.properties in your $HOME directory
;===============================================================================

;===============================================================================
; MACRO ASSEMBLER AS:  unzip to \prog
; http://john.ccac.rwth-aachen.de:8000/ftp/as/precompiled/i386-unknown-win32/aswcurr.zip
;===============================================================================
    .listing purecode   ; reduce listing to true conditionnal parts
    MACEXP_DFT noif     ; reduce macros listing to true part
    .PAGE  0            ; listing without pagination
;-------------------------------------------------------------------------------

VER .equ "V401"     ; FORTH version

;===============================================================================
; before assembling or programming you must set TARGET in scite param1 (SHIFT+F8)
; according to the selected (uncommented) TARGET below
;===============================================================================
;    TARGET        ;
;MSP_EXP430FR5739  ; compile for MSP-EXP430FR5739 launchpad
;MSP_EXP430FR5969  ; compile for MSP-EXP430FR5969 launchpad
;MSP_EXP430FR5994  ; compile for MSP-EXP430FR5994 launchpad
;MSP_EXP430FR6989  ; compile for MSP-EXP430FR6989 launchpad
;MSP_EXP430FR4133  ; compile for MSP-EXP430FR4133 launchpad
MSP_EXP430FR2355  ;; compile for MSP-EXP430FR2355 launchpad
;MSP_EXP430FR2433  ; compile for MSP-EXP430FR2433 launchpad
;LP_MSP430FR2476   ; compile for LP_MSP430FR2476  launchpad
;CHIPSTICK_FR2433  ; compile for "CHIPSTICK" of M. Ken BOAK

; choose DTC model (Direct Threaded Code); if you don't know, choose 2
DTC .equ 2  ; DTC model 1 : DOCOL = CALL rDOCOL           14 cycles 1 word      shortest but a little slow DTC model
            ; DTC model 2 : DOCOL = PUSH IP, CALL rEXIT   13 cycles 2 words     best compromize to mix FORTH/ASM code
            ; DTC model 3 : inlined DOCOL (and LO2HI)      9 cycles 4 words     fastest

THREADS     .equ 16 ;  1,  2 ,  4 ,  8 ,  16,  32  search entries in word-set.
                    ; +0, +28, +48, +56, +90, +154 bytes, usefull to speed up compilation;
                    ; the FORTH interpreter is speed up by about a square root factor of THREADS.

FREQUENCY   .equ 24 ; fully tested at 1,2,4,8,16 MHz, plus 24 MHz for MSP430FR57xx,MSP430FR2355


; ==============================================================================
UART_TERMINAL ; COMMENT TO SWITCH FROM UART TO I2C TERMINAL
; ==============================================================================
    .IFDEF UART_TERMINAL
TERMINALBAUDRATE    .equ 115200
TERMINAL3WIRES      ;; + 18 bytes  enable 3 wires XON/XOFF software flow control
TERMINAL4WIRES      ;; + 12 bytes  enable 4 wires RTS hardware flow control
;TERMINAL5WIRES      ; + 10 bytes  enable 5 wires RTS/CTS hardware flow control
;HALFDUPLEX          ; switch to UART half duplex TERMINAL input
    .ELSE
I2C_TERM_ADR .equ 18 ; I2C_TERMINAL_Slave_Address << 1
    .ENDIF

;===============================================================================
; KERNEL ADDONs that can't be added later
;===============================================================================
DOUBLE_INPUT        ;; +   60 bytes : adds the interpretation engine for double numbers (numbers with dot)
FIXPOINT_INPUT      ;; +   68 bytes : adds the interpretation engine for Q15.16 numbers (numbers with comma)
;VOCABULARY_SET      ; +  194 bytes : adds words: WORDSET FORTH hidden PREVIOUS ONLY DEFINITIONS
;SD_CARD_LOADER      ; + 1664 bytes : to load source files from SD_card
;SD_CARD_READ_WRITE  ; + 1168 bytes : to read, create, write and del files + copy text files from PC to target SD_Card
;LARGE_CODE          ; +  506 bytes : extended assembler to 20 bits addresses (1MB).
;LARGE_DATA          ; + 1212 bytes : extended assembler to 20 bits datas.
;PROMPT              ; +   18 bytes : to display the prompt "ok" (deprecated).
;===============================================================================

;-------------------------------------------------------------------------------
; OPTIONS that can be added later by downloading their source file >------------------------------------+
; however, added here, they are protected against WIPE and Deep Reset.                                  |
;-------------------------------------------------------------------------------                        v
;CORE_COMPLEMENT     ; + 2304 bytes, if you want a conventional FORTH ANS94 compliant               CORE_ANS.f
;FIXPOINT            ; +  422/528 bytes add HOLDS F+ F- F/ F* F#S F. S>F                            FIXPOINT.f
;UTILITY             ; +  434/524 bytes (1/16threads) : add .S .RS WORDS U.R DUMP ?                 UTILITY.f
;SD_TOOLS            ; +  142 bytes for trivial DIR, FAT, CLUSTR. and SECTOR. view, (adds UTILITY)  SD_TOOLS.f
;DOUBLE              ;              DOUBLE word set                                                 DOUBLE.f

; ------------------------------------------------------------------------------
    .include "ThingsInFirst.inc" ; macros, target definitions, RAM & INFO variables...
;-------------------------------------------------------------------------------
    .org    MAIN_ORG
;-------------------------------------------------------------------------------
; MEMORY OPERATIONS
;-------------------------------------------------------------------------------
            FORTHWORD "@"
; https://forth-standard.org/standard/core/Fetch
; @       a-addr -- x   fetch cell from memory
FETCH       MOV @TOS,TOS
            MOV @IP+,PC

            FORTHWORD "!"
; https://forth-standard.org/standard/core/Store
; !        x a-addr --   store cell in memory
STORE       MOV @PSP+,0(TOS);4
            MOV @PSP+,TOS   ;2
            MOV @IP+,PC     ;4

;-----------------------------------;
; modifying TOs is forbidden here ! ;
;-----------------------------------;
INIT_FORTH                          ; common QABORT|WARM subroutine
;-----------------------------------;
            MOV @RSP+,IP            ; init IP with CALLER next address
;                                   ;
            MOV #PUC_ABORT_ORG,X    ; FRAM INFO         FRAM MAIN
;                                   ; ---------         ---------
            MOV @X+,&PFAACCEPT      ; BODYACCEPT    --> PFAACCEPT
            MOV @X+,&PFAEMIT        ; BODYEMIT      --> PFAEMIT
            MOV @X+,&PFAKEY         ; BODYKEY       --> PFAKEY
            MOV @X+,&CIB_ORG        ; TIB_ORG       --> CIB_ORG             TIB = Terminal Input Buffer, CIB = Current Input Buffer
;                                   ;
;                                   ; FRAM INFO         REG|RAM
;                                   ; ---------         -------
            MOV @X+,RSP             ; INIT_RSTACK   --> R1=RSP              PSP is initialised with ABORT
            MOV @X+,rDOCOL          ; EXIT          --> R4=rDOCOL           (if DTC=2)
            MOV @X+,rDODOES         ; XDODOES       --> R5=rDODOES
            MOV @X+,rDOCON          ; XDOCON        --> R6=rDOCON
            MOV @X+,rDOVAR          ; RFROM         --> R7=rDOVAR
            MOV @X+,&BASEADR        ; INIT_BASE     --> RAM BASE            init decimal base
            MOV @X+,&LEAVEPTR       ; INIT_LEAVE    --> RAM LEAVEPTR
            MOV #0,&STATE           ; 0             --> RAM STATE
            CALL &SOFT_APP          ; default SOFT_APP = INIT_SOFT = RET_ADR, value set by DEEP_RESET.
            MOV #SEL_RST,PC         ; goto PUC 7 to select the user's choice from TOS value: RST_RET|DEEP_RESET
;-----------------------------------;

;-------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx program (FRAM) memory
;-------------------------------------------------------------------------------

    .IFNDEF UART_TERMINAL
        .include "forthMSP430FR_TERM_I2C.asm"
    .ELSE
        .IFDEF HALFDUPLEX
            .include "forthMSP430FR_TERM_HALF.asm"
        .ELSE
            .include "forthMSP430FR_TERM_UART.asm"
        .ENDIF
    .ENDIF
    .IFDEF SD_CARD_LOADER
        .include "forthMSP430FR_SD_ACCEPT.asm"
    .ENDIF

    .IF DTC = 1                     ; DOCOL = CALL rDOCOL, [rDOCOL] = XDOCOL
XDOCOL      MOV @RSP+,W             ; 2
            PUSH IP                 ; 3     save old IP on return stack
            MOV W,IP                ; 1     set new IP to PFA
            MOV @IP+,PC             ; 4     = NEXT
    .ENDIF                          ; 10 cycles

            FORTHWORD "TYPE"
;https://forth-standard.org/standard/core/TYPE
;C TYPE    adr u --     type string to terminal
TYPE        PUSH IP                 ;3
            MOV #TYPE_NEXT+2,IP     ;2                  because SUB #2,IP
            MOV @PSP+,X             ;2 -- len           X = adr
TYPELOOP    SUB #2,IP               ;1                  [IP] = TYPE_NEXT
            SUB #2,PSP              ;1 -- x len
            MOV TOS,0(PSP)          ;3 -- len len
            MOV.B @X+,TOS           ;2 -- len char
            JMP EMIT                ;22                 S T W regs are free
TYPE_NEXT   mNEXTADR                ;  -- len
            SUB.B #1,TOS            ;1 -- len-1         byte operation, according to the /COUNTED-STRING value
            JNZ TYPELOOP            ;2                  32~/19~ EMIT loop 312/526 kBds/MHz --> 7.5MBds @ 24 MHz
            JZ DROPEXIT             ;2

; ------------------------------------------------------------------------------
; forthMSP430FR :  CONDITIONNAL COMPILATION, 114/109 words
; ------------------------------------------------------------------------------
; goal: speed up the false conditionnal to reach true|false equal time: reached!
; ------------------------------------------------------------------------------

            FORTHWORDIMM "[THEN]"   ; does nothing
; https://forth-standard.org/standard/tools/BracketTHEN
            MOV @IP+,PC

; ------------------------------------------------------------------------------
; COMPILING OPERATORS
; ------------------------------------------------------------------------------
; Primitive LIT; compiled by LITERAL
; LIT      -- x    fetch inline literal to stack
; This is the run-time code of LITERAL.
LIT         SUB #2,PSP          ; 1  save old TOS..
            MOV TOS,0(PSP)      ; 3  ..onto stack
            MOV @IP+,TOS        ; 2  fetch new TOS value
            MOV @IP+,PC         ; 4  NEXT

TWODUP_XSQUOTE                  ; see [ELSE]
            MOV TOS,-2(PSP)     ; 3
            MOV @PSP,-4(PSP)    ; 4
            SUB #4,PSP          ; 1
; Primitive XSQUOTE; compiled by SQUOTE
; (S")     -- addr u   run-time code to get address and length of a compiled string.
XSQUOTE     SUB #4,PSP          ; 1                 push old TOS on stack
            MOV TOS,2(PSP)      ; 3                 and reserve one cell on stack
            MOV.B @IP+,TOS      ; 2 -- ? u          u = lenght of string
            MOV IP,0(PSP)       ; 3 -- addr u       IP is odd...
            ADD TOS,IP          ; 1                 IP=addr+u=addr(end_of_string)
            BIT #1,IP           ; 1                 IP=addr+u   Carry set/clear if odd/even
            ADDC #0,IP          ; 1                 IP=addr+u aligned
            MOV @IP+,PC         ; 4  16~

; : SETIB SOURCE 2! 0 >IN ! ;
; SETIB      org len --        set Input Buffer, shared by INTERPRET and [ELSE]
SETIB       MOV #0,&TOIN            ;3
            MOV @PSP+,&SOURCE_ORG   ;4 -- len
            MOV TOS,&SOURCE_LEN     ;3 -- len
            MOV @PSP+,TOS           ;2 --
            MOV @IP+,PC             ;4

; REFILL    accept one line to input buffer and leave org len' of the filled input buffer
; as it has no more host OS and as waiting command is done by ACCEPT, REFILL's flag is useless
; : REFILL TIB DUP CIB_LEN ACCEPT   ;   -- org len'     shared by QUIT and [ELSE]
REFILL      SUB #4,PSP              ;1
            MOV TOS,2(PSP)          ;3                  save TOS
TWODROP_REFILL                      ;                   see [ELSE]
            MOV #CIB_LEN,TOS        ;2  -- x len        Current Input Buffer LENght
            .word 40BFh             ;                   MOV #imm,index(PSP)
CIB_ORG     .word TIB_ORG           ;                   imm=TIB_ORG
            .word 0                 ;4  -- org len      index=0 ==> MOV #TIB_ORG,0(PSP)
            MOV @PSP,-2(PSP)        ;4  -- org len
            SUB #2,PSP              ;1  -- org org len
            JMP ACCEPT              ;2  org org len -- org len'

; Primitive QFBRAN; compiled by IF UNTIL
;Z ?FalseBranch   x --              ; branch if TOS is FALSE (TOS = 0)
QFBRAN      CMP #0,TOS              ; 1  test TOS value
            MOV @PSP+,TOS           ; 2  pop new TOS value (doesn't change flags)
ZBRAN       JNZ SKIPBRANCH          ; 2  if TOS was <> 0, skip the branch; 10 cycles
BRAN        MOV @IP,IP              ; 2  take the branch destination
            MOV @IP+,PC             ; 4  ==> branch taken, 11 cycles

XDODOES                             ; 4 for CALL rDODOES
            SUB #2,PSP              ;+1
            MOV TOS,0(PSP)          ;+3 save TOS on parameters stack
            MOV @RSP+,TOS           ;+2 TOS = PFA address of master word, i.e. address of its first cell after DOES>
            PUSH IP                 ;+3 save IP on return stack
            MOV @TOS+,IP            ;+2 IP = CFA of Master word, TOS = BODY address of created word
            MOV @IP+,PC             ;+4 = 19~ = ITC-2

XDOCON                              ; 4 for CALL rDOCON
            SUB #2,PSP              ;+1
            MOV TOS,0(PSP)          ;+3 save TOS on parameters stack
            MOV @RSP+,TOS           ;+2 TOS = PFA address of master word CONSTANT
            MOV @TOS,TOS            ;+2 TOS = CONSTANT value
            MOV @IP+,PC             ;+4 = 16~ = ITC+4

; ------------------------------------------------------------------------------
; BRanch if BAD strings COMParaison, [COMPARE ZEROEQUAL QFBRAN] replacement
QBRBADCOMP                  ; addr1 u1 addr2 u2 --
            MOV TOS,S       ;1          S = u2
            MOV @PSP+,Y     ;2          Y = addr2
            CMP @PSP+,S     ;2          u1 = u2 ?
            MOV @PSP+,X     ;2          X = addr1
            MOV @PSP+,TOS   ;2 --
            JNZ BRAN        ;2 --       branch if u1<>u2, 11+6 cycles
COMPLOOP    CMP.B @Y+,0(X)  ;4
            JNZ BRAN        ;2 --       if char1<>char2; branch on first char <> in 17+6 cycles
            ADD #1,X        ;1          addr+1
            SUB #1,S        ;1          u-1
            JNZ COMPLOOP    ;2          10 cycles char comp loop
SKIPBRANCH  ADD #2,IP       ;1
            MOV @IP+,PC     ;4

; [TWODROP ONEMINUS ?DUP ZEROEQUAL QFBRAN next_comp EXIT] replacement
QBRNEXTCMP                  ;    -- cnt addr u
            ADD #2,PSP      ;1   -- cnt addr    NIP
            MOV @PSP+,TOS   ;2   -- cnt         + DROP = TWODROP 
            SUB #1,TOS      ;3   -- cnt-1       ONEMINUS
            JNZ BRAN        ;2   -- cnt-1       branch to next comparaison if <> 0
DROPEXIT    MOV @RSP+,IP    ;2
DROP        MOV @PSP+,TOS   ;2   --
            MOV @IP+,PC     ;4

            FORTHWORDIMM  "[ELSE]"
; https://forth-standard.org/standard/tools/BracketELSE
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- )
;Skipping leading spaces, parse and discard space-delimited words from the parse area,
;including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN],
;until the word [THEN] has been parsed and discarded.
;If the parse area becomes exhausted, it is refilled as with REFILL.
;the loop back from BRACKTELSE1 to BRACKTELSE0 is shorten
BRACKETELSE mDOCOL
            .word   LIT,1                   ; -- cnt
            .word   BRAN,BRACKTELSE1        ;                   6~ versus 5~ for ONEPLUS
BRACKTELSE0 .word   XSQUOTE                 ;                   end of skiped line
            .byte   5,13,"ko ",10           ;                   send CR + "ko " + LF
            .word   TYPE                    ; -- cnt addr 0 
            .word   TWODROP_REFILL          ; -- cnt            REFILL Input Buffer with next line
            .word   SETIB                   ;                   SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
BRACKTELSE1 .word   BL_WORD,COUNT           ; -- cnt addr u     Z = 1 if u = 0
            .word   ZBRAN,BRACKTELSE0       ; cnt addr 0 --     Z = 1 --> end of line, -6~
            .word   TWODUP_XSQUOTE          ;                   24 ~
            .byte   6,"[THEN]"              ; -- cnt addr u addr1 u1 addr2 u2
            .word   QBRBADCOMP,BRACKTELSE2  ; -- cnt addr u     if [THEN] not found, jump for next comparaison
            .word   QBRNEXTCMP,BRACKTELSE1  ;                   if found, 2DROP,  count-1, loop back if count <> 0 | DROP EXIT if count = 0
BRACKTELSE2 .word   TWODUP_XSQUOTE          ;
            .byte   6,"[ELSE]"              ; -- cnt addr u addr1 u1 addr2 u2
            .word   QBRBADCOMP,BRACKTELSE3  ; -- cnt addr u     if [ELSE] not found, jump for next comparaison
            .word   QBRNEXTCMP,BRACKTELSE4  ;                   if found, 2DROP, count-1, loop back if count <> 0
BRACKTELSE3 .word   XSQUOTE                 ;                   16 ~
            .byte   4,"[IF]"                ; -- cnt addr1 u1 addr2 u2
            .word   QBRBADCOMP,BRACKTELSE1  ; -- cnt            if [IF] not found, loop back for next word comparaison
BRACKTELSE4 .word   ONEPLUS                 ; -- cnt+1          if found,  same loop back with count+1
            .word   BRAN,BRACKTELSE1        ;         

            FORTHWORDIMM "[IF]" ; flag --
; https://forth-standard.org/standard/tools/BracketIF
;Compilation:
;Perform the execution semantics given below.
;Execution: ;( flag | flag "<spaces>name ..." -- )
;If flag is true, do nothing. Otherwise, skipping leading spaces,
;   parse and discard space-delimited words from the parse area,
;   including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN],
;   until either the word [ELSE] or the word [THEN] has been parsed and discarded.
;If the parse area becomes exhausted, it is refilled as with REFILL. [IF] is an immediate word.
;An ambiguous condition exists if [IF] is POSTPONEd,
;   or if the end of the input buffer is reached and cannot be refilled before the terminating [ELSE] or [THEN] is parsed.
            CMP #0,TOS      ; -- f
            MOV @PSP+,TOS   ; --
            JZ BRACKETELSE  ;       if false flag output
            MOV @IP+,PC     ;       if true flag output

            FORTHWORDIMM  "[UNDEFINED]"
; https://forth-standard.org/standard/tools/BracketUNDEFINED
;Compilation:
;Perform the execution semantics given below.
;Execution: ( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space.
;Return a false flag if name is the name of a word that can be found,
;otherwise return a true flag.
            mDOCOL
            .word   BL_WORD,FIND
            mNEXTADR
            SUB #1,TOS      ;1 borrow if TOS was 0
            SUBC TOS,TOS    ;1 TOS=-1 if borrow is set
NIP_EXIT    MOV @RSP+,IP
NIP         ADD #2,PSP      ;1
            MOV @IP+,PC     ;4

            FORTHWORDIMM  "[DEFINED]"
; https://forth-standard.org/standard/tools/BracketDEFINED
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space.
;Return a true flag if name is the name of a word that can be found,
;otherwise return a false flag. [DEFINED] is an immediate word.
            mDOCOL
            .word   BL_WORD,FIND
            .word   NIP_EXIT

;-------------------------------------------------------------------------------
; STACK OPERATIONS
;-------------------------------------------------------------------------------
; https://forth-standard.org/standard/core/SWAP
SWAP        PUSH @PSP+      ; 3

; https://forth-standard.org/standard/core/Rfrom
; R>    -- x    R: x --   pop from return stack
; VARIABLE run time called by CALL rDOVAR
RFROM       SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3
            MOV @RSP+,TOS   ; 2
            MOV @IP+,PC     ; 4

; https://forth-standard.org/standard/core/DUP
; DUP      x -- x x      duplicate top of stack
DUP         SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3
            MOV @IP+,PC     ; 4

;-------------------------------------------------------------------------------
; ARITHMETIC OPERATIONS
;-------------------------------------------------------------------------------
; https://forth-standard.org/standard/core/Minus
; -      n1/u1 n2/u2 -- n3/u3      n3 = n1-n2
MINUS       SUB @PSP+,TOS   ;2  -- n2-n1
NEGATE      XOR #-1,TOS     ;1
ONEPLUS     ADD #1,TOS      ;1  -- n3 = -(n2-n1) = n1-n2
            MOV @IP+,PC

; ------------------------------------------------------------------------------
; STRINGS PROCESSING
; ------------------------------------------------------------------------------

; use SQUOTE+10 if you want to define another separator

            FORTHWORDIMM "S\34" ; immediate
; https://forth-standard.org/standard/core/Sq
; S"       --             compile in-line string
SQUOTE      SUB #2,PSP              ;               first choose separator
            MOV TOS,0(PSP)
            MOV #'"',TOS            ;               separator = '"'
            MOV #0,T                ;               volatile CAPS OFF, paired with WORDD+4
            mDOCOL              
            .word LIT,XSQUOTE,COMMA ;               obviously use not T register...
            .word WORDD+4           ; -- c-addr     = DP,  W=Count_of_chars
            mNEXTADR                ;
            ADD #1,W                ;               to include count of chars
            BIT #1,W                ;               C = /Z
            ADDC W,&DP              ; -- addr       new DP is aligned
            JMP DROPEXIT            ;
            
            FORTHWORDIMM ".\34"     ; immediate
; https://forth-standard.org/standard/core/Dotq
; ."       --              compile string to print
DOTQUOTE    mDOCOL
            .word   SQUOTE
            .word   LIT,TYPE,COMMA
            .word   EXIT

;-------------------------------------------------------------------------------
; NUMERIC OUTPUT
;-------------------------------------------------------------------------------
; Numeric conversion is done last digit first, so
; the output buffer is built backwards in memory.

            FORTHWORD "<#"
; https://forth-standard.org/standard/core/num-start
; <#    --       begin numeric conversion (initialize Hold Pointer)
LESSNUM     MOV #HOLD_BASE,&HP
            MOV @IP+,PC

; primitive MU/MOD; used by ?NUMBER UM/MOD, and M*/ in DOUBLE word set
; MU/MOD    UDVDlo UDVDhi UDIVlo -- UREMlo UQUOTlo UQUOThi
;-------------------------------------------------------------------------------
; unsigned 32-BIT DiViDend : 16-BIT DIVisor --> 32-BIT QUOTient 16-BIT REMainder
;-------------------------------------------------------------------------------
; two times faster if 16 bits DiViDend (cases of U. and . among others)

; reg     division            MU/MOD      NUM                       M*/
; ---------------------------------------------------------------------
; S     = DVD(15-0)         = ud1lo     = ud1lo                     ud1lo
; TOS   = DVD(31-16)        = ud1hi     = ud1hi                     ud1mi
; W     = DVD(47-32)/REM    = rem       = digit --> char --> -[HP]  ud1hi
; T     = DIV(15-0)         = BASE      = BASE                      ud2
; X     = QUOTlo            = ud2lo     = ud2lo                     QUOTlo
; Y     = QUOThi            = ud2hi     = ud2hi                     QUOThi
; rDODOES = count

MUSMOD      MOV TOS,T               ;1 T = DIVlo
            MOV 2(PSP),S            ;3 S = DVDlo
            MOV @PSP,TOS            ;2 TOS = DVDhi
MUSMOD1     MOV #0,W                ;1  W = REMlo = 0
            MOV #32,rDODOES         ;2  init loop count
            CMP #0,TOS              ;1  DVDhi=0 ?
            JNZ MDIV1               ;2  no
; ----------------------------------;
MDIV1DIV2   RRA rDODOES             ;1  yes:loop count / 2
            MOV S,TOS               ;1      DVDhi <-- DVDlo
            MOV #0,S                ;1      DVDlo <-- 0
            MOV #0,X                ;1      QUOTlo <-- 0 (to do QUOThi = 0 at the end of division)
; ----------------------------------;
MDIV1       CMP T,W                 ;1  REMlo U>= DIVlo ?
            JNC MDIV2               ;2  no : carry is reset
            SUB T,W                 ;1  yes: REMlo - DIVlo ; carry is set
MDIV2       ADDC X,X                ;1  RLC quotLO
            ADDC Y,Y                ;1  RLC quotHI
            SUB #1,rDODOES          ;1  Decrement loop counter
            JN ENDMDIV              ;2
            ADD S,S                 ;1  RLA DVDlo
            ADDC TOS,TOS            ;1  RLC DVDhi
            ADDC W,W                ;1  RLC REMlo
            JNC MDIV1               ;2  14~
            SUB T,W                 ;1  REMlo - DIVlo
            BIS #1,SR               ;1  SETC
            JMP MDIV2               ;2  14~
ENDMDIV     MOV #XDODOES,rDODOES    ;2  restore rDODOES
            MOV W,2(PSP)            ;3  REMlo in 2(PSP)
            MOV X,0(PSP)            ;3  QUOTlo in 0(PSP)
            MOV Y,TOS               ;1  QUOThi in TOS
RET_ADR     MOV @RSP+,PC            ;4  35 words, about 440/240 cycles, not FORTH executable !

            FORTHWORD "#"
; https://forth-standard.org/standard/core/num
; #     ud1lo ud1hi -- ud2lo ud2hi          convert 1 digit of output
NUM         MOV &BASEADR,T          ;3
NUM1        MOV @PSP,S              ;2          -- DVDlo DVDhi              S = DVDlo
            SUB #2,PSP              ;1          -- x x DVDhi                TOS = DVDhi
            CALL #MUSMOD1           ;244/444    -- REMlo QUOTlo QUOThi      T is unchanged W=REMlo X=QUOTlo Y=QUOThi
            MOV @PSP+,0(PSP)        ;4          -- QUOTlo QUOThi            W = REMlo
TODIGIT     CMP.B #10,W             ;2
            JNC TODIGIT1            ;2  jump if U<
            ADD.B #7,W              ;2
TODIGIT1    ADD.B #30h,W            ;2
HOLDW       SUB #1,&HP              ;3  store W=char --> -[HP]
            MOV &HP,Y               ;3
            MOV.B W,0(Y)            ;3
            MOV @IP+,PC             ;4 22 words, about 276|476 cycles for u|ud one digit

            FORTHWORD "#S"
; https://forth-standard.org/standard/core/numS
; #S    udlo udhi -- 0 0       convert remaining digits
NUMS        mDOCOL
            .word   NUM             ;       X=QUOTlo
            mNEXTADR                ;       next adr
            SUB #2,IP               ;1      restore NUM return
            BIS TOS,X               ;1
            CMP #0,X                ;1 --   ud2lo ud2hi      ud = 0 ?
            JNZ NUM1                ;2
EXIT        MOV @RSP+,IP            ;2      when DTC=2 rDOCOL is loaded with this EXIT address
            MOV @IP+,PC             ;4 10 words, about 294|494 cycles for u|ud one digit

            FORTHWORD "#>"
; https://forth-standard.org/standard/core/num-end
; #>    udlo:udhi -- addr u    end conversion, get string
NUMGREATER  MOV &HP,0(PSP)          ; -- addr 0
            MOV #HOLD_BASE,TOS      ;
            SUB @PSP,TOS            ; -- addr u
            MOV @IP+,PC

            FORTHWORD "HOLD"
; https://forth-standard.org/standard/core/HOLD
; HOLD  char --        add char to output string
HOLD        MOV.B TOS,W             ;1
            MOV @PSP+,TOS           ;2
            JMP HOLDW               ;15

            FORTHWORD "SIGN"
; https://forth-standard.org/standard/core/SIGN
; SIGN  n --           add minus sign if n<0
SIGN        CMP #0,TOS              ; 1
            MOV @PSP+,TOS           ; 2
            MOV.B #'-',W            ; 2
            JN HOLDW                ; 2 jump if 0<
            MOV @IP+,PC             ; 4

BL          CALL rDOCON
            .word   ' '

            FORTHWORD "U."
; https://forth-standard.org/standard/core/Ud
; U.    u --           display u (unsigned)
; note: DDOT = UDOT + 10 (see DOUBLE.f)
UDOT        MOV #0,S                ; 1                 S=sign
            SUB #2,PSP              ; 1
            MOV TOS,0(PSP)          ; 3 -- |lo| x
            MOV #0,TOS              ; 1 -- |lo| |hi|     
UDOTNEXT    PUSHM #2,IP             ; 4                 R-- IP sign
            mASM2FORTH              ;10
            .word   LESSNUM
            .word   BL,HOLD         ;                   add a trailing space
            .word   NUMS            ;
            .word   RFROM,SIGN      ;           IP sign R-- IP
            .word   NUMGREATER,TYPE
            .word   EXIT            ;                IP R-- 

            FORTHWORD "."
; https://forth-standard.org/standard/core/d
; .     n --           display n (signed)
DOT         CMP #0,TOS
            JGE UDOT
            XOR #-1,TOS             ;1 set TOS = |lo|
            ADD #1,TOS              ;1
            MOV #-1,S               ;1 set S = minus sign
            JMP UDOT+2

;-------------------------------------------------------------------------------
; INTERPRETER
;-------------------------------------------------------------------------------
;
; https://forth-standard.org/standard/core/WORD
; WORD   char -- addr        Z=1 if len=0
; parse a word delimited by char separator.
; the resulting c-string is left at HERE.
; if CAPS is ON, this word is CAPITALIZED unless for a 'char' input.
; notice that the average lenght of all CORE definitions is about 4.
            FORTHWORD "WORD"
            JMP WORDD           ;2

;-------------------------------;
BL_WORD     SUB #2,PSP          ;1              )
            MOV TOS,0(PSP)      ;3              > 6~ instead of 16~ for CONSTANT BL runtime
            MOV #' ',TOS        ;2 -- BL        ) 
WORDD       MOV #20h,T          ;3 -- sep       CAPS OFF = 0, CAPS ON = $20.
            MOV #SOURCE_LEN,S   ;2              WORD+16 address
            MOV @S+,X           ;2              X = src_len
            MOV @S+,Y           ;2              Y = src_org
            ADD Y,X             ;1              X = src_len + src_org = src_end
            ADD @S+,Y           ;2              Y = >IN + src_org = src_ptr
            MOV @S,W            ;2              W = HERE = dst_ptr
;-------------------------------;
SKIPSEPLOOP CMP X,Y             ;1              src_ptr >= src_end ?
            JC SKIPSEPEND       ;2              if yes : End Of Line !
            CMP.B @Y+,TOS       ;2              does char = separator ?
            JZ SKIPSEPLOOP      ;2              if yes; 7~ loop
            SUB #1,Y            ;1              decrement the post incremented src_ptr
;-------------------------------;
SCANTICK    CMP.B #"'",2(Y)     ;4              third char = TICK ? (that allows ' as first char for a definition name)
            JNZ SCANWRDLOOP     ;2              no
            MOV #0,T            ;1              don't capitalize a 'char' input
;-------------------------------;
SCANWRDLOOP MOV.B S,0(W)        ;3              first, make room in dst for word length; next, put char here.
            CMP X,Y             ;1              src_ptr = src_end ?
            JZ SCANWRDEND       ;2              if yes
            MOV.B @Y+,S         ;2              S=char
            CMP.B S,TOS         ;1 -- sep       does char = separator ?
            JZ SCANWRDEND       ;2              if yes
            ADD #1,W            ;1              increment dst
            CMP.B #'a',S        ;2              char U< 'a' ?  this condition is tested at each loop
            JNC SCANWRDLOOP     ;2              16~ upper case char loop
            CMP.B #'z'+1,S      ;2              char U>= 'z'+1 ?
            JC SCANWRDLOOP      ;2              U>= loopback if yes
            SUB.B T,S           ;1              convert a...z to A...Z if CAPS ON (T=$20)
            JMP SCANWRDLOOP     ;2              23~ lower case char loop
SKIPSEPEND
SCANWRDEND  SUB &SOURCE_ORG,Y   ;3 -- sep       Y=src_ptr - src_org = new >IN (first char separator next)
            MOV Y,&TOIN         ;3              update >IN for next search in this input stream
            MOV &DP,TOS         ;3 -- addr      TOS = HERE
            SUB TOS,W           ;1              W = Word_Length >= 0
            MOV.B W,0(TOS)      ;3 -- c-addr
            MOV @IP+,PC         ;4              Z=1 <==> Word_Length = 0 <==> EOL, tested by INTERPRET

            FORTHWORD "FIND"    ;
; https://forth-standard.org/standard/core/FIND
; FIND     addr -- c-addr 0    if not found ; flag Z=1       c-addr at transient RAM area (HERE)
;                  CFA -1      if found     ; flag Z=0
;                  CFA  1      if immediate ; flag Z=0
; compare WORD at c-addr (HERE)  with each of words in each of listed vocabularies in CONTEXT
; start of FIND     : 24/33 cycles
;                     +7  cycles on first char,
;                     +10 cycles x (n-1 char),
; WORDFOUND to end  : 16 cycles.
; VOCLOOP           : 12/19 cycles.
; name loop         : 8  cycles. 
; note: with 16 threads vocabularies, FIND takes only! 75% of CORETEST.4th processing time
FIND        SUB #2,PSP          ;1 -- ???? c-addr       reserve one cell, not at FINDEND which would kill the Z flag
            MOV TOS,S           ;1                      S=c-addr
            MOV #CONTEXT,T      ;2                      T = first cell addr of CONTEXT stack
VOCLOOP     MOV @T+,TOS         ;2 -- ???? VOC_PFA      T=CTXT+2
            CMP #0,TOS          ;1                      TOS = BODY = voclink; no more vocabulary in CONTEXT ?
            JZ FINDEND          ;2 -- ???? 0            yes ==> exit; Z=1
    .SWITCH THREADS
    .CASE   1                   ;                       nothing to do
    .ELSECASE                   ;                       searching thread adds 7 cycles & 6 words
            MOV.B 1(S),Y        ;3 -- ???? VOC_PFA0     S=c-addr Y=first char of c-addr string
            AND.B #(THREADS-1),Y;2 -- ???? VOC_PFA0     Y=thread_x
            ADD Y,Y             ;1 -- ???? VOC_PFA0     Y=thread_offset_x
            ADD Y,TOS           ;1 -- ???? VOC_PFAx     TOS = words set entry
    .ENDCASE
            ADD #2,TOS          ;1 -- ???? VOC_PFAx+2
WORDLOOP    MOV -2(TOS),TOS     ;3 -- ???? NFA          -2(TOS) = [VOC_PFAx] first, then [LFA]
            CMP #0,TOS          ;1                      no more word in the thread ?
            JZ VOCLOOP          ;2                      yes ==> search next voc in context
            MOV TOS,X           ;1
            MOV.B @X+,Y         ;2                      TOS = NFA,  X= NFA+1, Y = NFA_first_byte = cnt<<2+i (i= immediate flag)
            RRA.B Y             ;1                      remove immediate flag, the remainder is the count of the definition name.
LENCOMP     CMP.B @S,Y          ;2                      compare lenght
            JNZ WORDLOOP        ;2                      14~ word loop on lenght mismatch
            MOV S,W             ;1                      S=W=c-addr
CHARCOMP    CMP.B @X+,1(W)      ;4                      compare chars
            JNZ WORDLOOP        ;2                      21~ word loop on first char mismatch
            ADD #1,W            ;1
            SUB.B #1,Y          ;1                      decr count
            JNZ CHARCOMP        ;2                      10~ char loop
WORDFOUND   BIT #1,X            ;1
            ADDC #0,X           ;1
            MOV X,S             ;1                      S=aligned CFA
            MOV.B @TOS,TOS      ;2 -- ???? NFA_1st_byte 
            AND #1,TOS          ;1 -- ???? 0|1          test immediate flag
            JNZ FINDEND         ;2 -- ???? 1            jump if bit 1 is set, as immediate bit
            SUB #1,TOS          ;1 -- ???? -1
FINDEND     MOV S,0(PSP)        ;3 -- xt -1/0/1         if not found: -- c-addr 0    flag Z=1
            MOV @IP+,PC         ;4 34/40 words          return to interpreter

            FORTHWORD ">NUMBER"
; >NUMBER  ud1lo ud1hi addr1 cnt1 -- ud2lo ud2hi addr2 cnt2
; https://forth-standard.org/standard/core/toNUMBER
; ud2 is the unsigned result of converting the characters within the string specified by c-addr1 u1 into digits,
; using the number in BASE, and adding each into ud1 after multiplying ud1 by the number in BASE.
; Conversion continues left-to-right until a character that is not convertible (including '.'  ','  '_')
; is encountered or the string is entirely converted. c-addr2 is the location of the first unconverted character
; or the first character past the end of the string if the string was entirely converted.
; cnt2 is the number of unconverted characters in the string.
; An ambiguous condition exists if ud2 overflows during the conversion.

            MOV &BASEADR,T      ;3                      T = base
            MOV @PSP+,S         ;2 -- ud1lo ud1hi cnt1  S = addr1
            MOV @PSP+,Y         ;2 -- ud1lo cnt1        Y = ud1hi
            MOV @PSP,X          ;2 -- x cnt1            X = ud1lo
            SUB #4,PSP          ;1 -- x x x cnt1
TONUM_INPUT                     ;                       for QNUMBER
    .IFDEF MPY_32 ; if 32 bits hardware multiplier
            MOV T,&MPY          ;3                      base = MPY = OP1 loaded out of TONUMLOOP
    .ENDIF
TONUMLOOP   MOV.B @S,W          ;2 -- x x x cnt         S=adr, T=base, W=char, X=udlo, Y=udhi
DDIGITQ     SUB.B #':',W        ;2                      all Ctrl_Chars < '0'  and all chars '0' to '9' become negative
            JNC DDIGITQNEXT     ;2                      accept all chars U< ':'  (accept $0 up to $39)
            SUB.B #7,W          ;2                      W = char - (':' + $07 = 'A')
            JNC TONUMEND        ;2 -- x x x cnt         reject all Ctrl_Chars U< 'A', (with Z flag = 0)
DDIGITQNEXT ADD.B #0Ah,W        ;2                      restore digit value: 0 to 15 (and beyond)
            CMP T,W             ;1                      digit - base
            BIC #Z,SR           ;1                      clear Z before return to QNUMBER
            JC TONUMEND         ;2                      to avoid QNUMBER conversion true with digit=base :-(
    .IFDEF MPY_32 ; if 32 bits hardware multiplier      (ud * base) + digit --> ud 
            MOV X,&OP2L         ;3                      Load 2nd operand (ud1lo)
            MOV Y,&OP2H         ;3                      Load 2nd operand (ud1hi)
            MOV &RES0,X         ;3                      lo result in X (ud2lo)
            MOV &RES1,Y         ;3                      hi result in Y (ud2hi)
ADD_DIGIT   ADD W,X             ;1                      ud2lo + digit
            ADDC #0,Y           ;1                      ud2hi + carry
TONUMPLUS   ADD #1,S            ;1                      adr+1
            SUB #1,TOS          ;1 -- x x x cnt-1       cnt-1
            JNZ TONUMLOOP       ;2                      if count <>0    33~ per digit
TONUMEND    MOV S,0(PSP)        ;3 -- x x addr2 cnt2
    .ELSE ; no hardware multiplier                      (ud * base) + digit --> ud 
            MOV #0,rDODOES      ;1 RESlo=0
            MOV #0,rDOCON       ;1 REShi=0
            MOV #1,rDOVAR       ;1 BIT TEST for base
MUL_LOOP    BIT rDOVAR,T        ;1 test actual bit in base  (OP1)
            JZ MUL_SHIFT        ;2
            ADD X,rDODOES       ;1 IF 1: ADD ud1lo TO RESlo (OP2L + RES0 --> RES0)
            ADDC Y,rDOCON       ;1      ADDC ud1hi TO REShi (OP2H + RES1 + C --> RES1)
MUL_SHIFT   ADD X,X             ;1 (RLA LSBs) ud1lo *2      (OP2L*2)
            ADDC Y,Y            ;1 (RLC MSBs) ud1hi *2      (OP2H*2)
            ADD rDOVAR,rDOVAR   ;1 (RLA) NEXT BIT TO TEST   (BIT_TEST<1)
            JNC MUL_LOOP        ;2 IF BIT IN CARRY: FINISHED
            MOV rDODOES,X       ;1 RESlo --> ud2lo
            MOV rDOCON,Y        ;1 REShi --> ud2hi
ADD_DIGIT   ADD W,X             ;1                      ud2lo + digit
            ADDC #0,Y           ;1                      ud2hi + carry
TONUMPLUS   ADD #1,S            ;1                      adr+1
            SUB #1,TOS          ;1 -- x x x cnt-1       cnt-1
            JNZ TONUMLOOP       ;2                      if count <>0   158/160/158 ~ per digit with base 2/10/16
TONUMEND    MOV #FORTH_ORG+4,W  ;2
            MOV @W+,rDODOES     ;2                      XDODOES --> R5=rDODOES
            MOV @W+,rDOCON      ;2                       XDOCON --> R6=rDOCON
            MOV @W,rDOVAR       ;2                        RFROM --> R7=rDOVAR
            MOV S,0(PSP)        ;3 -- x x addr2 cnt2
    .ENDIF
            MOV Y,2(PSP)        ;3 -- x ud2hi addr2 cnt2
            MOV X,4(PSP)        ;3 -- ud2lo ud2hi addr2 cnt2
            MOV @IP+,PC         ;4

; ?NUMBER makes the interface between INTERPRET and >NUMBER; also used by ASSEMBLER.
; convert a string to a signed number; FORTH 2012 prefixes $  %  # are recognized,
; FORTH 2012 'char' numbers also, digits separator '_' also.
; with DOUBLE_INPUT option, 32 bits signed numbers (with decimal point) are recognized,
; with FIXPOINT_INPUT option, Q15.16 signed numbers (with comma) are recognized.
; prefixes ' # % $ - are processed before calling >NUMBER
; chars . , _  are processed as >NUMBER exits.
;Z ?NUMBER  addr -- n|d -1  if convert ok ; flag Z=0, UF9=1 if double
;Z          addr -- addr 0  if convert ko ; flag Z=1

INTQNUM     MOV #INTQNUMNEXT,IP ;2                          INTQNUMNEXT is the next of QNUMBER     
QNUMBER                         ;  -- addr
        .IFDEF DOUBLE_NUMBERS   ;                           DOUBLE_NUMBERS = DOUBLE_INPUT | FIXPOINT_INPUT
            BIC #UF9,SR         ;2                          clear UserFlag_9 used as double number flag
        .ENDIF                  ;
            SUB #8,PSP          ;1 -- x x x x addr          make room for >NUMBER
            MOV TOS,6(PSP)      ;3 -- addr x x x addr       save TOS for TONUMEXIT 
            MOV #0,Y            ;1                          Y=ud1hi=0
            MOV #0,X            ;1                          X=ud1lo=0
            MOV &BASEADR,T      ;3                          T=BASE
            MOV TOS,S           ;1                          S=addr
            MOV #0,TOS          ;1                          TOS=sign of result
            PUSHM #2,TOS        ;4 R-- sign IP              PUSH TOS,IP
            MOV #TONUMEXIT,IP   ;2                          set TONUMEXIT as return from >NUMBER
            MOV.B @S+,TOS       ;2 -- addr x x x cnt        TOS=count, S=addr+1
QNUMLDCHAR  MOV.B @S,W          ;2                          W=char
            SUB.B #'-',W        ;2                          char '-' ?
            JZ QNUMMINUS        ;2                              negate sign
            JC TONUM_INPUT      ;2 -- addr x x x cnt        jump if char U> '-', case of numeric chars
QBINARY     MOV #2,T            ;1                          preset base 2
            ADD.B #8,W          ;1                          binary '%' prefix ?     '%' + 8 = '-'
            JZ PREFIXNEXT       ;2                          yes
QDECIMAL    ADD #8,T            ;1                          preset base 10
            ADD.B #2,W          ;1                          decimal '#' prefix ?    '#' + 2 = '%'
            JZ PREFIXNEXT       ;2                          yes
QHEXA       MOV #16,T           ;2                          preset base 16
            CMP.B #1,W          ;1                          hex '$' prefix ?        '#' + 1 = '$'
            JZ PREFIXNEXT       ;2                          yes
QTICK       CMP.B #4,W          ;1                          ' prefix ?              '#' + 4 = "'"
            JNZ QNUMNEXT        ;2 -- addr x x x cnt        no, abort because other prefixes not recognized
            CMP #3,TOS          ;2                          count = 3 ?
            JNZ QNUMNEXT        ;2                          no, abort
            CMP.B @S+,1(S)      ;4 -- addr x x x 3          3rd char = 1st char ?
            MOV.B @S,S          ;2                          does byte to word conversion
            MOV S,4(PSP)        ;3 -- addr ud2lo x x 3      ud2lo = ASCII code of 'char'
            JMP QNUMNEXT        ;2 -- addr ud2lo x x 3      with happy end only if 3rd char = 1st char = '
QNUMMINUS   MOV #-1,2(RSP)      ;3 R-- sign IP              set sign flag
PREFIXNEXT  SUB #1,TOS          ;1 -- addr x x x cnt-1      TOS=count-1
            CMP.B @S+,0(S)      ;4                          S=adr+1; same prefix ?
            JNZ QNUMLDCHAR      ;2                          loopback if no
            JZ TONUM_INPUT      ;2                          if yes, this double prefix will be rejected by >NUMBER
; ------------------------------;46
TONUMEXIT   mNEXTADR            ;  -- addr ud2lo-hi addr2 cnt2      R-- IP sign BASE    S=addr2
            JZ QNUMNEXT         ;2                                  TOS=0 and Z=1 if conversion is ok
            SUB #2,IP           ;1                                  redefines TONUMEXIT as >NUMBER return, if loopback applicable
            MOV.B @S,W          ;2                                  reload rejected char
            CMP.B #'_',W        ;2                                  rejected char by >NUMBER is a underscore ?
            JZ TONUMPLUS        ;2                                  yes: return to >NUMBER to skip char then resume conversion, 30~ loopback
        .IFDEF DOUBLE_NUMBERS   ;                                   DOUBLE_NUMBERS = DOUBLE_INPUT | FIXPOINT_INPUT
            BIT #UF9,SR         ;2                                  UF9 already set ? ( if you have typed .. )
            JNZ QNUMNEXT        ;2                                  yes, goto QNUMKO
            BIS #UF9,SR         ;2                                  set double number flag
        .ENDIF
        .IFDEF DOUBLE_INPUT     ;
            SUB.B #'.',W        ;2                                  rejected char by >NUMBER is a decimal point ?
            JZ TONUMPLUS        ;2                                  yes, loopback to >NUMBER to skip char, 45~ loopback
        .ENDIF                  ;
        .IFDEF FIXPOINT_INPUT   ;
            .IFDEF DOUBLE_INPUT
            ADD.B #2,W          ;1                                  rejected char by >NUMBER is a comma ? (',' - '.' + 2 = 0)
            .ELSE               ;
            CMP.B #',',W        ;2                                  rejected char by >NUMBER is a comma ?
            .ENDIF              ;
            JNZ QNUMNEXT        ;2                                  no: with Z=0 ==> goto QNUMKO
; ------------------------------;  -- addr ud2lo   x      x     x   S=addr2, T=base
S15Q16      MOV TOS,W           ;1 -- addr ud2lo   x      x     x   W=cnt2
            MOV #0,X            ;1 -- addr ud2lo   x      x     x   init X = ud2lo' = 0
S15Q16LOOP  MOV X,2(PSP)        ;3 -- addr ud2lo ud2lo'   x     x   2(PSP) = X = ud2lo' = 0 then uqlo
            SUB.B #1,W          ;1                                  decrement cnt2
            MOV W,X             ;1                                  X = cnt2-1
            ADD S,X             ;1                                  X = end_of_string-1,-2,-3...
            MOV.B @X,X          ;2                                  X = last char of string first (reverse conversion)
            SUB.B #':',X        ;2
            JNC QS15Q16DIGI     ;2                                  accept all chars U< ':'
            SUB.B #7,X          ;2
            JNC S15Q16EOC       ;2                                  reject all chars U< 'A'
QS15Q16DIGI ADD.B #10,X         ;2                                  restore digit value
            CMP T,X             ;1                                  T=Base, is X a digit ?
            JC S15Q16EOC        ;2 -- addr ud2lo ud2lo'   x     x   if not a digit, --> goto QNUMKO
            MOV X,0(PSP)        ;3 -- addr ud2lo ud2lo' digit   x   
            MOV T,TOS           ;1 -- addr ud2lo ud2lo' digit  base             R-- IP sign
            PUSHM #3,S          ;5 -- addr ud2lo ud2lo' ud2hi' base PUSH S,T,W: R-- IP sign addr2 base cnt2
            CALL #MUSMOD        ;4                                  CALL MU/MOD
            POPM #3,S           ;5 -- addr ud2lo   ur   uqlo   uqhi restore W,T,S: R-- IP sign
            JMP S15Q16LOOP      ;2                                  X=uqlo
S15Q16EOC   MOV 4(PSP),2(PSP)   ;5 -- addr ud2lo ud2hi  uqlo   uqhi ud2lo from >NUMBER becomes ud2hi part of Q15.16
            MOV @PSP,4(PSP)     ;4 -- addr ud2lo ud2hi  uqlo   uqhi uqlo becomes ud2lo part of Q15.16
            CMP.B #0,W          ;1                                  count = 0 if end of conversion ok
        .ENDIF ; FIXPOINT_INPUT
; ------------------------------;
QNUMNEXT    POPM #2,TOS         ;4 -- addr ud2lo-hi x sign  R: --   POPM IP,TOS  TOS = sign flag = {-1;0}
            JZ QNUMOK           ;2 -- addr ud2lo-hi x sign          conversion OK if Z=1
; ------------------------------;
QNUMKO      ADD #6,PSP          ;2 -- addr sign
            AND #0,TOS          ;1 -- addr ff                       TOS=0 and Z=1 ==> conversion ko
            MOV @IP+,PC         ;4
; ------------------------------;
        .IFDEF DOUBLE_NUMBERS   ;  -- addr ud2lo-hi x sign
QNUMOK      ADD #2,PSP          ;1 -- addr ud2lo-hi sign
            MOV 2(PSP),4(PSP)   ;5 -- udlo udlo udhi sign
            MOV @PSP+,0(PSP)    ;4 -- udlo udhi sign                note : PSP is incremented before write back.
            XOR #-1,TOS         ;1 -- udlo udhi inv(sign)
            JNZ QDOUBLE         ;2 -- udlo udhi tf                  if jump : TOS=-1 and Z=0 ==> conversion ok
            XOR #-1,TOS         ;1 -- udlo udhi tf
QDNEGATE    XOR #-1,2(PSP)      ;3 -- udlo udhi -1
            XOR #-1,0(PSP)      ;3 -- (dlo dhi)-1 tf
            ADD #1,2(PSP)       ;3
            ADDC #0,0(PSP)      ;3
QDOUBLE     BIT #UF9,SR         ;2 -- dlo dhi tf                    decimal point or comma fixpoint ?
            JZ NIP              ;2                                  no, remove dhi, set Z=0
QNUMEND     MOV @IP+,PC         ;4                                  TOS=tf and Z=0 ==> conversion ok
        .ELSE
QNUMOK      ADD #4,PSP          ;1 -- addr ud2lo sign
            MOV @PSP,2(PSP)     ;4 -- u u sign                      note : PSP is incremented before write back !!!
            XOR #-1,TOS         ;1 -- udlo udhi inv(sign)
            JNZ QNUMEND         ;2 -- udlo udhi tf                  if jump : TOS=-1 and Z=0 ==> conversion ok
            XOR #-1,TOS         ;1 -- udlo udhi sign
QNEGATE     XOR #-1,2(PSP)      ;3
            ADD #1,2(PSP)       ;3 -- n u tf
QNUMEND     ADD #2,PSP          ;1 -- n tf
            MOV @IP+,PC         ;4                                  TOS=-1 and Z=0 ==> conversion ok
        .ENDIF ; DOUBLE_NUMBERS ;


            FORTHWORDIMM "\\"       ; immediate
; https://forth-standard.org/standard/block/bs
; \         --      backslash
; everything up to the end of the current line is a comment.
BACKSLASH   MOV &SOURCE_LEN,&TOIN   ;
            MOV @IP+,PC

; ------------------------------;
; INTERPRET=\\+8                ;
; EXECUTE=\\+$28;               ;
; ------------------------------;

; ------------------------------;
; INTERPRET    i*x addr u -- j*x      interpret given buffer
; This is the common factor of EVALUATE and QUIT.
; set addr u as input buffer then parse it word by word
INTERPRET   mDOCOL              ;               INTERPRET = BACKSLASH + 8
            .word SETIB         ; --            set input buffer pointers
INTLOOP     .word BL_WORD       ; -- c-addr     flag Z = 1 <=> End Of Line
            .word ZBRAN,FDROPEXIT;              early return if End of Line
            .word FIND          ;
            mNEXTADR            ; -- xt|c-addr|xt -1|0|+1   Z=1 --> not found
            MOV TOS,W           ;                           W = flag = (-1|0|+1) as (not_immediate|not_found|immediate)
            MOV @PSP+,TOS       ; -- xt|c-addr|xt
            JZ INTQNUM          ;2              if Z=1 --> not found, search a number from c_addr
            MOV #INTLOOP,IP     ;2              INTLOOP is the next of EXECUTE|COMMA
            XOR &STATE,W        ;3
            JZ COMMA            ;2 -- xt        if W xor STATE = 0 compile xt, then loop back to INTLOOP
EXECUTE     PUSH TOS            ;3 -- xt
            MOV @PSP+,TOS       ;2 --
            MOV @RSP+,PC        ;4              xt --> PC, then loop back to INTLOOP
; ------------------------------;
INTQNUMNEXT mNEXTADR            ;  -- n|c-addr fl   Z = 1 --> not a number, SR(UF9) double number request
            MOV @PSP+,TOS       ;2 -- n|c-addr
            MOV #INTLOOP,IP     ;2              INTLOOP is the next of LITERAL.
            JNZ LITERAL         ;2 n --         Z = 0 --> is a number, execute LITERAL then loop back to INTLOOP
NOTFOUND    MOV #FQABORT_YES,IP ;2              QABORT_YES becomes the end of INTERPRET
            ADD.B #1,0(TOS)     ;3 c-addr --    Z = 1 --> Not a Number : incr string count to add '?'
            MOV.B @TOS,Y        ;2              Y=count+1
            ADD TOS,Y           ;1              Y=end of string addr
            MOV.B #'?',0(Y)     ;5              add '?' to end of string
            JMP COUNT           ;2 -- addr len  return to ABORT_TERM
FDROPEXIT   .word   DROPEXIT

            FORTHWORDIMM "LITERAL"  ; immediate
    .IFDEF DOUBLE_NUMBERS       ; are recognized
; https://forth-standard.org/standard/core/LITERAL
; LITERAL  n --        append single numeric literal if compiling state
;          d --        append two numeric literals if compiling state and UF9<>0 (not ANS)
LITERAL     CMP #0,&STATE       ;3
            JZ LITERALNEXT      ;2 if interpreting state, does nothing else to clear UF9 flag
            MOV TOS,X           ;1          X = n|dhi
LITERALLOOP MOV &DP,W           ;3
            ADD #4,&DP          ;3
            MOV #LIT,0(W)       ;4
            MOV X,2(W)          ;3 pass 1: compile n, if pass 2: compile dhi
            MOV @PSP+,TOS       ;2
            BIT #UF9,SR         ;2 double number ?
LITERALNEXT BIC #UF9,SR         ;2    in all case, clear UF9
            JZ LITERALEND       ;2 no  goto end if n|interpret_state
            MOV TOS,2(W)        ;3 yes compile dlo over dhi
            JMP LITERALLOOP     ;2
LITERALEND  MOV @IP+,PC         ;4
    .ELSE
; https://forth-standard.org/standard/core/LITERAL
; LITERAL  n --        append single numeric literal if compiling state
LITERAL     CMP #0,&STATE       ;3
            JZ LITERALEND       ;2 if interpreting state, does nothing
            MOV &DP,W           ;3
            ADD #4,&DP          ;3
            MOV #LIT,0(W)       ;4
            MOV TOS,2(W)        ;3
            MOV @PSP+,TOS       ;2
LITERALEND  MOV @IP+,PC         ;4
    .ENDIF

; https://forth-standard.org/standard/core/DEPTH
; DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
QDEPTH      MOV TOS,-2(PSP)     ; 3
            MOV #PSTACK,TOS     ; 2
            SUB PSP,TOS         ; 1 PSP-S0--> TOS
            RRA TOS             ; 1 TOS/2   --> TOS
            SUB #2,PSP          ; 1
; https://forth-standard.org/standard/core/Zeroless
; 0<     n -- flag      true if TOS negative
ZEROLESS    ADD TOS,TOS         ;1 set carry if TOS negative
            SUBC TOS,TOS        ;1 TOS=-1 if carry was clear
INVERT      XOR #-1,TOS         ;1 TOS=-1 if carry was set
            MOV @IP+,PC         ;4

QFRAM_FULL  SUB #2,PSP          ; 2
            MOV TOS,0(PSP)      ; 3
            MOV #0,TOS          ; 1
            CMP #FRAM_FULL,&DP  ; 4
            JC INVERT           ; 2
            MOV @IP+,PC         ; 4 16~

            FORTHWORD "COUNT"
; https://forth-standard.org/standard/core/COUNT
; COUNT   c-addr1 -- adr len   counted->adr/len
COUNT       SUB #2,PSP          ;1
            MOV.B @TOS+,W       ;2
            MOV TOS,0(PSP)      ;3
            MOV W,TOS           ;1
            AND #-1,TOS         ;1       Z is set if u=0
            MOV @IP+,PC         ;4 12~

            FORTHWORD "ALLOT"
; https://forth-standard.org/standard/core/ALLOT
; ALLOT   n --         allocate n bytes
            ADD TOS,&DP
            MOV @PSP+,TOS
            MOV @IP+,PC

; ----------------------------------;
; ABORT = ALLOT + $08               ;
; QUIT  = ALLOT + $0E               ;
; ----------------------------------;
;            FORTHWORD "ABORT"
; https://forth-standard.org/standard/core/ABORT
; Empty the data stack and perform the function of QUIT,
; which includes emptying the return stack, without displaying a message.
; ABORT is the common next of WARM and ABORT"
ABORT       MOV #PSTACK,PSP         ; clear Parameter stack
            MOV #0,TOS              ; clear TOS for SYS use.
; https://forth-standard.org/standard/core/QUIT
; QUIT  --     interpret line by line the input stream
QUIT        mASM2FORTH              ; QUIT is the level 0 of Return stack
    .IFDEF PROMPT
QUIT1       .word   XSQUOTE         ;
            .byte   5,13,10,"ok "   ; CR+LF + Forth prompt
QUIT2
    .ELSE
QUIT2       .word   XSQUOTE         ; 16~
            .byte   2,13,10         ; CR+LF
    .ENDIF
            .word   TYPE            ; 79~
QUIT3       .word   REFILL          ;       -- org len      refill the input line buffer from ACCEPT
QUIT4       .word   INTERPRET       ;                       interpret it
QUIT5       .word   QDEPTH          ; 15~                   stack empty test
            .word   XSQUOTE         ; 16~                   ABORT" stack empty"
            .byte   11,"stack empty";
            .word   QABORT          ; 14~                   see QABORT in forthMSP430FR_TERM_xxx.asm
            .word   QFRAM_FULL      ; 16~                   FRAM full test
            .word   XSQUOTE         ; 16~                   ABORT" MAIN full"
            .byte   9,"MAIN full"   ;
            .word   QABORT          ; 14~ 
    .IFDEF PROMPT
            .word   LIT,STATE,FETCH ; STATE @
            .word   QFBRAN,QUIT1    ; 0= case of interpretion state
            .word   XSQUOTE         ; 0<> case of compilation state
            .byte   5,13,10,"   "   ; CR+LF + 3 spaces
    .ENDIF
            .word   BRAN,QUIT2      ; 6~

;             FORTHWORDIMM "ABORT\34"
; ; ABORT" is enabled in interpretation mode (+ 10 words) :
;             PUSH IP
;             CMP #0,&STATE
;             JNZ COMP_QABORT
; EXEC_QABORT MOV #0,T              ; CAPS OFF
;             mASM2FORTH
;             .word   LIT,'"',WORDD+4,COUNT,QABORT
;             .word   DROPEXIT
; COMP_QABORT mASM2FORTH
;             .word   SQUOTE
;             .word   LIT,QABORT,COMMA    ; see QABORT in forthMSP430FR_TERM_xxx.asm
; FEXIT       .word   EXIT

            FORTHWORDIMM "ABORT\34"
; https://forth-standard.org/standard/core/ABORTq
; ABORT" " (empty string) displays nothing
; ABORT"  i*x flag -- i*x   R: j*x -- j*x  flag=0
;         i*x flag --       R: j*x --      flag<>0
            mDOCOL
            .word   SQUOTE
            .word   LIT,QABORT,COMMA    ; see QABORT in forthMSP430FR_TERM_xxx.asm
FEXIT       .word   EXIT

            FORTHWORD "'"
; https://forth-standard.org/standard/core/Tick
; '    -- xt           find word in dictionary and leave on stack its execution address if exist else error.
TICK        mDOCOL
            .word   BL_WORD,FIND
            .word   QFBRAN,FNOTFOUND;
            .word   EXIT
FNOTFOUND   .word   NOTFOUND        ; see INTERPRET

            FORTHWORDIMM "[']"      ; immediate word, i.e. word executed during compilation
; https://forth-standard.org/standard/core/BracketTick
; ['] <name>        --         find word & compile it as literal
BRACTICK    mDOCOL
            .word   TICK            ; get xt of <name>
            .word   LIT,LIT,COMMA   ; append LIT action
            .word   COMMA,EXIT      ; append xt literal

            FORTHWORDIMM "["    ; immediate
; https://forth-standard.org/standard/core/Bracket
; [        --      enter interpretative state
LEFTBRACKET MOV #0,&STATE
            MOV @IP+,PC

            FORTHWORD "]"
; https://forth-standard.org/standard/core/right-bracket
; ]        --      enter compiling state
            MOV  #-1,&STATE
            MOV @IP+,PC

;-------------------------------------------------------------------------------
; COMPILER
;-------------------------------------------------------------------------------
            FORTHWORD ","
; https://forth-standard.org/standard/core/Comma
; ,    x --           append cell to dict
COMMA       ADD #2,&DP          ;3
            MOV &DP,W           ;3
            MOV TOS,-2(W)       ;3
            MOV @PSP+,TOS       ;2
            MOV @IP+,PC         ;4 15~      W = DP

            FORTHWORDIMM "POSTPONE"
; https://forth-standard.org/standard/core/POSTPONE
POSTPONE    mDOCOL
            .word   BL_WORD,FIND
            .word   ZBRAN,FNOTFOUND ; BRANch to FNOTFOUND if Z = 1
            .word   ZEROLESS        ; immediate word ?
            .word   QFBRAN,POST1    ; if immediate
            .word   LIT,LIT,COMMA   ; else  compile LIT
            .word   COMMA           ;       compile xt
            .word   LIT,COMMA       ;       CFA of COMMA
POST1       .word   COMMA,EXIT      ; then compile xt of word found if immediate else CFA of COMMA

            FORTHWORD ":"
; https://forth-standard.org/standard/core/Colon
; : <name>     --      begin a colon definition
            PUSH #COLONNEXT         ;3              define COLONNEXT as HEADER return
;-----------------------------------;
HEADER      BIT #1,&DP              ;3              carry set if odd
            ADDC #2,&DP             ;4              align and make room for LFA
            mDOCOL                  ;
            .word BL_WORD           ;               W = Count_of_chars, up to 127 for definitions
            mNEXTADR                ; -- HERE       HERE is the NFA of this new word
            MOV @RSP+,IP            ;
            BIS.B #1,W              ;               W=count is always odd
            ADD.B #1,W              ;               W=add one byte for length
            ADD TOS,W               ;               W=Aligned_CFA
            MOV &CURRENT,X          ;               X=VOC_BODY of CURRENT
            MOV TOS,Y               ;               Y=NFA
            ADD.B @TOS+,-1(TOS)     ;               shift left once NFA_1st_byte (make room for immediate flag, clear it)
    .SWITCH THREADS                 ;
    .CASE   1                       ;               nothing to do
    .ELSECASE                       ;               multithreading add 5~ 4words
            MOV.B @TOS,TOS          ; -- char       TOS=first CHAR of new word
            AND #(THREADS-1),TOS    ; -- offset     TOS= thread_offset in words
            ADD TOS,TOS             ;               TOS= thread_offset in bytes
            ADD TOS,X               ;               X=VOC_PFAx = thread x of VOC_PFA of CURRENT
    .ENDCASE                        ;
            MOV @PSP+,TOS           ; --
HEADEREND   MOV Y,&LAST_NFA         ;               NFA --> LAST_NFA            used by QREVEAL, IMMEDIATE
            MOV X,&LAST_THREAD      ;               VOC_PFAx --> LAST_THREAD    used by QREVEAL
            MOV W,&LAST_CFA         ;               HERE=CFA --> LAST_CFA       used by DOES>, RECURSE
            MOV PSP,&LAST_PSP       ;               save PSP for check compiling, used by QREVEAL
            ADD #4,W                ;               W = BODY of created word...
            MOV W,&DP               ;
            MOV @RSP+,PC            ; RET           W is the new DP value )
;-----------------------------------;               X is LAST_THREAD      > used by compiling words: CREATE DEFER : CODE ...
COLONNEXT                           ;               Y is NFA              )
    .SWITCH DTC                     ; Direct Threaded Code select:
    .CASE 1                         ; [rDOCOL] = XDOCOL
            MOV #DOCOL,-4(W)        ;   compile CALL R4 = rDOCOL
            SUB #2,&DP              ;   adjust DP
    .CASE 2                         ; [rDOCOL] = EXIT
            MOV #120Dh,-4(W)        ;   compile PUSH IP       3~
            MOV #DOCOL,-2(W)        ;   compile CALL R4 = rDOCOL
    .CASE 3                         ; [rDOCOL] = ???
            MOV #120Dh,-4(W)        ;   compile PUSH IP       3~
            MOV #400Dh,-2(W)        ;   compile MOV PC,IP     1~
            MOV #522Dh,0(W)         ;   compile ADD #4,IP     1~
            MOV #4D30h,+2(W)        ;   compile MOV @IP+,PC   4~
            ADD #4,&DP              ;   adjust DP
    .ENDCASE                        ;
            MOV #-1,&STATE          ; enter compiling state
            MOV @IP+,PC             ;
;-----------------------------------;

;;Z ?REVEAL   --      if no stack mismatch, link this new word in the CURRENT vocabulary
QREVEAL     CMP PSP,&LAST_PSP       ; Check SP with its saved value by , :NONAME CODE...
            JZ LINK_NFA             ;
            mASM2FORTH              ; if stack mismatch.
            .word   XSQUOTE
            .byte   15,"stack mismatch!" ; -- addr cnt
FQABORT_YES .word   QABORT_YES      ;

LINK_NFA    MOV &LAST_NFA,Y         ;                   if no error, link this definition in its thread
            MOV &LAST_THREAD,X      ;
REVEAL      MOV @X,-2(Y)            ; [LAST_THREAD] --> LFA         (for NONAME: LFA --> 210h unused PA reg)
            MOV Y,0(X)              ; LAST_NFA --> [LAST_THREAD]    (for NONAME: [LAST_THREAD] --> 212h unused PA reg)
            MOV @IP+,PC

            FORTHWORDIMM ";"
; https://forth-standard.org/standard/core/Semi
; ;            --      end a colon definition
SEMICOLON   CMP #0,&STATE           ; if interpret mode, semicolon becomes a comment identifier
            JZ BACKSLASH            ; tip: ";" is transparent to the preprocessor, so semicolon comments are kept in file.4th
            mDOCOL                  ; compile mode
            .word   LIT,EXIT,COMMA
            .word   QREVEAL,LEFTBRACKET,EXIT

            FORTHWORD "IMMEDIATE"
; https://forth-standard.org/standard/core/IMMEDIATE
; IMMEDIATE        --   make last definition immediate
IMMEDIATE   MOV &LAST_NFA,Y         ;3
            BIS.B #1,0(Y)           ;4 FIND process more easier with bit0 than bit7 for IMMEDIATE flag
            MOV @IP+,PC

            FORTHWORD "CREATE"
; https://forth-standard.org/standard/core/CREATE
; CREATE <name>        --          define a CONSTANT with its next address
; Execution: ( -- a-addr )          ; a-addr is the address of name's data field
;                                   ; the execution semantics of name may be extended by using DOES>
CREATE      CALL #HEADER            ; --        W = DP
            MOV #DOCON,-4(W)        ;4          -4(W) = CFA = CALL rDOCON
            MOV W,-2(W)             ;3          -2(W) = PFA = W = next address
            JMP REVEAL              ;           to link the definition in vocabulary

            FORTHWORD "DOES>"
; https://forth-standard.org/standard/core/DOES
; DOES>    --          set action for the latest CREATEd definition
DOES        MOV &LAST_CFA,W         ;           W = CFA of CREATEd word
            MOV #DODOES,0(W)        ;           replace CALL rDOCON of CREATE by new CFA: CALL rDODOES
            MOV IP,2(W)             ;           replace PFA by the address after DOES> as execution address
            MOV @RSP+,IP            ;           which ends the..
NEXT_ADR    MOV @IP+,PC             ;           ..of a CREATE  definition.

            FORTHWORD ":NONAME"
; https://forth-standard.org/standard/core/ColonNONAME
; :NONAME        -- xt
; W is DP
; X is the LAST_THREAD lure value for REVEAL
; Y is the LAST_NFA lure value for REVEAL and IMMEDIATE
; ...because we don't want to modify the word set !
            PUSH #COLONNEXT         ; define COLONNEXT as HEADEREND RET
HEADERLESS  SUB #2,PSP              ; -- TOS    common part of :NONAME and CODENNM
            MOV TOS,0(PSP)          ;
            MOV &DP,W               ;
            BIT #1,W                ;
            ADDC #0,W               ;           W = aligned CFA
            MOV W,TOS               ; -- xt     aligned CFA of :NONAME | CODENNM
            MOV #212h,X             ;           MOV Y,0(X)   will write to 212h = unused PA register address (lure for REVEAL)
            MOV X,Y                 ;           MOV @X,-2(Y) will write to 210h = unused PA register address (lure for REVEAL and IMMEDIATE)
            JMP HEADEREND           ;

;; https://forth-standard.org/standard/core/DEFER
;; Skip leading space delimiters. Parse name delimited by a space.
;; Create a definition for name with the execution semantics defined below.
;;
;; name Execution:   --
;; Execute the xt that name is set to execute, i.e. NEXT (nothing),
;; until the phrase ' word IS name is executed, causing a new value of xt to be assigned to name.
;            FORTHWORD "DEFER"
;            CALL #HEADER
;            MOV #4030h,-4(W)        ;4 first CELL = MOV @PC+,PC = BR #addr
;            MOV #NEXT_ADR,-2(W)     ;3 second CELL              =   ...mNEXT : do nothing by default
;            JMP REVEAL              ; to link created word in vocabulary

; used like this (high level defn.):
;   DEFER DISPLAY                       create a "do nothing" definition (2 CELLS)

; or (more elegant low level defn.):
;   CODE DISPLAY                        create a "do nothing" definition (2 CELLS)
;   MOV #NEXT_ADR,PC                    NEXT_ADR is the address of NEXT code: MOV @IP+,PC
;   ENDCODE

; inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
; or in a definition : ... ['] U. IS DISPLAY ... ;
; KEY, EMIT, CR, ACCEPT are examples of DEFERred words

            FORTHWORDIMM "IS"       ; immediate
IS          PUSH IP
            CMP #0,&STATE
            JNZ IS_COMPILE
; IS <name>        xt --
IS_EXEC     mASM2FORTH
            .word   TICK
            mNEXTADR
            MOV @RSP+,IP
DEFERSTORE  MOV @PSP+,2(TOS)        ; -- CFA_DEFERed_WORD          xt --> [PFA_DEFERed_WORD]
            MOV @PSP+,TOS           ; --
            MOV @IP+,PC             ;
IS_COMPILE  mASM2FORTH
            .word   BRACTICK        ; find the word, compile its CFA as literal
            .word   LIT,DEFERSTORE  ; compile DEFERSTORE
            .word   COMMA,EXIT

    .IFDEF VOCABULARY_SET
;-------------------------------------------------------------------------------
; WORDS SET for VOCABULARY, not ANS compliant,
;-------------------------------------------------------------------------------

            FORTHWORD "WORDSET"
;X VOCABULARY       -- create a new word_set
VOCABULARY  mDOCOL
            .word   CREATE
            mNEXTADR                ; W = BODY
        .SWITCH THREADS
        .CASE   1
            MOV #0,0(W)             ; W = BODY, init thread with 0
            ADD #2,W                ;
        .ELSECASE
            MOV #THREADS,X          ; count
VOCABULOOP  MOV #0,0(W)             ; init threads area with 0
            ADD #2,W
            SUB #1,X
            JNZ VOCABULOOP
        .ENDCASE                    ; W = BODY + THREADS*2
            MOV &LASTVOC,0(W)       ; link LASTVOC
            MOV W,&LASTVOC
            ADD #2,W                ; update DP
            MOV W,&DP               ;
            mASM2FORTH              ;
            .word   DOES            ;
;-----------------------------------;
VOCDOES     mNEXTADR                ; adds WORD-SET first in context stack
ALSO        MOV #14,X               ;2 -- move up 7 words, first word in last
ALSOLOOP    SUB #2,X
            MOV CONTEXT(X),CONTEXT+2(X) ; X=src < Y=dst copy W bytes beginning with the end
            JNZ ALSOLOOP
            MOV TOS,CONTEXT(X)      ;3  copy word-set BODY  --> first cell of CONTEXT
            MOV #DROPEXIT,PC

            FORTHWORD "DEFINITIONS"
;X DEFINITIONS  --      set last context vocabulary as entry for further defining words
            MOV &CONTEXT,&CURRENT
            MOV @IP+,PC

            FORTHWORD "ONLY"
;X ONLY     --      fill the context stack with 0 to access only the first word-set, ex.: FORTH ONLY
            MOV #8,W
            MOV #0,X
ONLY_LOOP   MOV #0,CONTEXT+2(X)
            ADD #2,X
            SUB #1,W
            JNZ ONLY_LOOP
            MOV @IP+,PC

            FORTHWORD "PREVIOUS"
;X  PREVIOUS   --               pop first word-set out of context stack
PREVIOUS    MOV #8,W                ;1 move down 8 words, first with CONTEXT+2 addr, last with NULL_WORD one
            MOV #CONTEXT+2,X        ;2 X = org = CONTEXT+2, X-2 = dst = CONTEXT
            CMP #0,0(X)             ;3 [org] = 0 ?
            JZ PREVIOUSEND          ;2 to avoid scratch of the first CONTEXT cell by human mistake
PREVIOUSLOO MOV @X+,-4(X)           ;4
            SUB #1,W                ;1 dec word
            JNZ PREVIOUSLOO         ;2 8~ loop * 8 = 64 ~
PREVIOUSEND MOV @IP+,PC             ;4

            FORTHWORD "FORTH"       ; add FORTH as first context word-set
            CALL rDODOES
            .word   VOCDOES

    .ENDIF ; VOCABULARY_SET

BODYFORTH   .word   lastforthword   ; BODY of FORTH
    .SWITCH THREADS
    .CASE   2
            .word   lastforthword1
    .CASE   4
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
    .CASE   8
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
            .word   lastforthword4
            .word   lastforthword5
            .word   lastforthword6
            .word   lastforthword7
    .CASE   16
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
            .word   lastforthword4
            .word   lastforthword5
            .word   lastforthword6
            .word   lastforthword7
            .word   lastforthword8
            .word   lastforthword9
            .word   lastforthword10
            .word   lastforthword11
            .word   lastforthword12
            .word   lastforthword13
            .word   lastforthword14
            .word   lastforthword15
    .CASE   32
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
            .word   lastforthword4
            .word   lastforthword5
            .word   lastforthword6
            .word   lastforthword7
            .word   lastforthword8
            .word   lastforthword9
            .word   lastforthword10
            .word   lastforthword11
            .word   lastforthword12
            .word   lastforthword13
            .word   lastforthword14
            .word   lastforthword15
            .word   lastforthword16
            .word   lastforthword17
            .word   lastforthword18
            .word   lastforthword19
            .word   lastforthword20
            .word   lastforthword21
            .word   lastforthword22
            .word   lastforthword23
            .word   lastforthword24
            .word   lastforthword25
            .word   lastforthword26
            .word   lastforthword27
            .word   lastforthword28
            .word   lastforthword29
            .word   lastforthword30
            .word   lastforthword31
    .ELSECASE
    .ENDCASE
            .word   voclink
voclink     .set    $-2

    .IFDEF VOCABULARY_SET
            FORTHWORD "hidden"      ; cannot be found by FORTH interpreter because the string is not capitalized
hidden      CALL rDODOES
            .word   VOCDOES
    .ENDIF
BODYhidden  .word   lastasmword     ; BODY of hidden words
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
voclink     .set    $-2

;-------------------------------------------------------------------------------
; ASSEMBLER building definitions
;-------------------------------------------------------------------------------
           FORTHWORD "CODE"         ; a CODE word must be finished with ENDCODE
ASMCODE     CALL #HEADER            ; (that sets CFA and PFA)
ASMCODE1    SUB #4,&DP              ; remove default room for CFA + PFA
    .IFDEF VOCABULARY_SET           ; if VOCABULARY_SET
            JMP hidden              ; add hidden word set in CONTEXT stack
    .ELSE                           ;
hidden      MOV &CONTEXT,&CONTEXT+2 ; add hidden word set in CONTEXT stack
            MOV #BODYhidden,&CONTEXT;
            MOV @IP+,PC             ;
    .ENDIF

; HDNCODE (hidden CODE) is used to define a CODE word which must not to be executed by FORTH interpreter
; i.e. typically the case of an assembler definition called by CALL and ended by RET, or an interrupt routine.
; HDNCODE words are only usable in ASSEMBLER CONTEXT.
            FORTHWORD "HDNCODE"
            PUSH &CURRENT           ; save CURRENT word-set
            MOV #BODYhidden,&CURRENT; select hidden word set as CURRENT
            mDOCOL
            .word   ASMCODE         ; thus, the created links of HDNCODE definitions are relative to the hidden word-set
            mNEXTADR
            MOV @RSP+,IP
            MOV @RSP+,&CURRENT      ; restore previous CURRENT word-set
            MOV @IP+,PC             ;

            FORTHWORD "CODENNM"     ; CODENoNaMe is the assembly counterpart of :NONAME
            PUSH #ASMCODE1          ; define HEADERLESS return
            JMP HEADERLESS          ; that makes room for CFA and PFA

            asmword "ENDCODE"       ;
ENDCODE     MOV IP,T                ; T is unused by QREVEAL
            mASM2FORTH              ;
            .word   QREVEAL
            mNEXTADR
            MOV T,IP
    .IFDEF VOCABULARY_SET
            JMP PREVIOUS            ; remove hidden word set from CONTEXT stack
    .ELSE                           ;
PREVIOUS    MOV #BODYFORTH,&CONTEXT ; remove hidden word set from CONTEXT stack
            MOV #0,&CONTEXT+2       ;
            MOV @IP+,PC
    .ENDIF

; here are 3 words used to switch FORTH <--> ASSEMBLER

; COLON --      compile DOCOL, remove ASSEMBLER from CONTEXT stack, switch to compilation state
            asmword "COLON"
            MOV &DP,W
        .SWITCH DTC
        .CASE 1
            MOV #DOCOL,0(W)         ; compile CALL R4 = rDOCOL ([rDOCOL] = XDOCOL)
            ADD #2,&DP
        .CASE 2
            MOV #120Dh,0(W)        ; compile PUSH IP
COLON1      MOV #DOCOL,2(W)        ; compile CALL R4 = rDOCOL
            ADD #4,&DP
        .CASE 3 ; inlined DOCOL
            MOV #120Dh,0(W)        ; compile PUSH IP
COLON1      MOV #400Dh,2(W)        ; compile MOV PC,IP
            MOV #522Dh,4(W)         ; compile ADD #4,IP
            MOV #4D30h,6(W)         ; compile MOV @IP+,PC
            ADD #8,&DP              ;
        .ENDCASE ; DTC
COLON2      MOV #-1,&STATE          ; enter in compile state
            JMP PREVIOUS            ; to restore CONTEXT

; LO2HI --       same as COLON but without saving IP
            asmword "LO2HI"
        .SWITCH DTC
        .CASE 1                     ; compile 2 words
            MOV &DP,W
            MOV #12B0h,0(W)         ; compile CALL #EXIT, 2 words  4+6=10~
            MOV #EXIT,2(W)
            ADD #4,&DP
            JMP COLON2
        .ELSECASE                   ; CASE 2 : compile 1 word, CASE 3 : compile 3 words
            SUB #2,&DP              ; to skip PUSH IP
            MOV &DP,W
            JMP COLON1
        .ENDCASE

; HI2LO --       immediate, switch to low level, set interpretation state, add ASSEMBLER to CONTEXT
            FORTHWORDIMM "HI2LO"    ;
            ADD #2,&DP              ; HERE+2
            MOV &DP,W               ; W = HERE+2
            MOV W,-2(W)             ; compile HERE+2 to HERE
            MOV #0,&STATE           ; LEFTBRACKET
            JMP hidden              ; to add ASSEMBLER in context stack

;-------------------------------------------------------------------------------
; FASTFORTH environment management: RST_SET RST_RET MARKER
;-------------------------------------------------------------------------------
ENV_COPY                            ; mini MOVE T words from X to W
    .IFDEF VOCABULARY_SET
            MOV #12,T               ; words count for extended environment: DP,LASTVOC,CURRENT,CONTEXT(8),NULL_WORD
    .ELSE
            MOV #4,T                ; words count for basic environment: DP,LASTVOC,CURRENT,CONTEXT
    .ENDIF
MOV_WORDS   MOV @X+,0(W)            ; 4 X = src, W = dst, T = words count
            ADD #2,W                ; 1
            SUB #1,T                ; 1 words count -1
            JNZ MOV_WORDS           ; 2
            MOV @RSP+,PC

            FORTHWORD "RST_SET"     ; define actual environment as new RESET environment
RST_SET     MOV #DP,X               ; org = RAM value (DP first)
            MOV #RST_DP,W           ; dst = FRAM value (RST_DP first), see \inc\ThingsInFirst.inc
            CALL #ENV_COPY          ; copy environment RAM --> FRAM RST, use T,W,X
            MOV @IP+,PC

            FORTHWORD "RST_RET"     ; init / return_to_previous RESET or MARKER environment
RST_RET     MOV #RST_DP,X           ; org = FRAM value (first RST_DP), see \inc\ThingsInFirst.inc
            MOV #DP,W               ; dst = RAM value (first DP)
            MOV @X,S                ; S = restored DP, used below for comparaison with NFAs below
            CALL #ENV_COPY          ; copy environment FRAM RST --> RAM, use T,W,X
            MOV &LASTVOC,W          ; W = init/restored LASTVOC in RAM
    .SWITCH THREADS                 ; init/restore THREAD(s) with NFAs value < DP value, for all word set
    .CASE   1 ; mono thread word-set
MARKALLVOC  MOV W,Y                 ; W=VLK   Y = VLK
MRKWORDLOOP MOV -2(Y),Y             ; W=VLK   Y = [THD] then [LFA] = NFA
            CMP Y,S                 ; Y=NFA   S=DP        CMP = S-Y : OLD_DP-NFA
            JNC MRKWORDLOOP         ; loop back if S<Y : OLD_DP<NFA
            MOV Y,-2(W)             ; W=VLK   X=THD   Y=NFA   refresh thread with good NFA
    .ELSECASE ; multi threads word-set
MARKALLVOC  MOV #THREADS,T          ; S=DP     T=ThdCnt (Threads Count), VLK = THD_n+1
            MOV W,X                 ; W = VLK   X = VLK then THD_n (VOCLINK first, then THREADn)
MRKTHRDLOOP MOV X,Y                 ;
            SUB #2,X                ;
MRKWORDLOOP MOV -2(Y),Y             ; Y = NFA = [THD_n] then [LFA]
            CMP Y,S                 ; Y = NFA   S=DP       CMP = S-Y : DP-NFA
            JNC MRKWORDLOOP         ;           loop back if S<Y : DP<NFA (if not_carry = if borrow)
MARKTHREAD  MOV Y,0(X)              ; Y=NFA     X=THD_n   refresh thread with good NFA
            SUB #1,T                ; T=ThdCnt-1
            JNZ MRKTHRDLOOP         ;           loopback to process NFA of next thread (thread-1)
    .ENDCASE ; of THREADS           ;
            MOV @W,W                ; W=[VLK] = VLK-1
            CMP #0,W                ;                   end of vocs ?
            JNZ MARKALLVOC          ; W=VLK-1           no : loopback
            MOV @IP+,PC             ;

; https://forth-standard.org/standard/core/MARKER
; MARKER
;name Execution: ( -- )
;Restore all dictionary allocation and search order pointers to the state they had just prior to the
;definition of name. Remove the definition of name and all subsequent definitions. Restoration
;of any structures still existing that could refer to deleted definitions or deallocated data space is
;not necessarily provided. No other contextual information such as numeric base is affected.
; the FORTH environment is it automaticaly restored.
; FastForth provides all that is necessary for a real time application,
; by adding a call to a custom asm subroutine to restore all user environment.

MARKER_DOES                         ; execution part of MARKER definition
            mNEXTADR                ; -- BODY
    .IFDEF VOCABULARY_SET
            MOV TOS,X               ;                       X = org (first : BODY = MARKER_DP)
            MOV #RST_DP,W           ;                       W = dst (first : RST_DP), see \inc\ThingsInFirst.inc
            CALL #ENV_COPY          ;                       restore previous FORTH environment from FRAM MARKER to FRAM RST
            MOV X,TOS               ; -- USER_DOES          RET_ADR by default
    .ELSE
            MOV @TOS+,&RST_DP       ; -- USER_DOES          only RST_DP is restored
    .ENDIF
            CALL @TOS+              ; -- USER_PARAM         executes defined USER_DOES subroutine (RET_ADR by default),
                                    ;                       IP is free, TOS is the address of first USER parameter 
            MOV @PSP+,TOS           ; --
            MOV @RSP+,IP            ;
            JMP RST_RET             ;                       which restores previous FORTH environment in RAM

            FORTHWORD "MARKER"      ; definition part
;( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a definition for name
;with the execution semantics defined above.
;-------------------------------------------------------------------------------
; before that, if already defined, "name" executes its MARKER_DOES part.
; i.e. does: [DEFINED] <name> [IF] <name> [THEN]
;            MARKER <name>
;-------------------------------------------------------------------------------
            PUSH &TOIN              ; --                save >IN
            mDOCOL
            .word BL_WORD,FIND      ; -- addr flag
            .word QFBRAN,MARKER_NEXT; -- addr           if not found
            .word DUP,EXECUTE       ;                   execute it
MARKER_NEXT mNEXTADR                ; -- addr
            MOV @PSP+,TOS           ; --
            MOV @RSP+,IP            ;
            MOV @RSP+,&TOIN         ;                   restore >IN for HEADER
;-------------------------------------------------------------------------------
            CALL #HEADER            ;4                  W = BODY, Y = NFA,
            MOV #1285h,-4(W)        ;4                  CFA = CALL rDODOES
            MOV #MARKER_DOES,-2(W)  ;4                  PFA = MARKER_DOES
            SUB #2,Y                ;1                  Y = NFA-2 = LFA = DP to be restored, W = FRAM MARKER_DDP
    .IFDEF VOCABULARY_SET
            MOV Y,&DP               ;                   Y = previous DP (just before MARKER definition)
            MOV #DP,X               ;                   X = org = RAM DP, W = dst = MARKER_BODY
            CALL #ENV_COPY          ;                   copy environment RAM --> FRAM MARKER
            MOV #RET_ADR,0(W)       ;4                  USER_DOES default subroutine = RET_ADR
            ADD #2,W                ;1
            MOV W,&DP               ;4                  set new RAM DP (after the end of MARKER definition)
    .ELSE
            MOV Y,0(W)              ;                   DP to be restored
            MOV #RET_ADR,2(W)       ;                   USER_DOES default subroutine = RET_ADR
            ADD #4,&DP              ;
    .ENDIF
            JMP LINK_NFA            ;                   then NEXT

;-------------------------------------------------------------------------------
; PUC 7 : SELECT RST_RET|DEEP_RESET <== INIT_FORTH <== (PUC,SYS,QABORT)
;-------------------------------------------------------------------------------
SEL_RST     CMP #0,TOS              ;
            JGE RST_RET             ; RST_RET if TOS >= 0
;-----------------------------------;
; DEEP RESET                        ; DEEP_RESET if TOS < 0
;-----------------------------------;
; DEEP INIT SIGNATURES AREA         ;
;-----------------------------------;
            MOV #16,X               ; max known SIGNATURES length = 12 bytes
SIGNATLOOP  SUB #2,X                ;
            MOV #-1,SIGNATURES(X)   ; reset signatures; WARNING ! DON'T CHANGE IMMEDIATE VALUE !
            JNZ SIGNATLOOP          ;
;-----------------------------------;
; DEEP INIT VECTORS INT             ; X = 0 ;-)
;-----------------------------------;
            MOV #RESET,-2(X)        ; write RESET at addr X-2 = FFFEh
INIVECLOOP  SUB #2,X                ;
            MOV #COLD,-2(X)         ; -2(X) = FFFCh first
            CMP #0FFACh+2,X         ; init 41 vectors, FFFCh down to 0FFACh
            JNZ INIVECLOOP          ; all vectors are initialised to execute COLD routine
;-----------------------------------;
; DEEP INIT Terminal Int vector     ;
;-----------------------------------;
            MOV #DEEP_ORG,X         ; DEEP_ORG values are in FRAM INFO, see \inc\ThingsInFirst.inc
            MOV @X+,&TERM_VEC       ; TERMINAL_INT           as default vector       --> FRAM TERM_VEC
;-----------------------------------;
; DEEP INIT FRAM RST values         ; {COLD,ABORT,SOFT,HARD,BACKGRND}_APP + RST_{DP,LASTVOC,CURRENT,CONTEXT,0}
;-----------------------------------;
            MOV #RST_LEN/2,T        ; T = words count
            MOV #RST_ORG,W          ; W = dst, X = org
            CALL #MOV_WORDS         ;
;-----------------------------------;
    .IFDEF SD_CARD_LOADER           ; does NOBOOT:
            MOV #WARM,&PUCNEXT      ; removes XBOOT from PUC chain.
    .ENDIF
;-----------------------------------;
; WARM INIT threads of all word set ;
;-----------------------------------;
            JMP RST_RET             ; then go to DUP|PUCNEXT,  resp. in QABORT|RESET
;-----------------------------------;

    .IFDEF LARGE_DATA
        .include "forthMSP430FR_EXTD_ASM.asm"
    .ELSE
        .include "forthMSP430FR_ASM.asm"
    .ENDIF

    .IFDEF SD_CARD_LOADER
;===============================================================================
; SD CARD KERNEL OPTIONS
;===============================================================================
        .include "forthMSP430FR_SD_LowLvl.asm"  ; SD primitives
        .include "forthMSP430FR_SD_INIT.asm"    ; return to INIT_TERM; without use of IP,TOS
        .include "forthMSP430FR_SD_LOAD.asm"    ; SD LOAD driver
        .IFDEF SD_CARD_READ_WRITE
            .include "forthMSP430FR_SD_RW.asm"  ; SD Read/Write driver
        .ENDIF
    .ENDIF

;===============================================================================
; ADDONS OPTIONS; if included here they will be protected against Deep_RST
;===============================================================================
    .IFDEF CORE_COMPLEMENT
;-------------------------------------------------------------------------------
; COMPLEMENT of definitions to pass ANS94 CORETEST
;-------------------------------------------------------------------------------
        .include "ADDON/CORE_ANS.asm"
    .ENDIF

    .IFDEF UTILITY
;-------------------------------------------------------------------------------
; UTILITY WORDS
;-------------------------------------------------------------------------------
        .include "ADDON/UTILITY.asm"
    .ENDIF

    .IFDEF FIXPOINT
;-------------------------------------------------------------------------------
; FIXED POINT OPERATORS
;-------------------------------------------------------------------------------
        .include "ADDON/FIXPOINT.asm"
    .ENDIF

    .IFDEF DOUBLE
;-------------------------------------------------------------------------------
; DOUBLE word set
;-------------------------------------------------------------------------------
        .include "ADDON/DOUBLE.asm"
    .ENDIF

    .IFDEF SD_CARD_LOADER
        .IFDEF SD_TOOLS
;-------------------------------------------------------------------------------
; BASIC SD TOOLS
;-------------------------------------------------------------------------------
            .include "ADDON/SD_TOOLS.asm"
        .ENDIF
    .ENDIF

;-------------------------------------------------------------------------------
; ADD HERE YOUR CODE TO BE INTEGRATED IN KERNEL and protected against Deep_RST
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
;           .include "YOUR_CODE.asm"
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; ADD HERE YOUR CODE TO BE INTEGRATED IN KERNEL (protected against Deep_RST)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; RESOLVE ASSEMBLY pointers, init interrupt Vectors
;-------------------------------------------------------------------------------
    .include "ThingsInLast.inc"
