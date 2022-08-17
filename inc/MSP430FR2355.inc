; MSP430fr2355.inc
; MSP430FR2355 minimal declarations for FastForth usage
    .save
    .listing off

DEVICE = "MSP430FR2355"
FR2_FAMILY
HMPY    ; hardware 
FLL     ; Frequency Locked Loop CLOCK
; ----------------------------------------------
; MSP430FR2355 MEMORY MAP
; ----------------------------------------------
; 0000-0005 = reserved
; 0006-001F = tiny RAM
; 0020-0FFF = peripherals (4 KB)
; 1000-17FF = ROM bootstrap loader BSL1 (2k)
; 1800-19FF = information memory (FRAM 512 B)
; 1A00-1A31 = TLV device descriptor info (FRAM 128 B)
; 1A80-1FFF = unused
; 2000-2FFF = RAM (4 KB)
; 2800-7FFF = unused
; 8000-FF7F = code memory (FRAM 15232 B)
; FF80-FFFF = interrupt vectors (FRAM 128 B)
; FFC00-FFFFF = BSL2 (2k)
; ----------------------------------------------
; MSP430FR2355 DEVICE ID
; ----------------------------------------------
; 1A04 = 0C, 1A05 = 83
; ----------------------------------------------
PAGESIZE        .equ 512         ; MPU unit
; ----------------------------------------------
; BSL                           
; ----------------------------------------------
BSL1            .equ 01000h 
BSL2            .equ 0FFC00h
; ----------------------------------------------
; FRAM                          ; INFO B, TLV
; ----------------------------------------------
TINYRAM_ORG     .equ 6
TINYRAM_LEN     .equ 1Ah
INFO_ORG        .equ 01800h
INFO_LEN        .equ 00200h
TLV_ORG         .equ 01A00h      ; Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN         .equ 00032h      ;
; ----------------------------------------------
; RAM
; ----------------------------------------------
RAM_ORG         .equ 02000h
RAM_LEN         .equ 01000h
; ----------------------------------------------
; FRAM
; ----------------------------------------------
MAIN_ORG        .equ 08000h      ; Code space start
; ----------------------------------------------
; Interrupt Vectors and signatures - MSP430FR2355
; ----------------------------------------------
SIGNATURES      .equ 0FF80h      ; JTAG/BSL signatures
JTAG_SIG1       .equ 0FF80h      ; if 0 (electronic fuse=0) enable JTAG/SBW ; reset by wipe and by S1+<reset>
JTAG_SIG2       .equ 0FF82h      ; if JTAG_SIG <> |0xFFFFFFFF, 0x00000000|, SBW and JTAG are locked
BSL_SIG1        .equ 0FF84h      ;
BSL_SIG2        .equ 0FF86h      ;
BSL_CONF_SIG    .equ 0FF88h      ;
BSL_CONF        .equ 0FF8Ah      ;
JTAG_PASSWORD   .equ 0FF88h      ; 256 bits
BSL_PASSWORD    .equ 0FFE0h      ; 256 bits
BSL_I2C_ADRE    .equ 0FFA0h      ;
I2CSLA0         .equ 0FFA2h      ; UCBxI2COA0 default value address 
I2CSLA1         .equ 0FFA4h      ; UCBxI2COA1 default value address
I2CSLA2         .equ 0FFA6h      ; UCBxI2COA2 default value address
I2CSLA3         .equ 0FFA8h      ; UCBxI2COA3 default value address
VECT_ORG        .equ 0FFCEh      ; FFCE-FFFF :  24 vectors + reset
VECT_LEN        .equ 32h
; ----------------------------------------------

;   .org    INTVECT             ; FFCE-FFFF 24 vectors + reset
;
;           .word  reset        ; FFCEh - P4       
;           .word  reset        ; FFD0h - P3
;           .word  reset        ; FFD2h - P2       
;           .word  reset        ; FFD4h - P1
;           .word  reset        ; FFD6h - SAC1-SAC3    
;           .word  reset        ; FFD8h - SAC0-SAC2     
;           .word  reset        ; FFDAh - eCOMPx    
;           .word  reset        ; FFDCh - ADC10    
;           .word  reset        ; FFDEh - eUSCI_B1 
;           .word  reset        ; FFE0h - eUSCI_B0 
;           .word  reset        ; FFE2h - eUSCI_A1 
;           .word  reset        ; FFE4h - eUSCI_A0 
;           .word  reset        ; FFE6h - WDT      
;           .word  reset        ; FFE8h - RTC      
;           .word  reset        ; FFEAh - TB3_x    
;           .word  reset        ; FFECh - TB3_0    
;           .word  reset        ; FFEEh - TB2_x    
;           .word  reset        ; FFF0h - TB2_0    
;           .word  reset        ; FFF2h - TB1_x    
;           .word  reset        ; FFF4h - TB1_0    
;           .word  reset        ; FFF6h - TB0_x    
;           .word  reset        ; FFF8h - TB0_0    
;           .word  reset        ; FFFAh - UserNMI  
;           .word  reset        ; FFFCh - SysNMI   
;           .word  reset        ; FFFEh - Reset    

; ----------------------------------------------------------------------
; MSP430FR2355 Peripheral File Map
; ----------------------------------------------------------------------
SFR_SFR         .equ 0100h           ; Special function
PMM_SFR         .equ 0120h           ; PMM
SYS_SFR         .equ 0140h           ; SYS
CS_SFR          .equ 0180h           ; Clock System
FRAM_SFR        .equ 01A0h           ; FRAM control
CRC16_SFR       .equ 01C0h
WDT_A_SFR       .equ 01CCh           ; Watchdog
PA_SFR          .equ 0200h           ; PORT1/2
PB_SFR          .equ 0220h           ; PORT3/4
PC_SFR          .equ 0240h           ; PORT5/6
RTC_SFR         .equ 0300h
TB0_SFR         .equ 0380h
TB1_SFR         .equ 03C0h
TB2_SFR         .equ 0400h
TB3_SFR         .equ 0440h
MPY_SFR         .equ 04C0h
eUSCI_A0_SFR    .equ 0500h           ; eUSCI_A0
eUSCI_B0_SFR    .equ 0540h           ; eUSCI_B0
eUSCI_A1_SFR    .equ 0580h           ; eUSCI_A1
eUSCI_B1_SFR    .equ 05C0h           ; eUSCI_B1
BACK_MEM_SFR    .equ 0660h
ICC_SFR         .equ 06C0h
ADC10_B_SFR     .equ 0700h
eCOMP0_SFR      .equ 08E0h
eCOMP1_SFR      .equ 0900h
SAC0_SFR        .equ 0C80h
SAC1_SFR        .equ 0C90h
SAC2_SFR        .equ 0CA0h
SAC3_SFR        .equ 0CB0h

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------
SFRIE1      .equ SFR_SFR
SFRIFG1     .equ SFR_SFR + 2
SFRRPCR     .equ SFR_SFR + 4

PMMCTL0     .equ PMM_SFR
PMMSWBOR    .equ 4

PM5CTL0     .equ PMM_SFR + 10h    ; Power mode 5 control register 0
LOCKLPM5    .equ 1               ; bit position

; ----------------------------------------------------------------------
; POWER ON RESET SYS config
; ----------------------------------------------------------------------
SYSCTL      .equ SYS_SFR + 00h  ;   System control                      
SYSBSLC     .equ SYS_SFR + 02h  ;   Bootstrap loader configuration area 
SYSJMBC     .equ SYS_SFR + 06h  ;   JTAG mailbox control                
SYSJMBI0    .equ SYS_SFR + 08h  ;   JTAG mailbox input 0                
SYSJMBI1    .equ SYS_SFR + 0Ah  ;   JTAG mailbox input 1                
SYSJMBO0    .equ SYS_SFR + 0Ch  ;   JTAG mailbox output 0               
SYSJMBO1    .equ SYS_SFR + 0Eh  ;   JTAG mailbox output 1               
SYSBERRIV   .equ SYS_SFR + 18h  ;   Bus Error vector generator          
SYSUNIV     .equ SYS_SFR + 1Ah  ;   User NMI vector generator           
SYSSNIV     .equ SYS_SFR + 1Ch  ;   System NMI vector generator         
SYSRSTIV    .equ SYS_SFR + 1Eh  ;   Reset vector generator              
SYSCFG0     .equ SYS_SFR + 20h  ;   System configuration 0              
SYSCFG1     .equ SYS_SFR + 22h  ;   System configuration 1              
SYSCFG2     .equ SYS_SFR + 24h  ;   System configuration 2        
SYSCFG3     .equ SYS_SFR + 26h  ;   System configuration 3        
      
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

WDTCTL      .equ WDT_A_SFR + 00h    ; Watchdog Timer Control */

; WDTCTL Control Bits
WDTPW       .equ 5A00h
WDTHOLD     .equ 0080h  ; WDT - Timer hold
WDTCNTCL    .equ 0008h  ; WDT timer counter clear


; ----------------------------------------------------------------------
; FRAM config
; ----------------------------------------------------------------------

FRCTL0      .equ FRAM_SFR + 00h   ; FRAM Controller Control 0
FRCTL0_H    .equ FRAM_SFR + 01h   ; FRAM Controller Control 0 high byte

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : CLOCK SYSTEM
; ----------------------------------------------------------------------

CSCTL0      .equ CS_SFR + 00h   ; Clock System Control Register 0
CSCTL1      .equ CS_SFR + 02h   ; Clock System Control Register 1
CSCTL2      .equ CS_SFR + 04h   ; Clock System Control Register 2
CSCTL3      .equ CS_SFR + 06h   ; Clock System Control Register 3
CSCTL4      .equ CS_SFR + 08h   ; Clock System Control Register 4
CSCTL5      .equ CS_SFR + 0Ah   ; Clock System Control Register 5
CSCTL6      .equ CS_SFR + 0Ch   ; Clock System Control Register 6
CSCTL7      .equ CS_SFR + 0Eh   ; Clock System Control Register 7
CSCTL8      .equ CS_SFR + 10h   ; Clock System Control Register 8

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT1/2
; ----------------------------------------------------------------------

PAIN        .equ PA_SFR + 00h    ; Port A Input
PAOUT       .equ PA_SFR + 02h    ; Port A Output
PADIR       .equ PA_SFR + 04h    ; Port A Direction
PAREN       .equ PA_SFR + 06h    ; Port A Resistor Enable
PASEL0      .equ PA_SFR + 0Ah    ; Port A Selection 0
PASEL1      .equ PA_SFR + 0Ch    ; Port A Selection 1
PAIES       .equ PA_SFR + 18h    ; Port A Interrupt Edge Select
PAIE        .equ PA_SFR + 1Ah    ; Port A Interrupt Enable
PAIFG       .equ PA_SFR + 1Ch    ; Port A Interrupt Flag

P1IN        .equ PA_SFR + 00h    ; Port 1 Input
P1OUT       .equ PA_SFR + 02h    ; Port 1 Output
P1DIR       .equ PA_SFR + 04h    ; Port 1 Direction
P1REN       .equ PA_SFR + 06h    ; Port 1 Resistor Enable
P1SEL0      .equ PA_SFR + 0Ah    ; Port 1 Selection 0
P1SEL1      .equ PA_SFR + 0Ch    ; Port 1 Selection 1
P1IV        .equ PA_SFR + 0Eh    ; Port 1 Interrupt Vector word 
P1IES       .equ PA_SFR + 18h    ; Port 1 Interrupt Edge Select
P1IE        .equ PA_SFR + 1Ah    ; Port 1 Interrupt Enable
P1IFG       .equ PA_SFR + 1Ch    ; Port 1 Interrupt Flag

P2IN        .equ PA_SFR + 01h    ; Port 2 Input
P2OUT       .equ PA_SFR + 03h    ; Port 2 Output
P2DIR       .equ PA_SFR + 05h    ; Port 2 Direction
P2REN       .equ PA_SFR + 07h    ; Port 2 Resistor Enable
P2SEL0      .equ PA_SFR + 0Bh    ; Port 2 Selection 0
P2SEL1      .equ PA_SFR + 0Dh    ; Port 2 Selection 1
P2IES       .equ PA_SFR + 19h    ; Port 2 Interrupt Edge Select
P2IE        .equ PA_SFR + 1Bh    ; Port 2 Interrupt Enable
P2IFG       .equ PA_SFR + 1Dh    ; Port 2 Interrupt Flag
P2IV        .equ PA_SFR + 1Eh    ; Port 2 Interrupt Vector word 

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT3/4
; ----------------------------------------------------------------------

PBIN        .equ PB_SFR + 00h    ; Port B Input
PBOUT       .equ PB_SFR + 02h    ; Port B Output
PBDIR       .equ PB_SFR + 04h    ; Port B Direction
PBREN       .equ PB_SFR + 06h    ; Port B Resistor Enable
PBSEL0      .equ PB_SFR + 0Ah    ; Port B Selection 0
PBSEL1      .equ PB_SFR + 0Ch    ; Port B Selection 1
PBIES       .equ PB_SFR + 18h    ; Port B Interrupt Edge Select
PBIE        .equ PB_SFR + 1Ah    ; Port B Interrupt Enable
PBIFG       .equ PB_SFR + 1Ch    ; Port B Interrupt Flag

P3IN        .equ PB_SFR + 00h    ; Port 3 Input
P3OUT       .equ PB_SFR + 02h    ; Port 3 Output
P3DIR       .equ PB_SFR + 04h    ; Port 3 Direction
P3REN       .equ PB_SFR + 06h    ; Port 3 Resistor Enable
P3SEL0      .equ PB_SFR + 0Ah    ; Port 3 Selection 0
P3SEL1      .equ PB_SFR + 0Ch    ; Port 3 Selection 1
P3IV        .equ PB_SFR + 0Eh    ; Port 3 Interrupt Vector word 
P3IES       .equ PB_SFR + 18h    ; Port 3 Interrupt Edge Select
P3IE        .equ PB_SFR + 1Ah    ; Port 3 Interrupt Enable
P3IFG       .equ PB_SFR + 1Ch    ; Port 3 Interrupt Flag

P4IN        .equ PB_SFR + 01h    ; Port 4 Input
P4OUT       .equ PB_SFR + 03h    ; Port 4 Output
P4DIR       .equ PB_SFR + 05h    ; Port 4 Direction
P4REN       .equ PB_SFR + 07h    ; Port 4 Resistor Enable
P4SEL0      .equ PB_SFR + 0Bh    ; Port 4 Selection 0
P4SEL1      .equ PB_SFR + 0Dh    ; Port 4 Selection 1
P4IES       .equ PB_SFR + 19h    ; Port 4 Interrupt Edge Select
P4IE        .equ PB_SFR + 1Bh    ; Port 4 Interrupt Enable
P4IFG       .equ PB_SFR + 1Dh    ; Port 4 Interrupt Flag
P4IV        .equ PB_SFR + 1Eh    ; Port 4 Interrupt Vector word 

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------
; PC = P6:P5

PCIN        .equ PC_SFR + 00h    ; Port C Input
PCOUT       .equ PC_SFR + 02h    ; Port C Output 1/0 or pullup/pulldown resistor
PCDIR       .equ PC_SFR + 04h    ; Port C Direction
PCREN       .equ PC_SFR + 06h    ; Port C Resistor Enable
PCSEL0      .equ PC_SFR + 0Ah    ; Port C Selection 0
PCSEL1      .equ PC_SFR + 0Ch    ; Port C Selection 1

P5IN        .equ PC_SFR + 00h    ; Port 5 Input */
P5OUT       .equ PC_SFR + 02h    ; Port 5 Output
P5DIR       .equ PC_SFR + 04h    ; Port 5 Direction
P5REN       .equ PC_SFR + 06h    ; Port 5 Resistor Enable
P5SEL0      .equ PC_SFR + 0Ah    ; Port 5 Selection 0
P5SEL1      .equ PC_SFR + 0Ch    ; Port 5 Selection 1

P6IN        .equ PC_SFR + 01h    ; Port 6 Input */
P6OUT       .equ PC_SFR + 03h    ; Port 6 Output
P6DIR       .equ PC_SFR + 05h    ; Port 6 Direction
P6REN       .equ PC_SFR + 07h    ; Port 6 Resistor Enable
P6SEL0      .equ PC_SFR + 0Bh    ; Port 6 Selection 0
P6SEL1      .equ PC_SFR + 0Dh    ; Port 6 Selection 1



; ----------------------------------------------------------------------
RTC
; ----------------------------------------------------------------------
RTCCTL      .equ RTC_SFR + 00h  ; Real-Time Clock Control 
RTCIV       .equ RTC_SFR + 04h  ; Real-Time Clock Interrupt Vector 
RTCMOD      .equ RTC_SFR + 08h  ; Real-Timer Clock Modulo 
RTCCNT      .equ RTC_SFR + 0Ch  ; Real-Time Clock Counter 

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


    .IFDEF UCA1_TERM
; ----------------------------------------------------------------------
eUSCI_A1
; ----------------------------------------------------------------------
TERM_CTLW0      .equ eUSCI_A1_SFR + 00h    ; eUSCI_A1 Control Word Register 0
TERM_BRW        .equ eUSCI_A1_SFR + 06h    ; eUSCI_A1 Baud Word Rate 0
TERM_MCTLW      .equ eUSCI_A1_SFR + 08h    ; eUSCI_A1 Modulation Control
TERM_STATW      .equ eUSCI_A1_SFR + 0Ah    ; eUSCI_A1 status Word Register
TERM_RXBUF      .equ eUSCI_A1_SFR + 0Ch    ; eUSCI_A1 Receive Buffer
TERM_TXBUF      .equ eUSCI_A1_SFR + 0Eh    ; eUSCI_A1 Transmit Buffer
TERM_IE         .equ eUSCI_A1_SFR + 1Ah    ; eUSCI_A1 Interrupt Enable Register
TERM_IFG        .equ eUSCI_A1_SFR + 1Ch    ; eUSCI_A1 Interrupt Flags Register

TERM_VEC        .equ 0FFE2h ;  int vector for eUSCI_A1
WAKE_UP         .equ 1      ; UART RX interrupt

RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCA1_TERM


    .IFDEF UCB0_TERM
; ----------------------------------------------------------------------
eUSCI_B0
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

TERM_VEC        .equ 0FFE0h ; interrupt vector for eUSCI_B0
WAKE_UP         .equ 4      ; START interrupt

RX_TERM         .equ 1
TX_TERM         .equ 2
    .ENDIF ;UCB0_TERM


    .IFDEF UCB1_SD
; ----------------------------------------------------------------------
eUSCI_B1
; ----------------------------------------------------------------------
SD_CTLW0       .equ eUSCI_B1_SFR + 00h    ; USCI_B1 Control Word Register 0
SD_BRW         .equ eUSCI_B1_SFR + 06h    ; USCI_B1 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_B1_SFR + 0Ch    ; USCI_B1 Receive Buffer 8
SD_TXBUF       .equ eUSCI_B1_SFR + 0Eh    ; USCI_B1 Transmit Buffer 8
SD_IFG         .equ eUSCI_B1_SFR + 2Ch    ; USCI_B1 Interrupt Flags Register

RX_SD           .equ 1
TX_SD           .equ 2
    .ENDIF ;UCB1_SD
