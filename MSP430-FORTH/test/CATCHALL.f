\ -*- coding: utf-8 -*-
\ http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

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



\ https://forth-standard.org/standard/string/COMPARE
\ COMPARE ( c-addr1 u1 c-addr2 u2 -- flag )
\Compare the string specified by c-addr1 u1 to the string specified by c-addr2 u2. 
\The strings are compared, beginning at the given addresses, character by character, 
\up to the length of the shorter string or until a difference is found. 
\If the two strings are identical, n is zero. 
\If the two strings are identical up to the length of the shorter string, 
\   n is minus-one (-1) if u1 is less than u2 and one (1) otherwise. 
\If the two strings are not identical up to the length of the shorter string, 
\   n is minus-one (-1) if the first non-matching character in the string specified by c-addr1 u1 
\   has a lesser numeric value than the corresponding character in the string specified by c-addr2 u2 and one (1) otherwise.
CODE COMPARE
        MOV TOS,S       \ 1 S = u2
        MOV @PSP+,Y     \ 2 Y = addr2
        MOV @PSP+,T     \ 2 T = u1     
        MOV @PSP+,X     \ 2 X = addr1
BEGIN   MOV T,TOS       \ 1
        ADD S,TOS       \ 1 TOS = u1+u2
        0= ?GOTO FW3    \ 2 u1=u2=0, Z=1,  end of all successfull comparisons
        SUB #1,T        \ 1
        0< ?GOTO FW1    \ 2 u1<u2 if u1 < 0
        SUB #1,S        \ 1
        0< ?GOTO FW2    \ 2 u1>u2 if u2 < 0
        ADD #1,X        \ 1 
        CMP.B @Y+,-1(X) \ 4 char1-char2
0<> UNTIL               \ 2 char1=char2  17~ loop
U< IF                   \ 2
FW1     MOV #-1,TOS     \ 1 -- -1  Z=0
        MOV @IP+,PC     \ 4
THEN
FW2     MOV #1,TOS      \ 1 -- 1   Z=0
FW3     MOV @IP+,PC     \ 4     20 + 6 def'n words



CODE F>S         \ convert a s15q16 (signed) number to a signed number (rounded)
CMP #0,0(PSP)   \ 
ADD #2,PSP
S< IF
    ADD #1,TOS
THEN
NEXT                \ 4
ENDCODE
    \

\ input: file size double word  Sector_per_cluster {1,2,4,8,16,32,64}
\ output cluster double word and cluster offset
CODE SD_DIV     \ SIZ_LO SIZ_HI SECPERCLU -- CLU_LO CLU_HI OFFSET
MOV.B 3(PSP),Y  \ Y = 0:CurSizeLOHi
MOV.B @PSP,X    \ X = 0:CurSizeHILo 
SWPB X          \ X = CurSizeHIlo:0
ADD Y,X         \ X = CurSizeHIlo:CurSizeLOhi
MOV.B 1(PSP),Y  \ Y:X = CurSize / 256
\ RRA Y           \ Y = Sectors number_High
\ RRC X           \ X = Sectors number_Low

MOV.B TOS,T     \ T = divisor = SECPERCLU

MOV #0,W        \ 1 W = 0:REMlo = 0
MOV #8,S        \ 1 CNT
\ RRA T           \ 1 0>0:SPClo>C   preshift one right DIVISOR
BEGIN
    RRA Y       \ 1 0>SEC_HI>C
    RRC X       \ 1 C>SEC_LO>C
    RRC.B W     \ 1 C>REMlo>C
    SUB #1,S    \ CNT-1
    RRA T       \ 1 0>SPChi:SPClo>C
U>= UNTIL
BEGIN
    RRA W       \ 1 0>0:REMlo>C
    SUB #1,S    \ 1 CNT-1
\ 0= UNTIL        \ Y = OFFSET, S = CLU_LO, W = CLU_HI
S< UNTIL        \ Y = OFFSET, S = CLU_LO, W = CLU_HI
MOV.B W,TOS     \ -- xx xx REMlo
MOV X,2(PSP)    \ -- CLU_LO xx OFFSET
MOV Y,0(PSP)    \ -- CLU_LO CLU_HI OFFSET
MOV @IP+,PC
ENDCODE


\ tests tools
\ -----------
    \

VARIABLE >PAD       \ declaration to do in start of source file
PAD IS >PAD         \ init >PAD, idem
    \

\ sample anything during an interrupt for example
\ usage in ASSEMBLER WORD :   ... LO2HI SAMPLE HI2LO ...     if IP is already saved
\ usage in ASSEMBLER WORD :   ... PUSH IP LO2HI SAMPLE HI2LO MOV @RSP+,IP ...     if IP is not already saved
\ usage in FORTH WORD :    ... SAMPLE ...

CODE SAMPLE2PAD
CMP #TIB,&>PAD      \ 4 do nothing if [>PAD] = TIB 
0<> IF              \ 2 
    MOV &>PAD,rDOVAR    \ 3 rDOVAR = rDOVAR
    MOV &TA0R,0(rDOVAR) \ 5 we want sample TB0R
    MOV W,2(rDOVAR)
    ADD #4,&>PAD    \ 3
    MOV #R>,rDOVAR      \ 2 RFROM ==> rDOVAR
THEN                \
MOV @IP+,PC         \ 4
ENDCODE             \ add LO2HI = 10 + 23 = 33 cycles ==>  4us @ 8MHz
    \

\ display samples, up to 42 samples
CODE DISPLAY_S      \ --
CMP #PAD,&>PAD
0= IF
    NEXT
THEN
COLON
CR
>PAD @ PAD DO   \ limit first --
    I  @ U.
2 +LOOP
PAD IS >PAD     \ reset >PAD
;
    \




DEFER TEST
    \
CODE NOOP      \ compile MOV #NEXT,PC
NEXT
ENDCODE
    \

CODE SAMPLE.    \ display what you want ( much slower than SAMPLE2PAD )
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &BASE,0(PSP)
    MOV &GPFLAGS,TOS \ we want sample GPFLAGS
    MOV #$10,&BASE
    PUSHM S,Y
    COLON
    ." $" U.
    BASE !
    HI2LO
    MOV @RSP+,IP
    POPM Y,S
    NEXT
ENDCODE
    \

