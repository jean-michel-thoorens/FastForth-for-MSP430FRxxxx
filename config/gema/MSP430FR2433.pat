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


TA0CTL=\$380!       \ TA0 control                 
TA0CCTL0=\$382!     \ Capture/compare control 0   
TA0CCTL1=\$384!     \ Capture/compare control 1   
TA0CCTL2=\$386!     \ Capture/compare control 2   
TA0R=\$390!         \ TA0 counter register        
TA0CCR0=\$392!      \ Capture/compare register 0  
TA0CCR1=\$394!      \ Capture/compare register 1  
TA0CCR2=\$396!      \ Capture/compare register 2  
TA0EX0=\$3A0!       \ TA0 expansion register 0    
TA0IV=\$3AE!        \ TA0 interrupt vector        

TA1CTL=\$3C0!       \ TA1 control                 
TA1CCTL0=\$3C2!     \ Capture/compare control 0   
TA1CCTL1=\$3C4!     \ Capture/compare control 1   
TA1CCTL2=\$3C6!     \ Capture/compare control 2   
TA1R=\$3D0!         \ TA1 counter register        
TA1CCR0=\$3D2!      \ Capture/compare register 0  
TA1CCR1=\$3D4!      \ Capture/compare register 1  
TA1CCR2=\$3D6!      \ Capture/compare register 2  
TA1EX0=\$3E0!       \ TA1 expansion register 0    
TA1IV=\$3EE!        \ TA1 interrupt vector        

TA2CTL=\$400!       \ TA2 control                 
TA2CCTL0=\$402!     \ Capture/compare control 0   
TA2CCTL1=\$404!     \ Capture/compare control 1   
TA2R=\$410!         \ TA2 counter register        
TA2CCR0=\$412!      \ Capture/compare register 0  
TA2CCR1=\$414!      \ Capture/compare register 1  
TA2EX0=\$420!       \ TA2 expansion register 0    
TA2IV=\$42E!        \ TA2 interrupt vector        

TA3CTL=\$440!       \ TA3 control                 
TA3CCTL0=\$442!     \ Capture/compare control 0   
TA3CCTL1=\$444!     \ Capture/compare control 1   
TA3R=\$450!         \ TA3 counter register        
TA3CCR0=\$452!      \ Capture/compare register 0  
TA3CCR1=\$454!      \ Capture/compare register 1  
TA3EX0=\$460!       \ TA3 expansion register 0    
TA3IV=\$46E!        \ TA3 interrupt vector        

