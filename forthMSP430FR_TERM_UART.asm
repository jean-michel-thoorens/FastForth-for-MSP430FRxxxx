; -*- coding: utf-8 -*-

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices with UART TERMINAL
; Copyright (C) <2019>  <J.M. THOORENS>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; ----------------------------------;
; ACCEPT part I prepare TERMINAL_INT;
; ----------------------------------;
            MOV TOS,Y               ;1 -- addr len
            MOV @PSP,TOS            ;2 -- org ptr
            ADD TOS,Y               ;1 -- org ptr   Y = buf_end
            MOV #0Dh,X              ;2              X = 'CR' to speed up char loop in part II
            MOV #20h,W              ;2              W = 'BL' to speed up char loop in part II
            MOV #AYEMIT_RET,T       ;2              T = return for YEMIT
            MOV #ENDACCEPT,S        ;2              S = XOFF_ret
            PUSHM #6,IP             ;5              PUSHM IP,S,T,W,X,Y       r-- ACCEPT_ret XOFF_ret yemit_ret BL CR buf_end
            JMP SLEEP               ;2              which calls RXON before falling down to LPMx mode
; ----------------------------------;

; **********************************;
TERMINAL_INT                        ; <--- TEMR RX interrupt vector, delayed by the LPMx wake up time
; **********************************;      if wake up time increases, max bauds rate decreases...
; (ACCEPT) part II under interrupt  ; Org Ptr -- len'
; ----------------------------------;
            ADD #4,RSP              ;1  remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            POPM #4,IP              ;6  POPM W=buffer_bound, T=0Dh, S=20h, IP=AYEMIT_RET       r-- ACCEPT_ret XOFF_ret 
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts the 2th stopwatch          ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3  read character into Y, RX_TERM is cleared
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 3th stopwatch           ; 3th bottleneck result : 17~ + LPMx wake_up time ( + 5~ XON loop if F/Bds<230400 )
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD1   CMP.B S,Y               ;1      printable char ?
            JC ASTORETEST           ;2      yes
            CMP.B T,Y               ;1      CR ?
            JZ RXOFF                ;2      then RET to ENDACCEPT
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;+ 4    to send RXOFF
; stops the first stopwatch         ;=      first bottleneck, best case result: 27~ + LPMx wake_up time..
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;       ...or 14~ in case of empty line
            CMP.B #8,Y              ;1      char = BS ?
            JNE WAITaKEY            ;2      case of other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ WAITaKEY             ;       yes: do nothing
            SUB #1,TOS              ;       no : dec Ptr
            JMP ASTOREEND           ;       don't store BS
; ----------------------------------;
; end of backspace                  ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JZ YEMIT1               ; 2 yes: send echo then loopback
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr, send echo then loopback
            ADD #1,TOS              ; 1     increment Ptr
ASTOREEND
; ----------------------------------;
    .IFNDEF HALFDUPLEX
YEMIT1      BIT #TX_TERM,&TERM_IFG  ; 3 wait the sending end of previous char, useless at high baudrates
            JZ YEMIT1               ; 2 but there's no point in wanting to save time here:
        .IFDEF  TERMINAL5WIRES      ;
YEMIT2      BIT.B #CTS,&HANDSHAKIN  ; 3
            JNZ YEMIT2              ; 2
        .ENDIF                      ;
YEMIT       .word   4882h           ; 4882h = MOV Y,&<next_adr>
            .word   TERM_TXBUF      ; 3
            MOV @IP+,PC             ; 4
; ----------------------------------;
AYEMIT_RET  .word $+2               ; 0     YEMII NEXT address
            SUB #2,IP               ; 1 restore AYEMIT_RET
; ----------------------------------;
    .ELSE
AYEMIT_RET
    .ENDIF ; HALDUPLEX
WAITaKEY    BIT #RX_TERM,&TERM_IFG  ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes
            JZ WAITaKEY             ; 2 no
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 2th stopwatch           ; best case result: 26~/22~ (with/without echo) ==> 385/455 kBds/MHz
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;

; ----------------------------------;
; return of RXOFF
; ----------------------------------;
ENDACCEPT   CMP #0,&LINE            ; --- Org Ptr   r-- ACCEPT_ret              
            JZ ENDACCEPT1           ;
            ADD #1,&LINE            ;               if LINE <> 0 increment LINE
ENDACCEPT1  SUB @PSP+,TOS           ; -- len'
            MOV @RSP+,IP            ; 2             return to INTERPRET with GIE=0: FORTH is protected against any interrupt...
; ----------------------------------;
            MOV #LPM0+GIE,&LPM_MODE ;               reset LPM_MODE to default mode LPM0 for next line of input stream
; ----------------------------------;
WAITLF      BIT #1,&TERM_IFG        ;
            JZ WAITLF               ;
            MOV.B &TERM_RXBUF,Y     ;               to clear RX_int flag after LF received
; ----------------------------------;
            MOV @IP+,PC             ; -- org len
; **********************************; 61 words

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

; ----------------------------------; to avoid any lock out, watchdog RST is configured first.
COLD        MOV #5A4Fh,&WDTCTL      ; start Watchdog Reset : XDTPW, WDTSSEL=VLOCLK, WDTCNTCL=1, WDTIS=2^6 (8ms)
; ----------------------------------;
COLD_TERM   BIT #1,&TERM_STATW      ;3 to stop correctly TX to TERMINAL in progress
            JNZ COLD_TERM           ;2 loop back while TERM_UART is busy
            MOV #0A504h,&PMMCTL0    ; performs BOR
; ----------------------------------;

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
    .IFNDEF HALFDUPLEX
            JMP YEMIT1              ;2 + 12~
    .ELSE
YEMIT1      BIT #TX_TERM,&TERM_IFG  ; 3 wait the sending end of previous char, useless at high baudrates
            JZ YEMIT1               ; 2
        .IFDEF TERMINAL5WIRES       ;
YEMIT2      BIT.B #CTS,&HANDSHAKIN  ;
            JNZ YEMIT2
        .ENDIF
YEMIT       .word   4882h           ; hi7/4~ lo:12/4~ send/send_not  echo to terminal
            .word   TERM_TXBUF      ; 3 MOV Y,&TERMTXBUF
            MOV @IP+,PC             ;
    .ENDIF

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
