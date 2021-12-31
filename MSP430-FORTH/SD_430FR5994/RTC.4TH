
    CODE ABORT_RTC
    SUB #4,R15
    MOV R14,2(R15)
    MOV &$180E,R14
    BIT #$4000,R14
    0<> IF MOV #0,R14 THEN
    MOV R14,0(R15)
    MOV &$180A,R14
    SUB #309,R14
    COLON
    $0D EMIT
    ABORT" FastForth V3.9 please!"
    ABORT" target without LF_XTAL !"
    RST_RET
    ;

    ABORT_RTC

; --------------------
; RTC.4th for MSP_EXP430FR5994
; --------------------


    MARKER {RTC}

    [UNDEFINED] OR 
    [IF]
    CODE OR
    BIS @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] C@ 
    [IF]
    CODE C@
    MOV.B @R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] C! 
    [IF]
    CODE C!
    MOV.B @R15+,0(R14)
    ADD #1,R15
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] SWAP 
    [IF]
    CODE SWAP
    MOV @R15,R10
    MOV R14,0(R15)
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] OVER 
    [IF]
    CODE OVER
    MOV R14,-2(R15)
    MOV @R15,R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DUP 
    [IF]
    CODE DUP
BW1 SUB #2,R15
    MOV R14,0(R15)
    MOV @R13+,R0
    ENDCODE

    CODE ?DUP
    CMP #0,R14
    0<> ?GOTO BW1
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DROP 
    [IF]
    CODE DROP
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DEPTH 
    [IF]
    CODE DEPTH
    MOV R14,-2(R15)
    MOV #$1C80,R14
    SUB R15,R14
    RRA R14
    SUB #2,R15
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] >R 
    [IF]
    CODE >R
    PUSH R14
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] R> 
    [IF]
    CODE R>
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R1+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 1+ 
    [IF]
    CODE 1+
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] 1- 
    [IF]
    CODE 1-
    SUB #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] U< 
    [IF]
    CODE U<
    SUB @R15+,R14
    0<> IF
        MOV #-1,R14
        U< IF
            AND #0,R14
        THEN
    THEN
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] = 
    [IF]
    CODE =
    SUB @R15+,R14
    0<> IF
        AND #0,R14
        MOV @R13+,R0
    THEN
    XOR #-1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] IF 
    [IF]
    CODE IF
    SUB #2,R15
    MOV R14,0(R15)
    MOV &$1DC8,R14
    ADD #4,&$1DC8
    MOV #$40AC,0(R14)
    ADD #2,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    CODE THEN
    MOV &$1DC8,0(R14)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ELSE 
    [IF]
    CODE ELSE
    ADD #4,&$1DC8
    MOV &$1DC8,R10
    MOV #$40B2,-4(R10)
    MOV R10,0(R14)
    SUB #2,R10
    MOV R10,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] DO
    [IF]
    HDNCODE XDO
    MOV #$8000,R9
    SUB @R15+,R9
    MOV R14,R8
    ADD R9,R8
    PUSHM #2,R9
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE

    CODE DO            
    SUB #2,R15
    MOV R14,0(R15)
    ADD #2,&$1DC8
    MOV &$1DC8,R14
    MOV #XDO,-2(R14)
    ADD #2,&$1C00
    MOV &$1C00,R10
    MOV #0,0(R10)
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    HDNCODE XLOOP
    ADD #1,0(R1)
BW1 BIT #$100,R2
    0= IF
        MOV @R13,R13
        MOV @R13+,R0
    THEN
    ADD #4,R1
    ADD #2,R13
    MOV @R13+,R0
    ENDCODE

    CODE LOOP
    MOV #XLOOP,R9
BW2 ADD #4,&$1DC8
    MOV &$1DC8,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    BEGIN
        MOV &$1C00,R14
        SUB #2,&$1C00
        MOV @R14,R14
        CMP #0,R14
    0<> WHILE
        MOV R10,0(R14)
    REPEAT
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE

    HDNCODE XPLOO
    ADD R14,0(R1)
    MOV @R15+,R14
    GOTO BW1
    ENDCODE

    CODE +LOOP
    MOV #XPLOO,R9
    GOTO BW2
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] BEGIN 
    [IF]

    CODE BEGIN
    MOV #$4032,R0
    ENDCODE IMMEDIATE
    
    CODE UNTIL
    MOV #$40AC,R9
BW1 ADD #4,&$1DC8
    MOV &$1DC8,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    
    CODE AGAIN
    MOV #$40B2,R9
    GOTO BW1
    ENDCODE IMMEDIATE
    
    : WHILE
    POSTPONE IF SWAP
    ; IMMEDIATE
    
    : REPEAT
    POSTPONE AGAIN POSTPONE THEN
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] CASE 
    [IF]
    : CASE 
    0 
    ; IMMEDIATE

    : OF
    1+	
    >R	
    POSTPONE OVER POSTPONE =
    POSTPONE IF	
    POSTPONE DROP	
    R>	
    ; IMMEDIATE 

    : ENDOF
    >R	
    POSTPONE ELSE 
    R>	
    ; IMMEDIATE 

    : ENDCASE
    POSTPONE DROP
    0 DO 
        POSTPONE THEN 
    LOOP 
    ; IMMEDIATE 
    [THEN]

    [UNDEFINED] + 
    [IF]
    CODE +
    ADD @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] - 
    [IF]
    CODE -
    SUB @R15+,R14
    XOR #-1,R14
    ADD #1,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] MAX 
    [IF]
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

    [UNDEFINED] 2* 
    [IF]
    CODE 2*
    ADD R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] UM* 
    [IF]
    CODE UM*
    MOV @R15,&$4C0
BW1 MOV R14,&$4C8
    MOV &$4E4,0(R15)
    MOV &$4E6,R14
    MOV @R13+,R0
    ENDCODE

    CODE M*
    MOV @R15,&$4C2
    GOTO BW1
    ENDCODE
    [THEN]

    [UNDEFINED] UM/MOD 
    [IF]
    CODE UM/MOD
    PUSH #DROP
    MOV #$403E,R0
    ENDCODE
    [THEN]

    : U*/
    >R UM* R> UM/MOD SWAP DROP
    ;

    : U/MOD
    0 SWAP UM/MOD
    ;

    : UMOD
    U/MOD DROP
    ;

    : U/
    U/MOD SWAP DROP
    ;

    [UNDEFINED] SPACES 
    [IF]
    : SPACES
    BEGIN
        ?DUP
    WHILE
        $20 EMIT
        1-
    REPEAT
    ;
    [THEN]

    [UNDEFINED] U.R 
    [IF]
    : U.R
    >R  <# 0 # #S #>  
    R> OVER - 0 MAX SPACES TYPE
    ;
    [THEN]

    CODE TIME?
    BEGIN
        BIT.B #$10,&$4A2
    0<> UNTIL
    COLON
    $4B2 C@ 2 U.R ':' EMIT
    $4B1 C@  2 U.R ':' EMIT
    $4B0 C@  2 U.R 
    ;
    
    : TIME!
    2 DEPTH
    U< IF
        $4B0 C!
        $4B1 C!
        $4B2 C!
    THEN
    ." it is " TIME? 
    ;

    CODE DATE?
    BEGIN
        BIT.B #$10,&$4A2
    0<> UNTIL
    COLON



    $4B3 C@
    CASE
    0 OF ." Sat"    ENDOF
    1 OF ." Sun"    ENDOF
    2 OF ." Mon"    ENDOF
    3 OF ." Tue"    ENDOF
    4 OF ." Wed"    ENDOF
    5 OF ." Thu"    ENDOF
    6 OF ." Fri"    ENDOF
    ENDCASE  
    $4B6 @
    $4B5 C@
    $4B4 C@
    $20 EMIT
    2 U.R '/' EMIT
    2 U.R '/' EMIT
    .
    ;

    : DATE!
    2 DEPTH
    U< IF
        $4B6 !
        $4B5 C!
        $4B4 C!
    THEN
    $4B4 C@
    $4B5 C@
    $4B6 @
    OVER 3 U<
    IF 1 - SWAP 12 + SWAP 
    THEN
    100 U/MOD
    DUP 4 U/ SWAP 2* -
    SWAP DUP 4 U/ + +
    SWAP 1+  13 5 U*/ + +
    7 UMOD
    $4B3 C!
    ." we are on " DATE? 
    ;

    RST_SET

    [UNDEFINED] S_ 
    [IF]
    CODE S_
    MOV #0,&$1DC0
    COLON
    $401E ,
    $20 WORD
    HI2LO
    MOV.B @R14,R14
    ADD #1,R14
    BIT #1,R14
    ADDC R14,&$1DC8
    MOV @R15+,R14
    MOV @R1+,R13
    MOV #$20,&$1DC0
    MOV @R13+,R0
    ENDCODE IMMEDIATE
    [THEN]

    [UNDEFINED] ESC 
    [IF]
    CODE ESC
    CMP #0,&$1DBC
    0= IF MOV @R13+,R0
    THEN
    COLON          
    $1B
    POSTPONE LITERAL
    POSTPONE EMIT
    POSTPONE S_
    POSTPONE TYPE
    ; IMMEDIATE
    [THEN]

    [UNDEFINED] >BODY 
    [IF]
    CODE >BODY
    ADD #4,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] EXECUTE 
    [IF]
    CODE EXECUTE
    PUSH R14
    MOV @R15+,R14
    MOV @R1+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] EVALUATE 
    [IF]
    CODE EVALUATE
    MOV #$1DC2,R9
    MOV @R9+,R12
    MOV @R9+,R11
    MOV @R9+,R10
    PUSHM #4,R13
    LO2HI
    [ ' \ 8 + , ]
    HI2LO
    MOV @R1+,&$1DC6
    MOV @R1+,&$1DC4
    MOV @R1+,&$1DC2
    MOV @R1+,R13 
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] CR 
    [IF]

    CODE CR
    MOV #$40B4,R0
    ENDCODE

    :NONAME
    $0D EMIT $0A EMIT
    ; IS CR
    [THEN]

    : SET_TIME
    ESC [8;40;80t
    39 0 DO CR LOOP
    ESC [H
    CR ." DATE (DMY): "
    $1CE4 DUP #84
    ['] ACCEPT >BODY
    EXECUTE
    EVALUATE
    CR DATE!
    CR ." TIME (HMS): "
    $1CE4 DUP #84
    ['] ACCEPT >BODY
    EXECUTE
    EVALUATE
    CR TIME!
    RST_RET
    ;
 
ECHO
SET_TIME
