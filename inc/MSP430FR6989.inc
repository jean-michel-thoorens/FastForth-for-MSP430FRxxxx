; MSP430FR6989.inc
; MSP430FR6989  minimal declarations for FastForth usage
    .save
    .listing off

DEVICE = "MSP430FR6989"


; ----------------------------------------------
; MSP430FR6989 MEMORY MAP
; ----------------------------------------------

; 0020-0FFF = peripherals (4 KB)
; 1000-17FF = BootStrap Loader BSL0..3 (ROM 4x512 B)
; 1800-187F = info D (FRAM 128 B)
; 1880-18FF = info C (FRAM 128 B)
; 1900-197F = info B (FRAM 128 B)
; 1980-19FF = info A (FRAM 128 B)
; 1A00-1AFF = TLV device descriptor info (FRAM 256 B)
; 1B00-1BFF = Boot memory (ROM 256 B)
; 1C00-23FF = RAM (2 KB)
; 2000-43FF = unused
; 4400-FF7F = code memory (FRAM 47999 B)
; FF80-FFFF = interrupt vectors (FRAM 128 B)
; 10000-23FFF = FRAM
; ----------------------------------------------
PAGESIZE       .equ 512         ; MPU unit
; ----------------------------------------------
; FRAM                          ; INFO{D,C,B,A},TLV
; ----------------------------------------------
INFO_ORG        .equ 01800h
INFO_LEN        .equ 00200h
INFOD_ORG       .equ 01800h
INFOD_LEN       .equ 00080h
INFOC_ORG       .equ 01880h
INFOC_LEN       .equ 00080h
INFOB_ORG       .equ 01900h
INFOB_LEN       .equ 00080h
INFOA_ORG       .equ 01980h
INFOA_LEN       .equ 00080h
TLV_ORG         .equ 01A00h      ; Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN         .equ 00100h      ;
; ----------------------------------------------
; RAM
; ----------------------------------------------
RAM_ORG         .equ 01C00h
RAM_LEN         .equ 00800h
; ----------------------------------------------
; FRAM
; ----------------------------------------------
MAIN_ORG        .equ 04400h      ; Code space start
MAIN_LEN        .equ 1FC00h      ; 127 k FRAM
; ----------------------------------------------
; Interrupt Vectors and signatures
; ----------------------------------------------
SIGNATURES      .equ 0FF80h      ; JTAG, BSL and IP Encapsulation signatures 1 and 2
JTAG_SIG1       .equ 0FF80h      ; if 0, enable JTAG/SBW
JTAG_SIG2       .equ 0FF82h      ; if JTAG_SIG1=0xAAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1        .equ 0FF84h      ;
BSL_SIG2        .equ 0FF86h      ;
JTAG_PASSWORD   .equ 0FF86h      ; up to 0FFC5h : 256 bits
I2CSLA0         .equ 0FFA2h      ; UCBxI2COA0 default value address 
I2CSLA1         .equ 0FFA4h      ; UCBxI2COA1 default value address
I2CSLA2         .equ 0FFA6h      ; UCBxI2COA2 default value address
I2CSLA3         .equ 0FFA8h      ; UCBxI2COA3 default value address
VECT_ORG        .equ 0FFC6h      ; FFC6-FFFF
VECT_LEN        .equ 3Ah
BSL_PASSWORD    .equ 0FFE0h      ; up to 0FFFFh : 256 bits
; ----------------------------------------------
;
;   .org JTAG_PASSWORD      ;Start of JTAG PASSWORD
;
;    .org    INTVECT         ; FFC6-FFFF 28 vectors + reset
;        .word  reset        ; 0FFC6h  -  AES
;        .word  reset        ; 0FFC8h  -  RTC_C
;        .word  reset        ; 0FFCAh  -  LCD_C
;        .word  reset        ; 0FFCCh  -  I/O Port 4
;        .word  reset        ; 0FFCEh  -  I/O Port 3
;        .word  reset        ; 0FFD0h  -  TA3_x
;        .word  reset        ; 0FFD2h  -  TA3_0
;        .word  reset        ; 0FFD4h  -  I/O Port P2
;        .word  reset        ; 0FFD6h  -  TA2_x
;        .word  reset        ; 0FFD8h  -  TA2_0
;        .word  reset        ; 0FFDAh  -  I/O Port P1
;        .word  reset        ; 0FFDCh  -  TA1_x
;        .word  reset        ; 0FFDEh  -  TA1_0
;;    .org BSL_PASSWORD      ;Start of BSL PASSWORD
;        .word  reset        ; 0FFE0h  -  DMA
;        .word  reset        ; 0FFE2h  -  eUSCI_B1
;        .word  reset        ; 0FFE4h  -  eUSCI_A1
;        .word  reset        ; 0FFE6h  -  TA0_x
;        .word  reset        ; 0FFE8h  -  TA0_0
;        .word  reset        ; 0FFEAh  -  ADC12_B
;        .word  reset        ; 0FFECh  -  eUSCI_B0
;        .word  reset        ; 0FFEEh  -  eUSCI_A0
;        .word  reset        ; 0FFF0h  -  Extended Scan IF
;        .word  reset        ; 0FFF2h  -  Watchdog
;        .word  reset        ; 0FFF4h  -  TB0_x
;        .word  reset        ; 0FFF6h  -  TB0_0
;        .word  reset        ; 0FFF8h  -  COMP_E
;        .word  reset        ; 0FFFAh  -  userNMI
;        .word  reset        ; 0FFFCh  -  sysNMI
;        .word  reset        ; 0FFFEh  -  reset




; ----------------------------------------------------------------------
; EXP430FR6989 Peripheral File Map
; ----------------------------------------------------------------------
SFR_SFR         .set 0100h           ; Special function
PMM_SFR         .set 0120h           ; PMM
FRAM_SFR        .set 0140h           ; FRAM control
CRC16_SFR       .set 0150h
RAMC_SFR        .set 0158h           ; RAM controller
WDT_A_SFR       .set 015Ch           ; Watchdog
CS_SFR          .set 0160h           ; Clock System
SYS_SFR         .set 0180h           ; SYS
REF_SFR         .set 01B0h           ; shared REF
PA_SFR          .set 0200h           ; PORT1/2
PB_SFR          .set 0220h           ; PORT3/4
PC_SFR          .set 0240h           ; PORT5/6
PD_SFR          .set 0260h           ; PORT7/8
PE_SFR          .set 0280h           ; PORT9/10
PJ_SFR          .set 0320h           ; PORTJ
TA0_SFR         .set 0340h
TA1_SFR         .set 0380h
TB0_SFR         .set 03C0h
TA2_SFR         .set 0400h
CTIO0_SFR       .set 0430h           ; Capacitive Touch IO
TA3_SFR         .set 0440h
CTIO1_SFR       .set 0470h           ; Capacitive Touch IO
RTC_C_SFR       .set 04A0h
MPY_SFR         .set 04C0h
DMA_CTRL_SFR    .set 0500h
DMA_CHN0_SFR    .set 0510h
DMA_CHN1_SFR    .set 0520h
DMA_CHN2_SFR    .set 0530h
MPU_SFR         .set 05A0h           ; memory protect unit
eUSCI_A0_SFR    .set 05C0h           ; eUSCI_A0
eUSCI_A1_SFR    .set 05E0h           ; eUSCI_A1
eUSCI_B0_SFR    .set 0640h           ; eUSCI_B0
eUSCI_B1_SFR    .set 0680h           ; eUSCI_B1
ADC12_B_SFR     .set 0800h
COMP_E_SFR      .set 08C0h
CRC32_SFR       .set 0980h
AES_SFR         .set 09C0h
LCD_SFR         .set 0A00h
ESI_SFR         .set 0D00h
ESI_RAM         .set 0E00h          ; 128 bytes


UCSWRST         .equ 1  ; eUSCI Software Reset
UCTXIE          .equ 2  ; eUSCI Transmit Interrupt Enable
UCRXIE          .equ 1  ; eUSCI Receive Interrupt Enable
UCTXIFG         .equ 2  ; eUSCI Transmit Interrupt Flag
UCRXIFG         .equ 1  ; eUSCI Receive Interrupt Flag


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------
SFRIE1      .equ SFR_SFR
SFRIFG1     .equ SFR_SFR + 2
SFRRPCR     .equ SFR_SFR + 4

PMMCTL0     .set PMM_SFR
PMMSWBOR    .set 4

PM5CTL0     .set PMM_SFR + 10h    ; Power mode 5 control register 0
LOCKLPM5    .set 1

; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------
FRCTL0          .set FRAM_SFR + 00h   ; FRAM Controller Control 0
FRCTL0_H        .set FRAM_SFR + 01h   ; FRAM Controller Control 0 high byte

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

WDTCTL      .equ WDT_A_SFR + 00h    ; Watchdog Timer Control */

; WDTCTL Control Bits
WDTPW       .equ 5A00h
WDTHOLD     .equ 0080h  ; WDT - Timer hold
WDTCNTCL    .equ 0008h  ; WDT timer counter clear

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

CSCTL0          .equ CS_SFR + 00h  	; CS Control Register 0
CSCTL0_H        .equ CS_SFR + 01h  	; CS Control Register 0 high byte
CSCTL1          .equ CS_SFR + 02h  	; CS Control Register 1
CSCTL2          .equ CS_SFR + 04h  	; CS Control Register 2
CSCTL3          .equ CS_SFR + 06h  	; CS Control Register 3

; CSCTL0 Control Bits
CSKEY           .equ 0A5h           ; CS Password
; CSCTL1 Control Bits
DCORSEL         .equ 0040h
DCOFSEL0        .equ 0002h           ; DCO frequency select Bit: 0
DCOFSEL1        .equ 0004h           ; DCO frequency select Bit: 1
DCOFSEL2        .equ 0008h           ; DCO frequency select Bit: 2
DCOFSEL3        .equ 000Ch           ; DCO frequency select Bit: 21
; CSCTL2 Control Bits
SELA_LFXCLK     .equ 0000h           ; 0 : ACLK Source Select LFXCLK
SELA_VLOCLK     .equ 0100h           ; 1 ACLK Source Select VLOCLK 10kHz
SELS_DCOCLK     .equ 0030h           ; 3 : SMCLK Source Select DCOCLK
SELM_DCOCLK     .equ 0003h           ; 3 : MCLK Source Select DCOCLK
; CSCTL3 Control Bits
DIVA_0          .equ 0000h           ; ACLK Source Divider 0
DIVS_0          .equ 0000h           ; SMCLK Source Divider 0
DIVM_0          .equ 0000h           ; MCLK Source Divider 0
DIVA_2          .equ 0100h           ; ACLK Source Divider 0
DIVS_2          .equ 0010h           ; SMCLK Source Divider 0
DIVM_2          .equ 0001h           ; MCLK Source Divider 0
DIVA_4          .equ 0200h           ; ACLK Source Divider 0
DIVS_4          .equ 0020h           ; SMCLK Source Divider 0
DIVM_4          .equ 0002h           ; MCLK Source Divider 0
DIVA_8          .equ 0300h           ; ACLK Source Divider 0
DIVS_8          .equ 0030h           ; SMCLK Source Divider 0
DIVM_8          .equ 0003h           ; MCLK Source Divider 0
DIVA_16         .equ 0400h           ; ACLK Source Divider 0
DIVS_16         .equ 0040h           ; SMCLK Source Divider 0
DIVM_16         .equ 0004h           ; MCLK Source Divider 0
DIVA_32         .equ 0500h           ; ACLK Source Divider 0
DIVS_32         .equ 0050h           ; SMCLK Source Divider 0
DIVM_32         .equ 0005h           ; MCLK Source Divider 0

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : SYS REGISTERS
; ----------------------------------------------------------------------

SYSUNIV     .equ SYS_SFR + 001Ah
SYSSNIV     .equ SYS_SFR + 001Ch
SYSRSTIV    .equ SYS_SFR + 001Eh

; SYS Control Bits
; ...
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : REF
; ----------------------------------------------------------------------

REFCTL      equ REF_SFR + 00h       ; REF Shared Reference control register 0

; REFCTL0 Control Bits
REFON       equ 0001h               ; REF Reference On
REFTCOFF    equ 0008h               ; REF Temp.Sensor off

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

PAIN        .equ PA_SFR + 00h    ; Port A INput
PAOUT       .equ PA_SFR + 02h    ; Port A OUTput
PADIR       .equ PA_SFR + 04h    ; Port A DIRection
PAREN       .equ PA_SFR + 06h    ; Port A Resistor ENable
PASEL0      .equ PA_SFR + 0Ah    ; Port A SELection 0
PASEL1      .equ PA_SFR + 0Ch    ; Port A SELection 1
PASELC      .equ PA_SFR + 16h    ; Port A SELection Complement
PAIES       .equ PA_SFR + 18h    ; Port A Interrupt Edge Select
PAIE        .equ PA_SFR + 1Ah    ; Port A Interrupt Enable
PAIFG       .equ PA_SFR + 1Ch    ; Port A Interrupt FlaG

P1IN        .equ PA_SFR + 00h    ; Port 1 INput
P1OUT       .equ PA_SFR + 02h    ; Port 1 OUTput
P1DIR       .equ PA_SFR + 04h    ; Port 1 DIRection
P1REN       .equ PA_SFR + 06h    ; Port 1 Resistor ENable
P1SEL0      .equ PA_SFR + 0Ah    ; Port 1 SELection 0
P1SEL1      .equ PA_SFR + 0Ch    ; Port 1 SELection 1
P1SELC      .equ PA_SFR + 16h    ; Port 1 SELection Complement
P1IES       .equ PA_SFR + 18h    ; Port 1 Interrupt Edge Select
P1IE        .equ PA_SFR + 1Ah    ; Port 1 Interrupt Enable
P1IFG       .equ PA_SFR + 1Ch    ; Port 1 Interrupt FlaG
P1IV        .equ PA_SFR + 0Eh    ; Port 1 Interrupt Vector word 

P2IN        .equ PA_SFR + 01h    ; Port 2 INput
P2OUT       .equ PA_SFR + 03h    ; Port 2 OUTput
P2DIR       .equ PA_SFR + 05h    ; Port 2 DIRection
P2REN       .equ PA_SFR + 07h    ; Port 2 Resistor ENable
P2SEL0      .equ PA_SFR + 0Bh    ; Port 2 SELection 0
P2SEL1      .equ PA_SFR + 0Dh    ; Port 2 SELection 1
P2SELC      .equ PA_SFR + 17h    ; Port 2 SELection Complement
P2IES       .equ PA_SFR + 19h    ; Port 2 Interrupt Edge Select
P2IE        .equ PA_SFR + 1Bh    ; Port 2 Interrupt Enable
P2IFG       .equ PA_SFR + 1Dh    ; Port 2 Interrupt FlaG
P2IV        .equ PA_SFR + 1Eh    ; Port 2 Interrupt Vector word 

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

PBIN        .equ PB_SFR + 00h    ; Port B Input
PBOUT       .equ PB_SFR + 02h    ; Port B Output 1/0 or pullup/pulldown resistor
PBDIR       .equ PB_SFR + 04h    ; Port B Direction
PBREN       .equ PB_SFR + 06h    ; Port B Resistor Enable
PBSEL0      .equ PB_SFR + 0Ah    ; Port B Selection 0
PBSEL1      .equ PB_SFR + 0Ch    ; Port B Selection 1
PBSELC      .equ PB_SFR + 16h    ; Port B Complement Selection
PBIES       .equ PB_SFR + 18h    ; Port B Interrupt Edge Select
PBIE        .equ PB_SFR + 1Ah    ; Port B Interrupt Enable
PBIFG       .equ PB_SFR + 1Ch    ; Port B Interrupt Flag

P3IN        .equ PB_SFR + 00h    ; Port 3 Input */
P3OUT       .equ PB_SFR + 02h    ; Port 3 Output
P3DIR       .equ PB_SFR + 04h    ; Port 3 Direction
P3REN       .equ PB_SFR + 06h    ; Port 3 Resistor Enable
P3SEL0      .equ PB_SFR + 0Ah    ; Port 3 Selection 0
P3SEL1      .equ PB_SFR + 0Ch    ; Port 3 Selection 1
P3SELC      .equ PB_SFR + 16h    ; Port 3 Complement Selection
P3IES       .equ PB_SFR + 18h    ; Port 3 Interrupt Edge Select
P3IE        .equ PB_SFR + 1Ah    ; Port 3 Interrupt Enable
P3IFG       .equ PB_SFR + 1Ch    ; Port 3 Interrupt Flag
P3IV        .equ PB_SFR + 0Eh    ; Port 3 Interrupt Vector word 

P4IN        .equ PB_SFR + 01h    ; Port 4 Input */
P4OUT       .equ PB_SFR + 03h    ; Port 4 Output
P4DIR       .equ PB_SFR + 05h    ; Port 4 Direction
P4REN       .equ PB_SFR + 07h    ; Port 4 Resistor Enable
P4SEL0      .equ PB_SFR + 0Bh    ; Port 4 Selection 0
P4SEL1      .equ PB_SFR + 0Dh    ; Port 4 Selection 1
P4SELC      .equ PB_SFR + 17h    ; Port 4 Complement Selection
P4IES       .equ PB_SFR + 19h    ; Port 4 Interrupt Edge Select
P4IE        .equ PB_SFR + 1Bh    ; Port 4 Interrupt Enable
P4IFG       .equ PB_SFR + 1Dh    ; Port 4 Interrupt Flag
P4IV        .equ PB_SFR + 1Eh    ; Port 4 Interrupt Vector word 

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------

PCIN        .set PC_SFR + 00h    ; Port C Input
PCOUT       .set PC_SFR + 02h    ; Port C Output 1/0 or pullup/pulldown resistor
PCDIR       .set PC_SFR + 04h    ; Port C Direction
PCREN       .set PC_SFR + 06h    ; Port C Resistor Enable
PCSEL0      .set PC_SFR + 0Ah    ; Port C Selection 0
PCSEL1      .set PC_SFR + 0Ch    ; Port C Selection 1
PCSELC      .set PC_SFR + 16h    ; Port C Complement Selection

P5IN        .set PC_SFR + 00h    ; Port 5 Input */
P5OUT       .set PC_SFR + 02h    ; Port 5 Output
P5DIR       .set PC_SFR + 04h    ; Port 5 Direction
P5REN       .set PC_SFR + 06h    ; Port 5 Resistor Enable
P5SEL0      .set PC_SFR + 0Ah    ; Port 5 Selection 0
P5SEL1      .set PC_SFR + 0Ch    ; Port 5 Selection 1
P5SELC      .set PC_SFR + 16h    ; Port 5 Complement Selection

P6IN        .set PC_SFR + 01h    ; Port 6 Input */
P6OUT       .set PC_SFR + 03h    ; Port 6 Output
P6DIR       .set PC_SFR + 05h    ; Port 6 Direction
P6REN       .set PC_SFR + 07h    ; Port 6 Resistor Enable
P6SEL0      .set PC_SFR + 0Bh    ; Port 6 Selection 0
P6SEL1      .set PC_SFR + 0Dh    ; Port 6 Selection 1
P6SELC      .set PC_SFR + 17h    ; Port 6 Complement Selection

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7/8
; ----------------------------------------------------------------------

PDIN        .set PD_SFR + 00h    ; Port D Input
PDOUT       .set PD_SFR + 02h    ; Port D Output 1/0 or pullup/pulldown resistor
PDDIR       .set PD_SFR + 04h    ; Port D Direction
PDREN       .set PD_SFR + 06h    ; Port D Resistor Enable
PDSEL0      .set PD_SFR + 0Ah    ; Port D Selection 0
PDSEL1      .set PD_SFR + 0Ch    ; Port D Selection 1
PDSELC      .set PD_SFR + 16h    ; Port D Complement Selection

P7IN        .set PD_SFR + 00h    ; Port 7 Input */
P7OUT       .set PD_SFR + 02h    ; Port 7 Output
P7DIR       .set PD_SFR + 04h    ; Port 7 Direction
P7REN       .set PD_SFR + 06h    ; Port 7 Resistor Enable
P7SEL0      .set PD_SFR + 0Ah    ; Port 7 Selection 0
P7SEL1      .set PD_SFR + 0Ch    ; Port 7 Selection 1
P7SELC      .set PD_SFR + 16h    ; Port 7 Complement Selection

P8IN        .set PD_SFR + 01h    ; Port 8 Input */
P8OUT       .set PD_SFR + 03h    ; Port 8 Output
P8DIR       .set PD_SFR + 05h    ; Port 8 Direction
P8REN       .set PD_SFR + 07h    ; Port 8 Resistor Enable
P8SEL0      .set PD_SFR + 0Bh    ; Port 8 Selection 0
P8SEL1      .set PD_SFR + 0Dh    ; Port 8 Selection 1
P8SELC      .set PD_SFR + 17h    ; Port 8 Complement Selection

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT9/10
; ----------------------------------------------------------------------

PEIN        .set PE_SFR + 00h    ; Port E Input
PEOUT       .set PE_SFR + 02h    ; Port E Output 1/0 or pullup/pulldown resistor
PEDIR       .set PE_SFR + 04h    ; Port E Direction
PEREN       .set PE_SFR + 06h    ; Port E Resistor Enable
PESEL0      .set PE_SFR + 0Ah    ; Port E Selection 0
PESEL1      .set PE_SFR + 0Ch    ; Port E Selection 1
PESELC      .set PE_SFR + 16h    ; Port E Complement Selection

P9IN        .set PE_SFR + 00h    ; Port 9 Input */
P9OUT       .set PE_SFR + 02h    ; Port 9 Output
P9DIR       .set PE_SFR + 04h    ; Port 9 Direction
P9REN       .set PE_SFR + 06h    ; Port 9 Resistor Enable
P9SEL0      .set PE_SFR + 0Ah    ; Port 9 Selection 0
P9SEL1      .set PE_SFR + 0Ch    ; Port 9 Selection 1
P9SELC      .set PE_SFR + 16h    ; Port 9 Complement Selection

P10IN        .set PE_SFR + 01h    ; Port 10 Input */
P10OUT       .set PE_SFR + 03h    ; Port 10 Output
P10DIR       .set PE_SFR + 05h    ; Port 10 Direction
P10REN       .set PE_SFR + 07h    ; Port 10 Resistor Enable
P10SEL0      .set PE_SFR + 0Bh    ; Port 10 Selection 0
P10SEL1      .set PE_SFR + 0Dh    ; Port 10 Selection 1
P10SELC      .set PE_SFR + 17h    ; Port 10 Complement Selection

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------

PJIN        .equ PJ_SFR + 00h   ; Port J INput
PJOUT       .equ PJ_SFR + 02h   ; Port J OUTput
PJDIR       .equ PJ_SFR + 04h   ; Port J DIRection
PJREN       .equ PJ_SFR + 06h   ; Port J Resistor ENable
PJSEL0      .equ PJ_SFR + 0Ah   ; Port 2 SELection 0
PJSEL1      .equ PJ_SFR + 0Ch   ; Port 2 SELection 1
PJSELC      .equ PJ_SFR + 16h   ; Port 2 SELection Complement; PJ 5-0 usage

; ----------------------------------------------------------------------
RTC_C
; ----------------------------------------------------------------------
RTCCTL0_L     .set RTC_C_SFR + 00h
RTCCTL0_H     .set RTC_C_SFR + 01h
RTCCTL1       .set RTC_C_SFR + 02h
RTCCTL3       .set RTC_C_SFR + 03h
RTCOCAL       .set RTC_C_SFR + 04h
RTCTCMP       .set RTC_C_SFR + 06h
RTCPS0CTL     .set RTC_C_SFR + 08h
RTCPS1CTL     .set RTC_C_SFR + 0Ah
RTCPS         .set RTC_C_SFR + 0Ch ; = RT1PS:RT0PS
RTCIV         .set RTC_C_SFR + 0Eh
RTCSEC        .set RTC_C_SFR + 10h
RTCCNT1       .set RTC_C_SFR + 10h     
RTCMIN        .set RTC_C_SFR + 11h
RTCCNT2       .set RTC_C_SFR + 11h
RTCHOUR       .set RTC_C_SFR + 12h
RTCCNT3       .set RTC_C_SFR + 12h
RTCDOW        .set RTC_C_SFR + 13h
RTCCNT4       .set RTC_C_SFR + 13h
RTCDAY        .set RTC_C_SFR + 14h
RTCMON        .set RTC_C_SFR + 15h
RTCYEAR       .set RTC_C_SFR + 16h

RTCHOLD       .set 40h
RTCRDY        .set 10h

; ----------------------------------------------------------------------
MPY_32
; ----------------------------------------------------------------------

MPY       .equ MPY_SFR + 00h    ; Multiply16 Unsigned/Operand 1 */
MPYS      .equ MPY_SFR + 02h    ; Multiply16 signed/Operand 1
MAC       .equ MPY_SFR + 04h    ; MultiplyAccumulate16 Unsigned/Operand 1 */
MACS      .equ MPY_SFR + 06h    ; MultiplyAccumulate16 signed/Operand 1
OP2       .equ MPY_SFR + 08h    ; Operand2_16 */
RESLO     .equ MPY_SFR + 0Ah    ; 16x16-bit result low - least significant word */
RESHI     .equ MPY_SFR + 0Ch    ; 16x16-bit result high */
SUMEXT    .equ MPY_SFR + 0Eh    ; 16x16-bit sum extension register
MPY32L    .equ MPY_SFR + 10h    ; Multiply32 Unsigned/Operand 1
MPY32H    .equ MPY_SFR + 12h    ; Multiply32 Unsigned/Operand 1
MPYS32L   .equ MPY_SFR + 14h    ; Multiply32 signed/Operand 1
MPYS32H   .equ MPY_SFR + 16h    ; Multiply32 signed/Operand 1
MAC32L    .equ MPY_SFR + 18h    ; MultiplyAccumulate32 Unsigned/Operand 1
MAC32H    .equ MPY_SFR + 1Ah    ; MultiplyAccumulate32 Unsigned/Operand 1
MACS32L   .equ MPY_SFR + 1Ch    ; MultiplyAccumulate32 signed/Operand 1
MACS32H   .equ MPY_SFR + 1Eh    ; MultiplyAccumulate32 signed/Operand 1
OP2L      .equ MPY_SFR + 20h    ; Multiply32 Operand 2
OP2H      .equ MPY_SFR + 22h    ; Multiply32 Operand 2
RES0      .equ MPY_SFR + 24h    ; 32x32-bit result 0 - least significant word */
RES1      .equ MPY_SFR + 26h    ; 32x32-bit result 1 */
RES2      .equ MPY_SFR + 28h    ; 32x32-bit result 2 */
RES3      .equ MPY_SFR + 2Ah    ; 32x32-bit result 3 */
MPY32CTL0 .equ MPY_SFR + 2Ch    ; MPY32 control register 0


MPUCTL0     .equ MPU_SFR + 00h  ; MPU control 0             
MPUCTL1     .equ MPU_SFR + 02h  ; MPU control 1             
MPUSEGB2    .equ MPU_SFR + 04h  ; MPU Segmentation Border 2 
MPUSEGB1    .equ MPU_SFR + 06h  ; MPU Segmentation Border 1 
MPUSAM      .equ MPU_SFR + 08h  ; MPU access management     
MPUIPC0     .equ MPU_SFR + 0Ah  ; MPU IP control 0                      
MPUIPSEGB2  .equ MPU_SFR + 0Ch  ; MPU IP Encapsulation Segment Border 2 
MPUIPSEGB1  .equ MPU_SFR + 0Eh  ; MPU IP Encapsulation Segment Border 1 

; ----------------------------------------------------------------------
; eUSCI_A0
; ----------------------------------------------------------------------

    .IFDEF UCA0_TERM
TERM_CTLW0       .equ eUSCI_A0_SFR + 00h    ; eUSCI_A0 Control Word Register 0
TERM_BRW         .equ eUSCI_A0_SFR + 06h    ; eUSCI_A0 Baud Word Rate 0
TERM_MCTLW       .equ eUSCI_A0_SFR + 08h    ; eUSCI_A0 Modulation Control
TERM_STATW       .equ eUSCI_A0_SFR + 0Ah    ; eUSCI_A0 status Word Register
TERM_RXBUF       .equ eUSCI_A0_SFR + 0Ch    ; eUSCI_A0 Receive Buffer
TERM_TXBUF       .equ eUSCI_A0_SFR + 0Eh    ; eUSCI_A0 Transmit Buffer
TERM_IE          .equ eUSCI_A0_SFR + 1Ah    ; eUSCI_A0 Interrupt Enable Register
TERM_IFG         .equ eUSCI_A0_SFR + 1Ch    ; eUSCI_A0 Interrupt Flags Register
TERM_VEC         .equ 0FFEEh      ; interrupt vector for  eUSCI_A0
RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCA0_TERM

    .IFDEF UCA0_SD
SD_CTLW0       .equ eUSCI_A0_SFR + 00h    ; eUSCI_A0 Control Word Register 0
SD_BRW         .equ eUSCI_A0_SFR + 06h    ; eUSCI_A0 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_A0_SFR + 0Ch    ; eUSCI_A0 Receive Buffer 8
SD_TXBUF       .equ eUSCI_A0_SFR + 0Eh    ; eUSCI_A0 Transmit Buffer 8
SD_IFG         .equ eUSCI_A0_SFR + 1Ch    ; eUSCI_A0 Interrupt Flags Register
RX_SD           .equ 1
TX_SD           .equ 2
    .ENDIF ;UCA0_SD

; ----------------------------------------------------------------------
; eUSCI_A1
; ----------------------------------------------------------------------

    .IFDEF UCA1_TERM
TERM_CTLW0      .equ eUSCI_A1_SFR + 00h    ; eUSCI_A1 Control Word Register 0
TERM_BRW        .equ eUSCI_A1_SFR + 06h    ; eUSCI_A1 Baud Word Rate 0
TERM_MCTLW      .equ eUSCI_A1_SFR + 08h    ; eUSCI_A1 Modulation Control
TERM_STATW      .equ eUSCI_A1_SFR + 0Ah    ; eUSCI_A1 status Word Register
TERM_RXBUF      .equ eUSCI_A1_SFR + 0Ch    ; eUSCI_A1 Receive Buffer
TERM_TXBUF      .equ eUSCI_A1_SFR + 0Eh    ; eUSCI_A1 Transmit Buffer
TERM_IE         .equ eUSCI_A1_SFR + 1Ah    ; eUSCI_A1 Interrupt Enable Register
TERM_IFG        .equ eUSCI_A1_SFR + 1Ch    ; eUSCI_A1 Interrupt Flags Register

TERM_VEC        .equ 0FFE4h ; interrupt vector for  eUSCI_A1
WAKE_UP         .equ 1      ; UART RX interrupt

RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCA1_TERM

    .IFDEF UCA1_SD
SD_CTLW0       .equ eUSCI_A1_SFR + 00h    ; eUSCI_A1 Control Word Register 0
SD_BRW         .equ eUSCI_A1_SFR + 06h    ; eUSCI_A1 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_A1_SFR + 0Ch    ; eUSCI_A1 Receive Buffer 8
SD_TXBUF       .equ eUSCI_A1_SFR + 0Eh    ; eUSCI_A1 Transmit Buffer 8
SD_IFG         .equ eUSCI_A1_SFR + 1Ch    ; eUSCI_A1 Interrupt Flags Register
RX_SD           .equ 1
TX_SD           .equ 2
    .ENDIF ;UCA1_SD


; ----------------------------------------------------------------------
; eUSCI_B0
; ----------------------------------------------------------------------
    .IFDEF UCB0_SD
SD_CTLW0       .equ eUSCI_B0_SFR + 00h    ; eUSCI_B0 Control Word Register 0
SD_BRW         .equ eUSCI_B0_SFR + 06h    ; eUSCI_B0 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_B0_SFR + 0Ch    ; eUSCI_B0 Receive Buffer 8
SD_TXBUF       .equ eUSCI_B0_SFR + 0Eh    ; eUSCI_B0 Transmit Buffer 8
SD_IFG         .equ eUSCI_B0_SFR + 2Ch    ; eUSCI_B0 Interrupt Flags Register
RX_SD           .equ 1
TX_SD           .equ 2
    .ENDIF ;UCB0_SD

    .IFDEF UCB0_TERM
TERM_CTLW0      .equ eUSCI_B0_SFR + 00h     ; USCI_B0 Control Word Register 0
TERM_CTLW1      .equ eUSCI_B0_SFR + 02h     ; USCI_B0 Control Word Register 1
TERM_BRW        .equ eUSCI_B0_SFR + 06h     ; USCI_B0 Baud Word Rate 0
TERM_STATW      .equ eUSCI_B0_SFR + 08h     ; USCI_B0 Status Word
TERM_RXBUF      .equ eUSCI_B0_SFR + 0Ch     ; USCI_B0 Receive Buffer 8
TERM_TXBUF      .equ eUSCI_B0_SFR + 0Eh     ; USCI_B0 Transmit Buffer 8
TERM_I2COA0     .equ eUSCI_B0_SFR + 14h     ; USCI_B0 I2C Own Address 0
TERM_ADDRX      .equ eUSCI_B0_SFR + 1Ch     ; USCI_B0  Received Address Register 
TERM_I2CSA      .equ eUSCI_B0_SFR + 20h     ; USCI_B0 I2C Slave Address
TERM_IE         .equ eUSCI_B0_SFR + 2Ah     ; USCI_B0 Interrupt Enable
TERM_IFG        .equ eUSCI_B0_SFR + 2Ch     ; USCI_B0 Interrupt Flags Register

TERM_VEC        .equ 0FFECh ; interrupt vector for eUSCI_B0
WAKE_UP         .equ 4      ; START interrupt

RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCB0_TERM



