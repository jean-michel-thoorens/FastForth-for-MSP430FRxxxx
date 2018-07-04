\ PRIMES.4th

PWR_STATE
: PRIMES
\    2 SWAP 2 . 3 . 5
    2 SWAP 2 4 U.R 3 4 U.R 5
    DO DUP DUP * I
        <  IF 1+ THEN
        1 OVER 1+ 3
        DO J I MOD
        0= IF 1- LEAVE THEN
        2 +LOOP
\        IF I . THEN
        IF I 4 U.R  THEN
    2 +LOOP
    DROP ;

\ 1000 PRIMES  : display prime numbers up to 1000
\ FAST FORTH for MSP430FR5969 @16MHz + TERATERM @921600Bds : 0.13 s

: TEST \ 1.3s @ 16 MHz
10 0 DO 
    CR
    1000 PRIMES
LOOP ;

TEST 