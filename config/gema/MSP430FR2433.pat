!MSP430FR2433.pat

@define{@read{/config/gema/MSP430FR2x4x.pat}}

! ----------------------------------------------
! MSP430FR2433 MEMORY MAP
! ----------------------------------------------
! 0000-0FFF = peripherals (4 KB)
! 1000-17FF = ROM bootstrap loader BSL1 (2k)
! 1800-19FF = info B (FRAM 512 B)
! 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
! 1A80-1FFF = unused
! 2000-2FFF = RAM (4 KB)
! 2800-C3FF = unused
! C400-FF7F = code memory (FRAM 15232 B)
! FF80-FFFF = interrupt vectors (FRAM 128 B)
! FFC00-FFFFF = BSL2 (2k)
! ----------------------------------------------
!PAGESIZE        .equ 512         ; MPU unit
! ----------------------------------------------
! BSL                           
! ----------------------------------------------
BSL1=\$1000!
BSL2=\$FFC00!
! ----------------------------------------------
! FRAM                          ; INFO B, TLV
! ----------------------------------------------
INFOSTART =\$1800!
INFOBSTART=\$1800!
INFOBEND=\$19FF!
INFOEND=\$19FF!
TLVSTART=\$1A00!    Device Descriptor Info (Tag-Lenght-Value)
TLVEND=\$1A7F!
! ----------------------------------------------
! RAM
! ----------------------------------------------
RAMSTART=\$2000!
RAMEND=\$2FFF!
! ----------------------------------------------
! FRAM
! ----------------------------------------------
PROGRAMSTART=\$C400!    Code space start
SIGNATURES=\$FF80!      JTAG/BSL signatures
JTAG_SIG1=\$FF80!       if 0 (electronic fuse=0) enable JTAG/SBW ; reset by wipe and by S1+<reset>
JTAG_SIG2=\$FF82!       if JTAG_SIG <> |\$FFFFFFFF, \$00000000|, SBW and JTAG are locked
BSL_SIG1=\$FF84!        
BSL_SIG2=\$FF86!        
JTAG_PASSWORD=\$FF88!   256 bits
INTVECT=\$FFDA!         FFDA-FFFF
BSL_PASSWORD=\$FFE0!    256 bits
! ----------------------------------------------


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

