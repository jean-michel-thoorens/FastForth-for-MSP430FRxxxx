; MSP430fr4133.inc
; MSP430FR4133 minimal declarations for FAST FORTH usage
DEVICE = "MSP430FR4133"

; ----------------------------------------------
; MSP430FR4133 MEMORY MAP
; ----------------------------------------------
; 0000-0FFF = peripherals (4 KB)
; 1000-17FF = ROM bootstrap loader BSL0..3 (4x512 B)
; 1800-19FF = info B (FRAM 512 B)
; 1A00-1A7F = TLV device descriptor info (FRAM 128 B)
; 1A80-1FFF = unused
; 2000-27FF = RAM (2 KB)
; 2800-C3FF = unused
; C400-FF7F = code memory (FRAM 15232 B)
; FF80-FFFF = interrupt vectors (FRAM 128 B)
; ----------------------------------------------
PAGESIZE        .equ 512         ; MPU unit
; ----------------------------------------------
; FRAM                          ; INFO B, TLV
; ----------------------------------------------
INFO_ORG        .equ 01800h
INFO_LEN        .equ 00200h
TLV_ORG         .equ 01A00h      ; Device Descriptor Info (Tag-Lenght-Value)
TLV_LEN         .equ 00080h      ;
; ----------------------------------------------
; RAM
; ----------------------------------------------
RAM_ORG         .equ 02000h
RAM_LEN         .equ 00800h
; ----------------------------------------------
; FRAM
; ----------------------------------------------
MAIN_ORG        .equ 0C400h      ; Code space start
SIGNATURES      .equ 0FF80h      ; JTAG/BSL signatures
JTAG_SIG1       .equ 0FF80h      ; if 0 (electronic fuse=0) enable JTAG/SBW ; reset by wipe and by S1+<reset>
JTAG_SIG2       .equ 0FF82h      ; if JTAG_SIG <> |0xFFFFFFFF, 0x00000000|, SBW and JTAG are locked
BSL_SIG1        .equ 0FF84h      ;
BSL_SIG2        .equ 0FF86h      ;
JTAG_PASSWORD   .equ 0FF88h      ; 256 bits
VECT_ORG        .equ 0FFE2h      ; FFE2-FFFF
VECT_LEN        .equ 1Eh
BSL_PASSWORD    .equ 0FFE0h      ; 256 bits

; ----------------------------------------------
; Interrupt Vectors and signatures - MSP430FR4133
; ----------------------------------------------

;    .org    SIGNATURES
;;Start of JTAG and BSL signatures
;        .word   0FFFFh      ; JTAG signature 1
;        .word   0FFFFh      ; JTAG signature 2
;        .word   0FFFFh      ; BSL signature 1, 5555h to disable BSL
;        .word   0FFFFh      ; BSL signature 2
;
;    .org    INTVECT         ; FFE2-FFFF 14 vectors + reset
;
;            .word  reset        ; FFE2h - LCD      
;            .word  reset        ; FFE4h - P2       
;            .word  reset        ; FFE6h - P1       
;            .word  reset        ; FFE8h - ADC10    
;            .word  reset        ; FFEAh - eUSCI_B0 
;            .word  reset        ; FFECh - eUSCI_A0 
;            .word  reset        ; FFEEh - WDT      
;            .word  reset        ; FFF0h - RTC      
;            .word  reset        ; FFF2h - TA1_x    
;            .word  reset        ; FFF4h - TA1_0    
;            .word  reset        ; FFF6h - TA0_x    
;            .word  reset        ; FFF8h - TA0_0    
;            .word  reset        ; FFFAh - UserNMI  
;            .word  reset        ; FFFCh - SysNMI   
;            .word  reset        ; FFFEh - Reset    


; ----------------------------------------------------------------------
; EXP430FR4133 Peripheral File Map
; ----------------------------------------------------------------------
SFR_SFR         .set 0100h           ; Special function
PMM_SFR         .set 0120h           ; PMM
SYS_SFR         .set 0140h           ; SYS
CS_SFR          .set 0180h           ; Clock System
FRAM_SFR        .set 01A0h           ; FRAM control
CRC16_SFR       .set 01C0h
WDT_A_SFR       .set 01CCh           ; Watchdog
PA_SFR          .set 0200h           ; PORT1/2
PB_SFR          .set 0220h           ; PORT3/4
PC_SFR          .set 0240h           ; PORT5/6
PD_SFR          .set 0260h           ; PORT7/8
CTIO0_SFR       .set 02E0h           ; Capacitive Touch IO
TA0_SFR         .set 0300h
TA1_SFR         .set 0340h
RTC_SFR         .set 03C0h
eUSCI_A0_SFR    .set 0500h           ; eUSCI_A0
eUSCI_B0_SFR    .set 0540h           ; eUSCI_B0
LCD_SFR         .set 0600h
BACK_MEM_SFR    .set 0660h
ADC10_B_SFR     .equ 0700h


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : LOCK PMM_LOCKLPM5
; ----------------------------------------------------------------------
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
      
; SYS Control Bits
; ...
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : WATCHDOG TIMER A
; ----------------------------------------------------------------------

WDTCTL      .equ WDT_A_SFR + 00h    ; Watchdog Timer Control */

; WDTCTL Control Bits
WDTPW       .equ 5A00h
WDTHOLD     .equ 0080h  ; WDT - Timer hold
WDTCNTCL    .equ 0008h  ; WDT timer counter clear


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
; PB = P4:P3

PBIN        .set PB_SFR + 00h    ; Port B Input
PBOUT       .set PB_SFR + 02h    ; Port B Output 1/0 or pullup/pulldown resistor
PBDIR       .set PB_SFR + 04h    ; Port B Direction
PBREN       .set PB_SFR + 06h    ; Port B Resistor Enable
PBSEL0      .set PB_SFR + 0Ah    ; Port B Selection 0
PBSEL1      .set PB_SFR + 0Ch    ; Port B Selection 1

P3IN        .set PB_SFR + 00h    ; Port 3 Input */
P3OUT       .set PB_SFR + 02h    ; Port 3 Output
P3DIR       .set PB_SFR + 04h    ; Port 3 Direction
P3REN       .set PB_SFR + 06h    ; Port 3 Resistor Enable
P3SEL0      .set PB_SFR + 0Ah    ; Port 3 Selection 0
P3SEL1      .set PB_SFR + 0Ch    ; Port 3 Selection 1

P4IN        .set PB_SFR + 01h    ; Port 4 Input */
P4OUT       .set PB_SFR + 03h    ; Port 4 Output
P4DIR       .set PB_SFR + 05h    ; Port 4 Direction
P4REN       .set PB_SFR + 07h    ; Port 4 Resistor Enable
P4SEL0      .set PB_SFR + 0Bh    ; Port 4 Selection 0
P4SEL1      .set PB_SFR + 0Dh    ; Port 4 Selection 1


; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT5/6
; ----------------------------------------------------------------------
; PC = P6:P5

PCIN        .set PC_SFR + 00h    ; Port C Input
PCOUT       .set PC_SFR + 02h    ; Port C Output 1/0 or pullup/pulldown resistor
PCDIR       .set PC_SFR + 04h    ; Port C Direction
PCREN       .set PC_SFR + 06h    ; Port C Resistor Enable
PCSEL0      .set PC_SFR + 0Ah    ; Port C Selection 0
PCSEL1      .set PC_SFR + 0Ch    ; Port C Selection 1

P5IN        .set PC_SFR + 00h    ; Port 5 Input */
P5OUT       .set PC_SFR + 02h    ; Port 5 Output
P5DIR       .set PC_SFR + 04h    ; Port 5 Direction
P5REN       .set PC_SFR + 06h    ; Port 5 Resistor Enable
P5SEL0      .set PC_SFR + 0Ah    ; Port 5 Selection 0
P5SEL1      .set PC_SFR + 0Ch    ; Port 5 Selection 1

P6IN        .set PC_SFR + 01h    ; Port 6 Input */
P6OUT       .set PC_SFR + 03h    ; Port 6 Output
P6DIR       .set PC_SFR + 05h    ; Port 6 Direction
P6REN       .set PC_SFR + 07h    ; Port 6 Resistor Enable
P6SEL0      .set PC_SFR + 0Bh    ; Port 6 Selection 0
P6SEL1      .set PC_SFR + 0Dh    ; Port 6 Selection 1

; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION : PORT7/8
; ----------------------------------------------------------------------
; PD = P8:P7

PDIN        .set PD_SFR + 00h    ; Port D Input
PDOUT       .set PD_SFR + 02h    ; Port D Output 1/0 or pullup/pulldown resistor
PDDIR       .set PD_SFR + 04h    ; Port D Direction
PDREN       .set PD_SFR + 06h    ; Port D Resistor Enable
PDSEL0      .set PD_SFR + 0Ah    ; Port D Selection 0
PDSEL1      .set PD_SFR + 0Ch    ; Port D Selection 1

P7IN        .set PD_SFR + 00h    ; Port 7 Input */
P7OUT       .set PD_SFR + 02h    ; Port 7 Output
P7DIR       .set PD_SFR + 04h    ; Port 7 Direction
P7REN       .set PD_SFR + 06h    ; Port 7 Resistor Enable
P7SEL0      .set PD_SFR + 0Ah    ; Port 7 Selection 0
P7SEL1      .set PD_SFR + 0Ch    ; Port 7 Selection 1

P8IN        .set PD_SFR + 01h    ; Port 8 Input */
P8OUT       .set PD_SFR + 03h    ; Port 8 Output
P8DIR       .set PD_SFR + 05h    ; Port 8 Direction
P8REN       .set PD_SFR + 07h    ; Port 8 Resistor Enable
P8SEL0      .set PD_SFR + 0Bh    ; Port 8 Selection 0
P8SEL1      .set PD_SFR + 0Dh    ; Port 8 Selection 1

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
RTC
; ----------------------------------------------------------------------
RTCCTL      .equ RTC_SFR + 00h  ; Real-Time Clock Control 
RTCIV       .equ RTC_SFR + 04h  ; Real-Time Clock Interrupt Vector 
RTCMOD      .equ RTC_SFR + 08h  ; Real-Timer Clock Modulo 
RTCCNT      .equ RTC_SFR + 0Ch  ; Real-Time Clock Counter 



UCSWRST         .equ 1  ; eUSCI Software Reset
UCTXIE          .equ 2  ; eUSCI Transmit Interrupt Enable
UCRXIE          .equ 1  ; eUSCI Receive Interrupt Enable
UCTXIFG         .equ 2  ; eUSCI Transmit Interrupt Flag
UCRXIFG         .equ 1  ; eUSCI Receive Interrupt Flag

; ----------------------------------------------------------------------
eUSCI_A0
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
TERM_VEC         .equ 0FFECh      ;  interrupt vector for eUSCI_A0
    .ENDIF ;UCA0_TERM

; ----------------------------------------------------------------------
; eUSCI_B0
; ----------------------------------------------------------------------

    .IFDEF UCB0_SD
SD_CTLW0       .equ eUSCI_B0_SFR + 00h    ; USCI_B0 Control Word Register 0
SD_BRW         .equ eUSCI_B0_SFR + 06h    ; USCI_B0 Baud Word Rate 0
SD_RXBUF       .equ eUSCI_B0_SFR + 0Ch    ; USCI_B0 Receive Buffer 8
SD_TXBUF       .equ eUSCI_B0_SFR + 0Eh    ; USCI_B0 Transmit Buffer 8
SD_IFG         .equ eUSCI_B0_SFR + 2Ch    ; USCI_B0 Interrupt Flags Register
    .ENDIF ;UCB0_SD

