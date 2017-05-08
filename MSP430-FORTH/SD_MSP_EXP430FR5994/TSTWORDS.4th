\ -----------------------------
\ MSP-EXP430FR5969_TSTWORDS.4th
\ -----------------------------

ECHO
PWR_HERE

\ -----------------------------------------------------------------------
\ test some assembler words and show how to mix FORTH/ASSEMBLER routines
\ -----------------------------------------------------------------------
LOAD" \misc\TestASM.4th"

\ -------------------------------------
\ here we returned in the TestWords.4th
\ -------------------------------------

\ ----------
\ LOOP tests
\ ----------
: LOOP_TEST 8 0 DO I . LOOP 
;

LOOP_TEST   \ you should see 0 1 2 3 4 5 6 7 -->


: LOOP_TEST1    \   n <LOOP_TEST1> ---

    BEGIN   DUP U. 1 -
    ?DUP
    0= UNTIL 
;


: FIND_NOTHING      \ FIND_NOTHING      --
    25000 0
    DO
    LOOP            \ 14 cycles by loop
    ABORT" 25000 x nothing = nothing..." 
;



 : FIND_TEST            \ FIND_TEST <word>     --
    BL WORD             \ -- c-addr
        50000 0 
        DO              \ -- c-addr 
            DUP   
            FIND DROP DROP
        LOOP
     FIND
     0=  IF ABORT" <-- not found !"
         ELSE ABORT" <-- found !"
         THEN 
  ;
      
\ seeking $ word, FIND jumps all words on their first character so time of word loop is 20 cycles
\ see FIND in the source file for more information
  
\ FIND_TEST <lastword> result @ 8MHz, monothread : 1,2s  

\ FIND_TEST $ results @ 8MHz, monothread, 201 words in vocabulary FORTH :
\ 27 seconds with only FORTH vocabulary in CONTEXT
\ 540 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ 2.6866 us / word, 21,49 cycles / word (for 20 cycles calculated (see FIND in source file)


\ FIND_TEST $ results @ 8MHz, 2 threads, 201 words in vocabulary FORTH :
\ 13 second with only FORTH vocabulary in CONTEXT
\ 260 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ 1,293 us / word, 10,34 cycles / word

\ FIND_TEST $ results @ 8MHz, 4 threads, 201 words in vocabulary FORTH :
\ 8 second with only FORTH vocabulary in CONTEXT
\ 160 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ 0,796 us / word, 6,37 cycles / word 

\ FIND_TEST $ results @ 8MHz, 8 threads, 201 words in vocabulary FORTH :
\ 4.66 second with only FORTH vocabulary in CONTEXT
\ 93 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ 0,4463 us / word, 3,7 cycles / word  

\ FIND_TEST $ results @ 8MHz, 16 threads, 201 words in vocabulary FORTH :
\ 2,8 second with only FORTH vocabulary in CONTEXT
\ 56 us for one search ( which gives the delay for QNUMBER in INTERPRET routine)
\ 0,278 us / word, 2,22 cycles / word  


\ --------
\ KEY test
\ --------
: KEY_TEST
    ."  type a key : "
    KEY EMIT    \ wait for a KEY, then emit it
;
\ KEY_TEST
