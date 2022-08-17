\ fibonacci.4th


: (
$29 WORD DROP
; IMMEDIATE
    \


CODE 1-
SUB #1,R14
MOV @R13+,R0
ENDCODE
    \

CODE 2-
SUB #2,R14
MOV @R13+,R0
ENDCODE
    \


: BENCHME ( xt n -- ) 
  DUP >R 
  0 DO DUP EXECUTE LOOP DROP
  7 EMIT \ BEEP 
  CR R> . ." Iterations." CR ; 



: fib1 ( n1 -- n2 )
    dup 2 < if drop 1 exit then
    dup  1- recurse 
    swap 2- recurse  + ;
    \

: fib1-bench 20 0 do i fib1 drop loop ;
    \

: fib2 ( n1 -- n2 )                                                                
   0 1 rot 0 do 
      over + swap loop 
   drop ;
    \

: fib2-bench 1000 0 do i fib2 drop loop ;
    \


( 2017-09-15)
( DTC=1,  MSP430FR4133 8MHz --> 50s )
' FIB1-BENCH 100 BENCHME