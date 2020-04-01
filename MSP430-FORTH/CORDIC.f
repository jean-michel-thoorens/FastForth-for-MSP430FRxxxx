\ -*- coding: utf-8 -*-

; ----------
; CORDIC.f
; ----------
\ see CORDICforDummies.pdf
\
; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, FIXPOINT_INPUT
\
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ LP_MSP430FR2476
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
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
\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT, rDOVAR, rDOCON, rDODOES
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  rDODOES, rDOCON, rDOVAR, rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM #6,IP   pulls Y,X,W,T,S,IP registers from return stack
\
\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }
\
\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=
\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  0<

PWR_STATE

[DEFINED] {CORDIC} [IF] {CORDIC} [THEN]

MARKER {CORDIC}


\ CORDIC USES
\   OPERATION   |   MODE    |   INITIALIZE x y z    |   DIRECTION   |     RESULT        | post operation
\ --------------|-----------|-----------------------|---------------|-------------------|
\ sine, cosine  | Rotation  | x=1, y=0,  z=angle    | Reduce z to 0 | cos=x*Gi,sin=y*Gi | mutiply by 1/Gi
\ --------------|-----------|-----------------------|---------------|-------------------|
\ Polar to Rect | Rotation  | x=magnit, y=0, Z=angle| Reduce z to 0 |  X=x*Gi, Y=y*Gi   | mutiply by 1/Gi
\ --------------|-----------|-----------------------|---------------|-------------------|
\ Rotation      | Rotation  | x=X, y=Y, z=angle     | Reduce z to 0 | X'=x*Gi,Y'=y*Gi   | <=== not implemented
\ --------------|-----------|-----------------------|---------------|-------------------|
\ Rect to Polar |  Vector   | x=X, y=Y, z=0         | Reduce y to 0 | hyp=x*Gi, angle=z | mutiply hyp by 1/Gi
\ --------------|-----------|-----------------------|---------------|-------------------|
\ Gi = CORDIC gain for i iterations; Gi < 1
\

CREATE T_ARCTAN \ ArcTan table
11520 ,         \ 256 * 45
6801 ,          \ 256 * 26.565
3593 ,          \ 256 * 14.036
1824 ,          \ 256 * 7.125
916 ,           \ 256 * 3.576
458 ,           \ 256 * 1.790
229 ,           \ 256 * 0.895
115 ,           \ 256 * 0.448
57 ,            \ 256 * 0.224
29 ,            \ 256 * 0.112
14 ,            \ 256 * 0.056
7 ,             \ 256 * 0.028
4 ,             \ 256 * 0.014
2 ,             \ 256 * 0.007
1 ,             \ 256 * 0.003

CREATE T_SCALE  \ 1/Gi table
46340 ,         \ = 65536 * cos(45)
41448 ,         \ = 65536 * cos(45) * cos(26.565)
40211 ,         \ = 65536 * cos(45) * cos(26.565) * cos(14.036)
39900 ,         \ = 65536 * cos(45) * cos(26.565) * cos(14.036) * ... 
39822 ,
39803 ,
39798 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,
39797 ,

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

$81EF DEVICEID @ U< 
DEVICEID @ $81F3 U<
= [IF]   ; MSP430FR413x subfamily without hardware_MPY

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

ASM XSCALE              \ X = X*Cordic_Gain
SUB #4,PSP
MOV TOS,2(PSP)
MOV X,0(PSP)            \       1st operand = X
MOV T_SCALE(W),TOS      \ 3     2nd operand = CORDIC Gain * 65536 ; IS UNSIGNED!
\ https://forth-standard.org/standard/core/MTimes
\ M*     n1 n2 -- dlo dhi  signed 16*16->32 multiply
\ -----------------------------------------------
\ CODE M*
\ -----------------------------------------------
MOV @PSP,S          \ S= n1
CMP #0,S            \ n1 > -1 ?
S< IF
    XOR #-1,0(PSP)  \ n1 --> u1
    ADD #1,0(PSP)   \
THEN
\ XOR TOS,S           \ S contains sign of result
\ CMP #0,TOS          \ n2 > -1 ?
\ S< IF
\     XOR #-1,TOS     \ n2 --> u2 
\     ADD #1,TOS      \
\ THEN
\ PUSHM #2,IP        \ UMSTAR use S,T,W,X,Y, we save IP,S
PUSHM #6,IP         \ UMSTAR use S,T,W,X,Y, we save IP,S,T,W,X,Y
LO2HI               \ -- ud1 u2
UM*       
HI2LO
\ POPM #2,IP         \ pop S,IP
POPM #6,IP           \ pop Y,X,W,T,S,IP
CMP #0,S             \ sign of result > -1 ?
S< IF
    XOR #-1,0(PSP)  \ ud --> d
    XOR #-1,TOS
    ADD #1,0(PSP)
    ADDC #0,TOS
THEN
\ MOV @IP+,PC
\ ENDCODE
\ -----------------------------------------------
MOV TOS,X           \ hi result --> X
ADD #2,PSP
MOV @PSP+,TOS       \ restore data stack
MOV @RSP+,PC        \ RET
ENDASM



[ELSE] ; hardware multiplier

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

ASM XSCALE              \ X = X*Cordic_Gain
MOV X,&MPY              \ 3     Load 1st operand
MOV T_SCALE(W),&OP2     \ 3     CORDIC Gain * 65536
MOV &RES1,X             \ 3     hi result = hypothenuse
MOV @RSP+,PC            \ RET
ENDASM

[THEN]  ; endcase of hardware multiplier


[UNDEFINED] F. [IF]
CODE F.             \ display a Q15.16 number with 4/5/16 digits after comma
MOV TOS,S           \ S = sign
MOV #4,T            \ T = 4     preset 4 digits for base 16 and by default
MOV &BASEADR,W
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
    TYPE $20 EMIT   \ --         
;

[THEN]

CODE POL2REC   \ u f -- X Y
\ input ; u = module {1000...16384}, f = angle (15Q16 number) in degrees {1,0...89,0}
\ output ; X Y 
\ TOS = fhi, 0(PSP) = flo, 2(PSP) = u
PUSH IP             \ save IP before use
MOV @PSP+,Y         \ Y = flo
SWPB Y
AND #$00FF,Y
SWPB TOS
AND #$FF00,TOS
BIS Y,TOS           \ -- module angle*256
\ =====================
\ CORDIC 16 bits engine
\ =====================
MOV #-1,IP          \ IP = i-1
MOV @PSP,X          \ X = Xi
MOV #0,Y            \ Y = Yi
 BEGIN              \ i loops with init i = 0 
    ADD #1,IP
    MOV X,S         \ S = Xi to be right shifted
    MOV Y,T         \ T = Yi to be right shifted
    MOV #0,W        \
    GOTO FW1
    BEGIN
        RRA S       \ (Xi >> 1)
        RRA T       \ (Yi >> 1)
        ADD #1,W
FW1     CMP IP,W    \ W = i ?
    0= UNTIL        \ loop back if W < i
    ADD W,W         \ W = 2i = T_SCALE displacement
    CMP #0,TOS      \ TOS = z
    0>= IF          \ TOS >= 0 : Rotate clockwise
        SUB T,X     \ Xi+1 = Xi - ( Yi >> i)
        ADD S,Y     \ Yi+1 = Yi + ( Xi >> i)
        SUB T_ARCTAN(W),TOS
    ELSE            \ TOS < 0 : Rotate counter-clockwise
        ADD T,X     \ Xi+1 = Xi + ( Yi >> i)
        SUB S,Y     \ Yi+1 = Yi - ( Xi >> i)
        ADD T_ARCTAN(W),TOS
    THEN
    CMP #0,TOS      \ if angle*256 = 0 quit loop
    0<> WHILE       \ search "Extended control-flow patterns" in https://forth-standard.org/standard/rationale
        CMP #14,IP
 0= UNTIL
    THEN            \ search "Extended control-flow patterns" in https://forth-standard.org/standard/rationale
\ multiply cos by factor scale
CALL #XSCALE
MOV X,0(PSP)        \ 3     hi result = cos
\ multiply sin by factor scale
MOV Y,X             \ 3
CALL #XSCALE
MOV X,TOS           \ 3     hi result = sin
\ ==================
\ endof CORDIC engine   \ X = cos, Y = sin
\ ==================
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE                 \ -- cos sin


\ REC2POL version with inputs scaling, to increase the accuracy of the angle:
\ REC2POL   X Y -- u f
\ input : X < 16384, |Y| < 16384
\ output ; u = hypothenuse, f = angle (15Q16 number) in degrees
\ rounded hypothenuse, 1 mn accuracy angle
CODE REC2POL        \ X Y -- u f
MOV @PSP,X          \ X = Xi
MOV TOS,Y           \ Y = Yi
\ normalize X Y to 16384 maxi
\ 1- calculate T = |Y|
MOV Y,T
CMP #0,T
S< IF
    XOR #-1,T
    ADD #1,T
THEN
\ 2- abort if null inputs
MOV #-1,TOS \ set TOS TRUE for the two ABORT" below
MOV X,S
ADD T,S
0= IF 
    LO2HI 
        ABORT" null inputs"
    HI2LO
THEN
\ 3- select max of X,|Y|
CMP X,T
U< IF       \ X > |Y|
    MOV X,T
THEN
\ 4- abort if X or |Y| >= 16384
CMP #16384,T
    U>= IF
    LO2HI
        ABORT" x or |y| >= 16384"
    HI2LO
    THEN
\ 5- multiply inputs by 2^n scale factor
MOV #1,S        \ init scale factor
RLAM #3,T       \ test bit 2^13
GOTO FW1
BEGIN
    ADD X,X     \ X=X*2
    ADD Y,Y     \ Y=Y*2
    ADD S,S     \ scale factor *2
    ADD T,T     \ to test next bit 2^(n-1)
FW1
U>= UNTIL       \ until carry set
\ 6- save IP and scale factor n
PUSHM #2,IP     \ push IP,S
\ ==================
\ CORDIC engine
\ ==================
MOV #-1,IP          \ IP = i-1, X = Xi, Y = Yi
MOV #0,TOS          \ init z=0
 BEGIN              \ i loops with init: i = 0
    ADD #1,IP
    MOV X,S         \ S = Xi to be right shifted
    MOV Y,T         \ T = Yi to be right shifted
    MOV #0,W        \ W = right shift loop count
    GOTO FW1
    BEGIN
        RRA S       \ (X >> i)
        RRA T       \ (Y >> i)
        ADD #1,W    \
FW1     CMP IP,W    \ W = i ?
    0= UNTIL        \ 6~ loop
    ADD W,W         \ W = 2i = T_SCALE displacement
    CMP #0,Y        \ Y sign ?
    0>= IF          \ Y >= 0 : Rotate counter-clockwise
        ADD T,X     \ Xi+1 = Xi + ( Yi >> i)
        SUB S,Y     \ Yi+1 = Yi - ( Xi >> i)
        ADD T_ARCTAN(W),TOS
    ELSE            \ Y < 0 : Rotate clockwise
        SUB T,X     \ Xi+1 = Xi - ( Yi >> i)
        ADD S,Y     \ Yi+1 = Yi + ( Xi >> i)
        SUB T_ARCTAN(W),TOS
    THEN
    CMP #0,Y        \
    0<> WHILE       \ if Y = 0 quit loop ---+
    CMP #14,IP      \                       |
 0= UNTIL           \                       |
    THEN            \ <---------------------+
\ multiply x by CORDIC gain
CALL #XSCALE             \ 3     hi result = hypothenuse
\ ==================
\ endof CORDIC engine   \ X = hypothenuse, TOS = 256*angle
\ ==================
\ divide x by scale factor
POPM #2,IP              \ S = scale factor, restore IP
GOTO FW1                
BEGIN                   \ 4~ loop
    RRA X               \ divide x by 2
FW1 RRA S               \ shift right scale factor
U>= UNTIL               \ until carry set
MOV X,0(PSP)
\ multiply z by 256 to display it as a Q15.16 number
MOV TOS,Y               \ Y = future fractional part of f
SWPB TOS
AND #$00FF,TOS
SXT TOS                 \ integer part of f
SWPB Y
AND #$FF00,Y
SUB #2,PSP
MOV Y,0(PSP)            \ fractional part of f
MOV @IP+,PC
ENDCODE                 \

PWR_HERE

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

[UNDEFINED] ROT [IF] \
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

: 1000CORDIC
500 0 DO
    POL2REC REC2POL     \ 2 CORDIC op. * 500 loops = 1000 CORDIC
LOOP 
;

ECHO

; -----------------------------------------------------------
; requires FIXPOINT_INPUT kernel addon, see forthMSP430FR.asm
; -----------------------------------------------------------

\
10000 89,0 POL2REC . .  ; sin, cos --> 
10000 75,0 POL2REC . .  ; sin, cos --> 
10000 60,0 POL2REC . .  ; sin, cos --> 
10000 45,0 POL2REC . .  ; sin, cos --> 
10000 30,0 POL2REC . .  ; sin, cos --> 
10000 15,0 POL2REC . .  ; sin, cos --> 
10000 1,0 POL2REC . .   ; sin, cos --> 
\ module phase -- X Y
16384 30,0 POL2REC SWAP . . ; x, y --> 
16384 45,0 POL2REC SWAP . . ; x, y --> 
16384 60,0 POL2REC SWAP . . ; x, y --> 
\


2  1  REC2POL F. .          ; phase module --> 
2 -1  REC2POL F. .          ; phase module --> 
20  10  REC2POL F. .        ; phase module --> 
20 -10  REC2POL F. .        ; phase module --> 
200 100 REC2POL F. .        ; phase module --> 
100 -100 REC2POL F. .       ; phase module --> 
2000 1000 REC2POL F. .      ; phase module --> 
1000 -1000 REC2POL F. .     ; phase module --> 
16000 8000 REC2POL F. .     ; phase module --> 
16000 -8000 REC2POL F. .    ; phase module --> 
16000 0 REC2POL F. .        ; phase module --> 
0 16000 REC2POL F. .        ; phase module --> 
\ 16384 -8192 REC2POL F. .    ; --> abort
\ 0 0 REC2POL F. .            ; --> abort


10000 89,0 POL2REC REC2POL   ROT . F. 
10000 75,0 POL2REC REC2POL   ROT . F. 
10000 60,0 POL2REC REC2POL   ROT . F. 
10000 45,0 POL2REC REC2POL   ROT . F. 
10000 30,0 POL2REC REC2POL   ROT . F. 
10000 26,565 POL2REC REC2POL ROT . F. 
10000 15,0 POL2REC REC2POL   ROT . F. 
10000 14,036 POL2REC REC2POL ROT . F. 
10000 7,125 POL2REC REC2POL  ROT . F. 
10000 1,0 POL2REC REC2POL    ROT . F. 

10000 89,0   1000CORDIC      ROT . F.
10000 75,0   1000CORDIC      ROT . F.
10000 60,0   1000CORDIC      ROT . F.
10000 45,0   1000CORDIC      ROT . F.
10000 30,0   1000CORDIC      ROT . F.
10000 26,565 1000CORDIC      ROT . F.
10000 15,0   1000CORDIC      ROT . F.
10000 14,036 1000CORDIC      ROT . F.
10000 7,125  1000CORDIC      ROT . F.
10000 1,0    1000CORDIC      ROT . F.

PWR_STATE \ remove tests
