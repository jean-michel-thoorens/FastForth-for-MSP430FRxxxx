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
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ******************************\
\ RC5_FirstStartBitHalfCycle:   \
\ ******************************\                division in TA0CTL (SMCLK/1,SMCLK/1,SMCLK/2,SMCLK/4,SMCLK/8)
\ MOV #0,&TA0EX0                \ predivide by 1 in TA0EX0 register ( 125kHz,   1MHz,   2MHZ,   4MHZ,   8MHZ), reset value
\ MOV #1,&TA0EX0                \ predivide by 2 in TA0EX0 register ( 250kHZ,   2MHz,   4MHZ,   8MHZ,  16MHZ)
\ MOV #2,&TA0EX0                \ predivide by 3 in TA0EX0 register ( 375kHz,   3MHz,   6MHZ,  12MHZ,  24MHZ)
\ MOV #3,&TA0EX0                \ predivide by 4 in TA0EX0 register ( 500kHZ,   4MHz,   8MHZ,  16MHZ)
\ MOV #4,&TA0EX0                \ predivide by 6 in TA0EX0 register ( 625kHz,   5MHz,  10MHZ,  20MHZ)
\ MOV #5,&TA0EX0                \ predivide by 6 in TA0EX0 register ( 750kHz,   6MHz,  12MHZ,  24MHZ)
\ MOV #6,&TA0EX0                \ predivide by 7 in TA0EX0 register ( 875kHz,   7MHz,  14MHZ,  28MHZ)
\ MOV #7,&TA0EX0                \ predivide by 8 in TA0EX0 register (   1MHz,   8MHz,  16MHZ,  32MHZ)
MOV #1778,X                     \ RC5_Period * 1us
\ MOV #222,X                    \ RC5_Period * 8us (SMCLK/1 and first column above)
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ******************************\
\ RC5_HalfCycle                 \ <--- loop back ---+ with readjusted RC5_Period
\ ******************************\                   |
\   MOV #%1000100100,&TA0CTL    \ (re)start timer_A | SMCLK/1 time interval,free running,clear TA0_IFG and TA0R
\   MOV #%1002100100,&TA0CTL    \ (re)start timer_A | SMCLK/2 time interval,free running,clear TA0_IFG and TA0R
\   MOV #%1010100100,&TA0CTL    \ (re)start timer_A | SMCLK/4 time interval,free running,clear TA0_IFG and TA0R
    MOV #%1011100100,&TA0CTL    \ (re)start timer_A | SMCLK/8 time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
    RRUM    #1,X                \ X=1/2 cycle       |
    MOV     X,Y                 \                   ^
    RRUM    #1,Y                \ Y=1/4
    ADD     X,Y                 \ Y=3/4 cycle
    BEGIN   CMP Y,&TA0R         \3 wait 1/2 + 3/4 cycle = n+1/4 cycles 
    U>= UNTIL                   \2
\ ******************************\
\ RC5_SampleOnFirstQuarter      \ at n+1/4 cycles, we sample RC5_input, ST2/C6 bit first
\ ******************************\
    BIT.B   #RC5,&IR_IN         \ C_flag = IR bit
    ADDC    IP,IP               \ C_flag <-- IP(15):IP(0) <-- C_flag
    MOV.B   &IR_IN,&IR_IES      \ preset Px_IES.y state for next IFG
    BIC.B   #RC5,&IR_IFG        \ clear Px_IFG.y after 4/4 cycle pin change
    SUB     #1,W                \ decrement count loop
\                               \  count = 13 ==> IP = x  x  x  x  x  x  x  x |x  x  x  x  x  x  x /C6
\                               \  count = 0  ==> IP = x  x /C6 Tg A4 A3 A2 A1|A0 C5 C4 C3 C2 C1 C0  1 
0<> WHILE                       \ ----> out of loop ----+
    ADD X,Y                     \                       |   Y = n+3/4 cycles = time out because n+1/2 cycles edge is always present
    BEGIN                       \                       |
        MOV &TA0R,X             \3                      |   X grows from n+1/4 up to n+3/4 cycles
        CMP Y,X                 \1                      |   cycle time out of bound ?
        U>= ?GOTO FW1           \2                  ^   |   yes: quit on truncated RC5 message
        BIT.B #RC5,&IR_IFG      \3                  |   |   n+1/2 cycles edge is always present
    0<> UNTIL                   \2                  |   |
REPEAT                          \ ----> loop back --+   |   with X = new RC5_period value
\ ******************************\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #2,PSP                  \
MOV     TOS,0(PSP)              \ save TOS before use
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2 A1 A0|C5 C4 C3 C2 C1 C0  1  0
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  1  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #BIT14,IP               \ test /C6 bit in IP
0= IF   BIS #BIT6,TOS           \ set C6 bit in TOS
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ -- BASE RC5_code
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(10) bit as toggle bit
\ ******************************\
RRUM    #3,IP                   \5 new toggle bit = IP(13) ==> IP(10)
XOR     SR,IP                   \ (new XOR old) Toggle bits
BIT     #UF10,IP                \ repeated RC5_command ?
0= ?GOTO FW2                    \ yes, RETI without UF1 change
\ ******************************\
XOR #UF10,0(RSP)                \ 5 toggle bit memory
FW2                             \   endof repeated RC5_command : RETI without UF1 change
FW1                             \   endof truncated RC5 message
BIC #$30,&TA0CTL                \   stop timer_A0
BIC #$F8,0(RSP)                 \ 4  SCG1,SCG0,OSCOFF,CPUOFF and GIE are OFF in retiSR to force LPM0_LOOP despite pending interrupt
RETI                            \ 5 for system OFF / 1 sec. ==> 1mA * 5us = 5nC + 6,5uA
ENDASM
    \ 

\ \ =============================================================
\ \ first definition of START with high level redirection of WARM
\ \ vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
\ \ ------------------------------\
\ CODE START                      \
\ \ ------------------------------\
\ \ init PORTX (P2:P1) (complement) default I/O are input with pullup resistors
\     BIC.B   #RC5,&IR_IFG        \ P1IFG.2 clear int flag for TSOP32236     (after IES select)
\     BIS.B   #RC5,&IR_IE         \ P1IE.2 enable interrupt for TSOP32236
\ \ ------------------------------\
\ \ define LPM mode for ACCEPT    \
\ \ ------------------------------\
\ \ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ \ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\ \                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ \ ------------------------------\
\ \ init interrupt vectors        \
\ \ ------------------------------\
\     MOV #RC5_INT,&IR_Vec        \ init Px vector interrupt
\ \ ------------------------------\
\ \ START is included in WARM     \
\ \ ------------------------------\
\ LO2HI
\    LIT RECURSE IS WARM          \ insert this starting routine between COLD and WARM...
\    ['] WARM >BODY EXECUTE       \ ...and continue with WARM (that unlocks I/O).
\ ;                               \
\ \ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
\ \ end of first definition of START (high level)
\ \ =============================================================

\ =============================================================
\ 2th definition of START with low level redirection of WARM
\ vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
\ ------------------------------\
CODE SYS_INIT                   \
\ ------------------------------\
\ init PORTX (P2:P1) (complement) default I/O are input with pullup resistors
    BIC.B   #RC5,&IR_IFG        \ P1IFG.2 clear int flag for TSOP32236     (after IES select)
    BIS.B   #RC5,&IR_IE         \ P1IE.2 enable interrupt for TSOP32236
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ init interrupt vectors        \
\ ------------------------------\
    MOV #RC5_INT,&IR_Vec        \ init Px vector interrupt
\ \ ------------------------------\
\ \ START is included in WARM     \ version with displaying WARM message
\ \ ------------------------------\ ====================================
\     MOV #WARM,X                 \
\     ADD #4,X                    \ ['] WARM >BODY
\     MOV X,PC                    \ executes default WARM, no return
\ ------------------------------\
\ START is included in WARM     \ version without displaying WARM message
\ ------------------------------\ =======================================
    MOV #ABORT",IP              \ IP = CFA of ABORT"
    SUB #12,IP                  \ IP = CFA of ABORT, to replace default WARMTYPE address
    MOV #WARM,X                 \ 
    ADD #8,X                    \ to skip WARMTYPE address, replaced by ABORT above
    MOV X,PC                    \ thus, executes default WARM without message, no return
ENDCODE

\ ------------------------------\
CODE START                      \
\ ------------------------------\
MOV #WARM,X                     \ 
MOV #SYS_INIT,2(X)              \ WARM will execute SYS_INIT
MOV X,PC                        \ EXECUTE WARM
ENDCODE 

\ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
\ end of 2th definition of START (low level)
\ =============================================================


\ \ high level definition of STOP
\ \ ------------------------------\
\ : STOP                          \ stops multitasking, must to be used before downloading app
\ \ ------------------------------\
\     ['] WARM >BODY IS WARM      \ remove START app from FORTH init process
\     COLD                        \ reset CPU, interrupt vectors, and start FORTH
\ ;

\ low level definition of STOP
\ ------------------------------\
CODE STOP                       \ stops multitasking, must to be used before downloading app
\ ------------------------------\
    MOV #WARM,X                 \ ['] WARM
    ADD #4,X                    \ >BODY
    MOV X,-2(X)                 \ IS WARM
    MOV #COLD,PC                \ COLD  reset CPU, interrupt vectors, and start FORTH
ENDCODE

RST_HERE

ECHO

\ --------------------------------------------------\
\ PHILIPS IR REMOTE RC5/RC6 protocol                \
\ --------------------------------------------------\
\ first half bit = no light, same as idle state
\ second half bit : 32 IR-light pulses of 6,944us,light ON/off ratio = 1/3
\
\        |<------32 IR light pulses = second half of first start bit ------->|
\        |_     _     _     _     _     _     _     _     _     _     _     _|
\ ...____| |___| |___| |___| |___| |___| |...| |___| |___| |___| |___| |___| |____________________________________...
\        |                                                                   |
\ 
\
\
\ at the output of IR receiver TSOPxxx during the first start bit :
\
\ ...idle state ->|<----- first half bit ------>|<- second half bit (IR light) ->|
\ ..._____________|_____________________________|                                |_________...
\                 |                             |                                |
\                 |                             |                                |
\                 |                             |________________________________|
\
\ 32 cycles of 27,777us (36kHz) = 888,888 us
\ one bit = 888,888 x 2 = 1778 us.
\
\
\
\   14 bits of active message   = 24.889 ms
\ + 50  bits of silent (idle)   = 88.888 ms
\ = RC5 message                 = 113.792 ms
\
\
\ RC5_message on IR LIGHT \ idle state = light off
\
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
\
\
\
\
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
\
\
\
\
\ principe of the driver : 13 samples at 1/4 period and Resynchronise (R) on 1/2 period (two examples)
\
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
\                 |       |       |       |       |       |       |       |       |       |       |       |       | |   |
\ samples :       1       2       3       4       5       6       4       8       9       10      11      12      13|   |
\                                                                                                                   |   | 
\ good ! but we have too many RC5_Int...---------------->                                                           I   I
\
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
\                 |       |       |       |       |       |       |       |       |       |       |       |       | |
\ samples :       1       2       3       4       5       6       7       8       9       10       11     12      13|
\                                                                                                                   |
\ good ! but we have too many RC5_Int...------------------>                                                         I
\
\
\
\ 
\
\ So, to avoid these RC5_Int after end : 13+1=14 samples, then the result is shifted one to wipe the 14th (two examples)
\
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
\                 |       |       |       |       |       |       |       |       |       |       |       |       |       |
\ samples :       1       2       3       4       5       6       7       8       9       10      11      12      13      14
\
\ 
\       0,888 ms
\       |<->|<--------------------------------routine time = 13 3/4 cycles = 24.447 ms----------------------------------->|
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       | |
\       |  ST1  | ST2/C6| Toggle|  A4   |  A3   |  A2   |   A1  |  A0   |  C5   |  C4   |  C3   |  C2   |  C1   |  C0   | |
\       |   1   |   1   |   1   |   1   |   0   |   0   |   1   |   1   |   1   |   1   |   1   |   1   |   1   |   0   | | 
\       |       |       |       |       |       |       |       |       |       |       |       |       |       |       | |
\  idle_____     _s_     _s_     _s_         _o_     _o___s_     _s_     _s_     _s_     _s_     _s_     _s_         _o___s_idle
\           |   |   |   |   |   |   |       ^   |   ^       |   |   |   |   |   |   |   |   |   |   |   |   |       ^   
\           v___|   v_o_|   v_o_|   v_o___s_|   |_s_|       v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o_|   v_o___s_|
\           I   i   R   i   R   i   R       R   i   R       R   i   R   i   R   i   R   i   R   i   R   i   R       R
\                 |       |       |       |       |       |       |       |       |       |       |       |       |       |
\ samples :       1       2       3       4       5       6       7       8       9       10      11      12      13      14
\
\
\ I = first interruption at the first 1/2 cycle : clear and start timer
\ i = useless RC5_Int (because aperiodic) at 4/4 cycle
\ s = sample RC5_intput at (1/2+3/4) = 5/4 cycle = n+1/4 cycles and clear useless RC5_Int
\ R = usefull (periodic) RC5_Int at 6/4 cycle = n+1/2 cycles : load new timer value, then clear it and restart it
\ o = RC5_Int time out at 7/4 cycle = n+3/4 cycles, used to detect truncated RC5_message (samples<14)
\
\ see also : http://www.sbprojects.com/knowledge/ir/rc5.php
\            http://laurent.deschamps.free.fr/ir/rc5/rc5.htm
\ Code RC5 : http://en.wikipedia.org/wiki/RC-5
\
