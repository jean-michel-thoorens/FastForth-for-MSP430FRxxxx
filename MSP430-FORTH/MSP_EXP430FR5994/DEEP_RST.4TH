
; ------------
; DEEP_RST.4th for MSP_EXP430FR5994
; ------------

; restore signatures and vectors area

[UNDEFINED] ! [IF]
CODE !
MOV @R15+,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

ECHO -1 $1808 ! COLD
