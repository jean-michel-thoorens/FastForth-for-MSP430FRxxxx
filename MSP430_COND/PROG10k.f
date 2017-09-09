; -----------------------------------
; prog10k.4th
; -----------------------------------
    \
PWR_STATE
\ NOECHO      ; if an error occurs during download, comment this line then download again
    \
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


\ ===========================================================================
\ remember: for good downloading to target, all lines must be ended with CR+LF !
\ ===========================================================================


\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4
\ example : PUSHM IP,Y
\
\ POPM  order :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before ?JMP ?GOTO    : S< S>= U< U>= 0= 0<> 0< 

\ FORTH conditionnal    : 0= 0< = < > U<

\ display on a LCD 2x20 CHAR the code sent by an IR remote under philips RC5 protocol
\ target : any TI MSP-EXP430FRxxxx launchpad (FRAM)
\ LPM_MODE = LPM0 because use SMCLK for LCDVo

\ DEMO : driver for IR remote compatible with the PHILIPS RC5 protocol
\ plus : driver for 5V LCD 2x20 characters display with 4 bits data interface
\        without usage of an auxiliary 5V to feed the LCD_Vo
\        and without potentiometer to adjust the LCD contrast :
\        to adjust LCD contrast, just press S1 (-) or S2 (+)
\        LCDVo current consumption ~ 500 uA.

\ ===================================================================================
\ notice : adjust TA0EX0,TB0CTL,TB0EX0 and 20_us to the target frequency if <> 8MHz !
\ ===================================================================================


\ layout : I/O are defined in the launchpad.pat file (don't work with ChipStick_FR2433)

\  GND  <-------+---0V0---------->  1 LCD_Vss
\  VCC  >------ | --3V6-----+---->  2 LCD_Vdd
\               |           |
\              ___    470n ---
\               ^          ---
\              / \ 1N4148   |
\              ---          |
\          100n |    2k2    |
\ TB0.2 >---||--+--^/\/\/v--+---->  3 LCD_Vo (= 0V6 without modulation)
\       ------------------------->  4 LCD_RW
\       ------------------------->  5 LCD_RW
\       ------------------------->  6 LCD_EN
\       <------------------------> 11 LCD_DB4
\       <------------------------> 12 LCD_DB5
\       <------------------------> 13 LCD_DB5
\       <------------------------> 14 LCD_DB7

\       <----- LCD contrast + <---    Sw1   <--- (finger) :-)
\       <----- LCD contrast - <---    Sw2   <--- (finger) :-)

\ rc5   <--- OUT IR_Receiver (1 TSOP32236)


PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \


PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \



PWR_STATE


CODE MAX    \    n1 n2 -- n3       signed maximum
            CMP     @PSP,TOS    \ n2-n1
            S<      ?GOTO FW1   \ n2<n1
BW1         ADD     #2,PSP
            MOV     @IP+,PC
ENDCODE
    \

CODE MIN    \    n1 n2 -- n3       signed minimum
            CMP     @PSP,TOS     \ n2-n1
            S<      ?GOTO BW1    \ n2<n1
FW1         MOV     @PSP+,TOS
            MOV     @IP+,PC
ENDCODE
    \

: U.R                       \ u n --           display u unsigned in n width (n >= 2)
  >R  <# 0 # #S #>  
  R> OVER - 0 MAX SPACES TYPE
;
    \

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W                \ 3 MCLK = 1 MHz
\    MOV     #23,W               \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W              \ 3 MCLK = 16 MHz
\    MOV     #158,W              \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND.B #LCD_DB,TOS           \ 
    MOV.B TOS,&LCD_DB_OUT       \ send LCD_Data
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV @PSP+,TOS               \
    MOV @IP+,PC
THEN                            \ read LCD bits pattern
    SUB #2,PSP
    MOV TOS,0(PSP)
    BIC.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 1-->0 ==> strobe data
    MOV.B &LCD_DB_IN,TOS        \ get LCD_Data
    AND.B #LCD_DB,TOS           \
    MOV @IP+,PC
ENDCODE
    \

CODE LCD_W                      \ byte --       write byte to LCD 
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;
    \

CODE LCD_WrC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W 
ENDCODE
    \

CODE LCD_WrF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W 
ENDCODE
    \

: LCD_Clear 
    $01 LCD_WrF 100 20_us      \  $01 LCD_WrF 80 20_us ==> bad init !
;
    \

: LCD_Home 
    $02 LCD_WrF 100 20_us 
;
    \

\ : LCD_Entry_set       $04 OR LCD_WrF ;

\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;

\ : LCD_Display_Shift   $10 OR LCD_WrF ;

\ : LCD_Fn_Set          $20 OR LCD_WrF ;

\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;

\ : LCD_Goto            $80 OR LCD_WrF ;

\ CODE LCD_R                      \ -- byte       read byte from LCD
\     BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000HHHH
\     TOP_LCD 2 20_us             \ -- %0000HHHH %0000LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH0000 %0000LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHHLLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\     \

\ CODE LCD_RdS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\     JMP LCD_R
\ ENDCODE
\     \

\ CODE LCD_RdC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     JMP LCD_R
\ ENDCODE
\     \

\ -------------+------+------+------+------++---+---+---+---+---------+
\ SR(low byte) | SCG1 | SCG0 |OSCOFF|CPUOFF||GIE| N | Z | C | current |
\ -------------+------+------+------+------++---+---+---+---+---------+
\ LPM0 = $18  |  0   |  0   |  0   |  1   || 1 | x | x | x |  180uA  | default mode
\ LPM1 = $58  |  0   |  1   |  0   |  1   || 1 | x | x | x |         | same mode as LPM0
\ LPM2 = $98  |  1   |  0   |  0   |  1   || 1 | x | x | x |   60uA  |
\ LPM3 = $D8  |  1   |  1   |  0   |  1   || 1 | x | x | x |   10uA  | 32768Hz XTAL is running
\ LPM4 = $F8  |  1   |  1   |  1   |  1   || 1 | x | x | x |    6uA  |
\ -------------+------+------+------+------++---+---+---+---+---------+


\ ******************************\
ASM WDT_INT                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                \ set CPU ON and GIE OFF in retiSR to force fall down to LPM mode
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #38,&TB0CCR2            \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
    U< IF
        ADD #1,&TB0CCR2         \ action for switch S2 (P2.5) : 78 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
            SUB #1,&TB0CCR2     \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
ASM RC5_INT                     \   wake up on Px.RC5 change interrupt
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : BASE,TOS,IP,W,X,Y, TA0 timer, TA0R register
\                               \ out : TOS = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ------------------------------\
BIC     #$F8,0(RSP)            \ CPU is ON and GIE is OFF in retiSR to force fall down to LPM0_LOOP
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ RC5_FirstStartBitHalfCycle:   \
\ ------------------------------\
MOV     #0,&TA0EX0              \ predivide by 1 in TA0EX0 register ( 8 MHZ), reset value
\ MOV     #1,&TA0EX0              \ predivide by 2 in TA0EX0 register (16 MHZ)
\ MOV     #2,&TA0EX0              \ predivide by 3 in TA0EX0 register (24 MHZ)
MOV     #1778,X                 \ RC5_Period in us
MOV     #14,W                   \ count of loop
BEGIN                           \
\ ------------------------------\
\ RC5_TopSynchro:               \ <--- loop back ---+ with readjusted RC5_Period
\ ------------------------------\                   | here, we are just after 1/2 RC5_cycle
    MOV #%1011100100,&TA0CTL   \ (re)start timer_A | SMCLK/8 : 1us time interval,free running,clear TA0_IFG and TA0R
\ RC5_Compute_3/4_Period:       \                   |
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
            BIC  #$30,&TA0CTL  \                       |   stop timer_A0
            RETI                \                       |   then quit to do nothing
        THEN                    \                       |
\ ------------------------------\                       |
        BIT.B   #RC5,&IR_IFG    \                   ^   |   test P1.2_IFG
    0<> UNTIL                   \                   |   |
    MOV     &TA0R,X             \                   |   |   get new RC5_period value 
REPEAT                          \ ----> loop back --+   |
\ ------------------------------\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ------------------------------\
BIC     #$30,&TA0CTL           \ stop timer_A0
RLAM    #1,IP                   \ IP =  x /C6 Tg A4 A3 A2|A1 A0 C5 C4 C3 C2 C1 C0  1  0
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(9) bit as toggle bit
\ ******************************\
MOV     @RSP,X                  \ retiSR(9)  = old UF9 = old RC5 toggle bit
RLAM    #4,X                    \ retiSR(11,10,9)= X(11,10,9) --> X(15,14,13)
XOR     IP,X                    \ (new XOR old) Toggle bit (13)
BIT     #BIT13,X                \ X(13) = New_RC5_command
0= IF RETI                      \ case of repeated RC5_command : RETI without SR(9) change
THEN                            \
XOR     #UF9,0(RSP)             \ change Toggle bit memory, UserFlag1 = SR(9) = 1
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
SUB     #4,PSP                  \
MOV     &BASE,2(PSP)            \ save variable BASE before use
MOV     TOS,0(PSP)              \ save TOS before use
MOV.B   IP,TOS                  \ TOS = C5 C4 C3 C2 C1 C0  0  0
RRUM    #2,TOS                  \ TOS =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #$4000,IP              \ test /C6 bit in IP
0= IF   BIS #$40,TOS           \ set C6 bit in S
THEN                            \ TOS =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ RC5_code --
\ ******************************\

\ ------------------------------\
\ Display IR_RC5 code           \
\ ------------------------------\
\ BIS.B #LED1,&LED1_OUT           \ switch ON LED1, comment if no LED
\ ------------------------------\
LO2HI                           \ switch from assembler to FORTH
    ['] LCD_CLEAR IS CR         \ redirects CR
    ['] LCD_WrC  IS EMIT        \ redirects EMIT
    $10 BASE !                 \ change BASE to hexadecimal
    CR ." $" 2 U.R             \ print IR_RC5 code
    ['] (CR) IS CR              \ restore CR
    ['] (EMIT) IS EMIT          \ restore EMIT
HI2LO                           \ switch from FORTH to assembler
\ ------------------------------\
\ BIC.B #LED1,&LED1_OUT           \ switch OFF LED1, comment if no LED
\ ------------------------------\
MOV @PSP+,&BASE                 \ restore variable BASE
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \ 

CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up to TB0CCR0
\                            -  \TBCLR TimerB Clear
\                             - \TBIE
\                              -\TBIFG
\ --------------------------------\\
\ TB0CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\              --                 \CM Capture Mode
\                --               \CCIS
\                   -             \SCS
\                    --           \CLLD
\                      -          \CAP
\                        ---      \OUTMOD \ 011 = set/reset
\                           -     \CCIE
\                             -   \CCI
\                              -  \OUT
\                               - \COV
\                                -\CCIFG
\ TB0CCRx                         \$3D{2,4,6,8,A,C,E}
\ TB0EX0                          \$3E0 
\ ------------------------------\
\ set TimerB to make 50kHz PWM  \
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL  \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL  \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate PWM for LCD_Vo
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2    \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2           \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2 TB0.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
    MOV #$5A5E,&WDTCTL         \ init WDT VLOCLK source ~10kHz /2^9 (50 ms), interval mode
\    MOV #$5A3D,&WDTCTL         \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL         \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init RC5_Int                  \
\ ------------------------------\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_INT,&WDT_Vec       \ init WDT interval vector interrupt
    MOV #RC5_INT,&IR_Vec        \ init interrupt vector
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4,&LPM_MODE         \ with MSP430FR59xx
\    MOV #LPM2,&LPM_MODE         \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value

LO2HI                           \ no need to push IP because (WARM) resets the Return Stack ! 

\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    $03E8 20_US                \ 1-  wait 20 ms
    $03 TOP_LCD                \ 2- send DB5=DB4=1
    $CD 20_US                  \ 3- wait 4,1 ms
    $03 TOP_LCD                \ 4- send again DB5=DB4=1
    $5 20_US                   \ 5- wait 0,1 ms
    $03 TOP_LCD                \ 6- send again again DB5=DB4=1
    $2 20_US                   \    wait 40 us = LCD cycle
    $02 TOP_LCD                \ 7- send DB5=1 DB4=0
    $2 20_US                   \    wait 40 us = LCD cycle
    $28 LCD_WRF                \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WRF                \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    $06 LCD_WRF                \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WRF                \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_Clear                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR              \ ' (CR) is CR
    ['] (EMIT) IS EMIT          \ ' (EMIT) is EMIT
    CR
    ."    RC5toLCD is running. Type STOP to quit"
\    NOECHO                      \ uncomment to run this app without terminal connexion
    LIT RECURSE IS WARM         \ insert this START routine between WARM and (WARM)...
    (WARM)                      \ ...and continue with (WARM) (very, very usefull after COLD or RESET !:-)
;
    \

: STOP                  \ stops multitasking, must to be used before downloading app
    ['] (WARM) IS WARM  \ remove START app from FORTH init process
    ECHO COLD           \ reset CPU, interrupt vectors, and start FORTH
;
    \




ECHO
            ; download is done
PWR_HERE    ; this app is protected against power ON/OFF,
\ START
