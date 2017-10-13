\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433
\ MY_MSP430FR5738_1 MY_MSP430FR5738     MY_MSP430FR5948     MY_MSP430FR5948_1   
\ JMJ_BOX



PWR_STATE
    \
[DEFINED] {FIXPOINT} [IF] {FIXPOINT} [THEN]     \ remove {FIXPOINT} if outside core 
    \
[DEFINED] ASM [UNDEFINED] {FIXPOINT} AND [IF]   \ assembler required, don't replicate {FIXPOINT} inside core
    \
MARKER {FIXPOINT}
    \
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
    \
CODE F+                 \ add s15q16 numbers
    ADD @PSP+,2(PSP)    \ -- sumlo  d1hi d2hi
    ADDC @PSP+,TOS      \ -- sumlo sumhi
    MOV @IP+,PC
ENDCODE
    \
CODE F-                 \ substract s15q16 numbers
    SUB @PSP+,2(PSP)    \ -- diflo d1hi d2hi
    SUBC TOS,0(PSP)     \ -- diflo difhi d2hi
    MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE
    \
CODE F/                     \ s15q16 / s15q16 --> s15q16 result
        MOV 2(PSP),S        \
        XOR TOS,S           \ MDhi XOR MRhi --> S keep sign of result
        MOV #0,T            \ DVDlo = 0
        MOV 4(PSP),Y        \ DVDlo --> DVDhi
        MOV 2(PSP),X        \ DVDhi --> REMlo
        BIT #8000,X         \ MD < 0 ? 
0<> IF  XOR #-1,Y           \ lo
        XOR #-1,X           \ hi
        ADD #1,Y            \ lo
        ADDC #0,X           \ hi
THEN    BIT #8000,TOS
0<> IF  XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
THEN
\ don't uncomment lines below !
\ ------------------------------------------------------------------------
\           UD/MOD    DVDlo DVDhi DVRlo DVRhi -- REMlo REMhi QUOTlo QUOThi
\ ------------------------------------------------------------------------
\           MOV 4(PSP),T    \ DVDlo
\           MOV 2(PSP),Y    \ DVDhi
\           MOV #0,X        \ REMlo = 0
            PUSHM R7,R4
            MOV #0,W        \  REMhi = 0
            MOV @PSP,R6     \  DIVlo
            MOV #32,R5      \  init loop count
BW1         CMP TOS,W       \ 1 REMhi = DIVhi ?
    0= IF   CMP R6,X        \ 1 REMlo U< DIVlo ?
    THEN
    U>= IF  SUB R6,X        \ 1 no:  REMlo - DIVlo  (carry is set)
            SUBC TOS,W      \ 1      REMhi - DIVhi
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
            SUB R6,X        \ 1 REMlo - DIVlo
            SUBC TOS,W      \ 1 REMhi - DIVhi
            BIS #1,SR       \ 1
            GOTO BW2        \ 2 16~ loop
FW1
\           MOV X,4(PSP)    \ REMlo    
\           MOV W,2(PSP)    \ REMhi
            ADD #4,PSP      \ skip REMlo REMhi

            MOV R7,0(PSP)   \ QUOTlo
            MOV R4,TOS      \ QUOThi
            POPM R4,R7      \ restore R7 to R4
\           MOV @IP+,PC     \ end of UD/MOD
\ ------------------------------------------------------------------------
BW1     AND #-1,S           \ clear V, set N
S< IF   XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
THEN    MOV @IP+,PC
ENDCODE
    \
$1A04 C@ $EF > [IF] ; test tag value MSP430FR413x subfamily without hardware_MPY 
    \
\ F#S    Shi Flo -- Shi 0   convert fractional part Flo of S15Q16 fixed point number
CODE F#S 
            SUB #2,PSP              \ -- Shi x Flo
            MOV TOS,0(PSP)          \ -- Shi Flo x
            MOV #4,TOS              \ -- Shi Flo x      TOS = limit for base 16
            CMP #10,&BASE
0= IF       ADD #1,TOS              \                   TOS = limit for base 10
THEN        PUSHM TOS,IP            \
            MOV #0,S                \ -- Shi Flo x
BEGIN       PUSH S                  \                   R-- limit IP count
            MOV &BASE,TOS           \ -- Shi Flo base
            LO2HI
            UM*                     \                   u1 u2 -- RESlo REShi
            HI2LO                   \ -- Shi RESlo digit
            SUB #2,IP
            CMP #10,TOS             \                   digit to char
    U>= IF  ADD #7,TOS
    THEN    ADD #$30,TOS
            MOV @RSP+,S             \                       R-- limit IP
            MOV.B TOS,HOLDS_ORG(S)  \ -- Shi RESlo char     char to string
            ADD #1,S                \                       count+1
            CMP 2(RSP),S            \                       count=limit ?
U>= UNTIL   POPM IP,TOS             \
            MOV #0,0(PSP)           \ -- Shi 0 len
            SUB #2,PSP              \ -- Shi 0 x len
            MOV #HOLDS_ORG,0(PSP)   \ -- Shi 0 addr len
            JMP HOLDS
ENDCODE
    \
\ unsigned multiply 32*32 = 64
\ don't use S reg (keep sign)
CODE UDM*
            PUSH IP         \ 3
            PUSHM R7,R4     \ 6 save R7 ~ R4 regs
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
    0<> IF  BIT X,W         \ 1 TEST ACTUAL BIT MRlo
    ELSE    BIT Y,TOS       \ 1 TEST ACTUAL BIT MRhi
    THEN
    0<> IF  ADD IP,4(PSP)   \ 3 IF 1: ADD MDlo TO RESlo
            ADDC T,2(PSP)   \ 3      ADDC MDhi TO REShi
            ADDC R4,R6      \ 1      ADDC MDLO TO RESLO        
            ADDC R5,R7      \ 1      ADDC MDHI TO RESHI
    THEN    ADD IP,IP       \ 1 (RLA LSBs) MDlo *2
            ADDC T,T        \ 1 (RLC MSBs) MDhi *2
            ADDC R4,R4      \ 1 (RLA LSBs) MDLO *2
            ADDC R5,R5      \ 1 (RLC MSBs) MDHI *2
            ADD X,X         \ 1 (RLA) NEXT BIT TO TEST
            ADDC Y,Y        \ 1 (RLA) NEXT BIT TO TEST
U>= UNTIL   MOV R6,0(PSP)   \ 2 IF BIT IN CARRY: FINISHED    32 * 16~ (average loop)
            MOV R7,TOS      \ 1 high result in TOS
            POPM R4,R7      \ 6 restore R4 ~ R7 regs
            MOV @RSP+,IP    \ 2
            MOV @IP+,PC
ENDCODE
    \
CODE F*                 \ s15.16 * s15.16 --> s15.16 result
    MOV 2(PSP),S        \
    XOR TOS,S           \ 1s15 XOR 2s15 --> S keep sign of result
    BIT #8000,2(PSP)    \ MD < 0 ? 
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
    \
[ELSE]                  \ hardware multiplier
    \
\ F#S    Shi Flo -- Shi 0   convert fractionnal part of S15Q16 fixed point number (direct order)
CODE F#S
            SUB #2,PSP              \ -- Shi x Flo
            MOV TOS,0(PSP)          \ -- Shi Flo x
            MOV #4,T                \ -- Shi Flo x      T = limit for base 16
            CMP #10,&BASE
0= IF       ADD #1,T                \                   T = limit for base 10
THEN        MOV #0,S                \                   S = count
BEGIN       MOV @PSP,&MPY           \                   Load 1st operand
            MOV &BASE,&OP2          \                   Load 2nd operand
            MOV &RES0,0(PSP)        \ -- Shi RESlo x        low result on stack
            MOV &RES1,TOS           \ -- Shi RESlo REShi    high result in TOS
            CMP #10,TOS             \                   digit to char
    U>= IF  ADD #7,TOS
    THEN    ADD #$30,TOS
            MOV.B TOS,HOLDS_ORG(S)  \ -- Shi RESlo char     char to string
            ADD #1,S                \                   count+1
            CMP T,S                 \                   count=limit ?
U>= UNTIL   MOV T,TOS               \ -- Shi RESlo limit
            MOV #0,0(PSP)           \ -- Shi 0 limit
            SUB #2,PSP              \ -- Shi 0 x len
            MOV #HOLDS_ORG,0(PSP)   \ -- Shi 0 addr len
            JMP HOLDS
ENDCODE
    \
CODE F*                 \ signed s15.16 multiplication --> s15.16 result
    MOV 4(PSP),&MPYS32L \ 5 Load 1st operand
    MOV 2(PSP),&MPYS32H \ 5
    MOV @PSP,&OP2L      \ 4 load 2nd operand
    MOV TOS,&OP2H       \ 3
    ADD #4,PSP          \ 1 remove 2 cells
    NOP2                \ 2
    NOP2                \ 2 wait 8 cycles after write OP2L before reading RES1
    MOV &RES1,0(PSP)    \ 5
    MOV &RES2,TOS       \ 5
    MOV @IP+,PC
ENDCODE
    \
[THEN]  \ hardware multiplier
    \
: F.                \ display a s15q16 number
    <# DUP >R DABS  \ -- udlo udhi          R-- sign
    SWAP            \ -- sign udhi udlo
    F#S             \ -- sign udhi 0
    $2C HOLD #S     \ -- sign 0 0
    R> SIGN #>      \ -- addr len           R-- 
    TYPE SPACE      \ --         
    EXIT
;
    \
CODE S>F         \ convert a signed number to a s15q16 (signed) number
    SUB #2,PSP
    MOV #0,0(PSP)
    MOV @IP+,PC
ENDCODE
    \
CODE D>F         \ convert a signed double number (-.32768|.32767) to a s15q16 (signed) number
    MOV @PSP,TOS
    MOV #0,0(PSP)
    MOV @IP+,PC
ENDCODE
    \

\ https://forth-standard.org/standard/double/TwoCONSTANT
: 2CONSTANT \  udlo/dlo/Flo udhi/dhi/Shi --         to create double or s15q16 CONSTANT
CREATE
SWAP , ,            \ compile Flo then Shi
DOES>
HI2LO
MOV @RSP+,IP
SUB #2,PSP          \ -- x PFA
MOV @TOS+,0(PSP)    \ -- lo PFA+2
MOV @TOS,TOS        \ -- lo hi
MOV @IP+,PC
ENDCODE
    \
[THEN]
    \
ECHO
PWR_HERE
    \
; -----------------------
; (volatile) tests
; -----------------------
3,14159 2CONSTANT PI
PI -1,0 F* 2CONSTANT -PI
    \
PI 2,0 F/ F.  
PI 2,0 F* F.  
PI -2,0 F/ F.
PI -2,0 F* F.
-PI 2,0 F/ F.
-PI 2,0 F* F.
-PI -2,0 F/ F.
-PI -2,0 F* F.
