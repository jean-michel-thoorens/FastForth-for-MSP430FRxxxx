
; ------------
; CHNGBAUD.4th
; ------------

PWR_STATE

[UNDEFINED] CONSTANT [IF]
: CONSTANT 
DEFER
HI2LO
MOV @R1+,R13
MOV #$1285,-4(R10)
MOV R14,-2(R10)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE
[THEN]

[UNDEFINED] BL [IF]
#32 CONSTANT BL
[THEN]

[UNDEFINED] SPACE [IF]
: SPACE
BL EMIT ;
[THEN]

[UNDEFINED] R@ [IF]
CODE R@
SUB #2,R15
MOV R14,0(R15)
MOV @R1,R14
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

[UNDEFINED] UM/MOD [IF]
CODE UM/MOD
    PUSH #DROP
    MOV #<#,R9
    ADD #8,R9
    MOV R9,R0
ENDCODE
[THEN]

: MCLK.
0 1000 UM/MOD .
;

: ESC #27 EMIT ;

: BAD_MHz
    1 ABORT"  only for 1,4,8,16,24 MHz MCLK!"
;

: BAD_SPEED
SPACE ESC ." [7m"
." with MCLK = " MCLK. 1 ABORT" MHz? don't dream!"
;

: <> = 0= ;

: CHNGBAUD
PWR_STATE

42
0 DO CR LOOP

ESC ." [1J"
ESC ." [H"

$1806 @ >R
." target MCLK = " R@ MCLK. ." MHz" CR
." choose your baudrate:" CR
." 0 --> 6 MBds" CR
." 1 --> 5 MBds" CR
." 2 --> 4 MBds" CR
." 3 --> 2457600 Bds" CR
." 4 --> 921600 Bds" CR
." 5 --> 460800 Bds" CR
." 6 --> 230400 Bds" CR
." 7 --> 115200 Bds" CR
." other --> abort" CR
." your choice: "
KEY

#48 - ?DUP 0=
IF  ." 6 MBds"
    R@ #24000 <
    IF  R@ BAD_SPEED
    THEN
    R@ #24000 <>
    IF  BAD_MHz
    THEN                
    $4
    $0
ELSE 1 - ?DUP 0=
    IF  ." 5 MBds"
        R@ #16000 <
        IF  R@ BAD_SPEED
        THEN
        R@ #16000 =
        IF  $3
            $2100
        ELSE R@ #24000 <>
            IF  BAD_MHz
            THEN
            $4
            $EE00
        THEN
    ELSE 1 - ?DUP 0=
        IF  ." 4 MBds"
            R@ #16000 <
            IF  R@ BAD_SPEED
            THEN
            R@ #16000 =
                IF  $4
                    $0
                ELSE R@ #24000 <>
                    IF  BAD_MHz
                    THEN
                    $6
                    $0
                THEN
        ELSE 1 - ?DUP 0=
            IF  ." 2457600 Bds"
                R@ #8000 <
                IF  R@ BAD_SPEED
                THEN
                R@ #8000 =
                IF  $3
                    $4400
                ELSE R@ #16000 =
                    IF  $6
                        $AA00
                    ELSE R@ #24000 <>
                        IF  BAD_MHz
                        THEN
                        $9
                        $DD00
                    THEN
                THEN
            ELSE 1 - ?DUP 0=
                IF  ." 921600 Bds"
                    R@ #4000 <
                    IF  R@ BAD_SPEED
                    THEN
                    R@ #4000 =
                    IF  4
                        $4900
                    ELSE
                        R@ #8000 =
                        IF  8
                            $D600
                        ELSE R@ #16000 =
                            IF  $11
                                $4A00
                            ELSE R@ #24000 <>
                                IF  BAD_MHz
                                THEN
                                $1
                                $00A1
                            THEN
                        THEN
                    THEN
                ELSE 1 - ?DUP 0=
                    IF  ." 460800 Bds"
                        R@ #4000 <
                        IF  R@ BAD_SPEED
                        THEN
                        R@ #4000  =
                        IF  8
                            $D600
                        ELSE
                            R@ #8000  =
                            IF  17
                                $4A00
                            ELSE R@ #16000 =
                                IF  2
                                    $BB21
                                ELSE R@ #24000 <>
                                    IF  BAD_MHz
                                    THEN
                                    6
                                    $0001
                                THEN
                            THEN
                        THEN
                    ELSE 1 - ?DUP 0=
                        IF  ." 230400 Bds"
                            R@ #1000 <
                            IF  R@ BAD_SPEED
                            THEN
                            R@ #1000 =
                            IF  4
                                $4900
                            ELSE
                                R@ #4000  =
                                IF  17
                                    $4A00
                                ELSE
                                    R@ #8000  =
                                    IF  2
                                        $BB21
                                    ELSE R@ #16000 =
                                        IF  4
                                            $5551
                                        ELSE R@ #24000 <>
                                            IF  BAD_MHz
                                            THEN
                                            3
                                            $0241
                                        THEN
                                    THEN
                                THEN
                            THEN
                        ELSE 1 - ?DUP 0=
                            IF  ." 115200 Bds"
                                R@ #1000  =
                                IF  8
                                    $D600
                                ELSE
                                    R@ #4000  =
                                    IF  2
                                        $BB21
                                    ELSE
                                        R@ #8000  =
                                        IF  4
                                            $5551
                                        ELSE R@ #16000 =
                                            IF  8
                                                $F7A1
                                            ELSE R@ #24000 <>
                                                IF  BAD_MHz
                                                THEN
                                                $0D
                                                $4901
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
$1804 !
$1802 !
R> DROP
CR ESC ." [7m"
." Change baudrate in Teraterm, save its setup then reset target."
;

ECHO CHNGBAUD 
