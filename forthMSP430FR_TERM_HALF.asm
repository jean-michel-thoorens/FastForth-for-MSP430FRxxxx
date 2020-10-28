; -*- coding: utf-8 -*-

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
            CALL #INI_FORTH         ; common ?ABORT|RST subroutine
; ----------------------------------;
            .word   lit,LINE,FETCH  ; -- f c-addr u line    fetch line number before set ECHO !
            .word   ECHO            ;
            .word   XSQUOTE         ;
            .byte   4,27,"[7m"      ;                       type ESC[7m    (set reverse video)
            .word   TYPE            ;  
; ----------------------------------;
            .word   QDUP,QFBRAN     ;                                 do nothing if line = 0
            .word   ABORT_TYPE      ;
; ----------------------------------;
; Display error "line:xxx"          ; -- f c-addr u line
; ----------------------------------;
            .word   XSQUOTE         ; -- f c-addr u line c-addr1 u1   displays the line where error occured
            .byte   15,"LAST.4TH, line " ;
            .word   TYPE            ; -- f c-addr u line
            .word   UDOT            ; -- f c-addr u
; ----------------------------------;
; Display ABORT message             ; <== WARM jumps here
; ----------------------------------;
ABORT_TYPE  .word   TYPE            ; -- f              type abort message
            .word   XSQUOTE         ; -- f c-addr u
            .byte   4,27,"[0m"      ;
            .word   TYPE            ; -- f              set normal video
            .word   ABORT           ; no return


; ----------------------------------;
COLD_TERM                           ; default STOP_APP: wait TERMINAL idle
; ----------------------------------;
UART_COLD_TERM
            BIT #1,&TERM_STATW      ;3
            JNZ COLD_TERM           ;2 loop back while TERM_UART is busy
            MOV @RSP+,PC            ;  return to software_BOR
; ----------------------------------;

; ----------------------------------;
INIT_TERM                           ; TOS = RSTIV_MEM
; ----------------------------------;
UART_INIT_TERM                      ;
    CMP #2,TOS                      ;
    JNC UART_INIT_TERM_END          ; no INIT_TERM if RSTIV_MEM U< 2 (WARM)
; ----------------------------------;
    MOV #0081h,&TERM_CTLW0          ; UC SWRST + UCLK = SMCLK
    MOV &TERMBRW_RST,&TERM_BRW      ; init value in FRAM
    MOV &TERMMCTLW_RST,&TERM_MCTLW  ; init value in FRAM
    BIS.B #BUS_TERM,&TERM_SEL       ; Configure pins TERM_UART|TERM_I2C
    BIC #1,&TERM_CTLW0              ; release UC_TERM from reset...
    BIS #WAKE_UP,&TERM_IE           ; then enable interrupt for wake up on terminal input
    BIC #LOCKLPM5,&PM5CTL0          ; activate all previous I/O settings.
UART_INIT_TERM_END
    MOV @RSP+,PC                    ; RET
; ----------------------------------;


; ----------------------------------;
RXON                                ; default BACKGND_APP 
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
            BIS.B #RTS,&HANDSHAKOUT ;3     set RTS high
    .ENDIF                          ;
            MOV @RSP+,PC            ;4 to CR_NEXT, ...or user defined
; ----------------------------------;

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


;===============================================================================
            FORTHWORD "WIPE"        ; software DEEP_RESET
;===============================================================================
            MOV #-1,&RSTIV_MEM      ; negative value ==> DEEP_RESET
            JMP COLD

;===============================================================================
            FORTHWORD "COLD"
;===============================================================================
;Z COLD     --      performs a software RESET
; as pin RST is replaced by pin NMI, RESET by pin activation is redirected here via USER NMI vector
; that allows actions to be performed before executing software BOR.
COLD        CALL @PC+               ; COLD first calls STOP_APP, in this instance: CALL #COLD_TERM by default
PFACOLD     .word COLD_TERM         ; INI_COLD_DEF: default value set by WIPE. see forthMSP430FR_TERM_xxxx.asm
            BIT.B #IO_WIPE,&WIPE_IN ; hardware Deep_RESET request (low) ?
            JNZ COLDEXE             ; no
            MOV #-1,&RSTIV_MEM      ; yes, set negative value to force DEEP_RESET
COLDEXE     MOV #0A504h,&PMMCTL0    ; performs software_BOR, see RESET in forthMSP430FR.asm
; ----------------------------------;

;===============================================================================
            FORTHWORD "WARM"
;===============================================================================
;Z WARM     xi --                   ; the next of RESET
WARM                                ;
;-------------------------------------------------------------------------------
; RESET 6.2: if RSTIV_MEM <> WARM, init TERM and enable I/O
;-------------------------------------------------------------------------------
            CALL @PC+               ; init TERM, only if TOS U>= 2 (RSTIV_MEM <> WARM)
    .IFNDEF SD_CARD_LOADER          ;
PFAWARM     .word INIT_TERM         ; default value, init TERM UC, unlock I/O's, TOS = RSTIV_MEM
    .ELSE
PFAWARM     .word INIT_SD           ; init TERM first then init SD Card
    .ENDIF
;-------------------------------------------------------------------------------
; END OF RESET
;-------------------------------------------------------------------------------
    ASMtoFORTH
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
    .word   BRAN,ABORT_TYPE         ; without return

;-------------------------------------------------------------------------------
; INTERPRETER INPUT
;-------------------------------------------------------------------------------
            FORTHWORD "ACCEPT"
;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get line at addr to interpret len' chars
ACCEPT      MOV @PC+,PC             ;3 Code Field Address (CFA) of ACCEPT
PFAACCEPT   .word   BODYACCEPT      ;  Parameter Field Address (PFA) of ACCEPT
BODYACCEPT                          ;  BODY of ACCEPT = default execution of ACCEPT
; ----------------------------------;
; ACCEPT part I prepare TERMINAL_INT;
; ----------------------------------;
            MOV TOS,X               ;1 -- addr len
            MOV @PSP,TOS            ;2 -- org ptr
            ADD TOS,X               ;1 -- org ptr   X = buf_end
            MOV #0Dh,W              ;2              W = 'CR' to speed up char loop in part II
            MOV #20h,T              ;2              T = 'BL' to speed up char loop in part II
            MOV IP,S                ;               S = ACCEPT_ret
            MOV #CR_NEXT,IP         ;2             IP = XOFF_ret
            PUSHM #5,IP             ;5              PUSHM IP,S,T,W,X       r-- XOFF_ret ACCEPT_ret BL CR buf_end
            JMP SLEEP               ;2              which calls RXON before falling down to LPMx mode
; ----------------------------------;

; **********************************;
TERMINAL_INT                        ; <--- TEMR RX interrupt vector, delayed by the LPMx wake up time
; **********************************;      if wake up time increases, max bauds rate decreases...
; (ACCEPT) part II under interrupt  ; Org Ptr -- len'
; ----------------------------------;
            ADD #4,RSP              ;1  remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            POPM #4,IP              ;6  POPM W=buffer_bound, T=0Dh, S=20h, IP=ACCEPT_RET r-- XOFF_ret 
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts the 2th stopwatch          ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3  read character into Y, RX_TERM is cleared
; ----------------------------------;
            CMP.B T,Y               ;1      CR ?
            JZ RXOFF                ;2      then RET to CR_NEXT
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;+ 12   to send RXOFF
; stops the first stopwatch         ;=      first bottleneck, best case result: 25~ + LPMx wake_up time..
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
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
            JMP WAITaKEY            ;       don't store BS
; ----------------------------------;
; end of backspace                  ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JZ YEMIT                ; 2 yes: send echo then loopback
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr, send echo then loopback
            ADD #1,TOS              ; 1     increment Ptr
; ----------------------------------;
WAITaKEY    BIT #RX_TERM,&TERM_IFG  ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 2th stopwatch           ; best case result: 26~/22~ (with/without echo) ==> 385/455 kBds/MHz
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
            JZ WAITaKEY             ; 2 no
; ----------------------------------;

; ----------------------------------;
; return of RXOFF
; ----------------------------------;
CR_NEXT     SUB @PSP+,TOS           ; -- len'
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
            JMP YEMIT               ;               before interpret line
; **********************************;

; ------------------------------------------------------------------------------
; TERMINAL I/O, input part
; ------------------------------------------------------------------------------
            FORTHWORD "KEY"
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

; ------------------------------------------------------------------------------
; TERMINAL I/O, output part
; ------------------------------------------------------------------------------
            FORTHWORD "EMIT"
; https://forth-standard.org/standard/core/EMIT
; EMIT     c --    output character to the selected output device ; primary DEFERred word
EMIT        MOV @PC+,PC             ;4 Code Field Address (CFA) of EMIT
PFAEMIT     .word   BODYEMIT        ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT    MOV TOS,Y               ;1 output character to the default output: TERMINAL
            MOV @PSP+,TOS           ;2
YEMIT      BIT #TX_TERM,&TERM_IFG   ; 3 wait the sending end of previous char, useless at high baudrates
            JZ YEMIT                ; 2
        .IFDEF TERMINAL5WIRES       ;
YEMIT1      BIT.B #CTS,&HANDSHAKIN  ;
            JNZ YEMIT1
        .ENDIF
QYEMIT      .word   48C2h           ;3 48C2h = MOV.B Y,&<next_adr>
            .word   TERM_TXBUF      ; 3 MOV Y,&TERMTXBUF
            MOV @IP+,PC             ;

            FORTHWORD "ECHO"
;Z ECHO     --      connect terminal output (default)
ECHO        MOV #48C2h,&QYEMIT      ; 48C2h = MOV.B Y,&<next_adr>
            MOV #0,&LINE            ;
            MOV @IP+,PC

            FORTHWORD "NOECHO"
;Z NOECHO   --      disconnect terminal output
NOECHO      MOV #NEXT,&QYEMIT       ;  NEXT = 4030h = MOV @IP+,PC
            MOV #1,&LINE            ;
            MOV @IP+,PC
