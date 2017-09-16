\ IR_RC5_to_I2CF_Soft_Master.f

\ Copyright (C) <2016>  <J.M. THOORENS>
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


\ --------------------------------------\
\ example of App running under interrupt
\ --------------------------------------\
\ FORTH driver for IR remote compatible with the PHILIPS RC5 protocol, with select new/repeated command

\ target : any MSP430FRxxxx @ 8Mhz

\ prerequisites : your launchpad is wired as described in launchpad.pat file : UART0, Soft_Master(SDA,SCL), IR_RC5 parts.
\                 FastForth runs @ 8MHz
\                 add 3k3 pull up resistors on SDA and SCL lines.

\ usage :   create a logical network drive ( a: b: ...as you want) from your local copy of Gitlab FAST FORTH
\           with scite.exe open this file MSP430-FORTH\IR_RC5_to_I2CF_Soft_Master.f,
\           select "tools" menu, "preprocess" item 1 (CTRL+0),
\           a dialog box asks you for 4 parameters $(1) to $(4),
\           in the 2th param. field, type your launchpad to select the launchpad.pat to be used : for example MSP_EXP430FR5969,
\ result :  the word START starts the app that runs under LPMx.

\           to recover the console input (i.e. to quit LPMx), type a space. Then you can enter a command, for example STOP.

\ select one initial state :
WIPE        \ to suppress any previous app 
\ RST_STATE   \ to conserve the previous app protected against <reset> 
\ PWR_STATE   \ to conserve the previous app protected against POWER OFF
NOECHO      \ comment if an error occurs, to detect it with new download

\ HERE        \ uncomment for a dump, part 1
    \



\ -------------------------------------------------------------------------------------------------------------------\
\ I2CF Soft MASTER driver, FAST MODE, 8MHz
\ -------------------------------------------------------------------------------------------------------------------\

VARIABLE I2CS_ADR   \ low(I2CS_ADR) = slave I2C address with RW flag, high(I2CS_ADR) = RX buffer,data0
2 ALLOT             \ data1,data2
VARIABLE I2CM_BUF   \ low(I2CM_BUF) = RX or TX lentgh, high(I2CM_BUF) = TX buffer,data0
2 ALLOT             \ data1,data2
    \

\ ------------------------------\
ASM I2C_MTX                     \ MASTER TX \ shared code for address and TX data
\ ------------------------------\
BEGIN                           \
    ADD.B   X,X                 \ 1 l     shift one left
    U>= IF                      \ 2 l carry set ?
        BIC.B #MSDA,&I2CSM_DIR  \ 4 l yes : SDA as input  ==> SDA high because pull up resistor
    ELSE                        \ 2 l
        BIS.B #MSDA,&I2CSM_DIR  \ 4 l no  : SDA as output ==> SDA low
    THEN                        \   l   _
    BIC.B #MSCL,&I2CSM_DIR      \ 4 l _^    release SCL (high)
    BEGIN                       \           14/16~l
        BIT.B #MSCL,&I2CSM_IN   \ 3 h       test if SCL is released
    0<> UNTIL                   \ 2 h _
    BIS.B #MSCL,&I2CSM_DIR      \ 4 h  v_   SCL as output : force SCL low
    SUB #1,W                    \ 1 l     count of bits
0= UNTIL                        \ 2 l
BIC.B   #MSDA,&I2CSM_DIR        \ 5 l _   SDA as input : release SDA high to prepare read Ack/Nack
RET
ENDASM                          \
    \

\ ******************************\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM INT_RC5                     \ wake up on P1.2 change interrupt \ IP,TOS,W,X,Y are free for use
\ ------------------------------\
BIC #$F8,0(RSP)                 \ SCG1,SCG0,OSCOFF,CPUOFF and GIE are OFF in retiSR to force LPMx_LOOP with pending interrupt
\ BIC #$B8,0(RSP)                \ {SCG1,OSCOFF,CPUOFF,GIE}=OFF after RETI to force goto label "LPMx_LOOP" with any pending interrupt
\ ------------------------------\
\ define LPM mode for ACCEPT    \ uncomment a line
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : IP,TOS,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\    MOV     #1,&TA0EX0          \ predivide by 2 in TA0EX0 register (16 MHZ)
\    MOV     #2,&TA0EX0          \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL    \ (re)start timer_A | SMCLK/8 : 2us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:        \                   |
    RRUM    #1,X                \ X=1/2 cycle       |
    MOV     X,Y                 \ Y=1/2             ^
    RRUM    #1,Y                \ Y=1/4
    ADD     X,Y                 \ Y=3/4
\ RC5_Wait_1_1/4                 \ wait 3/4 cycle after 1/2 cycle to sample RC5_Input at 1/4 cycle+1
    BEGIN   CMP Y,&TA0R         \ CMP &TA0R with 3/4 cycle value 
    0= UNTIL                    \
\ ------------------------------\
\ RC5_Sample:                   \ at 5/4 cycle, we can sample RC5_input, ST2/C6 bit first
\ ------------------------------\
    BIT.B   #RC5,&IR_IN         \ C_flag = IR bit
    ADDC    IP,IP               \ C_flag <-- IP(15):IP(0) <-- C_flag
    MOV     &IR_IN,&IR_IES      \ preset Px_IES.y state for next IFG
    BIC.B   #RC5,&IR_IFG        \ clear Px_IFG.y after 4/4 cycle pin change
    SUB     #1,W                \ decrement count loop
\                               \  count = 13 ==> IP = x  x  x  x  x  x  x  x |x  x  x  x  x  x  x /C6
\                               \  count = 0  ==> IP = x  x /C6 Tg A4 A3 A2 A1|A0 C5 C4 C3 C2 C1 C0  1 
0<> WHILE                       \ ----> out of loop ----+
\ RC5_compute_7/4_Time_out:     \                       |
    ADD     X,Y                 \                       |   out of bound = 7/4 period 
\ RC5_WaitHalfCycleP1.2_IFG:    \                       |
    BEGIN                       \                       |
        CMP Y,&TA0R             \                       |   TA0R = 5/4 cycle test
        0>= IF                  \                       |   if cycle time out of bound
          BIC #$30,&TA0CTL      \                       |   stop timer_A0
          RETI                  \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B #RC5,&IR_IFG      \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV &TA0R,X                 \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
MOV #$30,&TA0CTL                \ stop timer_A0
RLAM #1,IP                      \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV @RSP,X                      \ retiSR(9)  = old RC5 toggle bit
RLAM #4,X                       \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR IP,X                        \ (new XOR old) Toggle bit (13)
BIT #BIT13,X                    \ X(13) = New_RC5_command
0= IF 
    RETI                        \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR #UF1,0(RSP)                 \ change Toggle bit memory, User Flag 1 = SR(9)
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
MOV.B IP,S                      \ S = C5 C4 C3 C2 C1 C0  0  0
RRUM #2,S                       \ S =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT #BIT14,IP                   \ test /C6 bit in IP
0= IF
   BIS #BIT6,S                  \ set C6 bit in S
THEN                            \ S =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\
\ ------------------------------\
\ Prepare I2C_MASTER            \
\ ------------------------------\
SWPB S                          \ 1 high byte = data
ADD #1,S                        \ 1 low byte = count
MOV S,&I2CM_BUF                 \ 3
MOV #%0010100,&I2CS_ADR         \ MSP-EXP430FRxxx I2C slave address
\ ------------------------------\
\ echo code to terminal option  \
\ ------------------------------\
\ SUB #2,PSP
\ MOV TOS,0(PSP)
\ MOV.B S,TOS
\ LO2HI
\ cr ." $" HEX 2 U.R
\ HI2LO

\ ==================================\
\ CODE I2C_M                        \ fast I2C soft Master, only 8 MHz
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
\ I2C_MR_DC_ListenBeforeStart:      \ test if SCL & SDA lines are idle (high)
\ ----------------------------------\
BIC.B #M_BUS,&I2CSM_DIR             \ SDA & SCL pins as input
BIC.B #M_BUS,&I2CSM_OUT             \ preset output LOW for SDA & SCL pins
MOV #2,T                            \ I2C_MR_DC_Wait_Start_Loop = 8 탎 @ 8 MHz
\ MOV #4,T                          \ I2C_MR_DC_Wait_Start_Loop = 8 탎 @ 16 MHz
\ MOV #6,T                          \ I2C_MR_DC_Wait_Start_Loop = 8 탎 @ 24 MHz
BEGIN                               \
    BEGIN                           \
        BEGIN                       \
           BIT.B #MSCL,&I2CSM_IN    \ 4 P1DIR.3 SCL high ? 
        0<> UNTIL                   \ 2
        BIT.B #MSDA,&I2CSM_IN       \ 4 P1IN.2 SDA high ?
    0<> UNTIL                       \ 2
        SUB #1,T                    \ 1
0= UNTIL                            \ 2 here the I2C bus is idle
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
\        MOV @RSP+,PC               \ RET  ====>
        RETI                        \
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
        BIC.B #MSDA,&I2CSM_DIR      \ 5 l _    After ACK we must release SDA
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


\ ------------------------------\
CODE START                      \
\ ------------------------------\
\ init PORT M_BUS (complement)  \ when reset occurs all I/O are set in input with resistors pullup 
BIC.B #M_BUS,&I2CSM_OUT         \ preset SDA + SCL output low
BIC.B #M_BUS,&I2CSM_REN         \ SDA + SCL pullup/down disable
\ ------------------------------\
\ init PORT IR (complement) default I/O are input with pullup resistors
BIS.B #RC5,&IR_IE               \ enable interrupt for TSOP32236
BIC.B #RC5,&IR_IFG              \ clear int flag for TSOP32236
\ ------------------------------\
\ init interrupt vectors        \
\ ------------------------------\
MOV #INT_RC5,&IR_Vec            \ init IR vector interrupt
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
LO2HI
." RC5toI2CF_Master is running. Type STOP to quit"
\ NOECHO                          \ uncomment to run this app without terminal connexion
LIT RECURSE IS WARM             \ insert this starting routine between COLD and WARM...
(WARM) ;                        \ ...and continue with WARM (very, very usefull after COLD or RESET !:-)
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \

ECHO

\ DUP HERE SWAP - DUMP            \ uncomment for a dump, part 2
    \

\ select one end state :
RST_HERE    \ this app is protected against POWER OFF, <reset>, COLD, ...and STOP that executes COLD.
\ PWR_HERE    \ this app is protected only againt POWER OFF
\ nothing   \ this app is volatile !


\ all lines beyond START command are ignored

\ --------------------------------------------------\
\ PHILIPS IR REMOTE RC5/RC6 protocol                \
\ --------------------------------------------------\
\ first half bit = no light, same as idle state
\ second half bit : 32 IR-light pulses of 6,944us,light ON/off ratio = 1/3

\        |<------32 IR light pulses = second half of first start bit ------->|
\        |_     _     _     _     _     _     _     _     _     _     _     _|
\ ...____| |___| |___| |___| |___| |___| |...| |___| |___| |___| |___| |___| |____________________________________...
\        |                                                                   |
\ 


\ at the output of IR receiver TSOPxxx during the first start bit :

\ ...idle state ->|<----- first half bit ------>|<- second half bit (IR light) ->|
\ ..._____________|_____________________________|                                |_________...
\                 |                             |                                |
\                 |                             |                                |
\                 |                             |________________________________|

\ 32 cycles of 27,777us (36kHz) = 888,888 us
\ one bit = 888,888 x 2 = 1778 us.



\   14 bits of active message   = 24.889 ms
\ + 50  bits of silent (idle)   = 88.888 ms
\ = RC5 message                 = 113.792 ms

\
\ RC5_message on IR LIGHT \ idle state = light off

\ 89ms>|<--------------------------------------------------24.889 ms-------------------------------------------------->|<88,
\      |                                                                                                               |
\      |       |       |       |       |       |       |       |       |       |       |       |       |       |       | 
\      |  ST1  | ST2/C6|  Tog  |  A4   |  A3   |  A2   |  A1   |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   |  C0   |
\      |       |       |       |       |       |       |       |       |       |       |       |       |       |       | 
\          1       1       1       1       0       0       1       1       1       1       1       1       1       1 
\           ___     ___     ___     _______     ___         ___     ___     ___     ___     ___     ___     ___     ___ 
\          ^   |   ^   |   ^   |   ^       |   |   |       ^   |   ^   |   ^   |   ^   |   ^   |   ^   |   ^   |   ^   |
\  idle____|   |___|   |___|   |___|       v___|   v_______|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |____
\          
\
\ notice that each cycle contains its bit value preceded by its complement




\ the same RC5_message inverted at the output of IR receiver : idle state = 1
\
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
\       |  ST1  | ST2/C6|  Tog  |  A4   |  A3   |  A2   |   A1  |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   |  C0   |
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
\           1       1       1       1       0       0       1       1       1       1       1       1       1       1  
\  idle_____     ___     ___     ___         ___     _______     ___     ___     ___     ___     ___     ___     ___     __idle
\           |   |   |   |   |   |   |       ^   |   ^       |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
\           v___|   v___|   v___|   v_______|   |___|       v___|   v___|   v___|   v___|   v___|   v___|   v___|   v___|
\           I       R       R       R       R       R       R       R       R       R       R       R       R       R
\
\ notice that each cycle contains its bit value followed by its complement




\ principe of the driver : 13 samples at 1/4 period and Resynchronise (R) on 1/2 period (two examples)

\       0,888 ms
\       |<->|<--------------------------------routine time = 12 3/4 cycles = 22.644 ms--------------------------->|
\       |       |       |       |       |       |       |       |       |       |       |       |       |       | |     |
\       |  ST1  | ST2/C6| Toggle|  A4   |  A3   |  A2   |   A1  |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   | |C0   |
\       |       |       |       |       |       |       |       |       |       |       |       |       |       | |     |
\           1       1       1       1       0       0       1       1       1       1       1       1       1     | 1  
\  idle_____     _s_     _s_     _s_         ___     _____s_     _s_     _s_     _s_     _s_     _s_     _s_     _s_     __idle
\           |   |   |   |   |   |   |       ^   |   ^       |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
\           v___|   v___|   v___|   v_____s_|   |_s_|       v___|   v___|   v___|   v___|   v___|   v___|   v___|   v___|
\           S       R       R       R       R       R       R       R       R       R       R       R       R       ^   ^
\ samples :       1       2       3       4       5       6       4       8       9      10      11      12      13 |   |
\                                                                                                                   |   | 
\                                                                                                                   I   I
\       0,888 ms
\       |<->|<--------------------------------routine time = 12 3/4 cycles = 22.644 ms--------------------------->|
\       |       |       |       |       |       |       |       |       |       |       |       |       |       | |     |
\       |  ST1  | ST2/C6| Toggle|  A4   |  A3   |  A2   |   A1  |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   | |C0   |
\       |       |       |       |       |       |       |       |       |       |       |       |       |       | |     |
\           1       1       1       1       0       0       1       1       1       1       1       1       1     | 1
\  idle_____     _s_     _s_     ___         _o_     _o___s_     _s_     _s_     _s_     _s_     _s_     _s_         ______idle
\           |   |   |   |   |   |   |       ^   |   ^       |   |   |   |   |   |   |   |   |   |   |   |   |       ^   
\           v___|   v_o_|   v_o_|   v_o___s_|   |_s_|       v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o___s_|
\           S       R       R       R       R       R       R       R       R       R       R       R       R       ^
\ samples :       1       2       3       4       5       6       7       8       9       10       11     12      13|
\                                                                                                                   |
\                                                                                                                   I
\ good ! but we have too many of RC5_Int...


 

\ So, to avoid these RC5_Int after end : 13+1=14 samples, then the result is shifted one to right (two examples)

\       0,888 ms
\       |<->|<--------------------------------routine time = 13 3/4 cycles = 24.447 ms----------------------------------->|
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       | |
\       |  ST1  | ST2/C6| Toggle|  A4   |  A3   |  A2   |   A1  |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   |  C0   | |
\       |   1   |   1   |   1   |   1   |   0   |   0   |   1   |   1   |   1   |   1   |   1   |   1   |   1   |   1   | | 
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       | |
\  idle_____     _s_     _s_     _s_         _o_     _o___s_     _s_     _s_     _s_     _s_     _s_     _s_     _s_     _s_idle
\           |   |   |   |   |   |   |       ^   |   ^       |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
\           v___|   v_o_|   v_o_|   v_o___s_|   |_s_|       v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o_|
\           S   i   R   i   R   i   R       R   i   R       R   i   R   i   R   i   R   i   R   i   R   i   R   i   R   i
\ samples :       1       2       3       4       5       6       7       8       9       10      11      12      13      14
\
\ 
\       0,888 ms
\       |<->|<--------------------------------routine time = 13 3/4 cycles = 24.447 ms----------------------------------->|
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       | |
\       |  ST1  | ST2/C6| Toggle|  A4   |  A3   |  A2   |   A1  |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   |  C0   | |
\       |   1   |   1   |   1   |   1   |   0   |   0   |   1   |   1   |   1   |   1   |   1   |   1   |   1   |   0   | | 
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       | |
\  idle_____     _s_     _s_     ___         _o_     _o___s_     _s_     _s_     _s_     _s_     _s_     _s_         _o___s_idle
\           |   |   |   |   |   |   |       ^   |   ^       |   |   |   |   |   |   |   |   |   |   |   |   |       ^   
\           v___|   v_o_|   v_o_|   v_o___s_|   |_s_|       v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o___s_|
\           S   i   R   i   R   i   R       R   i   R       R   i   R   i   R   i   R   i   R   i   R   i   R       R
\ samples :       1       2       3       4       5       6       7       8       9       10      11      12      13      14


\ S = Wake up on RC5_Int at 1/2 cycle : clear and start timer
\ i = useless RC5_Int (not periodic) at 4/4 cycle
\ s = sample RC5_intput at (1/2+3/4) = 5/4 cycle = 1/4 cycle+1 and clear useless RC5_Int
\ R = usefull (periodic) RC5_Int at 6/4 cycle = 1/2 cycle+1 : cycle value = timer value then clear it and restart it
\ o = RC5_Int time out at 7/4 cycle = 3/4 cycle+1, used to detect (samples<14) truncated RC5_message

\ see also : http://www.sbprojects.com/knowledge/ir/rc5.php
\            http://laurent.deschamps.free.fr/ir/rc5/rc5.htm
\ Code RC5 : http://en.wikipedia.org/wiki/RC-5


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
\ SDA   \____/_MSB_R9_____R9_..._R9_LSB_R9__R10__x_ACK_x_MSB_R9_____R9_..._R9_____R9_LSB_R9_ACK_R9___/
\     _____     _     _           _     _     _     _     _           _     _     _     ___
\ SCL      \___/1\___/2\___...___/7\___/8\___/9\___/1\___/2\___...___/7\___/8\___/9\___/
\       ^   ^                             ^     ^                             ^     ^    ^
\       |   |SSL                          |SSL  |SSL                          |SSL  |SSL |
\       |                                                                                |
\       |Start Condition                                                                 |stoP Condition
\
\             first byte = address + R/W flag    | byte data (one, for example)
\     __      _____ _____ _..._ _____ __R__ _NAK_ _____ _____ _..._ _____ _____ _NAK_ ___
\ SDA   \____/_MSB_R9_____R9_..._R9_LSB_R9__R10__x_ACK_x_MSB_R9_____R9_..._R9_____R9_LSB_R9_ACK_R9   \____...
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
\ standard mode (up to 100 kHz) :   tHIGH   =   tHD:STA =   tSU:STO =   4탎
\                                   tLOW    =   tSU:STA =   tBUF    =   4,7탎
\                                   tHD:DAT <=  3,45 탎
\ -------------------------------------------------------------------------------------------------------------------\

