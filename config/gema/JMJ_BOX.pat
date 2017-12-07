! -*- coding: utf-8 -*-
! JMJ_BOX.pat
!
! Fast Forth for JMJ-BOX
!
! Copyright (C) <2016>  <J.M. THOORENS>
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.
!
!
!
! ======================================================================
! MSP430FR5738 Config
! ======================================================================

@define{@read{@mergepath{@inpath{};MSP430FR5738.pat;}}}
@define{@read{@mergepath{@inpath{};MSP430FR57xx_FastForth.pat;}}}
@define{@read{@mergepath{@inpath{};FastForthREGtoTI.pat;}}}
@define{@read{@mergepath{@inpath{};RemoveComments.pat;}}}

! ======================================================================
! JMJ-BOX board
! ======================================================================
! -------------------------------
! PORTA (PORT2:1) default values  DIR0,REN1,OUT1 (input with pullup resistors)
! -------------------------------
! 18 RST   <------- PROG.4 ---------> Prog6pins RST 
! 17 TST   <------- PROG.3 ---------> Prog6pins TST 
!  5 P1.0  >------- OUT.9 ----------> STBY_A
!  6 P1.1 
!  7 P1.2  <------- LOCAL <---------- ADC_BAT
!  8 P1.3  <------- LOCAL <---------- GND
!  9 P1.4  <------- LOCAL <---------- ADC_REF
! 10 P1.5  <------- LOCAL <---------- ADC_OUT
! 22 P1.6  <------> OUT.5 <---------> MSDA
! 23 P1.7  -------> OUT.4 ----------> MSCL
!
!                            +-4k7--< DeepRST <-- GND
!                            |
! 19 P2.0  -------> PROG.1 --+------> Prog6pins TX0  
! 20 P2.1  <------- PROG.6 <--------- Prog6pins RX0  
! 21 P2.2  <------- OUT.8 <---------- IR_RC5
! 27 P2.3  <------- OUT.2 <---------- PLUS_CAP 
! 28 P2.4  <------- OUT.3 <---------- MINUS_CAP
! 16 P2.6  <------- LOCAL <---------- MIC
! 15 P2.5  <------- LOCAL <---------- AUX
! 11 PJ.0
! 12 PJ.1
! 13 PJ.2  -------> LOCAL ----------> MUTE_PA
! 14 PJ.3  -------> LOCAL ----------> STBY_PA
!  1 PJ.4  <------- LOCAL <---------- XT1 
!  2 PJ.5  -------> LOCAL ----------> XT2  

! ============================================
! FORTH I/O :
! ============================================

TERM_REN=\$207!
TERM_SEL=\$20D!
TERM_IE=\$21B!
TERM_IFG=\$21D!
Deep_RST=1!         ; P2.0 = TX
Deep_RST_IN=\$201!  ; TERMINAL TX  pin as FORTH Deep_RST


! ============================================
! APPLICATION I/O :
! ============================================

! PORT 1 use

STBY_A=1!       P1.0    AMPLI output

ADC_BAT=2!      P1.2    ADC inputs
ADC_GND=3!      P1.3
ADC_REF=4!      P1.4
ADC_OUT=5!      P1.5

MSDA=\$40!      P1.6    I2C master SDA   
MSCL=\$80!      P1.7    I2C master SCL   
I2CM_BUS=\$C0!  MASK    

! PORT 2 use

TERM_TX=1!      P2.0    TERMINAL TX
TERM_RX=2!      P2.1    TERMINAL RX

IR_RC5=4!       P2.2    IR_RC5 input

PLUS_CAP=8!     P2.3    CAPACITIVE KEY +
MINUS_CAP=\$10! P2.4    CAPACITIVE KEY -
CAP_IO=\$18!    MASK

!AUX=\$20!       P2.5    COMBO TRS switch
!MIC=\$40!       P2.6    COMBO XLR switch
!COMBO=\$60!     MASK

! PORT J use

MUTE_PA=4!      PJ.2    output
STBY_PA=8!      PJ.3    output
OUT_PA=\$0C!    MASK



! FRAM variables

wROMGAIN=\$1818!        word EEPROM variable 
bROMMICGAIN=\$1818!     byte
bROMAUXGAIN=\$1819!     byte



! GPFLAGS

GPFLAGS=\$181A!     General Purpose FLAGS in FRAM to keep flags during reset

RELEASE=1!      \ ALC release
ATTACK=2!       \ ALC attack 
ALC_FLAGS=3!

BAT_IS_OK=4! 

PLUS_FLAG=8!        \ Human command PLUS, same position as PLUS_CAP
MINUS_FLAG=\$10!    \ Human command MINUS, same position as MINUS_CAP
OK_FLAG=\$20!       \ human command OK 
PMO_FLAGS=\$38!     \ 3 human commands: Plus Minus Ok
CHNG=\$40!          \ request to change gain or gain is modified, ready to do OK

SAVE=\$80!          \ request to Save gain in ROM (FRAM)

PLAY_ON=\$100!      \ System is ON / off
COMBO_MIC=\$400!    \ switch MIC / aux for DEF gain definition

! tests flags
TEST_FLAG=\$800!    \
NO_BAT_FLAG=\$1000! \ simulate bat is OK

WDT_FLAG=\$2000!     
ADC_FLAG=\$4000!
P2INT_FLAG=\$8000!
TEST_FLAGS=\$F800!  BIC MASK to reset tests
START_FLAGS=\$F804! AND MASK to reset other flags than (tests + BAT) flags during START




!RAM usage, 32 bytes free @ $1DDE 
!================================
PRS=\$1DDE!             \ Pseudo Registers Structure : x(IP)
&wRAMGAIN=0(R13)!       \ word
&bRAMMICGAIN=0(R13)!    \ byte
&bRAMAUXGAIN=1(R13)!    \ byte
&bALCTIME=2(R13)!       \ byte
&bCAPKEYTIME=3(R13)!    \ byte
&bDISPLAYTIME=4(R13)!   \ byte
&bSTARTTIME=5(R13)!     \ byte
&bNGTIME=6(R13)!        \ byte
&bGAIN=7(R13)!          \ byte
&bPOTAR=8(R13)!         \ byte
&bCONFPOT=9(R13)!       \ byte
&wBATDIVSIX=10(R13)!    \ word
&wADCREF=12(R13)!       \ word
&wSTBYTIME=14(R13)!     \ word

I2CM_BUF=\$1DF0!        \ I2CS_addr,not_exchanged,count,data1,data2,data3
I2C_ADR=0! I2C_ADR & R/w bit
BUF_EXG=1! bytes count eXchanGed
BUF_CNT=2! bytes count requested 
BUF_TX1=3!
BUF_TX2=4!
BUF_TX3=5!
BUF_RX1=3!
BUF_RX2=4!
BUF_RX3=5!




!=================
! System constants
!=================

VISUAL_ACK=\$0F!    !   \ ROM_LED offset

! I2C slave addresses + write flag
!---------------------------------
PCA9574A_ADR=\%01110000!    \ 1<<PCA8574A_address 8 bits GPIO
DS1881_ADR=\%01010000!      \ 1<<DS1881_I2C_potar_address

!WATCHDOG TA0CCR0 values
!-----------------------
WDTDEBOUNCE=#11!    !   \ 5.5ms*11=60ms     ; debounce time for COMBO activity
!WDTDEBOUNCE=#6!        \ 5.5ms*11=60ms     ; debounce time for COMBO activity
WDTTICKON=6!        !   \ 5.5ms*6=33ms      ; System_is_ON state Watchdog 
!WDTTICKOFF=#65535!     \ 5.5ms*65535=6'    ; System_is_OFF or BAT_IS_KO states Watchdog
WDTTICKOFF=#10910!     \ 5.5ms*10910=1'    ; System_is_OFF or BAT_IS_KO states Watchdog
!WDTTICKOFF=#182!    !   \ 5.5ms*182=1s      ; System_is_OFF and BOT_IS_KO states Watchdog, test value
!WDTTICKALC=9!          \ 5.5ms*9=50ms      ; ALC release time = 20dB/s
WDTTICKALC=6!       !   \ 5.5ms*6=33ms      ; ALC release time = 30dB/s
!WDTTICKALC=5!          \ 5.5ms*5=28ms      ; ALC release time = 36dB/s
!WDTTICKALC=4!          \ 5.5ms*4=22ms      ; ALC release time = 45dB/s
!WDTTICKALC=4!          \ 5.5ms*3=16ms      ; ALC release time = 60dB/s
!                                           ; ROHM BD5465 ALC release = 4dB/s 
!                                           ; ONSEMI LC75106V ALC release = 4dB/s for ALC attack = 60dB/s
!                                           ; ANALOGSSM2804 ALC release = 4dB/s  for ALC attack = 1200dB/s (default values)


!TIME VALUES
!-----------
!NGTEMP=\#120!          \ 33ms*120=4s       ; Noise Gate time
!NGTEMP=\#30!        !   \ 33ms*30=1s        ; Noise Gate time
!NGTEMP=\#15!           \ 33ms*15=500ms     ; Noise Gate time
NGTEMP=\#6!             \ 33ms*6 =200ms     ; Noise Gate time
ALCTEMP=1!          !   \ 33ms=33ms         ; ALC release base time 30dB/s (= ALC ON/OFF !)
CAPKEYTEMP=5!       !   \ 33ms*5=165ms      ; enable one human request by time slice (RC5 message = 140ms)
!CAPKEYTEMP=6!          \ 33ms*6=200ms      ; enable one human request by time slice (RC5 message = 140ms)
DISPLAYTEMP=\#40!   !   \ 33ms*60=2s        ; display time
STARTTEMP=\#60!     !   \ 33ms*60=2s        ; start time
STBYTEMP=\#9000!    !   \ 33ms*30*60*5 = 5' : standby ampli time value

!GAIN
!----
MINMICGAIN=\#12!    !   \ 12dB : (G=4)
DEFMICGAIN=\#20!    !   \ 20dB : middle value (G=40)
MAXMICGAIN=\#49!    !   \ 49dB : max value (G=250) + 1

MINAUXGAIN=0!       !   \ 0dB
DEFAUXGAIN=\#12!    !   \ 12dB to compensate input divisor ==> effective AUX gain = 0dB
MAXAUXGAIN=\#37!    !   \ 37dB : max value + 1

!BATTERY
!-------
CELLBATKO=\$239!    !   \ =int(12*1024/6/3.6)=569 ; 12 V = LiFePO4 battery out of use threshold
!CELLBATOK=\$298!       \ =int(14*1024/6/3.6)=664 ; 14 V = high return value to force recharging (obsolete)
CELLBATOK=\$284!    !   \ =int(13.6*1024/6/3.6)=644 ; 13V6 V = high return for test with 13.8V supply

!NOISE GATE LEVEL
!----------------
!NGLVL=1!               \ 1*3.6/1024 = 3.5mVcrete = 2.5mVeff = -52dB
NGLVL=2!            !   \ 2*3.6/1024 = 7mVcrete = 5mVeff = -46dB
!NGLVL=4!               \ 4*3.6/1024 = 14mVcrete = 10mVeff = -40dB





