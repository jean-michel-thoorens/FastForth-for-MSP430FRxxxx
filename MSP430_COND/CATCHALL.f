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



\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free HOLDS chars space in the 32+2 bytes HOLD area = {24,21,0} chars with a 32 bits sized {hexa,decimal,binary} number.
\ perfect to display all a line on LCD 2x20 chars...
\ C HOLDS    addr u --
CODE HOLDS
        MOV @PSP+,X     \ 2
        ADD TOS,X       \ 1 src
        MOV &HP,Y       \ 3 dst
BEGIN   SUB #1,Y        \ 1 dst-1
        SUB #1,X        \ 1 src-1
        SUB #1,TOS      \ 1 cnt-1
U>= WHILE               \ 2
        MOV.B @X,0(Y)   \ 4
REPEAT                  \ 2
        MOV Y,&HP       \ 3
        MOV @PSP+,TOS   \ 2
        NEXT            \ 4  15 words
ENDCODE


\ https://forth-standard.org/standard/core/StoD
\ Convert the number n to the double-cell number d with the same numerical value.
CODE S>D        \ n -- d
SUB #2,PSP
MOV TOS,0(PSP)
BIT #$8000,TOS
MOV #0,TOS
0<> IF
    SUB #1,TOS
THEN
NEXT
ENDCODE
    \

\ https://forth-standard.org/standard/core/VALUE

\ Skip leading space delimiters. Parse name delimited by a space. 
\ Create a definition for name with the execution semantics defined below,
\ with an initial value equal to x.

\ Place x on the stack. The value of x is that given when name was created, 
\ until the phrase x TO name is executed, causing a new value of x to be assigned to name.

CODE VALUE
    MOV #CONSTANT,PC
ENDCODE

CODE TO
    MOV #IS,PC
ENDCODE IMMEDIATE




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
    MOV &>PAD,R6    \ 3 R6 = rDOVAR
    MOV &TB0R,0(R6) \ 5 we want sample TB0R
    MOV W,2(R6)
    ADD #4,&>PAD    \ 3
    MOV #R>,R6      \ 2 RFROM ==> rDOVAR
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

\ ' SAMPLE. IS TEST \ to start test
\ ' NOOP IS TEST    \ to stop test


