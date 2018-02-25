

    .IFNDEF LOWERCASE
    .WARNING "uncomment LOWERCASE ADD-ON to pass coretest COMPARE !"
    .ENDIF ; LOWERCASE

;COMPARE ( c-addr1 u1 c-addr2 u2 -- n )
;https://forth-standard.org/standard/string/COMPARE
;Compare the string specified by c-addr1 u1 to the string specified by c-addr2 u2. 
;The strings are compared, beginning at the given addresses, character by character, 
;up to the length of the shorter string or until a difference is found. 
;If the two strings are identical, n is zero. 
;If the two strings are identical up to the length of the shorter string, 
;   n is minus-one (-1) if u1 is less than u2 and one (1) otherwise. 
;If the two strings are not identical up to the length of the shorter string, 
;   n is minus-one (-1) if the first non-matching character in the string specified by c-addr1 u1 
;   has a lesser numeric value than the corresponding character in the string specified by c-addr2 u2 and one (1) otherwise.
        FORTHWORD "COMPARE"
COMPARE
        MOV TOS,S       ;1 u2 = S
        MOV @PSP+,Y     ;2 addr2 = Y
        MOV @PSP+,T     ;2 u1 = T     
        MOV @PSP+,X     ;2 addr1 = X
COMPAR1 MOV T,TOS       ;1
        ADD S,TOS       ;1
        JZ  COMPEQUAL   ;2 end of all successfull comparisons
        SUB #1,T        ;1
        JN COMPLESS     ;2 u1<u2
        SUB #1,S        ;1
        JN COMPGREATER  ;2 u2<u1
        ADD #1,X        ;1
        CMP.B @Y+,-1(X) ;4 char1-char2
        JZ COMPAR1      ;2 char1=char2  17~ loop
        JHS COMPGREATER ;2 char1>char2
COMPLESS                ;  char1<char2
        MOV #-1,TOS     ;1
        MOV @IP+,PC     ;4
COMPGREATER
        MOV #1,TOS      ;1
COMPEQUAL
        MOV @IP+,PC     ;4     20 words

;[THEN]
;https://forth-standard.org/standard/tools/BracketTHEN
        FORTHWORDIMM "[THEN]"   ; do nothing
        mNEXT

ONEMIN
        SUB #1,TOS
        mNEXT

;[ELSE]
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- )
;Skipping leading spaces, parse and discard space-delimited words from the parse area, 
;including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], 
;until the word [THEN] has been parsed and discarded. 
;If the parse area becomes exhausted, it is refilled as with REFILL. 
        FORTHWORDIMM  "[ELSE]"
BRACKETELSE
        mDOCOL
        .word   lit,1                   ;   1
BRACKETELSE1                            ;   BEGIN
BRACKETELSE2                            ;       BEGIN
        .word   FBLANK,WORDD,COUNT      ;           BL WORD COUNT 
        .word   DUP,QBRAN,BRACKETELSE10 ;       DUP WHILE
        .word   OVER,OVER               ;           2DUP 
        .word   XSQUOTE                 ;           S" [IF]"
        .byte   4,"[IF]"                ; 
        .word   COMPARE                 ;           COMPARE
        .word   QZBRAN,BRACKETELSE3     ;           0= IF
        .word   TWODROP,ONEPLUS         ;               2DROP 1+
        .word   BRAN,BRACKETELSE8       ;           (ENDIF)
BRACKETELSE3                            ;           ELSE
        .word   OVER,OVER               ;               OVER OVER
        .word   XSQUOTE                 ;               S" [ELSE]"
        .byte   6,"[ELSE]"              ; 
        .word   COMPARE                 ;               COMPARE
        .word   QZBRAN,BRACKETELSE5     ;               0= IF
        .word   TWODROP,ONEMIN          ;                   2DROP 1-
        .word   DUP,QBRAN,BRACKETELSE4  ;                   DUP IF
        .word   ONEPLUS                 ;                       1+
BRACKETELSE4                            ;                   THEN
        .word   BRAN,BRACKETELSE7       ;               (ENDIF)
BRACKETELSE5                            ;               ELSE
        .word   XSQUOTE                 ;                   S" [THEN]"
        .byte   6,"[THEN]"              ; 
        .word   COMPARE                 ;                   COMPARE
        .word   QZBRAN,BRACKETELSE6     ;                   0= IF
        .word   ONEMIN                  ;                       1-
BRACKETELSE6                            ;                   THEN
BRACKETELSE7                            ;               THEN
BRACKETELSE8                            ;           THEN
        .word   QDUP                    ;           ?DUP
        .word   QZBRAN,BRACKETELSE9     ;           0= IF
        .word   EXIT                    ;               EXIT
BRACKETELSE9                            ;           THEN
        .word   BRAN,BRACKETELSE2       ;       REPEAT
BRACKETELSE10                           ;
        .word   TWODROP                 ;       2DROP
        .word   XSQUOTE                 ;
;        .byte   3,13,107,111            ;
;        .word   TYPE,SPACE              ;       CR ." ko "     to show false branch of conditionnal compilation
        .byte   5,13,10,"ko "           ;
        .word   TYPE                    ;       CR+LF ." ko "     to show false branch of conditionnal compilation
        .word   FCIB,DUP,CPL            ;                   )  
                                        ;                   > REFILL
        .word   ACCEPT                  ;       -- CIB len  )
        FORTHtoASM                      ;
        MOV     #0,&TOIN                ;
        MOV     TOS,&SOURCE_LEN         ;       -- CIB len
        MOV     @PSP+,&SOURCE_ADR       ;       -- len' 
        MOV     @PSP+,TOS               ;       --
        MOV     #BRACKETELSE1,IP        ;   AGAIN
        mNEXT                           ; 78 words


;[IF]
;https://forth-standard.org/standard/tools/BracketIF
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
        FORTHWORDIMM "[IF]" ; flag -- 
        CMP #0,TOS
        MOV @PSP+,TOS
        JZ BRACKETELSE
        mNEXT

;[UNDEFINED]
;https://forth-standard.org/standard/tools/BracketUNDEFINED
;Compilation:
;Perform the execution semantics given below.
;Execution: ( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space. 
;Return a false flag if name is the name of a word that can be found,
;otherwise return a true flag.
        FORTHWORDIMM  "[UNDEFINED]"
        mDOCOL
        .word   FBLANK,WORDD,FIND,NIP,ZEROEQUAL,EXIT

;[DEFINED]
;https://forth-standard.org/standard/tools/BracketDEFINED
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space. 
;Return a true flag if name is the name of a word that can be found,
;otherwise return a false flag. [DEFINED] is an immediate word.

        FORTHWORDIMM  "[DEFINED]"
        mDOCOL
        .word   FBLANK,WORDD,FIND,NIP,EXIT

;; CORE EXT  MARKER
;;https://forth-standard.org/standard/core/MARKER
;;( "<spaces>name" -- )
;;Skip leading space delimiters. Parse name delimited by a space. Create a definition for name
;;with the execution semantics defined below.

;;name Execution: ( -- )
;;Restore all dictionary allocation and search order pointers to the state they had just prior to the
;;definition of name. Remove the definition of name and all subsequent definitions. Restoration
;;of any structures still existing that could refer to deleted definitions or deallocated data space is
;;not necessarily provided. No other contextual information such as numeric base is affected

MARKER_DOES FORTHtoASM                  ; execution part
            MOV     @RSP+,IP            ; -- PFA
            MOV     @TOS+,&INIVOC       ;       set VOC_LINK value for RST_STATE
            MOV     @TOS,&INIDP         ;       set DP value for RST_STATE
            MOV     @PSP+,TOS           ; --
            JMP     RST_STATE           ;       execute RST_STATE, PWR_STATE then STATE_DOES

            FORTHWORD "MARKER"          ; definition part
            CALL    #HEADER             ;4 W = DP+4
            MOV     #DODOES,-4(W)       ;4 CFA = DODOES
            MOV     #MARKER_DOES,-2(W)  ;4 PFA = MARKER_DOES
            MOV     &LASTVOC,0(W)       ;5 [BODY] = VOCLINK to be restored
            SUB     #2,Y                ;1 Y = LFA
            MOV     Y,2(W)              ;3 [BODY+2] = LFA = DP to be restored
            ADD     #4,&DDP             ;3

