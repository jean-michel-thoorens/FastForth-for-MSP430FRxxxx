; -----------------------------------
; prog10k.4th
; -----------------------------------

PWR_STATE

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

PWR_STATE
CODE MAX
            CMP     @R15,R14
            S<      ?GOTO FW1
BW1         ADD     #2,R15
            MOV     @R13+,R0
ENDCODE

CODE MIN
            CMP     @R15,R14
            S<      ?GOTO BW1
FW1         MOV     @R15+,R14
            MOV     @R13+,R0
ENDCODE

: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;

CODE 20_US
BEGIN
    MOV     #51,R10
    BEGIN
        SUB #1,R10
    0= UNTIL
    SUB     #1,R14
0= UNTIL
    MOV     @R15+,R14
    MOV     @R13+,R0
ENDCODE

CODE TOP_LCD
    BIS.B #4,&$243
    BIT.B #1,&$241
0= IF
    AND.B #$0F,R14
    MOV.B R14,&$222
    BIC.B #4,&$243
    MOV @R15+,R14
    MOV @R13+,R0
THEN
    SUB #2,R15
    MOV R14,0(R15)
    BIC.B #4,&$243
    MOV.B &$220,R14
    AND.B #$0F,R14
    MOV @R13+,R0
ENDCODE

CODE LCD_W
    SUB #2,R15
    MOV R14,0(R15)
    RRUM #4,R14
    BIC.B #1,&$243
    BIS.B #$0F,&$224
COLON
    TOP_LCD 2 20_US
    TOP_LCD 2 20_US 
;

CODE LCD_WrC
    BIS.B #2,&$243
    JMP LCD_W 
ENDCODE

CODE LCD_WrF
    BIC.B #2,&$243
    JMP LCD_W 
ENDCODE

: LCD_Clear 
    $01 LCD_WrF 100 20_us
;

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;

ASM WDT_INT
BIC #$F8,0(R1)
BIT.B #$20,&$240
0= IF
    CMP #38,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #7,&$3D6
        U>= IF
            SUB #1,&$3D6
        THEN
    THEN
THEN
RETI
ENDASM

ASM RC5_INT
BIC     #$F8,0(R1)
MOV     #0,&$360
MOV     #1778,R9
MOV     #14,R10
BEGIN
    MOV #%1011100100,&$340
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$350
    0= UNTIL
    BIT.B   #4,&$200
    ADDC    R13,R13
    MOV     &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD     R9,R8
    BEGIN
        CMP     R8,&$350
        0>= IF
            BIC  #$30,&$340
            RETI
        THEN
        BIT.B   #4,&$20C
    0<> UNTIL
    MOV     &$350,R9
REPEAT
BIC     #$30,&$340
RLAM    #1,R13
MOV     @R1,R9
RLAM    #4,R9
XOR     R13,R9
BIT     #$2000,R9
0= IF RETI
THEN
XOR     #$200,0(R1)
SUB     #4,R15
MOV     &$1DDA,2(R15)
MOV     R14,0(R15)
MOV.B   R13,R14
RRUM    #2,R14
BIT     #$4000,R13
0= IF   BIS #$40,R14
THEN
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    $10 $1DDA !
    CR ." $" 2 U.R
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
HI2LO
MOV @R15+,&$1DDA
RETI
ENDASM

CODE START
    MOV #%1010010100,&$3C0
    MOV #0,&$3E0
    MOV #40,&$3D2
    MOV #%1100000,&$3C6
    MOV #25,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    MOV #$5A5E,&$15C
    BIS #1,&$100
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #WDT_INT,&$FFF2
    MOV #RC5_INT,&$FFDE
LO2HI
    $03E8 20_US
    $03 TOP_LCD
    $CD 20_US
    $03 TOP_LCD
    $5 20_US
    $03 TOP_LCD
    $2 20_US
    $02 TOP_LCD
    $2 20_US
    $28 LCD_WRF
    $08 LCD_WRF
    LCD_Clear
    $06 LCD_WRF
    $0C LCD_WRF
    LCD_Clear
    ['] LCD_HOME IS CR
    ['] LCD_WRC  IS EMIT
    CR ." I love you"   
    ['] (CR) IS CR
    ['] (EMIT) IS EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    (WARM)
;

: STOP
    ['] (WARM) IS WARM
    ECHO COLD
;

ECHO
            ; download is done
PWR_HERE    ; this app is protected against power ON/OFF,
