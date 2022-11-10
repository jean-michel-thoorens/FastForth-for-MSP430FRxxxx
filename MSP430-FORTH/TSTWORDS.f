\ -----------------------------
\ MSP-EXP430FR5969_TSTWORDS.f
\ -----------------------------

\ first, we do some tests allowing the download
    CODE ABORT_TSTWORDS
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #401,TOS        \ FastForth V4.1
    COLON
    'CR' EMIT            \ return to column 1 without 'LF'
    ABORT" FastForth V4.1 please!"
    RST_RET           \ remove ABORT_TEST_ASM definition before resuming
    ;

    ABORT_TSTWORDS      \ abort test

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.f)
; ------------------------------------------------------------------

    [UNDEFINED] 0=
    [IF]
\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
    CODE 0=
    SUB #1,TOS      \ 1 borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ 1 TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] DUP
    [IF]    \ define DUP and ?DUP
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

    [UNDEFINED] IF
    [IF]     \ define IF THEN

\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    CODE IF
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
    CODE THEN
    MOV &DP,0(TOS)          \ -- IFadr
    MOV @PSP+,TOS           \ --
    MOV @IP+,PC
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ELSE
    [IF]
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

    [UNDEFINED] SWAP
    [IF]
\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
    CODE SWAP
    PUSH TOS            \ 3
    MOV @PSP,TOS        \ 2
    MOV @RSP+,0(PSP)    \ 4
    MOV @IP+,PC         \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] BEGIN
    [IF]  \ define BEGIN UNTIL AGAIN WHILE REPEAT

\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
    CODE BEGIN
    MOV #BEGIN,PC
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

    [UNDEFINED] DO
    [IF]     \ define DO LOOP +LOOP

\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
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
    SUB #2,PSP          \
    MOV TOS,0(PSP)      \
    ADD #2,&DP          \   make room to compile xdo
    MOV &DP,TOS         \ -- HERE+2
    MOV #XDO,-2(TOS)    \   compile xdo
    ADD #2,&LEAVEPTR    \ -- HERE+2     LEAVEPTR+2
    MOV &LEAVEPTR,W     \
    MOV #0,0(W)         \ -- HERE+2     L-- 0, init
    MOV @IP+,PC
    ENDCODE IMMEDIATE

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

\ https://forth-standard.org/standard/core/LOOP
\ LOOP    DOadr --         L-- an an-1 .. a1 0
    CODE LOOP
    MOV #XLOOP,X
BW2 ADD #4,&DP          \ make room to compile two words
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

    HDNCODE XPLOO   \   +LOOP run time
    ADD TOS,0(RSP)  \ 4 increment INDEX by TOS value
    MOV @PSP+,TOS   \ 2 get new TOS, doesn't change flags
    GOTO BW1        \ 2
    ENDCODE         \

\ https://forth-standard.org/standard/core/PlusLOOP
\ +LOOP   adrs --   L-- an an-1 .. a1 0
    CODE +LOOP
    MOV #XPLOO,X
    GOTO BW2
    ENDCODE IMMEDIATE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

ECHO

; -----------------------------------------------------------------------
; test some assembler words and show how to mix FORTH/ASSEMBLER routines
; -----------------------------------------------------------------------

LOAD" \misc\TestASM.4th"

ECHO

; -------------------------------------
; here we returned in the TestWords.4th
; -------------------------------------

\ ----------
\ LOOP tests
\ ----------
: LOOP_TEST 8 0 DO I . LOOP
;

LOOP_TEST   \ you should see 0 1 2 3 4 5 6 7 -->


: LOOP_TEST1    \   n <LOOP_TEST1> ---
    BEGIN   DUP U. 1 -
    ?DUP
    0= UNTIL
;
\
\ : LOOP_MAX      \ FIND_NOTHING      --
\     0 0
\     DO
\     LOOP            \ 14 cycles by loop
\     ABORT" 65536 LOOP "
\ ;
\
: FIND_TEST            \ FIND_TEST <word>     --
   $20 WORD             \ -- c-addr
       50000 0
       DO              \ -- c-addr
           DUP
           FIND DROP DROP
       LOOP
    FIND
    0=  IF ABORT" <-- not found !"
        ELSE ABORT" <-- found !"
        THEN
 ;
\
\ \ seeking $ word, FIND jumps all words on their first character so time of word loop is 20 cycles
\ \ see FIND in the source file for more information
\ \
\ \ FIND_TEST <lastword> result @ 8MHz, monothread : 1,2s
\ \
\ \ FIND_TEST $ results @ 8MHz, monothread, 201 words in vocabulary FORTH :
\ \ 27 seconds with only FORTH vocabulary in CONTEXT
\ \ 540 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ \ 2.6866 us / word, 21,49 cycles / word (for 20 cycles calculated (see FIND in source file)
\ \
\ \
\ \ FIND_TEST $ results @ 8MHz, 2 threads, 201 words in vocabulary FORTH :
\ \ 13 second with only FORTH vocabulary in CONTEXT
\ \ 260 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ \ 1,293 us / word, 10,34 cycles / word
\ \
\ \ FIND_TEST $ results @ 8MHz, 4 threads, 201 words in vocabulary FORTH :
\ \ 8 second with only FORTH vocabulary in CONTEXT
\ \ 160 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ \ 0,796 us / word, 6,37 cycles / word
\ \
\ \ FIND_TEST $ results @ 8MHz, 8 threads, 201 words in vocabulary FORTH :
\ \ 4.66 second with only FORTH vocabulary in CONTEXT
\ \ 93 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ \ 0,4463 us / word, 3,7 cycles / word
\ \
\ \ FIND_TEST $ results @ 8MHz, 16 threads, 201 words in vocabulary FORTH :
\ \ 2,8 second with only FORTH vocabulary in CONTEXT
\ \ 56 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ \ 0,278 us / word, 2,22 cycles / word
\ \
\ \ --------
\ \ KEY test
\ \ --------
\ : KEY_TEST
\     ."  type a key : "
\     KEY EMIT    \ wait for a KEY, then emit it
\ ;
\ \ KEY_TEST

