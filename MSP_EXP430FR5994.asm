; -*- coding: utf-8 -*-
; MSP_EXP430FR5994.inc

; Fast Forth For Texas Instrument MSP430FR5994
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
; MSP_EXP430FR5994 board
; ======================================================================
;
; J101 Target     <---> eZ-FET
; GND             14-13   GND
; +5V             12-11
; 3V3             10-9
; P2.1 UCA0_RX     8-7         <---- TX   UARTtoUSB bridge
;                                +--4k7-< DeepRST <-- GND
;                                |            
; P2.0 UCA0_TX     6-5         <-+-> RX   UARTtoUSB bridge
; /RST             4-3
; TEST             2-1
;
;
; P5.6    - sw1                <--- LCD contrast + (finger :-)
; P5.5    - sw2                <--- LCD contrast - (finger ;-)
; RST     - sw3 
;
; P1.0    - led1 red
; P1.1    - led2 green
;
; J1 - left ext.
; 3v3
; P1.2/TA1.1/TA0CLK/COUT/A2/C2 <--- OUT IR_Receiver (1 TSOP32236)     
; P6.1/UCA3RXD/UCA3SOMI        ------------------------->  4 LCD_RS
; P6.0/UCA3TXD/UCA3SIMO        ------------------------->  5 LCD_R/W
; P6.2/UCA3CLK                 ------------------------->  6 LCD_EN0
; P1.3/TA1.2/UCB0STE/A3/C3            
; P5.2/UCB1CLK/TA4CLK
; P6.3/UCA3STE
; P7.1/UCB2SOMI/UCB2SCL        ---> SCL I2C MASTER/SLAVE
; P7.0/UCB2SIMO/UCB2SDA        <--> SDA I2C MASTER/SLAVE
;
; J3 - left int.
; 5V
; GND
; P3.0/A12/C12                 <------------------------> 11 LCD_DB4   
; P3.1/A13/C13                 <------------------------> 12 LCD_DB5
; P3.2/A14/C14                 <------------------------> 13 LCD_DB5
; P3.3/A15/C15                 <------------------------> 14 LCD_DB7
; P1.4/TB0.1/UCA0STE/A4/C4
; P1.5/TB0.2/UCA0CLK/A5/C5     >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)    
; P4.7
; P8.0
;
; J4 - right int.
; P3.7/TB0.6                          
; P3.6/TB0.5                          
; P3.5/TB0.4/COUT                     
; P3.4/TB0.3/SMCLK
; P7.3/UCB2STE/TA4.1
; P2.6/TB0.1/UCA1RXD/UCA1SOMI 
; P2.5/TB0.0/UCA1TXD/UCA1SIMO 
; P4.3/A11
; P4.2/A10       RTS ----> CTS  UARTtoUSB bridge (optional hardware control flow)
; P4.1/A9        CTS <---- RTS  UARTtoUSB bridge (optional hardware control flow)
;
; J2 - right ext.
; GND
; P5.7/UCA2STE/TA4.1/MCLK
; P4.4/TB0.5
; P5.3/UCB1STE
; /RST
; P5.0/UCB1SIMO/UCB1SDA
; P5.1/UCB1SOMI/UCB1SCL
; P8.3
; P8.2                          <--> SDA I2C SOFTWARE MASTER
; P8.1                          <--> SCL I2C SOFTWARE MASTER
;
; SD_CARD
; P7.2/UCB2CLK                        <--- SD_CD
; P1.6/TB0.3/UCB0SIMO/UCB0SDA/TA0.0   ---> SD_MOSI
; P1.7/TB0.4/UCB0SOMI/UCB0SCL/TA1.0   <--- SD_MISO
; P4.0/A8                             ---> SD_CS
; P2.2/TB0.2/UCB0CLK                  ---> SD_CLK
;
; XTAL LF 32768 Hz
; PJ.4/LFXIN
; PJ.5/LFXOUT
;
; XTAL HF
; PJ.6/HFXIN
; PJ.7/HFXOUT


; -----------------------------------------------
; LCD config
; -----------------------------------------------
                                    
;       <-------+---0V0---------->  1 LCD_Vss
;       >------ | --3V6-----+---->  2 LCD_Vdd
;               |           |
;             |___    470n ---
;               ^ |        ---
;              / \ BAT54    |
;              ---          |
;          100n |    2k2    |
; TB0.2 >---||--+--^/\/\/v--+---->  3 LCD_Vo (=0V6 without modulation)
;       ------------------------->  4 LCD_RS
;       ------------------------->  5 LCD_R/W
;       ------------------------->  6 LCD_EN0
;       <------------------------> 11 LCD_DB4
;       <------------------------> 12 LCD_DB5
;       <------------------------> 13 LCD_DB5
;       <------------------------> 14 LCD_DB7



; ----------------------------------------------------------------------
; INIT order : WDT, GPIOs, FRAM, Clock, RTC, REF
; ----------------------------------------------------------------------

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

; PORT1 FastForth usage
; P1.0    - led1 red
; P1.1    - led2 green

; PORTx default wanted state : pins as input with pullup resistor

            BIS #3,&PADIR       ; all pins 0 as input else LEDs
            MOV #0FFFCh,&PAOUT  ; all pins high  else LEDs
            BIC #3,&PAREN       ; all pins 1 with pull resistors else LEDs


; PORT2 FastForth usage

    .IFDEF UCB0_SD ; see device.inc
SD_SEL      .equ PASEL1 ; to configure UCB0
SD_REN      .equ PAREN  ; to configure pullup resistors
SD_BUS      .equ 04C0h  ; pins P2.2 as UCB0CLK, P1.6 as UCB0SIMO & P1.7 as UCB0SOMI
    .ENDIF

    .IFDEF UCA0_TERM ; see device.inc
; P2.0  UCA0-TXD    --> USB2UART RXD    
; P2.1  UCA0-RXD    <-- USB2UART TXD 
TXD         .equ 1      ; P2.0 = TXD + FORTH Deep_RST pin
RXD         .equ 2      ; P2.1 = RXD
TERM_BUS    .equ 3
TERM_IN     .equ P2IN
TERM_SEL    .equ P2SEL1
TERM_REN    .equ P2REN
    .ENDIF

    .IFDEF UCA1_TERM ; see device.inc
; P2.5  UCA0-TXD    --> USB2UART RXD    
; P2.6  UCA0-RXD    <-- USB2UART TXD 
TXD         .equ 20h   ; P2.5 = TXD + FORTH Deep_RST pin
RXD         .equ 40h   ; P2.6 = RXD
TERM_BUS    .equ 60h
TERM_IN     .equ P2IN
TERM_SEL    .equ P2SEL1
TERM_REN    .equ P2REN
    .ENDIF


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT3 FastForth usage

; PORT4 FastForth usage
SD_CS       .equ 1              ; P4.0 as SD_CS     
SD_CSOUT    .equ P4OUT
SD_CSDIR    .equ P4DIR


            MOV #-1,&PBREN      ; REN1 all pullup resistors
            MOV #-1,&PBOUT

    .IFDEF TERMINAL4WIRES
; RTS output is wired to the CTS input of UART2USB bridge 
; configure RTS as output high to disable RX TERM during start FORTH
HANDSHAKOUT .equ    P4OUT
HANDSHAKIN  .equ    P4IN
RTS         .equ    4           ; P4.2
            BIS.B #RTS,&P4DIR   ; RTS as output high
        .IFDEF TERMINAL5WIRES
; CTS input must be wired to the RTS output of UART2USB bridge 
; configure CTS as input low (true) to avoid lock when CTS is not wired
CTS         .equ  8             ; P4.3
            BIC.B #CTS,&P4OUT   ; CTS input pulled down
        .ENDIF  ; TERMINAL5WIRES
    .ENDIF  ; TERMINAL4WIRES

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT5 FastForth usage
; P5.6 Switch S1
; P5.5 Switch S2
SWITCHIN    .set P5IN    ; port
s1          .set 020h    ; P5.5 bit position

    .IFDEF UCB1_SD ; see device.inc
SD_SEL      .equ PCSEL1 ; to configure UCB0
SD_REN      .equ PCREN  ; to configure pullup resistors
SD_BUS      .equ 0007h  ; pins P5.2 as UCB1CLK, P5.0 as UCB1SIMO & P5.1 as UCB1SOMI
    .ENDIF

; PORT6 FastForth usage


; PORTx default wanted state : pins as input with pullup resistor

            MOV #-1,&PCOUT    ; all pins output high
            BIS #-1,&PCREN    ; all pins with pull resistors

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7/8
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORT7 FastForth usage
SD_CD       .equ 4        ; P7.2 as SD_CD
SD_CDIN     .equ P7IN


; PORT8 FastForth usage


; PORTx default wanted state : pins as input with pullup resistor

            MOV #-1,&PDOUT    ; all pins output high
            BIS #-1,&PDREN    ; all pins with pull resistors


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

; reset state : Px{DIR,REN,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; Px{IN,OUT,IES} = ?

; PORTJ FastForth usage

; PORTx default wanted state : pins as input with pullup resistor

            MOV.B #-1,&PJREN    ; enable pullup/pulldown resistors
            BIS.B #-1,&PJOUT    ; pullup resistors


; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

    .IF  FREQUENCY > 8
            MOV.B   #0A5h, &FRCTL0_H    ; enable FRCTL0 access
            MOV.B   #10h, &FRCTL0       ; 1 waitstate @ 16 MHz
            MOV.B   #01h, &FRCTL0_H     ; disable FRCTL0 access
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

; DCOCLK: Internal digitally controlled oscillator (DCO).


; CS code for MSP430FR5948
            MOV.B   #CSKEY,&CSCTL0_H ;  Unlock CS registers

    .IF FREQUENCY = 0.25
;            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1      ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_32 + DIVM_32,&CSCTL3
            MOV     #4,X

    .ELSEIF FREQUENCY = 0.5
            MOV     #0,&CSCTL1                  ; Set 1MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3             ; set all dividers as 2
            MOV     #8,X

    .ELSEIF FREQUENCY = 1
            MOV     #0,&CSCTL1                  ; Set 1MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #16,X

    .ELSEIF FREQUENCY = 2
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_2 + DIVM_2,&CSCTL3
            MOV     #32,X

    .ELSEIF FREQUENCY = 4
            MOV     #DCOFSEL1+DCOFSEL0,&CSCTL1  ; Set 4MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #64,X

    .ELSEIF FREQUENCY = 8
;            MOV     #DCOFSEL2+DCOFSEL1,&CSCTL1  ; Set 8MHZ DCO setting (default value)
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #128,X

    .ELSEIF FREQUENCY = 16
            MOV     #DCORSEL+DCOFSEL2,&CSCTL1   ; Set 16MHZ DCO setting
            MOV     #DIVA_0 + DIVS_0 + DIVM_0,&CSCTL3             ; set all dividers as 0
            MOV     #256,X

    .ELSEIF
    .error "bad frequency setting, only 0.5,1,2,4,8,16 MHz"
    .ENDIF

    .IFDEF LF_XTAL
            MOV     #SELA_LFXCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ELSE
            MOV     #SELA_VLOCLK+SELS_DCOCLK+SELM_DCOCLK,&CSCTL2
    .ENDIF
            MOV.B   #1, &CSCTL0_H   ; Lock CS Registers

            BIS &SYSRSTIV,&SAVE_SYSRSTIV    ; store volatile SYSRSTIV preserving a pending request for DEEP_RST
;            MOV &SAVE_SYSRSTIV,TOS  ;
;            CMP #2,TOS              ; POWER ON ?
;            JZ      ClockWaitX      ; yes
;            RRUM    #2,X            ; no: wait only 125 ms
ClockWaitX  MOV     #5209,Y         ; wait 0.5s before starting after POWER ON
ClockWaitY  SUB     #1,Y            ;1
            JNZ     ClockWaitY      ;2 5209x3 = 15625 cycles delay = 15.625ms @ 1MHz
            SUB     #1,X            ; x 32 @ 1 MHZ = 500ms
            JNZ     ClockWaitX      ; time to stabilize power source ( 500ms )

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : RTC_C REGISTERS
; ----------------------------------------------------------------------

    .IFDEF LF_XTAL ; see device.inc
; LFXIN : PJ.4, LFXOUT : PJ.5
            BIS.B   #010h,&PJSEL0       ; SEL0 for only LFXIN
            MOV.B   #0A5h,&RTCCTL0_H    ; unlock RTC_C
            BIC.B   #RTCHOLD,&RTCCTL1   ; Clear RTCHOLD = start RTC_C
    .ENDIF

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : REF
; ----------------------------------------------------------------------

            MOV   #8, &REFCTL

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION next : see RESET in forthMSP430.asm
; ----------------------------------------------------------------------
