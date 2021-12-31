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

\ first, we test for downloading driver only if UART TERMINAL target
    CODE ABORT_SD_TEST
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #309,TOS        \                   FastForth V3.9
    COLON
    'CR' EMIT            \ return to column 1 without 'LF'
    ABORT" FastForth V3.9 please!"
    [UNDEFINED] WRITE
    [IF]
        1 ABORT" no SD_CARD_READ_WRITE addon!"
    [THEN]
    RST_RET           \ remove ABORT_SD_TEST definition before resuming
    ;

    ABORT_SD_TEST

    MARKER {SD_TEST}

\ https://forth-standard.org/standard/core/EXIT
\ EXIT     --      exit a colon definition; CALL #EXIT performs ASMtoFORTH (10 cycles)
\                                           JMP #EXIT performs EXIT
    [UNDEFINED] EXIT
    [IF]
    CODE EXIT
    MOV @RSP+,IP    \ 2 pop previous IP (or next PC) from return stack
    MOV @IP+,PC     \ 4 = NEXT
    ENDCODE         \ 6 (ITC-2)
    [THEN]

\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
    [UNDEFINED] SWAP
    [IF]
    CODE SWAP
    MOV @PSP,W      \ 2
    MOV TOS,0(PSP)  \ 3
    MOV W,TOS       \ 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
    [UNDEFINED] >BODY
    [IF]
    CODE >BODY
    ADD #4,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
    [UNDEFINED] 0=
    [IF]
    CODE 0=
    SUB #1,TOS      \ borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    [UNDEFINED] IF
    [IF]     \ define IF and THEN
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

\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
    [UNDEFINED] ELSE
    [IF]
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

\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
    [UNDEFINED] BEGIN
    [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT
    CODE BEGIN
    MOV #HEREXEC,PC
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

\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
    [UNDEFINED] DO
    [IF]                \ define DO LOOP +LOOP
    HDNCODE XDO         \ DO run time
    MOV #$8000,X        \ 2 compute 8000h-limit = "fudge factor"
    SUB @PSP+,X         \ 2
    MOV TOS,Y           \ 1 loop ctr = index+fudge
    ADD X,Y             \ 1 Y = INDEX
    PUSHM #2,X          \ 4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
    MOV @PSP+,TOS       \ 2
    MOV @IP+,PC         \ 4
    ENDCODE

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
    HDNCODE XLOOP       \   LOOP run time
    ADD #1,0(RSP)       \ 4 increment INDEX
BW1 BIT #$100,SR        \ 2 is overflow bit set?
    0= IF               \   branch if no overflow
        MOV @IP,IP
        MOV @IP+,PC
    THEN
    ADD #4,RSP          \ 1 empties RSP
    ADD #2,IP           \ 1 overflow = loop done, skip branch ofs
    MOV @IP+,PC         \ 4 14~ taken or not taken xloop/loop
    ENDCODE             \

    CODE LOOP
    MOV #XLOOP,X
BW2 ADD #4,&DP              \ make room to compile two words
    MOV &DP,W
    MOV X,-4(W)             \ xloop --> HERE
    MOV TOS,-2(W)           \ DOadr --> HERE+2
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
    HDNCODE XPLOO   \   +LOOP run time
    ADD TOS,0(RSP)  \ 4 increment INDEX by TOS value
    MOV @PSP+,TOS   \ 2 get new TOS, doesn't change flags
    GOTO BW1        \ 2
    ENDCODE         \

    CODE +LOOP
    MOV #XPLOO,X
    GOTO BW2        \ goto BW1 LOOP
    ENDCODE IMMEDIATE
    [THEN]

\ https://forth-standard.org/standard/core/I
\ I        -- n   R: sys1 sys2 -- sys1 sys2
\                  get the innermost loop index
    [UNDEFINED] I
    [IF]
    CODE I
    SUB #2,PSP              \ 1 make room in TOS
    MOV TOS,0(PSP)          \ 3
    MOV @RSP,TOS            \ 2 index = loopctr - fudge
    SUB 2(RSP),TOS          \ 3
    MOV @IP+,PC             \ 4 13~
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    [UNDEFINED] +
    [IF]
    CODE +
    ADD @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Minus
\ -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
    [UNDEFINED] -
    [IF]
    CODE -
    SUB @PSP+,TOS   \ 2  -- n2-n1 ( = -n3)
    XOR #-1,TOS     \ 1
    ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] MAX
    [IF]   \ define MAX and MIN
    CODE MAX    \    n1 n2 -- n3       signed maximum
    CMP @PSP,TOS    \ n2-n1
    S< ?GOTO FW1    \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
    ENDCODE

    CODE MIN    \    n1 n2 -- n3       signed minimum
    CMP @PSP,TOS    \ n2-n1
    S< ?GOTO BW1    \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
    [UNDEFINED] C@
    [IF]
    CODE C@
    MOV.B @TOS,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
    [UNDEFINED] SPACE
    [IF]
    : SPACE
    $20 EMIT ;
    [THEN]

\ https://forth-standard.org/standard/core/SPACES
\ SPACES   n --            output n spaces
    [UNDEFINED] SPACES
    [IF]
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

\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
    [UNDEFINED] DUP
    [IF]    \ define DUP and DUP?
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

\ https://forth-standard.org/standard/core/OVER
\ OVER    x1 x2 -- x1 x2 x1
    [UNDEFINED] OVER
    [IF]
    CODE OVER
    MOV TOS,-2(PSP)     \ 3 -- x1 (x2) x2
    MOV @PSP,TOS        \ 2 -- x1 (x2) x1
    SUB #2,PSP          \ 1 -- x1 x2 x1
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
    [UNDEFINED] >R
    [IF]
    CODE >R
    PUSH TOS
    MOV @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
    [UNDEFINED] R>
    [IF]
    CODE R>
    SUB #2,PSP      \ 1
    MOV TOS,0(PSP)  \ 3
    MOV @RSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT
    [UNDEFINED] CONSTANT
    [IF]
    : CONSTANT
    CREATE
    HI2LO
    MOV TOS,-2(W)           \   PFA = n
    MOV @PSP+,TOS
    MOV @RSP+,IP
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/STATE
\ STATE   -- a-addr       holds compiler state
    [UNDEFINED] STATE
    [IF]
    STATEADR CONSTANT STATE
    [THEN]

\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]

\    DEFER CR    \ DEFERed definition, by default executes that of :NONAME
\ create a primary defered word, i.e. with its default runtime beginning at the >BODY of the definition
    CODE CR     \ part I : DEFERed definition of CR
    MOV #NEXT_ADR,PC                \ [PFA] = NEXT_ADR
    ENDCODE

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] U.R
    [IF]        \ defined in {UTILITY}
    : U.R                       \ u n --           display u unsigned in n width (n >= 2)
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
    [UNDEFINED] BASE
    [IF]
    BASEADR  CONSTANT BASE
    [THEN]

\ https://forth-standard.org/standard/tools/DUMP
    [UNDEFINED] DUMP
    [IF]       \ defined in {UTILITY}
    CODE DUMP               \ adr n  --   dump memory
    PUSH IP
    PUSH &BASE              \ save current base
    MOV #$10,&BASE          \ HEX base
    ADD @PSP,TOS            \ -- ORG END
    LO2HI
    SWAP                    \ -- END ORG
    DO                      \ generate line
        I 4 U.R SPACE       \ generate address
        I 8 + I
        DO I C@ 3 U.R LOOP
        SPACE
        I $10 + I 8 +
        DO I C@ 3 U.R LOOP
        SPACE SPACE
        I $10 + I           \ display 16 chars
        DO I C@ $7E MIN $20 MAX EMIT LOOP
        CR
    $10 +LOOP
    R> BASE !               \ restore current base
    ;
    [THEN]

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #BEGIN,PC
    ENDCODE
    [THEN]


\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
    [UNDEFINED] DROP
    [IF]
    CODE DROP
    MOV @PSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
    [UNDEFINED] 1+
    [IF]
    CODE 1+
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    [UNDEFINED] =
    [IF]
    CODE =
    SUB @PSP+,TOS   \ 2
    0<> IF          \ 2
        AND #0,TOS  \ 1
        MOV @IP+,PC \ 4
    THEN
    XOR #-1,TOS     \ 1 flag Z = 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/CASE
    [UNDEFINED] CASE
    [IF]
    : CASE
    0
    ; IMMEDIATE \ -- #of-1

\ https://forth-standard.org/standard/core/OF
    : OF \ #of-1 -- orgOF #of
    1+	                    \ count OFs
    >R	                    \ move off the stack in case the control-flow stack is the data stack.
    POSTPONE OVER
    POSTPONE =              \ copy and test case value
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

\ SD_EMIT  c --    output char c to a SD_CARD file opened as write
    CODE SD_EMIT
    CMP #$200,&BufferPtr        \ 512 bytes by sector
    U>= IF                      \ if file buffer is full
        CALL &WRITE+2           \ CALL #Write_File ; BufferPtr = 0
    THEN
    MOV &BufferPtr,Y            \ 3
    MOV.B TOS,SD_BUF(Y)         \ 3
    ADD #1,&BufferPtr           \ 4
    MOV @PSP+,TOS               \ 2
    MOV @IP+,PC
    ENDCODE

    : DOESWRITE
    ['] SD_EMIT IS EMIT
    MAIN_ORG HERE OVER - DUMP
    ['] EMIT >BODY IS EMIT
    CLOSE
    ;

    : SD_TEST
    ECHO
    'CR' EMIT
    CR
    ." ----------" CR
    ." Bootloader" CR
    ." ----------" CR
    ." ? Fast Forth Specifs" CR
    ." 0 Set date and time" CR
    ." 1 Load {UTILITY} words" CR
    ." 2 Load {SD_TOOLS} words" CR
    ." 3 Load {CORE_COMP} words" CR
    ." 4 Load ANS core tests" CR
    ." 5 Load a source file to make 10k program" CR
    ." 6 Read it only (47k)" CR
    ." 7 write FORTH dump in YOURFILE.TXT" CR
    ." 8 append FORTH dump to YOURFILE.TXT" CR
    ." 9 delete YOURFILE.TXT" CR
    ." your choice: "
    KEY DUP EMIT
    NOECHO
    {SD_TEST}                           \ remove {SD_TEST} application
    CASE
    '?' OF  LOAD" FF_SPECS.4TH" ENDOF   \
    '0' OF  LOAD" RTC.4TH"      ENDOF
    '1' OF  LOAD" UTILITY.4TH"  ENDOF
    '2' OF  LOAD" SD_TOOLS.4TH" ENDOF
    '3' OF  LOAD" CORE_ANS.4TH" ENDOF
    '4' OF  LOAD" CORETEST.4TH" ENDOF
    '5' OF  LOAD" PROG10K.4TH"  ENDOF   \ download one ko, so no erasure here
    '6' OF  READ" PROG10K.4TH"
            BEGIN READ                  \ sequentially read 512 bytes
            UNTIL               ENDOF   \ prog10k.4TH is closed
    '7' OF  WRITE" YOURFILE.TXT"
            DOESWRITE           ENDOF
    '8' OF  APPEND" YOURFILE.TXT"
            DOESWRITE           ENDOF
    '9' OF  DEL" YOURFILE.TXT"  ENDOF
    ENDCASE
    CR
    ;

SD_TEST
