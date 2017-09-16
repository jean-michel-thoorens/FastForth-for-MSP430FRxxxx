; -------------------------------------------------------------------------------
; ANS complement for MSP430FRxxxx devices with hardware_MPY, to pass CORETEST.4th
; when downloading to SD_CARD target, truncate filename ANS_COMP_HMPY.4th to ANS_COMP.4th
; -------------------------------------------------------------------------------

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433
\ MY_MSP430FR5738_1 MY_MSP430FR5738     MY_MSP430FR5948     MY_MSP430FR5948_1   
\ JMJ_BOX

PWR_STATE

[DEFINED] ASM [UNDEFINED] {ANS_COMP} AND [IF]
    \

MARKER {ANS_COMP}
    \


CODE INVERT     \   x1 -- x2            bitwise inversion
            XOR #-1,TOS
            MOV @IP+,PC
ENDCODE
    \

CODE LSHIFT     \   x1 u -- x2    logical L shift u places
            MOV @PSP+,W
            AND #$1F,TOS        \ no need to shift more than 16
0<> IF
    BEGIN   ADD W,W
            SUB #1,TOS
    0= UNTIL
THEN        MOV W,TOS
            MOV @IP+,PC
ENDCODE
    \

CODE RSHIFT \   x1 u -- x2    logical rEXIT shift u places
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
    \

CODE 1+     \    n1/u1 -- n2/u2       add 1 to TOS
            ADD #1,TOS
            MOV @IP+,PC
ENDCODE
    \

CODE 1-     \ n1/u1 -- n2/u2     subtract 1 from TOS
            SUB #1,TOS
            MOV @IP+,PC
ENDCODE
    \

[UNDEFINED] MAX [IF]
CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
[THEN]
    \

CODE 2*     \   x1 -- x2        arithmetic left shift
            ADD TOS,TOS
            MOV @IP+,PC
ENDCODE
    \

CODE 2/     \   x1 -- x2        arithmetic right shift
            RRA TOS
            MOV @IP+,PC
ENDCODE
    \

\ --------------------
\ ARITHMETIC OPERATORS
\ --------------------

$1A04 C@ $7F > [IF] ; test tag value MSP430FR413x without hardware_MPY 
    \
CODE M*             \ n1 n2 -- dlo dhi  signed 16*16->32 multiply             
MOV TOS,S           \ TOS= n2
XOR @PSP,S          \ S contains sign of result
CMP #0,0(PSP)       \ n1 > -1 ?
S< IF
    XOR #-1,0(PSP)  \ n1 --> u1
    ADD #1,0(PSP)   \
THEN
CMP #0,TOS          \ n2 > -1 ?
S< IF
    XOR #-1,TOS     \ n2 --> u2 
    ADD #1,TOS      \
THEN
PUSHM IP,S
LO2HI               \ -- ud1 u2
UM*                 \ UMSTAR use S,T,W,X,Y
HI2LO
POPM S,IP
CMP #0,S            \ sign of result > -1 ?
S< IF
    XOR #-1,0(PSP)  \ ud --> d
    XOR #-1,TOS
    ADD #1,0(PSP)
    ADDC #0,TOS
THEN
MOV     @IP+,PC
ENDCODE
    \

[ELSE]              ; MSP430FRxxxx with hardware_MPY
    \
CODE UM*        \ u1 u2 -- udlo udhi    unsigned 16x16->32 mult.
MOV @PSP,&MPY       \ Load 1st operand
MOV TOS,&OP2        \ Load 2nd operand
MOV &RES0,0(PSP)    \ low result on stack
MOV &RES1,TOS       \ high result in TOS
MOV @IP+,PC
ENDCODE
    \

CODE M*         \ n1 n2 -- dlo dhi      signed 16*16->32 multiply
MOV @PSP,&MPYS
MOV TOS,&OP2
MOV &RES0,0(PSP)
MOV &RES1,TOS
MOV @IP+,PC
ENDCODE
    \

[THEN]
    \
\ \ TOS = DIVlo
\ \ S   = DVDlo
\ \ W   = DVDhi / REMlo 
\ \ X   = count
\ \ Y   = QUOTlo
\ \ DVDhi|DVDlo : DIVlo -> QUOTlo, REMlo
\ 
\ \ C UM/MOD   udlo|udhi u1 -- ur uq
\ CODE UM/MOD
\     MOV @PSP+,W     
\     MOV @PSP,S      
\     MOV #16,X       
\ BEGIN
\     ADD S,S         
\     ADDC W,W        
\     CMP TOS,W       
\     U>= IF          
\         SUB TOS,W   
\     THEN            
\     ADDC Y,Y        
\     SUB #1,X        
\ 0= UNTIL            
\     MOV W,0(PSP)    
\     MOV Y,TOS       
\     MOV @IP+,PC     
\ ENDCODE
\     \

\ C UM/MOD   udlo|udhi u1 -- ur uq
CODE UM/MOD
    MOV @PSP+,W     \ 2 W = DIVIDENDhi
    MOV @PSP,S      \ 2 S = DIVIDENDlo
    MOV #16,X       \ 2 INITIALIZE LOOP COUNTER
BW1 CMP TOS,W       \ 1 DVDhi - DIVlo
    U>= IF          \ 2
        SUB TOS,W   \ 1 if carry
    THEN            \
BW2 ADDC Y,Y        \ 1 RLC quotient
    SUB #1,X        \ 1 Decrement loop counter
    0< ?GOTO FW1    \ 2 if 0< terminate
    ADD S,S         \ 1 RLA DVDlo
    ADDC W,W        \ 1 RLC DVDhi
    U< ?GOTO BW1    \ 2 if not carry    14~ loop
    SUB TOS,W       \ 1 DVDhi - DIVlo
    BIS #1,SR       \ 1 SETC
    GOTO BW2        \ 2                 14~ loop
FW1 MOV W,0(PSP)    \ 3 remainder on stack
    MOV Y,TOS       \ 1 quotient in TOS
    MOV @IP+,PC     \ 4
ENDCODE
    \

CODE SM/REM         \ d1lo d1hi n2 -- n3 n4  symmetric signed div
MOV TOS,S           \           S=divisor
MOV @PSP,T          \           T=dividend_sign=rem_sign
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
THEN                \ -- ud1 u2
PUSHM IP,S          \  
LO2HI               \
UM/MOD              \           UM/MOD use S,W,X,Y, not T
HI2LO               \ -- u3 u4
POPM S,IP           \  
CMP #0,T            \           T=rem_sign
S< IF
    XOR #-1,0(PSP)
    ADD #1,0(PSP)
THEN
XOR S,T             \           S=divisor T=quot_sign
CMP #0,T            \ -- n3 u4  T=quot_sign
S< IF
    XOR #-1,TOS
    ADD #1,TOS
THEN                \ -- n3 n4  S=divisor
MOV @IP+,PC
ENDCODE
    \

: FM/MOD            \ d1 n2 -- n3 n4   floored signed div
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
    \

: *         \ n1 n2 -- n3           n1*n2 --> n3
M* DROP
;
    \

: /MOD      \ n1 n2 -- n3 n4        n1/n2 --> rem quot
>R DUP 0< R> FM/MOD
;
    \

: /         \ n1 n2 -- n3           n1/n2 --> quot
>R DUP 0< R> FM/MOD NIP
;
    \

: MOD       \ n1 n2 -- n3           n1/n2 --> rem
>R DUP 0< R> FM/MOD DROP
;
    \

: */MOD     \ n1 n2 n3 -- n4 n5     n1*n2/n3 --> rem quot
>R M* R> FM/MOD
;
    \

: */        \ n1 n2 n3 -- n4        n1*n2/n3 --> quot
>R M* R> FM/MOD NIP
;
    \

\ ----------------------------------------------------------------------
\ DOUBLE OPERATORS
\ ----------------------------------------------------------------------

: S>D           \ n -- d      single -> double
    DUP 0<
;
    \

CODE 2@        \ a-addr -- x1 x2    fetch 2 cells \ the lower address will appear on top of stack
SUB     #2, PSP
MOV     2(TOS),0(PSP)
MOV     @TOS,TOS
MOV     @IP+,PC
ENDCODE
    \

CODE 2!         \ x1 x2 a-addr --    store 2 cells \ the top of stack is stored at the lower adr
MOV     @PSP+,0(TOS)
MOV     @PSP+,2(TOS)
MOV     @PSP+,TOS
MOV     @IP+,PC
ENDCODE
    \

CODE 2DUP       \ x1 x2 -- x1 x2 x1 x2   dup top 2 cells
SUB     #4,PSP          \ -- x1 x x x2
MOV     TOS,2(PSP)      \ -- x1 x2 x x2
MOV     4(PSP),0(PSP)   \ -- x1 x2 x1 x2
MOV     @IP+,PC
ENDCODE
    \

CODE 2DROP      \ x1 x2 --      drop 2 cells
ADD     #2,PSP
MOV     @PSP+,TOS
MOV     @IP+,PC
ENDCODE
    \

CODE 2SWAP      \ x1 x2 x3 x4 -- x3 x4 x1 x2
MOV     @PSP,W          \ -- x1 x2 x3 x4    W=x3
MOV     4(PSP),0(PSP)   \ -- x1 x2 x1 x4
MOV     W,4(PSP)        \ -- x3 x2 x1 x4
MOV     TOS,W           \ -- x3 x2 x1 x4    W=x4
MOV     2(PSP),TOS      \ -- x3 x2 x1 x2    W=x4
MOV     W,2(PSP)        \ -- x3 x4 x1 x2
MOV     @IP+,PC
ENDCODE
    \

CODE 2OVER      \ x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
SUB     #4,PSP          \ -- x1 x2 x3 x x x4
MOV     TOS,2(PSP)      \ -- x1 x2 x3 x4 x x4
MOV     8(PSP),0(PSP)   \ -- x1 x2 x3 x4 x1 x4
MOV     6(PSP),TOS      \ -- x1 x2 x3 x4 x1 x2
MOV     @IP+,PC
ENDCODE
    \


\ ----------------------------------------------------------------------
\ ALIGNMENT OPERATORS
\ ----------------------------------------------------------------------

CODE ALIGNED    \ addr -- a-addr       align given addr
BIT     #1,TOS
ADDC    #0,TOS
MOV     @IP+,PC
ENDCODE
    \

CODE ALIGN      \ --                         align HERE
BIT     #1,&DP  \ 3
ADDC    #0,&DP  \ 4
MOV     @IP+,PC
ENDCODE
    \

\ ---------------------
\ PORTABILITY OPERATORS
\ ---------------------

CODE CHARS      \ n1 -- n2            chars->adrs units
MOV     @IP+,PC
ENDCODE
    \

CODE CHAR+      \ c-addr1 -- c-addr2   add char size
ADD     #1,TOS
MOV     @IP+,PC
ENDCODE
    \

CODE CELLS      \ n1 -- n2            cells->adrs units
ADD     TOS,TOS
MOV     @IP+,PC
ENDCODE
    \

CODE CELL+      \ a-addr1 -- a-addr2      add cell size
ADD     #2,TOS
MOV     @IP+,PC
ENDCODE
    \
\ ---------------------------
\ BLOCK AND STRING COMPLEMENT
\ ---------------------------

: CHAR      \ -- char       parse ASCII character
    BL WORD 1+ C@
;

: [CHAR]    \ --            compile character literal
    CHAR lit lit , ,
; IMMEDIATE

    \

CODE +!         \ n/u a-addr --     add to memory
ADD @PSP+,0(TOS)
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
    \ 


CODE FILL       \ c-addr u char --  fill memory with char
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
    \ 

\ --------------------
\ INTERPRET COMPLEMENT
\ --------------------

CODE HEX
MOV     #$10,&BASE
MOV     @IP+,PC
ENDCODE
    \

CODE DECIMAL
MOV     #$0A,&BASE
MOV     @IP+,PC
ENDCODE
    \
: (                 \
$29 WORD DROP
; IMMEDIATE
    \

: .(             \  --     dotparen \ type comment immediatly.
\ CAPS_OFF        \  --     set CAPS_OFF  (recompile FORTH with LOWERCASE swith ON before, must be paired with set CAP_ON)
$29 WORD
COUNT TYPE
\ CAPS_ON               \  --     set CAPS_OFF  (recompile FORTH with LOWERCASE swith ON before, must be paired with set CAP_ON)
; IMMEDIATE
    \

CODE SOURCE         \ -- adr u    current input buffer
SUB #4,PSP
MOV TOS,2(PSP)
MOV &SOURCE_LEN,TOS
MOV &SOURCE_ADR,0(PSP)
MOV @IP+,PC
ENDCODE
    \

CODE >BODY
ADD #4,TOS
MOV @IP+,PC
ENDCODE
    \

( added ANS_COMPLEMENT: INVERT LSHIFT RSHIFT 1+ 1- MAX MIN 2* 2/ CHAR [CHAR] +! FILL HEX DECIMAL ( .( SOURCE >BODY
(                       ARITHMETIC: UM* M* UM/MOD SM/REM FM/MOD * /MOD / MOD */MOD */
(                       DOUBLE: S>D 2@ 2! 2DUP 2DROP 2SWAP 2OVER
(                       ALIGMENT: ALIGNED ALIGN
(                       PORTABIITY: CHARS CHAR+ CELLS CELL+) 

[THEN]
    \
PWR_HERE

ECHO 
