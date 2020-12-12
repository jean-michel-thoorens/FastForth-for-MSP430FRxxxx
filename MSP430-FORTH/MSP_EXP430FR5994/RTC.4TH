
CODE ABORT_RTC
SUB #4,R15
MOV R14,2(R15)
MOV &$1812,R14
BIT #$8000,R14
0<> IF MOV #0,R14 THEN
MOV R14,0(R15)
MOV &$180E,R14
SUB #308,R14
COLON
$0D EMIT
ABORT" FastForth V3.8 please!"
ABORT" target without LF_XTAL !"
PWR_STATE
;

ABORT_RTC

; --------------------
; RTC.4th for MSP_EXP430FR5994
; --------------------

[DEFINED] {RTC} [IF] {RTC} [THEN] 

MARKER {RTC}
8 ALLOT


[UNDEFINED] OR [IF]
CODE OR
BIS @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] C@ [IF]
CODE C@
MOV.B @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] C! [IF]
CODE C!
MOV.B @R15+,0(R14)
ADD #1,R15
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] SWAP [IF]
CODE SWAP
MOV @R15,R10
MOV R14,0(R15)
MOV R10,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] OVER [IF]
CODE OVER
MOV R14,-2(R15)
MOV @R15,R14
SUB #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DUP [IF]
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

[UNDEFINED] DROP [IF]
CODE DROP
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DEPTH [IF]
CODE DEPTH
MOV R14,-2(R15)
MOV #$1C80,R14
SUB R15,R14
RRA R14
SUB #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] >R [IF]
CODE >R
PUSH R14
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] R> [IF]
CODE R>
SUB #2,R15
MOV R14,0(R15)
MOV @R1+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 1+ [IF]
CODE 1+
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] U< [IF]
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

[UNDEFINED] = [IF]
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

[UNDEFINED] IF [IF]
CODE IF
SUB #2,R15
MOV R14,0(R15)
MOV &$1DC6,R14
ADD #4,&$1DC6
MOV #$4034,0(R14)
ADD #2,R14
MOV @R13+,R0
ENDCODE IMMEDIATE

CODE THEN
MOV &$1DC6,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
CODE ELSE
ADD #4,&$1DC6
MOV &$1DC6,R10
MOV #$403A,-4(R10)
MOV R10,0(R14)
SUB #2,R10
MOV R10,R14
MOV @R13+,R0
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] DO [IF]
CODE DO
SUB #2,R15
MOV R14,0(R15)
ADD #2,&$1DC6
MOV &$1DC6,R14
MOV #$403E,-2(R14)
ADD #2,&$1C00
MOV &$1C00,R10
MOV #0,0(R10)
MOV @R13+,R0
ENDCODE IMMEDIATE

CODE LOOP
    MOV #$4060,R9
BW1 ADD #4,&$1DC6
    MOV &$1DC6,R10
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

CODE +LOOP
MOV #$404E,R9
GOTO BW1
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] CASE [IF]
: CASE 0 ; IMMEDIATE

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

[UNDEFINED] + [IF]
CODE +
ADD @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] - [IF]
CODE -
SUB @R15+,R14
XOR #-1,R14
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

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

[UNDEFINED] 2* [IF]
CODE 2*
ADD R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] UM* [IF]    
CODE UM*
    MOV @R15,&$4C0
    MOV R14,&$4C8
    MOV &$4E4,0(R15)
    MOV &$4E6,R14
    MOV @R13+,R0
ENDCODE
[THEN] 

[UNDEFINED] UM/MOD [IF]
CODE UM/MOD
    PUSH #DROP
    MOV #$4066,R0
ENDCODE
[THEN]

[UNDEFINED] U*/ [IF]
: U*/
>R UM* R> UM/MOD SWAP DROP
;
[THEN]

[UNDEFINED] U/MOD [IF]
: U/MOD
0 SWAP UM/MOD
;
[THEN]

[UNDEFINED] UMOD [IF]
: UMOD
U/MOD DROP
;
[THEN]

[UNDEFINED] U/ [IF]
: U/
U/MOD SWAP DROP
;
[THEN]

[UNDEFINED] SPACES [IF]
CODE SPACES
CMP #0,R14
0<> IF
    PUSH R13
    BEGIN
        LO2HI
        $20 EMIT
        HI2LO
        SUB #2,R13 
        SUB #1,R14
    0= UNTIL
    MOV @R1+,R13
THEN
MOV @R15+,R14
MOV @R13+,R0              
ENDCODE
[THEN]

[UNDEFINED] HERE [IF]
CODE HERE
MOV #$4028,R0
ENDCODE
[THEN]

[UNDEFINED] U.R [IF]
: U.R
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]

$81EF $1A04 @ U<     ; search device ID: MSP430FR4133 or...
$1A04 @ $8241 U<     ; ...MSP430FR2433
=   
$830B $1A04 @ U<     ; MSP430FR21xx/23xx/24xx/25xx/26xx
OR                      ; -- flag

[IF] 


    CREATE $4B0 2 ALLOT
    CREATE $4B1 2 ALLOT
    CREATE $4B2 2 ALLOT
    CREATE $4B3 2 ALLOT
    CREATE $4B4 2 ALLOT
    CREATE $4B5 2 ALLOT
    CREATE $4B6 2 ALLOT

    HDNCODE RTC_INT
    ADD #2,R1
    BIT #1,&$4AE
    ADD.B #1,&$4B0
    CMP.B #60,&$4B0
    U>= IF               
        MOV.B #0,&$4B0
        ADD.B #1,&$4B1
        CMP.B #60,&$4B1
        U>= IF               
            MOV.B #0,&$4B1
            ADD.B #1,&$4B2
            CMP.B #24,&$4B2
            U>= IF                
                MOV.B #0,&$4B2
                ADD.B #1,&$4B3
                CMP.B #7,&$4B3
                U>= IF
                    MOV.B #0,&$4B3
                THEN
                ADD.B #1,&$4B4
                CMP.B #2,&$4B5
                0= IF
                    COLON
                    $4B6 @ 4 UMOD 
                    IF 29
                    ELSE
                        $4B6 @ 100 UMOD 
                        IF 30
                        ELSE
                            $4B6 @ 400 UMOD
                            IF 29
                            ELSE 30
                            THEN
                        THEN
                    THEN
                    HI2LO
                    MOV @R1+,R13
                    MOV R14,R9
                    MOV @R15+,R14
                ELSE
                    MOV #31,R9
                    MOV.B &$4B5,R10
                    CMP.B #8,R10
                    0>= IF
                        ADD.B #1,R10      
                    THEN
                    BIT.B #1,R10
                    0<> IF      
                        ADD #1,R9
                    THEN
                THEN
                CMP.B R9,&$4B4
                U>= IF
                    MOV.B #1,&$4B4
                    ADD.B #1,&$4B5
                    CMP.B #13,&$4B5
                    U>= IF
                    MOV.B #1,&$4B5
                        ADD #1,&$4B6
                    THEN
                THEN
            THEN
        THEN
    THEN
    MOV @R1+,R0
    ENDCODE    

    HDNCODE STOP_RTC
    CMP #$40AA,&{RTC}+8
    0<> IF
    MOV #{RTC}+10,R9
        MOV #$40AA,-2(R9)
        MOV @R9+,&RTC_VEC
        MOV @R9+,&COLD+2
        MOV @R9+,&WARM+2
    THEN
    MOV #0,&RTCCTL
    MOV.B #XIN,R9
    BIC.B R9,&XT1_SEL
    BIS.B R9,&XT1_DIR
    BIC.B R9,&XT1_OUT
    BIS.B R9,&XT1_OUT
    BIC.B R9,&XT1_OUT
    BIS.B R9,&XT1_OUT
    BIC.B R9,&XT1_DIR
    BIS.B R9,&XT1_SEL
    MOV &COLD+2,R0
    ENDCODE

    HDNCODE INI_RTC
    CALL &{RTC}+14
    CMP #0,&RTCCTL
    0= IF
        MOV #$7F,&RTCMOD
        BIT #-1,&$4AE
        MOV #%0010_0110_0100_0010,&RTCCTL
    THEN
    MOV @R1+,R0
    ENDCODE


    CODE START_RTC
    CMP #STOP_RTC,&{RTC}+8
    0<> IF
        MOV #STOP_RTC,&{RTC}+8
        MOV &RTC_VEC,&{RTC}+10
        MOV #RTC_INT,&RTC_VEC
        MOV &COLD+2,&{RTC}+12
        MOV #STOP_RTC,&COLD+2
        MOV &WARM+2,&{RTC}+14
        MOV #INI_RTC,&WARM+2
    THEN
    CALL #INI_RTC
    MOV @R13+,R0
    ENDCODE                 

    : TIME?
    $4B2 C@ 2 U.R $3A EMIT
    $4B1 C@  2 U.R $3A EMIT
    $4B0 C@  2 U.R 
    ;
    
    : TIME!
    START_RTC
    2 DEPTH
    U< IF
        $4B0 C!
        $4B1 C!
        $4B2 C!
    THEN
    ." it is " TIME? 
    ;

    : DATE?

[ELSE]


    CODE TIME?
    BEGIN
        BIT.B #$10,&$4A2
    0<> UNTIL
    COLON
    $4B2 C@ 2 U.R $3A EMIT
    $4B1 C@  2 U.R $3A EMIT
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

[THEN]


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
    2 U.R $2F EMIT
    2 U.R $2F EMIT
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

RST_HERE

[UNDEFINED] S_ [IF]
CODE S_
MOV #0,&$1DB4
COLON
$4014 ,
$20 WORD
HI2LO
MOV.B @R14,R14
ADD #1,R14
BIT #1,R14
ADDC R14,&$1DC6
MOV @R15+,R14
MOV @R1+,R13
MOV #$20,&$1DB4
MOV @R13+,R0
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ESC [IF]
CODE ESC
CMP #0,&$1DBE
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

[UNDEFINED] >BODY [IF]
CODE >BODY
ADD #4,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] EXECUTE [IF]
CODE EXECUTE
PUSH R14
MOV @R15+,R14
MOV @R1+,R0
ENDCODE
[THEN]

[UNDEFINED] EVALUATE [IF]
CODE EVALUATE
MOV #$1DC0,R9
MOV @R9+,R12
MOV @R9+,R11
MOV @R9+,R10
PUSHM #4,R13
LO2HI
INTERPRET
HI2LO
MOV @R1+,&$1DC4
MOV @R1+,&$1DC2
MOV @R1+,&$1DC0
MOV @R1+,R13 
MOV @R13+,R0
ENDCODE
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
RST_STATE
;
 
ECHO
SET_TIME
