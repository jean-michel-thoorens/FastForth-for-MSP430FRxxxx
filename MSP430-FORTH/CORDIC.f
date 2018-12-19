; CORDIC.f
\ see CORDICforDummies.pdf
\
\
\ FAST-FORTH V208.
\ compile FAST-FORTH with at least these options: ASSEMBLER, CONDCOMP, FIXPOINT_INPUT, LOWERCASE.

\ TARGET Current Selection (used by preprocessor GEMA to load the pattern: \config\gema\TARGET.pat)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433  MSP_EXP430FR2355    CHIPSTICK_FR2433
\
[DEFINED] {CORDIC} [IF] {CORDIC} [THEN] \ remove {CORDIC}

MARKER {CORDIC}

[UNDEFINED] {FIXPOINT} [IF] \ define words to display angle as Q15.16 number.

\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free chars area in the 32+2 bytes HOLD buffer sized for a 32 bits {hexa,decimal,binary} number = {26,23,2}.
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

\ F#S    Qlo Qhi u -- Qhi 0   convert fractionnal part of Q15.16 fixed point number with u digits
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

[THEN] \ end of [UNDEFINED] {FIXPOINT}

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
    FW1 CMP IP,W    \ W = i ?
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
MOV X,&MPY              \ 3     Load 1st operand
MOV T_SCALE(W),&OP2     \ 3     Load 2nd operand
MOV &RES1,0(PSP)        \ 3     hi result = cos
\ multiply sin by factor scale
MOV Y,&MPY              \ 3     Load 1st operand
MOV T_SCALE(W),&OP2     \ 3     Load 2nd operand
MOV &RES1,TOS           \ 3     hi result = sin
\ ==================
\ endof CORDIC engine   \ X = cos, Y = sin
\ ==================
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE                 \ -- cos sin

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
    FW1 CMP IP,W    \ W = i ?
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
    CMP #0,Y        \ if Y = 0 quit loop
    0<> WHILE       \ if Y = 0 goto THEN
    CMP #14,IP
 0= UNTIL
    THEN
\ multiply x by CORDIC gain
MOV X,&MPY              \ 3     Load 1st operand
MOV T_SCALE(W),&OP2     \ 3     CORDIC Gain * 65536
MOV &RES1,X             \ 3     hi result = hypothenuse
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

RST_HERE

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
\16384 -8192 REC2POL F. .    ; --> abort
\0 0 REC2POL F. .            ; --> abort


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

: 2000CORDIC
1000 0 DO
    POL2REC REC2POL     \ 1000 loops
LOOP 
;

10000 89,0  2000CORDIC  ROT . F.
10000 75,0  2000CORDIC  ROT . F.
10000 60,0  2000CORDIC  ROT . F.
10000 45,0  2000CORDIC  ROT . F.
10000 30,0  2000CORDIC  ROT . F.
10000 26,565 2000CORDIC ROT . F.
10000 15,0 2000CORDIC   ROT . F.
10000 14,036 2000CORDIC ROT . F.
10000 7,125 2000CORDIC  ROT . F.
10000 1,0 2000CORDIC    ROT . F.
