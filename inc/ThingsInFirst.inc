; ThingsInFirst.inc

;    .listing OFF
    .cpu MSP430X

; ----------------------------------------------
; MACROS FOR assembly instructions
; ----------------------------------------------

;****************************************************************************
;*                                                                          *
;*   AS 1.41 - Datei REGMSP.INC von Alfred Arnold                           *
;*   					 			            *
;*   Sinn : enthält Makro- und Registerdefinitionen fu den MSP430          *
;* 									    *
;*   letzte underungen : 2002-01-11                                         *
;*                       2010/2011/2012 erweitert von Matthias Koch         *
;*                                                                          *
;****************************************************************************

                ifndef  regmspinc      ; verhindert Mehrfacheinbindung

regmspinc       equ     1

                if      (MOMCPUNAME<>"MSP430")&&(MOMCPUNAME<>"MSP430X")
                 fatal  "Falscher Prozessortyp eingestellt: nur MSP430 erlaubt!"
		endif

                if      MOMPASS=1
                 message "MSP430-Register+Befehlsdefinitionen (C) 1996 Alfred Arnold"
		endif

; Definitions for Instructions, Macros and Ports.

;----------------------------------------------------------------------------
; Arithmetik

adc             macro   op
                addc.attribute #0,op
                endm

dadc            macro   op
                dadd.attribute #0,op
                endm

dec             macro   op
                sub.attribute #1,op
                endm

decd            macro   op
                sub.attribute #2,op
                endm

inc             macro   op
                add.attribute #1,op
                endm

incd            macro   op
                add.attribute #2,op
                endm

sbc             macro   op
                subc.attribute #0,op
                endm

;----------------------------------------------------------------------------
; Logik

inv             macro   op
                xor.attribute #-1,op
                endm

rla             macro   op
                add.attribute op,op
                endm

rlc             macro   op
                addc.attribute op,op
                endm

;----------------------------------------------------------------------------
; Daten bewegen ;-)

clr             macro   op
                mov.attribute #0,op
                endm

clrc            macro
                bic     #1,sr
                endm

clrn            macro
                bic     #4,sr
                endm

clrz            macro
                bic     #2,sr
                endm

pop             macro   op         ; Muss hier noch ein Atribut anbringen ! Kann auch Bytes zurückladen...
                mov.attribute     @sp+,op
                endm

setc            macro
                bis     #1,sr
                endm

setn            macro
                bis     #4,sr
                endm

setz            macro
                bis     #2,sr
                endm

tst             macro   op
                cmp.attribute #0,op
                endm

;----------------------------------------------------------------------------
; Sprungbefehle

br              macro   op
            mov     op,pc
                endm

dint            macro
            bic     #8,sr
                endm

eint            macro
            bis     #8,sr
                endm

nop             macro         
            .word   04303h         ; mov #0, r3         
                endm

nop2            macro                  ; 1 Word, 2 Takte
            jmp $+2
                endm

nop3            macro                  ; 1 Word, 3 Takte
            MOV PC,PC
                endm

ret             macro
            mov     @sp+,pc
                endm

jlo		macro	label   ; unsigned
		jnc	label
		endm

jhs		macro	label   ; unsigned
		jc	label
		endm

jeq		macro	label
		jz	label
		endm

; Flags im Statusregister
; SR bits : only SR(11:0) are PUSHed by interrupts
C             equ 0001h
Z             equ 0002h
N             equ 0004h
V             equ 0100h
GIE           equ 0008h
CPUOFF        equ 0010h ; CPU Off.                  1=turn_off_CPU
OSCOFF        equ 0020h ; Oscillator Off.           1=turn_off_LFXT1CLK
SCG0          equ 0040h ; System Clock Generator 0. 1=turn_off_DCO
SCG1          equ 0080h ; System Clock Generator 1. 1=turn_off_SMCLK
UF9           equ 0200h ; = SR(9) User Flag 1 used by ?NUMBER --> INTERPRET --> LITERAL to process double numbers, else free for use.  
UF10          equ 0400h ; = SR(10) User Flag 2  
UF11          equ 0800h ; = SR(11) User Flag 3  

;----------------------------------------------------------------------------
; Low-Power-Mode Bitmuster

LPM0          equ CPUOFF
LPM1          equ SCG0 + CPUOFF
LPM2          equ SCG1 + CPUOFF
LPM3          equ SCG1 + SCG0 + CPUOFF
LPM4          equ SCG1 + SCG0 + OSCOFF + CPUOFF

;----------------------------------------------------------------------------

                endif                   ; von IFDEF...

; ----------------------------------------------
; INIT VOCABULARY POINTERS and MACROS FOR HEADER
; ----------------------------------------------

voclink     .set 0                      ; init vocabulary links
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
FORTHWORD   .MACRO  name
;-------------------------------------------
; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
thread      .set    charfromstr(name,0) &  ((THREADS-1)*2)

    .SWITCH thread
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
;            .align  2
            .ENDM

;-------------------------------------------
FORTHWORDIMM .MACRO  name
;-------------------------------------------

; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
thread      .set    charfromstr(name,0) &  ((THREADS-1)*2)


    .SWITCH thread
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

            .byte   STRLEN(name)+128,name
;            .align  2
            .ENDM

;-------------------------------------------
asmword     .MACRO  name
;-------------------------------------------

; (THREADS-1)*2 = AND mask to define CURRENT offset in vocabulary
thread      .set    charfromstr(name,0) &  ((THREADS-1)*2)

    .SWITCH thread
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
;            .align  2
            .ENDM

    .endif ; thread case

; --------------------------
; COMPUTE BAUDRATE registers = fn(FREQUENCY,BAUDS)
; --------------------------
    .include "TERMINALBAUDRATE.inc"

; -----------------------------
; compute value of FORTHVERSION
; -----------------------------
VERSIO .equ VAL(SUBSTR(VER,1,0))

; -------------------------------------
; define FREQ  used in WARM message (6)
; -------------------------------------
    .IF     FREQUENCY = 0.25
FREQ    .set " .2MHz"
    .ELSEIF FREQUENCY = 0.5
FREQ    .set " .5MHz"
    .ELSEIF FREQUENCY = 1
FREQ    .set "  1MHz"
    .ELSEIF FREQUENCY = 2
FREQ    .set "  2MHz"
    .ELSEIF FREQUENCY = 4
FREQ    .set "  4MHz"
    .ELSEIF FREQUENCY = 8
FREQ    .set "  8MHz"
    .ELSEIF FREQUENCY = 12
FREQ    .set " 12MHz"
    .ELSEIF FREQUENCY = 16
FREQ    .set " 16MHz"
    .ELSEIF FREQUENCY = 20
FREQ    .set " 20MHz"
    .ELSEIF FREQUENCY = 24
FREQ    .set " 24MHz"
    .ENDIF

; -------------------------------------
; define MAIN max bound
; -------------------------------------
FRAM_FULL   .equ SIGNATURES-50h ; set to protect JTAG and BSL signatures against overwrite.
                                ; notice that ALLOT memory space beyond SIGNATURES don't corrupt it,
                                ; thus 80 bytes are sufficient considering what can be compiled in one line + WORD use.
                                ; good practice: one line for each ALLOT command.

;-----------------------------------------------------------------------
; DEVICE I/O, MEMORY, SFR, vectors and minimum FORTH I/O declarations
;-----------------------------------------------------------------------
    .IFDEF MSP_EXP430FR5739
LF_XTAL
UCA0_TERM
UCB0_SD
    .include "MSP430FR5739.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR5969
LF_XTAL
UCA0_TERM
UCA1_SD
    .include "MSP430FR5969.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR5994
LF_XTAL
UCA0_TERM
UCB0_SD
    .include "MSP430FR5994.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR6989
LF_XTAL
UCA1_TERM
UCA0_SD
    .INCLUDE "MSP430FR6989.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR4133
LF_XTAL
UCA0_TERM
UCB0_SD
    .INCLUDE "MSP430FR4133.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2433
LF_XTAL
UCA0_TERM
UCA1_SD
    .include "MSP430FR2433.inc"
    .ENDIF

    .IFDEF CHIPSTICK_FR2433
UCA0_TERM 
UCB0_SD
    .include "MSP430FR2433.inc"
    .ENDIF

    .IFDEF MSP_EXP430FR2355
LF_XTAL
UCA1_TERM
UCB1_SD
    .include "MSP430FR2355.inc"
    .ENDIF

; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
; add here your device.inc item:
;     .IFDEF MY_MSP430FR5738_1
; UCA0_UART   ; defines uart used by FORTH input terminal 
; LF_XTAL     ; defines if your module have a 32768 Hz xtal, to enable it.
; UCB0_SD     ; defines UC used for SD Card driver if used
;     .include "MSP430FR5738.inc"  ; include device declarations
;     .ENDIF
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; ---------------------------
; compute value of FORTHADDON
; ---------------------------
FADDON .set 0
    .IFDEF CONDCOMP
FADDON .SET FADDON | 01h
    .ENDIF
    .IFDEF MSP430ASSEMBLER
FADDON .SET FADDON | 02h
    .ENDIF
    .IFDEF EXTENDED_ASM
FADDON .SET FADDON | 04h
    .ENDIF
    .IFDEF NONAME
FADDON .SET FADDON | 08h
    .ENDIF
    .IFDEF VOCABULARY_SET
FADDON .SET FADDON | 10h
    .ENDIF
    .IFDEF DOUBLE_INPUT
FADDON .SET FADDON | 20h
    .ENDIF
    .IFDEF FIXPOINT_INPUT
FADDON .SET FADDON | 40h
    .ENDIF
    .IFDEF SD_CARD_LOADER
FADDON .SET FADDON | 80h
    .ENDIF
    .IFDEF SD_CARD_READ_WRITE
FADDON .SET FADDON | 100h
    .ENDIF
    .IFDEF BOOTLOADER
FADDON .SET FADDON | 200h
    .ENDIF
    .IFDEF PROMPT
FADDON .SET FADDON | 400h
    .ENDIF
    .IFDEF HALFDUPLEX
FADDON .SET FADDON | 800h
    .ENDIF
    .IFDEF TERMINAL3WIRES
FADDON .SET FADDON | 1000h
    .ENDIF
    .IFDEF TERMINAL4WIRES
FADDON .SET FADDON | 2000h
    .ENDIF
    .IFDEF TERMINAL5WIRES
FADDON .SET FADDON | 4000h
    .ENDIF
    .IFDEF LF_XTAL
FADDON .SET FADDON | 8000h
    .ENDIF

; --------------------------
; COMPUTE SWITCHES
; --------------------------

    .IFDEF EXTENDED_ASM
        .IFNDEF MSP430ASSEMBLER
MSP430ASSEMBLER
        .ENDIF
    .ENDIF

; define if QUIT is DEFERed
    .IFDEF SD_CARD_LOADER 
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
        .IFNDEF DOUBLE_INPUT ; for indirect extended indexed modes of MOVA ADDA CMPA SUBA instructions
DOUBLE_INPUT
        .ENDIF
        .IFNDEF DEFER_ACCEPT ; to write EXTD_LOAD"
DEFER_ACCEPT
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

; define if Terminal half duplex
    .IFDEF UARTtoI2C
        .IFNDEF HALFDUPLEX
HALFDUPLEX
        .ENDIF
    .ENDIF

    .listing ON
