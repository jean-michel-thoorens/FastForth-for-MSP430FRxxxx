; MSP430fr5738.inc
; MSP430FR5738 minimal declarations for FastForth usage
DEVICE = "MSP430FR5738"

; ----------------------------------------------
; MSP430FR5738 MEMORY MAP
; ----------------------------------------------
; 0000-0FFF = peripherals (4 KB)
; 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
; 1800-187F = info B (FRAM 128 B)
; 1880-18FF = info A (FRAM 128 B)
; 1900-19FF = N/A (mirrored into info A/B)
; 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
; 1A80-1BFF = unused (385 B)
; 1C00-1FFF = RAM (1 KB)
; 2000-C1FF = unused (41472 B)
; C200-FF7F = code memory (FRAM 15743 B)
; FF80-FFFF = interrupt vectors (FRAM 127 B)
; ----------------------------------------------
PAGESIZE        .equ 512         ; MPU unit
; ----------------------------------------------
; FRAM                          ; INFO B, A, TLV
; ----------------------------------------------
INFO_ORG        .equ 01800h
INFO_LEN        .equ 00100h
INFOB_ORG       .equ 01800h
INFOB_LEN       .equ 00080h
INFOA_ORG       .equ 01880h
INFOA_LEN       .equ 00080h
; ----------------------------------------------
TLV_ORG         .equ 01A00h      ; Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN         .equ 00080h      ;
; ----------------------------------------------
; RAM
; ----------------------------------------------
RAM_ORG         .equ 01C00h
RAM_LEN         .equ 00400h
; ----------------------------------------------
; FRAM
; ----------------------------------------------
MAIN_ORG        .equ 0C200h      ; Code space start
SIGNATURES      .equ 0FF80h      ; JTAG/BSL signatures
JTAG_SIG1       .equ 0FF80h      ; if 0 (electronic fuse=0) enable JTAG/SBW; must be reset by wipe.
JTAG_SIG2       .equ 0FF82h      ; if JTAG_SIG1=0xAAAA, length of password string @ JTAG_PASSWORD
BSL_SIG1        .equ 0FF84h      ;
BSL_SIG2        .equ 0FF86h      ;
JTAG_PASSWORD   .equ 0FF88h      ; 256 bits
VECT_ORG        .equ 0FFCEh      ; FFCE-FFFF
VECT_LEN        .equ 32h
BSL_PASSWORD    .equ 0FFE0h      ; 256 bits
; ----------------------------------------------

; ----------------------------------------------
; Interrupt Vectors and signatures - MSP430FR57xx
; ----------------------------------------------
;    .org    SIGNATURES
;;Start of JTAG and BSL signatures
;        .word   0           ; JTAG signature 1
;        .word   0           ; JTAG signature 2
;        .word   0 ; 5555h   ; BSL signature 1 ; disable BSL
;        .word   0           ; BSL signature 2
;
;    .org JTAG_PASSWORD     ;Start of JTAG PASSWORD
;
;    .org    VECT_ORG         ; FFCE-FFFF 24 vectors + reset
;        .word  reset        ; $FFCE  -  RTC_B
;        .word  reset        ; $FFD0  -  I/O Port 4
;        .word  reset        ; $FFD2  -  I/O Port 3
;        .word  reset        ; $FFD4  -  TB2_x
;        .word  reset        ; $FFD6  -  TB2_0
;        .word  reset        ; $FFD8  -  I/O Port 2
;        .word  reset        ; $FFDA  -  TB1_x
;        .word  reset        ; $FFDC  -  TB1_0
;        .word  reset        ; $FFDE  -  I/O Port 1
;;   .org BSL_PASSWORD       ;Start of BSL PASSWORD
;        .word  reset        ; $FFE0  -  TA1_x
;        .word  reset        ; $FFE2  -  TA1_0
;        .word  reset        ; $FFE4  -  DMA
;        .word  reset        ; $FFE8  -  TA0_x
;        .word  reset        ; $FFEA  -  TA0_0
;        .word  reset        ; $FFEC  -  ADC10_B
;        .word  reset        ; $FFEE  -  eUSCI_B0
;        .word  reset        ; $FFF0  -  eUSCI_A0
;        .word  reset        ; $FFF2  -  Watchdog
;        .word  reset        ; $FFF4  -  TB0_x
;        .word  reset        ; $FFF6  -  TB0_0
;        .word  reset        ; $FFF8  -  COMP_D
;        .word  reset        ; $FFFA  -  userNMI
;        .word  reset        ; $FFFC  -  sysNMI
;        .word  reset        ; $FFFE  -  reset



; ----------------------------------------------------------------------
; MSP430FR5739 Peripheral File Map
; ----------------------------------------------------------------------
SFR_SFR         .equ 0100h           ; Special function
PMM_SFR         .equ 0120h           ; PMM
FRAM_SFR        .equ 0140h           ; FRAM control
CRC16_SFR       .equ 0150h   
WDT_A_SFR       .equ 015Ch           ; Watchdog
CS_SFR          .equ 0160h
SYS_SFR         .equ 0180h           ; SYS 
REF_SFR         .equ 01B0h           ; REF
PA_SFR          .equ 0200h           ; PORT1/2
PJ_SFR          .equ 0320h           ; PORTJ
TA0_SFR         .equ 0340h
TA1_SFR         .equ 0380h
TB0_SFR         .equ 03C0h
TB1_SFR         .equ 0400h
TB2_SFR         .equ 0440h
RTC_B_SFR       .equ 04A0h
MPY_SFR         .equ 04C0h
DMA_CTRL_SFR    .equ 0500h
DMA_CHN0_SFR    .equ 0510h
DMA_CHN1_SFR    .equ 0520h
DMA_CHN2_SFR    .equ 0530h
MPU_SFR         .equ 05A0h           ; memory protect unit
eUSCI_A0_SFR    .equ 05C0h           ; eUSCI_A0
eUSCI_B0_SFR    .equ 0640h           ; eUSCI_B0
ADC10_B_SFR     .equ 0700h
COMP_D_SFR      .equ 08C0h

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK I/O as high impedance state
; ----------------------------------------------------------------------
SFRIE1      .equ SFR_SFR
SFRIFG1     .equ SFR_SFR + 2
SFRRPCR     .equ SFR_SFR + 4

PMMCTL0     .equ PMM_SFR
PMMSWBOR    .equ 4

PM5CTL0     .equ PMM_SFR + 10h    ; Power mode 5 control register 0
LOCKLPM5    .equ 1

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
CSKEY           .equ 0A5h            ; CS Password
; CSCTL1 Control Bits
DCORSEL         .equ 0080h
DCOFSEL0        .equ 0002h           ; DCO frequency select Bit: 0
DCOFSEL1        .equ 0004h           ; DCO frequency select Bit: 1
; CSCTL2 Control Bits
; SELA_LFXCLK     .equ 0000h           ; 0 : ACLK Source Select LFXCLK
SELA_LFXCLK     .equ 0000h           ; 0 : ACLK Source Select LFXCLK
SELA_VLOCLK     .equ 0100h           ; 1 ACLK Source Select VLOCLK 10kHz
SELS_DCOCLK     .equ 0030h           ; 3 SMCLK Source Select DCOCLK
SELM_DCOCLK     .equ 0003h           ; 3 MCLK Source Select DCOCLK
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
SYSRSTIV    .equ SYS_SFR + 001Eh

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : REF
; ----------------------------------------------------------------------
REFCTL      .equ REF_SFR + 00h       ; REF Shared Reference control register 0

; REFCTL0 Control Bits
REFON       .equ 0001h               ; REF Reference On
REFTCOFF    .equ 0008h               ; REF Temp.Sensor off

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION PAIN=PORT2:PORT1
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
P1IV        .equ PA_SFR + 0Eh    ; Port 1 Interrupt Vector word 
P1SELC      .equ PA_SFR + 16h    ; Port 1 SELection Complement
P1IES       .equ PA_SFR + 18h    ; Port 1 Interrupt Edge Select
P1IE        .equ PA_SFR + 1Ah    ; Port 1 Interrupt Enable
P1IFG       .equ PA_SFR + 1Ch    ; Port 1 Interrupt FlaG

P2IN        .equ PA_SFR + 01h    ; Port 2 INput
P2OUT       .equ PA_SFR + 03h    ; Port 2 OUTput
P2DIR       .equ PA_SFR + 05h    ; Port 2 DIRection
P2REN       .equ PA_SFR + 07h    ; Port 2 Resistor ENable
P2SEL0      .equ PA_SFR + 0Bh    ; Port 2 SELection 0
P2SEL1      .equ PA_SFR + 0Dh    ; Port 2 SELection 1
P2SELC      .equ PA_SFR + 17h    ; Port 2 SELection Complement
P2IES       .equ PA_SFR + 19h    ; Port 2 Interrupt Edge Select
P2IE        .equ PA_SFR + 1Bh    ; Port 2 Interrupt Enable
P2IFG       .equ PA_SFR + 1Dh    ; Port 2 Interrupt Flag
P2IV        .equ PA_SFR + 1Eh    ; Port 2 Interrupt Vector word 

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORTJ
; ----------------------------------------------------------------------
PJIN        .set PJ_SFR + 00h    ; Port B Input
PJOUT       .set PJ_SFR + 02h    ; Port B Output
PJDIR       .set PJ_SFR + 04h    ; Port B Direction
PJREN       .set PJ_SFR + 06h    ; Port B Resistor Enable
PJSEL0      .set PJ_SFR + 0Ah    ; Port B Selection 0
PJSEL1      .set PJ_SFR + 0Ch    ; Port B Selection 1
PJSELC      .set PJ_SFR + 16h    ; Port B Complement Selection

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
MPUSEG      .equ MPU_SFR + 04h  ; MPU Segmentation Register 
MPUSAM      .equ MPU_SFR + 06h  ; MPU access management     

    .IFDEF UCA0_TERM
; ----------------------------------------------------------------------
; eUSCI_A0
; ----------------------------------------------------------------------
TERM_CTLW0       .equ eUSCI_A0_SFR + 00h    ; eUSCI_A0 Control Word Register 0
TERM_BRW         .equ eUSCI_A0_SFR + 06h    ; eUSCI_A0 Baud Word Rate 0
TERM_MCTLW       .equ eUSCI_A0_SFR + 08h    ; eUSCI_A0 Modulation Control
TERM_STATW       .equ eUSCI_A0_SFR + 0Ah    ; eUSCI_A0 status Word Register
TERM_RXBUF       .equ eUSCI_A0_SFR + 0Ch    ; eUSCI_A0 Receive Buffer
TERM_TXBUF       .equ eUSCI_A0_SFR + 0Eh    ; eUSCI_A0 Transmit Buffer
TERM_IE          .equ eUSCI_A0_SFR + 1Ah    ; eUSCI_A0 Interrupt Enable Register
TERM_IFG         .equ eUSCI_A0_SFR + 1Ch    ; eUSCI_A0 Interrupt Flags Register
TERM_VEC         .equ 0FFF0h      ; interrupt vector for  eUSCI_A0
RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCA0_TERM

    .IFDEF UCA0_SD
; ----------------------------------------------------------------------
; eUSCI_A0
; ----------------------------------------------------------------------
SD_CTLW0       .equ eUSCI_A0_SFR + 00h      ; USCI_A0 Control Word Register 0
SD_BRW         .equ eUSCI_A0_SFR + 06h      ; USCI_A0 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_A0_SFR + 0Ch      ; USCI_A0 Receive Buffer 8
SD_TXBUF       .equ eUSCI_A0_SFR + 0Eh      ; USCI_A0 Transmit Buffer 8
SD_IFG         .equ eUSCI_A0_SFR + 1Ch      ; USCI_A0 Interrupt Flags Register
RX_SD           .equ 1
TX_SD           .equ 2
    .ENDIF

    .IFDEF UCB0_TERM
; ----------------------------------------------------------------------
; eUSCI_B0
; ----------------------------------------------------------------------
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
TERM_VEC        .equ 0FFEEh                 ; interrupt vector for eUSCI_B0
RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCB0_TERM

    .IFDEF UCB0_SD
; ----------------------------------------------------------------------
; eUSCI_B0
; ----------------------------------------------------------------------
SD_CTLW0       .equ eUSCI_B0_SFR + 00h    ; USCI_B0 Control Word Register 0
SD_BRW         .equ eUSCI_B0_SFR + 06h    ; USCI_B0 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_B0_SFR + 0Ch    ; USCI_B0 Receive Buffer 8
SD_TXBUF       .equ eUSCI_B0_SFR + 0Eh    ; USCI_B0 Transmit Buffer 8
SD_IFG         .equ eUSCI_B0_SFR + 2Ch    ; USCI_B0 Interrupt Flags Register
RX_SD           .equ 1
TX_SD           .equ 2
    .ENDIF ;UCB0_SD


