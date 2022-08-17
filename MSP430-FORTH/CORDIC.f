\ -*- coding: utf-8 -*-
\ see CORDICforDummies.pdf
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, FIXPOINT_INPUT
\
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ LP_MSP430FR2476
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2433  CHIPSTICK_FR2433    MSP_EXP430FR2355
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

; ----------
; CORDIC.f
; ----------

    CODE ABORT_CORDIC
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #BIT8,TOS
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (FIXPOINT_INPUT), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #400,TOS        \                   FastForth V4.0
    COLON
    $0D EMIT            \ return to column 1 without CR
    ABORT" FastForth V4.0 please!"
    ABORT" build FastForth with FIXPOINT_INPUT addon"
    RST_RET             \ if no abort remove this word
    ;

    ABORT_CORDIC

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
    12870 ,         \ 286 * 45      =
    7598 ,          \ 286 * 26.565  = 7597,605
    4014 ,          \ 286 * 14.036  = 4014,366
    2038 ,          \ 286 * 7.125   = 2037,755
    1023 ,          \ 286 * 3.576   = 1022,832
    512 ,           \ 286 * 1.790   = 511,914
    256 ,           \ 286 * 0.895   = 256,020
    128 ,           \ 286 * 0.448   = 128,017
    64 ,            \ 286 * 0.224   = 64,010
    32 ,            \ 286 * 0.112   = 32,005
    16 ,            \ 286 * 0.056   = 16,0025
    8 ,             \ 286 * 0.028   = 8,00126
    4 ,             \ 286 * 0.014   = 4
    2 ,             \ 286 * 0.007   = 2
    1 ,             \ 286 * 0.003   = 1

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

    RST_SET
\ \ https://forth-standard.org/standard/core/Equal
\ \ =      x1 x2 -- flag         test x1=x2
\     [UNDEFINED] =
\     [IF]
\     CODE =
\     SUB @PSP+,TOS   \ 2
\     0<> IF          \ 2
\         AND #0,TOS  \ 1
\         MOV @IP+,PC \ 4
\     THEN
\     XOR #-1,TOS     \ 1 flag Z = 1
\     MOV @IP+,PC     \ 4
\     ENDCODE
\     [THEN]
\
\ \ https://forth-standard.org/standard/core/Uless
\ \ U<    u1 u2 -- flag       test u1<u2, unsigned
\     [UNDEFINED] U<
\     [IF]
\     CODE U<
\     SUB @PSP+,TOS   \ 2 u2-u1
\     0<> IF
\         MOV #-1,TOS     \ 1
\         U< IF           \ 2 flag
\             AND #0,TOS  \ 1 flag Z = 1
\         THEN
\     THEN
\     MOV @IP+,PC     \ 4
\     ENDCODE
\     [THEN]
\
\     $81EF DEVICEID @ U<
\     DEVICEID @ $81F3 U<
\     =

    CODE TSTBIT     \ addr bit_mask -- true/flase flag
    MOV @PSP+,X
    AND @X,TOS
    MOV @IP+,PC
    ENDCODE

    KERNEL_ADDON HMPY TSTBIT \ hardware MPY ?

    RST_RET

    [IF]   ; MSP430FRxxxx with hardware_MPY

        [UNDEFINED] HOLDS [IF]
\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
\ (2 supplementary bytes are room for sign - and decimal point)
\ C HOLDS    addr u --
        CODE HOLDS
        MOV @PSP+,X         \ 2     X=src
BW3     ADD TOS,X           \ 1     X=src_end
        MOV &HP,Y           \ 3     Y=dst
        BEGIN
        SUB #1,X            \ 1     src-1
            SUB #1,TOS          \ 1     cnt-1
        U>= WHILE
            SUB #1,Y            \ 1     dst-1
            MOV.B @X,0(Y)       \ 4
        REPEAT
        MOV Y,&HP           \ 3
        MOV @PSP+,TOS       \ 2
        MOV @IP+,PC         \ 4  15 words
        ENDCODE
        [THEN]

        [UNDEFINED] F#S [IF]
\ F#S    Qlo Qhi u -- Qhi 0   convert fractionnal part of Q15.16 fixed point number
\                             with u digits
        CODE F#S
        MOV 2(PSP),X            \ -- Qlo Qhi u      X = Qlo
        MOV @PSP,2(PSP)         \ -- Qhi Qhi u
        MOV X,0(PSP)            \ -- Qhi Qlo u
        MOV TOS,T               \                   T = len
        MOV #0,S                \                   S = count
        BEGIN
            MOV @PSP,&MPY       \                   Load 1st operand
            MOV &BASEADR,&OP2   \                   Load 2nd operand
            MOV &RES0,0(PSP)    \ -- Qhi RESlo x        low result on stack
            MOV &RES1,TOS       \ -- Qhi RESlo REShi    high result in TOS
            CMP #10,TOS         \                   digit to char
            U>= IF
                ADD #7,TOS
            THEN
            ADD #$30,TOS
            MOV.B TOS,HOLDS_ORG(S)  \ -- Qhi RESlo char     char to string
            ADD #1,S            \                   count+1
            CMP T,S             \                   count=len ?
        0= UNTIL
        MOV T,TOS               \ -- len RESlo len
        MOV #0,0(PSP)           \ -- Qhi 0 len
        MOV #HOLDS_ORG,X        \ -- Qhi 0 len          X=HOLDS_ORG
        GOTO BW3                \ 35~ JMP HOLDS+2
        ENDCODE
        [THEN]

        HDNCODE XSCALE          \ X = X*Cordic_Gain
        MOV T_SCALE(W),&MPYS32L \ 3     CORDIC Gain * 65536
        MOV #0,&MPYS32H
        MOV X,&OP2              \ 3     Load 1st operand
        MOV &RES1,X             \ 3     hi result
        MOV @RSP+,PC            \ RET
        ENDCODE

    [ELSE] ; no hardware multiplier

\ https://forth-standard.org/standard/core/HOLDS
\ Adds the string represented by addr u to the pictured numeric output string
\ compilation use: <# S" string" HOLDS #>
\ free chars area in the 32+2 bytes HOLD buffer = {26,23,2} chars with a 32 bits sized {hexa,decimal,binary} number.
\ (2 supplementary bytes are room for sign - and decimal point)
\ C HOLDS    addr u --
        [UNDEFINED] HOLDS
        [IF]
        CODE HOLDS
        MOV @PSP+,X         \ 2     X=src
BW3     ADD TOS,X           \ 1     X=src_end
        MOV &HP,Y           \ 3     Y=dst
        BEGIN
        SUB #1,X            \ 1     src-1
            SUB #1,TOS      \ 1     cnt-1
        U>= WHILE
            SUB #1,Y        \ 1     dst-1
            MOV.B @X,0(Y)   \ 4
        REPEAT
        MOV Y,&HP           \ 3
        MOV @PSP+,TOS       \ 2
        MOV @IP+,PC         \ 4  15 words
        ENDCODE
        [THEN]

\ F#S    Qlo Qhi len -- Qhi 0   convert fractional part Qlo of Q15.16 fixed point number
\                               with len digits
        [UNDEFINED] F#S
        [IF]
        CODE F#S
        MOV @PSP,S              \ -- Qlo Qhi len        S = Qhi
        MOV #0,T                \                       T = count
        PUSHM #3,IP             \                       R-- IP Qhi count
        MOV 2(PSP),0(PSP)       \ -- Qlo Qlo len
        MOV TOS,2(PSP)          \ -- len Qlo len
        BEGIN
            MOV &BASEADR,TOS    \ -- len Qlo base
            LO2HI
            UM*                 \                       u1 u2 -- RESlo REShi
            HI2LO               \ -- len RESlo digit
            CMP #10,TOS         \                       digit to char
            U>= IF
                ADD #7,TOS
            THEN
            ADD #$30,TOS        \ -- len RESlo char
            MOV @RSP,T          \                       T=count
            MOV.B TOS,HOLDS_ORG(T)  \                   char to string_org(T)
            ADD #1,T            \                       count+1
            MOV T,0(RSP)        \
            CMP 2(PSP),T        \ -- len RESlo char     count=len ?
        U>= UNTIL
        POPM #3,IP              \                       S=Qhi, T=len
        MOV T,TOS               \ -- len RESlo len
        MOV S,2(PSP)            \ -- Qhi RESlo len
        MOV #0,0(PSP)           \ -- Qhi 0 len
        MOV #HOLDS_ORG,X        \ -- Qhi 0 len          X=HOLDS_ORG
        GOTO BW3                \ 36~ JMP HOLDS
        ENDCODE
        [THEN]

\ T.I. UNSIGNED MULTIPLY SUBROUTINE: U1 x U2 -> Ud
\ https://forth-standard.org/standard/core/UMTimes
\ UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
        HDNCODE XSCALE              \ X --> X*Cordic_Gain
        MOV T_SCALE(W),rDOCON   \ rDOCON=MR, X=MDlo
        MOV #0,Y                \ 1 MDhi=0
        MOV #0,S                \ 1 RES0=0
        MOV #0,T                \ 1 RES1=0
        MOV #1,W                \ 1 BIT TEST REGISTER
        BEGIN
            BIT W,rDOCON        \ 1 TEST ACTUAL BIT MRlo
            0<> IF
                ADD X,S         \ 1 IF 1: ADD MDlo TO RES0
                ADDC Y,T        \ 1      ADDC MDhi TO RES1
            THEN
        ADD X,X                 \ 1 (RLA LSBs) MDlo x 2
        ADDC Y,Y                \ 1 (RLC MSBs) MDhi x 2
        ADD W,W                 \ 1 (RLA) NEXT BIT TO TEST
        U>= UNTIL                           \ S = RESlo, T=REShi
        MOV T,X                 \ 2 IF BIT IN CARRY: FINISHED    10~ loop
        MOV #XDOCON,rDOCON      \ restore rDOCON
        MOV @RSP+,PC            \ RET
        ENDCODE

    [THEN]  ; endcase of hardware multiplier

\ input ; u = module {1000...16384}, F = angle (15Q16 number) in degrees {-89,9...89,9}
\ output ; X Y
\ TOS = Fhi, 0(PSP) = Flo, 2(PSP) = u
    CODE POL2REC   \ u F -- X Y
    PUSH IP             \ save IP before use
    MOV @PSP+,&MPY32L     \ multiply angle by 286
    MOV TOS,&MPY32H
    MOV #286,&OP2
    MOV &RES0,Y
    MOV &RES1,TOS       \ -- module angle*286
\ =====================
\ CORDIC 16 bits engine
\ =====================
    MOV #-1,IP          \ IP = i-1
    MOV @PSP,X          \ X = Xi
    MOV #0,Y            \ Y = Yi
    BEGIN               \ i loops with init i = -1
        ADD #1,IP       \ i = i+1
        MOV X,S         \ S = Xi to be right shifted
        MOV Y,T         \ T = Yi to be right shifted
        MOV #0,W        \
        GOTO FW1
        BEGIN
            RRA S       \ (Xi >> 1)
            RRA T       \ (Yi >> 1)
            ADD #1,W
FW1         CMP IP,W    \ W = i ?
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
            CMP #14,IP  \ IP = size of ARC_TAN table ?
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
\ input : X < 16384, Y < 16384
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
\ 2- calculate S = |X|
    MOV X,S
    CMP #0,S
    S< IF
        XOR #-1,S
        ADD #1,S
    THEN
\ 3- abort if null inputs
    MOV #-1,TOS \ set TOS TRUE for the two ABORT" below
    CMP #0,X
    0= IF
        CMP #0,Y
        0= IF
            LO2HI
                ABORT" null inputs!"
            HI2LO
        THEN
    THEN
\ 4- select max of |X|,|Y|
    CMP S,T
    U< IF       \ |X| > |Y|
        MOV S,T
    THEN
\ 5- abort if |X| or |Y| >= 16384
    CMP #16384,T
        U>= IF
        LO2HI
            ABORT" |x| or |y| >= 16384"
        HI2LO
        THEN
\ 6- multiply inputs by 2^n scale factor
    MOV #1,S        \ init scale factor
    RLAM #3,T       \ test bit 2^13 of max(X,Y)
    GOTO FW1
    BEGIN
        ADD X,X     \ X=X*2
        ADD Y,Y     \ Y=Y*2
        ADD S,S     \ scale factor *2
        ADD T,T     \ to test next bit 2^(n-1)
FW1
    U>= UNTIL       \ until carry set
\ 7- save IP and scale factor n
    PUSHM #2,IP     \ push IP,S
\ ==================
\ CORDIC 16 bits engine
\ ==================
    MOV #-1,IP          \ IP = i-1, X = Xi, Y = Yi
    MOV #0,TOS          \ init z=0
    BEGIN              \ i loops with init: i = -1
        ADD #1,IP       \ i = i+1
        MOV X,S         \ S = Xi to be right shifted
        MOV Y,T         \ T = Yi to be right shifted
        MOV #0,W        \ W = right shift loop count
        GOTO FW1
        BEGIN
            RRA S       \ (X >> i)
            RRA T       \ (Y >> i)
            ADD #1,W    \
FW1         CMP IP,W    \ W = i ?
        0= UNTIL        \ 6~ loop
        ADD W,W         \ W = 2i = T_SCALE displacement
        CMP #0,Y        \ Y sign ?
        S>= IF          \ Y >= 0 : Rotate counter-clockwise
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
FW1     RRA S               \ shift right scale factor
    U>= UNTIL               \ until carry set
    MOV X,0(PSP)
\ divide z by 286 to display it as a Q15.16 number
    SUB #4,PSP              \ -- X * * Zhi
    MOV TOS,rDOCON          \ -- rDOCON as sign of QUOT
    CMP #0,rDOCON
    S< IF
        XOR #-1,TOS
        ADD #1,TOS
    THEN
    MOV #0,2(PSP)           \ -- X Zlo * Zhi
    MOV TOS,0(PSP)          \ -- X Zlo Zhi Zhi
    MOV #286,TOS            \ -- X Zlo Zhi DIV
    CALL #MUSMOD            \ -- X rem QUOTlo QUOThi
    MOV @PSP+,0(PSP)        \    remove remainder
    CMP #0,rDOCON
    S< IF
        XOR #-1,0(PSP)
        XOR #-1,TOS
        ADD #1,0(PSP)
        ADDC #0,TOS
    THEN
    MOV #XDOCON,rDOCON
    MOV @IP+,PC
    ENDCODE


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

RST_SET

\ https://forth-standard.org/standard/core/SWAP
\ SWAP     x1 x2 -- x2 x1    swap top two items
    [UNDEFINED] SWAP [IF]
    CODE SWAP
    MOV @PSP,W      \ 2
    MOV TOS,0(PSP)  \ 3
    MOV W,TOS       \ 1
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

\ https://forth-standard.org/standard/core/ROT
\ ROT    x1 x2 x3 -- x2 x3 x1
    [UNDEFINED] ROT [IF] \
    CODE ROT
    MOV @PSP,W          \ 2 fetch x2
    MOV TOS,0(PSP)      \ 3 store x3
    MOV 2(PSP),TOS      \ 3 fetch x1
    MOV W,2(PSP)        \ 3 store x2
    MOV @IP+,PC
    ENDCODE
    [THEN]

ECHO

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
10000 -89,0 POL2REC . .  ; sin, cos --> 
10000 -75,0 POL2REC . .  ; sin, cos --> 
10000 -60,0 POL2REC . .  ; sin, cos --> 
10000 -45,0 POL2REC . .  ; sin, cos --> 
10000 -30,0 POL2REC . .  ; sin, cos --> 
10000 -15,0 POL2REC . .  ; sin, cos --> 
10000 -1,0 POL2REC . .   ; sin, cos --> 
\ module phase -- X Y
16384 -30,0 POL2REC SWAP . . ; x, y --> 
16384 -45,0 POL2REC SWAP . . ; x, y --> 
16384 -60,0 POL2REC SWAP . . ; x, y --> 

\
-10000 89,0 POL2REC . .  ; sin, cos --> 
-10000 75,0 POL2REC . .  ; sin, cos --> 
-10000 60,0 POL2REC . .  ; sin, cos --> 
-10000 45,0 POL2REC . .  ; sin, cos --> 
-10000 30,0 POL2REC . .  ; sin, cos --> 
-10000 15,0 POL2REC . .  ; sin, cos --> 
-10000 1,0 POL2REC . .   ; sin, cos --> 
\ module phase -- X Y
-16384 30,0 POL2REC SWAP . . ; x, y --> 
-16384 45,0 POL2REC SWAP . . ; x, y --> 
-16384 60,0 POL2REC SWAP . . ; x, y --> 
\

-10000 -89,0 POL2REC . .  ; sin, cos --> 
-10000 -75,0 POL2REC . .  ; sin, cos --> 
-10000 -60,0 POL2REC . .  ; sin, cos --> 
-10000 -45,0 POL2REC . .  ; sin, cos --> 
-10000 -30,0 POL2REC . .  ; sin, cos --> 
-10000 -15,0 POL2REC . .  ; sin, cos --> 
-10000 -1,0 POL2REC . .   ; sin, cos --> 
\ module phase -- X Y
-16384 -30,0 POL2REC SWAP . . ; x, y --> 
-16384 -45,0 POL2REC SWAP . . ; x, y --> 
-16384 -60,0 POL2REC SWAP . . ; x, y --> 
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

-2  1  REC2POL F. .          ; phase module --> 
-2 -1  REC2POL F. .          ; phase module --> 
-20  10  REC2POL F. .        ; phase module --> 
-20 -10  REC2POL F. .        ; phase module --> 
-200 100 REC2POL F. .        ; phase module --> 
-100 -100 REC2POL F. .       ; phase module --> 
-2000 1000 REC2POL F. .      ; phase module --> 
-1000 -1000 REC2POL F. .     ; phase module --> 
-16000 8000 REC2POL F. .     ; phase module --> 
-16000 -8000 REC2POL F. .    ; phase module --> 
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


