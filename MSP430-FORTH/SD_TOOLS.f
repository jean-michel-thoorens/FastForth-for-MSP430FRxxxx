; ------------------------------------------------------------------------
; BASIC TOOLS for SD Card : {DIR FAT SECTOR CLUSER} DUMP ; include UTILITY
; ------------------------------------------------------------------------

\ Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
\ Copyright (C) <2017>  <J.M. THOORENS>
\
\ This program is free software: you can redistribute it and/or modify
\ it under the terms of the GNU General Public License as published by
\ the Free Software Foundation, either version 3 of the License, or
\ (at your option) any later version.
\
\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU General Public License for more details.
\
\ You should have received a copy of the GNU General Public License
\ along with this program.  If not, see <http://www.gnu.org/licenses/>.

\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4
\ example : PUSHM IP,Y
\
\ POPM  order :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before GOTO ?GOTO     : S< S>= U< U>= 0= 0<> <0 

\ FORTH conditionnal usage after IF UNTIL WHILE : 0= 0< = < > U<




\ ECHO      ; if an error occurs, uncomment this line before new download to find it.

    \

CODE ?          \ adr --            display the content of adr
    MOV @TOS,TOS
    MOV #U.,PC  \ goto U.
ENDCODE
    \

CODE SP@        \ -- SP
    SUB #2,PSP
    MOV TOS,0(PSP)
    MOV PSP,TOS
    MOV @IP+,PC
ENDCODE

: .S                \ --            print <number> of cells and stack contents if not empty
$3C EMIT           \ --            char "<"
DEPTH .
8 EMIT              \               backspace
$3E EMIT SPACE     \               char ">"
SP@  PSTACK OVER OVER U<    \
IF  2 -
    DO I @ U.
    -2 +LOOP
ELSE
    DROP DROP
THEN
;
    \

: WORDS                             \ --            list all words in all dicts in CONTEXT.

\ vvvvvvvv   may be skipped    vvvvvvvv
BASE @                              \ -- BASE
#10 BASE !
CR ."    "
INI_THREAD @ DUP
1 = IF DROP ." monothread"
    ELSE . ." threads"
    THEN ."  vocabularies"
BASE !                              \ --
\ ^^^^^^^^   may be skipped    ^^^^^^^^

CONTEXT                             \ -- CONTEXT
BEGIN                               \                                       search dictionnary
    DUP 
    2 + SWAP                        \ -- CONTEXT+2 CONTEXT
    @ ?DUP                          \ -- CONTEXT+2 (VOC_BODY VOC_BODY or 0)
WHILE                               \ -- CONTEXT+2 VOC_BODY                  dictionnary found
CR ."    "                          \
\   MOVE all threads of VOC_BODY in PAD
    DUP PAD INI_THREAD @ DUP +      \ -- CONTEXT+2 VOC_BODY  VOC_BODY PAD THREAD*2
    MOVE                            \         char MOVE

    BEGIN                           \ -- CONTEXT+2 VOC_BODY
        0 DUP                       \ -- CONTEXT+2 VOC_BODY ptr MAX
\   select the MAX of NFA in threads
        INI_THREAD @ DUP + 0 DO     \         ptr = threads*2
        DUP I PAD + @               \ -- CONTEXT+2 VOC_BODY ptr MAX MAX NFAx
        U< IF 
            DROP DROP I DUP PAD + @ \ -- CONTEXT+2 VOC_BODY ptr MAX          if MAX U< NFAx replace adr and MAX
        THEN                        \ 
        2 +LOOP                     \ -- CONTEXT+2 VOC_BODY ptr MAX
        ?DUP                        \ -- CONTEXT+2 VOC_BODY ptr MAX          max NFA = 0 ? end of vocabulary ?
    WHILE                           \ -- CONTEXT+2 VOC_BODY ptr MAX
\   replace it by its LFA
        DUP                         \ -- CONTEXT+2 VOC_BODY ptr MAX MAX
        2 - @                       \ -- CONTEXT+2 VOC_BODY ptr MAX [LFA]
        ROT                         \ -- CONTEXT+2 VOC_BODY MAX [LFA] ptr
        PAD +                       \ -- CONTEXT+2 VOC_BODY MAX [LFA] thread
        !                           \ -- CONTEXT+2 VOC_BODY MAX
\   type it in 16 chars format
                DUP                 \ -- CONTEXT+2 VOC_BODY MAX MAX
            COUNT $7F AND TYPE      \ -- CONTEXT+2 VOC_BODY MAX
                C@ $0F AND          \ -- 
                $10 SWAP - SPACES   \ -- CONTEXT+2 VOC_BODY 
\   search next MAX of NFA 
    REPEAT
                                    \ -- CONTEXT+2 VOC_BODY 0
    DROP DROP                       \ -- CONTEXT+2
    CR         
\   repeat for each CONTEXT vocabulary

REPEAT                              \ -- 0
DROP                                \ --
;
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
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

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
    \

\ ----------------------------------\
\ read sector and dump it           \ sector. --            don't forget to add decimal point to your sector number (if < 65536)
\ ----------------------------------\
CODE SECT_D                         \
    MOV     TOS,X                   \ X = SectorH
    MOV     @PSP,W                  \ W = sectorL
    CALL    &ReadSectorWX           \ W = SectorLO  X = SectorHI
COLON                               \
    UD.                             \ display the sector number
    BUFFER $200 DUMP CR ;           \ then dump the sector
\ ----------------------------------\
    \

\ TIP : How to identify FAT16 or FAT32 SD_Card ?
\ 1 CLUSTER <==> FAT16 RootDIR
\ 2 CLUSTER <==> FAT32 RootDIR
\ ----------------------------------\
\ read first sector of Cluster and dump it
\ ----------------------------------\
CODE CLUST_D                        \ cluster.  --         don't forget to add decimal point to your cluster number (if < 65536)
\ ----------------------------------\
    MOV     TOS,&ClusterH           \
    MOV     @PSP,&ClusterL          \
BW1 MOV     &OrgClusters,&RES0      \ OrgClusters = sector of virtual cluster 0, word size
    MOV     #0,&RES1
    MOV     &ClusterL,&MAC32L
    MOV     &ClusterH,&MAC32H
    MOV     &SecPerClus,&OP2
    MOV     &RES0,0(PSP)            \ cluster sectorL
    MOV     &RES1,TOS               \ cluster sectorH
    JMP     SECT_D                  \ jump to a defined word
ENDCODE
\ ----------------------------------\
    \

\ dump FAT1 sector of last entry
\ ----------------------------------\
CODE FAT_D                          \ Display CurFATsector
\ ----------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \
    MOV     &FATsector,0(PSP)       \ FATsectorLO
    ADD     &OrgFAT1,0(PSP)         \
    MOV     #0,TOS                  \ FATsectorHI = 0
    JMP     SECT_D                  \ jump to a defined word
ENDCODE
\ ----------------------------------\
    \

\ dump DIR sector of opened file or first sector of current DIR by default
\ ----------------------------------\
CODE DIR_D                          \ Display DIR sector of CurrentHdl or CurrentDir sector by default 
\ ----------------------------------\
    SUB     #4,PSP                  \
    MOV     TOS,2(PSP)              \           save TOS
\ ComputeClusFrstSect               \ If Cluster = 1 ==> RootDirectory ==> SectorL = OrgRootDir
    CMP     #1,&DIRclusterL         \ clusterL = 1 ? (FAT16 specificity)
    0= IF
        CMP.B   #0,&DIRclusterH     \     clusterT = 0 ?
        0=  IF
            MOV #0,TOS              \
            MOV &OrgRootDir,0(PSP)  \ sectorL for FAT16 OrgRootDIR is done
            JMP SECT_D                
        THEN
    THEN                            \
    MOV     &DIRclusterL,&ClusterL  \
    MOV     &DIRclusterH,&ClusterH  \
    GOTO    BW1                     \ jump to the backward LABEL BW1
ENDCODE
\ ----------------------------------\
    \

ECHO
            ; added : UTILITY : ? SP@ .S WORDS MAX MIN U.R DUMP 
            ; added : FAT_D to DUMP first sector of FAT1 and DIR_D for that of current DIRectory.
            ; added : SECT_D to DUMP a sector and CLUST_D for first sector of a cluster
            ;         include a decimal point to force 32 bits number, example : 2. CLUST_D
    \
PWR_HERE    ; to protect this app against a RESET, type: RST_HERE

