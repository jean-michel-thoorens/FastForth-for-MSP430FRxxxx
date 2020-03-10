
; -----------------------------------------------------
; VALUE.4th for MSP_EXP430FR5994
; -----------------------------------------------------

PWR_STATE

: VALUE
CREATE ,
DOES> 
HI2LO
MOV @R1+,R13
BIT #$400,R2
0= IF
    MOV #@,R0
THEN 
BIC #$400,R2
MOV #!,R0
ENDCODE

: 2VALUE
CREATE , ,
DOES>
HI2LO
MOV @R1+,R13
BIT #$400,R2
0= IF
   MOV #2@,R0
THEN 
BIC #$400,R2
MOV #2!,R0
ENDCODE

CODE TO
BIS #$400,R2
MOV @R13+,R0
ENDCODE

PWR_HERE
