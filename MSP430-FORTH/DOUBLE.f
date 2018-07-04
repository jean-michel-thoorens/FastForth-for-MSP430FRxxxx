\ -*- coding: utf-8 -*-
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433


\ Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
\ Copyright (C) <2015>  <J.M. THOORENS>
\
\ This program is free software: you can redistribute it and/or modify
\ it under the terms of the GNU General Public License as published by
\ the Free Software Foundation, either version 3 of the License, or
\ (at your option) any later version.
\
\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU General Public License for more details.
\
\ You should have received a copy of the GNU General Public License
\ along with this program.  If not, see <http://www.gnu.org/licenses/>.

\ REGISTERS USAGE
\ rDODOES to rEXIT must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT, rDOVAR, rDOCON, rDODOES
\ example : PUSHM IP,Y
\
\ POPM  order :  rDODOES, rDOCON, rDOVAR, rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }

\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=

\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  <0


\ https://forth-standard.org/standard/double/DtoS
\ D>S    d -- n          double prec -> single.
CODE D>S
MOV @PSP+,TOS
NEXT
ENDCODE
    \

[UNDEFINED] {ANS_COMP} [IF]
\ https://forth-standard.org/standard/core/StoD
\ S>D    n -- d          single -> double prec.
: S>D
    DUP 0<
;
    \

\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
CODE 2@
SUB #2,PSP
MOV 2(TOS),0(PSP)
MOV @TOS,TOS
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
CODE 2DUP
SUB #4,PSP          \ -- x1 x x x2
MOV TOS,2(PSP)      \ -- x1 x2 x x2
MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x2
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/core/TwoDROP
\ 2DROP  x1 x2 --          drop 2 cells
CODE 2DROP
ADD #2,PSP
MOV @PSP+,TOS
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/core/TwoSWAP
\ 2SWAP  x1 x2 x3 x4 -- x3 x4 x1 x2
CODE 2SWAP
MOV @PSP,W          \ -- x1 x2 x3 x4    W=x3
MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x4
MOV W,4(PSP)        \ -- x3 x2 x1 x4
MOV TOS,W           \ -- x3 x2 x1 x4    W=x4
MOV 2(PSP),TOS      \ -- x3 x2 x1 x2    W=x4
MOV W,2(PSP)        \ -- x3 x4 x1 x2
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/core/TwoOVER
\ 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
CODE 2OVER
SUB #4,PSP          \ -- x1 x2 x3 x x x4
MOV TOS,2(PSP)      \ -- x1 x2 x3 x4 x x4
MOV 8(PSP),0(PSP)   \ -- x1 x2 x3 x4 x1 x4
MOV 6(PSP),TOS      \ -- x1 x2 x3 x4 x1 x2
NEXT
ENDCODE
    \

[THEN] \ undefined ANS_COMP

\ https://forth-standard.org/standard/double/TwoROT
\ Rotate the top three cell pairs on the stack bringing cell pair x1 x2 to the top of the stack.
CODE 2ROT
MOV 8(PSP),X        \ 3
MOV 6(PSP),Y        \ 3
MOV 4(PSP),8(PSP)   \ 5
MOV 2(PSP),6(PSP)   \ 5
MOV @PSP,4(PSP)     \ 4
MOV TOS,2(PSP)      \ 3
MOV X,0(PSP)        \ 3
MOV Y,TOS           \ 1
NEXT
ENDCODE
    \

CODE 2NIP
MOV @PSP,X
ADD #4,PSP
MOV X,0(PSP)
NEXT
ENDCODE
    \

CODE D0=
CMP #0,TOS
MOV #0,TOS
0= IF
    CMP #0,0(PSP)
    0= IF
        MOV #-1,TOS
    THEN
THEN
ADD #2,PSP
NEXT
ENDCODE
    \

CODE D0<
CMP #0,TOS
MOV #0,TOS
S< IF
    MOV #-1,TOS
THEN
ADD #2,PSP
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/double/DEqual
CODE D=
CMP TOS,2(PSP)      \ 3 ud1H - ud2H
MOV #0,TOS          \ 1
0= IF               \ 2
    CMP @PSP,4(PSP) \ 4 ud1L - ud2L
    0= IF           \ 2
    MOV #-1,TOS     \ 1
    THEN
THEN
ADD #6,PSP          \ 2
NEXT                \ 4
ENDCODE
    \

\ https://forth-standard.org/standard/double/Dless
\ flag is true if and only if d1 is less than d2
CODE D<
CMP TOS,2(PSP)      \ 3 d1H - d2H
MOV #0,TOS          \ 1
S< IF               \ 2
    MOV #-1,TOS     \ 1
THEN
0= IF               \ 2
    CMP @PSP,4(PSP) \ 4 d1L - d2L
    S< IF           \ 2
        MOV #-1,TOS \ 1
    THEN
THEN
ADD #6,PSP          \ 2
NEXT                \ 4
ENDCODE
    \

CODE D>
CMP 2(PSP),TOS      \ 3 d2H - d1H
MOV #0,TOS          \ 1
S< IF               \ 2
    MOV #-1,TOS     \ 1
THEN
0= IF               \ 2
    CMP 4(PSP),0(PSP) \ 4 d2L - d1L
    S< IF           \ 2
        MOV #-1,TOS \ 1
    THEN
THEN
ADD #6,PSP          \ 2
NEXT                \ 4
ENDCODE
    \

\ https://forth-standard.org/standard/double/DUless
\ flag is true if and only if ud1 is less than ud2
CODE DU<
CMP TOS,2(PSP)      \ 3 ud1H - ud2H
MOV #0,TOS          \ 1
U< IF               \ 2
    MOV #-1,TOS     \ 1
THEN
0= IF               \ 2
    CMP @PSP,4(PSP) \ 4 ud1L - ud2L
    U< IF           \ 2
        MOV #-1,TOS \ 1
    THEN
THEN
ADD #6,PSP          \ 2
NEXT                \ 4
ENDCODE
    \


CODE D+
ADD @PSP+,2(PSP)
ADDC @PSP+,TOS
NEXT                \ 4
ENDCODE
    \

CODE D-
SUB @PSP+,2(PSP)
SUBC TOS,0(PSP)
MOV @PSP+,TOS
NEXT                \ 4
ENDCODE
    \

CODE DNEGATE
XOR #-1,0(PSP)
XOR #-1,TOS
ADD #1,0(PSP)
ADDC #0,TOS
NEXT                \ 4
ENDCODE
    \

\ https://forth-standard.org/standard/double/DTwoDiv
CODE D2/
RRA TOS
RRC 0(PSP)
NEXT                \ 4
ENDCODE
    \

\ https://forth-standard.org/standard/double/DTwoTimes
CODE D2*
ADD @PSP,0(PSP)
ADDC TOS,TOS
NEXT                \ 4
ENDCODE
    \

: DMAX
2OVER 2OVER \ ( d1 d2 d1 d2 )
D> IF 2DROP ELSE 2NIP THEN
;
    \

: DMIN
2OVER 2OVER \ ( d1 d2 d1 d2 )
D< IF 2DROP ELSE 2NIP THEN
;
    \

CODE M+
ADD TOS,2(PSP)
ADDC #0,0(PSP)
MOV @PSP+,TOS
NEXT                \ 4
ENDCODE
    \

$1A04 C@ $EF > [IF] ; test tag value MSP430FR413x subfamily without hardware_MPY 
    \

\ signed multiply 32*16 --> 48 / 16 = 32
CODE M*/                \ d1lo d1hi n1 +n2 -- d2lo d2hi
    MOV 2(PSP),S        \ 
    XOR @PSP,S          \ S keep sign of M* result
    BIT #$8000,2(PSP)   \ MD < 0 ? 
0<> IF  XOR #-1,4(PSP)
        XOR #-1,2(PSP)
        ADD #1,4(PSP)
        ADDC #0,2(PSP)
THEN
    BIT #$8000,TOS
0<> IF  XOR #-1,TOS
        ADD #1,TOS
THEN
\ UDM*
            PUSHM R5,R4     \ 6 save R5 ~ R4 regs
            MOV 4(PSP),Y    \ 3 MDlo
            MOV 2(PSP),T    \ 3 MDhi
            MOV @PSP+,W     \ 2 MRlo        -- d1lo d1hi +n2
            MOV #0,R4       \ 1 MDLO=0
            MOV #0,2(PSP)   \ 3 RESlo=0
            MOV #0,0(PSP)   \ 3 REShi=0     -- p1lo p1hi +n2 
            MOV #0,R5       \ 1 RESLO=0
            MOV #1,X        \ 1 BIT TEST REGlo
BEGIN       BIT X,W         \ 1 test actual bit
    0<> IF  ADD Y,2(PSP)    \ 3 IF 1: ADD MDlo TO RESlo
            ADDC T,0(PSP)   \ 3      ADDC MDhi TO REShi
            ADDC R4,R5      \ 1      ADDC MDLO TO RESLO        
    THEN    ADD Y,Y         \ 1 (RLA LSBs) MDlo *2
            ADDC T,T        \ 1 (RLC MSBs) MDhi *2
            ADDC R4,R4      \ 1 (RLA LSBs) MDLO *2
            ADD X,X         \ 1 (RLA) NEXT BIT TO TEST
U>= UNTIL   MOV R5,W        \ 1 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
            POPM R4,R5      \ 6 restore R4 ~ R5 regs
\ UDM*END
    MOV TOS,T               \
    MOV @PSP,TOS            \
    AND #-1,S               \ clear V, set N, test M* sign
    MOV 2(PSP),S
S< IF   XOR #-1,S
        XOR #-1,TOS
        XOR #-1,W
        ADD #1,S
        ADDC #1,TOS
        ADDC #0,W
THEN
MOV #MU/MOD,X
ADD #10,X           \ 2 X = MUSMOD2 addr
CALL X              \ 4
MOV @PSP+,0(PSP)    \ rem d2lo d2hi -- d2lo d2hi
NEXT                \ 4
ENDCODE
    \
[ELSE]
    \
CODE M*/            \ d1 * n1 / +n2 -- d2
MOV 4(PSP),&MPYS32L \ 5 Load 1st operand
MOV 2(PSP),&MPYS32H \ 5
MOV @PSP+,&OP2      \ 4 load 2nd operand
MOV #MU/MOD,X       \ 2
ADD #10,X           \ 2 X = MUSMOD2 addr
MOV TOS,T           \ 1 T = DIVlo
MOV &RES0,S         \ 3 S = DVDlo
MOV &RES1,TOS       \ 3 TOS = DVDhi
MOV &RES2,W         \ 3 W = REMlo
CALL X              \ 4
MOV @PSP+,0(PSP)    \ rem dquot -- d2
NEXT                \ 4
ENDCODE
    \
[THEN]
    \

\ https://forth-standard.org/standard/double/TwoVARIABLE
: 2VARIABLE \  --
VARIABLE
2 ALLOT
;
    \

[UNDEFINED] 2CONSTANT [IF]
\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
CODE 2@
SUB #2,PSP
MOV 2(TOS),0(PSP)
MOV @TOS,TOS
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/double/TwoCONSTANT
: 2CONSTANT \  udlo/dlo/Flo udhi/dhi/Shi --         to create double or s15q16 CONSTANT
CREATE
, ,             \ compile Shi then Flo
DOES>
2@              \ execution part
;
[THEN]
    \

CODE 2VALUE
MOV #CONSTANT,PC
ENDCODE
    \

CODE 2LITERAL
BIS #UF9,SR
MOV #LITERAL,PC
ENDCODE
    \

PWR_HERE

: ?floored [ -3 2 / -2 = ] LITERAL IF 1. D- THEN ;

5. 7 11 M*/             D.  ; 3  --> 
5. -7 11 M*/ ?floored   D.  ; -3 --> 
-5. 7 11 M*/ ?floored   D.  ; -3 --> 
-5. -7 11 M*/           D.  ; 3  -->  
$7FFFFFFF. 8 16 M*/     D.  ; $7FFF --> 
