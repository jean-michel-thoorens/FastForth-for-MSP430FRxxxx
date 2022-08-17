\ PID controller written in Forth
\ Based on the code presented here:
\ http://brettbeauregard.com/blog/2011/04/improving-the-beginners-pid-introduction/

\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433

MARKER {PID}

[UNDEFINED] VARIABLE [IF]
\ https://forth-standard.org/standard/core/VARIABLE
\ VARIABLE <name>       --                      define a Forth VARIABLE
: VARIABLE 
CREATE
HI2LO
MOV @RSP+,IP
MOV #DOVAR,-4(W)        \   CFA = DOVAR
MOV @IP+,PC
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

[UNDEFINED] STATE [IF]
\ https://forth-standard.org/standard/core/STATE
\ STATE   -- a-addr       holds compiler state
STATEADR CONSTANT STATE
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

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] SPACE [IF]
\ https://forth-standard.org/standard/core/SPACE
\ SPACE   --               output a space
: SPACE
$20 EMIT ;
[THEN]

[UNDEFINED] R> [IF]
\ https://forth-standard.org/standard/core/Rfrom
\ R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
CODE R>
MOV rDOVAR,PC
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

[UNDEFINED] 1+ [IF]
\ https://forth-standard.org/standard/core/OnePlus
\ 1+      n1/u1 -- n2/u2       add 1 to TOS
CODE 1+
ADD #1,TOS
MOV @IP+,PC
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


[UNDEFINED] 2NIP [IF]
\ 2NIP   d1 d2 -- d2
CODE 2NIP
MOV @PSP,X
ADD #4,PSP
MOV X,0(PSP)
NEXT
ENDCODE
[THEN]

[UNDEFINED] 2DUP  [IF]
\ https://forth-standard.org/standard/core/TwoDUP
\ 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
CODE 2DUP
SUB #4,PSP          \ -- x1 x x x2
MOV TOS,2(PSP)      \ -- x1 x2 x x2
MOV 4(PSP),0(PSP)   \ -- x1 x2 x1 x2
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

[UNDEFINED] 2DROP [IF]
\ https://forth-standard.org/standard/core/TwoDROP
\ 2DROP  x1 x2 --          drop 2 cells
CODE 2DROP
ADD #2,PSP
MOV @PSP+,TOS
MOV @IP+,PC
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
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] DABS [IF]
\ https://forth-standard.org/standard/double/DABS
\ DABS     d1 -- |d1|     absolute value
CODE DABS
AND #-1,TOS         \ clear V, set N
U< IF               \ if positive (N=0)
    XOR #-1,0(PSP)  \ 4
    XOR #-1,TOS     \ 1
    ADD #1,0(PSP)   \ 4
    ADDC #0,TOS     \ 1
THEN
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 2@ [IF]
    \ https://forth-standard.org/standard/core/TwoFetch
    \ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
    CODE 2@
    SUB #2,PSP
    MOV 2(TOS),0(PSP)
    MOV @TOS,TOS
    NEXT
    ENDCODE
[THEN]

[UNDEFINED] 2! [IF]
    \ https://forth-standard.org/standard/core/TwoStore
    \ x1 x2 addr --     Store the cell pair x1 x2 at a-addr, with x2 at a-addr and x1 at the next consecutive cell.
    CODE 2!
    MOV @PSP+,0(TOS)
    MOV @PSP+,2(TOS)
    MOV @PSP+,TOS
    NEXT
    ENDCODE
[THEN]

\ https://forth-standard.org/standard/core/TwotoR
\ ( x1 x2 -- ) ( R: -- x1 x2 )   Transfer cell pair x1 x2 to the return stack.
CODE 2>R
PUSH @PSP+
PUSH TOS
MOV @PSP+,TOS
NEXT
ENDCODE

\ https://forth-standard.org/standard/core/TwoRFetch
\ ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 ) Copy cell pair x1 x2 from the return stack.
CODE 2R@
SUB #4,PSP
MOV TOS,2(PSP)
MOV @RSP,TOS
MOV 2(RSP),0(PSP)
NEXT
ENDCODE

\ https://forth-standard.org/standard/core/TwoRfrom
\ ( -- x1 x2 ) ( R: x1 x2 -- )  Transfer cell pair x1 x2 from the return stack
CODE 2R>
SUB #4,PSP
MOV TOS,2(PSP)
MOV @RSP+,TOS       
MOV @RSP+,0(PSP)
NEXT
ENDCODE

[UNDEFINED] 2VARIABLE [IF]
\ https://forth-standard.org/standard/double/TwoVARIABLE
: 2VARIABLE \  --
CREATE 4 ALLOT
;
[THEN]

[UNDEFINED] 2CONSTANT [IF] \ defined if MEM_EXT
    \ https://forth-standard.org/standard/double/TwoCONSTANT
    : 2CONSTANT \  udlo/dlo/Qlo udhi/dhi/Qhi --         to create double or Q15.16 CONSTANT
    CREATE , ,  \ compile Qhi then Qlo
    DOES> 2@    \ execution part    addr -- Qhi Qlo
    ;
[THEN]

[UNDEFINED] <> [IF]
\ https://forth-standard.org/standard/core/ne
\ =      ( x1 x2 -- flag ) flag is true if and only if x1 is not bit-for-bit the same as x2
CODE <>
SUB @PSP+,TOS   \ 2
0<> IF 
    MOV #-1,TOS
THEN
NEXT            \ 4
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

\ https://forth-standard.org/standard/core/Uless
\ U<    u1 u2 -- flag       test u1<u2, unsigned
[UNDEFINED] U< [IF]
CODE U<
SUB @PSP+,TOS   \ 2 u2-u1
0<> IF
    MOV #-1,TOS     \ 1
    U< IF           \ 2 flag 
        AND #0,TOS  \ 1 flag Z = 1
    THEN
THEN
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

\ ------------------------------------------------------------------------------
\ CONTROL STRUCTURES
\ ------------------------------------------------------------------------------
\ THEN and BEGIN compile nothing
\ DO compile one word
\ IF, ELSE, AGAIN, UNTIL, WHILE, REPEAT, LOOP & +LOOP compile two words
\ LEAVE compile three words
\
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

[UNDEFINED] DEFER! [IF]
\ https://forth-standard.org/standard/core/DEFERStore
\ Set the word xt1 to execute xt2. An ambiguous condition exists if xt1 is not for a word defined by DEFER.
CODE DEFER!             \ xt2 xt1 --
MOV @PSP+,2(TOS)        \ -- xt1=CFA_DEFER          xt2 --> [CFA_DEFER+2]
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] IS [IF]
\ https://forth-standard.org/standard/core/IS
\ IS <name>        xt --
\ used as is :
\ DEFER DISPLAY                         create a "do nothing" definition (2 CELLS)
\ inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
\ or in a definition : ... ['] U. IS DISPLAY ...
\ KEY, EMIT, CR, ACCEPT and WARM are examples of DEFERred words
\
\ as IS replaces the PFA value of any word, it's a TO alias for VARIABLE and CONSTANT words...
: IS
STATE @
IF  POSTPONE ['] POSTPONE DEFER! 
ELSE ' DEFER! 
THEN
; IMMEDIATE
[THEN]

[UNDEFINED] >BODY [IF]
\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
CODE >BODY
ADD #4,TOS
MOV @IP+,PC
ENDCODE
[THEN]

\ =============================================================================
\ fixpoint words
CODE F+
BW1 ADD @PSP+,2(PSP)
    ADDC @PSP+,TOS
    NEXT                \ 4
ENDCODE

CODE F-
BW1 SUB @PSP+,2(PSP)
    SUBC TOS,0(PSP)
    MOV @PSP+,TOS
    NEXT                \ 4
ENDCODE

\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
\ (2 supplementary bytes are room for sign - and decimal point)
\ C HOLDS    addr u --
CODE HOLDS
BW3         MOV @PSP+,X     \ 2
            ADD TOS,X       \ 1 src
            MOV &HP,Y       \ 3 dst
BEGIN       SUB #1,X        \ 1 src-1
            SUB #1,TOS      \ 1 cnt-1
U>= WHILE   SUB #1,Y        \ 1 dst-1
            MOV.B @X,0(Y)   \ 4
REPEAT      MOV Y,&HP       \ 3
            MOV @PSP+,TOS   \ 2
            MOV @IP+,PC     \ 4  15 words
ENDCODE

TLV_ORG 4 + @ $81F3 U<
$81EF TLV_ORG 4 + @ U< 
= [IF]   ; MSP430FR2xxx|MSP430FR4xxx subfamilies without hardware_MPY


CODE F/                     \ Q15.16 / Q15.16 --> Q15.16 result
        PUSHM #4,R7    
        MOV @PSP+,R6        \ DVRlo
        MOV @PSP+,X         \ DVDhi --> REMlo
        MOV #0,W            \ REMhi = 0
        MOV @PSP,Y          \ DVDlo --> DVDhi
        MOV #0,T            \ DVDlo = 0
        MOV X,S             \
        XOR TOS,S           \ DVDhi XOR DVRhi --> S keep sign of result
        AND #-1,X           \ DVD < 0 ? 
S< IF   XOR #-1,Y           \ INV(DVDlo)
        XOR #-1,X           \ INV(DVDhi)
        ADD #1,Y            \ INV(DVDlo)+1
        ADDC #0,X           \ INV(DVDhi)+C
THEN    AND #-1,TOS         \ DVR < 0 ?
S< IF   XOR #-1,R6          \ INV(DVRlo)
        XOR #-1,TOS         \ INV(DVRhi)
        ADD #1,R6           \ INV(DVRlo)+1
        ADDC #0,TOS         \ INV(DVRhi)+C
THEN
\ don't uncomment lines below !
\ ------------------------------------------------------------------------
\           UD/MOD    DVDlo DVDhi DVRlo DVRhi -- REMlo REMhi QUOTlo QUOThi
\ ------------------------------------------------------------------------
\           MOV 4(PSP),T    \ DVDlo
\           MOV 2(PSP),Y    \ DVDhi
\           MOV #0,X        \ REMlo = 0
\           MOV #0,W        \ REMhi = 0
            MOV #32,R5      \  init loop count
BW1         CMP TOS,W       \ 1 REMhi = DVRhi ?
    0= IF   CMP R6,X        \ 1 REMlo U< DVRlo ?
    THEN
    U>= IF  SUB R6,X        \ 1 no:  REMlo - DVRlo  (carry is set)
            SUBC TOS,W      \ 1      REMhi - DVRhi
    THEN
BW2         ADDC R7,R7      \ 1 RLC quotLO
            ADDC R4,R4      \ 1 RLC quotHI
            SUB #1,R5       \ 1 Decrement loop counter
            0< ?GOTO FW1    \ 2 out of loop if count<0    
            ADD T,T         \ 1 RLA DVDlo
            ADDC Y,Y        \ 1 RLC DVDhi
            ADDC X,X        \ 1 RLC REMlo
            ADDC W,W        \ 1 RLC REMhi
            U< ?GOTO BW1    \ 2 15~ loop 
            SUB R6,X        \ 1 REMlo - DVRlo
            SUBC TOS,W      \ 1 REMhi - DVRhi
            BIS #1,SR       \ 1
            GOTO BW2        \ 2 16~ loop
FW1
\           MOV X,4(PSP)    \ REMlo    
\           MOV W,2(PSP)    \ REMhi
\           ADD #4,PSP      \ skip REMlo REMhi
            MOV R7,0(PSP)   \ QUOTlo
            MOV R4,TOS      \ QUOThi
            POPM #4,R7      \ restore R4 to R7
\           MOV @IP+,PC     \ end of UD/MOD
\ ------------------------------------------------------------------------
BW1     AND #-1,S           \ clear V, set N; QUOT < 0 ?
S< IF   XOR #-1,0(PSP)      \ INV(QUOTlo)
        XOR #-1,TOS         \ INV(QUOThi)
        ADD #1,0(PSP)       \ INV(QUOTlo)+1
        ADDC #0,TOS         \ INV(QUOThi)+C
THEN    MOV @IP+,PC
ENDCODE

\ F#S    Qlo Qhi u -- Qhi 0   convert fractional part Qlo of Q15.16 fixed point number
\                             with u digits
CODE F#S 
            MOV 2(PSP),X            \ -- Qlo Qhi u      X = Qlo
            MOV @PSP,2(PSP)         \ -- Qhi Qhi u
            MOV X,0(PSP)            \ -- Qhi Qlo u
            PUSHM #2,TOS            \                   save TOS,IP
            MOV #0,S                \ -- Qhi Qlo x
BEGIN       PUSH S                  \                   R-- limit IP count
            MOV &BASEADR,TOS        \ -- Qhi Qlo base
            LO2HI
            UM*                     \                   u1 u2 -- RESlo REShi
            HI2LO                   \ -- Qhi RESlo digit
            SUB #2,IP
            CMP #10,TOS             \                   digit to char
    U>= IF  ADD #7,TOS
    THEN    ADD #$30,TOS
            MOV @RSP+,S             \                       R-- limit IP
            MOV.B TOS,HOLDS_ORG(S)  \ -- Qhi RESlo char     char to string
            ADD #1,S                \                       count+1
            CMP 2(RSP),S            \                       count=limit ?
U>= UNTIL   
            POPM #2,TOS             \                       restore IP,TOS
            MOV #0,0(PSP)           \ -- Qhi 0 len
            SUB #2,PSP              \ -- Qhi 0 x len
            MOV #HOLDS_ORG,0(PSP)   \ -- Qhi 0 addr len
            GOTO BW3                \ jump HOLDS
ENDCODE

\ unsigned multiply 32*32 = 64
\ don't use S reg (keep sign)
CODE UDM*
            PUSH IP         \ 3
            PUSHM #4,R7     \ 6 save R7 ~ R4 regs
            MOV 4(PSP),IP   \ 3 MDlo
            MOV 2(PSP),T    \ 3 MDhi
            MOV @PSP,W      \ 2 MRlo
            MOV #0,R4       \ 1 MDLO=0
            MOV #0,R5       \ 1 MDHI=0
            MOV #0,4(PSP)   \ 3 RESlo=0
            MOV #0,2(PSP)   \ 3 REShi=0
            MOV #0,R6       \ 1 RESLO=0
            MOV #0,R7       \ 1 RESHI=0
            MOV #1,X        \ 1 BIT TEST REGlo
            MOV #0,Y        \ 1 BIT TEST2 REGhi
BEGIN       CMP #0,X    
    0<> IF  BIT X,W         \ 2+1 TEST ACTUAL BIT MRlo
    ELSE    BIT Y,TOS       \ 2+1 TEST ACTUAL BIT MRhi
    THEN
    0<> IF  ADD IP,4(PSP)   \ 2+3 IF 1: ADD MDlo TO RESlo
            ADDC T,2(PSP)   \ 3      ADDC MDhi TO REShi
            ADDC R4,R6      \ 1      ADDC MDLO TO RESLO        
            ADDC R5,R7      \ 1      ADDC MDHI TO RESHI
    THEN    ADD IP,IP       \ 1 (RLA LSBs) MDlo *2
            ADDC T,T        \ 1 (RLC MSBs) MDhi *2
            ADDC R4,R4      \ 1 (RLA LSBs) MDLO *2
            ADDC R5,R5      \ 1 (RLC MSBs) MDHI *2
            ADD X,X         \ 1 (RLA) NEXT BIT TO TEST
            ADDC Y,Y        \ 1 (RLA) NEXT BIT TO TEST
U>= UNTIL   MOV R6,0(PSP)   \ 2+2 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
            MOV R7,TOS      \ 1 high result in TOS
            POPM #4,R7      \ 6 restore R4 to R7
            MOV @RSP+,IP    \ 2
            MOV @IP+,PC
ENDCODE

CODE F*                 \ s15.16 * s15.16 --> s15.16 result
    MOV 2(PSP),S        \
    XOR TOS,S           \ 1s15 XOR 2s15 --> S keep sign of result
    BIT #$8000,2(PSP)   \ MD < 0 ? 
0<> IF  XOR #-1,2(PSP)
        XOR #-1,4(PSP)
        ADD #1,4(PSP)
        ADDC #0,2(PSP)
THEN
    COLON
    DABS UDM*           \ -- RES0 RES1 RES2 RES3
    HI2LO
    MOV @RSP+,IP
    MOV @PSP+,TOS       \ -- RES0 RES1 RES2
    MOV @PSP+,0(PSP)    \ -- RES1 RES2
    GOTO BW1            \ goto end of F/ to process sign of result
ENDCODE

[ELSE] \ hardware multiplier

CODE F/                     \ Q15.16 / Q15.16 --> Q15.16 result
\ TOS = DVRhi
\ 0(PSP) = DVRlo
\ 2(PSP) = DVDhi
\ 4(PSP) = DVDlo
        PUSHM #4,R7         \ 6 PUSHM R7 to R4
        MOV @PSP+,R6        \ 2 DVRlo
        MOV @PSP+,X         \ 2 DVDhi --> REMlo
        MOV #0,W            \ 1 REMhi = 0
        MOV @PSP,Y          \ 2 DVDlo --> DVDhi
        MOV #0,T            \ 1 DVDlo = 0
        MOV X,S             \ 1
        XOR TOS,S           \ 1 DVDhi XOR DVRhi --> S keep sign of result
        AND #-1,X           \ 1 DVD < 0 ? 
S< IF   XOR #-1,Y           \ 1 INV(DVDlo)
        XOR #-1,X           \ 1 INV(DVDhi)
        ADD #1,Y            \ 1 INV(DVDlo)+1
        ADDC #0,X           \ 1 INV(DVDhi)+C
THEN    AND #-1,TOS         \ 1 DVR < 0 ?
S< IF   XOR #-1,R6          \ 1 INV(DVRlo)
        XOR #-1,TOS         \ 1 INV(DVRhi)
        ADD #1,R6           \ 1 INV(DVRlo)+1
        ADDC #0,TOS         \ 1 INV(DVRhi)+C
THEN    MOV #32,R5          \ 2 init loop count
BW1     CMP TOS,W           \ 1 REMhi = DVRhi ?
    0= IF                   \ 2
        CMP R6,X            \ 1 REMlo U< DVRlo ?
    THEN
    U>= IF                  \ 2  
        SUB R6,X            \ 1 no:  REMlo - DVRlo  (carry is set)
        SUBC TOS,W          \ 1      REMhi - DVRhi
    THEN
BW2     ADDC R7,R7          \ 1 RLC quotLO
        ADDC R4,R4          \ 1 RLC quotHI
        SUB #1,R5           \ 1 Decrement loop counter
        0< ?GOTO FW1        \ 2 out of loop if count<0    
        ADD T,T             \ 1 RLA DVDlo
        ADDC Y,Y            \ 1 RLC DVDhi
        ADDC X,X            \ 1 RLC REMlo
        ADDC W,W            \ 1 RLC REMhi
        U< ?GOTO BW1        \ 2 19~ loop 
        SUB R6,X            \ 1 REMlo - DVRlo
        SUBC TOS,W          \ 1 REMhi - DVRhi
        BIS #1,SR           \ 1
        GOTO BW2            \ 2 16~ loop
FW1     AND #-1,S           \ 1 clear V, set N; QUOT < 0 ?
S< IF   XOR #-1,R7          \ 1 INV(QUOTlo)
        XOR #-1,R4          \ 1 INV(QUOThi)
        ADD #1,R7           \ 1 INV(QUOTlo)+1
        ADDC #0,R4          \ 1 INV(QUOThi)+C
THEN    MOV R7,0(PSP)       \ 3 QUOTlo
        MOV R4,TOS          \ 1 QUOThi
        POPM #4,R7          \ 6 restore R4 to R7
        MOV @IP+,PC         \ 4
ENDCODE

\ F#S    Qlo Qhi u -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
\                             with u digits
CODE F#S
            MOV 2(PSP),X            \ -- Qlo Qhi u      X = Qlo
            MOV @PSP,2(PSP)         \ -- Qhi Qhi u
            MOV X,0(PSP)            \ -- Qhi Qlo u
            MOV TOS,T               \                   T = limit
            MOV #0,S                \                   S = count
BEGIN       MOV @PSP,&MPY           \                   Load 1st operand
            MOV &BASEADR,&OP2       \                   Load 2nd operand
            MOV &RES0,0(PSP)        \ -- Qhi RESlo x        low result on stack
            MOV &RES1,TOS           \ -- Qhi RESlo REShi    high result in TOS
            CMP #10,TOS             \                   digit to char
    U>= IF  ADD #7,TOS
    THEN    ADD #$30,TOS
            MOV.B TOS,HOLDS_ORG(S)  \ -- Qhi RESlo char     char to string
            ADD #1,S                \                   count+1
            CMP T,S                 \                   count=limit ?
0= UNTIL    MOV #0,0(PSP)           \ -- Qhi 0 REShi
            MOV T,TOS               \ -- Qhi 0 limit
            SUB #2,PSP              \ -- Qhi 0 x len
            MOV #HOLDS_ORG,0(PSP)   \ -- Qhi 0 addr len
            GOTO BW3                \ jump HOLDS
ENDCODE

CODE F*                 \ signed s15.16 multiplication --> s15.16 result
    MOV 4(PSP),&MPYS32L \ 5 Load 1st operand
    MOV 2(PSP),&MPYS32H \ 5
    MOV @PSP,&OP2L      \ 4 load 2nd operand
    MOV TOS,&OP2H       \ 3
    ADD #4,PSP          \ 1 remove 2 cells
\    NOP2                \ 2
\    NOP2                \ 2 wait 8 cycles after write OP2L before reading RES1
    MOV &RES1,0(PSP)    \ 5
    MOV &RES2,TOS       \ 5
    MOV @IP+,PC
ENDCODE

[THEN]  \ hardware multiplier

CODE F.N            \ ( f n -- ) display a Q15.16 number with n digits after comma
MOV TOS,T           \ T = #digits
MOV @PSP+,TOS
MOV TOS,S           \ S = sign
PUSHM #3,IP         \                   R-- IP sign #digit
LO2HI
    <# DABS         \ -- uQlo uQhi      R-- IP sign #digit
    R> F#S          \ -- uQhi 0         R-- IP sign
    $2C HOLD        \                   $2C = char ','
    #S              \ -- 0 0
    R> SIGN #>      \ -- addr len       R-- IP
    TYPE SPACE      \ --         
;


\ https://forth-standard.org/standard/double/Dless
\ flag is true if and only if d1 is less than d2
CODE D<
            MOV @PSP+,S         \ S=d2L
            MOV @PSP+,T         \ T=d1H
            MOV @PSP+,W         \ W=d1L
BW1         CMP TOS,T           \ 1 d1H - d2H
            MOV #0,TOS          \ 1 -- false_flag       by default
S< IF       MOV #-1,TOS         \ 2 -- true_flag        if d1H < d2H
THEN
0= IF       CMP S,W             \ 1 -- false_flag       d1L - d2L
    S< IF   MOV #-1,TOS         \ 1 -- true_flag        if (d1H = d2H) & (d1L < d2L)
    THEN
THEN
NEXT                            \ 4
ENDCODE

\ : D> 2SWAP D< ;
CODE D>
MOV TOS,T           \ T=d2H
MOV @PSP+,W         \ W=d2L
MOV @PSP+,TOS       \ TOS=d1H
MOV @PSP+,S         \ S=d1L
GOTO BW1
ENDCODE

CODE S2F \ ( s -- f )  Signed number to fixed point
    SUB #2,PSP
    MOV #0,0(PSP)
    MOV @IP+,PC
ENDCODE

: F2S \ ( f -- s )  Fixed point to signed number (rounded)
  SWAP $8000 AND IF 1 + THEN ;

: DMIN \ ( d1 d2 -- d_min )  Minimum of double number (also for fixed-point)
  2OVER 2OVER
  D< IF 2DROP ELSE 2NIP THEN
;

: DMAX \ ( d1 d2 -- d_max )  Maximum of double number (also for fixed-point)
  2OVER 2OVER
  D> IF 2DROP ELSE 2NIP THEN
;

: DRANGE \ ( d_val d_min d_max -- d_val )  Make sure a double number is in range
  2ROT DMIN DMAX
;

: RANGE \ ( s_val s_min s_max -- s_val )  Make sure a number is in range
  ROT MIN MAX
;

: F.000 3 F.N ;  \ Output fixed point value

\ Setup variables for pid control
2VARIABLE KP            \ Proportionnal coeff, scaled to input range.
2VARIABLE KI            \ integral coeff, in second
2VARIABLE KD            \ derivative coeff, in second
VARIABLE SETPOINT       \ setpoint, same scale as input

VARIABLE SAMPLE_TIME    \ sampling interval in ms
VARIABLE OUT_MAX        \ output max limit (--> 20 mA)
VARIABLE OUT_MIN        \ output min limit (--> 4 mA)
VARIABLE OUT-OVERRIDE   \ output override (auto mode if -1)

\ Working variables while pid is running
VARIABLE SET-VAL        \ current setpoint
VARIABLE INPUT_PREV     \ last seen input
2VARIABLE I_SUM         \ cummulative i error

VARIABLE DEBUG          \ PID compute state
0 DEBUG !

: ?DEBUG DEBUG @ ;


\ =============================================================================
\ Main PID - internal definitions (do not call manually)
\ inputs and outputs are 16 bits numbers
\ PID parameters and PID compute are Q15.16 numbers.

: CALC-P \ ( f_error -- f_correction )  Calculate proportionnal output
KP 2@ F*                 \ fetch k-value and scale error
?DEBUG IF ." Pval:" 2DUP F2S . 
THEN    
;


: CALC-I \ ( f_error -- f_correction )  Calculate integral output
KI 2@ F*                \ apply ki factor
I_SUM 2@ F+             \ sum up with running integral error
OUT_MIN @ S2F 
OUT_MAX @ S2F
DRANGE \ cap inside output range
2DUP I_SUM 2!           \ update running integral error
?DEBUG IF  ." Ival:" 2DUP F2S . 
THEN
;

: CALC-D \ ( s_is -- f_correction )  Calculate differential output
  \ actually use "derivative on input", not on error
  INPUT_PREV @ -           \ substract last input from current input
  S2F KD 2@ F*             \ make fixed point, fetch kd factor and multiply
?DEBUG IF  ." Dval:" 2DUP F2S . 
THEN
;

: PID_COMPUTE \ ( s_is -- s_corr )  Do a PID calculation, return duty-cycle
\  CR ." SET:" SET-VAL @ .  ." IS:"  DUP . \ DEBUG
\ feed error in p and i, current setpoint in d, sum up results
DUP DUP SET-VAL @ SWAP - S2F  \ ( s_is s_is f_error )
2DUP  CALC-P                  \ ( s_is s_is f_error f_p )
2SWAP CALC-I F+               \ ( s_is s_is f_p+i )
ROT   CALC-D F-               \ ( s_is f_p+i+d ) \ substract! derivate on input - not error

F2S                           \ ( s_is s_corr )
?DEBUG IF  ." OUT:" DUP .
THEN
SWAP INPUT_PREV !             \ Update INPUT_PREV for next run
OUT_MIN @ OUT_MAX @ RANGE     \ Make sure we return something inside PWM range
?DEBUG IF  ." PWM:" DUP .
THEN
;

\ =============================================================================
\ Main PID - external interface

: SET \ ( s -- )  Change setpoint on a running pid
  SET-VAL ! ;

: TUNING \  ( f_kp f_ki f_kd -- )  Change tuning-parameters on a running pid
  \ depends on sampletime, so fetch it, move to fixed-point and change unit to seconds
  \ store on return stack for now
  SAMPLE_TIME @ S2F 1000,0 F/ 2>R  \ 

  2R@ F/ KD 2!                  \ translate from 1/s to the sampletime
  2R> F* KI 2!                  \ translate from 1/s to the sampletime
         KP 2! ;

\ Init PID
\ To use in a *reverse acting system* (bigger output value **reduced**
\ input value make sure `kp`, `ki` and `kd` are **all** negative.
\ Starts pid in manual mode (no setpoint set!). Set setpoint and call auto
\ to start the control loop.
: PID-INIT \ ( f_kp f_ki f_kd s_sampletime s_outmin s_outmax  -- )
  OUT_MAX !
  OUT_MIN !
  SAMPLE_TIME !
  TUNING
  0 OUT-OVERRIDE !         \ Make sure we're in manual mode
  CR ." PID initialized - kp:" KP 2@ F.000 ." ki:" KI 2@ F.000 ." kd:" KD 2@ F.000
;

\ Returns calculated PID value or override value if in manual mode
: PID \ ( s_is -- s_corr )
  OUT-OVERRIDE @ -1 = IF   \ we're in auto-mode - do PID calculation
    PID_COMPUTE
  ELSE                     \ manual-mode! store input, return override value
    CR ." SET:" SET-VAL @ .  ." IS:"  DUP .
    INPUT_PREV !
    OUT-OVERRIDE @
    ." PWM:" DUP .
  THEN ;

: MANUAL \ ( s -- )  Override output - switches PID into *manual mode*
  OUT-OVERRIDE ! ;


: AUTO \ ( -- )  Switch back to auto-mode after manual mode
  OUT-OVERRIDE @ -1 <> IF \ only do something if we'r in override mode
    \ store current output value as i to let it run smoothly
    OUT-OVERRIDE @
    OUT_MIN @ OUT_MAX @ RANGE   \ Make sure we return something inside PWM range
    S2F I_SUM 2!                \ init I_SUM
    -1 OUT-OVERRIDE !
  THEN ;

: AUTOHOLD \ ( -- )  Bring PID back to auto-mode after a manual override
  INPUT_PREV @ SET-VAL !   \ Use last input as setpoint (no bumps!)
  AUTO ;



\ \ ******************************\
\ ASM BACKGROUND                  \
\ \ ******************************\
\ BEGIN
\ \     ...                         \ insert here your background task
\ \     ...                         \
\ \     ...                         \
\     CALL &RXON                  \ comment this line to disable TERMINAL_INPUT
\     BIS &LPM_MODE,SR            \
\ \ ******************************\
\ \ here start all interrupts     \
\ \ ******************************\
\ \ here return all interrupts    \
\ \ ******************************\
\ AGAIN                           \
\ ENDASM                          \
\ \ ******************************\

\ ------------------------------\
CODE STOP                       \ stops multitasking, must to be used before downloading app
\ ------------------------------\
    MOV @IP+,PC
ENDCODE

\ ------------------------------\
CODE APP_INIT                   \ this routine completes the init of system, i.e. FORTH + this app.
\ ------------------------------\
    MOV @IP+,PC
ENDCODE                               \

\ ------------------------------\
CODE START                      \ this routine replaces WARM and SLEEP default values by these of this application.
\ ------------------------------\
\ MOV #SLEEP,X                    \ replace default background process SLEEP
\ MOV #BACKGROUND,2(X)            \ by RC5toLCD BACKGROUND
\ MOV #WARM,X                     \ replace default WARM
\ MOV #APP_INIT,2(X)              \ by RC5toLCD APP_INIT
\ MOV X,PC                        \ then execute it
    MOV @IP+,PC
ENDCODE 


ECHO
