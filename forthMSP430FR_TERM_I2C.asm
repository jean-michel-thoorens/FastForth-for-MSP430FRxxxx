; -*- coding: utf-8 -*-
;
; ---------------------------------------------------
; TERMINAL driver for I2CFastForth target (I2C Slave)
; ---------------------------------------------------
;          |
;          |           GND------------------------------GND
;          |           Vcc-------------o---o------------Vcc
;          |                           |   |
;          |                           3   3
;          |                           k   k
;          v                           3   3
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
; I2C TERMINAL: QABORT ABORT_TERM INIT_TERM COLD_TERM RXON I2C_CTRL_CH
;-------------------------------------------------------------------------------

; ?ABORT defines run-time part of ABORT"
QABORT      CMP #0,2(PSP)           ; -- f addr cnt     if f is true abort current process then display ABORT" msg.
            JNZ ABORT_TERM          ;                   see forthMSP430FR_TERM_xxxx.asm below
THREEDROP   ADD #4,PSP              ; -- cnt
            JMP DROP                ;
; ----------------------------------;
I2C_ABORT_TERM                      ; exit from downloading then reinit FORTH variables via INIT_FORTH
; ----------------------------------;
ABORT_TERM  MOV #2,Y                ;                   send $02 as Ctrl_Char ?ABORT
            CALL #I2C_CTRL_CH       ;
            CALL #INIT_FORTH        ;                   common ?ABORT|PUC subroutine to init DEFERed definitions + INIT_FORTH
            .word   DUP             ; -- f addr cnt cnt
            .word   QFBRAN,ABORT_END; -- f addr 0       if cnt = 0 display nothing
            .word   ECHO            ;                   force ECHO
            .word   XSQUOTE         ;
            .byte   5,27,"[7m",'@'  ;
            .word   TYPE            ;                       cmd "reverse video" + displays "@"
            .word   LIT,I2CSLAVEADR ;
            .word   FETCH,DOT       ;                       displays I2C_Slave_Address<<1
; ----------------------------------;
; Display ABORT|WARM message        ; -- f addr cnt     <== WARM jumps here
; ----------------------------------;
ABORT_TYPE  .word   TYPE            ; -- f              display QABORT|WARM message
            .word   XSQUOTE         ;
            .byte   4,27,"[0m"      ;
            .word   TYPE            ;                   set normal video
ABORT_END   .word   ABORT           ; -- f|f addr 0     no return
; ----------------------------------;

RXON                                ; called by SLEEP before CPU sleeping down.
; ----------------------------------;
I2C_ACCEPT  MOV.B #0,Y              ; ACCEPT request Ctrl_Char = $00
; ----------------------------------;
I2C_CTRL_CH BIT #TX_TERM,&TERM_IFG  ; send it to I2C_Master_RX to restart it in TX mode
            JZ I2C_CTRL_CH          ; wait TX buffer empty
            MOV.B Y,&TERM_TXBUF     ; send Ctrl_Char
; ----------------------------------;
I2C_COLD_TERM
; ----------------------------------;
COLD_TERM                           ; does nothing by default
; ----------------------------------;
I2C_INIT_SOFT                       ;
; ----------------------------------;
INIT_SOFT_TERM
            MOV @RSP+,PC            ; does nothing by default
; ----------------------------------;

;-------------------------------------------------------------------------------
; INIT TERMinal then enable I/O
;-------------------------------------------------------------------------------
; ----------------------------------;
I2C_INIT_TERM                       ;
; ----------------------------------;
INIT_TERM                           ; TOS = USERSYS, don't change
        BIS #07C0h,&TERM_CTLW0      ; set I2C_Slave in RX mode to receive I2C_address
        MOV &I2CSLAVEADR,Y          ; init value found in FRAM INFO
        RRA Y                       ; I2C Slave address without R/W bit
        BIS #400h,Y                 ; enable I2COA0 Slave address
        MOV Y,&TERM_I2COA0          ;
        BIS.B #BUS_TERM,&TERM_SEL   ; Configure pins TERM_I2C
        BIC #1,&TERM_CTLW0          ; release UC_TERM from reset...
        BIS #WAKE_UP,&TERM_IE       ; then enable interrupt for wake up on START
        BIC #LOCKLPM5,&PM5CTL0      ; activate all previous I/O settings.
        MOV @RSP+,PC                ;
; ----------------------------------;

;-------------------------------------------------------------------------------
; I2C TERMINAL : WARM SYS COLD
;-------------------------------------------------------------------------------

;-----------------------------------;
;            FORTHWORD "WARM"       ; (n) --
;-----------------------------------;
I2C_WARM                            ;
;-----------------------------------;
WARM        CALL &HARD_APP          ; init HARD_APP, i.e. UART_TERMinal then unlock IO's
            mASM2FORTH              ; display a message then goto QUIT (without return):
    .word   ECHO                    ;
    .word   XSQUOTE
    .byte   7,13,10,27,"[7m@"       ; CR+LF + cmd "reverse video" + @
    .word   TYPE
    .word   LIT,I2CSLAVEADR,FETCH
    .word   DOT                     ; display decimal I2C_address<<1
    .word   LIT,'#',EMIT
    .word   DOT                     ; display signed USERSYS
    .word   XSQUOTE
    .byte   25,"FastForth ",169,"J.M.Thoorens, "
    .word   TYPE
    .word   LIT,FRAM_FULL
    .word   HEREXEC,MINUS,UDOT      ; number of...
    .word   XSQUOTE
    .byte   10,"bytes free"         ; bytes free
    .word   BRAN,ABORT_TYPE         ; no return
;-----------------------------------;

;-----------------------------------;
            FORTHWORD "SYS"         ; n --      software RST, DEEP_RST, COLD, WARM
;-----------------------------------;
            CMP #0,TOS              ;
            JL SYSEND               ; if -n SYS  ==> COLD + DEEP_RESET
            JZ NOPUC                ; if [0] SYS
            BIT #1,TOS              ;
            JNC SYSEND              ; if +n SYS (+n even)
NOPUC       PUSH #WARM              ; push WARM address
            PUSH RSP                ; Push address of WARM address
            JMP INIT_FORTH          ; if +n SYS (+n odd)  ==> INIT_FORTH --> WARM -->  WARM display
SYSEND      MOV TOS,&USERSYS        ; ==> COLD --> PUC --> INIT_FORTH --> WARM -->  WARM display
;===============================================================================
COLD        ; <--- USER_NMI vector <--- <RESET> and <RESET> + <SW1> (DEEP_RESET)
;===============================================================================
; as pin RST is replaced by pin NMI by RESET below, hardware RESET is redirected here via USER NMI vector
; that allows specific actions before executing software BOR:
            CALL &COLD_APP          ; to stop APPlication before reset
            BIT.B #SW1,&SW1_IN      ; <SW1> pressed ?
            JNZ COLDEXE             ; no
            MOV #-1,&USERSYS        ; yes, force USERSYS negative value to do DEEP_RESET
COLDEXE     MOV #0A504h,&PMMCTL0    ; performs software_BOR ------------------------+
;===============================================================================    |
RESET                               ; <-- RST vect. <-- SYS_failures PUC POR BOR <--+
;===============================================================================
; PUC 1: replace pin RESET by pin NMI, stops WDT_RESET
;-------------------------------------------------------------------------------
            BIS #3,&SFRRPCR         ; pin RST becomes pin NMI with falling edge, so SYSRSTIV = 4
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
; PUC 5: GET SYSRSTIV and SYS_USER
;-------------------------------------------------------------------------------
            MOV &USERSYS,TOS        ; TOS = USERSYS
            MOV #0,&USERSYS         ; clear USERSYS
            AND #-1,TOS             ;
            JNZ PUC6                ; if TOS <> 0, keep USERSYS value
            MOV &SYSRSTIV,TOS       ; TOS <-- SYSRSTIV <-- 0
;-------------------------------------------------------------------------------
; PUC 6: START FORTH engine
;-------------------------------------------------------------------------------
PUC6        CALL #INIT_FORTH        ; common part of QABORT|PUC
PUCNEXT     .WORD WARM              ; no return. May be replaced by XBOOT.
;-----------------------------------;

;-------------------------------------------------------------------------------
; INTERPRETER INPUT: ACCEPT KEY EMIT ECHO NOECHO
;-------------------------------------------------------------------------------
            FORTHWORD "ACCEPT"      ;
; ----------------------------------;
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
            PUSHM #4,IP             ;6              PUSH IP,S,T,W  R-- IP, 'BL', 'LF', buf_end  )
            JMP SLEEP               ;2
; ----------------------------------;

; As TI says nothing about the reset of the UCSTTIFG flag by the I2C_Slave,
; it is assumed that it clears it as soon as the first byte has been exchanged.
; **********************************;
TERMINAL_INT                        ; down to LPM4  <--- START interrupt vector, bus is stalled, waiting ACK first char by I2C_Slave RX
; **********************************;
; (ACCEPT) part II under interrupt  ; Org Ptr --
; ----------------------------------;
            ADD #4,RSP              ;1      remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            BIC #WAKE_UP,&TERM_IFG  ;       clear UCSTTIFG before return to SLEEP (instead of RXBUF access to clear it)
            BIT #10h,&TERM_CTLW0    ;4      test UCTR
            JNZ SLEEP               ;       if I2C_Master RX, loop back to SLEEP
            POPM #4,IP              ;6      POPM  IP=ret_IP,W=src_end,T=0Ah,S=20h
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
            JNZ QNEWCHAR            ;       case of all other control chars: skip it
; ----------------------------------;
; case of backspace                 ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ QNEWCHAR             ;       yes: do nothing else
            SUB #1,TOS              ;       no : dec Ptr
            JMP QNEWCHAR            ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1     end of buffer is reached ?
            JC QNEWCHAR             ; 2     yes: don't store char @ dst_Ptr, don't increment TOS
            MOV.B Y,0(TOS)          ; 3     no: store char @ dst_Ptr
            ADD #1,TOS              ; 1     increment dst_Ptr
            JMP QNEWCHAR            ;
; ----------------------------------;
LF_NEXT     SUB @PSP+,TOS           ; -- len'
ACCEPT_EOL  MOV S,Y                 ;       output a BL on TERMINAL (for the case of error occuring)
            JMP YEMIT               ;       before line interpreting
; **********************************;

; ----------------------------------;
            FORTHWORD "KEY"         ;
; ----------------------------------;
; https://forth-standard.org/standard/core/KEY
; KEY      -- c      wait character from input device ; primary DEFERred word
KEY         MOV @PC+,PC             ; Code Field Address (CFA) of KEY
PFAKEY      .word BODYKEY           ; Param Field Address (PFA) of KEY, with its default value
BODYKEY     MOV.B #1,Y              ; KEY request Ctrl_Char = $01
            CALL #I2C_CTRL_CH       ; send it to I2C_Master to restart its UART in RX mode
            SUB #2,PSP              ;           push old TOS..
            MOV TOS,0(PSP)          ;           ..onto stack
BKEYLOOP    BIT #RX_TERM,&TERM_IFG  ;           received char ?
            JZ BKEYLOOP             ;           wait char received
            MOV &TERM_RXBUF,TOS     ; -- char
            CALL #RXON              ; send Ctrl_Char $00 to I2C_Master to restart its UART in TX mode
BKEYEND     MOV @IP+,PC             ; -- char
; ----------------------------------;

; ----------------------------------;
            FORTHWORD "EMIT"        ;
; ----------------------------------;
; https://forth-standard.org/standard/core/EMIT
; EMIT     c --    output character to an output device ; primary DEFERred word
EMIT        MOV @PC+,PC             ;3 Code Field Address (CFA) of EMIT
PFAEMIT     .word BODYEMIT          ;  Parameter Field Address (PFA) of EMIT, with its default value
BODYEMIT
            MOV TOS,Y               ;1 sends character to the default output TERMINAL
            MOV @PSP+,TOS           ;2
YEMIT       BIT #TX_TERM,&TERM_IFG  ;3
            JZ YEMIT                ;2 wait TX buffer empty
QYEMIT      MOV.B Y,&TERM_TXBUF     ;3 may be replaced by MOV @IP+,PC with NOECHO
YEMITEND    MOV @IP+,PC             ;4 11 words
; ----------------------------------;

; ----------------------------------;
            FORTHWORD "ECHO"        ; connect EMIT to TERMINAL (default)
; ----------------------------------;
ECHO        MOV #48C2h,&QYEMIT      ; 48C2h = MOV.B Y,&<next_adr>
            MOV #5,Y                ; ECHO request Ctrl_Char = $05
ECHOEND     CALL #I2C_CTRL_CH       ;
            MOV @IP+,PC             ;
; ----------------------------------;

; ----------------------------------;
            FORTHWORD "NOECHO"      ; disconnect EMIT to TERMINAL
; ----------------------------------;
NOECHO      MOV #4D30h,&QYEMIT      ; NEXT = 4D30h = MOV @IP+,PC
            MOV #4,Y                ; NOECHO request Ctrl_Char = $04
            JMP ECHOEND             ;
; ----------------------------------;

