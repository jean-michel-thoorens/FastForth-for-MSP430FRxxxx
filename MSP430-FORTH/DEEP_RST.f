\ -*- coding: utf-8 -*-

\ TARGET Current Selection 
\ (used by preprocessor GEMA to load the pattern: \inc\TARGET.pat)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433  MSP_EXP430FR4133    MSP_EXP430FR2355    CHIPSTICK_FR2433

; ------------
; DEEP_RST.f
; ------------

; restore signatures and vectors area


[UNDEFINED] ! [IF]
\ https://forth-standard.org/standard/core/Store
\ !        x a-addr --   store cell in memory
CODE !
MOV @PSP+,0(TOS)    \ 4
MOV @PSP+,TOS       \ 2
MOV @IP+,PC         \ 4
ENDCODE
[THEN]

ECHO
-1 SAVE_SYSRSTIV ! COLD \ download to unlock JTAG and BSL, for example
