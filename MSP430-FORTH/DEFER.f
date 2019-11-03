\ -*- coding: utf-8 -*-

; --------------------
; DEFER.f
; --------------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP
\
\ TARGET SELECTION
\ LP_MSP430FR2476
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
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
MOV #NEXT_ADR,-2(W)     \ PFA = address of MOV @IP+,PC to do nothing.
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
STATE @
IF  POSTPONE ['] POSTPONE DEFER! 
ELSE ' DEFER! 
THEN
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

