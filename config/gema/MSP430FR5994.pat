!MSP430fr5994.pat

@define{@read{/config/gema/MSP430FR5x6x.pat}}


! ----------------------------------------------
! MSP430FR5994 MEMORY MAP
! ----------------------------------------------
! 000A-001F = tiny RAM
! 0020-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
! 1800-187F = FRAM info D (128 B)
! 1880-18FF = FRAM info C (128 B)
! 1900-197F = FRAM info B (128 B)
! 1980-19FF = FRAM info A (128 B)
! 1A00-1AFF = FRAM TLV device descriptor info (256 B)
! 1B00-1BFF = unused (256 B)
! 1C00-2BFF = RAM (4KB)
! 2C00-3BFF = sharedRAM (4kB)
! 4400-FF7F = FRAM code memory (FRAM) (MSP430FR59x8/9)
! 8000-FF7F = FRAM code memory (FRAM) (MSP430FR59x7/8/9)
! FF80-FFFF = FRAM interrupt vectors and signatures (FRAM)

! ----------------------------------------------
! PAGESIZE        .equ 512         ; MPU unit
! ----------------------------------------------
! BSL                         
! ----------------------------------------------
BSL=\$1000!
! ----------------------------------------------
! FRAM                          ; INFO B, A, TLV
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
TLVSTART=\$1A00!        Device Descriptor Info (Tag-Lenght-Value)
TLVEND=\$1AFF!
! ----------------------------------------------
! RAM
! ----------------------------------------------
TinyRAM=\$0A!
TinyRAMEnd=\$1F!
RAMSTART=\$1C00!
RAMEND=\$2BFF!
SharedRAMSTART=\$2C00!
SharedRAMEND=\$3BFF!
! ----------------------------------------------
! FRAM
! ----------------------------------------------
PROGRAMSTART=\$4000!    Code space start
!FRAMEND=\$43FFF!       256 k FRAM
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0, enable JTAG/SBW
JTAG_SIG2=\$FF82!       if JTAG_SIG1=\$AAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1=\$FF84!     
BSL_SIG2=\$FF86!     
JTAG_PASSWORD=\$FF88!   256 bits max
IPE_SIG_VALID=\$FF88!   one word
IPE_STR_PTR_SRC=\$FF8A! one word
INTVECT=\$FFB4!         FFB4-FFFF
BSL_PASSWORD=\$FFE0!    256 bits


LEA_Vec=\$FFB4!
P8_Vec=\$FFB6!
P7_Vec=\$FFB8!
eUSCI_B3_Vec=\$FFBA!
eUSCI_B2_Vec=\$FFBC!
eUSCI_B1_Vec=\$FFBE!
eUSCI_A3_Vec=\$FFC0!
eUSCI_A2_Vec=\$FFC2!
P6_Vec=\$FFC4!
P5_Vec=\$FFC6!
TA4_x_Vec=\$FFC8!
TA4_0_Vec=\$FFCA!
AES_Vec=\$FFCC!
RTC_C_Vec=\$FFCE!
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
COMP_E_Vec=\$FFF8!
U_NMI_Vec=\$FFFA!
S_NMI_Vec=\$FFFC!
RST_Vec=\$FFFE!
