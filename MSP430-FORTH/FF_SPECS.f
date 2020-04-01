\ -*- coding: utf-8 -*-

; ------------------
; FF_SPECS.f
; ------------------

; displays all FastForth specifications

\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\ COLD            \ uncomment for this TEST which must not disrupt the downloading process

PWR_STATE       \ remove volatile words

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] DUP [IF]    \ define DUP and DUP?
\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
CODE DUP
BW1 SUB #2,PSP      \ 2  push old TOS..
    MOV TOS,0(PSP)  \ 3  ..onto stack
    MOV @IP+,PC     \ 4
ENDCODE

\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
CODE ?DUP
CMP #0,TOS      \ 2  test for TOS nonzero
0<> ?GOTO BW1   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

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

[UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
CODE DROP
MOV @PSP+,TOS   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] SWAP [IF]
\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
CODE SWAP
MOV @PSP,W      \ 2
MOV TOS,0(PSP)  \ 3
MOV W,TOS       \ 1
MOV @IP+,PC     \ 4
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

[UNDEFINED] >R [IF]
\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
CODE >R
PUSH TOS
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] R> [IF]
\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
CODE R>
SUB #2,PSP      \ 1
MOV TOS,0(PSP)  \ 3
MOV @RSP+,TOS   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] 0= [IF]
\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
CODE 0=
SUB #1,TOS      \ borrow (clear cy) if TOS was 0
SUBC TOS,TOS    \ TOS=-1 if borrow was set
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 0< [IF]
\ https://forth-standard.org/standard/core/Zeroless
\ 0<     n -- flag      true if TOS negative
CODE 0<
ADD TOS,TOS     \ 1 set carry if TOS negative
SUBC TOS,TOS    \ 1 TOS=-1 if carry was clear
XOR #-1,TOS     \ 1 TOS=-1 if carry was set
MOV @IP+,PC     \ 
ENDCODE
[THEN]

[UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
CODE =
SUB @PSP+,TOS   \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1 flag Z = 1
    MOV @IP+,PC \ 4
THEN
XOR #-1,TOS     \ 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

\ https://forth-standard.org/standard/core/Uless
\ U<    u1 u2 -- flag       test u1<u2, unsigned
[UNDEFINED] U< [IF]
CODE U<
SUB @PSP+,TOS   \ 2 u2-u1
0<> IF
    MOV #-1,TOS     \ 1
    U< IF           \ 2 flag 
        AND #0,TOS  \ 1 flag Z = 1
    THEN
THEN
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] IF [IF]     \ define IF and THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
CODE IF
SUB #2,PSP              \
MOV TOS,0(PSP)          \
MOV &DP,TOS             \ -- HERE
ADD #4,&DP              \           compile one word, reserve one word
MOV #QFBRAN,0(TOS)      \ -- HERE   compile QFBRAN
ADD #2,TOS              \ -- HERE+2=IFadr
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
CODE THEN
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
CODE ELSE
ADD #4,&DP              \ make room to compile two words
MOV &DP,W               \ W=HERE+4
MOV #BRAN,-4(W)
MOV W,0(TOS)            \ HERE+4 ==> [IFadr]
SUB #2,W                \ HERE+2
MOV W,TOS               \ -- ELSEadr
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] BEGIN [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT
\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
CODE BEGIN
    MOV #HEREADR,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/UNTIL
\ UNTIL    BEGINadr --             resolve conditional backward branch
CODE UNTIL
    MOV #QFBRAN,X
BW1 ADD #4,&DP          \ compile two words
    MOV &DP,W           \ W = HERE
    MOV X,-4(W)         \ compile Bran or QFBRAN at HERE
    MOV TOS,-2(W)       \ compile bakcward adr at HERE+2
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/AGAIN
\ AGAIN    BEGINadr --             resolve uncondionnal backward branch
CODE AGAIN
MOV #BRAN,X
GOTO BW1
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/WHILE
\ WHILE    BEGINadr -- WHILEadr BEGINadr
: WHILE
POSTPONE IF SWAP
; IMMEDIATE

\ https://forth-standard.org/standard/core/REPEAT
\ REPEAT   WHILEadr BEGINadr --     resolve WHILE loop
: REPEAT
POSTPONE AGAIN POSTPONE THEN
; IMMEDIATE
[THEN]

[UNDEFINED] DO [IF]     \ define DO LOOP +LOOP
\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
CODE DO
SUB #2,PSP              \
MOV TOS,0(PSP)          \
ADD #2,&DP              \   make room to compile xdo
MOV &DP,TOS             \ -- HERE+2
MOV #XDO,-2(TOS)        \   compile xdo
ADD #2,&LEAVEPTR        \ -- HERE+2     LEAVEPTR+2
MOV &LEAVEPTR,W         \
MOV #0,0(W)             \ -- HERE+2     L-- 0
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/LOOP
\ LOOP    DOadr --         L-- an an-1 .. a1 0
CODE LOOP
    MOV #XLOOP,X
BW1 ADD #4,&DP          \ make room to compile two words
    MOV &DP,W
    MOV X,-4(W)         \ xloop --> HERE
    MOV TOS,-2(W)       \ DOadr --> HERE+2
BEGIN                   \ resolve all "leave" adr
    MOV &LEAVEPTR,TOS   \ -- Adr of top LeaveStack cell
    SUB #2,&LEAVEPTR    \ --
    MOV @TOS,TOS        \ -- first LeaveStack value
    CMP #0,TOS          \ -- = value left by DO ?
0<> WHILE
    MOV W,0(TOS)        \ move adr after loop as UNLOOP adr
REPEAT
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/PlusLOOP
\ +LOOP   adrs --   L-- an an-1 .. a1 0
CODE +LOOP
MOV #XPLOOP,X
GOTO BW1        \ goto BW1 LOOP
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] I [IF]
\ https://forth-standard.org/standard/core/I
\ I        -- n   R: sys1 sys2 -- sys1 sys2
\                  get the innermost loop index
CODE I
SUB #2,PSP              \ 1 make room in TOS
MOV TOS,0(PSP)          \ 3
MOV @RSP,TOS            \ 2 index = loopctr - fudge
SUB 2(RSP),TOS          \ 3
MOV @IP+,PC             \ 4 13~
ENDCODE
[THEN]

[UNDEFINED] HERE [IF]
CODE HERE
MOV #HEREADR,PC
ENDCODE
[THEN]

[UNDEFINED] @ [IF]
\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- char   fetch char from memory
CODE @
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] ! [IF]
\ https://forth-standard.org/standard/core/Store
\ !        x a-addr --   store cell in memory
CODE !
MOV @PSP+,0(TOS)    \ 4
MOV @PSP+,TOS       \ 2
MOV @IP+,PC         \ 4
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
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
CODE 1+
ADD #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] - [IF]
\ https://forth-standard.org/standard/core/Minus
\ -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
CODE -
SUB @PSP+,TOS   \ 2  -- n2-n1 ( = -n3)
XOR #-1,TOS     \ 1
ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 2* [IF]
\ https://forth-standard.org/standard/core/TwoTimes
\ 2*      x1 -- x2         arithmetic left shift
CODE 2*
ADD TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
CODE UM/MOD
    PUSH #DROP      \
    MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
ENDCODE
[THEN]

[UNDEFINED] MOVE [IF]
\ https://forth-standard.org/standard/core/MOVE
\ MOVE    addr1 addr2 u --     smart move
\             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
CODE MOVE
MOV TOS,W           \ W = cnt
MOV @PSP+,Y         \ Y = addr2 = dst
MOV @PSP+,X         \ X = addr1 = src
MOV @PSP+,TOS       \ pop new TOS
CMP #0,W            \ count = 0 ?
0<> IF              \ if 0, already done !
    CMP X,Y         \ Y-X \ dst - src
    0<> IF          \ if dst = src, already done !
        U< IF       \ U< if src > dst
            BEGIN   \ copy W bytes
                MOV.B @X+,0(Y)
                ADD #1,Y
                SUB #1,W
            0= UNTIL
            MOV @IP+,PC
        THEN        \ U>= if dst > src
        ADD W,Y     \ copy W bytes beginning with the end
        ADD W,X
        BEGIN
            SUB #1,X
            SUB #1,Y
            MOV.B @X,0(Y)
            SUB #1,W
        0= UNTIL
    THEN
THEN
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] WORDS [IF]
\ https://forth-standard.org/standard/tools/WORDS
\ list all words of vocabulary first in CONTEXT.
: WORDS                         \ --            
CR 
CONTEXT @ PAD_ORG               \ -- VOC_BODY PAD                  MOVE all threads of VOC_BODY in PAD_ORG
INI_THREAD @ 2*                 \ -- VOC_BODY PAD THREAD*2
MOVE                            \ -- vocabulary entries are copied in PAD_ORG
BEGIN                           \ -- 
    0 DUP                       \ -- ptr=0 MAX=0                
    INI_THREAD @ 2* 0           \ -- ptr=0 MAX=0 THREADS*2 0
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

[UNDEFINED] CASE [IF]
\ https://forth-standard.org/standard/core/CASE
: CASE 0 ; IMMEDIATE \ -- #of-1 

\ https://forth-standard.org/standard/core/OF
: OF \ #of-1 -- orgOF #of 
1+	                    \ count OFs 
>R	                    \ move off the stack in case the control-flow stack is the data stack. 
POSTPONE OVER POSTPONE = \ copy and test case value
POSTPONE IF	            \ add orig to control flow stack 
POSTPONE DROP	        \ discards case value if = 
R>	                    \ we can bring count back now 
; IMMEDIATE 

\ https://forth-standard.org/standard/core/ENDOF
: ENDOF \ orgOF #of -- orgENDOF #of 
>R	                    \ move off the stack in case the control-flow stack is the data stack. 
POSTPONE ELSE 
R>	                    \ we can bring count back now 
; IMMEDIATE 

\ https://forth-standard.org/standard/core/ENDCASE
: ENDCASE \ orgENDOF1..orgENDOFn #of -- 
POSTPONE DROP
0 DO 
    POSTPONE THEN 
LOOP 
; IMMEDIATE 
[THEN]

[UNDEFINED] >BODY [IF]
\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
CODE >BODY
ADD #4,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] S_ [IF]
CODE S_             \           Squote alias with blank instead quote separator
MOV #0,&CAPS        \           turn CAPS OFF
COLON
XSQUOTE ,           \           compile run-time code
$20 WORD            \ -- c-addr (= HERE)
HI2LO
MOV.B @TOS,TOS      \ -- len    compile string
ADD #1,TOS          \ -- len+1
BIT #1,TOS          \           C = ~Z
ADDC TOS,&DP        \           store aligned DP
MOV @PSP+,TOS       \ --
MOV @RSP+,IP        \           pop paired with push COLON
MOV #$20,&CAPS      \           turn CAPS ON (default state)
MOV @IP+,PC         \ NEXT
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ESC [IF]
CODE ESC
CMP #0,&STATEADR
0= IF MOV @IP+,PC   \ interpret time usage disallowed
THEN
COLON          
$1B                 \ -- char escape
POSTPONE LITERAL    \ compile-time code : lit $1B  
POSTPONE EMIT       \ compile-time code : EMIT
POSTPONE S_         \ compile-time code : S_ <escape_sequence>
POSTPONE TYPE       \ compile-time code : TYPE
; IMMEDIATE
[THEN]

\ -------------------------------------------------------
: SPECS             \ to see all FastForth specifications
\ -------------------------------------------------------
PWR_STATE           \ before free bytes computing, remove all created words 
ECHO
42 0 DO CR LOOP     \ to avoid erasing any line of source, create 42 empty lines
ESC [H              \ then cursor home
ESC [7m             \ Turn reverse video on
CR ." FastForth V"  \ title line in reverse video 
VERSION @         
0 <# #  8 HOLD # 46 HOLD #S #> TYPE
."  for MSP430FR"
HERE                \ HERE - MAIN_ORG = bytes code
DEVICEID @          \ value kept in TLV area
CASE
\ device_ID   OF      ." xxxx," $MAIN_ORG ENDOF \ <-- add here your device
    $8102     OF      ." 5738,"   $C200   ENDOF 
    $8103     OF      ." 5739,"   $C200   ENDOF
    $8160     OF      ." 5948,"   $4400   ENDOF
    $8169     OF      ." 5969,"   $4400   ENDOF
    $81A8     OF      ." 6989,"   $4400   ENDOF
    $810D     OF      ." 5986,"   $4400   ENDOF
    $81F0     OF      ." 4133,"   $C400   ENDOF
    $8240     OF      ." 2433,"   $C400   ENDOF
    $82A1     OF      ." 5994,"   $4000   ENDOF
    $82A6     OF      ." 5962,"   $4000   ENDOF
    $830C     OF      ." 2355,"   $8000   ENDOF
    $830D     OF      ." 2353,"   $C000   ENDOF
    $831E     OF      ." 2155,"   $8000   ENDOF
    $831D     OF      ." 2153,"   $C000   ENDOF
    $832A     OF      ." 2476,"   $8000   ENDOF
    $832B     OF      ." 2475,"   $8000   ENDOF
    $833C     OF      ." 2633,"   $C400   ENDOF
    $833D     OF      ." 2533,"   $C400   ENDOF
    ABORT" xxxx <-- unrecognized device!"
ENDCASE                     \ -- HERE MAIN_ORG
['] ['] DUP @ $1284 =       \ DOCOL = CALL rDOCOL opcode
IF ."  DTC=1," DROP         \ [CFA] = CALL rDOCOL
ELSE 2 + @ $1284 =          \ 
    IF ."  DTC=2,"          \ [CFA] = PUSH IP, [CFA+2] = CALL rDOCOL 
    ELSE ."  DTC=3,"        \ [CFA] = PUSH IP, [CFA+2] = MOV PC,IP
    THEN
THEN
$20 EMIT 
INI_THREAD @ U. #8 EMIT ." -Entry word sets, "  \ number of Entry word sets,
FREQ_KHZ @ 0 1000 UM/MOD U.                     \ frequency,
?DUP IF #8 EMIT #44 EMIT U. \ if remainder
THEN ." MHz, "              \ MCLK
- U. ." bytes"              \ HERE - MAIN_ORG = number of bytes code,
ESC [0m                     \ Turn off character attributes
CR
." /COUNTED-STRING   = 255" CR 
." /HOLD             = 34" CR
." /PAD              = 84" CR
." ADDRESS-UNIT-BITS = 16" CR
." FLOORED           = true" CR
." MAX-CHAR          = 255" CR
." MAX-N             = 32767" CR
." MAX-U             = 65535" CR
." MAX-D             = 2147483647" CR
." MAX-UD            = 4294967295" CR
." STACK-CELLS       = 48" CR
." RETURN-STACK-CELLS= 48" CR
." WoRdS aRe CaSe-InSeNsItIvE" CR
CR 
ESC [7m ." KERNEL SPECS" ESC [0m   \ subtitle in reverse video
CR
KERNEL_ADDON @
    DUP 0< IF ." 32.768kHz XTAL" CR THEN
2*  DUP 0< IF 2* ." (RTS/CTS) UART TERMINAL" CR
        ELSE 2* DUP
            0< IF ." (RTS) UART TERMINAL" CR
            THEN
        THEN
2*  DUP 0< IF ." (XON/XOFF) UART TERMINAL" CR
        ELSE  ." I2C SLAVE TERMINAL" CR
        THEN
2*  DUP 0< IF ." HALF-DUPLEX TERMINAL" CR THEN
2*  DUP 0< IF ." ASM DATA ACCESS BEYOND $FFFF" CR THEN
2*  DUP 0< IF ." BOOTLOADER" CR THEN
2*  DUP 0< IF ." SD_CARD READ/WRITE" CR THEN
2*  DUP 0< IF ." SD_CARD LOADER" CR THEN
2*  DUP 0< IF ." FIXPOINT INPUT" CR THEN
2*  DUP 0< IF ." DOUBLE INPUT" CR THEN
2*  DUP 0< IF ." VOCABULARY SET" CR THEN
2*  DUP 0< IF ." DEFERRED words" CR THEN
2*  DUP 0< IF ." EXTENDED ASSEMBLER" CR THEN
2*  DUP 0< IF ." ASSEMBLER" CR THEN
2*  DUP 0< IF ." CONDITIONNAL COMPILATION" CR THEN
0< IF                           \ true if CONDCOMP add-on
    CR 
    ESC [7m ." OPTIONS" ESC [0m \ subtitle in reverse video
    CR
    [DEFINED] {CORE_ANS}  [IF] ." ANS94 CORE COMPLIANT" CR [THEN]
    [DEFINED] {DOUBLE}    [IF] ." Double-Number word set" CR [THEN]
    [DEFINED] {TOOLS}     [IF] ." UTILITY" CR [THEN]
    [DEFINED] {FIXPOINT}  [IF] ." FIXPOINT" CR [THEN]
    [DEFINED] {CORDIC}    [IF] ." CORDIC engine" CR [THEN]
    [DEFINED] {SD_TOOLS}  [IF] ." SD_TOOLS" CR [THEN]
    [DEFINED] {RTC}       [IF] ." RTC utility" CR [THEN]
    [DEFINED] {UARTI2CS}  [IF] ." UART to I2C_FastForth bridge" CR [THEN]
    [DEFINED] VOCABULARY  [IF] 
        CR 
        ESC [7m ." ASSEMBLER word set" ESC [0m  \ subtitle in reverse video 
        ALSO ASSEMBLER WORDS PREVIOUS           \ type ASSEMBLER word set
        CR
    [THEN]
THEN
CR
ESC [7m ." FORTH word set"  ESC [0m \ subtitle in reverse video 
WORDS                               \ type FORTH word set 
CR
WARM    \ type bytes free
;

SPECS \ here FastForth types a (volatile) message with some informations
