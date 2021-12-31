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
DOCOL       .equ 1284h              ; 1284h = CALL rDOCOL instruction
DODOES      .equ 1285h              ; 1285h = CALL rDODOES instruction
DOCON       .equ 1286h              ; 1286h = CALL rDOCON instruction
DOVAR       .equ 1287h              ; 1287h = CALL rDOVAR instruction



    .SWITCH DTC

    .CASE 1 ; DOCOL = CALL rDOCOL, [rDOCOL] = XDOCOL
mASM2FORTH  .MACRO                  ; compiled by LO2HI
            CALL #EXIT              ; 10 cycles
            .ENDM                   ; 2 words, 10 cycles
                                    ; LO2HI + HI2LO = 3 words, 10 cycles.

mDOCOL      .MACRO                  ; compiled by : and by colon
            CALL rDOCOL             ; 10 [rDOCOL] = XDOCOL
            .ENDM                   ; 1 word, 14 cycles (CALL included) (ITC+4)
                                    ; COLON + SEMI = 2 words, 20 cycles (ITC+2)
    .CASE 2 ; DOCOL = PUSH IP + CALL rDOCOL, [rDOCOL] = EXIT
mASM2FORTH  .MACRO                  ; compiled by LO2HI
            CALL rDOCOL             ; 10 [rDOCOL] = EXIT
            .ENDM                   ; 1 word, 10 cycles.
                                    ; LO2HI + HI2LO = 2 words, 10 cycles.

mDOCOL      .MACRO                  ; compiled by : and by COLON
            PUSH IP                 ; 3
            CALL rDOCOL             ; 10 [rDOCOL] = EXIT
            .ENDM                   ; 2 words, 13 cycles (ITC+3)
                                    ; COLON + SEMI = 3 words, 19 cycles (ITC+1)
    .CASE 3 ; inlined DOCOL
mASM2FORTH  .MACRO                  ; compiled by LO2HI
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

mNEXTADR    .MACRO
            .word   $+2
            .ENDM

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
            .byte   STRLEN(name)*2,name
;            .align  2
            .ENDM

FORTHWORDIMM .MACRO  name
            .word   forthlink
forthlink   .set    $
            .byte   STRLEN(name)*2+1,name ; bit 0 is the immediate flag
;            .align  2
            .ENDM

asmword     .MACRO  name
            .word   asmlink
asmlink     .set    $
            .byte   STRLEN(name)*2,name
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
CONTEXTofst .set    (charfromstr(name,0) & (THREADS-1))*2
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
            .byte   STRLEN(name)*2,name
            .ENDM

;-------------------------------------------
; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
;-------------------------------------------
FORTHWORDIMM .MACRO  name
CONTEXTofst .set    (charfromstr(name,0) & (THREADS-1))*2
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
            .byte   STRLEN(name)*2+1,name ; bit 0 is the immediate flag
            .ENDM

;-------------------------------------------
; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
;-------------------------------------------
asmword     .MACRO  name
CONTEXTofst .set    (charfromstr(name,0) & (THREADS-1))*2
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
            .byte   STRLEN(name)*2,name
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
    .IFDEF SD_CARD_LOADER
        .IFNDEF DOUBLE_INPUT
DOUBLE_INPUT
        .ENDIF
        .IFDEF BOOTLOADER
            .IFNDEF CONDCOMP
CONDCOMP                    ; mandatory for Bootstrap
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
FADDON .set 0

    .IFDEF MSP_EXP430FR5739
FADDON .SET FADDON | BIT0   ; hardware MPY
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
FADDON .SET FADDON | BIT0   ; hardware MPY
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
FADDON .SET FADDON | BIT0   ; hardware MPY
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
FADDON .SET FADDON | BIT0   ; hardware MPY
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
FADDON .SET FADDON | BIT0   ; hardware MPY
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
FADDON .SET FADDON | BIT0   ; hardware MPY
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
FADDON .SET FADDON | BIT0   ; hardware MPY
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
    .IFDEF FLOORED_DIVISION
FADDON .SET FADDON | BIT15  ; FLOORED_DIVISION
    .ENDIF
    .IFDEF LF_XTAL
FADDON .SET FADDON | BIT14  ; LFXTAL = 32768 Hz
    .ENDIF
    .IFNDEF TERMINAL_I2C ; if TERMINAL UART...
        .IFDEF TERMINAL5WIRES
FADDON .SET FADDON | BIT13  ; UART CTS
        .ENDIF
        .IFDEF TERMINAL4WIRES
FADDON .SET FADDON | BIT12  ; UART RTS
        .ENDIF
        .IFDEF TERMINAL3WIRES
FADDON .SET FADDON | BIT11  ; UART XON/XOFF
        .ENDIF
        .IFDEF HALFDUPLEX
FADDON .SET FADDON | BIT10  ; UART Half Duplex
        .ENDIF
    .ENDIF ; TERMINAL UART
; ---------------------------
        .IFDEF TERMINAL_I2C
FADDON .SET FADDON | BIT9   ;I2C TERMINAL
        .ENDIF
    .IFDEF FIXPOINT_INPUT
FADDON .SET FADDON | BIT8   ; Q15.16 INPUT
    .ENDIF
    .IFDEF DOUBLE_INPUT
FADDON .SET FADDON | BIT7   ; DOUBLE INPUT
    .ENDIF
; ---------------------------
    .IFDEF EXTENDED_ASM     ; Assembler 20 bits
FADDON .SET FADDON | BIT6
    .ENDIF
;    .IFDEF MSP430ASSEMBLER
FADDON .SET FADDON | BIT5   ; Assembler 16 bits
;    .ENDIF
    .IFDEF EXTENDED_MEM
        .IFNDEF EXTENDED_ASM
FADDON .SET FADDON | BIT4   ; Assembler 16 bits with Address access beyond $FFFF
        .ENDIF
    .ENDIF
; ---------------------------
;    .IFDEF VOCABULARY_SET   ;
;FADDON .SET FADDON | BIT3   ; vocabulary set
;    .ENDIF                  ; BIT2 to BIT0 are free



;-------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx RAM memory map:
;-------------------------------------------------------------------------------

;---------------------------;---------
; name             words    ; comment
;---------------------------;---------
;LSTACK = L0 = LEAVEPTR     ; ----- RAM_ORG
                            ; |
LSTACK_LEN .equ     16      ; | grows up
                            ; V
                            ; ^
PSTACK_LEN .equ     48      ; | grows down
                            ; |
;PSTACK=S0                  ; ----- RAM_ORG + $80
                            ; ^
RSTACK_LEN .equ     48      ; | grows down
                            ; |
;RSTACK=R0                  ; ----- RAM_ORG + $E0

;---------------------------;---------
; names            bytes    ; comments
;---------------------------;---------
; PAD_I2CADR                ; ----- RAM_ORG + $E0
; PAD_I2CCNT                ;
; PAD                       < ----- RAM_ORG + $E4
                            ; |
PAD_LEN     .equ    84      ; | grows up    (ans spec. : PAD >= 84 chars)
                            ; v
; TIB_I2CADR                ; ----- RAM_ORG + $138
; TIB_I2CCNT                ;
; TIB                       < ----- RAM_ORG + $13C
                            ; |
CIB_LEN     .equ    84      ; | grows up    Current Input Buffer (ans spec. : TIB >= 80 chars)
                            ; v
; HOLDS_ORG                 < ------RAM_ORG + $190
                            ; ^
HOLD_LEN   .equ     34      ; | grows down  (ans spec. : HOLD_LEN >= (2*n) + 2 char, with n = 16 bits/cell
                            ; |
; HOLD_BASE                 < ----- RAM_ORG + $1B2
                            ;
                            ;       system variables
                            ;
                            ; ----- RAM_ORG + $1E0
                            ;
                            ;       28 bytes free
                            ;
; SD_BUF_I2CADR             < ----- RAM_ORG + $1FC
; SD_BUF_I2CCNT             ;
; SD_BUF                    < ----- RAM_ORG + $200
                            ;
SD_BUF_LEN   .equ   200h    ;       512 bytes buffer
                            ;
; SD_BUF_END                < ----- RAM_ORG + $400

LSTACK          .equ RAM_ORG
LEAVEPTR        .equ LSTACK             ; Leave-stack pointer
PSTACK          .equ LSTACK+(LSTACK_LEN*2)+(PSTACK_LEN*2)
RSTACK          .equ PSTACK+(RSTACK_LEN*2)
PAD_I2CADR      .equ PAD_ORG-4
PAD_I2CCNT      .equ PAD_ORG-2
PAD_ORG         .equ RSTACK+4
TIB_I2CADR      .equ TIB_ORG-4
TIB_I2CCNT      .equ TIB_ORG-2
TIB_ORG         .equ PAD_ORG+PAD_LEN+4
HOLDS_ORG       .equ TIB_ORG+CIB_LEN

HOLD_BASE       .equ HOLDS_ORG+HOLD_LEN

; ----------------------------------------------------
; RAM_ORG + $1B2 : RAM VARIABLES
; ----------------------------------------------------
HP              .equ HOLD_BASE      ; HOLD ptr
; ----------------------------------------------------
; new definition pointers, generated by HEADER
; ----------------------------------------------------
LAST_NFA        .equ HOLD_BASE+2    ; used by REVEAL, IMMEDIATE
LAST_THREAD     .equ HOLD_BASE+4    ;    "    REVEAL
LAST_CFA        .equ HOLD_BASE+6    ;    "    DOES>, RECURSE
LAST_PSP        .equ HOLD_BASE+8    ;    "    REVEAL
; ----------------------------------------------------
; FORTH interpreter variables
; ----------------------------------------------------
STATE           .equ HOLD_BASE+10   ; Interpreter state
BASEADR         .equ HOLD_BASE+12   ; BASE
CAPS            .equ HOLD_BASE+14   ; CAPS
; ----------------------------------------------------
SOURCE          .equ HOLD_BASE+16   ; len, org of input stream
SOURCE_LEN      .equ HOLD_BASE+16   ;
SOURCE_ORG      .equ HOLD_BASE+18   ;
TOIN            .equ HOLD_BASE+20   ; CurrentInputBuffer pointer
; ----------------------------------------------------
; FORTH environment
; ----------------------------------------------------
DP              .equ HOLD_BASE+22   ; dictionnary pointer
LASTVOC         .equ HOLD_BASE+24   ;
CURRENT         .equ HOLD_BASE+26   ;
CONTEXT         .equ HOLD_BASE+28   ; 8 words of depth ending
NULL_WORD       .equ HOLD_BASE+44   ; with a null word in addition
; ----------------------------------;

    .IFDEF SD_CARD_LOADER
; --------------------------------------------------
; RAM_ORG + $1FC : RAM SD_CARD SD_BUF 4 + 512 bytes
; --------------------------------------------------
SD_BUF_I2CADR   .equ SD_BUF-4
SD_BUF_I2CCNT   .equ SD_BUF-2
SD_BUF          .equ HOLD_BASE+78
SD_BUF_END      .equ SD_BUF+200h        ; 512bytes
; --------------------------------------------------
; RAM_ORG + $400 : free RAM
; --------------------------------------------------
    .ENDIF

    .IFDEF SD_CARD_LOADER
; ---------------------------------------
; VARIABLES that should be in RAM
; ---------------------------------------
        .IF RAM_LEN < 2048              ; if RAM < 2K (FR57xx) the variables below are in INFO space (FRAM)
SD_ORG     .equ INFO_ORG+5Ah            ;
        .ELSE                           ; if RAM >= 2k the variables below are in RAM
SD_ORG     .equ SD_BUF_END+2            ; 1 word guard
        .ENDIF

    .org SD_ORG
; ---------------------------------------
; FAT FileSystemInfos
; ---------------------------------------
;FATtype         .equ SD_ORG+0
BS_FirstSectorL .equ SD_ORG+2           ; init by SD_Init, used by RW_Sector_CMD
BS_FirstSectorH .equ SD_ORG+4           ; init by SD_Init, used by RW_Sector_CMD
OrgFAT1         .equ SD_ORG+6           ; init by SD_Init,
FATSize         .equ SD_ORG+8           ; init by SD_Init,
OrgFAT2         .equ SD_ORG+10          ; init by SD_Init,
;OrgRootDIR      .equ SD_ORG+12          ; init by SD_Init,
OrgClusters     .equ SD_ORG+14          ; init by SD_Init, Sector of Cluster 0
SecPerClus      .equ SD_ORG+16          ; init by SD_Init, byte size
; ---------------------------------------
; SD command
; ---------------------------------------
SD_LOW_LEVEL    .equ SD_ORG+18
SD_CMD_FRM      .equ SD_LOW_LEVEL       ; SD_CMDx inverted frame ${CRC7,ll,LL,hh,HH,CMD}
SectorL         .equ SD_LOW_LEVEL+6
SectorH         .equ SD_LOW_LEVEL+8
; ---------------------------------------
; SD_BUF management
; ---------------------------------------
BufferPtr       .equ SD_LOW_LEVEL+10
BufferLen       .equ SD_LOW_LEVEL+12
; ---------------------------------------
; FAT entry
; ---------------------------------------
SD_FAT_LEVEL    .equ SD_LOW_LEVEL+14
ClusterL        .equ SD_FAT_LEVEL       ;
ClusterH        .equ SD_FAT_LEVEL+2     ;
LastFATsector   .equ SD_FAT_LEVEL+4     ;
LastFAToffset   .equ SD_FAT_LEVEL+6     ;
FATsector       .equ SD_FAT_LEVEL+8     ; not used
; ---------------------------------------
; DIR entry
; ---------------------------------------
DIRClusterL     .equ SD_FAT_LEVEL+10    ; contains the Cluster of current directory ; = 1 as FAT16 root directory
DIRClusterH     .equ SD_FAT_LEVEL+12    ; contains the Cluster of current directory ; = 1 as FAT16 root directory
DIREntryOfst    .equ SD_FAT_LEVEL+14
; ---------------------------------------
; Handle Pointer
; ---------------------------------------
CurrentHdl      .equ SD_FAT_LEVEL+16    ; contains the address of the last opened file structure, or 0
; ---------------------------------------
; Load file operation
; ---------------------------------------
PathName_PTR    .equ SD_FAT_LEVEL+18    ;
PathName_END    .equ SD_FAT_LEVEL+20    ;
; ---------------------------------------
; Handle structure
; ---------------------------------------
FirstHandle     .equ SD_FAT_LEVEL+22
; three handle tokens :
; HDLB_Token= 0 : free handle
;           = 1 : file to read
;           = 2 : file updated (write)
;           =-1 : LOAD"ed file (source file)

; offset values
HDLW_PrevHDL    .equ 0  ; previous handle
HDLB_Token      .equ 2  ; token
HDLB_ClustOfst  .equ 3  ; Current sector offset in current cluster (Byte)
HDLL_DIRsect    .equ 4  ; Dir SectorL
HDLH_DIRsect    .equ 6  ; Dir SectorH
HDLW_DIRofst    .equ 8  ; SD_BUF offset of Dir entry
HDLL_FirstClus  .equ 10 ; File First ClusterLo (identify the file)
HDLH_FirstClus  .equ 12 ; File First ClusterHi (identify the file)
HDLL_CurClust   .equ 14 ; Current ClusterLo
HDLH_CurClust   .equ 16 ; Current ClusterHi
HDLL_CurSize    .equ 18 ; written size / not yet read size (Long)
HDLH_CurSize    .equ 20 ; written size / not yet read size (Long)
HDLW_BUFofst    .equ 22 ; SD_BUF offset ; used by LOAD"
HDLW_PrevLEN    .equ 24 ; previous LEN
HDLW_PrevORG    .equ 26 ; previous ORG

    .IF RAM_LEN < 2048     ; due to the lack of RAM, only 4 handles and PAD replaces SDIB
HandleMax       .equ 4 ; and not 8 to respect INFO size (FRAM)
HandleLenght    .equ 28
HandlesLen      .equ handleMax*HandleLenght
HandleEnd       .equ FirstHandle+handleMax*HandleLenght
SD_END          .equ HandleEnd
SDIB_I2CADR     .equ PAD_ORG-4
SDIB_I2CCNT     .equ PAD_ORG-2
SDIB_ORG        .equ PAD_ORG
    .ELSE      ; RAM_Size >= 2k all is in RAM
HandleMax       .equ 8
HandleLenght    .equ 28
HandlesLen      .equ handleMax*HandleLenght
HandleEnd       .equ FirstHandle+handleMax*HandleLenght
SDIB_I2CADR     .equ SDIB_ORG-4
SDIB_I2CCNT     .equ SDIB_ORG-2
SDIB_ORG        .equ HandleEnd+4
SD_END          .equ SDIB_ORG+CIB_LEN
    .ENDIF ; RAM_Size
SD_LEN          .equ SD_END-SD_ORG
    .ENDIF ; SD_CARD_LOADER

    .org    INFO_ORG
;-------------------------------------------------------------------------------
; INFO(DCBA) >= 256 bytes memory map (FRAM) :
;-------------------------------------------------------------------------------
; FRAM INFO: KERNEL INIT CONSTANTS and VARIABLES
; ----------------------------------------------
FREQ_KHZ        .word FREQUENCY*1000    ; used to stabilize MCLK before start, see MSP430FRxxxx.asm
    .IFDEF TERMINAL_I2C
I2CSLAVEADR     .word MYSLAVEADR        ; on MSP430FR2xxx devices with BSL I2C, Slave address is FFA0h
I2CSLAVEADR1    .word 0
LPM_MODE        .word GIE+LPM4          ; LPM4 is the default mode for I2C TERMINAL
    .ELSE ; TERMINAL_UART
TERMBRW_RST     .word TERMBRW_INI       ; set by TERMINALBAUDRATE.inc
TERMMCTLW_RST   .word TERMMCTLW_INI     ; set by TERMINALBAUDRATE.inc
LPM_MODE        .word GIE+LPM0          ; LPM0 is the default mode for UART TERMINAL
    .ENDIF
USERSYS         .word -3                ; RESET use, value = -3 when compiling new kernel
FORTHVERSION  .word VAL(SUBSTR(VER,1,0)); used by WARM
INI_THREAD      .word THREADS           ; used by WORDS definition
FORTHADDON      .word FADDON            ; used by FF_SPECS.f and to secure downloading of any source.f files.
; --------------------------------------;
DEEP_ORG                                ; MOV #DEEP_ORG,X     see "PUC 7" in forthMSP430FR.ASM
; --------------------------------------;
DEEP_TERM_VEC   .word TERMINAL_INT      ; MOV @X+,&TERM_VEC     ; TERMINAL_INT      --> FRAM TERM_VEC
    .IFNDEF SD_CARD_LOADER
DEEP_COLD       .word COLD_TERM         ; MOV @X+,&COLD_APP     ; COLD_TERM         --> FRAM COLD_APP
DEEP_SOFT       .word INIT_SOFT_TERM    ; MOV @X+,&SOFT_APP     ; INIT_SOFT_TERM    --> FRAM SOFT_APP
DEEP_HARD       .word INIT_TERM         ; MOV @X+,&HARD_APP     ; INIT_TERM         --> FRAM HARD_APP
DEEP_SLEEP      .word RXON              ; MOV @X+,&SLEEP_APP    ; RXON              --> FRAM SLEEP_APP
    .ELSE
DEEP_COLD       .word COLD_TERM         ; MOV @X+,&COLD_APP     ; COLD_TERM         --> FRAM COLD_APP
DEEP_SOFT       .word INIT_SOFT_SD      ; MOV @X+,&SOFT_APP     ; INIT_SOFT_SD      --> FRAM SOFT_APP
DEEP_HARD       .word INIT_HARD_SD      ; MOV @X+,&HARD_APP     ; INIT_HARD_SD      --> FRAM HARD_APP
DEEP_SLEEP      .word RXON              ; MOV @X+,&SLEEP_APP    ; RXON              --> FRAM SLEEP_APP
    .ENDIF
DEEP_DP         .word ROMDICT           ; MOV @X+,&RST_DP       ; DEEP_DP           --> FRAM RST_DP
DEEP_LASTVOC    .word lastvoclink       ; MOV @X+,&RST_LASTVOC  ; DEEP_LASTVOC      --> FRAM RST_LASTVOC
DEEP_CURRENT    .word BODYFORTH         ; MOV @X+,&CURRENT      ; DEEP_CONTEXT      --> FRAM RST_CURRENT
DEEP_CONTEXT    .word BODYFORTH         ; MOV @X+,&CONTEXT      ; DEEP_CONTEXT      --> FRAM RST_CONTEXT
; --------------------------------------;
PUC_ABORT_ORG                           ; MOV #PUC_ABORT_ORG,X
; --------------------------------------;
INIT_ACCEPT    .word ACCEPT+4           ; MOV @X+,&ACCEPT+2     ; INIT_ACCEPT       --> FRAM PFA_ACCEPT
INIT_EMIT      .word EMIT+4             ; MOV @X+,&EMIT+2       ; INIT_EMIT         --> FRAM PFA_EMIT
INIT_KEY       .word KEY+4              ; MOV @X+,&KEY+2        ; INIT_KEY          --> FRAM PFA_KEY
INIT_CIB       .word TIB_ORG            ; MOV @X+,&CIB_ORG      ; INIT_CIB          --> FRAM CIB_ORG
; --------------------------------------;
FORTH_ORG                               ; MOV #FORTH_ORG,X
; --------------------------------------;
INIT_RSP        .word RSTACK            ; MOV @X+,RSP           ; INIT_RSP          --> RSP     (R1)
    .SWITCH DTC
        .CASE 1
INIT_DOCOL      .word xDOCOL            ; MOV @X+,rDOCOL        ; INIT_DOCOL        --> rDOCOL  (R4)
        .CASE 2
INIT_DOCOL      .word EXIT              ; MOV @X+,rDOCOL        ; INIT_DOCOL        --> rDOCOL  (R4)
        .CASE 3
INIT_DOCOL      .word 0                 ; MOV @X+,R4            ; useless rDOCOL
    .ENDCASE
INIT_DODOES     .word xDODOES           ; MOV @X+,rDODOES       ; INIT_DODOES       --> rDODOES (R5)
INIT_DOCON      .word xDOCON            ; MOV @X+,rDOCON        ; INIT_DOCON        --> rDOCON  (R6)
INIT_DOVAR      .word RFROM             ; MOV @X+,rDOVAR        ; INIT_DOVAR        --> rDOVAR  (R7)
INIT_CAPS       .word 32                ; MOV @X+,&CAPS         ; INIT_CAPS         --> RAM CAPS
INIT_BASE       .word 10                ; MOV @X+,&BASE         ; INIT_BASE         --> RAM BASE
INIT_LEAVE      .word LSTACK            ; MOV @X+,&LEAVEPTR     ; INIT_LEAVE        --> RAM LEAVEPTR
; --------------------------------------;
; FRAM RST values initialised by -1 SYS ;
; --------------------------------------;
RST_ORG                                 ; make room for RST values of:
RST_LEN        .equ 16                  ; 16 bytes
; --------------------------------------;
    .IFNDEF SD_CARD_LOADER
COLD_APP        .word COLD_TERM         ; COLD_APP
SOFT_APP        .word INIT_SOFT_TERM    ; SOFT_APP
HARD_APP        .word INIT_TERM         ; HARD_APP
SLEEP_APP       .word RXON              ; SLEEP_APP
    .ELSE
COLD_APP        .word COLD_TERM         ; COLD_APP
SOFT_APP        .word INIT_SOFT_SD      ; SOFT_APP
HARD_APP        .word INIT_HARD_SD      ; HARD_APP
SLEEP_APP       .word RXON              ; SLEEP_APP
    .ENDIF
; --------------------------------------;
RST_DP          .word ROMDICT           ; program memory pointer
; --------------------------------------;
RST_LASTVOC     .word lastvoclink       ; last vocabulary link
; --------------------------------------;
RST_CURRENT     .word BODYFORTH         ; CURRENT word-set ptr
; --------------------------------------;
RST_CONTEXT     .word BODYFORTH         ; CONTEXT space (8 CELLS)
                .word 0
                .word 0
                .word 0
                .word 0
                .word 0
                .word 0
                .word 0
; --------------------------------------;
                .word 0                 ; NULL_WORD, always 0
; --------------------------------------;

; --------------------------;
; INFO_ORG + $5A : free use ;
; --------------------------;