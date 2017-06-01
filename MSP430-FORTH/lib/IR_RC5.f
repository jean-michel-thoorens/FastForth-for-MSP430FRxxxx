\ ---------------
\ IR_RC5_P1.2.f
\ ---------------
RST_STATE   \ to rub out this test with <reset> or RST_STATE or COLD

\ Copyright (C) <2014>  <J.M. THOORENS>
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


\ FORTH driver for IR remote compatible with the PHILIPS RC5 protocol, with select new/repeated command
\ target : see IR_RC5.pat

\ Send to terminal the RC5 new command.
\ Press S1 to send also RC5 repeated command.


\ HERE                            \ general minidump, part 1

\ --------------------------------------------------------------------------------------------
\ MSP-EXP430FR5969 driver for IR_RC5 receiver TSOP32236 wired on Px.y input \ 65 words, 24.5ms
\ --------------------------------------------------------------------------------------------

\ layout : see config.pat file for defining I/O

\ ******************************\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM INT_RC5                     \ wake up on P1.2 change interrupt \ IP,TOS,W,X,Y are free for use
\ ------------------------------\
BIC #$F8,0(RSP)                 \ SCG1,SCG0,OSCOFF,CPUOFF and GIE are OFF in retiSR to force LPM0_LOOP with pending interrupt
\ ------------------------------\
\ define LPM mode for ACCEPT    \
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
    MOV     #0,&TA0EX0          \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\    MOV     #1,&TA0EX0          \ predivide by 2 in TA0EX0 register (16 MHZ)
\    MOV     #2,&TA0EX0          \ predivide by 3 in TA0EX0 register (24 MHZ)
    MOV     #1778,X             \ RC5_Period in us
    MOV     #14,W               \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL    \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:        \                   |
    RRUM    #1,X                \ X=1/2 cycle       |
    MOV     X,Y                 \ Y=1/2             ^
    RRUM    #1,Y                \ Y=1/4
    ADD     X,Y                 \ Y=3/4
\ RC5_Wait_1_1/4                \ wait 3/4 cycle after 1/2 cycle to sample RC5_Input at 1/4 cycle+1
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
        CMP     Y,&TA0R         \                       |   TA0R = 5/4 cycle test
        0>= IF                  \                       |   if cycle time out of bound
          BIC  #$30,&TA0CTL     \                       |   stop timer_A0
          RETI                  \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
    BIC     #$30,&TA0CTL        \ stop timer_A0
    RLAM    #1,IP               \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
    MOV     @RSP,X              \ retiSR(9)  = old RC5 toggle bit
    RLAM    #4,X                \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
    XOR     IP,X                \ (new XOR old) Toggle bit (13)
    BIT     #BIT13,X            \ X(13) = New_RC5_command
    0= IF RETI                  \ case of repeated RC5_command : RETI without SR(9) change
    THEN                        \
    XOR #UF1,0(RSP)             \ change Toggle bit memory, User Flag 1 ( SR(9))
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
    MOV.B   IP,S                \ S = C5 C4 C3 C2 C1 C0  0  0
    RRUM    #2,S                \ S =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
    BIT     #BIT14,IP           \ test /C6 bit in IP
    0= IF   BIS #BIT6,S         \ set C6 bit in S
    THEN                        \ S =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\
    RETI
ENDASM
    \



\ ------------------------------
\ Start process RC5 part
\ ------------------------------
\ ------------------------------\
CODE START                      \
\ ------------------------------\
\ init PORTX (P2:P1) (complement) default I/O are input with pullup resistors
    BIC.B   #RC5,&PIRIFG        \ P1IFG.2 clear int flag for TSOP32236     (after IES select)
    BIS.B   #RC5,&PIRIE         \ P1IE.2 enable interrupt for TSOP32236
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ init interrupt vectors        \
\ ------------------------------\
    MOV     #INT_RC5,&IR_Vec    \ init Px vector interrupt
\ ------------------------------\
    LO2HI
    ." RC5toLCD is running. Type STOP to quit"
    LIT RECURSE IS WARM         \ insert this starting routine between COLD and WARM...
    (WARM) ;                    \ ...and continue with WARM (very, very usefull after COLD or RESET !:-)
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \

\ HERE OVER - DUMP              \ general minidump, part 2

RST_HERE    \



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
\           I       R       R       R       R       R       R       R       R       R       R       R       R       ^   ^
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
\           I       R       R       R       R       R       R       R       R       R       R       R       R       ^
\ samples :       1       2       3       4       5       6       7       8       9       10       11     12      13|
\                                                                                                                   |
\                                                                                                                   i !
\ good ! but we have too many RC5_Int...


 

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
\           I   i   R   i   R   i   R       R   i   R       R   i   R   i   R   i   R   i   R   i   R   i   R   i   R   i
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
\           I   i   R   i   R   i   R       R   i   R       R   i   R   i   R   i   R   i   R   i   R   i   R       R
\ samples :       1       2       3       4       5       6       7       8       9       10      11      12      13      14


\ S = Wake up on RC5_Int at 1/2 cycle : clear and start timer
\ I = first interruption
\ i = useless RC5_Int (not periodic) at 4/4 cycle
\ s = sample RC5_intput at (1/2+3/4) = 5/4 cycle = n+1/4 cycles and clear useless RC5_Int
\ R = usefull (periodic) RC5_Int at 6/4 cycle = n+1/2 cycles : cycle value = timer value then clear it and restart it
\ o = RC5_Int time out at 7/4 cycle = n+3/4 cycles, used to detect (samples<14) truncated RC5_message

\ see also : http://www.sbprojects.com/knowledge/ir/rc5.php
\            http://laurent.deschamps.free.fr/ir/rc5/rc5.htm
\ Code RC5 : http://en.wikipedia.org/wiki/RC-5

