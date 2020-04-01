
; ------------
; CHNGBAUD.4th for MSP_EXP430FR5994
; ------------

[UNDEFINED] @ [IF]
CODE @
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] AND [IF]
CODE AND
AND @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 0= [IF]
CODE 0=
SUB #1,R14
SUBC R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

: I2CTERM_ABORT
$0D EMIT
1 ABORT" <-- Ouch! unexpected target with I2C TERMINAL"
;

$1812 @ $7800 AND 0= [IF] ; unexpected I2C TERMINAL ?
I2CTERM_ABORT
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

[UNDEFINED] OVER [IF]
CODE OVER
MOV R14,-2(R15)
MOV @R15,R14
SUB #2,R15
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] @ [IF]
CODE @
MOV @R14,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] ! [IF]
CODE !
MOV @R15+,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] 1+ [IF]
CODE 1+
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] U/ [IF]
CODE U/
SUB #2,R15
MOV #0,0(R15)
CALL #$4074
MOV @R15,R14
ADD #4,R15
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

[UNDEFINED] = [IF]
CODE =
SUB @R15+,R14
0<> IF
    AND #0,R14
ELSE
    XOR #-1,R14
THEN
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] < [IF]
CODE <
    SUB @R15+,R14
    S< ?GOTO FW1
    0<> IF
BW1     MOV #-1,R14
    THEN
    MOV @R13+,R0
ENDCODE

CODE >
    SUB @R15+,R14
    S< ?GOTO BW1
FW1 AND #0,R14
    MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] IF [IF]
CODE IF
SUB #2,R15
MOV R14,0(R15)
MOV &$1DC6,R14
ADD #4,&$1DC6
MOV #$4042,0(R14)
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
MOV #$403E,-4(R10)
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
MOV #$404C,-2(R14)
ADD #2,&$1C00
MOV &$1C00,R10
MOV #0,0(R10)
MOV @R13+,R0
ENDCODE IMMEDIATE

CODE LOOP
    MOV #$406E,R9
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
MOV #$405C,R9
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

[UNDEFINED] S_ [IF]
CODE S_
MOV #0,&$1DB4
COLON
$4018 ,
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

: BAD_MHz
$20 DUP EMIT 
        ABORT" only for 1,4,8,16,24 MHz MCLK!"
;

: OVR_BAUDS
$20 DUP EMIT ESC [7m
        ." with MCLK = " $1806 @ 1000 U/ .
        ABORT" MHz? don't dream!"
;

: CHNGBAUD
PWR_STATE
ECHO
42 0 DO CR LOOP
ESC [H

$1806 @ DUP >R
." target MCLK = " 1000 U/ . ." MHz" CR
." choose your baudrate:" CR
."  0 --> 6 MBds" CR
."  1 --> 5 MBds" CR
."  2 --> 4 MBds" CR
."  3 --> 2457600 Bds" CR
."  4 --> 921600 Bds" CR
."  5 --> 460800 Bds" CR
."  6 --> 230400 Bds" CR
."  7 --> 115200 Bds" CR
."  8 --> 38400 Bds" CR
."  9 --> 19200 Bds" CR
."  A --> 9600 Bds" CR
." other --> abort" CR
." your choice: "
KEY

CASE
#48 OF  ." 6 MBds"
        R> CASE
            #24000 OF $4 $0
                   ENDOF
            24000 <   
            IF OVR_BAUDS
            THEN BAD_MHz
        ENDCASE
    ENDOF
#49 OF  ." 5 MBds"
        R> CASE
            #24000 OF $4 $EE00  ENDOF
            #16000 OF $3 $2100  ENDOF
            16000 <   
            IF OVR_BAUDS
            THEN BAD_MHz
        ENDCASE
    ENDOF
#50 OF  ." 4 MBds"
        R> CASE
            #24000 OF $6 $0     ENDOF
            #16000 OF $4 $0     ENDOF
            16000 <   
            IF OVR_BAUDS
            THEN BAD_MHz
        ENDCASE
    ENDOF
#51 OF  ." 2457600 Bds"
        R> CASE
            #24000  OF $9 $DD00 ENDOF
            #16000  OF $6 $AA00 ENDOF
            #8000   OF $3 $4400 ENDOF
            8000 <   
            IF OVR_BAUDS
            THEN BAD_MHz
        ENDCASE
    ENDOF
#52 OF  ." 921600 Bds"
        R> CASE
            #24000  OF $1 $00A1     ENDOF
            #16000  OF $11 $4A00    ENDOF
            #8000   OF $8 $D600     ENDOF
            #4000   OF $4 $4900     ENDOF
            4000 <   
            IF OVR_BAUDS
            THEN BAD_MHz
        ENDCASE
    ENDOF
#53 OF  ." 460800 Bds"
        R> CASE
            #24000  OF $6 $0001     ENDOF
            #16000  OF $2 $BB21     ENDOF
            #8000   OF $11 $4A00    ENDOF
            #4000   OF $8 $D600     ENDOF
            4000 <   
            IF OVR_BAUDS
            THEN BAD_MHz
        ENDCASE
    ENDOF
#54 OF  ." 230400 Bds"
        R> CASE
            #24000  OF $3 $0241     ENDOF
            #16000  OF $4 $5551     ENDOF
            #8000   OF $2 $BB21     ENDOF
            #4000   OF $11 $4A00    ENDOF
            #1000   OF $4 $4900     ENDOF
            BAD_MHz
        ENDCASE
    ENDOF
#55 OF  ." 115200 Bds"
        R> CASE
            #24000  OF $0D $4901    ENDOF
            #16000  OF $8 $F7A1     ENDOF
            #8000   OF $4 $5551     ENDOF
            #4000   OF $2 $BB21     ENDOF
            #1000   OF $8 $D600     ENDOF
            BAD_MHz
        ENDCASE
    ENDOF
#56 OF  ." 38400 Bds"
        R> CASE
            #24000  OF $27 $0011    ENDOF
            #16000  OF $1A $D601    ENDOF
            #8000   OF $0D $4901    ENDOF
            #4000   OF $6 $2081     ENDOF
            #1000   OF $1 $00A1     ENDOF
            BAD_MHz
        ENDCASE
    ENDOF
#57 OF  ." 19200 Bds"
        R> CASE
            #24000  OF $4E $0021    ENDOF
            #16000  OF $34 $4911    ENDOF
            #8000   OF $1A $D601    ENDOF
            #4000   OF $0D $4901    ENDOF
            #1000   OF $3 $0241     ENDOF
            BAD_MHz
        ENDCASE
    ENDOF
#65 OF  ." 9600 Bds"
        R> CASE
            #24000  OF $9C $0041    ENDOF
            #16000  OF $68 $D621    ENDOF
            #8000   OF $34 $4911    ENDOF
            #4000   OF $1A $D601    ENDOF
            #1000   OF $6 $2081     ENDOF
            BAD_MHz
        ENDCASE
    ENDOF
    ." abort" CR ABORT
ENDCASE
$1804 !
$1802 !
CR ESC [7m
." Change baudrate in Teraterm, save its setup, then reset target."
;

CHNGBAUD 
