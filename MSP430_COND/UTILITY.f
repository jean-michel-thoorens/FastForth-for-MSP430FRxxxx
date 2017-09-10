\ UTILITY.f
\ must be preprocessed with yourtarget.pat file because PSTACK,CONTEXT,INI_THREAD

\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4
\ example : PUSHM IP,Y
\
\ POPM  order :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before GOTO ?GOTO    : S< S>= U< U>= 0= 0<> <0 

\ FORTH conditionnal usage after IF UNTIL WHILE : 0= 0< = < > U<


[UNDEFINED] {UTILITY} [IF]
    \

MARKER {UTILITY} 
    \

[UNDEFINED] ? [IF]    \
\ https://forth-standard.org/standard/tools/q
CODE ?          \ adr --            display the content of adr
    MOV @TOS,TOS
    MOV #U.,PC  \ goto U.
ENDCODE
[THEN]
    \

[UNDEFINED] .S [IF]    \
\ https://forth-standard.org/standard/tools/DotS
CODE .S                 \ --            display <depth> of Param Stack and stack contents if not empty
    MOV     TOS,-2(PSP) \ -- TOS ( tos x x )
    MOV     PSP,TOS
    SUB     #2,TOS      \ to take count that TOS is first cell
    MOV     TOS,-6(PSP) \ -- TOS ( tos x  PSP )
    MOV     #PSTACK,TOS \ -- P0  ( tos x  PSP )
    SUB     #2,TOS      \ to take count that TOS is first cell
BW1 MOV     TOS,-4(PSP) \ -- S0  ( tos S0 SP )
    SUB     #6,PSP      \ -- S0 SP S0
    SUB     @PSP,TOS    \ -- S0 SP S0-SP
    RRA     TOS         \ -- S0 SP #cells
COLON
    $3C EMIT            \ char '<'
    .                   \ display #cells
    $08 EMIT            \ backspace
    $3E EMIT SPACE      \ char '>' SPACE
    OVER OVER >         \ 
    0= IF 
        DROP DROP EXIT
    THEN
    DO 
        I @ U.
    2 +LOOP
;
[THEN]
    \

[UNDEFINED] .RS [IF]    \
CODE .RS                \ --           display <depth> of Return Stack and stack contents if not empty
    MOV     TOS,-2(PSP) \ -- TOS ( tos x x ) 
    MOV     RSP,-6(PSP) \ -- TOS ( tos x  RSP )
    MOV     #RSTACK,TOS \ -- R0  ( tos x  RSP )
    GOTO    BW1
ENDCODE
[THEN]
    \

\ : WORDS                             \ --            list all words in all dicts in CONTEXT.
\ 
\ \ \ vvvvvvvv   may be skipped    vvvvvvvv
\ \ BASE @                              \ -- BASE
\ \ #10 BASE !
\ \ CR ."    "
\ \ INI_THREAD @ DUP
\ \ 1 = IF DROP ." monothread"
\ \     ELSE . ." threads"
\ \     THEN ."  vocabularies"
\ \ BASE !                              \ --
\ \ \ ^^^^^^^^   may be skipped    ^^^^^^^^
\ 
\ CONTEXT                             \ -- CONTEXT
\ BEGIN                               \                                       search dictionnary
\     DUP 
\     2 + SWAP                        \ -- CONTEXT+2 CONTEXT
\     @ ?DUP                          \ -- CONTEXT+2 (VOC_BODY VOC_BODY or 0)
\ WHILE                               \ -- CONTEXT+2 VOC_BODY                  dictionnary found
\ CR ."    "                          \
\ \   MOVE all threads of VOC_BODY in PAD
\     DUP PAD INI_THREAD @ DUP +      \ -- CONTEXT+2 VOC_BODY  VOC_BODY PAD THREAD*2
\     MOVE                            \         char MOVE
\ 
\     BEGIN                           \ -- CONTEXT+2 VOC_BODY
\         0 DUP                       \ -- CONTEXT+2 VOC_BODY ptr MAX
\ \   select the MAX of NFA in threads
\         INI_THREAD @ DUP + 0 DO     \         ptr = threads*2
\         DUP I PAD + @               \ -- CONTEXT+2 VOC_BODY ptr MAX MAX NFAx
\         U< IF 
\             DROP DROP I DUP PAD + @ \ -- CONTEXT+2 VOC_BODY ptr MAX          if MAX U< NFAx replace adr and MAX
\         THEN                        \ 
\         2 +LOOP                     \ -- CONTEXT+2 VOC_BODY ptr MAX
\         ?DUP                        \ -- CONTEXT+2 VOC_BODY ptr MAX          max NFA = 0 ? end of vocabulary ?
\     WHILE                           \ -- CONTEXT+2 VOC_BODY ptr MAX
\ \   replace it by its LFA
\         DUP                         \ -- CONTEXT+2 VOC_BODY ptr MAX MAX
\         2 - @                       \ -- CONTEXT+2 VOC_BODY ptr MAX [LFA]
\         ROT                         \ -- CONTEXT+2 VOC_BODY MAX [LFA] ptr
\         PAD +                       \ -- CONTEXT+2 VOC_BODY MAX [LFA] thread
\         !                           \ -- CONTEXT+2 VOC_BODY MAX
\ \   type it in 16 chars format
\                 DUP                 \ -- CONTEXT+2 VOC_BODY MAX MAX
\             COUNT $7F AND TYPE      \ -- CONTEXT+2 VOC_BODY MAX
\                 C@ $0F AND          \ -- 
\                 $10 SWAP - SPACES   \ -- CONTEXT+2 VOC_BODY 
\ \   search next MAX of NFA 
\     REPEAT
\                                     \ -- CONTEXT+2 VOC_BODY 0
\     DROP DROP                       \ -- CONTEXT+2
\     CR         
\ \   repeat for each CONTEXT vocabulary
\ 
\ REPEAT                              \ -- 0
\ DROP                                \ --
\ ;
    \


[UNDEFINED] WORDS [IF]    \
\ https://forth-standard.org/standard/tools/WORDS
: WORDS                             \ --            list all words in first vocabulary in CONTEXT.

\ \ vvvvvvvv   may be skipped    vvvvvvvv
\ BASE @                              \ -- BASE
\ #10 BASE !
\ CR ."    "
\ INI_THREAD @ DUP
\ 1 = IF DROP ." monothread"
\     ELSE . ." threads"
\     THEN ."  vocabularies"
\ BASE !                              \ --
\ \ ^^^^^^^^   may be skipped    ^^^^^^^^

CR ."    "                          \
CONTEXT @                           \ -- VOC_BODY
\   MOVE all threads of VOC_BODY in PAD
    PAD INI_THREAD @ DUP +          \ -- VOC_BODY PAD THREAD*2
    MOVE                            \
    BEGIN                           \ -- 
        0 DUP                       \ -- ptr MAX
\   select the MAX of NFA in threads
        INI_THREAD @ DUP + 0 DO     \                   ptr = threads*2
        DUP I PAD + @               \ -- ptr MAX MAX NFAx
        U< IF 
            DROP DROP I DUP PAD + @ \ -- ptr MAX        if MAX U< NFAx replace adr and MAX
        THEN                        \ 
        2 +LOOP                     \ -- ptr MAX
        ?DUP                        \ -- ptr MAX MAX ( or -- ptr 0)  max NFA = 0 ? end of vocabulary ?
    WHILE                           \ -- ptr MAX
\   replace it by its LFA
        DUP                         \ -- ptr MAX MAX
        2 - @                       \ -- ptr MAX [LFA]
        ROT                         \ -- MAX [LFA] ptr
        PAD +                       \ -- MAX [LFA] thread
        !                           \ -- MAX
\   type it in 16 chars format
        DUP                         \ -- MAX MAX
        COUNT $7F AND               \ -- MAX addr count
        TYPE                        \ -- MAX
        C@ $0F AND                  \ -- 
        $10 SWAP - SPACES           \ -- 
\   search next MAX of NFA 
    REPEAT                          \ -- ptr
    DROP                            \ --
;
[THEN]
    \

[UNDEFINED] MAX [IF]    \ MAX and MIN are defined in {ANS_COMP}
    CODE MAX    \    n1 n2 -- n3       signed maximum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO FW1    \ n2<n1
    BW1 ADD #2,PSP
        MOV @IP+,PC
    ENDCODE
    \

    CODE MIN    \    n1 n2 -- n3       signed minimum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO BW1    \ n2<n1
    FW1 MOV @PSP+,TOS
        MOV @IP+,PC
    ENDCODE
[THEN]
    \


[UNDEFINED] U.R [IF]    \ MAX and MIN are defined in {ANS_COMP}
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
>R  <# 0 # #S #>  
R> OVER - 0 MAX SPACES TYPE
;
[THEN]
    \

[UNDEFINED] DUMP [IF]    \
\ https://forth-standard.org/standard/tools/DUMP
: DUMP                      \ adr n  --   dump memory
  BASE @ >R $10 BASE !
  SWAP $FFF0 AND SWAP
  OVER + SWAP
  DO  CR                    \ generate line
    I 7 U.R SPACE           \ generate address
      I $10 + I            \ display 16 bytes
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I            \ display 16 chars
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> BASE !
;
[THEN]
    \

[THEN]
ECHO
            ; added : ? .S .RS WORDS U.R MAX MIN DUMP 
PWR_HERE RST_HERE
