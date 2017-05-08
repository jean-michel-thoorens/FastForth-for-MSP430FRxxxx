!MSP430fr5948.pat

@define{@read{/config/gema/MSP430FR5x6x.pat}}

! ----------------------------------------------
! MSP430fr5948 MEMORY MAP
! ----------------------------------------------
! 0000-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
! 1800-187F = info D (FRAM 128 B)
! 1880-18FF = info C (FRAM 128 B)
! 1900-197F = info B (FRAM 128 B) 
! 1980-19FF = info A (FRAM 128 B) 
! 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
! 1A80-1BFF = unused (385 B)
! 1C00-23FF = RAM (2 KB)
! 2000-C1FF = unused (41472 B)
! C200-FF7F = code memory (FRAM 15743 B)
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
INFOEND=\$19FF!
TLVSTAT=\$1A00!         Device Descriptor Info (Tag-Lenght-Value)
TLVEND=\$1A7F! 
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
TB2_x_Vec=\$FFD4!
TB2_0_Vec=\$FFD6!
P2_Vec=\$FFD8!
TB1_x_Vec=\$FFDA!
TB1_0_Vec=\$FFDC!
P1_Vec=\$FFDE!
TA1_x_Vec=\$FFE0!
TA1_0_Vec=\$FFE2!
DMA_Vec=\$FFE4!
eUSCI_A1_Vec=\$FFE6!
TA0_x_Vec=\$FFE8!
TA0_0_Vec=\$FFEA!
ADC10_B_Vec=\$FFEC!
eUSCI_B0_Vec=\$FFEE!
eUSCI_A0_Vec=\$FFF0!
WDT_Vec=\$FFF2!
TB0_x_Vec=\$FFF4!
TB0_0_Vec=\$FFF6!
COMP_D_Vec=\$FFF8!
U_NMI_Vec=\$FFFA!
S_NMI_Vec=\$FFFC!
RST_Vec=\$FFFE!

