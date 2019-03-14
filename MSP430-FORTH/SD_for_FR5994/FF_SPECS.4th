
; ------------------
; FastForthSpecs.4th
; ------------------

; display all FastForth compilation options


[DEFINED] {ANS_COMP} [IF] {ANS_COMP}    [THEN]
[DEFINED] {TOOLS}    [IF] {TOOLS}       [THEN]
[DEFINED] {FIXPOINT} [IF] {FIXPOINT}    [THEN]
[DEFINED] {SD_TOOLS} [IF] {SD_TOOLS}    [THEN]

0 CONSTANT CASE IMMEDIATE

: OF
1+	
>R	
POSTPONE OVER POSTPONE =
POSTPONE IF	
POSTPONE DROP	
R>	
; IMMEDIATE 

: ENDOF
>R	
POSTPONE ELSE 
R>	
; IMMEDIATE 

: ENDCASE
POSTPONE DROP
0 DO 
    POSTPONE THEN 
LOOP 
; IMMEDIATE 

: BS 8 EMIT ;
: ESC #27 EMIT ;

: ADDONS
ESC ." [7m"
." KERNEL OPTIONS:"
ESC ." [0m"
$1812 @
    DUP + DUP 0< IF CR ." TERMINAL5WIRES" THEN
    DUP + DUP 0< IF CR ." TERMINAL4WIRES" THEN
    DUP + DUP 0< IF CR ." TERMINAL3WIRES" THEN
    DUP + DUP 0< IF CR ." HALFDUPLEX_TERMINAL"  THEN
    DUP + DUP 0< IF CR ." PROMPT" THEN
    DUP + DUP 0< IF CR ." BOOTLOADER" THEN
    DUP + DUP 0< IF CR ." SD_CARD_READ_WRITE" THEN
    DUP + DUP 0< IF CR ." SD_CARD_LOADER" THEN
    DUP + DUP 0< IF CR ." FIXPOINT_INPUT" THEN
    DUP + DUP 0< IF CR ." DOUBLE_INPUT" THEN
    DUP + DUP 0< IF CR ." VOCABULARY_SET" THEN
    DUP + DUP 0< IF CR ." NONAME" THEN
    DUP + DUP 0< IF CR ." ASM_EXTENDED" THEN
    DUP + DUP 0< IF CR ." ASSEMBLER" THEN
    DUP + DUP 0< IF CR ." CONDCOMP" THEN

0< IF  
    CR CR 
    ESC ." [7m"
    ." OTHER OPTIONS:"
    ESC ." [0m"
    [DEFINED] {ANS_COMP} [IF] CR ." ANS_COMPLEMENT" [THEN]
    [DEFINED] {TOOLS}    [IF] CR ." UTILITY" [THEN]
    [DEFINED] {FIXPOINT} [IF] CR ." FIXPOINT" [THEN]
    [DEFINED] {SD_TOOLS} [IF] CR ." SD_TOOLS" [THEN]
THEN
;

: specs
PWR_STATE
ECHO
ESC ." [1J"
ESC ." [H"
ESC ." [7m"
CR ." FastForth V" 
$1810 @ U.
." for MSP430FR"
HERE
$1A04 @
CASE
   $830C     OF      ." 2355"   $8000   ENDOF
   $8240     OF      ." 2433"   $C400   ENDOF
   $81F0     OF      ." 4133"   $C400   ENDOF
   $8103     OF      ." 5739"   $C200   ENDOF
   $8102     OF      ." 5738"   $C200   ENDOF
   $8169     OF      ." 5969"   $4400   ENDOF
   $8160     OF      ." 5948"   $4400   ENDOF
   $82A1     OF      ." 5994"   $4000   ENDOF
   $81A8     OF      ." 6989"   $4400   ENDOF
ABORT" xxxx <-- unrecognized device!"
ENDCASE SPACE
$1806 @ 0 1000 UM/MOD U. BS
?DUP
IF   ." ," U. BS
THEN ." MHz, "
$1800 @ U. BS ." -Entry Vocabularies, "
- U. ." bytes, "
$FF80 HERE - U. ." bytes free"
CR
ESC ." [0m"
CR ADDONS CR
;

specs
