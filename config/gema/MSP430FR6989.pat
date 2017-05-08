!MSP430fr6989.pat

@define{@read{/config/gema/MSP430FR5x6x.pat}}


! ----------------------------------------------
! MSP430FR6989 MEMORY MAP
! ----------------------------------------------
! 0000-0005 = reserved ROM
! 0006-001F = tiny RAM 26 bytes
! 0020-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
! 1800-187F = FRAM info D (128 B)
! 1880-18FF = FRAM info C (128 B)
! 1900-197F = FRAM info B (128 B)
! 1980-19FF = FRAM info A (128 B)
! 1A00-1AFF = TLV device descriptor info (FRAM 256 B)
! 1B00-1BFF = ROM boot memory 
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
INTVECT=\$FFC6!         FFCE-FFFF
BSL_PASSWORD=\$FFE0!    256 bits


AES_Vec=\$FFC6!
RTC_Vec=\$FFC8!
LCD_Vec=\$FFCA!
P4_Vec=\$FFCC!
P3_Vec=\$FFCE!
TA3_x_Vec=\$FFD0!
TA3_0_Vec=\$FFD2!
P2_Vec=\$FFD4!
TA2_x_Vec=\$FFD6!
TA2_0_Vec=\$FFD8!
P1_Vec=\$FFDA!
TA1_x_Vec=\$FFDC!
TA1_0_Vec=\$FFDE!
DMA_Vec=\$FFE0!
eUSCI_B1_Vec=\$FFE2!
eUSCI_A1_Vec=\$FFE4!
TA0_x_Vec=\$FFE6!
TA0_0_Vec=\$FFE8!
ADC12_B_Vec=\$FFEA!
eUSCI_B0_Vec=\$FFEC!
eUSCI_A0_Vec=\$FFEE!
ESI_Vec=\$FFF0!
WDT_Vec=\$FFF2!
TB0_x_Vec=\$FFF4!
TB0_0_Vec=\$FFF6!
COMP_E_Vec=\$FFF8!
U_NMI_Vec=\$FFFA!
S_NMI_Vec=\$FFFC!
RST_Vec=\$FFFE!

