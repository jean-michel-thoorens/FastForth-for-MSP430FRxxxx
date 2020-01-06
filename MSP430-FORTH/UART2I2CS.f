\ -*- coding: utf-8 -*-

\ Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
\ Copyright (C) <2019>  <J.M. THOORENS>
\
\ This program is free software: you can redistribute it and/or modify
\ it under the terms of the GNU General Public License as published by
\ the Free Software Foundation, either version 3 of the License, or
\ (at your option) any later version.
\
\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY\ without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU General Public License for more details.
\
\ You should have received a copy of the GNU General Public License
\ along with this program.  If not, see <http://www.gnu.org/licenses/>.
\
; ----------------------------------------------------------------------
; UART2I2CS.f
; ----------------------------------------------------------------------
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\
\ FastForth kernel compilation minimal options:
\ DTC = 2, THREADS = 16, FREQUENCY = 16
\ TERMINALBAUDRATE = 921600, TERMINAL3WIRES, TERMINAL4WIRES
\ MSP430ASSEMBLER, CONDCOMP
\
\
\     notebook                                 USB to I2C_Slave bridge                                     any I2C_slave
\ +---------------+         +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - --+
\ |               |         |   PL2303HXD               master running UART2I2CS @ 16MHz |
\ |               |         +---------------+           +--------------------------------+         +-------------------------------+
\ |               |         |               |           |                                |         |                               |
\ |   TERATERM   -o--> USB -o--> USB2UART --o--> UART --o--> FAST FORTH ---> UART2I2CS --o--> I2C -o--> FAST FORTH with kernel     |
\ |   terminal    |         |               | 921600Bds |                                |  450kHz |     option TERMINAL_I2C       |
\ |               |         +---------------+           +--------------------------------+         +-------------------------------+
\ |               |         |                                                            | 
\ +---------------+         +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - --+
\
\
\ software I2C MASTER, you can use any I/O for SDA and SCL,
\ Preferably use a couple of I/O in the interval Px0...Px3.
\ don't forget to wire 3.3k pullup resitors on SDA and SCL.


\ the LEDs TX and RX work fine, uncomment if you want.

\ Multi Master Mode work but is not tested in real word.


PWR_STATE

[DEFINED] {FF_I2C} [IF]  {FF_I2C} [THEN]

MARKER {FF_I2C}

[UNDEFINED] @ [IF]
\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- char   fetch char from memory
CODE @
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT 
: CONSTANT 
CREATE
HI2LO
MOV TOS,-2(W)           \   PFA = n
MOV @PSP+,TOS
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

$1820 CONSTANT SLAVE_ADR    \ to save I2C_Slave address in FRAM


ASM QUIT_I2C                    \ as ASM word, QUIT_I2C is hidden.
\ ------------------------------\
BW1 \   STOP I2C                \
\ \ ------------------------------\
\     BIC.B #LED2,&LED2_DIR       \ RX green led OFF
\     BIC.B #LED2,&LED2_OUT       \ RX green led OFF
\     BIC.B #LED1,&LED1_DIR       \ TX red led OFF
\     BIC.B #LED1,&LED1_OUT       \ TX red led OFF
\ \ ------------------------------\
    BIS #M_BUS,&I2CM_REN        \ reset I/O as reset state
    BIC #M_BUS,&I2CM_DIR        \
    BIS #M_BUS,&I2CM_OUT        \
    MOV #$5A88,&WDTCTL          \ stop WDT
    BIC #1,&SFRIE1              \ disable WDT int
    MOV &$FFFA,&WDT_VEC         \ [USER_NMI_vector] = COLD, restore default WDT_VEC value
    MOV &TERMINAL_INT,&TERM_VEC \ restore default TERM_VEC value (in FRAM INFO)
    MOV #WARM,X                 \
    ADD #4,X
    MOV X,-2(X)                 \ restore default WARM
\    MOV @IP+,PC                 \ quiet return without COLD
    MOV X,PC                    \ explicit return with COLD
ENDASM

ASM WDT_INT                     \ enable Alt+B when I2C_Master is sleeping
BIT #8,&TERM_STATW              \ UART break sent by TERATERM ?
0<> IF
    ADD #4,RSP                  \ remove RETI
    POPM #6,IP                  \ remove Y,X,W,T,S,IP from return stack, restore IP
    GOTO BW1                    \
THEN
RETI
ENDASM

\ \ vvvvvvvMulti-Master-Modevvvvvv\
\ ASM DO_IDLE                     \ 
\ MOV #4,W                        \ 1   wait bus idle time = 5 µs @ 16 MHz
\ BEGIN
\     BIT #8,&TERM_STATW          \ 3         break sent by TERATERM ?
\     0<> IF                      \ 2
\         ADD #2,RSP              \           remove RET
\         MOV #QUIT_I2C,PC        \           STOP I2C
\     THEN  
\     BIT.B #MSCL,&I2CM_IN        \ 3 
\     0= IF                       \ 2
\         MOV #4,W                \ 1 if SCL is LOW
\     THEN
\         BIT.B #MSDA,&I2CM_IN    \ 3
\     0= IF                       \ 2
\         MOV #4,W                \ 1 if SDA is LOW
\     THEN
\     SUB #1,W                    \ 1
\ 0= UNTIL                        \ 2
\ MOV @RSP+,PC
\ ENDASM
\ \ ^^^^^^^Multi-Master-Mode^^^^^^\


\ **************************************\
ASM TERM_INT                            \  starts with first char of line input from TERMINAL
\ **************************************\
ADD #4,RSP                              \ 1   remove RET and SR
POPM #6,IP                              \ 8   pop Y,X,W,T,S,IP
\                                       \ S = last char to RX from UART
\                                       \ T = UART RX buffer
\                                       \ W = flag NOECHO/ECHO to TERMINAL
\                                       \ X = UART RX char
\                                       \ Y = I2C TX buffer
\ --------------------------------------\
BEGIN                                   \
    BEGIN                               \
        BEGIN                           \   wait for a char or for a break
            BIT #1,&TERM_IFG            \ 3 received char ?
        0<> UNTIL                       \ 2 
BW1     MOV.B &TERM_RXBUF,X             \ 3 received char in TERMRXBUF
        MOV.B X,0(T)                    \ 3 fill I2C_input... ...buffer
        CMP.B S,X                       \ 1 char = char end = $0A ?
        0= ?GOTO FW1                    \ 2 goto out of UART RX loop
        ADD #1,T                        \ 1
        CMP.B #$0D,X                    \ 2 CR ?
    0<> WHILE                           \ 2  32 cycles loop ==> up to 2.5Mbds @ 8MHz
        CMP #0,W                        \ 1
        0= IF                           \ 2  if echo ON requested by I2C_Slave
            MOV.B X,&TERM_TXBUF         \ 3
        THEN
    REPEAT                              \ 2
    CALL &RXOFF                         \ stops UART RX after received char CR and before receive char LF
AGAIN                                   \ then take again one loop back to get LF
\ --------------------------------------\
FW1 \ END OF UART RX                    \  CR+LF ends the line input from TERMIANL
\ ======================================\ S = last char to transmit
\ ======================================\ T = last char transmitted
BW2 \ I2C MASTER TX                     \ W = bits count / delay count down
\ ======================================\ X = I2C_Address / I2C_Data
\ ======================================\ Y = buffer TX address            
\ \ --------------------------------------\
\ BIS.B #LED1,&LED1_DIR                   \ red led ON = I2C TX 
\ BIS.B #LED1,&LED1_OUT                   \ red led ON = I2C TX
\ \ --------------------------------------\
\ BW3 \ I2C_Master TX Start               \ here, SDA and SCL must be in idle state
\ --------------------------------------\
BIS.B   #MSDA,&I2CM_DIR                 \ 4 l   force SDA as output (low)
MOV.B   &SLAVE_ADR,X                    \ 1 h   X = Slave_Address
BIC.B   #1,X                            \ 1 h   Master TX
NOP3                                    \ 3 h
NOP3                                    \ 3 h
BIS.B   #MSCL,&I2CM_DIR                 \ 4 h   force SCL as output (low)
MOV S,T                                 \       
XOR #-1,T                               \ 1     set T <> S before sending I2C address 
\ --------------------------------------\
BEGIN
\   ------------------------------------\
\   I2C Master TX address/Data          \
\   ------------------------------------\
    MOV.B #8,W                          \ 1 l       prepare 8 bits address
    BEGIN                               \
        ADD.B X,X                       \ 1 l       shift one left
        U>= IF                          \ 2 l       carry set ?
            BIC.B #MSDA,&I2CM_DIR       \ 4 l       yes : SDA as input  ==> SDA high because pull up resistor
        ELSE                            \ 2 l
            BIS.B #MSDA,&I2CM_DIR       \ 4 l       no  : SDA as output ==> SDA low
            NOP2                        \ 2
        THEN                            \   l   _
        BIC.B #MSCL,&I2CM_DIR           \ 4 l _^    release SCL (high)
        BEGIN                           \           9~h/16~l
            BIT.B #MSCL,&I2CM_IN        \ 3 h       test if SCL is released
        0<> UNTIL                       \ 2 h 
\ \       vvvvvvvvMulti-Master-Modevvvvvvv\
\         BIT.B #MSDA,&I2CM_IN            \ 3 h _     test SDA
\ \       ^^^^^^^^Multi-Master-Mode^^^^^^^\
        BIS.B #MSCL,&I2CM_DIR           \ 4 h  v_   SCL as output : force SCL low
\ \       vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\         0= IF                                   \ 2 l
\             BIT.B #MSDA,&I2CM_DIR               \ 3 l
\             0= IF                               \ 2 l
\ \               --------------------------------\
\ \               collision detected              \   l collision if SDA(IN)=0 AND SDA(DIR)=0
\ \               --------------------------------\
\                 BIS.B #MSCL,&I2CM_DIR           \ 4 l release SCL first
\                 CALL #DO_IDLE                   \     wait stable idle state 
\                 GOTO BW3                        \ 2 l goto START TX
\             THEN
\         THEN
\ \       ^^^^^^^^^^^^Multi-Master-Mode^^^^^^^^^^^\
        SUB #1,W                        \ 1 l       bits count-1
    0= UNTIL                            \ 2 l
\   ------------------------------------\
    BIC.B   #MSDA,&I2CM_DIR             \ 4 l       after TX byte we must release SDA to read Ack/Nack from Slave
\   ------------------------------------\
\   I2C Master get Slave Ack/Nack       \
\   ------------------------------------\       _
    BIC.B   #MSCL,&I2CM_DIR             \ 3 l _^    release SCL (high)
    BEGIN                               \
        BIT.B #MSCL,&I2CM_IN            \ 3 h       test if SCL is released
    0<> UNTIL                           \ 2 h
    BIT.B   #MSDA,&I2CM_IN              \ 3 h _     get SDA state
    BIS.B   #MSCL,&I2CM_DIR             \ 3 h  v_   SCL as output : force SCL low
\   ------------------------------------\
0= WHILE \ 1 Slave Ack received         \ 2 l       goto THEN; out of loop if Nack
\   ------------------------------------\           
\   I2C_Master_TX_data_loop             \
\   ------------------------------------\
    CMP.B S,T                           \ 1         T = S = last char to transmit ?
0<> WHILE \ 2                           \ 2         goto beyond REPEAT; out of loop if =
    MOV.B @Y+,X                         \ 2 l       get next byte to TX
    MOV X,T                             \ 1         T = last char TX for comparaison above
REPEAT                                  \           <-- WHILE2  search "Extended control-flow patterns"... 
THEN                                    \           <-- WHILE1  ...in https://forth-standard.org/standard/rationale
\   ------------------------------------\
\ Nack or Ack on last char              \           Nack = I2C_Slave request or I2C_Slave RESET, Ack = last char has been TX
\   ------------------------------------\
    NOP3                                \ 3 l   _   delay to reach I2C tLO
    BIC.B #MSCL,&I2CM_DIR               \ 4 l _^    release SCL to enable reSTART
\ \ --------------------------------------\
\     BIC.B #LED1,&LED1_DIR               \ red led OFF = endof I2C TX 
\     BIC.B #LED1,&LED1_OUT               \ red led OFF = endof I2C TX
\ \ --------------------------------------\
\ ======================================\
\ END OF I2C MASTER TX                  \
\ ======================================\
\ ======================================\
\ I2C MASTER RX                         \
\ ======================================\
BW3 \ I2C_Master START RX               \
\ --------------------------------------\
\ le driver I2C_Master envoie START RX en boucle.
\ le test d'un break en provenance de l'UART est intégré dans cette boucle.
\ --------------------------------------\
BEGIN                                   \           I2C MASTER RX
\ --------------------------------------\
    BEGIN                               \           I2C MASTER START RX
\   ------------------------------------\
\       I2C_Master_Start_Cond           \           here, SDA and SCL must be in idle state
\       --------------------------------\
        BIS.B   #MSDA,&I2CM_DIR         \ 4 l       force SDA as output (low)
        MOV.B   &SLAVE_ADR,X            \ 1 h       X = Slave_Address
        BIS.B   #1,X                    \ 1 h       Master RX
        NOP3                            \ 3
        NOP3                            \ 3
        BIS.B   #MSCL,&I2CM_DIR         \ 4 h       force SCL as output (low)
\       --------------------------------\
\       I2C_Master_Send_address         \           may be SCL is held low by slave
\       --------------------------------\
        MOV.B   #8,W                    \ 1 l       prepare 8 bits address
        BEGIN                           \
            ADD.B X,X                   \ 1 l       shift one left
            U>= IF                      \ 2 l       carry set ?
                BIC.B #MSDA,&I2CM_DIR   \ 4 l yes : SDA as input  ==> SDA high because pull up resistor
            ELSE                        \ 2 l
                BIS.B #MSDA,&I2CM_DIR   \ 4 l no  : SDA as output ==> SDA low
                NOP2                    \ 2 l
            THEN                        \       _
            BIC.B #MSCL,&I2CM_DIR       \ 4 l _^    release SCL (high)
            BEGIN                       \
                BIT.B #MSCL,&I2CM_IN    \ 3 h       test if SCL is released
            0<> UNTIL                   \ 2 h
\ \           vvvvvvMulti-Master-Modevvvvv\
\             BIT.B #MSDA,&I2CM_IN                    \ 3 h _     test SDA
\ \           ^^^^^^Multi-Master-Mode^^^^^\
            BIS.B #MSCL,&I2CM_DIR       \ 4 h  v_   SCL as output : force SCL low
\ \           vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\             0= IF                                   \ 2 l
\                 BIT.B #MSDA,&I2CM_DIR               \ 3 l
\                 0= IF                               \ 2 l
\ \               ------------------------------------\
\ \               collision detection                 \   l collision if SDA(IN)=0 AND SDA(DIR)=0
\ \               ------------------------------------\
\                     BIS.B #MSCL,&I2CM_DIR           \ 4 l release SCL first
\                     CALL #DO_IDLE                   \     wait stable idle state 
\                     GOTO BW3                        \ 2 l goto START RX
\                 THEN
\             THEN
\ \           ^^^^^^^^^^^^Multi-Master-Mode^^^^^^^^^^^\
            SUB #1,W                    \ 1 l       bits count - 1
        0= UNTIL                        \ 2 l
\       --------------------------------\
        BIC.B   #MSDA,&I2CM_DIR         \ 4 l   _   after TX address we must release SDA to read Ack/Nack from Slave
        BIC.B   #MSCL,&I2CM_DIR         \ 3 l _^    release SCL (high)
        BEGIN                           \
            BIT.B #MSCL,&I2CM_IN        \ 3 h       test if SCL is released
        0<> UNTIL                       \ 2 h
        BIT.B   #MSDA,&I2CM_IN          \ 3 h _     get SDA
        BIS.B   #MSCL,&I2CM_DIR         \ 3 h  v_   SCL as output : force SCL low
\       --------------------------------\  
    0<> WHILE   \ Nack_On_Address       \ 2 l
\       --------------------------------\  
        NOP3                            \ 3 l       delay to reach tLO
\       --------------------------------\
\       I2C_Master Send STOP            \           after Nack_On_Address
\       --------------------------------\     _
        BIS.B #MSDA,&I2CM_DIR           \ 4 l  v_   SDA as output ==> SDA low
        NOP3                            \ 3 l   _
        BIC.B #MSCL,&I2CM_DIR           \ 4 l _^    release SCL (high)
        NOP3                            \ 3 h
        NOP3                            \ 3 h   _
        BIC.B #MSDA,&I2CM_DIR           \ 4 h _^    SDA as input  ==> SDA high with pull up resistor
\       --------------------------------\
        BIT #8,&TERM_STATW              \ 3         break sent by TERATERM ?
        0<> IF
            MOV #QUIT_I2C,PC            \ 2         STOP I2C
        THEN
\       --------------------------------\
    REPEAT                              \ 2         loop back to MASTER START RX
\ \   ------------------------------------\
\     BIS.B #LED2,&LED2_DIR               \           green led ON = I2C RX
\     BIS.B #LED2,&LED2_OUT               \           green led ON = I2C RX
\ \   ------------------------------------\
\   I2C_Master_RX_data                  \
\   ------------------------------------\
    BEGIN
        BEGIN
            MOV.B #8,W                  \ 1 l       prepare 8 bits transaction
\           ----------------------------\
            BEGIN                       \
\               ------------------------\       _
\               do SCL pulse            \ SCL _| |_
\               ------------------------\       _
                BIC.B #MSCL,&I2CM_DIR   \ 4 l _^    release SCL (high)
                BEGIN                   \           9/16~l
                BIT.B #MSCL,&I2CM_IN    \ 3 h       test if SCL is released
                0<> UNTIL               \ 2 h
                BIT.B #MSDA,&I2CM_IN    \ 3 h _     get SDA
                BIS.B #MSCL,&I2CM_DIR   \ 4 h  v_   SCL as output : force SCL low   13~
                ADDC.B X,X              \ 1 l       C <--- X(7) ... X(0) <--- SDA
                SUB #1,W                \ 1 l       count down of bits
            0= UNTIL                    \ 2 l
\           ----------------------------\
            CMP.B #8,X                  \ 1 l       $08 = char BS
\           ----------------------------\
        U>= WHILE                       \ 2 l       normal char received, comprizing BS
\           ----------------------------\
            BEGIN                       \
                BIT #2,&TERM_IFG        \ 3 l       TX buffer empty ?
            0<> UNTIL                   \ 2 l       loop if no
\           ----------------------------\   
            BIS.B #MSDA,&I2CM_DIR       \ 4 l       prepare Ack
\           ----------------------------\       _   
            BIC.B   #MSCL,&I2CM_DIR     \ 3 l _^    release SCL (high)
            BEGIN                       \
                BIT.B #MSCL,&I2CM_IN    \ 3 h       test if SCL is released
            0<> UNTIL                   \ 2 h
            MOV.B X,&TERM_TXBUF         \ 3 h _     send RX char to UART TERMINAL
            BIS.B #MSCL,&I2CM_DIR       \ 3 h  v_   SCL as output : force SCL low
\           ----------------------------\  
            BIC.B #MSDA,&I2CM_DIR       \ 4 l       before RX next byte, we must release SDA
\           ----------------------------\  
        REPEAT                          \ 2 l       loop back to I2C_Master_RX_data
\       --------------------------------\
\       Ctrl_char received              \
\       --------------------------------\ 
        CMP.B #4,X                      \ 1         
        U>= IF                          \ 2
\           ----------------------------\
            BIS.B #MSDA,&I2CM_DIR       \ 4 l       prepare Ack for $04=NOECHO,$05=ECHO
\           ----------------------------\
        THEN
\       --------------------------------\       _   
        BIC.B   #MSCL,&I2CM_DIR         \ 3 l _^    release SCL (high)
        BEGIN                           \
            BIT.B #MSCL,&I2CM_IN        \ 3 h       test if SCL is released
        0<> UNTIL                       \ 2 h
        BIT.B   #MSDA,&I2CM_IN          \ 3 h _     get SDA
        BIS.B   #MSCL,&I2CM_DIR         \ 3 h  v_   SCL as output : force SCL low
\       --------------------------------\       
    0= WHILE                            \ 2 l       if Ack sent by Master (4 >= char < 8) 
\       --------------------------------\       
        BIC.B #MSDA,&I2CM_DIR           \           before RX next byte, we must release SDA
\       --------------------------------\       
        CMP.B #4,X                      \
\       --------------------------------\       
        0= IF                           \           $04 = ctrl_char for NOECHO request
            MOV #1,&TIB_I2CADR          \           set NOECHO
        ELSE                            \           $05 = ctrl_char for ECHO request
            MOV #0,&TIB_I2CADR          \           set ECHO
        THEN
    REPEAT                              \           loop back to I2C_Master_RX_data
\   ------------------------------------\   
\   if Nack sent by Master              \           SDA is released HIGH
\   ------------------------------------\   
    CMP.B #2,X                          \ 1 l       $02 = ctrl_char for ABORT request
0= WHILE                                \ 2 l       if Ctrl_char = $02
    MOV #0,&TIB_I2CADR                  \           set echo on I2C_Master side
\   ------------------------------------\   
\   UART_ABORT                          \
\   ------------------------------------\
    CALL &RXON                          \           resume UART downloading source file
    BEGIN                               \
        BIC #UCRXIFG,&TERM_IFG          \           clear UCRXIFG ('ESC' char is lost)
        MOV &FREQ_KHZ,Y                 \           1000, 2000, 4000, 8000, 16000, 240000
        BEGIN MOV #32,X                 \           2~        <-------+ windows 10 seems very slow... ==> ((32*3)+5) = 101ms delay
            BEGIN SUB #1,X              \           1~        <---+   |
            0= UNTIL                    \           2~ 3~ loop ---+   | to refill its USB buffer
            SUB #1,Y                    \           1~                |
        0= UNTIL                        \           2~ 101~ loop -----+
        BIT #UCRXIFG,&TERM_IFG          \           4 new char in TERMRXBUF during this delay ?
    0= UNTIL                            \           2 yes, the input stream may be still active: loop back
REPEAT                                  \           loop back to I2C MASTER reSTART RX
\ --------------------------------------\
\ I2C_Master Send STOP                  \           after RX Data(s) 
\ --------------------------------------\       _
BIC.B #MSCL,&I2CM_DIR                   \ 4 l _^    release SCL (high)
NOP3                                    \ 3 h
NOP3                                    \ 3 h   _
BIC.B #MSDA,&I2CM_DIR                   \ 4 h _^    SDA as input  ==> SDA high with pull up resistor
\ \ --------------------------------------\
\ BIC.B #LED2,&LED2_DIR                   \ 4 l green led OFF = endof I2C RX
\ BIC.B #LED2,&LED2_OUT                   \ 4 l green led OFF = endof I2C RX
\ \ --------------------------------------\
\ ======================================\
\ ======================================\
\ END OF I2C MASTER RX                  \   here I2C_bus is free and Nack on Ctrl_char $00|$01 remains to be processed.
\ ======================================\
\ ======================================\
\ TERMINAL TX --> UART RX               \
\ --------------------------------------\
\ I2C_Slave KEY ctl_char $01            \ I2C_Slave request for KEY input
\ --------------------------------------\
CMP.B #1,X                              \ 1 l
\ Quand I2C_Master reçoit ce caractère de contrôle,
\ il attend un caractère en provenance de TERMINAL UART
\ et une fois ce caractère reçu reSTART TX pour l'envoyer à I2C_Slave
0= IF                                   \ 2 l
    CALL &RXON                          \ 4 l  to enable UART RX; use no registers
    MOV #TIB_I2CCNT,Y                   \ Y = input buffer for I2C_Master TX
    MOV Y,T                             \ T = input buffer for UART RX
    BEGIN                               \   wait for a char or for a break
        BIT #UCRXIFG,&TERM_IFG          \ 3 received char ?
    0<> UNTIL                           \ 2 
    MOV.B &TERM_RXBUF,X                 \ 3 X = UART RX char
    MOV.B X,0(T)                        \ 3 fill I2C_input... ...buffer
    MOV.B X,S                           \ 2 S = KEY char = last char to send with I2C_MASTER TX !
    CALL &RXOFF                         \ stops UART RX
    GOTO BW2                            \ goto I2C MASTER TX
THEN                                    \                             
\ --------------------------------------\
\ I2C_Slave ACCEPT ctrl_char $00        \ I2C_Slave requests I2C_Master to stop RX and start TX
\ --------------------------------------\
\ en début de sa routine ACCEPT, I2C_Slave envoie sur le bus I2C le caractère de contrôle $00
\ avant de s'endormir avec SLEEP
\ I2C_Master envoie NACK + STOP pour signifier la fin de la transaction.
\ --------------------------------------\
\ I2C_Slave SLEEP ctrl_char $00         \ as request to stop I2C_Master RX     
\ --------------------------------------\
\ si I2C_Slave est sorti de son sommeil par un START RX, idem.
\ --------------------------------------\
\ I2C_Master envoie un XON sur l'UART, à destination de TERMINAL
\ I2C_Master attend un flux de caractères en provenance du TERMINAL 
\     ou l'occurence d'un break qui génère la sortie du programme. 
\ les caractères reçus de TERMINAL sont stockés dans un buffer.
\ A la réception du caractère CR, I2C_Master envoie XOFF à TERMINAL
\ et refait encore un tour pour capter LF.
\ pendant ce temps, I2C_Slave est dans l'état SLEEP, le bus I2C est libre
\ --------------------------------------\
MOV #TIB_ORG,Y                          \ Y = input buffer for I2C_Master TX
MOV &TIB_I2CADR,W                       \ W = 0 if ECHO, 1 if NOECHO
MOV Y,T                                 \ T = input buffer for UART RX
MOV #$0A,S                              \ S = last char to send with I2C_MASTER TX
PUSHM #6,IP                             \ push IP,S,T,W,X,Y, as ACCEPT
MOV #SLEEP,PC                           \ execute RXON then goto dodo
ENDASM                                  \ 
\ --------------------------------------\





\ --------------------------------------\
ASM WARM_I2C                            \           replace default WARM
\ --------------------------------------\
CMP #4,&SAVE_SYSRSTIV                   \
0= IF
    MOV #QUIT_I2C,PC                    \           if <reset> STOP I2C
THEN                
    CMP #$10,&SAVE_SYSRSTIV             \
    U>= IF
        MOV #QUIT_I2C,PC                \           if other SYS failure >= $10 STOP I2C
    THEN                                \
MOV #0,&SAVE_SYSRSTIV                   \           
\ --------------------------------------\
\ init WDT timer                        \
\ --------------------------------------\
MOV #%0101_1010_0101_1111,&WDTCTL       \           start Watchdog Timer : XDTPW, WDTSSEL=VLOCLK, WDTCNTCL=1, WDTIS=2^6 (8ms)
BIS #1,&SFRIE1                          \           enable WDT
MOV #WDT_INT,&WDT_VEC                   \           replace WDT_VEC default value (COLD) by WDT_INT
\ --------------------------------------\
\ init TERMINAL UART                    \
\ --------------------------------------\
BIS #IE_TERM,&TERM_IE                   \           then enable RX interrupt for wake up on terminal input
BIS.B #TERM_BUS,&TERM_SEL               \           Configure pins TXD & RXD for TERM_UART use, otherwise no TERMINAL !
MOV #TERM_INT,&TERM_VEC                 \           replace TERM_VEC default value (TERMINAL_INT) by TERM_INT
\ --------------------------------------\
\ initialisation I2C_MASTER             \           I2CM_DIR(M_BUS) = 0,  M_BUS as input
\ --------------------------------------\
BIC #M_BUS,&I2CM_REN                    \           remove internal pullup resistors (presence of external pullup resistor 3.3k)
BIC #M_BUS,&I2CM_OUT                    \           preset SDA + SCL LOW
\ --------------------------------------\
\ activate I/O                          \           SYSRSTIV = $02 | $0E = POWER ON | SVSH threshold
\ --------------------------------------\
BIC #1,&PM5CTL0                         \           activate all previous I/O settings; if not activated, nothing works after reset !
\ ======================================\
\ ENDOF WARM part                       \
\ ======================================\
GOTO BW3                                \           goto I2C_Master START RX
ENDASM

\ ================================================================================
\ Driver UART to I2CM : this FastForth launchpad becomes an USB to I2C_Slave bridge
\ ================================================================================
\
\ I2C = 450 kHz @ MCLK = 16 MHz, better than an hardware UCB0 I2C Master !
\ I2C bus resistors pullup = 3.3k
\ type on TERMINAL "$10 UART2I2CS" to link TERMINAL with FastForth I2C_Slave at address hex $10
\
\ type Alt+B on TERATERM TERMINAL to send a break to quit, or <reset> on I2C_Master.

\ UART to I2C_Master 
CODE UART2I2CS                         \ SlaveAddress --
MOV @RSP+,IP
MOV TOS,&SLAVE_ADR                  \ save in FRAM
MOV @PSP+,TOS
MOV #WARM,X
MOV #WARM_I2C,2(X)                  \ replace WARM by WARM_I2C, so POR execute WARM_I2C
MOV X,PC                            \ execute WARM_I2C
ENDCODE

RST_HERE

; Since there is no difference in behavior whether the TERMINAL is connected to the Master
; or to a Slave, the convenient way to check which target is connected to is to execute WARM,
; because WARM displays first the decimal I2C address when TERMINAL is connected to I2C FastForth.

WARM    \ to show the target linked to TERMINAL before: no I2C Slave address 

; v---- in forthMSP430FR.asm file search "I2CSLAVEADR" value used when compiling FastForth for TERMINAL_I2C
 $10 UART2I2CS

WARM    \ to show the target linked to TERMINAL after: see the decimal I2C Slave address first.

; remember: from scite menu or in the SendSourceFileToTarget.bat file, select the good target to download UART2I2CS
;           then select the good target to download sources file to the target running FastForth I2C
;           at the specified I2C address !

;           Alt-B to quit UART2I2CS

; ready for a cluster of FastForth(s) ?
