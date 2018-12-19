
; -----------------------------------------------------
; ANS_COMP.f    words complement to pass CORETEST.4th
; -----------------------------------------------------
\
\ TARGET Current Selection 
\ (used by preprocessor GEMA to load the pattern: \config\gema\TARGET.pat)
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
\
\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<

PWR_STATE

[DEFINED] {ANS_COMP} [IF] {ANS_COMP} [THEN] \ remove {ANS_COMP} if outside protected core  

[UNDEFINED] ASM [IF]
ECHO ASM ; assembler is required! <-- 
[THEN]

[UNDEFINED] {ANS_COMP} [IF]

MARKER {ANS_COMP}

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] OR [IF]
\ https://forth-standard.org/standard/core/OR
\ C OR     x1 x2 -- x3           logical OR
CODE OR
BIS @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] XOR [IF]
\ https://forth-standard.org/standard/core/XOR
\ C XOR    x1 x2 -- x3           logical XOR
CODE XOR
XOR @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

\ https://forth-standard.org/standard/core/INVERT
\ INVERT   x1 -- x2            bitwise inversion
CODE INVERT
XOR #-1,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/LSHIFT
\ LSHIFT  x1 u -- x2    logical L shift u places
CODE LSHIFT
            MOV @PSP+,W
            AND #$1F,TOS        \ no need to shift more than 16
0<> IF
    BEGIN   ADD W,W
            SUB #1,TOS
    0= UNTIL
THEN        MOV W,TOS
            MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/RSHIFT
\ RSHIFT  x1 u -- x2    logical R7 shift u places
CODE RSHIFT
            MOV @PSP+,W
            AND #$1F,TOS       \ no need to shift more than 16
0<> IF
    BEGIN   BIC #C,SR           \ Clr Carry
            RRC W
            SUB #1,TOS
    0= UNTIL
THEN        MOV W,TOS
            MOV @IP+,PC
ENDCODE

[UNDEFINED] MAX [IF]
\ https://forth-standard.org/standard/core/MAX
\ MAX    n1 n2 -- n3       signed maximum
CODE MAX
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/MIN
\ MIN    n1 n2 -- n3       signed minimum
CODE MIN
    CMP @PSP,TOS    \ n2-n1
    S< ?GOTO BW1    \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE
[THEN]

\ https://forth-standard.org/standard/core/TwoTimes
\ 2*      x1 -- x2         arithmetic left shift
CODE 2*
ADD TOS,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/TwoDiv
\ 2/      x1 -- x2        arithmetic right shift
CODE 2/
RRA TOS
MOV @IP+,PC
ENDCODE

\ --------------------
\ ARITHMETIC OPERATORS
\ --------------------
$1A04 C@ $EF > [IF] ; test tag value MSP430FR413x subfamily without hardware_MPY 

\ https://forth-standard.org/standard/core/MTimes
\ M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
CODE M*
MOV @PSP,S          \ S= n1
CMP #0,S            \ n1 > -1 ?
S< IF
    XOR #-1,0(PSP)  \ n1 --> u1
    ADD #1,0(PSP)   \
THEN
XOR TOS,S           \ S contains sign of result
CMP #0,TOS          \ n2 > -1 ?
S< IF
    XOR #-1,TOS     \ n2 --> u2 
    ADD #1,TOS      \
THEN
PUSHM #2,IP         \ UMSTAR use S,T,W,X,Y
LO2HI               \ -- ud1 u2
UM*       
HI2LO
POPM #2,IP           \ pop S,IP
CMP #0,S            \ sign of result > -1 ?
S< IF
    XOR #-1,0(PSP)  \ ud --> d
    XOR #-1,TOS
    ADD #1,0(PSP)
    ADDC #0,TOS
THEN
MOV @IP+,PC
ENDCODE

[ELSE]              ; MSP430FRxxxx with hardware_MPY

\ https://forth-standard.org/standard/core/UMTimes
\ UM*     u1 u2 -- udlo udhi   unsigned 16x16->32 mult.
CODE UM*
    MOV @PSP,&MPY       \ Load 1st operand for unsigned multiplication
BW1 MOV TOS,&OP2        \ Load 2nd operand
    MOV &RES0,0(PSP)    \ low result on stack
    MOV &RES1,TOS       \ high result in TOS
    MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/MTimes
\ M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
CODE M*
    MOV @PSP,&MPYS      \ Load 1st operand for signed multiplication
    GOTO BW1
ENDCODE

[THEN]

\ https://forth-standard.org/standard/core/SMDivREM
\ SM/REM   d1lo d1hi n2 -- r3 q4  symmetric signed div
CODE SM/REM
MOV TOS,S           \           S=divisor
MOV @PSP,T          \           T=dividend_sign==>rem_sign
CMP #0,TOS          \           n2 >= 0 ?
S< IF               \
    XOR #-1,TOS
    ADD #1,TOS      \ -- d1 u2
THEN
CMP #0,0(PSP)       \           d1hi >= 0 ?
S< IF               \
    XOR #-1,2(PSP)  \           d1lo
    XOR #-1,0(PSP)  \           d1hi
    ADD #1,2(PSP)   \           d1lo+1
    ADDC #0,0(PSP)  \           d1hi+C
THEN                \ -- uDVDlo uDVDhi uDIVlo
PUSHM #3,IP         \           save IP,S,T
LO2HI
    UM/MOD          \ -- uREMlo uQUOTlo
HI2LO
POPM #3,IP          \           restore T,S,IP
CMP #0,T            \           T=rem_sign
S< IF
    XOR #-1,0(PSP)
    ADD #1,0(PSP)
THEN
XOR S,T             \           S=divisor T=quot_sign
CMP #0,T            \ -- n3 u4  T=quot_sign
S< IF
BW1
BW2
    XOR #-1,TOS
    ADD #1,TOS
THEN                \ -- n3 n4  S=divisor
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/NEGATE
\ C NEGATE   x1 -- x2            two's complement
CODE NEGATE
GOTO BW1 
ENDCODE

\ https://forth-standard.org/standard/core/ABS
\ C ABS     n1 -- +n2     absolute value
CODE ABS
CMP #0,TOS       \  1
0< ?GOTO BW2
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/FMDivMOD
\ FM/MOD   d1 n1 -- r q   floored signed div'n
: FM/MOD
SM/REM
HI2LO               \ -- remainder quotient       S=divisor
CMP #0,0(PSP)       \ remainder <> 0 ?
0<> IF
    CMP #1,TOS      \ quotient < 1 ?
    S< IF
      ADD S,0(PSP)  \ add divisor to remainder
      SUB #1,TOS    \ decrement quotient
    THEN
THEN
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/Times
\ *      n1 n2 -- n3       signed multiply
: *
M* DROP
;

\ https://forth-standard.org/standard/core/DivMOD
\ /MOD   n1 n2 -- r3 q4     signed division
: /MOD
>R DUP 0< R> FM/MOD
;

\ https://forth-standard.org/standard/core/Div
\ /      n1 n2 -- n3       signed quotient
: /
>R DUP 0< R> FM/MOD NIP
;

\ https://forth-standard.org/standard/core/MOD
\ MOD    n1 n2 -- n3       signed remainder
: MOD
>R DUP 0< R> FM/MOD DROP
;

\ https://forth-standard.org/standard/core/TimesDivMOD
\ */MOD  n1 n2 n3 -- r4 q5    signed mult/div
: */MOD
>R M* R> FM/MOD
;

\ https://forth-standard.org/standard/core/TimesDiv
\ */     n1 n2 n3 -- n4        n1*n2/q3
: */
>R M* R> FM/MOD NIP
;

\ ----------------------------------------------------------------------
\ DOUBLE OPERATORS
\ ----------------------------------------------------------------------

\ https://forth-standard.org/standard/core/StoD
\ S>D    n -- d          single -> double prec.
: S>D
    DUP 0<
;

\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
CODE 2@
SUB #2,PSP
MOV 2(TOS),0(PSP)
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/TwoStore
\ 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
CODE 2!
MOV @PSP+,0(TOS)
MOV @PSP+,2(TOS)
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
CODE 2DUP
SUB #4,PSP          \ -- x1 x x x2
MOV TOS,2(PSP)      \ -- x1 x2 x x2
MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x2
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/TwoDROP
\ 2DROP  x1 x2 --          drop 2 cells
CODE 2DROP
ADD #2,PSP
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/TwoSWAP
\ 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
CODE 2SWAP
MOV @PSP,W          \ -- x1 x2 x3 x4    W=x3
MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x4
MOV W,4(PSP)        \ -- x3 x2 x1 x4
MOV TOS,W           \ -- x3 x2 x1 x4    W=x4
MOV 2(PSP),TOS      \ -- x3 x2 x1 x2    W=x4
MOV W,2(PSP)        \ -- x3 x4 x1 x2
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/TwoOVER
\ 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
CODE 2OVER
SUB #4,PSP          \ -- x1 x2 x3 x x x4
MOV TOS,2(PSP)      \ -- x1 x2 x3 x4 x x4
MOV 8(PSP),0(PSP)   \ -- x1 x2 x3 x4 x1 x4
MOV 6(PSP),TOS      \ -- x1 x2 x3 x4 x1 x2
MOV @IP+,PC
ENDCODE

\ ----------------------------------------------------------------------
\ ALIGNMENT OPERATORS
\ ----------------------------------------------------------------------
\ https://forth-standard.org/standard/core/ALIGNED
\ ALIGNED  addr -- a-addr       align given addr
CODE ALIGNED
BIT #1,TOS
ADDC #0,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/ALIGN
\ ALIGN    --                         align HERE
CODE ALIGN
BIT #1,&DP  \ 3
ADDC #0,&DP \ 4
MOV @IP+,PC
ENDCODE

\ ---------------------
\ PORTABILITY OPERATORS
\ ---------------------
\ https://forth-standard.org/standard/core/CHARS
\ CHARS    n1 -- n2            chars->adrs units
CODE CHARS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/CHARPlus
\ CHAR+    c-addr1 -- c-addr2   add char size
CODE CHAR+
ADD #1,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/CELLS
\ CELLS    n1 -- n2            cells->adrs units
CODE CELLS
ADD TOS,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/CELLPlus
\ CELL+    a-addr1 -- a-addr2      add cell size
CODE CELL+
ADD #2,TOS
MOV @IP+,PC
ENDCODE

\ ---------------------------
\ BLOCK AND STRING COMPLEMENT
\ ---------------------------
\ https://forth-standard.org/standard/core/CHAR
\ CHAR   -- char           parse ASCII character
: CHAR
    BL WORD 1+ C@
;

\ https://forth-standard.org/standard/core/BracketCHAR
\ [CHAR]   --          compile character literal
: [CHAR]
    CHAR lit lit , ,
; IMMEDIATE

\ https://forth-standard.org/standard/core/PlusStore
\ +!     n/u a-addr --       add n/u to memory
CODE +!
ADD @PSP+,0(TOS)
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/FILL
\ FILL   c-addr u char --  fill memory with char
CODE FILL
MOV @PSP+,X     \ count
MOV @PSP+,W     \ address
CMP #0,X
0<> IF
    BEGIN
        MOV.B TOS,0(W)    \ store char in memory
        ADD #1,W
        SUB #1,X
    0= UNTIL
THEN
MOV @PSP+,TOS     \ empties stack
MOV @IP+,PC
ENDCODE

\ --------------------
\ INTERPRET COMPLEMENT
\ --------------------
\ https://forth-standard.org/standard/core/HEX
CODE HEX
MOV #$10,&BASE
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/DECIMAL
CODE DECIMAL
MOV #$0A,&BASE
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/p
\ (         --          skip input until char ) or EOL
: ( 
$29 WORD DROP
; IMMEDIATE

\ https://forth-standard.org/standard/core/Dotp
\ .(        --          type comment immediatly.
CODE .(         \ "
MOV #0,&CAPS    \ CAPS OFF
COLON
$29 WORD
COUNT TYPE
BL CAPS !       \ CAPS ON
; IMMEDIATE

\ https://forth-standard.org/standard/core/SOURCE
\ SOURCE    -- adr u    of current input buffer
CODE SOURCE
SUB #4,PSP
MOV TOS,2(PSP)
MOV &SOURCE_LEN,TOS
MOV &SOURCE_ADR,0(PSP)
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/toIN
\ C >IN     -- a-addr       holds offset in input stream
TOIN CONSTANT >IN

[UNDEFINED] PAD [IF]

\ https://forth-standard.org/standard/core/PAD
\  PAD           --  addr
PAD_ORG CONSTANT PAD

[THEN]

RST_HERE

[THEN]

ECHO
