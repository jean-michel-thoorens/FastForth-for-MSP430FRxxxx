\ name : msp430FR5xxx_I2C_Soft_Master.asm

WIPE

\ Copyright (C) <2015>  <J.M. THOORENS>
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


\ version 2.0 2015-07-30
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
\ standard mode (up to 100 kHz) :   tHIGH   =   tHD:STA =   tSU:STO =   4�s
\                                   tLOW    =   tSU:STA =   tBUF    =   4,7�s
\                                   tHD:DAT <=  3,45 �s
\ -------------------------------------------------------------------------------------------------------------------\
\
\
\ -------------------------------------------------------------------------------------------------------------------\
\ I2C Soft MASTER, Standard MODE, 8,16,24MHz
\ -------------------------------------------------------------------------------------------------------------------\

\ ===============================================================================================
\ ===============================================================================================

\ ###  #####   #####      #####                         #     #
\  #  #     # #     #    #     #  ####  ###### #####    ##   ##   ##    ####  ##### ###### #####
\  #        # #          #       #    # #        #      # # # #  #  #  #        #   #      #    #
\  #   #####  #           #####  #    # #####    #      #  #  # #    #  ####    #   #####  #    #
\  #  #       #                # #    # #        #      #     # ######      #   #   #      #####
\  #  #       #     #    #     # #    # #        #      #     # #    # #    #   #   #      #   #
\ ### #######  #####      #####   ####  #        #      #     # #    #  ####    #   ###### #    #

\ ===============================================================================================
\ ===============================================================================================

\ use Px.0 to Px.3 pins as SCL and SDA pins to use immediate instruction in one byte (#1,#2,#4,#8)

\ tested with P1.6 SDA, P1.7 SCL @8 MHZ :
\ Start + Adr + Write 3 bytes + Stop + Start + adr + read 2 bytes + stop = 600us ==> 105 kHz 
\ See MSP430FR5xxx_I2C_Soft_Master.png

VARIABLE I2CS_ADR   \ low(I2CS_ADR) = slave I2C address with RW flag, high(I2CS_ADR) = RX buffer,data0
2 ALLOT             \ data1,data2
VARIABLE I2CM_BUF   \ low(I2CM_BUF) = RX or TX lentgh, high(I2CM_BUF) = TX buffer,data0
2 ALLOT             \ data1,data2
    \

\ ------------------------------\
ASM T_I2C                       \ 4 init first once !!!
\ ------------------------------\
BEGIN                           \ 3~ loop
    SUB #1,Y                    \ 1
0= UNTIL                        \ 2
    MOV #1,Y                    \ 2 set I2C tHIGH time @ 8MHz
\    MOV #9,Y                   \ 2 set I2C tHIGH time @ 16MHz
\    MOV #20,Y                  \ 2 set I2C tHIGH time @ 24MHz
    MOV @RSP+,PC                \ 4 ret
ENDASM                          \
    \

\ ------------------------------\       _
ASM I2C_PLS                     \ SCL _| |_ pulse
\ ------------------------------\   
CALL #T_I2C                     \   _   wait tLOW
BIC.B   #SMSCL,&I2CSM_DIR       \ _^    release SCL (high)
BEGIN
    BIT.B #SMSCL,&I2CSM_IN      \       test if SCL is released
0<> UNTIL
CALL    #T_I2C                  \       wait tHIGH
BIT.B   #SMSDA,&I2CSM_IN        \ _     get SDA
BIS.B   #SMSCL,&I2CSM_DIR       \  v_   force SCL low
MOV     @RSP+,PC                \       ret
ENDASM                          \
    \

\ ------------------------------\
ASM I2C_MTX                     \ MASTER TX \ shared code for address and TX data
\ ------------------------------\
BEGIN                           \
    ADD.B X,X                   \ 1 l   shift one left
    U>= IF                      \ 2 l   carry set ?
        BIC.B #SMSDA,&I2CSM_DIR \ 4 l   yes : SDA as input  ==> SDA high because pull up resistor
    ELSE                        \ 2 l
        BIS.B #SMSDA,&I2CSM_DIR \ 4 l   no  : SDA as output ==> SDA low
    THEN                        \   l  _ 
    CALL I2C_PLS                \    _| |_ SCL
    SUB.B #1,W                  \   l   count of bits
0= UNTIL                        \   l
BIC.B   #SMSDA,&I2CSM_DIR       \ 5 l _   SDA as input : release SDA high to prepare read Ack/Nack
MOV     @RSP+,PC                \       ret
ENDASM                          \
    \

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
\                                   \       X           dataI2CM_
\                                   \ out   I2CSLA_ADR & (R/W) unCHNGd
\                                   \       S = BUF PTR pointing on first data not exCHNGd
\                                   \       T = count+1 of TX/RX datas exCHNGd
\                                   \       I2CS_ADR(0) = unCHNGd
\                                   \       I2CM_BUF(0) = count of data not exCHNGd (normally = 0)
\                                   \       I2CM_BUF(0) = -1 <==> Nack on address
\ ----------------------------------\
\ I2C_MR_DC_ListenBeforeStart:      \ test if SCL & SDA lines are idle (high)
\ ----------------------------------\
    BIC.B #SM_BUS,&I2CSM_DIR        \ SDA & SCL pins as input
    BIC.B #SM_BUS,&I2CSM_OUT        \ preset output LOW for SDA & SCL pins
    MOV #2,T                        \ I2C_MR_DC_Wait_Start_Loop = 8 �s @ 8 MHz
\    MOV #4,T                        \ I2C_MR_DC_Wait_Start_Loop = 8 �s @ 16 MHz
\    MOV #6,T                        \ I2C_MR_DC_Wait_Start_Loop = 8 �s @ 24 MHz
    BEGIN                           \
        BEGIN                       \
            BEGIN                   \
               BIT.B #SMSCL,&I2CSM_IN \ 4 P1DIR.3 SCL high ? 
            0<> UNTIL                 \ 2
            BIT.B #SMSDA,&I2CSM_IN    \ 4 P1IN.2 SDA high ?
        0<> UNTIL                     \ 2
            SUB #1,T                    \ 1
    0= UNTIL                          \ 2 here the I2C bus is idle
\ ------------------------------\
\ I2C_Master_Start_Cond:        \ here, SDA and SCL are in idle state
\ ------------------------------\
BIS.B #SMSDA,&I2CSM_DIR         \ 4- P1DIR.2 force SDA output (low)
MOV #5,Y                        \ 2  tHD\STA time 8 MHz
\ MOV #15,Y                     \ 2  tHD\STA time 16MHz
\ MOV #25,Y                     \ 2  tHD\STA time 24MHz
CALL #T_I2C                     \   wait tHD\STA
BIS.B #SMSCL,&I2CSM_DIR         \ 4- P1DIR.3 force SCL output (low)
\ ------------------------------\
\ I2C_Master_Start_EndOf:       \
\ ------------------------------\
MOV #I2CS_ADR,S                 \ 2 l
MOV.B @S+,X                     \ 3 l X = slave address, S = RX buffer
MOV #I2CM_BUF,W                 \ 2 l
MOV.B @W+,T                     \ 2 l T = count of datas, W = TX buffer
BIT.B #1,X                      \ 1 l test I2C R/w flag
0= IF                           \ 2 l write flag
    MOV W,S                     \ 3 l TX buffer
THEN                            \
\ ------------------------------\
\ I2C_Master_Send_address       \     SCL is held low by slave 
\ ------------------------------\
ADD #1,T                        \     to add address in count
MOV #8,W                        \ 1 l prepare 8 bit Master writing
MOV #1,Y                        \ 2 tHD\STA time 8 MHz value
\ MOV #5,Y                       \ 2 tHD\STA time 16MHz value
\ MOV #15,Y                      \ 2 tHD\STA time 24MHz value
CALL #I2C_MTX                   \ 4  to send address
\ ------------------------------\
\ I2C_Master_Loop_Data          \
\ ------------------------------\
BEGIN                           \
\   ----------------------------\
\   Master TX/RX ACK/NACK       \
\   ----------------------------\
    MOV #2,Y                    \ 2     tLOW time complement @ 8MHz
\     MOV #15,Y                  \ 2     tLOW time complement @ 16MHz
\     MOV #20,Y                  \ 2     tLOW time complement @ 24MHz
    CALL #I2C_PLS               \ _| |_ SCL with BIT SDA, then ret
    0<> IF  BIS #2,SR           \ l     if Nack (TX), force Z=1 ==> StopCond
    ELSE    SUB.B #1,T          \       else dec count
    THEN                        \ l
\   ----------------------------\
\   I2C_Master_CheckCountDown   \       count=0 or Nack received
\   ----------------------------\
    0= IF                       \       count reached or Nack
\   ----------------------------\
\   I2C_Master_StopCond         \
\   ----------------------------\       before releasing SCL
        BIS.B #SMSDA,&I2CSM_DIR \ l     P1DIR.2 as output ==> SDA low
        CALL #T_I2C             \ l _       wait 4 us
        BIC.B #SMSCL,&I2CSM_DIR \ _|    P1DIR.2 release SCL (high)
        MOV #5,Y                \ 2      tSU:STO time 8 MHz value
\        MOV #15,Y               \ 2     tSU:STO time 16MHz value
\        MOV #25,Y               \ 2     tSU:STO time 24MHz value
        CALL #T_I2C             \     _  wait tSU:STO
        BIC.B #SMSDA,&I2CSM_DIR \   _|   P1DIR.2 as input  ==> SDA high with pull up resistor
        SUB.B T,&I2CM_BUF       \ 4 l    refresh buffer length and reach tSU:STO
        MOV @RSP+,PC            \ ====> 
\   ----------------------------\
    THEN                        \
\   ----------------------------\
    MOV.B #8,W                  \ 1 l     prepare 8 bits transaction
    BIT.B #1,&I2CS_ADR          \ 3 l     I2C_Master Read/write bit test
    0=  IF                      \ 2 l     write flag test
\       ------------------------\
\       I2C write               \
\       ------------------------\
        MOV.B @S+,X             \ 2 l     next byte to transmit
        CALL #I2C_MTX           \ 4       to send data + test ack
    ELSE                        \ l
\       ------------------------\
\       I2C read                \
\       ========================\
\       I2C_Master_RX:          \       here, SDA is indetermined, SCL is strech low by master
\       ========================\
        BEGIN                   \
            BIC.B #SMSDA,&I2CSM_DIR \ 4 l _   P1DIR.2 as input  ==> release SDA high because pull up resistor
            MOV #3,Y                \ 2     tLOW time complement @ 8 MHz
\            MOV #15,Y               \ 2    tLOW time complement @ 16MHz
\            MOV #24,Y               \ 2    tLOW time complement @ 24MHz
            CALL #I2C_PLS           \ _| |_ SCL + BIT SDA input (SDA-->carry)
            ADDC.B X,X              \ 1 l   C <-- X <--- C
            SUB #1,W                \ 1 l   count of bits
        0= UNTIL                    \ 2 l
        MOV.B X, 0(S)               \ 3 l     store byte in buffer
        ADD #1,S                    \ 1 l
\       ------------------------\
\       Compute Ack Or Nack     \ here, SDA is released by slave, SCL is strech low by master
\       ------------------------\
        CMP #1,T                \ 1 l     here, SDA is released by slave = Nack
        0<> IF                  \ 2
            BIS.B #SMSDA,&I2CSM_DIR  \ 4 l     send Ack if byte count <> 1
        THEN                    \ l
    THEN                        \
AGAIN                           \ l
ENDASM                          \
    \

\ ------------------------------\
CODE START                      \ 
\ ------------------------------\
\ init PORTA (P2:P1) (complement) when reset occurs all I/O are set in input with resistors pullup 
BIC.B #SM_BUS,&I2CSM_OUT        \ P1OUT.32 preset SDA + SCL output low
BIC.B #SM_BUS,&I2CSM_REN        \ P1REN.32 SDA + SCL pullup/down disable
\ ------------------------------\
LO2HI
." \ type stop to stop :-)"
LIT recurse is WARM             \ insert this starting routine between COLD and WARM...
(WARM)                          \ ...and continue with (WARM)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \

