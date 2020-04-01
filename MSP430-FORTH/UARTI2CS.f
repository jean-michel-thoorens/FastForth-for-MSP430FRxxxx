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
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133 (can't use LED1 because wired on UART TX)
\ MSP_EXP430FR2433  CHIPSTICK_FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\
\ FastForth kernel compilation minimal options:
\ TERMINAL3WIRES, TERMINAL4WIRES
\ MSP430ASSEMBLER, CONDCOMP
\
\ coupled to a PL2303HXD cable, this driver enables a FastForth target to do an USB to I2C_Slave bridge,
\ thus, any I2C_FastForth target can communicate with TERATERM.
\ In addition, UARTI2CS simulates a full duplex TERMINAL while the I2C bus is half duplex.
\ 
\ driver test @ speed maxi: MCLK=24MHz, PL2303HXD with shortened cable (20cm), WIFI off, all windows apps closed else Scite and TERATERM.
\ ------------------------------------
\
\     notebook                                  USB to I2C_Slave bridge                                     any I2C_slave target
\ +---------------+          +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +            +-------------------------------+
\ |               |          i   PL2303HXD                target running UARTI2CS @ 24MHz i           +-------------------------------+|
\ |               |          +---------------+           +--------------------------------+          +-------------------------------+||
\ |               |          |               |           |                                |RX:1150kHz|                               |||
\ |   TERATERM   -o--> USB --o--> USB2UART --o--> UART --o--> FAST FORTH ---> UARTI2CS  --o--> I2C --o--> FAST FORTH @ 24MHz with    ||+
\ |   terminal    |          |               |   6 MBds  |                                |TX:750kHz |   kernel option TERMINAL_I2C  |+
\ |               |          +---------------+           +--------------------------------+          +-------------------------------+
\ |               |          i               |<-L<=20cm->|                                i 
\ +---------------+          +- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
\
\ I2C frequency = (TX+RX)/2 = 950 kHz @ MCLK=24 MHz, without any error...
\ downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Slave best time = 844ms.
\ downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Master best time = 531ms.
\ nota: the difference (313 ms) is the time of the I2C Half duplex exchange (I2C freq. about 1MHz).
\ 
\ also tested with I2C_Master @ 24MHz and I2C_Slave @ 1MHz.
\
\ You can use any pin for SDA and SCL, preferably in the interval Px0...Px3.
\ don't forget to wire 3.3k pullup resitors on pin SDA and SCL.
\ you will find SCA and SCL pin by searching 'SM_BUS' in your \inc\target.pat file
\
\
\ the LEDs TX and RX work fine, comment/uncomment as you want.
\
\ Multi Master Mode works but is not tested in the real word.
\
\ les limitations du bus I2C
\ --------------------------
\
\ 1- le bus I2C est orienté Maître vers Esclave, l'esclave ne décide de rien.
\    Cet ordre des choses permet en tout cas d'établir la liaison.
\    On placera donc le maître du côté du TERMINAL de commande et la cible FastForth côté esclave.
\    Mais une fois que la liaison est établie il faut trouver une astuce pour renverser
\    les rôles, afin que l'esclave puisse prendre le contrôle de l'échange de données.
\
\ 2- le bus I2C fonctionne en Half Duplex. 
\    Une autre astuce consistera donc à simuler une liaison I2C_Slave TERMINAL en mode Full Duplex.
\
\ Solutions : l'esclave envoie "servilement" des caractères de contrôle au maître,
\ et comme celui-ci obéit à un plus grand que lui, le programmeur,
\ il se fait un devoir "magistral" d'obéir à l'esclave.
\
\ Pour prendre le contrôle du maître, l'esclave lui émet donc 1 parmi 6 CTRL-Char:
\   CTRL-Char $00 envoyé par ACCEPT (1ère partie, avant de s'endormir avec SLEEP),
\   CTRL-Char $01 envoyé par KEY: demande d'envoi d'un caractère unique saisi sur TERMINAL,
\   CTRL-Char $02 envoyé par ABORT: demande d'abandon du fichier en cours de transmission le cas échéant,
\                                   suivi d'un START RX pour la réception du message envoyé par ABORT,
\   CTRL-Char $03 envoyé par COLD, pour que le maître relance la connexion I2C en mode RX,
\   CTRL-Char $04 envoyé par NOECHO, pour qu'il passe l'UART en mode half duplex,
\   CTRL-Char $05 envoyé par ECHO, pour qu'il rétablisse l'UART en mode full duplex.
\
\ Enfin, si le maître reçoit un caractère $FF, il considère que la liaison est coupée,
\ il effectue ABORT pour forcer le maître à effectuer un START RX en boucle.
\
\ Une fois que l'esclave a envoyé le CTRL_Char $00, il s'endort, 
\ à la reception de ce CTRL_Char, le maître s'endort aussi, dans l'attente d'une interruption UART RX.
\ Tant que le TERMINAL est silencieux, le maître et l'esclave restent en mode SLEEP,
\ LPM0 pour le maître (l'UART ne fonctionne pas si LPMx < LPM0), LPM4 pour l'esclave.
\
\ ---------------
\ interruptions
\ ---------------
\
\ TxIFG_INT sert à générer une interruption 1/2 seconde qui est prise en compte uniquement quand le maître fait dodo.
\ Elle effectue un (re)START RX ce qui permet de rétablir la liaison I2C suite à un RESET|COLD effectué sur I2C_Slave.
\    (Le switch RESET est en effet redirigé sur COLD via l'interruption USER NMI).
\ Logique d'établissement de la liaison I2C (START RX): 
\   si X U>= 4 (1ère connexion demandée par le maître) ==> un START RX à chaque 1/2s, 
\   si X U< 4 (perte de connexion suite à I2C_Slave{COLD|RESET|WARM|ABORT}) ==> START RX répété en boucle.
\
\ WDT_INT génère une interruption 8 ms qui est prise en compte quand le maître fait dodo.
\ elle permet la sortie du programme UARTI2CS quand Teraterm envoie Alt-B ou quand l'utilisateur actionne SW2+RESET.
\
\ TERM_INT redirige l'interruption par défaut UART RX_INT
\
\
[UNDEFINED] @ [IF]
\ https://forth-standard.org/standard/core/Fetch
\ @     c-addr -- char   fetch char from memory
CODE @
MOV @TOS,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] AND [IF]
\ https://forth-standard.org/standard/core/AND
\ C AND    x1 x2 -- x3           logical AND
CODE AND
AND @PSP+,TOS
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] 0= [IF]
\ https://forth-standard.org/standard/core/ZeroEqual
\ 0=     n/u -- flag    return true if TOS=0
CODE 0=
SUB #1,TOS      \ borrow (clear cy) if TOS was 0
SUBC TOS,TOS    \ TOS=-1 if borrow was set
MOV @IP+,PC
ENDCODE
[THEN]

: I2CTERM_ABORT
$0D EMIT   \ return to column 1
1 ABORT" <-- Ouch! unexpected target with I2C TERMINAL"
;

KERNEL_ADDON @ $7800 AND 0= [IF] ; unexpected I2C TERMINAL ?
I2CTERM_ABORT
[THEN]

PWR_STATE \ remove the above words 

[DEFINED] {UARTI2CS} [IF] {UARTI2CS} [THEN]

MARKER {UARTI2CS}

[UNDEFINED] < [IF]      \ define < and >
\ https://forth-standard.org/standard/core/less
\ <      n1 n2 -- flag        test n1<n2, signed
CODE <
        SUB @PSP+,TOS   \ 1 TOS=n2-n1
        S< ?GOTO FW1    \ 2 signed
        0<> IF          \ 2
BW1         MOV #-1,TOS \ 1 flag Z = 0
        THEN
        MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/more
\ >     n1 n2 -- flag         test n1>n2, signed
CODE >
        SUB @PSP+,TOS   \ 2 TOS=n2-n1
        S< ?GOTO BW1    \ 2 --> +5
FW1     AND #0,TOS      \ 1 flag Z = 1
        MOV @IP+,PC
ENDCODE
[THEN]

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

I2CSLA0 CONSTANT I2CS_ADR       \ CONSTANT = I2C_Slave address in FRAM (I2CSLA0=$FFA2)

\ ------------------------------\
ASM QUIT_I2C                    \ <== MultiMaster, START_RX loop, I2C_WARM
\ ------------------------------\
BW1                             \ <== WDT_INT
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

\ ******************************\
ASM WDT_INT                     \ enables Alt+B when I2C_Master is sleeping
\ ******************************\
BIT #8,&TERM_STATW              \ UART break sent by TERATERM ?
0<> IF
    ADD #4,RSP                  \ remove RETI
    GOTO BW1                    \ goto QUIT_I2C
THEN
RETI                            \ return to SLEEP
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
0<> WHILE                               \ 2 28 cycles loop ==> up to 2.85 Mbds @ 8MHz
    CMP #0,W                            \ 1
    0= IF                               \ 2 if echo ON requested by I2C_Slave
        BEGIN                           \   )
            BIT #2,&TERM_IFG            \ 3 > Test TX_Buf empty mandatory for low baudrates
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
MOV.B &TERM_RXBUF,S                     \ 3 S = last char (LF|KEY_input) ...
MOV.B S,0(T)                            \ 4 store it into buffer
\ ======================================\
\ ======================================\
\ I2C MASTER TX                         \ now we transmit UART RX buffer (PAD) to I2C_Slave, S = last char to transmit
\ ======================================\
\ ======================================\          
\ \ --------------------------------------\
\ BIS.B #LED1,&LED1_DIR                   \ red led ON = I2C TX 
\ BIS.B #LED1,&LED1_OUT                   \ red led ON = I2C TX
\ \ --------------------------------------\
\ \     vvvvvvvvvvMulti-Master-Modevvvvvvv\
\ BW2 \ I2C_Master TX Start               \ here, SDA and SCL must be in idle state
\ \     ^^^^^^^^^^Multi-Master-Mode^^^^^^^\   _
BIS.B   #SM_SDA,&I2CSM_DIR              \ 3 l  v_ force SDA as output (low)
MOV.B   &I2CS_ADR,X                     \ 3 h     X = Slave_Address
MOV     #PAD_ORG,Y                      \ 2 h     Y = input buffer for I2C_Master TX
NOP3                                    \ 3 h _
BIS.B   #SM_SCL,&I2CSM_DIR              \ 3 h  v_ force SCL as output (low)
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
\            NOP2                        \ 2        uncomment for beautiful code
        THEN                            \   l   _
        BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
        BEGIN                           \           we must wait I2C_Slave wake up
            BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       by testing SCL released
        0<> UNTIL                       \ 2 h
\ \       vvvvvvvvMulti-Master-Modevvvvvvv\
\         BIT.B #SM_SDA,&I2CSM_IN         \ 3 h       test SDA
\ \       ^^^^^^^^Multi-Master-Mode^^^^^^^\   _
        BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\ \       vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\         0= IF                                   \ 2 l   SDA input low
\             BIT.B #SM_SDA,&I2CSM_DIR            \ 3 l + SDA command high
\             0= IF                               \ 2 l = collision detected
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
\        BIT.B #SM_SCL,&I2CSM_IN         \ 3 h      testing SCL released is useless
\    0<> UNTIL                           \ 2 h      replaced by NOP3
    NOP3                                \ 3 h
    BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA state
    BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low
\   ------------------------------------\
0= WHILE \ 1- Slave Ack received        \ 2 l       else goto THEN; out of loop if Nack
\   ------------------------------------\           
\   I2C_Master_TX_data_loop             \
\   ------------------------------------\
    CMP S,T                             \ 1         T = last char to transmit ? (when address is sent, T = 16bits <> S = 8bits)
\   ------------------------------------\
0<> WHILE \ 2- TXed char <> last char   \ 2         else out of loop
\   ------------------------------------\
    MOV.B @Y+,X                         \ 2 l       get next byte to TX
    MOV X,T                             \ 1         T = last char TX for comparaison above
REPEAT                                  \           <-- WHILE2  search "Extended control-flow patterns"... 
THEN                                    \           <-- WHILE1  ...in https://forth-standard.org/standard/rationale
\   ------------------------------------\
\ Nack or Ack on last char              \           Nack = I2C_Slave request or I2C_Slave RESET, Ack = last char has been TXed
\   ------------------------------------\
    NOP3                                \ 3 l   _   delay to reach I2C tLO
    BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL to enable START RX
\ \ --------------------------------------\
\     BIC.B #LED1,&LED1_DIR               \   red led OFF = endof I2C TX 
\     BIC.B #LED1,&LED1_OUT               \   red led OFF = endof I2C TX
\ \ --------------------------------------\
GOTO FW1                                \   X > 4 ==> START RX every 1/2s 
\ ======================================\
\ END OF I2C MASTER TX                  \
\ ======================================\
ENDASM

\ **************************************\
ASM TxIFG_INT
\ **************************************\
\ I2C MASTER RX                         \
\ --------------------------------------\
ADD #4,RSP                              \ 1 remove RET and SR
\ --------------------------------------\
FW1                                     \   from TERM_INT above
\ --------------------------------------\
BW3                                     \   from I2C_WARM below
\ --------------------------------------\
\ I2C_Master START RX                   \
\ --------------------------------------\
KERNEL_ADDON @ 0 <                      \ 
[IF]                                    \ if LF XTAL
    MOV #%0001_1101_0110,&TB0CTL        \ 3 (re)starts RX_timer,ACLK=LFXTAL=32738,/8=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
\    MOV #%0001_1101_0110,&TA0CTL        \ 3 (re)starts RX_timer,ACLK=LFXTAL=32768,/8=4096Hz,up mode,clear timer,enable TA0 int, clear IFG
[ELSE]                                    \ 2
    MOV #%0001_0101_0110,&TB0CTL        \ 3 (re)starts RX_timer,ACLK=VLO=8kHz,/2=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
\    MOV #%0001_0101_0110,&TA0CTL        \ 3 (re)starts RX_timer,ACLK=VLO=8kHz,/2=4096Hz,up mode,clear timer,enable TA0 int, clear IFG
[THEN]
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
\       --------------------------------\     _
        BIS.B   #SM_SDA,&I2CSM_DIR      \ 3 l  v_   force SDA as output (low)
        MOV.B   &I2CS_ADR,Y             \ 3 h       X = Slave_Address
        BIS.B   #1,Y                    \ 1 h       Master RX
        NOP2                            \ 2   _
        BIS.B   #SM_SCL,&I2CSM_DIR      \ 3 h  v_   force SCL as output (low)
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
\            NOP2                        \ 2        uncomment for beautiful code
            THEN                        \       _
            BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
\            BEGIN                       \
\                BIT.B #SM_SCL,&I2CSM_IN \ 3 h      testing SCL released is useless
\            0<> UNTIL                   \ 2 h      replaced by NOP3
            NOP3                        \ 3
\ \           vvvvvvMulti-Master-Modevvvvv\
\             BIT.B #SM_SDA,&I2CSM_IN     \ 3 h     test SDA
\ \           ^^^^^^Multi-Master-Mode^^^^^\   _
            BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_  force SCL as output (low)
\ \           vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\             0= IF                                   \ 2 l   SDA input low
\                 BIT.B #SM_SDA,&I2CSM_DIR            \ 3 l + SDA command high
\                 0= IF                               \ 2 l = collision detected
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
            BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       wait I2C_Slave ready 
        0<> UNTIL                       \ 2 h       I2C_Slave releases SCL
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
        U>= IF                          \           if X >= 4 goto dodo for 1/2 s..
            MOV #SLEEP,PC               \ 4           ..wake up by TxIFG_INT to reSTART RX or by WDT_INT (to QUIT UARTI2CS)
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
\               BIT.B #SM_SCL,&I2CSM_IN \ 3 h       testing SCL released is useless
\               0<> UNTIL               \ 2 h       replaced by NOP3
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
\           ----------------------------\
\           I2C_Master Send Ack         \
\           ----------------------------\       _   
            BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
            BEGIN                       \
                BIT.B #SM_SCL,&I2CSM_IN \ 3 h       wait I2C_Slave ready 
            0<> UNTIL                   \ 2 h       I2C_Slave releases SCL
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
\       --------------------------------\
\       I2C_Master send Ack/Nack        \
\       --------------------------------\       _   
        BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
        BEGIN                           \
            BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       wait I2C_Slave ready 
        0<> UNTIL                       \ 2 h       I2C_Slave releases SCL
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
    CALL &RXON                          \ 4 l   enables TERMINAL to TX; use no registers
    BEGIN                               \       wait for a char or for a break
        BIT #UCRXIFG,&TERM_IFG          \ 3     received char ?
    0<> UNTIL                           \ 2 
    CALL &RXOFF                         \       stops UART RX then
    GOTO BW1                            \       goto end of UART RX line input, for receiving last char
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
MOV #SLEEP,PC                           \ execute RXON (that enables TERMINAL to TX) then goto dodo
\ --------------------------------------\
\ I2C_Master se réveillera au premier caractère saisi sur le TERMINAL ==> TERM_INT,
\ ou en fin du temps TxIFG ==> TxIFG_INT\
\ ou par un break opérateur ==> WDT_INT \ 
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
MOV #WDT_INT,&WDT_VEC                   \           replace WDT_VEC default COLD value by WDT_INT
\ --------------------------------------\
\ init TxIFG_INT                        \           used to scan I2C_Slave hard RESET during SLEEP and to slow START RX loop
\ --------------------------------------\
MOV #$800,&TB0CCR0                      \           be careful:  RX_Int time = (2047+1)/4096 = 0.5s must be >> COLD time !
MOV #TxIFG_INT,&TB0_x_VEC               \           replace TB0_x_VEC default COLD value by TxIFG_INT
\ MOV #$800,&TA0CCR0                      \           be careful:  RX_Int time = (2047+1)/4096 = 0.5s must be >> COLD time !
\ MOV #TxIFG_INT,&TA0_x_VEC               \           replace TA0_x_VEC default COLD value by TxIFG_INT
\ --------------------------------------\
\ init UART_INT                         \
\ --------------------------------------\
MOV #TERM_INT,&TERM_VEC                 \           replace TERM_VEC default value (TERMINAL_INT) by TERM_INT
\ --------------------------------------\
\ init I2C_MASTER I/O                   \           see \inc\your_target.pat
\ --------------------------------------\
BIC.B #SM_BUS,&I2CSM_REN                \           remove internal pullup resistors because of external 3.3k pullup resistor
BIC.B #SM_BUS,&I2CSM_OUT                \           preset SDA + SCL output LOW
\ --------------------------------------\
\ activate I/O                          \           SYSRSTIV = $02 | $0E = POWER ON | SVSH threshold
\ --------------------------------------\
BIC #1,&PM5CTL0                         \           activate all previous I/O settings; if not activated, nothing works after reset !
\ --------------------------------------\           else CLOCK
MOV.B #4,X                              \           to enable sleep during START RX loop
GOTO BW3                                \           goto I2C_Master START RX loop
ENDASM

\ ================================================================================
\ Driver UART to I2CM : any FastForth launchpad becomes an USB to I2C_Slave bridge
\ ================================================================================
\ type on TERMINAL "$10 UARTI2CS" to link TERMINAL with FastForth I2C_Slave at address hex $10
\
: UARTI2CS              \ SlaveAddress --
CR                      \ to compensate the lack of one INTERPRET
HI2LO
MOV @RSP+,IP
MOV TOS,&I2CS_ADR       \ save in FRAM
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
