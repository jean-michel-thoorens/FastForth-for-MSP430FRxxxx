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

RST_STATE

[UNDEFINED] OVER [IF]
\ https://forth-standard.org/standard/core/OVER
\ OVER    x1 x2 -- x1 x2 x1
CODE OVER
MOV TOS,-2(PSP)     \ 3 -- x1 (x2) x2
MOV @PSP,TOS        \ 2 -- x1 (x2) x1
SUB #2,PSP          \ 1 -- x1 x2 x1
MOV @IP+,PC
ENDCODE
[THEN]

: CASE 0 ; IMMEDIATE \ -- #of-1 

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

: ESC #27 EMIT ;

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]


[UNDEFINED] ROT [IF]
\ https://forth-standard.org/standard/core/ROT
\ ROT    x1 x2 x3 -- x2 x3 x1
CODE ROT
MOV @PSP,W          \ 2 fetch x2
MOV TOS,0(PSP)      \ 3 store x3
MOV 2(PSP),TOS      \ 3 fetch x1
MOV W,2(PSP)        \ 3 store x2
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] C@ [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
CODE C@
MOV.B @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] SPACES [IF]
\ https://forth-standard.org/standard/core/SPACES
\ SPACES   n --            output n spaces
CODE SPACES
CMP #0,TOS
0<> IF
    PUSH IP
    BEGIN
        LO2HI
        $20 EMIT
        HI2LO
        SUB #2,IP 
        SUB #1,TOS
    0= UNTIL
    MOV @RSP+,IP
THEN
MOV @PSP+,TOS           \ --         drop n
NEXT              
ENDCODE
[THEN]

[UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
CODE UM/MOD
    PUSH #DROP      \
    MOV #<#,X       \ X = addr of <#
    ADD #8,X        \ X = addr of MUSMOD
    MOV X,PC        \ execute MUSMOD then RET to DROP
ENDCODE
[THEN]

[UNDEFINED] WORDS [IF]
\ https://forth-standard.org/standard/tools/WORDS
\ list all words of vocabulary first in CONTEXT.
: WORDS                         \ --            
CR 
CONTEXT @ PAD_ORG               \ -- VOC_BODY PAD                  MOVE all threads of VOC_BODY in PAD_ORG
INI_THREAD @ DUP +              \ -- VOC_BODY PAD THREAD*2
MOVE                            \ -- vocabumary entries are copied in PAD_ORG
BEGIN                           \ -- 
    0 DUP                       \ -- ptr=0 MAX=0                
    INI_THREAD @ DUP + 0        \ -- ptr=0 MAX=0 THREADS*2 0
        DO                      \ -- ptr MAX            I =  PAD_ptr = thread*2
        DUP I PAD_ORG + @       \ -- ptr MAX MAX NFAx
            U< IF               \ -- ptr MAX            if MAX U< NFAx
                DROP DROP       \ --                    drop ptr and MAX
                I DUP PAD_ORG + @   \ -- new_ptr new_MAX
            THEN                \ 
        2 +LOOP                 \ -- ptr MAX
    ?DUP                        \ -- ptr MAX MAX | -- ptr 0 (all threads in PAD = 0)
WHILE                           \ -- ptr MAX                    replace it by its LFA
    DUP                         \ -- ptr MAX MAX
    2 - @                       \ -- ptr MAX [LFA]
    ROT                         \ -- MAX [LFA] ptr
    PAD_ORG +                   \ -- MAX [LFA] thread
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

: ADDONS            \ see "compute value of FORTHADDON" in file \inc\ThingsInFirst.inc
ESC ." [7m"         \ escape sequence to set reverse video
." KERNEL OPTIONS:" \ in reverse video
ESC ." [0m"         \ escape sequence to clear reverse video
KERNEL_ADDON @                                  \ see ThingsInFirst.inc

      DUP 0< IF CR ." 32.768kHz XTAL" THEN
DUP + DUP 0< IF DUP + CR ." HARDWARE (RTS/CTS) TERMINAL"     \ 'DUP +' = one shift left
             ELSE DUP + DUP 0< IF CR ." HARDWARE (RTS) TERMINAL" THEN
             THEN
DUP + DUP 0< IF CR ." XON/XOFF TERMINAL" THEN
DUP + DUP 0< IF CR ." HALF-DUPLEX TERMINAL" THEN
DUP + DUP 0< IF CR ." ASM DATA ACCESS BEYOND $FFFF" THEN
DUP + DUP 0< IF CR ." BOOTLOADER" THEN
DUP + DUP 0< IF CR ." SD_CARD READ/WRITE" THEN
DUP + DUP 0< IF CR ." SD_CARD LOADER" THEN
DUP + DUP 0< IF CR ." FIXPOINT INPUT" THEN
DUP + DUP 0< IF CR ." DOUBLE INPUT" THEN
DUP + DUP 0< IF CR ." VOCABULARY SET" THEN
DUP + DUP 0< IF CR ." NONAME" THEN
DUP + DUP 0< IF CR ." EXTENDED ASSEMBLER" THEN
DUP + DUP 0< IF CR ." ASSEMBLER" THEN
DUP + DUP 0< IF CR ." CONDITIONNAL COMPILATION" THEN

0< IF                   \ true if CONDCOMP add-on
    CR ESC ." [7m"      \ escape sequence to set reverse video
    ." OTHER OPTIONS:"  \ in reverse video
    ESC ." [0m"         \ escape sequence to clear reverse video
    CR ." none"
    ESC ." [G"          \ cursor row 0
    [DEFINED] {ANS_COMP} [IF] ." ANS_COMPLEMENT" CR [THEN]
    [DEFINED] {TOOLS}    [IF] ." UTILITY" CR [THEN]
    [DEFINED] {FIXPOINT} [IF] ." FIXPOINT" CR [THEN]
    [DEFINED] {SD_TOOLS} [IF] ." SD_TOOLS" CR [THEN]
    CR CR
    [DEFINED] VOCABULARY [IF]
    ESC ." [7m"      \ escape sequence to set reverse video
    ." ASSEMBLER word set"
    ESC ." [0m"         \ escape sequence to clear reverse video
    ALSO ASSEMBLER WORDS CR PREVIOUS
    [THEN]
ESC ." [7m" ." FORTH word set" ESC ." [0m"
WORDS                                           \ Forth words set
THEN
;

: specs         \ to see Fast Forth specifications
PWR_STATE       \ before free bytes computing, remove all created words 
HERE            \ to compute bytes
ECHO

41              \ number of terminal lines -1  
0 DO CR LOOP    \ don't erase any line of source

ESC ." [1J"     \ erase up (41 empty lines)
ESC ." [H"      \ cursor home
ESC ." [7m"     \ escape sequence to set reverse video

DEVICEID @      \ value kept in TLV area

CR ." FastForth V" VERSION @                    \ FastForth version,
0 <# #  8 HOLD # 46 HOLD #S #> TYPE $20 EMIT
." for MSP430FR"                                \ target,
CASE
\ device ID   of MSP430FRxxxx    MAIN org
    $830C     OF      ." 2355,"   $8000   ENDOF
    $8328     OF      ." 2476,"   $8000   ENDOF
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
ENDCASE $20 EMIT 

['] ['] DUP @ $1287 = IF ." DTC=1," DROP         \ DTC model number,
                         ELSE 2 + @ $1287 =
                            IF ." DTC=2,"
                            ELSE ." DTC=3,"
                            THEN
                        THEN $20 EMIT 

INI_THREAD @ U. #8 EMIT ." -Entry word sets, "  \ number of Entry word sets,

FREQ_KHZ @ 0 1000 UM/MOD U.                     \ frequency,
?DUP IF #8 EMIT ." ," U.    \ if remainder
THEN ." MHz, "              \ MCLK

- U. ." bytes"     \ HERE - MAIN_ORG            \ number of bytes code,

\ ESC ." [0m"

CR CR ADDONS                                    \ addons

CR WARM
;

ECHO specs \ here FastForth types a (volatile) message with some informations
