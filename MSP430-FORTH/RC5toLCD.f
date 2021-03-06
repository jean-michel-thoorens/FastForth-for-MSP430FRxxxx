\ -*- coding: utf-8 -*-

; -----------------------------------
; RC5TOLCD.f
; -----------------------------------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, FREQUENCY = 8/16/24 MHz
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR2355
\ LP_MSP430FR2476
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\
\ ================================================================================
\ REGISTERS USAGE for embedded MSP430 ASSEMBLER
\ ================================================================================
\ don't use R2, R3, R4
\ R5, R6, R7 must be PUSHed/POPed before/after use, OR restored after: MOV #{XDOCOL|XDOCON|R>},{rDODOES|rDOCON|rDOVAR}
\ scratch registers Y to S are free,
\ under interrupt, IP is free,
\ use FORTH rules for reg. TOS, PSP, RSP.
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
\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before      ?GOTO    : S< S>= U< U>= 0= 0<> 0< 
\
\
\ display on a LCD 2x20 CHAR the code sent by an IR remote under philips RC5 protocol
\ target : any TI MSP-EXP430FRxxxx launchpad (FRAM)
\ LPM_MODE = LPM0 because use SMCLK for LCDVo
\
\ DEMO : driver for IR remote compatible with the PHILIPS RC5 protocol
\ plus : driver for 5V LCD 2x20 characters display with 4 bits data interface
\        without usage of an auxiliary 5V to feed the LCD_Vo
\        and without potentiometer to adjust the LCD contrast :
\        to adjust LCD contrast, just press S1 (-) or S2 (+)
\        LCDVo current consumption ~ 500 uA.
\
\ ===================================================================================
\ notice : adjust WDT_TIM_EX0,LCD_TIM_CTL,LCD_TIM_EX0 and 20_us to the target frequency if <> 8MHz !
\ ===================================================================================
\
\
\ layout : I/O are defined in the launchpad.pat file (don't work with ChipStick_FR2433)
\
\  GND  <-------o---0V0---------->  1 LCD_Vss
\  VCC  >-------|---3V6-----o---->  2 LCD_Vdd
\               |           |
\              ___    470n ---
\               ^          ---
\              / \ 1N4148   |
\              ---          |
\          100n |    2k2    |
\ TB0.2 >---||--o--^/\/\/v--o---->  3 LCD_Vo (= 0V6 without modulation)
\       ------------------------->  4 LCD_RW
\       ------------------------->  5 LCD_RW
\       ------------------------->  6 LCD_EN
\       <------------------------> 11 LCD_DB4
\       <------------------------> 12 LCD_DB5
\       <------------------------> 13 LCD_DB5
\       <------------------------> 14 LCD_DB7
\
\       <----- LCD contrast + <---    Sw1   <--- (finger) :-)
\       <----- LCD contrast - <---    Sw2   <--- (finger) :-)
\
\ rc5   <--- OUT IR_Receiver (1 TSOP32236)


\ first, we test for downloading driver only if UART TERMINAL target
CODE ABORT_RC5TOLCD
SUB #2,PSP
MOV TOS,0(PSP)
MOV &VERSION,TOS
SUB #308,TOS        \ FastForth V3.8
COLON
'CR' EMIT            \ return to column 1 without 'LF'
ABORT" FastForth V3.8 please!"
PWR_STATE           \ remove ABORT_UARTI2CS definition before resuming
;

ABORT_RC5TOLCD


[DEFINED] {RC5TOLCD} [IF] {RC5TOLCD} [THEN]     \ remove application

MARKER {RC5TOLCD}   \ restore the state before MARKER definition
\                   \ {UARTI2CS}+8 = RET_ADR: by default MARKER_DOES does CALL #RET_ADR
6 ALLOT             \ {UARTI2CS}+10: make room to save previous INI_APP address
                    \ {RC5TOLCD}+12: make room to save previous WDT_TIM_0_VEC
                    \ {RC5TOLCD}+14: make room to save previous IR_VEC

[UNDEFINED] CONSTANT [IF]
\ https://forth-standard.org/standard/core/CONSTANT
\ CONSTANT <name>     n --                      define a Forth CONSTANT 
: CONSTANT 
CREATE
HI2LO
MOV TOS,-2(W)           \   PFA = n
MOV @PSP+,TOS
MOV @RSP+,IP
MOV @IP+,PC
ENDCODE
[THEN]

[UNDEFINED] STATE [IF]
\ https://forth-standard.org/standard/core/STATE
\ STATE   -- a-addr       holds compiler state
STATEADR CONSTANT STATE
[THEN]

[UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
CODE =
SUB @PSP+,TOS   \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1
    MOV @IP+,PC \ 4
THEN
XOR #-1,TOS     \ 1 flag Z = 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

[UNDEFINED] IF [IF]     \ define IF and THEN
\ https://forth-standard.org/standard/core/IF
\ IF       -- IFadr    initialize conditional forward branch
CODE IF       \ immediate
SUB #2,PSP              \
MOV TOS,0(PSP)          \
MOV &DP,TOS             \ -- HERE
ADD #4,&DP            \           compile one word, reserve one word
MOV #QFBRAN,0(TOS)      \ -- HERE   compile QFBRAN
ADD #2,TOS              \ -- HERE+2=IFadr
MOV @IP+,PC
ENDCODE IMMEDIATE

\ https://forth-standard.org/standard/core/THEN
\ THEN     IFadr --                resolve forward branch
CODE THEN               \ immediate
MOV &DP,0(TOS)          \ -- IFadr
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] ELSE [IF]
\ https://forth-standard.org/standard/core/ELSE
\ ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
CODE ELSE     \ immediate
ADD #4,&DP              \ make room to compile two words
MOV &DP,W               \ W=HERE+4
MOV #BRAN,-4(W)
MOV W,0(TOS)            \ HERE+4 ==> [IFadr]
SUB #2,W                \ HERE+2
MOV W,TOS               \ -- ELSEadr
MOV @IP+,PC
ENDCODE IMMEDIATE
[THEN]

[UNDEFINED] IS [IF]     \ define DEFER! and IS

\ https://forth-standard.org/standard/core/DEFERStore
\ Set the word xt1 to execute xt2. An ambiguous condition exists if xt1 is not for a word defined by DEFER.
CODE DEFER!             \ xt2 xt1 --
MOV @PSP+,2(TOS)        \ -- xt1=CFA_DEFER          xt2 --> [CFA_DEFER+2]
MOV @PSP+,TOS           \ --
MOV @IP+,PC
ENDCODE

\ https://forth-standard.org/standard/core/IS
\ IS <name>        xt --
\ used as is :
\ DEFER DISPLAY                         create a "do nothing" definition (2 CELLS)
\ inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
\ or in a definition : ... ['] U. IS DISPLAY ...
\ KEY, EMIT, CR, ACCEPT and WARM are examples of DEFERred words
\
\ as IS replaces the PFA value of any word, it's a TO alias for VARIABLE and CONSTANT words...

: IS
STATE @
IF  POSTPONE ['] POSTPONE DEFER! 
ELSE ' DEFER! 
THEN
; IMMEDIATE
[THEN]

[UNDEFINED] >BODY [IF]
\ https://forth-standard.org/standard/core/toBODY
\ >BODY     -- addr      leave BODY of a CREATEd word\ also leave default ACTION-OF primary DEFERred word
CODE >BODY
ADD #4,TOS
MOV @IP+,PC
ENDCODE
[THEN]

\ CODE 20uS           \ n --      8MHz version
\ BEGIN               \ 4 + 16 ~ loop
\     MOV #39,rDOCON   \ 39
\     BEGIN           \ 4 ~ loop
\         NOP
\         SUB #1,rDOCON
\     0=  UNTIL
\     SUB #1,TOS      \ 1
\ 0= UNTIL
\ MOV #XDOCON,rDOCON  \ 2
\ MOV @PSP+,TOS
\ MOV @RSP+,IP        \
\ ENDCODE

CODE 20_US                      \ n --      n * 20 us
BEGIN                           \ here we presume that LCD_TIM_IFG = 1...
    BEGIN
        BIT #1,&LCD_TIM_CTL     \ 3
    0<> UNTIL                   \ 2         loop until LCD_TIM_IFG set
    BIC #1,&LCD_TIM_CTL         \ 3         clear LCD_TIM_IFG
    SUB #1,TOS                  \ 1
U< UNTIL                        \ 2 ...so add a dummy loop with U< instead of 0=
MOV @PSP+,TOS                   \ 2
MOV @IP+,PC                     \ 4
ENDCODE

CODE TOP_LCD                    \ LCD Sample
\                               \ if write : %xxxx_WWWW --
\                               \ if read  : -- %0000_RRRR
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

CODE LCD_WRC                    \ char --         Write Char
    BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
BW1 SUB #2,PSP                  \
    MOV TOS,0(PSP)              \ -- %xxxx_LLLL %HHHH_LLLL
    RRUM #4,TOS                 \ -- %xxxx_LLLL %xxxx_HHHH
    BIC.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=0
    BIS.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as output
COLON                           \ high level word starts here 
    TOP_LCD 2 20_US             \ write high nibble first
    TOP_LCD 2 20_US 
;

CODE LCD_WRF                    \ func --         Write Fonction
    BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
    GOTO BW1
ENDCODE

: LCD_CLEAR $01 LCD_WRF 100 20_us ;    \  $01 LCD_WrF 80 20_us ==> bad init !
: LCD_HOME $02 LCD_WRF 100 20_us ;

\ [UNDEFINED] OR [IF]
\ 
\ \ https://forth-standard.org/standard/core/OR
\ \ C OR     x1 x2 -- x3           logical OR
\ CODE OR
\ BIS @PSP+,TOS
\ MOV @IP+,PC
\ ENDCODE
\ 
\ [THEN]
\ 
\ : LCD_ENTRY_SET     $04 OR LCD_WrF ;
\ : LCD_DSP_CTRL      $08 OR LCD_WrF ;
\ : LCD_DSP_SHIFT     $10 OR LCD_WrF ;
\ : LCD_FN_SET        $20 OR LCD_WrF ;
\ : LCD_CGRAM_SET     $40 OR LCD_WrF ;
\ : LCD_GOTO          $80 OR LCD_WrF ;
\ 
\ 
\ CODE LCD_RDS                    \ -- status       Read Status
\     BIC.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=0
\ BW1 BIC.B #LCD_DB,&LCD_DB_DIR   \ LCD_Data as intput
\     BIS.B #LCD_RW,&LCD_CMD_OUT  \ lcd_rw=1
\ COLON                           \ starts a FORTH word
\     TOP_LCD 2 20_us             \ -- %0000_HHHH
\     TOP_LCD 2 20_us             \ -- %0000_HHHH %0000_LLLL
\ HI2LO                           \ switch from FORTH to assembler
\     RLAM #4,0(PSP)              \ -- %HHHH_0000 %0000_LLLL
\     ADD.B @PSP+,TOS             \ -- %HHHH_LLLL
\     MOV @RSP+,IP                \ restore IP saved by COLON
\     MOV @IP+,PC                 \
\ ENDCODE
\ 
\ CODE LCD_RDC                    \ -- char         Read Char
\     BIS.B #LCD_RS,&LCD_CMD_OUT  \ lcd_rs=1
\     GOTO BW1
\ ENDCODE


\ ******************************\
HDNCODE WDT_INT                 \ Watchdog interrupt routine, warning : not FORTH executable !
\ ******************************\
\ XOR.B #LED1,&LED1_OUT           \ to visualise WDT
BIT.B #SW2,&SW2_IN              \ test switch S2
0= IF                           \ case of switch S2 pressed
    CMP #19,&LCD_TIM_CCRn       \ maxi Ton = 19/20 & VDD=3V6 ==> LCD_Vo = -1V4
    U< IF
        ADD #1,&LCD_TIM_CCRn    \ action for switch S2 (P2.5) : 150 mV / increment
    THEN
ELSE
    BIT.B #SW1,&SW1_IN          \ test switch S1 input
    0= IF                       \ case of Switch S1 pressed
        CMP #3,&LCD_TIM_CCRn    \ mini Ton = 3/20 & VDD=3V6 ==> LCD_Vo = 0V
        U>= IF                  \
           SUB #1,&LCD_TIM_CCRn \ action for switch S1 (P2.6) : -150 mV / decrement
        THEN                    \
    THEN                        \
THEN                            \
RETI                            \ 5
ENDCODE

\ ******************************\
HDNCODE RC5_INT                 \   wake up on Px.RC5 change interrupt
\ ******************************\
\ IR_RC5 driver                 \ IP,S,T,W,X,Y registers are free for use
\ ******************************\
\                               \ in :  SR(9)=old Toggle bit memory (ADD on)
\                               \       SMclock = 8|16|24 MHz
\                               \ use : T,W,X,Y, RC5_TIM_ timer, RC5_TIM_R register
\                               \ out : X = 0 C6 C5 C4 C3 C2 C1 C0
\                               \       SR(9)=new Toggle bit memory (ADD on)
\ ******************************\
\ RC5_FirstStartBitHalfCycle:   \
\ ******************************\                division in RC5_TIM_CTL (SMCLK/1|SMCLK/1|SMCLK/2|SMCLK/4|SMCLK/8)
\ FREQ_KHZ @ 8000 = [IF]        \ 8 MHz ?
\     MOV #0,&RC5_TIM_EX0       \ predivide by 1 in RC5_TIM_EX0 register, reset value
\ [THEN]
FREQ_KHZ @ 16000 = [IF]         \ 16 MHz ?
    MOV #1,&RC5_TIM_EX0         \ predivide by 2 in RC5_TIM_EX0 register
[THEN]
FREQ_KHZ @ 24000 = [IF]         \ 24 MHz ?
    MOV #2,&RC5_TIM_EX0         \ predivide by 3 in RC5_TIM_EX0 register
[THEN]
MOV #1778,X                     \ RC5_Period * 1us
MOV #14,W                       \ count of loop
BEGIN                           \
\ ******************************\
\ RC5_HalfCycle                 \ <--- loop back ---+ with readjusted RC5_Period
\ ******************************\                   |
MOV #%1011100100,&RC5_TIM_CTL   \ (re)start timer_A | SMCLK/8 time interval,free running,clear RC5_TIM__IFG and RC5_TIM_R
\ RC5_Compute_3/4_Period:       \                   |
    RRUM    #1,X                \ X=1/2 cycle       |
    MOV     X,Y                 \                   ^
    RRUM    #1,Y                \ Y=1/4
    ADD     X,Y                 \ Y=3/4 cycle
    BEGIN   CMP Y,&RC5_TIM_R    \ 3 wait 1/2 + 3/4 cycle = n+1/4 cycles 
    U>= UNTIL                   \ 2
\ ******************************\
\ RC5_SampleOnFirstQuarter      \ at n+1/4 cycles, we sample RC5_input, ST2/C6 bit first
\ ******************************\
    BIT.B   #RC5,&IR_IN         \ C_flag = IR bit
    ADDC    T,T                 \ C_flag <-- T(15):T(0) <-- C_flag
    MOV.B   &IR_IN,&IR_IES      \ preset Px_IES.y state for next IFG
    BIC.B   #RC5,&IR_IFG        \ clear Px_IFG.y after 4/4 cycle pin change
    SUB     #1,W                \ decrement count loop
\                               \  count = 13 ==> T = x  x  x  x  x  x  x  x |x  x  x  x  x  x  x /C6
\                               \  count = 0  ==> T = x  x /C6 Tg A4 A3 A2 A1|A0 C5 C4 C3 C2 C1 C0  1 
0<> WHILE                       \ ----> out of loop ----+
    ADD X,Y                     \                       |   Y = n+3/4 cycles = time out because n+1/2 cycles edge is always present
    BEGIN                       \                       |
        MOV &RC5_TIM_R,X        \ 3                     |   X grows from n+1/4 up to n+3/4 cycles
        CMP Y,X                 \ 1                     |   cycle time out of bound ?
        U>= IF                  \ 2                 ^   |   yes:
        BIC #$30,&RC5_TIM_CTL   \                   |   |      stop timer
        GOTO FW1                \                   |   |      quit on truncated RC5 message
        THEN                    \                   |   |
        BIT.B #RC5,&IR_IFG      \ 3                 |   |   n+1/2 cycles edge is always present
    0<> UNTIL                   \ 2                 |   |
REPEAT                          \ ----> loop back --+   |   with X = new RC5_period value
\ ******************************\                       |
\ RC5_SampleEndOf:              \ <---------------------+
\ ******************************\
BIC #$30,&RC5_TIM_CTL           \   stop timer
\ ******************************\
\ RC5_ComputeNewRC5word         \
\ ******************************\
RLAM    #1,T                    \ T =  x /C6 Tg A4 A3 A2 A1 A0|C5 C4 C3 C2 C1 C0  1  0
MOV.B   T,X                     \ X = C5 C4 C3 C2 C1 C0  1  0
RRUM    #2,X                    \ X =  0  0 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_ComputeC6bit              \
\ ******************************\
BIT     #BIT14,T                \ test /C6 bit in T
0= IF   BIS #BIT6,X             \ set C6 bit in X
THEN                            \ X =  0  C6 C5 C4 C3 C2 C1 C0
\ ******************************\
\ RC5_CommandByteIsDone         \ -- BASE RC5_code
\ ******************************\
\ Only New_RC5_Command ADD_ON   \ use SR(10) bit as toggle bit
\ ******************************\
RRUM    #3,T                    \ new toggle bit = T(13) ==> T(10)
XOR     @RSP,T                  \ (new XOR old) Toggle bits
BIT     #UF10,T                 \ repeated RC5_command ?
0= ?GOTO FW2                    \ yes, RETI without UF10 change and without action !
XOR #UF10,0(RSP)                \ 5 toggle bit memory
\ ******************************\
\ Display IR_RC5 code           \
\ ******************************\
SUB #8,PSP                      \ TOS -- x x x x TOS
MOV TOS,6(PSP)                  \     -- Save_TOS x x x TOS
MOV &BASEADR,4(PSP)             \     -- Save_TOS Save_Base x x TOS
MOV #$10,&BASEADR               \                                               set hexadecimal base
MOV X,0(PSP)                    \     -- Save_TOS Save_Base x RC5_code TOS      convert number to ascii low word = RC5 byte
MOV #0,TOS                      \     -- Save_TOS Save_Base x RC5_code 0        convert number to ascii high word = 0
LO2HI                           \                                               switch from assembler to FORTH
    LCD_CLEAR                   \                                               set LCD cursor at home
    <# # #S #36 HOLD #>         \                                               32 bits conversion as "$xx"
    ['] LCD_WRC IS EMIT         \                                               redirect EMIT to LCD
    TYPE                        \     -- Save_TOS Save_Base x adr cnt           display "$xx" on LCD
    ['] EMIT >BODY IS EMIT      \     -- Save_TOS Save_Base TOS                 restore EMIT
HI2LO                           \     --                                        switch from FORTH to assembler
MOV @PSP+,&BASEADR              \     -- Save_TOS TOS                           restore current BASE
MOV @PSP+,TOS                   \     -- TOS
FW1 FW2
    MOV @RSP+,SR                \ restore SR flags
    BIC #%1111_1000,SR          \ but force CPU Active Mode
    RET                         \ (instead of RETI)
ENDCODE


\ ------------------------------\
HDNCODE STOP_R2L                \ define new STOP_APP
\ ------------------------------\
CMP #RET_ADR,&{RC5TOLCD}+8      \
0<> IF                          \ if previous START executing
    BIC.B #RC5,&IR_IE           \ clear I/O RC5_Int
    BIC.B #RC5,&IR_IFG          \ clear I/O RC5_Int flag
    MOV #0,&LCD_TIM_CTL         \ stop LCD_TIMER
    MOV #0,&WDT_TIM_CTL         \ stop WDT_TIMER
    MOV #0,&WDT_TIM_CCTL0       \ clear CCIFG0 disable CCIE0
    MOV #RET_ADR,&{RC5TOLCD}+8  \ clear MARKER_DOES call
    MOV &{RC5TOLCD}+10,&WARM+2          \ restore previous ini_APP
    MOV &{RC5TOLCD}+12,&WDT_TIM_0_VEC   \ restore Vector previous value
    MOV &{RC5TOLCD}+14,&IR_VEC          \ restore Vector previous value
    MOV &{RC5TOLCD}+10,PC       \ run previous INI_APP, then RET
THEN 
MOV @RSP+,PC                    \ RET
ENDCODE

\ ------------------------------\
CODE STOP                       \
\ ------------------------------\
BW1                             \ <-- INI_R2L for some events
CALL #STOP_R2L
COLON                           \ restore default action of primary DEFERred word WARM (FORTH version)
ECHO                            \
." RC5toLCD is removed,"
."  type START to restart"
ABORT" "
;
\ ------------------------------\

\ ------------------------------\
HDNCODE INI_R2L                 \ this routine completes the init of system, i.e. FORTH + this app.
\ ------------------------------\
\ activate I/O                  \
\ ------------------------------\
BIC #1,&PM5CTL0                 \ activate I/O to enable SW2 test
\ ------------------------------\
\ RESET events handling         \ search "SYSRSTIV" in your MSP430FRxxxx datasheet to get listing
\ ------------------------------\
MOV &RSTIV_MEM,TOS              \ SYSRSTIV = $00|$02|$04|$0E|$xx = POWER_ON|RST|SVSH_threshold|SYS_failures
CMP #$0E,TOS                    \ RSTIV_MEM = SVSHIFG SVSH event ?
0<> IF                          \ if not
    CMP #$0A,TOS                \   RSTIV_MEM >= violation memory protected areas ?
    U>= ?GOTO BW1               \   execute STOP_R2L then RET to BODY of WARM
THEN                            \
BIT.B #SW2,&SW2_IN              \ hardware SW2+RST ?
0= ?GOTO BW1                    \ hardware SW2+RST execute STOP_U2I then RET to BODY of WARM
\ CMP #4,TOS                      \ hardware RST 
\ 0= ?GOTO BW1                    \ hardware RST performs STOP.
\ CMP #2,TOS                      \ Power_ON event
\ 0= ?GOTO BW1                    \ uncomment if you want to loose application in this case...
\ CMP #6,TOS                      \
\ 0= ?GOTO BW1                    \ COLD event performs STOP... uncomment if it's that you want.
\ CMP #$0A,TOS                    \
\ 0= ?GOTO BW1                    \ fault event (violation memory protected areas) performs STOP
\ CMP #$16,TOS                    \
\ U>= ?GOTO BW1                   \ all other fault events + Deep Reset perform STOP
MOV #0,&RSTIV_MEM               \ clear RSTIV_MEM after use and before next RST event!
\ ------------------------------\
\ LCD_TIM_CTL =  %0000 0010 1001 0100\$3C0
\                    - -             \CNTL Counter lentgh \ 00 = 16 bits
\                        --          \TBSSEL TimerB clock select \ 10 = SMCLK
\                           --       \ID input divider \ 10 = /4
\                             --     \MC Mode Control \ 01 = up to LCD_TIM_CCR0
\                                 -  \TBCLR TimerB Clear
\                                  - \TBIE
\                                   -\TBIFG
\ -------------------------------\
\ LCD_TIM_CCTLx = %0000 0000 0110 0000\$3C{2,4,6,8,A,C,E}
\                  --                 \CM Capture Mode
\                    --               \CCIS
\                       -             \SCS
\                        --           \CLLD
\                          -          \CAP
\                            ---      \OUTMOD \ 011 = set/reset
\                               -     \CCIE
\                                 -   \CCI
\                                  -  \OUT
\                                   - \COV
\                                    -\CCIFG
\ -------------------------------\
\ LCD_TIM_CCRx                   \
\ -------------------------------\
\ LCD_TIM_EX0                    \ 
\ ------------------------------\
\ set LCD_TIM_ to make 50kHz PWM \ for LCD_Vo; works without interrupt
\ ------------------------------\
MOV #%10_1101_0100,&LCD_TIM_CTL \ SMCLK/8, up mode, clear timer, no int
\    MOV #0,&LCD_TIM_EX0        \ predivide by 1 in LCD_TIM_EX0 register (8 MHZ)
FREQ_KHZ @ 16000 = [IF]         \ if 16 MHz
    MOV #1,&LCD_TIM_EX0         \ predivide by 2 in LCD_TIM_EX0 register (16 MHZ)
[THEN]
FREQ_KHZ @ 24000 = [IF]         \ if 24 MHz
    MOV #2,&LCD_TIM_EX0         \ predivide by 3 in LCD_TIM_EX0 register (24 MHZ)
[THEN]
    MOV #19,&LCD_TIM_CCR0       \ 19+1=20*1us=20us
\ ------------------------------\
\ set LCD_TIM_.2 to generate PWM for LCD_Vo
\ ------------------------------\
MOV #%0110_0000,&LCD_TIM_CCTLn  \ output mode = set/reset \ clear CCIFG
    MOV #10,&LCD_TIM_CCRn       \ contrast adjust : 10/20 ==> LCD_Vo = -0V6|+3V6 (Vcc=3V6)
\    MOV #12,&LCD_TIM_CCRn        \ contrast adjust : 12/20 ==> LCD_Vo = -1V4|+3V3 (Vcc=3V3)
\ ------------------------------\
    BIS.B #LCDVo,&LCDVo_DIR     \
    BIS.B #LCDVo,&LCDVo_SEL     \ SEL.2
\ ------------------------------\
    BIS.B #LCD_CMD,&LCD_CMD_DIR \ lcd_cmd as outputs
    BIC.B #LCD_CMD,&LCD_CMD_REN \ lcd_cmd pullup/down disable
\ ------------------------------\
    BIS.B #LCD_DB,&LCD_DB_DIR   \ as output, wired to DB(4-7) LCD_Data
    BIC.B #LCD_DB,&LCD_DB_REN   \ LCD_Data pullup/down disable
\ ******************************\
\ init RC5_Int                  \
\ ******************************\
    BIS.B #RC5,&IR_IE           \ enable RC5_Int
    BIC.B #RC5,&IR_IFG          \ reset RC5_Int flag
\ ******************************\
\ init WatchDog WDT_TIM_        \ eUSCI_A0 (FORTH terminal) has higher priority than WDT_TIM_
\ ******************************\
\              %01 0001 0100    \ TAxCTL
\               --              \ TASSEL    CLK = ACLK = LFXT = 32768 Hz
\                  --           \ ID        divided by 1
\                    --         \ MC        MODE = up to TAxCCRn
\                        -      \ TACLR     clear timer count
\                         -     \ TAIE
\                          -    \ TAIFG
\ ------------------------------\
MOV #%01_0001_0100,&WDT_TIM_CTL \ start WDT_TIM_, ACLK, up mode, disable int, 
\ ------------------------------\
\                        000    \ TAxEX0
\                        ---    \ TAIDEX    pre divisor
\ ------------------------------\
\          %0000 0000 0000 0101 \ TAxCCR0
    MOV ##3276,&WDT_TIM_CCR0    \ else init WDT_TIM_ for LFXT: 32768/20=1638 ==> 100ms
\ ------------------------------\
\          %0000 0000 0001 0000 \ TAxCCTL0
\                   -           \ CAP capture/compare mode = compare
\                        -      \ CCIEn
\                             - \ CCIFGn
    MOV #%10000,&WDT_TIM_CCTL0  \ enable compare interrupt, clear CCIFG0
\ ------------------------------\
\ define LPM mode for ACCEPT    \
\ ------------------------------\
\    MOV #LPM4+GIE,&LPM_MODE    \ with MSP430FR59xx
\    MOV #LPM2+GIE,&LPM_MODE    \ with MSP430FR57xx, terminal input don't work for LPMx > 2
\                               \ with MSP430FR2xxx, terminal input don't work for LPMx > 0 ; LPM0 is the default value
\ ------------------------------\
COLON                           \
\ ------------------------------\
\ Init LCD 2x20                 \
\ ------------------------------\
    #1000 20_US                 \ 1- wait 20 ms
    %011 TOP_LCD                \ 2- send DB5=DB4=1
    #205 20_US                  \ 3- wait 4,1 ms
    %011 TOP_LCD                \ 4- send again DB5=DB4=1
    #5 20_US                    \ 5- wait 0,1 ms
    %011 TOP_LCD                \ 6- send again again DB5=DB4=1
    #2 20_US                    \    wait 40 us = LCD cycle
    %010 TOP_LCD                \ 7- send DB5=1 DB4=0
    #2 20_US                    \    wait 40 us = LCD cycle
    %00101000 LCD_WRF           \ 8- %001DNFxx "FonctionSet" D=8/4 DataBus width, Number of lines=2/1, Font bold/normal
    %1000 LCD_WRF               \ 9- %1DCB   "DisplayControl" : Display off, Cursor off, Blink off. 
    LCD_CLEAR                   \ 10- "LCD_Clear"
    %0110 LCD_WRF               \ 11- %01xx   "LCD_EntrySet" : address and cursor shift after writing in RAM
    %1100 LCD_WRF               \ 12- %1DCB "DisplayControl" : Display on, Cursor off, Blink off. 
    LCD_CLEAR                   \ 10- "LCD_Clear"
    ['] LCD_HOME IS CR          \ ' CR redirected to LCD_HOME
    ['] LCD_WRC  IS EMIT        \ ' EMIT redirected to LCD_WrC
    CR ." I love you"           \ display message on LCD
    ['] CR >BODY IS CR          \ CR executes its default value
    ['] EMIT >BODY IS EMIT      \ EMIT executes its defaulte value
    ." RC5toLCD is running. Type STOP to quit" \ display message on FastForth Terminal
    ABORT" "                    \
;                               \
\ ------------------------------\

\ ------------------------------\
CODE START                      \ this routine replaces WARM and COLD default values by these of this application.
\ ------------------------------\
CMP #RET_ADR,&{RC5TOLCD}+8      \ init R2L once, only if MARKER_DOES is not initialized
0= IF                           \ if not done, customizes MARKER_DOES
    MOV #STOP_R2L,&{RC5TOLCD}+8 \ execution of {RC5TOLCD} will perform STOP_R2L.
    MOV &WARM+2,&{RC5TOLCD}+10  \ save previous INI_APP subroutine
    MOV #INI_R2L,&WARM+2        \ replace it by RC5toLCD INI_APP
    MOV &WDT_TIM_0_VEC,&{RC5TOLCD}+12   \ save Vector previous value
    MOV #WDT_INT,&WDT_TIM_0_VEC \ for only CCIFG0 int, this interrupt clears automatically CCIFG0
    MOV &IR_VEC,&{RC5TOLCD}+14  \ save Vector previous value
    MOV #RC5_INT,&IR_VEC        \ init interrupt vector
    MOV #INI_R2L,PC             \ then execute new INI_APP, without return
THEN
MOV @IP+,PC 
ENDCODE 
\ ------------------------------\

ECHO
            ; downloading RC5toLCD.4th is done
RST_HERE    ; this app is protected against <reset>

START
