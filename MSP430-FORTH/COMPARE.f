\ -*- coding: utf-8 -*-
\
\ Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
\ Copyright (C) <2017>  <J.M. THOORENS>
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

[UNDEFINED] IF [IF]
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
CODE IF       \ immediate
SUB #2,PSP              \
MOV TOS,0(PSP)          \
MOV &DP,TOS             \ -- HERE
ADD #4,&DP            \           compile one word, reserve one word
MOV #QFBRAN,0(TOS)      \ -- HERE   compile QFBRAN
ADD #2,TOS              \ -- HERE+2=IFadr
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] THEN [IF]
\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
CODE THEN               \ immediate
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] BEGIN [IF]
\ https://forth-standard.org/standard/core/BEGIN
\ BEGIN    -- BEGINadr             initialize backward branch
CODE BEGIN              \ immediate
MOV #HERE,PC            \ BR HERE
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] UNTIL [IF]
\ https://forth-standard.org/standard/core/UNTIL
\ UNTIL    BEGINadr --             resolve conditional backward branch
CODE UNTIL              \ immediate
    MOV #QFBRAN,X
BW1 ADD #4,&DP          \ compile two words
    MOV &DP,W           \ W = HERE
    MOV X,-4(W)         \ compile Bran or QFBRAN at HERE
    MOV TOS,-2(W)       \ compile bakcward adr at HERE+2
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

\ COMPARE ( c-addr1 u1 c-addr2 u2 -- n )
\ https://forth-standard.org/standard/string/COMPARE
\ Compare the string specified by c-addr1 u1 to the string specified by c-addr2 u2. 
\ The strings are compared, beginning at the given addresses, character by character, 
\ up to the length of the shorter string or until a difference is found. 
\ If the two strings are identical, n is zero. 
\ If the two strings are identical up to the length of the shorter string, 
\    n is minus-one (-1) if u1 is less than u2 and one (1) otherwise. 
\ If the two strings are not identical up to the length of the shorter string, 
\    n is minus-one (-1) if the first non-matching character in the string specified by c-addr1 u1 
\    has a lesser numeric value than the corresponding character in the string specified by c-addr2 u2 and one (1) otherwise.
CODE COMPARE
        MOV TOS,S       \ 1 u2 = S
        MOV @PSP+,Y     \ 2 addr2 = Y
        MOV @PSP+,T     \ 2 u1 = T     
        MOV @PSP+,X     \ 2 addr1 = X
BEGIN   MOV T,TOS       \ 1
        ADD S,TOS       \ 1
        0= ?GOTO FW3    \ 2 end of all successfull comparisons 
        SUB #1,S        \ 1
        0< ?GOTO FW2    \ 2 u2<u1 ==> u1>u2
        SUB #1,T        \ 1
        0< ?GOTO FW1    \ 2 u1<u2
        ADD #1,X        \ 1
        CMP.B @Y+,-1(X) \ 4 char1-char2
0<> UNTIL               \ 2 if char1=char2 loopback
    U< IF               \   char1<char2
FW1     MOV #-1,TOS     \ 1
        MOV @IP+,PC     \ 4
    THEN                \ 2 char1>char2
FW2     MOV #1,TOS      \ 1
FW3     MOV @IP+,PC     \ 4     20 words
ENDCODE
    \

\ [DEFINED] COMPARE [IF]
\ \ ------------------------------------------------------------------------
\ TESTING COMPARE
\ : CMOVE MOVE ;
\ : s1 S" abcdefghijklmnopqrstuvwxyz" ;
\ : s6 S" 123456" ;
\ 
\ T{ s1        s1 COMPARE ->  0  }T 
\ T{ s1  PAD SWAP CMOVE   ->     }T    \ Copy s1 to PAD 
\ T{ s1  PAD OVER COMPARE ->  0  }T 
\ T{ s1     PAD 6 COMPARE ->  1  }T 
\ T{ PAD 10    s1 COMPARE -> -1  }T 
\ T{ s1     PAD 0 COMPARE ->  1  }T 
\ T{ PAD  0    s1 COMPARE -> -1  }T 
\ T{ s1        s6 COMPARE ->  1  }T 
\ T{ s6        s1 COMPARE -> -1  }T
\ : "abdde" S" abdde" ; 
\ : "abbde" S" abbde" ; 
\ : "abcdf" S" abcdf" ; 
\ : "abcdee" S" abcdee" ;
\ 
\ T{ s1 "abdde"  COMPARE -> -1 }T 
\ T{ s1 "abbde"  COMPARE ->  1 }T 
\ T{ s1 "abcdf"  COMPARE -> -1 }T 
\ T{ s1 "abcdee" COMPARE ->  1 }T
\ 
\ : s11 S" 0abc" ; 
\ : s12 S" 0aBc" ;
\ 
\ T{ s11 s12 COMPARE ->  1 }T 
\ T{ s12 s11 COMPARE -> -1 }T
\ 
\ [THEN]      \ COMPARE

