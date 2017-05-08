; -*- coding: utf-8 -*-
; MY_MSP430FR5738_2.asm
; config file for MY_MSP430FR5738 board
;
; Copyright (C) <2014>  <J.M. THOORENS>
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


; ======================================================================
; MY_MSP430FR5738_2 BOARD 
; ======================================================================
;
; MSP430FR5738          XTAL 32768 Hz
; 1       --- PJ.4 ---  LFXIN
; 2       --- PJ.5 ---  LFXOUT
;
; MSP430FR5738         PROG 6PINS                    ISOLATOR    
;         --- VCC  <->  2 "3v3"   >-------->  Vdd1 1 [| SI |] 8 Vdd2  <---< 3v3 )   
; 20      --- P2.1 <--  6 "RX0"   <---4k7--<  A1   2 [| 86 |] 7   B1  <---- TXD \ UART2USB
; 19      --- P2.0 <->  1 "TX0"   <--+----->  A2   3 [| 22 |] 6   B2  >---> RXD / PL2303TA   
;         --- VSS  <->  5 "GND"   <- | ---->  Gnd1 4 [| EC |] 5 Gnd2  <---> GND )
; 17      --- TEST ---  3 "TST"      | 
; 18      --- RST  ---  4 "RST"      | 
;                                    +-4k7-< DeepRST <-- GND 

; DIP1   AVcc -- ferrite bead -- DVcc
; DIP2   AVss -- ferrite bead -- DVss
; DIP3   P2.4/TA1.0/A7/CD11
; DIP4   P2.3/TA0.0/A6/CD10
; DIP5   P1.7/UCB0SOMI/UCB0SCL/TA1.0
; DIP6   P1.6/UCB0SIMO/UCB0SDA/TA0.0
; DIP7   P2.2/UCB0CLK
; DIP8   P2.6
; DIP9   P2.5/TB0.0
; DIP10  GND
; DIP11  PJ.3/TCK/CD9 
; DIP12  PJ.2/TMS/ACLK/CD8
; DIP13  PJ.1/TDI/TCLK/MCLK/CD7
; DIP14  PJ.0/TDO/TB0OUTH/SMCLK/CD6
; DIP15  P1.5/TB0.2/UCA0CLK/A5/CD5 
; DIP16  P1.4/TB0.1/UCA0STE/A4/CD4 
; DIP17  P1.3/TA1.2/UCB0STE/A3/CD3
; DIP18  P1.2/TA1.1/TA0CLK/CDOUT/A2/CD2 
; DIP19  P1.1/TA0.2/TA1CLK/CDOUT/A1/CD1/VeREF+
; DIP20  P1.0/TA0.1/DMAE0/RTCCLK/A0/CD0/VeREF-


; CPU                                   OUTPUT WORLD
; ---                                   ------------
; GND       <-------+---0V0---------->  1 LCD_Vss
; VCC       <------ | --3V6-----+---->  2 LCD_Vdd
;                   |           |
;                  ___    470n ---
;                   ^          ---
;                  / \ 1N4148   |
;                  ---          |
;              100n |    2k2    |
; P1.5      >---||--+--^/\/\/v--+---->  3 LCD_Vo (0V6 without modulation)
; P1.4      >------------------------>  4 LCD_RS
; P1.3      >------------------------>  5 LCD_R/W
; P1.2      >------------------------>  6 LCD_EN
;   
; PJ.0      <------------------------> 11 LCD_DB4
; PJ.1      <------------------------> 12 LCD_DB5
; PJ.2      <------------------------> 13 LCD_DB5
; PJ.3      <------------------------> 14 LCD_DB7        
;   
; P2.5      <------------------------< S2 LCD contrast +
; P2.6      <------------------------< S1 LCD contrast -
;   
; P1.1      >------------------------>    SCL I2C MASTER
; P1.0      >------------------------>    SDA I2C MASTER | IR_RC5 receiver
;
;
;
;        VCC                    DIP1    ---> red    SD_CardAdapter VCC
;        GND                    DIP2    <--> black  SD_CardAdapter GND
; P2.4/TA1.0/A7/CD11            DIP3    ---> brown  SD_CardAdapter CS (Card Select)
; P2.3/TA0.0/A6/CD10            DIP4    <--- violin SD_CardAdapter CD (Card Detect)
; P1.7/UCB0SOMI/UCB0SCL/TA1.0   DIP5    <--- purple SD_CardAdapter SDO (MISO)
; P1.6/UCB0SIMO/UCB0SDA/TA0.0   DIP6    ---> grey   SD_CardAdapter SDI (MOSI)
; P2.2/UCB0CLK                  DIP7    ---> orange SD_CardAdapter CLK (SCK)  


; Clocks:
; 24 MHz DCO intern

; ----------------------------------------------------------------------
; INIT order : LOCK I/O, WDT, GPIOs, FRAM, Clock, UARTs
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK I/O as high impedance state
; ----------------------------------------------------------------------

        BIS     #LOCKLPM5,&PM5CTL0 ; unlocked by WARM

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

; WDT code
        MOV #WDTPW+WDTHOLD+WDTCNTCL,&WDTCTL    ; stop WDT

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION PAIN=PORT2:PORT1
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT1 usage

; PORT2 usage

Deep_RST_IN .equ P2IN   ; TERMINAL TX  pin as FORTH Deep_RST 
Deep_RST    .equ 1      ; P2.0 = TX
TERM_TXRX   .equ 003h   ; P2.1 = RX
TERM_SEL    .equ P2SEL1
TERM_REN    .equ P2REN

    .IFDEF TERMINALCTSRTS
;configure P2.2 as RTS output high
RTS         .equ  4
HANDSHAKOUT .equ  P2OUT
HANDSHAKIN  .equ  P2IN
            BIS.B #RTS,&HANDSHAKOUT
    .ENDIF

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PAOUT    ; all pins 1
            BIS     #-1,&PAREN    ; all pins 1 with pull resistors

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTJ usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B   #-1,&PJOUT    ; pullup resistors
            BIS.B   #-1,&PJREN    ; enable pullup/pulldown resistors

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).

            MOV.B   #CSKEY,&CSCTL0_H ;  Unlock CS registers

    .IF FREQUENCY = 0.5
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_16 + DIVM_16,&CSCTL3
            MOV     #4,X

    .ELSEIF FREQUENCY = 1
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_8 + DIVM_8,&CSCTL3
            MOV     #8,X

    .ELSEIF FREQUENCY = 2
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_4 + DIVM_4,&CSCTL3
            MOV     #16,X

    .ELSEIF FREQUENCY = 4
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3
            MOV     #32,X

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1          ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #64,X

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL,&CSCTL1                    ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #128,X

    .ELSEIF FREQUENCY = 24
            MOV     #DCORSEL+DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 24 MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3   ; set all dividers as 0
            MOV     #192,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,16,24 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSE
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #01h, &CSCTL0_H                     ; Lock CS Registers

            BIS &SYSRSTIV,&SAVE_SYSRSTIV; store volatile SYSRSTIV preserving a pending request for DEEP_RST
            CMP #2,&SAVE_SYSRSTIV   ; POWER ON ?
            JZ      ClockWaitX      ; yes
            .word   0759h           ; no  RRUM #2,X --> wait only 125 ms
ClockWaitX  MOV     #41666,Y        ; wait 0.5s before starting after POWER ON
ClockWaitY  SUB     #1,Y            ;
            JNZ     ClockWaitY      ; 41666x3 = 125000 cycles delay = 125ms @ 1MHz
            SUB     #1,X            ; x 4 @ 1 MHZ
            JNZ     ClockWaitX      ; time to stabilize power source ( 1s )

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : REF
; ----------------------------------------------------------------------

            MOV   #8, &REFCTL

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : RTC REGISTERS
; ----------------------------------------------------------------------

    .IFDEF LF_XTAL
; LF Xtal XIN : PJ.4, LF Xtal XOUT : PJ.5
    BIS.B   #010h,&PJSEL0   ; SEL0 for only XIN
    BIC.B   #RTCHOLD,&RTCCTL1 ; Clear RTCHOLD = start RTC_B
    .ENDIF

