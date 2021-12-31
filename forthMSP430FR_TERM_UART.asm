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
; UART TERMINAL: QABORT INIT_TERM COLD_TERM
;-------------------------------------------------------------------------------

; this define run-time part of ABORT"    if f is true display msg. then abort current process
QABORT      CMP #0,2(PSP)           ; -- f addr cnt         test flag f
            JNZ ABORT_TERM          ;               see forthMSP430FR_TERM_xxxx.asm below
THREEDROP   ADD #4,PSP              ; -- cnt
            JMP DROP                ;
; ----------------------------------;
UART_ABORT_TERM                     ; exit from downloading, execute INIT_FORTH then display message if any
; ----------------------------------;
ABORT_TERM  CALL #RXON              ; resume downloading source file if any
A_UART_LOOP BIC #RX_TERM,&TERM_IFG  ; clear RX_TERM
            MOV &FREQ_KHZ,Y         ; 1000, 2000, 4000, 8000, 16000, 24000
A_USB_LOOPJ MOV #65,X               ; 2~           <----+ linux with minicom seems very very slow...
A_USB_LOOPI SUB #1,X                ; 1~         <--+   | to refill its USB buffer
            JNZ A_USB_LOOPI         ; 2~ 3~ loop ---+   |
            SUB #1,Y                ; 1~                |
            JNZ A_USB_LOOPJ         ; 2~ 200~ loop -----+  ((65*3)+5)*1000 = 200ms delay
            BIT #RX_TERM,&TERM_IFG  ; 4 new char in TERMRXBUF after 200ms delay ?
            JNZ A_UART_LOOP         ; 2 yes, the input stream is still active: loop back
            CALL #INIT_FORTH        ;                   common ?ABORT|PUC subroutine
                                    ;                   TOS = cnt (byte), always positive. No RST_RET if cnt = 0.
            .word   DUP             ; -- f addr cnt cnt
            .word   QFBRAN,ABORT_END; -- f addr 0       don't force ECHO if ABORT" is an empty string
            .word   ECHO            ; -- f addr cnt     force ECHO
            .word   XSQUOTE         ;
            .byte   4,27,"[7m"      ;
            .word   TYPE            ;                   ESC [7m = set reverse video
; ----------------------------------;
; Display QABORT|WARM message       ; <== WARM jumps here
; ----------------------------------;
ABORT_TYPE  .word   TYPE            ; -- f              type QABORT|WARM message
            .word   XSQUOTE         ;
            .byte   4,27,"[0m"      ;
            .word   TYPE            ;                   ESC [0m = set normal video
ABORT_END   .word   ABORT           ; -- f              no return
; ----------------------------------;

;-------------------------------------------------------------------------------
; INIT TERMinal then enable I/O
;-------------------------------------------------------------------------------

; ----------------------------------;
UART_INIT_TERM                      ;
; ----------------------------------;
INIT_TERM
    CALL #WAIT_UART_IDLE            ; wait while TERM_UART is busy
    MOV #0081h,&TERM_CTLW0          ; 8 bits, UC SWRST + UCLK = SMCLK, max 6MBds
;    MOV #1081h,&TERM_CTLW0          ; 7 bits, UC SWRST + UCLK = SMCLK, max 4MBds
    MOV &TERMBRW_RST,&TERM_BRW      ; init value in FRAM INFO
    MOV &TERMMCTLW_RST,&TERM_MCTLW  ; init value in FRAM INFO
    BIS.B #BUS_TERM,&TERM_SEL       ; Configure pins TERM_UART|TERM_I2C
    BIC #1,&TERM_CTLW0              ; release UC_TERM from reset...
    BIS #WAKE_UP,&TERM_IE           ; then enable interrupt for wake up on terminal input
    BIC #LOCKLPM5,&PM5CTL0          ; activate all previous I/O settings.
    MOV @RSP+,PC                    ; RET
; ----------------------------------;

; ----------------------------------;
UART_COLD_TERM                      ; default STOP_APP: wait TERMINAL idle
; ----------------------------------;
WAIT_UART_IDLE
COLD_TERM   BIT #1,&TERM_STATW      ;3 uart busy ?
            JNZ COLD_TERM           ;2 loop back while TERM_UART is busy
; ----------------------------------;
UART_INIT_SOFT                      ;
; ----------------------------------;
INIT_SOFT_TERM
            MOV @RSP+,PC            ; does nothing
; ----------------------------------;

;-------------------------------------------------------------------------------
; UART TERMINAL : WARM SYS COLD RESET
;-------------------------------------------------------------------------------

;-----------------------------------;
;           FORTHWORD "WARM"        ; (n) --
;-----------------------------------; thanks to INIT_FORTH, WARM implements the choice
UART_WARM                           ; made by the user with SYS|hardwareRST|DEEP_reset
;-----------------------------------; regarding the state of the software.
WARM        CALL &HARD_APP          ;
            mASM2FORTH              ;
    .word   ECHO                    ;
    .word   XSQUOTE
    .byte   7,13,10,27,"[7m#"       ; CR + cmd "reverse video" + #
    .word   TYPE
    .word   DOT                     ; display TOS = USERSYS value
    .word   XSQUOTE
    .byte   25,"FastForth ",169,"J.M.Thoorens, "
    .word   TYPE
    .word   LIT,FRAM_FULL
    .word   HEREXEC,MINUS,UDOT
    .word   XSQUOTE
    .byte   10,"bytes free"
    .word   BRAN,ABORT_TYPE         ; without return
;-----------------------------------;

;-----------------------------------;
            FORTHWORD "SYS"         ; n --      software RST, DEEP_RST, COLD, WARM
;-----------------------------------;
            CMP #0,TOS              ;
            JL SYSEND               ; if -n SYS  ==> COLD + DEEP_RESET
            JZ NOPUC                ; if [0] SYS ==> INIT_FORTH --> WARM -->  WARM display
            BIT #1,TOS              ;
            JNC SYSEND              ; if +n SYS (+n even)
NOPUC       PUSH #WARM              ;
            PUSH RSP                ; Push address of WARM address
            JMP INIT_FORTH          ; if +n SYS (+n odd)  ==> INIT_FORTH --> WARM -->  WARM display
SYSEND      MOV TOS,&USERSYS        ; ==> COLD --> PUC --> INIT_FORTH --> WARM -->  WARM display
;===============================================================================
COLD        ; <--- USER_NMI vector <--- <RESET> and <RESET> + <SW1> (DEEP_RESET)
;===============================================================================
; as pin RST is replaced by pin NMI, RESET by pin activation is redirected here via USER NMI vector
; that allows actions to be performed before executing software BOR.
            CALL &COLD_APP          ; to stop APPlication before reset
            BIT.B #SW1,&SW1_IN      ; <SW1> pressed ?
            JNZ COLDEXE             ; no
            MOV #-1,&USERSYS        ; yes, set negative value to force DEEP_RESET
COLDEXE     MOV #0A504h,&PMMCTL0    ; performs software_BOR ------------------------+
;===============================================================================    |
RESET                               ; <-- RST vect. <-- SYS_failures PUC POR BOR <--+
;===============================================================================
; PUC 1: replace pin RESET by pin NMI, stops WDT_RESET
;-------------------------------------------------------------------------------
            BIS #3,&SFRRPCR         ; pin NMI with falling edge replaces pin RST, so SYSRSTIV = 4
            BIS #10h,&SFRIE1        ; enable NMI pin interrupt ==> hardware RESET is redirected to COLD.
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
            MOV #RAM_LEN,X          ; 2 RAM_LEN must be even and > 1, obviously.
INITRAMLOOP SUB #2,X                ; 1
            MOV #0,RAM_ORG(X)       ; 3
            JNZ INITRAMLOOP         ; 2 6 cycles loop !
;-------------------------------------------------------------------------------
; PUC 5: GET SYSRSTIV and SYS_USER
;-------------------------------------------------------------------------------
            MOV &SYSRSTIV,X         ; X <-- SYSRSTIV <-- 0
            MOV &USERSYS,TOS        ; TOS = USERSYS
            MOV #0,&USERSYS         ; clear USERSYS
            AND #-1,TOS             ;
            JNZ PUC6                ; if TOS <> 0, keep USERSYS value
            MOV X,TOS               ; TOS <-- SYSRSTIV
;-------------------------------------------------------------------------------
; PUC 6: START FORTH engine
;-------------------------------------------------------------------------------
PUC6        CALL #INIT_FORTH        ; common part of QABORT|PUC
PUCNEXT     .WORD WARM              ; no return. May be redirected by BOOT.
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
            MOV #YEMIT_NEXT,T       ;2              T = return for QYEMIT
            MOV #CR_NEXT,S          ;2              S = CR_NEXT
            PUSHM #6,IP             ;8              PUSHM IP,S,T,W,X,Y       r-- ACCEPT_ret CR_NEXT YEMIT_NEXT BL CR buf_end
            JMP SLEEP               ;2              send RXON then shut down to LPM0 sleeping mode
; ----------------------------------;

; **********************************;
TERMINAL_INT                        ; <--- TERM RX buffer full interrupt vector, delayed by the LPM0 wake up time
; **********************************;      if wake up time increases, max bauds rate decreases...
; ACCEPT part II under interrupt    ; Org Ptr -- len'       all SR flags are cleared
; ----------------------------------;
            ADD #4,RSP              ;1  remove SR and PC from stack
            POPM #4,IP              ;6  POPM W=buffer_bound, T=0Dh, S=20h, IP=YEMIT_NEXT    r-- ACCEPT_ret CR_NEXT
; ----------------------------------;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3  read character into Y, RX_TERM is cleared
; ----------------------------------;
            CMP.B T,Y               ;1      CR ?
            JNZ AKEYRDNNEXT         ;2      no
; ----------------------------------;
RXOFF                               ; Software|hardware flow control to stop RX UART    r-- ACCEPT_ret CR_NEXT
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;   first software flow control
RXOFF_LOOP  BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char
            JZ RXOFF_LOOP           ;2
            MOV #19,&TERM_TXBUF     ;4      move XOFF char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIS.B #RTS,&HANDSHAKOUT ;3  set RTS high
    .ENDIF                          ;
            MOV @RSP+,PC            ;4 to CR_NEXT
; ----------------------------------;
AKEYRDNNEXT CMP.B S,Y               ;1      printable char ?
            JC ASTORETEST           ;2      yes
; ----------------------------------;
            CMP.B #8,Y              ;1      char = BS ?
            JNE WAITaKEY            ;2      case of other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ WAITaKEY             ;       yes: do nothing
            SUB #1,TOS              ;       no : dec Ptr
            JMP YEMIT               ;       don't store BS, return to YEMIT_NEXT
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JC YEMIT                ; 2 yes: don't store char @ Ptr, don't increment TOS
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr
            ADD #1,TOS              ; 1     increment Ptr
; ----------------------------------;
YEMIT       BIT #TX_TERM,&TERM_IFG  ; 3 wait the sending end of previous char, useless at high baudrates,
            JZ YEMIT                ; 2 but there's no point in wanting to save time here:
        .IFDEF  TERMINAL5WIRES      ;
YEMIT1      BIT.B #CTS,&HANDSHAKIN  ; 3 CTS is pulled low if unwired.
            JNZ YEMIT1              ; 2
        .ENDIF                      ;
QYEMIT      MOV.B Y,&TERM_TXBUF     ; 3 may be replaced by MOV @IP+,PC with NOECHO
            MOV @IP+,PC             ; 4
; ----------------------------------;
YEMIT_NEXT  .word $+2               ; 0 YEMII NEXT address
            SUB #2,IP               ; 1 restore YEMIT_NEXT
; ----------------------------------;
WAITaKEY    BIT #RX_TERM,&TERM_IFG  ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes, loop = 34~/31~ by char (with/without echo) ==> 294/322 kBds/MHz
            JMP WAITaKEY            ; 2 no
; ----------------------------------;
; return of RXOFF                   ; --- Org Ptr   R-- ACCEPT_NEXT
; ----------------------------------;
CR_NEXT     SUB @PSP+,TOS           ; -- len'
            MOV @RSP+,IP            ;               R--
WAITLF      BIT #RX_TERM,&TERM_IFG  ;               char 'LF' is received ?
            JZ WAITLF               ;               no
            MOV.B &TERM_RXBUF,Y     ;               yes, clear RX_IFG flag after LF received
; ----------------------------------;
ACCEPT_EOL  MOV S,Y                 ;               output a BL on TERMINAL (for the case of error occuring)
            JMP YEMIT               ;               before return to QUIT to interpret line
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
RXON                                ; default BACKGND_APP
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;   first software flow control
RXON_LOOP   BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char, useless at high baudrates
            JZ RXON_LOOP            ;2
            MOV #17,&TERM_TXBUF     ;4  move char XON into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIC.B #RTS,&HANDSHAKOUT ;3      set RTS low
    .ENDIF                          ;
            MOV @RSP+,PC            ;4  to BACKGND (End of file download or quiet input) or AKEYREAD...
; ----------------------------------;   ... (get next line of file downloading), or user defined
KEYNEXT     SUB #2,PSP              ;1  push old TOS..
            MOV TOS,0(PSP)          ;3  ..onto stack
KEYLOOP     BIT #RX_TERM,&TERM_IFG  ; loop if bit0 = 0 in interupt flag register
            JZ KEYLOOP              ;
            CALL #RXOFF             ;
            MOV &TERM_RXBUF,TOS     ;
            MOV @IP+,PC

;-----------------------------------;
            FORTHWORD "EMIT"
;-----------------------------------;
; https://forth-standard.org/standard/core/EMIT
; EMIT     c --    output character to the selected output device ; primary DEFERred word
EMIT        MOV @PC+,PC             ;4 Code Field Address (CFA) of EMIT
PFAEMIT     .word   BODYEMIT        ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT    MOV TOS,Y               ;1 output character to the default output: TERMINAL
            MOV @PSP+,TOS           ;2
            JMP YEMIT               ;2 + 12~

;-----------------------------------;
            FORTHWORD "ECHO"
;-----------------------------------;
;Z ECHO     --      connect terminal output (default)
ECHO        MOV #48C2h,&QYEMIT      ; 48C2h = MOV.B Y,&<next_adr>
            MOV @IP+,PC

;-----------------------------------;
            FORTHWORD "NOECHO"
;-----------------------------------;
;Z NOECHO   --      disconnect terminal output
NOECHO      MOV #4D30h,&QYEMIT      ;  NEXT = 4D30h = MOV @IP+,PC
            MOV @IP+,PC

