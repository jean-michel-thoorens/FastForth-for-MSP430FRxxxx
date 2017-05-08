; -*- coding: utf-8 -*-
; MY_MSP430FR5948.asm 

; Fast Forth For Texas Instrument MSP430FR5739
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
; MY_MSP430FR5948_1 : MSP430FR5948 TSSOP38 to DIP28 board MAP
;                     may be remplaced by MSP430FR5939 TSSOP 38
;   Version 1 : added a 4k7 resistor on RX signal between Si8622EC and PROG6PINS
;               SD_CS and SD_CD are inverted
; ======================================================================
;
; MSP430FR5948          XTAL 32768 Hz
; 1       --- PJ.4 ---  LFXIN
; 2       --- PJ.5 ---  LFXOUT
;
; MSP430FR5948          PROG 6PINS        ISOLATED UARTtoUSB bridge    
; 34      --- DVCC <->  2 "3v3"   -------->  1  Vdd1 <| SI |> Vdd2  8 <-- 3v3    
; 24      --- P2.1 <--  6 "RX0"   <----4k7-  2  A1   <| 86 |>   B1  7 <-- TXD 
; 23      --- P2.0 <->  1 "TX0"   <--+---->  3  A2   <| 22 |>   B2  6 --> RXD    
; 33      --- DVSS <->  5 "GND"   <- | --->  4  Gnd1 <| EC |> Gnd2  5 <-- GND 
; 21      --- TEST ---  3 "TST"      |
; 22      --- RST  ---  4 "RST"      |
;                                    +-4k7-  DeepRST <-- GND 
;
;
; DIP28 1 --- 4 AVCC --- ferrite bead --- DVCC  34
; DIP28 2 --- 3 AVSS --- ferrite bead --- DVSS  33
;
; MSP430FR5948          DIP28
; 4,      --- AVCC ---  1   ; +
; 3,38    --- AVSS ---  2   ; -
;                       3   ; GND  
; 37      --- P2.4 ---  4   ; TA1.0/UCA1CLK/A7/C11
; 36      --- P2.3 ---  5   ; TA0.0/UCA1STE/A6/C10
; 30      --- P1.6 ---  6   ; TB0.3/UCB0SIMO/UCB0SDA/TA0.0
; 31      --- P1.7 ---  7   ; TB0.4/UCB0SOMI/UCB0SCL/TA1.0
; 29      --- P3.7 ---  8   ; TB0.6
; 28      --- P3.6 ---  9   ; TB0.5
; 27      --- P3.5 ---  10  ; TB0.4/COUT
; 26      --- P3.4 ---  11  ; TB0.3/SMCLK
; 20      --- P2.6 ---  12  ; TB0.1/UCA1RXD/UCA1SOMI
; 25      --- P2.2 ---  13  ; TB0.2/UCB0CLK
; 19      --- P2.5 ---  14  ; TB0.0/UCA1TXD/UCA1SIMO
; 15      --- PJ.0 ---  15  ; TDO/TB0OUTH/SMCLK/SRSCG1/C6
; 16      --- PJ.1 ---  16  ; TDI/TCLK/MCLK/SRSCG0/C7
; 17      --- PJ.2 ---  17  ; TMS/ACLK/SROSCOFF/C8
; 18      --- PJ.3 ---  18  ; TCK/SRCPUOFF/C9
; 14      --- P1.5 ---  19  ; TB0.2/UCA0CLK/A5/C5
; 13      --- P1.4 ---  20  ; TB0.1/UCA0STE/A4/C4
; 12      --- P1.3 ---  21  ; TA1.2/UCB0STE/A3/C3
; 10      --- P3.2 ---  22  ; A14/C14
; 11      --- P3.3 ---  23  ; A15/C15
; 9       --- P3.1 ---  24  ; A13/C13
; 8       --- P3.0 ---  25  ; A12/C12
; 5       --- P1.0 ---  26  ; TA0.1/DMAE0/RTCCLK/A0/C0/VREF-/VeREF-
; 6       --- P1.1 ---  27  ; TA0.2/TA1CLK/COUT/A1/C1/VREF+/VeREF+
; 7       --- P1.2 ---  28  ; TA1.1/TA0CLK/COUT/A2/C2
;
;
; P1.0  - DIP.26
; P1.1  - DIP.27
; P1.2  - DIP.28    <------------------------> SDA I2C SOFTWARE MASTER
; P1.3  - DIP.21    <------------------------> SCL I2C SOFTWARE MASTER        
; P1.4  - DIP.20        
; P1.5  - DIP.19
; P1.6  - DIP.6 UCB0 SDA/SIMO   <------------> SDA I2C MASTER/SLAVE         
; P1.7  - DIP.7 UCB0 SCL/SOMI   <------------> SCL I2C MASTER/SLAVE         
;
; SD_Card socket
; VCC   -           ------------------------->  VCC        SD_CardAdapter
; P2.2  - DIP.13    ------------------------->  TB0.2   LCD_Vo 
; P2.3  - DIP.5     ------------------------->  SD_CardAdapter DAT3/CS (Card Select) (CD at power up)  
; P2.4  - DIP.4   UCA1/CLK    --------------->  SD_CardAdapter SCK  
; P2.5  - DIP.14  UCA1/SIMO   --------------->  SD_CardAdapter CMD/SDI (MOSI)
; P2.6  - DIP.12  UCA1/SOMI   <---------------  SD_CardAdapter DAT0/SDO (MISO)
; P2.7  -           ------------------------->  SD_CardAdapter CD (CardDetect)
; VSS   -           <------------------------>  GND SD_CardAdapter
; 
;
; P3.0  - DIP.25    ------------------------->  4 LCD_RS
; P3.1  - DIP.24    ------------------------->  5 LCD_R/W
; P3.2  - DIP.23    ------------------------->  6 LCD_EN
; P3.3  - DIP.22    <------------------------- OUT IR_Receiver (1 TSOP32236)
; P3.4  - DIP.11    ------------------------->  sw1 (hard reset)
; P3.5  - DIP.10    ------------------------->  sw2
; P3.6  - DIP.9 
; P3.7  - DIP.8 
;
;
; PJ.0  - DIP.15    <------------------------> 11 LCD_DB4
; PJ.1  - DIP.16    <------------------------> 12 LCD_DB5
; PJ.2  - DIP.17    <------------------------> 13 LCD_DB5
; PJ.3  - DIP.18    <------------------------> 14 LCD_DB7

; Clocks:
; 8 MHz DCO intern

; ----------------------------------------------------------------------
; INIT order : LOCK I/O, WDT, GPIOs, FRAM, Clock, UARTs
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------

;              BIS     #LOCKLPM5,&PM5CTL0 ; unlocked by WARM

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

        MOV #WDTPW+WDTHOLD+WDTCNTCL,&WDTCTL    ; stop WDT

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : I/O
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT1 usage

; PORT2 usage

Deep_RST_IN .equ P2IN  ; TERMINAL TX  pin as FORTH Deep_RST 
Deep_RST    .equ 1     ; P2.0
TERM_TXRX   .equ 003h
TERM_SEL    .equ P2SEL1
TERM_REN    .equ P2REN

          .IFDEF TERMINALCTSRTS
          .error "CTS/RTS Control Flow not implemented"
          .ENDIF

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PAOUT   ; OUT1
            BIS     #-1,&PAREN   ; REN1 all pullup resistors

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 usage

; PORT4 usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV     #-1,&PBOUT   ; pullup
            BIS     #-1,&PBREN   ; all pullup resistors

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PJ  usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B   #-1,&PJOUT ;
            BIS.B   #-1,&PJREN ; pullup resistors on unused pins

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF FREQUENCY = 16
            MOV.B   #0A5h, &FRCTL0_H     ; enable FRCTL0 access
            MOV.B   #10h, &FRCTL0         ; 1 waitstate @ 16 MHz
            MOV.B   #01h, &FRCTL0_H       ; disable FRCTL0 access
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).
; Startup clock system in max. DCO setting ~8MHz


; CS code for MSP430FR5948
            MOV.B   #CSKEY,&CSCTL0_H ;  Unlock CS registers

    .IF FREQUENCY = 0.5
            MOV     #0,&CSCTL1                  ; Set 1MHZ DCO setting
            MOV     #DIVA_2 + DIVS_2 + DIVM_2,&CSCTL3             ; set all dividers as 2
            MOV     #4,X

    .ELSEIF FREQUENCY = 1
            MOV     #0,&CSCTL1                  ; Set 1MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #8,X

    .ELSEIF FREQUENCY = 2
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3
            MOV     #16,X

    .ELSEIF FREQUENCY = 4
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #32,X

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL2+DCOFSEL1,&CSCTL1  ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #64,X

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL+DCOFSEL2,&CSCTL1   ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #128,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSE
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #01h, &CSCTL0_H                               ; Lock CS Registers

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

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : SYS REGISTERS
; ----------------------------------------------------------------------


; SYS code                                  
; see COLD word
