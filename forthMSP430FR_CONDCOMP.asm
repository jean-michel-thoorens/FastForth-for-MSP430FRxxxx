

; https://forth-standard.org/standard/tools/BracketTHEN
; [THEN]
        FORTHWORDIMM "[THEN]"   ; do nothing
        MOV @IP+,PC

; ; https://forth-standard.org/standard/string/COMPARE
; ; COMPARE ( c-addr1 u1 c-addr2 u2 -- n )
; ;Compare the string specified by c-addr1 u1 to the string specified by c-addr2 u2. 
; ;The strings are compared, beginning at the given addresses, character by character, 
; ;up to the length of the shorter string or until a difference is found. 
; ;If the two strings are identical, n is zero. 
; ;If the two strings are identical up to the length of the shorter string, 
; ;   n is minus-one (-1) if u1 is less than u2 and one (1) otherwise. 
; ;If the two strings are not identical up to the length of the shorter string, 
; ;   n is minus-one (-1) if the first non-matching character in the string specified by c-addr1 u1 
; ;   has a lesser numeric value than the corresponding character in the string specified by c-addr2 u2 and one (1) otherwise.
;         FORTHWORD "COMPARE"
; COMPARE
;         MOV TOS,S       ;1 S = u2
;         MOV @PSP+,Y     ;2 Y = addr2
;         MOV @PSP+,T     ;2 T = u1     
;         MOV @PSP+,X     ;2 X = addr1
; COMPAR1 MOV T,TOS       ;1
;         ADD S,TOS       ;1 TOS = u1+u2
;         JZ  COMPEQUAL   ;2 u1=u2=0, Z=1,  end of all successfull comparisons
;         SUB #1,T        ;1
;         JN COMPLESS     ;2 u1<u2 if u1 < 0
;         SUB #1,S        ;1
;         JN COMPGREATER  ;2 u1>u2 if u2 < 0
;         ADD #1,X        ;1 
;         CMP.B @Y+,-1(X) ;4 char1-char2
;         JZ COMPAR1      ;2 char1=char2  17~ loop
;         JC  COMPGREATER ;2 char1>char2
; COMPLESS                ;  char1<char2
;         MOV #-1,TOS     ;1 Z=0
;         MOV @IP+,PC     ;4
; COMPGREATER
;         MOV #1,TOS      ;1 Z=0
; COMPEQUAL
;         MOV @IP+,PC     ;4     20 + 5 words def'n

; ; https://forth-standard.org/standard/tools/BracketELSE
; ; [ELSE]      a few (smaller and faster) definition
; ;Compilation:
; ;Perform the execution semantics given below.
; ;Execution:
; ;( "<spaces>name ..." -- )
; ;Skipping leading spaces, parse and discard space-delimited words from the parse area, 
; ;including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], 
; ;until the word [THEN] has been parsed and discarded. 
; ;If the parse area becomes exhausted, it is refilled as with REFILL. 
;         FORTHWORDIMM  "[ELSE]"          ; or [IF] if isnogood...
; BRACKETELSE
;         mDOCOL
;         .word   lit,0                   
; BRACKETELSE0
;         .word   ONEPLUS                 ; 
; BRACKETELSE1                            ;
;         .word   FBLANK,WORDD,COUNT      ; -- addr u
;         .word   DUP,QFBRAN,BRACKETELSE5 ;       u = 0 if end of line --> refill buffer then loop back
;         .word   TWODUP                  ;
;         .word   XSQUOTE                 ;
;         .byte   6,"[THEN]"              ;
;         .word   COMPARE                 ;
;         .word   QTBRAN,BRACKETELSE2     ; if bad comparaison, jump for next comparaison
;         .word   TWODROP,ONEMINUS        ; 2DROP, decrement count
;         .word   QDUP,QTBRAN,BRACKETELSE1; loop back if count <> 0
;         .word   EXIT                    ; else exit
; BRACKETELSE2                            ;
;         .word   TWODUP                  ;
;         .word   XSQUOTE                 ;
;         .byte   6,"[ELSE]"              ;
;         .word   COMPARE                 ;
;         .word   QTBRAN,BRACKETELSE3     ; if bad comparaison, jump for next comparaison
;         .word   TWODROP,ONEMINUS        ; 2DROP, decrement count
;         .word   QDUP,QTBRAN,BRACKETELSE0; if count <> 0 restore old count with loop back increment
;         .word   EXIT                    ; else exit
; BRACKETELSE3                            ;
;         .word   XSQUOTE                 ;
;         .byte   4,"[IF]"                ;
;         .word   COMPARE                 ;
;         .word   QTBRAN,BRACKETELSE1     ; if bad comparaison, loop back
;         .word   BRAN,BRACKETELSE0       ; else increment loop back
; BRACKETELSE5                            ;
;         .word   TWODROP                 ;
; ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
; ; OPTION                                ; plus 5 words option
; ;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
;         .word   XSQUOTE                 ;
;         .byte   5,13,10,"ko "           ;
;         .word   TYPE                    ; CR+LF ." ko "     to show false branch of conditionnal compilation
; ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
;         .word   REFILL                  ; REFILL Input Buffer with next line
;         .word   SETIB                   ; SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
;         .word   BRAN,BRACKETELSE1       ; then loop back   54 words without options

BADCOMPBR               ; branch if string compare is false; [COMPARE,QTBRAN] replacement
        MOV TOS,S       ;1 S = u2
        MOV @PSP+,Y     ;2 Y = addr2
        MOV @PSP+,T     ;2 T = u1     
        MOV @PSP+,X     ;2 X = addr1
COMPAR1 MOV T,TOS       ;1
        ADD S,TOS       ;1 TOS = u1+u2
        JZ  COMPEQU     ;2 u1=u2=0, Z=1,  end of all successfull comparisons
        SUB #1,T        ;1
        JN COMPDIF      ;2 u1<u2 if u1 < 0
        SUB #1,S        ;1
        JN COMPDIF      ;2 u1>u2 if u2 < 0
        ADD #1,X        ;1 
        CMP.B @Y+,-1(X) ;4 char1-char2
        JZ COMPAR1      ;2 char1=char2  17~ loop
COMPDIF MOV @IP,IP      ; take branch
CMPEND  MOV @PSP+,TOS
        MOV @IP+,PC     ;4

TOQTB                   ; [TWODROP,ONEMINUS,?DUP,QTBRAN] replacement
        ADD #2,PSP      ;1   -- savedTOS TOS
        SUB #1,0(PSP)   ;3   -- savedTOS-1 TOS
        JNZ COMPDIF     ;2   -- cnt     take branch
        ADD #2,PSP      ;1   --
COMPEQU ADD #2,IP       ;               skip branch
        JMP CMPEND      ; 25 words

; https://forth-standard.org/standard/tools/BracketELSE
; [ELSE]      a few (smaller and faster) definition
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- )
;Skipping leading spaces, parse and discard space-delimited words from the parse area, 
;including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], 
;until the word [THEN] has been parsed and discarded. 
;If the parse area becomes exhausted, it is refilled as with REFILL. 
        FORTHWORDIMM  "[ELSE]"          ; or [IF] if isnogood...
BRACKETELSE
        mDOCOL
        .word   lit,0                   
BRACKETELSE0
        .word   ONEPLUS                 ; 
BRACKETELSE1                            ;
        .word   FBLANK,WORDD,COUNT      ; -- addr u
        .word   DUP,QFBRAN,BRACKETELSE5 ;       u = 0 if end of line --> refill buffer then loop back
        .word   TWODUP                  ;
        .word   XSQUOTE                 ;
        .byte   6,"[THEN]"              ;
        .word   BADCOMPBR,BRACKETELSE2  ; if bad string comparaison, jump for next comparaison
        .word   TOQTB,BRACKETELSE1      ; 2DROP,  count-1, loop back if count <> 0, else DROP
        .word   EXIT                    ; then exit
BRACKETELSE2                            ;
        .word   TWODUP                  ;
        .word   XSQUOTE                 ;
        .byte   6,"[ELSE]"              ;
        .word   BADCOMPBR,BRACKETELSE3  ; if bad string comparaison, jump for next comparaison
        .word   TOQTB,BRACKETELSE0      ; 2DROP, count-1, loop back with count+1 if count <> 0, else DROP
        .word   EXIT                    ; then exit
BRACKETELSE3                            ;
        .word   XSQUOTE                 ;
        .byte   4,"[IF]"                ;
        .word   BADCOMPBR,BRACKETELSE1  ; if bad string comparaison, loop back
        .word   BRAN,BRACKETELSE0       ; else loop back with count+1
BRACKETELSE5                            ;
        .word   TWODROP                 ;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
; OPTION                                ; plus 5 words option
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
        .word   XSQUOTE                 ;
        .byte   5,13,10,"ko "           ;
        .word   TYPE                    ; CR+LF ." ko "     to show false branch of conditionnal compilation
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
        .word   REFILL                  ; REFILL Input Buffer with next line
        .word   SETIB                   ; SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
        .word   BRAN,BRACKETELSE1       ; then loop back   44 words without options

; https://forth-standard.org/standard/tools/BracketIF
; [IF]
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
        MOV @IP+,PC

; https://forth-standard.org/standard/core/NIP
; NIP      x1 x2 -- x2         Drop the first item below the top of stack
    .IFNDEF NIP
NIP         ADD #2,PSP      ; 1
            MOV @IP+,PC     ; 4
    .ENDIF

; https://forth-standard.org/standard/tools/BracketDEFINED
; [DEFINED]
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space. 
;Return a true flag if name is the name of a word that can be found,
;otherwise return a false flag. [DEFINED] is an immediate word.

        FORTHWORDIMM  "[DEFINED]"
DEFINED mDOCOL
        .word   FBLANK,WORDD,FIND,NIP,EXIT

; https://forth-standard.org/standard/tools/BracketUNDEFINED
; [UNDEFINED]
;Compilation:
;Perform the execution semantics given below.
;Execution: ( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space. 
;Return a false flag if name is the name of a word that can be found,
;otherwise return a true flag.
        FORTHWORDIMM  "[UNDEFINED]"
        mDOCOL
        .word   DEFINED
        .word   $+2
        MOV @RSP+,IP
        MOV #ZEROEQUAL,PC
