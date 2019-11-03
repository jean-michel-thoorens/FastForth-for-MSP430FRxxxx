\ -*- coding: utf-8 -*-

; ---------------------------------------------------------------
; SD_TOOLS.f : BASIC TOOLS for SD Card : DIR FAT SECTOR CLUSTER
; ---------------------------------------------------------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, DOUBLE_INPUT, SD_CARD_LOADER
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
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

[DEFINED] {SD_TOOLS} [IF]  {SD_TOOLS} [THEN]

[UNDEFINED] {SD_TOOLS} [IF]

PWR_STATE

[UNDEFINED] MARKER [IF]
\  https://forth-standard.org/standard/core/MARKER
\  MARKER
\ ( "<spaces>name" -- )
\ Skip leading space delimiters. Parse name delimited by a space. Create a definition for name
\ with the execution semantics defined below.
\ 
\ name Execution: ( -- )
\ Restore all dictionary allocation and search order pointers to the state they had just prior to the
\ definition of name. Remove the definition of name and all subsequent definitions. Restoration
\ of any structures still existing that could refer to deleted definitions or deallocated data space is
\ not necessarily provided. No other contextual information such as numeric base is affected
\
: MARKER
CREATE
HI2LO
MOV &LASTVOC,0(W)   \ [BODY] = LASTVOC
SUB #2,Y            \ 1 Y = LFA
MOV Y,2(W)          \ 3 [BODY+2] = LFA = DP to be restored
ADD #4,&DP          \ 3 add 2 cells
LO2HI
DOES>
HI2LO
MOV @RSP+,IP        \ -- PFA
MOV @TOS+,&INIVOC   \       set VOC_LINK value for RST_STATE
MOV @TOS,&INIDP     \       set DP value for RST_STATE
MOV @PSP+,TOS       \ --
MOV #RST_STATE,PC   \       execute RST_STATE, PWR_STATE then STATE_DOES
ENDCODE
[THEN]

MARKER {SD_TOOLS}

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] MAX [IF]    \ MAX and MIN are defined in {UTILITY}

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
MOV rDOVAR,PC
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

[UNDEFINED] U.R [IF]        \ defined in {UTILITY}
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]

[UNDEFINED] DO [IF]
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
[THEN]

[UNDEFINED] LOOP [IF]
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
[THEN]

[UNDEFINED] +LOOP [IF]
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

\ display content of a sector
\ ----------------------------------\
CODE SECTOR                         \ sector. --     don't forget to add decimal point to your sector number
\ ----------------------------------\
BW1 MOV     TOS,X                   \ X = SectorH
    MOV     @PSP,W                  \ W = sectorL
    CALL    &ReadSectorWX           \ W = SectorLO  X = SectorHI
COLON                               \
    <# #S #> TYPE SPACE             \ ud --            display the double number
    SD_BUF $200 DUMP CR ;           \ then dump the sector
\ ----------------------------------\

\ display first sector of a Cluster
\ ----------------------------------\
CODE CLUSTER                        \ cluster.  --        don't forget to add decimal point to your cluster number
\ ----------------------------------\
BW2 MOV.B &SecPerClus,W             \ SecPerClus(54321) = multiplicator
    MOV @PSP,X                      \ X = ClusterL
    GOTO FW1                        \
    BEGIN
        ADD X,X                     \ (RLA) shift one left MULTIPLICANDlo16
        ADDC TOS,TOS                \ (RLC) shift one left MULTIPLICANDhi8
FW1     RRA W                       \ shift one right multiplicator
    U>= UNTIL                       \ carry set
    ADD     &OrgClusters,X          \ add OrgClusters = sector of virtual cluster 0 (word size)
    MOV     X,0(PSP)      
    ADDC    #0,TOS                  \ don't forget carry
    GOTO    BW1                     \ jump to SECTOR
ENDCODE
\ ----------------------------------\

\ ----------------------------------\
CODE FAT                            \ Display CurFATsector
\ ----------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \
    MOV     &OrgFAT1,0(PSP)         \
    MOV     #0,TOS                  \ FATsectorHI = 0
    GOTO    BW1                     \ jump to SECTOR
ENDCODE
\ ----------------------------------\

\ ----------------------------------\
CODE DIR                            \ Display CurrentDir first sector
\ ----------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \           save TOS
    MOV     &DIRclusterL,0(PSP)     \
    MOV     &DIRclusterH,TOS        \
    CMP     #0,TOS
    0<>     ?GOTO BW2               \ jump to CLUSTER
    CMP     #1,0(PSP)               \ cluster 1 ?
    0<>     ?GOTO BW2               \ jump to CLUSTER
    MOV     &OrgRootDir,0(PSP)      \ if yes, special case of FAT16 OrgRootDir
    GOTO    BW1                     \ jump to SECTOR
ENDCODE
\ ----------------------------------\


RST_HERE

[THEN]
ECHO

