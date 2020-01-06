
; ------------
; CHNGBAUD.4th
; ------------

PWR_STATE

[UNDEFINED] SWAP [IF]
CODE SWAP
MOV @R15,R10
MOV R14,0(R15)
MOV R10,R14
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

[UNDEFINED] 0= [IF]
CODE 0=
SUB #1,R14
SUBC R14,R14
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

[UNDEFINED] BEGIN [IF]
CODE BEGIN
    MOV #$402C,R0
ENDCODE IMMEDIATE

CODE UNTIL
    MOV #$4042,R9
BW1 ADD #4,&$1DC6
    MOV &$1DC6,R10
    MOV R9,-4(R10)
    MOV R14,-2(R10)
    MOV @R15+,R14
    MOV @R13+,R0
ENDCODE IMMEDIATE

CODE AGAIN
MOV #$403E,R9
GOTO BW1
ENDCODE IMMEDIATE

: WHILE
POSTPONE IF SWAP
; IMMEDIATE

: REPEAT
POSTPONE AGAIN POSTPONE THEN
; IMMEDIATE
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

[UNDEFINED] R@ [IF]
CODE R@
SUB #2,R15
MOV R14,0(R15)
MOV @R1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] DROP [IF]
CODE DROP
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] ?DUP [IF]
CODE ?DUP
CMP #0,R14
0<> IF
    SUB #2,R15
    MOV R14,0(R15)
THEN
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

[UNDEFINED] - [IF]
CODE -
SUB @R15+,R14
XOR #-1,R14
ADD #1,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] UM/MOD [IF]
CODE UM/MOD
    PUSH #DROP
    MOV #$4074,R0
ENDCODE
[THEN]

[UNDEFINED] ESC" [IF]
: ESC" $1B POSTPONE LITERAL POSTPONE EMIT POSTPONE S" POSTPONE TYPE ; IMMEDIATE
[THEN]

: BAD_MHz
$20 EMIT 1 ABORT" only for 1,4,8,16,24 MHz MCLK!"
;

: OVR_BAUDS
$20 EMIT ESC" [7m"
." with MCLK = " $1806 @ 0 1000 UM/MOD . DROP
1 ABORT" MHz? don't dream!"
;

: <> = 0= ;

: CHNGBAUD
PWR_STATE
ECHO
42
0 DO CR LOOP

ESC" [1J"
ESC" [H"

$1806 @ >R
." target MCLK = " R@ 0 1000 UM/MOD . ." MHz" DROP CR
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

#48 - ?DUP 0=
IF  ." 6 MBds"
    R@ #24000 <
    IF  OVR_BAUDS THEN
    R@ #24000 <>
    IF  BAD_MHz  THEN
    $4
    $0
ELSE 1 - ?DUP 0=
    IF  ." 5 MBds"
        R@ #16000 <
        IF  OVR_BAUDS THEN
        R@ #16000 =
        IF  $3
            $2100
        ELSE R@ #24000 <>
            IF  BAD_MHz  THEN
            $4
            $EE00
        THEN
    ELSE 1 - ?DUP 0=
        IF  ." 4 MBds"
            R@ #16000 <
            IF  OVR_BAUDS THEN
            R@ #16000 =
                IF  $4 $0
                ELSE R@ #24000 <>
                    IF  BAD_MHz  THEN
                    $6 $0
                THEN
        ELSE 1 - ?DUP 0=
            IF  ." 2457600 Bds"
                R@ #8000 <
                IF  OVR_BAUDS THEN
                R@ #8000 =
                IF  $3 $4400
                ELSE R@ #16000 =
                    IF  $6 $AA00
                    ELSE R@ #24000 <>
                        IF  BAD_MHz  THEN
                        $9 $DD00
                    THEN
                THEN
            ELSE 1 - ?DUP 0=
                IF  ." 921600 Bds"
                    R@ #4000 <
                    IF  OVR_BAUDS THEN
                    R@ #4000 =
                    IF  4 $4900
                    ELSE R@ #8000 =
                        IF  8 $D600
                        ELSE R@ #16000 =
                            IF  $11 $4A00
                            ELSE R@ #24000 <>
                                IF  BAD_MHz  THEN
                                $1 $00A1
                            THEN
                        THEN
                    THEN
                ELSE 1 - ?DUP 0=
                    IF  ." 460800 Bds"
                        R@ #4000 <
                        IF  OVR_BAUDS THEN
                        R@ #4000  =
                        IF  8 $D600
                        ELSE R@ #8000  =
                            IF $11 $4A00
                            ELSE R@ #16000 =
                                IF $2 $BB21
                                ELSE R@ #24000 <>
                                    IF  BAD_MHz  THEN
                                    $6 $0001
                                THEN
                            THEN
                        THEN
                    ELSE 1 - ?DUP 0=
                        IF  ." 230400 Bds"
                            R@ #1000 <
                            IF  OVR_BAUDS THEN
                            R@ #1000 =
                            IF  4 $4900
                            ELSE R@ #4000  =
                                IF $11 $4A00
                                ELSE R@ #8000  =
                                    IF  2 $BB21
                                    ELSE R@ #16000 =
                                        IF  4 $5551
                                        ELSE R@ #24000 <>
                                            IF  BAD_MHz  THEN
                                            3 $0241
                                        THEN
                                    THEN
                                THEN
                            THEN
                        ELSE 1 - ?DUP 0=
                            IF  ." 115200 Bds"
                                R@ #1000  =
                                IF  8 $D600
                                ELSE R@ #4000  =
                                    IF  2 $BB21
                                    ELSE R@ #8000  =
                                        IF  4 $5551
                                        ELSE R@ #16000 =
                                            IF  8 $F7A1
                                            ELSE R@ #24000 <>
                                                IF  BAD_MHz  THEN
                                                $0D $4901
                                            THEN
                                        THEN
                                    THEN
                                THEN
                            ELSE 1 - ?DUP 0=
                                IF  ." 38400 Bds"
                                    R@ #1000  =
                                    IF  $1  $00A1
                                    ELSE R@ #4000  =
                                        IF  $6  $2081
                                        ELSE R@ #8000  =
                                            IF  $0D $4901
                                            ELSE R@ #16000 =
                                                IF  $1A $D601
                                                ELSE R@ #24000 <>
                                                    IF  BAD_MHz  THEN
                                                    $27 $0011
                                                THEN
                                            THEN
                                        THEN
                                    THEN
                                ELSE 1 - ?DUP 0=
                                    IF  ." 19200 Bds"
                                        R@ #1000  =
                                        IF  $3  $0241
                                        ELSE R@ #4000  =
                                            IF  $0D $4901
                                            ELSE R@ #8000  =
                                                IF  $1A $D601
                                                ELSE R@ #16000 =
                                                    IF  $34 $4911
                                                    ELSE R@ #24000 <>
                                                        IF  BAD_MHz  THEN
                                                        $4E $0021
                                                    THEN
                                                THEN
                                            THEN
                                        THEN
                                    ELSE 8 - ?DUP 0=
                                        IF  ." 9600 Bds"
                                            R@ #1000  =
                                            IF  $6  $2081
                                            ELSE R@ #4000  =
                                                IF  $1A $D601
                                                ELSE R@ #8000  =
                                                    IF  $34 $4911
                                                    ELSE R@ #16000 =
                                                        IF  $68 $D621
                                                        ELSE R@ #24000 <>
                                                            IF  BAD_MHz  THEN
                                                            $9C $0041
                                                        THEN
                                                    THEN
                                                THEN
                                            THEN
                                        ELSE
                                            ." abort" CR ABORT
                                        THEN
                                    THEN
                                THEN
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
THEN
$1804 !
$1802 !
R> DROP
CR ESC" [7m"
." Change baudrate in Teraterm, save its setup, then reset target."
;

CHNGBAUD 
