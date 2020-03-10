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
; UARTI2CS.f
; ----------------------------------------------------------------------
\
\ TARGET SELECTION
\ LP_MSP430FR2476
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133 (can't use LED1 because wired on UART TX)
\ MSP_EXP430FR2433  MSP_EXP430FR2355    CHIPSTICK_FR2433
\
\ software I2C MASTER, you can use any pin for SDA and SCL,
\ Preferably use a couple of pins in the interval Px0...Px3.
\ don't forget to wire 3.3k pullup resitors on pin SDA and SCL.
\
\ FastForth kernel compilation minimal options:
\ TERMINAL3WIRES, TERMINAL4WIRES
\ MSP430ASSEMBLER, CONDCOMP
\
\ driver test @ speed maxi: MCLK=24MHz
\ ------------------------------------
\
\     notebook                                  USB to I2C_Slave bridge                                     any I2C_slave
\ +---------------+          +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +            +-------------------------------+
\ |               |          i    CP2102                  master running UARTI2CS @ 24MHz i           +-------------------------------+|
\ |               |          +---------------+           +--------------------------------+          +-------------------------------+||
\ |               |          |               |           |                                |RX:1.15MHz|                               |||
\ |   TERATERM   -o--> USB --o--> USB2UART --o--> UART --o--> FAST FORTH ---> UARTI2CS  --o--> I2C --o--> FAST FORTH @ 24MHz with    ||+
\ |   terminal    |          |               | 2457600Bds|                                |TX:692kHz |   kernel option TERMINAL_I2C  |+
\ |               |          +---------------+           +--------------------------------+          +-------------------------------+
\ |               |          i                                                            i 
\ +---------------+          +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
\
\ I2C frequency = (TX+RX)/2 = 921 kHz @ MCLK=24 MHz, without any error...
\ downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Slave in 859ms.
\ downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Master in 625ms.
\
\
\ the LEDs TX and RX work fine, uncomment if you want.
\
\ Multi Master Mode works but is not tested in the real word.
\
\ les arcanes du bus I2C
\ ----------------------
\
\ le bus I2C est orienté Maître vers esclave, l'esclave ne décide de rien.
\ Cet ordre des choses permet en tout cas d'établir la liaison.
\ On placera donc le maître du côté du TERMINAL de commande et la cible FastForth côté esclave.
\ Mais une fois que la liaison est établie il faut trouver une astuce pour renverser
\ les rôles, pour que l'esclave puisse prendre le contrôle de la liaison.
\
\ Pour ce faire l'esclave envoie "servilement" des caractères de contrôle au maître,
\ et comme celui-ci obéit à un plus grand que lui, le programmeur,
\ il se fait un devoir "magistral" d'obéir à l'esclave.
\
\ Pour prendre le contrôle du maître, l'esclave émet donc 1 parmi 6 CTRL-Char:
\   CTRL-Char $00 envoyé par ACCEPT (1ère partie, avant SLEEP),
\   CTRL-Char $01 envoyé par KEY: demande d'envoi d'un caractère unique saisi sur TERMINAL,
\   CTRL-Char $02 envoyé par ABORT: demande d'abandon du fichier en cours de transmission le cas échéant,
\                                   suivi de la réception du message envoyé par ABORT,
\   CTRL-Char $03 envoyé par COLD, pour que le maître relance la connexion I2C,
\   CTRL-Char $04 envoyé par NOECHO, pour qu'il passe l'UART en mode half duplex,
\   CTRL-Char $05 envoyé par ECHO, pour qu'il rétablisse l'UART en mode full duplex.
\
\ Enfin, si le maître reçoit un caractère $FF, il considère que la liaison est coupée,
\ il envoie le reste du fichier en cours de téléchargment à la poubelle, quitte le driver
\ puis exécute COLD.
\
\ Une fois que l'esclave a envoyé le CTRL_Char $00, il s'endort, 
\ à la reception de ce CTRL_Char, le maître s'endort aussi, dans l'attente d'une nouvelle entrée TERMINAL.
\ Tant que le TERMINAL n'envoie pas de nouvelle ligne, le maître et l'esclave sont en mode SLEEP,
\ LPM0 pour le maître, LPM4 pour l'esclave.
\
\
\ le timer TB0 sert à générer une interruption 1/2 seconde
\ pour détecter un hard RESET effectué sur I2C_Slave, quand I2C_Master fait dodo, 
\ ainsi que pour effectuer le couplage dans la boucle I2C_Master RX: 
\   si X U>= 4 (I2C_WARM state) ==> un START RX à chaque 1/2s, 
\   si X U< 4 (I2C_Slave COLD|RESET|ABORT) ==> continuous repeated START RX 

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

$1820 CONSTANT SLAVE_ADR    \ CONSTANT = I2C_Slave address in FRAM

ASM QUIT_I2C                    \ as ASM word, QUIT_I2C is hidden.
\ ------------------------------\
BW1                             \
\ \ ------------------------------\
\     BIC.B #LED2,&LED2_DIR       \ RX green led OFF
\     BIC.B #LED2,&LED2_OUT       \ RX green led OFF
\     BIC.B #LED1,&LED1_DIR       \ TX red led OFF
\     BIC.B #LED1,&LED1_OUT       \ TX red led OFF
\ \ ------------------------------\
    BIS.B #SM_BUS,&I2CSM_REN    \ reset I/O as reset state
    BIC.B #SM_BUS,&I2CSM_DIR    \
    BIS.B #SM_BUS,&I2CSM_OUT    \
    MOV #$5A88,&WDTCTL          \ stop WDT
    BIC #1,&SFRIE1              \ disable WDT int
    MOV #COLD,&WDT_VEC          \ restore default WDT_VEC value
\    MOV #0,&TA0CTL              \ stop timer
\    MOV #COLD,&TA0_x_VEC        \ restore default TA0_x_VEC value
    MOV #0,&TB0CTL              \ stop timer
    MOV #COLD,&TB0_x_VEC        \ restore default TB0_x_VEC value
    MOV &TERMINAL_INT,&TERM_VEC \ restore default TERM_VEC value
    MOV #WARM,X                 \ X = CFA of WARM
    ADD #4,X                    \ X = BODY of WARM
    MOV X,-2(X)                 \ restore default WARM: BODY of WARM --> PFA of WARM
    MOV #COLD,PC                \ explicit return with COLD
ENDASM

ASM WDT_INT                     \ to enable Alt+B when I2C_Master is sleeping
BIT #8,&TERM_STATW              \ UART break sent by TERATERM ?
0<> IF
    ADD #4,RSP                  \ remove RETI
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
\     BIT.B #SM_SCL,&I2CSM_IN     \ 3 
\     0= IF                       \ 2
\         MOV #4,W                \ 1 if SCL is LOW
\     THEN
\         BIT.B #SM_SDA,&I2CSM_IN \ 3
\     0= IF                       \ 2
\         MOV #4,W                \ 1 if SDA is LOW
\     THEN
\     SUB #1,W                    \ 1
\ 0= UNTIL                        \ 2
\ MOV @RSP+,PC
\ ENDASM
\ \ ^^^^^^^Multi-Master-Mode^^^^^^\

\ wake up from LPM0 is longer with MSP30FR2xxx devices than with MSP430FR5xxx devices:
\ @ MCLK = 24MHz baudrate max = 5MBds with FR2xxx, and 6MBds with FR57xx. 
\ **************************************\
ASM TERM_INT                            \  interrupt starts on RX first char of line input from TERMINAL
\ **************************************\
ADD #4,RSP                              \ 1 remove RET and SR
\ --------------------------------------\
MOV &PAD_I2CADR,W                       \ 3 W = 0 if ECHO, 1 if NOECHO
MOV #PAD_ORG,T                          \ 2 T = input buffer for I2C_Master TX
MOV #$0D,S                              \ 2 S = last char to be RXed by UART
BEGIN                                   \
    MOV.B &TERM_RXBUF,Y                 \ 3 move char from TERM_RXBUF...
    ADD #1,T                            \ 1
    MOV.B Y,-1(T)                       \ 3 ... to buffer (PAD)
    CMP.B Y,S                           \ 1 char = CR ?
0<> WHILE                               \ 2 28 cycles loop ==> up to 2.96 Mbds @ 8MHz
    CMP #0,W                            \ 1
    0= IF                               \ 2 if echo ON requested by I2C_Slave
        BEGIN                           \   )
            BIT #2,&TERM_IFG            \ 3 > mandatory for low baudrates
        0<> UNTIL                       \ 2 )
        MOV.B Y,&TERM_TXBUF             \ 3
    THEN
    BEGIN                               \
        BIT #1,&TERM_IFG                \ 3 received char ?
    0<> UNTIL                           \ 2 
REPEAT                                  \ 2
CALL &RXOFF                             \ stops UART RX still char CR is received and before receiving char LF
BEGIN                                   \
    BIT #1,&TERM_IFG                    \ 3 char $0A received ?
0<> UNTIL                               \ 2 RX_int flag is cleared
\ --------------------------------------\
BW1                                     \   <=== Ctrl_char $01 (KEY input)
\ --------------------------------------\
MOV.B &TERM_RXBUF,S                     \ 3 S = last char (LF|KEY) ...
MOV.B S,0(T)                            \ 4 store it into buffer
\ ======================================\
\ ======================================\ S = last char to be transmitted
\ I2C MASTER TX                         \ T = last char transmitted
\ ======================================\ W = bits count
\ ======================================\ X = I2C_Address / I2C_Data           
\ \ --------------------------------------\
\ BIS.B #LED1,&LED1_DIR                   \ red led ON = I2C TX 
\ BIS.B #LED1,&LED1_OUT                   \ red led ON = I2C TX
\ \ --------------------------------------\
\ \     vvvvvvvvvvMulti-Master-Modevvvvvvv\
BW2 \ I2C_Master TX Start               \ here, SDA and SCL must be in idle state
\ \     ^^^^^^^^^^Multi-Master-Mode^^^^^^^\
BIS.B   #SM_SDA,&I2CSM_DIR              \ 3 l   force SDA as output (low)
MOV.B   &SLAVE_ADR,X                    \ 3 h   X = Slave_Address
MOV     #PAD_ORG,Y                      \ 2 h   Y = input buffer for I2C_Master TX
NOP3                                    \ 3 h
BIS.B   #SM_SCL,&I2CSM_DIR              \ 3 h   force SCL as output (low)
\ --------------------------------------\
BEGIN
\   ------------------------------------\
\   I2C Master TX address/Data          \
\   ------------------------------------\
    MOV.B #8,W                          \ 1 l       prepare 8 bits address
    BEGIN                               \
        ADD.B X,X                       \ 1 l       shift one left
        U>= IF                          \ 2 l       carry set ?
            BIC.B #SM_SDA,&I2CSM_DIR    \ 3 l       yes : SDA as input  ==> SDA high because pull up resistor
        ELSE                            \ 2 l
            BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       no  : SDA as output ==> SDA low
            NOP2                        \ 2
        THEN                            \   l   _
        BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
        BEGIN                           \           9~h/16~l
            BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       test if SCL is released (Slave RX addr/data)
        0<> UNTIL                       \ 2 h 
\ \       vvvvvvvvMulti-Master-Modevvvvvvv\
\         BIT.B #SM_SDA,&I2CSM_IN         \ 3 h _     test SDA
\ \       ^^^^^^^^Multi-Master-Mode^^^^^^^\
        BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\ \       vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\         0= IF                                   \ 2 l
\             BIT.B #SM_SDA,&I2CSM_DIR            \ 3 l
\             0= IF                               \ 2 l
\ \               --------------------------------\
\ \               collision detected              \   l collision if SDA(IN)=0 AND SDA(DIR)=0
\ \               --------------------------------\
\                 BIS.B #SM_SCL,&I2CSM_DIR        \ 4 l release SCL first
\                 CALL #DO_IDLE                   \     wait stable idle state 
\                 GOTO BW2                        \ 2 l goto START TX
\             THEN                                \
\         THEN                                    \
\ \       ^^^^^^^^^^^^Multi-Master-Mode^^^^^^^^^^^\
        SUB #1,W                        \ 1 l       bits count-1
    0= UNTIL                            \ 2 l
\   ------------------------------------\
    BIC.B #SM_SDA,&I2CSM_DIR            \ 3 l       after TX byte we must release SDA to read Ack/Nack from Slave
\   ------------------------------------\
\   I2C Master get Slave Ack/Nack       \
\   ------------------------------------\       _
    BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
\    BEGIN                               \
\        BIT.B #SM_SCL,&I2CSM_IN         \ 3 h      useless test if SCL is released (SLAVE ACK Addr/data) 
\    0<> UNTIL                           \ 2 h
    NOP3                                \ 3 h
    BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA state
    BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low
\   ------------------------------------\
0= WHILE \ 1 Slave Ack received         \ 2 l       goto THEN; out of loop if Nack
\   ------------------------------------\           
\   I2C_Master_TX_data_loop             \
\   ------------------------------------\
    CMP S,T                             \ 1         T = S = last char to transmit ? after address is sent, T = PAD_ORG <> S = any char
0<> WHILE \ 2                           \ 2         out of loop if yes
    MOV.B @Y+,X                         \ 2 l       get next byte to TX
    MOV X,T                             \ 1         T = last char TX for comparaison above
REPEAT                                  \           <-- WHILE2  search "Extended control-flow patterns"... 
THEN                                    \           <-- WHILE1  ...in https://forth-standard.org/standard/rationale
\   ------------------------------------\
\ Nack or Ack on last char              \           Nack = I2C_Slave request or I2C_Slave RESET, Ack = last char has been TX
\   ------------------------------------\
    NOP3                                \ 3 l   _   delay to reach I2C tLO
    BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL to enable reSTART
\ \ --------------------------------------\
\     BIC.B #LED1,&LED1_DIR               \   red led OFF = endof I2C TX 
\     BIC.B #LED1,&LED1_OUT               \   red led OFF = endof I2C TX
\ \ --------------------------------------\
GOTO FW1                                \   X > 4 ==> continuous repeated START RX below
\ ======================================\
\ END OF I2C MASTER TX                  \
\ ======================================\
ENDASM

ASM RX_INT
\ **************************************\
\ I2C MASTER RX                         \
\ **************************************\
ADD #4,RSP                              \ 1 remove RET and SR
\ --------------------------------------\
FW1                                     \   from TERM_INT above
\ --------------------------------------\
BW3                                     \   from I2C_WARM below
\ --------------------------------------\
\ I2C_Master START RX                   \
\ --------------------------------------\
CMP #0,&KERNEL_ADDON                    \ 3
0>= IF                                  \ 2 if LF XTAL present
    MOV #%0001_0101_0110,&TB0CTL        \ 3 (re)starts RX_timer,ACLK=VLO=8kHz,/2=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
\    MOV #%0001_0101_0110,&TA0CTL        \ 3 (re)starts RX_timer,ACLK=VLO=8kHz,/2=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
ELSE                                    \ 2
    MOV #%0001_1101_0110,&TB0CTL        \ 3 (re)starts RX_timer,ACLK=LFXTAL=32738,/8=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
\    MOV #%0001_1101_0110,&TA0CTL        \ 3 (re)starts RX_timer,ACLKLFXTAL=32768,/8=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
THEN
\ --------------------------------------\
\ le driver I2C_Master envoie START RX en boucle continue (X < 4) ou discontinue (X >= 4).
\ le test d'un break en provenance de l'UART est intégré dans cette boucle.
\ --------------------------------------\
BEGIN                                   \   I2C MASTER RX
\ --------------------------------------\
    BEGIN                               \   I2C MASTER START RX
\   ------------------------------------\
        BIT #8,&TERM_STATW              \ 3 break sent by TERATERM ?
        0<> IF                          \ 2
            MOV #QUIT_I2C,PC            \ 2 STOP I2C
        THEN
\       --------------------------------\
\       I2C_Master_Start_Cond           \   here, SDA and SCL must be in idle state
\       --------------------------------\
        BIS.B   #SM_SDA,&I2CSM_DIR      \ 3 l       force SDA as output (low)
        MOV.B   &SLAVE_ADR,Y            \ 3 h       X = Slave_Address
        BIS.B   #1,Y                    \ 1 h       Master RX
        NOP2                            \ 2
        BIS.B   #SM_SCL,&I2CSM_DIR      \ 3 h       force SCL as output (low)
\       --------------------------------\
\       I2C_Master_Send_address         \           may be SCL is held low by slave
\       --------------------------------\
        MOV.B   #8,W                    \ 1 l       prepare 8 bits address
        BEGIN                           \
            ADD.B Y,Y                   \ 1 l       shift one left
            U>= IF                      \ 2 l       carry set ?
               BIC.B #SM_SDA,&I2CSM_DIR \ 3 l yes : SDA as input  ==> SDA high because pull up resistor
            ELSE                        \ 2 l
               BIS.B #SM_SDA,&I2CSM_DIR \ 3 l no  : SDA as output ==> SDA low
               NOP2                     \ 2 l
            THEN                        \       _
            BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
\            BEGIN                       \
\                BIT.B #SM_SCL,&I2CSM_IN \ 3 h       useless test if SCL is released (SLAVE RX Addr)
\            0<> UNTIL                   \ 2 h
            NOP3                        \ 3
\ \           vvvvvvMulti-Master-Modevvvvv\
\             BIT.B #SM_SDA,&I2CSM_IN     \ 3 h _     test SDA
\ \           ^^^^^^Multi-Master-Mode^^^^^\
            BIS.B #SM_SCL,&I2CSM_DIR     \ 3 h  v_   SCL as output : force SCL low
\ \           vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\             0= IF                                   \ 2 l
\                 BIT.B #SM_SDA,&I2CSM_DIR            \ 3 l
\                 0= IF                               \ 2 l
\ \               ------------------------------------\
\ \               collision detection                 \   l collision if SDA(IN)=0 AND SDA(DIR)=0
\ \               ------------------------------------\
\                     BIS.B #SM_SCL,&I2CSM_DIR        \ 4 l release SCL first
\                     CALL #DO_IDLE                   \     wait stable idle state 
\                     GOTO BW3                        \ 2 l goto START RX
\                 THEN                                \
\             THEN                                    \
\ \           ^^^^^^^^^^^^Multi-Master-Mode^^^^^^^^^^^\
            SUB #1,W                    \ 1 l       bits count - 1
        0= UNTIL                        \ 2 l
\       --------------------------------\
\       Wait Ack/Nack on address        \
\       --------------------------------\
        BIC.B   #SM_SDA,&I2CSM_DIR      \ 3 l   _   after TX address we must release SDA to read Ack/Nack from Slave
        BIC.B   #SM_SCL,&I2CSM_DIR      \ 3 l _^    release SCL (high)
        BEGIN                           \
            BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       test if SCL is released (SLAVE TX ACK_ON_Addr)
        0<> UNTIL                       \ 2 h
        BIT.B   #SM_SDA,&I2CSM_IN       \ 3 h _     get SDA
        BIS.B   #SM_SCL,&I2CSM_DIR      \ 3 h  v_   SCL as output : force SCL low
\       --------------------------------\  
    0<> WHILE   \ Nack_On_Address       \ 2 l
\       --------------------------------\  
        NOP3                            \ 3 l       delay to reach tLO
\       --------------------------------\
\       I2C_Master Send STOP            \           after Nack_On_Address
\       --------------------------------\     _
        BIS.B #SM_SDA,&I2CSM_DIR        \ 3 l  v_   SDA as output ==> SDA low
        NOP3                            \ 3 l   _
        BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
        NOP3                            \ 3 h
        NOP3                            \ 3 h   _
        BIC.B #SM_SDA,&I2CSM_DIR        \ 3 h _^    SDA as input  ==> SDA high with pull up resistor
        CMP.B #4,X                      \           last CTRL_char <> ABORT ?
        U>= IF                          \
            MOV #SLEEP,PC               \ 4          if yes goto dodo
        THEN
    REPEAT                              \ 2
\ \   ------------------------------------\
\     BIS.B #LED2,&LED2_DIR               \           green led ON = I2C RX
\     BIS.B #LED2,&LED2_OUT               \           green led ON = I2C RX
\ \   ------------------------------------\
\   I2C_Master_RX_data                  \
\   ------------------------------------\
    BEGIN
        BEGIN
            BIC.B #SM_SDA,&I2CSM_DIR    \ 4 l       after Ack and before RX next byte, we must release SDA
            MOV.B #8,W                  \ 1 l       prepare 8 bits transaction
\           ----------------------------\
            BEGIN                       \
\              -------------------------\       _
\              do SCL pulse             \ SCL _| |_
\              -------------------------\       _
               BIC.B #SM_SCL,&I2CSM_DIR \ 3 l _^    release SCL (high)
\               BEGIN                   \           9/16~l
\               BIT.B #SM_SCL,&I2CSM_IN \ 3 h       useless test if SCL is released (SLAVE TX Data)
\               0<> UNTIL               \ 2 h
               NOP3
               BIT.B #SM_SDA,&I2CSM_IN  \ 3 h _     get SDA
               BIS.B #SM_SCL,&I2CSM_DIR \ 3 h  v_   SCL as output : force SCL low   13~
               ADDC.B X,X               \ 1 l       C <--- X(7) ... X(0) <--- SDA
               SUB #1,W                 \ 1 l       count down of bits
            0= UNTIL                    \ 2 l
\       --------------------------------\
        CMP.B #-1,X                     \ 1
        0= IF                           \ 2         received char $FF: let's consider that the slave is lost...
            MOV #2,X                    \           to do ABORT action
        THEN                            \
\       --------------------------------\
            CMP.B #8,X                  \ 1 l       $08 = char BS
        U>= WHILE                       \ 2 l       ASCII char received, from char 'BS' up to char $7F.
\           ----------------------------\
            BEGIN                       \
                BIT #2,&TERM_IFG        \ 3 l       UART TX buffer empty ?
            0<> UNTIL                   \ 2 l       loop if no
\           ----------------------------\   
            BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       prepare Ack
\           ----------------------------\       _   
            BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
            BEGIN                       \
                BIT.B #SM_SCL,&I2CSM_IN \ 3 h       test if SCL is released (SLAVE RX Ack)
            0<> UNTIL                   \ 2 h
            MOV.B X,&TERM_TXBUF         \ 3 h _     send RX char to UART TERMINAL
            BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_   SCL as output : force SCL low
        REPEAT                          \ 2 l       loop back to I2C_Master_RX_data
\       --------------------------------\
\       case of Ctrl_char received      \           here Master holds SCL low, Slave can test it: CMP #8,&TERM_STATW
\       --------------------------------\ 
        CMP.B #4,X                      \ 1         
        U>= IF                          \ 2
            0= IF                       \ 2
                MOV #1,&PAD_I2CADR      \ 3         set NOECHO if char $04
            ELSE                        \ 
                MOV #0,&PAD_I2CADR      \           set ECHO if char >$04
            THEN
            BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       prepare Ack
        THEN
\       --------------------------------\       _   
        BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
        BEGIN                           \
            BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       test if SCL is released (SLAVE RX Ack)
        0<> UNTIL                       \ 2 h
        BIT.B #SM_SDA,&I2CSM_IN         \ 3 h _     get SDA
        BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\       --------------------------------\       
    0<> UNTIL                           \ 2 l       until Nack sent by Master for CTRL-Char {$00|$01|$02|$03} 
\   ------------------------------------\   
\   Nack is sent by Master              \
\   ------------------------------------\   
    CMP.B #2,X                          \ 1 l       $02 = ctrl_char for ABORT request
U>= WHILE                               \ 2 l
\   ------------------------------------\   
\   CTRL_Char $02|$03                   \           if ABORT|COLD requests
\   ------------------------------------\
    0= IF                               \           if ctrl_char $02 = ABORT request
        MOV #0,&PAD_I2CADR              \           set echo ON I2C_Master side (I use the useless address PAD_I2CADR)
        CALL &RXON                      \           resume UART downloading source file
        BEGIN                           \
            BIC #UCRXIFG,&TERM_IFG      \           clear UCRXIFG
            MOV &FREQ_KHZ,Y             \           1000, 2000, 4000, 8000, 16000, 240000
            BEGIN MOV #32,W             \           2~        <-------+ windows 10 seems very slow...
                BEGIN SUB #1,W          \           1~        <---+   | ==> ((32*3)+5)*1000 = 101ms delay
                0= UNTIL                \           2~ 3~ loop ---+   | to refill its USB buffer
                SUB #1,Y                \           1~                |
            0= UNTIL                    \           2~ 101~ loop -----+
\           BEGIN MOV #65,W             \                  <-------+ linux with minicom seems very very slow...
\               BEGIN SUB #1,W          \                  <---+   | ==> ((65*3)+5)*1000 = 200ms delay
\               0= UNTIL                \           3~ loop ---+   | to refill its USB buffer
\               SUB #1,Y                \                          |
\           0= UNTIL                    \           200~ loop -----+
            BIT #UCRXIFG,&TERM_IFG      \           4 new char in TERMRXBUF during this delay ?
        0= UNTIL                        \           2 yes, the input stream may be still active: loop back
\    ELSE                                \           do nothing if Ctrl_char = $03
    THEN
REPEAT                                  \           loop back to I2C MASTER reSTART RX
\ --------------------------------------\   
\ CTRL_Char $00|$01                     \           if ACCEPT|KEY requests
\ --------------------------------------\
\ I2C_Master RX Send STOP               \
\ --------------------------------------\       
BIS.B #SM_SDA,&I2CSM_DIR                \ 3         before STOP, we must pull SDA low
\   ------------------------------------\       _
BIC.B #SM_SCL,&I2CSM_DIR                \ 3 l _^    release SCL (high)
NOP3                                    \ 3 h
MOV #PAD_ORG,T                          \ 2 h   _   ready to store KEY char: MOV.B S,0(T)
BIC.B #SM_SDA,&I2CSM_DIR                \ 3 h _^    SDA as input  ==> SDA high with pull up resistor
\ \ --------------------------------------\
\ BIC.B #LED2,&LED2_DIR                   \ 4 l green led OFF = endof I2C RX
\ BIC.B #LED2,&LED2_OUT                   \ 4 l green led OFF = endof I2C RX
\ \ --------------------------------------\
\ ======================================\
\ ======================================\
\ END OF I2C MASTER RX                  \   here I2C_bus is freed and Nack on Ctrl_char $FF|$00|$01 remains to be processed.
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
    BEGIN                               \   wait for a char or for a break
        BIT #UCRXIFG,&TERM_IFG          \ 3 received char ?
    0<> UNTIL                           \ 2 
    CALL &RXOFF                         \ stops UART RX
    GOTO BW1                            \ goto end of TERMINAL line input to RX KEY char to 0(T) with T = 
THEN                                    \                             
\ --------------------------------------\
\ I2C_Slave ACCEPT ctrl_char $00        \ I2C_Slave requests I2C_Master to stop RX and start TX
\ --------------------------------------\
\ en début de sa routine ACCEPT, I2C_Slave envoie sur le bus I2C le caractère de contrôle $00
\ avant de s'endormir avec SLEEP
\ I2C_Master envoie NACK + STOP pour signifier la fin de la transaction.
\ --------------------------------------\
\ et si I2C_Slave est sorti de son sommeil par un START RX, idem.
\ --------------------------------------\
MOV #SLEEP,PC                           \ execute RXON then goto dodo
\ --------------------------------------\
\ I2C_Master se réveillera au premier caractère saisi sur le TERMINAL ==> TERM_INT,
\ ou en fin du temps TxyCCR0 ==> RX_INT,
\ ou par un break opérateur ==> WDT_INT. 
ENDASM                                  \ 
\ --------------------------------------\


\ --------------------------------------\
ASM I2C_WARM                            \           replace default WARM
\ --------------------------------------\
CMP #4,&SAVE_SYSRSTIV                   \           hard RESET ?
0= IF                                   \           yes
    BIT.B #SW2,&SW2_IN                  \           SW2 pressed ? ( SW2 <> SW1 = Deep RESET)
    0= IF                               \           yes
        MOV #QUIT_I2C,PC                \           quit I2C only if SW2+RESET
    THEN                                \
THEN                                    \
CMP #$10,&SAVE_SYSRSTIV                 \
U>= IF                                  \           if SYS failure >= $10 then STOP I2C
    MOV #QUIT_I2C,PC                    \
THEN                                    \
MOV #0,&SAVE_SYSRSTIV                   \           clear SAVE_SYSRSTIV after use
\ --------------------------------------\
\ init WDT_INT                          \
\ --------------------------------------\
MOV #%0101_1010_0101_1111,&WDTCTL       \           start Watchdog Timer : XDTPW, WDTSSEL=VLOCLK, WDTCNTCL=1, WDTIS=2^6 (8ms)
BIS #1,&SFRIE1                          \           enable WDT
MOV #WDT_INT,&WDT_VEC                   \           replace WDT_VEC default value (COLD) by WDT_INT
\ --------------------------------------\
\ init RX_INT                           \           used to scan I2C_Slave hard RESET during SLEEP and to slow START RX loop
\ --------------------------------------\
MOV #$800,&TB0CCR0                      \           be careful:  RX_Int time = (2047+1)/4096 = 0.5s must be >> COLD time !
MOV #RX_INT,&TB0_x_VEC                  \
\ MOV #$800,&TA0CCR0                      \           be careful:  RX_Int time = (2047+1)/4096 = 0.5s must be >> COLD time !
\ MOV #RX_INT,&TA0_x_VEC                  \
\ --------------------------------------\
\ init UART_INT                         \
\ --------------------------------------\
MOV #TERM_INT,&TERM_VEC                 \           replace TERM_VEC default value (TERMINAL_INT) by TERM_INT
\ --------------------------------------\
\ init I2C_MASTER I/O                   \           reset state: I2CSM_DIR(SM_BUS) = 0
\ --------------------------------------\
BIC.B #SM_BUS,&I2CSM_REN                \           remove internal pullup resistors because of external 3.3k pullup resistor
BIC.B #SM_BUS,&I2CSM_OUT                \           preset SDA + SCL output LOW
\ --------------------------------------\
\ activate I/O                          \           SYSRSTIV = $02 | $0E = POWER ON | SVSH threshold
\ --------------------------------------\
BIC #1,&PM5CTL0                         \           activate all previous I/O settings; if not activated, nothing works after reset !
\ --------------------------------------\
MOV.B #4,X                              \           to enable RX_INT sleep
GOTO BW3                                \           goto I2C_Master START RX loop
ENDASM

\ ================================================================================
\ Driver UART to I2CM: this FastForth launchpad becomes an USB to I2C_Slave bridge
\ ================================================================================
\ type on TERMINAL "$10 UARTI2CS" to link TERMINAL with FastForth I2C_Slave at address hex $10
\
: UARTI2CS              \ SlaveAddress --
CR                      \ to compensate the lack of one INTERPRET
HI2LO
MOV @RSP+,IP
MOV TOS,&SLAVE_ADR      \ save in FRAM
MOV @PSP+,TOS
MOV #WARM,X
MOV #I2C_WARM,2(X)      \ replace WARM by I2C_WARM, so POR falls down to I2C_WARM
MOV X,PC                \ execute I2C_WARM
ENDCODE

RST_HERE ECHO
#16 UARTI2CS    ; Alt-B (TERATERM) or S2+RESET (I2C_Master) to quit

; Since there is no difference in behaviour whether the TERMINAL is connected to the Master
; or bridged to any Slave, WARM is the convenient way to check which target is connected to,
; because, as any ABORT message, WARM displays first the decimal I2C address if applicable:
WARM
