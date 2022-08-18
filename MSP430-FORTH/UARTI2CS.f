\ -*- coding: utf-8 -*-
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133 (can't use LED1 because wired on UART TX)
\ MSP_EXP430FR2433  CHIPSTICK_FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476   MY_MSP430FR5738_2
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ OR
\
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\
\ FastForth kernel compilation minimal options:
\ TERMINAL3WIRES | TERMINAL4WIRES
\
\ see symbolic values in \inc\launchpad.pat or/and in \inc\device.pat
\
\ ================================================================================
\ coupled to a PL2303HXD/GC/TA cable, this driver enables a FastForth target to act as USB to I2C_Slave bridge,
\ thus, from TERATERM.exe you can take the entire control of up to 112 I2C_FastForth targets.
\ In addition, it simulates a full duplex communication while the I2C bus is only half duplex.
\ ================================================================================

\ ------------------------------------------------- 
; UARTI2CS.f  \I2C to UART bridge for I2C_FastForth\ -------------------------->+
\ --------------------------------------------------                            |
\ ------------------------------                                                |
\ see forthMSP430FR_TERM_I2C.asm                                                |
\ ------------------------------                                                |
\        |                                                                      |
\        |                                                                      |
\        |             GND------------------------------GND                     |
\        |             3V3-------------o---o------------3V3                     |
\        |                             |   |                                    | 
\        |                             1   1                                    | 
\        |                             k   k                Txy.z output        | 
\        v                             0   0                     to             v                 GND-------------------------------------GND 
\   I2C_FastForth                      |   |                  Px.y int       UARTI2CS              +-------------------------------------->+
\     (hardware         +<-------------|---o------------>+     jumper       (Software              |    +<----------------------------+    |
\     I2C Slave)        ^      +<------o----------+      ^     +--->+       I2C Master)            |    |    +------(option)---->+    |    |
\                       v      v                  ^      v     ^    |                              ^    v    ^                   v    ^    v
\ I2C_FastForth(s)     SDA    SCL  connected to: SCL    SDA    |    v   I2C_to_UART_bridge        TXD  RXD  RTS  connected to : CTS  TXD  RXD  UARTtoUSB <--> COMx <--> TERMINAL
\ ------------------   ----   ----               ----   ----             ----------------         ---  ---  ---                 ---  ---  ---  ---------      ----      --------
\ MSP_EXP430FR2355     P1.2   P1.3               P3.3   P3.2  P1.7 P1.6  MSP_EXP430FR2355 (24MHz) P4.3 P4.2 P2.0                               PL2303GC                    |      
\ MSP_EXP430FR5739     P1.6   P1.7               P4.1   P4.0  P1.1 P1.0  MSP_EXP430FR5739 (24MHz) P2.0 P2.1 P2.2                               PL2303HXD                   v
\ MSP_EXP430FR5969     P1.6   P1.7               P1.3   P1.2  P2.2 P3.4  MSP_EXP430FR5969 (16MHz) P2.0 P2.1 P4.1                               PL2303TA               TERATERM.EXE     
\ MSP_EXP430FR5994     P7.0   P7.1               P8.1   P8.2  P1.5 P1.4  MSP_EXP430FR5994 (16MHz) P2.0 P2.1 P4.2                               CP2102                      ^ 
\ MSP_EXP430FR6989     P1.6   P1.7               P1.5   P1.3  P3.6 P3.7  MSP_EXP430FR6989 (16MHz) P3.4 P3.5 P3.0                                                           |       
\ MSP_EXP430FR4133     P5.2   P5.3               P8.3   P8.2  P1.6 P1.7  MSP_EXP430FR4133 (16MHz) P1.0 P1.1 P2.3                                                           |       
\ MSP_EXP430FR2433     P1.2   P1.3               P3.1   P3.2  P1.2 P1.3  MSP_EXP430FR2433 (16MHz) P1.4 P1.5 P1.0                                                           |           
\ LP_MSP430FR2476      P4.4   P4.3               P3.3   P3.2  P1.2 P1.1  LP_MSP430FR2476  (16MHz) P1.4 P1.5 P6.1                                                           |                                                                     
\ MY_MSP430FR5738_2    P1.6   P1.7               P1.3   P1.2  P1.1 P1.0 MY_MSP430FR5738_2 (24MHz) P2.0 P2.1 P2.2                               PL2303HXD                   |
\                                                                               ^                                                                                          |
\                                                                               |                                                                                          |
\                                                                              RST                                                                                       ALT+B
\                                                                               ^                                                                                          ^
\                                                                               |                                                                                          |
\                                                                         QUIT UARTI2CS                                                                             QUIT UARTI2CS
\
\ =============================================================================================
\ don't forget to link 3V3 and GND on each side and to add 1k0 pullup resistors on SDA and SCL.
\ =============================================================================================
\ don't forget to set the jumper Txy.z <--> Px.y
\ =============================================================================================
\ don't forget to remove the jumpers SBWTCK & SBWTDIO from the unpowered launchpad if any
\ =============================================================================================
\
\ empiric value of I2C pullup resistors: R (k) = 8 Vcc / MCLK (MHz). ex. VCC = 3.3, MCLK = 24 MHz ==> R = 1k1
\
\ if you want to see what is happening on the I2C bus with an oscilloscope, pay attention to the capacitance of the probes, 
\ switch them from x1 to x10. 
\
\ ------------
\ how it works
\ ------------
\
\ 1- the I2C bus is Master to Slave oriented, the Slave does not decide anything.
\    The I2C Master device is placed on the TERMINAL side and the FastForth target on the I2C Slave side.
\    Once the Master to Slave link is made, we have to find a trick to reverse the roles, 
\    so that the Slave can take control of the data exchange.
\
\ 2- The I2C bus is a half duplex exchange. 
\    Another trick will be to simulate an I2C_Master TERMINAL in Full Duplex mode.
\
\ 3- ..without forgetting a visual effect to show the lack of I2C connection.
\
\ Solution: The slave "slavishly" sends control characters to the master, 
\ and since this one obeys a bigger than itself, the programmer,
\ he makes it his "masterly" duty to obey the slave.
\
\ To take control of the master, the slave emits one of 5 CTRL-Chars:
\   CTRL-Char $00 sent by ACCEPT (before falling asleep with BACKGRND),
\   CTRL-Char $01 sent by KEY: request to send a single character from TERMINAL,
\   CTRL-Char $04 sent by NOECHO to switch the UART to half-duplex mode,
\   CTRL-Char $05 sent by ECHO to switch the UART to full duplex mode,
\   CTRL-Char $FF sent by ABORT": request to abort the file being downloaded if any,
\                                 followed by a START RX to display the ABORT" message.
\   More, if the master receives a $FF as data (it's the case for any SYS event on I2C_Slave side), 
\   it considers the link broken and performs ABORT, which forces a START RX into a 500 ms loop with an appropriate visual effect.
\   All this guarantees a perfect hot swap of any I2C_slave.
\
\ Once the slave sends the CTRL_Char $00, he falls asleep, 
\ On its receipt, the master sends an UART RXON then falls down to sleep awaiting a UART RX interruption from TERMINAL.
\ As long as the TERMINAL is silent, the master and the slave remain in their SLEEP mode,
\ (a part a Tx0_INT interrupt (2*12us @24MHz --> Ires < 0,1uA ) every 1/2s on Master side).
\ SLEEP mode is LPM0 for the master (else UART does not work), LPM4 for the slave.
\
\ interruptions
\ -------------
\ Since the slave can't wake up the master with a dedicated pin interrupt, the master must generate one
\ cyclically to listen to the slave.
\ 500MS_INT is used to generate a 1/2 second interrupt, obviously taken into account only when the master goes to sleep.
\ It performs a (re)START I2C RX that enables the I2C link to be re-established following a RESET performed on I2C_Slave side.
\
\ This interruption also allows to exit the UARTI2CS program when user sends a software BREAK (Teraterm(Alt-B)).
\
\ To avoid locking, we have to ensure U2I_TERM_INT priority greater than 500MS_INT. As MSP430FR2xxx don't have timer with lower priority than eUSCI,
\ we link the timer output pin with a contiguous pin with lower interrupt than TERM_INT to do this.
\
\
\ driver test : MCLK=24MHz, PL2303CG with shortened cable (20cm), WIFI off, all windows apps closed else Scite and TERATERM.
\ -----------                                                                                    .
\                                                                                               .         ┌────────────────────────────────┐
\     notebook                                  USB to I2C bridge                              +-- I2C -->| up to 112 I2C_FASTFORTH targets|
\ ┌───────────────┐          ╔════════════════════════════════════════════════════════════╗   /         ┌───────────────────────────────┐  |
\ |   WINDOWS 10  |          ║ PL2303GC/HXD/TA               launchpad running UARTI2CS   ║  +-- I2C -->|    MSP430FR4133 @ 1 MHz       |  |
\ |               |          ║───────────────┐           ┌────────────────────────────────║ /        ┌───────────────────────────────┐  |──┘
\ |               |          ║               |  3 wires  |    MSP430FR2355 @ 24MHz        ║/         |    MSP430FR5738 @ 24 MHz      |  |
\ |   TERATERM   -o--> USB --o--> USB2UART --o--> UART --o--> FASTFORTH  +  UARTI2CS    --o--> I2C --o-->     I2C_FASTFORTH          |──┘
\ |   terminal    |          ║               |   6 MBds  |     (software I2C MASTER)      ║          |     (hardware I2C SLAVE)      | 
\ |               |          ║───────────────┘           └────────────────────────────────║          └───────────────────────────────┘
\ |               |          ║               |<- l=20cm->|                                ║<-l=20cm->| 
\ └───────────────┘          ╚════════════════════════════════════════════════════════════╝              
\                                                                       |_|
\ test results :                                                        RST
\ ------------
\
\ Full duplex downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Master target = 625ms/732kBds.
\ Full duplex downloading (+ interpret + compile + execute) CORETEST.4TH to I2C Slave target = 1047ms/431kBds.
\ the difference (422 ms) is the effective time of the I2C Half duplex exchange.
\ [(9 bits / char) + ( 2*START + 2*addr + 1 CTRL_Char + 1 STOP / line )] = [(45763 chars * 9 bits) + (1538 lines * 30 bits)] / 0,422 = 1,085 MHz
\ ==> I2C effective rate = 109 % of I2C Fast-mode Plus (Fm+).
\ 
\ also connected to and tested with another I2C_FastForth target with MCLK = 1MHz (I2C CLK > MCLK !).
\
\ The I2C_Slave address is defined as 'MYSLAVEADR' in forthMSP430FR.asm source file for the I2C_Slave target.
\ You can use any pin for SDA and SCL, preferably in the interval Px0...Px3.  
\ don't forget to add 3.3k (maxi) pullup resitors on wires SDA and SCL.
\
\ the LEDs TX and RX work fine, comment/uncomment as you want.
\
\ Multi Master Mode works but is not tested in the real word.
\
\
\ ================================================================================
\ REGISTERS USAGE for embedded MSP430 ASSEMBLER  
\ ================================================================================
\ don't use R2, R3,
\ R4, R5, R6, R7 must be PUSHed/POPed before/after use
\ scratch registers S,T,W,X and Y are free,
\ in interrupt routines, IP is free,
\ Apply FORTH rules for TOS, PSP, RSP registers.
\
\ PUSHM order : PSP,TOS, IP, S , T , W , X , Y ,rDOVAR,rDOCON,rDODOES,rDOCOL, R3, SR,RSP, PC
\ PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5   ,  R4  , R3, R2, R1, R0
\
\ example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack, with IP first pushed
\
\ POPM  order :  PC,RSP, SR, R3, rDODOES,rDOCON,rDOVAR,rEXIT,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ POPM  order :  R0, R1, R2, R3,   R4   ,  R5  ,  R6  ,  R7 , R8, R9,R10,R11,R12,R13,R14,R15
\
\ example : POPM #6,IP   pop Y,X,W,T,S,IP registers from return stack, with IP last poped
\
\ ASSEMBLER conditionnal usage before IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before          ?GOTO : S< S>= U< U>= 0= 0<> 0< 

\ first, we do some tests allowing the download
    CODE ABORT_UARTI2CS     \
    SUB #4,PSP
    MOV TOS,2(PSP)
    MOV &KERNEL_ADDON,TOS
    BIT #$3C00,TOS          \ BIT13|BIT12|BIT11|BIT10 test (UART TERMINAL test)
    0<> IF MOV #0,TOS THEN  \ if TOS <> 0 (UART TERMINAL), set TOS = 0
    MOV TOS,0(PSP)
    MOV &VERSION,TOS
    SUB #400,TOS            \ FastForth V4.0
    COLON                   \ ASSEMBLER switch to FORTH with IP backup
    $0D EMIT                \ return to column 1 without CR
    ABORT" FastForth V4.0 please!"
    ABORT" <-- Ouch! unexpected I2C_FastForth target!"
    RST_RET                 \ remove the ABORT_UARTI2CS definition before continuing the download.
    ;

    ABORT_UARTI2CS          \ run tests

\ here is a MARKER definition, used to free the program memory including it, and restoring previous hardware context if any.

    MARKER {UARTI2CS}   \ the command : ' <MARKER_definition>, leaves USER_PARAM address on the stack.
\                         &{UARTI2CS}-2   = USER_DOES     <-- #REMOVE_U2I addr, the subroutine used to restore the low level environment below:
    16 ALLOT            \ &{UARTI2CS}     = USER_PARAM    <-- previous &STOP_APP addr
                        \ &{UARTI2CS}+2   = USER_PARAM+2  <-- previous &HARD_APP addr
\                         &{UARTI2CS}+4   = USER_PARAM+4  <-- previous &BACKGRND_APP addr
\                         &{UARTI2CS}+6   = USER_PARAM+6  <-- previous &TERM_VEC addr
\                         &{UARTI2CS}+8   = USER_PARAM+8  <-- previous &Px_VEC addr
\ local variables :       UARTI2CS_ADR=\{UARTI2CS\}\+10;  <-- I2C_Slave_Addr<<1
\                         TIMER_CONF=\{UARTI2CS\}\+12     <-- TIM_CTL configuration
\                         COLLISION_DLY=\{UARTI2CS\}\+14; <-- 20 us resolution delay after I2C collision
\                         DUPLEX_MODE=\{UARTI2CS\}\+15;   <-- flag = 4 --> NOECHO, <> 4 --> ECHO, -1 = I2C link lost
\ USER_PARAMS[-2...+16[ are initialised by START_U2I and USER_PARAMS[-2...+10[ are restored by REMOVE_U2I.

\ =========================================================================
    CODE LEDS MOV @IP+,PC ENDCODE \ comment this line to remove LEDS option
\ =========================================================================

\ -----------------------------------------------------------------------
\ first we download the set of definitions we need (copied from CORE_ANS)
\ -----------------------------------------------------------------------
\
    [UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    CODE =
    SUB @PSP+,TOS   \ 2
    SUB #1,TOS      \ 1 borrow if TOS was 0
    SUBC TOS,TOS    \ 1 TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] + [IF]  \ for [ABORT, (GEMA pattern)
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    CODE +
    ADD @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ -----------------------------
\ end of definitions we need...
\ -----------------------------
\
    [UNDEFINED] TSTBIT [IF]
    CODE TSTBIT         \ addr bit_mask -- true/flase flag
    MOV @PSP+,X
    AND @X,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

\ see symbolic values in ..\inc\launchpad.pat or/and in ..\inc\device.pat
\ note: HDNCODE definitions are HiDdeN and cannot be called from TERMINAL
\   ------------------------------------\
    HDNCODE I2CM_STOP                   \ sends a STOP on I2C_BUS
\   ------------------------------------\     _
    BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   force SCL as output (low)
    NOP3                                \ 3 l _
    BIS.B #SM_SDA,&I2CSM_DIR            \ 3 l  v_   SDA as output ==> SDA low
    NOP3                                \ 3 l   _
    BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
    NOP3                                \ 3 h   _
    BIC.B #SM_SDA,&I2CSM_DIR            \ 3 h _^    relase SDA (high) when SCL is high = STOP
    MOV @RSP+,PC                        \ 4
    ENDCODE                             \
\   ------------------------------------\

\   ------------------------------------\
    HDNCODE REMOVE_U2I                  \   REMOVE_APP subroutine 
\   ------------------------------------\
BW1                                     \ <-- WARM <-- INIT_FORTH <-- SYS_failures|RESET 
\   ------------------------------------\
    [DEFINED] LEDS [IF]
    BIC.B #LED1,&LED1_OUT               \ set TX red led OFF
    BIC.B #LED1,&LED1_DIR               \ set TX red led pin as input
    BIC.B #LED2,&LED2_OUT               \ set RX green led OFF
    BIC.B #LED2,&LED2_DIR               \ set RX green led pin as input
    [THEN]
    CALL #I2CM_STOP                     \ stop properly I2C_BUS
    BIS.B #SM_BUS,&I2CSM_OUT            \ restore I2C_BUS I/O
    BIS.B #SM_BUS,&I2CSM_REN            \ with pull up resistors
\   ------------------------------------\
    MOV #0,&TIM_CTL                     \ stop timer
    BIC.B #T_OUT2,&T_OUT2_SEL           \ clear T_OUT2 SEL
    BIC.B #T_OUT2,&T_OUT2_DIR           \ set T_OUT2 as input
    BIC.B #INT_IN,&INT_IN_IE            \ clear INT_IN IE
\   ------------------------------------\
    CMP #RET_ADR,&{UARTI2CS}-2          \
    0<> IF                              \ restore USER_PARAMS[-2...+10[
        MOV #{UARTI2CS},W               \ W = addr of first user parameter following MARKER
        MOV #RET_ADR,-2(W)              \ don't forget: restore default USER_DOES call address !
        MOV @W+,&STOP_APP               \ restore previous (default) STOP_APP value
        MOV @W+,&HARD_APP               \ restore previous (default) HARD_APP value
        MOV @W+,&BACKGRND_APP           \ restore previous (default) BACKGRND_APP value
        MOV @W+,&TERM_VEC               \ restore previous (default) TERM_VEC value
        MOV @W+,&INT_IN_VEC             \ restore previous (default) INT_IN_VEC value
    THEN                                \
\   ------------------------------------\
    MOV @RSP+,PC                        \ --> WARM --> previous_HARD_APP --> display I2C_address + WARM message --> FORTH interpreter
    ENDCODE                             \
\   ------------------------------------\

\   ------------------------------------\
    HDNCODE STOP_U2I                    \ new STOP_APP subroutine, defined for the example, not used.
\   ------------------------------------\
    CALL #I2CM_STOP                     \ send I2C STOP
    MOV &{UARTI2CS},PC                  \ run previous STOP_APP then RET
    ENDCODE                             \
\   ------------------------------------\

\   ------------------------------------\
    HDNCODE BACKGRND_U2I                \       new BACKGRND_APP subroutine, RET to LPM0 shut down.
\   ------------------------------------\
\   user request test                   \
\   ------------------------------------\
    BIT #8,&TERM_STATW                  \ 3     break sent by TERATERM (Alt+B) ?
    0<> IF
        MOV #WARM_IP_ADR,0(RSP)         \       replace BACKGRND_U2I return by INIT_FORTH followed by WARM 
        PUSH #INIT_FORTH                \
\   ------------------------------------\
BW2     MOV #1,TOS                      \       to identify manual request to REMOVE_U2I
        GOTO BW1                        \ 2
    THEN
\   ------------------------------------\
    BIC.B #INT_IN,&INT_IN_IFG           \ 4     clear INT_IN IFG
    MOV #'CR',S                         \ 2     S = 'CR' = penultimate char of line to be RXed by UART
    MOV #0,T                            \ 2     T = init buffer pointer for UART_TERMINAL input
    MOV.B &DUPLEX_MODE,Y                \ 3     Y = 4 ==> NOECHO else ECHO, for U2I_TERM_INT and 500MS_INT use
    MOV &{UARTI2CS}+4,PC                \ 3     previous BACKGRND_APP executes RXON, enabling TERMINAL TX, then RET to LPM0 shut down.
    ENDCODE                             \
\   ------------------------------------\

\   ------------------------------------\
    HDNCODE HARD_U2I                    \ new HARD_APP subroutine, RETurn redirected to ABORT --> ACCEPT --> BACKGRND
\   ------------------------------------\
\   init 500MS_INT                      \ used to scan I2C_Slave hard RESET and to slow down (re)START RX loop
\   ------------------------------------\
BW3 MOV &TIMER_CONF,&TIM_CTL            \ start RX_timer, up mode
    MOV #4096,&TIM_CCR0                 \ time  0.5s
\   ------------------------------------\
\   set TB0.2 to generate 500ms int     \
\   ------------------------------------\
    MOV #$60,&TIM_CCTL2                 \ output mode = set/reset           )
    MOV #4096,&TIM_CCR2                 \ one cycle pulse to set P1.6IFG    )
    BIS.B #T_OUT2,&T_OUT2_DIR           \ P1.7 as output                    >  (MSP-EXP430FR2355 values, to custom for your launchpad)
    BIS.B #T_OUT2,&T_OUT2_SEL           \ P1.7 as TB0.2 output              )
    BIS.B #INT_IN,&INT_IN_IE            \ P1.6IE                            )
\   ------------------------------------\
\   init I2C_MASTER I/O                 \
\   ------------------------------------\
    BIC.B #SM_BUS,&I2CSM_REN            \ remove internal pull up resistors because the next instruction which change them to pull down resistors
    BIC.B #SM_BUS,&I2CSM_OUT            \ preset SDA + SCL output LOW
    BIC.B #SM_BUS,&I2CSM_IES            \ set IES for SDA_IFG and SCL_IFG on low_to_high transition, for detection collision.
    [DEFINED] LEDS [IF]
    BIS.B #LED1,&LED1_DIR               \ set red led (I2C TX) pin as output
    BIS.B #LED2,&LED2_DIR               \ set green led (I2C RX) pin as output
    [THEN]
\   ------------------------------------\
\   run previous HARD_APP               \
\   ------------------------------------\
    CALL &{UARTI2CS}+2                  \       execute previous HARD_APP to init TERM_UC, activates I/O.
\   ------------------------------------\       TOS = USERSYS=$00|SYSRSTIV=$02|$04|$0E|$xx as UARTI2CS|POWER_ON|RST|SVSH_threshold|SYS_failures 
\   define new SYSRSTIV select          \
\   ------------------------------------\
    CMP #6,TOS                          \       SYSRSTIV = RESET ?
    0= ?GOTO BW2                        \       if yes goto REMOVE_U2I with TOS = 1, return to WARM
    CMP #$0E,TOS                        \       SVSHIFG SVSH event = #14 ? (POWER_ON)
    0<> IF                              \       if not
        CMP #$0A,TOS                    \           SYSRSTIV >= violation memory protected areas ?
        U>= ?GOTO BW1                   \       if yes goto REMOVE_U2I, return to WARM
    THEN                                \
\   ------------------------------------\
    MOV #ABORT,0(RSP)                   \       replace WARM return by ABORT return
    MOV @RSP+,PC                        \       --> ABORT --> ACCCEPT --> BACKGRND --> LPM4
    ENDCODE                             \
\   ------------------------------------\

\   ----------------------------------------\
    HDNCODE I2CM_START                      \           I2C_Master START and TX Address, version with collision detection and resolution
\   ----------------------------------------\     _
    BIS.B   #SM_SDA,&I2CSM_DIR              \ 3    v_   force SDA as output (low)
    BIS     &UARTI2CS_ADR,X                 \ 3   _     X = (Slave_Address<<1 | R/w bit)
    BIS.B   #SM_SCL,&I2CSM_DIR              \ 3    v_   force SCL as output (low)
\   ----------------------------------------\
\   I2C_Master Send I2C Addr                \
\   ----------------------------------------\
    MOV.B #8,W                              \ 1 l       count for 7 bits address + R/w bit
    BEGIN                                   \
        ADD.B X,X                           \ 1 l       shift one left
        U< IF                               \ 2 l       carry set ?
            BIS.B #SM_SDA,&I2CSM_DIR        \ 3 l   _   no  SDA as output ==> SDA low
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^        release SCL (high)
            NOP3                            \ 3 h           for symmetry.
        ELSE                                \ 2 l       yes we can detect collision only when SDA is driven high 
            BIC.B #SM_SDA,&I2CSM_DIR        \ 3 l   _       SDA as input  ==> SDA high because pull up resistor
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^        release SCL (high)
            BIT.B #SM_SDA,&I2CSM_IN         \ 3 h           get SDA input
            0= IF                           \ 2 h
\               ----------------------------\
\               collision detected          \               if SDA input low, collision detected
\               ----------------------------\
                BEGIN                       \
                    BIT #TX,&TERM_IFG       \ 3
                0<> UNTIL                   \ 2
                MOV.B #'c',&TERM_TXBUF      \ 3             send 'c' to TERMINAL to show collision
\               ----------------------------\
\               collision resolution        \
\               ----------------------------\
                BEGIN                       \               wait until SDA high
                    BIT.B #SM_SDA,&I2CSM_IN \ 3 h
                0<> UNTIL                   \ 2
\               ----------------------------\
                BEGIN                       \               wait for 20us bus idle time
                  BIC.B #SM_BUS,&I2CSM_IFG  \ 4                 clear SM_BUS IFG
                  NOP3                      \ 3
                  MOV.B &COLLISION_DLY,W    \ 3                 load delay value 
                  BEGIN                     \
                    NOP                     \ 1
                    SUB #1,W                \ 1
                  0= UNTIL                  \ 2               4~ x (delay value)
                  BIT.B #SM_BUS,&I2CSM_IFG  \ 4
                0= UNTIL                    \ 2             + 16~ dead time for the remainder of idle time
\               ----------------------------\
                ADD #2,RSP                  \ 1             remove the RET for Nack/Ack processing and select..
                MOV @RSP,PC                 \ 4 h           ...RET to ReStart after a collision detection with preserving this RET address on RSP
\               ----------------------------\
            THEN                            \
        THEN                                \     _   
        BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low
        SUB #1,W                            \ 1 l       bits count-1
    0= UNTIL                                \ 2 l       20 * 8 cycles
\   ----------------------------------------\
\   I2C_Master get Slave Ack/Nack on address\
\   ----------------------------------------\       _
    BIC.B #SM_SDA,&I2CSM_DIR                \ 3 l _^_   after TX address we must release SDA to read Ack/Nack from Slave
    BIC.B #SM_SCL,&I2CSM_DIR                \ 3 l _^    release SCL (high)
    BEGIN                                   \           we must wait I2C_Slave software
        BIT.B #SM_SCL,&I2CSM_IN             \ 3 h       by testing SCL released
    0<> UNTIL                               \ 2 h       because Slave can strech SCL low (may be occupied)
    BIT.B #SM_SDA,&I2CSM_IN                 \ 3 h _     get SDA state: flag Z = 0 if Nack
    BIS.B #SM_SCL,&I2CSM_DIR                \ 3 h  v_   SCL as output : force SCL low
\   ----------------------------------------\
    MOV @RSP+,0(RSP)                        \ 4         remove RET to (ReStart after a collision detection)
    MOV @RSP+,PC                            \ 4         RET to RX|RX datas
    ENDCODE                                 \           195 cycles
\   ----------------------------------------\

\   ****************************************\
    HDNCODE U2I_TERM_INT                    \ UART RX interrupt starts on first char of each line sent by TERMINAL
\   ****************************************\ 
    ADD #4,RSP                              \ 1 remove unused SR_RET, and remove PC_RET because we want include BACKGRND_U2I as end of U2I_TERM_INT routine
\   ----------------------------------------\
\   get one line from UART TERMINAL to PAD  \ S = 'CR', T = 0, W = char, Y = ECHO/NOECHO flag (see U2I_BACKGRND)
\   ----------------------------------------\
    BEGIN                                   \ input buffer begins at PAD-2, able to receive CIB_LEN = 84 chars, plus CR+LF !!!
        MOV.B &TERM_RXBUF,W                 \ 3
        ADD #1,T                            \ 1
        CMP.B S,W                           \ 1 char = CR ? (if yes goto next REPEAT)
    0<> WHILE                               \ 2 while <> CR
        CMP #CIB_LEN+1,T                    \ 2
        U< IF                               \ 2 discard chars out of PAD-2 + CIB_LEN bound
            MOV.B W,PAD_ORG-3(T)            \ 3 write char to input buffer, PAD-2 first
        THEN
        CMP.B #4,Y                          \ 1 echo OFF ?
        0<> IF                              \ 2 if echo is ON
            BEGIN                           \   )
                BIT #TX,&TERM_IFG           \ 3 > Test TX_Buf empty, mandatory for low baudrates
            0<> UNTIL                       \ 2 )
            MOV.B W,&TERM_TXBUF             \ 3 return all characters to UART_TERMINAL except CR+LF which will be sent later by I2C_SLAVE
        THEN                                \
        BEGIN                               \ 
            BIT #RX,&TERM_IFG               \ 3 wait for next char received
        0<> UNTIL                           \ 2 
    REPEAT                                  \ 2 32 cycles loop ==> up to UART 2.5 Mbds @ 8MHz
    CALL #UART_RXOFF                        \ stops UART RX still char CR is received, the LF char is being transmitted.
    MOV.B W,PAD_ORG-3(T)                    \ move CR in buffer
    BEGIN                                   \
        BIT #RX,&TERM_IFG                   \ 3 char LF received ?
    0<> UNTIL                               \ 2
\   ----------------------------------------\
BW2 \ here, BW2 is redefined                \   <=== KEY input from TERMINAL, via I2C_MASTER
\   ----------------------------------------\
    MOV.B &TERM_RXBUF,S                     \           S = last char RXed by UART (LF|KEY_input), used by I2C_MASTER_TX as last byte to be TXed.         
    MOV.B S,PAD_ORG-2(T)                    \ 3
\   ========================================\ here I2C_Slave is sleeping in its ACCEPT routine
\   I2C_MASTER TX                           \ now we transmit UART RX buffer (PAD) to I2C_Slave, S = LF|KEY = last char to transmit
\   ========================================\          
    PUSH PC                                 \           PUSH next address as RET for reSTART after collision detection
\   ----------------------------------------\
\   I2C Master TX Start                     \ S = last char UART RXed
\   ----------------------------------------\
    MOV #0,X                                \ 1         to Start I2C TX
    CALL #I2CM_START                        \ 4         flag Z = 0 if Nack_On_Address
    0<> ?GOTO FW2                           \           if Nack on address ───────────────┐
\   ========================================\                                             |
\   I2C MASTER TX datas                     \                                             |
\   ========================================\                                             |
    [DEFINED] LEDS [IF]                     \                                             |
    BIS.B #LED1,&LED1_OUT                   \           red led ON = I2C TX               |
    [THEN]                                  \                                             |
\   ----------------------------------------\                                             |
    MOV #PAD_ORG-2,T                        \ 2         Y = buffer pointer, PAD-2 first   |
    BEGIN                                   \                                             |
        MOV.B @T,X                          \ 2 l       get first char to be TX           |
\       ------------------------------------\                                             v
\       I2C_Master TX 7 bits of Data        \
\       ------------------------------------\
        MOV.B #7,W                          \ 2 l       count for 7 data bits
        BEGIN                               \
            ADD.B X,X                       \ 1 l       shift one left
            U>= IF                          \ 2 l       carry set ?
                BIC.B #SM_SDA,&I2CSM_DIR    \ 3 l       yes : SDA as input  ==> SDA high because pull up resistor
            ELSE                            \ 2 l
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l       no: SDA as output ==> SDA low
            NOP2                            \ 2 l           for symmetry  
            THEN                            \   l   _
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
\           --------------------------------\
            NOP3                            \ 3 h
\           --------------------------------\     _
            BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
            SUB #1,W                        \ 1 l       bits count-1
        0= UNTIL                            \ 2 l
\       ------------------------------------\
\       I2C_Master TX 8th bit of Data       \
\       ------------------------------------\
        ADD.B X,X                           \ 1 l       shift one left
        U>= IF                              \ 2 l       carry set ?
            BIC.B #SM_SDA,&I2CSM_DIR        \ 3 l       yes : SDA as input  ==> SDA high because pull up resistor
        ELSE                                \ 2 l
            BIS.B #SM_SDA,&I2CSM_DIR        \ 3 l       no: SDA as output ==> SDA low 
            NOP2                            \ 2 l           for symmetry  
        THEN                                \   l   _
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
\       ------------------------------------\
        BEGIN                               \           here, (last bit of TX data), I2C_Slave streches SCL low until its RX_BUF is read,
            BIT.B #SM_SCL,&I2CSM_IN         \ 3 h       that is not documented in any MSP430FRxxx family user's guide...
        0<> UNTIL                           \ 2 h
\       ------------------------------------\     _
        BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low
\       ------------------------------------\
\       I2C_Master_TX get Slave Ack/Nack    \
\       ------------------------------------\
        BIC.B #SM_SDA,&I2CSM_DIR            \ 3 l   _   after TX byte we must release SDA to read Ack/Nack from Slave
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL (high)
        NOP3                                \           here, I2C_Slave doesn't strech SCL low, as suggested in TI's documentation...
        BIT.B #SM_SDA,&I2CSM_IN             \ 3 h _     get SDA state
        BIS.B #SM_SCL,&I2CSM_DIR            \ 3 h  v_   SCL as output : force SCL low, to keep I2C_BUS until next START (RX|TX)
\   ----------------------------------------\
    0= WHILE \ 1- Slave Ack received        \ 2 l       out of loop if Nack on data (goto next THEN)
\   ----------------------------------------\
\   I2C_Master TX Data Loop                 \
\   ----------------------------------------\
        CMP.B @T+,S                         \ 2 l       last char I2C TXed = last char UART RXed (LF|KEY) ?
\   ----------------------------------------\
    0= UNTIL  \ TXed char = last char       \ 2 l       loop back if <> 0
\   ----------------------------------------\
    THEN                                    \           <-- WHILE1 case of I2C_Slave Nack on Master_TX data
\   ========================================\
\   END OF I2C MASTER TX datas              \
\   ========================================\
    [DEFINED] LEDS [IF]
    BIC.B #LED1,&LED1_OUT                   \   red led OFF = endof I2C TX
    [THEN]
\   ----------------------------------------\
    GOTO FW1                                \   SCL is kept low   ──────┐
    ENDCODE                                 \                           |
\   ****************************************\                           v

\ wakes up every 1/2s by P1.6 int to listen I2C Slave or 
\ break from TERMINAL/USB_to_I2C_bridge.
\   ****************************************\                           |                 |
    HDNCODE 500MS_INT                       \                           |                 |
\   ****************************************\                           |                 |
    ADD #4,RSP                              \ 1 remove PC_RET, SR_RET   |                 |
\   ----------------------------------------\                           |                 |    
FW1 \ single use forward label              \ <──────── does START <────┘                 |
FW2 \ single use forward label              \ <──────── if Nack on Address Master TX <────┘
\   ========================================\
\   I2C_MASTER RX                           \
\   ========================================\
    PUSH PC                                 \ 3 l       PUSH next address as RET for reSTART after collision detection
\   ----------------------------------------\   
    BEGIN                                   \           Start MASTER RX
\       ------------------------------------\
\       I2C MASTER (re)START RX             \
\       ------------------------------------\       _
        BIC.B #SM_SCL,&I2CSM_DIR            \ 3 l _^    release SCL to enable START RX
        MOV #1,X                            \ 1 h       to Start MASTER RX
        CALL #I2CM_START                    \ 199~      flag Z = 0 if Nack_On_Address
\       ------------------------------------\
        0<> IF                              \ 2 l           if Nack on address
            CALL #I2CM_STOP                 \ 28~           generate STOP
            MOV.B #'.',&TERM_TXBUF          \ 4             to view the lack of I2C_target at the I2C_Addr provided.
            MOV.B #-1,&DUPLEX_MODE          \ 3             set 'no_I2C_Slave' flag
            MOV #BACKGRND,PC                \ 29~           which calls BACKGRND_U2I then RXON before LPM0 shut down.
        THEN                                \               (275 cycles for 500MS_INT)
        CMP.B #-1,Y                         \ 1 l           return of I2C_Slave on bus ?
        0= IF                               \ 2 l           if yes
            MOV.B #0,Y                      \                   clear 'no_I2C_Slave' flag, ECHO is ON
            MOV.B #'CR',&TERM_TXBUF         \                   send CR+LF to terminal
            BEGIN                           \
                BIT #TX,&TERM_IFG           \
            0<> UNTIL                       \
            MOV.B #'LF',&TERM_TXBUF         \
        THEN                                \
\       ====================================\
\       I2C Master RX data                  \
\       ====================================\
        [DEFINED] LEDS [IF]
        BIS.B #LED2,&LED2_OUT               \ 3 l       green led ON = I2C RX
        [THEN]
\       ------------------------------------\
        BEGIN                               \   l
            BEGIN                           \   l
                BIC.B #SM_SDA,&I2CSM_DIR    \ 4 l       after Ack and before RX next byte, we must release SDA
                MOV.B #8,W                  \ 2 l       count for 8 data bits
                BEGIN                       \       _      
                  BIC.B #SM_SCL,&I2CSM_DIR  \ 3 l _^    release SCL (high)
                  BIT.B #SM_SDA,&I2CSM_IN   \ 3 h _     get SDA
                  BIS.B #SM_SCL,&I2CSM_DIR  \ 3 h  v_   SCL as output : force SCL low   13~
                  ADDC.B X,X                \ 1 l       C <--- X(7) ... X(0) <--- SDA
                  SUB #1,W                  \ 1 l       count down of bits
                0= UNTIL                    \ 2 l
\               ----------------------------\
\               case of RX data $FF         \               case of -1 SYS for example
\               ----------------------------\
                CMP.B #-1,X                 \ 1 l       received char $FF ? let's consider that the slave is lost...
            0<> WHILE                       \ 2 l
\               ----------------------------\
                CMP.B #8,X                  \ 1 l       $08 = char BS
            U>= WHILE                       \ 2 l       ASCII char received, from char 'BS' up to char $FE.
\               ----------------------------\
\               I2C_Master_RX Send Ack      \           on char {$08...$FE}
\               ----------------------------\ 
                BIS.B #SM_SDA,&I2CSM_DIR    \ 3 l   _   set SDA low to do Ack
                BIC.B #SM_SCL,&I2CSM_DIR    \ 3 l _^    release SCL (high)
                BEGIN                       \           we must wait I2C_Slave software (data processing)
                    BIT.B #SM_SCL,&I2CSM_IN \ 3 h       by testing SCL released,
                0<> UNTIL                   \ 2 h _
                BIS.B #SM_SCL,&I2CSM_DIR    \ 3 h  v_   SCL as output : force SCL low
\               ----------------------------\
\               I2C_Master echo to TERMINAL \
\               ----------------------------\
                CMP.B #4,Y                  \ 1         $04 = NOECHO request
                0<> IF                      \ 2
                    BEGIN                   \
                        BIT #TX,&TERM_IFG   \ 3 l       UART TX buffer empty ?
                    0<> UNTIL               \ 2 l       loop if no
                    MOV.B X,&TERM_TXBUF     \ 3 l       send RXed char to UART TERMINAL
                THEN                        \
            REPEAT                          \ 2 l       loop back to RX data
\           --------------------------------\
\           case of RX CTRL_Char {$00...$07}\           here Master holds SCL low, Slave can test it: CMP #8,&TERM_STATW
\           --------------------------------\           see forthMSP430FR_TERM_I2C.asm
                CMP.B #4,X                  \ 1         
                U>= IF                      \ 2
                   MOV.B X,Y                \           NOECHO = $04, ECHO = {$05...$07}
                   BIS.B #SM_SDA,&I2CSM_DIR \ 3 l       prepare SDA low = Ack for Ctrl_Chars {$04...$07}
                THEN                        \
\           --------------------------------\
            THEN                            \           false branch of CMP.B #-1,X 0<> WHILE 
\           --------------------------------\
\           Master_RX send Ack/Nack on data \           Ack for {$04...$07,$08...$FE}, Nack for {$FF...$03}
\           --------------------------------\       _
            BIC.B #SM_SCL,&I2CSM_DIR        \ 3 l _^    release SCL (high)
            BEGIN                           \           we must wait I2C_Slave software (data processing)
                BIT.B #SM_SCL,&I2CSM_IN     \ 3 h       by testing SCL released
            0<> UNTIL                       \ 2 h       (because Slave may strech SCL low)
            BIT.B #SM_SDA,&I2CSM_IN         \ 3 h _     get SDA as TX Ack/Nack state
            BIS.B #SM_SCL,&I2CSM_DIR        \ 3 h  v_   SCL as output : force SCL low
\           --------------------------------\    
        0<> UNTIL                           \ 2 l       if Ack, loop back to Master_RX data after CTRL_Chars {$04...$07,$08...$FE}
\       ------------------------------------\   
\       Nack is sent by Master              \           case of CTRL-Chars {$FF...$03}, SDA is high, SCL is low 
\       ------------------------------------\   
        CMP.B #2,X                          \
    U>= WHILE                               \   l       out of loop for CTRL_chars {$00,$01}
\       ------------------------------------\   
\       CTRL_Char {$02,$03,$FF}             \           only CTRL_Char $FF is used
\       ------------------------------------\
        MOV.B #0,Y                          \           set echo ON
        CALL #UART_RXON                     \               resume UART downloading source file
        BEGIN                               \   
            BIC #RX,&TERM_IFG               \               clear UCRXIFG
            MOV &FREQ_KHZ,X                 \               1000, 2000, 4000, 8000, 16000, 240000
           BEGIN MOV #65,W                  \               2~        <-------+ wait time for TERMINAL to refill its USB buffer
               BEGIN SUB #1,W               \               1~        <---+   | ==> ((65*3)+5)*FREQ_KHZ/1000 = 200ms delay
               0= UNTIL                     \               2~ 3~ loop ---+   |
               SUB #1,X                     \               1~                |
           0= UNTIL                         \               2~ 200~ loop -----+
            BIT #RX,&TERM_IFG               \               4 new char in TERMRXBUF during this delay ?
        0= UNTIL                            \               2 yes, the input stream is still active: loop back
    REPEAT                                  \   l       loop back to reSTART RX on WARM|ABORT messages.
\   ----------------------------------------\
\   I2C_Master_RX Send STOP                 \           remainder: CTRL_Chars {$00,$01}
\   ----------------------------------------\ 
    CALL #I2CM_STOP                         \
\   ========================================\
\   END OF I2C MASTER RX datas              \   here I2C_bus is freed, CTRL_chars $00|$01 remain to be processed.
\   ========================================\
    [DEFINED] LEDS [IF]
    BIC.B #LED2,&LED2_OUT                   \ green led OFF = endof I2C RX
    [THEN]
\   ========================================\
    CMP.B #0,X                              \
\   ----------------------------------------\
\   I2C_Slave ACCEPT ctrl_char $00          \ case of request by I2C_Slave ACCEPT
\   ----------------------------------------\
    0= IF                                   \
        MOV.B Y,&DUPLEX_MODE                \ save updated NOECHO flag before RET
        MOV #BACKGRND,PC                    \ which calls BACKGRND_U2I, RXON enabling TERMINAL TX, then LPM0 shut down.
    THEN                                    \                             
\   ----------------------------------------\
\   I2C_Slave KEY ctl_char $01              \ I2C_Slave request for KEY input
\   ----------------------------------------\
    CALL #UART_RXON                         \ enables TERMINAL to TX; use no registers
    BEGIN                                   \ wait for a char
        BIT #RX,&TERM_IFG                   \ received char ?
    0<> UNTIL                               \ 
    CALL #UART_RXOFF                        \ stops UART RX; use no registers
    MOV #0,T                                \ ready to store KEY char as last char to be received
    GOTO BW2                                \ goto the end of UART RX line input
    ENDCODE                                 \ 
\   ****************************************\
\
\
\ ==============================================================================
\ Driver UART to I2C to do a bridge USB to I2C_FastForth devices
\ ==============================================================================
\
\ I2C_address<<1  mini = $10, maxi = $EE (I2C-bus specification and user manual V6)
\ type on TERMINAL "$12 START_U2I" to link teraterm TERMINAL with FastForth I2C_Slave target at address $12

\   ------------------------------------\
    CODE START_U2I                      \ I2C_Addr<<1 --   
\   ------------------------------------\
    SUB #2,PSP                          \               DUP
    MOV TOS,0(PSP)                      \
    COLON                               \               ASSEMBLER switch to FORTH with IP backup
    'CR' EMIT 'LF' EMIT                 \
    ." Connect to I2C_SLAVE at @"       \
    . 'BS' EMIT                         \               display number without space after
     ." , TERATERM(Alt-B) "             \
    ." or I2C_MASTER(RST) to quit..."   \
    HI2LO                               \               FORTH switch to ASSEMBLER
    MOV @RSP+,IP                        \               restore IP
    BEGIN                               \
        BIT #1,&TERM_STATW              \               uart busy ?
    0= UNTIL                            \               wait end of TX last char
    CMP #RET_ADR,&{UARTI2CS}-2          \               USER_DOES default value ?
    0= IF                               \               if yes
        MOV #REMOVE_U2I,&{UARTI2CS}-2   \               USER_DOES of {UARTI2CS} will CALL &{UARTI2CS}-2 = CALL #REMOVE_U2I
        MOV &STOP_APP,&{UARTI2CS}       \               save STOP_APP value to {UARTI2CS}
        MOV &HARD_APP,&{UARTI2CS}+2     \               save HARD_APP value to {UARTI2CS}+2
        MOV &BACKGRND_APP,&{UARTI2CS}+4 \               save BACKGRND_APP value to {UARTI2CS}+4
        MOV &TERM_VEC,&{UARTI2CS}+6     \               save TERM_VEC value to {UARTI2CS}+6
        MOV &INT_IN_VEC,&{UARTI2CS}+8   \               save INT_IN_VEC value to {UARTI2CS}+8
        MOV #STOP_U2I,&STOP_APP         \               set STOP_APP with STOP_U2I addr
        MOV #HARD_U2I,&HARD_APP         \               set HARD_APP with HARD_U2I addr
        MOV #BACKGRND_U2I,&BACKGRND_APP \               set BACKGRND_APP with BACKGRND_U2I addr
        MOV #U2I_TERM_INT,&TERM_VEC     \               set TERM_VEC with U2I_TERM_INT addr
        MOV #500MS_INT,&INT_IN_VEC      \               set INT_IN_VEC with 500MS_INT addr
\       --------------------------------\
        MOV TOS,&UARTI2CS_ADR           \               save I2C_address<<1 at {UARTI2CS}+10
        KERNEL_ADDON LF_XTAL TSTBIT     \               test ACLK source before compilation
        [IF]   MOV #$0194,&TIMER_CONF   \              start RX_timer,ACLK=LFXTAL=32768/4=8192Hz,up mode
        [ELSE] MOV #$0114,&TIMER_CONF   \              start RX_timer,ACLK=VLO=8kHz, up mode
        [THEN]                          \
        FREQ_KHZ @ 24000 =              \               in assembly mode the FORTH interpreter is always active, let's enjoy it...
        [IF]   MOV #116,&COLLISION_DLY  \               )
        [ELSE] FREQ_KHZ @ 16000 =       \               )
          [IF]   MOV #76,&COLLISION_DLY \               > set 20us delay = (delay*MHz/4 -4, and set ECHO (<>4)
          [ELSE] MOV #36,&COLLISION_DLY \               )
          [THEN]                        \               )
        [THEN]                          \
    THEN                                \
    MOV #0,TOS                          \ -- 0          to enter in HARD_U2I with 0 SYS
    GOTO BW3                            \               goto HARD_U2I as new HARD_APP, direct return to ABORT
    ENDCODE                             \
\   ------------------------------------\

RST_SET ECHO    \ RST_SET defines the new bound of program memory protected against any (positive) SYS event,
                \ and so protects the MARKER structure before its use by START_U2I:
\
#18 START_U2I   \ $12 is the wanted I2C_Slave_Address<<1 to link
