!MSP430fr5969.pat

@define{@read{/config/gema/MSP430FR5x6x.pat}}


!                   \ RTC_B
RTCCTL0=\$4A0!      \ RTC control 0                     
RTCCTL1=\$4A1!      \ RTC control 1                                
RTCCTL2=\$4A2!      \ RTC control 2                              
RTCCTL3=\$4A3!      \ RTC control 3                       
RTCPS0CTL=\$4A8!    \ RTC prescaler 0 control                         
RTCPS1CTL=\$4AA!    \ RTC prescaler 1 control                         
RTCPS0=\$4AC!       \ RTC prescaler 0                                 
RTCPS1=\$4AD!       \ RTC prescaler 1                                 
RTCIV=\$4AE!        \ RTC interrupt vector word                       
RTCSEC=\$4B0!       \ RTC seconds, RTC counter register 1 RTCSEC,     
RTCMIN=\$4B1!       \ RTC minutes, RTC counter register 2 RTCMIN,     
RTCHOUR=\$4B2!      \ RTC hours, RTC counter register 3 RTCHOUR,      
RTCDOW=\$4B3!       \ RTC day of week, RTC counter register 4 RTCDOW, 
RTCDAY=\$4B4!       \ RTC days                                        
RTCMON=\$4B5!       \ RTC month                                       
RTCYEAR=\$4B6!                                       
RTCYEARL=\$4B6!     \ RTC year low                                    
RTCYEARH=\$4B7!     \ RTC year high                                   
RTCAMIN=\$4B8!      \ RTC alarm minutes                               
RTCAHOUR=\$4B9!     \ RTC alarm hours                                 
RTCADOW=\$4BA!      \ RTC alarm day of week                           
RTCADAY=\$4BB!      \ RTC alarm days                                  
BIN2BCD=\$4BC!      \ Binary-to-BCD conversion register               
BCD2BIN=\$4BE!      \ BCD-to-binary conversion register  
RTCHOLD=\$40!
RTCRDY=\$10!

! ----------------------------------------------
! MSP430FR5969 MEMORY MAP
! ----------------------------------------------
! 0000-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
! 1800-187F = FRAM info D (128 B)
! 1880-18FF = FRAM info C (128 B)
! 1900-197F = FRAM info B (128 B)
! 1980-19FF = FRAM info A (128 B)
! 1A00-1AFF = TLV device descriptor info (FRAM 256 B)
! 1B00-1BFF = unused (256 B)
! 1C00-23FF = RAM (2 KB)
! 4400-FF7F = code memory (FRAM 47 kB)
! FF80-FFFF = interrupt vectors (FRAM 127 B)
! ----------------------------------------------
INFOSTART=\$1800!
INFODSTART=\$1800!
INFODEND=\$187F!
INFOCSTART=\$1880!
INFOCEND=\$18FF!
INFOBSTART=\$1900!
INFOBEND=\$197F!
INFOASTART=\$1980!
INFOAEND=\$19FF!
TLVSTAT=\$1A00!         Device Descriptor Info (Tag-Lenght-Value)
TLVEND=\$1AFF! 
RAMSTART=\$1C00!
RAMEND=\$23FF!
PROGRAMSTART=\$4400!    Code space start
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2=\$FF82!       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84!  
BSL_SIG2=\$FF86!  
JTAG_PASSWORD=\$FF88!   256 bits
INTVECT=\$FFCC!         FFCC-FFFF
BSL_PASSWORD=\$FFE0!    256 bits

AES_Vec=\$FFCC!
RTC_Vec=\$FFCE!
P4_Vec=\$FFD0!
P3_Vec=\$FFD2!
TA3_x_Vec=\$FFD4!
TA3_0_Vec=\$FFD6!
P2_Vec=\$FFD8!
TA2_x_Vec=\$FFDA!
TA2_0_Vec=\$FFDC!
P1_Vec=\$FFDE!
TA1_x_Vec=\$FFE0!
TA1_0_Vec=\$FFE2!
DMA_Vec=\$FFE4!
eUSCI_A1_Vec=\$FFE6!
TA0_x_Vec=\$FFE8!
TA0_0_Vec=\$FFEA!
ADC12_B_Vec=\$FFEC!
eUSCI_B0_Vec=\$FFEE!
eUSCI_A0_Vec=\$FFF0!
WDT_Vec=\$FFF2!
TB0_x_Vec=\$FFF4!
TB0_0_Vec=\$FFF6!
COMP_D_Vec=\$FFF8!
U_NMI_Vec=\$FFFA!
S_NMI_Vec=\$FFFC!
RST_Vec=\$FFFE!

