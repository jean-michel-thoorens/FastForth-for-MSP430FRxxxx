; -*- coding: utf-8 -*-

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices with I2C TERMINAL
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
            MOV TOS,W               ;1 -- org len   W=len
            MOV @PSP,TOS            ;2 -- org ptr                                               )
            ADD TOS,W               ;1 -- org ptr   W=buf_end                                   )
            MOV #0Ah,T              ;2              T = 'LF' to speed up char loop in part II   > prepare stack and registers for TERMINAL_INT use
            MOV #20h,S              ;2              S = 'BL' to speed up char loop in part II   ) 
            PUSHM #4,IP             ;6              PUSH IP,S,T,W  r-- IP, 'BL', 'LF', buf_end  )
;            BIC.B #LED1,&LED1_DIR   ;           Red led OFF, end of Slave TX
;            BIC.B #LED1,&LED1_OUT   ;           Red led OFF, end of Slave TX
            JMP SLEEP               ;           which calls RXON before goto sleep
; ----------------------------------;

; **********************************;
TERMINAL_INT                        ; <--- START interrupt vector, bus is stalled, waiting ACK first char by I2C_Slave RX
; **********************************;
; (ACCEPT) part II under interrupt  ; Org Ptr --
; ----------------------------------;
            ADD #4,RSP              ;1      remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            BIC #WAKE_UP,&TERM_IFG  ;       clear UCSTTIFG before return to SLEEP
            BIT #10h,&TERM_CTLW0    ;4      test UCTR
            JNZ SLEEP               ;       if I2C_Master RX, loop back to SLEEP
            POPM #4,IP              ;6      POPM  IP=ret_IP,W=src_end,T=0Ah,S=20h
;            BIS.B #LED2,&LED2_OUT   ;       green led ON, start of Slave RX
;            BIS.B #LED2,&LED2_DIR   ;       green led ON, start of Slave RX
QNEWCHAR    BIT #RX_TERM,&TERM_IFG  ;3      test RX BUF IFG
            JZ QNEWCHAR             ;2      wait RX BUF full
            MOV.B &TERM_RXBUF,Y     ;3      read char into Y, RX_IFG is cleared, bus unstalled by I2C_Slave
            CMP.B T,Y               ;1
            JZ ENDACCEPT            ;2      jump if char = LF
            CMP.B S,Y               ;1      printable char ?
            JC ASTORETEST           ;2      jump if char U>= BL
; ----------------------------------;
            CMP.B #8,Y              ;       char = BS ?
            JNZ QNEWCHAR            ;       case of all other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ QNEWCHAR             ;       yes: do nothing else
            SUB #1,TOS              ;       no : dec Ptr
            JMP QNEWCHAR
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1     end of buffer is reached ?
            JZ QNEWCHAR             ; 2     yes: loopback
            MOV.B Y,0(TOS)          ; 3     no: store char @ dst_Ptr
            ADD #1,TOS              ; 1     increment dst_Ptr
            JMP QNEWCHAR
; ----------------------------------;
ENDACCEPT                           ; -- Org Ptr
;            BIC.B #LED2,&LED2_DIR   ;       green led OFF, end of Slave RX
;            BIC.B #LED2,&LED2_OUT   ;       green led OFF, end of Slave RX
;            BIS.B #LED1,&LED1_DIR   ;       Red led ON, start of Slave TX
;            BIS.B #LED1,&LED1_OUT   ;       Red led ON, start of Slave TX
            CMP #0,&LINE            ;  
            JZ ACCEPTEND            ;
            ADD #1,&LINE            ;           increment LINE if <> 0
ACCEPTEND   SUB @PSP+,TOS           ; -- len'
; ----------------------------------;
;           MOV #LPMx+GIE,&LPM_MODE ;           no need to redefine LPM_MODE because I2C START works down to LPM4 mode
; ----------------------------------;
            CALL #WAITCHAREND       ;           wait SCL held low, i.e. I2C_Master RX waits first char;
            MOV @IP+,PC             ;           we want to synchronize Slave TX with Master RX before running INTERPRET
; **********************************;

; ----------------------------------;
RXON                                ;           send ctrl_char $00 as ACCEPT request
; ----------------------------------;
            MOV.B #0,Y              ;           Y = ctrl_char $00
; ----------------------------------;
CTRLCHARTX                          ;           send Y = ctrl_char
; ----------------------------------;
CTRLCH_WAIT BIT #TX_TERM,&TERM_IFG  ;3
            JZ CTRLCH_WAIT          ;2          wait TX buffer empty
            MOV.B Y,&TERM_TXBUF     ;
WAITCHAREND BIT #40h,&TERM_STATW    ;
            JZ WAITCHAREND          ;           wait SCL held low by Master RX, i.e. I2C_Master RX processes this Ctrl_char
; ----------------------------------;
RXOFF       MOV @RSP+,PC            ;           Calling RXOFF does nothing.
; ----------------------------------;

; ----------------------------------;
COLD        MOV #5A4Fh,&WDTCTL      ;           start Watchdog Reset : XDTPW, WDTSSEL=VLOCLK, WDTCNTCL=1, WDTIS=2^6 (8ms)
; ----------------------------------;
COLD_TERM   BIT #TX_TERM,&TERM_IFG  ;3
            JZ COLD_TERM            ;2          wait complete send of previous char
; ----------------------------------;
; send ctrl_char $03 (COLD request) ;
; ----------------------------------;
            MOV.B #3,&TERM_TXBUF    ;           send ctrl_char $03 to I2C_Master which will execute QABORT_TERM
            CALL #WAITCHAREND       ;           
            MOV #0A504h,&PMMCTL0    ;           performs BOR
; ----------------------------------;

; ------------------------------------------------------------------------------
; TERMINAL I/O, input part
; ------------------------------------------------------------------------------
            FORTHWORD "KEY"
; https://forth-standard.org/standard/core/KEY
; KEY      -- c      wait character from input device ; primary DEFERred word
KEY         MOV @PC+,PC             ; Code Field Address (CFA) of KEY
PFAKEY      .word BODYKEY           ; Param Field Address (PFA) of KEY, with its default value
BODYKEY     SUB #2,PSP              ;           push old TOS..
            MOV TOS,0(PSP)          ;           ..onto stack
            MOV.B #1,Y              ;           send $01 to I2C_Master RX as KEY request
            CALL #CTRLCHARTX        ;
BKEYLOOP    BIT #RX_TERM,&TERM_IFG  ;           received char ?
            JZ BKEYLOOP             ;           wait char received
            MOV &TERM_RXBUF,TOS     ; -- char
BKEYEND     MOV @IP+,PC             ; -- char

; ------------------------------------------------------------------------------
; TERMINAL I/O, output part
; ------------------------------------------------------------------------------
            FORTHWORD "EMIT"
; https://forth-standard.org/standard/core/EMIT
; EMIT     c --    output character to an output device ; primary DEFERred word
EMIT        MOV @PC+,PC             ;3 Code Field Address (CFA) of EMIT
PFAEMIT     .word BODYEMIT          ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT    MOV TOS,Y               ;1 sends character to the default output TERMINAL
            MOV @PSP+,TOS           ;2
YEMIT1
;            BIT #10h,&TERM_CTLW0    ;4      test UCTR
;            JZ YEMITEND
YEMIT2      BIT #TX_TERM,&TERM_IFG  ;3
            JZ YEMIT2               ;2 wait TX buffer empty
YEMIT       .word   4882h           ;3 4882h = MOV Y,&<next_adr>
            .word   TERM_TXBUF      ;
YEMITEND    MOV @IP+,PC             ;4 11 words

            FORTHWORD "ECHO"
;Z ECHO     --      connect EMIT to TERMINAL (default)
ECHO        MOV #4882h,&YEMIT       ; 4882h = MOV Y,&<next_adr>
            MOV #0,&LINE            ;
            MOV #5,Y                ;
ECHOEND     CALL #CTRLCHARTX
            MOV @IP+,PC

            FORTHWORD "NOECHO"
;Z NOECHO   --      disconnect EMIT to TERMINAL
NOECHO      MOV #NEXT,&YEMIT        ;  NEXT = 4030h = MOV @IP+,PC
            MOV #1,&LINE            ;
            MOV #4,Y                ;
            JMP ECHOEND
