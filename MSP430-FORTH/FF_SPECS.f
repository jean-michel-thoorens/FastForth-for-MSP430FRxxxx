\ -*- coding: utf-8 -*-
\
\ displays all FastForth specifications
\ 3 kb free mandatory.
\
\ FastForth kernel compilation minimal options:
\ TERMINAL3WIRES, TERMINAL4WIRES
\ MSP430ASSEMBLER, CONDCOMP

\ TARGET ( = the name of \INC\target.pat file without extension):
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
\ MY_MSP430FR5738_2
\ JMJ_BOX_2018_10_29    JMJ_BOX_2022_07_28
\
\ from scite editor : copy your TARGET selection in (shift+F8) parameter 1:
\                     copy COMPLEMENT if used in (shift+F8) parameter 2:
\
\ OR
\
\ from file explorer :  drag and drop this file onto SendSourceFileToTarget.bat
\                       then select your TARGET + COMPLEMENT when asked.
\
; ---------------------------------
; FF_SPECS.f
; ---------------------------------

\ first, we do some tests allowing the download
    CODE ABORT_FF_SPECS
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV &VERSION,TOS        \ ARG
    SUB #401,TOS            \ FastForth V4.1
    COLON
    'CR' EMIT               \ return to column 1, no 'LF'
    ABORT" FastForth V4.1 please!"
    RST_RET                 \ remove ABORT_FF_SPECS definition before resuming
    ;

    ABORT_FF_SPECS          \ run tests

; ------------------------------------------------------------------
; first we download the set of definitions we need, from CORE_ANS
; ------------------------------------------------------------------

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

    [UNDEFINED] U< [IF] \ define U> and U>
\ https://forth-standard.org/standard/core/Uless
\ U<    u1 u2 -- flag       test u1<u2, unsigned
    CODE U<
    SUB @PSP+,TOS   \ 2 u2-u1
    U< ?GOTO FW1
    0<> IF
BW1 MOV #-1,TOS     \ 1
    THEN
    MOV @IP+,PC     \ 4
    ENDCODE

\ https://forth-standard.org/standard/core/Umore
\ U>     n1 n2 -- flag
    CODE U>
    SUB @PSP+,TOS   \ 2
    U< ?GOTO BW1    \ 2 flag = true, Z = 0
FW1 AND #0,TOS      \ 1 Z = 1
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
    MOV #BEGIN,PC
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

    [UNDEFINED] DO [IF] \ define DO LOOP +LOOP

    HDNCODE XDO         \ DO run time
    MOV #$8000,X        \ 2 compute 8000h-limit = "fudge factor"
    SUB @PSP+,X         \ 2
    MOV TOS,Y           \ 1 loop ctr = index+fudge
    ADD X,Y             \ 1 Y = INDEX
    PUSHM #Z,X          \ 4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
    MOV @PSP+,TOS       \ 2
    MOV @IP+,PC         \ 4
    ENDCODE

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
    MOV #BEGIN,PC
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
            'SP' EMIT
            HI2LO
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

    [UNDEFINED] 2/ [IF]
\ https://forth-standard.org/standard/core/TwoDiv
\ 2/      x1 -- x2        arithmetic right shift
    CODE 2/
    RRA TOS
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

    [UNDEFINED] CR [IF]
\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device

\ create a primary defered word, i.e. with its default runtime beginning at the >BODY of the definition
    CODE CR     \ part I : DEFERed definition of CR
    MOV #NEXT_ADR,PC                \ [PFA] = NEXT_ADR
    ENDCODE

    :NONAME     \ part II : :NONAME part as default runtime of CR
    'CR' EMIT 'LF' EMIT
    ; IS CR                         \ set [PFA] of CR = >BODY addr of CR = CFA of :NONAME part

    [THEN]

    [UNDEFINED] CASE [IF]   \ define CASE OF ENDOF ENDCASE

\ https://forth-standard.org/standard/core/CASE
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

; --------------------------
; end of definitions we need
; --------------------------

    CODE 2*DUP
    SUB #2,PSP
    ADD TOS,TOS
    MOV TOS,0(PSP)
    MOV @IP+,PC
    ENDCODE

    [UNDEFINED] S? [IF] \
    CODE S?             \  sep ---          to compile: sep S? <string>sep
    MOV #S"+$0A,PC      \                   (S" + 10) --> PC
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ESC [IF]
    CODE ESC            \ we can't use  which is trapped by TERMINAL !
    CMP #0,&STATEADR
    0= IF MOV @IP+,PC   \ interpret time usage disallowed
    THEN
    COLON
    'ESC'               \ -- char escape
    POSTPONE LITERAL    \ compile-time code : lit 'ESC'
    POSTPONE EMIT       \ compile-time code : EMIT
    'SP'                \ char SPACE as separator for end of string
    POSTPONE S?         \ compile-time code : S?
    POSTPONE TYPE       \ compile-time code : TYPE
    ; IMMEDIATE
    [THEN]

    [DEFINED] FORTH [IF]    \ word-set addon ?
\ NFA address is always even
\ [NFA] = count_of_string + Immediate_flag
\ NFA + count_of_string_odd = CFA
\ NFA + count_of_string_even + 1 = CFA
    CODE BODY>SQNFA     \ BODY -- NFA(addr cnt)             BODY > SQuoteNFA
    SUB #2,PSP          \ -- x BODY
    SUB #4,TOS          \ -- x CFA
    MOV TOS,Y           \               Y = CFA
    MOV Y,X             \               X = CFA
    BEGIN
        SUB #2,X        \ --            X = CFA-2i = NFA ?
        MOV X,0(PSP)    \ -- CFA-2i x
        MOV.B @X+,TOS   \ -- CFA-2i cnt_test+Imm
        RRA TOS         \ -- CFA-2I cnt_test
        MOV TOS,W       \
        ADD #1,TOS
        BIT #1,W        \                   cnt_test even ?
        0= IF
            ADD #1,W    \                   if yes add #1 to cnt_test
        THEN
        ADD X,W         \                   CFA-2i + aligned_cnt_test
        CMP W,Y         \                   CFA-2i + aligned_cnt_test = CFA ?
    0<> WHILE           \                   out of loop if yes
        MOV @PSP,X      \                   loop back to test with CFA-2(i+1)
    REPEAT
    MOV @IP+,PC         \ -- addr cnt
    ENDCODE
    [THEN]

    : SPECS             \ to see all FastForth specifications
\
    RST_RET             \ before computing free bytes, remove all FF_SPECS previous definitions
    ECHO
    ESC [8;42;80t       \ set 42L * 80C terminal display
\
\   title in reverse video
    CR
    ESC [7m             \ Turn reverse video on
    CR ." FastForth V"
    VERSION @
    0 <# # 'BS' HOLD # '.' HOLD #S #> TYPE
    ."  for MSP430FR"
    HERE                \ HERE - MAIN_ORG = bytes code
    DEVICEID @          \ value kept in TLV area
    CASE
\
\ device_ID OF  ." xxxx," $MAIN_ORG ENDOF \ <-- add here your device
    $8102   OF  ." 5738,"   $C200   ENDOF
    $8103   OF  ." 5739,"   $C200   ENDOF
    $810D   OF  ." 5986,"   $4400   ENDOF
    $8160   OF  ." 5948,"   $4400   ENDOF
    $8169   OF  ." 5969,"   $4400   ENDOF
    $81A8   OF  ." 6989,"   $4400   ENDOF
    $81F0   OF  ." 4133,"   $C400   ENDOF
    $8240   OF  ." 2433,"   $C400   ENDOF
    $825D   OF  ." 5972,"   $4400   ENDOF
    $82A1   OF  ." 5994,"   $4000   ENDOF
    $830C   OF  ." 2355,"   $8000   ENDOF
    $830D   OF  ." 2353,"   $C000   ENDOF
    $831E   OF  ." 2155,"   $8000   ENDOF
    $831D   OF  ." 2153,"   $C000   ENDOF
    $832A   OF  ." 2476,"   $8000   ENDOF
    $832B   OF  ." 2475,"   $8000   ENDOF
    $833C   OF  ." 2633,"   $C400   ENDOF
    $833D   OF  ." 2533,"   $C400   ENDOF
    ABORT" xxxx <-- unrecognized device!"
    ENDCASE                             \ -- HERE MAIN_ORG
    ."  DTC"
    ['] ['] DUP @ $1284 =               \ DOCOL = CALL rDOCOL opcode
    IF ." =1," DROP                     \ [CFA] = CALL rDOCOL
    ELSE 2 + @ $1284 =                  \
        IF ." =2,"                      \ [CFA] = PUSH IP, [CFA+2] = CALL rDOCOL
        ELSE ." =3,"                    \ [CFA] = PUSH IP, [CFA+2] = MOV PC,IP
        THEN
    THEN
    'SP' EMIT
    THREADS @ U. 'BS' EMIT
    ." -Entry word set, "               \ number of Entry word set,
    FREQ_KHZ @ 0 1000 UM/MOD U.         \ frequency
    ?DUP IF 'BS' EMIT ',' EMIT U.       \ if remainder
    THEN ." MHz, "                      \ MCLK
    - U. ." bytes"                      \ HERE - MAIN_ORG = number of bytes code,
    ESC [0m                             \ Turn off character attributes
    CR

\
\   FORTH specs
    ." /COUNTED-STRING   = 255" CR
    ." /HOLD             = 34" CR
    ." /PAD              = 84" CR
    ." ADDRESS-UNIT-BITS = 16" CR
    ." FLOORED DIVISION  = "
    [DEFINED] SM/REM [IF] ." false" [THEN]
    [DEFINED] FM/MOD [IF] ." true" [THEN]
    CR
    ." MAX-CHAR          = 255" CR
    ." MAX-N             = 32767" CR
    ." MAX-U             = 65535" CR
    ." MAX-D             = 2147483647" CR
    ." MAX-UD            = 4294967295" CR
    ." STACK-CELLS       = 48" CR
    ." RETURN-STACK-CELLS= 48" CR
    ." Definitions are forced UPPERCASE" CR
\    ." BACKGROUND, COLD, WARM, ABORT customizable" CR
\    ." automatic garbage collector" CR

\   kernel specs
    CR ESC [7m ." KERNEL add-ons" ESC [0m CR  \ subtitle in reverse video
    KERNEL_ADDON @
    2*DUP   0< IF ." 32.768kHz LF XTAL" CR THEN         \ BIT14
    2*DUP   0< IF ." /CTS " THEN                        \ BIT13
    2*DUP   0< IF ." /RTS " THEN                        \ BIT12
    2*DUP   0< IF ." XON/XOFF "  THEN                   \ BIT11
    2*DUP   0< IF ." Half-Duplex "  THEN                \ BIT10
    2*DUP   0< IF ." I2C_Master TERMINAL"               \ BIT9
            ELSE  ." UART TERMINAL"                     \ /BIT9
            THEN CR
    2*DUP   0< IF 2*DUP
                0< IF ." DOUBLE and "                   \  BIT8 + BIT7
                THEN  ." Q15.16 numbers handling" CR
            ELSE  2*DUP
                0< IF ." DOUBLE numbers handling" CR    \ /BIT8 + BIT7
                THEN
            THEN
    2*DUP   0< IF       ." MSP430 16/20bits"            \ BIT6   BIT5
            ELSE  2*DUP ." MSP430 16bits"               \ /BIT6
                0< IF   ."  (20bits addr)"              \        BIT5
                THEN
            THEN    ."  assembler, with TI's syntax" CR
    DROP
    [DEFINED] FORTH [IF] ." word-set management" CR 
    [THEN]
    [DEFINED] LOAD" [IF] ." SD_CARD Load + Bootloader" CR
    [THEN]
    [DEFINED] READ" [IF] ." SD_CARD Read/Write/Del/CopyTERM2SD" CR
    [THEN]

\   extensions
    CR ESC [7m ." EXTENSIONS" ESC [0m   \ subtitle in reverse video
    [DEFINED] {CORE_ANS} [IF] CR ." CORE ANS94 'CORETEST passed'"
    [THEN]
    [DEFINED] {DOUBLE}   [IF] CR ." DOUBLE numbers set"
    [THEN]
    [DEFINED] {UTILITY}  [IF] CR ." UTILITY"
    [THEN]
    [DEFINED] {FIXPOINT} [IF] CR ." Q15.16 ADD SUB MUL DIV"
    [THEN]
    [DEFINED] {CORDIC}   [IF] CR ." CORDIC engine"
    [THEN]
    [DEFINED] {SD_TOOLS} [IF] CR ." SD_TOOLS"
    [THEN]
    [DEFINED] {RTC}      [IF] CR ." RTC utility"
    [THEN]
    [DEFINED] {UARTI2CS} [IF] CR ." UART to I2C_FastForth bridge"
    [THEN]
    CR

\   display word-sets
\   ------------------------------------\
    LASTVOC                             \ -- VOCLINK addr.
    BEGIN
        @ ?DUP                          \ -- VOCLINK            word-set here ?
    WHILE                               \ -- VLK
\       --------------------------------\
        ESC [7m                         \                       word-set TITLE in reverse video
        DUP THREADS @ 2* -              \ -- VLK WORDSET_BODY
        [DEFINED] FORTH                 \                       word-set addon ?
        [IF]    DUP BODY>SQNFA          \ -- VLK WRDST_BODY addr cnt
        [ELSE]  OVER @                  \ -- VLK WRDST_BODY NEXT_VLINK
                IF S" hidden"           \                       if next_vlink <>0
                ELSE S" FORTH"          \                       if next_vlink = 0
                THEN                    \ -- VLK WRDST_BODY addr cnt
        [THEN]  TYPE                    \                       type word-set name
        ."  word-set"                   \ -- VLK WRDST_BODY
        ESC [0m CR
\       --------------------------------\
\       : WORDS                         \ --
\       --------------------------------\
\       CR                              \
\       CONTEXT @                       \ -- VOC_BODY
        PAD_ORG                         \ -- VOC_BODY PAD                  MOVE all threads from VOC_BODY to PAD_ORG
        THREADS @ 2*                    \ -- VOC_BODY PAD THREADS*2
        MOVE                            \ -- vocabulary entries are copied in PAD_ORG
        BEGIN                           \ --
            0 DUP                       \ -- ptr=0 MAX=0
            THREADS @ 2* 0              \ -- ptr=0 MAX=0 THREADS*2 0
                DO                      \ -- ptr MAX            I =  PAD_ptr = thread*2
                DUP I PAD_ORG + @       \ -- ptr MAX MAX NFAx
                    U< IF               \ -- ptr MAX            if MAX U< NFAx
                        DROP DROP I     \ --                    drop ptr and MAX
                        DUP PAD_ORG + @ \ -- new_ptr new_MAX
                    THEN                \
                2 +LOOP                 \ -- ptr MAX
            ?DUP                        \ -- ptr MAX MAX | -- ptr 0 (all threads in PAD = 0)
        WHILE                           \ -- ptr MAX                    replace it by its LFA
            DUP                         \ -- ptr MAX MAX
            2 - @                       \ -- ptr MAX [LFA]
            ROT                         \ -- MAX [LFA] ptr
            PAD_ORG +                   \ -- MAX [LFA] thread
            !                           \ -- MAX                MAX=highest_NFA [LFA]=new_NFA updates PAD_ORG+ptr
            COUNT 2/                    \ -- addr name_count    2/ to hide Immediate flag
            DUP >R TYPE                 \ --      R-- count
            $10 R> - SPACES             \ --      R--           complete with spaces modulo 16 chars
        REPEAT                          \ --
        DROP                            \ ptr --
\       ;                               \ all threads in PAD are filled with 0
\       --------------------------------\
        CR                              \ -- VLINK              definitions display
    REPEAT
\   ------------------------------------\ --
    SYS                                 \ [0] SYS = WARM
    ;

SPECS \ performs RST_RET and displays FastForth specs
