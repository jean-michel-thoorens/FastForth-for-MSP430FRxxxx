; -*- coding: utf-8 -*-
;

; ---------------------------------------
; TERMINAL driver for FastForth target
; ---------------------------------------
;                     +---------------------------+
; ------              |    +-----------------+    |
; WIRING              |    |    +--------+   |    |
; ------              |    |    |        |   |    |
; FastForth target   TXD  RXD  RTS <--> CTS TXD  RXD  UARTtoUSB <--> COMx <--> TERMINAL
; -----------------------------------------------------------------------------------------
; MSP_EXP430FR5739   P2.0 P2.1 P2.2                   PL2303TA                 TERATERM.EXE
; MSP_EXP430FR5969   P2.0 P2.1 P4.1                   PL2303HXD
; MSP_EXP430FR5994   P2.0 P2.1 P4.2                   CP2102
; MSP_EXP430FR6989   P3.4 P3.5 P3.0   
; MSP_EXP430FR4133   P1.0 P1.1 P2.3   
; CHIPSTICK_FR2433   P1.4 P1.5 P3.2       
; MSP_EXP430FR2433   P1.4 P1.5 P1.0       
; MSP_EXP430FR2355   P4.3 P4.2 P2.0
; LP_MSP430FR2476    P1.4 P1.5 P6.1
;
;-------------------------------------------------------------------------------
; UART TERMINAL: QABORT ABORT_TERM COLD_TERM INI_TERM RXON RXOFF
;-------------------------------------------------------------------------------
; define run-time part of ABORT"
;Z ?ABORT   xi f c-addr u --      abort & print msg.
;            FORTHWORD "?ABORT"
QABORT      CMP #0,2(PSP)           ; -- f c-addr u         test flag f
            JNZ ABORT_TERM          ;
THREEDROP   ADD #4,PSP              ; -- u
            MOV @PSP+,TOS           ; -- 
            MOV @IP+,PC             ;
; ----------------------------------;
ABORT_TERM                          ; exit from downloading file then reinit some variables via INI_FORTH
; ----------------------------------;
            CALL #RXON              ; PFA resume downloading source file if any
A_UART_LOOP BIC #RX_TERM,&TERM_IFG  ; clear RX_TERM
            MOV &FREQ_KHZ,Y         ; 1000, 2000, 4000, 8000, 16000, 240000
A_USB_LOOPJ MOV #65,X               ; 2~        <-------+ linux with minicom seems very very slow...
A_USB_LOOPI SUB #1,X                ; 1~        <---+   |  ==> ((65*3)+5)*1000 = 200ms delay
            JNZ A_USB_LOOPI         ; 2~ 3~ loop ---+   | to refill its USB buffer
            SUB #1,Y                ; 1~                |
            JNZ A_USB_LOOPJ         ; 2~ 200~ loop -----+
            BIT #RX_TERM,&TERM_IFG  ; 4 new char in TERMRXBUF after A_USB_LOOPJ delay ?
            JNZ A_UART_LOOP         ; 2 yes, the input stream is still active: loop back
            CALL #INI_FORTH         ; common ?ABORT|RST, "hybrid" subroutine with return to FORTH interpreter
; ----------------------------------;
; display line of error if NOECHO   ;
; ----------------------------------;
            .word   lit,LINE,FETCH  ; -- f c-addr u line    fetch line number before set ECHO !
            .word   ECHO            ;
            .word   XSQUOTE         ;
            .byte   4,27,"[7m"      ;                       type ESC[7m    (set reverse video)
            .word   TYPE            ;  
            .word   QDUP,QFBRAN     ;                       don't display line if line = 0 (ECHO was ON)
            .word   ABORT_TYPE      ;
            .word   XSQUOTE         ; -- f c-addr u line c-addr1 u1   displays the line where error occured
            .byte   15,"LAST.4TH, line " ;
            .word   TYPE            ; -- f c-addr u line
            .word   UDOT            ; -- f c-addr u
; ----------------------------------;
; Display ABORT|WARM message        ; <== WARM jumps here
; ----------------------------------;
ABORT_TYPE  .word   TYPE            ; -- f              type abort message
            .word   XSQUOTE         ; -- f c-addr u
            .byte   4,27,"[0m"      ;
            .word   TYPE            ; -- f              set normal video
            .word   ABORT           ; without return
; ----------------------------------;

; ----------------------------------;
COLD_TERM                           ; default STOP_APP: wait TERMINAL idle
; ----------------------------------;
UART_COLD_TERM                      ;
            BIT #1,&TERM_STATW      ;3 uart busy ?
            JNZ COLD_TERM           ;2 loop back while TERM_UART is busy
            MOV @RSP+,PC            ;  return to software_BOR
; ----------------------------------;

; ----------------------------------;
INIT_TERM                           ; TOS = RSTIV_MEM
; ----------------------------------;
UART_INIT_TERM                      ;
    CMP #2,TOS                      ;
    JNC UART_INIT_TERM_END          ; no INIT_TERM if RSTIV_MEM U< 2 (WARM|ABORT)
; ----------------------------------;
    MOV #0081h,&TERM_CTLW0          ; UC SWRST + UCLK = SMCLK
    MOV &TERMBRW_RST,&TERM_BRW      ; init value in FRAM INFO
    MOV &TERMMCTLW_RST,&TERM_MCTLW  ; init value in FRAM INFO
    BIS.B #BUS_TERM,&TERM_SEL       ; Configure pins TERM_UART|TERM_I2C
    BIC #1,&TERM_CTLW0              ; release UC_TERM from reset...
    BIS #WAKE_UP,&TERM_IE           ; then enable interrupt for wake up on terminal input
    BIC #LOCKLPM5,&PM5CTL0          ; activate all previous I/O settings.
UART_INIT_TERM_END
    MOV @RSP+,PC                    ; RET
; ----------------------------------;


; ----------------------------------;
UART_RXON   JMP RXON_EXE            ; Software and/or hardware flow control, to start Terminal UART for one line
; ----------------------------------;

; ----------------------------------;
RXOFF                               ; Software and/or hardware flow control, to stop Terminal UART comunication
; ----------------------------------;
UART_RXOFF                          ;
    .IFDEF TERMINAL3WIRES           ;   first software flow control
RXOFF_LOOP  BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char
            JZ RXOFF_LOOP           ;2
            MOV #19,&TERM_TXBUF     ;4      move XOFF char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIS.B #RTS,&HANDSHAKOUT ;3  set RTS high
    .ENDIF                          ;
            MOV @RSP+,PC            ;4 to CR_NEXT, ...or user defined
; ----------------------------------;

; ----------------------------------;
RXON                                ; default BACKGND_APP 
; ----------------------------------;
RXON_EXE
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


;-------------------------------------------------------------------------------
; UART TERMINAL : WIPE COLD WARM ACCEPT KEY EMIT ECHO NOECHO
;-------------------------------------------------------------------------------

;-----------------------------------;
            FORTHWORD "WIPE"        ; software DEEP_RESET
;-----------------------------------;
WIPE        MOV #-1,&RSTIV_MEM      ; negative value ==> DEEP_RESET
            JMP COLD

;-----------------------------------;
            FORTHWORD "COLD"
;-----------------------------------;
;Z COLD     --      performs a software RESET
; as pin RST is replaced by pin NMI, RESET by pin activation is redirected here via USER NMI vector
; that allows actions to be performed before executing software BOR.
COLD        CALL @PC+               ; COLD first calls STOP_APP, in this instance: CALL #COLD_TERM by default
PFACOLD     .word COLD_TERM         ; INI_COLD_DEF: default value set by WIPE. see forthMSP430FR_TERM_xxxx.asm
            BIT.B #IO_WIPE,&WIPE_IN ; hardware Deep_RESET request (low) ?
            JNZ COLDEXE             ; no
            MOV #-1,&RSTIV_MEM      ; yes, set negative value to force DEEP_RESET
COLDEXE     MOV #0A504h,&PMMCTL0    ; performs software_BOR --> RST_vector --> RESET in forthMSP430FR.asm
; ----------------------------------;

;-----------------------------------;
            FORTHWORD "WARM"        ;
;-----------------------------------;
;Z WARM     xi --                   ; common part of WARM|PUC
;-----------------------------------;
WARM                                ;
;-------------------------------------------------------------------------------
; PUC 7: if RSTIV_MEM <> WARM, init TERM and enable I/O
;-------------------------------------------------------------------------------
            CALL @PC+               ; init TERM, only if TOS U>= 2 (RSTIV_MEM <> WARM)
    .IFNDEF SD_CARD_LOADER          ;
PFAWARM     .word INIT_TERM         ; INI_HARD_APP default value, init TERM UC, unlock I/O's, TOS = RSTIV_MEM
    .ELSE
PFAWARM     .word INI_HARD_SD       ; init SD Card + init TERM, see forthMSP430FR_SD_INIT.asm
    .ENDIF                          ; TOS = RSTIV_MEM
;-----------------------------------;
WARM_DISPLAY                        ; TOS = RSTIV_MEM value
    ASMtoFORTH                      ; display a message then goto QUIT, without return
    .word   XSQUOTE
    .byte   7,13,10,27,"[7m#"       ; CR + cmd "reverse video" + #
    .word   TYPE
    .word   DOT                     ; display TOS = RSTIV_MEM value
    .word   XSQUOTE
    .byte   25,"FastForth ©J.M.Thoorens "
    .word   TYPE
    .word   LIT,FRAM_FULL,HERE,MINUS,UDOT
    .word   XSQUOTE
    .byte   10,"bytes free"
    .word   BRAN,ABORT_TYPE
; ----------------------------------;

;-----------------------------------;
            FORTHWORD "ACCEPT"
;-----------------------------------;
;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  from REFILL, get line at addr to interpret len' chars
ACCEPT      MOV @PC+,PC             ;3 Code Field Address (CFA) of ACCEPT
PFAACCEPT   .word   BODYACCEPT      ;  Parameter Field Address (PFA) of ACCEPT
BODYACCEPT                          ;  BODY of ACCEPT = default execution of ACCEPT
; ----------------------------------;
; ACCEPT part I prepare TERMINAL_INT;               this version allows to RX one char (LF) after sending XOFF 
; ----------------------------------;
            MOV TOS,Y               ;1 -- addr len
            MOV @PSP,TOS            ;2 -- org ptr
            ADD TOS,Y               ;1 -- org ptr   Y = buf_end                                 )
            MOV #0Dh,X              ;2              X = 'CR' to speed up char loop in part II   )
            MOV #20h,W              ;2              W = 'BL' to speed up char loop in part II   >
            MOV #YEMIT_NEXT,T       ;2              T = return for QYEMIT                       )
            MOV #CR_NEXT,S          ;2              S = CR_NEXT                                 )
            PUSHM #6,IP             ;8              PUSHM IP,S,T,W,X,Y       r-- ACCEPT_ret CR_NEXT YEMIT_NEXT BL CR buf_end
            JMP SLEEP               ;2              which calls RXON before falling down to LPMx mode
; ----------------------------------;

; **********************************;
TERMINAL_INT                        ; <--- TEMR RX interrupt vector, delayed by the LPMx wake up time
; **********************************;      if wake up time increases, max bauds rate decreases...
; ACCEPT part II under interrupt    ; Org Ptr -- len'
; ----------------------------------;
            ADD #4,RSP              ;1  remove SR and PC from stack, cleared flags: V SCG1 OSCOFF CPUOFF GIE N Z C
            POPM #4,IP              ;6  POPM W=buffer_bound, T=0Dh, S=20h, IP=YEMIT_NEXT       r-- ACCEPT_ret CR_NEXT 
; ----------------------------------;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3  read character into Y, RX_TERM is cleared
; ----------------------------------;
            CMP.B T,Y               ;1      CR ?
            JZ RXOFF                ;2      then RET to CR_NEXT
            CMP.B S,Y               ;1      printable char ? 
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
            JMP YEMIT               ;       don't store BS
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JZ YEMIT                ; 2 yes: don't store char @ Ptr
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr
            ADD #1,TOS              ; 1     increment Ptr
; ----------------------------------;
YEMIT       BIT #TX_TERM,&TERM_IFG  ; 3 wait the sending end of previous char, useless at high baudrates,
            JZ YEMIT                ; 2 but there's no point in wanting to save time here:
        .IFDEF  TERMINAL5WIRES      ;
YEMIT1      BIT.B #CTS,&HANDSHAKIN  ; 3 CTS is pulled low if unwired.
            JNZ YEMIT1              ; 2
        .ENDIF                      ;
QYEMIT      .word   48C2h           ; 48C2h = MOV.B Y,&<next_adr>
            .word   TERM_TXBUF      ; 3
            MOV @IP+,PC             ; 4
; ----------------------------------;
YEMIT_NEXT  .word $+2               ; 0 YEMII NEXT address
            SUB #2,IP               ; 1 restore YEMIT_NEXT
; ----------------------------------;
WAITaKEY    BIT #RX_TERM,&TERM_IFG  ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes, loop = 34~/31~ by char (with/without echo) ==> 294/322 kBds/MHz
            JMP WAITaKEY            ; 2 no
; ----------------------------------;

; ----------------------------------;
; return of RXOFF                   ; --- Org Ptr   r-- ACCEPT_NEXT 
; ----------------------------------;
CR_NEXT     SUB @PSP+,TOS           ; -- len'
            MOV @RSP+,IP            ;
; ----------------------------------;
            MOV #LPM0+GIE,&LPM_MODE ;               reset LPM_MODE to default mode LPM0 for next line of input stream
; ----------------------------------;
WAITLF      BIT #RX_TERM,&TERM_IFG  ;               char 'LF' is received ?
            JZ WAITLF               ;               no
            MOV.B &TERM_RXBUF,Y     ;               yes, clear RX_int flag after LF received
; ----------------------------------;
ACCEPT_EOL  CMP #0,&LINE            ;               if LINE <> 0 increment LINE             
            JZ ACCEPT_END           ;
            ADD #1,&LINE            ;
ACCEPT_END  
; ----------------------------------;
            MOV S,Y                 ;               output a BL on TERMINAL (for the case of error occuring)
            JMP YEMIT               ;               before return to ABORT to interpret line
; **********************************;               UF9 to UF11 are reset.

;-----------------------------------;
            FORTHWORD "KEY"
;-----------------------------------;
; https://forth-standard.org/standard/core/KEY
; KEY      -- c      wait character from input device ; primary DEFERred word
KEY         MOV @PC+,PC             ;4  Code Field Address (CFA) of KEY
PFAKEY      .word   BODYKEY         ;   Parameter Field Address (PFA) of KEY, with default value
BODYKEY     SUB #2,PSP              ;1  push old TOS..
            MOV TOS,0(PSP)          ;3  ..onto stack
            CALL #RXON
KEYLOOP     BIT #RX_TERM,&TERM_IFG  ; loop if bit0 = 0 in interupt flag register
            JZ KEYLOOP              ;
            MOV &TERM_RXBUF,TOS     ;
            CALL #RXOFF             ;
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
            MOV #0,&LINE            ;
            MOV @IP+,PC

;-----------------------------------;
            FORTHWORD "NOECHO"
;-----------------------------------;
;Z NOECHO   --      disconnect terminal output
NOECHO      MOV #4D30h,&QYEMIT      ;  NEXT = 4D30h = MOV @IP+,PC
            MOV #1,&LINE            ;
            MOV @IP+,PC
