\ -----------------------------------------------------------------------
\ File Name TestASM.f
\ -----------------------------------------------------------------------

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433

\ MY_MSP430FR5738_1 MY_MSP430FR5738     MY_MSP430FR5948     MY_MSP430FR5948_1   
\ JMJ_BOX




ECHO

\ -----------------------------------------------------------------------
\ test CPUx instructions PUSHM, POPM, RLAM, RRAM, RRCM, RRUM
\ -----------------------------------------------------------------------
CODE TESTPUSHM
            MOV     #22222,Y
            MOV     #3,X
            MOV     #2,W
            MOV     #1,T
            MOV     #0,S
\            PUSHM   Y,IP       \ uncomment to test error (registers bad order) 
            PUSHM   IP,W        \ PUSHM order : PSP,TOS,IP,S,T,W,X,Y,rEXIT,rDOVAR,rDOCON,rDODOES
            POPM    W,IP        \ POPM order  : rDODOES,rDOCON,rDOVAR,rEXIT,Y,X,W,T,S,IP,TOS,PSP
            SUB     #10,PSP
            MOV     TOS,8(PSP)  \ save old TOS
            MOV     S,6(PSP)
            MOV     T,4(PSP)
            MOV     W,2(PSP)
            MOV     X,0(PSP)
            MOV     Y,TOS
\            RLAM    #0,TOS     \ uncomment to test error (bad shift value)
            RRAM    #1,TOS      \ 0 < shift value < 5
            RLAM    #2,TOS
            RRCM    #1,TOS
            RRUM    #1,TOS
            COLON               \ high level part of the word starts here...
            space . . . . .
            ;                   \ and finishes here.
    \
TESTPUSHM  ; you should see 11111 3 2 1 0 -->

CODE TESTPOPM
            MOV     #22222,Y
            MOV     #3,X
            MOV     #2,W
            MOV     #1,T
            MOV     #0,S
\            PUSHM   W,IP        \ uncomment to test error "out of bounds" 
            PUSHM   IP,W        \ PUSHM order : PSP,TOS,IP,S,T,W,X,Y,rEXIT,rDOVAR,rDOCON,rDODOES
            POPM    W,IP        \ POPM order  : rDODOES,rDOCON,rDOVAR,rEXIT,Y,X,W,T,S,IP,TOS,PSP
            SUB     #10,PSP
            MOV     TOS,8(PSP)  \ save old TOS
            MOV     S,6(PSP)
            MOV     T,4(PSP)
            MOV     W,2(PSP)
            MOV     X,0(PSP)
            MOV     Y,TOS
\            RLAM    #0,TOS      \ uncomment to test error "out of bounds" 
\            RLAM    #5,TOS      \ uncomment to test error "out of bounds" 
            RRAM    #1,TOS      \ 0 < shift value < 5
            RLAM    #2,TOS
            RRCM    #1,TOS
            RRUM    #1,TOS
            COLON               \ high level part of the word starts here...
            space . . . . .
            ;                   \ and finishes here.
    \
TESTPOPM  ; you should see 11111 3 2 1 0 -->



\ -----------------------------------------------------------------------
\ test symbolic branch in assembler
\ test a FORTH section encapsulated in an assembly word
\ -----------------------------------------------------------------------
CODE TEST1                  \ the word "CODE" add ASSEMBLER as CONTEXT vocabulary...

            MOV &BASE,&BASE \ to test &xxxx src operand
            CMP #%10,&BASE
0<> IF      MOV #2,&BASE    \ if base <> 2
ELSE        MOV #$0A,&BASE  \ else base = 2
THEN        
            COLON           \ tips : no "ok" displayed in start of line <==> compilation mode
            BASE @ U.       \ always display 10 !
            ;
    \

\ -----------------------------------------------------------------------
\ test a word that starts as word FORTH and ends as assembly word
\ -----------------------------------------------------------------------
: TEST2                     \ ":" starts compilation
            BASE @ U.       \ always display 10 !
            HI2LO           \ switch FORTH to ASM : compile one word (next address)
                            \                       add vocabulary ASSEMBLER as CONTEXT vocabulary
                            \                       switch in interpret mode
            CMP #2, &BASE
0<> IF      MOV #2, &BASE   \ if variable system BASE <> 2
ELSE        MOV #10,&BASE   \ else (BASE = 2)
THEN
\           MOV #EXIT,PC    \ to pair with ":" i.e. to restore IP saved by : then execute NEXT. 
\ but even compile two words, it's better to compile an inline EXIT :
            MOV @RSP+,IP    \ restore IP
            MOV @IP+,PC     \ = NEXT
ENDCODE                     \ ends assembler : remove vocabulary ASSEMBLER from CONTEXT
    \

\ -----------------------------------------------------------------------
\ test a word that starts as assembly word and ends as FORTH word
\ -----------------------------------------------------------------------
CODE TEST3                  \ "CODE" starts assembler, i.e. add ASSEMBLER as CONTEXT vocabulary
            CMP #2, &BASE
0<> IF      MOV #2, &BASE   \ if variable system BASE <> 2
ELSE        MOV #10,&BASE   \ else (BASE = 2)
THEN        COLON           \
            BASE @  U.      \ always display 10 !
;                           \
    \


\ -----------------------------------------------------------------------
\ test an assembly jump spanning a section written in FORTH
\ -----------------------------------------------------------------------
: TEST5
            SPACE
            HI2LO
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #%1010,TOS  \ init count = 10
BEGIN       SUB #$0001,TOS
            LO2HI
                            \ IP is already saved by word ":"
            DUP U.          \ display count
            HI2LO
            CMP #0,TOS
0= UNTIL    MOV @PSP+,TOS
\           MOV #EXIT,PC    \ to pair with ":" i.e. to restore IP saved by : then execute NEXT. 
            MOV @RSP+,IP    \ restore IP
            MOV @IP+,PC     \ = NEXT
ENDCODE
    \
TEST5  ; you should see :  9 8 7 6 5 4 3 2 1 0 -->
    \

\ -----------------------------------------------------------------------
\ tests indexing address
\ -----------------------------------------------------------------------

: TABLE
CREATE 
0 DO I C,
LOOP
DOES>
+
;

8 TABLE BYTES_TABLE
    \
2 BYTES_TABLE C@ . ; you should see 2 -->
\


VARIABLE BYTES_TABLE1

$0201 BYTES_TABLE1 !              \ words written in memory are little endian !

CODE IDX_TEST1                     \ index -- value
    MOV.B   BYTES_TABLE1(TOS),TOS  \ -- value
COLON
    U. 
;      

0 IDX_TEST1     ; you should see 1 -->

CODE TEST6
            MOV 0(PSP),0(PSP)  \
            MOV @IP+,PC
ENDCODE


1 TEST6 .       ; you should see 1 -->


\ -----------------------------------------------------------------------
\ tests behaviour of assembly error 
\ -----------------------------------------------------------------------
\ R16 causes an error, assembler context is aborted and the word TEST7 is "hidden".

; CODE TEST7
;            MOV 0(PSP),0(R16)  ; display an error "out of bounds" -->






