\ -*- coding: utf-8 -*-

; -----------------------------------------------------
; FIXPOINT.f 
; -----------------------------------------------------

; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, FIXPOINT_INPUT
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433  MSP_EXP430FR4133    MSP_EXP430FR2355    CHIPSTICK_FR2433
\
\ REGISTERS USAGE
\ rDODOES to rEXIT must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use
\ 
\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
\ PUSHM order : PSP,TOS,IP,S,T,W, X, Y,  rDOCOL  ,  rDOVAR  ,  rDOCON  ,   rDODOES   , R3, SR, RSP, PC
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  PC, RSP, SR, R3,   rDODOES   ,  rDOCON  ,  rDOVAR  ,  rDOCOL , Y, X,W,T,S,IP,TOS,PSP
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<
\

PWR_STATE

[DEFINED] {FIXPOINT} [IF]  {FIXPOINT} [THEN]

[UNDEFINED] {FIXPOINT} [IF]

MARKER {FIXPOINT}

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
MOV @IP+,PC
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

[UNDEFINED] DABS [IF]
\ https://forth-standard.org/standard/double/DABS
\ DABS     d1 -- |d1|     absolute value
CODE DABS
AND #-1,TOS         \ clear V, set N
S< IF               \
    XOR #-1,0(PSP)  \ 4
    XOR #-1,TOS     \ 1
    ADD #1,0(PSP)   \ 4
    ADDC #0,TOS     \ 1
THEN
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] HOLDS [IF]
\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
\ (2 supplementary bytes are room for sign - and decimal point)
\ C HOLDS    addr u --
CODE HOLDS
            MOV @PSP+,X         \ 2     X=src
BW3         ADD TOS,X           \ 1     X=src_end
            MOV &HP,Y           \ 3     Y=dst
BEGIN       SUB #1,X            \ 1     src-1
            SUB #1,TOS          \ 1     cnt-1
U>= WHILE   SUB #1,Y            \ 1     dst-1
            MOV.B @X,0(Y)       \ 4     
REPEAT      MOV Y,&HP           \ 3
            MOV @PSP+,TOS       \ 2
            MOV @IP+,PC         \ 4  15 words
ENDCODE
[THEN]

CODE F+                         \ add Q15.16|double numbers
            ADD @PSP+,2(PSP)    \ -- sumlo  d1hi d2hi
            ADDC @PSP+,TOS      \ -- sumlo sumhi
            MOV @IP+,PC
ENDCODE

CODE F-                         \ substract Q15.16|double numbers
            SUB @PSP+,2(PSP)    \ -- diflo d1hi d2hi
            SUBC TOS,0(PSP)     \ -- diflo difhi d2hi
            MOV @PSP+,TOS
            MOV @IP+,PC
ENDCODE

TLV_ORG 4 + @ $81F3 U<
$81EF TLV_ORG 4 + @ U< 
= [IF]   ; MSP430FR413x subfamily without hardware_MPY

\ unsigned multiply 32*32 = 64
\ don't use S reg (keep sign)
CODE UDM*
            PUSH IP             \ 3
            PUSHM #4,rDOVAR     \ 6 save rDOVAR to rDOCOL regs to use M to R alias
            MOV 4(PSP),IP       \ 3 MDlo
            MOV 2(PSP),T        \ 3 MDhi
            MOV @PSP,W          \ 2 MRlo
            MOV #0,M            \ 1 MDLO=0
            MOV #0,P            \ 1 MDHI=0
            MOV #0,4(PSP)       \ 3 RESlo=0
            MOV #0,2(PSP)       \ 3 REShi=0
            MOV #0,Q            \ 1 RESLO=0
            MOV #0,R            \ 1 RESHI=0
            MOV #1,X            \ 1 BIT TEST REGlo
            MOV #0,Y            \ 1 BIT TEST2 REGhi
BEGIN       CMP #0,X    
    0<> IF  BIT X,W             \ 2+1 TEST ACTUAL BIT MRlo
    ELSE    BIT Y,TOS           \ 2+1 TEST ACTUAL BIT MRhi
    THEN
    0<> IF  ADD IP,4(PSP)       \ 2+3 IF 1: ADD MDlo TO RESlo
            ADDC T,2(PSP)       \ 3      ADDC MDhi TO REShi
            ADDC M,Q            \ 1      ADDC MDLO TO RESLO        
            ADDC P,R            \ 1      ADDC MDHI TO RESHI
    THEN    ADD IP,IP           \ 1 (RLA LSBs) MDlo *2
            ADDC T,T            \ 1 (RLC MSBs) MDhi *2
            ADDC M,M            \ 1 (RLC LSBs) MDLO *2
            ADDC P,P            \ 1 (RLC MSBs) MDHI *2
            ADD X,X             \ 1 (RLA) NEXT BIT TO TEST
            ADDC Y,Y            \ 1 (RLC) NEXT BIT TO TEST
U>= UNTIL   MOV Q,0(PSP)        \ 2+2 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
            MOV R,TOS           \ 1 high result in TOS
            POPM #4,rDOVAR      \ 6 restore rDOCOL to rDOVAR
            MOV @RSP+,IP        \ 2
            MOV @IP+,PC
ENDCODE

CODE F*                         \ s15.16 * s15.16 --> s15.16 result
            MOV 2(PSP),S        \
            XOR TOS,S           \ 1s15 XOR 2s15 --> S keep sign of result
            BIT #$8000,2(PSP)   \ MD < 0 ? 
0<> IF      XOR #-1,2(PSP)
            XOR #-1,4(PSP)
            ADD #1,4(PSP)
            ADDC #0,2(PSP)
THEN        COLON
            DABS UDM*           \ -- RES0 RES1 RES2 RES3
            HI2LO
            MOV @RSP+,IP
            MOV @PSP+,TOS       \ -- RES0 RES1 RES2
            MOV @PSP+,0(PSP)    \ -- RES1 RES2
BW2         AND #-1,S           \ clear V, set N; process S sign
S< IF       XOR #-1,0(PSP)      \ INV(QUOTlo)
            XOR #-1,TOS         \ INV(QUOThi)
            ADD #1,0(PSP)       \ INV(QUOTlo)+1
            ADDC #0,TOS         \ INV(QUOThi)+C
THEN        MOV @IP+,PC
ENDCODE

CODE F/                         \ Q15.16 / Q15.16 --> Q15.16 result
            PUSHM #4,rDOVAR     \ 6 save rDOVAR to rDOCOL regs to use M to R alias
            MOV @PSP+,M         \ DVRlo
            MOV @PSP+,X         \ DVDhi --> REMlo
            MOV #0,W            \ REMhi = 0
            MOV @PSP,Y          \ DVDlo --> DVDhi
            MOV #0,T            \ DVDlo = 0
            MOV X,S             \
            XOR TOS,S           \ DVDhi XOR DVRhi --> S keep sign of result
            AND #-1,X           \ DVD < 0 ? 
S< IF       XOR #-1,Y           \ INV(DVDlo)
            XOR #-1,X           \ INV(DVDhi)
            ADD #1,Y            \ INV(DVDlo)+1
            ADDC #0,X           \ INV(DVDhi)+C
THEN        AND #-1,TOS         \ DVR < 0 ?
S< IF       XOR #-1,M           \ INV(DVRlo)
            XOR #-1,TOS         \ INV(DVRhi)
            ADD #1,M            \ INV(DVRlo)+1
            ADDC #0,TOS         \ INV(DVRhi)+C
THEN
\ don't uncomment lines below !
\ ------------------------------------------------------------------------
\           UD/MOD    DVDlo DVDhi DVRlo DVRhi -- REMlo REMhi QUOTlo QUOThi
\ ------------------------------------------------------------------------
\           MOV 4(PSP),T        \ DVDlo
\           MOV 2(PSP),Y        \ DVDhi
\           MOV #0,X            \ REMlo = 0
\           MOV #0,W            \ REMhi = 0
            MOV #32,P           \  init loop count
BW1         CMP TOS,W           \ 1 REMhi = DVRhi ?
    0= IF   CMP M,X             \ 1 REMlo U< DVRlo ?
    THEN
    U>= IF  SUB M,X             \ 1 no:  REMlo - DVRlo  (carry is set)
            SUBC TOS,W          \ 1      REMhi - DVRhi
    THEN
    BEGIN   ADDC R,R            \ 1 RLC quotLO
            ADDC Q,Q            \ 1 RLC quotHI
            SUB #1,P            \ 1 Decrement loop counter
            0< ?GOTO FW1        \ 2 out of loop if count<0    
            ADD T,T             \ 1 RLA DVDlo
            ADDC Y,Y            \ 1 RLC DVDhi
            ADDC X,X            \ 1 RLC REMlo
            ADDC W,W            \ 1 RLC REMhi
            U< ?GOTO BW1        \ 2 15~ loop 
            SUB M,X             \ 1 REMlo - DVRlo
            SUBC TOS,W          \ 1 REMhi - DVRhi
            BIS #1,SR           \ 1
    AGAIN                       \ 2 16~ loop
FW1
\           MOV X,4(PSP)        \ REMlo    
\           MOV W,2(PSP)        \ REMhi
\           ADD #4,PSP          \ skip REMlo REMhi
            MOV R,0(PSP)        \ QUOTlo
            MOV Q,TOS           \ QUOThi
            POPM #4,rDOVAR      \ 6 restore rDOCOL to rDOVAR
\           MOV @IP+,PC         \ end of UD/MOD
\ ------------------------------------------------------------------------
            GOTO BW2            \ to process S sign
ENDCODE

[UNDEFINED] F#S [IF]
\ F#S    Qlo Qhi len -- Qhi 0   convert fractional part Qlo of Q15.16 fixed point number
\                               with len digits
CODE F#S
            MOV @PSP,S          \ -- Qlo Qhi len        S = Qhi
            MOV #0,T            \                       T = count
            PUSHM #3,IP         \                       R-- IP Qhi count
            MOV 2(PSP),0(PSP)   \ -- Qlo Qlo len
            MOV TOS,2(PSP)      \ -- len Qlo len
BEGIN       MOV &BASEADR,TOS    \ -- len Qlo base
            LO2HI
            UM*                 \                       u1 u2 -- RESlo REShi
            HI2LO               \ -- len RESlo digit
            CMP #10,TOS         \                       digit to char
    U>= IF  ADD #7,TOS
    THEN    ADD #$30,TOS        \ -- len RESlo char 
            MOV @RSP,T          \                       T=count
            MOV.B TOS,HOLDS_ORG(T)  \                   char to string_org(T)
            ADD #1,T            \                       count+1
            MOV T,0(RSP)        \
            CMP 2(PSP),T        \ -- len RESlo char     count=len ?
U>= UNTIL   POPM #3,IP          \                       S=Qhi, T=len
            MOV T,TOS           \ -- len RESlo len
            MOV S,2(PSP)        \ -- Qhi RESlo len
            MOV #0,0(PSP)       \ -- Qhi 0 len
            MOV #HOLDS_ORG,X    \ -- Qhi 0 len          X=HOLDS_ORG
            GOTO BW3            \ 36~ JMP HOLDS
ENDCODE
[THEN]

[ELSE] ; hardware multiplier

CODE F/                         \ Q15.16 / Q15.16 --> Q15.16 result
\ TOS = DVRhi
\ 0(PSP) = DVRlo
\ 2(PSP) = DVDhi
\ 4(PSP) = DVDlo
            PUSHM #4,rDOVAR     \ 6 PUSHM rDOVAR to rDOCOL to use M to R alias
            MOV @PSP+,M         \ 2 DVRlo
            MOV @PSP+,X         \ 2 DVDhi --> REMlo
            MOV #0,W            \ 1 REMhi = 0
            MOV @PSP,Y          \ 2 DVDlo --> DVDhi
            MOV #0,T            \ 1 DVDlo = 0
            MOV X,S             \ 1
            XOR TOS,S           \ 1 DVDhi XOR DVRhi --> S keep sign of result
            AND #-1,X           \ 1 DVD < 0 ? 
S< IF       XOR #-1,Y           \ 1 INV(DVDlo)
            XOR #-1,X           \ 1 INV(DVDhi)
            ADD #1,Y            \ 1 INV(DVDlo)+1
            ADDC #0,X           \ 1 INV(DVDhi)+C
THEN        AND #-1,TOS         \ 1 DVRhi < 0 ?
S< IF       XOR #-1,M           \ 1 INV(DVRlo)
            XOR #-1,TOS         \ 1 INV(DVRhi)
            ADD #1,M            \ 1 INV(DVRlo)+1
            ADDC #0,TOS         \ 1 INV(DVRhi)+C
THEN    
\ don't uncomment lines below !
\ ------------------------------------------------------------------------
\           UD/MOD    DVDlo DVDhi DVRlo DVRhi -- REMlo REMhi QUOTlo QUOThi
\ ------------------------------------------------------------------------
\           MOV 4(PSP),T        \ DVDlo
\           MOV 2(PSP),Y        \ DVDhi
\           MOV #0,X            \ REMlo = 0
\           MOV #0,W            \ REMhi = 0
            MOV #32,P           \ 2 init loop count
BW1         CMP TOS,W           \ 1 REMhi = DVRhi ?
    0= IF   CMP M,X             \ 1 REMlo U< DVRlo ?
    THEN
    U>= IF  SUB M,X             \ 1 no:  REMlo - DVRlo  (carry is set)
            SUBC TOS,W          \ 1      REMhi - DVRhi
    THEN
BW2         ADDC R,R            \ 1 RLC quotLO
            ADDC Q,Q            \ 1 RLC quotHI
            SUB #1,P            \ 1 Decrement loop counter
            0< ?GOTO FW1        \ 2 out of loop if count<0    
            ADD T,T             \ 1 RLA DVDlo
            ADDC Y,Y            \ 1 RLC DVDhi
            ADDC X,X            \ 1 RLC REMlo
            ADDC W,W            \ 1 RLC REMhi
            U< ?GOTO BW1        \ 2 19~ loop 
            SUB M,X             \ 1 REMlo - DVRlo
            SUBC TOS,W          \ 1 REMhi - DVRhi
            BIS #1,SR           \ 1
            GOTO BW2            \ 2 16~ loop
FW1         AND #-1,S           \ 1 clear V, set N; QUOT < 0 ?
S< IF       XOR #-1,R           \ 1 INV(QUOTlo)
            XOR #-1,Q           \ 1 INV(QUOThi)
            ADD #1,R            \ 1 INV(QUOTlo)+1
            ADDC #0,Q           \ 1 INV(QUOThi)+C
THEN        MOV R,0(PSP)        \ 3 QUOTlo
            MOV Q,TOS           \ 1 QUOThi
            POPM #4,rDOVAR      \ 6 restore rDOCOL to rDOVAR
            MOV @IP+,PC         \ 4
ENDCODE

[UNDEFINED] F#S [IF]
\ F#S    Qlo Qhi u -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
\                             with u digits
CODE F#S
            MOV 2(PSP),X        \ -- Qlo Qhi u      X = Qlo
            MOV @PSP,2(PSP)     \ -- Qhi Qhi u
            MOV X,0(PSP)        \ -- Qhi Qlo u
            MOV TOS,T           \                   T = len
            MOV #0,S            \                   S = count
BEGIN       MOV @PSP,&MPY       \                   Load 1st operand
            MOV &BASEADR,&OP2   \                   Load 2nd operand
            MOV &RES0,0(PSP)    \ -- Qhi RESlo x        low result on stack
            MOV &RES1,TOS       \ -- Qhi RESlo REShi    high result in TOS
            CMP #10,TOS         \                   digit to char
    U>= IF  ADD #7,TOS
    THEN    ADD #$30,TOS
            MOV.B TOS,HOLDS_ORG(S)  \ -- Qhi RESlo char     char to string
            ADD #1,S            \                   count+1
            CMP T,S             \                   count=len ?
0= UNTIL    MOV T,TOS           \ -- len RESlo len
            MOV #0,0(PSP)       \ -- Qhi 0 len
            MOV #HOLDS_ORG,X    \ -- Qhi 0 len          X=HOLDS_ORG
            GOTO BW3            \ 35~ JMP HOLDS+2
ENDCODE
[THEN]

CODE F*                         \ signed s15.16 multiplication --> s15.16 result
            MOV 4(PSP),&MPYS32L \ 5 Load 1st operand
            MOV 2(PSP),&MPYS32H \ 5
            MOV @PSP,&OP2L      \ 4 load 2nd operand
            MOV TOS,&OP2H       \ 3
            ADD #4,PSP          \ 1 remove 2 cells
            MOV &RES1,0(PSP)    \ 5
            MOV &RES2,TOS       \ 5
            MOV @IP+,PC
ENDCODE

[THEN]  \ endcase of hardware multiplier

[UNDEFINED] F. [IF]
CODE F.             \ display a Q15.16 number with 4/5/16 digits after comma
MOV TOS,S           \ S = sign
MOV #4,T            \ T = 4     preset 4 digits for base 16 and by default
MOV &BASEADR,W
CMP #$0A,W
0= IF               \           if base 10
    ADD #1,T        \ T = 5     set 5 digits
ELSE
    CMP #2,W
    0= IF           \           if base 2
        MOV #$10,T  \ T = 16    set 16 digits
    THEN
THEN
PUSHM #3,IP         \                   R-- IP sign #digit
LO2HI
    <# DABS         \ -- uQlo uQhi      R-- IP sign #digit
    R> F#S          \ -- uQhi 0         R-- IP sign
    $2C HOLD        \                   $2C = char ','
    #S              \ -- 0 0
    R> SIGN #>      \ -- addr len       R-- IP
    TYPE $20 EMIT   \ --         
;

CODE S>F            \ convert a signed number to a Q15.16 (signed) number
    SUB #2,PSP
    MOV #0,0(PSP)
    MOV @IP+,PC
ENDCODE
[THEN]

PWR_HERE

[THEN] \ endof [UNDEFINED] {FIXPOINT}

; -----------------------
; definitions (volatile) for tests below
; -----------------------

[UNDEFINED] ! [IF]
\ https://forth-standard.org/standard/core/Store
\ !        x a-addr --   store cell in memory
CODE !
MOV @PSP+,0(TOS)    \ 4
MOV @PSP+,TOS       \ 2
MOV @IP+,PC         \ 4
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

[UNDEFINED] 2CONSTANT [IF]
\ https://forth-standard.org/standard/double/TwoCONSTANT
: 2CONSTANT \  udlo/dlo/Qlo udhi/dhi/Qhi --         to create double or Q15.16 CONSTANT
CREATE , ,  \ compile Qhi then Qlo
DOES>       \ execution part    addr -- Qhi Qlo
HI2LO
SUB #2,PSP
MOV 2(TOS),0(PSP)
MOV @TOS,TOS
MOV @RSP+,IP
NEXT
ENDCODE
[THEN]

ECHO

; -----------------------
; (volatile) tests for FIXPOINT.asm | FIXPOINT.f
; -----------------------

3,14159 2CONSTANT PI
PI U. U.
PI F.

PI -1,0 F* 2CONSTANT -PI
-PI . U.
-PI F.

$10 BASEADR !  PI F. 
            -PI F.
%10 BASEADR !  PI F. 
            -PI F.
#10 BASEADR !  PI F. 
            -PI F.

PI 2,0 F* F.      
PI -2,0 F* F.    
-PI 2,0 F* F.    
-PI -2,0 F* F.    

PI 2,0 F/ F.      
PI -2,0 F/ F.    
-PI 2,0 F/ F.    
-PI -2,0 F/ F.    

32767,99999 1,0 F* F. 
32767,99999 1,0 F/ F. 
32767,99999 2,0 F/ F. 
32767,99999 4,0 F/ F. 
32767,99999 8,0 F/ F. 
32767,99999 16,0 F/ F.

-32767,0 -1,0 F* F.   
-32767,0 -1,0 F/ F.   
-32767,0 -2,0 F/ F.   
-32767,0 -4,0 F/ F.   
-32767,0 -8,0 F/ F.   
-32767,0 -16,0 F/ F.  
-32767,0 -32,0 F/ F.  
-32767,0 -64,0 F/ F.  

; SQRT(32768)^2 = 32768
181,01933598375 181,01933598375 F* F.  
181,01933598375 -181,01933598375 F* F.
-181,01933598375 181,01933598375 F* F.
-181,01933598375 -181,01933598375 F* F.


