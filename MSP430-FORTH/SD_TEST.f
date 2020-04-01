\ -*- coding: utf-8 -*-

; -----------
; SD_TEST.f
; -----------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, SD_CARD_READ_WRITE
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\ LP_MSP430FR2476
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\
\
\
\ how to test SD_CARD driver on your launchpad:
\
\
\ remove the jumpers RX, TX of programming port (don't remove GND, TST, RST and VCC)
\ wire PL2303TA/HXD: GND <-> GND, RX <-- TX, TX --> RX
\ connect it to your PC on a free USB port
\ connect the PL2303TA/HXD cable to your PC on another free USB port
\ configure TERATERM as indicated in forthMSP430FR.asm
\
\
\ if you have a MSP-EXP430FR5994 launchpad, program it with MSP_EXP430FR5994_xbauds_SD_CARD.txt
\ to do, drag and drop this file onto prog.bat
\ nothing else to do!
\
\
\ else edit forthMSP430FR.asm with scite editor
\   uncomment your target, copy it
\   paste it into (SHIFT+F8) param1
\   set DTC .equ 1
\       FREQUENCY   .equ 16
\       THREADS     .equ 16
\       TERMINALBAUDRATE    .equ what_you_want
\         
\   uncomment:  CONDCOMP
\               MSP430ASSEMBLER
\               SD_CARD_LOADER
\               SD_CARD_READ_WRITE
\ 
\   compile for your target (CTRL+0)
\
\   program your target via TI interface (CTRL+1)
\
\   then wire your SD_Card module as described in your MSP430-FORTH\target.pat file
\
\
\
\ format FAT16 or FAT32 a SD_CARD memory (max 64GB) with "FRxxxx" in the disk name
\ drag and drop \MSP430_COND\MISC folder on the root of this SD_CARD memory (FastForth doesn't do yet)
\ put it in your target SD slot
\ if no reset, type COLD from the console input (teraterm) to reset FAST FORTH
\
\ with MSP430FR5xxx or MSP430FR6xxx targets, you can first set RTC:
\ by downloading RTC.f with SendSourceFileToTarget.bat
\ then terminal input asks you to type (with spaces) (DMY), then (HMS),
\ So, subsequent copied files will be dated:
\
\ with CopySourceFileToTarget_SD_Card.bat (or better, from scite editor, menu tools):
\
\   copy TESTASM.4TH        to \MISC\TESTASM.4TH    (add path \MISC in the window opened by TERATERM)
\   copy TSTWORDS.4TH       to \TSTWORDS.4TH
\   copy CORETEST.4TH       to \CORETEST.4TH
\   copy SD_TOOLS.f         to \SD_TOOLS.4TH
\   copy SD_TEST.f          to \SD_TEST.4TH
\   copy PROG100k.f         to \PROG100k.4TH
\   copy RTC.f              to \RTC.4TH             ( doesn't work with if FR2xxx or FR4xxx)

PWR_STATE

[DEFINED] {SD_TEST} [IF]  {SD_TEST} [THEN] \ remove it if defined out of kernel 

MARKER {SD_TEST}

[UNDEFINED] EXIT [IF]
\ https://forth-standard.org/standard/core/EXIT
\ EXIT     --      exit a colon definition; CALL #EXIT performs ASMtoFORTH (10 cycles)
\                                           JMP #EXIT performs EXIT
CODE EXIT
MOV @RSP+,IP    \ 2 pop previous IP (or next PC) from return stack
MOV @IP+,PC     \ 4 = NEXT
                \ 6 (ITC-2)
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

[UNDEFINED] >BODY [IF]
\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
CODE >BODY
ADD #4,TOS
MOV @IP+,PC
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

[UNDEFINED] IF [IF]     \ define IF and THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
CODE IF       \ immediate
SUB #2,PSP              \
MOV TOS,0(PSP)          \
MOV &DP,TOS             \ -- HERE
ADD #4,&DP            \           compile one word, reserve one word
MOV #QFBRAN,0(TOS)      \ -- HERE   compile QFBRAN
ADD #2,TOS              \ -- HERE+2=IFadr
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
CODE THEN               \ immediate
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
CODE ELSE     \ immediate
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
CODE UNTIL              \ immediate
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
CODE AGAIN     \ immediate
MOV #BRAN,X
GOTO BW1
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/WHILE
\ WHILE    BEGINadr -- WHILEadr BEGINadr
: WHILE     \ immediate
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
CODE DO                 \ immediate
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
CODE LOOP               \ immediate
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
CODE +LOOP              \ immediate
MOV #XPLOOP,X
GOTO BW1
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

[UNDEFINED] MAX [IF]   \ define MAX and MIN
    CODE MAX    \    n1 n2 -- n3       signed maximum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO FW1    \ n2<n1
BW1     ADD #2,PSP
        MOV @IP+,PC
    ENDCODE

    CODE MIN    \    n1 n2 -- n3       signed minimum
        CMP @PSP,TOS    \ n2-n1
        S< ?GOTO BW1    \ n2<n1
FW1     MOV @PSP+,TOS
        MOV @IP+,PC
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

[UNDEFINED] C@ [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
CODE C@
MOV.B @TOS,TOS
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

[UNDEFINED] SPACE [IF]
\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
: SPACE
$20 EMIT ;
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
0<> ?GOTO BW1    \ 2
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

[UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT 
: CONSTANT 
CREATE
HI2LO
MOV TOS,-2(W)           \   PFA = n
MOV @PSP+,TOS
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] STATE [IF]
\ https://forth-standard.org/standard/core/STATE
\ STATE   -- a-addr       holds compiler state
STATEADR CONSTANT STATE
[THEN]

[UNDEFINED] IS [IF]     \ define DEFER! and IS
\ https://forth-standard.org/standard/core/DEFERStore
\ Set the word xt1 to execute xt2. An ambiguous condition exists if xt1 is not for a word defined by DEFER.
CODE DEFER!             \ xt2 xt1 --
MOV @PSP+,2(TOS)        \ -- xt1=CFA_DEFER          xt2 --> [CFA_DEFER+2]
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/IS
\ IS <name>        xt --
\ used as is :
\ DEFER DISPLAY                         create a "do nothing" definition (2 CELLS)
\ inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
\ or in a definition : ... ['] U. IS DISPLAY ...
\ KEY, EMIT, CR, ACCEPT and WARM are examples of DEFERred words
: IS
STATE @
IF  POSTPONE ['] POSTPONE DEFER! 
ELSE ' DEFER! 
THEN
; IMMEDIATE
[THEN]

[UNDEFINED] U.R [IF]        \ defined in {UTILITY}
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
>R  <# 0 # #S #>  
R> OVER - 0 MAX SPACES TYPE
;
[THEN]

[UNDEFINED] DUMP [IF]       \ defined in {UTILITY}
\ https://forth-standard.org/standard/tools/DUMP
CODE DUMP                   \ adr n  --   dump memory
PUSH IP
PUSH &BASEADR               \ save current base
MOV #$10,&BASEADR           \ HEX base
ADD @PSP,TOS                \ -- ORG END
LO2HI
  SWAP                      \ -- END ORG
  DO  CR                    \ generate line
    I 4 U.R SPACE           \ generate address
      I 8 + I
      DO I C@ 3 U.R LOOP
      SPACE
      I $10 + I 8 +
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I             \ display 16 chars
      DO I C@ $7E MIN $20 MAX EMIT LOOP
  $10 +LOOP
  R> BASEADR !              \ restore current base
;
[THEN]

[UNDEFINED] HERE [IF]
CODE HERE
MOV #BEGIN,PC
ENDCODE
[THEN]


\ SD_EMIT  c --    output char c to a SD_CARD file opened as write
CODE SD_EMIT
CMP #512,&BufferPtr     \ 512 bytes by sector
U>= IF                  \ if file buffer is full
    MOV #WRITE,X        \ CALL #Write_File
    CALL 2(X)           \ BufferPtr = 0
THEN
MOV &BufferPtr,Y        \ 3 
MOV.B TOS,SD_BUF(Y)     \ 3
ADD #1,&BufferPtr       \ 4
MOV @PSP+,TOS           \ 2
MOV @IP+,PC
ENDCODE

: SD_TEST
PWR_HERE    \ remove all volatile programs from MAIN memory
CR
." 0 Set date and time" CR
." 1 Load {TOOLS} words" CR
." 2 Load {SD_TOOLS} words" CR
." 3 Load {CORE_COMP} words" CR
." 4 Load ANS core tests" CR
." 5 Load a 100k program " CR
." 6 Read only this source file" CR
." 7 append a dump of FORTH to YOURFILE.TXT" CR
." 8 delete YOURFILE.TXT" CR
." 9 Load TST_WORDS" CR
." your choice : "
KEY
48 - ?DUP
0= IF
    ." LOAD RTC.4TH" CR
    LOAD" RTC.4TH"
ELSE 1 - ?DUP
    0= IF
        ." LOAD UTILITY.4TH" CR
        LOAD" UTILITY.4TH"
    ELSE 1 - ?DUP
        0= IF
            ." LOAD SD_TOOLS.4TH" CR
            LOAD" SD_TOOLS.4TH"
        ELSE 1 - ?DUP
            0= IF
                ." LOAD CORECOMP.4TH" CR
                LOAD" CORECOMP.4TH"
            ELSE 1 - ?DUP
                0= IF
                    ." LOAD CORETEST.4TH" CR
                    LOAD" CORETEST.4TH"
                    PWR_STATE
                ELSE 1 - ?DUP
                    0= IF
                        ." LOAD PROG100K.4TH" CR
                        NOECHO
                        LOAD" PROG100K.4TH"
                    ELSE 1 - ?DUP
                        0= IF
                            ." READ PROG100K.4TH" CR
                            READ" PROG100K.4TH"
                            BEGIN
                                READ    \ sequentially read 512 bytes
                            UNTIL       \ prog10k.4TH is closed
                        ELSE 1 - ?DUP
                            0= IF
                                ." WRITE YOURFILE.TXT" CR
                                WRITE" YOURFILE.TXT"
                                ['] SD_EMIT IS EMIT
\                                ." va te faire voir"
                                MAIN_ORG HERE OVER - DUMP
                                ['] EMIT >BODY IS EMIT
                                CLOSE
                            ELSE 1 - ?DUP
                                0= IF
                                    ." DEL YOURFILE.TXT" CR
                                    DEL" YOURFILE.TXT"
                                ELSE 1 - ?DUP
                                    0= IF
                                        ." LOAD TSTWORDS.4TH" CR
                                        LOAD" TSTWORDS.4TH"
                                    ELSE
                                        ." abort" CR EXIT
                                    THEN                                        
                                THEN
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
THEN
;



RST_HERE

[THEN]

ECHO SD_TEST
