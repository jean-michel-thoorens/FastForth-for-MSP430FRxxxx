\ -*- coding: utf-8 -*-
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, FIXPOINT_INPUT
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433  MSP_EXP430FR4133    CHIPSTICK_FR2433    MSP_EXP430FR2355
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

CODE ABORT_FIXPOINT
SUB #4,PSP
MOV TOS,2(PSP)
MOV &KERNEL_ADDON,TOS
BIT #BIT10,TOS
0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (FIXPOINT input), set TOS = 0  
MOV TOS,0(PSP)
MOV &VERSION,TOS
SUB #308,TOS            \ FastForth V3.8
COLON
$0D EMIT    \ return to column 1 without CR
ABORT" FastForth V3.8 please!"
ABORT" buil FastForth with FIXPOINT_INPUT addon !"
PWR_STATE           \ if no abort remove this word
$1B EMIT $63 EMIT   \ send 'ESC c' (clear screen)
;

ABORT_FIXPOINT

; -----------------------------------------------------
; FIXPOINT.f 
; -----------------------------------------------------

[DEFINED] {FIXPOINT} [IF]  {FIXPOINT} [THEN]

MARKER {FIXPOINT}

[UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
CODE +
ADD @PSP+,TOS
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

CODE F+ \ add Q15.16|double numbers
            ADD @PSP+,2(PSP)    \ -- sumlo  d1hi d2hi
            ADDC @PSP+,TOS      \ -- sumlo sumhi
            MOV @IP+,PC
ENDCODE

CODE F- \ substract Q15.16|double numbers
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
            AND #-1,S           \ clear V, set N; process S sign
S< IF       XOR #-1,0(PSP)      \ INV(QUOTlo)
            XOR #-1,TOS         \ INV(QUOThi)
            ADD #1,0(PSP)       \ INV(QUOTlo)+1
            ADDC #0,TOS         \ INV(QUOThi)+C
THEN        MOV @IP+,PC
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

CODE F* \ signed s15.16 multiplication --> s15.16 result
            MOV 4(PSP),&MPYS32L \ 5 Load 1st operand
            MOV 2(PSP),&MPYS32H \ 5
            MOV @PSP,&OP2L      \ 4 load 2nd operand
            MOV TOS,&OP2H       \ 3
            ADD #4,PSP          \ 1 remove 2 cells
            MOV &RES1,0(PSP)    \ 5
            MOV &RES2,TOS       \ 5
            MOV @IP+,PC
ENDCODE

[UNDEFINED] F#S [IF]
\ F#S    Qlo Qhi len -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
\                             with len digits
CODE F#S
            MOV 2(PSP),X        \ -- Qlo Qhi len    X = Qlo
            MOV @PSP,2(PSP)     \ -- Qhi Qhi len
            MOV X,0(PSP)        \ -- Qhi Qlo len
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

[THEN]  \ end of hardware/software multiplier

CODE F/                         \ Q15.16 / Q15.16 --> Q15.16 result
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
            MOV X,M             \ 1 DVDhi --> REMlo     to adjust Q15.16 division
            MOV T,X             \ 1 DVDlo --> DVDhi
            MOV #0,T            \ 1     0 --> DVDlo
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
\            MOV #0,M            \ 1 M=REMlo = 0
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
\            MOV M,T             \ 1 T=REMlo
\            MOV P,W             \ 1 W=REMhi
            POPM #5,X           \ 7 X=DVDhi, Y=DVRhi, system regs M,P,Q restored
\            CMP #0,X            \ 1 sign of Rem ?
\    S< IF   XOR #-1,T           \ 1 INV(REMlo)
\            XOR #-1,W           \ 1 INV(REMhi)
\            ADD #1,T            \ 1 INV(REMlo)+1 
\            ADDC #0,W           \ 1 INV(REMhi)+C
\    THEN
\           SUB #4,PSP          \
\           MOV T,4(PSP)        \   REMlo
\           MOV W,2(PSP)        \   REMhi
            XOR X,Y             \ Y = sign of Quot
            CMP #0,Y            \ sign of Quot ?
S< IF       XOR #-1,S           \ 1 INV(QUOTlo)
            XOR #-1,TOS         \ 1 INV(QUOThi)
            ADD #1,S            \ 1 INV(QUOTlo)+1
            ADDC #0,TOS         \ 1 INV(QUOThi)+C
THEN
            MOV S,0(PSP)        \ 3 QUOTlo
            MOV @IP+,PC         \ 4
ENDCODE

[UNDEFINED] F. [IF]
CODE F. \ display a Q15.16 number with 4/5/16 digits after comma
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

CODE S>F    \ convert a signed number to a Q15.16 (signed) number
    SUB #2,PSP
    MOV #0,0(PSP)
    MOV @IP+,PC
ENDCODE
[THEN]

RST_HERE

; -----------------------
; complement (volatile) for tests below
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

[UNDEFINED] D. [IF]
\ https://forth-standard.org/standard/double/Dd
\ D.     dlo dhi --           display d (signed)
CODE D.
MOV #U.,W   \ U. + 10 = D.
ADD #10,W
MOV W,PC
ENDCODE
[THEN]

[UNDEFINED] BASE [IF]
\ https://forth-standard.org/standard/core/BASE
\ BASE    -- a-addr       holds conversion radix
BASEADR CONSTANT BASE
[THEN]

ECHO

; -----------------------
; (volatile) tests for FIXPOINT.asm|FIXPOINT.f
; -----------------------

3,14159 2CONSTANT PI
PI -1,0 F* 2CONSTANT -PI

PI D.   ; D. is not appropriate --> 
-PI D.  ; D. is not appropriate -->

PI F.   ; F. is a good choice! ---> 
-PI F.  ; F. is a good choice! --->

$10 BASE !   PI F. 
            -PI F.
%10 BASE !   PI F. 
            -PI F.
#10 BASE !   PI F. 
            -PI F.

 PI  2,0 F* F.     
 PI -2,0 F* F.    
-PI  2,0 F* F.    
-PI -2,0 F* F.     

 PI  2,0 F/ F.     
 PI -2,0 F/ F.    
-PI  2,0 F/ F.    
-PI -2,0 F/ F.     

 32768,0  1,0 F* F. ; overflow! -->
 32768,0  1,0 F/ F. ; overflow! -->
-32768,0 -1,0 F* F. ; overflow! -->
-32768,0 -1,0 F/ F. ; overflow! -->

32767,99999 1,0  F* F. 
32767,99999 1,0  F/ F. 
32767,99999 2,0  F/ F. 
32767,99999 4,0  F/ F. 
32767,99999 8,0  F/ F. 
32767,99999 16,0 F/ F. 

-32768,0 -2,0    F/ F. 
-32768,0 -4,0    F/ F. 
-32768,0 -8,0    F/ F. 
-32768,0 -16,0   F/ F. 
-32768,0 -32,0   F/ F. 
-32768,0 -64,0   F/ F. 

-3276,80 -1,0    F/ F. 
-327,680 -1,0    F/ F. 
-32,7680 -1,0    F/ F. 
-3,27680 -1,0    F/ F. 
-0,32768 -1,0    F/ F. 

; SQRT(32768)^2 = 32768
 181,01933598375  181,01933598375 F* F. 
 181,01933598375 -181,01933598375 F* F.
-181,01933598375  181,01933598375 F* F.
-181,01933598375 -181,01933598375 F* F.
 
RST_STATE
