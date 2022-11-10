\ -*- coding: utf-8 -*-
\ http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\ MY_MSP430FR5738_1 MY_MSP430FR5738     MY_MSP430FR5948     MY_MSP430FR5948_1   
\ JMJ_BOX

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

\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<


RST_RET

CODE DSM/REM                    \ D1 / D2 --> DREM DQUOT
            MOV TOS,Y           \ 1 Y=DVRhi
            MOV @PSP+,W         \ 2 W=DVRlo
            MOV @PSP+,X         \ 2 X=DVDhi
            MOV @PSP,T          \ 2 T=DVDlo
            PUSHM #5,X          \ 7 PUSHM DVDhi,DVRhi, M, P, Q
            AND #-1,Y           \ 1 Y=DVRhi < 0 ?
S< IF       XOR #-1,W           \ 1 W=INV(DVRlo)
            XOR #-1,Y           \ 1 Y=INV(DVRhi)
            ADD #1,W            \ 1 W=INV(DVRlo)+1
            ADDC #0,Y           \ 1 Y=INV(DVRhi)+C
THEN    
            AND #-1,X           \ 1 X=DVDhi < 0 ? 
S< IF       XOR #-1,T           \ 1 T=INV(DVDlo)
            XOR #-1,X           \ 1 X=INV(DVDhi)
            ADD #1,T            \ 1 T=INV(DVDlo)+1
            ADDC #0,X           \ 1 X=INV(DVDhi)+C
THEN        
\ ------------------------------------------------------------------------
\ don't uncomment lines below, don't rub out, please !
\ ------------------------------------------------------------------------
\           UD/MOD    DVDlo DVDhi DVRlo DVRhi -- REMlo REMhi QUOTlo QUOThi
\ ------------------------------------------------------------------------
\            MOV TOS,Y           \ 1 Y=DVRhi
\            MOV @PSP+,W         \ 2 W=DVRlo
\            MOV @PSP+,X         \ 2 X=DVDhi
\            MOV @PSP,T          \ 2 T=DVDlo
\            PUSHM #5,X          \ 7 PUSHM DVDhi,DVRhi, M, P, Q
             MOV #0,M            \ 1 M=REMlo = 0
            MOV #0,P            \ 1 P=REMhi = 0
            MOV #32,Q           \ 2 Q=count
BW1         CMP Y,P             \ 1 REMhi = DVRhi ?
    0= IF   CMP W,M             \ 1 REMlo U< DVRlo ?
    THEN
    U>= IF  SUB W,M             \ 1 no:  REMlo - DVRlo  (carry is set)
            SUBC Y,P            \ 1      REMhi - DVRhi
    THEN
    BEGIN   ADDC S,S            \ 1 RLC quotLO
            ADDC TOS,TOS        \ 1 RLC quotHI
            SUB #1,Q            \ 1 Decrement loop counter
    U>= WHILE                   \ 2 out of loop if count<0    
            ADD T,T             \ 1 RLA DVDlo
            ADDC X,X            \ 1 RLC DVDhi
            ADDC M,M            \ 1 RLC REMlo
            ADDC P,P            \ 1 RLC REMhi
            U< ?GOTO BW1        \ 2 19~ loop 
            SUB W,M             \ 1 REMlo - DVRlo
            SUBC Y,P            \ 1 REMhi - DVRhi
            BIS #1,SR           \ 1
    REPEAT                      \ 2 16~ loop
            MOV M,T             \ 1 T=REMlo
            MOV P,W             \ 1 W=REMhi
            POPM #5,X           \ 7 X=DVDhi, Y=DVRhi, restore M, P, Q, as system regs
            CMP #0,X            \ 1 sign of Rem ?
    S< IF   XOR #-1,T           \ 1 INV(REMlo)
            XOR #-1,W           \ 1 INV(REMhi)
            ADD #1,T            \ 1 INV(REMlo)+1 
            ADDC #0,W           \ 1 INV(REMhi)+C
    THEN
            SUB #4,PSP          \
            MOV T,4(PSP)        \   REMlo
            MOV W,2(PSP)        \   REMhi
            XOR X,Y
            CMP #0,Y            \ sign of Quot ?
S< IF       XOR #-1,S           \ 1 INV(QUOTlo)
            XOR #-1,TOS         \ 1 INV(QUOThi)
            ADD #1,S            \ 1 INV(QUOTlo)+1
            ADDC #0,TOS         \ 1 INV(QUOThi)+C
THEN
            MOV S,0(PSP)        \ 3 QUOTlo
            MOV @IP+,PC         \ 4
ENDCODE

PWR_HERE

[UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
CODE DROP
MOV @PSP+,TOS   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

: UD. \    u --           display ud (unsigned)
<# #S #> TYPE $20 EMIT
;

\ https://forth-standard.org/standard/double/Dd
\ D.     dlo dhi --           display d (signed)
CODE D.
MOV #U.,W   \ U. + 10 = D.
ADD #10,W
MOV W,PC
ENDCODE



; dvd div               ; Quot  Rem 
  .0  .0  UD/MOD D. D.  ;  inf   0   -->
  .0  .1  UD/MOD D. D.  ;   0    0   -->
  .1  .0  UD/MOD D. D.  ;  inf  dvd  -->
  .1  .1  UD/MOD D. D.  ;   1    0   -->
  .1  .2  UD/MOD D. D.  ;   0    1   -->
  .0  .2  UD/MOD D. D.  ;   0    0   -->
  .2  .0  UD/MOD D. D.  ;  inf  dvd  -->
  .2  .1  UD/MOD D. D.  ;   2    0   -->
  .2  .2  UD/MOD D. D.  ;   1    0   -->
  .2  .3  UD/MOD D. D.  ;   0    2   -->
  .0  .3  UD/MOD D. D.  ;   0    0   -->
  .3  .0  UD/MOD D. D.  ;  inf  dvd  -->
  .3  .1  UD/MOD D. D.  ;   3    0   -->
  .3  .2  UD/MOD D. D.  ;   1    1   -->
  .3  .3  UD/MOD D. D.  ;   1    0   -->
  .3  .4  UD/MOD D. D.  ;   0    3   -->
  .4  .1  UD/MOD D. D.  ;   4    0   -->
 
; dvd div               ; Quot  Rem 
   .0 -.1 UD/MOD D. D.  ;   0    0   -->
  -.1  .0 UD/MOD D. D.  ;  inf  dvd  -->
  -.1  .1 UD/MOD D. D.  ;  dvd   0   -->
  -.1 -.1 UD/MOD D. D.  ;   1    0   -->
  -.1 -.2 UD/MOD D. D.  ;   1    1   -->
  -.1 -.3 UD/MOD D. D.  ;   1    2   -->
  -.2  .0 UD/MOD D. D.  ;  inf  dvd  -->
  -.2 -.1 UD/MOD D. D.  ;   0   dvd  -->
  -.2 -.2 UD/MOD D. D.  ;   1    0   -->
  -.2 -.3 UD/MOD D. D.  ;   1    1   -->
  -.2 -.4 UD/MOD D. D.  ;   1    2   -->
