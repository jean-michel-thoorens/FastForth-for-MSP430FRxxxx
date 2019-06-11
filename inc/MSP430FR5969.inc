; MSP430FR5969.inc
; MSP430FR569  minimal declarations for FastForth usage
DEVICE = "MSP430FR5969"

; ----------------------------------------------
; MSP430FR5969 MEMORY MAP
; ----------------------------------------------
; 0000-0FFF = peripherals (4 KB)
; 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
; 1800-187F = FRAM info D (128 B)
; 1880-18FF = FRAM info C (128 B)
; 1900-197F = FRAM info B (128 B)
; 1980-19FF = FRAM info A (128 B)
; 1A00-1AFF = FRAM TLV device descriptor info (256 B)
; 1B00-1BFF = unused (256 B)
; 1C00-23FF = RAM (2KB)
; 23FF-43FF = unused (8kB)
; 4400-FF7F = FRAM code memory (FRAM) (MSP430FR59x8/9)
; 8000-FF7F = FRAM code memory (FRAM) (MSP430FR59x7/8/9)
; FF80-FFFF = FRAM interrupt vectors and signatures (FRAM)
; 10000-13FFF = FRAM (MSP430FR59x9)

; ----------------------------------------------
PAGESIZE        .equ 512         ; MPU unit
; ----------------------------------------------
; BSL                         
; ----------------------------------------------
BSL             .equ 1000h
; ----------------------------------------------
; FRAM                          ; INFO B, A, TLV
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
MAIN_LEN        .equ 14000h      ; 63 k FRAM
SIGNATURES      .equ 0FF80h      ; JTAG/BSL signatures
JTAG_SIG1       .equ 0FF80h      ; if 0, enable JTAG/SBW
JTAG_SIG2       .equ 0FF82h      ; if JTAG_SIG1=0xAAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1        .equ 0FF84h      ;
BSL_SIG2        .equ 0FF86h      ;
JTAG_PASSWORD   .equ 0FF88h      ; 256 bits max
IPE_SIG_VALID   .equ 0FF88h      ; one word
IPE_STR_PTR_SRC .equ 0FF8Ah      ; one word
VECT_ORG        .equ 0FFCCh      ; FFCC-FFFF
VECT_LEN        .equ 34h
BSL_PASSWORD    .equ 0FFE0h      ; 256 bits
; ----------------------------------------------

;    .org    SIGNATURES
;;Start of JTAG and BSL signatures
;        .word   0FFFFh      ; JTAG signature 1
;        .word   0FFFFh      ; JTAG signature 2
;        .word   0FFFFh      ; BSL signature 1, 5555h to disable BSL
;        .word   0FFFFh      ; BSL signature 2
;
;    .org JTAG_PASSWORD     ;Start of JTAG PASSWORD
;
;    .org    INTVECT         ; FFCC-FFFF 25 vectors + reset
;         .word  reset       ; $FFCC  -  AES
;         .word  reset       ; $FFCE  -  RTC_B
;         .word  reset       ; $FFD0  -  I/O Port 4
;         .word  reset       ; $FFD2  -  I/O Port 3
;         .word  reset       ; $FFD4  -  TB2_1
;         .word  reset       ; $FFD6  -  TB2_0
;         .word  reset       ; $FFD8  -  I/O Port P2
;         .word  reset       ; $FFDA  -  TB1_1
;         .word  reset       ; $FFDC  -  TB1_0
;         .word  reset       ; $FFDE  -  I/O Port P1
;
;
;;    .org BSL_PASSWORD      ;Start of BSL PASSWORD
;         .word  reset       ; $FFE0  -  TA1_1
;         .word  reset       ; $FFE2  -  TA1_0
;         .word  reset       ; $FFE4  -  DMA
;         .word  reset       ; $FFE6  -  eUSCI_A1
;         .word  reset       ; $FFE8  -  TA0_1
;         .word  reset       ; $FFEA  -  TA0_0
;         .word  reset       ; $FFEC  -  ADC12_B
;         .word  reset       ; $FFEE  -  eUSCI_B0
;         .word  reset       ; $FFF0  -  eUSCI_A0
;         .word  reset       ; $FFF2  -  Watchdog
;         .word  reset       ; $FFF4  -  TB0_1
;         .word  reset       ; $FFF6  -  TB0_0
;         .word  reset       ; $FFF8  -  COMP_D
;         .word  reset       ; $FFFA  -  userNMI
;         .word  reset       ; $FFFC  -  sysNMI
;         .word  reset       ; $FFFE  -  reset




; ----------------------------------------------------------------------
; MSP430FR5969 Peripheral File Map
; ----------------------------------------------------------------------
SFR_SFR         .set 0100h           ; Special function
PMM_SFR         .set 0120h           ; PMM
FRAM_SFR        .set 0140h           ; FRAM control
CRC16_SFR       .set 0150h
WDT_A_SFR       .set 015Ch           ; Watchdog
CS_SFR          .set 0160h           ; Clock System
SYS_SFR         .set 0180h           ; SYS
REF_SFR         .set 01B0h           ; REF
PA_SFR          .set 0200h           ; PORT1/2
PB_SFR          .set 0220h           ; PORT3/4
PJ_SFR          .set 0320h           ; PORTJ
TA0_SFR         .set 0340h
TA1_SFR         .set 0380h
TB0_SFR         .set 03C0h
TA2_SFR         .set 0400h
CTIO0_SFR       .set 0430h           ; Capacitive Touch IO
TA3_SFR         .set 0440h
CTIO1_SFR       .set 0470h           ; Capacitive Touch IO
RTC_B_SFR       .set 04A0h
MPY_SFR         .set 04C0h
DMA_CTRL_SFR    .set 0500h
DMA_CHN0_SFR    .set 0510h
DMA_CHN1_SFR    .set 0520h
DMA_CHN2_SFR    .set 0530h
MPU_SFR         .set 05A0h           ; memory protect unit
eUSCI_A0_SFR    .set 05C0h           ; eUSCI_A0
eUSCI_A1_SFR    .set 05E0h           ; eUSCI_A1
eUSCI_B0_SFR    .set 0640h           ; eUSCI_B0
ADC12_B_SFR     .set 0800h
COMP_E_SFR      .set 08C0h
AES_SFR         .set 09C0h

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------
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
RTC_B
; ----------------------------------------------------------------------
RTCCTL01      .equ RTC_B_SFR + 00h
RTCCTL0       .equ RTC_B_SFR + 00h
RTCCTL1       .equ RTC_B_SFR + 01h
RTCCTL23      .equ RTC_B_SFR + 02h
RTCPS0CTL     .equ RTC_B_SFR + 08h
RTCPS1CTL     .equ RTC_B_SFR + 0Ah
RTCPS         .equ RTC_B_SFR + 0Ch
RTCIV         .equ RTC_B_SFR + 0Eh
RTCSEC        .equ RTC_B_SFR + 10h
RTCMIN        .equ RTC_B_SFR + 11h
RTCHOUR       .equ RTC_B_SFR + 12h
RTCDOW        .equ RTC_B_SFR + 13h
RTCDAY        .equ RTC_B_SFR + 14h
RTCMON        .equ RTC_B_SFR + 15h
RTCYEAR       .equ RTC_B_SFR + 16h

RTCHOLD       .equ 40h
RTCRDY        .equ 10h

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


UCSWRST         .equ 1  ; eUSCI Software Reset
UCTXIE          .equ 2  ; eUSCI Transmit Interrupt Enable
UCRXIE          .equ 1  ; eUSCI Receive Interrupt Enable
UCTXIFG         .equ 2  ; eUSCI Transmit Interrupt Flag
UCRXIFG         .equ 1  ; eUSCI Receive Interrupt Flag


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
TERM_VEC         .equ 0FFF0h      ; interrupt vector for  eUSCI_A0
    .ENDIF ;UCA0_TERM

    .IFDEF UCA0_SD
SD_CTLW0       .equ eUSCI_A0_SFR + 00h    ; eUSCI_A0 Control Word Register 0
SD_BRW         .equ eUSCI_A0_SFR + 06h    ; eUSCI_A0 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_A0_SFR + 0Ch    ; eUSCI_A0 Receive Buffer 8
SD_TXBUF       .equ eUSCI_A0_SFR + 0Eh    ; eUSCI_A0 Transmit Buffer 8
SD_IFG         .equ eUSCI_A0_SFR + 1Ch    ; eUSCI_A0 Interrupt Flags Register
    .ENDIF ;UCA0_SD

; ----------------------------------------------------------------------
; eUSCI_A1
; ----------------------------------------------------------------------

    .IFDEF UCA1_TERM
TERM_CTLW0       .equ eUSCI_A1_SFR + 00h    ; eUSCI_A1 Control Word Register 0
TERM_BRW         .equ eUSCI_A1_SFR + 06h    ; eUSCI_A1 Baud Word Rate 0
TERM_MCTLW       .equ eUSCI_A1_SFR + 08h    ; eUSCI_A1 Modulation Control
TERM_STATW       .equ eUSCI_A1_SFR + 0Ah    ; eUSCI_A1 status Word Register
TERM_RXBUF       .equ eUSCI_A1_SFR + 0Ch    ; eUSCI_A1 Receive Buffer
TERM_TXBUF       .equ eUSCI_A1_SFR + 0Eh    ; eUSCI_A1 Transmit Buffer
TERM_IE          .equ eUSCI_A1_SFR + 1Ah    ; eUSCI_A1 Interrupt Enable Register
TERM_IFG         .equ eUSCI_A1_SFR + 1Ch    ; eUSCI_A1 Interrupt Flags Register
TERM_VEC         .equ 0FFE6h      ; interrupt vector for  eUSCI_A1
    .ENDIF ;UCA1_TERM

    .IFDEF UCA1_SD
SD_CTLW0       .equ eUSCI_A1_SFR + 00h    ; eUSCI_A1 Control Word Register 0
SD_BRW         .equ eUSCI_A1_SFR + 06h    ; eUSCI_A1 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_A1_SFR + 0Ch    ; eUSCI_A1 Receive Buffer 8
SD_TXBUF       .equ eUSCI_A1_SFR + 0Eh    ; eUSCI_A1 Transmit Buffer 8
SD_IFG         .equ eUSCI_A1_SFR + 1Ch    ; eUSCI_A1 Interrupt Flags Register
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
    .ENDIF ;UCB0_SD



