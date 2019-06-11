

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
        MOV TOS,S       ;1 S = u2
        MOV @PSP+,Y     ;2 Y = addr2
        MOV @PSP+,T     ;2 T = u1     
        MOV @PSP+,X     ;2 X = addr1
COMPAR1 MOV T,TOS       ;1
        ADD S,TOS       ;1 TOS = u1+u2
        JZ  COMPEQUAL   ;2 u1=u2=0: end of all successfull comparisons
        SUB #1,T        ;1
        JN COMPLESS     ;2 u1<u2 if u1 < 0
        SUB #1,S        ;1
        JN COMPGREATER  ;2 u1>u2 if u2 < 0
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

;;[ELSE]
;;https://forth-standard.org/standard/tools/BracketELSE
;;Compilation:
;;Perform the execution semantics given below.
;;Execution:
;;( "<spaces>name ..." -- )
;;Skipping leading spaces, parse and discard space-delimited words from the parse area, 
;;including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], 
;;until the word [THEN] has been parsed and discarded. 
;;If the parse area becomes exhausted, it is refilled as with REFILL. 
;        FORTHWORDIMM  "[ELSE]"
;BRACKETELSE
;        mDOCOL
;        .word   lit,1                   ;   1
;BRACKETELSE1                            ;   BEGIN
;BRACKETELSE2                            ;       BEGIN
;        .word   FBLANK,WORDD,COUNT      ;           BL WORD COUNT
;        .word   DUP                     ;           DUP
;        .word   QFBRAN,BRACKETELSE10     ;       WHILE
;        .word   OVER,OVER               ;           2DUP 
;        .word   XSQUOTE                 ;           S" [IF]"
;        .byte   4,"[IF]"                ; 
;        .word   COMPARE                 ;           COMPARE
;        .word   QTBRAN,BRACKETELSE3     ;           0= IF
;        .word   TWODROP,ONEPLUS         ;               2DROP 1+
;        .word   BRAN,BRACKETELSE8       ;           (ENDIF)
;BRACKETELSE3                            ;           ELSE
;        .word   OVER,OVER               ;               2DUP
;        .word   XSQUOTE                 ;               S" [ELSE]"
;        .byte   6,"[ELSE]"              ; 
;        .word   COMPARE                 ;               COMPARE
;        .word   QTBRAN,BRACKETELSE5     ;               0= IF
;        .word   TWODROP,ONEMINUS        ;                   2DROP 1-
;        .word   DUP,QFBRAN,BRACKETELSE4  ;                  DUP IF
;        .word   ONEPLUS                 ;                       1+
;BRACKETELSE4                            ;                   THEN
;        .word   BRAN,BRACKETELSE7       ;               (ENDIF)
;BRACKETELSE5                            ;               ELSE
;        .word   XSQUOTE                 ;                   S" [THEN]"
;        .byte   6,"[THEN]"              ; 
;        .word   COMPARE                 ;                   COMPARE
;        .word   QTBRAN,BRACKETELSE6     ;                   0= IF
;        .word   ONEMINUS                ;                       1-
;BRACKETELSE6                            ;                   THEN
;BRACKETELSE7                            ;               THEN
;BRACKETELSE8                            ;           THEN
;        .word   QDUP                    ;           ?DUP
;        .word   QTBRAN,BRACKETELSE9     ;           0= IF
;        .word   EXIT                    ;               EXIT
;BRACKETELSE9                            ;           THEN
;        .word   BRAN,BRACKETELSE2       ;       REPEAT
;BRACKETELSE10                           ;
;        .word   TWODROP                 ;       2DROP
;        .word   XSQUOTE                 ;
;        .byte   5,13,10,"ko "           ;
;        .word   TYPE                    ;       CR+LF ." ko "     to show false branch of conditionnal compilation
;        .word   REFILL                  ;       REFILL
;        .word   SETIB                   ;               SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
;        .word   BRAN,BRACKETELSE1       ;   AGAIN  65 words

;
;[ELSE]      a few (smaller and faster) definition
;https://forth-standard.org/standard/tools/BracketELSE
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- )
;Skipping leading spaces, parse and discard space-delimited words from the parse area, 
;including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], 
;until the word [THEN] has been parsed and discarded. 
;If the parse area becomes exhausted, it is refilled as with REFILL. 
        FORTHWORDIMM  "[ELSE]"          ; or [IF] isnogood...
BRACKETELSE
        mDOCOL
        .word   lit,0                   
BRACKETELSE0
        .word   ONEPLUS                 ; 
BRACKETELSE1                            ;
        .word   FBLANK,WORDD,COUNT      ;
        .word   DUP,QFBRAN,BRACKETELSE5 ; if end of line refill buffer then loop back
        .word   TWODUP                  ;
        .word   XSQUOTE                 ;
        .byte   6,"[THEN]"              ;
        .word   COMPARE                 ;
        .word   QTBRAN,BRACKETELSE2     ; if bad comparaison, jump for next comparaison
        .word   TWODROP,ONEMINUS        ; 2DROP, decrement count
        .word   QDUP,QTBRAN,BRACKETELSE1; loop back if count <> 0
        .word   EXIT                    ; else exit
BRACKETELSE2                            ;
        .word   TWODUP                  ;
        .word   XSQUOTE                 ;
        .byte   6,"[ELSE]"              ;
        .word   COMPARE                 ;
        .word   QTBRAN,BRACKETELSE3     ; if bad comparaison, jump for next comparaison
        .word   TWODROP,ONEMINUS        ; 2DROP, decrement count
        .word   QDUP,QTBRAN,BRACKETELSE0; if count <> 0 restore old count with loop back increment
        .word   EXIT                    ; else exit
BRACKETELSE3                            ;
        .word   XSQUOTE                 ;
        .byte   4,"[IF]"                ;
        .word   COMPARE                 ;
        .word   QTBRAN,BRACKETELSE1     ; if bad comparaison, loop back
        .word   BRAN,BRACKETELSE0       ; else increment loop back
BRACKETELSE5                            ;
        .word   TWODROP                 ;
        .word   XSQUOTE                 ;
        .byte   5,13,10,"ko "           ;
        .word   TYPE                    ; CR+LF ." ko "     to show false branch of conditionnal compilation
        .word   REFILL                  ; REFILL Input Buffer
        .word   SETIB                   ; SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
        .word   BRAN,BRACKETELSE1       ; then loop back   58 words


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
BRACKETIF
        CMP #0,TOS
        MOV @PSP+,TOS
        JZ BRACKETELSE
        mNEXT

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
            MOV     #RST_STATE,PC       ;       execute RST_STATE, PWR_STATE then STATE_DOES

            FORTHWORD "MARKER"          ; definition part
            CALL    #HEADER             ;4 W = DP+4
            MOV     #DODOES,-4(W)       ;4 CFA = DODOES
            MOV     #MARKER_DOES,-2(W)  ;4 PFA = MARKER_DOES
            MOV     &LASTVOC,0(W)       ;5 [BODY] = VOCLINK to be restored
            SUB     #2,Y                ;1 Y = LFA
            MOV     Y,2(W)              ;3 [BODY+2] = LFA = DP to be restored
            ADD     #4,&DDP             ;3
            MOV     #GOOD_CSP,PC
