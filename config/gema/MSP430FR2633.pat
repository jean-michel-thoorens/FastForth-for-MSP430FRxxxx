!MSP430FR2633.pat

@define{@read{/config/gema/MSP430FR2x4x.pat}}

! ----------------------------------------------
! MSP430FR2633 MEMORY MAP
! ----------------------------------------------
! 0000-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL1 (4x512 B)
! 1800-187F = info B (FRAM 128 B)
! 1880-18FF = info A (FRAM 128 B)
! 1900-19FF = N/A (mirrored into info A/B)
! 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
! 2000-2FFF = RAM (4 KB)
! 4000-6FFF = ROM captivate (12 k)
! C400-FF7F = code memory (FRAM 15232 B)
! FF80-FFFF = interrupt vectors (FRAM 127 B)
! ----------------------------------------------
INFOSTART=\$1800!
INFOBSTART=\$1800!
INFOBEND=\$19FF!
INFOEND=\$19FF!
TLVSTAT=\$1A00!         Device Descriptor Info (Tag-Lenght-Value)
TLVEND=\$1A7F! 
RAMSTART=\$2000!
RAMEND=\$2FFF!
PROGRAMSTART=\$C400!    Code space start
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2=\$FF82!       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84!  
BSL_SIG2=\$FF86!  
JTAG_PASSWORD=\$FF88!   256 bits
INTVECT=\$FFD8!         FFD8-FFFF
BSL_PASSWORD=\$FFE0!    256 bits


CAPTIVATE_Vec=\$FFD8!
P2_Vec=\$FFDA!
P1_Vec=\$FFDC!
ADC10_B_Vec=\$FFDE!
eUSCI_B0_Vec=\$FFE0!
eUSCI_A1_Vec=\$FFE2!
eUSCI_A0_Vec=\$FFE4!
WDT_Vec=\$FFE6!
RTC_Vec=\$FFE8!
TA3_x_Vec=\$FFEA!
TA3_0_Vec=\$FFEC!
TA2_x_Vec=\$FFEE!
TA2_0_Vec=\$FFF0!
TA1_x_Vec=\$FFF2!
TA1_0_Vec=\$FFF4!
TA0_x_Vec=\$FFF6!
TA0_0_Vec=\$FFF8!
U_NMI_Vec=\$FFFA!
S_NMI_Vec=\$FFFC!
RST_Vec=\$FFFE!

