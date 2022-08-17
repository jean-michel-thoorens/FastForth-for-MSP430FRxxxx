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
\ MSP430ASSEMBLER, CONDCOMP
\
\ ================================================================================
\ REGISTERS USAGE for embedded MSP430 ASSEMBLER
\ ================================================================================
\ don't use R2, R3,
\ R4, R5, R6, R7 must be PUSHed/POPed before/after use
\ scratch registers S to Y are free,
\ under interrupt, IP is free,
\ Apply FORTH rules for TOS, PSP, RSP registers use.
\
\ PUSHM order : PSP,TOS, IP, S , T , W , X , Y ,rDOVAR,rDOCON,rDODOES,rDOCOL, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5   ,  R4  , R3, R2, R1, R0
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack
\
\ ASSEMBLER conditionnal usage before IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before          ?GOTO : S< S>= U< U>= 0= 0<> 0< 
\
\ ================================================================================
\ driver to load a binary file as core program
\ ================================================================================
\ 
\
\ how it works
\ ------------
\
\ 1- compile this file.4TH as FORTH program,
\ 2- copy it in RAM @ SD_BUF then executes it:
\ 3- wait UART RX the TI formated file.txt.
\ 4- load bytes in INFO|MAIN memory, at addresse next '@'flag
\ 5- performs a software BOR after RX 'q' flag.

\ no interruptions, no subroutines
\ --------------------------------


; ----------------------------------------------------------------------
; LOADBIN.f (UART to I2C_Slave bridge)
; ----------------------------------------------------------------------

\ first, we do some tests to allow downloading application
    CODE ABORT_LOADBIN
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #$3C00,TOS          \ BIT13|BIT12|BIT11|BIT10 test
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (UART TERMINAL), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #309,TOS            \ FastForth V3.9
    COLON
    $0D EMIT                \ return to column 1 without CR
    ABORT" FastForth V3.9 please!"
    ABORT" <-- Ouch! unexpected I2C_FastForth target!"
    PWR_RET               \ remove the ABORT_UARTI2CS definition before continuing the download.
    ;

    ABORT_LOADBIN      \ abort test


\ https://forth-standard.org/standard/core/CR
\ CR      --               send CR+LF to the output device
    [UNDEFINED] CR
    [IF]
    DEFER CR    \ DEFERed definition, by default executes that of :NONAME

    :NONAME
    'CR' EMIT 'LF' EMIT
    ; IS CR
    [THEN]


; ******************************************
    HDNCODE U2I_TERM_INT                    \ UART RX interrupt starts on first char of each line sent by TERMINAL
; ******************************************
    ADD #4,RSP                              \ 1 remove unused PC_RET and SR_RET
\ ------------------------------------------\
    MOV &{UARTI2CS}+16,W                    \ 3 W = HALF_DUPLEX = 0 if ECHO, -1 if NOECHO
    MOV #SD_BUF,T                          \ 2 T = buffer pointer for UART_TERMINAL input
    MOV #$0D,S                              \ 2 S = 'CR' = penultimate char of line to be RXed by UART
    BEGIN                                   \
        MOV.B &TERM_RXBUF,Y                 \ 3 move char from TERM_RXBUF...
        ADD #1,T                            \ 1
        MOV.B Y,-1(T)                       \ 3 ... to input buffer
        CMP.B Y,S                           \ 1 char = CR ? (if yes goto next REPEAT)
    0<> WHILE                               \ 2 if <>
        CMP #4,W                            \ 1 HALF_DUPLEX ?
        0<> IF                              \ 2 no, echo is ON
            BEGIN                           \   )
                BIT #2,&TERM_IFG            \ 3 > Test TX_Buf empty, mandatory for low baudrates
            0<> UNTIL                       \ 2 )
            MOV.B Y,&TERM_TXBUF             \ 3 echo char to UART_TERMINAL
        THEN                                \
        BEGIN                               \ 
            BIT #1,&TERM_IFG                \ 3 wait for next char received
        0<> UNTIL                           \ 2 
    REPEAT                                  \ 2 31 cycles loop ==> up to UART 2.58 Mbds @ 8MHz
    CALL #UART_RXOFF                        \ stops UART RX still char CR is received, the LF char is being transmitted.
    BEGIN                                   \
        BIT #1,&TERM_IFG                    \ 3 char LF received ?
    0<> UNTIL                               \ 2
\ ------------------------------------------\
BW2                                         \   <=== Ctrl_char $01 (KEY input)
\ ------------------------------------------\
    MOV.B &TERM_RXBUF,S                     \ 3 S = last char RXed by UART (LF|KEY)
    MOV.B S,0(T)                            \ 4 store it into buffer
\ ==========================================\
\ ==========================================\ here I2C_Slave is sleeping in its ACCEPT routine
\ PARSE LINE                                \
\ ==========================================\
\ ==========================================\          
    MOV #SD_BUF+1,S                         \
    CMP.B #'q',-1(S)
    0= IF                                   \ end of file.txt
    ELSE
        CMP.B #'@'-1(S)                     \ case of address
        0= IF
        MOV.B @S+,X
        SUB #$30,X
        MOV X,Y
        RLAM #4,Y
        MOV @S+,X
        SUB #$30,X
        BIS X,Y
        
        
        M
        ELSE
        MOV
\ vvvvvvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvv\
    BIS.B #LED1,&LED1_OUT                   \ red led ON = I2C TX
\ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\
\ ------------------------------------------\
\ I2C_Master_TX_Start                       \ here, SDA and SCL must be in idle state
\ ------------------------------------------\
    BIS.B   #SM_SDA,&I2CSM_DIR              \ 3 l  v_ force SDA low when SCL is high = START
    MOV.B   &I2CS_ADR,X                     \ 3 h     X = Slave_Address
    MOV     #SD_BUF,Y                      \ 2 h     Y = buffer pointer for I2C_Master TX
    NOP3                                    \ 3 h _
    BIS.B   #SM_SCL,&I2CSM_DIR              \ 3 h  v_ force SCL as output (low)
\   ----------------------------------------\
    BEGIN
\   ----------------------------------------\
\   I2C_Master_TX address/Data              \
\   ----------------------------------------\
        MOV.B #8,W                          \ 1 l       prepare 8 bits address
        BEGIN                               \
            ADD.B X,X                       \ 1 l       shift one left
            U>= IF                          \ 2 l       carry set ?
                BIC.B #SM_SDA,&I2CSM_DIR    \ 3 l       yes : SDA as input  ==> SDA high because pull up resistor
            ELSE                            \ 2 l
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       no  : SDA as output ==> SDA low
            THEN                            \   l   _
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
            BEGIN                           \           we must wait I2C_Slave software
                BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       by testing SCL released
            0<> UNTIL                       \ 2 h       (because Slave can strech SCL low)
\ \           vvvvvvvvMulti-Master-Modevvvvvvv\
\             BIT.B #SM_SDA,&I2CSM_IN         \ 3 h       test SDA
\ \           ^^^^^^^^Multi-Master-Mode^^^^^^^\   _
            BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\ \           vvvvvvvvvvvvMulti-Master-Modevvvvvvvvvvv\
\             0= IF                                   \ 2 l   SDA input low
\                 BIT.B #SM_SDA,&I2CSM_DIR            \ 3 l + SDA command high
\                 0= IF                               \ 2 l = collision detected
\                     BIS.B #SM_SCL,&I2CSM_DIR        \ 4 l release SCL first
\                     CALL #DO_IDLE                   \     wait stable idle state 
\                     GOTO BW3                        \ 2 l goto START TX
\                 THEN                                \
\             THEN                                    \
\ \           ^^^^^^^^^^^^Multi-Master-Mode^^^^^^^^^^^\
            SUB #1,W                        \ 1 l       bits count-1
        0= UNTIL                            \ 2 l
\ ------------------------------------------\
        BIC.B #SM_SDA,&I2CSM_DIR            \ 3 l       after TX byte we must release SDA to read Ack/Nack from Slave
\ ------------------------------------------\
\   I2C_Master_TX get Slave Ack/Nack        \
\   ----------------------------------------\       _
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
\        BEGIN                               \
\            BIT.B #SM_SCL,&I2CSM_IN         \ 3 h      testing SCL released is useless
\        0<> UNTIL                           \ 2 h      because no risk of Slave streching SCL low
        NOP3                                \ 3 h       replaced by NOP3.
        BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA state
        BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low, to keep I2C_BUS until next I2C_MASTER START (RX|TX)
\ ------------------------------------------\
    0= WHILE \ 1- Slave Ack received        \ 2 l       out of loop if Nack (goto THEN next REPEAT) 
\ ------------------------------------------\
\   I2C_Master_TX_data_loop                 \
\ ------------------------------------------\
        CMP S,T                             \ 1         last char TXed = last char RXed ? (when address is sent, T = 16bits <> S = 8bits)
\ ------------------------------------------\
    0<> WHILE \ 2- TXed char <> last char   \ 2         out of loop if TXed char T = last char S to be TXed (goto below REPEAT)
\ ------------------------------------------\
        MOV.B @Y+,X                         \ 2 l       get next RXed char
        MOV X,T                             \ 1         T = last TX char for comparaison above, on next loop.
    REPEAT                                  \           <-- WHILE2  search "Extended control-flow patterns" in https://forth-standard.org/standard/rationale.. 
    THEN                                    \           <-- WHILE1 case of I2C_Slave Nack on Master_TX
\ vvvvvvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvv\
    BIC.B #LED1,&LED1_OUT                   \   red led OFF = endof I2C TX
\ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\
    GOTO FW1                                \   X > 4 ==> reSTART RX repeated every 1/2s 
\ ==========================================\
\ END OF I2C MASTER TX                      \ SCL is kept low until START RX  --┐
\ ==========================================\                                   |
    ENDCODE                                 \                                   |
\ ******************************************\                                   v
\
\
\

; ******************************************
    HDNCODE 500MS_INT                       \ wakes up every 1/2s to listen I2C Slave or break from TERMINAL.
; ******************************************
    ADD #4,RSP                              \ 1 remove PC_RET and SR_RET        |
\ ------------------------------------------\                                   |
FW1                                         \ <-- the next of TERM_INT above <--┘
BW3                                         \ <=== multi master RX
\                                           \ <-- the next of INI_U2I below  <--┐
\ ------------------------------------------\                                   |
    BIT #BIT14,&KERNEL_ADDON                \ 3 KERNEL_ADDON(BIT14) = LF XTAL flag
    0= IF                                   \ if no LF XTAL
\        MOV #%0001_0101_0110,&TA0CTL        \ 3 (re)starts RX_timer,ACLK=VLO=8kHz,/2=4096Hz,up mode,clear timer,enable TA0 int, clear IFG
        MOV #%0001_0101_0110,&TB0CTL        \ 3 (re)starts RX_timer,ACLK=VLO=8kHz,/2=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
    ELSE                                    \ if LF XTAL
\        MOV #%0001_1101_0110,&TA0CTL        \ 3 (re)starts RX_timer,ACLK=LFXTAL=32768,/8=4096Hz,up mode,clear timer,enable TA0 int, clear IFG
        MOV #%0001_1101_0110,&TB0CTL        \ 3 (re)starts RX_timer,ACLK=LFXTAL=32738,/8=4096Hz,up mode,clear timer,enable TB0 int, clear IFG
    THEN                                    \
\   ========================================\
\   I2C_MASTER RX                           \ le driver I2C_Master envoie START RX en boucle continue (X < 4) ou discontinue (X >= 4).
\   ========================================\ le test d'un break en provenance de l'UART est intégré dans cette boucle.
    BEGIN \   I2C MASTER START RX           \ ABORT|WARM loop back
\       ------------------------------------\       _
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL to enable ReSTART RX
        BIT #8,&TERM_STATW                  \ 3         break (Alt+B) sent by TERATERM ?
        0<> IF                              \ 2         goto REMOVE_U2I, exit to WARM+4.
            MOV #REMOVE_U2I,PC
        THEN
        BIT.B #SW2,&SW2_IN                  \ 3 SW2 pressed ?
        0= IF                               \ 2 goto REMOVE_U2I then RET to BODY of WARM
            MOV #REMOVE_U2I,PC
        THEN
\       ------------------------------------\
\       I2C_Master_RX_Start_Cond            \   here, SDA and SCL must be in idle state
\       ------------------------------------\     _
        BIS.B   #SM_SDA,&I2CSM_DIR          \ 3 l  v_   force SDA as output (low)
        MOV.B   &I2CS_ADR,Y                 \ 3 h       X = Slave_Address
        BIS.B   #1,Y                        \ 1 h       set Master RX
        NOP2                                \ 2   _
        BIS.B   #SM_SCL,&I2CSM_DIR          \ 3 h  v_   force SCL as output (low)
\       ------------------------------------\
\       I2C_Master_RX_Send_address          \           may be SCL is held low by slave
\       ------------------------------------\
        MOV.B #8,W                          \ 1 l       prepare 8 bits address
        BEGIN                               \
            ADD.B Y,Y                       \ 1 l       shift one left
            U>= IF                          \ 2 l       carry set ?
                BIC.B #SM_SDA,&I2CSM_DIR    \ 3 l yes : SDA as input  ==> SDA high because pull up resistor
            ELSE                            \ 2 l
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l no  : SDA as output ==> SDA low
            THEN                            \       _
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
\            BEGIN                           \
\                BIT.B #SM_SCL,&I2CSM_IN     \ 3 h      testing SCL released is useless
\            0<> UNTIL                       \ 2 h      because no risk of Slave streching SCL low
            NOP3                            \ 3         replaced by NOP3
\ \           vvvvvvMulti-Master-Modevvvvvvvvv\
\             BIT.B #SM_SDA,&I2CSM_IN         \ 3 h     test SDA
\ \           ^^^^^^Multi-Master-Mode^^^^^^^^^\   _
            BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_  force SCL as output (low)
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
            SUB #1,W                        \ 1 l       bits count - 1
        0= UNTIL                            \ 2 l
\       ------------------------------------\
\       Wait Ack/Nack on address            \           
\       ------------------------------------\       _
        BIC.B   #SM_SDA,&I2CSM_DIR          \ 3 l _^_   after TX address we must release SDA to read Ack/Nack from Slave
        BIC.B   #SM_SCL,&I2CSM_DIR          \ 3 l _^    release SCL (high)
        BEGIN                               \           we must wait I2C_Slave software
            BIT.B #SM_SCL,&I2CSM_IN         \ 3 h       by testing SCL released
        0<> UNTIL                           \ 2 h       (because Slave can strech SCL low)
        BIT.B   #SM_SDA,&I2CSM_IN           \ 3 h _     get SDA
        BIS.B   #SM_SCL,&I2CSM_DIR          \ 3 h  v_   SCL as output : force SCL low
\       ------------------------------------\  
        0<> IF   \ Nack_On_Address          \ 2 l
\           --------------------------------\  
\           I2C_Master Send STOP            \
\           --------------------------------\
            CALL #I2CSTOP                   \
            MOV #'.',&TERM_TXBUF            \           to see when no I2C_target is linked
            MOV #SLEEP,PC                   \ 4         goto dodo for 1/2 s .. wake up by 500MS_INT
        THEN                                \ 2
\       ------------------------------------\
\       I2C_Master_RX_data                  \
\       ------------------------------------\
\       vvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvv\
        BIS.B #LED2,&LED2_OUT               \           green led ON = I2C RX
\       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\
        BEGIN                               \
            BEGIN                           \
                BIC.B #SM_SDA,&I2CSM_DIR    \ 4 l       after Ack and before RX next byte, we must release SDA
                MOV.B #8,W                  \ 1 l       prepare 8 bits transaction
\               ----------------------------\
                BEGIN                       \
\                   ----------------------------\       _
\                   do SCL pulse                \ SCL _| |_
\                   ----------------------------\       _
                    BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
\                   BEGIN                        \
\                   BIT.B #SM_SCL,&I2CSM_IN      \ 3 h       testing SCL released is useless
\                   0<> UNTIL                    \ 2 h       because no risk of Slave streching SCL low
                    NOP3                        \ 3          replaced by NOP3 
                    BIT.B #SM_SDA,&I2CSM_IN     \ 3 h _     get SDA
                    BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_   SCL as output : force SCL low   13~
                    ADDC.B X,X                  \ 1 l       C <--- X(7) ... X(0) <--- SDA
                    SUB #1,W                    \ 1 l       count down of bits
                0= UNTIL                        \ 2 l       here, slave releases SDA
\               ----------------------------\
\               case of RX data $FF         \
\               ----------------------------\
                CMP.B #-1,X                 \ 1
                0= IF                       \ 2         received char $FF: let's consider that the slave is lost...
                    MOV #2,X                \           to do ABORT action
                THEN                        \
\               ----------------------------\
                CMP.B #8,X                  \ 1 l       $08 = char BS
            U>= WHILE                       \ 2 l       ASCII char received, from char 'BS' up to char $7F.
\               ----------------------------\
                BEGIN                       \
                    BIT #2,&TERM_IFG        \ 3 l       UART TX buffer empty ?
                0<> UNTIL                   \ 2 l       loop if no
\               ----------------------------\   
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       prepare Ack
\               ----------------------------\
\               I2C_Master_RX Send Ack      \           on ASCII char >= $08
\               ----------------------------\       _   
                BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
                BEGIN                       \           we must wait I2C_Slave software
                    BIT.B #SM_SCL,&I2CSM_IN \ 3 h       by testing SCL released
                0<> UNTIL                   \ 2 h       (because Slave can strech SCL low)
\               ----------------------------\
                MOV.B X,&TERM_TXBUF         \ 3 h       send RXed ASCII char to UART TERMINAL
\               ----------------------------\     _
                BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_   SCL as output : force SCL low
            REPEAT                          \ 2 l       loop back to I2C_Master_RX_data for chars >= 8
\           --------------------------------\
\           case of RX CTRL_Chars < $08     \           here Master holds SCL low, Slave can test it: CMP #8,&TERM_STATW
\           --------------------------------\           see forthMSP430FR_TERM_I2C.asm
            CMP.B #4,X                      \ 1         
            U>= IF                          \ 2
                MOV X,&{UARTI2CS}+16        \           set NOECHO = $04, ECHO = $05
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       prepare Ack for Ctrl_Chars $04 $05
            THEN                            \
\           --------------------------------\
\           Master_RX send Ack/Nack on data \           Ack for $04, $05, Nack for $00, $01, $02
\           --------------------------------\       _   
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
            BEGIN                           \           we must wait I2C_Slave software
                BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       by testing SCL released
            0<> UNTIL                       \ 2 h       (because Slave can strech SCL low)
            BIT.B #SM_SDA,&I2CSM_IN         \ 3 h _     get SDA as TX Ack/Nack state
            BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\           --------------------------------\   l    
        0<> UNTIL                           \           if Ack, loop back to Master_RX data for CTRL_Char $04,$05
\       ------------------------------------\   
\       Nack is sent by Master              \   l       case of CTRL-Char {$00|$01|$02|$03}
\       ------------------------------------\   
        CMP.B #2,X                          \           $02 = ctrl_char for ABORT request
    0= WHILE                                \
\       ------------------------------------\   
\       CTRL_Char $02                       \   l       if ABORT request, SDA is high, SCL is low
\       ------------------------------------\
        MOV #0,&{UARTI2CS}+16               \               set echo ON I2C_Master side
        CALL #UART_RXON                     \               resume UART downloading source file
        BEGIN                               \   
            BIC #UCRXIFG,&TERM_IFG          \               clear UCRXIFG
            MOV &FREQ_KHZ,Y                 \               1000, 2000, 4000, 8000, 16000, 240000
            BEGIN MOV #32,W                 \           2~        <-------+ windows 10 seems very slow...
                BEGIN SUB #1,W              \           1~        <---+   | ==> ((32*3)+5)*1000 = 101ms delay
                0= UNTIL                    \           2~ 3~ loop ---+   | to refill its USB buffer
                SUB #1,Y                    \           1~                |
            0= UNTIL                        \           2~ 101~ loop -----+
\           BEGIN MOV #65,W                 \                  <-------+ linux with minicom seems very very slow...
\               BEGIN SUB #1,W              \                  <---+   | ==> ((65*3)+5)*1000 = 200ms delay
\               0= UNTIL                    \           3~ loop ---+   | to refill its USB buffer
\               SUB #1,Y                    \                          |
\           0= UNTIL                        \           200~ loop -----+
            BIT #UCRXIFG,&TERM_IFG          \               4 new char in TERMRXBUF during this delay ?
        0= UNTIL                            \               2 yes, the input stream may be still active: loop back
    REPEAT                                  \   l       loop back to reSTART RX
\   ----------------------------------------\
\   I2C_Master_RX Send STOP                 \   l       remainder: CTRL_Chars $00,$01
\   ----------------------------------------\ 
    CALL #I2CSTOP                           \
\   vvvvvvvvvvvvvvv OPTION vvvvvvvvvvvvvvvvv\
    BIC.B #LED2,&LED2_OUT                   \ green led OFF = endof I2C RX
\   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\
\   ========================================\
\   END OF I2C MASTER RX                    \   here I2C_bus is freed, Nack on Ctrl_char $FF|$00|$01 remains to be processed.
\   ========================================\
\   I2C_Slave KEY ctl_char $01              \ I2C_Slave request for KEY input
\   ----------------------------------------\
    CMP.B #1,X                              \
\   Quand I2C_Master reçoit ce caractère de contrôle,
\   il attend un caractère en provenance de TERMINAL UART
\   et une fois ce caractère reçu reSTART TX pour l'envoyer à I2C_Slave
    0= IF                                   \
        MOV #SD_BUF,T                      \ ready to store KEY char: MOV.B S,0(T)
        CALL #UART_RXON                     \ enables TERMINAL to TX; use no registers
        BEGIN                               \ wait for a char
            BIT #UCRXIFG,&TERM_IFG          \ received char ?
        0<> UNTIL                           \ 
        CALL #UART_RXOFF                    \ stops UART RX then
        GOTO BW2                            \ goto end of UART RX line input, for receiving last char
    THEN                                    \                             
\   ----------------------------------------\
\   I2C_Slave ACCEPT ctrl_char $00          \ I2C_Slave requests I2C_Master to stop RX and start TX
\   ----------------------------------------\
\   en début de sa routine ACCEPT, I2C_Slave envoie sur le bus I2C le caractère de contrôle $00
\   avant de s'endormir avec SLEEP
\   I2C_Master envoie NACK + STOP pour signifier la fin de la transaction.
\   ----------------------------------------\
\   et si I2C_Slave est sorti de son sommeil par un START RX, idem.
\   ----------------------------------------\
    MOV #SLEEP,PC                           \ executes RXON (that enables TERMINAL to TX) before LPM0 shut down.
\   ----------------------------------------\
\   I2C_Master se réveillera au premier caractère saisi sur le TERMINAL ==> TERM_INT,
\   ou en fin du temps TxIFG ==> 500MS_INT\
    ENDCODE                                \ 
\   ***************************************\

\   ----------------------------\
    HDNCODE INI_U2I             \ define INI_HARD_APP subroutine called by PUC|WARM
\   ----------------------------\ 
\   init 500MS_INT              \ used to scan I2C_Slave hard RESET and to slow (re)START RX loop
\   ----------------------------\ 
    MOV #$800,&TB0CCR0          \ time = (2047+1)/4096 = 0.5s
\    MOV #$800,&TA0CCR0          \ time = (2047+1)/4096 = 0.5s
\   ----------------------------\
\   init I2C_MASTER I/O         \ see \inc\your_target.pat to find I2C MASTER SDA & SCL pins (as SM_BUS)
\   ----------------------------\
    BIC.B #SM_BUS,&I2CSM_REN    \ remove internal pull up resistors because external 3k3 pullup resistors
    BIC.B #SM_BUS,&I2CSM_OUT    \ preset SDA + SCL output LOW
\   ----------------------------\
\   vvvvvvvvv OPTION vvvvvvvvvvv\
    BIS.B #LED1,&LED1_DIR       \ set red led (I2C TX) pin as output
    BIS.B #LED2,&LED2_DIR       \ set green led (I2C RX) pin as output
\   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^\
\   ----------------------------\
    CALL &{UARTI2CS}+10         \ previous INI_APP executing init TERM_UC, activates I/O and sets TOS = RSTIV_MEM.
\   ----------------------------\ TOS = SYSRSTIV = $00|$02|$04|$0E|$xx = POWER_ON|RST|SVSH_threshold|SYS_failures 
    CMP #$0E,TOS                \ SVSHIFG SVSH event ?
    0<> IF                      \ if not
        CMP #$0A,TOS            \   RSTIV_MEM >= violation memory protected areas ?
        U>= IF                  \   goto REMOVE_U2I then RET to BODY of WARM
            MOV #REMOVE_U2I,PC
        THEN
    THEN                        \ RSTIV_MEM = {$00,$02,$04,$6,$0E} as: {WARM,PWR_ON,RST,COLD,SVSH_Threshold}
    BIT.B #SW2,&SW2_IN          \ SW2 pressed (RST+SW2) ?
    0= IF                       \   goto REMOVE_U2I then RET to BODY of WARM
        MOV #REMOVE_U2I,PC
    THEN
    MOV #0,&RSTIV_MEM           \ clear RSTIV_MEM before next RST event!
    MOV #500MS_INT+2,PC         \ goto I2C_Master START RX loop+2, with no other return than ALT+B|SW2+RST 
\   ----------------------------\
    ENDCODE                     \
\   ----------------------------\
\
\ ==============================================================
\ Driver UART to I2CM which does the bridge USB to I2C_FastForth
\ ==============================================================

\ I2C address mini = 10h, maxi = 0EEh (I2C-bus specification and user manual V6)
\ type on TERMINAL "16 UARTI2CS" to link teraterm TERMINAL with FastForth I2C_Slave at address $10
\ you can also link with last known I2C_Slave address : "I2CS_ADR @ UARTI2CS"
\
    : UARTI2CS                          \ I2C_Slave_Address_%0 --
    CR I2CS_ADR !                       \ -- 
    HI2LO
    CMP #RET_ADR,&{UARTI2CS}+8          \
    0= IF                               \ save parameters only if MARKER_DOES is not initialized
        MOV #REMOVE_U2I,&{UARTI2CS}+8   \ MARKER_DOES of {UARTI2CS} will do CALL &{UARTI2CS}+8 = CALL #REMOVE_U2I
        MOV &WARM+2,&{UARTI2CS}+10      \ save previous INI_APP from WARM PFA to {UARTI2CS}+10
        MOV #INI_U2I,&WARM+2            \ replace INI_APP by new INI_U2I
        MOV &TERM_VEC,&{UARTI2CS}+12    \ save previous TERM_VEC value to {UARTI2CS}+12, see target.pat
        MOV #U2I_TERM_INT,&TERM_VEC     \ set TERM_VEC with U2I_TERM_INT
\        MOV &TA0_X_VEC,&{UARTI2CS}+14   \ save previous TA0_X_VEC value to {UARTI2CS}+14
\        MOV #500MS_INT,&TA0_X_VEC       \ set TA0_X_VEC with 500MS_INT
        MOV &TB0_X_VEC,&{UARTI2CS}+14   \ save previous TB0_X_VEC value to {UARTI2CS}+14
        MOV #500MS_INT,&TB0_X_VEC       \ set TB0_X_VEC with 500MS_INT
        MOV #0,&{UARTI2CS}+16           \ reset Half_Duplex variable (set ECHO ON)
    THEN
    MOV #WARM,PC                        \ execute INI_U2I then goto BW3; abort with Alt-B or SW2+RST.
    ENDCODE                             \ when there is no i2C slave at the provided address, UARTI2CS sends to TERMINAL a LF char each 1/2s.

    RST_SET
    ECHO 18 UARTI2CS     ; TERATERM(Alt-B) or I2C_Master(SW2) to quit
