\ -*- coding: utf-8 -*-
; -----------------------------------------------------
; STRING.f
; -----------------------------------------------------

\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP
\ to see FastForth kernel options, download FF_SPECS.f
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    CHIPSTICK_FR2433    MSP_EXP430FR2355
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
\ MSP430ASSEMBLER, CONDCOMP
\
\
\
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
\
\ REGISTERS USAGE
\ rDODOES to rEXIT must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\
\ ASSEMBLER conditionnal usage with ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<
\

\ https://forth-standard.org/standard/string/COMPARE
\ COMPARE ( c-addr1 u1 c-addr2 u2 -- n )
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
            MOV TOS,S       \ 1 S = u2
            MOV @PSP+,Y     \ 2 Y = addr2
            MOV @PSP+,T     \ 2 T = u1     
            MOV @PSP+,X     \ 2 X = addr1
BEGIN       MOV T,TOS       \ 1 TOS = u1
            ADD S,TOS       \ 1 TOS = u1+u2
            0= ?GOTO FW3    \ 2 COMPEQUAL exit if u1=u2=0       and Z=1
            SUB #1,T        \ 1 u1-1
            0< ?GOTO FW2    \ 2 if u1<0 (if u1<u2)
            SUB #1,S        \ 1 u2-1
            0< ?GOTO FW1    \ 2 if u2<0 (if u1>u2)
            ADD #1,X        \ 1 
            CMP.B @Y+,-1(X) \ 4 char1-char2
0<> UNTIL                   \ 2 loop back if char1=char2  17~ loop
0>= IF
FW1         MOV #1,TOS      \ COMPGREATER: u1>u2 | char1>char2  and Z=0
            MOV @IP+,PC
THEN
FW2         MOV #-1,TOS     \ COMPLESS: u1<u2 | char1<char2     and Z=0
FW3         MOV @IP+,PC     \ 20 + 5 words def'n


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

