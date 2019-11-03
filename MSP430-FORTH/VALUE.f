\ -*- coding: utf-8 -*-

; -----------------------------------------------------
; VALUE.f
; -----------------------------------------------------
\
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP
\ to see FastForth kernel options, download FF_SPECS.f
\
\ TARGET Current Selection 
\ (used by preprocessor GEMA to load the pattern: \inc\TARGET.pat)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433  MSP_EXP430FR4133    MSP_EXP430FR2355    CHIPSTICK_FR2433
\
\ REGISTERS USAGE
\ rDODOES to rEXIT must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use
\
\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT, rDOVAR, rDOCON, rDODOES
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  rDODOES, rDOCON, rDOVAR, rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM #6,IP   pulls Y,X,W,T,S,IP registers from return stack
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?GOTO           S<  S>=  U<   U>=  0=  0<>  0<

PWR_STATE

\ https://forth-standard.org/standard/core/VALUE
\ ( x "<spaces>name" -- )                      define a Forth VALUE
\ Skip leading space delimiters. Parse name delimited by a space.
\ Create a definition for name with the execution semantics defined below,
\ with an initial value equal to x.
\ 
\ name Execution: ( -- x )
\ Place x on the stack. The value of x is that given when name was created,
\ until the phrase x TO name is executed, causing a new value of x to be assigned to name.
\ 
: VALUE                 \ x "<spaces>name" -- 
CREATE ,
DOES> 
HI2LO
MOV @RSP+,IP
BIT #UF10,SR    \ see TO
0= IF
    MOV #@,PC
THEN 
BIC #UF10,SR
MOV #!,PC
ENDCODE

\ https://forth-standard.org/standard/double/TwoVALUE
: 2VALUE        \ x1 x2 "<spaces>name" --
CREATE , ,      \ compile Shi then Flo
DOES>
HI2LO
MOV @RSP+,IP
BIT #UF10,SR    \see TO
0= IF
   MOV #2@,PC
THEN 
BIC #UF10,SR
MOV #2!,PC
ENDCODE

\ https://forth-standard.org/standard/core/TO
\ TO name Run-time: ( x -- )
\ Assign the value x to named VALUE.
CODE TO
BIS #UF10,SR
MOV @IP+,PC
ENDCODE

PWR_HERE
