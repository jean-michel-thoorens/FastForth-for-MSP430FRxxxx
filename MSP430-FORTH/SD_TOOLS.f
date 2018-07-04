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

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4
\ example : PUSHM IP,Y
\
\ POPM  order :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ FORTH conditionnals:  unary{ 0= 0< 0> }, binary{ = < > U< }

\ ASSEMBLER conditionnal usage with IF UNTIL WHILE  S<  S>=  U<   U>=  0=  0<>  0>=

\ ASSEMBLER conditionnal usage with ?JMP ?GOTO      S<  S>=  U<   U>=  0=  0<>  <0
    \

PWR_STATE
    \
[DEFINED] {SD_TOOLS} [IF] {SD_TOOLS} [THEN]     \ remove {SD_TOOLS} if outside core 
    \
[DEFINED] ASM [DEFINED] LOAD" AND [UNDEFINED] {SD_TOOLS} AND [IF] \ "
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
    MOV     &CurFATsector,0(PSP)    \ FATsectorLO
    ADD     &OrgFAT1,0(PSP)         \
    MOV     #0,TOS                  \ FATsectorHI = 0
    JMP     SECTOR                  \ jump to a defined word
ENDCODE
\ ----------------------------------\
    \

\ display first sector of a Cluster
\ ----------------------------------\
CODE CLUSTER                        \ cluster.  --        don't forget to add decimal point to your cluster number
\ ----------------------------------\
    MOV.B &SecPerClus,W             \ 3 SecPerClus(5-1) = multiplicator
    MOV @PSP,X
    RRA W                           \ 1
    U< IF                           \ case of SecPerClus>1
        BEGIN
            ADD X,X                 \ 5 (RLA) shift one left MULTIPLICANDlo16
            ADDC TOS,TOS            \ 1 (RLC) shift one left MULTIPLICANDhi8
            RRA W                   \ 1 shift one right multiplicator
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
