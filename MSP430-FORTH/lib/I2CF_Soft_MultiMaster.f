\ name : msp430FR5xxx_I2CF_Soft_MultiMaster.asm

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


\ I2C MASTER Standard Mode software driver without interrupt, with detection collision
\ Target: MSP430FR5xxx, tested @ 8,16,24 MHz and adjusted @ 16,24 MHz
\         SDA = P1.2, SCL = P1.3,  with 3k3 pullup resistors

\ version 1.0 2015-03-24

WIPE
\ ==============================================================================================================
\ ==============================================================================================================
                     
\ ###  #####   #####  ######     #####                         #     # #     #
\  #  #     # #     # #         #     #  ####  ###### #####    ##   ## ##   ##   ##    ####  ##### ###### #####
\  #        # #       #         #       #    # #        #      # # # # # # # #  #  #  #        #   #      #    #
\  #   #####  #       #####      #####  #    # #####    #      #  #  # #  #  # #    #  ####    #   #####  #    #
\  #  #       #       #               # #    # #        #      #     # #     # ######      #   #   #      #####
\  #  #       #     # #         #     # #    # #        #      #     # #     # #    # #    #   #   #      #   #
\ ### #######  #####  #          #####   ####  #        #      #     # #     # #    #  ####    #   ###### #    #
                     
\ ==============================================================================================================
\ ==============================================================================================================

\ use Px.0 to Px.3 for good timing at 8 MHz

\ tested with P1.6 SDA, P1.7 SCL :
\ Start + Adr + Write 3 bytes + Stop + Start + adr + read 2 bytes + stop = 310us ==> 200 kHz 
\ See MSP430FR5xxx_I2CF_Soft_MultiMaster.png

VARIABLE I2CS_ADR   \ low(I2CS_ADR) = slave I2C address with RW flag, high(I2CS_ADR) = RX buffer,data0
2 ALLOT             \ data1,data2
VARIABLE I2CM_BUF   \ low(I2CM_BUF) = RX or TX lentgh, high(I2CM_BUF) = TX buffer,data0
2 ALLOT             \ data1,data2
    \

\ ==================================\
ASM I2C_MM                          \ soft I2C_MultiMaster driver
\ ==================================\
\                                   \ in  : I2CS_ADR pointer
\                                   \     : I2CM_BUF pointer
\                                   \ used: S   BUF_PTR
\                                   \       T   count of I2C datas exchanged
\                                   \       W   count of bits
\                                   \       X   data
\                                   \       Y   BUF_ORG
\                                   \       SR(10) collision flag
\                                   \ out : I2CS_ADR(0) unchanged
\                                   \       I2CM_BUF(0) = count of data not exchanged (normally = 0)
\                                   \       I2CM_BUF(0) = -1 <==> Nack on address
\ ----------------------------------\
\ I2CMM_Stop_UCBxI2CSlave           \ if SDA SCL of I2C_MultiMaster are hard wired onto SDA SCL of I2C_Slave under interrupt...
\ ----------------------------------\
\ BIS #1,&UCB0CTLW0                  \ set eUSCI_B0 in reset state, reset StartCond int in UCB0IFG
\ BIC.B #SMM_BUS,&PI2CMSEL1          \ disable I2C I/O
\ ----------------------------------\
\ I2C_MR_DC_listenBeforeStart:      \ test if SCL & SDA lines are idle (high)
\ ----------------------------------\
BEGIN                               \
    BIC.B #SMM_BUS,&I2CSMM_DIR      \ SDA & SCL pins as input
    BIC.B #SMM_BUS,&I2CSMM_OUT      \ preset output LOW for SDA & SCL pins
    MOV #2,T                        \ I2C_MR_DC_Wait_Start_Loop = 3 탎 @ 8 MHz
    BEGIN                           \ 15~loop
      BEGIN                         \
        BEGIN                       \
          BIT.B #SMMSCL,&I2CSMM_IN  \ 4 SCL high ? 
        0<> UNTIL                   \ 2
        BIT.B #SMMSDA,&I2CSMM_IN    \ 4 SDA high ?
      0<> UNTIL                     \ 2
      SUB #1,T                      \ 1
    0= UNTIL                        \ 2 here the I2C bus is idle
\   --------------------------------\
\   I2C_Master_Start_Cond:          \ here, SDA and SCL are in idle state
\   --------------------------------\
    BIS.B #SMMSDA,&I2CSMM_DIR       \ 4 h   force SDA output (low)
    MOV #I2CS_ADR,S                 \ 2 l
    MOV.B @S+,X                     \ 3 l   X = slave address, S = RX buffer
    MOV #I2CM_BUF,W                 \ 2 l
    MOV.B @W+,T                     \ 2 l   T = count of datas, W = TX buffer
    ADD.B #1,T                      \ 1 l   to add address in count
    BIT.B #1,X                      \ 1 l   test I2C R/w flag
    0= IF                           \ 2 l   write flag ?
        MOV W,S                     \ 3 l   TX buffer
    THEN                            \
    BIS.B #SMMSCL,&I2CSMM_DIR       \ 4 h   force SCL output (low)
\   --------------------------------\   l
\   I2C_Master_Start_EndOf:         \   l
\   --------------------------------\
\   I2C_Master_Send_address         \   l SCL
\   --------------------------------\
    BIC #UF2,SR                     \ 2     reset detection collision SR(10) flag
    MOV #8,W                        \ 1 l   8 bits TX
    BEGIN                           \
        ADD.B X,X                   \ 1 l     shift one left
        U>= IF                      \ 2 l carry set ?
          BIC.B #SMMSDA,&I2CSMM_DIR \ 4 l yes : releas SDA high because pull up resistor
        ELSE                        \ 2 l
          BIS.B #SMMSDA,&I2CSMM_DIR \ 4 l no  : set as output ==> SDA low
        THEN                        \   l   _
        BIC.B #SMMSCL,&I2CSMM_DIR   \ 4 l _^    release SCL (high)
        BEGIN                       \
          BIT.B #SMMSCL,&I2CSMM_IN  \ 4 h       test if SCL is released
        0<> UNTIL                   \ 2 h
        MOV.B &I2CSMM_IN,Y          \ 3 h _     get SDA in Y
        BIS.B #SMMSCL,&I2CSMM_DIR   \ 4 h  v_   force SCL low
\       ----------------------------\
\       collision detection         \   l
\       ----------------------------\
        XOR.B &I2CSMM_DIR,Y         \ 3     normal : IN(SMMSDA) XOR DIR(SMMSDA) = 1 
        BIT.B #SMMSDA,Y             \ 2     collision : IN(SMMSDA=0) XOR DIR(SMMSDA=0) = 0 
        0= IF   BIS #$0402,SR       \ 6     set collision detection flag SR(10) and set Z=1 to force end of loop
        ELSE    SUB #1,W            \ 3     dec count of bits
        THEN                        \
    0= UNTIL                        \ 2  
    BIT #UF2,SR                     \ 2     collision ?
0= UNTIL                            \ 2     loop back if collision during send address
BIC.B #SMMSDA,&I2CSMM_DIR           \ 5     release SDA high before 9th bit
\ ----------------------------------\
\   I2C_Master_Loop                 \
\ ----------------------------------\
BEGIN                               \ 4 l
\   --------------------------------\   l
\   Master TX/RX ACK/NACK           \
\   --------------------------------\   l   _
    BIC.B #SMMSCL,&I2CSMM_DIR       \ 3 l _^    release SCL (high)
    BEGIN                           \
        BIT.B #SMMSCL,&I2CSMM_IN    \ 3 h       test if SCL is released
    0<> UNTIL                       \ 2 h
    BIT.B #SMMSDA,&I2CSMM_IN        \ 3 h _     get SDA
    BIS.B #SMMSCL,&I2CSMM_DIR       \ 3 h  v_   force SCL low
\   --------------------------------\ 4 l   here ack/nack is received/transmitted
\   I2C_Master_Loop_Data            \
\   --------------------------------\
    0<> IF  BIS #Z,SR               \ 5     if Nack (TX), force Z+1 ==> StopCond
    ELSE    SUB.B #1,T              \ 3     else dec count
    THEN                            \
\   --------------------------------\
\   I2C_Master_CheckCountDown       \       count=0 or Nack received
\   --------------------------------\
    0= IF                           \       count reached or Nack
\       ----------------------------\
\       I2C_Master_StopCond         \
\       ----------------------------\         _
        BIS.B #SMMSDA,&I2CSMM_DIR   \ 4 l  v_   force SDA low
        SUB.B T,&I2CM_BUF           \ 4 l       refresh buffer length and reach tSU:STO
        BIC.B #SMMSCL,&I2CSMM_DIR   \ 4 l _^    release SCL (high)
        BEGIN                       \
          BIT.B #SMMSCL,&I2CSMM_IN  \ 3 h   SCL released ?
        0<> UNTIL                   \ 2 h _
        BIC.B #SMMSDA,&I2CSMM_DIR   \   _|      as input  ==> SDA high with the hard wired pull up resistor
\       ----------------------------\
\       I2C_Master_Endof            \
\       ----------------------------\
\       Restart I2C_Slave_Int       \   if any
\       ----------------------------\
\        MOV #4,&UCB0IE              \       enable StartCond interrupt in UCB0IE register
\        BIC #1,&UCB0CTLW0           \       restart eUSCI_B
\        BIS.B #SMM_BUS,&I2CSMM_SEL1 \       reenable I2C I/O
\       ----------------------------\
        MOV @RSP+,PC                \ ====> out
\       ----------------------------\
    THEN                            \
    MOV.B #8,W                      \ 1 l   prepare 8 bits transaction
    BIT #1,&I2CS_ADR                \ 3 l   I2C_Master Read/write bit test
    0= IF                           \ 2 l   write flag test
\       ----------------------------\
\       I2C Master write            \
\       ----------------------------\
        MOV.B @S+,X                     \ 2 l   X = TX data
        BEGIN                           \
            ADD.B X,X                   \ 1 l   shift one left
            U>= IF                      \ 2 l   carry set ?
              BIC.B #SMMSDA,&I2CSMM_DIR \ 4 l yes : release SDA (high because pull up resistor)
            ELSE                        \ 2 l
              BIS.B #SMMSDA,&I2CSMM_DIR \ 4 l no  : force SDA low
            THEN                        \   l   _
            BIC.B #SMMSCL,&I2CSMM_DIR   \ 4 l _^    release SCL (high)
            BEGIN                       \
               BIT.B #SMMSCL,&I2CSMM_IN \ 4 h       test if SCL is released
            0<> UNTIL                   \ 2 h _
            BIS.B #SMMSCL,&I2CSMM_DIR   \ 4 h  v_   force SCL low
            SUB #1,W                    \ 1 l       count of bits
        0= UNTIL                        \ 2 l
        BIC.B #SMMSDA,&I2CSMM_DIR       \ 4 l       release SDA high
    ELSE                                \ 2 l
\       ============================\
\       I2C_Master_RX:              \       here, SDA is indetermined, SCL is strech low by master
\       ============================\
        BIC.B #SMMSDA,&I2CSMM_DIR   \ 5 l _    After ACK we must release SDA
        BEGIN                       \
\           ------------------------\       _
\           send bit                \ SCL _| |_
\           ------------------------\       _
            BIC.B #SMMSCL,&I2CSMM_DIR   \ 3 l _^    release SCL (high)
            BEGIN                       \
               BIT.B #SMMSCL,&I2CSMM_IN \ 3 h       test if SCL is released
            0<> UNTIL                   \ 2 h
            BIT.B #SMMSDA,&I2CSMM_IN    \ 3 h _     get SDA
            BIS.B #SMMSCL,&I2CSMM_DIR   \ 3 h  v_   force SCL low
            ADDC.B X,X                  \ 1 l       C <-- X <--- C
            SUB #1,W                    \ 1 l       count of bits
        0= UNTIL                        \ 2 l
        MOV.B X,0(S)                    \ 3 l       store byte @ BUF_PTR
        ADD #1,S                        \ 1 l
\       ----------------------------\
\       I2C_MSendAckOrNack          \ here, SDA is released by slave, SCL is strech low by master
\       ----------------------------\
        CMP.B #1,T                  \         bytes count = 1 ?
        0<> IF                      \ 2
          BIS.B #SMMSDA,&I2CSMM_DIR \ 4 l     prepare send Ack if byte count <> 1
        THEN                        \   
    THEN                            \
AGAIN                               \ 2 l
ENDASM                              \
    \

\ ------------------------------\
CODE START                      \ 
\ ------------------------------\
\ init PORTA (P2:P1) (complement) when reset occurs all I/O are set in input with resistors pullup 
BIC.B #SMM_BUS,&I2CSMM_OUT      \ preset SDA + SCL output low
BIC.B #SMM_BUS,&I2CSMM_REN      \ SDA + SCL pullup/down disable
\ ------------------------------\
LO2HI
." Type STOP to stop :-)"
LIT RECURSE IS WARM         \ insert this routine between COLD and WARM...
(WARM) ;                    \ ...and continue with WARM
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \

RST_HERE


\ ---------------------------------------------------------------------------------------------------------------------\
\ SCL clock generation, timing, and test of data(s) number are made by I2C_Master.
\ slave can strech SCL low after Start Condition and after any bit.

\ address Ack/Nack is generated by the slave on SDA line (released by the master)
\ Two groups of eight addresses (000xxxy and 1111xxxy) are not allowed (reserved)
\ after address or data is sent, the transmitter (Master or Slave) must release SDA line to allow (N)Ack by the receiver
\ data Ack/Nack are generated by the receiver (master or slave) on SDA line
\ a master receiver must signal the end of data to the slave transmitter by sending a Nack bit
\ Stop or restart conditions must be generated by master after a Nack bit.
\ after Ack bit is sent, Slave must release SDA line to allow master to do stop or restart conditions
\
\     __      _____ _____ _..._ _____ _____ _NACK _____ _____ _..._ _____ _____ _NACK     _
\ SDA   \____/_MSB_X_____X_..._X_LSB_X_R/W_x_ACK_x_MSB_X_____X_..._X_____X_LSB_X_ACK_X___/
\     _____     _     _           _     _     _     _     _           _     _     _     ___
\ SCL      \___/1\___/2\___...___/7\___/8\___/9\___/1\___/2\___...___/7\___/8\___/9\___/
\       ^   ^                             ^     ^                             ^     ^    ^
\       |   |Slave Stretch Low            |SSL  |SSL                          |SSL  |SSL |
\       |                                                                                |
\       |Start Condition                                                                 |stoP Condition
\
\     __      _____ _____ _..._ _____ _____ _NACK _____ _____ _..._ _____ _____ _NACK ___
\ SDA   \____/_MSB_X_____X_..._X_LSB_X_R/W_x_ACK_x_MSB_X_____X_..._X_____X_LSB_X_ACK_X   \____...
\     _____     _     _           _     _     _     _     _           _     _     _     ____
\ SCL      \___/1\___/2\___...___/7\___/8\___/9\___/1\___/2\___...___/7\___/8\___/9\___/    \_...
\       ^   ^                             ^     ^                             ^     ^    ^
\       |   |Slave Stretch Low            |SSL  |SSL                          |SSL  |SSL |
\       |                                                                                |
\       |Start Condition                                                                 |reStart Condition
\
\ tHIGH : SCL high time
\ tLOW : SCL low time
\ tBUF : SDA high time between Stop and Start conditions
\ tHD:STA : Start_Condition SCL high time after SDA is low
\ tSU:STO : Stop_Condition SCL high time before SDA rise
\ tSU:STA : Start_Condition SCL high time before SDA fall
\ tHD:DAT : SDA data change time after SCL is low
\ the SDA line must be strobe just after SCL is high
\ the SDA data must be change just after SCL is low
\ standard mode (up to 100 kHz) :   tHIGH   =   tHD:STA =   tSU:STO =   4탎
\                                   tLOW    =   tSU:STA =   tBUF    =   4,7탎
\                                   tHD:DAT <=  3,45 탎
\ -------------------------------------------------------------------------------------------------------------------\
