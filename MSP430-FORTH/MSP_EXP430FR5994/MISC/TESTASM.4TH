
; -----------------------------------------------------------------------
; TEST_ASM.4th
; -----------------------------------------------------------------------

CODE TESTPUSHM
            MOV     #22222,R8
            MOV     #3,R9
            MOV     #2,R10
            MOV     #1,R11
            MOV     #0,R12

            PUSHM   #4,R13
            POPM    #4,R13
            SUB     #10,R15
            MOV     R14,8(R15)
            MOV     R12,6(R15)
            MOV     R11,4(R15)
            MOV     R10,2(R15)
            MOV     R9,0(R15)
            MOV     R8,R14
            RRAM    #1,R14
            RLAM    #2,R14
            RRCM    #1,R14
            RRUM    #1,R14
            COLON
            space . . . . .
            ;

TESTPUSHM  ; you should see 11111 3 2 1 0 -->

CODE TESTPOPM
            JMP TESTPUSHM
ENDCODE


TESTPOPM  ; you should see 11111 3 2 1 0 -->



CODE TEST1

            MOV &BASE,&BASE
            CMP #%10,&BASE
0<> IF      MOV #2,&BASE
ELSE        MOV #$0A,&BASE
THEN        
            COLON
            BASE @ U.
            ;


: TEST2
            BASE @ U.
            HI2LO


            CMP #2, &BASE
0<> IF      MOV #2, &BASE
ELSE        MOV #10,&BASE
THEN
            MOV @R1+,R13
            MOV @R13+,R0
ENDCODE


CODE TEST3
            CMP #2, &BASE
0<> IF      MOV #2, &BASE
ELSE        MOV #10,&BASE
THEN        COLON
            BASE @  U.
;



: TEST5
            SPACE
            HI2LO
            SUB #2,R15
            MOV R14,0(R15)
            MOV #%1010,R14
BEGIN       SUB #$0001,R14
            LO2HI

            DUP U.
            HI2LO
            CMP #0,R14
0= UNTIL    MOV @R15+,R14
            MOV @R1+,R13
            MOV @R13+,R0
ENDCODE

TEST5  ; you should see :  9 8 7 6 5 4 3 2 1 0 -->



: BYTES_TABLE_IDX
CREATE 
0 DO I C,
LOOP
DOES>
+
;

8 BYTES_TABLE_IDX BYTES_TABLE

2 BYTES_TABLE C@ . ; you should see 2 -->


VARIABLE BYTES_TABLE1

$0201 BYTES_TABLE1 !

CODE IDX_TEST1
    MOV.B   BYTES_TABLE1(R14),R14
COLON
    U. 
;      

0 IDX_TEST1     ; you should see 1 -->

CODE TEST6
            MOV 0(R15),0(R15)
            MOV @R13+,R0
ENDCODE


1 TEST6 .       ; you should see 1 -->





CREATE TABLE0
0 C,
1 C,
2 C,
3 C,


CREATE TABLE10
$10 C,
$11 C,
$12 C,
$13 C,



CREATE TABLE20
$20 C,
$21 C,
$22 C,
$23 C,


CREATE TABLE


TABLE 2 - CONSTANT PFA_TABLE


CODE REDIRECT       ; <table> --    redirects TABLE to argument <table>    
MOV R14,&PFA_TABLE
MOV @R15+,R14
MOV @R13+,R0
ENDCODE


CODE REDIRECT0      ; --            redirects TABLE to TABLE0        
MOV #TABLE0,&PFA_TABLE
MOV @R13+,R0
ENDCODE


CODE REDIRECT10     ; --            redirects TABLE to TABLE10        
MOV #TABLE10,&PFA_TABLE
MOV @R13+,R0
ENDCODE


CODE REDIRECT20     ; --            redirects TABLE to TABLE20        
MOV #TABLE20,&PFA_TABLE
MOV @R13+,R0
ENDCODE


' TABLE0 10 DUMP

' TABLE10 10 DUMP

' TABLE20 10 DUMP


TABLE0 REDIRECT TABLE 10 DUMP

TABLE10 REDIRECT TABLE 10 DUMP

TABLE20 REDIRECT TABLE 10 DUMP


REDIRECT0 TABLE 10 DUMP

REDIRECT10 TABLE 10 DUMP

REDIRECT20 TABLE 10 DUMP


TABLE0 PFA_TABLE ! TABLE 10 DUMP

TABLE10 PFA_TABLE ! TABLE 10 DUMP

TABLE20 PFA_TABLE ! TABLE 10 DUMP




; -----------------------------------------------------------------------
; create a primary DEFERred assembly word
; -----------------------------------------------------------------------

DEFER TRUC              ; here, TRUC is a secondary DEFERred word (i.e. without BODY)


CODENNM                 ; leaves its execution address (CFA) on stack
    SUB #2,R15
    MOV R14,0(R15)
    MOV @R13+,R0
ENDCODE 
DUP . IS TRUC         ; TRUC becomes a primary DEFERred word
                        ; with its default action (DUP) located at its BODY addresse.

TRUC .                  ; display R14 value -->


' TRUC >BODY IS TRUC    ; TRUC is reinitialzed with its default action


TRUC .                  ; display R14 value --> 





