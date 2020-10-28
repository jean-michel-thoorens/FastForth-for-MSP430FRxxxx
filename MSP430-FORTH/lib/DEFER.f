\ -*- coding: utf-8 -*-

; --------------------
; DEFER.f
; --------------------
\
\ TARGET SELECTION
\ LP_MSP430FR2476
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    CHIPSTICK_FR2433    MSP_EXP430FR2355
\\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\ FastForth kernel compilation minimal options:
\ TERMINAL3WIRES, TERMINAL4WIRES
\ MSP430ASSEMBLER, CONDCOMP
\
\ to see kernel options, download FastForthSpecs.f
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
\

PWR_STATE

[UNDEFINED] @ [IF]
\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- char   fetch char from memory
CODE @
MOV @TOS,TOS
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

[UNDEFINED] DEFER [IF]
\ https://forth-standard.org/standard/core/DEFER
\ DEFER "<spaces>name"   --
\ Skip leading space delimiters. Parse name delimited by a space.
\ Create a definition for name with the execution semantics defined below.

\ name Execution:   --
\ Execute the xt that name is set to execute, i.e. NEXT (nothing),
\ until the phrase ' word IS name is executed, causing a new value of xt to be assigned to name.
: DEFER
CREATE
HI2LO
MOV #$4030,-4(W)        \ CFA = MOV @PC+,PC = BR MOV @IP+,PC
MOV #BR@IP+_ADR,-2(W)   \ PFA = address of MOV @IP+,PC to do nothing.
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] DEFER! [IF] 
\ https://forth-standard.org/standard/core/DEFERStore
\ Set the word xt1 to execute xt2. An ambiguous condition exists if xt1 is not for a word defined by DEFER.
CODE DEFER!             \ xt2 xt1 --
MOV @PSP+,2(TOS)        \ -- xt1=CFA_DEFER          xt2 --> [CFA_DEFER+2]
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] IS [IF]
\ https://forth-standard.org/standard/core/IS
\ IS <name>        xt --
\ used as is :
\ DEFER DISPLAY                         create a "do nothing" definition (2 CELLS)
\ inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
\ or in a definition : ... ['] U. IS DISPLAY ...
\ KEY, EMIT, CR, ACCEPT and WARM are examples of DEFERred words
\
\ as IS replaces the PFA value of any word, it's a TO alias for VARIABLE and CONSTANT words...
: IS
STATEADR @
IF  POSTPONE ['] POSTPONE DEFER! 
ELSE ' DEFER! 
THEN
; IMMEDIATE
[THEN]

PWR_HERE
