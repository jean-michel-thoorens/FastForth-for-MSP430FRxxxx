; -*- coding: utf-8 -*-

; define run-time part of ABORT"
;Z ?ABORT   xi f c-addr u --           abort & print msg.
;            FORTHWORD "?ABORT"
QABORT      CMP #0,2(PSP)           ; -- f c-addr u         test flag f
            JNZ ABORT_TERM          ;
THREEDROP   ADD #4,PSP              ; -- u
            MOV @PSP+,TOS           ; -- 
            MOV @IP+,PC             ;
; ----------------------------------;
ABORT_TERM                          ; exit from downloading then reinit some variables via INI_FORTH
; ----------------------------------;
            MOV.B #2,Y              ; ABORT request Ctrl_Char = $02
            CALL #I2C_CTRL_CH       ; send it to I2C_Master to run QABORT_TERM on its side
            CALL #INI_FORTH         ; common ?ABORT|RST subroutine
; ----------------------------------;
            .word   lit,LINE,FETCH  ; -- f c-addr u line    fetch line number before set ECHO ON !
            .word   ECHO            ;
; ----------------------------------;
            .word   OVER            ; -- f c-addr u line u
            .word   QFBRAN,ABORT    ; --                    display nothing when ABORT" with empty string
; ----------------------------------;
            .word   XSQUOTE         ;
            .byte   5,27,"[7m",'@'  ;
            .word   TYPE            ;                       cmd "reverse video" + displays "@"
            .word   LIT,I2CSLAVEADR ;
            .word   FETCH,DOT       ;                       displays <I2C_Slave_Address>
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
            .word   ABORT           ; -- f              no return
; ----------------------------------;

; ----------------------------------;
INIT_TERM                           ; TOS = RSTIV_MEM
; ----------------------------------;
I2C_INIT_TERM
        CMP #2,TOS                  ;
        JNC I2C_INIT_TERM_END       ; no INIT_TERM if RSTIV_MEM U< 2 (WARM)
; ----------------------------------;
I2C_INIT_TERM_BODY
        BIS #07C0h,&TERM_CTLW0      ; set I2C_Slave in RX mode to receive I2C_address
        MOV &I2CSLAVEADR,Y          ; init value found in FRAM INFO
        RRA Y                       ; I2C Slave address without R/W bit 
        BIS #400h,Y                 ; enable I2COA0 Slave address
        MOV Y,&TERM_I2COA0          ;
        BIS.B #BUS_TERM,&TERM_SEL   ; Configure pins TERM_UART|TERM_I2C
        BIC #1,&TERM_CTLW0          ; release UC_TERM from reset...
        BIS #WAKE_UP,&TERM_IE       ; then enable interrupt for wake up on terminal input
        BIC #LOCKLPM5,&PM5CTL0      ; activate all previous I/O settings.
I2C_INIT_TERM_END
; ----------------------------------;
COLD_TERM                           ; nothing to do
; ----------------------------------;
        MOV @RSP+,PC                ;
; ----------------------------------;


; ----------------------------------;
RXON                                ; send ctrl_char $00 as ACCEPT request
; ----------------------------------;
I2C_RXON    MOV.B #0,Y              ; ACCEPT request Ctrl_Char = $00
; ----------------------------------;
I2C_CTRL_CH                         ; send it to I2C_Master_RX to restart it in TX mode
; ----------------------------------;
        BIT #TX_TERM,&TERM_IFG      ;3
        JZ I2C_CTRL_CH              ;2 wait TX buffer empty
        MOV.B Y,&TERM_TXBUF         ;3 send Ctrl_Char
WAITCHAREND 
;        BIT #40h,&TERM_STATW        ; SCL held low (after I2C_Master (re)START) ?
        BIT #4,&TERM_IFG            ; I2C_Master (re)START ?
        JZ WAITCHAREND              ; no
        MOV @RSP+,PC                ; yes
; ----------------------------------;

;===============================================================================
            FORTHWORD "WIPE"        ; software DEEP_RESET
;===============================================================================
            MOV #-1,&RSTIV_MEM      ; negative value ==> DEEP_RESET
            JMP COLD

;===============================================================================
            FORTHWORD "COLD"
;===============================================================================
;Z COLD     --      performs a software reset
; as pin RST is replaced by pin NMI, RESET by pin activation is redirected here via USER NMI vector
; that allows actions to be performed before executing software BOR.
COLD        CALL @PC+               ; COLD first calls STOP_APP, in this instance: CALL #COLD_TERM by default
PFACOLD     .word COLD_TERM         ; PFACOLD default value set by WIPE.
BODYCOLD    BIT.B #IO_WIPE,&WIPE_IN ; hardware Deep_RESET request (low) ?
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
    MOV.B  #3,Y                     ; WARM request Ctrl_Char = $03
    CALL #I2C_CTRL_CH               ; send it to I2C_Master to reSTART in RX mode
    ASMtoFORTH
    .word   XSQUOTE
    .byte   7,13,10,27,"[7m@"       ; CR + cmd "reverse video" + @
    .word   TYPE
    .word   LIT,I2CSLAVEADR,FETCH,DOT
    .word   LIT,'#',EMIT
    .word   DOT                     ; display signed RSTIV_MEM
    .word   XSQUOTE
    .byte   25,"FastForth ©J.M.Thoorens "
    .word   TYPE
    .word   LIT,FRAM_FULL,HERE,MINUS,UDOT
    .word   XSQUOTE
    .byte   10,"bytes free"
    .word   BRAN,ABORT_TYPE         ; without return!


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
            MOV TOS,W               ;1 -- org len   W=len
            MOV @PSP,TOS            ;2 -- org ptr                                               )
            ADD TOS,W               ;1 -- org ptr   W=buf_end                                   )
            MOV #0Ah,T              ;2              T = 'LF' to speed up char loop in part II   > prepare stack and registers for TERMINAL_INT use
            MOV #20h,S              ;2              S = 'BL' to speed up char loop in part II   ) 
            PUSHM #4,IP             ;6              PUSH IP,S,T,W  r-- IP, 'BL', 'LF', buf_end  )
;vvvvvvvvvvvvv OPTION vvvvvvvvvvvvvv;
;            BIC.B #LED1,&LED1_DIR   ;           Red led OFF,
;            BIC.B #LED1,&LED1_OUT   ;           end of Slave TX
;^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^;
            JMP SLEEP               ;            which calls RXON before goto sleep
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
;vvvvvvvvvvvvv OPTION vvvvvvvvvvvvvv;
;            BIS.B #LED2,&LED2_OUT   ;       green led ON,
;            BIS.B #LED2,&LED2_DIR   ;       start of Slave RX
;^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^;
QNEWCHAR    BIT #RX_TERM,&TERM_IFG  ;3      test RX BUF IFG
            JZ QNEWCHAR             ;2      wait RX BUF full
; ----------------------------------;
AKEYREAD    MOV.B &TERM_RXBUF,Y     ;3      read char into Y, RX_IFG is cleared, bus unstalled by I2C_Slave
; ----------------------------------;
            CMP.B T,Y               ;1      char = LF ?
            JZ LF_NEXT              ;2      jump if char = LF
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
LF_NEXT                             ; -- Org Ptr
; ----------------------------------;
            SUB @PSP+,TOS           ; -- len'
; ----------------------------------;
;           MOV #LPMx+GIE,&LPM_MODE ;       no need to redefine LPM_MODE because I2C START works down to LPM4 mode
; ----------------------------------;       after the sent of 'LF', I2C_Master automaticaly reSTARTs in RX mode:
            CALL #WAITCHAREND       ;       wait I2C_Master (re)START RX
;vvvvvvvvvvvvv OPTION vvvvvvvvvvvvvv;
;            BIC.B #LED2,&LED2_DIR   ;       green led OFF,
;            BIC.B #LED2,&LED2_OUT   ;       end of Slave RX
;            BIS.B #LED1,&LED1_DIR   ;       Red led ON,
;            BIS.B #LED1,&LED1_OUT   ;       start of Slave TX
;^^^^^^^^^^^^^ OPTION ^^^^^^^^^^^^^^;
ACCEPT_EOL  CMP #0,&LINE            ;            
            JZ ACCEPT_END           ;
            ADD #1,&LINE            ;       if LINE <> 0 increment LINE
ACCEPT_END  
; ----------------------------------;
            MOV S,Y                 ;       output a BL on TERMINAL (for the case of error occuring)
            JMP YEMIT               ;       before interpret line
; **********************************;

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
            MOV.B #1,Y              ; KEY request Ctrl_Char = $01
            CALL #I2C_CTRL_CH       ; send it to I2C_Master to restart UART in RX mode
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
YEMIT       BIT #TX_TERM,&TERM_IFG  ;3
            JZ YEMIT                ;2 wait TX buffer empty
QYEMIT      .word   48C2h           ;3 48C2h = MOV.B Y,&<next_adr>
            .word   TERM_TXBUF      ;
YEMITEND    MOV @IP+,PC             ;4 11 words

            FORTHWORD "ECHO"
;Z ECHO     --      connect EMIT to TERMINAL (default)
ECHO        MOV #48C2h,&QYEMIT      ; 48C2h = MOV.B Y,&<next_adr>
            MOV #0,&LINE            ;
            MOV #5,Y                ; ECHO request Ctrl_Char = $05
ECHOEND     CALL #I2C_CTRL_CH       ; send it to I2C_Master to do it echo char to TERMINAL
            MOV @IP+,PC

            FORTHWORD "NOECHO"
;Z NOECHO   --      disconnect EMIT to TERMINAL
NOECHO      MOV #4D30h,&QYEMIT      ;  NEXT = 4D30h = MOV @IP+,PC
            MOV #1,&LINE            ;
            MOV #4,Y                ; NOECHO request Ctrl_Char = $04
            JMP ECHOEND             ; send it to I2C_Master, to not do it echo to TERMINAL

            FORTHWORD "OVER"
;https://forth-standard.org/standard/core/OVER
;C OVER    x1 x2 -- x1 x2 x1
OVER        MOV TOS,-2(PSP) ; 3 -- x1 (x2) x2
            MOV @PSP,TOS    ; 2 -- x1 (x2) x1
            SUB #2,PSP      ; 1 -- x1 x2 x1
            MOV @IP+,PC     ; 4
