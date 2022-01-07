\ -*- coding: utf-8 -*-
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133 (can't use LED1 because wired on UART TX)
\ MSP_EXP430FR2433  CHIPSTICK_FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476   MY_MSP430FR5738_1
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
\
\ ================================================================================
\ REGISTERS USAGE for embedded MSP430 ASSEMBLER
\ ================================================================================
\ don't use R2, R3,
\ R4, R5, R6, R7 must be PUSHed/POPed before/after use
\ scratch registers S,T,W,X and Y are free,
\ in interrupt routines, IP is free,
\ Apply FORTH rules for TOS, PSP, RSP registers.
\
\ PUSHM order : PSP,TOS, IP, S , T , W , X , Y ,rDOVAR,rDOCON,rDODOES,rDOCOL, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5   ,  R4  , R3, R2, R1, R0
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack, with IP first pushed
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack, with IP last poped
\
\ ASSEMBLER conditionnal usage before IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before          ?GOTO : S< S>= U< U>= 0= 0<> 0< 
\
\ ================================================================================
\ coupled to a PL2303HXD/TA cable, this driver enables a FastForth target to act as USB to I2C_Slave bridge,
\ thus, from TERATERM.exe you can take the entire control of up to 112 I2C_FastForth targets.
\ In addition, it simulates a full duplex communication while the I2C bus is only half duplex.
\ Don't forget to wire 3k3 pull up resistors on wires SDA SCL!
\ ================================================================================
\ 
\ driver test : MCLK=24MHz, PL2303HXD with shortened cable (20cm), WIFI off, all windows apps closed else Scite and TERATERM.
\ -----------                                                                                    .
\                                                                                               .         ┌────────────────────────────────┐
\     notebook                                  USB to I2C bridge                              +-- I2C -->|  up to 112 I2C_Slave targets   |
\ ┌───────────────┐          ╔════════════════════════════════════════════════════════════╗   /         ┌───────────────────────────────┐  |
\ |               |          ║   PL2303HXD                device running UARTI2CS @ 24MHz ║  +-- I2C -->|    MSP430FR4133 @ 1 MHz       |  |
\ |               |          ║───────────────┐           ┌────────────────────────────────║ /        ┌───────────────────────────────┐  |──┘
\ |               |          ║               |  3 wires  |    MSP430FR2355 @ 24MHz        ║/         |    MSP430FR5738 @ 24 MHz      |  |
\ |   TERATERM   -o--> USB --o--> USB2UART --o--> UART --o--> FAST FORTH ---> UARTI2CS  --o--> I2C --o-->    FAST FORTH with         |──┘
\ |   terminal    |          ║               |   6 MBds  |                  (I2C MASTER)  ║          |         I2C TERMINAL          | 
\ |               |          ║───────────────┘           └────────────────────────────────║          └───────────────────────────────┘
\ |               |          ║               |<- l=20cm->|                                ║ 
\ └───────────────┘          ╚════════════════════════════════════════════════════════════╝              
\
\ test results :
\ ------------
\
\ downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Master target = 1016ms.
\ downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Slave target = 1422ms.
\ the difference (406 ms) is the time of the I2C Half duplex exchange.
\ [(45906 chars * 9 bits) + (1533 * 31)] / 0,406 = 1,135 MHz (9 bits / char + (2*START + 2*STOP + 2*addr + CTRL_Char) / line) 
\ ==> 113 % of I2C Fast-mode Plus (Fm+)!
\ 
\ also connected to and tested with another I2C_FastForth target with MCLK = 1MHz (I2C CLK = MCLK ! ).
\
\ The I2C_Slave address is defined as 'MYSLAVEADR' in forthMSP430FR.asm source file of I2C_Slave target.
\ You can use any pin for SDA and SCL, preferably in the interval Px0...Px3.  
\ don't forget to add 3.3k pullup resitors on wires SDA and SCL.
\
\
\ the LEDs TX and RX work fine, comment/uncomment as you want.
\
\ Multi Master Mode works but is not tested in the real word.
\
\ how it works
\ ------------
\
\ 1- the I2C bus is Master to Slave oriented, the Slave does not decide anything.
\    This order of things allows in any case to establish the connection.
\    The I2C Master device is therefore placed on the TERMINAL side and the FastForth target on the I2C Slave side.
\    But once the link is established, we have to find a trick to reverse the roles, 
\    so that the slave can take control of the data exchange.
\
\ 2- The I2C bus operates on half duplex. 
\    Another trick will be to simulate an I2C_Master TERMINAL in Full Duplex mode.
\
\ 3- Without forgetting a visual effect to show the lack of I2C connection...
\
\ Solution: The slave "slavishly" sends control characters to the master,
\ and since this one obeys a bigger man than himself: the programmer..,
\ he makes it his "masterly" duty to obey the slave.
\
\ To take control of the master, the slave emits one of 5+1 CTRL-Char:
\   CTRL-Char $00 sent by ACCEPT (before falling asleep with SLEEP),
\   CTRL-Char $01 sent by KEY: request to send a single character entered on TERMINAL,
\   CTRL-Char $02 sent by ABORT": request to abort the file being downloaded if any,
\                                followed by a START RX for ABORT" message,
\   CTRL-Char $04 sent by NOECHO, to switch the UART to half-duplex mode,
\   CTRL-Char $05 sent by ECHO, to switch the UART to full duplex mode.
\
\   Finally, if the master receives a $FF as data, he considers the link broken,
\   it performs ABORT which forces a START RX into a 500 ms loop with an appropriate visual effect...
\
\ Once the slave sends the CTRL_Char $00, he falls asleep, 
\ On its receipt, the master also falls asleep, awaiting a UART RX interruption.
\ As long as the TERMINAL is silent, the master and the slave remain in SLEEP mode,
\ (a part the Tx0_INT interrupt every 1/2 s).
\ SLEEP mode is LPM0 for the master (UART does not work if LPMx > LPM0), LPM4 for the slave.
\
\ interruptions
\ -------------
\ Since the slave can't wake up the master with a dedicated interrupt, the master must generate one
\ cyclically to listen to the slave.
\ 500MS_INT is used to generate a 1/2 second interrupt, obviously taken into account only when the master goes to sleep.
\ It performs a (re)START RX that enables the I2C link to be re-established following a RESET performed on I2C_Slave side.
\
\ This interruption also allows to exit the UARTI2CS program when user sends a software BREAK (Teraterm(Alt-B)), or presses SW2.
\
\ the other interruption U2I_TERM_INT is used to link the TERMINAL with UARTI2CS instead of FORTH interpreter.
\
\ don't forget to link 3V3 and GND on each side and to add 3k3 pullup resistors on SDA and SCL.
\
\ because Txi_int > UCxi_int > Pi.j_int and to ensure U2I_TERM_INT priority greater than 500MS_INT
\ we choose P1.7 = TB0.2 output linked to P1.6 to use P1.6_int instead of Txi_int for 500MS_INT.

; --------------------------------------------------------- \
; UARTI2CS.f \ UART to I2C bridge for I2C_FastForth TERMINAL----------+
; --------------------------------------------------------- \         |
\                                                                     |
\                                                                     |
\                      GND------------------------------GND           |
\                      Vcc-------------o---o------------Vcc           |
\                                      |   |                          | 
\                                      3   3                          | 
\                                      k   k                          | 
\                                      3   3                          v 
\   I2C_FastForth                      |   |                       UARTI2CS        +---------------------------------------+
\      hardware         +--------------|---o-------------+         Software        |    +-----------------------------+    |
\      I2C Slave        |      +-------o----------+      |         I2C Master      |    |    +------(option)-----+    |    |
\                       |      |                  |      |                         |    |    |                   |    |    |
\ I2C_FastForth(s)     SCL    SDA  connected to: SDA    SCL of I2C to UART bridge TXD  RXD  RTS  connected to : CTS  TXD  RXD  UARTtoUSB <--> COMx <--> TERMINAL
\ ------------------   ----   ----               ----   ----   ------------------ ---  ---  ---                 ---  ---  ---  ---------      ----      ------------
\ MSP_EXP430FR5739     P1.7   P1.6               P4.0   P4.1   MSP_EXP430FR5739   P2.0 P2.1 P2.2                               PL2303TA                 TERATERM.EXE
\ MSP_EXP430FR5969     P1.7   P1.6               P1.2   P1.3   MSP_EXP430FR5969   P2.0 P2.1 P4.1                               PL2303HXD
\ MSP_EXP430FR5994     P7.1   P7.0               P8.2   P8.1   MSP_EXP430FR5994   P2.0 P2.1 P4.2                               CP2102
\ MSP_EXP430FR6989     P1.7   P1.6               P1.3   P1.5   MSP_EXP430FR6989   P3.4 P3.5 P3.0       
\ MSP_EXP430FR4133     P5.3   P5.2               P8.2   P8.3   MSP_EXP430FR4133   P1.0 P1.1 P2.3       
\ CHIPSTICK_FR2433     P1.3   P1.2               P2.0   P2.2   CHIPSTICK_FR2433   P1.4 P1.5 P3.2           
\ MSP_EXP430FR2433     P1.3   P1.2               P3.2   P3.1   MSP_EXP430FR2433   P1.4 P1.5 P1.0           
\ MSP_EXP430FR2355     P1.3   P1.2               P3.2   P3.3   MSP_EXP430FR2355   P4.3 P4.2 P2.0      
\ LP_MSP430FR2476      P4.3   P4.4               P3.2   P3.3   LP_MSP430FR2476    P1.4 P1.5 P6.1                                                                     

\ first, we do some tests allowing the download
\   ------------------------\
    CODE ABORT_UARTI2CS     \
\   ------------------------\
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #$3C00,TOS          \ BIT13|BIT12|BIT11|BIT10 test (UART TERMINAL test)
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (UART TERMINAL), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #309,TOS            \ FastForth V3.9
    COLON
    $0D EMIT                \ return to column 1 without CR
    ABORT" FastForth V3.9 please!"
    ABORT" <-- Ouch! unexpected I2C_FastForth target!"
    RST_RET                 \ remove the ABORT_UARTI2CS definition before continuing the download.
    ;

    ABORT_UARTI2CS          \ run tests

    MARKER {UARTI2CS}   \ USER_PARAM-2 addr = {UARTI2CS}-2  <-- REMOVE_APP (RET_ADR by default)
    10 ALLOT            \ USER_PARAM   addr = {UARTI2CS}    <-- previous HARD_APP
\                         USER_PARAM+2 addr = {UARTI2CS}+2  <-- previous SLEEP_APP
\                         USER_PARAM+4 addr = {UARTI2CS}+4  <-- previous TERM_VEC
\                         USER_PARAM+6 addr = {UARTI2CS}+6  <-- previous P1_VEC
\                         USER_PARAM+8 addr = {UARTI2CS}+8  <-- I2C_Slave_Addr << 1
\                         USER_PARAM+9 addr = {UARTI2CS}+9  <-- Half_Duplex flag : 4 --> NOECHO, <> 4 --> ECHO

    [UNDEFINED] TSTBIT  
    [IF]
    CODE TSTBIT         \ addr bit_mask -- true/flase flag
    MOV @PSP+,X
    AND @X,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ note: HDNCODE definitions are HiDdeN and cannot be executed from TERMINAL
\   ----------------------------\
    HDNCODE I2CM_STOP           \ sends a STOP on I2C_BUS
\   ----------------------------\     _
    BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_   force SCL as output (low)
    NOP3                        \ 3 l _
    BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l  v_   SDA as output ==> SDA low
    NOP3                        \ 3 l   _
    BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
    NOP3                        \ 3 h   _
    BIC.B #SM_SDA,&I2CSM_DIR    \ 3 h _^    relase SDA (high) when SCL is high = STOP
    MOV @RSP+,PC                \
    ENDCODE                     \
\   ----------------------------\

\   ----------------------------\
    CODE REMOVE_U2I             \
\   ----------------------------\
BW1                             \ <-- TERATERM(ALT+B)|USBtoI2C_bridge(SW2)|SYS_failures
\   vvvvvvvvvvvv OPTION vvvvvvvv\
    BIC.B #LED1,&LED1_OUT       \ set TX red led OFF
    BIC.B #LED1,&LED1_DIR       \ set TX red led pin as input
    BIC.B #LED2,&LED2_OUT       \ set RX green led OFF
    BIC.B #LED2,&LED2_DIR       \ set RX green led pin as input
\   ^^^^^^^^^^^^ OPTION ^^^^^^^^\
    CALL #I2CM_STOP             \ stop properly I2C_BUS
    MOV #SM_BUS,W               \
    BIC.B W,&I2CSM_DIR          \ restore I2C_BUS I/O as input 
    BIS.B W,&I2CSM_OUT          \         with pull up resistors
    BIS.B W,&I2CSM_REN          \
\   ----------------------------\
    MOV #0,&TB0CTL              \ stop TBO
    BIC.B #BIT7,&P1SEL1         \ clear P1.7 SEL1
    BIC.B #BIT7,&P1DIR          \ P1.7 as input
    BIC.B #BIT6,&P1IE           \ stop P1.6 int
\   ----------------------------\
    CMP #RET_ADR,&{UARTI2CS}-2  \
    0<> IF
        MOV #{UARTI2CS},W       \ W = addr of first user parameter following MARKER
        MOV #RET_ADR,-2(W)      \ don't forget: restore default MARKER_DOES call address !
        MOV @W+,&HARD_APP       \ restore previous (default) HARD_APP value
        MOV @W+,&SLEEP_APP      \ restore previous (default) SLEEP_APP value
        MOV @W+,&TERM_VEC       \ restore previous (default) TERM_VEC value
        MOV @W+,&P1_VEC         \ restore previous (default) P1_VEC value 
    THEN
\   ----------------------------\
    MOV #1,TOS                  \ TOS = USERSYS value we want for TERATERM(ALT+B)|USBtoI2C_bridge(SW2)|SYS_failures events
    MOV #UART_WARM+4,PC         \ display WARM message then RET to FORTH interpreter
    ENDCODE                     \ REMOVE_U2I is redirected to this CODENNM definition
\   ----------------------------\

\   ----------------------------------------\
    HDNCODE I2CM_START                      \ WX use    I2C_Master TX ADdRess with collision detection and resolution
\   ----------------------------------------\     _
    BIS.B   #SM_SDA,&I2CSM_DIR              \ 3    v_   force SDA as output (low)
    BIS.B   &{UARTI2CS}+8,X                 \ 3         X = Slave_Address&flag
    NOP3                                    \ 3
    BIS.B   #SM_SCL,&I2CSM_DIR              \ 3    v_   force SCL as output (low)
\   ----------------------------------------\
\   I2C_Master_Send_I2C_Addr                \
\   ----------------------------------------\
    MOV.B #8,W                              \ 1 l       count for 7 bits address + R/w bit
    BEGIN                                   \
        ADD.B X,X                           \ 1 l       shift one left
        U>= IF                              \ 2 l       carry set ?
            BIC.B #SM_SDA,&I2CSM_DIR        \ 3 l       yes : SDA as input  ==> SDA high because pull up resistor
        ELSE                                \ 2 l
            BIS.B #SM_SDA,&I2CSM_DIR        \ 3 l       no  : SDA as output ==> SDA low
        THEN                                \   l   _
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
\        BEGIN                               \
\            BIT.B #SM_SCL,&I2CSM_IN         \ 3 h       The I2C_Slave hardware takes the I2C address without delay even if the CPU is in the LPM4 state (wired logic).
\        0<> UNTIL                           \ 2 h
        BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA
        BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low
\       vvvvvvvvv Multi-Master-Mode vvvvvvvv\
        0= IF                               \ 2 l       if SDA input low
            BIT.B #SM_SDA,&I2CSM_DIR        \ 3 l       + SDA command high
            0= IF                           \ 2 l       = collision detected
                BIS.B #SM_BUS,&I2CSM_DIR    \ 4 l       release SDA,SCL
                BIC.B #SM_BUS,&I2CSM_IES    \ 4 l       set IES for SDA_IFG and SCL_IFG on low_to_high transition
                BEGIN                       \           SDA_IFG=1, SCL_IFG=1
                    BIT.B #SM_BUS,&I2CSM_IFG    \ 4     SM_BUS IFG ?
                    BIC.B #SM_BUS,&I2CSM_IFG    \ 4         clear SM_BUS IFG
                    0<> IF                      \ 2     if yes
\                        MOV #3,W            \ 2             SCL is still active: load for 8*15/MHz = 5.6 µs delay @ 8 MHz
\                        MOV #6,W            \ 2             SCL is still active: load for 8*15/MHz = 5.6 µs delay @ 16 MHz
                        MOV #9,W            \ 2             SCL is still active: load for 8*15/MHz = 5.6 µs delay @ 24 MHz
                    ELSE                    \ 2         if no
                        NOP2                \ 2             does the same
                        NOP2                \ 2             time as if yes
                    THEN
                SUB #1,W                    \ 1
                0= UNTIL                    \ 2         end of collision process
                ADD #2,RSP                  \           remove RET to Nack/Ack processing and select..
                MOV @RSP+,PC                \ 2 l       RET to ReStart after a collision detection
            THEN                            \
        THEN                                \
\       ^^^^^^^^^ Multi-Master-Mode ^^^^^^^^\
        SUB #1,W                            \ 1 l       bits count-1
    0= UNTIL                                \ 2 l
\   ----------------------------------------\
\   I2C_Master_TX get Slave Ack/Nack        \
\   ----------------------------------------\       _
    BIC.B #SM_SDA,&I2CSM_DIR                \ 3 l _^_   after TX address we must release SDA to read Ack/Nack from Slave
    BIC.B #SM_SCL,&I2CSM_DIR                \ 3 l _^    release SCL (high)
    BEGIN                                   \           we must wait I2C_Slave software
        BIT.B #SM_SCL,&I2CSM_IN             \ 3 h       by testing SCL released
    0<> UNTIL                               \ 2 h       because Slave can strech SCL low (wake up from interrupt)
    BIT.B #SM_SDA,&I2CSM_IN                 \ 3 h _     get SDA state
    BIS.B #SM_SCL,&I2CSM_DIR                \ 3 h  v_   SCL as output : force SCL low
\   ^^^^^^^^^^^ Multi-Master-Mode ^^^^^^^^^^\ 
    MOV @RSP+,0(RSP)                        \           remove RET to ReStart after a collision detection
\   vvvvvvvvvvv Multi-Master-Mode vvvvvvvvvv\   
    MOV @RSP+,PC                            \           RET to Nack/Ack select
    ENDCODE
\   ----------------------------------------\


\   ****************************************\
    HDNCODE U2I_TERM_INT                    \ UART RX interrupt starts on first char of each line sent by TERMINAL
\   ****************************************\ 
    ADD #4,RSP                              \ 1 remove unused PC_RET and SR_RET
\   ----------------------------------------\
\   get one line from UART TERMINAL to PAD  \ S = 'CR', T = 0
\   ----------------------------------------\
    BEGIN                                   \
        MOV.B &TERM_RXBUF,Y                 \ 3 move char from TERM_RXBUF...
        MOV.B Y,PAD_ORG(T)                  \ 3 ... to input buffer
        ADD #1,T                            \ 1
        CMP.B Y,S                           \ 1 char = CR ? (if yes goto next REPEAT)
    0<> WHILE                               \ 2 if <>
        CMP #4,W                            \ 1 HALF_DUPLEX = 4 ?
        0<> IF                              \ 2 no, echo is ON
            BEGIN                           \   )
                BIT #2,&TERM_IFG            \ 3 > Test TX_Buf empty, mandatory for low baudrates
            0<> UNTIL                       \ 2 )
            MOV.B Y,&TERM_TXBUF             \ 3 return all characters to UART_TERMINAL except CR+LF which will be later by I2C_SLAVE
        THEN                                \
        BEGIN                               \ 
            BIT #1,&TERM_IFG                \ 3 wait for next char received
        0<> UNTIL                           \ 2 
    REPEAT                                  \ 2 2 cycles loop ==> up to UART 2.58 Mbds @ 8MHz
    CALL #UART_RXOFF                        \ stops UART RX still char CR is received, the LF char is being transmitted.
    BEGIN                                   \
        BIT #1,&TERM_IFG                    \ 3 char LF received ?
    0<> UNTIL                               \ 2
\   ----------------------------------------\
BW2                                         \   <=== KEY input from TERMINAL, via I2C_MASTER
\   ----------------------------------------\
    MOV.B &TERM_RXBUF,S                     \ 3 S = last char RXed by UART (LF|KEY_input), used by I2C_MASTER_TX as last byte to be TXed.
    MOV.B S,PAD_ORG(T)                      \ 3 store it into buffer
\   ========================================\ here I2C_Slave is sleeping in its ACCEPT routine
\   I2C MASTER TX                           \ now we transmit UART RX buffer (PAD) to I2C_Slave, S = LF|KEY = last char to transmit
\   ========================================\          
\   ----------------------------------------\
\   I2C_Master_TX_Start                     \ S = last char UART RXed
\   ----------------------------------------\
\   ^^^^^^^^^^^ Multi-Master-Mode ^^^^^^^^^^\ 
    PUSH PC                                 \           PUSH next address as RET for START with collision detection
\   vvvvvvvvvvv Multi-Master-Mode vvvvvvvvvv\
    MOV #0,X                                \           to Start I2C_Master_TX
    CALL #I2CM_START                        \WX use     return to I2C_Master_TX_Start if collision detection on I2C address
    0<> ?GOTO FW2                           \           if Nack on address
\   vvvvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvv\
    BIS.B #LED1,&LED1_OUT                   \           red led ON = I2C TX
\   ^^^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^^^^\
    MOV #PAD_ORG,Y                          \ 2         Y = buffer pointer for I2C_Master TX datas
    BEGIN                                   \
        MOV.B @Y,X                          \ 2 l       get first char to be TX
\       ------------------------------------\
\       I2C_Master_TX Data from PAD         \
\       ------------------------------------\
        MOV.B #8,W                          \ 1 l       count for 8 bits data
        BEGIN                               \
            ADD.B X,X                       \ 1 l       shift one left
            U>= IF                          \ 2 l       carry set ?
                BIC.B #SM_SDA,&I2CSM_DIR    \ 3 l       yes : SDA as input  ==> SDA high because pull up resistor
            ELSE                            \ 2 l
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       no  : SDA as output ==> SDA low
            THEN                            \   l   _
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
\           --------------------------------\
            BEGIN                           \
                BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       TERM2SD" doesn't work if you replace this test by NOP3 !
            0<> UNTIL                       \ 2 h
\           --------------------------------\     _
            BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
            SUB #1,W                        \ 1 l       bits count-1
        0= UNTIL                            \ 2 l
\       ------------------------------------\
        BIC.B #SM_SDA,&I2CSM_DIR            \ 3 l       after TX byte we must release SDA to read Ack/Nack from Slave
\       ------------------------------------\
\       I2C_Master_TX get Slave Ack/Nack    \
\       ------------------------------------\       _
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
        BEGIN                               \
            BIT.B #SM_SCL,&I2CSM_IN         \ 3 h
        0<> UNTIL                           \ 2 h
        BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA state
        BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low, to keep I2C_BUS until next I2C_MASTER START (RX|TX)
\   ----------------------------------------\
    0= WHILE \ 1- Slave Ack received        \ 2 l       out of loop if Nack on data
\   ----------------------------------------\
\   I2C_Master_TX_Data_Loop                 \
\   ----------------------------------------\
        CMP.B @Y+,S                         \ 2         last char I2C TXed = last char UART RXed (LF|KEY) ?
\   ----------------------------------------\
    0= UNTIL  \ TXed char = last char       \ 2
\   ----------------------------------------\
    THEN                                    \           <-- WHILE1 case of I2C_Slave Nack on Master_TX
\   vvvvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvv\
    BIC.B #LED1,&LED1_OUT                   \   red led OFF = endof I2C TX
\   ^^^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^^^^\
    GOTO FW1                                \   SCL is kept low   ──────────┐
\   ========================================\                               |
\   END OF I2C MASTER TX                    \                               |
\   ========================================\                               |
    ENDCODE                                 \                               |
\   ****************************************\                               v

\ wakes up every 1/2s by P1.6 int to listen I2C Slave or 
\ break from TERMINAL/USB_to_I2C_bridge.
\   ********************************************\                           |
    HDNCODE 500MS_INT                           \                           |
\   ********************************************\                           |
    ADD #4,RSP                                  \ 1 remove PC_RET, SR_RET   |
\   --------------------------------------------\                           |    
FW1                                             \ <────── does START <──────┘
FW2                                             \ <────── if Nack on Address Master TX
\   ^^^^^^^^^^^ Multi-Master-Mode ^^^^^^^^^^^^^^\ 
    PUSH PC                                     \   PUSH next address as RET for START with collision detection
\   vvvvvvvvvvv Multi-Master-Mode vvvvvvvvvvvvvv\   
\   ============================================\
\   I2C_MASTER RX                               \ le driver I2C_Master envoie START RX en boucle continue (X < 4) ou discontinue (X >= 4).
\   ============================================\ le test d'un break en provenance de l'UART est intégré dans cette boucle.
    BEGIN                                       \
\       ----------------------------------------\
\       QUIT on user request tests              \
\       ----------------------------------------\
        BIT #8,&TERM_STATW                      \ 3         break sent by TERATERM (Alt+B) ?
        0<> ?GOTO BW1                           \ 2         goto REMOVE_U2I, RET to WARM+4 with TOS=1.
        BIT.B #SW2,&SW2_IN                      \ 3         USB_to_I2C_bridge(SW2) pressed ?
        0= ?GOTO BW1                            \ 2         goto REMOVE_U2I, RET to WARM+4 with TOS=1.
\       ----------------------------------------\
\       I2C MASTER START RX                     \
\       ----------------------------------------\       _
        BIC.B #SM_SCL,&I2CSM_DIR                \ 3 l _^    release SCL to enable START RX
        MOV #1,X                                \           to Start I2C_Master as RX
            CALL #I2CM_START                    \           Start MASTER RX               
        0<> IF                                  \           if Nack_On_Address
            CALL #I2CM_STOP                     \           I2C_Master Send STOP
            MOV #'.',&TERM_TXBUF                \           to view the absence of I2C_target at the I2C_Addr provided.
            MOV #SLEEP,PC                       \           which executes SLEEP_U2I then RXON before LPM0 shut down.
        THEN                                    \
\       ----------------------------------------\
\       I2C_Master_RX_data                      \           End of RX_Data only on Ctrl_Char {$00|$01|$02|$FF}
\       ----------------------------------------\
\       vvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvvvv\
        BIS.B #LED2,&LED2_OUT                   \           green led ON = I2C RX
\       ^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^^^^^^\
        BEGIN                                   \
            BEGIN                               \
                BIC.B #SM_SDA,&I2CSM_DIR        \ 4 l       after Ack and before RX next byte, we must release SDA
                MOV.B #8,W                      \ 1 l       prepare 8 bits transaction
                BEGIN                           \
\                   ----------------------------\       _
                    BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
\                   ----------------------------\
                    BIT.B #SM_SDA,&I2CSM_IN     \ 3 h       get SDA
\                   ----------------------------\     _
                    BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_   SCL as output : force SCL low   13~
                    ADDC.B X,X                  \ 1 l       C <--- X(7) ... X(0) <--- SDA
                    SUB #1,W                    \ 1 l       count down of bits
                0= UNTIL                        \ 2 l       here, slave has set SDA for next bit
\               --------------------------------\
\               case of RX data $FF             \               case of -1 SYS for example
\               --------------------------------\
                CMP.B #-1,X                     \ 1
                0= IF                           \ 2         received char $FF: let's consider that the slave is lost...
                    MOV #2,X                    \           to do ABORT action after Nack sent
                THEN                            \
\               --------------------------------\
                CMP.B #8,X                      \ 1 l       $08 = char BS
            U>= WHILE                           \ 2 l       ASCII char received, from char 'BS' up to char $7F.
\               --------------------------------\
\               I2C_Master_RX Send Ack          \           on ASCII char >= $08
\               --------------------------------\ 
                BIS.B #SM_SDA,&I2CSM_DIR        \ 3 l   _   set SDA as Ack
                BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
                BEGIN                           \           we must wait I2C_Slave software (data processing)
                    BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       by testing SCL released,
                0<> UNTIL                       \ 2 h _     because Slave can strech SCL low
                BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\               --------------------------------\
\               I2C_Master echoes to TERMINAL   \
\               --------------------------------\
                CMP.B #4,&{UARTI2CS}+9          \ 3 W = HALF_DUPLEX = $04 if NOECHO, $05 if ECHO
                0<> IF
                    BEGIN                       \
                        BIT #2,&TERM_IFG        \ 3 l       UART TX buffer empty ?
                    0<> UNTIL                   \ 2 l       loop if no
                    MOV.B X,&TERM_TXBUF         \ 3 h       send RXed ASCII char to UART TERMINAL
                THEN
            REPEAT                              \ 2 l       loop back to I2C_Master_RX_data for chars >= 8
\           ------------------------------------\
\           case of RX CTRL_Chars < $08         \           here Master holds SCL low, Slave can test it: CMP #8,&TERM_STATW
\           ------------------------------------\           see forthMSP430FR_TERM_I2C.asm
            CMP.B #4,X                          \ 1         
            U>= IF                              \ 2
                MOV.B X,&{UARTI2CS}+9           \           set NOECHO = $04, ECHO = $05
                BIS.B #SM_SDA,&I2CSM_DIR        \ 3 l       prepare Ack for Ctrl_Chars $04 $05
            THEN                                \
\           ------------------------------------\
\           Master_RX send Ack/Nack on data     \           Ack for $04, $05, Nack for $00, $01, $02
\           ------------------------------------\       _   
            BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
            BEGIN                               \           we must wait I2C_Slave software (data processing)
                BIT.B #SM_SCL,&I2CSM_IN         \ 3 h       by testing SCL released
            0<> UNTIL                           \ 2 h       (because Slave can strech SCL low)
            BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA as TX Ack/Nack state
            BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low
\           ------------------------------------\   l    
        0<> UNTIL                               \           if Ack, loop back to Master_RX data for CTRL_Char $04,$05
\       ----------------------------------------\   
\       Nack is sent by Master                  \   l       case of CTRL-Char {$00|$01|$02}
\       ----------------------------------------\   
        CMP.B #2,X                              \           $02 = ctrl_char for ABORT request
    U>= WHILE                                   \
\       ----------------------------------------\   
\       CTRL_Char $02|$03                       \   l       if ABORT request, SDA is high, SCL is low
\       ----------------------------------------\
        0= IF                                   \           if ABORT request $02 :
            MOV.B #0,&{UARTI2CS}+9              \               set echo ON I2C_Master side
            CALL #UART_RXON                     \               resume UART downloading source file
            BEGIN                               \   
                BIC #UCRXIFG,&TERM_IFG          \               clear UCRXIFG
                MOV &FREQ_KHZ,X                 \               1000, 2000, 4000, 8000, 16000, 240000
\                BEGIN MOV #32,W                 \           2~        <-------+ windows 10 seems very slow...
\                    BEGIN SUB #1,W              \           1~        <---+   | ==> ((32*3)+5)*FREQ_KHZ/1000 = 101ms delay
\                    0= UNTIL                    \           2~ 3~ loop ---+   | to refill its USB buffer
\                    SUB #1,X                    \           1~                |
\                0= UNTIL                        \           2~ 101~ loop -----+
               BEGIN MOV #65,W                  \           2~        <-------+ linux with minicom seems very very slow...
                   BEGIN SUB #1,W               \           1~        <---+   | ==> ((65*3)+5)*FREQ_KHZ/1000 = 200ms delay
                   0= UNTIL                     \           2~ 3~ loop ---+   | to refill its USB buffer
                   SUB #1,X                     \           1~                |
               0= UNTIL                         \           2~ 200~ loop -----+
                BIT #UCRXIFG,&TERM_IFG          \               4 new char in TERMRXBUF during this delay ?
            0= UNTIL                            \               2 yes, the input stream may be still active: loop back
        THEN    
    REPEAT                                      \           loop back to reSTART RX
\   --------------------------------------------\
\   I2C_Master_RX Send STOP                     \           remainder: CTRL_Chars $00,$01
\   --------------------------------------------\ 
    CALL #I2CM_STOP                             \
\   vvvvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvvvvvv\
    BIC.B #LED2,&LED2_OUT                       \ green led OFF = endof I2C RX
\   ^^^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^^^^^^^^\
\   ============================================\
\   END OF I2C MASTER RX                        \   here I2C_bus is freed, Nack on Ctrl_char $00|$01 remains to be processed.
\   ============================================\
    CMP.B #0,X                                  \
\   --------------------------------------------\
\   I2C_Slave ACCEPT ctrl_char $00              \ I2C_Slave requests I2C_Master to stop RX
\   --------------------------------------------\
\   en début de sa routine ACCEPT, I2C_Slave envoie sur le bus I2C le caractère de contrôle $00
\   avant de s'endormir avec SLEEP.
\   Quand I2C_Slave est sorti de son sommeil par un START RX, il renvoie aussi un $00.
\   I2C_Master envoie alors ce NACK + STOP pour signifier la fin de la transaction.
\   --------------------------------------------\
\   I2C_Master se réveillera au premier caractère saisi sur le TERMINAL ==> TERM_INT,
\   ou en fin du temps TxIFG ==> 500MS_INT      \
    0= IF                                       \ prepare U2I_TERM_INT environment
        MOV #SLEEP,PC                           \ which executes SLEEP_U2I then RXON, enabling TERMINAL TX, before LPM0 shut down.
    THEN                                        \                             
\   --------------------------------------------\
\   I2C_Slave KEY ctl_char $01                  \ I2C_Slave request for KEY input
\   --------------------------------------------\
\   Quand I2C_Master reçoit ce caractère de contrôle,
\   il attend un caractère en provenance de TERMINAL UART
\   et une fois ce caractère reçu ReStart TX pour l'envoyer à I2C_Slave
    CALL #UART_RXON                             \ enables TERMINAL to TX; use no registers
    BEGIN                                       \ wait for a char
        BIT #UCRXIFG,&TERM_IFG                  \ received char ?
    0<> UNTIL                                   \ 
    CALL #UART_RXOFF                            \ stops UART RX; use no registers
    MOV #0,T                                    \ ready to store KEY char as last char to be received
    GOTO BW2                                    \ goto end of UART RX line input
    ENDCODE                                     \ 
\   ********************************************\

\   --------------------------------------------\
    HDNCODE SLEEP_U2I                           \ new SLEEP_APP subroutine called by SLEEP before shutdown
\   --------------------------------------------\
    KERNEL_ADDON LF_XTAL TSTBIT                 \
    [IF]    MOV #%1_1001_0100,&TB0CTL ; if ACLK=LFXTAL  \ 3 (re)starts RX_timer,ACLK=LFXTAL=32768/4=8192Hz,up mode,clear timer
    [ELSE]  MOV #%1_0001_0100,&TB0CTL ; if ACLK=VLO     \ 3 (re)starts RX_timer,ACLK=VLO=8kHz, up mode,clear timer
    [THEN]                                      \
    MOV.B &{UARTI2CS}+9,W                       \ 3 W = HALF_DUPLEX = $04 if NOECHO, $05 if ECHO
    MOV #'CR',S                                 \ 2 S = 'CR' = penultimate char of line to be RXed by UART
    MOV #0,T                                    \ 2 T = init buffer pointer for UART_TERMINAL input
    BIC #BIT6,&P1IFG                            \ 3 clear P1.6 IFG
    MOV &{UARTI2CS}+2,PC                        \ which executes RXON, enabling TERMINAL TX, before LPM0 shut down.
    ENDCODE                                     \
\   --------------------------------------------\

\   ----------------------------\
    HDNCODE INIT_U2I            \ adds the INIT_HARD_APP to HARD_APP called by PUC|WARM
\   ----------------------------\ 
\   init 500MS_INT              \ used to scan I2C_Slave hard RESET and to slow down (re)START RX loop
\   ----------------------------\ 
\    MOV #%10_1101_0100,&TB0_CTL \ ACLK/4=8192Hz, up mode, clear timer
    MOV #4096,&TB0CCR0          \ time  0.5s
\ ------------------------------\
\ set TB0.2 to generate pulse   \
\ ------------------------------\
    MOV #$60,&TB0CCTL2          \ output mode = set/reset
    MOV #4095,&TB0CCR2          \ 0.12 ms pulse
    BIS.B #BIT7,&P1DIR          \ P1.7 as output
    BIS.B #BIT7,&P1SEL1         \ P1.7 as TB0.2 output
    BIS.B #BIT6,&P1IE  
\   ----------------------------\
\   init I2C_MASTER I/O         \ see \inc\your_target.pat to find I2C MASTER SDA & SCL pins (as SM_BUS)
\   ----------------------------\
    BIC.B #SM_BUS,&I2CSM_REN    \ remove internal pull up resistors because the next instruction which change them to pull down resistors
    BIC.B #SM_BUS,&I2CSM_OUT    \ preset SDA + SCL output LOW
\   ----------------------------\
\   vvvvvvvvv OPTION vvvvvvvvvvv\
    BIS.B #LED1,&LED1_DIR       \ set red led (I2C TX) pin as output
    BIS.B #LED2,&LED2_DIR       \ set green led (I2C RX) pin as output
\   ^^^^^^^^^ OPTION ^^^^^^^^^^^\
\   ----------------------------\
\   run previous INIT_HARD_APP  \
\   ----------------------------\
    CALL &{UARTI2CS}            \ execute previous INIT_HARD_APP to init TERM_UC, activates I/O.
\   ----------------------------\ TOS = SYSRSTIV = $00|$02|$04|$0E|$xx = POWER_ON|RST|SVSH_threshold|SYS_failures 
\   define new SYSRSTIV select  \
\   ----------------------------\
    CMP #$0E,TOS                \ SVSHIFG SVSH event ?
    0<> IF                      \ if not
        CMP #$0A,TOS            \   SYSRSTIV >= violation memory protected areas ?
        U>= ?GOTO BW1           \   if yes goto REMOVE_U2I, RET to WARM+4.
    THEN                        \ else TOS = SYSRSTIV = {$02,$06,$0E} as: {PWR_ON,RST,SVSH_Threshold}
    BIS.B #BIT6,&P1IFG          \ to force wake up from SLEEP to execute 500MS_INT.
\   ----------------------------\
    MOV #ABORT,PC               \   skip WARM message, goto ABORT --> ACCEPT --> SLEEP.
    ENDCODE                     \
\   ----------------------------\
\
\
\ ==============================================================================
\ Driver UART to I2C to do a bridge USB to I2C_FastForth devices
\ ==============================================================================
\
\ I2C address mini = 10h, maxi = 0EEh (I2C-bus specification and user manual V6)
\ type on TERMINAL "$12 UARTI2CS" to link teraterm TERMINAL with FastForth I2C_Slave target at address $12

\ UARTI2CS starts the USB to I2C bridge, to quit: TERATERM(Alt-B) or USB_to_I2C_bridge(SW2)
\   --------------------------------\
    : UARTI2CS                      \ I2C_Addr&b0 --        
\   --------------------------------\               init UARTI2CS environment.
    'CR' EMIT 'LF' EMIT             \   
    HI2LO
    MOV @RSP+,IP                    \
    BEGIN
        BIT #1,&TERM_STATW          \               uart busy ?
    0= UNTIL                        \               wait end of 'LF' TX
    CMP #RET_ADR,&{UARTI2CS}-2      \
    0= IF
        MOV #REMOVE_U2I,&{UARTI2CS}-2   \               MARKER_DOES of {UARTI2CS} will CALL &{UARTI2CS}-2 = CALL #REMOVE_U2I
        MOV &HARD_APP,&{UARTI2CS}       \               save previous HARD_APP to {UARTI2CS}
        MOV &SLEEP_APP,&{UARTI2CS}+2    \               save previous SLEEP_APP to {UARTI2CS}+2
        MOV &TERM_VEC,&{UARTI2CS}+4     \               save previous TERM_VEC value to {UARTI2CS}+4, see target.pat
        MOV &P1_VEC,&{UARTI2CS}+6       \               save previous P1_VEC value to {UARTI2CS}+6
        MOV TOS,&{UARTI2CS}+8           \ -- I2C_Addr&0 save I2C address, set ECHO
\        MOV.B #0,&{UARTI2CS}+9          \               set ECHO ON
    THEN
    MOV #0,TOS                      \ -- 0          to enter in INIT_U2I with 0 SYS
    MOV #INIT_U2I,&HARD_APP         \               replace HARD_APP by new INIT_U2I
    MOV #SLEEP_U2I,&SLEEP_APP       \               replace HARD_APP by new INIT_U2I
    MOV #U2I_TERM_INT,&TERM_VEC     \               set TERM_VEC with U2I_TERM_INT
    MOV #500MS_INT,&P1_VEC          \               set P1_VEC as 500MS_INT
    MOV #INIT_U2I,PC                \               load INIT_U2I
    ENDCODE                         \
\   --------------------------------\

    RST_SET ECHO    

    $12 UARTI2CS   ; TERATERM(Alt-B) or USB_to_I2C_bridge(SW2) to quit
