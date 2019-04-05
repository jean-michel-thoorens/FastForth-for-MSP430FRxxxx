; -----------------------------------
; PROG100k.4th = 110 x RC5toLCD.4th
; -----------------------------------


PWR_STATE

[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE

CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE


CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]


[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]



CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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


[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE


[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE


CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE


CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE



ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM


ASM RC5_INT
  MOV #1,&$3A0
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM


ASM BACKGROUND
MOV #SLEEP,R9
ADD #4,R9
MOV R9,R0
ENDASM


CODE START
    MOV #%1011010100,&$3C0
    MOV #1,&$3E0
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA

    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)

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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;


CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)

COLON
    ['] WARM >BODY IS WARM

    COLD
;



            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

[THEN]





; -----------------------------------
; RC5toLCD.4th
; -----------------------------------


[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]

[DEFINED] ASM [IF]

MARKER {RC5TOLCD}

[UNDEFINED] MAX [IF]

CODE MAX
    CMP @R15,R14
    S<  ?GOTO FW1
BW1 ADD #2,R15
    MOV @R13+,R0
ENDCODE

CODE MIN
    CMP @R15,R14
    S<  ?GOTO BW1
FW1 MOV @R15+,R14
    MOV @R13+,R0
ENDCODE

[THEN]

[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]

CODE 20_US
BEGIN
    BEGIN
        BIT #1,&$3C0
    0<> UNTIL
    BIC #1,&$3C0
    SUB #1,R14
U< UNTIL
MOV @R15+,R14
MOV @R13+,R0
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

[UNDEFINED] OR [IF]

CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE

[THEN]

: LCD_Entry_set     $04 OR LCD_WrF ;

: LCD_DSP_Ctrl      $08 OR LCD_WrF ;

: LCD_DSP_Shift     $10 OR LCD_WrF ;

: LCD_Fn_Set        $20 OR LCD_WrF ;

: LCD_CGRAM_Set     $40 OR LCD_WrF ;

: LCD_Goto          $80 OR LCD_WrF ;

CODE LCD_R
    BIC.B #$0F,&$224
    BIS.B #1,&$243
COLON
    TOP_LCD 2 20_us
    TOP_LCD 2 20_us
HI2LO
    RLAM #4,0(R15)
    ADD.B @R15+,R14
    MOV @R1+,R13
    MOV @R13+,R0
ENDCODE

CODE LCD_RdS
    BIC.B #2,&$243
    JMP LCD_R
ENDCODE

CODE LCD_RdC
    BIS.B #2,&$243
    JMP LCD_R
ENDCODE


ASM WDT_INT
BIT.B #$20,&$240
0= IF
    CMP #19,&$3D6
    U< IF
        ADD #1,&$3D6
    THEN
ELSE
    BIT.B #$40,&$240
    0= IF
        CMP #3,&$3D6
        U>= IF
           SUB #1,&$3D6
        THEN
    THEN
THEN
BW1
BW2
BW3
BIC #$78,0(R1)
RETI
ENDASM

ASM RC5_INT
$1806 @ 16000 = [IF]
    MOV #1,&$3A0
[THEN]
$1806 @ 24000 = [IF]
    MOV #2,&$3A0
[THEN]
MOV #1778,R9
MOV #14,R10
BEGIN
MOV #%1011100100,&$380
    RRUM    #1,R9
    MOV     R9,R8
    RRUM    #1,R8
    ADD     R9,R8
    BEGIN   CMP R8,&$390
    U>= UNTIL
    BIT.B   #4,&$200
    ADDC    R11,R11
    MOV.B   &$200,&$208
    BIC.B   #4,&$20C
    SUB     #1,R10
0<> WHILE
    ADD R9,R8
    BEGIN
        MOV &$390,R9
        CMP R8,R9
        U>= IF
        BIC #$30,&$380
        GOTO BW1
        THEN
        BIT.B #4,&$20C
    0<> UNTIL
REPEAT
BIC #$30,&$380
RLAM    #1,R11
MOV.B   R11,R9
RRUM    #2,R9
BIT     #$4000,R11
0= IF   BIS #$40,R9
THEN
RRUM    #3,R11
XOR     @R1,R11
BIT     #$400,R11
0= ?GOTO BW2
XOR #$400,0(R1)
SUB #4,R15
MOV &BASE,2(R15)
MOV #$10,&BASE
MOV R14,0(R15)
MOV R9,R14
LO2HI
    ['] LCD_CLEAR IS CR
    ['] LCD_WrC  IS EMIT
    CR ." $" 2 U.R
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
HI2LO
MOV R14,&BASE
MOV @R15+,R14
GOTO BW3
ENDASM

ASM BACKGROUND
BIS #$180A,R2
ENDASM
CODENNM
JMP BACKGROUND
ENDCODE DROP



CODE STOP
    MOV #SLEEP,R9
    ADD #4,R9
    MOV R9,-2(R9)
COLON
['] WARM >BODY IS WARM
ECHO
." RC5toLCD is removed." CR
."    type START to restart"
COLD
;

CODE START
MOV #%1011010100,&$3C0
$1806 @ 16000 = [IF]
    MOV #1,&$3E0
[THEN]
$1806 @ 24000 = [IF]
    MOV #2,&$3E0
[THEN]
    MOV #19,&$3D2
    MOV #%01100000,&$3C6
    MOV #10,&$3D6
    BIS.B #$20,&$204
    BIS.B #$20,&$20A
    BIS.B #7,&$245
    BIC.B #7,&$247
    BIS.B #$0F,&$224
    BIC.B #$0F,&$226
    BIS.B #4,&$20A
    BIC.B #4,&$20C
    MOV #RC5_INT,&$FFDE
    MOV #%0100010100,&$340
    MOV ##1638,&$352
    MOV #%10000,&$342
    MOV #WDT_INT,&$FFEA
    MOV #SLEEP,R9
    MOV #BACKGROUND,2(R9)
BIC #1,&$130
BIS.B #3,&$20D
MOV &$1808,R8
CMP #4,R8
0= ?JMP STOP
COLON
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
    ['] CR >BODY IS CR
    ['] EMIT >BODY IS EMIT
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM
    ABORT
;

ECHO
            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

