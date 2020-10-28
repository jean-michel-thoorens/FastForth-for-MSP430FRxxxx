; -*- coding: utf-8 -*-
;
            FORTHWORDIMM "[THEN]"   ; do nothing
; https://forth-standard.org/standard/tools/BracketTHEN
; [THEN]
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
; COMPLOOP MOV T,TOS       ;1
;         ADD S,TOS       ;1 TOS = u1+u2
;         JZ  COMPEQUAL   ;2 u1=u2=0, Z=1,  end of all successfull comparisons
;         SUB #1,T        ;1
;         JN COMPLESS     ;2 u1<u2 if u1 < 0
;         SUB #1,S        ;1
;         JN COMPGREATER  ;2 u1>u2 if u2 < 0
;         ADD #1,X        ;1 
;         CMP.B @Y+,-1(X) ;4 char1-char2
;         JZ COMPLOOP      ;2 char1=char2  17~ loop
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
;         .word   lit,0                   ; -- cnt=0
; BRACKETELSE0
;         .word   ONEPLUS                 ; -- cnt+1
; BRACKETELSE1                            ;
;         .word   FBLANK,WORDD,COUNT      ; -- cnt addr u
;         .word   DUP,QFBRAN,BRACKETELSE5 ;                 u = 0 if end of line --> refill buffer then loop back
;         .word   TWODUP                  ;
;         .word   XSQUOTE                 ;
;         .byte   6,"[THEN]"              ;
;         .word   COMPARE,ZEROEQUAL       ; 
;         .word   QFBRAN,BRACKETELSE2     ; -- cnt addr u   if bad comparaison, jump for next comparaison
;         .word   TWODROP,ONEMINUS        ; -- cnt-1        2DROP, decrement count
;         .word   QDUP,ZEROEQUAL          ;
;         .word   QFBRAN,BRACKETELSE1     ; -- cnt-1        loop back if count <> 0
;         .word   EXIT                    ; --              else exit
; BRACKETELSE2                            ;
;         .word   TWODUP                  ; -- cnt addr u addr u
;         .word   XSQUOTE                 ;
;         .byte   6,"[ELSE]"              ;
;         .word   COMPARE,ZEROEQUAL       ; -- cnt addr u ff 
;         .word   QFBRAN,BRACKETELSE3     ; -- cnt addr u   if bad comparaison, jump for next comparaison
;         .word   TWODROP,ONEMINUS        ; -- cnt-1        2DROP, decrement count
;         .word   QDUP,ZEROEQUAL          ;
;         .word   QFBRAN,BRACKETELSE0     ; -- cnt-1        if count <> 0 restore old count with loop back increment
;         .word   EXIT                    ; --              else exit
; BRACKETELSE3                            ;
;         .word   XSQUOTE                 ;
;         .byte   4,"[IF]"                ;
;         .word   COMPARE,ZEROEQUAL       ;
;         .word   QFBRAN,BRACKETELSE1     ; -- cnt          if bad comparaison, loop back
;         .word   BRAN,BRACKETELSE0       ; -- cnt          else increment loop back
; BRACKETELSE5                            ;
;         .word   TWODROP                 ; -- cnt
; ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
; ; OPTION                                ; plus 5 words option
; ;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
;         .word   XSQUOTE                 ;
;         .byte   5,13,10,"ko "           ;
;         .word   TYPE                    ;                 CR+LF ." ko" to show false branch of conditionnal compilation
; ;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
;         .word   REFILL                  ;                 REFILL Input Buffer with next line
;         .word   SETIB                   ;                 SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
;         .word   BRAN,BRACKETELSE1       ; -- cnt          then loop back   54 words without options

; BRanch if string BAD COMParaison, [COMPARE,ZEROEQUAL,QFBRAN] replacement
BRBADCOMP                   ;   -- cnt addr1 u1 addr1 u1 addr2 u2
            MOV TOS,S       ;1  S = u2
            MOV @PSP+,Y     ;2  Y = addr2
            MOV @PSP+,T     ;2  T = u1     
            MOV @PSP+,X     ;2  X = addr1
COMPLOOP    MOV T,TOS       ;1  -- cnt addr1 u1 u1 
            ADD S,TOS       ;1  -- cnt addr1 u1 u1+u2 
            JZ  COMPEQU     ;2  u1=u2=0, Z=1,  end of all successfull comparisons
            SUB #1,T        ;1  
            JN COMPDIF      ;2  u1<u2 if u1 < 0
            SUB #1,S        ;1  
            JN COMPDIF      ;2  u1>u2 if u2 < 0
            ADD #1,X        ;1  
            CMP.B @Y+,-1(X) ;4  char1-char2
            JZ COMPLOOP     ;2  char1=char2  17~ loop
COMPDIF     MOV @IP,IP      ;1  take branch
CMPEND      MOV @PSP+,TOS   ;
            MOV @IP+,PC     ;4

; BRanch if string GOOD COMParaison, [TWODROP,ONEMINUS,?DUP,ZEROEQUAL,QFBRAN] replacement
BRGOODCMP                   ;    -- cnt addr u
            ADD #2,PSP      ;1   -- cnt u
            SUB #1,0(PSP)   ;3   -- cnt-1 u
            JNZ COMPDIF     ;2   -- cnt-1 u take branch
            ADD #2,PSP      ;1   -- u
COMPEQU     ADD #2,IP       ;               skip branch
            JMP CMPEND      ; 25 words

            FORTHWORDIMM  "[ELSE]"          ; or [IF] if isnogood...
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
BRACKETELSE
            mDOCOL
            .word   lit,0                   
BRACKETELSE0
            .word   ONEPLUS                 ; 
BRACKETELSE1                                ;
            .word   FBLANK,WORDD,COUNT      ; -- addr u
            .word   DUP,QFBRAN,BRACKETELSE5 ;       u = 0 if end of line --> refill buffer then loop back
            .word   TWODUP                  ;
            .word   XSQUOTE                 ;
            .byte   6,"[THEN]"              ;
            .word   BRBADCOMP,BRACKETELSE2  ; if bad string comparaison, jump for next comparaison
            .word   BRGOODCMP,BRACKETELSE1  ; 2DROP,  count-1, loop back if count <> 0, else DROP
            .word   EXIT                    ; then exit
BRACKETELSE2                                ;
            .word   TWODUP                  ;
            .word   XSQUOTE                 ;
            .byte   6,"[ELSE]"              ;
            .word   BRBADCOMP,BRACKETELSE3  ; if bad string comparaison, jump for next comparaison
            .word   BRGOODCMP,BRACKETELSE0  ; 2DROP, count-1, loop back with count+1 if count <> 0, else DROP
            .word   EXIT                    ; then exit
BRACKETELSE3                                ;
            .word   XSQUOTE                 ;
            .byte   4,"[IF]"                ;
            .word   BRBADCOMP,BRACKETELSE1  ; if bad string comparaison, loop back
            .word   BRAN,BRACKETELSE0       ; else loop back with count+1
BRACKETELSE5                                ;
            .word   TWODROP                 ;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
; OPTION                                    ; +5 words option
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
            .word   XSQUOTE                 ;
            .byte   5,13,10,"ko "           ;
            .word   TYPE                    ; CR+LF ." ko "     to show false branch of conditionnal compilation
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
BRKTELSEND  .word   REFILL                  ; REFILL Input Buffer with next line
            .word   SETIB                   ; SET Input Buffer pointers SOURCE_LEN, SOURCE_ORG and clear >IN
            .word   BRAN,BRACKETELSE1       ; then loop back   44 words without options

            FORTHWORDIMM "[IF]" ; flag -- 
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
BRACKETIF   CMP #0,TOS      ; -- f
            MOV @PSP+,TOS   ; --
            JZ BRACKETELSE  ; false flag output
            MOV @IP+,PC     ; true flag output

    .IFNDEF NIP
; https://forth-standard.org/standard/core/NIP
; NIP      x1 x2 -- x2         Drop the first item below the top of stack
NIP         ADD #2,PSP      ; 1
            MOV @IP+,PC     ; 4
    .ENDIF


            FORTHWORDIMM  "[DEFINED]"
; https://forth-standard.org/standard/tools/BracketDEFINED
; [DEFINED]
;Compilation:
;Perform the execution semantics given below.
;Execution:
;( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space. 
;Return a true flag if name is the name of a word that can be found,
;otherwise return a false flag. [DEFINED] is an immediate word.
DEFINED     mDOCOL
            .word   FBLANK,WORDD,FIND,NIP,EXIT

            FORTHWORDIMM  "[UNDEFINED]"
; https://forth-standard.org/standard/tools/BracketUNDEFINED
; [UNDEFINED]
;Compilation:
;Perform the execution semantics given below.
;Execution: ( "<spaces>name ..." -- flag )
;Skip leading space delimiters. Parse name delimited by a space. 
;Return a false flag if name is the name of a word that can be found,
;otherwise return a true flag.
            mDOCOL
            .word   DEFINED,ZEROEQUAL,EXIT


; https://forth-standard.org/standard/core/MARKER
; MARKER
;name Execution: ( -- )
;Restore all dictionary allocation and search order pointers to the state they had just prior to the
;definition of name. Remove the definition of name and all subsequent definitions. Restoration
;of any structures still existing that could refer to deleted definitions or deallocated data space is
;not necessarily provided. No other contextual information such as numeric base is affected.


; FastForth provides all that is necessary for a real time application next MARKER definition,
; by adding a call to a custom subroutine, with the default parameters to be restored saved next MARKER definition.
MARKER_DOES                         ; execution part of MARKER, same effect than RST_STATE, but to restore state before MARKER defn.
            .word   $+2             ; -- BODY
            MOV @TOS+,&RST_DP       ; -- BODY+2         thus RST_STATE will restore the word-set state before MARKER
    .IFDEF VOCABULARY_SET
            MOV @TOS+,&RST_VOC      ; -- BODY+4         thus RST_STATE will restore the word-set state before MARKER
    .ELSE
            ADD #2,TOS              ; -- BODY+4
    .ENDIF
            CALL @TOS+              ; -- BODY+6         @TOS = RET_ADR|STOP_APP_ADR    (default|custom)
            MOV @PSP+,TOS           ; --
            MOV @RSP+,IP            ;
            JMP RST_STATE           ;               then next

            FORTHWORD "MARKER"      ; definition part
;( "<spaces>name" -- )
;Skip leading space delimiters. Parse name delimited by a space. Create a definition for name
;with the execution semantics defined below.

            CALL #HEADER            ;4 W = DP+4, Y = NFA, 
            MOV #1285h,-4(W)        ;4 CFA = CALL R5 = rDODOES
            MOV #MARKER_DOES,-2(W)  ;4 PFA = MARKER_DOES
            SUB #2,Y                ;1 Y = NFA-2 = LFA
            MOV Y,0(W)              ;3 BODY   = DP value before this MARKER definition
    .IFDEF VOCABULARY_SET
            MOV &LASTVOC,2(W)       ;5 BODY+2 = current VOCLINK
    .ENDIF
            MOV #RET_ADR,4(W)       ;  BODY+4 = RET addr, to do nothing by default
            ADD #6,&DDP             ;4
            JMP GOOD_CSP            ;
