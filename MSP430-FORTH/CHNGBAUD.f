\ -*- coding: utf-8 -*-
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    CHIPSTICK_FR2433    MSP_EXP430FR2355
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

; ------------
; CHNGBAUD.f
; ------------

\ first, we do some tests allowing the download
    CODE I2CTERM_ABORT
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #$3C00,TOS          \ BIT13|BIT12|BIT11|BIT10 test (UART TERMINAL test)
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (UART TERMINAL), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #401,TOS            \ FastForth V4.1
    COLON
    $0D EMIT                \ return to column 1 without CR
    ABORT" FastForth V4.1 please!"
    ABORT" <-- Ouch! unexpected I2C_FastForth target!"
    RST_RET             \ remove ABORT_UARTI2CS definition before resuming
    ;

I2CTERM_ABORT

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.f)
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

    [UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
    CODE DROP
    MOV @PSP+,TOS   \ 2
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

    [UNDEFINED] CR [IF]
\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device

\    DEFER CR    \ DEFERed definition, by default executes that of :NONAME
    CODE CR
    MOV #NEXT_ADR,PC    \ compile same as DEFER
    ENDCODE

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]

    [UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
    CODE 1+
    ADD #1,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] U/ [IF]
\ U/   u1 u2 -- q   unsigned 16/16->q16
    CODE U/
    SUB #2,PSP
    MOV #0,0(PSP)   \ -- u1lo u1hi u2
    CALL #MUSMOD    \ -- r qlo qhi
    MOV @PSP,TOS    \ -- r qlo qlo
    ADD #4,PSP      \ -- qlo
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

    [UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    CODE =
    SUB @PSP+,TOS   \ 2
    0<> IF          \ 2
        AND #0,TOS  \ 1 flag Z = 1
    ELSE            \ 2
        XOR #-1,TOS \ 1
    THEN
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] < [IF]  \ define < and >
\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
    CODE <
    SUB @PSP+,TOS   \ 1 TOS=n2-n1
    S< ?GOTO FW1    \ 2 signed
    0<> IF          \ 2
BW1 MOV #-1,TOS \ 1 flag Z = 0
    THEN
    MOV @IP+,PC
    ENDCODE

\ https://forth-standard.org/standard/core/more
\ >     n1 n2 -- flag         test n1>n2, signed
    CODE >
    SUB @PSP+,TOS   \ 2 TOS=n2-n1
    S< ?GOTO BW1    \ 2 --> +5
FW1 AND #0,TOS      \ 1 flag Z = 1
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] IF [IF] \ define IF THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
    CODE IF
    SUB #2,PSP          \
    MOV TOS,0(PSP)      \
    MOV &DP,TOS         \ -- HERE
    ADD #4,&DP          \           compile one word, reserve one word
    MOV #QFBRAN,0(TOS)  \ -- HERE   compile QFBRAN
    ADD #2,TOS          \ -- HERE+2=IFadr
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

    [UNDEFINED] DO [IF] \ define DO LOOP +LOOP
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

    [UNDEFINED] CASE [IF]   \ define CASE OF ENDOF ENDCASE
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

; --------------------------
; end of definitions we need
; --------------------------

    [UNDEFINED] S_ [IF]
    CODE S_             \           Squote alias with blank instead quote separator
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV #'SP',TOS
    MOV #S"+10,PC       \           addr S" + 10 --> PC
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ESC [IF]
    CODE ESC
    CMP #0,&STATEADR
    0= IF MOV @IP+,PC   \ interpret time use is disallowed
    THEN
    COLON
    $1B                 \ -- char escape
    POSTPONE LITERAL    \ compile-time code : lit $1B
    POSTPONE EMIT       \ compile-time code : EMIT
    POSTPONE S_         \ compile-time code : S_ <escape_sequence>
    POSTPONE TYPE       \ compile-time code : TYPE
    ; IMMEDIATE
    [THEN]

    : BAD_MHz
    $20 DUP EMIT
            ABORT" only for 1, 2, 4, 8, 12, 16, 20, 24 MHz MCLK!"
    ;

    : OVER_BDS
    $20 DUP EMIT ESC [7m    \ set reverse video
                ." with MCLK = " FREQ_KHZ @ 1000 U/ .
            ABORT" MHz ? don't dream!"
    ;

    : CHNGBAUD                  \ only for 1, 4, 8, 12, 16, 20, 24 MHz
    RST_RET                     \ removes this created word (garbage collector)
    ECHO
    ESC [8;42;80t      \ set 42L * 80C terminal display
    41 0 DO CR LOOP     \ to avoid erasing any line of source, create 42-1 empty lines
    ESC [H              \ cursor home

    FREQ_KHZ @ DUP >R               \ r-- target MCLCK frequency in MHz
    ." target MCLK = " 1000 U/ . ." MHz" CR
    ." choose your baudrate:" CR
    ."   0 --> 6 MBds" CR        \ >= 20 MHz
    ."   1 --> 5 MBds" CR        \ >= 16 MHz
    ."   2 --> 4 MBds" CR        \ >= 16 MHz
    ."   3 --> 3 MBds" CR        \ >= 12 MHz
    ."   4 --> 1843200 Bds" CR   \ >= 8 MHz
    ."   5 --> 921600 Bds" CR    \ >= 4 MHz
    ."   6 --> 460800 Bds" CR    \ >= 2 MHz
    ."   7 --> 230400 Bds" CR    \ >= 1 MHz
    ."   8 --> 115200 Bds" CR    \ >= 500 kHz
    ."   9 --> 57600 Bds" CR
    ."   A --> 38400 Bds" CR
    ."   B --> 19200 Bds" CR
    ."   C --> 9600 Bds" CR
    ."   D --> DMX interface (250000 Bds)" CR
    ."   M --> MIDI interface (31250 Bds)" CR
    ." other --> quit" CR
    ." your choice: "
    KEY
    CASE
    #'0' OF  ." 6 MBds"          \ add this to the current line
            R> CASE
                #24000  OF $4  $0       ENDOF \ -- TERM_BRW  TERM_MCTLW
                #20000  OF $3  $4900    ENDOF
                20000 <
                IF OVER_BDS    \ < 20 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'1' OF  ." 5 MBds"
            R> CASE
                #24000  OF $4  $EE00    ENDOF
                #20000  OF $4  $0       ENDOF
                20000 <
                IF OVER_BDS    \ < 16 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'2' OF  ." 4 MBds"
            R> CASE
                #24000  OF $6  $0       ENDOF
                #20000  OF $5  $0       ENDOF
                #16000  OF $4  $0       ENDOF
                16000 <
                IF OVER_BDS    \ < 16 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'3' OF  ." 3 MBds"
            R> CASE
                #24000  OF $8  $0       ENDOF
                #20000  OF $6  $D600    ENDOF
                #16000  OF $5  $4900    ENDOF
                #12000  OF $4  $0       ENDOF
                12000 <
                IF OVER_BDS    \ < 12 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'4' OF  ." 1843200 Bds"
            R> CASE
                #24000  OF $0D $0200    ENDOF
                #20000  OF $0A $DF00    ENDOF
                #16000  OF $8  $D600    ENDOF
                #12000  OF $6  $AA00    ENDOF
                #8000   OF $5  $9200    ENDOF
                8000 <
                IF OVER_BDS    \ < 8 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'5' OF  ." 921600 Bds"
            R> CASE
                #24000  OF $1  $00A1    ENDOF
                #20000  OF $1  $B751    ENDOF
                #16000  OF $11 $4A00    ENDOF
                #12000  OF $0D $0200    ENDOF
                #8000   OF $8  $D600    ENDOF
                #4000   OF $4  $4900    ENDOF
                4000 <
                IF OVER_BDS    \ < 4 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'6' OF  ." 460800 Bds"
            R> CASE
                #24000  OF $3  $0241    ENDOF
                #20000  OF $2  $92B1    ENDOF
                #16000  OF $2  $BB21    ENDOF
                #12000  OF $1  $00A1    ENDOF
                #8000   OF $11 $4A00    ENDOF
                #4000   OF $8  $D600    ENDOF
                #2000   OF $4  $4900    ENDOF
                2000 <
                IF OVER_BDS    \ < 2 MHz --> abort
                THEN BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'7' OF  ." 230400 Bds"
            R> CASE
                #24000  OF $6  $2081    ENDOF
                #20000  OF $5  $EE61    ENDOF
                #16000  OF $4  $5551    ENDOF
                #12000  OF $3  $0241    ENDOF
                #8000   OF $2  $BB21    ENDOF
                #4000   OF $11 $4A00    ENDOF
                #2000   OF $8  $D600    ENDOF
                #1000   OF $4  $4900    ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'8' OF  ." 115200 Bds"
            R> CASE
                #24000  OF $0D $4901    ENDOF
                #20000  OF $0A $AD01    ENDOF
                #16000  OF $8  $F7A1    ENDOF
                #12000  OF $6  $2081    ENDOF
                #8000   OF $4  $5551    ENDOF
                #4000   OF $2  $BB21    ENDOF
                #2000   OF $11 $4A00    ENDOF
                #1000   OF $8  $D600    ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'9' OF  ." 57600 Bds"
            R> CASE
                #24000  OF $1A $D601    ENDOF
                #20000  OF $15 $00A1    ENDOF
                #16000  OF $11 $DD51    ENDOF
                #12000  OF $0D $4901    ENDOF
                #8000   OF $8  $F7A1    ENDOF
                #4000   OF $4  $5551    ENDOF
                #2000   OF $2  $BB21    ENDOF
                #1000   OF $11 $4A00    ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'A' OF  ." 38400 Bds"
            R> CASE
                #24000  OF $27 $0011    ENDOF
                #20000  OF $20 $BF01    ENDOF
                #16000  OF $1A $D601    ENDOF
                #12000  OF $13 $5581    ENDOF
                #8000   OF $0D $4901    ENDOF
                #4000   OF $6  $2081    ENDOF
                #2000   OF $3  $0241    ENDOF
                #1000   OF $1  $00A1    ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'B' OF  ." 19200 Bds"
            R> CASE
                #24000  OF $4E $0021    ENDOF
                #20000  OF $41 $D611    ENDOF
                #16000  OF $34 $4911    ENDOF
                #12000  OF $27 $0011    ENDOF
                #8000   OF $1A $D601    ENDOF
                #4000   OF $0D $4901    ENDOF
                #2000   OF $6  $2081    ENDOF
                #1000   OF $3  $0241    ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'C' OF  ." 9600 Bds"
            R> CASE
                #24000  OF $9C $0041    ENDOF
                #20000  OF $82 $2531    ENDOF
                #16000  OF $68 $D621    ENDOF
                #12000  OF $4E $0021    ENDOF
                #8000   OF $34 $4911    ENDOF
                #4000   OF $1A $D601    ENDOF
                #2000   OF $13 $4901    ENDOF
                #1000   OF $6  $2081    ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'D' OF  ." DMX interface (250000 Bds)"
            R> CASE
                #24000  OF $6  $1       ENDOF
                #20000  OF $5  $1       ENDOF
                #16000  OF $4  $1       ENDOF
                #12000  OF $3  $1       ENDOF
                #8000   OF $2  $1       ENDOF
                #4000   OF $10 $0       ENDOF
                #2000   OF $8  $0       ENDOF
                #1000   OF $4  $0       ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
    #'M' OF  ." MIDI interface (31250 Bds)"
            R> CASE
                #24000  OF $30 $1       ENDOF
                #20000  OF $28 $1       ENDOF
                #16000  OF $20 $1       ENDOF
                #12000  OF $18 $1       ENDOF
                #8000   OF $10 $1       ENDOF
                #4000   OF $8  $1       ENDOF
                #2000   OF $4  $1       ENDOF
                #1000   OF $2  $1       ENDOF
                BAD_MHz    \ other MHz --> abort
            ENDCASE
        ENDOF
        ABORT" "    \ ABORT" " displays nothing
    ENDCASE
    TERMMCTLW_RST !             \ set UCAxMCTLW value in FRAM
    TERMBRW_RST !               \ set UCAxBRW value in FRAM
    CR ESC [7m                  \ escape sequence to set reverse video
    ." Change baudrate in Teraterm, save its setup, then hit a key."
    ESC [0m
    CR
    KEY
    0 SYS
    ;

    CHNGBAUD
