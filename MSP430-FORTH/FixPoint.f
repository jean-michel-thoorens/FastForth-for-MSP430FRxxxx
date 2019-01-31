
; -----------------------------------------------------
; FIXPOINT.f
; -----------------------------------------------------
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
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<
\

PWR_STATE

[DEFINED] {FIXPOINT} [IF] {FIXPOINT} [THEN]     \ remove {FIXPOINT} if outside core 

[UNDEFINED] {FIXPOINT} [IF]   \ don't replicate {FIXPOINT} inside core

MARKER {FIXPOINT}

\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
\ (2 supplementary bytes are room for sign - and decimal point)
\ C HOLDS    addr u --
CODE HOLDS
            MOV @PSP+,X     \ 2
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

CODE F+                     \ add Q15.16 numbers
    ADD @PSP+,2(PSP)        \ -- sumlo  d1hi d2hi
    ADDC @PSP+,TOS          \ -- sumlo sumhi
    MOV @IP+,PC
ENDCODE

CODE F-                     \ substract Q15.16 numbers
    SUB @PSP+,2(PSP)        \ -- diflo d1hi d2hi
    SUBC TOS,0(PSP)         \ -- diflo difhi d2hi
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE

$1A04 C@ $EF > [IF] ; test tag value MSP430FR413x subfamily without hardware_MPY 

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
            MOV &BASE,TOS           \ -- Qhi Qlo base
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
            JMP HOLDS
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
            MOV &BASE,&OP2          \                   Load 2nd operand
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
            JMP HOLDS
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

CODE F.             \ display a Q15.16 number with 4/5/16 digits after comma
MOV TOS,S           \ S = sign
MOV #4,T            \ T = 4     preset 4 digits for base 16 and by default
MOV &BASE,W
CMP ##10,W
0= IF               \           if base 10
    ADD #1,T        \ T = 5     set 5 digits
ELSE
    CMP #%10,W
    0= IF           \           if base 2
        MOV #16,T   \ T = 16    set 16 digits
    THEN
THEN
PUSHM #3,IP         \                   R-- IP sign #digit
LO2HI
    <# DABS         \ -- uQlo uQhi      R-- IP sign #digit
    R> F#S          \ -- uQhi 0         R-- IP sign
    $2C HOLD        \                   $2C = char ','
    #S              \ -- 0 0
    R> SIGN #>      \ -- addr len       R-- IP
    TYPE SPACE      \ --         
;

CODE S>F         \ convert a signed number to a Q15.16 (signed) number
    SUB #2,PSP
    MOV #0,0(PSP)
    MOV @IP+,PC
ENDCODE

[UNDEFINED] 2@ [IF]

\ https://forth-standard.org/standard/core/TwoFetch
\ 2@    a-addr -- x1 x2    fetch 2 cells ; the lower address will appear on top of stack
CODE 2@
SUB #2,PSP
MOV 2(TOS),0(PSP)
MOV @TOS,TOS
NEXT
ENDCODE
[THEN] \ of [UNDEFINED] 2@

[UNDEFINED] 2CONSTANT [IF]

\ https://forth-standard.org/standard/double/TwoCONSTANT
: 2CONSTANT \  udlo/dlo/Qlo udhi/dhi/Qhi --         to create double or Q15.16 CONSTANT
CREATE , ,  \ compile Qhi then Qlo
DOES> 2@    \ execution part    addr -- Qhi Qlo
;

[THEN] \ of [UNDEFINED] 2CONSTANT

RST_HERE
[THEN] \ of [UNDEFINED] {FIXPOINT}

ECHO

; -----------------------
; (volatile) tests
; -----------------------


3,14159 2CONSTANT PI
PI -1,0 F* 2CONSTANT -PI

$10 BASE !  PI F. 
           -PI F.
%10 BASE !  PI F. 
           -PI F.
#10 BASE !  PI F. 
           -PI F.

PI 2,0 F* F.      
PI -2,0 F* F.    
-PI 2,0 F* F.    
-PI -2,0 F* F.    

PI 2,0 F/ F.      
PI -2,0 F/ F.    
-PI 2,0 F/ F.    
-PI -2,0 F/ F.    

32767,99999 1,0 f* F. 
32767,99999 1,0 f/ F. 
32767,99999 2,0 f/ F. 
32767,99999 4,0 f/ F. 
32767,99999 8,0 f/ F. 
32767,99999 16,0 f/ F.

-32767,0 -1,0 f* F.   
-32767,0 -1,0 f/ F.   
-32767,0 -2,0 f/ F.   
-32767,0 -4,0 f/ F.   
-32767,0 -8,0 f/ F.   
-32767,0 -16,0 f/ F.  
-32767,0 -32,0 f/ F.  
-32767,0 -64,0 f/ F.  

; sqrt(32768)^2 = 32768
181,01933598375 181,01933598375 f* f.  
181,01933598375 -181,01933598375 f* f.
-181,01933598375 181,01933598375 f* f.
-181,01933598375 -181,01933598375 f* f.
