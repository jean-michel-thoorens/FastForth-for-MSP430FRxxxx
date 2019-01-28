
; ------------------
; FastForthSpecs.f
; ------------------

; display all FastForth compilation options

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
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

: ADDONS
ESC ." [7m"     \ escape sequence to set reverse video
." KERNEL ADD-ON:"
ESC ." [0m"     \ escape sequence to clear reverse video
KERNEL_ADDON @
    DUP + DUP 0< IF CR ." TERMINAL5WIRES" THEN
    DUP + DUP 0< IF CR ." TERMINAL4WIRES" THEN
    DUP + DUP 0< IF CR ." TERMINAL3WIRES" THEN
    DUP + DUP 0< IF CR ." TOTAL" THEN
    DUP + DUP 0< IF CR ." QUIETBOOT" THEN
    DUP + DUP 0< IF CR ." BOOTLOADER" THEN
    DUP + DUP 0< IF CR ." SD_CARD_READ_WRITE" THEN
    DUP + DUP 0< IF CR ." SD_CARD_LOADER" THEN
    DUP + DUP 0< IF CR ." FIXPOINT_INPUT" THEN
    DUP + DUP 0< IF CR ." DOUBLE_INPUT" THEN
    DUP + DUP 0< IF CR ." VOCABULARY_SET" THEN
    DUP + DUP 0< IF CR ." NONAME" THEN
    DUP + DUP 0< IF CR ." ASM_EXTENDED_MEM" THEN
    DUP + DUP 0< IF CR ." ASSEMBLER" THEN
    DUP + DUP 0< IF CR ." CONDCOMP" THEN
    0< \ true if CONDCOMP add-on
IF CR CR 
ESC ." [7m"     \ escape sequence to set reverse video
." OTHER ADD-ON:"
ESC ." [0m"     \ escape sequence to clear reverse video
    [DEFINED] {ANS_COMP} [IF] CR ." ANS_COMPLEMENT" [THEN]
    [DEFINED] {TOOLS}    [IF] CR ." UTILITY" [THEN]
    [DEFINED] {FIXPOINT} [IF] CR ." FIXPOINT" [THEN]
    [DEFINED] {SD_TOOLS} [IF] CR ." SD_TOOLS" [THEN]
THEN
;

: specs         \ to see Fast Forth specifications
PWR_STATE       \ before free bytes computing, remove all words defined after RST_HERE
ESC ." [1J"     \ erase up
ESC ." [H"      \ cursor home
ESC ." [7m"     \ escape sequence to set reverse video
CR ." FastForth V" 
VERSION @ U.
." for MSP430FR"
HERE            \ to compute bytes
DEVICEID @      \ kept in TLV area
CASE
$830C OF ." 2355" $8000 ENDOF \ $8000 = org MAIN
$8240 OF ." 2433" $C400 ENDOF
$81F0 OF ." 4133" $C400 ENDOF
$8103 OF ." 5739" $C200 ENDOF
$8102 OF ." 5738" $C200 ENDOF
$8169 OF ." 5969" $4400 ENDOF
$8160 OF ." 5948" $4400 ENDOF
$82A1 OF ." 5994" $4000 ENDOF
$81A8 OF ." 6989" $4400 ENDOF
ABORT" xxxx <-- unrecognized device!"
ENDCASE SPACE
FREQ_KHZ @ 0 1000 UM/MOD U. BS
?DUP
IF   ." ," U. BS                \ if remainder
THEN ." MHz, "                  \ MCLK
INI_THREAD @ U. BS ." -Entry Vocabularies, "
- U. ." bytes, "                \ HERE - MAIN_ORG
SIGNATURES HERE - U. ." bytes free"
CR
ESC ." [0m"     \ escape sequence to clear reverse video
CR ADDONS CR
;

ECHO
specs \ here FastForth type a (volatile) message with some informations
