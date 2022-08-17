; -*- coding: utf-8 -*-
;
; ---------------------------------------
; UART TERMINAL driver for FastForth target
; ---------------------------------------
;
;                     +---------------------------------------+
;                     |    +-----------------------------+    |
;                     |    |    +------(option)-----+    |    |
;                     |    |    |                   |    |    |
; FastForth target:  TXD  RXD  RTS  connected to : CTS  TXD  RXD of UARTtoUSB <--> COMx <--> TERMINAL
; ----------------   ---  ---  ---                 ---  ---  ---    -------------------------------------
; MSP_EXP430FR5739   P2.0 P2.1 P2.2                                 PL2303TA                 TERATERM.EXE
; MSP_EXP430FR5969   P2.0 P2.1 P4.1                                 PL2303HXD/GC
; MSP_EXP430FR5994   P2.0 P2.1 P4.2                                 CP2102
; MSP_EXP430FR6989   P3.4 P3.5 P3.0
; MSP_EXP430FR4133   P1.0 P1.1 P2.3
; CHIPSTICK_FR2433   P1.4 P1.5 P3.2
; MSP_EXP430FR2433   P1.4 P1.5 P1.0
; MSP_EXP430FR2355   P4.3 P4.2 P2.0
; LP_MSP430FR2476    P1.4 P1.5 P6.1
;
;-------------------------------------------------------------------------------
; UART TERMINAL: QABORT ABORT_TERM INIT_BACKGRND RXON INIT_FORTH INIT_TERM INIT_COLD INIT_SOFT
;-------------------------------------------------------------------------------
;
;-----------------------------------;
; modifying TOs is forbidden here ! ;
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
            MOV @X+,&CIB_ORG        ; TIB_ORG       --> CIB_ORG             TIB = Terminal Input Buffer, CIB = Current Input Buffer
;                                   ;
;                                   ; FRAM INFO         REG|RAM
;                                   ; ---------         -------
            MOV @X+,RSP             ; INIT_RSTACK   --> R1=RSP              PSP is initialised with ABORT
            MOV @X+,rDOCOL          ; EXIT          --> R4=rDOCOL           (if DTC=2)
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
ABORT_TERM  PUSH #ABORT_INIT        ; ABORT_TERM is called by INTERPRET, QREVEAL, TYPE2DOES
; ----------------------------------;
UART_ABORT  CALL #UART_RXON         ;
; ----------------------------------;
A_UART_LOOP BIC #RX_TERM,&TERM_IFG  ; clear RX_TERM
            MOV &FREQ_KHZ,Y         ; 1000, 2000, 4000, 8000, 16000, 24000
A_USB_LOOPJ MOV #65,X               ; 2~        <-------+ linux with minicom seems very very slow...
A_USB_LOOPI SUB #1,X                ; 1~        <---+   | ...to refill its USB buffer
            JNZ A_USB_LOOPI         ; 2~ 3~ loop ---+   |  ==> ((65*3)+5)*1000 = 200ms delay
            SUB #1,Y                ; 1~                |
            JNZ A_USB_LOOPJ         ; 2~ 200~ loop -----+
            BIT #RX_TERM,&TERM_IFG  ; 4 new char in TERMRXBUF after 200ms delay ?
            JNZ A_UART_LOOP         ; 2 yes, the input stream is still active: loop back
            MOV @RSP+,PC
; ----------------------------------;
ABORT_INIT  CALL #INIT_FORTH        ;                   common ?ABORT|PUC subroutine
            .word   DUP             ; -- f addr cnt cnt
            .word   QFBRAN,ABORT_END; -- f addr 0       don't force ECHO, no display if ABORT" is an empty string
            .word   ECHO            ; -- f addr cnt     force ECHO
            .word   XSQUOTE         ;
            .byte   4,27,"[7m"      ;
            .word   TYPE            ;                   ESC [7m = set reverse video
; ----------------------------------;
; Display QABORT|WARM message       ; -- addr cnt       <== WARM jumps here
; ----------------------------------;
ABORT_TYPE  .word   TYPE            ; -- f              type QABORT|WARM message
SDABORT_END .word   XSQUOTE         ;                   set normal video Display then goto ABORT
            .byte   4,27,"[0m"      ;
            .word   TYPE            ;                   ESC [0m = set normal video
ABORT_END   .word   ABORT           ; -- f              no return
; ----------------------------------;

;-------------------------------------------------------------------------------
; INIT TERMinal then enable I/O     ;
;-------------------------------------------------------------------------------
INIT_HARD                           ;
; ----------------------------------;
INIT_TERM                           ; default content of HARD_APP called by WARM
; ----------------------------------;
    MOV #0081h,&TERM_CTLW0          ; 8 bits, UC SWRST + UCLK = SMCLK, max 6MBds @24MHz
    MOV &TERMBRW_RST,&TERM_BRW      ; init value in FRAM INFO
    MOV &TERMMCTLW_RST,&TERM_MCTLW  ; init value in FRAM INFO
    BIS.B #BUS_TERM,&TERM_SEL       ; Configure pins TERM_UART|TERM_I2C
    BIC #1,&TERM_CTLW0              ; release UC_TERM from reset...
    BIS #WAKE_UP,&TERM_IE           ; then enable interrupt for wake up on terminal input
    BIC #LOCKLPM5,&PM5CTL0          ; activate all previous I/O settings.
    MOV @RSP+,PC                    ; RET
; ----------------------------------;

; ----------------------------------;
INIT_STOP                           ; default STOP_APP, called by SYS: wait end of TX to TERMINAL
; ----------------------------------;
TX_IDLE     BIT #1,&TERM_STATW      ;3 uart busy ?
            JNZ TX_IDLE             ;2 loop back while TERM_UART is busy
; ----------------------------------;
INIT_SOFT   MOV @RSP+,PC            ;
; ----------------------------------;

;-------------------------------------------------------------------------------
; UART TERMINAL : SYS COLD RESET WARM
;-------------------------------------------------------------------------------

;-----------------------------------;
UART_WARM                           ; (n) --
;-----------------------------------;
WARM    CALL &HARD_APP              ; default HARD_APP = INIT_TERM, value set by DEEP_RESET.
        mASM2FORTH                  ;
        .word   ECHO                ;
        .word   XSQUOTE             ;
        .byte   7,13,10,27,"[7m#"   ; CR + cmd "reverse video" + #
        .word   TYPE                ;
        .word   DOT                 ; display TOS = USERSYS value
        .word   XSQUOTE             ;
        .byte   25,"FastForth ",169 ;
        .byte   "J.M.Thoorens, "    ;
        .word   TYPE                ;
        .word   LIT,FRAM_FULL       ;
        .word   HERE,MINUS,UDOT     ;
        .word   XSQUOTE             ;
        .byte   10,"bytes free"     ;
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
COLD                                ; <--- USER_NMI vector <------------------------ <RESET> | <RESET+SW1>
;*******************************************************************************
; as pin RST is replaced by pin NMI, hardware RESET is redirected here via USER NMI vector
; that allows actions to be performed before executing software BOR.
            BIT.B #SW1,&SW1_IN      ; <SW1> pressed ?
            JNZ DO_BOR              ; no
            MOV #-1,&USERSYS        ; yes, set negative value to force DEEP_RESET
DO_BOR      MOV #0A504h,&PMMCTL0    ; ---------------------------> software_BOR --->+
;*******************************************************************************    |
;*******************************************************************************    v
RESET                               ; <--- RST vector <----------- PUC <--- POR <---+<--- BOR <--- SYS_failures 
;*******************************************************************************
;*******************************************************************************
; PUC 1: replace pin RESET by pin NMI, stops WDT_RESET
;-------------------------------------------------------------------------------
            BIS #1,&SFRRPCR         ; pin RST becomes pin NMI with rising edge, SYSRSTIV = 6, hardware RESET is redirected to COLD
            BIS #10h,&SFRIE1        ; enable NMI pin interrupt.
            MOV #5A80h,&WDTCTL      ; disable WDT RESET
;-------------------------------------------------------------------------------
; PUC 2: INIT STACK
;-------------------------------------------------------------------------------
            MOV #PSTACK,PSP         ; init parameter stack
            MOV #RSTACK,RSP         ; init return stack
;-------------------------------------------------------------------------------
; PUC 3: I/O, RAM, RTC, CS, SYS initialisation limited to FastForth usage.
;          All unused I/O are set as input with pullup resistor.
;-------------------------------------------------------------------------------
        .include "TargetInit.asm"   ; include target specific init code
;-------------------------------------------------------------------------------
; PUC 4: init RAM to 0
;-------------------------------------------------------------------------------
            MOV #RAM_LEN,X          ; 2 RAM_LEN must be even and > 0, obviously.
INITRAMLOOP SUB #2,X                ; 1
            MOV #0,RAM_ORG(X)       ; 3
            JNZ INITRAMLOOP         ; 2 6 cycles loop !
;-------------------------------------------------------------------------------
; PUC 5: GET SYSRSTIV and USERSYS
;-------------------------------------------------------------------------------
            MOV &SYSRSTIV,X         ; X <-- SYSRSTIV <-- 0
            MOV &USERSYS,TOS        ; TOS = FRAM USERSYS
            MOV #0,&USERSYS         ; clear FRAM USERSYS
            BIT #-1,TOS             ;
            JNZ PUC6                ; if TOS <> 0, keep USERSYS value
            MOV X,TOS               ; else TOS <-- SYSRSTIV
;-------------------------------------------------------------------------------
; PUC 6: START FORTH engine: WARM (BOOT)
;-------------------------------------------------------------------------------
PUC6        CALL #INIT_FORTH        ; common part of QABORT|PUC
PUCNEXT     .word WARM              ; no return. May be redirected by BOOT.
;-----------------------------------;

;-------------------------------------------------------------------------------
; INTERPRETER INPUT: ACCEPT KEY EMIT ECHO NOECHO
;-------------------------------------------------------------------------------
            FORTHWORD "ACCEPT"      ;
;-----------------------------------;
;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get line at addr to interpret len' chars
ACCEPT      MOV @PC+,PC             ;3 Code Field Address (CFA) of ACCEPT
PFAACCEPT   .word   BODYACCEPT      ;  Parameter Field Address (PFA) of ACCEPT
; ----------------------------------;
; ACCEPT part I prepare TERMINAL_INT;               this version allows to RX one char (LF) after sending XOFF
; ----------------------------------;
BODYACCEPT  MOV TOS,Y               ;1 -- org len   Y = len
            MOV @PSP,TOS            ;2 -- org ptr
            ADD TOS,Y               ;1 -- org ptr   Y = buf_end
            MOV #0Dh,X              ;2              X = 'CR' to speed up char loop in part II
            MOV #20h,W              ;2              W = 'BL' to speed up char loop in part II
            MOV #YEMIT_NEXT,T       ;2              T = YEMIT_ret
            MOV #CR_NEXT,S          ;2              S = XOFF_ret
            PUSHM #6,IP             ;8              PUSHM IP,S,T,W,X,Y       r-- ACCEPT_ret XOFF_ret YEMIT_ret BL CR buf_end

;###################################################################################
BACKGRND    CALL &BACKGRND_APP      ;   default BACKGRND_APP = UART_INIT_BACKGRND = UART_RXON, value set by DEEP_RESET.
            BIS &LPM_MODE,SR        ;2  enter in LPM0 mode with GIE=1
; here, FAST FORTH sleeps, awaiting any interrupt.
; IP,S,T,W,X,Y registers (R13 to R8) are free...
; ...and also TOS, PSP and RSP stacks within their rules of use.
            JMP BACKGRND            ;2  return for all interrupts.
;###################################################################################

; ----------------------------------;
UART_RXOFF                          ; Software|hardware flow control to stop RX UART
; ----------------------------------; RXOFF is sent while LF char is received...
    .IFDEF TERMINAL3WIRES           ;   first software flow control
RXOFF_LOOP  BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char
            JZ RXOFF_LOOP           ;2
            MOV #19,&TERM_TXBUF     ;4      move XOFF char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIS.B #RTS,&HANDSHAKOUT ;3  set RTS high
    .ENDIF                          ;
            MOV @RSP+,PC            ;4 to CR_NEXT
; ----------------------------------; RXOFF is sent while LF char is received...

; **********************************;
TERMINAL_INT                        ; <--- TERM RX interrupt vector, delayed by the LPM0 wake up time
; **********************************;      if wake up time increases, max baudrate decreases...
; ACCEPT part II under interrupt    ; Org Ptr -- len'       all SR flags are cleared
; ----------------------------------;
            ADD #4,RSP              ;1  remove SR and PC from stack
            POPM #4,IP              ;6  POPM W=BUF_end, T='CR', S='BL', IP=YEMIT_ret    r-- ACCEPT_ret XOFF_ret
; ----------------------------------;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3  read character into Y, RX_TERM is cleared
; ----------------------------------;
            CMP.B S,Y               ;1      printable char ?
            JC ASTORETEST           ;2      yes
; ----------------------------------;
            CMP.B T,Y               ;1      CR ?
            JZ UART_RXOFF           ;2      yes
; ----------------------------------;
            CMP.B #8,Y              ;1      char = BS ?
            JNZ WAITaKEY            ;2      case of other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ WAITaKEY             ;       yes: do nothing
            SUB #1,TOS              ;       no : dec Ptr
            JMP QYEMIT              ;       don't store BS, return to YEMIT_NEXT
; ----------------------------------;
; end of backspace                  ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JC QYEMIT               ; 2 yes: don't store char @ Ptr, don't increment TOS
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr
            ADD #1,TOS              ; 1     increment Ptr
; ----------------------------------;
QYEMIT      BIT #TX_TERM,&TERM_IFG  ; 3 NOECHO stores here : MOV @IP+,PC, ECHO store here the first word of: BIT #TX_TERM,&TERM_IFG
            JZ QYEMIT               ; 2 but there's no point in wanting to save time here:
        .IFDEF  TERMINAL5WIRES      ; then decrease BAUDRATE !
QYEMIT1     BIT.B #CTS,&HANDSHAKIN  ; 3 CTS is pulled low if unwired.
            JNZ QYEMIT1             ; 2
        .ENDIF                      ;
            MOV.B Y,&TERM_TXBUF     ; 3
            MOV @IP+,PC             ; 4
; ----------------------------------;
YEMIT_NEXT  .word $+2               ; 0 YEMIT NEXT address
            SUB #2,IP               ; 1 restore YEMIT_NEXT
; ----------------------------------;
WAITaKEY    BIT #RX_TERM,&TERM_IFG  ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes, loop = 34~/26~ by char (with/without echo) ==> 294/384 kBds/MHz
            JMP WAITaKEY            ; 2 no
; ----------------------------------;
; return of RXOFF                   ; --- Org Ptr
; ----------------------------------;
CR_NEXT     BIT #RX_TERM,&TERM_IFG  ;               char 'LF' is received ?
            JZ CR_NEXT              ;               no
            MOV.B &TERM_RXBUF,Y     ;               yes, clear RX_IFG flag after LF received
; ----------------------------------;
            SUB @PSP+,TOS           ; -- len'       R-- ACCEPT_NEXT
            MOV @RSP+,IP            ;               R--
ACCEPT_EOL  MOV.B S,Y               ;               output a BL on TERMINAL (for the case of error occuring)
            JMP QYEMIT              ;               before return to QUIT to interpret line
; **********************************;               UF9 to UF11 will be resetted.

;-----------------------------------;
            FORTHWORD "KEY"
;-----------------------------------;
; https://forth-standard.org/standard/core/KEY
; KEY      -- c      wait character from input device ; primary DEFERred word
KEY         MOV @PC+,PC             ;4  Code Field Address (CFA) of KEY
PFAKEY      .word   BODYKEY         ;   Parameter Field Address (PFA) of KEY, with default value
BODYKEY     PUSH #KEYNEXT           ;
; ----------------------------------;
INIT_BACKGRND                       ; default content of BACKGRND_APP called by BACKGRND
; ----------------------------------;
UART_RXON                           ;
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;   first software flow control
            BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char, useless at high baudrates
            JZ UART_RXON            ;2
            MOV #17,&TERM_TXBUF     ;4  move char XON into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIC.B #RTS,&HANDSHAKOUT ;3      set RTS low
    .ENDIF                          ;
            MOV @RSP+,PC            ;4
; ----------------------------------;
KEYNEXT     SUB #2,PSP              ;1  push old TOS..
            MOV TOS,0(PSP)          ;3  ..onto stack
KEYLOOP     BIT #RX_TERM,&TERM_IFG  ; loop if bit0 = 0 in interupt flag register
            JZ KEYLOOP              ;
            CALL #UART_RXOFF        ;
            MOV &TERM_RXBUF,TOS     ;
            MOV @IP+,PC
;-----------------------------------;

;-----------------------------------;
            FORTHWORD "EMIT"        ;       save X before use if used
;-----------------------------------;
; https://forth-standard.org/standard/core/EMIT
; EMIT     c --    output character to the selected output device ; primary DEFERred word
EMIT        MOV @PC+,PC             ;3 Code Field Address (CFA) of EMIT
PFAEMIT     .word   BODYEMIT        ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT    MOV TOS,Y               ;1 output character to the default output: TERMINAL
            MOV @PSP+,TOS           ;2
            JMP QYEMIT              ;2 + 12~
;-----------------------------------;

;-----------------------------------;
            FORTHWORD "ECHO"        ; --    connect ACCEPT and EMIT to TERMINAL input (default)
;-----------------------------------;
ECHO        MOV #0B3A2h,&QYEMIT     ;       MOV #'BIT #TX_TERM,0(PC)',&QYEMIT
            MOV @IP+,PC             ;
;-----------------------------------;

;-----------------------------------;
            FORTHWORD "NOECHO"      ; --    disconnect ACCEPT and EMIT from TERMINAL input
;-----------------------------------;
NOECHO      MOV #4D30h,&QYEMIT      ;       MOV #'MOV @IP+,PC',&QYEMIT
            MOV @IP+,PC             ;
;-----------------------------------;
