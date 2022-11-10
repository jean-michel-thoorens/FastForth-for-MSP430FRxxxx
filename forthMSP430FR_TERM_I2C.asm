; -*- coding: utf-8 -*-
;
; ---------------------------------------------------              ---------------------------
; TERMINAL driver for I2CFastForth target (I2C Slave)              see MSP430-FORTH/UARTI2CS.f
; ---------------------------------------------------              ---------------------------
;        |                                                                      |
;        |                                                                      |
;        |             GND------------------------------GND                     |
;        |             3V3-------------o---o------------3V3                     |
;        |                             |   |                                    | 
;        |                             1   1                                    | 
;        |                             k   k                Txy.z output        | 
;        v                             0   0                     to             v                 GND-------------------------------------GND 
;   I2C_FastForth                      |   |                  Px.y int       UARTI2CS              +-------------------------------------->+
;     (hardware         +<-------------|---o------------>+     jumper       (Software              |    +<----------------------------+    |
;     I2C Slave)        ^      +<------o----------+      ^     +--->+       I2C Master)            |    |    +------(option)---->+    |    |
;                       v      v                  ^      v     ^    |                              ^    v    ^                   v    ^    v
; I2C_FastForth(s)     SDA    SCL  connected to: SCL    SDA    |    v   I2C_to_UART_bridge        TXD  RXD  RTS  connected to : CTS  TXD  RXD  UARTtoUSB <--> COMx <--> TERMINAL
; ------------------   ----   ----               ----   ----             ----------------         ---  ---  ---                 ---  ---  ---  ---------      ----      --------
; MSP_EXP430FR2355     P1.2   P1.3               P3.3   P3.2  P1.7 P1.6  MSP_EXP430FR2355 (24MHz) P4.3 P4.2 P2.0                               PL2303GC                    |      
; MSP_EXP430FR5739     P1.6   P1.7               P4.1   P4.0  P1.1 P1.0  MSP_EXP430FR5739 (24MHz) P2.0 P2.1 P2.2                               PL2303HXD                   v
; MSP_EXP430FR5969     P1.6   P1.7               P1.3   P1.2  P2.2 P3.4  MSP_EXP430FR5969 (16MHz) P2.0 P2.1 P4.1                               PL2303TA               TERATERM.EXE     
; MSP_EXP430FR5994     P7.0   P7.1               P8.1   P8.2  P1.5 P1.4  MSP_EXP430FR5994 (16MHz) P2.0 P2.1 P4.2                               CP2102                       
; MSP_EXP430FR6989     P1.6   P1.7               P1.5   P1.3  P3.6 P3.7  MSP_EXP430FR6989 (16MHz) P3.4 P3.5 P3.0                                                                  
; MSP_EXP430FR4133     P5.2   P5.3               P8.3   P8.2  P1.6 P1.7  MSP_EXP430FR4133 (16MHz) P1.0 P1.1 P2.3                                                                  
; MSP_EXP430FR2433     P1.2   P1.3               P3.1   P3.2  P1.2 P1.3  MSP_EXP430FR2433 (16MHz) P1.4 P1.5 P1.0                                                                      
; LP_MSP430FR2476      P4.4   P4.3               P3.3   P3.2  P1.2 P1.1  LP_MSP430FR2476  (16MHz) P1.4 P1.5 P6.1                                                                                                                                
;
; don't forget to link 3V3 and GND on each side and to add 3k3 pullup resistors on SDA and SCL.
;
;-----------------------------------------------------------------------------------------------------------
; I2C TERMINAL: ?ABORT, INIT values of ABORT_APP, BACKGRND_APP, HARD_APP, COLD_APP and SOFT_APP
;-----------------------------------------------------------------------------------------------------------

; ==================================;
ABORT_TERM                          ; INIT value of ABORT_APP,  used by SD_CARD_ERROR
; ==================================;
            MOV.B #-1,Y             ; send $FF (QABORT_YES Ctrl_Char) to UARTtoI2C bridge (I2C Master), used by SD_CARD_ERROR
            JMP I2C_CTRL_CH         ; then RET
;-----------------------------------;

; ?ABORT defines the run-time part of ABORT"
;-----------------------------------;
QABORT      CMP #0,2(PSP)           ; -- f addr cnt     if f is true abort current process then display ABORT" msg.
            JNZ QABORT_YES          ;
            ADD #4,PSP              ; -- cnt
            JMP DROP                ;
; ----------------------------------;
QABORT_YES  CALL &ABORT_APP         ;                   QABORT_YES called by INTERPRET, QREVEAL, TYPE2DOES
; ----------------------------------;
            CALL #INIT_FORTH        ;                   common ?ABORT|PUC subroutine
            .word   DUP             ; -- f addr cnt cnt
            .word   QFBRAN,ABORT_END; -- f addr 0       if cnt = 0 display nothing
            .word   ECHO            ; -- f addr cnt     force ECHO
            .word   XSQUOTE         ;
            .byte   5,27,"[7m",'@'  ;
            .word   TYPE            ;                       cmd "reverse video" + displays "@"
            .word   LIT,I2CSLAVEADR ;
            .word   FETCH,DOT       ;                       displays I2C_Slave_Address<<1
; ----------------------------------;
; Display ABORT|WARM message        ; -- f addr cnt     <== WARM jumps here
; ----------------------------------;
ABORT_TYPE  .word   TYPE            ; -- f              display QABORT|WARM message
SDABORT_END .word   XSQUOTE         ;                   set normal video Display then goto ABORT
            .byte   4,27,"[0m"      ;
            .word   TYPE            ;                   set normal video
ABORT_END   .word   ABORT           ; -- f|f addr 0     no return
; ----------------------------------;

; ==================================;
INIT_BACKGRND                       ; INIT value of BACKGRND_APP
; ==================================;
I2C_ACCEPT  MOV.B #0,Y              ; ACCEPT request Ctrl_Char = $00
            JMP I2C_CTRL_CH         ; then RET
; ----------------------------------;

;-------------------------------------------------------------------------------
; INIT TERMinal then enable I/O
;-------------------------------------------------------------------------------

; ==================================;
INIT_TERM                           ; INIT value of HARD_APP called by WARM
; ==================================;
        BIS #07C0h,&TERM_CTLW0      ; set I2C_Slave in RX mode to receive I2C_address
        MOV &I2CSLAVEADR,Y          ; I2C_Slave_address<<1 value found in FRAM INFO
        RRA Y                       ; shift it right one 
        BIS #400h,Y                 ; enable I2COA0 Slave address
        MOV Y,&TERM_I2COA0          ;
        BIS.B #BUS_TERM,&TERM_SEL   ; Configure pins TERM_I2C
        BIC #1,&TERM_CTLW0          ; release UC_TERM from reset...
        BIS #WAKE_UP,&TERM_IE       ; ...enable interrupt for wake up on START
        BIC #LOCKLPM5,&PM5CTL0      ; then activate all previous I/O settings.
; ==================================;
INIT_STOP                           ; INIT value of STOP_APP called by SYS, does nothing
; ==================================;
INIT_SOFT                           ; INIT value of SOFT_APP
; ==================================;
   MOV @RSP+,PC                     ;
; ----------------------------------;

;-------------------------------------------------------------------------------
; I2C TERMINAL : SYS COLD RESET WARM
;-------------------------------------------------------------------------------

;-----------------------------------;
WARM                                ; (n) --
;-----------------------------------;
        CALL &HARD_APP              ; init HARD_APP, i.e. I2C_TERMinal then unlock IO's
        mASM2FORTH                  ;
        .word   ECHO                ;
        .word   XSQUOTE             ;
        .byte   7,13,10,27,"[7m@"   ; CR+LF + cmd "reverse video" + @
        .word   TYPE                ;
        .word   LIT,I2CSLAVEADR     ;
        .word   FETCH,DOT           ; display decimal I2C_address<<1
        .word   LIT,'#',EMIT        ;
        .word   DOT                 ; display signed USERSYS
        .word   XSQUOTE             ;
        .byte   25,"FastForth ",169 ;
        .byte   "J.M.Thoorens, "    ;
        .word   TYPE                ;
        .word   LIT,FRAM_FULL       ;
        .word   HERE,MINUS,UDOT     ;
        .word   XSQUOTE             ;
        .byte   10,"bytes free"     ; bytes free
        .word   BRAN,ABORT_TYPE     ; no return
;-----------------------------------;

            FORTHWORD "SYS"         ; n --      select COLD, DEEP_COLD, WARM (as software RST,DEEP_RST,WARM)
;-----------------------------------;
SYS         CALL &STOP_APP          ; default STOP_APP = INIT_STOP, set by DEEP_RESET.
            CMP #0,TOS              ;
            JL TOS2COLD             ; if -n SYS  --> COLD --> PUC --> INIT_FORTH --> DEEP_RESET --> WARM
            JZ TOS2WARM             ; if [0] SYS --> INIT_FORTH --> WARM
            BIT #1,TOS              ;
            JZ TOS2COLD             ; if +n SYS (+n even)--> COLD --> PUC --> INIT_FORTH --> WARM
TOS2WARM    CALL #INIT_FORTH        ; if +n SYS (+n odd) --> INIT_FORTH --> WARM
FWARM       .word WARM              ; no return
TOS2COLD    MOV TOS,&USERSYS        ;
;*******************************************************************************
COLD        ; <--- USER_NMI vector <--- <RESET> and <RESET> + <SW1> (DEEP_RESET)
;*******************************************************************************
; as pin RST is replaced by pin NMI, RESET by pin activation is redirected here via USER NMI vector
; that allows actions to be performed before executing software BOR.
            BIT.B #SW1,&SW1_IN      ; <SW1> pressed ?
            JNZ DO_BOR              ; no
            MOV #-1,&USERSYS        ; yes, set negative value to force DEEP_RESET
DO_BOR      MOV #0A504h,&PMMCTL0    ; ---------------------------> software_BOR --->+
;*******************************************************************************    |
RESET                               ; <-- RST vect. <-- SYS_failures PUC POR BOR <--+
;*******************************************************************************
; PUC 1: replace pin RESET by pin NMI, stops WDT_RESET
;-------------------------------------------------------------------------------
            BIS #1,&SFRRPCR         ; pin RST becomes pin NMI with rising edge, so SYSRSTIV = 6
            BIS #10h,&SFRIE1        ; enable NMI interrupt ==> hardware RESET is redirected to COLD.
            MOV #5A80h,&WDTCTL      ; disable WDT RESET
;-------------------------------------------------------------------------------
; PUC 2: INIT STACK
;-------------------------------------------------------------------------------
            MOV #RSTACK,RSP         ; init return stack
            MOV #PSTACK,PSP         ; init parameter stack
;-------------------------------------------------------------------------------
; PUC 3: I/O, RAM, RTC, CS, SYS initialisation limited to FastForth usage.
;          All unused I/O are set as input with pullup resistor.
;-------------------------------------------------------------------------------
        .include "TargetInit.asm"   ; include target specific init code
;-------------------------------------------------------------------------------
; PUC 4: init RAM to 0
;-------------------------------------------------------------------------------
            MOV #RAM_LEN,X          ; 2 RAM_LEN must be even and > 1, obviously.
INITRAMLOOP SUB #2,X                ; 1
            MOV #0,RAM_ORG(X)       ; 3
            JNZ INITRAMLOOP         ; 2     6 cycles loop !
; ;-------------------------------------------------------------------------------
; ; PUC 5: GET SYSRSTIV and USERSYS
; ;-------------------------------------------------------------------------------
;             MOV &SYSRSTIV,X        ; X <-- SYSRSTIV <-- 0
;-------------------------------------------------------------------------------
; PUC 5: GET SYSUNIV_SYSSNIV_SYSRSTIV ( %0_UUU0_SSSS0_RRRRR0) and USERSYS
;-------------------------------------------------------------------------------
            MOV &SYSUNIV,X          ; 0 --> SYSUNIV --> X   (%0000_0000_0000_UUU0) (7 values)
            RLAM #4,X               ; make room for SYSSNIV (%0000_0000_UUU0_0000)
            ADD X,X                 ;                       (%0000_000U_UU00_0000)
            BIS &SYSSNIV,X          ; 0 --> SYSSNIV --> X   (%0000_000U_UU0S_SSS0) (15 values)
            RLAM #4,X               ; make room for SYSRSTIV(%000U_UU0S_SSS0_0000)
            RLAM #2,X               ;                       (%0UUU_0SSS_S000_0000)
            BIS.B &SYSRSTIV,X       ; 0 --> SYSRSTIV --> X  (%0UUU_0SSS_S0RR_RRR0) (31 values)
;-------------------------------------------------------------------------------
            MOV &USERSYS,TOS        ; TOS = USERSYS (FRAM)
            MOV #0,&USERSYS         ; and clear USERSYS
            BIT.B #-1,TOS           ; high byte reserved use
            JNZ PUC6                ; if TOS <> 0, keep this USERSYS value
            MOV X,TOS               ; else TOS = SYSRSTIV
;-------------------------------------------------------------------------------
; PUC 6: START FORTH engine: WARM (BOOT)
;-------------------------------------------------------------------------------
PUC6        CALL #INIT_FORTH        ; common part of QABORT|PUC
PUCNEXT     .word WARM              ; no return. May be replaced by XBOOT by BOOT ;-)
;-----------------------------------;

;-------------------------------------------------------------------------------
; INTERPRETER INPUT: ACCEPT KEY EMIT ECHO NOECHO
;-------------------------------------------------------------------------------

            FORTHWORD "ACCEPT"      ;
; ----------------------------------;
;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get a line from TERMINAL
ACCEPT      MOV @PC+,PC             ;3 Code Field Address (CFA) of ACCEPT
PFAACCEPT   .word   BODYACCEPT      ;  Parameter Field Address (PFA) of ACCEPT
; ----------------------------------;
; ACCEPT part I prepare TERMINAL_INT;
; ----------------------------------;
BODYACCEPT  MOV TOS,W               ;1 -- org len   W=len
            MOV @PSP,TOS            ;2 -- org ptr                                               )
            ADD TOS,W               ;1 -- org ptr   W=buf_end                                   )
            MOV #0Ah,T              ;2              T = 'LF' to speed up char loop in part II   > prepare stack and registers for TERMINAL_INT use
            MOV #20h,S              ;2              S = 'BL' to speed up char loop in part II   )
            PUSHM #4,IP             ;6              PUSH IP,S,T,W  R-- IP, 'BL', 'LF', buf_end  )

; here, FAST FORTH sleeps, waiting any interrupt. With LPM4, supply current is below 1uA.
; IP,S,T,W,X,Y registers (R13 to R8) are free...
; ...and also TOS, PSP and RSP stacks within their rules of use.
;###################################################################################
BACKGRND    CALL &BACKGRND_APP  ;   default BACKGRND_APP = INIT_BACKGRND = I2C_ACCEPT, value set by DEEP_RESET.
            BIS &LPM_MODE,SR    ;2  enter in LPM4 mode with GIE=1
            JMP BACKGRND        ;2  return for all interrupts.
;###################################################################################

; As TI says nothing about the reset of the UCSTTIFG flag by the I2C_Slave,
; it is assumed that it clears it as soon as the first byte has been exchanged.
; **********************************;
TERMINAL_INT                        ; <--- 80us <--- START interrupt vector, bus is stalled, I2C_Master waits ACK on address
; **********************************;
; ACCEPT part II wake on TERM_INT   ; Org Ptr --
; ----------------------------------;
            ADD #4,RSP              ;1      remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            BIC #WAKE_UP,&TERM_IFG  ;       clear UCSTTIFG before return to BACKGRND if any (here, UCSTTIFG is not yet cleared !)
            BIT #10h,&TERM_CTLW0    ;4      test UCTR
            JNZ BACKGRND            ;       if Master RX loop back to BACKGRND
ACCEPT_YES  POPM #4,IP              ;6      POPM  S=20h, T=0Ah, W=src_end, IP=ret_IP
QNEWCHAR    BIT #RX_TERM,&TERM_IFG  ;3      test RX BUF IFG
            JZ QNEWCHAR             ;2      wait RX BUF full
; ----------------------------------;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3      read char into Y, RX_IFG is cleared, bus unstalled by I2C_Slave
; ----------------------------------;
            CMP.B S,Y               ;1      printable char ?
            JC ASTORETEST           ;2      jump if char U>= BL
            CMP.B T,Y               ;1      char = LF ?
            JZ LF_NEXT              ;2      jump if char = LF
; ----------------------------------;
            CMP.B #8,Y              ;       char = BS ?
            JNZ QNEWCHAR            ;       case of all other control chars: skip them
; ----------------------------------;
; case of backspace                 ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ QNEWCHAR             ;       yes: does nothing
            SUB #1,TOS              ;       no : dec Ptr
            JMP QNEWCHAR            ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1     end of buffer is reached ?
            JC QNEWCHAR             ; 2     yes: don't store char @ dst_Ptr, don't increment TOS
            MOV.B Y,0(TOS)          ; 3     no: store char @ dst_Ptr
            ADD #1,TOS              ; 1     increment dst_Ptr
            JMP QNEWCHAR            ;
; ----------------------------------;
LF_NEXT     BIT #10h,&TERM_CTLW0    ;4      test UCTR, instead of BUS idle because a ReSTART perhaps used by Master
            JZ LF_NEXT              ;       wait until Master switched from TX to RX
; ----------------------------------;
            SUB @PSP+,TOS           ; -- len'
            MOV S,Y                 ;       output a BL on TERMINAL (for the case of error occuring)
            JMP QYEMIT              ;       before going to INTERPRET
; **********************************;

            FORTHWORD "KEY"         ;
; ----------------------------------;
; https://forth-standard.org/standard/core/KEY
; KEY      -- c      wait character from input device ; primary DEFERred word
KEY         MOV @PC+,PC             ; Code Field Address (CFA) of KEY
PFAKEY      .word BODYKEY           ; Param Field Address (PFA) of KEY, with its default value
BODYKEY     PUSH #KEYNEXT           ;
            MOV.B #1,Y              ; KEY request Ctrl_Char = $01
; ----------------------------------;
I2C_CTRL_CH BIT #TX_TERM,&TERM_IFG  ; send it to I2C_Master_RX to restart it in TX mode
            JZ I2C_CTRL_CH          ; wait TX buffer empty
            MOV.B Y,&TERM_TXBUF     ; send Ctrl_Char
            MOV @RSP+,PC            ;
; ----------------------------------;
KEYNEXT     SUB #2,PSP              ;1          push old TOS..
            MOV TOS,0(PSP)          ;           ..onto stack
BKEYLOOP    BIT #RX_TERM,&TERM_IFG  ;           received char ?
            JZ BKEYLOOP             ;           wait char received
            MOV &TERM_RXBUF,TOS     ; -- char
            CALL #I2C_ACCEPT        ;           send Ctrl_Char $00 to I2C_Master to restart its UART in TX mode
BKEYEND     MOV @IP+,PC             ; -- char
; ----------------------------------;

            FORTHWORD "EMIT"        ;
; ----------------------------------;
; https://forth-standard.org/standard/core/EMIT
; EMIT     c --    output character to an output device ; primary DEFERred word
EMIT        MOV @PC+,PC             ;3 Code Field Address (CFA) of EMIT
PFAEMIT     .word BODYEMIT          ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT    MOV TOS,Y               ;1 sends character to the default output TERMINAL
            MOV @PSP+,TOS           ;2
QYEMIT      BIT #TX_TERM,&TERM_IFG  ;3 NOECHO stores here : MOV @IP+,PC, ECHO store here the first word of: BIT #TX_TERM,&TERM_IFG
            JZ QYEMIT               ;2 wait TX buffer empty
            MOV.B Y,&TERM_TXBUF     ;3
            MOV @IP+,PC             ;4 11 words
; ----------------------------------;

            FORTHWORD "ECHO"        ; --    connect EMIT to TERMINAL (default)
;-----------------------------------;
ECHO        MOV #0B3A2h,&QYEMIT     ;       MOV #'BIT #TX_TERM,0(PC)',&QYEMIT
            MOV.B #5,Y              ;       ECHO request Ctrl_Char = $05
ECHOEND     CALL #I2C_CTRL_CH       ;
            MOV @IP+,PC             ;
; ----------------------------------;

            FORTHWORD "NOECHO"      ; --    disconnect TERMINAL from EMIT
;-----------------------------------;
NOECHO      MOV #4D30h,&QYEMIT      ;       MOV #'MOV @IP+,PC',&QYEMIT
            MOV.B #4,Y              ;       NOECHO request Ctrl_Char = $04
            JMP ECHOEND             ;
; ----------------------------------;
