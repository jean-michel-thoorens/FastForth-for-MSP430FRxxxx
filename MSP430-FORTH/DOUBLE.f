\ -*- coding: utf-8 -*-

; -----------------------------------------------------
; DOUBLE.f
; -----------------------------------------------------

; -----------------------------------------------------------
; requires DOUBLE_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, DOUBLE_INPUT
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

PWR_STATE

[DEFINED] {DOUBLE} [IF]  {DOUBLE} [THEN]

MARKER {DOUBLE}

[UNDEFINED] >R [IF]
\ https://forth-standard.org/standard/core/toR
\ >R    x --   R: -- x   push to return stack
CODE >R
PUSH TOS
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] R> [IF]
\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
CODE R>
SUB #2,PSP      \ 1
MOV TOS,0(PSP)  \ 3
MOV @RSP+,TOS   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] @ [IF]
\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- char   fetch char from memory
CODE @
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] ! [IF]
\ https://forth-standard.org/standard/core/Store
\ !        x a-addr --   store cell in memory
CODE !
MOV @PSP+,0(TOS)    \ 4
MOV @PSP+,TOS       \ 2
MOV @IP+,PC         \ 4
ENDCODE
[THEN]

[UNDEFINED] C@ [IF]
\ https://forth-standard.org/standard/core/CFetch
\ C@     c-addr -- char   fetch char from memory
CODE C@
MOV.B @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] SWAP [IF]
\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
CODE SWAP
MOV @PSP,W      \ 2
MOV TOS,0(PSP)  \ 3
MOV W,TOS       \ 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] OVER [IF]
\ https://forth-standard.org/standard/core/OVER
\ OVER    x1 x2 -- x1 x2 x1
CODE OVER
MOV TOS,-2(PSP)     \ 3 -- x1 (x2) x2
MOV @PSP,TOS        \ 2 -- x1 (x2) x1
SUB #2,PSP          \ 1 -- x1 x2 x1
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] ROT [IF]
\ https://forth-standard.org/standard/core/ROT
\ ROT    x1 x2 x3 -- x2 x3 x1
CODE ROT
MOV @PSP,W          \ 2 fetch x2
MOV TOS,0(PSP)      \ 3 store x3
MOV 2(PSP),TOS      \ 3 fetch x1
MOV W,2(PSP)        \ 3 store x2
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] - [IF]
\ https://forth-standard.org/standard/core/Minus
\ -      n1/u1 n2/u2 -- n3/u3     n3 = n1-n2
CODE -
SUB @PSP+,TOS   \ 2  -- n2-n1 ( = -n3)
XOR #-1,TOS     \ 1
ADD #1,TOS      \ 1  -- n3 = -(n2-n1) = n1-n2
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] < [IF]      \ define < and >
\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
CODE <
        SUB @PSP+,TOS   \ 1 TOS=n2-n1
        S< ?GOTO FW1    \ 2 signed
        0<> IF          \ 2
BW1         MOV #-1,TOS \ 1 flag Z = 0
        THEN
        MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/more
\ >     n1 n2 -- flag         test n1>n2, signed
CODE >
        SUB @PSP+,TOS   \ 2 TOS=n2-n1
        S< ?GOTO BW1    \ 2 --> +5
FW1     AND #0,TOS      \ 1 flag Z = 1
        MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] IF [IF]     \ define IF THEN
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

\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
CODE THEN               \ immediate
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
CODE ELSE     \ immediate
ADD #4,&DP              \ make room to compile two words
MOV &DP,W               \ W=HERE+4
MOV #BRAN,-4(W)
MOV W,0(TOS)            \ HERE+4 ==> [IFadr]
SUB #2,W                \ HERE+2
MOV W,TOS               \ -- ELSEadr
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] TO [IF]
\ https://forth-standard.org/standard/core/TO
CODE TO
BIS #UF10,SR
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] DOES> [IF]
\ https://forth-standard.org/standard/core/DOES
\ DOES>    --          set action for the latest CREATEd definition
CODE DOES> 
MOV &LAST_CFA,W         \ W = CFA of CREATEd word
MOV #DODOES,0(W)        \ replace CFA (DOCON) by new CFA (DODOES)
MOV IP,2(W)             \ replace PFA by the address after DOES> as execution address
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] SPACES [IF]
\ https://forth-standard.org/standard/core/SPACES
\ SPACES   n --            output n spaces
CODE SPACES
CMP #0,TOS
0<> IF
    PUSH IP
    BEGIN
        LO2HI
        $20 EMIT
        HI2LO
        SUB #2,IP 
        SUB #1,TOS
    0= UNTIL
    MOV @RSP+,IP
THEN
MOV @PSP+,TOS           \ --         drop n
NEXT              
ENDCODE
[THEN]

[UNDEFINED] 2@ [IF]
\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
CODE 2@
SUB #2,PSP
MOV 2(TOS),0(PSP)
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 2! [IF]
\ https://forth-standard.org/standard/core/TwoStore
\ 2!    x1 x2 a-addr --    store 2 cells ; the top of stack is stored at the lower adr
CODE 2!
MOV @PSP+,0(TOS)
MOV @PSP+,2(TOS)
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 2DUP [IF]
\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
CODE 2DUP
SUB #4,PSP          \ -- x1 x x x2
MOV TOS,2(PSP)      \ -- x1 x2 x x2
MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x2
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2DROP [IF]
\ https://forth-standard.org/standard/core/TwoDROP
\ 2DROP  x1 x2 --          drop 2 cells
CODE 2DROP
ADD #2,PSP
MOV @PSP+,TOS
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2SWAP [IF]
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
[THEN]

[UNDEFINED] 2OVER [IF]
\ https://forth-standard.org/standard/core/TwoOVER
\ 2OVER  x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2
CODE 2OVER
SUB #4,PSP          \ -- x1 x2 x3 x x x4
MOV TOS,2(PSP)      \ -- x1 x2 x3 x4 x x4
MOV 8(PSP),0(PSP)   \ -- x1 x2 x3 x4 x1 x4
MOV 6(PSP),TOS      \ -- x1 x2 x3 x4 x1 x2
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2>R [IF]
\ https://forth-standard.org/standard/core/TwotoR
\ ( x1 x2 -- ) ( R: -- x1 x2 )   Transfer cell pair x1 x2 to the return stack.
CODE 2>R
PUSH @PSP+
PUSH TOS
MOV @PSP+,TOS
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2R@ [IF]
\ https://forth-standard.org/standard/core/TwoRFetch
\ ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 ) Copy cell pair x1 x2 from the return stack.
CODE 2R@
SUB #4,PSP
MOV TOS,2(PSP)
MOV @RSP,TOS
MOV 2(RSP),0(PSP)
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2R> [IF]
\ https://forth-standard.org/standard/core/TwoRfrom
\ ( -- x1 x2 ) ( R: x1 x2 -- )  Transfer cell pair x1 x2 from the return stack
CODE 2R>
SUB #4,PSP
MOV TOS,2(PSP)
MOV @RSP+,TOS
MOV @RSP+,0(PSP)
NEXT
ENDCODE
[THEN]

\ ===============================================
\ DOUBLE word set
\ ===============================================

[UNDEFINED] D. [IF]
\ https://forth-standard.org/standard/double/Dd
\ D.     dlo dhi --           display d (signed)
CODE D.
MOV #U.,W   \ U. + 10 = D.
ADD #10,W
MOV W,PC
ENDCODE
[THEN]

[UNDEFINED] 2ROT [IF]
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
[THEN]

[UNDEFINED] D>S [IF]
\ https://forth-standard.org/standard/double/DtoS
\ D>S    d -- n          double prec -> single.
CODE D>S
MOV @PSP+,TOS
NEXT
ENDCODE
[THEN]

[UNDEFINED] D0= [IF]
\ https://forth-standard.org/standard/double/DZeroEqual
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
[THEN]

[UNDEFINED] D0< [IF]
\ https://forth-standard.org/standard/double/DZeroless
CODE D0<
CMP #0,TOS
MOV #0,TOS
S< IF
    MOV #-1,TOS
THEN
ADD #2,PSP
NEXT
ENDCODE
[THEN]

[UNDEFINED] D= [IF]
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
[THEN]

[UNDEFINED] D< [IF]
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
[THEN]

[UNDEFINED] DU< [IF]
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
[THEN]

[UNDEFINED] D+ [IF]
\ https://forth-standard.org/standard/double/DPlus
CODE D+
BW1 ADD @PSP+,2(PSP)
    ADDC @PSP+,TOS
NEXT                \ 4
ENDCODE
[THEN]

[UNDEFINED] M+ [IF]
\ https://forth-standard.org/standard/double/MPlus
CODE M+
SUB #2,PSP
CMP #0,TOS
MOV TOS,0(PSP)
MOV #-1,TOS
0>= IF
    MOV #0,TOS
THEN
GOTO BW1
ENDCODE
[THEN]

[UNDEFINED] D- [IF]
\ https://forth-standard.org/standard/double/DMinus
CODE D-
SUB @PSP+,2(PSP)
SUBC TOS,0(PSP)
MOV @PSP+,TOS
NEXT                \ 4
ENDCODE
[THEN]

[UNDEFINED] DNEGATE [IF]
\ https://forth-standard.org/standard/double/DNEGATE
CODE DNEGATE
XOR #-1,0(PSP)
XOR #-1,TOS
ADD #1,0(PSP)
ADDC #0,TOS
NEXT                \ 4
ENDCODE
[THEN]

[UNDEFINED] DABS [IF]
\ https://forth-standard.org/standard/double/DABS
\ DABS     d1 -- |d1|     absolute value
CODE DABS
CMP #0,TOS       \  1
0>= IF
    MOV @IP+,PC
THEN
MOV #DNEGATE,PC
ENDCODE
[THEN]

[UNDEFINED] D2/ [IF]
\ https://forth-standard.org/standard/double/DTwoDiv
CODE D2/
RRA TOS
RRC 0(PSP)
NEXT                \ 4
ENDCODE
[THEN]

[UNDEFINED] D2* [IF]
\ https://forth-standard.org/standard/double/DTwoTimes
CODE D2*
ADD @PSP,0(PSP)
ADDC TOS,TOS
NEXT                \ 4
ENDCODE
[THEN]

[UNDEFINED] DMAX [IF]
\ https://forth-standard.org/standard/double/DMAX
: DMAX              \ -- d1 d2
2OVER 2OVER         \ -- d1 d2 d1 d2
D< IF               \ -- d1 d2
    2>R 2DROP 2R>   \ -- d2
ELSE                \ -- d1 d2
    2DROP           \ -- d1 
THEN
;
[THEN]

[UNDEFINED] DMIN [IF]
\ https://forth-standard.org/standard/double/DMIN
: DMIN              \ -- d1 d2
2OVER 2OVER         \ -- d1 d2 d1 d2
D< IF               \ -- d1 d2
    2DROP           \ -- d1
ELSE 2>R 2DROP 2R>  \ -- d1 d2
THEN                \ -- d2 
;

DEVICEID C@ $EF > [IF] ; test tag value for MSP430FR413x devices without hardware_MPY 

[UNDEFINED] M*/ [IF]
\ https://forth-standard.org/standard/double/MTimesDiv
CODE M*/    \ d1lo d1hi n1 +n2 -- d2lo d2hi
BIC #UF9,SR                 \ clear RES sign flag
CMP #0,2(PSP)               \ d1 < 0 ? 
S< IF
    XOR #-1,4(PSP)
    XOR #-1,2(PSP)
    ADD #1,4(PSP)
    ADDC #0,2(PSP)
    BIS #UF9,SR             \ set RES sign flag
THEN                        \ ud1
CMP #0,0(PSP)               \ n1 < 0 ?
S< IF
    XOR #-1,0(PSP)
    ADD #1,0(PSP)           \ u1
    BIT #UF9,SR
    0= IF 
        BIS #UF9,SR
    ELSE
        BIC #UF9,SR
    THEN
THEN                        \ let's process UM*     -- ud1lo ud1hi u1 +n2
            MOV 4(PSP),Y            \ 3 uMDlo
            MOV 2(PSP),T            \ 3 uMDhi
            MOV @PSP+,S             \ 2 uMRlo        -- ud1lo ud1hi +n2
            MOV #0,rDODOES          \ 1 uMDlo=0
            MOV #0,2(PSP)           \ 3 uRESlo=0
            MOV #0,0(PSP)           \ 3 uRESmi=0     -- uRESlo uRESmi +n2 
            MOV #0,W                \ 1 uREShi=0
            MOV #1,X                \ 1 BIT TEST REGlo
BEGIN       BIT X,S                 \ 1 test actual bit in uMRlo
    0<> IF  ADD Y,2(PSP)            \ 3 IF 1: ADD uMDlo TO uRESlo
            ADDC T,0(PSP)           \ 3      ADDC uMDmi TO uRESmi
            ADDC rDODOES,W          \ 1      ADDC uMRlo TO uREShi        
    THEN    ADD Y,Y                 \ 1 (RLA LSBs) uMDlo *2
            ADDC T,T                \ 1 (RLC MSBs) uMDhi *2
            ADDC rDODOES,rDODOES    \ 1 (RLA LSBs) uMDlo *2
            ADD X,X                 \ 1 (RLA) NEXT BIT TO TEST
U>= UNTIL                           \ 1 IF BIT IN CARRY: FINISHED   W=uREShi
MOV TOS,T                   \     T = +n2 
MOV @PSP,TOS                \ -- uRESlo uRESmi uRESmi
MOV 2(PSP),S                \ S=uRESlo, TOS=uRESmi, W=uREShi

MOV #32,rDODOES             \ 2  init loop count
CALL #MDIV1                 \ -- urem ud2lo ud2hi
MOV @PSP+,0(PSP)            \ -- d2lo d2hi
BIT #UF9,SR                 \ sign of RES is set ?
0<> IF                      \ DNEGATE
    XOR #-1,0(PSP)
    XOR #-1,TOS
    ADD #1,0(PSP)
    ADDC #0,TOS
    BIC #UF9,SR             \       clear sign flag
\ now, make floored division, only used if rem<>0 and quot<0 :  
    CMP #0,W                \ remainder <> 0 ?
    0<> IF
        SUB #1,0(PSP)       \ decrement quotient
        SUBC #0,TOS 
    THEN
THEN                
NEXT                \ 4
ENDCODE
[THEN]

[ELSE]  \ hardware multiplier

[UNDEFINED] M*/ [IF]
\ https://forth-standard.org/standard/double/MTimesDiv
CODE M*/                \ d1 * n1 / +n2 -- d2
MOV 4(PSP),&MPYS32L     \ 5             Load 1st operand    d1lo    
MOV 2(PSP),&MPYS32H     \ 5                                 d1hi
MOV @PSP+,&OP2          \ 4 -- d1 n2    load 2nd operand    n1     
MOV TOS,T               \ T = DIV
NOP3
MOV &RES0,S             \ 3 S = RESlo
MOV &RES1,TOS           \ 3 TOS = RESmi
MOV &RES2,W             \ 3 W = REShi
BIC #UF9,SR             \ clear sign flag
CMP #0,W                \ negative product ?
S< IF                   \ DABS if yes
    XOR #-1,S
    XOR #-1,TOS
    XOR #-1,W
    ADD #1,S
    ADDC #0,TOS
    ADDC #0,W
    BIS #UF9,SR         \ set RES sign flag
THEN
MOV #32,rDODOES         \ 2  init loop count
CALL #MDIV1             \ -- urem ud2lo ud2hi
MOV @PSP+,0(PSP)        \ -- d2lo d2hi
BIT #UF9,SR             \ RES sign is set ?
0<> IF                  \ DNEGATE
    XOR #-1,0(PSP)
    XOR #-1,TOS
    ADD #1,0(PSP)
    ADDC #0,TOS
    BIC #UF9,SR         \ clear sign flag
\ now, make floored division, only used if rem<>0 and quot<0 :  
    CMP #0,W            \ remainder <> 0 ?
    0<> IF
        SUB #1,0(PSP)   \ decrement quotient
        SUBC #0,TOS 
    THEN
THEN                
NEXT                    \ 52 words
ENDCODE
[THEN]

[THEN]  ; end of software/hardware_MPY

[UNDEFINED] 2VARIABLE [IF]
\ https://forth-standard.org/standard/double/TwoVARIABLE
: 2VARIABLE \  --
CREATE 
HI2LO
ADD #4,&DP
MOV @RSP+,IP
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2CONSTANT [IF]
\ https://forth-standard.org/standard/double/TwoCONSTANT
: 2CONSTANT \  udlo/dlo/Flo udhi/dhi/Shi --         to create double or s15q16 CONSTANT
CREATE
, ,             \ compile Shi then Flo
DOES>
2@              \ execution part
;
[THEN]

[UNDEFINED] 2VALUE [IF]
\ https://forth-standard.org/standard/double/TwoVALUE
: 2VALUE        \ x1 x2 "<spaces>name" --
CREATE , ,      \ compile Shi then Flo
DOES>
HI2LO
MOV @RSP+,IP
BIT #UF9,SR    \ see TO
0= IF
   MOV #2@,PC
THEN 
BIC #UF9,SR
MOV #2!,PC
ENDCODE
[THEN]

[UNDEFINED] 2LITERAL [IF]
\ https://forth-standard.org/standard/double/TwoLITERAL
CODE 2LITERAL
BIS #UF9,SR     \ see LITERAL
MOV #LITERAL,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] D.R [IF]
\ https://forth-standard.org/standard/double/DDotR
\ D.R       d n --
: D.R
>R SWAP OVER DABS <# #S ROT SIGN #> 
R> OVER - SPACES TYPE 
;
[THEN]

[THEN] \ end of {DOUBLE}

RST_HERE

\ --------------------------------------------------------------------------------
\ --------------------------------------------------------------------------------
\ Complement to test DOUBLE
\ --------------------------------------------------------------------------------
\ --------------------------------------------------------------------------------

[UNDEFINED] VARIABLE [IF]
\ https://forth-standard.org/standard/core/VARIABLE
: VARIABLE \  --
CREATE 
HI2LO
MOV @RSP+,IP
ADD #2,&DP
NEXT
ENDCODE
[THEN]

[UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT 
: CONSTANT 
CREATE
HI2LO
MOV TOS,-2(W)           \   PFA = n
MOV @PSP+,TOS
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] CELLS [IF]
\ https://forth-standard.org/standard/core/CELLS
\ CELLS    n1 -- n2            cells->adrs units
CODE CELLS
ADD TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] ALLOT [IF]
\ https://forth-standard.org/standard/core/ALLOT
\ ALLOT   n --         allocate n bytes
CODE ALLOT
ADD TOS,&DP
MOV @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] DEPTH [IF]
\ https://forth-standard.org/standard/core/DEPTH
\ DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
CODE DEPTH
MOV TOS,-2(PSP)
MOV #PSTACK,TOS
SUB PSP,TOS     \ PSP-S0--> TOS
RRA TOS         \ TOS/2   --> TOS
SUB #2,PSP      \ post decrement stack...
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] DUP [IF]
\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
CODE DUP
BW1 SUB #2,PSP      \ 2  push old TOS..
    MOV TOS,0(PSP)  \ 3  ..onto stack
    MOV @IP+,PC     \ 4
ENDCODE

\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
CODE ?DUP
CMP #0,TOS      \ 2  test for TOS nonzero
0<> ?GOTO BW1    \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] DO [IF]     \ define DO LOOP +LOOP
\ https://forth-standard.org/standard/core/DO
\ DO       -- DOadr   L: -- 0
CODE DO                 \ immediate
SUB #2,PSP              \
MOV TOS,0(PSP)          \
ADD #2,&DP              \   make room to compile xdo
MOV &DP,TOS             \ -- HERE+2
MOV #XDO,-2(TOS)        \   compile xdo
ADD #2,&LEAVEPTR        \ -- HERE+2     LEAVEPTR+2
MOV &LEAVEPTR,W         \
MOV #0,0(W)             \ -- HERE+2     L-- 0
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/LOOP
\ LOOP    DOadr --         L-- an an-1 .. a1 0
CODE LOOP               \ immediate
    MOV #XLOOP,X
BW1 ADD #4,&DP          \ make room to compile two words
    MOV &DP,W
    MOV X,-4(W)         \ xloop --> HERE
    MOV TOS,-2(W)       \ DOadr --> HERE+2
BEGIN                   \ resolve all "leave" adr
    MOV &LEAVEPTR,TOS   \ -- Adr of top LeaveStack cell
    SUB #2,&LEAVEPTR    \ --
    MOV @TOS,TOS        \ -- first LeaveStack value
    CMP #0,TOS          \ -- = value left by DO ?
0<> WHILE
    MOV W,0(TOS)        \ move adr after loop as UNLOOP adr
REPEAT
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/PlusLOOP
\ +LOOP   adrs --   L-- an an-1 .. a1 0
CODE +LOOP              \ immediate
MOV #XPLOOP,X
GOTO BW1
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] I [IF]
\ https://forth-standard.org/standard/core/I
\ I        -- n   R: sys1 sys2 -- sys1 sys2
\                  get the innermost loop index
CODE I
SUB #2,PSP              \ 1 make room in TOS
MOV TOS,0(PSP)          \ 3
MOV @RSP,TOS            \ 2 index = loopctr - fudge
SUB 2(RSP),TOS          \ 3
MOV @IP+,PC             \ 4 13~
ENDCODE
[THEN]

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
CODE =
SUB @PSP+,TOS   \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1
    MOV @IP+,PC \ 4
THEN
XOR #-1,TOS     \ 1 flag Z = 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] 0= [IF]
\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
CODE 0=
SUB #1,TOS      \ borrow (clear cy) if TOS was 0
SUBC TOS,TOS    \ TOS=-1 if borrow was set
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] SOURCE [IF]
\ https://forth-standard.org/standard/core/SOURCE
\ SOURCE    -- adr u    of current input buffer
CODE SOURCE
SUB #4,PSP
MOV TOS,2(PSP)
MOV &SOURCE_LEN,TOS
MOV &SOURCE_ORG,0(PSP)
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] >IN [IF]
\ https://forth-standard.org/standard/core/toIN
\ C >IN     -- a-addr       holds offset in input stream
TOIN CONSTANT >IN
[THEN]

[UNDEFINED] SWAP [IF]
\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
CODE SWAP
MOV @PSP,W      \ 2
MOV TOS,0(PSP)  \ 3
MOV W,TOS       \ 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
CODE DROP
MOV @PSP+,TOS   \ 2
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
CODE 1+
ADD #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] CHAR [IF]
\ https://forth-standard.org/standard/core/CHAR
\ CHAR   -- char           parse ASCII character
: CHAR
    $20 WORD 1+ C@
;
[THEN]

[UNDEFINED] [CHAR] [IF]
\ https://forth-standard.org/standard/core/BracketCHAR
\ [CHAR]   --          compile character literal
: [CHAR]
    CHAR POSTPONE LITERAL
; IMMEDIATE
[THEN]

[UNDEFINED] 2/ [IF]
\ https://forth-standard.org/standard/core/TwoDiv
\ 2/      x1 -- x2        arithmetic right shift
CODE 2/
RRA TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] INVERT [IF]
\ https://forth-standard.org/standard/core/INVERT
\ INVERT   x1 -- x2            bitwise inversion
CODE INVERT
XOR #-1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] RSHIFT [IF]
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
[THEN]

[UNDEFINED] 0< [IF]
\ https://forth-standard.org/standard/core/Zeroless
\ 0<     n -- flag      true if TOS negative
CODE 0<
ADD TOS,TOS     \ 1 set carry if TOS negative
SUBC TOS,TOS    \ 1 TOS=-1 if carry was clear
XOR #-1,TOS     \ 1 TOS=-1 if carry was set
MOV @IP+,PC     \ 
ENDCODE
[THEN]

[UNDEFINED] S>D [IF]
\ https://forth-standard.org/standard/core/StoD
\ S>D    n -- d          single -> double prec.
: S>D
    DUP 0<
;
[THEN]

[UNDEFINED] 1- [IF]
\ https://forth-standard.org/standard/core/OneMinus
\ 1-      n1/u1 -- n2/u2     subtract 1 from TOS
CODE 1-
SUB #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] UM/MOD [IF]
\ https://forth-standard.org/standard/core/UMDivMOD
\ UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->r16 q16
CODE UM/MOD
    PUSH #DROP      \
    MOV #MUSMOD,PC  \ execute MUSMOD then return to DROP
ENDCODE
[THEN]

[UNDEFINED] SM/REM [IF]
\ https://forth-standard.org/standard/core/SMDivREM
\ SM/REM   DVDlo DVDhi DIVlo -- r3 q4  symmetric signed div
CODE SM/REM
MOV TOS,S           \           S=DIVlo
MOV @PSP,T          \           T=DVD_sign==>rem_sign
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
    XOR #-1,TOS
    ADD #1,TOS
THEN                \ -- n3 n4  S=divisor
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] FM/MOD [IF]
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
[THEN]

[UNDEFINED] NIP [IF]
\ https://forth-standard.org/standard/core/NIP
\ NIP      x1 x2 -- x2         Drop the first item below the top of stack
CODE NIP
ADD #2,PSP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] / [IF]
\ https://forth-standard.org/standard/core/Div
\ /      n1 n2 -- n3       signed quotient
: /
>R DUP 0< R> FM/MOD NIP
;
[THEN]

[UNDEFINED] NEGATE [IF]
\ https://forth-standard.org/standard/core/NEGATE
\ C NEGATE   x1 -- x2            two's complement
CODE NEGATE
XOR #-1,TOS
ADD #1,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] HERE [IF]
CODE HERE
MOV #HEREADR,PC
ENDCODE
[THEN]

[UNDEFINED] CHARS [IF]
\ https://forth-standard.org/standard/core/CHARS
\ CHARS    n1 -- n2            chars->adrs units
CODE CHARS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] MOVE [IF]
\ https://forth-standard.org/standard/core/MOVE
\ MOVE    addr1 addr2 u --     smart move
\             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
CODE MOVE
MOV TOS,W           \ W = cnt
MOV @PSP+,Y         \ Y = addr2 = dst
MOV @PSP+,X         \ X = addr1 = src
MOV @PSP+,TOS       \ pop new TOS
CMP #0,W            \ count = 0 ?
0<> IF              \ if 0, already done !
    CMP X,Y         \ Y-X \ dst - src
    0<> IF          \ else already done !
        U< IF       \ U< if src > dst
            BEGIN   \ copy W bytes
                MOV.B @X+,0(Y)
                ADD #1,Y
                SUB #1,W
            0= UNTIL
            MOV @IP+,PC \ out 1 of MOVE ====>
        THEN        \ U>= if dst > src
        ADD W,Y     \ copy W bytes beginning with the end
        ADD W,X
        BEGIN
            SUB #1,X
            SUB #1,Y
            MOV.B @X,0(Y)
            SUB #1,W
        0= UNTIL
    THEN
THEN
MOV @IP+,PC \ out 2 of MOVE ====>
ENDCODE
[THEN]

 0 CONSTANT FALSE
-1 CONSTANT TRUE

\ SET THE FOLLOWING FLAG TO TRUE FOR MORE VERBOSE OUTPUT; THIS MAY
\ ALLOW YOU TO TELL WHICH TEST CAUSED YOUR SYSTEM TO HANG.
VARIABLE VERBOSE
    FALSE VERBOSE !
\   TRUE VERBOSE !

\ : EMPTY-STACK ( ... -- )  \ EMPTY STACK: HANDLES UNDERFLOWED STACK TOO.
\     DEPTH ?DUP
\             IF DUP 0< IF NEGATE 0
\             DO 0 LOOP
\             ELSE 0 DO DROP LOOP THEN
\             THEN ;
\ 
\ : ERROR     \ ( C-ADDR U -- ) DISPLAY AN ERROR MESSAGE FOLLOWED BY
\         \ THE LINE THAT HAD THE ERROR.
\     TYPE SOURCE TYPE CR          \ DISPLAY LINE CORRESPONDING TO ERROR
\     EMPTY-STACK              \ THROW AWAY EVERY THING ELSE
\     QUIT  \ *** Uncomment this line to QUIT on an error
\ ;

VARIABLE ACTUAL-DEPTH           \ STACK RECORD
CREATE ACTUAL-RESULTS 20 CELLS ALLOT

: T{        \ ( -- ) SYNTACTIC SUGAR.
    ;

: ->        \ ( ... -- ) RECORD DEPTH AND CONTENT OF STACK.
    DEPTH DUP ACTUAL-DEPTH !     \ RECORD DEPTH
    ?DUP IF              \ IF THERE IS SOMETHING ON STACK
        0 DO ACTUAL-RESULTS I CELLS + ! LOOP \ SAVE THEM
    THEN ;

: }T        \ ( ... -- ) COMPARE STACK (EXPECTED) CONTENTS WITH SAVED
            \ (ACTUAL) CONTENTS.
    DEPTH ACTUAL-DEPTH @ = IF   \ IF DEPTHS MATCH
        DEPTH ?DUP IF           \ IF THERE IS SOMETHING ON THE STACK
        0 DO                    \ FOR EACH STACK ITEM
            ACTUAL-RESULTS I CELLS + @  \ COMPARE ACTUAL WITH EXPECTED
\           = 0= IF S" INCORRECT RESULT: " ERROR LEAVE THEN \ jmt
            = 0= IF TRUE ABORT" INCORRECT RESULT" THEN      \ jmt : abort with colorised message
        LOOP
        THEN
    ELSE                 \ DEPTH MISMATCH
\       S" WRONG NUMBER OF RESULTS: " ERROR     \ jmt
        TRUE ABORT" WRONG NUMBER OF RESULTS"    \ jmt : abort with colorised message
    THEN ;

: TESTING   \ ( -- ) TALKING COMMENT.
    SOURCE VERBOSE @
    IF DUP >R TYPE CR R> >IN !
    ELSE >IN ! DROP [CHAR] * EMIT
    THEN ;

-1 CONSTANT 1S
0 CONSTANT <FALSE>
-1 CONSTANT <TRUE>
0 INVERT 1 RSHIFT           CONSTANT MAX-INT    ; 011...1
0 INVERT 1 RSHIFT INVERT    CONSTANT MIN-INT    ; 100...0
MAX-INT 2/                  CONSTANT HI-INT     ; 001...1 
MIN-INT 2/                  CONSTANT LO-INT     ; 110...0
-1 MAX-INT                  2CONSTANT MAX-2INT  ; 011...1 
0 MIN-INT                   2CONSTANT MIN-2INT  ; 100...0 
MAX-2INT 2/                 2CONSTANT HI-2INT   ; 001...1
MIN-2INT 2/                 2CONSTANT LO-2INT   ; 110...0

ECHO

; --------------------------------------------------------------------------------
; DOUBLE tests
; --------------------------------------------------------------------------------

\ MAX-INT .
\ MIN-INT .
\ HI-INT .
\ LO-INT .
\ MAX-2INT D.
\ MIN-2INT D.
\ HI-2INT D.
\ LO-2INT D.
\ 
\ 2CONSTANT
T{ 1 2 2CONSTANT 2c1 -> }T 
T{ 2c1 -> 1 2 }T
T{ : cd1 2c1 ; -> }T 
T{ cd1 -> 1 2 }T

T{ : cd2 2CONSTANT ; -> }T 
T{ -1 -2 cd2 2c2 -> }T 
T{ 2c2 -> -1 -2 }T

T{ 4 5 2CONSTANT 2c3 IMMEDIATE 2c3 -> 4 5 }T 
T{ : cd6 2c3 2LITERAL ; cd6 -> 4 5 }T

\ 2VARIABLE
T{ 2VARIABLE 2v1 -> }T 
T{ 0. 2v1 2! ->    }T 
T{    2v1 2@ -> 0. }T 
T{ -1 -2 2v1 2! ->       }T 
T{       2v1 2@ -> -1 -2 }T
T{ : cd2 2VARIABLE ; -> }T 
T{ cd2 2v2 -> }T 
T{ : cd3 2v2 2! ; -> }T 
T{ -2 -1 cd3 -> }T 
T{ 2v2 2@ -> -2 -1 }T

T{ 2VARIABLE 2v3 IMMEDIATE 5 6 2v3 2! -> }T 
T{ 2v3 2@ -> 5 6 }T

\ 2LITERAL
T{ : cd1 [ MAX-2INT ] 2LITERAL ; -> }T
T{ cd1 -> MAX-2INT }T
T{ 2VARIABLE 2v4 IMMEDIATE 5 6 2v4 2! -> }T 
T{ : cd7 2v4 [ 2@ ] 2LITERAL ; cd7 -> 5 6 }T 
T{ : cd8 [ 6 7 ] 2v4 [ 2! ] ; 2v4 2@ -> 6 7 }T

\ 2VALUE
T{ 1 2 2VALUE t2val -> }T 
T{ t2val -> 1 2 }T 
T{ 3 4 TO t2val -> }T 
T{ t2val -> 3 4 }T 
: sett2val t2val 2SWAP TO t2val ; 
T{ 5 6 sett2val t2val -> 3 4 5 6 }T

\ D+
T{  0.  5. D+ ->  5. }T                         \ small integers 
T{ -5.  0. D+ -> -5. }T 
T{  1.  2. D+ ->  3. }T 
T{  1. -2. D+ -> -1. }T 
T{ -1.  2. D+ ->  1. }T 
T{ -1. -2. D+ -> -3. }T 
T{ -1.  1. D+ ->  0. }T
T{  0  0  0  5 D+ ->  0  5 }T                  \ mid range integers 
T{ -1  5  0  0 D+ -> -1  5 }T 
T{  0  0  0 -5 D+ ->  0 -5 }T 
T{  0 -5 -1  0 D+ -> -1 -5 }T 
T{  0  1  0  2 D+ ->  0  3 }T 
T{ -1  1  0 -2 D+ -> -1 -1 }T 
T{  0 -1  0  2 D+ ->  0  1 }T 
T{  0 -1 -1 -2 D+ -> -1 -3 }T 
T{ -1 -1  0  1 D+ -> -1  0 }T

T{ MIN-INT 0 2DUP D+ -> 0 1 }T 
T{ MIN-INT S>D MIN-INT 0 D+ -> 0 0 }T

T{  HI-2INT       1. D+ -> 0 HI-INT 1+ }T    \ large double integers 
T{  HI-2INT     2DUP D+ -> 1S 1- MAX-INT }T 
T{ MAX-2INT MIN-2INT D+ -> -1. }T 
T{ MAX-2INT  LO-2INT D+ -> HI-2INT }T 
T{  LO-2INT     2DUP D+ -> MIN-2INT }T 
T{  HI-2INT MIN-2INT D+ 1. D+ -> LO-2INT }T

\ D-
T{  0.  5. D- -> -5. }T              \ small integers 
T{  5.  0. D- ->  5. }T 
T{  0. -5. D- ->  5. }T 
T{  1.  2. D- -> -1. }T 
T{  1. -2. D- ->  3. }T 
T{ -1.  2. D- -> -3. }T 
T{ -1. -2. D- ->  1. }T 
T{ -1. -1. D- ->  0. }T 
T{  0  0  0  5 D- ->  0 -5 }T       \ mid-range integers 
T{ -1  5  0  0 D- -> -1  5 }T 
T{  0  0 -1 -5 D- ->  1  4 }T 
T{  0 -5  0  0 D- ->  0 -5 }T 
T{ -1  1  0  2 D- -> -1 -1 }T 
T{  0  1 -1 -2 D- ->  1  2 }T 
T{  0 -1  0  2 D- ->  0 -3 }T 
T{  0 -1  0 -2 D- ->  0  1 }T 
T{  0  0  0  1 D- ->  0 -1 }T
T{ MIN-INT 0 2DUP D- -> 0. }T 
T{ MIN-INT S>D MAX-INT 0 D- -> 1 1S }T 
T{ MAX-2INT max-2INT D- -> 0. }T    \ large integers 
T{ MIN-2INT min-2INT D- -> 0. }T 
T{ MAX-2INT  hi-2INT D- -> lo-2INT DNEGATE }T 
T{  HI-2INT  lo-2INT D- -> max-2INT }T 
T{  LO-2INT  hi-2INT D- -> min-2INT 1. D+ }T 
T{ MIN-2INT min-2INT D- -> 0. }T 
T{ MIN-2INT  lo-2INT D- -> lo-2INT }T

\ D0<
T{                0. D0< -> <FALSE> }T 
T{                1. D0< -> <FALSE> }T 
T{  MIN-INT        0 D0< -> <FALSE> }T 
T{        0  MAX-INT D0< -> <FALSE> }T 
T{          MAX-2INT D0< -> <FALSE> }T 
T{               -1. D0< -> <TRUE>  }T 
T{          MIN-2INT D0< -> <TRUE>  }T

\ D0=
T{               1. D0= -> <FALSE> }T 
T{ MIN-INT        0 D0= -> <FALSE> }T 
T{         MAX-2INT D0= -> <FALSE> }T 
T{      -1  MAX-INT D0= -> <FALSE> }T 
T{               0. D0= -> <TRUE>  }T 
T{              -1. D0= -> <FALSE> }T 
T{       0  MIN-INT D0= -> <FALSE> }T

\ D2*
T{              0. D2* -> 0. D2* }T 
T{ MIN-INT       0 D2* -> 0 1 }T 
T{         HI-2INT D2* -> MAX-2INT 1. D- }T 
T{         LO-2INT D2* -> MIN-2INT }T

\ D2/
T{       0. D2/ -> 0.        }T 
T{       1. D2/ -> 0.        }T 
T{      0 1 D2/ -> MIN-INT 0 }T 
T{ MAX-2INT D2/ -> HI-2INT   }T 
T{      -1. D2/ -> -1.       }T 
T{ MIN-2INT D2/ -> LO-2INT   }T

\ D<
T{       0.       1. D< -> <TRUE>  }T 
T{       0.       0. D< -> <FALSE> }T 
T{       1.       0. D< -> <FALSE> }T 
T{      -1.       1. D< -> <TRUE>  }T 
T{      -1.       0. D< -> <TRUE>  }T 
T{      -2.      -1. D< -> <TRUE>  }T 
T{      -1.      -2. D< -> <FALSE> }T 
T{      -1. MAX-2INT D< -> <TRUE>  }T 
T{ MIN-2INT MAX-2INT D< -> <TRUE>  }T 
T{ MAX-2INT      -1. D< -> <FALSE> }T 
T{ MAX-2INT MIN-2INT D< -> <FALSE> }T
T{ MAX-2INT 2DUP -1. D+ D< -> <FALSE> }T 
T{ MIN-2INT 2DUP  1. D+ D< -> <TRUE>  }T

\ D=
T{      -1.      -1. D= -> <TRUE>  }T 
T{      -1.       0. D= -> <FALSE> }T 
T{      -1.       1. D= -> <FALSE> }T 
T{       0.      -1. D= -> <FALSE> }T 
T{       0.       0. D= -> <TRUE>  }T 
T{       0.       1. D= -> <FALSE> }T 
T{       1.      -1. D= -> <FALSE> }T 
T{       1.       0. D= -> <FALSE> }T 
T{       1.       1. D= -> <TRUE>  }T
T{   0   -1    0  -1 D= -> <TRUE>  }T 
T{   0   -1    0   0 D= -> <FALSE> }T 
T{   0   -1    0   1 D= -> <FALSE> }T 
T{   0    0    0  -1 D= -> <FALSE> }T 
T{   0    0    0   0 D= -> <TRUE>  }T 
T{   0    0    0   1 D= -> <FALSE> }T 
T{   0    1    0  -1 D= -> <FALSE> }T 
T{   0    1    0   0 D= -> <FALSE> }T 
T{   0    1    0   1 D= -> <TRUE>  }T

T{ MAX-2INT MIN-2INT D= -> <FALSE> }T 
T{ MAX-2INT       0. D= -> <FALSE> }T 
T{ MAX-2INT MAX-2INT D= -> <TRUE>  }T 
T{ MAX-2INT HI-2INT  D= -> <FALSE> }T 
T{ MAX-2INT MIN-2INT D= -> <FALSE> }T 
T{ MIN-2INT MIN-2INT D= -> <TRUE>  }T 
T{ MIN-2INT LO-2INT  D= -> <FALSE> }T 
T{ MIN-2INT MAX-2INT D= -> <FALSE> }T

\ D>S
T{    1234  0 D>S ->  1234   }T 
T{   -1234 -1 D>S -> -1234   }T 
T{ MAX-INT  0 D>S -> MAX-INT }T 
T{ MIN-INT -1 D>S -> MIN-INT }T


\ DABS
T{       1. DABS -> 1.       }T 
T{      -1. DABS -> 1.       }T 
T{ MAX-2INT DABS -> MAX-2INT }T 
T{ MIN-2INT 1. D+ DABS -> MAX-2INT }T

\ DMAX
T{       1.       2. DMAX ->  2.      }T 
T{       1.       0. DMAX ->  1.      }T 
T{       1.      -1. DMAX ->  1.      }T 
T{       1.       1. DMAX ->  1.      }T 
T{       0.       1. DMAX ->  1.      }T 
T{       0.      -1. DMAX ->  0.      }T 
T{      -1.       1. DMAX ->  1.      }T 
T{      -1.      -2. DMAX -> -1.      }T
T{ MAX-2INT  HI-2INT DMAX -> MAX-2INT }T 
T{ MAX-2INT MIN-2INT DMAX -> MAX-2INT }T 
T{ MIN-2INT MAX-2INT DMAX -> MAX-2INT }T 
T{ MIN-2INT  LO-2INT DMAX -> LO-2INT  }T

T{ MAX-2INT       1. DMAX -> MAX-2INT }T 
T{ MAX-2INT      -1. DMAX -> MAX-2INT }T 
T{ MIN-2INT       1. DMAX ->  1.      }T 
T{ MIN-2INT      -1. DMAX -> -1.      }T

\ DMIN
T{       1.       2. DMIN ->  1.      }T 
T{       1.       0. DMIN ->  0.      }T 
T{       1.      -1. DMIN -> -1.      }T 
T{       1.       1. DMIN ->  1.      }T 
T{       0.       1. DMIN ->  0.      }T 
T{       0.      -1. DMIN -> -1.      }T 
T{      -1.       1. DMIN -> -1.      }T 
T{      -1.      -2. DMIN -> -2.      }T
T{ MAX-2INT  HI-2INT DMIN -> HI-2INT  }T 
T{ MAX-2INT MIN-2INT DMIN -> MIN-2INT }T 
T{ MIN-2INT MAX-2INT DMIN -> MIN-2INT }T 
T{ MIN-2INT  LO-2INT DMIN -> MIN-2INT }T

T{ MAX-2INT       1. DMIN ->  1.      }T 
T{ MAX-2INT      -1. DMIN -> -1.      }T 
T{ MIN-2INT       1. DMIN -> MIN-2INT }T 
T{ MIN-2INT      -1. DMIN -> MIN-2INT }T

\ DNEGATE
T{   0. DNEGATE ->  0. }T 
T{   1. DNEGATE -> -1. }T 
T{  -1. DNEGATE ->  1. }T 
T{ max-2int DNEGATE -> min-2int SWAP 1+ SWAP }T 
T{ min-2int SWAP 1+ SWAP DNEGATE -> max-2int }T

\ 2ROT
T{       1.       2. 3. 2ROT ->       2. 3.       1. }T 
T{ MAX-2INT MIN-2INT 1. 2ROT -> MIN-2INT 1. MAX-2INT }T

\ DU<
T{       1.       1. DU< -> <FALSE> }T 
T{       1.      -1. DU< -> <TRUE>  }T 
T{      -1.       1. DU< -> <FALSE> }T 
T{      -1.      -2. DU< -> <FALSE> }T
T{ MAX-2INT  HI-2INT DU< -> <FALSE> }T 
T{  HI-2INT MAX-2INT DU< -> <TRUE>  }T 
T{ MAX-2INT MIN-2INT DU< -> <TRUE>  }T 
T{ MIN-2INT MAX-2INT DU< -> <FALSE> }T 
T{ MIN-2INT  LO-2INT DU< -> <TRUE>  }T

\ M+
T{ HI-2INT   1 M+ -> HI-2INT   1. D+ }T 
T{ MAX-2INT -1 M+ -> MAX-2INT -1. D+ }T 
T{ MIN-2INT  1 M+ -> MIN-2INT  1. D+ }T 
T{ LO-2INT  -1 M+ -> LO-2INT  -1. D+ }T

\ M*/
-3 2 / . ; if floored you see -2 --> 
: ?floored [ -3 2 / -2 = ] LITERAL IF 1. D- THEN ;

T{       5.       7             11 M*/ ->  3. }T 
T{       5.      -7             11 M*/ -> -3. ?floored }T 
T{      -5.       7             11 M*/ -> -3. ?floored }T 
T{      -5.      -7             11 M*/ ->  3. }T 

T{ MAX-2INT       8             16 M*/ -> HI-2INT }T 
T{ MIN-2INT       8             16 M*/ -> LO-2INT }T 
T{ MAX-2INT      -8             16 M*/ -> HI-2INT DNEGATE ?floored }T  \ actual-results = -1.
T{ MIN-2INT      -8             16 M*/ -> LO-2INT DNEGATE }T

T{ MAX-2INT MAX-INT        MAX-INT M*/ -> MAX-2INT }T 
T{ MAX-2INT MAX-INT 2/     MAX-INT M*/ -> MAX-INT 1- HI-2INT NIP }T 
T{ MIN-2INT LO-2INT NIP DUP NEGATE M*/ -> MIN-2INT }T 
T{ MIN-2INT LO-2INT NIP 1- MAX-INT M*/ -> MIN-INT 3 + HI-2INT NIP 2 + }T 
T{ MAX-2INT LO-2INT NIP DUP NEGATE M*/ -> MAX-2INT DNEGATE }T 
T{ MIN-2INT MAX-INT            DUP M*/ -> MIN-2INT }T

\ D.R
MAX-2INT 71 73 M*/ 2CONSTANT dbl1 
MIN-2INT 73 79 M*/ 2CONSTANT dbl2
: d>ascii \ ( d -- caddr u ) 
   DUP >R <# DABS #S R> SIGN #>  \  ( -- caddr1 u ) 
   HERE SWAP 2DUP 2>R CHARS DUP ALLOT MOVE 2R> 
;

dbl1 d>ascii 2CONSTANT "dbl1" 
dbl2 d>ascii 2CONSTANT "dbl2"

: DoubleOutput 
   CR ." You should see lines duplicated:" CR 
   5 SPACES "dbl1" TYPE CR 
   5 SPACES dbl1 D. CR 
   8 SPACES "dbl1" DUP >R TYPE CR 
   5 SPACES dbl1 R> 3 + D.R CR 
   5 SPACES "dbl2" TYPE CR 
   5 SPACES dbl2 D. CR 
   10 SPACES "dbl2" DUP >R TYPE CR 
   5 SPACES dbl2 R> 5 + D.R CR 
;

T{ DoubleOutput -> }T
