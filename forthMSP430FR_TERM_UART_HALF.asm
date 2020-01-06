; con speed of TERMINAL link, there are three bottlenecks :
; 1- time to send XOFF/RTS_high on CR (CR+LF=EOL), first emergency.
; 2- the char loop time,
; 3- the time between sending XON/RTS_low and clearing RX_TERM on first received char,
; everything must be done to reduce these times, taking into account the necessity of switching to SLEEP (LPMx mode).

; ----------------------------------;
; (ACCEPT) part I: prepare TERMINAL_INT ;
; ----------------------------------;
            MOV #ENDACCEPT,S        ;2              S = ACCEPT XOFF return
            MOV #AKEYREAD1,T        ;2              T = default XON return
            PUSHM #3,IP             ;5              PUSHM IP,S,T, as IP ret, XOFF ret, XON ret
            MOV TOS,W               ;1 -- addr len
            MOV @PSP,TOS            ;2 -- org ptr                                             )
            ADD TOS,W               ;1 -- org ptr   W=Bound                                   )
            MOV #0Dh,T              ;2              T = 'CR' to speed up char loop in part II  > prepare stack and registers
            MOV #20h,S              ;2              S = 'BL' to speed up char loop in part II )  for TERMINAL_INT use
            BIT #RX_TERM,&TERM_IFG  ;3              RX_Int ?
            JZ ACCEPTNEXT           ;2              no : case of quiet input terminal
            MOV &TERM_RXBUF,Y       ;3              yes: clear RX_Int
            CMP #0Ah,Y              ;2                   received char = LF ? (end of downloading ?)
            JNZ RXON                ;2                   no : RXON return = AKEYREAD1, to process first char of new line.
ACCEPTNEXT  ADD #2,RSP              ;1                   yes: remove AKEYREAD1 as XON return,
            PUSHM  #3,S             ;6                        PUSHM S,T,W before SLEEP (and so WAKE on any interrupts)
            JMP SLEEP               ;2
; ----------------------------------;



; ----------------------------------;
RXON                                ; Software and/or hardware flow control, to start Terminal UART communication
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;   first software flow control
RXON_LOOP   BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char, useless at high baudrates
            JZ RXON_LOOP            ;2
            MOV #17,&TERM_TXBUF     ;4  move char XON into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIC.B #RTS,&HANDSHAKOUT ;3      set RTS low
    .ENDIF                          ;
            MOV @RSP+,PC            ;4  to BACKGND (End of file download or quiet input) or AKEYREAD1...
; ----------------------------------;   ... (get next line of file downloading), or user defined

COLD_TERM
; here we can add a preamble to BOR, executed by COLD, also by <RST> button
TERM_BUSY   BIT #1,&TERM_STATW      ;3
            JNZ TERM_BUSY           ;2 loop back while TERM_UART is busy
            MOV @RSP+,PC            ;

; ----------------------------------;
RXOFF                               ; Software and/or hardware flow control, to stop Terminal UART comunication
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;   first software flow control
RXOFF_LOOP  BIT #TX_TERM,&TERM_IFG  ;3      wait the sending of last char
            JZ RXOFF_LOOP           ;2
            MOV #19,&TERM_TXBUF     ;4      move XOFF char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;   and hardware flow control after
            BIS.B #RTS,&HANDSHAKOUT ;3     set RTS high
    .ENDIF                          ;
            MOV @RSP+,PC            ;4 to ENDACCEPT, ...or user defined
; ----------------------------------;


; **********************************;
TERMINAL_INT                        ; <--- TEMR RX interrupt vector, delayed by the LPMx wake up time
; **********************************;      if wake up time increases, max bauds rate decreases...
; (ACCEPT) part II under interrupt  ; Org Ptr -- len'
; ----------------------------------;
             POPM #5,S              ;8  POPM  Y=SR,X=PC,W=buffer_bound, T=0Dh,S=20h
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts the 2th stopwatch          ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3  read character into Y, RX_TERM is cleared
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 3th stopwatch           ; 3th bottleneck result : 17~ + LPMx wake_up time ( + 5~ XON loop if F/Bds<230401 )
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD1                           ; <---  XON RET address 2 ; first emergency: anticipate XOFF on CR as soon as possible
            CMP.B T,Y               ;1      char = CR ?
            JZ RXOFF                ;2      then RET to ENDACCEPT
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;+ 4    to send RXOFF
; stops the first stopwatch         ;=      first bottleneck (empty line process), best case result: 20~ + LPMx wake_up time..
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;       ...or 11~ in case of empty line
            CMP.B S,Y               ;1      printable char ?
            JC  ASTORETEST          ;2      yes
            CMP.B #8,Y              ;       char = BS ?
            JNE WAITaKEY            ;       case of other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ WAITaKEY             ;       yes: do nothing else
            SUB #1,TOS              ;       no : dec Ptr
            JMP WAITaKEY
; ----------------------------------;
; end of backspace                  ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JZ WAITaKEY             ; 2 yes: loopback
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr, send echo then loopback
            ADD #1,TOS              ; 1     increment Ptr
; ----------------------------------;
WAITaKEY    BIT #RX_TERM,&TERM_IFG  ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes
            JZ WAITaKEY             ; 2 no
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 2th stopwatch           ; best case result: 23~ ==> 434 kBds/MHz
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;

; ----------------------------------;
ENDACCEPT                           ; --- Org Ptr       r-- ACCEPT_ret
; ----------------------------------;
            CMP #0,&LINE            ; if LINE <> 0...
            JZ ACCEPTEND            ;
            ADD #1,&LINE            ; ...increment LINE
ACCEPTEND   SUB @PSP+,TOS           ; -- len'
            MOV @RSP+,IP            ; 2  return to INTERPRET with GIE=0: FORTH is protected against any interrupt...
; ----------------------------------;
            MOV #LPM0+GIE,&LPM_MODE ; reset LPM_MODE to default mode LPM0 for next line of input stream
; ----------------------------------;
            MOV @IP+,PC             ; ...until next falling down to LPMx mode of (ACCEPT) part1,
; **********************************;    i.e. when the FORTH interpreter has no more to do.

; ------------------------------------------------------------------------------
; TERMINAL I/O, input part
; ------------------------------------------------------------------------------

            FORTHWORD "KEY"
; https://forth-standard.org/standard/core/KEY
; KEY      -- c      wait character from input device ; primary DEFERred word
KEY         MOV @PC+,PC             ;4  Code Field Address (CFA) of KEY
PFAKEY      .word   BODYKEY         ;   Parameter Field Address (PFA) of KEY, with default value
BODYKEY     MOV &TERM_RXBUF,Y       ;3  empty buffer
            SUB #2,PSP              ;1  push old TOS..
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

;https://forth-standard.org/standard/core/EMIT
;C EMIT     c --    output character to the output device ; deferred word
            FORTHWORD "EMIT"        ; HalfDuplexEMIT
EMIT        MOV @PC+,PC             ;3  15~
PFAEMIT     .word   BODYEMIT        ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT    MOV TOS,Y               ; 1
            MOV @PSP+,TOS           ; 2
YEMIT1      BIT #TX_TERM,&TERM_IFG  ; 3 wait the sending end of previous char, useless at high baudrates
            JZ YEMIT1               ; 2
    .IFDEF TERMINAL5WIRES           ;
YEMIT2      BIT.B #CTS,&HANDSHAKIN  ;
            JNZ YEMIT2
    .ENDIF
YEMIT       .word   4882h           ; hi7/4~ lo:12/4~ send/send_not  echo to terminal
            .word   TERM_TXBUF      ; 3 MOV Y,&TERMTXBUF
            MOV @IP+,PC             ;

            FORTHWORD "ECHO"
;Z ECHO     --      connect terminal output (default)
ECHO        MOV #4882h,&YEMIT       ; 4882h = MOV Y,&<next_adr>
            MOV #0,&LINE            ;
            MOV @IP+,PC

            FORTHWORD "NOECHO"
;Z NOECHO   --      disconnect terminal output
NOECHO      MOV #NEXT,&YEMIT        ;  NEXT = 4030h = MOV @IP+,PC
            MOV #1,&LINE            ;
            MOV @IP+,PC

