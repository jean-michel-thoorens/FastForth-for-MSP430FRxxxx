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

; for I2C_Slave init, see in /inc/TARGET.asm file

; ----------------------------------;
; ACCEPT part I prepare TERMINAL_INT;   a START can be match here, with START ifg flag 
; ----------------------------------;
            MOV TOS,W               ;1 -- addr len  W=len
            MOV @PSP,TOS            ;2 -- org ptr                                               )
            ADD TOS,W               ;1 -- org ptr   W=buf_end                                   )
            MOV #0Ah,T              ;2              T = 'LF' to speed up char loop in part II   > prepare stack and registers for TERMINAL_INT use
            MOV #20h,S              ;2              S = 'BL' to speed up char loop in part II   ) 
            PUSHM #4,IP             ;6          PUSH IP,S,T,W  r-- IP, 'BL', 'LF', buf_end )
ACCEPT1     BIC #IE_TERM,&TERM_IFG  ;           clear UCSTTIFG before use during SLEEP
; ----------------------------------;
;; -test-v-test-v-test-v-test-v-test-;
;            BIC.B #LED1,&LED1_DIR   ;           Red led OFF, end of Slave TX
;            BIC.B #LED1,&LED1_OUT   ;           Red led OFF, end of Slave TX
;; -test-^-test-^-test-^-test-^-test-;
; ----------------------------------;
            BIT #10h,&TERM_CTLW0    ;4          test UCTR
            JZ SLEEP                ;2          UCTR=0, IC2_Slave RX mode or I2C_Slave unplugged, 16~
ACCEPT2     BIT #TX_TERM,&TERM_IFG  ;3          UCTR=1, IC2_Slave TX mode
            JZ ACCEPT2              ;2          wait complete send of char
            MOV.B #0,&TERM_TXBUF    ;           send ctrl_char $00
; ----------------------------------;
            JMP SLEEP               ;2          which calls RXON before shut down to LPMx mode
; ----------------------------------;

; **********************************;
TERMINAL_INT                        ; <--- START interrupt vector, bus stalled, waiting ACK first char by I2C_Slave RX
; **********************************;
; (ACCEPT) part II under interrupt  ; Org Ptr --
; ----------------------------------;
            ADD #4,RSP              ;1      remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            BIT #10h,&TERM_CTLW0    ;4      test UCTR
            JNZ ACCEPT1             ;       if I2C_Master RX, send $00 then return to SLEEP
            POPM #4,IP               ;6      POPM  IP=ret_IP,W=src_end,T=0Ah,S=20h
;; -test-v-test-v-test-v-test-v-test-;
;            BIS.B #LED2,&LED2_OUT   ;       green led ON, start of Slave RX
;            BIS.B #LED2,&LED2_DIR   ;       green led ON, start of Slave RX
;; -test-^-test-^-test-^-test-^-test-;
QNEWCHAR    BIT #RX_TERM,&TERM_IFG  ;3      test RX BUF IFG
            JZ QNEWCHAR             ;2      wait RX BUF full
AREADCHAR   MOV.B &TERM_RXBUF,Y     ;3      read char into Y, RX_IFG is cleared, bus unstalled by I2C_Slave
            CMP.B S,Y               ;1      printable char ?
            JC ASTORETEST           ;2      char U>= BL --> yes
            CMP.B T,Y               ;1      char = LF ?
            JZ ENDACCEPT            ;2      yes
; ----------------------------------;
            CMP.B #8,Y              ;       char = BS ?
            JNZ QNEWCHAR            ;       case of other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ QNEWCHAR             ;       yes: do nothing else
            SUB #1,TOS              ;       no : dec Ptr
            JMP QNEWCHAR
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1     end of buffer is reached ?
            JZ QNEWCHAR             ; 2 yes: loopback
            MOV.B Y,0(TOS)          ; 3 no: store char @ dst_Ptr
            ADD #1,TOS              ; 1     increment dst_Ptr
            JMP QNEWCHAR
; ----------------------------------;
ENDACCEPT                           ;       here, after char 'LF' TXed, I2C_Master reSTARTs in RX mode
;; -test-v-test-v-test-v-test-v-test-;
;            BIC.B #LED2,&LED2_DIR   ;       green led OFF, end of Slave RX
;            BIC.B #LED2,&LED2_OUT   ;       green led OFF, end of Slave RX
;            BIS.B #LED1,&LED1_DIR   ;       Red led ON, start of Slave TX
;            BIS.B #LED1,&LED1_OUT   ;       Red led ON, start of Slave TX
;; -test-^-test-^-test-^-test-^-test-;
; ----------------------------------; -- Org Ptr
            CMP #0,&LINE            ;  
            JZ ACCEPTEND            ;           if LINE <> 0 increment LINE
            ADD #1,&LINE            ;
ACCEPTEND   SUB @PSP+,TOS           ;   -- len'
AWAITTX     BIT #40h,&TERM_STATW    ;           wait SCL held low, i.e. I2C_Master RX waits a char from I2C_Slave
            JZ AWAITTX              ;      
; ----------------------------------;
;        MOV #CPUOFF+GIE,&LPM_MODE   ;   reset LPM_MODE to default mode LPM0 for next line of input stream
        MOV #LPM4+GIE,&LPM_MODE     ;   reset LPM_MODE to default mode LPM4 for next line of input stream
; ----------------------------------;
            MOV @IP+,PC             ;   ...until next falling down to LPMx mode of (ACCEPT) part1,
; **********************************;    i.e. when the FORTH interpreter has no more to do.

; ----------------------------------;
RXOFF                               ;
; ----------------------------------;
RXON        MOV @RSP+,PC            ; <======= SLEEP
; ----------------------------------;

; ----------------------------------;
COLD                                ;
; ----------------------------------;
            MOV #5A4Dh,&WDTCTL      ;           start Watchdog Reset : XDTPW, WDTSSEL=VLOCLK, WDTCNTCL=1, WDTIS=2^13 (1s)
; ----------------------------------;           WDT_RST time = 1s because the ABORT loop time on I2C_Master side.
; send $02 (ABORT request)          ;
; ----------------------------------;
            BIT #10h,&TERM_CTLW0    ;4          test UCTR
            JZ COLDI2CEND2          ;2          UCTR=0, IC2_Slave RX mode or I2C_Slave unplugged, 16~
COLDI2C     BIT #TX_TERM,&TERM_IFG  ;3          UCTR=1, IC2_Slave TX mode
            JZ COLDI2C              ;2          wait complete send of previous char
            MOV.B #2,&TERM_TXBUF    ;           send ctrl_char $02 to I2C_Master which will execute QABORT_TERM
; ----------------------------------;
; wait STOP from Master             ;
; ----------------------------------;
COLDI2CEND  BIC #8,&TERM_IFG        ;           clear STOP ifg before test
COLDI2CEND1 BIT #8,&TERM_IFG        ;           test STOP occurring
            JZ COLDI2CEND1          ; 
; ----------------------------------;
COLDI2CEND2 MOV #0A504h,&PMMCTL0    ;           performs BOR
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
            MOV #0,TOS              ; -- 0      aborted KEY value
; ----------------------------------;
            BIT #10h,&TERM_CTLW0    ;           test UCTR
            JZ BKEYEND              ;           when UCTR=0, IC2_Slave is in (RX|SWRST) mode, KEY can't work.
; ----------------------------------;
KEYQEMIT    BIT #TX_TERM,&TERM_IFG  ;           TX buffer empty ?
            JZ KEYQEMIT             ;           wait TX buffer empty
            MOV.B #1,&TERM_TXBUF    ;           send $01 to I2C_Master RX as KEY request
BKEYLOOP    BIT #RX_TERM,&TERM_IFG  ;           received char ?
            JZ BKEYLOOP             ;           wait char received
            MOV &TERM_RXBUF,TOS     ; -- char
; ----------------------------------;
BKEYEND     MOV @IP+,PC             ; -- char|0 Z=aborted KEY

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
; ----------------------------------;
YEMIT2      BIT #10h,&TERM_CTLW0    ;4 test UCTR
            JZ YEMITEND             ;2 UCTR=0, IC2_Slave RX mode or I2C_Slave unplugged, 16~
; ----------------------------------;
YEMIT1      BIT #TX_TERM,&TERM_IFG  ;3 UCTR=1, IC2_Slave TX mode
            JZ YEMIT1               ;2 wait complete send of previous char
YEMIT       .word   4882h           ; 4882h = MOV Y,&<next_adr>
            .word   TERM_TXBUF      ; 3
; ----------------------------------;
YEMITEND    MOV @IP+,PC             ;4 14 words

            FORTHWORD "ECHO"
;Z ECHO     --      connect EMIT to TERMINAL (default)
ECHO        MOV #4882h,&YEMIT       ; 4882h = MOV Y,&<next_adr>
            MOV #0,&LINE            ;
            MOV #5,Y                ;
            JMP YEMIT2              ; send ctrl_char $05 to I2C_Master

            FORTHWORD "NOECHO"
;Z NOECHO   --      disconnect EMIT to TERMINAL
NOECHO      MOV #1,&LINE            ;
            MOV #4,Y                ;
            mDOCOL
            .word YEMIT2            ; send ctrl_char $04 to I2C_Master
            .word $+2
            MOV #NEXT,&YEMIT        ;  NEXT = 4030h = MOV @IP+,PC
            MOV @RSP+,IP
            MOV @IP+,PC
            