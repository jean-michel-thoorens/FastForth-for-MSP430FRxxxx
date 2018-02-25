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
0<> UNTIL               \ 2 char1=char2  17~ loop
    U< IF               \   char1<char2
FW1     MOV #-1,TOS     \ 1
        MOV @IP+,PC     \ 4
    THEN                \ 2 char1>char2
FW2     MOV #1,TOS      \ 1
FW3     MOV @IP+,PC     \ 4     20 words
ENDCODE
    \

\ [THEN]
\ https://forth-standard.org/standard/tools/BracketTHEN
: [THEN]
; IMMEDIATE
    \

\ [ELSE]
\ Compilation:
\ Perform the execution semantics given below.
\ Execution:
\ ( "<spaces>name ..." -- )
\ Skipping leading spaces, parse and discard space-delimited words from the parse area, 
\ including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN], 
\ until the word [THEN] has been parsed and discarded. 
\ If the parse area becomes exhausted, it is refilled as with REFILL. 
: [ELSE]
1                                   \ -- level 
BEGIN
    BEGIN BL WORD COUNT             \ -- lvl adr len
    DUP                             \ -- lvl adr len len 
    WHILE                           \ -- lvl adr len                test len
        OVER OVER                   \ -- lvl adr len  adr len       OVER OVER = 2DUP
        S" [IF]" COMPARE            \ -- lvl adr len flag
        0= IF                       \ -- lvl adr len 
            DROP DROP 1 +           \ -- lvl+1 
        ELSE                        \ -- lvl adr len 
            OVER OVER               \ -- lvl adr len  adr len
            S" [ELSE]" COMPARE
            0= IF                   \ -- lvl adr len 
                DROP DROP 1 - DUP   \ -- lvl-1 lvl-1
                IF 1 +              \ -- lvl' = lvl
                THEN                \ -- lvl' 
            ELSE                    \ -- lvl adr len 
                S" [THEN]" COMPARE 
                0= IF 1 -           \ -- lvl' = lvl-1
                THEN 
            THEN 
        THEN                        \ -- lvl'
        ?DUP 0= IF
            EXIT                    \ --          if lvl = 0
        THEN                        \ -- lvl' 
    REPEAT
                                    \ -- lvl adr len
    DROP DROP                       \ -- lvl 
    CR ." ko " 
    CIB DUP DPL                     \       refill Current Input Buffer with next line, max length = CPL
    ACCEPT
    HI2LO
    MOV     TOS,&SOURCE_LEN         
    MOV     @PSP+,&SOURCE_ADR       
    MOV     @PSP+,TOS               
    MOV     #0,&>IN 
    LO2HI
AGAIN                               \ -- lvl 
; IMMEDIATE
    \

\ [IF]
\ https://forth-standard.org/standard/tools/BracketIF
\ Compilation:
\ Perform the execution semantics given below.
\ Execution: ;( flag | flag "<spaces>name ..." -- )
\ If flag is true, do nothing. Otherwise, skipping leading spaces, 
\    parse and discard space-delimited words from the parse area, 
\    including nested occurrences of [IF] ... [THEN] and [IF] ... [ELSE] ... [THEN],
\    until either the word [ELSE] or the word [THEN] has been parsed and discarded. 
\ If the parse area becomes exhausted, it is refilled as with REFILL. [IF] is an immediate word.
\ An ambiguous condition exists if [IF] is POSTPONEd, 
\    or if the end of the input buffer is reached and cannot be refilled before the terminating [ELSE] or [THEN] is parsed.
: [IF]
0= IF POSTPONE [ELSE]
THEN 
; IMMEDIATE
    \

\ [UNDEFINED]
\ https://forth-standard.org/standard/tools/BracketUNDEFINED
\ Compilation:
\ Perform the execution semantics given below.
\ Execution: ( "<spaces>name ..." -- flag )
\ Skip leading space delimiters. Parse name delimited by a space. 
\ Return a false flag if name is the name of a word that can be found,
\ otherwise return a true flag.
: [UNDEFINED]
    BL WORD FIND NIP 0=
; IMMEDIATE
    \

\ [DEFINED]
\ https://forth-standard.org/standard/tools/BracketDEFINED
\ Compilation:
\ Perform the execution semantics given below.
\ Execution:
\ ( "<spaces>name ..." -- flag )
\ Skip leading space delimiters. Parse name delimited by a space. 
\ Return a true flag if name is the name of a word that can be found,
\ otherwise return a false flag. [DEFINED] is an immediate word.
: [DEFINED]
    BL WORD FIND NIP
; IMMEDIATE
    \

RST_HERE
