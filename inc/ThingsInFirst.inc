; ThingsInFirst.inc

    .cpu MSP430X    ; define CPU

BIT0        .equ 1
BIT1        .equ 2
BIT2        .equ 4
BIT3        .equ 8
BIT4        .equ 16
BIT5        .equ 32
BIT6        .equ 64
BIT7        .equ 128
BIT8        .equ 256
BIT9        .equ 512
BIT10       .equ 1024
BIT11       .equ 2048
BIT12       .equ 4096
BIT13       .equ 8192
BIT14       .equ 16384
BIT15       .equ 32768

; ----------------------------------------------
; MACROS FOR assembly instructions
; ----------------------------------------------
NOP         .macro      ; 1 word, 1 cycle    
            .word 4303h ; mov #0, r3         
            .endm

NOP2        .macro      ; 1 Word, 2 cycles
            .word 3C00h ; jmp $+2
            .endm

NOP3        .macro      ; 1 Word, 3 cycles
            .word 4000h ; MOV PC,PC
            .endm

; SR(11:0) bits are saved by interrupts and restored by the instruction RETI
C           .equ 0001h
Z           .equ 0002h
N           .equ 0004h
GIE         .equ 0008h
CPUOFF      .equ 0010h ; CPU Off.                  1=turn_off_CPU
OSCOFF      .equ 0020h ; Oscillator Off.           1=turn_off_LFXT1CLK
SCG0        .equ 0040h ; System Clock Generator 0. 1=turn_off_DCO
SCG1        .equ 0080h ; System Clock Generator 1. 1=turn_off_SMCLK
V           .equ 0100h
UF9         .equ 0200h ; = SR(9) User Flag 9
UF10        .equ 0400h ; = SR(10) User Flag 10
UF11        .equ 0800h ; = SR(11) User Flag 11  
;----------------------------------------------------------------------------
LPM0        .equ CPUOFF
LPM1        .equ SCG0 + CPUOFF  ; for devices with FLL: LPM1 = LPM0 + FLL disabled
LPM2        .equ SCG1 + CPUOFF
LPM3        .equ SCG1 + SCG0 + CPUOFF
LPM4        .equ SCG1 + SCG0 + OSCOFF + CPUOFF

;-------------------------------------------------------------------------------
; DEFINING FORTH REGISTERS - DTC model
;-------------------------------------------------------------------------------
RSP         .reg    R1      ; RSP = Return Stack Pointer (return stack)
;                   R2      ; not to be used
;                   R3      ; not to be used
; DOxxx registers           ; must be saved before use and restored after use
rDOCOL      .reg    R4
rDODOES     .reg    r5      ; to restore: MOV #XDODOES,rDODOES
rDOCON      .reg    r6      ; to restore: MOV #XDOCON,rDOCON
rDOVAR      .reg    r7      ; to restore: MOV #R>,rDOVAR
; rDOxxx alias
R           .reg    r4      ; rDOCOL alias
Q           .reg    r5      ; rDODOES alias
P           .reg    r6      ; rDOCON alias
M           .reg    R7      ; rDOVAR alias
; Scratch registers
Y           .reg    R8
X           .reg    R9
W           .reg    R10
T           .reg    R11
S           .reg    R12
; Forth virtual machine
IP          .reg    R13     ; interpretative pointer
TOS         .reg    R14     ; first PSP cell
PSP         .reg    R15     ; PSP = Parameters Stack Pointer (stack data)

; ----------------------------------------------
; EXECUTIVE WORDS FOR Direct-Threaded Code (DTC)
; ----------------------------------------------
;-------------------------------------------------------------------------------
; very nice FAST FORTH feature:
; as IP is always computed from the PC value, we can place low to high level
; "ASMtoFORTH" or "mDOCOL" switches anywhere in a word, i.e. not only at its
; beginning as ITC competitors.
;-------------------------------------------------------------------------------
    .SWITCH DTC

    .CASE 1 ; DOCOL = CALL rDOCOL, [rDOCOL] = XDOCOL
ASMtoFORTH  .MACRO                  ; compiled by LO2HI
            CALL #EXIT              ; 10 cycles
            .ENDM                   ; 2 words, 10 cycles
                                    ; LO2HI + HI2LO = 3 words, 10 cycles.

mDOCOL      .MACRO                  ; compiled by : and by colon
            CALL rDOCOL             ; 10 [rDOCOL] = XDOCOL
            .ENDM                   ; 1 word, 14 cycles (CALL included) (ITC+4)
                                    ; COLON + SEMI = 2 words, 20 cycles (ITC+2)
    .CASE 2 ; DOCOL = PUSH IP + CALL rDOCOL, [rDOCOL] = EXIT
ASMtoFORTH  .MACRO                  ; compiled by LO2HI
            CALL rDOCOL             ; 10 [rDOCOL] = EXIT
            .ENDM                   ; 1 word, 10 cycles. 
                                    ; LO2HI + HI2LO = 2 words, 10 cycles.

mDOCOL      .MACRO                  ; compiled by : and by COLON
            PUSH IP                 ; 3
            CALL rDOCOL             ; 10 [rDOCOL] = EXIT
            .ENDM                   ; 2 words, 13 cycles (ITC+3)
                                    ; COLON + SEMI = 3 words, 19 cycles (ITC+1)
    .CASE 3 ; inlined DOCOL
ASMtoFORTH  .MACRO                  ; compiled by LO2HI
            MOV PC,IP               ; 1
            ADD #4,IP               ; 1
            MOV @IP+,PC             ; 4 NEXT
            .ENDM                   ; 6 cycles, 3 words
                                    ; LO2HI + HI2LO = 4 words, 6 cycles.

mDOCOL      .MACRO                  ; compiled by : and by COLON
            PUSH IP                 ; 3
            MOV PC,IP               ; 1
            ADD #4,IP               ; 1
            MOV @IP+,PC             ; 4 NEXT
            .ENDM                   ; 4 words, 9 cycles (ITC-1)
                                    ; COLON + SEMI = 5 words, 15 cycles (ITC-3)
    .ENDCASE ; DTC

    .save
    .listing off
; ----------------------------------------------
; INIT VOCABULARY POINTERS and MACROS FOR HEADER
; ----------------------------------------------
voclink     .set 0  ; init vocabulary links
forthlink   .set 0
asmlink     .set 0

    .IF THREADS = 1

FORTHWORD   .MACRO  name
            .word   forthlink
forthlink   .set    $
            .byte   STRLEN(name),name
;            .align  2
            .ENDM

FORTHWORDIMM .MACRO  name
            .word   forthlink
forthlink   .set    $
            .byte   STRLEN(name)+128,name
;            .align  2
            .ENDM

asmword     .MACRO  name
            .word   asmlink
asmlink     .set    $
            .byte   STRLEN(name),name
;            .align  2
            .ENDM

    .ELSE
forthlink1  .set 0
forthlink2  .set 0
forthlink3  .set 0
forthlink4  .set 0
forthlink5  .set 0
forthlink6  .set 0
forthlink7  .set 0
forthlink8  .set 0
forthlink9  .set 0
forthlink10 .set 0
forthlink11 .set 0
forthlink12 .set 0
forthlink13 .set 0
forthlink14 .set 0
forthlink15 .set 0
forthlink16 .set 0
forthlink17 .set 0
forthlink18 .set 0
forthlink19 .set 0
forthlink20 .set 0
forthlink21 .set 0
forthlink22 .set 0
forthlink23 .set 0
forthlink24 .set 0
forthlink25 .set 0
forthlink26 .set 0
forthlink27 .set 0
forthlink28 .set 0
forthlink29 .set 0
forthlink30 .set 0
forthlink31 .set 0

asmlink1    .set 0
asmlink2    .set 0
asmlink3    .set 0
asmlink4    .set 0
asmlink5    .set 0
asmlink6    .set 0
asmlink7    .set 0
asmlink8    .set 0
asmlink9    .set 0
asmlink10   .set 0
asmlink11   .set 0
asmlink12   .set 0
asmlink13   .set 0
asmlink14   .set 0
asmlink15   .set 0
asmlink16   .set 0
asmlink17   .set 0
asmlink18   .set 0
asmlink19   .set 0
asmlink20   .set 0
asmlink21   .set 0
asmlink22   .set 0
asmlink23   .set 0
asmlink24   .set 0
asmlink25   .set 0
asmlink26   .set 0
asmlink27   .set 0
asmlink28   .set 0
asmlink29   .set 0
asmlink30   .set 0
asmlink31   .set 0

;-------------------------------------------
; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
;-------------------------------------------
FORTHWORD   .MACRO  name
CONTEXTofst .set    charfromstr(name,0) & ((THREADS-1)*2)
    .SWITCH CONTEXTofst
    .case 0
            .word   forthlink
forthlink   .set    $
    .case 2
            .word   forthlink1
forthlink1  .set    $
    .case 4
            .word   forthlink2
forthlink2  .set    $
    .case 6
            .word   forthlink3
forthlink3  .set    $
    .case 8
            .word   forthlink4
forthlink4  .set    $
    .case 10
            .word   forthlink5
forthlink5  .set    $
    .case 12
            .word   forthlink6
forthlink6  .set    $
    .case 14
            .word   forthlink7
forthlink7  .set    $
    .case 16
            .word   forthlink8
forthlink8  .set    $
    .case 18
            .word   forthlink9
forthlink9  .set    $
    .case 20
            .word   forthlink10
forthlink10 .set    $
    .case 22
            .word   forthlink11
forthlink11 .set    $
    .case 24
            .word   forthlink12
forthlink12 .set    $
    .case 26
            .word   forthlink13
forthlink13 .set    $
    .case 28
            .word   forthlink14
forthlink14 .set    $
    .case 30
            .word   forthlink15
forthlink15 .set    $
    .case 32
            .word   forthlink16
forthlink16 .set    $
    .case 34
            .word   forthlink17
forthlink17 .set    $
    .case 36
            .word   forthlink18
forthlink18 .set    $
    .case 38
            .word   forthlink19
forthlink19 .set    $
    .case 40
            .word   forthlink20
forthlink20 .set    $
    .case 42
            .word   forthlink21
forthlink21 .set    $
    .case 44
            .word   forthlink22
forthlink22 .set    $
    .case 46
            .word   forthlink23
forthlink23 .set    $
    .case 48
            .word   forthlink24
forthlink24 .set    $
    .case 50
            .word   forthlink25
forthlink25 .set    $
    .case 52
            .word   forthlink26
forthlink26 .set    $
    .case 54
            .word   forthlink27
forthlink27 .set    $
    .case 56
            .word   forthlink28
forthlink28 .set    $
    .case 58
            .word   forthlink29
forthlink29 .set    $
    .case 60
            .word   forthlink30
forthlink30 .set    $
    .case 62
            .word   forthlink31
forthlink31 .set    $
    .endcase
            .byte   STRLEN(name),name
            .ENDM

;-------------------------------------------
; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
;-------------------------------------------
FORTHWORDIMM .MACRO  name
CONTEXTofst .set    charfromstr(name,0) &  ((THREADS-1)*2)
    .SWITCH CONTEXTofst
    .case 0
            .word   forthlink
forthlink   .set    $
    .case 2
            .word   forthlink1
forthlink1  .set    $
    .case 4
            .word   forthlink2
forthlink2  .set    $
    .case 6
            .word   forthlink3
forthlink3  .set    $
    .case 8
            .word   forthlink4
forthlink4  .set    $
    .case 10
            .word   forthlink5
forthlink5  .set    $
    .case 12
            .word   forthlink6
forthlink6  .set    $
    .case 14
            .word   forthlink7
forthlink7  .set    $
    .case 16
            .word   forthlink8
forthlink8  .set    $
    .case 18
            .word   forthlink9
forthlink9  .set    $
    .case 20
            .word   forthlink10
forthlink10 .set    $
    .case 22
            .word   forthlink11
forthlink11 .set    $
    .case 24
            .word   forthlink12
forthlink12 .set    $
    .case 26
            .word   forthlink13
forthlink13 .set    $
    .case 28
            .word   forthlink14
forthlink14 .set    $
    .case 30
            .word   forthlink15
forthlink15 .set    $
    .case 32
            .word   forthlink16
forthlink16 .set    $
    .case 34
            .word   forthlink17
forthlink17 .set    $
    .case 36
            .word   forthlink18
forthlink18 .set    $
    .case 38
            .word   forthlink19
forthlink19 .set    $
    .case 40
            .word   forthlink20
forthlink20 .set    $
    .case 42
            .word   forthlink21
forthlink21 .set    $
    .case 44
            .word   forthlink22
forthlink22 .set    $
    .case 46
            .word   forthlink23
forthlink23 .set    $
    .case 48
            .word   forthlink24
forthlink24 .set    $
    .case 50
            .word   forthlink25
forthlink25 .set    $
    .case 52
            .word   forthlink26
forthlink26 .set    $
    .case 54
            .word   forthlink27
forthlink27 .set    $
    .case 56
            .word   forthlink28
forthlink28 .set    $
    .case 58
            .word   forthlink29
forthlink29 .set    $
    .case 60
            .word   forthlink30
forthlink30 .set    $
    .case 62
            .word   forthlink31
forthlink31 .set    $
    .endcase
            .byte   80h+STRLEN(name),name
            .ENDM

;-------------------------------------------
; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
;-------------------------------------------
asmword     .MACRO  name
CONTEXTofst .set    charfromstr(name,0) &  ((THREADS-1)*2)
    .SWITCH CONTEXTofst
    .case 0
            .word   asmlink
asmlink   .set    $
    .case 2
            .word   asmlink1
asmlink1  .set    $
    .case 4
            .word   asmlink2
asmlink2  .set    $
    .case 6
            .word   asmlink3
asmlink3  .set    $
    .case 8
            .word   asmlink4
asmlink4  .set    $
    .case 10
            .word   asmlink5
asmlink5  .set    $
    .case 12
            .word   asmlink6
asmlink6  .set    $
    .case 14
            .word   asmlink7
asmlink7  .set    $
    .case 16
            .word   asmlink8
asmlink8  .set    $
    .case 18
            .word   asmlink9
asmlink9  .set    $
    .case 20
            .word   asmlink10
asmlink10 .set    $
    .case 22
            .word   asmlink11
asmlink11 .set    $
    .case 24
            .word   asmlink12
asmlink12 .set    $
    .case 26
            .word   asmlink13
asmlink13 .set    $
    .case 28
            .word   asmlink14
asmlink14 .set    $
    .case 30
            .word   asmlink15
asmlink15 .set    $
    .case 32
            .word   asmlink16
asmlink16 .set    $
    .case 34
            .word   asmlink17
asmlink17 .set    $
    .case 36
            .word   asmlink18
asmlink18 .set    $
    .case 38
            .word   asmlink19
asmlink19 .set    $
    .case 40
            .word   asmlink20
asmlink20 .set    $
    .case 42
            .word   asmlink21
asmlink21 .set    $
    .case 44
            .word   asmlink22
asmlink22 .set    $
    .case 46
            .word   asmlink23
asmlink23 .set    $
    .case 48
            .word   asmlink24
asmlink24 .set    $
    .case 50
            .word   asmlink25
asmlink25 .set    $
    .case 52
            .word   asmlink26
asmlink26 .set    $
    .case 54
            .word   asmlink27
asmlink27 .set    $
    .case 56
            .word   asmlink28
asmlink28 .set    $
    .case 58
            .word   asmlink29
asmlink29 .set    $
    .case 60
            .word   asmlink30
asmlink30 .set    $
    .case 62
            .word   asmlink31
asmlink31 .set    $
    .endcase ; asmlink
            .byte   STRLEN(name),name
            .ENDM

    .endif ; thread case

; -------------------------------------
; define MAIN max bound
; -------------------------------------
FRAM_FULL   .equ SIGNATURES-40h ; set to protect JTAG and BSL signatures against overwrite.
                                ; 64 bytes are sufficient considering what can be compiled in one line + WORD use.
                                ; take care with ALLOT : don't ALLOT more than 32 words by line!
    .restore
; --------------------------
; COMPUTE ASSEMBLY SWITCHES
; --------------------------
    .IFDEF CORE_COMPLEMENT
        .IFNDEF USE_MOVE
USE_MOVE
        .ENDIF
    .ENDIF
    .IFDEF UTILITY
        .IFNDEF USE_MOVE
USE_MOVE
        .ENDIF
    .ENDIF
    .IFDEF FIXPOINT_INPUT
        .IFNDEF DOUBLE_INPUT
DOUBLE_INPUT
        .ENDIF
    .ENDIF
    .IFDEF SD_CARD_LOADER 
; define if QUIT is DEFERed
        .IFNDEF DOUBLE_INPUT
DOUBLE_INPUT
        .ENDIF
        .IFNDEF DEFER_ACCEPT
DEFER_ACCEPT
        .ENDIF
        .IFDEF BOOTLOADER
            .IFNDEF CONDCOMP
CONDCOMP                    ; mandatory for Bootstrap
            .ENDIF
            .IFNDEF DEFER_QUIT
DEFER_QUIT
            .ENDIF
        .ENDIF
    .ENDIF
    .IFDEF EXTENDED_ASM
        .IFNDEF DOUBLE_INPUT
DOUBLE_INPUT
        .ENDIF
    .ELSE
        .IFDEF EXTENDED_MEM
            .IFNDEF MSP430ASSEMBLER
MSP430ASSEMBLER
            .ENDIF
            .IFNDEF DOUBLE_INPUT
DOUBLE_INPUT
            .ENDIF
        .ENDIF
    .ENDIF
    .IFDEF FIXPOINT
        .IFNDEF FIXPOINT_INPUT
FIXPOINT_INPUT              ; to interpret fixpoint numbers
        .ENDIF
    .ENDIF
    .IFDEF FIXPOINT_INPUT
    .IFNDEF DOUBLE_NUMBERS
DOUBLE_NUMBERS              ; to process double numbers
    .ENDIF
    .ENDIF
    .IFDEF DOUBLE_INPUT
    .IFNDEF DOUBLE_NUMBERS
DOUBLE_NUMBERS              ; to process double numbers
    .ENDIF
    .ENDIF

; --------------------------
; COMPUTE BAUDRATE registers = fn(FREQUENCY,BAUDS)
; --------------------------
    .IFNDEF TERMINAL_I2C
        .include "TERMINALBAUDRATE.inc"
    .ENDIF
;-----------------------------------------------------------------------
; DEVICE I/O, MEMORY, SFR, vectors and minimum FORTH I/O declarations
;-----------------------------------------------------------------------
    .IFDEF MSP_EXP430FR5739
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA0_TERM
        .ENDIF
UCA1_SD
        .include "MSP430FR5739.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR5969
;EXTENDED_MEM
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA0_TERM
        .ENDIF
UCA1_SD
        .include "MSP430FR5969.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR5994
;EXTENDED_MEM
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB2_TERM
        .ELSE
UCA0_TERM
        .ENDIF
UCB0_SD
        .include "MSP430FR5994.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR6989
;EXTENDED_MEM
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA1_TERM
        .ENDIF
UCA0_SD
        .INCLUDE "MSP430FR6989.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR5972
;EXTENDED_MEM
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA1_TERM
        .ENDIF
UCA0_SD
        .INCLUDE "MSP430FR5972.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR4133
FLL
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA0_TERM
UCB0_SD
        .ENDIF
        .INCLUDE "MSP430FR4133.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR2433
FLL
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA0_TERM
        .ENDIF
UCA1_SD
        .include "MSP430FR2433.inc"
    .ENDIF
    .IFDEF CHIPSTICK_FR2433
FLL
; no LF_XTAL to select ACLK = REFOCLK
        .IFDEF TERMINAL_I2C
UCB0_TERM
UCA0_SD
        .ELSE
UCA0_TERM
UCB0_SD
        .ENDIF
        .include "MSP430FR2433.inc"
    .ENDIF
    .IFDEF MSP_EXP430FR2355
FLL
LF_XTAL
        .IFDEF TERMINAL_I2C
UCB0_TERM
        .ELSE
UCA1_TERM
        .ENDIF
UCB1_SD
        .include "MSP430FR2355.inc"
    .ENDIF
    .IFDEF LP_MSP430FR2476
FLL
;EXTENDED_MEM
; LF_XTAL       ; connect resistors R2=0k, R3=0k before uncomment this line
        .IFDEF TERMINAL_I2C
UCB1_TERM
        .ELSE
UCA0_TERM
        .ENDIF
UCA1_SD
        .include "MSP430FR2476.inc"
    .ENDIF
    .IFDEF YOUR_TARGET
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
; add here your device.inc item:
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    .ENDIF

    .restore
; ---------------------------
; compute value of FORTHADDON
; ---------------------------
FADDON .set 0
    .IFDEF LF_XTAL
FADDON .SET FADDON | BIT15  ; LFXTAL = 32768 Hz
    .ENDIF
    .IFNDEF TERMINAL_I2C ; if TERMINAL UART...
        .IFDEF TERMINAL5WIRES
FADDON .SET FADDON | BIT14  ; UART CTS
        .ENDIF
        .IFDEF TERMINAL4WIRES
FADDON .SET FADDON | BIT13  ; UART RTS
        .ENDIF
        .IFDEF TERMINAL3WIRES
FADDON .SET FADDON | BIT12  ; UART XON/XOFF
        .ENDIF
        .IFDEF HALFDUPLEX
FADDON .SET FADDON | BIT11  ; UART Half Duplex
        .ENDIF
    .ENDIF ; TERMINAL UART
    .IFDEF FIXPOINT_INPUT
FADDON .SET FADDON | BIT10  ; FIXPOINT INPUT
    .ENDIF
    .IFDEF DOUBLE_INPUT
FADDON .SET FADDON | BIT9   ; DOUBLE INPUT
    .ENDIF
    .IFDEF EXTENDED_ASM     ; Assembler 20 bits
FADDON .SET FADDON | BIT8
    .ENDIF
    .IFDEF MSP430ASSEMBLER
FADDON .SET FADDON | BIT7   ; Assembler 16 bits
    .ENDIF
    .IFDEF EXTENDED_MEM
    .IFNDEF EXTENDED_ASM
FADDON .SET FADDON | BIT6   ; Assembler 16 bits with Address access beyond $FFFF
    .ENDIF
    .ENDIF
    .IFDEF CONDCOMP
FADDON .SET FADDON | BIT0   ; Conditionnal Compilation
    .ENDIF
