\ ------------------------------
\ MSP430FR5xxx_LCD_20.f
\ ------------------------------
RST_STATE
\ NOECHO
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


 
\ driver for LCD 2x20 characters display with 4 bits data interface 
\ without usage of an auxiliary 5V to feed the Vo of LCD
\ without potentiometer to adjust the LCD contrast
\ LCD contrast software adjustable by 2 switches
\ TB0.2 current consumption ~ 500 uA
    
\ layout : see config.pat file for defining I/O

\  GND  <-------+---0V0---------->  1 LCD_Vss
\  VCC  >------ | --3V6-----+---->  2 LCD_Vdd
\               |           |
\             |___    470n ---
\               ^ |        ---
\              / \ BAT54    |
\              ---          |
\          100n |    2k2    |
\ TB0.2 >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
\       ------------------------->  4 LCD_RW
\       ------------------------->  5 LCD_RW
\       ------------------------->  6 LCD_EN
\       <------------------------> 11 LCD_DB4
\       <------------------------> 12 LCD_DB5
\       <------------------------> 13 LCD_DB5
\       <------------------------> 14 LCD_DB7

\ Sw1   <--- LCD contrast + (finger :-)
\ Sw2   <--- LCD contrast - (finger \-)
                                    


\ ------------------------------\
CODE 20_us                      \ n --      n * 20 us
\ ------------------------------\
BEGIN                           \ 3 cycles loop + 6~  
\    MOV     #5,W               \ 3 MCLK = 1 MHz
\    MOV     #23,W              \ 3 MCLK = 4 MHz
    MOV     #51,W               \ 3 MCLK = 8 MHz
\    MOV     #104,W             \ 3 MCLK = 16 MHz
\    MOV     #158,W             \ 3 MCLK = 24 MHz
    BEGIN                       \ 3 cycles loop ==> 3 * W / F us = 100 us - 1 @ 8 MHz
        SUB #1,W                \ 1
    0= UNTIL                    \ 2
    SUB     #1,TOS              \ 1
0= UNTIL                        \ 2
    MOV     @PSP+,TOS           \ 2
    MOV     @IP+,PC             \ 4
ENDCODE
    \

\ ------------------------------\
CODE TOP_LCD                    \ LCD Sample
\ ------------------------------\ if write : %xxxxWWWW --
\                               \ if read  : -- %0000RRRR
    BIS.B #LCD_EN,&LCD_CMD_OUT  \ lcd_en 0-->1
    BIT.B #LCD_RW,&LCD_CMD_IN   \ lcd_rw test
0= IF                           \ write LCD bits pattern
    AND #LCD_DB,TOS             \ 
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

\ ------------------------------\
CODE LCD_W                      \ byte --       write byte 
\ ------------------------------\
    SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxxLLLL %HHHHLLLL
    RRUM #4,TOS                 \ -- %xxxxLLLL %xxxxHHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
    COLON
    TOP_LCD 2 20_us             \ write high nibble first
    TOP_LCD 2 20_us ;
    \

\ ------------------------------\
CODE LCD_R                      \ -- byte       read byte
\ ------------------------------\
    BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
    BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
    COLON
    TOP_LCD 2 20_us             \ read high nibble first
    TOP_LCD 2 20_us
    HI2LO                       \ -- %0000HHHH %0000LLLL
    MOV @RSP+,IP
    MOV @PSP+,W                 \ W = high nibble
    RLAM #4,W                   \ -- %0000LLLL     W = %HHHH0000 
    ADD.B W,TOS
    MOV @IP+,PC
ENDCODE
    \
\ ------------------------------\
CODE LCD_WrF                    \ func --         Write Fonction
\ ------------------------------\
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_W
ENDCODE
    \
\ ------------------------------\
CODE LCD_RdS                    \ -- status       Read Status
\ ------------------------------\
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    JMP LCD_R
ENDCODE
    \
\ ------------------------------\
CODE LCD_WrC                    \ char --         Write Char
\ ------------------------------\
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_W
ENDCODE
    \
\ ------------------------------\
CODE LCD_RdC                    \ -- char         Read Char
\ ------------------------------\
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
    JMP LCD_R
ENDCODE
    \
\ ------------------------------\
\  : LCD_Clear $01 LCD_WrF 80 20_us ; \ bad init !
: LCD_Clear $01 LCD_WrF 100 20_us ;
    \
\ ------------------------------\
: LCD_Home $02 LCD_WrF 80 20_us ;
    \
\ ------------------------------\
\ : LCD_Entry_set       $04 OR LCD_WrF ;
\ : LCD_Display_Ctrl    $08 OR LCD_WrF ;
\ : LCD_Display_Shift   $10 OR LCD_WrF ;
\ : LCD_Fn_Set          $20 OR LCD_WrF ;
\ : LCD_CGRAM_Set       $40 OR LCD_WrF ;
\ : LCD_Goto            $80 OR LCD_WrF ;

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
ASM WDT_Int                     \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
BIC #$F8,0(RSP)                 \ set CPU ON and GIE OFF in retiSR
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
  CMP #34,&TB0CCR2              \ maxi Ton = 34/40 & VDD=3V6 ==> LCD_Vo = -2V2
  U< IF
    ADD #1,&TB0CCR2             \ action for switch S2 (P2.5) : 78 mV / increment
  THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #7,&TB0CCR2         \ mini Ton = 6/40 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
        SUB #1,&TB0CCR2         \ action for switch S1 (P2.6) : -78 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ CPU is ON, GIE is OFF
ENDASM                          \
    \


\ ------------------------------\
CODE START                      \
\ ------------------------------\
\ TB0CTL = %0000 0010 1001 0100\$3C0
\               - -             \CNTL Counter lentgh \ 00 = 16 bits
\                   --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                      --       \ID input divider \ 10 = /4
\                        --     \MC Mode Control \ 01 = up mode
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
\    MOV #%1000010100,&TB0CTL   \ SMCLK/1, up mode, clear timer, no int
\    MOV #0,&TB0EX0             \ predivide by 1 in TB0EX0 register (1 MHZ) (25 kHz PWM)
\ ------------------------------\
\    MOV #%1000010100,&TB0CTL   \ SMCLK/1, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (4 MHZ)
\ ------------------------------\
    MOV #%1010010100,&TB0CTL    \ SMCLK/4, up mode, clear timer, no int
    MOV #0,&TB0EX0              \ predivide by 1 in TB0EX0 register (8 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
\    MOV #1,&TB0EX0             \ predivide by 2 in TB0EX0 register (16 MHZ)
\ ------------------------------\
\    MOV #%1010010100,&TB0CTL   \ SMCLK/4, up mode, clear timer, no int
\    MOV #2,&TB0EX0             \ predivide by 3 in TB0EX0 register (24 MHZ)
\ ------------------------------\
    MOV #40,&TB0CCR0            \ 40*0.5us=20us (40us @ 1MHz)
\ ------------------------------\
\ set TimerB to generate LCD_V0 via TB0.2 and P1.5/P2.2
\ ------------------------------\
    MOV #%1100000,&TB0CCTL2     \ output mode = set/reset \ clear CCIFG
\    MOV #20,&TB0CCR2            \ contrast adjust : 20/40 ==> LCD_Vo = -1V1|+3V6 (Vcc=3V6)
    MOV #25,&TB0CCR2            \ contrast adjust : 25/40 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
\ ------------------------------\
\ WDT interval init part        \
\ ------------------------------\
\    MOV #$5A5E,&WDTCTL          \ init WDT Vloclk source 10kHz /2^9 (50 ms), interval mode
    MOV #$5A3D,&WDTCTL          \ init WDT ACLK source 32.768kHz /2^13 (250 ms), interval mode
\    MOV #$5A5D,&WDTCTL          \ init WDT Vloclk source 10kHz /2^13 (800 ms), interval mode
    BIS #1,&SFRIE1              \ enable WDT interval mode interrupt in SFRIE
\ ------------------------------\
\ init interrupt vectors
\ ------------------------------\
    MOV #WDT_Int,&WDT_Vec       \ init WDT interval vector interrupt
\ ------------------------------\
\ init PORTA (P2:P1) (complement)
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL0    \ SEL0.2 TB0.2
\ ------------------------------\
\ init PORTB (P4:P3) (complement)
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
\ init PORTJ (PJ) (complement)
    BIS.B   #LCD_DB,&LCD_DB_DIR \ PJDIR.(0-3) as output, wired to DB(4-7) LCD_Data
    BIC.B   #LCD_DB,&LCD_DB_REN \ PJREN.(0-3) LCD_Data pullup/down disable
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\ MOV #LPM4,&LPM_MODE             \ with MSP430FR59xx
\ MOV #LPM2,&LPM_MODE             \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                                 \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
\ Init LCD
    LO2HI
    $3E8 20_us              \ 1-  wait 20 ms
    $03 TOP_LCD             \ 2- send DB5=DB4=1
    $CD 20_us               \ 3- wait 4,1 ms
    $03 TOP_LCD             \ 4- send again DB5=DB4=1
    5 20_us                 \ 5- wait 0,1 ms
    $03 TOP_LCD             \ 6- send again again DB5=DB4=1
    2 20_us                 \    wait 40 us = LCD cycle
    $02 TOP_LCD             \ 7- send DB5=1 DB4=0
    2 20_us                 \    wait 40 us = LCD cycle
    $28 LCD_WrF             \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    $08 LCD_WrF             \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_Clear               \ 10- "LCD_Clear"
    $06 LCD_WrF             \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    $0C LCD_WrF             \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    ['] LCD_HOME IS CR      \ ' CR redirected to LCD_HOME
    ['] LCD_WrC  IS EMIT    \ ' EMIT redirected to LCD_WrC
    CR ." I love you"   
    ['] (CR) IS CR          \ ' (CR) is CR
    ['] (EMIT) IS EMIT      \ ' (EMIT) is EMIT
    ."    xxxx_to_LCD is running. Type STOP to quit"
    LIT RECURSE IS WARM         \ insert this starting routine between COLD and WARM...
    ['] WARM >BODY EXECUTE      \ ...and continue with WARM (very, very usefull after COLD or RESET !:-)
 ;

: STOP                          \ stops multitasking, must to be used before downloading app
    ['] WARM >BODY  IS WARM     \ remove START app from FORTH init process
    ECHO COLD                   \ reset CPU, interrupt vectors, and start FORTH
;

PWR_HERE               \ set here the power_on dictionnary 
