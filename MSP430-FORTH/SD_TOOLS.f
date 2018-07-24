; ------------------------------------------------
; BASIC TOOLS for SD Card : DIR FAT SECTOR CLUSTER
; ------------------------------------------------

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355

\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, rEXIT,rDOVAR,rDOCON, rDODOES, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5  ,   R4   , R3, R2, R1, R0

\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15

\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack


\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }

\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=

\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  <0
    \

PWR_STATE
    \
[DEFINED] {SD_TOOLS} [IF] {SD_TOOLS} [THEN]     \ remove {SD_TOOLS} if outside core 
    \
[UNDEFINED] {SD_TOOLS} [IF] \ 
    \
MARKER {SD_TOOLS}
    \
[UNDEFINED] MAX [IF]    \ MAX and MIN are defined in {UTILITY}
    \
CODE MAX    \    n1 n2 -- n3       signed maximum
    CMP @PSP,TOS    \ n2-n1
    S<  ?GOTO FW1   \ n2<n1
BW1 ADD #2,PSP
    MOV @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
    CMP @PSP,TOS     \ n2-n1
    S<  ?GOTO BW1    \ n2<n1
FW1 MOV @PSP+,TOS
    MOV @IP+,PC
ENDCODE

[THEN]
    \

[UNDEFINED] U.R [IF]        \ defined in {UTILITY}
: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
[THEN]
    \

[UNDEFINED] AND [IF]
    \
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
    \
[THEN]
    \

[UNDEFINED] DUMP [IF]       \ defined in {UTILITY}
: DUMP                      \ adr n  --   dump memory
  BASE @ >R $10 BASE !
  SWAP $FFF0 AND SWAP
  OVER + SWAP
  DO  CR                    \ generate line
    I 7 U.R SPACE           \ generate address
      I $10 + I             \ display 16 bytes
      DO I C@ 3 U.R LOOP  
      SPACE SPACE
      I $10 + I             \ display 16 chars
      DO I C@ $7E MIN BL MAX EMIT LOOP
  $10 +LOOP
  R> BASE !
;
[THEN]
    \


\ display content of a sector
\ ----------------------------------\
CODE SECTOR                         \ sector. --     don't forget to add decimal point to your sector number
\ ----------------------------------\
    MOV     TOS,X                   \ X = SectorH
    MOV     @PSP,W                  \ W = sectorL
    CALL    &ReadSectorWX           \ W = SectorLO  X = SectorHI
COLON                               \
    <# #S #> TYPE SPACE             \ ud --            display the double number
    SD_BUF $200 DUMP CR ;           \ then dump the sector
\ ----------------------------------\
    \

\ ----------------------------------\
CODE FAT                            \ Display CurFATsector
\ ----------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \
    MOV     &OrgFAT1,0(PSP)         \
    MOV     #0,TOS                  \ FATsectorHI = 0
    JMP     SECTOR                  \ jump to a defined word
ENDCODE
\ ----------------------------------\
    \

\ display first sector of a Cluster
\ ----------------------------------\
CODE CLUSTER                        \ cluster.  --        don't forget to add decimal point to your cluster number
\ ----------------------------------\
    MOV.B &SecPerClus,W             \ SecPerClus(54321) = multiplicator
    MOV @PSP,X                      \ X = ClusterL
    RRA W                           \
    U< IF                           \ case of SecPerClus>1
        BEGIN
            ADD X,X                 \ (RLA) shift one left MULTIPLICANDlo16
            ADDC TOS,TOS            \ (RLC) shift one left MULTIPLICANDhi8
            RRA W                   \ shift one right multiplicator
        U>= UNTIL                   \ carry set
    THEN                            \
    ADD     &OrgClusters,X          \ add OrgClusters = sector of virtual cluster 0 (word size)
    MOV     X,0(PSP)      
    ADDC    #0,TOS                  \ don't forget carry
    JMP     SECTOR                  \ jump to a defined word
ENDCODE
\ ----------------------------------\
    \

\ ----------------------------------\
CODE DIR                            \ Display CurrentDir first sector
\ ----------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \           save TOS
    MOV     &DIRclusterL,0(PSP)     \
    MOV     &DIRclusterH,TOS        \
    JMP     CLUSTER                 \
ENDCODE
\ ----------------------------------\
    \
[THEN]
    \
ECHO
            ; added : FAT to DUMP first sector of FAT1 and DIR for that of current DIRectory.
            ; added : SECTOR to DUMP a sector and CLUSTER for first sector of a cluster:
            ;         include a decimal point to force 32 bits number, example : .2 CLUSTER

RST_HERE
