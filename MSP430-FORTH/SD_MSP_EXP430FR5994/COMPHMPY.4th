; -------------------------------------------------------------------------------
; ANS complement for MSP430FRxxxx devices with hardware_MPY, to pass CORETEST.4th
; -------------------------------------------------------------------------------

CODE INVERT
            XOR #-1,R14
            MOV @R13+,R0
ENDCODE

CODE LSHIFT
            MOV @R15+,R10
            AND #$1F,R14
0<> IF
    BEGIN   ADD R10,R10
            SUB #1,R14
    0= UNTIL
THEN        MOV R10,R14
            MOV @R13+,R0
ENDCODE

CODE RSHIFT
            MOV @R15+,R10
            AND #$1F,R14
0<> IF
    BEGIN   BIC #1,R2
            RRC R10
            SUB #1,R14
    0= UNTIL
THEN        MOV R10,R14
            MOV @R13+,R0
ENDCODE

CODE 1+
            ADD #1,R14
            MOV @R13+,R0
ENDCODE

CODE 1-
            SUB #1,R14
            MOV @R13+,R0
ENDCODE

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

CODE 2*
            ADD R14,R14
            MOV @R13+,R0
ENDCODE

CODE 2/
            RRA R14
            MOV @R13+,R0
ENDCODE

CODE NIP
ADD #2,R15
MOV @R13+,R0
ENDCODE

: S>D
    DUP 0<
;

CODE UM*
MOV @R15,&$4C0
MOV R14,&$4C8
MOV &$4E4,0(R15)
MOV &$4E6,R14
MOV @R13+,R0
ENDCODE

CODE M*
MOV @R15,&$4C2
MOV R14,&$4C8
MOV &$4E4,0(R15)
MOV &$4E6,R14
MOV @R13+,R0
ENDCODE

CODE UM/MOD
    MOV @R15+,R10
    MOV @R15,R12
    MOV #16,R9
BW1 CMP R14,R10
    U< ?GOTO FW1
    SUB R14,R10
FW1
BW2 ADDC R8,R8
    SUB #1,R9
    0< ?GOTO FW1
    ADD R12,R12
    ADDC R10,R10
    U< ?GOTO BW1
    SUB R14,R10
    BIS #1,R2
    GOTO BW2
FW1 MOV R10,0(R15)
    MOV R8,R14
    MOV @R13+,R0
ENDCODE

CODE SM/REM
MOV R14,R12
MOV @R15,R11
CMP #0,R14
S< IF
    XOR #-1,R14
    ADD #1,R14
THEN
CMP #0,0(R15)
S< IF
    XOR #-1,2(R15)
    XOR #-1,0(R15)
    ADD #1,2(R15)
    ADDC #0,0(R15)
THEN
PUSHM R13,R12
LO2HI
UM/MOD
HI2LO
POPM R12,R13
CMP #0,R11
S< IF
    XOR #-1,0(R15)
    ADD #1,0(R15)
THEN
XOR R12,R11
CMP #0,R11
S< IF
    XOR #-1,R14
    ADD #1,R14
THEN
MOV @R13+,R0
ENDCODE

: FM/MOD
SM/REM
HI2LO
CMP #0,0(R15)
0<> IF
    CMP #1,R14
    S< IF
      ADD R12,0(R15)
      SUB #1,R14
    THEN
THEN
MOV @R1+,R13
MOV @R13+,R0
ENDCODE

: *
M* DROP
;

: /MOD
>R DUP 0< R> FM/MOD
;

: /
>R DUP 0< R> FM/MOD NIP
;

: MOD
>R DUP 0< R> FM/MOD DROP
;

: */MOD
>R M* R> FM/MOD
;

: */
>R M* R> FM/MOD NIP
;

CODE 2@
SUB     #2, R15
MOV     2(R14),0(R15)
MOV     @R14,R14
MOV     @R13+,R0
ENDCODE

CODE 2!
MOV     @R15+,0(R14)
MOV     @R15+,2(R14)
MOV     @R15+,R14
MOV     @R13+,R0
ENDCODE

CODE 2DUP
SUB     #4,R15
MOV     R14,2(R15)
MOV     4(R15),0(R15)
MOV     @R13+,R0
ENDCODE

CODE 2DROP
ADD     #2,R15
MOV     @R15+,R14
MOV     @R13+,R0
ENDCODE

CODE 2SWAP
MOV     @R15,R10
MOV     4(R15),0(R15)
MOV     R10,4(R15)
MOV     R14,R10
MOV     2(R15),R14
MOV     R10,2(R15)
MOV     @R13+,R0
ENDCODE

CODE 2OVER
SUB     #4,R15
MOV     R14,2(R15)
MOV     8(R15),0(R15)
MOV     6(R15),R14
MOV     @R13+,R0
ENDCODE

CODE ALIGNED
BIT     #1,R14
ADDC    #0,R14
MOV     @R13+,R0
ENDCODE

CODE ALIGN
BIT     #1,&$1DC4
ADDC    #0,&$1DC4
MOV     @R13+,R0
ENDCODE

CODE CHARS
MOV     @R13+,R0
ENDCODE

CODE CHAR+
ADD     #1,R14
MOV     @R13+,R0
ENDCODE

CODE CELLS
ADD     R14,R14
MOV     @R13+,R0
ENDCODE

CODE CELL+
ADD     #2,R14
MOV     @R13+,R0
ENDCODE

: CHAR
    BL WORD 1+ C@
;
: [CHAR]
    CHAR lit lit , ,
; IMMEDIATE

CODE +!
ADD @R15+,0(R14)
MOV @R15+,R14
MOV @R13+,R0
ENDCODE

CODE FILL
MOV @R15+,R9
MOV @R15+,R10
CMP #0,R9
0<> IF
    BEGIN
        MOV.B R14,0(R10)
        ADD #1,R10
        SUB #1,R9
    0= UNTIL
THEN
MOV @R15+,R14
MOV @R13+,R0
ENDCODE

CODE HEX
MOV     #$10,&$1DDA
MOV     @R13+,R0
ENDCODE

CODE DECIMAL
MOV     #$0A,&$1DDA
MOV     @R13+,R0
ENDCODE

: (
$29 WORD DROP
; IMMEDIATE

: .(
$29 WORD
COUNT TYPE
; IMMEDIATE

CODE SOURCE
SUB #4,R15
MOV R14,2(R15)
MOV &$1DBE,R14
MOV &$1DC0,0(R15)
MOV @R13+,R0
ENDCODE

CODE >BODY
ADD #4,R14
MOV @R13+,R0
ENDCODE

ECHO
            ; added ANS_COMPLEMENT: INVERT LSHIFT RSHIFT 1+ 1- MAX MIN 2* 2/ CHAR [CHAR] +! FILL HEX DECIMAL ( .( SOURCE >BODY
            ;                       ARITHMETIC: NIP S>D UM* M* UM/MOD SM/REM FM/MOD * /MOD / MOD */MOD */
            ;                       DOUBLE: 2@ 2! 2DUP 2DROP 2SWAP 2OVER
            ;                       ALIGMENT: ALIGNED ALIGN
            ;                       PORTABIITY: CHARS CHAR+ CELLS CELL+

PWR_HERE    ; to protect this app against a RESET, type: RST_HERE
