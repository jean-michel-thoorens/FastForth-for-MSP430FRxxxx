\ name : MSP430FR5xxx_I2CF_Soft_Master.asm

WIPE
\ NOECHO

\ version 2.0 2015-07-30
\
\
\ -------------------------------------------------------------------------------------------------------------------\
\ I2CF Soft MASTER, FAST MODE, 8MHz
\ -------------------------------------------------------------------------------------------------------------------\

\ ======================================================================================================
\ ======================================================================================================

\ ###  #####   #####  ######     #####                         #     #
\  #  #     # #     # #         #     #  ####  ###### #####    ##   ##   ##    ####  ##### ###### #####
\  #        # #       #         #       #    # #        #      # # # #  #  #  #        #   #      #    #
\  #   #####  #       #####      #####  #    # #####    #      #  #  # #    #  ####    #   #####  #    #
\  #  #       #       #               # #    # #        #      #     # ######      #   #   #      #####
\  #  #       #     # #         #     # #    # #        #      #     # #    # #    #   #   #      #   #
\ ### #######  #####  #          #####   ####  #        #      #     # #    #  ####    #   ###### #    #

\ ======================================================================================================
\ ======================================================================================================

\ use Px.0 to Px.3 pins as SCL and SDA pins to use immediate instruction in one byte (#1,#2,#4,#8)

\ tested with P1.6 SDA, P1.7 SCL :
\ Start + Adr + Write 3 bytes + Stop + Start + adr + read 2 bytes + stop = 300us ==> 210 kHz 
\ See MSP430FR5xxx_I2CF_Soft_Master.png

VARIABLE I2CS_ADR   \ low(I2CS_ADR) = slave I2C address with RW flag, high(I2CS_ADR) = RX buffer,data0
2 ALLOT             \ data1,data2
VARIABLE I2CM_BUF   \ low(I2CM_BUF) = RX or TX lentgh, high(I2CM_BUF) = TX buffer,data0
2 ALLOT             \ data1,data2
    \

\ ----------------------------------\
AMS I2C_MTX                         \ MASTER TX \ shared code for address and TX data
\ ----------------------------------\
BEGIN                               \
    ADD.B   X,X                     \ 1 l     shift one left
    U>= IF                          \ 2 l carry set ?
        BIC.B #MSDA,&I2CSM_DIR      \ 4 l yes : SDA as input  ==> SDA high because pull up resistor
    ELSE                            \ 2 l
        BIS.B #MSDA,&I2CSM_DIR      \ 4 l no  : SDA as output ==> SDA low
    THEN                            \   l   _
    BIC.B #MSCL,&I2CSM_DIR          \ 4 l _^    release SCL (high)
    BEGIN                           \           14/16~l
        BIT.B #MSCL,&I2CSM_IN       \ 3 h       test if SCL is released
    0<> UNTIL                       \ 2 h _
    BIS.B #MSCL,&I2CSM_DIR          \ 4 h  v_   SCL as output : force SCL low
    SUB #1,W                        \ 1 l     count of bits
0= UNTIL                            \ 2 l
BIC.B   #MSDA,&I2CSM_DIR            \ 5 l _   SDA as input : release SDA high to prepare read Ack/Nack
MOV @RSP+,PC
ENDASM                              \

\ ==================================\
ASM I2C_M                           \
\ ==================================\
\                                   \ in    I2CS_ADR/I2CM_BUF as RX/TX buffer requested by I2CS_ADR(0(0))
\                                   \       I2CS_ADR(0) = I2C_Slave_addr&R/w
\                                   \       I2CM_BUF(0) = TX/RX count of datas
\                                   \       I2CM_BUF(0) = 0 ==> send only I2C address
\                                   \ used  S           BUF ptr
\                                   \       T           datas countdown
\                                   \       W           bits countdown
\                                   \       X           data
\                                   \ out   I2CSLA_ADR & (R/W) unCHNGd
\                                   \       S = BUF PTR pointing on first data not exCHNGd
\                                   \       T = count+1 of TX/RX datas exCHNGd
\                                   \       I2CS_ADR(0) = unCHNGd
\                                   \       I2CM_BUF(0) = count of data not exCHNGd (normally = 0)
\                                   \       I2CM_BUF(0) = -1 <==> Nack on address
\ ----------------------------------\
\ I2C_Master_Start_Cond:            \ here, SDA and SCL are in idle state
\ ----------------------------------\
BIS.B   #MSDA,&I2CSM_DIR            \ 4 l   force SDA as output (low)
MOV     #I2CM_BUF,W                 \ 2 h   W=buffer out
MOV.B   @W+,T                       \ 2 h   T=datas countdown
MOV     #I2CS_ADR,S                 \ 2 h   S=buffer in
MOV.B   @S+,X                       \ 2 h   X=Slave address to TX
BIT.B   #1,X                        \ 1 h   test I2C R/w flag
0= IF                               \ 2 h   if write
    MOV W,S                         \ 2 h   S= buffer out ptr
THEN                                \       S= buffer ptr
BIS.B   #MSCL,&I2CSM_DIR            \ 4 h   force SCL as output (low)
\ ----------------------------------\
\ I2C_Master_Start_EndOf:           \
\ ----------------------------------\
\ I2C_Master_Send_address           \       may be SCL is held low by slave
\ ----------------------------------\
ADD     #1,T                        \ 1 l   to add address in count
MOV     #8,W                        \ 1 l   prepare 8 bit Master writing
CALL    #I2C_MTX                    \ 21 l   to send address
\ ----------------------------------\
\ I2C_Master_Loop_Data              \
\ ----------------------------------\
BEGIN                               \ 4 l   here ack/nack is received/transmitted
\   --------------------------------\   l
\   Master TX/RX ACK/NACK           \
\   --------------------------------\   l   _   
    BIC.B   #MSCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
    BEGIN                           \
        BIT.B #MSCL,&I2CSM_IN       \ 3 h       test if SCL is released
    0<> UNTIL                       \ 2 h
    BIT.B   #MSDA,&I2CSM_IN         \ 3 h _     get SDA
    BIS.B   #MSCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\   --------------------------------\   l
\   I2C_Master_Loop_Data            \
\   --------------------------------\
    0<> IF  BIS #Z,SR               \ 5 l   if Nack (TX), force Z=1 ==> StopCond
    ELSE    SUB.B #1,T              \ 3 l   else dec count
    THEN                            \ l
\   --------------------------------\
\   I2C_Master_CheckCountDown       \       count=0 (TX) or Nack received
\   --------------------------------\
    0= IF                           \ 2 l   send stop
\       ----------------------------\
\       Send Stop                   \
\       ----------------------------\     _
        BIS.B #MSDA,&I2CSM_DIR      \ 4 l  v_   SDA as output ==> SDA low
        SUB.B T,&I2CM_BUF           \ 4 l   _   refresh buffer length and reach tSU:STO
        BIC.B #MSCL,&I2CSM_DIR      \ 4 l _^    release SCL (high)
        BEGIN                       \
            BIT.B #MSCL,&I2CSM_IN   \ 3 h       SCL released ?
        0<> UNTIL                   \ 2 h
        BIC.B #MSDA,&I2CSM_DIR      \ 4 h _^    SDA as input  ==> SDA high with pull up resistor
        MOV @RSP+,PC                \ RET  ====>
    THEN                            \
    MOV.B #8,W                      \ 1 l     prepare 8 bits transaction
    BIT.B #1,&I2CS_ADR              \ 3 l     I2C_Master Read/write bit test
    0= IF                           \ 2 l     write flag test
\       ============================\
\       I2C_Master_TX               \
\       ============================\
        MOV.B @S+,X                 \ 2 l     next byte to transmit
        CALL #I2C_MTX               \   l       to send data
    ELSE                            \ l
\       ============================\
\       I2C_Master_RX:              \       here, SDA is indetermined, SCL is strech low by master
\       ============================\
        BIC.B #MSDA,&I2CSM_DIR      \ 5 l       After ACK we must release SDA
        BEGIN                       \
\           ------------------------\       _
\           send bit                \ SCL _| |_
\           ------------------------\       _
            BIC.B #MSCL,&I2CSM_DIR  \ 4 l _^    release SCL (high)
            BEGIN                   \           14/16~l
              BIT.B #MSCL,&I2CSM_IN \ 3 h       test if SCL is released
            0<> UNTIL               \ 2 h
            BIT.B #MSDA,&I2CSM_IN   \ 4 h _     get SDA
            BIS.B #MSCL,&I2CSM_DIR  \ 4 h  v_   SCL as output : force SCL low   13~
            ADDC.B X,X              \ 1 l   C <-- X <--- C
            SUB #1,W                \ 1 l   count of bits
        0= UNTIL                    \ 2 l
        MOV.B X,0(S)                \ 3 l     store byte in buffer
        ADD #1,S                    \ 1 l
\       ----------------------------\
\       Compute Ack Or Nack         \ here, SDA is released by slave, SCL is strech low by master
\       ----------------------------\
        CMP.B #1,T                  \
        0<> IF                      \ 2 l
            BIS.B #MSDA,&I2CSM_DIR  \ 5 l       yes : send Ack
        THEN                        \
    THEN                            \
AGAIN                               \ 2 l
ENDASM                              \
    \



\ ==================================\
\ reduced version for TX only
\ ==================================\
VARIABLE I2CS_ADR   \ low(I2CS_ADR) = slave I2C address with RW flag
VARIABLE I2CM_BUF   \ low(I2CM_BUF) = RX or TX lentgh, high(I2CM_BUF) = TX buffer,data0
2 ALLOT             \ data1,data2
    \
\ ==================================\
ASM I2C_M_TX                        \
\ ==================================\
\                                   \ in    I2CS_ADR/I2CM_BUF as RX/TX buffer requested by I2CS_ADR(0(0))
\                                   \       I2CS_ADR(0) = I2C_Slave_addr&R/w
\                                   \       I2CM_BUF(0) = TX/RX count of datas
\                                   \       I2CM_BUF(0) = 0 ==> send only I2C address
\                                   \ used  S           BUF ptr
\                                   \       T           datas countdown
\                                   \       W           bits countdown
\                                   \       X           data
\                                   \ out   I2CSLA_ADR & (R/W) unCHNGd
\                                   \       S = BUF PTR pointing on first data not exCHNGd
\                                   \       T = count+1 of TX/RX datas exCHNGd
\                                   \       I2CS_ADR(0) = unCHNGd
\                                   \       I2CM_BUF(0) = count of data not exCHNGd (normally = 0)
\                                   \       I2CM_BUF(0) = -1 <==> Nack on address
\ ----------------------------------\
\ I2C_Master_Start_Cond:            \ here, SDA and SCL are in idle state
\ ----------------------------------\
BIS.B   #MSDA,&PI2CMDIR             \ 4 l   force SDA as output (low)
MOV     #I2CM_BUF,W                 \ 2 h   W=buffer out
MOV.B   @W+,T                       \ 2 h   T=datas countdown
MOV.B   &I2CS_ADR,X                 \ 3 h   X=Slave address to TX
BIS.B   #MSCL,&PI2CMDIR             \ 4 h   force SCL as output (low)
\ ----------------------------------\
\ I2C_Master_Start_EndOf:           \
\ ----------------------------------\
\ I2C_Master_Send_address           \       may be SCL is held low by slave
\ ----------------------------------\
ADD     #1,T                        \ 1 l   to add address in count
\ ----------------------------------\
\ I2C_Master_Loop_Data              \
\ ----------------------------------\
BEGIN                               \ 2 l
\   --------------------------------\
\   I2C_MTX                         \
\   --------------------------------\
    MOV #8,W                        \ 1 l   prepare 8 bit Master writing
    BEGIN                           \
        ADD.B   X,X                 \ 1 l     shift one left
        U>= IF                      \ 2 l carry set ?
            BIC.B #MSDA,&PI2CMDIR   \ 4 l yes : SDA as input  ==> SDA high because pull up resistor
        ELSE                        \ 2 l
            BIS.B #MSDA,&PI2CMDIR   \ 4 l no  : SDA as output ==> SDA low
        THEN                        \   l
        BIC.B #MSCL,&PI2CMDIR       \ 4 l _^    release SCL (high)
        BEGIN                       \           14/16~l
            BIT.B #MSCL,&PI2CMIN    \ 3 h       test if SCL is released
        0<> UNTIL                   \ 2 h _
        BIS.B #MSCL,&PI2CMDIR       \ 4 h  v_   SCL as output : force SCL low
        SUB #1,W                    \ 1 l     count of bits
    0= UNTIL                        \ 2 l
    BIC.B   #MSDA,&PI2CMDIR         \ 5 l _   SDA as input : release SDA high to prepare read Ack/Nack
\   --------------------------------\   l
\   Master TX/RX ACK/NACK           \
\   --------------------------------\   l     _
    BIC.B   #MSCL,&PI2CMDIR         \ 3 l _^    P1DIR.3 release SCL (high)
    BEGIN                           \
        BIT.B #MSCL,&PI2CMIN        \ 3 h       test if SCL is released
    0<> UNTIL                       \ 2 h
    BIT.B   #MSDA,&PI2CMIN          \ 3 h _     get SDA
    BIS.B   #MSCL,&PI2CMDIR         \ 3 h  v_   SCL as output : force SCL low
\   --------------------------------\   l
    0<> IF  BIS #Z,SR               \ 5 l   if Nack (TX), force Z=1 ==> StopCond
    ELSE    SUB.B #1,T              \ 3 l   else dec count
    THEN                            \ l
\   --------------------------------\
\   I2C_Master_CheckCountDown       \       count=0 (TX) or Nack received
\   --------------------------------\
    0= IF                           \ 2 l   send stop
\       ----------------------------\
\       Send Stop                   \
\       ----------------------------\     _
        BIS.B #MSDA,&PI2CMDIR       \ 4 l  v_   SDA as output ==> SDA low
        SUB.B T,&I2CM_BUF           \ 4 l   _   refresh buffer length and reach tSU:STO
        BIC.B #MSCL,&PI2CMDIR       \ 4 l _^    release SCL (high)
        BEGIN                       \
            BIT.B #MSCL,&PI2CMIN    \ 3 h       SCL released ?
        0<> UNTIL                   \ 2 h
        BIC.B #MSDA,&PI2CMDIR       \ 4 h _^    SDA as input  ==> SDA high with pull up resistor
        MOV @RSP+,PC                \ RET  ====>
    THEN                            \
    MOV.B @S+,X                     \ 2 l     next byte to transmit
AGAIN                               \ 2 l
ENDASM                              \ 93 words
    \



\ ------------------------------\
CODE START                      \ 
\ ------------------------------\
\ init PORTA (P2:P1) (complement) when reset occurs all I/O are set in input with resistors pullup 
BIC.B #M_BUS,&I2CSM_OUT         \ preset SDA + SCL output low
BIC.B #M_BUS,&I2CSM_REN         \ SDA + SCL pullup/down disable
\ ------------------------------\
LO2HI
." \ type stop to stop :-)"
    LIT RECURSE IS WARM         \ insert this starting routine between COLD and WARM...
    ['] WARM >BODY EXECUTE      \ ...and continue with WARM (very, very usefull after COLD or RESET !:-)
 ;

: STOP                          \ stops multitasking, must to be used before downloading app
    ['] WARM >BODY  IS WARM     \ remove START app from FORTH init process
    ECHO COLD                   \ reset CPU, interrupt vectors, and start FORTH
;

RST_HERE                   \ set here the reset dictionnary 

\ ---------------------------------------------------------------------------------------------------------------------\
\ SCL clock generation, timing, and test of data(s) number are made by I2C_Master.
\ slave can strech SCL low after Start Condition and after any bit.
\
\ address Ack/Nack is generated by the slave on SDA line (released by the master)
\ Two groups of eight addresses (000xxxy and 1111xxxy) are not allowed (reserved)
\ after address or data is sent, the transmitter (Master or Slave) must release SDA line to allow (N)Ack by the receiver
\ data Ack/Nack are generated by the receiver (master or slave) on SDA line
\ a master receiver must signal the end of data to the slave transmitter by sending a Nack bit
\ Stop or restart conditions must be generated by master after a Nack bit.
\ after Ack bit is sent, Slave must release SDA line to allow master to do stop or restart conditions.
\
\
\             first byte = address + R/W flag    | byte data (one, for example)
\     __      _____ _____ _..._ _____ __R__ _NAK_ _____ _____ _..._ _____ _____ _NAK_     _
\ SDA   \____/_MSB_X_____X_..._X_LSB_X__W__x_ACK_x_MSB_X_____X_..._X_____X_LSB_X_ACK_X___/
\     _____     _     _           _     _     _     _     _           _     _     _     ___
\ SCL      \___/1\___/2\___...___/7\___/8\___/9\___/1\___/2\___...___/7\___/8\___/9\___/
\       ^   ^                             ^     ^                             ^     ^    ^
\       |   |SSL                          |SSL  |SSL                          |SSL  |SSL |
\       |                                                                                |
\       |Start Condition                                                                 |stoP Condition
\
\             first byte = address + R/W flag    | byte data (one, for example)
\     __      _____ _____ _..._ _____ __R__ _NAK_ _____ _____ _..._ _____ _____ _NAK_ ___
\ SDA   \____/_MSB_X_____X_..._X_LSB_X__W__x_ACK_x_MSB_X_____X_..._X_____X_LSB_X_ACK_X   \____...
\     _____     _     _           _     _     _     _     _           _     _     _     ____
\ SCL      \___/1\___/2\___...___/7\___/8\___/9\___/1\___/2\___...___/7\___/8\___/9\___/    \_...
\       ^   ^                             ^     ^                             ^     ^    ^
\       |   |SSL                          |SSL  |SSL                          |SSL  |SSL |
\       |                                                                                |
\       |Start Condition                                                                 |reStart Condition
\
\ SSL : Slave can strech SCL low
\ tHIGH : SCL high time
\ tLOW : SCL low time
\ tBUF : SDA high time between Stop and Start conditions
\ tHD:STA : Start_Condition SCL high time after SDA is low
\ tSU:STO : Stop_Condition SCL high time before SDA rise
\ tSU:STA : Start_Condition SCL high time before SDA fall
\ tHD:DAT : SDA data change time after SCL is low
\ the SDA line must be strobe just after SCL is high
\ the SDA data must be change just after SCL is low
\ standard mode (up to 100 kHz) :   tHIGH   =   tHD:STA =   tSU:STO =   4µs
\                                   tLOW    =   tSU:STA =   tBUF    =   4,7µs
\                                   tHD:DAT <=  3,45 µs
\ -------------------------------------------------------------------------------------------------------------------\
