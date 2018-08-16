\ ------------------------------------------------------------------------------
\ UTILITY.f
\ ------------------------------------------------------------------------------

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433

\ must be preprocessed with yourtarget.pat file because PSTACK,CONTEXT,INI_THREAD

\ REGISTERS USAGE
\ rDODOES to rEXIT must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0

\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15

\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack

\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }

\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=

\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  <0

PWR_STATE
    \
[DEFINED] {TOOLS} [IF] {TOOLS} [THEN]     \ remove {UTILITY} if outside core 
    \
[UNDEFINED] {TOOLS} [IF]  \ don't replicate {UTILITY} if inside core
    \
MARKER {TOOLS} 
    \
[UNDEFINED] ? [IF]    \
\ https://forth-standard.org/standard/tools/q
\ ?         adr --            display the content of adr
CODE ?          
    MOV @TOS,TOS
    MOV #U.,PC  \ goto U.
ENDCODE
[THEN]
    \

[UNDEFINED] .S [IF]    \
\ https://forth-standard.org/standard/tools/DotS
\ .S            --            display <depth> of param Stack and stack contents if not empty
CODE .S
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
\ .RS            --            display <depth> of Return Stack and stack contents if not empty
CODE .RS
    MOV     TOS,-2(PSP) \ -- TOS ( tos x x ) 
    MOV     RSP,-6(PSP) \ -- TOS ( tos x  RSP )
    MOV     #RSTACK,TOS \ -- R0  ( tos x  RSP )
    GOTO    BW1
ENDCODE
[THEN]
    \

[UNDEFINED] WORDS [IF]
    \
[UNDEFINED] AND [IF]
    \
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
    \
[THEN]
    \
[UNDEFINED] PAD [IF]
    \
\ https://forth-standard.org/standard/core/PAD
\ C PAD    -- addr
PAD_ORG CONSTANT PAD
    \
[THEN]
    \
\ https://forth-standard.org/standard/tools/WORDS
\ list all words of vocabulary first in CONTEXT.
: WORDS                             \ --            

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
CONTEXT @                           \ -- VOC_BODY                   MOVE all threads of VOC_BODY in PAD
    PAD INI_THREAD @ DUP +          \ -- VOC_BODY PAD THREAD*2
    MOVE                            \
    BEGIN                           \ -- 
\        0 DUP                       \ -- ptr=0 MAX=0                select the MAX of NFAs in all vocabulary threads
        0.                          \ -- ptr=0 MAX=0                
        INI_THREAD @ DUP + 0        \ -- ptr=0 MAX=0 THREADS*2 0
            DO                      \ -- ptr MAX            I =  PAD_ptr = thread*2
            DUP I PAD + @           \ -- ptr MAX MAX NFAx
                U< IF               \ -- ptr MAX            if MAX U< NFAx
                    DROP DROP       \ --                    drop ptr and MAX
                    I DUP PAD + @   \ -- new_ptr new_MAX
                THEN                \ 
            2 +LOOP                 \ -- ptr MAX
        ?DUP                        \ -- ptr MAX MAX | -- ptr 0  
    WHILE                           \ -- ptr MAX                    replace it by its LFA
        DUP                         \ -- ptr MAX MAX
        2 - @                       \ -- ptr MAX [LFA]
        ROT                         \ -- MAX [LFA] ptr
        PAD +                       \ -- MAX [LFA] thread
        !                           \ -- MAX                [LFA]=new_NFA --> PAD+ptr   type it in 16 chars format
        DUP                         \ -- MAX MAX
        COUNT $7F AND               \ -- MAX addr count (with suppr. of immediate bit)
        TYPE                        \ -- MAX
        C@ $0F AND                  \ -- count_of_chars
        $10 SWAP - SPACES           \ --                    complete with spaces to 16 chars
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

[UNDEFINED] U.R [IF]
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
>R  <# 0 # #S #>  
R> OVER - 0 MAX SPACES TYPE
;
[THEN]
    \

[UNDEFINED] DUMP [IF]    \
\ https://forth-standard.org/standard/tools/DUMP
CODE DUMP                   \ adr n  --   dump memory
PUSH IP
PUSH &BASE                  \ save current base
MOV #$10,&BASE              \ HEX base
ADD @PSP,TOS                \ -- ORG END
LO2HI
  SWAP OVER OVER            \ -- END ORG END ORG 
  U. U.                     \ -- END ORG        display org end 
  $FFF0 AND                 \ -- END ORG_modulo_16
  DO  CR                    \ generate line
    I 7 U.R SPACE           \ generate address
      I $10 + I             \ display 16 bytes
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I             \ display 16 chars
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> BASE !                 \ restore current base
;
[THEN]
    \

[THEN]
    \
PWR_HERE
ECHO

: BS 8 EMIT ;   \ 8 EMIT = BackSpace EMIT
: ESC #27 EMIT ;
: specs         \ to see Fast Forth specifications
PWR_STATE       \ remove specs definition when running, and before bytes free processing
6 0 DO BS LOOP  \ to reach start of line
ESC ." [7m"     \ set reverse video
." FastForth "
INI_THREAD @ U. BS ." Threads "   \ vocabularies threads
." DeviceID=$"
$10 BASE ! $1A04 @ U. #10 BASE ! 
FREQ_KHZ @ 0 1000 UM/MOD U. ?DUP
IF      BS ." ," U.
THEN    BS ." MHz "            \ MCLK
FRAM_FULL HERE - U. ." bytes free"
ESC ." [0m"                     \ reset reverse video
;
    \

specs