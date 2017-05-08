\ name : msp430FR5xxx_I2C_MMultiMaster.f
\
\ Copyright (C) <2016>  <J.M. THOORENS>
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
\
\
\ I2C MASTER Standard Mode software driver without interrupt
\ Target: MSP-EXP430FR5969 @ 8,16MHz
\ version 1.1 2016-03-18
\
\ ---------------------------------------------------------------------------------------------------------------------;
\ SCL clock generation, timing, and test of data(s) number are made by I2C_MMaster.
\ slave can strech SCL low after Start Condition and after any bit.
\
\ address Ack/Nack is generated by the slave on SDA line (released by the master)
\ Two groups of eight addresses (000$xxy and 1111xxxy) are not allowed (reserved)
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
\ standard mode (up to 100 kHz) :   tHIGH   =   tHD:STA =   tSU:STO =   4�s
\                                   tLOW    =   tSU:STA =   tBUF    =   4,7�s
\                                   tHD:DAT <=  3,45 �s
\
\ fast mode     (up to 400 kHz) :   tHIGH   =   tHD:STA =   tSU:STO =   0,6�s
\                                   tLOW    =   tSU:STA =   tBUF    =   1,3�s
\                                   tHD:DAT <=  0,9 �s
\ -------------------------------------------------------------------------------------------------------------------;

\ =========================================================================
\ =========================================================================
                          
\ ###  #####   #####      #     ##     #
\  #  #     # #     #     ##   ## ##   ##   ##    ####  ##### ###### #####
\  #        # #           # # # # # # # #  #  #  #        #   #      #    #
\  #   #####  #           #  #  # #  #  # #    #  ####    #   #####  #    #
\  #  #       #           #     # #     # ######      #   #   #      #####
\  #  #       #     #     #     # #     # #    # #    #   #   #      #   #
\ ### #######  #####      #     # #     # #    #  ####    #   ###### #    #
                          
\ =========================================================================
\ =========================================================================

\ tested with P1.6 SDA, P1.7 SCL :
\ Start + Adr + Write 3 bytes + Stop + Start + adr + read 2 bytes + stop = 206us ==> 305 kHz (STOP=14us)
\ See MSP430FR5xxx_I2C_MultiMaster.png


CREATE I2CMS_ADR    \ low(I2CMS_ADR) = slave I2C address with RW flag, high(I2CMS_ADR) = RX buffer,data0
4 ALLOT             \ data1,data2
CREATE I2CMM_BUF    \ low(I2CMM_BUF) = RX or TX lentgh, high(I2CMM_BUF) = TX buffer,data0
4 ALLOT             \ data1,data2
    \
VARIABLE MY_OWN_ADR


\ ----------------------------------\
ASM I2C_MM                          \
\ ----------------------------------\
\                                   \ in    I2CMS_ADR/I2CMM_BUF as RX/TX buffer requested by I2CMS_ADR(0(0))
\                                   \       I2CMS_ADR(0) = I2C_Slave_addr&R/w
\                                   \       I2CMM_BUF(0) = TX/RX count of datas
\                                   \       I2CMM_BUF(0) = 0 ==> send only I2C address
\                                   \ used  S = BUF ptr
\                                   \       T
\                                   \ out   S = BUF PTR pointing on first data not exCHNGd
\                                   \       T = count of TX/RX datas exCHNGd
\                                   \       T = -1 ==> NACK on address
\                                   \       I2CMS_ADR(0) = -1 ==> arbitration lost, else unchanged
\                                   \       I2CMM_BUF(0) = unchanged
\ ------------------------------    \
\ Swap Slave to Master mode         \
\ ------------------------------    \
BIS #1,&UCB0CTLW0                   \ SWRST 
MOV #$2FD3,&UCB0CTLW0               \ master mode + UCMM + UCTR + START + SWRST, IFG=IE=0 
MOV #$00C8,&UCB0CTLW1               \ set automatic stop (count byte reached)
MOV #$14,&UCB0BRW                   \ baudrate = SMCLK/20 = 400 kHz @8MHz ; 340 kHz measured
MOV &MY_OWN_ADR,&UCB0I2COA0         \ (required by multimaster mode)
BIS #$0400,&UCB0I2COA0              \ UCOAEN=1 enable UCB0I2COA0 with address slave
\ ------------------------------    \
MOV #I2CMM_BUF,S                    \ count & TX buf
MOV.B @S+,&UCB0TBCNT                \
CMP.B #0,&UCB0TBCNT                 \
0= IF                               \ count = 0
    BIS #4,&UCB0CTLW0               \ add Stop to Start cmd ==> Master send only I2C address
THEN    
MOV #I2CMS_ADR,T                    \ I2Cadr & RX buf
MOV.B @T+,&UCB0I2CSA                \ UCB0I2CSA = slave_address & R/w bit
RRA &UCB0I2CSA                      \ UCB0I2CSA = slave_address, C flag = R/w flag
U>= IF                              \ C flag = 1
    MOV T,S                         \ Master read  : S = RX buffer
    BIC #$10,&UCB0CTLW0             \                UCB0CTLW0 <-- UCTR=0
THEN                                \
\ ------------------------------    \
\ Start                             \
\ ------------------------------    \
MOV.B #-1,T                         \ T=-1
BIC #1,&UCB0CTLW0                   \ UCB0CTLW0 : clear SWRST, start I2C MASTER
BIT.B #1,&I2CMS_ADR                 \ R/W test
0= IF                               \
\   ----------------------------    \
\   MASTER TX                       \
\   ----------------------------    \
    BEGIN                           \
        MOV.B &UCBCNT0,T            \ store count of byte
        BIT #$10,&UCB0IFG           \ test UCALIFG : arbitration lost interrupt
        0<> ?GOTO FW1               \ eUSCI is already in Slave mode
        BIT #8,&UCB0IFG             \ test UCSTPIFG
        0<> ?GOTO FW2               \
        BIT #$20,&UCB0IFG           \ test UCNACKIFG
        0<> IF                      \
            BIS #4,&UCB0CTLW0       \ generate stop bit
        THEN                        \
        BIT #2,&UCB0IFG             \ test UCTXIFG0
        0<> IF                      \
            MOV.B @S+,&UCB0TXBUF    \ load data into UCB0TXBUF
        THEN                        \
    AGAIN                           \
THEN                                \
\ ------------------------------    \
\ MASTER RX                         \
\ ------------------------------    \
BEGIN                               \ of Master RX
    MOV.B &UCBCNT0,T                \ store count of byte
    BIT #8,&UCB0IFG                 \ test UCSTPIFG
    0<> IF                          \
        MOV @RSP+,PC                \ end of I2C_MM RX driver
    THEN                            \
    BIT #1,&UCB0IFG                 \ test UCRXIFG0
    0<> IF                          \
        MOV.B &UCB0RXBUF,0(S)       \ load data from UCB0RXBUF
        ADD   #1,S                  \
    THEN                            \
AGAIN                               \
\ ------------------------------    \
\ Swap Master to Slave mode         \
\ ------------------------------    \
FW2 MOV #1,&UCB0CTLW0               \ set eUSCI_B in reset state, clear UCB0IE & UCB0IFG all flags
    BIS #$07A0,&UCB0CTLW0           \
\    BIS #$10,&UCB0CTLW1             \ set software ack address (UCSWACK=1)
\    MOV #0,&UCB0ADDMSK              \ enable address mask for all addresses i.e. software address 
    BIC #1,&UCB0CTLW0               \ activate eUSCI_B
    MOV #4,&UCB0IE                  \ enable StartCond interrupt
FW1 MOV @RSP+,PC                    \
\ ------------------------------    \
ENDASM                              \ 62 words + 9 init words
    \

\ ------------------------------\
CODE START                      \ init
\ ------------------------------\
\ init I2C_MMaster              \
\ ------------------------------\
\       %0000 1111 1101 0011     $640 = $0FD3
\           -                     UCMM = 1  : multi master mode
\              -                  UCMST = 1 : I2C_MMaster
\               --                UCMODE = %11 = I2C
\                 _               USYNC=1 (always 1)
\                   --            UCSSEL=SMCLK=8MHz
\                     -           UCTXACK=0 not auto ACK slave address
\                      -          UCTR=1/0 : TX/RX modes
\                         -       UCTXSTP
\                          -      UCTXSTT send start
\                           -     UCSWRST=1
\ ------------------------------\
\       %0000 0000 1100 1000     $642 = $00C8
\                 -               UCETXINT=0 : UCTXIFG0 set address match UCxI2COAx and TX mode
\                   --            UCCLTO=%11 : SCL low time out = 34 ms
\                      -          UCSWACK=1 : UCTXACK must be written to continue
\                        --       UCASTP0=%10 : automatic Stop when UCBxTBCNT is reached
\ ------------------------------\
\ PORTX (PORTx:y) default values\ DIR0,REN1,OUT1 (input with pullup resistors)
\ ------------------------------\
\ notice : UCB0 I2C driver seems to control only DIR register !!!
BIC.B #MM_BUS,&I2CMM_REN        \ REN0 : no_resistor
BIC.B #MM_BUS,&I2CMM_OUT        \ OUT0 : preset output low
BIS.B #MM_BUS,&I2CMM_SEL1       \ SEL11 : enable I2C I/O
COLON
." ; type stop to stop :-)"
LIT recurse is WARM             \ insert this starting routine between COLD and WARM...
(WARM)                          \ ...and continue with (WARM)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \

