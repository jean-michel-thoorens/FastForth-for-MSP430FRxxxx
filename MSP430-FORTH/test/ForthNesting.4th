\ ForthNesting.4th

PWR_STATE

: bottom ;                                                                         
: 1st bottom bottom ;  : 2nd 1st 1st ;      : 3rd 2nd 2nd ;                        
: 4th 3rd 3rd ;        : 5th 4th 4th ;      : 6th 5th 5th ;                        
: 7th 6th 6th ;        : 8th 7th 7th ;      : 9th 8th 8th ;                        
: 10th 9th 9th ;       : 11th 10th 10th ;   : 12th 11th 11th ;                     
: 13th 12th 12th ;     : 14th 13th 13th ;   : 15th 14th 14th ;                     
: 16th 15th 15th ;     : 17th 16th 16th ;   : 18th 17th 17th ;                     
: 19th 18th 18th ;     : 20th 19th 19th ;   : 21th 20th 20th ;                     
: 22th 21th 21th ;     : 23th 22th 22th ;   : 24th 23th 23th ;                     
: 25th 24th 24th ;                                                                 
    \
: 32million   CR ." 32 million nest/unnest operations" 25th ;                      
:  1million   CR ."  1 million nest/unnest operations" 20th ;                      
    \
: (
$29 WORD DROP
; IMMEDIATE
    \

( 2017-09-15)
( 32million, DTC=1,  8 MHz --> 208s )
( 32million, DTC=2,  8 MHz --> 186s )
( 32million, DTC=3,  8 MHz --> 150s )
( 32million, DTC=1, 16 MHz --> 104s )
( 32million, DTC=2, 16 MHz --> 94s  )
( 32million, DTC=3, 16 MHz --> 80s  )
    \

32million 7 EMIT  \ BEEP at end