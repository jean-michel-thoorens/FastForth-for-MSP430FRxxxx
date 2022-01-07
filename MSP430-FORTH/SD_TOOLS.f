\ -*- coding: utf-8 -*-

\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, DOUBLE_INPUT, SD_CARD_LOADER
\
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
\
\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use
\
\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack
\
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<

; ---------------------------------------------------------------
; SD_TOOLS.f
; BASIC TOOLS for SD Card : DIR FAT SECTOR CLUSTER
; ---------------------------------------------------------------

\ first, we test for downloading driver only if UART TERMINAL target
    CODE ABORT_SD_TOOLS
    SUB #4,PSP
    MOV TOS,2(PSP)
    [UNDEFINED] LOAD"       \ "
    [IF]
    MOV #-1,0(PSP)
    [ELSE]
    MOV #0,0(PSP)
    [THEN]
    MOV &VERSION,TOS
    SUB #309,TOS        \                   FastForth V3.9
    COLON
    'CR' EMIT            \ return to column 1 without 'LF'
    ABORT" FastForth V3.9 please!"
    ABORT" Builds FastForth with SD_CARD_LOADER addon.."
    RST_RET              \ remove ABORT_UARTI2CS definition before resuming
    ;

    ABORT_SD_TOOLS

    MARKER {SD_TOOLS}

    [UNDEFINED] HERE
    [IF]
    CODE HERE
    MOV #HEREXEC,PC
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

    [UNDEFINED] MAX
    [IF]    \ define MAX and MIN
    CODE MAX    \    n1 n2 -- n3       signed maximum
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
    ENDCODE

    CODE MIN    \    n1 n2 -- n3       signed minimum
    CMP @PSP,TOS     \ n2-n1
    S<  ?GOTO BW1    \ n2<n1
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

    [UNDEFINED] U.R
    [IF]        \ defined in {UTILITY}
    : U.R                       \ u n --           display u unsigned in n width (n >= 2)
    >R  <# 0 # #S #>
    R> OVER - 0 MAX SPACES TYPE
    ;
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

\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]
\ create a primary defered word, i.e. with its default runtime beginning at the >BODY of the definition
    CODE CR     \ part I : DEFERed definition of CR
    MOV #NEXT_ADR,PC                \ [PFA] = NEXT_ADR
    ENDCODE

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]

\ https://forth-standard.org/standard/tools/DUMP
    [UNDEFINED] DUMP
    [IF]       \ defined in {UTILITY}
    CODE DUMP                   \ adr n  --   dump memory
    PUSH IP
    PUSH &BASEADR               \ save current base
    MOV #$10,&BASEADR           \ HEX base
    ADD @PSP,TOS                \ -- ORG END
    LO2HI
    SWAP                        \ -- END ORG
\    $FFF0 AND                   \ -- END ORG_modulo_16
    DO  CR                      \ generate line
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

\ display content of a sector
\   --------------------------------\
    CODE SECTOR.                    \ sector. --     don't forget to add decimal point to your sector number
\   --------------------------------\
BW1 MOV     TOS,X                   \ X = SectorH
    MOV     @PSP,W                  \ W = sectorL
    CALL    #R_SECT_WX              \ W = SectorLO  X = SectorHI
    COLON                           \
    SPACE <# #S #> TYPE             \ ud --            display the double number
    SD_BUF $200 DUMP CR ;           \ then dump the sector
\   --------------------------------\

\ display first sector of a Cluster
\   --------------------------------\
    CODE CLUSTER.                   \ cluster.  --        don't forget to add decimal point to your cluster number
\   --------------------------------\
BW2 BIT.B   #CD_SD,&SD_CDIN         \ test Card Detect: memory card present ?
    0<> IF                          \ no: force COLD
        MOV #COLD,PC                \ no
    THEN
    MOV.B &SecPerClus,W             \ SecPerClus(54321) = multiplicator
    MOV @PSP,X                      \ X = ClusterL
    BEGIN
        RRA W                       \ shift one right multiplicator
    U< WHILE                        \ carry clear
        ADD X,X                     \ (RLA) shift one left MULTIPLICANDlo16
        ADDC TOS,TOS                \ (RLC) shift one left MULTIPLICANDhi8
    REPEAT
    ADD     &OrgClusters,X          \ add OrgClusters = sector of virtual cluster 0 (word size)
    MOV     X,0(PSP)
    ADDC    #0,TOS                  \ don't forget carry
    GOTO    BW1                     \ jump to SECTOR
    ENDCODE
\   --------------------------------\

\   --------------------------------\
    CODE FAT                        \ Display FATsector
\   --------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \
    MOV     &OrgFAT1,0(PSP)         \
    MOV     #0,TOS                  \ FATsectorHI = 0
    GOTO    BW1                     \ jump to SECTOR
    ENDCODE
\   --------------------------------\

\   --------------------------------\
    CODE DIR                        \ Display CurrentDir first sector
\   --------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \           save TOS
    MOV     &DIRclusterL,0(PSP)     \
    MOV     &DIRclusterH,TOS        \
    GOTO    BW2                     \ jump to SECTOR
    ENDCODE
\   --------------------------------\

    RST_SET ECHO
