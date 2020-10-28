
; ------------------------------------------------------------------------------
; FACILITY.f
; ------------------------------------------------------------------------------
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133
\ MSP_EXP430FR2433  CHIPSTICK_FR2433    MSP_EXP430FR2355
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
\ FastForth kernel minimal options:
\ TERMINAL3WIRES, TERMINAL4WIRES
\ MSP430ASSEMBLER, CONDCOMP, DEFERRED
\

PWR_STATE

[UNDEFINED] MS [IF]
\ https://forth-standard.org/standard/facility/MS
\ ( u -- ) Wait at least u milliseconds.
\ exact time if the clock speed expressed in kHz - 12 is divisible by 4.
CODE MS             \ if u=0, wait 65536 ms
BEGIN               \   j_loop
    MOV &FREQ_KHZ,X \   3~   FREQ_KHZ = cycles/ms
    SUB #12,X       \   2~   FREQ_KHZ-12, because 12 cycles by j_loop (out of i_loop)
    RRUM #2,X       \   2~   i_count = (FREQ_KHZ-12)/4, because 4 cycles by i_loop
    NOP2            \   2~
    BEGIN           \     i_loop
        NOP         \     1~
        SUB #1,X    \     1~ decrement i_count
    0=  UNTIL       \     2~ i_loop time = FREQ_KHZ - 12~ --> 1ms - 12~
    SUB #1,TOS      \   1~   decrement j_count
0= UNTIL            \   2~   j_loop time = (1ms - 12~) + 12~ = 1.0000000 ms
MOV @PSP+,TOS       \ 2~ 
MOV @IP+,PC         \ 4~     SR(Z)=1
ENDCODE             \
[THEN]

[UNDEFINED] KEY? [IF]
\ https://forth-standard.org/standard/facility/KEYq
\ If a character is available, return true. Otherwise, return false. 
\ If non-character keyboard events are available before the first valid character, 
\ they are discarded and are subsequently unavailable. 
\ The character shall be returned by the next execution of KEY.
\ After KEY? returns with a value of true, subsequent executions of KEY? prior to
\ the execution of KEY or EKEY also return true, without discarding keyboard events.

DEFER KEY?      \ DEFERred word, as KEY is.
CODENNM         \ -- flag
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV #0,TOS
    BIT #RX_TERM,&TERM_IFG
    0<> IF
        MOV #-1,TOS
    THEN
    MOV @IP+,PC
ENDCODE IS KEY? \ this code becomes default action of DEFERred word KEY?
[THEN]

PWR_HERE
