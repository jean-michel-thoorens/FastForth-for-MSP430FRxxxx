\ -*- coding: utf-8 -*-

; ------------------
; FF_SPECS.f
; ------------------

; display all FastForth compilation options

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\

WIPE \ remove all downloaded word set

0 CONSTANT CASE IMMEDIATE \ -- #of-1 

: OF \ #of-1 -- orgOF #of 
1+	                    \ count OFs 
>R	                    \ move off the stack in case the control-flow stack is the data stack. 
POSTPONE OVER POSTPONE = \ copy and test case value
POSTPONE IF	            \ add orig to control flow stack 
POSTPONE DROP	        \ discards case value if = 
R>	                    \ we can bring count back now 
; IMMEDIATE 

: ENDOF \ orgOF #of -- orgENDOF #of 
>R	                    \ move off the stack in case the control-flow stack is the data stack. 
POSTPONE ELSE 
R>	                    \ we can bring count back now 
; IMMEDIATE 

: ENDCASE \ orgENDOF1..orgENDOFn #of -- 
POSTPONE DROP
0 DO 
    POSTPONE THEN 
LOOP 
; IMMEDIATE 

: BS 8 EMIT ;   \ 8 EMIT = BackSpace EMIT

: ESC #27 EMIT ;

[UNDEFINED] PAD [IF]
\ https://forth-standard.org/standard/core/PAD
\  PAD           --  addr
PAD_ORG CONSTANT PAD
[THEN]

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]


[UNDEFINED] WORDS [IF]
\ https://forth-standard.org/standard/tools/WORDS
\ list all words of vocabulary first in CONTEXT.
: WORDS                         \ --            
CR 
CONTEXT @ PAD                   \ -- VOC_BODY PAD                  MOVE all threads of VOC_BODY in PAD
INI_THREAD @ DUP +              \ -- VOC_BODY PAD THREAD*2
MOVE                            \ -- vocabumary entries are copied in PAD
BEGIN                           \ -- 
    0 DUP                       \ -- ptr=0 MAX=0                
    INI_THREAD @ DUP + 0        \ -- ptr=0 MAX=0 THREADS*2 0
        DO                      \ -- ptr MAX            I =  PAD_ptr = thread*2
        DUP I PAD + @           \ -- ptr MAX MAX NFAx
            U< IF               \ -- ptr MAX            if MAX U< NFAx
                DROP DROP       \ --                    drop ptr and MAX
                I DUP PAD + @   \ -- new_ptr new_MAX
            THEN                \ 
        2 +LOOP                 \ -- ptr MAX
    ?DUP                        \ -- ptr MAX MAX | -- ptr 0 (all threads in PAD = 0)
WHILE                           \ -- ptr MAX                    replace it by its LFA
    DUP                         \ -- ptr MAX MAX
    2 - @                       \ -- ptr MAX [LFA]
    ROT                         \ -- MAX [LFA] ptr
    PAD +                       \ -- MAX [LFA] thread
    !                           \ -- MAX                [LFA]=new_NFA updates PAD+ptr
    DUP                         \ -- MAX MAX
    COUNT $7F AND               \ -- MAX addr count (with suppr. of immediate bit)
    TYPE                        \ -- MAX
    C@ $0F AND                  \ -- count_of_chars
    $10 SWAP - SPACES           \ --                    complete with spaces modulo 16 chars
REPEAT                          \ --
DROP                            \ ptr --
;                               \ all threads in PAD are filled with 0
[THEN]

: ADDONS
ESC ." [7m"         \ escape sequence to set reverse video
." KERNEL OPTIONS:" \ in reverse video
ESC ." [0m"         \ escape sequence to clear reverse video
KERNEL_ADDON @                                  \ see ThingsInFirst.inc

      DUP 0< IF CR ." LF XTAL" THEN
DUP + DUP 0< IF CR ." TERMINAL5WIRES" THEN      \ 'DUP +' = one shift left
DUP + DUP 0< IF CR ." TERMINAL4WIRES" THEN
DUP + DUP 0< IF CR ." TERMINAL3WIRES" THEN
DUP + DUP 0< IF CR ." HALFDUPLEX_TERMINAL" THEN
DUP + DUP 0< IF CR ." PROMPT" THEN
DUP + DUP 0< IF CR ." BOOTLOADER" THEN
DUP + DUP 0< IF CR ." SD_CARD_READ_WRITE" THEN
DUP + DUP 0< IF CR ." SD_CARD_LOADER" THEN
DUP + DUP 0< IF CR ." FIXPOINT_INPUT" THEN
DUP + DUP 0< IF CR ." DOUBLE_INPUT" THEN
DUP + DUP 0< IF CR ." VOCABULARY_SET" THEN
DUP + DUP 0< IF CR ." NONAME" THEN
DUP + DUP 0< IF CR ." EXTENDED_ASM" THEN
DUP + DUP 0< IF CR ." ASSEMBLER" THEN
DUP + DUP 0< IF CR ." CONDCOMP" THEN

0< IF                   \ true if CONDCOMP add-on
    CR ESC ." [7m"      \ escape sequence to set reverse video
    ." OTHER OPTIONS:"  \ in reverse video
    ESC ." [0m"         \ escape sequence to clear reverse video
    [DEFINED] {ANS_COMP} [IF] CR ." ANS_COMPLEMENT" [THEN]
    [DEFINED] {TOOLS}    [IF] CR ." UTILITY" [THEN]
    [DEFINED] {FIXPOINT} [IF] CR ." FIXPOINT" [THEN]
    [DEFINED] {SD_TOOLS} [IF] CR ." SD_TOOLS" [THEN]
    CR CR
    [DEFINED] VOCABULARY [IF]
    CR ESC ." [7m"      \ escape sequence to set reverse video
    ." ASSEMBLER word set"
    ESC ." [0m"         \ escape sequence to clear reverse video
        ALSO ASSEMBLER WORDS CR PREVIOUS
    [THEN]
    CR ESC ." [7m"      \ escape sequence to set reverse video
    ." FORTH word set"
    ESC ." [0m"         \ escape sequence to clear reverse video
    WORDS
THEN
;

: specs         \ to see Fast Forth specifications
PWR_STATE       \ before free bytes computing, remove all created words 
HERE            \ to compute bytes
ECHO

41              \ number of terminal lines   
0 DO CR LOOP    \ don't erase any line of source

ESC ." [1J"     \ erase up (42 empty lines)
ESC ." [H"      \ cursor home
ESC ." [7m"     \ escape sequence to set reverse video

DEVICEID @      \ value kept in TLV area

CR ." FastForth V" VERSION @ U. ." for MSP430FR"
CASE
\ device ID   of MSP430FRxxxx    MAIN org
    $830C     OF      ." 2355,"   $8000   ENDOF
    $8240     OF      ." 2433,"   $C400   ENDOF
    $81F0     OF      ." 4133,"   $C400   ENDOF
    $8103     OF      ." 5739,"   $C200   ENDOF
    $8102     OF      ." 5738,"   $C200   ENDOF
    $8169     OF      ." 5969,"   $4400   ENDOF
    $8160     OF      ." 5948,"   $4400   ENDOF
    $82A1     OF      ." 5994,"   $4000   ENDOF
    $81A8     OF      ." 6989,"   $4400   ENDOF
\   DevID     OF      ." xxxx,"   $MAIN   ENDOF \ <-- add here your device

    ABORT" xxxx <-- unrecognized device!"
ENDCASE

SPACE FREQ_KHZ @ 0 1000 UM/MOD U. 
?DUP IF  BS ." ," U.    \ if remainder
THEN ." MHz, "          \ MCLK

INI_THREAD @ U. BS ." -Entry Vocabularies, "

- U. ." bytes, "        \ HERE - MAIN_ORG

SIGNATURES HERE - U. ." bytes free" CR

ESC ." [0m"     \ escape sequence to clear reverse video

CR ADDONS
;

ECHO specs \ here FastForth types a (volatile) message with some informations
