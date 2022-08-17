; -*- coding: utf-8 -*-
;
; ---------------------------------------------------      ---------------------------
; TERMINAL driver for I2CFastForth target (I2C Slave)      see MSP430-FORTH/UARTI2CS.f
; ---------------------------------------------------      ---------------------------
;          |                                                           |
;          |           GND------------------------------GND            |
;          |           Vcc-------------o---o------------Vcc            |
;          |                           |   |                           |
;          |                           3   3                           |
;          |                           k   k                           |
;          v                           3   3                           v
;   I2C_FastForth                      |   |                        UARTI2C        +---------------------------------------+
;      hardware         +--------------|---o-------------+          Software       |    +-----------------------------+    |
;      I2C Slave        |      +-------o----------+      |          I2C Master     |    |    +------(option)-----+    |    |
;                       |      |                  |      |                         |    |    |                   |    |    |
; I2CFastForth target  SCL    SDA  connected to: SDA    SCL of UART to I2C bridge TXD  RXD  RTS  connected to : CTS  TXD  RXD  UARTtoUSB <--> COMx <--> TERMINAL
; ------------------   ----   ----               ----   ----   ------------------ ---  ---  ---                 ---  ---  ---  -------------------------------------
; MSP_EXP430FR5739     P1.7   P1.6               P4.0   P4.1   MSP_EXP430FR5739   P2.0 P2.1 P2.2                               PL2303TA                 TERATERM.EXE
; MSP_EXP430FR5969     P1.7   P1.6               P1.2   P1.3   MSP_EXP430FR5969   P2.0 P2.1 P4.1                               PL2303HXD
; MSP_EXP430FR5994     P7.1   P7.0               P8.2   P8.1   MSP_EXP430FR5994   P2.0 P2.1 P4.2                               CP2102
; MSP_EXP430FR6989     P1.7   P1.6               P1.3   P1.5   MSP_EXP430FR6989   P3.4 P3.5 P3.0
; MSP_EXP430FR4133     P5.3   P5.2               P8.2   P8.3   MSP_EXP430FR4133   P1.0 P1.1 P2.3
; CHIPSTICK_FR2433     P1.3   P1.2               P2.0   P2.2   CHIPSTICK_FR2433   P1.4 P1.5 P3.2
; MSP_EXP430FR2433     P1.3   P1.2               P3.2   P3.1   MSP_EXP430FR2433   P1.4 P1.5 P1.0
; MSP_EXP430FR2355     P1.3   P1.2               P3.2   P3.3   MSP_EXP430FR2355   P4.3 P4.2 P2.0
; LP_MSP430FR2476      P4.3   P4.4               P3.2   P3.3   LP_MSP430FR2476    P1.4 P1.5 P6.1
;
; don't forget to link 3V3 and GND on each side and to add 3k3 pullup resistors on SDA and SCL.
;
;-------------------------------------------------------------------------------
; I2C TERMINAL: QABORT ABORT_TERM INIT_FORTH INIT_TERM COLD_TERM RXON I2C_CTRL_CH
;-------------------------------------------------------------------------------

;-----------------------------------;
INIT_FORTH                          ; common ABORT_TERM|WARM subroutine, to init DEFERed definitions + INIT_FORTH
;-----------------------------------;
            MOV @RSP+,IP            ; init IP with CALLER next address
;                                   ;
            MOV #PUC_ABORT_ORG,X    ; FRAM INFO         FRAM MAIN
;                                   ; ---------         ---------
            MOV @X+,&PFAACCEPT      ; BODYACCEPT    --> PFAACCEPT
            MOV @X+,&PFAEMIT        ; BODYEMIT      --> PFAEMIT
            MOV @X+,&PFAKEY         ; BODYKEY       --> PFAKEY
            MOV @X+,&CIB_ORG        ; TIB_ORG       --> CIB_ORG
;                                   ;
;                                   ; FRAM INFO         REG|RAM
;                                   ; ---------         -------
            MOV @X+,RSP             ; INIT_RSTACK   --> R1=RSP
            MOV @X+,rDOCOL          ; EXIT          --> R4=rDOCOL   (if DTC=2)
            MOV @X+,rDODOES         ; XDODOES       --> R5=rDODOES
            MOV @X+,rDOCON          ; XDOCON        --> R6=rDOCON
            MOV @X+,rDOVAR          ; RFROM         --> R7=rDOVAR
            MOV @X+,&CAPS           ; INIT_CAPS     --> RAM CAPS            init CAPS ON
            MOV @X+,&BASEADR        ; INIT_BASE     --> RAM BASE            init decimal base
            MOV @X+,&LEAVEPTR       ; INIT_LEAVE    --> RAM LEAVEPTR
            MOV #0,&STATE           ; 0             --> RAM STATE
            CALL &SOFT_APP          ; default SOFT_APP = INIT_SOFT = RET_ADR, value set by DEEP_RESET.
            MOV #SEL_RST,PC         ; goto PUC 7 to select the user's choice from TOS value: RST_RET|DEEP_RESET
;-----------------------------------;

; ?ABORT defines the run-time part of ABORT"
;-----------------------------------;
QABORT      CMP #0,2(PSP)           ; -- f addr cnt     if f is true abort current process then display ABORT" msg.
            JNZ ABORT_TERM          ;
THREEDROP   ADD #4,PSP              ; -- cnt
            JMP DROP                ;
; ----------------------------------;
ABORT_TERM  PUSH #ABORT_INIT        ; called by INTERPRET, QREVEAL, TYPE2DOES
; ----------------------------------;
I2C_ABORT   MOV.B #-1,Y             ; send $FF (ABORT_TERM Ctrl_Char) to UARTtoI2C bridge (I2C Master)
            JMP I2C_CTRL_CH         ;
ABORT_INIT  CALL #INIT_FORTH        ;                   common ?ABORT|PUC subroutine
A_TERM_END  .word   DUP             ; -- f addr cnt cnt
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

; ----------------------------------;
INIT_BACKGRND                       ; default content of BACKGRND_APP called by BACKGRND
; ----------------------------------;
I2C_INIT_BACKGRND                   ;
; ----------------------------------;
I2C_ACCEPT  MOV.B #0,Y              ; ACCEPT request Ctrl_Char = $00
            JMP I2C_CTRL_CH         ;
; ----------------------------------;

;-------------------------------------------------------------------------------
; INIT TERMinal then enable I/O
;-------------------------------------------------------------------------------
INIT_TERM                           ; default content of HARD_APP called by WARM
; ----------------------------------; TOS = USERSYS, don't change
        BIS #07C0h,&TERM_CTLW0      ; set I2C_Slave in RX mode to receive I2C_address
        MOV &I2CSLAVEADR,Y          ; I2C_Slave_address<<1 value found in FRAM INFO
        RRA Y                       ; shift it right one 
        BIS #400h,Y                 ; enable I2COA0 Slave address
        MOV Y,&TERM_I2COA0          ;
        BIS.B #BUS_TERM,&TERM_SEL   ; Configure pins TERM_I2C
        BIC #1,&TERM_CTLW0          ; release UC_TERM from reset...
        BIS #WAKE_UP,&TERM_IE       ; ...enable interrupt for wake up on START
        BIC #LOCKLPM5,&PM5CTL0      ; then activate all previous I/O settings.
; ----------------------------------;
INIT_STOP                           ; default content of STOP_APP called by SYS, does nothing
; ----------------------------------;
INIT_SOFT   MOV @RSP+,PC            ; default content of SOFT_APP called by INIT_FORTH, does nothing
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
;-------------------------------------------------------------------------------
; PUC 5: GET SYSRSTIV and USERSYS
;-------------------------------------------------------------------------------
            MOV &SYSRSTIV,X         ; X <-- SYSRSTIV <-- 0
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
ACCEPT_EOL  MOV S,Y                 ;       output a BL on TERMINAL (for the case of error occuring)
            JMP QYEMIT              ;       before going to INTERPRET
; **********************************;

; ----------------------------------;
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

;-----------------------------------;
            FORTHWORD "ECHO"        ; --    connect EMIT to TERMINAL (default)
;-----------------------------------;
ECHO        MOV #0B3A2h,&QYEMIT     ;       MOV #'BIT #TX_TERM,0(PC)',&QYEMIT
            MOV.B #5,Y              ;       ECHO request Ctrl_Char = $05
ECHOEND     CALL #I2C_CTRL_CH       ;
            MOV @IP+,PC             ;
; ----------------------------------;

;-----------------------------------;
            FORTHWORD "NOECHO"      ; --    disconnect TERMINAL from EMIT
;-----------------------------------;
NOECHO      MOV #4D30h,&QYEMIT      ;       MOV #'MOV @IP+,PC',&QYEMIT
            MOV.B #4,Y              ;       NOECHO request Ctrl_Char = $04
            JMP ECHOEND             ;
; ----------------------------------;
