; -*- coding: utf-8 -*-
; http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices
; Copyright (C) <2017>  <J.M. THOORENS>
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

; ----------------------------------------------------------------------
; assembled with MACROASSEMBLER AS (http://john.ccac.rwth-aachen.de:8000/as/)
; ----------------------------------------------------------------------

    .cpu MSP430
    .include "mspregister.mac" ;
;    macexp off             ; unrem to hide macro results

;----------------------------------------------------------------------------------------------------------
; Vingt fois sur le métier remettez votre ouvrage, 
; Polissez-le sans cesse, et le repolissez,
; Ajoutez quelquefois, et souvent effacez. 
;                                                                                   Boileau, L'Art poétique
;----------------------------------------------------------------------------------------------------------

;==========================================================================================================
; FAST FORTH challenge: time to load, interpret, compile and execute 31136 bytes source file "CORETEST.4th"
;==========================================================================================================
; Look at a FAST FORTH competitor @24MHZ, 115200 Bds without flow control, delay=50ms/line ==> result: 54s.
;==========================================================================================================
; FAST FORTH on a MSP430FR5738 @500kHz UART 115200 Bds, PL2303TA/HXD, download speed measured by TERATERM
; real bytes rate without UART connexion     : 11.36 kbytes/s ==> 113600 Bds instead of 115200 Bds expected
; real bytes rate without echo (half duplex) : 3.19 kbytes/s       ==> result: 9.75s.
; process time @ 1MHz = 2/(1/3.19 - 1/11.36) = 8.86 kbytes/s of source file.
;==========================================================================================================
; test on a MSP430FR5738 @24MHz UART 6 Mbds via si8622EC-B-IS iso, 1m of cable, PL2303HXD, TERATERM, COREi7
; download CORETESTx20.4th without UART connexion : 165 kbytes/s   ==> 1.65 MBds instead of 6 MBds expected 
; without echo (half duplex), best of 10 downloads: 123.5 kbytes/s ==> result: 0.25s ==> 200 times faster!
;----------------------------------------------------------------------------------------------------------

;===============================================================================================
;===============================================================================================
; before assembling or programming you must set DEVICE in param1 and TARGET in param2 (SHIFT+F8)
; according to the TARGET "switched" below
; example : your TARGET = MSP_EXP430FR5969 (notice the underscore) ==> DEVICE = MSP430FR5969 
;===============================================================================================
;===============================================================================================

;-----------------------------------------------------------------------------------------------
; TARGET configuration SWITCHES ; bytes values are measured for DTC=1, 8MHz 2457600 bds settings
;-----------------------------------------------------------------------------------------------
;                                                                     TOTAL - SUM of (INFO+RAM +VECTORS) = MAIN PROG
;MSP_EXP430FR5739   ; compile for MSP-EXP430FR5739 launchpad        ; 4136  - 160    ( 24 + 86 +  50   ) = 3976 bytes 
MSP_EXP430FR5969   ; compile for MSP-EXP430FR5969 launchpad        ; 4104  - 162    ( 24 + 86 +  52   ) = 3942 bytes 
;MSP_EXP430FR5994   ; compile for MSP-EXP430FR5994 launchpad        ; 4138  - 186    ( 24 + 86 +  76   ) = 3952 bytes
;MSP_EXP430FR6989   ; compile for MSP-EXP430FR6989 launchpad        ; 4136  - 168    ( 24 + 86 +  58   ) = 3968 bytes 
;MSP_EXP430FR4133   ; compile for MSP-EXP430FR4133 launchpad        ; 4168  - 140    ( 24 + 86 +  30   ) = 4028 bytes
;CHIPSTICK_FR2433   ; compile for the "CHIPSTICK" of M. Ken BOAK    ; 4070  - 148    ( 24 + 86 +  38   ) = 3932 bytes

; choose DTC (Direct Threaded Code) model, if you don't know, choose 1
DTC .equ 1  ; DTC model 1 : DOCOL = CALL rDOCOL           14 cycles 1 word      shortest DTC model
            ; DTC model 2 : DOCOL = PUSH IP, CALL rEXIT   13 cycles 2 words     good compromize for mix FORTH/ASM code
            ; DTC model 3 : inlined DOCOL                  9 cycles 4 words     fastest

FREQUENCY   .equ 16 ; fully tested at 0.5,1,2,4,8,16 (and 24 for MSP430FR57xx) MHz
THREADS     .equ 16 ; 1,   4,   8,  16,   32 search entries in dictionnary. 16 is an optimum: speed up to 8 the interpretation.
                    ;    +40, +66, +90, +154 bytes

TERMINALBAUDRATE    .equ 3000000    ; choose value considering the frequency and the bridge uart/USB, see explanations below. 
TERMINALXONXOFF     ;; to allow XON/XOFF flow control (PL2303TA/CP2102 devices)
;TERMINALCTSRTS      ; to allow Hardware flow control (FT232RL device)

    .include "Target.inc" ; to define target config: I/O, memory, SFR, vectors, TERMINAL eUSCI, SD_Card eUSCI, LF_XTAL,

;-----------------------------------------------------------------------
; KERNEL ADD-ON SWITCHES ;
;-----------------------------------------------------------------------
MSP430ASSEMBLER    ; + 1896 bytes : add embedded assembler with TI syntax; without, you can do all but all much more slowly...
;SD_CARD_LOADER     ; + 1776 bytes to LOAD source files from SD_card
;SD_CARD_READ_WRITE ; + 1162 bytes to create, read, write, close and del files, + copy file from PC to SD_Card
;VOCABULARY_SET     ; +  108 bytes : add VOCABULARY FORTH ASSEMBLER ALSO PREVIOUS ONLY DEFINITIONS (FORTH83, not ANSI)
;LOWERCASE          ; +   30 bytes : enable to EMIT strings in lowercase.
;BACKSPACE_ERASE    ; +   24 bytes : replace BS by ERASE, for visual comfort

;-------------------------------------------------------------------------------------------------
; OPTIONAL KERNELL ADD-ON SWITCHES, because their source file can be downloaded later >----------------+ 
;-------------------------------------------------------------------------------------------------     |
;                                                                                                      v
;UTILITY            ; +  404 bytes : add .S WORDS U.R DUMP ?                                        UTILITY.f
;SD_TOOLS           ; +  126 bytes for trivial DIR, FAT, CLUSTER and SECTOR view, needs UTILITY     SD_TOOLS.f
;ANS_CORE_COMPLIANT ; +  876 bytes : required to pass coretest.4th ; (includes items below)         COMPxMPY.f (x = H or S)
;ARITHMETIC         ; +  358 bytes : add S>D M* SM/REM FM/MOD * /MOD / MOD */MOD /MOD */            ARITxMPY.f (x = H or S)
;DOUBLE             ; +  130 bytes : add 2@ 2! 2DUP 2SWAP 2OVER                                     DOUBLE.f
;ALIGNMENT          ; +   24 bytes : add ALIGN ALIGNED                                              ALIGN.f
;PORTABILITY        ; +   46 bytes : add CHARS CHAR+ CELLS CELL+                                    PORTABLE.f



;=================================================================
; XON/XOFF control flow configuration ; up to 285kBd/MHz with ECHO
;=================================================================
; notice: these specified baud rates perform downloads error free.

; the cheapest and best : UARTtoUSB cable with Prolific PL2303TA (supply current = 8 mA) or PL2303HXD
; ---------------------------------------------------------------------------------------------------
; WARNING ! if you use it as supply for your target, open box before to weld red wire on 3v3 pad !
; ---------------------------------------------------------------------------------------------------
; 9600,19200,38400,57600,115200,134400 (500kHz)
; + 161280,201600,230400,268800 (1MHz)
; + 403200,460800,614400 (2MHz)
; + 806400,921600,1228800 (4MHz)
; + 2457600 (8MHz)
; + 3000000 (16MHz)
; + 6000000 (24MHz, MSP430FR57xx)


; UARTtoUSB module with Silabs CP2102 (supply current = 20 mA)
; ---------------------------------------------------------------------------------------------------
; WARNING ! if you use it as supply for your target, connect VCC on the wire 3v3 !
; ---------------------------------------------------------------------------------------------------
; 9600,19200,38400,57600 (500kHz)
; + 115200 (1MHz)
; + 230400 (2MHz)
; + 460800 (4MHz)
; + 921600,1382400,1843200 (8MHz,16MHz,24MHz)
; notice that you must program the CP2102 device to add speeds 1382400, 1843200 bds.

; Launchpad --- UARTtoUSB device
;        RX <-- TX
;        TX --> RX
;       GND <-> GND

; TERATERM config terminal      : NewLine receive : AUTO,
;                                 NewLine transmit : CR+LF
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : 9600 to 6000000 Bds,
;                                 8bits, no parity, 1Stopbit,
;                                 XON/XOFF flow control,
;                                 delay = 0ms/line, 0ms/char

; don't forget : save new TERATERM configuration !


;=================================================================
; Hardware control flow configuration with FT232RL device only
;=================================================================

; UARTtoUSB module with FTDI FT232RL
;===============================================================================================
; WARNING ! buy a FT232RL module with a switch 5V/3V3 and select 3V3 !
;===============================================================================================
; 9600,19200,38400,57600,115200 (500kHz)
; + 230400 (1MHz)
; + 460800 (2MHz)
; + 921600 (4,8,16 MHz)

; Launchpad     UARTtoUSB device
;        RX <-- TX
;        TX --> RX
;       RTS --> CTS
;       GND <-> GND

; notice that the control flow seems not necessary for TX

; TERATERM config terminal      : NewLine receive : AUTO,
;                                 NewLine transmit : CR+LF (so FT232RL can test its CTS line during transmit LF)
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : 9600 to 921600 Bds,
;                                 8bits, no parity, 1Stopbit,
;                                 Hardware flow control,
;                                 delay = 0ms/line, 0ms/char

; don't forget : save new TERATERM configuration !



; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx Init vocabulary pointers:
; ----------------------------------------------------------------------

    .IF THREADS = 1

voclink     .set 0                      ; init vocabulary links
forthlink   .set 0
asmlink     .set 0

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
    .include "ForthThreads.mac"
    .ENDIF

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx RAM memory map:
; ----------------------------------------------------------------------

; name              words   ; comment

;LSTACK=L0                  ; ----- 1C00
                            ; |
LSTACK_SIZE .equ    16      ; | grows up
                            ; |
                            ; V
                            ;
                            ; ^
                            ; |
PSTACK_SIZE .equ    48      ; | grows down
                            ; |
;PSTACK=S0                  ; ----- 1C80
                            ;
                            ; ^
                            ; |
RSTACK_SIZE .equ    48      ; | grows down
                            ; |
;RSTACK=R0                  ; ---- 1CE0

                            ; aligned buffers only required for terminal tasks.

; names             bytes   ; comments

;PAD                        ; ----- 1CE2
                            ; |
PAD_SIZE    .equ    84      ; | grows up    (ans spec. : PAD >= 84 chars)
                            ; |
                            ; v
                            ; ------1D36
;TIB                        ; ----- 1D38
                            ; |
TIB_SIZE    .equ    80      ; | grows up    (ans spec. : TIB >= 80 chars)
                            ; |
                            ; v
                            ; ^
                            ; |
HOLD_SIZE   .equ    34      ; | grows down  (ans spec. : HOLD_SIZE >= (2*n) + 2 char, with n = 16 bits/cell
                            ; |
;BASE_HOLD                  ; ----- 1DAA
                            ; |
; variables systme          ; | grows up
                            ; |
                            ; v
;BUFFER                     ; ----- 1DDC
;INPUT_BUFFER               ; 512 bytes buffer
                            ; ----- 1FDC

LSTACK      .equ    RAMSTART
PSTACK      .equ    LSTACK+(LSTACK_SIZE*2)+(PSTACK_SIZE*2)
RSTACK      .equ    PSTACK+(RSTACK_SIZE*2)
PAD         .equ    RSTACK+2
TIB         .equ    PAD+PAD_SIZE+2
BASE_HOLD   .equ    TIB+TIB_SIZE+HOLD_SIZE


; ----------------------------------
; RAM VARIABLES initialised by RESET
; ----------------------------------

    .org BASE_HOLD

HP              .word 0                 ; HOLD ptr
LEAVEPTR        .word 0                 ; Leave-stack pointer
LAST_NFA        .word 0                 ; NFA, VOC_PFA, LFA, CFA, CSP of last created word
LAST_THREAD     .word 0
LAST_CFA        .word 0
LAST_CSP        .word 0
STATE           .word 0                 ; Interpreter state
ASM_CURRENT     .word 0                 ; preserve CURRENT during create assembler words
OPCODE          .word 0                 ; OPCODE adr
ASMTYPE         .word 0                 ; keep the opcode complement
SOURCE_LEN      .word 0
SOURCE_ADR      .word 0                 ; len, addr of input stream
TOIN            .word 0
DDP             .word 0
LASTVOC         .word 0                 ; keep VOC-LINK
CURRENT         .word 0                 ; CURRENT dictionnary ptr
CONTEXT         .word 0,0,0,0,0,0,0,0   ; CONTEXT dictionnary space (8 CELLS)
BASE            .word 0
CAPS            .word 0

                .word 0,0,0,0,0,0,0,0   ; user free use
                .word 0,0,0,0,0,0,0,0   ; user free use



; ------------------------------
; RAM SD_CARD BUFFER 2+512 bytes
; ------------------------------

            .word 0 ; to init BufferPtr down to -2 (to skip a CR, for example)
BUFFER
BUFEND      .equ BUFFER + 200h 

; ----------------------------------------------------------------------
; INFO(DCBA) >= 256 bytes memory map:
; ----------------------------------------------------------------------

    .org    INFOSTART

; --------------------------
; FRAM INFO KERNEL CONSTANTS
; --------------------------

INI_THREAD      .word THREADS               ; used by ADDON_UTILITY.f
INI_TERM        .word TERMINAL_INT          ; used by RESET
    .IF FREQUENCY = 0.5
FREQ_KHZ        .word 500                   ; user use
    .ELSE
FREQ_KHZ        .word FREQUENCY*1000        ; user use
    .ENDIF
HECTOBAUDS      .word TERMINALBAUDRATE/100  ; user use

SAVE_SYSRSTIV   .word -3                ; to perform DEEP_RST after FastForth compiling 
LPM_MODE        .word CPUOFF+GIE        ; LPM0 is the default mode
INIDP           .word ROMDICT           ; define RST_STATE
INIVOC          .word lastvoclink       ; define RST_STATE

                .word XON                   ; user use
                .word XOFF                  ; user use

    .IFDEF SD_CARD_LOADER
                .word ReadSectorWX          ; used by ADDON_SD_TOOLS.f
        .IFDEF SD_CARD_READ_WRITE
                .word WriteSectorWX         ; used by ADDON_SD_TOOLS.f
        .ELSEIF
                .word 0
        .ENDIF ; SD_CARD_READ_WRITE
    .ELSEIF     
                .word 0,0
    .ENDIF ; SD_CARD_LOADER

; ------------------------------
; VARIABLES that could be in RAM
; ------------------------------
    .IFNDEF RAM_1K      ; if RAM = 1K the variables below stay in FRAM 
    .org BUFEND         ; else in RAM beyond BUFFER
    .ENDIF

    .IFDEF SD_CARD_LOADER

SD_ORG_DATA
                .word 0 ; guard word
; ---------------------------------------
; FAT16 FileSystemInfos 
; ---------------------------------------
FATtype         .word 0
BS_FirstSectorL .word 0 ; init by SD_Init, used by RW_Sector_CMD
BS_FirstSectorH .word 0 ; init by SD_Init, used by RW_Sector_CMD
OrgFAT1         .word 0 ; init by SD_Init, 
FATSize         .word 0 ; init by SD_Init,
OrgFAT2         .word 0 ; init by SD_Init,
OrgRootDIR      .word 0 ; init by SD_Init, (FAT16 specific)   
OrgClusters     .word 0 ; init by SD_Init, Sector of Cluster 0
SecPerClus      .word 0 ; init by SD_Init, byte size

; ---------------------------------------
; SD command
; ---------------------------------------
SD_CMD_FRM      .byte 0,0,0,0,0,0   ; SD_CMDx inverted frame ${CRC7,ll,LL,hh,HH,CMD} 
SectorL         .word 0
SectorH         .word 0

; ---------------------------------------
; BUFFER management
; ---------------------------------------
BufferPtr       .word 0
BufferLen       .word 0

; ---------------------------------------
; FAT entry
; ---------------------------------------
ClusterL        .word 0   ;
ClusterH        .word 0   ;
NewClusterL     .word 0   ; 
NewClusterH     .word 0   ; 
FATsector       .word 0   ; not used 
CurFATsector    .word 0   ; current FATSector of last free cluster

; ---------------------------------------
; DIR entry
; ---------------------------------------
DIRClusterL     .word 0     ; contains the Cluster of current directory ; = 1 as FAT16 root directory
DIRClusterH     .word 0     ; contains the Cluster of current directory ; = 1 as FAT16 root directory
EntryOfst       .word 0
pathname        .word 0     ; address of pathname string

; ---------------------------------------
; Handle Pointer
; ---------------------------------------
CurrentHdl      .word 0     ; contains the address of the last opened file structure, or 0

; ---------------------------------------
; Load file operation
; ---------------------------------------
SAVEtsLEN       .word 0     ; of previous ACCEPT
SAVEtsPTR       .word 0     ; of previous ACCEPT
MemSectorL      .word 0     ; 
MemSectorH      .word 0     ;

; ---------------------------------------
; Handle structure
; ---------------------------------------
; three handle tokens : 
; HDLB_Token= 0 : free handle
;           = 1 : file to read
;           = 2 : file updated (write)
;           =-1 : LOAD"ed file (source file)

; offset values
HDLW_PrevHDL    .equ 0  ; previous handle ; used by LOAD"
HDLB_Token      .equ 2  ; token
HDLB_ClustOfst  .equ 3  ; Current sector offset in current cluster (Byte)
HDLL_DIRsect    .equ 4  ; Dir SectorL
HDLH_DIRsect    .equ 6  ; Dir SectorH
HDLW_DIRofst    .equ 8  ; BUFFER offset of Dir entry
HDLL_FirstClus  .equ 10 ; File First ClusterLo (identify the file)
HDLH_FirstClus  .equ 12 ; File First ClusterHi (byte)
HDLL_CurClust   .equ 14 ; Current ClusterLo
HDLH_CurClust   .equ 16 ; Current ClusterHi
HDLL_CurSize    .equ 18 ; written size / not yet read size (Long)
HDLH_CurSize    .equ 20 ; written size / not yet read size (Long)
HDLW_BUFofst    .equ 22 ; BUFFER offset ; used by LOAD"


    .IFDEF RAM_1K ; RAM_Size  = 1k
HandleMax       .equ 7
HandleLenght    .equ 24

;OpenedFirstFile     ; structure  "openedFile"
FirstHandle     .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
HandleEnd

    .ELSEIF     ; RAM_Size >= 2k
HandleMax       .equ 8
HandleLenght    .equ 24

;OpenedFirstFile     ; structure  "openedFile"
FirstHandle     .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
                .word 0,0,0,0,0,0,0,0,0,0,0,0
HandleEnd


SDIB
SDIB_SIZE .equ 84

    .org SDIB+SDIB_SIZE

    .ENDIF ; RAM_Size

SD_END_DATA

    .ENDIF ; SD_CARD_LOADER
; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx REGISTER USAGE
; ----------------------------------------------------------------------

    .SWITCH DTC
    .CASE 1 ; DOCOL = CALL rDOCOL

RSP         .reg    SP      ; RSP = Return Stack Pointer (return stack)

; DOxxx registers           ; must be saved before use and restored after use
rDODOES     .reg    r4
rDOCON      .reg    r5
rDOVAR      .reg    r6
rDOCOL      .reg    R7

; Scratch registers
Y           .reg    R8 
X           .reg    R9 
W           .reg    R10
T           .reg    R11
S           .reg    R12

; Forth virtual machine
IP          .reg    R13      ; interpretative pointer
TOS         .reg    R14      ; first PSP cell
PSP         .reg    R15      ; PSP = Parameters Stack Pointer (stack data)

    .CASE 2 ; DOCOL = PUSH IP + CALL rEXIT

RSP         .reg    SP      ; RSP = Return Stack Pointer (return stack)

; DOxxx registers           ; must be saved before use and restored after use
rDODOES     .reg    r4
rDOCON      .reg    r5
rDOVAR      .reg    r6
rEXIT       .reg    R7

; Scratch registers
Y           .reg    R8 
X           .reg    R9 
W           .reg    R10
T           .reg    R11
S           .reg    R12

; Forth virtual machine
IP          .reg    R13      ; interpretative pointer
TOS         .reg    R14      ; first PSP cell
PSP         .reg    R15      ; PSP = Parameters Stack Pointer (stack data)

    .CASE 3  ; INLINED DOCOL

RSP         .reg    SP      ; RSP = Return Stack Pointer (return stack)

; DOxxx registers           ; must be saved before use and restored after use
rDODOES     .reg    r4
rDOCON      .reg    r5
rDOVAR      .reg    r6

; Scratch registers
R           .reg    R7
Y           .reg    R8 
X           .reg    R9 
W           .reg    R10
T           .reg    R11
S           .reg    R12

; Forth virtual machine
IP          .reg    R13      ; interpretative pointer
TOS         .reg    R14      ; first PSP cell
PSP         .reg    R15      ; PSP = Parameters Stack Pointer (stack data)

    .ENDCASE ; DTC

; ----------------------------------------------------------------------
; DTCforthMSP430FR5xxx program (FRAM) memory
; ----------------------------------------------------------------------

    .org    PROGRAMSTART

; ----------------------------------------------------------------------
; DEFINING EXECUTIVE WORDS - DTC model
; ----------------------------------------------------------------------

; ----------------------------------------------------------------------
; very nice FAST FORTH added feature: 
; ----------------------------------------------------------------------
; as IP is calculated from the PC value we can place the low to high level
; switches "COLON" or "LO2HI" anywhere in a word, i.e. not only at its beginning.
; ----------------------------------------------------------------------


    .SWITCH DTC
    .CASE 1 ; DOCOL = CALL rDOCOL

mNEXT       .MACRO          ; return for low level words (written in assembler)
            MOV @IP+,PC     ; 4 fetch code address into PC, IP=PFA
            .ENDM           ; 4 cycles,1word = ITC -2cycles -1 word

NEXT        .equ    4D30h   ; 4 MOV @IP+,PC

FORTHtoASM  .MACRO          ; compiled by HI2LO
            .word   $+2     ; 0 cycle
            .ENDM           ; 0 cycle, 1 word

ASMtoFORTH  .MACRO          ; compiled by LO2HI
            CALL #EXIT      ;
            .ENDM           ; 2 words, 10~

DOCOL1      .equ    1287h   ; 4 CALL R7 ; [R7] is set as xdocol by COLD

mDOCOL      .MACRO          ; compiled by : and by colon
            CALL R7         ;
            .ENDM           ; 14~ 1 word

xdocol                      ; 4 for CALL rDOCOL
            MOV @RSP+,W     ; 2
            PUSH IP         ; 3     save old IP on return stack
            MOV W,IP        ; 1     set new IP to PFA
            MOV @IP+,PC     ; 4     = NEXT
                            ; 14 = ITC +4

    .CASE 2 ; DOCOL = PUSH IP + CALL rEXIT

mNEXT       .MACRO
            MOV @IP+,PC     ; 4 fetch code address into PC, IP=PFA
            .ENDM           ; 4cycles,1word = ITC -2cycles -1 word

NEXT        .equ    4D30h   ; 4 MOV @IP+,PC

FORTHtoASM  .MACRO          ; compiled by HI2LO
            .word   $+2     ; 0 cycle
            .ENDM           ; 0 cycle, 1 word

ASMtoFORTH  .MACRO          ; compiled by LO2HI
            CALL rEXIT      ;    CALL EXIT
            .ENDM           ; 10 cycles, 1 word

mDOCOL      .MACRO          ; compiled by : and by COLON
            PUSH IP         ; 3
            CALL rEXIT      ; 10 CALL EXIT
            .ENDM           ; 13 cycles (ITC+3), two words

DOCOL1      .equ    120Dh   ; 3 PUSH IP
DOCOL2      .equ    1287h   ; 4 CALL rEXIT ; [rEXIT] is set as EXIT by COLD

    .CASE 3 ; inlined DOCOL

mNEXT       .MACRO          ; return for low level words (written in assembler)
            MOV @IP+,PC     ; 4 fetch code address into PC, IP=PFA
            .ENDM           ; 4 cycles,1word = ITC -2cycles -1 word

NEXT        .equ    4D30h   ; 4 MOV @IP+,PC

FORTHtoASM  .MACRO          ; compiled by HI2LO
            .word   $+2     ; 0 cycle
            .ENDM           ; 0 cycle, 1 word

ASMtoFORTH  .MACRO          ; compiled by LO2HI
            MOV PC,IP       ; 1 
            ADD #4,IP       ; 1 
            MOV @IP+,PC     ; 4 NEXT
            .ENDM           ; 6 cycles, 3 words

mDOCOL      .MACRO          ; compiled by : and by COLON
            PUSH IP         ; 3 
            MOV PC,IP       ; 1 
            ADD #4,IP       ; 1 
            MOV @IP+,PC     ; 4 NEXT
            .ENDM           ; 9 cycles (ITC -1), 4 words

DOCOL1      .equ    120Dh   ; 3 PUSH IP
DOCOL2      .equ    400Dh   ; 1 MOV PC,IP
DOCOL3      .equ    522Dh   ; 1 ADD #4,IP 

    .ENDCASE ; DTC

; mDOVAR leave on parameter stack the PFA of a VARIABLE definition

mDOVAR      .MACRO          ; compiled by VARIABLE
            CALL rDOVAR     ;    CALL RFROM    
            .ENDM           ; 14 cycles (ITC+4), 1 word

DOVAR       .equ    1286h   ; 4 CALL rDOVAR ; [rDOVAR] is set as RFROM by COLD


; mDOCON  leave on parameter stack the [PFA] of a CONSTANT definition

mDOCON      .MACRO          ; compiled by CONSTANT
            CALL rDOCON     ;    CALL xdocon
            .ENDM           ; 16 cycles (ITC+4), 1 word

DOCON       .equ    1285h   ; 4 CALL rDOCON ; [rDOCON] is set as xdocon by COLD

xdocon  ;   -- constant     ; 4 for CALL rDOCON
            SUB #2,PSP      ; 1 make room on stack
            MOV TOS,0(PSP)  ; 3 push first PSP cell
            MOV @RSP+,TOS   ; 2 TOS=CONSTANT address
            MOV @TOS,TOS    ; 2 TOS=CONSTANT
            MOV @IP+,PC     ; 4 execute next word
                            ; 16 = ITC (+4)

; mDODOES  leave on parameter stack the PFA of a CREATE definition

mDODOES     .MACRO          ; compiled  by DOES>
            CALL rDODOES    ;    CALL xdodoes 
            .ENDM           ; 19 cycles (ITC-2), 1 word

DODOES      .equ    1284h   ; 4 CALL rDODOES ; [rDODOES] is set as xdodoes by COLD

xdodoes   ; -- a-addr       ; 4 for CALL rDODOES
            SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3 save TOS on parameters stack
            MOV @RSP+,TOS   ; 2 TOS = CFA address of master word, i.e. address of its first cell after DOES>
            PUSH IP         ; 3 save IP on return stack
            MOV @TOS+,IP    ; 2 IP = CFA of Master word, TOS = BODY of created word
            MOV @IP+,PC     ; 4 Execute Master word

; ----------------------------------------------------------------------
; INTERPRETER LOGIC
; ----------------------------------------------------------------------

;C EXIT     --      exit a colon definition; CALL #EXIT performs ASMtoFORTH
            FORTHWORD "EXIT"
EXIT        MOV     @RSP+,IP    ; 2 pop previous IP (or next PC) from return stack
            MOV     @IP+,PC     ; 4 = NEXT
                                ; 6 = ITC - 2

;Z lit      -- x    fetch inline literal to stack
; This is the primitive compiled by LITERAL.
            FORTHWORD "LIT"
lit         SUB     #2,PSP      ; 2  push old TOS..
            MOV     TOS,0(PSP)  ; 3  ..onto stack
            MOV     @IP+,TOS    ; 2  fetch new TOS value
            MOV     @IP+,PC     ; 4  NEXT
                                ; 11 = ITC - 2

; ----------------------------------------------------------------------
; STACK OPERATIONS
; ----------------------------------------------------------------------

;C DUP      x -- x x      duplicate top of stack
            FORTHWORD "DUP"
DUP         SUB     #2,PSP          ; 2  push old TOS..
            MOV     TOS,0(PSP)      ; 3  ..onto stack
            mNEXT                   ; 4

;C ?DUP     x -- 0 | x x    DUP if nonzero
            FORTHWORD "?DUP"
QDUP        CMP     #0,TOS          ; 2  test for TOS nonzero
            JNZ     DUP             ; 2
            mNEXT                   ; 4

;C DROP     x --          drop top of stack
            FORTHWORD "DROP"
DROP        MOV     @PSP+,TOS       ; 2
            mNEXT                   ; 4

;C SWAP     x1 x2 -- x2 x1    swap top two items
            FORTHWORD "SWAP"
SWAP        MOV     @PSP,W          ; 2
            MOV     TOS,0(PSP)      ; 3
            MOV     W,TOS           ; 1
            mNEXT                   ; 4

;C OVER    x1 x2 -- x1 x2 x1
            FORTHWORD "OVER"
OVER        SUB     #2,PSP          ; 2 -- x1 x x2
            MOV     TOS,0(PSP)      ; 3 -- x1 x2 x2
            MOV     2(PSP),TOS      ; 2 -- x1 x2 x1
            mNEXT                   ; 4

;C ROT    x1 x2 x3 -- x2 x3 x1
            FORTHWORD "ROT"
ROT         MOV     @PSP,W          ; 2 fetch x2
            MOV     TOS,0(PSP)      ; 3 store x3
            MOV     2(PSP),TOS      ; 3 fetch x1
            MOV     W,2(PSP)        ; 3 store x2
            mNEXT                   ; 4

;C >R    x --   R: -- x   push to return stack
            FORTHWORD ">R"
TOR         PUSH    TOS
            MOV     @PSP+,TOS
            mNEXT

;C R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
            FORTHWORD "R>"
RFROM       SUB     #2,PSP          ; 1
            MOV     TOS,0(PSP)      ; 3
            MOV     @RSP+,TOS       ; 2
            mNEXT                   ; 4

;C R@    -- x     R: x -- x   fetch from rtn stk
            FORTHWORD "R@"
RFETCH      SUB     #2,PSP
            MOV     TOS,0(PSP)
            MOV     @RSP,TOS
            mNEXT

;;Z SP@  -- a-addr       get data stack pointer, must leave PSTACK value if stack empty
;            FORTHWORD "SP@"
SPFETCH     MOV     TOS,-2(PSP) ;3
            MOV     PSP,TOS     ;1
            SUB     #2,PSP      ;1 post decrement stack...
            mNEXT

;C DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
            FORTHWORD "DEPTH"
DEPTH:      MOV     TOS,-2(PSP)
            MOV     #PSTACK,TOS
            SUB     PSP,TOS       ; PSP-S0--> TOS
            SUB     #2,PSP        ; post decrement stack...
            RRA     TOS           ; TOS/2   --> TOS
            mNEXT

; ----------------------------------------------------------------------
; MEMORY OPERATIONS
; ----------------------------------------------------------------------

;C @       a-addr -- x   fetch cell from memory
            FORTHWORD "@"
FETCH       MOV     @TOS,TOS
            mNEXT


;C !        x a-addr --   store cell in memory
            FORTHWORD "!"
STORE       MOV     @PSP+,0(TOS)    ;4
            MOV     @PSP+,TOS       ;2
            mNEXT                   ;4

;C C@     c-addr -- char   fetch char from memory
            FORTHWORD "C@"
CFETCH      MOV.B   @TOS,TOS
            mNEXT


;C C!      char c-addr --    store char in memory
            FORTHWORD "C!"
CSTORE      MOV     @PSP+,W     ;2
            MOV.B   W,0(TOS)    ;3
            MOV     @PSP+,TOS   ;2
            mNEXT

; ----------------------------------------------------------------------
; ARITHMETIC OPERATIONS
; ----------------------------------------------------------------------

;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
            FORTHWORD "+"
PLUS        ADD     @PSP+,TOS
            mNEXT

;C -      n1/u1 n2/u2 -- n3/u3      subtract n1-n2
            FORTHWORD "-"
MINUS       MOV     @PSP+,W     ; 2
            SUB     TOS,W       ; 1
            MOV     W,TOS       ; 1
            mNEXT

;C AND    x1 x2 -- x3           logical AND
            FORTHWORD "AND"
ANDD        AND     @PSP+,TOS
            mNEXT

;C OR     x1 x2 -- x3           logical OR
            FORTHWORD "OR"
ORR         BIS     @PSP+,TOS
            mNEXT

;C XOR    x1 x2 -- x3           logical XOR
            FORTHWORD "XOR"
XORR        XOR     @PSP+,TOS
            mNEXT

;C NEGATE   x1 -- x2            two's complement
            FORTHWORD "NEGATE"
NEGATE      XOR     #-1,TOS
            ADD     #1,TOS
            mNEXT

;C ABS     n1 -- +n2     absolute value
            FORTHWORD "ABS"
ABBS:       CMP     #0,TOS       ; 1
            JN      NEGATE
            mNEXT

; ----------------------------------------------------------------------
; COMPARAISON OPERATIONS
; ----------------------------------------------------------------------

;C 0=     n/u -- flag    return true if TOS=0
            FORTHWORD "0="
ZEROEQUAL   SUB     #1,TOS      ; borrow (clear cy) if TOS was 0
            SUBC    TOS,TOS     ; TOS=-1 if borrow was set
            mNEXT

;C 0<     n -- flag      true if TOS negative
            FORTHWORD "0<"
ZEROLESS    ADD     TOS,TOS     ; set carry if TOS negative
            SUBC    TOS,TOS     ; TOS=-1 if carry was clear
            XOR     #-1,TOS     ; TOS=-1 if carry was set
            mNEXT

;C =      x1 x2 -- flag         test x1=x2
            FORTHWORD "="
EQUAL:      SUB     @PSP+,TOS   ; 2
            JNZ     TOSFALSE    ; 2 --> +4
TOSTRUE:    MOV     #-1,TOS     ; 2 (MOV @R3+,TOS)
            mNEXT               ; 4

;C <      n1 n2 -- flag        test n1<n2, signed
            FORTHWORD "<"
LESS:       MOV     @PSP+,W     ; 2 W=n1
            SUB     TOS,W       ; 1 W=n1-n2 flags set
            JL      TOSTRUE     ; 2
TOSFALSE    MOV     #0,TOS      ; 1
            mNEXT               ; 4

;C >     n1 n2 -- flag         test n1>n2, signed
            FORTHWORD ">"
GREATER:    SUB     @PSP+,TOS   ; 2 TOS=n2-n1
            JL      TOSTRUE     ; 2
            MOV     #0,TOS      ; 1
            mNEXT               ; 4

;C U<    u1 u2 -- flag       test u1<u2, unsigned
            FORTHWORD "U<"
ULESS:      MOV     @PSP+,W     ; 2
            SUB     TOS,W       ; 1 u1-u2 in W, cy clear if borrow
            JNC     TOSTRUE     ; 2
            MOV     #0,TOS      ; 1
            mNEXT               ; 4

; ----------------------------------------------------------------------
; BRANCH and LOOP OPERATIONS
; ----------------------------------------------------------------------

;Z branch   --                  branch always
;            FORTHWORD "BRANCH"
BRAN        MOV     @IP,IP      ; 2
            mNEXT               ; 4

;Z ?branch   x --              branch if TOS = zero
;            FORTHWORD "?BRANCH"
QBRAN       CMP     #0,TOS      ; 1  test TOS value
            MOV     @PSP+,TOS   ; 2  pop new TOS value (doesn't change flags)
            JZ      bran        ; 2  if TOS was zero, take the branch = 11 cycles
            ADD     #2,IP       ; 1  else skip the branch destination
            mNEXT               ; 4  ==> branch not taken = 10 cycles

;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2      run-time code for DO
;                                               n1|u1=limit, n2|u2=index
;            FORTHWORD "(DO)"

xdo         MOV     #8000h,X        ;2 compute 8000h-limit "fudge factor"
            SUB     @PSP+,X         ;2
            MOV     TOS,Y           ;1 loop ctr = index+fudge
            MOV     @PSP+,TOS       ;2 pop new TOS
            ADD     X,Y             ;1
            .word 01519h            ;4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
            mNEXT                   ;4

;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates, clean up the
; return stack and skip the branch. Else take the inline branch.
;            FORTHWORD "(+LOOP)"

xploop      ADD     TOS,0(RSP)  ;4 increment INDEX by TOS value
            MOV     @PSP+,TOS   ;2 get new TOS, doesn't change flags
xloopnext   BIT     #100h,SR    ;2 is overflow bit set?
            JZ      bran        ;2 no overflow = loop
            ADD     #2,IP       ;1 overflow = loop done, skip branch ofs
UNXLOOP     ADD     #4,RSP      ;1 empty RSP
            mNEXT               ;4 16~ taken or not taken xloop/loop
                 

;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates, clean up the
; return stack and skip the branch.  Else take the inline branch.
; Note that LOOP terminates when index=8000h.
;            FORTHWORD "(LOOP)"

xloop       ADD     #1,0(RSP)   ;4 increment INDEX
            JMP     xloopnext   ;2

;C UNLOOP   --   R: sys1 sys2 --  drop loop parms
            FORTHWORD "UNLOOP"
UNLOOP      JMP     UNXLOOP

;C I        -- n   R: sys1 sys2 -- sys1 sys2
;C                  get the innermost loop index
            FORTHWORD "I"
II          SUB     #2,PSP          ; make room in TOS
            MOV     TOS,0(PSP)
            MOV     @RSP,TOS        ; index = loopctr - fudge
            SUB     2(RSP),TOS
            mNEXT

;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
            FORTHWORD "J"
JJ          SUB     #2,PSP          ; make room in TOS
            MOV     TOS,0(PSP)
            MOV     4(RSP),TOS      ; index = loopctr - fudge
            SUB     6(RSP),TOS
            mNEXT

; ----------------------------------------------------------------------
; SYSTEM VARIABLES & CONSTANTS
; ----------------------------------------------------------------------

;C >IN     -- a-addr       holds offset in input stream
            FORTHWORD ">IN"
FTOIN       mDOCON
            .word   TOIN    ; VARIABLE address in RAM space

;C BASE    -- a-addr       holds conversion radix
            FORTHWORD "BASE"
FBASE       mDOCON
            .word   BASE    ; VARIABLE address in INFO space

;C STATE   -- a-addr       holds compiler state
            FORTHWORD "STATE"
FSTATE      mDOCON
            .word   STATE   ; VARIABLE address in RAM space

;C BL      -- char            an ASCII space
            FORTHWORD "BL"
FBLANK       mDOCON
            .word   32

; ----------------------------------------------------------------------
; MULTIPLY
; ----------------------------------------------------------------------

    .IFNDEF MPY ; if no hardware MPY

; T.I. SIGNED MULTIPLY SUBROUTINE: U1 x U2 -> Ud

;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
            FORTHWORD "UM*"
UMSTAR      MOV @PSP,S      ; U1 = MULTIPLICANDlo
            MOV #0,W        ; 0 -> created MULTIPLICANDhi
            MOV #0,Y        ; 0 -> created RESULTlo
            MOV #0,T        ; 0 -> created RESULThi
            MOV #1,X        ; BIT TEST REGISTER
UMSTARLOOP  BIT X,TOS       ;1 TEST ACTUAL BIT MULTIPLIER
            JZ UMSTARNEXT   ;2 IF 0: DO NOTHING
            ADD S,Y         ;1 IF 1: ADD MULTIPLICAND TO RESULT
            ADDC W,T        ;1
UMSTARNEXT  ADD S,S         ;1 (RLA LSBs) MULTIPLICAND x 2
            ADDC W,W        ;1 (RLC MSBs)
            ADD X,X         ;1 (RLA) NEXT BIT TO TEST
            JNC UMSTARLOOP  ;2 IF BIT IN CARRY: FINISHED    10~ loop
            MOV Y,0(PSP)    ; low result on stack
            MOV T,TOS       ; high result in TOS
            mNEXT

    .ENDIF ; hardware MPY

; ----------------------------------------------------------------------------------------
; ANS complement OPTION that include ALIGNMENT, PORTABILITY, ARITHMETIC and DOUBLE options
; ----------------------------------------------------------------------------------------
    .IFDEF ANS_CORE_COMPLIANT
    .include "ADDON\ANS_COMPLEMENT.asm"
; ----------------------------------------------------------------------------------------

    .ELSEIF

; ----------------------------------------------------------------------
; ALIGNMENT OPERATORS OPTION
; ----------------------------------------------------------------------
    .IFDEF ALIGNMENT ; included in ANS_COMPLEMENT
    .include "ADDON\ALIGNMENT.asm"
    .ENDIF ; ALIGNMENT
; ----------------------------------------------------------------------
; PORTABILITY OPERATORS OPTION
; ----------------------------------------------------------------------
    .IFDEF PORTABILITY
    .include "ADDON\PORTABILITY.asm"
    .ENDIF ; PORTABILITY
; ----------------------------------------------------------------------
; ARITHMETIC OPERATORS OPTION
; ----------------------------------------------------------------------
    .IFDEF ARITHMETIC ; included in ANS_COMPLEMENT
    .include "ADDON\ARITHMETIC.asm"
    .ENDIF ; ARITHMETIC
; ----------------------------------------------------------------------
; DOUBLE OPERATORS OPTION
; ----------------------------------------------------------------------
    .IFDEF DOUBLE ; included in ANS_COMPLEMENT
    .include "ADDON\DOUBLE.asm"
    .ENDIF ; DOUBLE

; ----------------------------------------------------------------------------------------
    .ENDIF ; ANS_COMPLEMENT
; ----------------------------------------------------------------------------------------

; ----------------------------------------------------------------------
; NUMERIC OUTPUT
; ----------------------------------------------------------------------

; Numeric conversion is done last digit first, so
; the output buffer is built backwards in memory.

;C <#    --             begin numeric conversion (initialize Hold Pointer in PAD area)
            FORTHWORD "<#"
LESSNUM:    MOV     #BASE_HOLD,&HP
            mNEXT

; unsigned 32-BIT DIVIDEND : 16-BIT DIVISOR --> 32-BIT QUOTIENT, 16-BIT REMAINDER
; DVDhi|DVDlo : DVR --> QUOThi|QUOTlo, REMAINDER
; then REMAINDER is converted in ASCII char
; about 2 times faster if ud1 < 65536 (it's the general case)

; input registers :
; T     = DIVISOR
; S     = DVDlo
; W     = DVDhi
; output registers :
; W     = remainder
; X     = QUOTlo
; Y     = QUOThi
; saved registers :
; IP    = count
; TOS   = DVD48

UDIVQ32                         ; use S,T,W,X,Y
            .word   151Eh       ;4  PUSHM TOS,IP (1+1 push,TOS=Eh): save all no scratch registers before use
            MOV     #0,TOS      ;1  TOS = DVD48 = 0
            MOV     #32,IP      ;3  init loop count
            CMP     #0,W        ;1  DVDhi <> 0 ?
            JNZ     MDIV1       ;2  yes
            RRA     IP          ;1  no: loop count / 2
            MOV     S,W         ;1      DVD = DVD<<16
            MOV     #0,S        ;1
            MOV     #0,X        ;1      QUOTlo = 0
MDIV1:      CMP     T,TOS       ;1  DVD48 > divisor ?
            JNC     MDIV2       ;2  U<
            SUB     T,TOS       ;1  DVD48 - DVR
MDIV2:      ADDC    X,X         ;1  RLC quotLO
            ADDC    Y,Y         ;1  RLC quotHI
            SUB     #1,IP       ;1  Decrement loop counter
            JN      ENDMDIVIDE  ;2  If 0< --> end
            ADD     S,S         ;1  RLA DVDlo
            ADDC    W,W         ;1  RLC DVDhi
            ADDC    TOS,TOS     ;1  RLC DVD48
            JNC     MDIV1       ;2                  14~ loop
            SUB     T,TOS       ;1  DVD48 - DVR
            BIS     #1,SR       ;1  SETC
            JMP     MDIV2       ;2                  14~ loop
ENDMDIVIDE  MOV     TOS,W       ;1  DVD48 ==> W = remainder
            .word   171Dh       ;4  POPM IP, TOS
            RET                 ;4  27 words


;C #     ud1lo:ud1hi -- ud2lo:ud2hi          convert 1 digit of output
            FORTHWORD "#"
NUM         MOV     &BASE,T     ;3  T = Divisor 
            MOV     @PSP,S      ;2  S = DVDlo
            MOV     TOS,W       ;1  TOS ==> W = DVDhi
            CALL    #UDIVQ32    ;4  use S,T,W,X,Y
            MOV     X,0(PSP)    ;3  QUOTlo in 0(PSP)
            MOV     Y,TOS       ;1  QUOThi in TOS
TODIGIT     CMP.B   #10,W       ;2  W = REMAINDER
            JLO     TODIGIT1    ;2  U<
            ADD     #7,W        ;2
TODIGIT1    ADD     #30h,W      ;2
HOLDW       SUB     #1,&HP      ;3  store W=char --> -[HP]
            MOV     &HP,Y       ;3
            MOV.B   W,0(Y)      ;3
            mNEXT               ;4  23 words, about 290/490 cycles/char

;C #S    udlo:udhi -- udlo:udhi=0       convert remaining digits
            FORTHWORD "#S"
NUMS        mDOCOL
            .word   NUM         ;
NUMS1       FORTHtoASM          ;
            SUB     #2,IP       ;1      define NUM return
            CMP     #0,X        ;1      test udlo first
            JNZ     NUM         ;2
            CMP     #0,TOS      ;1      then udhi
            JNZ     NUM         ;2
NUMSEND     MOV     @RSP+,IP    ;2
            mNEXT               ;4

;C #>    udlo:udhi=0 -- c-addr u    end conversion, get string
            FORTHWORD "#>"
NUMGREATER: MOV     &HP,0(PSP)
            MOV     #BASE_HOLD,TOS
            SUB     @PSP,TOS
            mNEXT

;C HOLD  char --        add char to output string
            FORTHWORD "HOLD"
HOLD:       MOV     TOS,W       ;1
            MOV     @PSP+,TOS   ;2
            JMP     HOLDW       ;15

;C SIGN  n --           add minus sign if n<0
            FORTHWORD "SIGN"
SIGN:       CMP     #0,TOS
            MOV     @PSP+,TOS
            MOV     #'-',W
            JN      HOLDW   ; 0<
            mNEXT

;C UD.    udlo udhi --           display ud (unsigned)
            FORTHWORD "UD."
UDDOT:       mDOCOL
            .word   LESSNUM,NUMS,NUMGREATER,TYPE
            .word   SPACE,EXIT

;C U.    u --           display u (unsigned)
            FORTHWORD "U."
UDOT:       SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #0,TOS
            JMP UDDOT

;C DABS     d1 -- |d1|     absolute value
;            FORTHWORD "DABS"
DABBS:      BIT     #8000h,TOS       ; 1
            JZ      DABBSEND
            XOR     #-1,0(PSP)
            XOR     #-1,TOS
            ADD     #1,0(PSP)
            ADDC    #0,TOS
DABBSEND    mNEXT

;C D.     dlo dhi --           display d (signed)
            FORTHWORD "D."
DDOT:        mDOCOL
            .word   LESSNUM,SWAP,OVER,DABBS,NUMS
            .word   ROT,SIGN,NUMGREATER,TYPE,SPACE,EXIT

;C .     n --           display n (signed)
            FORTHWORD "."
DOT:        BIT #8000h,TOS
            JZ  UDOT
            SUB #2,PSP
            MOV #-1,TOS
            JMP DDOT

; ----------------------------------------------------------------------
; DICTIONARY MANAGEMENT
; ----------------------------------------------------------------------

;C HERE    -- addr      returns dictionary ptr
            FORTHWORD "HERE"
HERE        SUB     #2,PSP
            MOV     TOS,0(PSP)
            MOV     &DDP,TOS
            mNEXT

;C ALLOT   n --         allocate n bytes in dict
            FORTHWORD "ALLOT"
ALLOT       ADD     TOS,&DDP
            MOV     @PSP+,TOS
            mNEXT

;C C,   char --        append char to dict
            FORTHWORD "C,"
CCOMMA      MOV     &DDP,W
            MOV.B   TOS,0(W)
            ADD     #1,&DDP
            MOV     @PSP+,TOS
            mNEXT

; ------------------------------------------------------------------------------
; TERMINAL I/O, input part
; ------------------------------------------------------------------------------

;Z (KEY?)   -- c      get character from the terminal
;            FORTHWORD "(KEY?)"
PARENKEYTST SUB     #2,PSP              ; 1  push old TOS..
            MOV     TOS,0(PSP)          ; 4  ..onto stack
            CALL    #XON
KEYLOOP     BIT     #UCRXIFG,&TERMIFG   ; loop if bit0 = 0 in interupt flag register
            JZ      KEYLOOP             ;
            MOV     &TERMRXBUF,TOS      ;
            CALL    #XOFF               ;
            mNEXT

;F KEY?     -- c      get character from input device ; deferred word
;            FORTHWORD "KEY?"
KEYTST      MOV     #PARENKEYTST,PC


;Z (KEY)    -- c      get character from the terminal
            FORTHWORD "(KEY)"
PARENKEY    MOV     &TERMRXBUF,Y        ; empty buffer
            JMP     PARENKEYTST

;C KEY      -- c      wait character from input device ; deferred word
            FORTHWORD "KEY"
KEY         MOV     #PARENKEY,PC

; ----------------------------------------------------------------------
; INTERPRETER INPUT, the kernel of kernel !
; ----------------------------------------------------------------------

    .IFDEF SD_CARD_LOADER                   ; ACCEPT becomes a DEFERred word

    .include "forthMSP430FR_SD_ACCEPT.asm"  ; that creates SD_ACCEPT and (SD_ACCEPT)

    .ELSE                                   ; ACCEPT is not a DEFERred word 

;C ACCEPT  addr len -- len'  get line at addr to interpret len' chars
            FORTHWORD "ACCEPT"
ACCEPT

    .ENDIF

; con speed of TERMINAL link, there are three bottlenecks :
; 1- time to send XOFF/RTS_high on CR (CR+LF=EOL), first emergency.
; 2- the char loop time,
; 3- the time between sending XON/RTS_low and clearing UCRXIFG on first received char,
; everything must be done to reduce these times, taking into account the necessity of switching to Standby (LPMx mode). 
; --------------------------------------;
; (ACCEPT) part I: prepare TERMINAL_INT ;
; --------------------------------------;
            MOV     #ENDACCEPT,S        ;2              S = XOFF return
            MOV     #AKEYREAD1,T        ;2              T = default XON return
            .word   152Dh               ;5              PUSHM IP,S,T, as IP ret, XOFF ret, XON ret
            MOV     TOS,W               ;1 -- addr len
            MOV     @PSP,TOS            ;2 -- org ptr                                             )
            ADD     TOS,W               ;1 -- org ptr   W=Bound                                   ) 
            MOV     #0Dh,T              ;2              T = 'CR' to speed up char loop in part II  > prepare stack and registers
            MOV     #20h,S              ;2              S = 'BL' to speed up char loop in part II )  for TERMINAL_INT use
            MOV     #AYEMIT_RET,IP      ;2              IP = return for YEMIT                     )
            BIT     #UCRXIFG,&TERMIFG   ;3              RX_Int ?
            JZ      ACCEPTNEXT          ;2              no : case of FORTH init or input terminal quiet
            MOV     &TERMRXBUF,Y        ;3              yes: clear RX_Int
            CMP     #0Ah,Y              ;2                   received char = LF ? (end of downloading ?) 
            JNZ     XON                 ;2                   no : process char (first char of a new line).
ACCEPTNEXT  ADD     #2,RSP              ;1              nothing to do, remove previous XON return address,
            MOV     #LPMx_LOOP,X        ;2              and set good XON return to force the shutdown in sleep mode
            .word   154Dh               ;7              PUSHM IP,S,T,W,X

; ======================================;
XON                                     ;
; ======================================;
    .IFDEF TERMINALXONXOFF              ;
            MOV     #17,&TERMTXBUF      ;4  move char XON into TX_buf
    .IF TERMINALBAUDRATE/FREQUENCY <230400
XON_LOOP    BIT     #UCTXIFG,&TERMIFG   ;3  wait the sending end of previous char, useless at high baudrates
            JZ      XON_LOOP            ;2
    .ENDIF
    .ENDIF                              ;
    .IFDEF TERMINALCTSRTS               ;
            BIC.B   #RTS,&HANDSHAKOUT   ;4  set RTS low
    .ENDIF                              ;
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts first and 3th stopwatches      ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
            RET                         ;4  to LPMx_LOOP or AKEYREAD1, ...or user defined
; --------------------------------------;

; ======================================;
XOFF                                    ; NOP11
; ======================================;
    .IFDEF TERMINALXONXOFF              ;
            MOV     #19,&TERMTXBUF      ;4 move XOFF char into TX_buf
    .IF TERMINALBAUDRATE/FREQUENCY <230400
XOFF_LOOP   BIT     #UCTXIFG,&TERMIFG   ;3 wait the sending end of previous char, useless at high baudrates
            JZ      XOFF_LOOP           ;2
    .ENDIF
    .ENDIF                              ;
    .IFDEF TERMINALCTSRTS               ;
            BIS.B   #RTS,&HANDSHAKOUT   ;4 set RTS high
    .ENDIF                              ;
            RET                         ;4 to ENDACCEPT, ...or user defined
; --------------------------------------;


; ======================================;
LPMx_LOOP                               ; XON RET address 1 ; NOP100
; ======================================;
    BIS &LPM_MODE,SR                    ;3  enter in LPMx sleep mode with GIE=1
; --------------------------------------;   default mode : LPM0.


; ### #     # ####### ####### ######  ######  #     # ######  #######  #####     #     # ####### ######  #######
;  #  ##    #    #    #       #     # #     # #     # #     #    #    #     #    #     # #       #     # #
;  #  # #   #    #    #       #     # #     # #     # #     #    #    #          #     # #       #     # #
;  #  #  #  #    #    #####   ######  ######  #     # ######     #     #####     ####### #####   ######  #####
;  #  #   # #    #    #       #   #   #   #   #     # #          #          #    #     # #       #   #   #
;  #  #    ##    #    #       #    #  #    #  #     # #          #    #     #    #     # #       #    #  #
; ### #     #    #    ####### #     # #     #  #####  #          #     #####     #     # ####### #     # #######


; here, Fast FORTH sleeps, waiting any interrupt.
; IP,S,T,W,X,Y registers (R13 to R8) are free for any interrupt routine...
; ...and so PSP and RSP stacks with their rules of use.
; remember : in any interrupt routine you must include : BIC #0xF8,0(RSP) before RETI
;           to force return to LPMx_LOOP.


; ======================================;
            JMP     LPMx_LOOP           ;2  and here is the return for any interrupts, else TERMINAL_INT  :-)
; ======================================;


; **************************************;
TERMINAL_INT                            ; <--- UCA0 RX interrupt vector, delayed by the LPMx wake up time
; **************************************;      if wake up time increases, max bauds rate decreases...
; (ACCEPT) part II under interrupt      ; Org Ptr -- len'
; --------------------------------------;
            ADD     #4,RSP              ;1  remove SR and PC from stack
            .word   173Ah               ;6  POPM W=bound,T=0Dh,S=20h,IP=AYEMIT_RET
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts the 2th stopwatch              ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD    MOV.B   &TERMRXBUF,Y        ;3  read character into Y, UCRXIFG is cleared
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 3th stopwatch               ; 3th bottleneck result : 17~ + LPMx wake_up time ( + 5~ XON loop if F/Bds<230400 )
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD1                               ; <---  XON RET address 2 ; first emergency: anticipate XOFF on CR as soon as possible
            CMP.B   T,Y                 ;1      char = CR ?
            JZ      XOFF                ;2      then RET to ENDACCEPT
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;+ 4
; stops the first stopwatch             ;       first bottleneck, best case result: 24~ + LPMx wake_up time..
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;       ...or 11~ in case of empty line
            CMP.B   S,Y                 ;1      printable char ?
            JHS     ASTORETEST          ;2      yes
            CMP.B   #8,Y                ;       char = BS ?
            JNE     WAITaKEY
; --------------------------------------;
; start of backspace                    ;
; --------------------------------------;
BACKSPACE   CMP     @PSP,TOS            ;       Ptr = Org ?
            JZ      WAITaKEY            ;       yes: do nothing
            SUB     #1,TOS              ;       no : dec Ptr
; --------------------------------------;
    .IFDEF BACKSPACE_ERASE
            MOV     #BS_NEXT,IP         ;
            JMP     YEMIT               ;       send BS
BS_NEXT     FORTHtoASM                  ;
            MOV     #32,Y               ;       send SPACE to rub previous char
            ADD     #8,IP               ;       (BS_NEXT+2) + 8 = FORTHtoASM @ !
            JMP     YEMIT               ;
            FORTHtoASM                  ;
            MOV.B   #8,Y                ;
            MOV     #AYEMIT_RET,IP      ;
    .ENDIF
; --------------------------------------;
            JMP     YEMIT               ;       send BS
; --------------------------------------;
; end of backspace                      ;
; --------------------------------------;
ASTORETEST  CMP     W,TOS               ; 1 Bound is reached ? (protect against big lines without CR, UNIX like)
            JZ      YEMIT               ; 2 yes, send echo without store, then loopback
ASTORE      MOV.B   Y,0(TOS)            ; 3 no, store char @ Ptr before send echo, then loopback
            ADD     #1,TOS              ; 1     increment Ptr
YEMIT       .word   4882h               ; hi7/4~ lo:12/4~ send/send_not  echo to terminal
            .word   TERMTXBUF           ; 3 MOV Y,&TERMTXBUF
    .IF TERMINALBAUDRATE/FREQUENCY <230400
YEMIT1      BIT     #UCTXIFG,&TERMIFG   ; 3 wait the sending end of previous char, useless at high baudrates
            JZ      YEMIT1              ; 2
    .ENDIF
            mNEXT                       ; 4
; --------------------------------------;
AYEMIT_RET  FORTHtoASM                  ; 0     YEMII NEXT address; NOP9
            SUB     #2,IP               ; 1 set YEMIT NEXT address to AYEMIT_RET
WAITaKEY    BIT     #UCRXIFG,&TERMIFG   ; 3 new char in TERMRXBUF ?
            JZ      WAITaKEY            ; 2 no
            JNZ     AKEYREAD            ; 2 yes
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 2th stopwatch               ; best case result: 31~/28~ (with/without echo) ==> 322/357 kBds/MHz
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;

; --------------------------------------;
ENDACCEPT                               ; <--- XOFF RET address
; --------------------------------------;
            MOV     #LPM0+GIE,&LPM_MODE ; reset LPM_MODE to default mode LPM0
DROPEXIT    SUB     @PSP+,TOS           ; Org Ptr -- len'
            MOV     @RSP+,IP            ; 2 and continue with INTERPRET with GIE=0.
                                        ; So FORTH machine is protected against any interrupt...
            mNEXT                       ; ...until next falling down to LPMx mode of (ACCEPT) part1,
; **************************************;    i.e. when the FORTH interpreter has no more to do.

; ------------------------------------------------------------------------------
; TERMINAL I/O, output part
; ------------------------------------------------------------------------------


;Z (EMIT)   c --    output character (byte) to the terminal
; hardware or software control on TX flow seems not necessary with UARTtoUSB bridges because
; they stop TX when their RX buffer is full. So no problem when the terminal input is echoed to output.
            FORTHWORD "(EMIT)"
PARENEMIT   MOV     TOS,Y               ; 1
            MOV     @PSP+,TOS           ; 2
    .IF TERMINALBAUDRATE/FREQUENCY >=230400
YEMIT1      BIT     #UCTXIFG,&TERMIFG   ; 3 wait the sending end of previous char (usefull for low baudrates)
            JZ      YEMIT1              ; 2
    .ENDIF
            JMP     YEMIT


;C EMIT     c --    output character to the output device ; deferred word
            FORTHWORD "EMIT"
EMIT        MOV     #PARENEMIT,PC       ; 3


;Z ECHO     --      connect console output (default)
            FORTHWORD "ECHO"
ECHO        MOV     #4882h,&YEMIT        ; 4882h = MOV Y,&<next_adr>
            mNEXT

;Z NOECHO   --      disconnect console output
            FORTHWORD "NOECHO"
NOECHO      MOV     #NEXT,&YEMIT        ;  NEXT = 4030h = MOV @IP+,PC
            mNEXT

; (CR)     --               send CR to the output terminal (via EMIT)
            FORTHWORD "(CR)"
PARENCR     SUB     #2,PSP
            MOV     TOS,0(PSP)
            MOV     #0Dh,TOS
            JMP     EMIT

;C CR      --               send CR to the output device
            FORTHWORD "CR"
CR          MOV #PARENCR,PC


;C SPACE   --               output a space
            FORTHWORD "SPACE"
SPACE       SUB     #2,PSP
            MOV     TOS,0(PSP)
            MOV     #20h,TOS
            JMP     EMIT

;C SPACES   n --            output n spaces
            FORTHWORD "SPACES"
SPACES      CMP     #0,TOS
            JZ      SPACESEND
            PUSH    IP
            MOV     #SPACESNEXT,IP
            JMP     SPACE
SPACESNEXT  FORTHtoASM
            SUB     #2,IP
            SUB     #1,TOS
            JNZ     SPACE
            MOV     @RSP+,IP
SPACESEND   MOV     @PSP+,TOS
            mNEXT


;C TYPE    adr len --     type line to terminal
            FORTHWORD "TYPE"
TYPE        CMP     #0,TOS
            JZ      TWODROP
            MOV     @PSP,W
            ADD     TOS,0(PSP)
            MOV     W,TOS
            mDOCOL
            .word   xdo
TYPELOOP    .word   II,CFETCH,EMIT,xloop,TYPELOOP
            .word   EXIT


; ------------------------------------------------------------------------------
; STRINGS PROCESSING
; ------------------------------------------------------------------------------

;Z (S")     -- addr u   run-time code for S"
; get address and length of string.
XSQUOTE:    SUB     #4,PSP          ; 1 -- x x TOS      ; push old TOS on stack
            MOV     TOS,2(PSP)      ; 3 -- TOS x x      ; and reserve one cell on stack
            MOV.B   @IP+,TOS        ; 2 -- x u          ; u = lenght of string
            MOV     IP,0(PSP)       ; 3 -- addr u
            ADD     TOS,IP          ; 1 -- addr u       IP=addr+u=addr(end_of_string)
            BIT     #1,IP           ; 1 -- addr u       IP=addr+u   Carry set/clear if odd/even
            ADDC    #0,IP           ; 1 -- addr u       IP=addr+u aligned
            mNEXT                   ; 4  16~

;C S"       --             compile in-line string
            FORTHWORDIMM "S\34"        ; immediate
SQUOTE:     mDOCOL
            .word   lit,XSQUOTE,COMMA
            .word   lit,'"',WORDD ; -- c-addr (= HERE)
            FORTHtoASM
            MOV @RSP+,IP
            MOV.B @TOS,TOS      ; -- u
            SUB #1,TOS          ;   -1 byte
            ADD TOS,&DDP
            MOV @PSP+,TOS
CELLPLUSALIGN
            BIT #1,&DDP         ;3 
            ADDC #2,&DDP        ;4  +2 bytes
            mNEXT

    .IFDEF LOWERCASE

            FORTHWORD "CAPS_ON"
CAPS_ON     MOV     #-1,&CAPS       ; state by default
            mNEXT

            FORTHWORD "CAPS_OFF"
CAPS_OFF    MOV     #0,&CAPS
            mNEXT

;C ."       --              compile string to print
            FORTHWORDIMM ".\34"        ; immediate
DOTQUOTE:   mDOCOL
            .word   CAPS_OFF
            .word   SQUOTE
            .word   CAPS_ON
            .word   lit,TYPE,COMMA,EXIT

    .ELSE

;C ."       --              compile string to print
            FORTHWORDIMM ".\34"        ; immediate
DOTQUOTE:   mDOCOL
            .word   SQUOTE
            .word   lit,TYPE,COMMA,EXIT

    .ENDIF ; LOWERCASE

; ----------------------------------------------------------------------
; INTERPRETER
; ----------------------------------------------------------------------

;C WORD   char -- addr        Z=1 if len=0
; parse a word delimited by char ( and begining usually at [TIB])
;                                   "word" is capitalized 
;                                   TOIN is the relative displacement into buffer
;                                   empty line = 25 cycles + 7 cycles by char
            FORTHWORD "WORD"
WORDD       MOV     #SOURCE_LEN,S   ;2 -- separator 
            MOV     @S+,X           ;2               X = buf_len
            MOV     @S+,W           ;2               W = buf_org
            ADD     W,X             ;1               W = buf_org X = buf_org + buf_len = buf_end
            ADD     @S+,W           ;2               W = buf_org + >IN = buf_ptr    X = buf_end
            MOV     @S,Y            ;2 -- separator  W = buf_ptr    X = buf_end     Y = HERE, as dst_ptr
SKIPCHARLOO CMP     W,X             ;1               buf_ptr = buf_end ?
            JZ      EOL_END         ;2 -- separator  if yes : End Of Line !
            CMP.B   @W+,TOS         ;2               does char = separator ?
            JZ      SKIPCHARLOO     ;2 -- separator  if yes
SCANWORD    SUB     #1,W            ;1
            MOV     #96,T           ;2              T = 96 = ascii(a)-1 (test value in register before SCANWORD loop)
SCANWORDLOO                         ; -- separator  15/23 cycles loop for upper/lower case char... write words in upper case !
            MOV.B   S,0(Y)          ;3              first time puts anything in dst word length, then put char @ dst.
            CMP     W,X             ;1              buf_ptr = buf_end ?
            JZ      SCANWORDEND     ;2              if yes
            MOV.B   @W+,S           ;2
            CMP.B   S,TOS           ;1              does char = separator ?
            JZ      SCANWORDEND     ;2              if yes
            ADD     #1,Y            ;1              increment dst just before test loop
            CMP.B   S,T             ;1              char U< 'a' ?  ('a'-1 U>= char) this condition is tested at each loop
            JC      SCANWORDLOO     ;2              15~ upper case char loop
    .IFDEF LOWERCASE                ;               enable lowercase strings
QCAPS       CMP     #0,&CAPS        ;3              CAPS is OFF ? (case available only for ABORT" ." .( )
            JZ      SCANWORDLOO     ;2              yes
    .ENDIF ; LOWERCASE              ;               here CAPS is ON (other cases)
            CMP.B   #123,S          ;2              char U>= 'z'+1 ?
            JC      SCANWORDLOO     ;2              if yes
            SUB.B   #32,S           ;2              convert lowercase char to uppercase
            JMP     SCANWORDLOO     ;2              28~ lower case char loop

SCANWORDEND SUB     &SOURCE_ADR,W   ;3 -- separator  W=buf_ptr - buf_org = new >IN (first char separator next)
            MOV     W,&TOIN         ;3               update >IN
EOL_END     MOV     &DDP,TOS        ;3 -- c-addr
            SUB     TOS,Y           ;1               Y=Word_Length
            MOV.B   Y,0(TOS)        ;3
            mNEXT                   ;4 -- c-addr     40 words      Z=1 <==> lenght=0 <==> EOL


;C FIND   c-addr -- c-addr 0   if not found ; flag Z=1
;C                  xt -1      if found     ; flag Z=0
;C                  xt  1      if immediate ; flag Z=0
; compare WORD at c-addr (HERE)  with each of words in each of listed vocabularies in CONTEXT
; FIND to WORDLOOP  : 14/20 cycles,
; mismatch word loop: 13 cycles on len, +8 cycles on first char,
;                     +10 cycles char loop,
; VOCLOOP           : 12/18 cycles,
; WORDFOUND to end  : 21 cycles.
; note: with 16 threads vocabularies, FIND takes about 75% of CORETEST.4th processing time

            FORTHWORD "FIND"
FIND        SUB     #2,PSP          ;1 -- ???? c-addr       reserve one cell here, not at FINDEND because interacts with flag Z
            MOV     TOS,S           ;1                      S=c-addr
            MOV.B   @S,rDOCON       ;2                      R5= string count
            MOV.B   #80h,rDODOES    ;2                      R4= immediate mask
            MOV     #CONTEXT,T      ;2               
VOCLOOP     MOV     @T+,TOS         ;2 -- ???? VOC_PFA      T=CTXT+2
            CMP     #0,TOS          ;1                      no more vocabulary in CONTEXT ?
            JZ      FINDEND         ;2 -- ???? 0            yes ==> exit; Z=1
    .SWITCH THREADS
    .CASE   1
    .ELSECASE                       ;                       search thread add 6cycles  5words
MAKETHREAD  MOV.B   1(S),Y          ;3 -- ???? VOC_PFA0     S=c-addr Y=CHAR0
            AND.B #(THREADS-1)*2,Y  ;2 -- ???? VOC_PFA0     Y=thread offset
            ADD     Y,TOS           ;1 -- ???? VOC_PFAx
    .ENDCASE
            ADD     #2,TOS          ;1 -- ???? VOC_PFA+2
WORDLOOP    MOV     -2(TOS),TOS     ;3 -- ???? [VOC_PFA]    [VOC_PFA] first, then [LFA]
            CMP     #0,TOS          ;1 -- ???? NFA          no more word in the thread ?
            JZ      VOCLOOP         ;2 -- ???? NFA          yes ==> search next voc in context
            MOV     TOS,X           ;1
            MOV.B   @X+,Y           ;2                      TOS=NFA,X=NFA+1,Y=NFA_char
            BIC.B   rDODOES,Y       ;1                      hide Immediate bit
LENCOMP     CMP.B   rDOCON,Y        ;1                      compare lenght
            JNZ     WORDLOOP        ;2 -- ???? NFA          13~ word loop on lenght mismatch
            MOV     S,W             ;1                      W=c-addr
CHARLOOP    ADD     #1,W            ;1
CHARCOMP    CMP.B   @X+,0(W)        ;4                      compare chars
            JNZ     WORDLOOP        ;2 -- ???? NFA          21~ word loop on first char mismatch
            SUB.B   #1,Y            ;1                      decr count
            JNZ     CHARLOOP        ;2 -- ???? NFA          10~ char loop
WORDFOUND   BIT     #1,X            ;1      
            ADDC    #0,X            ;1
            MOV     X,S             ;1                      S=aligned CFA
            MOV.B   @TOS,W          ;2 -- ???? NFA          W=NFA_first_char
            MOV     #1,TOS          ;1 -- ???? 1            preset immediate flag
            CMP.B   #0,W            ;1                      W is negative if immediate flag
            JN      FINDEND         ;2 -- ???? 1
            SUB     #2,TOS          ;1 -- ???? -1
FINDEND     MOV     S,0(PSP)        ;3 not found: -- c-addr 0                           flag Z=1
                                    ;      found: -- xt -1|+1 (not immediate|immediate) flag Z=0
            MOV     #xdocon,rDOCON  ;2
            MOV     #xdodoes,rDODOES;2
            mNEXT                   ;4 42/47 words



THREEDROP   ADD     #2,PSP
TWODROP     ADD     #2,PSP
            MOV     @PSP+,TOS
            mNEXT

;C  convert a string to double number until count = 0 or until not convertible char
;C >NUMBER  ud1lo|ud1hi addr1 count1 -- ud2lo|ud2hi addr2 count2

    .IFDEF MPY

            FORTHWORD ">NUMBER"     ; 23 cycles + 32/34 cycles DEC/HEX char loop 
TONUMBER    MOV     @PSP+,S         ;2                          S = adr
            MOV     @PSP+,Y         ;2                          Y = ud1hi
            MOV     @PSP,X          ;2                          X = ud1lo
            SUB     #4,PSP          ;1
            MOV     &BASE,T         ;3                          
TONUMLOOP   MOV.B   @S,W            ;2 -- ud1lo ud1hi adr count W=char
DDIGITQ     SUB.B   #30h,W          ;2                          skip all chars < '0'
            CMP.B   #10,W           ;2                          char was > "9" ?
            JLO     DDIGITQNEXT     ;2                          no
            SUB.B   #7,W            ;2                          skip all chars between "9" and "A"
DDIGITQNEXT CMP     T,W             ;1                          digit-base
            JHS     TONUMEND        ;2 -- ud1lo ud1hi adr count abort
            MOV     X,&MPY32L       ;3                          Load 1st operand (ud1lo)
            MOV     Y,&MPY32H       ;3                          Load 1st operand (ud1hi)
            MOV     T,&OP2          ;3                          Load 2nd operand with BASE
            MOV     &RES0,X         ;3                          lo result in X (ud2lo)
            MOV     &RES1,Y         ;3                          hi result in Y (ud2hi)
            ADD     W,X             ;1                          ud2lo + digit
            ADDC    #0,Y            ;1                          ud2hi + carry
            ADD     #1,S            ;1 -- ud1lo ud1hi adr count S=adr+1
            SUB     #1,TOS          ;1 -- ud1lo ud1hi adr count-1
            JNZ     TONUMLOOP       ;2                          if count <>0
            MOV     X,4(PSP)        ;3 -- ud2lo ud1hi adr count2
            MOV     Y,2(PSP)        ;3 -- ud2lo ud2hi adr count2
TONUMEND    MOV     S,0(PSP)        ;3 -- ud2lo ud2hi addr2 count2 
            mNEXT                   ;4 38 words


; convert a string to a signed number; FORTH 2012 prefixes $, %, # are recognized
; 32 bits numbers are recognized
; the decimal point is processed
;Z ?NUMBER  c-addr -- n -1      if convert ok ; flag Z=0
;Z          c-addr -- c-addr 0  if convert ko ; flag Z=1

;            FORTHWORD "?NUMBER"
QNUMBER     PUSH    #0              ;3 -- c-addr
            PUSH    IP              ;3
            MOV     &BASE,T         ;3          T=BASE
            PUSH    T               ;3          R-- sign IP base
; ----------------------------------;
; Added decimal point process       ;
; ----------------------------------;
            BIC     #UF1,SR         ;2          reset flag UF1 used here as Decimal Point flag
            MOV.B   @TOS,IP         ;2          IP = count of chars
            ADD     TOS,IP          ;1          IP = end address   
            MOV     TOS,S           ;1          S = ptr
            MOV.B   #'.',W          ;2          W = '.' = Decimal Point DP
SearchDP    CMP     S,IP            ;1          IP U< S ?
            JLO     SearchDPEND     ;2          
            CMP.B   @S+,W           ;2          DP found ?
            JNE     SearchDP        ;2          7~ loop by char 
DPfound     BIS     #UF1,SR         ;2          DP found: set flag UF1
DPrubLoop   MOV.B   @S+,-2(S)       ;4          rub out decimal point
            CMP     S,IP            ;1          and move left one all susbsequent chars
            JHS     DPrubLoop       ;2          7~ loop by char
            SUB.B   #1,0(TOS)       ;3          and decrement count of chars
SearchDPEND                         ;
; ----------------------------------;
            MOV     #0,X            ;1                      X=ud1lo
            MOV     #0,Y            ;1                      Y=ud1hi
            MOV     #QNUMNEXT,IP    ;2                      return from >NUMBER
            SUB     #8,PSP          ;1 -- x x x x c-addr
            MOV     TOS,6(PSP)      ;3 -- c-addr x x x c-addr
            MOV     TOS,S           ;1                      S=addrr
            MOV.B   @S+,TOS         ;2 -- c-addr x x x cnt 
            MOV.B   @S,W            ;2                      W=char
            CMP.B   #'-',W          ;2
            JHS     QSIGN           ;2                      speed up for not prefixed numbers
QHEXA       MOV     #16,T           ;2                      BASE = 16
            SUB.B   #'$',W          ;2                      = 0 ==> "$" : hex number ?
            JZ      PREFIXED        ;2
QBINARY     MOV     #2,T            ;1                      BASE = 2
            SUB.B   #1,W            ;1                      "%" - "$" - 1 = 0 ==> '%' : hex number ?
            JZ      PREFIXED        ;2
QDECIMAL    ADD     #8,T            ;1                      BASE = 10
            ADD.B   #2,W            ;1                      "#" - "%" + 2 = 0 ==> '#' : decimal number ?
            JNZ     TONUMLOOP       ;2                      then the conversion return will be ko
PREFIXED    ADD     #1,S            ;1                          addr+1 to skip prefix
            SUB     #1,TOS          ;1 -- c-addr x x x cnt-1
            MOV.B   @S,W            ;2                      W=2th char, S=adr
            CMP.B   #'-',W          ;2
QSIGN       JNZ     TONUMLOOP       ;15 + 32/34 cycles DEC/HEX char loop
QSIGNYES    ADD     #1,S            ;1                          addr+1 to skip "-"
            SUB     #1,TOS          ;1 -- c-addr x x x cnt-1
            MOV     #-1,4(RSP)      ;3                      R-- sign IP BASE 
            JMP     TONUMLOOP       ;15 + 32/34 cycles DEC/HEX char loop
; ----------------------------------;
QNUMNEXT    FORTHtoASM              ;  -- c-addr ud2lo ud2hi addr2 count2
            ADD     #2,PSP          ;1
            CMP     #0,TOS          ;1 -- c-addr ud2lo ud2hi cnt2  n=0 ? conversion is ok ?
            .word   0172Ch          ;4 -- c-addr ud2lo ud2hi sign  POPM S,IP,TOS; TOS = sign flag = {-1;0}
            MOV     S,&BASE         ;3
            JZ      QNUMOK          ;2 -- c-addr ud2lo ud2hi sign  conversion OK
QNUMKO      ADD     #4,PSP          ;1 -- c-addr sign
            AND     #0,TOS          ;1 -- c-addr ff         TOS=0 and Z=1 ==> conversion ko 
            mNEXT                   ;4

;; ----------------------------------;
;; process word conversion           ;
;; ----------------------------------;
;QNUMOK      ADD     #2,PSP          ; -- c-addr ud2lo sign
;            MOV     @PSP+,0(PSP)    ;4 -- |n| sign          note : PSP is incremented before write back !!!
;            XOR     #-1,TOS         ;1 -- |n| inv(sign)
;            JNZ     QNUMEND         ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
;QNEGATE     XOR     #-1,0(PSP)      ;3 -- n-1 ff            else TOS=0
;            ADD     #1,0(PSP)       ;3 -- n ff
;            XOR     #-1,TOS         ;1 -- n tf              TOS=-1 and Z=0 ==> conversion ok        
;QNUMEND     mNEXT                   ;4
;; ----------------------------------;
      
; ----------------------------------;
; Select word|double word conversion;  -- c-addr ud2lo ud2hi sign
; ----------------------------------;
QNUMOK      CMP     #0,0(PSP)       ;3      double number ?
            JNZ     PROCESSNUM2     ;2      process double numbers
            BIT     #UF1,SR         ;2      decimal point added ?
            JNZ     PROCESSNUM3     ;2      process double numbers
            CMP     #0,TOS          ;       test sign
            JZ      PROCESSNUM      ;       if unsigned number < 65536
            MOV     2(PSP),W        ;
            SUB     #1,W            ;
            CMP     #0,W            ;
            JL      PROCESSNUM2     ;       if number < -32768
; ----------------------------------;
; process word conversion           ;
; ----------------------------------;
PROCESSNUM  ADD     #2,PSP          ; -- c-addr ud2lo sign
            MOV     @PSP+,0(PSP)    ;4 -- |n| sign          note : PSP is incremented before write back !!!
            XOR     #-1,TOS         ;1 -- |n| inv(sign)
            JNZ     QNUMEND         ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
QNEGATE     XOR     #-1,0(PSP)      ;3 -- n-1 ff            else TOS=0
            ADD     #1,0(PSP)       ;3 -- n ff
            XOR     #-1,TOS         ;1 -- n tf              TOS=-1 and Z=0 ==> conversion ok        
QNUMEND     mNEXT                   ;4
; ----------------------------------;
; process double word conversion    ;
; ----------------------------------;
PROCESSNUM2 BIS     #UF1,SR         ;                       set UF1 flag (SR(9)), for LITERAL use
PROCESSNUM3 MOV     2(PSP),4(PSP)   ;  -- udlo udlo udhi sign
            MOV     @PSP+,0(PSP)    ;4 -- udlo udhi sign          note : PSP is incremented before write back !!!
            XOR     #-1,TOS         ;1 -- udlo udhi inv(sign)
            JNZ     QNUMEND         ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
Q2NEGATE    XOR     #-1,2(PSP)      ;3 -- dlo-1 dhi-1 ff
            XOR     #-1,0(PSP)      ;3 -- dlo-1 udhi ff
            ADD     #1,2(PSP)       ;3 -- dlo dhi-1 ff
            ADDC    #0,0(PSP)       ;3 -- dlo dhi ff
            XOR     #-1,TOS         ;1 -- dlo dhi tf        
QNUM2END    mNEXT                   ;4 105 words             TOS=-1 and Z=0 ==> conversion ok 
; ----------------------------------;

    .ELSE ; no hardware MPY

            FORTHWORD ">NUMBER"
TONUMBER    MOV     @PSP,S          ; -- ud1lo ud1hi adr count
            MOV.B   @S,S            ; -- ud1lo ud1hi adr count      S=char
DDIGITQ     SUB.B   #30h,S          ;2                          skip all chars < '0'
            CMP.B   #10,S           ;                               char was > "9" ?
            JLO     DDIGITQNEXT     ; -- ud1lo ud1hi adr count      no
            SUB.B   #07h,S          ;                                   S=digit
DDIGITQNEXT CMP     &BASE,S         ; -- ud1lo ud1hi adr count          digit-base
            JHS     TONUMEND        ; U>=
UDSTAR      .word   152Eh           ; -- ud1lo ud1hi adr count          PUSHM TOS,IP,S (2+1 push,TOS=Eh)
            SUB     #2,PSP          ; -- ud1lo ud1hi adr x count
            MOV     4(PSP),0(PSP)   ; -- ud1lo ud1hi adr ud1hi count
            MOV     &BASE,TOS       ; -- ud1lo ud1hi adr ud1hi u2=base
            MOV     #UMSTARNEXT1,IP ;
UMSTAR1     MOV     #UMSTAR,PC      ; ud1hi * base ; UMSTAR use S,T,W,X,Y
UMSTARNEXT1 FORTHtoASM              ; -- ud1lo ud1hi adr ud3lo ud3hi
            PUSH    @PSP            ;                                   r-- count ud3lo
            MOV     6(PSP),0(PSP)   ; -- ud1lo ud1hi adr ud1lo ud3hi
            MOV     &BASE,TOS       ; -- ud1lo ud1hi adr ud1lo u=base
            MOV     #UMSTARNEXT2,IP
UMSTAR2     MOV     #UMSTAR,PC      ; ud1lo * base ; UMSTAR use S,T,W,X,Y, and S is free for use
UMSTARNEXT2 FORTHtoASM              ; -- ud1lo ud1hi adr ud2lo ud2hi    r-- count IP digit ud3lo
            ADD     @RSP+,TOS       ; -- ud1lo ud1hi adr ud2lo ud2hi    r-- count IP digit       add ud3lo to ud2hi
MPLUS       ADD     @RSP+,0(PSP)    ; -- ud1lo ud1hi adr ud2lo ud2hi    Ud2lo + digit
            ADDC    #0,TOS          ; -- ud1lo ud1hi adr ud2lo ud2hi    ud2hi + carry
            MOV     @PSP,6(PSP)     ; -- ud2lo ud1hi adr ud2lo ud2hi
            MOV     TOS,4(PSP)      ; -- ud2lo ud2hi adr ud2lo ud2hi

            .word   171Dh           ; -- ud2lo ud2hi adr ud2lo count    POPM IP,TOS (1+1 pop,IP=D)
            ADD     #2,PSP          ; -- ud2lo ud2hi adr count
            ADD     #1,0(PSP)       ; -- ud2lo ud2hi adr+1 count
            SUB     #1,TOS          ; -- ud2lo ud2hi adr+1 count-1
            JNZ     TONUMBER
TONUMEND    mNEXT                   ; 52 words


; convert a string to a signed number
;Z ?NUMBER  c-addr -- n -1      if convert ok ; flag Z=0
;Z          c-addr -- c-addr 0  if convert ko ; flag Z=1
; FORTH 2012 prefixes $, %, # are recognized
;            FORTHWORD "?NUMBER"
QNUMBER     PUSH    #0              ;3 -- c-addr
            PUSH    IP              ;3
            PUSH    &BASE           ;3          R-- sign IP base 
; ----------------------------------;
; Added decimal point process       ;
; ----------------------------------;
            BIC     #UF1,SR         ;2          reset flag UF1 used here as decimal point flag
            MOV.B   @TOS,IP         ;2          IP = count of chars
            ADD     TOS,IP          ;1          IP = end address   
            MOV     TOS,S           ;1          S = ptr
            MOV.B   #'.',W          ;2          W = '.'
SearchDP    CMP     S,IP            ;1          IP U< S ?
            JLO     SearchDPEND     ;2          
            CMP.B   @S+,W           ;2          DP found ?
            JNE     SearchDP        ;2          7~ loop by char 
DPfound     BIS     #UF1,SR         ;2          DP found: set flag UF1
DPrubLoop   MOV.B   @S+,-2(S)       ;4          rub out decimal point
            CMP     S,IP            ;1          and move left one all susbsequent chars
            JHS     DPrubLoop       ;2          7~ loop by char
            SUB.B   #1,0(TOS)       ;3          and decrement count of chars
SearchDPEND
; ----------------------------------;
            MOV     #QNUMNEXT,IP    ;2              return from >NUMBER
            SUB     #8,PSP          ;1 -- x x x x c-addr
            MOV     TOS,6(PSP)      ;3 -- c-addr x x x c-addr
            MOV     #0,4(PSP)       ;3
            MOV     #0,2(PSP)       ;3 -- c-addr ud x c-addr
            MOV     TOS,W           ;1
            MOV.B   @W+,TOS         ;2 -- c-addr ud x count 
            MOV     W,0(PSP)        ;3 -- c-addr ud adr count 
            MOV.B   @W+,X           ;2                   X=char
            CMP.B   #'-',X          ;2
            JHS     QSIGN           ;2                   speed up for not prefixed numbers
QHEXA       SUB.B   #'$',X          ;2                   = 0 ==> "$" : hex number ?
            JNZ     QBINARY         ;2 -- c-addr ud adr count      other cases will cause error
            MOV     #16,&BASE       ;4
            JMP     PREFIXED        ;2
QBINARY     SUB.B   #1,X            ;1           "%" - "$" - 1 = 0 ==> '%' : hex number ?
            JNZ     QDECIMAL        ;2
            MOV     #2,&BASE        ;3
            JMP     PREFIXED        ;2
QDECIMAL    ADD.B   #2,X            ;1           "#" - "%" + 2 = 0 ==> '#' : decimal number ?
            JNZ     TONUMBER        ;2           that will perform a conversion error
            MOV     #10,&BASE       ;4
PREFIXED    MOV     W,0(PSP)        ;3
            SUB     #1,TOS          ;1 -- c-addr ud adr+1 count-1
            MOV.B   @W+,X           ;2                           X=2th char, W=adr
            CMP.B   #'-',X          ;2
QSIGN       JNZ     TONUMBER        ;2
            MOV     #-1,4(RSP)      ;3                           R-- sign IP BASE 
            MOV     W,0(PSP)        ;3
            SUB     #1,TOS          ;1 -- c-addr ud adr+1 count-1
            JMP     TONUMBER        ;2
; ----------------------------------;
QNUMNEXT    FORTHtoASM              ;  -- c-addr ud2lo ud2hi addr2 count2
            ADD     #2,PSP          ;1
            CMP     #0,TOS          ;1 -- c-addr ud2lo ud2hi cnt2  n=0 ? conversion is ok ?
            .word   0172Ch          ;4 -- c-addr ud2lo ud2hi sign  POPM S,IP,TOS; TOS = sign flag = {-1;0}
            MOV     S,&BASE         ;3
            JZ      QNUMOK          ;2 -- c-addr ud2lo ud2hi sign  conversion OK
QNUMKO      ADD     #4,PSP          ;1 -- c-addr sign
            AND     #0,TOS          ;1 -- c-addr ff         TOS=0 and Z=1 ==> conversion ko 
            mNEXT                   ;4

;; ----------------------------------;
;; process word conversion           ;
;; ----------------------------------;
;QNUMOK      ADD     #2,PSP          ; -- c-addr ud2lo sign
;            MOV     @PSP+,0(PSP)    ;4 -- |n| sign          note : PSP is incremented before write back !!!
;            XOR     #-1,TOS         ;1 -- |n| inv(sign)
;            JNZ     QNUMEND         ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
;QNEGATE     XOR     #-1,0(PSP)      ;3 -- n-1 ff            else TOS=0
;            ADD     #1,0(PSP)       ;3 -- n ff
;            XOR     #-1,TOS         ;1 -- n tf              TOS=-1 and Z=0 ==> conversion ok        
;QNUMEND     mNEXT                   ;4
;; ----------------------------------;
      
; ----------------------------------;
; Select word|double word conversion;  -- c-addr ud2lo ud2hi sign
; ----------------------------------;
QNUMOK      CMP     #0,0(PSP)       ;3      double number ?
            JNZ     PROCESSNUM2     ;2      process double numbers
            BIT     #UF1,SR         ;2      decimal point added ?
            JNZ     PROCESSNUM3     ;2      process double numbers
            CMP     #0,TOS          ;       test sign
            JZ      PROCESSNUM      ;       if unsigned number < 65536
            MOV     2(PSP),W        ;
            SUB     #1,W            ;
            CMP     #0,W            ;
            JL      PROCESSNUM2     ;       if number < -32768
; ----------------------------------;
; process word conversion           ;
; ----------------------------------;
PROCESSNUM  ADD     #2,PSP          ; -- c-addr ud2lo sign
            MOV     @PSP+,0(PSP)    ;4 -- |n| sign          note : PSP is incremented before write back !!!
            XOR     #-1,TOS         ;1 -- |n| inv(sign)
            JNZ     QNUMEND         ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
QNEGATE     XOR     #-1,0(PSP)      ;3 -- n-1 ff            else TOS=0
            ADD     #1,0(PSP)       ;3 -- n ff
            XOR     #-1,TOS         ;1 -- n tf              TOS=-1 and Z=0 ==> conversion ok        
QNUMEND     mNEXT                   ;4
; ----------------------------------;
; process double word conversion    ;
; ----------------------------------;
PROCESSNUM2 BIS     #UF1,SR          ;                       set UF1 flag (SR(9)), case of number > word
PROCESSNUM3 MOV     2(PSP),4(PSP)   ;  -- udlo udlo udhi sign
            MOV     @PSP+,0(PSP)    ;4 -- udlo udhi sign          note : PSP is incremented before write back !!!
            XOR     #-1,TOS         ;1 -- udlo udhi inv(sign)
            JNZ     QNUMEND         ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
Q2NEGATE    XOR     #-1,2(PSP)      ;3 -- dlo-1 dhi-1 ff
            XOR     #-1,0(PSP)      ;3 -- dlo-1 udhi ff
            ADD     #1,2(PSP)       ;3 -- dlo dhi-1 ff
            ADDC    #0,0(PSP)       ;3 -- dlo dhi ff
            XOR     #-1,TOS         ;1 -- dlo dhi tf        
QNUM2END    mNEXT                   ;4 105 words             TOS=-1 and Z=0 ==> conversion ok 
; ----------------------------------;

    .ENDIF ; MPY


;C EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
            FORTHWORD "EXECUTE"
EXECUTE     MOV     TOS,W       ; 1 put word address into W
            MOV     @PSP+,TOS   ; 2 fetch new TOS
            MOV     W,PC        ; 3 fetch code address into PC
                                ; 6 = ITC - 1

;C ,    x --           append cell to dict
            FORTHWORD ","
COMMA       MOV     &DDP,W      ;3
            ADD     #2,&DDP     ;3
            MOV     TOS,0(W)    ;3
            MOV     @PSP+,TOS   ;2
            mNEXT               ;4 15~

;C LITERAL  (n|d) --        append single or double numeric literal if compiling state
            FORTHWORDIMM "LITERAL"      ; immediate
LITERAL     CMP     #0,&STATE   ;3
            JZ      LITERALEND  ;2
            BIT     #UF1,SR      ;2
            JZ      LITERAL1    ;2
LITERAL2    MOV     &DDP,W      ;3 
            ADD     #4,&DDP     ;3
            MOV     #lit,0(W)   ;4
            MOV     @PSP+,2(W)  ;3
LITERAL1    MOV     &DDP,W      ;3
            ADD     #4,&DDP     ;3
            MOV     #lit,0(W)   ;4
            MOV     TOS,2(W)    ;3
            MOV     @PSP+,TOS   ;2
LITERALEND  mNEXT               ;4 24~

;C COUNT   c-addr1 -- adr len   counted->adr/len
            FORTHWORD "COUNT"
COUNT:      SUB     #2,PSP      ;1
            ADD     #1,TOS      ;1
            MOV     TOS,0(PSP)  ;3
            MOV.B   -1(TOS),TOS ;3
            mNEXT               ;4 15~

;C INTERPRET    i*x addr u -- j*x      interpret given buffer
; This is the common factor of EVALUATE and QUIT.
; ref. dpANS-6, 3.4 The Forth Text Interpreter

;            FORTHWORD "INTERPRET"       ; not used in FORTH 2012
INTERPRET   MOV     TOS,&SOURCE_LEN     ; -- addr u     buffer lentgh  ==> ticksource variable
            MOV     @PSP+,&SOURCE_ADR   ; -- u          buffer address ==> ticksource+2 variable
            MOV     @PSP+,TOS           ; --
            MOV     #0,&TOIN            ;
            mDOCOL                      ;
INTLOOP     .word   FBLANK,WORDD        ; -- c-addr     Z = End Of Line
            FORTHtoASM                  ;          
            MOV     #INTFINDNEXT,IP     ;2              ddefine INTFINDNEXT as FIND return
            JNZ     FIND                ;2              if EOL not reached
            MOV     @RSP+,IP            ; --
            MOV     @PSP+,TOS           ; --            else EOL is reached
            mNEXT                       ;               return to QUIT on EOL

INTFINDNEXT FORTHtoASM                  ; -- c-addr fl  Z = not found
            MOV     TOS,W               ;               W = flag =(-1|0|+1)  as (normal|not_found|immediate)
            MOV     @PSP+,TOS           ; -- c-addr     
            MOV     #INTQNUMNEXT,IP     ;2              define QNUMBER return
            JZ      QNUMBER             ;2 c-addr --    if not found search a number
            MOV     #INTLOOP,IP         ;2              define (EXECUTE | COMMA) return
            XOR     &STATE,W            ;3
            JZ      COMMA               ;2 c-addr --    if W xor STATE = 0 compile xt then loop back to INTLOOP
            JNZ     EXECUTE             ;2 c-addr --    if W xor STATE <> 0 execute then loop back to INTLOOP

INTQNUMNEXT FORTHtoASM                  ;  -- n|c-addr fl Z = not a number
            MOV     @PSP+,TOS           ;2
            MOV     #INTLOOP,IP         ;2 -- n|c-addr  define LITERAL return
            JNZ     LITERAL             ;2 n --         execute LITERAL then loop back to INTLOOP
NotFoundExe ADD.B   #1,0(TOS)           ;3 c-addr --    Not a Number : incr string count to add '?'
            MOV.B   @TOS,Y              ;2
            ADD     TOS,Y               ;1
            MOV.B   #'?',0(Y)           ;5              add '?' to end of word
            MOV     #FQABORTYES,IP      ;2              define COUNT return
            JMP     COUNT               ;2 c-addr --    44 words

; EVALUATE          \ i*x c-addr u -- j*x  interpret string
            FORTHWORD "EVALUATE"
EVALUATE    MOV     #SOURCE_LEN,X
            PUSH    @X+
            PUSH    @X+
            PUSH    @X+
            PUSH    IP
            ASMtoFORTH
            .word   INTERPRET
            FORTHtoASM
            MOV     @RSP+,IP            ;2
            MOV     @RSP+,&TOIN         ;4
            MOV     @RSP+,&SOURCE_ADR   ;4
            MOV     @RSP+,&SOURCE_LEN   ;4
            mNEXT

;c QUIT  --     interpret line by line the input stream
            FORTHWORD "QUIT"
QUIT        MOV     #RSTACK,RSP
            MOV     #LSTACK,&LEAVEPTR
            MOV     #0,&STATE

            MOV #0,&SAVE_SYSRSTIV   ;

QUIT0            ASMtoFORTH
QUIT1       .word   XSQUOTE
            .byte   4,13,"ok "           ; CR + system prompt
QUIT2       .word   TYPE
QUIT3       .word   lit,TIB,DUP,lit,TIB_SIZE    ; -- StringOrg StringOrg len
            .word   ACCEPT                      ; -- StringOrg len'
            .word   SPACE
QUIT4       .word   INTERPRET
            .word   lit,PSTACK-2,SPFETCH,ULESS
            .word   XSQUOTE
            .byte   13,"stack empty !"
            .word   QABORT
            .word   lit,FRAM_FULL,HERE,ULESS
            .word   XSQUOTE
            .byte   11,"FRAM full !"
            .word   QABORT
            .word   FSTATE,FETCH
            .word   QBRAN,QUIT1         ; case of interpretion state
            .word   XSQUOTE             ; case of compilation state
            .byte   4,13,"   "          ; CR + 3 spaces
            .word   BRAN,QUIT2

;C ABORT    i*x --   R: j*x --   clear stack & QUIT
            FORTHWORD "ABORT"
ABORT:      MOV     #PSTACK,PSP
            JMP     QUIT

RefillUSBtime .equ int(frequency*2730) ; 2730*frequency ==> word size max value @ 24 MHz

;Z ?ABORT   f c-addr u --      abort & print msg
;            FORTHWORD "?ABORT"
QABORT      CMP #0,2(PSP)           ; -- f c-addr u         flag test
QABORTNO    JZ THREEDROP

QABORTYES   MOV #4882h,&YEMIT       ; restore default YEMIT = set ECHO
    .IFDEF SD_CARD_LOADER           ; close all handles
    MOV     &CurrentHdl,T
QABORTCLOSE
    CMP     #0,T
    JZ      QABORTYESNOECHO
    MOV.B   #0,HDLB_Token(T)
    MOV     @T,T
    JMP     QABORTCLOSE
    .ENDIF
                                    ; -- c-addr u 
; ----------------------------------;
QABORTYESNOECHO                     ; <== WARM jumps here, thus, if NOECHO, TERMINAL can be disconnected without freezing the app
; ----------------------------------;
            CALL #QAB_DEFER         ; restore default deferred words ....else WARM.
    .IFDEF MSP430ASSEMBLER          ; reset all branch labels
            MOV #0,&CLRBW1
            MOV #0,&CLRBW2
            MOV #0,&CLRBW3
            MOV #0,&CLRFW1
            MOV #0,&CLRFW2
            MOV #0,&CLRFW3
    .ENDIF


; ----------------------------------;
QABORTTERM                          ; wait the end of source file downloading
; ----------------------------------;
    .IFDEF TERMINALXONXOFF          ;
            BIT #UCTXIFG,&TERMIFG   ; TX buffer empty ?
            JZ QABORTTERM           ; no
            MOV #17,&TERMTXBUF      ; yes move XON char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINALCTSRTS           ;
        BIC.B   #RTS,&HANDSHAKOUT   ; set /RTS low (connected to /CTS pin of UARTtoUSB bridge)
    .ENDIF                          ;
QABORTLOOP  BIC #UCRXIFG,&TERMIFG   ; reset TERMIFG(UCRXIFG)
            MOV #RefillUSBtime,Y    ; 2730*28 = 75 ms
QABUSBLOOPJ                         ; 28~ loop : PL2303TA seems the slower USB device to refill its buffer.
            MOV #8,X                ; 1~
QABUSBLOOPI                         ; 3~ loop
            SUB #1,X                ; 1~
            JNZ QABUSBLOOPI         ; 2~
            SUB #1,Y                ; 1~
            JNZ QABUSBLOOPJ         ; 2~
            BIT #UCRXIFG,&TERMIFG   ; 4 new char in TERMXBUF ?
            JNZ QABORTLOOP          ; 2 yes, the input stream (download source file) is still active

; ----------------------------------;
; Display WARM/ABORT message        ;
; ----------------------------------;
            mDOCOL                  ;   no, the input stream is quiet (end of download source file)
            .word   XSQUOTE         ; -- c-addr u c-addr1 u1
            .byte   4,1Bh,"[7m"     ;            
            .word   TYPE            ; -- c-addr u       set reverse video
            .word   TYPE            ; --                type abort message
            .word   XSQUOTE         ; -- c-addr2 u2
            .byte   4,1Bh,"[0m"     ;
            .word   TYPE            ; --                set normal video
            .word   FORTH,ONLY      ; to quit assembler and so to abort any ASSEMBLER definitions
            .word   DEFINITIONS     ; reset CURRENT directory
    .IFDEF LOWERCASE
            .word   CAPS_ON         ;
    .ENDIF
            .word   ABORT           ;

    .IFDEF LOWERCASE

;C ABORT"  i*x flag -- i*x   R: j*x -- j*x  flag=0
;C         i*x flag --       R: j*x --      flag<>0
            FORTHWORDIMM "ABORT\34"        ; immediate
ABORTQUOTE  mDOCOL
            .word   CAPS_OFF,SQUOTE,CAPS_ON
            .word   lit,QABORT,COMMA
            .word   EXIT 

    .ELSE

;C ABORT"  i*x flag -- i*x   R: j*x -- j*x  flag=0
;C         i*x flag --       R: j*x --      flag<>0
            FORTHWORDIMM "ABORT\34"        ; immediate
ABORTQUOTE  mDOCOL
            .word   SQUOTE
            .word   lit,QABORT,COMMA
            .word   EXIT 

    .ENDIF ; LOWERCASE


;C '    -- xt           find word in dictionary
            FORTHWORD "'"
TICK        mDOCOL          ; separator -- xt
            .word   FBLANK,WORDD,FIND    ; Z=1 if not found
            .word   QBRAN,NotFound
            .word   EXIT
NotFound    .word   NotFoundExe          ; in INTERPRET

; \         --      backslash
; everything up to the end of the current line is a comment.
            FORTHWORDIMM "\\"      ; immediate
BACKSLASH   MOV     &SOURCE_LEN,&TOIN   ;
            mNEXT

; ----------------------------------------------------------------------
; COMPILER
; ----------------------------------------------------------------------

; HEADER        create an header for a new word. Max count of chars = 126
;               common code for VARIABLE, CONSTANT, CREATE, DEFER, :, CODE, ASM.
;               don't link created word in vocabulary.

HEADER      mDOCOL
            .word CELLPLUSALIGN ;               ALIGN then make room for LFA
            .word FBLANK,WORDD  ;
            FORTHtoASM          ; -- HERE       HERE is the NFA of this new word
            MOV TOS,Y           ;
            MOV.B @TOS+,W       ; -- xxx        W=Count_of_chars    Y=NFA
            BIS.B #1,W          ; -- xxx        W=count is always odd
            ADD.B #1,W          ; -- xxx        W=add one byte for length
            ADD Y,W             ; -- xxx        W=Aligned_CFA
            MOV &CURRENT,X      ; -- xxx        X=VOC_BODY of CURRENT    Y=NFA
    .SWITCH THREADS
    .CASE   1                       ;               nothing to do
    .ELSECASE                       ;               multithreading add 5~ 4words
            MOV.B   @TOS,TOS        ; -- xxx        TOS=first CHAR of new word
            AND #(THREADS-1)*2,TOS  ; -- xxx        TOS= Thread offset
            ADD     TOS,X           ; -- xxx        TOS= Thread   X=VOC_PFAx = thread x of VOC_PFA of CURRENT
    .ENDCASE
            MOV     Y,&LAST_NFA     ; -- xxx        NFA --> LAST_NFA            used by QREVEAL, IMMEDIATE
            MOV     X,&LAST_THREAD  ; -- xxx        VOC_PFAx --> LAST_THREAD    used by QREVEAL
            MOV     W,&LAST_CFA     ; -- xxx        HERE=CFA --> LAST_CFA       used by DOES>, RECURSE
            ADD     #4,W            ; -- xxx        by default make room for two words...
            MOV     W,&DDP          ; -- xxx
            MOV     @PSP+,TOS       ; --
            MOV     @RSP+,IP
            MOV     @RSP+,PC        ; 23 words, W is the new DDP value )
                                    ;           X is LAST_THREAD       > used by VARIABLE, CONSTANT, CREATE, DEFER and :
                                    ;           Y is NFA               )

BAD_CSP     mDOCOL
            .word   XSQUOTE
            .byte   15,"stack mismatch!"
FQABORTYES  .word   QABORTYES

;;Z ?REVEAL   --      link last created word in vocabulary if no stack mismatch
;            FORTHWORD "REVEAL"
QREVEAL     CMP     PSP,&LAST_CSP   ; check actual SP with saved value by :
            JNZ     BAD_CSP         ; if stack mismatch
            MOV     &LAST_NFA,Y     ;
            MOV     &LAST_THREAD,X  ;
REVEAL      MOV     @X,-2(Y)        ; [LAST_THREAD] --> LFA
            MOV     Y,0(X)          ; LAST_NFA --> [LAST_THREAD]
            mNEXT


;C VARIABLE <name>       --                      define a Forth VARIABLE
            FORTHWORD "VARIABLE"
VARIABLE    CALL    #HEADER      ; --        W = DDP = CFA + 2 words
            MOV     #DOVAR,-4(W)
            JMP     REVEAL

;C CONSTANT <name>     n --                      define a Forth CONSTANT
            FORTHWORD "CONSTANT"
CONSTANT    CALL    #HEADER      ; --        W = DDP
            MOV     #DOCON,-4(W)           ; compile exec
            MOV     TOS,-2(W)              ; compile TOS as constant
            MOV     @PSP+,TOS
            JMP     REVEAL

;C CREATE <name>        --                      define a CONSTANT with its next address
; Execution: ( -- a-addr )          ; a-addr is the address of name's data field
;                                   ; the execution semantics of name may be extended by using DOES>
            FORTHWORD "CREATE"
CREATE      CALL    #HEADER         ; --        W = DDP
            MOV     #DOCON,-4(W)    ;4 first CELL = DOCON
            MOV     W,-2(W)         ;3 second CELL = HERE
            JMP     REVEAL

;C DOES>    --          set action for the latest CREATEd definition
            FORTHWORD "DOES>"
DOES        MOV     &LAST_CFA,W     ; W = CFA of latest CREATEd word that becomes a master word
            MOV     #DODOES,0(W)    ; remplace code of CFA (DOCON) by DODOES
            MOV     IP,2(W)         ; remplace parameter of PFA (HERE) by the address after DOES> as execution address
            MOV     @RSP+,IP        ; exit of the new created word
NEXTADR     mNEXT

;X DEFER <name>   --                ; create a word to be deferred
            FORTHWORD "DEFER"
            CALL    #HEADER
            MOV     #4030h,-4(W)    ;4 first CELL = MOV @PC+,PC = BR...
            MOV     #NEXTADR,-2(W)  ;4 second CELL = address of mNEXT below : created word does nothing by default
            JMP     REVEAL

;C [        --      enter interpretative state
                FORTHWORDIMM "["    ; immediate
LEFTBRACKET     MOV     #0,&STATE
                mNEXT

;C ]        --      enter compiling state
                FORTHWORD "]"
RIGHTBRACKET    MOV     #-1,&STATE
                mNEXT

;C RECURSE  --      recurse to current definition (compile current definition)
            FORTHWORDIMM "RECURSE"  ; immediate
RECURSE     MOV     &DDP,X          ;
            MOV     &LAST_CFA,0(X)  ;
            ADD     #2,&DDP         ;
            mNEXT

    .SWITCH DTC
    .CASE 1

;C : <name>     --      begin a colon definition
            FORTHWORD ":"
            CALL    #HEADER
            MOV     #DOCOL1,-4(W)   ; compile CALL rDOCOL
            SUB     #2,&DDP

    .CASE 2

;C : <name>     --      begin a colon definition
            FORTHWORD ":"
            CALL    #HEADER
            MOV     #DOCOL1,-4(W)   ; compile PUSH IP       3~
            MOV     #DOCOL2,-2(W)   ; compile CALL rEXIT

    .CASE 3 ; inlined DOCOL

;C : <name>     --      begin a colon definition
            FORTHWORD ":"
            CALL    #HEADER       
            MOV     #DOCOL1,-4(W)   ; compile PUSH IP       3~
            MOV     #DOCOL2,-2(W)   ; compile MOV PC,IP     1~
            MOV     #DOCOL3,0(W)    ; compile ADD #4,IP     1~
            MOV     #NEXT,+2(W)     ; compile MOV @IP+,PC   4~
            ADD     #4,&DDP

    .ENDCASE ; DTC

            MOV     #-1,&STATE      ; enter compiling state
SAVE_PSP    MOV     PSP,&LAST_CSP   ; save PSP for check compiling, used by QREVEAL
            mNEXT

;C ;            --      end a colon definition
            FORTHWORDIMM ";"        ; immediate
SEMICOLON   CMP     #0,&STATE       ; interpret mode : semicolon becomes a comment separator
            JZ      BACKSLASH       ; tip: ; it's transparent to the preprocessor, so semicolon comments are kept in file.4th
            mDOCOL                  ; compile mode
            .word   lit,EXIT,COMMA
            .word   QREVEAL,LEFTBRACKET,EXIT

;C IMMEDIATE        --   make last definition immediate
            FORTHWORD "IMMEDIATE"
IMMEDIATE   MOV     &LAST_NFA,W
            BIS.B   #80h,0(W)
            mNEXT

;X DEFER!       xt CFA_DEFER --     ; store xt to the address after DODEFER
DEFERSTORE  MOV     @PSP+,2(TOS)    ; -- CFA_DEFER          xt --> [CFA_DEFER+2]
            MOV     @PSP+,TOS       ; --
            mNEXT

;X IS <name>        xt --
; used as is :
; DEFER DISPLAY                         create a "do nothing" definition (2 CELLS) 
; inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
; or in a definition : ... ['] U. IS DISPLAY ...
; KEY, EMIT, CR, ACCEPT and WARM are DEFERred words

            FORTHWORDIMM "IS"       ; immediate
IS          mDOCOL
            .word   FSTATE,FETCH
            .word   QBRAN,IS_EXEC
IS_COMPILE  .word   BRACTICK             ; find the word, compile its CFA as literal  
            .word   lit,DEFERSTORE,COMMA ; compile DEFERSTORE
            .word   EXIT
IS_EXEC     .word   TICK,DEFERSTORE     ; find the word, leave its CFA on the stack and execute DEFERSTORE
            .word   EXIT

;C ['] <name>        --         find word & compile it as literal
            FORTHWORDIMM "[']"      ; immediate word, i.e. word executed also during compilation
BRACTICK    mDOCOL
            .word   TICK            ; get xt of <name>
            .word   lit,lit,COMMA   ; append LIT action
            .word   COMMA,EXIT      ; append xt literal

            FORTHWORDIMM "POSTPONE" ; immediate
POSTPONE    mDOCOL
            .word   FBLANK,WORDD,FIND,QDUP
            .word   QBRAN,NotFound
            .word   ZEROLESS        ; immediate ?
            .word   QBRAN,POST1     ; yes
            .word   lit,lit,COMMA,COMMA
            .word   lit,COMMA
POST1:      .word   COMMA,EXIT

;; CORE EXT  MARKER
;;( "<spaces>name" -- )
;;Skip leading space delimiters. Parse name delimited by a space. Create a definition for name
;;with the execution semantics defined below.

;;name Execution: ( -- )
;;Restore all dictionary allocation and search order pointers to the state they had just prior to the
;;definition of name. Remove the definition of name and all subsequent definitions. Restoration
;;of any structures still existing that could refer to deleted definitions or deallocated data space is
;;not necessarily provided. No other contextual information such as numeric base is affected

;            FORTHWORD "MARKER"
;            CALL    #HEADER             ;4
;            MOV     #DODOES,-4(W)       ;4 CFA = DODOES
;            MOV     #MARKER_DOES,-2(W)  ;4 PFA = MARKER_DOES
;            ADD     #4,&DDP             ;3
;            MOV     &LASTVOC,0(W)       ;5 [BODY] = VOCLINK to be restored
;            MOV     Y,2(W)              ;3 [BODY+2] = NFA
;            SUB     #2,2(W)             ;4 [BODY+2] = LFA = DP to be restored
;            JMP     REVEAL              ;2

MARKER_DOES
    .IFDEF VOCABULARY_SET
            .word   FORTH,ONLY,DEFINITIONS
    .ENDIF
            FORTHtoASM              ; -- BODY       IP is free
            MOV     @TOS+,W         ; -- BODY+2     W= old VOCLINK =VLK
            MOV     W,&LASTVOC      ; -- BODY+2     restore LASTVOC
            MOV     @TOS,TOS        ; -- OLD_DP
            MOV     TOS,&DDP        ; -- OLD_DP     restore DP

    .SWITCH THREADS

    .CASE   1
MARKALLVOC  MOV     W,Y             ; -- OLD_DP      W=VLK   Y=VLK
MRKWORDLOOP MOV     -2(Y),Y         ; -- OLD_DP      W=VLK   Y=NFA
            CMP     Y,TOS           ; -- OLD_DP      CMP = TOS-Y : OLD_DP-NFA
            JNC     MRKWORDLOOP     ;                loop back if TOS<Y : OLD_DP<NFA
            MOV     Y,-2(W)         ;                W=VLK   X=THD   Y=NFA   refresh thread with good NFA
            MOV     @W,W            ; -- OLD_DP      W=[VLK] = next voclink
            CMP     #0,W            ; -- OLD_DP      W=[VLK] = next voclink   end of vocs ?
            JNZ     MARKALLVOC      ; -- OLD_DP      W=VLK                   no : loopback

    .ELSECASE ; multi threads 

MARKALLVOC  MOV     #THREADS,IP     ; -- OLD_DP      W=VLK
            MOV     W,X             ; -- OLD_DP      W=VLK   X=VLK
MRKTHRDLOOP MOV     X,Y             ; -- OLD_DP      W=VLK   X=VLK   Y=VLK
            SUB     #2,X            ; -- OLD_DP      W=VLK   X=THD (thread ((case-2)to0))
MRKWORDLOOP MOV     -2(Y),Y         ; -- OLD_DP      W=VLK   Y=NFA
            CMP     Y,TOS           ; -- OLD_DP      CMP = TOS-Y : OLD_DP-NFA
            JNC     MRKWORDLOOP     ;               loop back if TOS<Y : OLD_DP<NFA
MARKTHREAD  MOV     Y,0(X)          ;               W=VLK   X=THD   Y=NFA   refresh thread with good NFA
            SUB     #1,IP           ; -- OLD_DP      W=VLK   X=THD   Y=NFA   IP=CFT-1
            JNZ     MRKTHRDLOOP     ;                       loopback to compare NFA in next thread (thread-1)
            MOV     @W,W            ; -- OLD_DP      W=[VLK] = next voclink
            CMP     #0,W            ; -- OLD_DP      W=[VLK] = next voclink   end of vocs ?
            JNZ     MARKALLVOC      ; -- OLD_DP      W=VLK                   no : loopback

    .ENDCASE ; THREADS              ; -- HERE

            MOV     @PSP+,TOS       ;
            MOV     @RSP+,IP        ;
            mNEXT                   ;
; ----------------------------------;

; ----------------------------------------------------------------------
; CONTROL STRUCTURES
; ----------------------------------------------------------------------
; THEN and BEGIN compile nothing
; DO compile one word
; IF, ELSE, AGAIN, UNTIL, WHILE, REPEAT, LOOP & +LOOP compile two words
; LEAVE compile three words

;C IF       -- IFadr    initialize conditional forward branch
            FORTHWORDIMM "IF"       ; immediate
IFF         SUB     #2,PSP          ;
            MOV     TOS,0(PSP)      ;
            MOV     &DDP,TOS        ; -- HERE
            MOV     #QBRAN,0(TOS)   ; -- HERE
            ADD     #4,&DDP         ; compile two words
CELLPLUS    ADD     #2,TOS          ; -- HERE+2=IFadr
            mNEXT

;C ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
            FORTHWORDIMM "ELSE"     ; immediate
ELSS        MOV     &DDP,W
            MOV     #bran,0(W)
            ADD     #4,W            ; W=HERE+4
            MOV     W,&DDP          ; compile two words
            MOV     W,0(TOS)        ; HERE+4 ==> [IFadr]
            SUB     #2,W            ; HERE+2
            MOV     W,TOS           ; -- ELSEadr
            mNEXT

;C THEN     IFadr --                resolve forward branch
            FORTHWORDIMM "THEN"     ; immediate
THEN        MOV     &DDP,0(TOS)     ; -- IFadr
            MOV     @PSP+,TOS       ; --
            mNEXT

;C BEGIN    -- BEGINadr             initialize backward branch
            FORTHWORDIMM "BEGIN"    ; immediate
BEGIN       MOV     #HERE,PC        ; BR HERE

;C UNTIL    BEGINadr --             resolve conditional backward branch
            FORTHWORDIMM "UNTIL"    ; immediate
UNTIL       MOV     #qbran,X
UNTIL1      MOV     &DDP,W          ; W = HERE
            ADD     #4,&DDP         ; compile two words
            MOV     X,0(W)          ; compile Bran or qbran at HERE
            MOV     TOS,2(W)        ; compile bakcward adr at HERE+2
            MOV     @PSP+,TOS
            mNEXT

;X AGAIN    BEGINadr --             resolve uncondionnal backward branch
            FORTHWORDIMM "AGAIN"    ; immediate
AGAIN       MOV     #bran,X
            JMP     UNTIL1

;C WHILE    BEGINadr -- WHILEadr BEGINadr
            FORTHWORDIMM "WHILE"    ; immediate
WHILE       mDOCOL
            .word   IFF,SWAP,EXIT

;C REPEAT   WHILEadr BEGINadr --     resolve WHILE loop
            FORTHWORDIMM "REPEAT"   ; immediate
REPEAT      mDOCOL
            .word   AGAIN,THEN,EXIT

;C DO       -- DOadr   L: -- 0
            FORTHWORDIMM "DO"       ; immediate
DO          SUB     #2,PSP          ;
            MOV     TOS,0(PSP)      ;
            MOV     &DDP,TOS        ; -- HERE
            MOV     #xdo,0(TOS)
            ADD     #2,TOS          ; -- HERE+2
            MOV     TOS,&DDP        ; compile one word
            ADD     #2,&LEAVEPTR    ; -- HERE+2     LEAVEPTR+2
            MOV     &LEAVEPTR,W     ;               
            MOV     #0,0(W)         ; -- HERE+2     L-- 0
            mNEXT

;C LOOP    DOadr --         L-- 0 a1 a2 .. aN
            FORTHWORDIMM "LOOP"     ; immediate
LOO         MOV     #xloop,X
ENDLOOP     MOV     &DDP,W
            ADD     #4,&DDP         ; compile two words
            MOV     X,0(W)          ; xloop --> HERE
            MOV     TOS,2(W)        ; DOadr --> HERE+2
; resolve all "leave" adr
LEAVELOOP   MOV     &LEAVEPTR,TOS   ; -- Adr of first LeaveStack cell
            SUB     #2,&LEAVEPTR    ; -- 
            MOV     @TOS,TOS        ; -- first LeaveStack value
            CMP     #0,TOS          ; -- = value left by DO ?
            JZ      ENDLOOPEND
            MOV     &DDP,0(TOS)     ; move adr after loop as UNLOOP adr
            JMP     LEAVELOOP
ENDLOOPEND  MOV     @PSP+,TOS
            mNEXT

;C +LOOP   adrs --   L: 0 a1 a2 .. aN --
            FORTHWORDIMM "+LOOP"    ; immediate
PLUSLOOP    MOV     #xploop,X
            JMP     ENDLOOP

;C LEAVE    --    L: -- adrs
            FORTHWORDIMM "LEAVE"    ; immediate
LEAV        MOV     &DDP,W          ; compile three words
            MOV     #UNLOOP,0(W)    ; [HERE] = UNLOOP
            MOV     #BRAN,2(W)      ; [HERE+2] = BRAN
            ADD     #6,&DDP         ; [HERE+4] = take word for AfterLOOPadr
            ADD     #2,&LEAVEPTR
            ADD     #4,W
            MOV     &LEAVEPTR,X
            MOV     W,0(X)          ; leave HERE+4 on LEAVEPTR stack
            mNEXT

;C MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
            FORTHWORD "MOVE"
MOVE        MOV     TOS,W       ; 1
            MOV     @PSP+,Y     ; dest adrs
            MOV     @PSP+,X     ; src adrs
            MOV     @PSP+,TOS   ; pop new TOS
            CMP     #0,W
            JZ      MOVE_X
            CMP     X,Y         ; Y-X ; dst - src
            JZ      MOVE_X      ; already made !
            JC      MOVEUP      ; U>= if dst > src
MOVEDOWN:   MOV.B   @X+,0(Y)    ; if X=src > Y=dst copy W bytes down
            ADD     #1,Y
            SUB     #1,W
            JNZ     MOVEDOWN
            mNEXT
MOVEUP      ADD     W,Y         ; start at end
            ADD     W,X
MOVUP1:     SUB     #1,X
            SUB     #1,Y
            MOV.B   @X,0(Y)     ; if X=src < Y=dst copy W bytes up
            SUB     #1,W
            JNZ     MOVUP1
MOVE_X:     mNEXT


; ----------------------------------------------------------------------
; WORDS SET for VOCABULARY, not ANS compliant
; ----------------------------------------------------------------------

;X VOCABULARY       -- create a vocabulary

    .IFDEF VOCABULARY_SET

            FORTHWORD "VOCABULARY"
VOCABULARY  mDOCOL
            .word   CREATE
    .SWITCH THREADS
    .CASE   1
            .word   lit,0,COMMA             ; will keep the NFA of the last word of the future created vocabularies
    .ELSECASE                               ; multithreading add 7 words
            .word   lit,THREADS,lit,0,xdo
VOCABULOOP  .word   lit,0,COMMA
            .word   xloop,VOCABULOOP
    .ENDCASE
            .word   HERE                    ; link via LASTVOC the future created vocabularies
            .word   LIT,LASTVOC,DUP
            .word   FETCH,COMMA             ; compile [LASTVOC] to HERE+
            .word   STORE                   ; store (HERE - CELL) to LASTVOC
            .word   DOES                    ; compile CFA and PFA for the future defined vocabulary

    .ENDIF ; VOCABULARY_SET

VOCDOES     .word   LIT,CONTEXT,STORE
            .word   EXIT

;X  FORTH    --                         ; set FORTH the first context vocabulary; FORTH is and must be the first vocabulary
    .IFDEF VOCABULARY_SET
            FORTHWORD "FORTH"
    .ENDIF ; VOCABULARY_SET
FORTH       mDODOES                     ; leave FORTH_BODY on the stack and run VOCDOES
            .word   VOCDOES
FORTH_BODY  .word   lastforthword
    .SWITCH THREADS
    .CASE   2
            .word   lastforthword1
    .CASE   4
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
    .CASE   8
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
            .word   lastforthword4
            .word   lastforthword5
            .word   lastforthword6
            .word   lastforthword7
    .CASE   16
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
            .word   lastforthword4
            .word   lastforthword5
            .word   lastforthword6
            .word   lastforthword7
            .word   lastforthword8
            .word   lastforthword9
            .word   lastforthword10
            .word   lastforthword11
            .word   lastforthword12
            .word   lastforthword13
            .word   lastforthword14
            .word   lastforthword15
    .CASE   32
            .word   lastforthword1
            .word   lastforthword2
            .word   lastforthword3
            .word   lastforthword4
            .word   lastforthword5
            .word   lastforthword6
            .word   lastforthword7
            .word   lastforthword8
            .word   lastforthword9
            .word   lastforthword10
            .word   lastforthword11
            .word   lastforthword12
            .word   lastforthword13
            .word   lastforthword14
            .word   lastforthword15
            .word   lastforthword16
            .word   lastforthword17
            .word   lastforthword18
            .word   lastforthword19
            .word   lastforthword20
            .word   lastforthword21
            .word   lastforthword22
            .word   lastforthword23
            .word   lastforthword24
            .word   lastforthword25
            .word   lastforthword26
            .word   lastforthword27
            .word   lastforthword28
            .word   lastforthword29
            .word   lastforthword30
            .word   lastforthword31

    .ELSECASE
    .ENDCASE
            .word   voclink
voclink     .set    $-2

;X  ALSO    --                  make room to put a vocabulary as first in context
    .IFDEF VOCABULARY_SET
            FORTHWORD "ALSO"
    .ENDIF ; VOCABULARY_SET
ALSO        MOV     #12,W           ; -- move up 6 words
            MOV     #CONTEXT,X      ; X=src
            MOV     #CONTEXT+2,Y    ; Y=dst
            JMP     MOVEUP          ; src < dst

;X  PREVIOUS   --               pop last vocabulary out of context
    .IFDEF VOCABULARY_SET
            FORTHWORD "PREVIOUS"
    .ENDIF ; VOCABULARY_SET
PREVIOUS    MOV     #14,W           ; -- move down 7 words
            MOV     #CONTEXT+2,X    ; X=src
            MOV     #CONTEXT,Y      ; Y=dst
            JMP     MOVEDOWN        ; src > dst

;X ONLY     --      cut context list to access only first vocabulary, ex.: FORTH ONLY
    .IFDEF VOCABULARY_SET
            FORTHWORD "ONLY"
    .ENDIF ; VOCABULARY_SET
ONLY        MOV     #0,&CONTEXT+2
            mNEXT

;X DEFINITIONS  --      set last context vocabulary as entry for further defining words
    .IFDEF VOCABULARY_SET
            FORTHWORD "DEFINITIONS"
    .ENDIF ; VOCABULARY_SET
DEFINITIONS MOV     &CONTEXT,&CURRENT
            mNEXT

; ----------------------------------------------------------------------
; IMPROVED POWER ON RESET AND INITIALIZATION
; ----------------------------------------------------------------------

            FORTHWORD "PWR_STATE"   ; set dictionary in same state as OFF/ON
PWR_STATE   mDODOES                 ; DOES part of MARKER : resets pointers DP, voclink and latest
            .word   MARKER_DOES     ; execution vector of MARKER DOES
MARKVOC     .word   lastvoclink     ; as voclink value
MARKDP      .word   ROMDICT         ; as DP value

            FORTHWORD "PWR_HERE"    ; define dictionary bound for PWR_STATE
PWR_HERE    MOV     &DDP,&MARKDP
            MOV     &LASTVOC,&MARKVOC
            JMP     PWR_STATE

            FORTHWORD "RST_STATE"   ; set dictionary in same state as <reset>
RST_STATE   MOV     &INIDP,&MARKDP
            MOV     &INIVOC,&MARKVOC 
            JMP     PWR_STATE

            FORTHWORD "RST_HERE"    ; define dictionary bound for RST_STATE
RST_HERE    MOV     &DDP,&INIDP
            MOV     &LASTVOC,&INIVOC
            JMP     PWR_HERE        ; and reset PWR_STATE same as RST_STATE


WIPE_DEFER  MOV #PARENWARM,&WARM+2
QAB_DEFER   MOV #PARENEMIT,&EMIT+2   ; always restore default console output
            MOV #PARENCR,&CR+2       ; and CR to CR EMIT
            MOV #PARENKEY,&KEY+2
    .IFDEF SD_CARD_LOADER
            MOV #PARENACCEPT,&ACCEPT+2  ; always restore default console input 
    .ENDIF
            RET

            FORTHWORD "WIPE"        ; restore the program as it was in FastForth.hex file
WIPE
; reset JTAG and BSL signatures   ; unlock JTAG, SBW and BSL
            MOV     #SIGNATURES,X
SIGNLOOP    MOV     #-1,0(X)        ; reset signature; WARNING ! DON'T CHANGE THIS IMMEDIATE VALUE !
            ADD     #2,X
            CMP     #INTVECT,X
            JNZ     SIGNLOOP

; reset all FACTORY defered words to allow execution from SD_Card
            CALL    #WIPE_DEFER
; reinit this factory values :
            MOV     #ROMDICT,&DDP
            MOV     #lastvoclink,&LASTVOC
; then reinit RST_STATE and PWR_STATE
            JMP     RST_HERE


; define FREQ  used in WARM message (6)
    .IF     FREQUENCY = 0.5
FREQ    .set " .5MHz"
    .ELSEIF FREQUENCY = 1
FREQ    .set "  1MHz"
    .ELSEIF FREQUENCY = 2
FREQ    .set "  2MHz"
    .ELSEIF FREQUENCY = 4
FREQ    .set "  4MHz"
    .ELSEIF FREQUENCY = 8
FREQ    .set "  8MHz"
    .ELSEIF FREQUENCY = 16
FREQ    .set " 16MHz"
    .ELSEIF FREQUENCY = 24
FREQ    .set " 24MHz"
    .ENDIF

;Z (WARM)   --      ; init some user variables,
                    ; print start message if ECHO is set,
                    ; then ABORT
            FORTHWORD "(WARM)"
PARENWARM
            MOV     &SAVE_SYSRSTIV,TOS  ; to display it
            mDOCOL
            .word   XSQUOTE             ;
            .byte   5,13,1Bh,"[7m"      ; CR + cmd "reverse video"
            .word   TYPE                ;
            .word   DOT                 ; display signed SAVE_SYSRSTIV
            .word   XSQUOTE
            .byte   39," FastForth V160",FREQ," (C) J.M.Thoorens "
            .word   TYPE
            .word   LIT,FRAM_FULL,HERE,MINUS,UDOT
            .word   XSQUOTE         ;
            .byte   11,"bytes free ";
            .word   QABORTYESNOECHO     ; NOECHO enables any app to execute COLD without terminal connexion !


;Z WARM   --    ; deferred word used to init your application
                ; define this word:  : START ...init app here... LIT RECURSE IS WARM (WARM) ;
            FORTHWORD "WARM"
WARM        MOV     #PARENWARM,PC

;Z COLD     --      performs a software reset
            FORTHWORD "COLD"
COLD        MOV     #0A500h+PMMSWBOR,&PMMCTL0

; -------------------------------------------------------------------------
; in addition to <reset>, DEEP_RST restores the program as it was in the FastForth.hex file and the electronic fuse so.
; -------------------------------------------------------------------------
RESET
; -------------------------------------------------------------------------
; case 1  : Power ON ==> RESET + the volatile program beyond PWR_HERE (not protected by PWR_STATE against POWER OFF) is lost
;           SYSRSTIV = 2

; case 2 : <reset>  ==> RESET + the program beyond RST_HERE (not protected by RST_STATE against reset) is lost
;           SYSRSTIV = 4
; case 2.1 : software <reset> is performed by COLD.
;           SYSRSTIV = 6

; case 3 : TERM_TX wired to GND via 4k7 + <reset> ===> DEEP_RST, works even if the electronic fuse is "blown" !
; case 3.1 : (SYSRSTIV = 0Ah | SYSRSTIV >= 16h) ===> DEEP_RST on failure,
; case 3.2 : writing -1 in SAVE_SYSRSTIV then COLD ===> software DEEP_RST (WARM displays "-1")
; -------------------------------------------------------------------------

; ------------------------------------------------------------------
; RESET : Target Init, limited to FORTH usage : I/O, FRAM, RTC
; ------------------------------------------------------------------

    .include "TargetInit.asm"   ; include for each target the init code

; reset all interrupt vectors to RESET vector
            MOV     #RESET,W        ; W = reset vector
            MOV     #INTVECT,X      ; interrupt vectors base address
RESETINT:   MOV     W,0(X)
            ADD     #2,X
            JNZ     RESETINT        ; endloop when X = 0

; reset default TERMINAL vector interrupt and LPM0 mode for terminal use
            MOV     &INI_TERM,&TERMVEC
            MOV     #CPUOFF+GIE,&LPM_MODE

; -----------------------------------------------------------
; RESET : INIT FORTH machine 
; -----------------------------------------------------------
            MOV     #RSTACK,SP              ; init return stack
            MOV     #PSTACK,PSP             ; init parameter stack
    .SWITCH DTC
    .CASE 1
            MOV     #xdocol,rDOCOL          
    .CASE 2
            MOV     #EXIT,rEXIT
    .CASE 3 ; inlined DOCOL, do nothing here
    .ENDCASE
            MOV     #RFROM,rDOVAR
            MOV     #xdocon,rDOCON
            MOV     #xdodoes,rDODOES

            MOV     #10,&BASE
            MOV     #-1,&CAPS

; -----------------------------------------------------------
; RESET : test TERM_TXD/Deep_RST before init TERM_UART  I/O
; -----------------------------------------------------------
    BIC #LOCKLPM5,&PM5CTL0          ; activate all previous I/O settings before DEEP_RST test
    MOV &SAVE_SYSRSTIV,Y            ;
    BIT.B #DEEP_RST,&Deep_RST_IN    ; TERM TXD wired to GND via 4k7 resistor ?
    JNZ TERM_INIT                   ; no
    XOR #-1,Y                       ; yes : force DEEP_RST
    ADD #1,Y                        ;       to display SAVE_SYSRSTIV as negative value
    MOV Y,&SAVE_SYSRSTIV

; ----------------------------------------------------------------------
; RESET : INIT TERM_UART
; ----------------------------------------------------------------------
TERM_INIT

    MOV #0081h,&TERMCTLW0       ; Configure TERM_UART  UCLK = SMCLK

    .include "TERMINALBAUDRATE.asm" ; include code to configure baudrate

    BIS.B #TERM_TXRX,&TERM_SEL  ; Configure pins TXD & RXD for TERM_UART (PORTx_SEL0 xor PORTx_SEL1)
                                ; TERM_DIR is controlled by eUSCI_Ax module
    BIC #UCSWRST,&TERMCTLW0     ; release from reset...
    BIS #UCRXIE,&TERMIE         ; ... then enable RX interrupt for wake up on terminal input

; -----------------------------------------------------------
; RESET : Select  POWER_ON|<reset>|DEEP_RST   
; -----------------------------------------------------------

SelectReset MOV #COLD_END,IP    ; define return of WIPE,RST_STATE,PWR_STATE
            MOV &SAVE_SYSRSTIV,Y;
            CMP #0Ah,Y          ; reset event = security violation BOR ???? not documented...
            JZ WIPE            ; Add WIPE to this reset to do DEEP_RST     --------------
            CMP #16h,Y          ; reset event > software POR : failure or DEEP_RST request
            JHS WIPE            ; U>= ; Add WIPE to this reset to do DEEP_RST
            CMP #2,Y            ; reset event = Brownout ?
            JNZ RST_STATE       ; else  execute RST_STATE
            JZ  PWR_STATE       ; yes   execute PWR_STATE

; ----------------------------------------------------------------------
; RESET : INIT SD_Card optionally
; ----------------------------------------------------------------------
COLD_END
    .IFNDEF SD_CARD_LOADER      ;
        .word   WARM            ; the next step
    .ELSE
        FORTHtoASM
    BIT.B #SD_CD,&SD_CDIN       ; SD_memory in SD_Card module ?
    JNZ WARM                    ; no
    .include "forthMSP430FR_SD_INIT.asm"; 
    JMP     WARM
    .ENDIF

; ----------------------------------------------------------------------
; ASSEMBLER OPTION
; ----------------------------------------------------------------------
    .IFDEF MSP430ASSEMBLER
    .include "forthMSP430FR_ASM.asm"
    .ENDIF

; ----------------------------------------------------------------------
; SD CARD FAT OPTIONS
; ----------------------------------------------------------------------
    .IFDEF SD_CARD_LOADER
    .include "forthMSP430FR_SD_LowLvl.asm" ; SD primitives
    .include "forthMSP430FR_SD_LOAD.asm" ; SD LOAD fonctions
        .IFDEF SD_CARD_READ_WRITE
        .include "forthMSP430FR_SD_RW.asm" ; SD Read/Write fonctions
        .ENDIF
    .ENDIF ; SD_CARD_LOADER

; ----------------------------------------------------------------------
; UTILITY WORDS OPTION
; ----------------------------------------------------------------------
    .IFDEF UTILITY
    .include "ADDON\UTILITY.asm"
    .ENDIF ; UTILITY

;-----------------------------------------------------------------------
; SD TOOLS
;-----------------------------------------------------------------------
    .IFDEF SD_TOOLS

        .IFNDEF UTILITY
        .include "ADDON\UTILITY.asm"
        .ENDIF

    .include "ADDON\SD_TOOLS.asm"
    .ENDIF ;  SD_READ_WRITE_TOOLS

; -----------------------------------------------------------
; IT'S FINISH : RESOLVE ASSEMBLY PTR   
; -----------------------------------------------------------
ROMDICT         ; init DDP
lastvoclink     .equ voclink
lastforthword   .equ forthlink
lastasmword     .equ asmlink

    .IF THREADS <> 1

lastforthword1  .equ forthlink1
lastforthword2  .equ forthlink2
lastforthword3  .equ forthlink3
lastforthword4  .equ forthlink4
lastforthword5  .equ forthlink5
lastforthword6  .equ forthlink6
lastforthword7  .equ forthlink7
lastforthword8  .equ forthlink8
lastforthword9  .equ forthlink9
lastforthword10 .equ forthlink10
lastforthword11 .equ forthlink11
lastforthword12 .equ forthlink12
lastforthword13 .equ forthlink13
lastforthword14 .equ forthlink14
lastforthword15 .equ forthlink15
lastforthword16 .equ forthlink16
lastforthword17 .equ forthlink17
lastforthword18 .equ forthlink18
lastforthword19 .equ forthlink19
lastforthword20 .equ forthlink20
lastforthword21 .equ forthlink21
lastforthword22 .equ forthlink22
lastforthword23 .equ forthlink23
lastforthword24 .equ forthlink24
lastforthword25 .equ forthlink25
lastforthword26 .equ forthlink26
lastforthword27 .equ forthlink27
lastforthword28 .equ forthlink28
lastforthword29 .equ forthlink29
lastforthword30 .equ forthlink30
lastforthword31 .equ forthlink31

lastasmword1    .equ asmlink1
lastasmword2    .equ asmlink2
lastasmword3    .equ asmlink3
lastasmword4    .equ asmlink4
lastasmword5    .equ asmlink5
lastasmword6    .equ asmlink6
lastasmword7    .equ asmlink7
lastasmword8    .equ asmlink8
lastasmword9    .equ asmlink9
lastasmword10   .equ asmlink10
lastasmword11   .equ asmlink11
lastasmword12   .equ asmlink12
lastasmword13   .equ asmlink13
lastasmword14   .equ asmlink14
lastasmword15   .equ asmlink15
lastasmword16   .equ asmlink16
lastasmword17   .equ asmlink17
lastasmword18   .equ asmlink18
lastasmword19   .equ asmlink19
lastasmword20   .equ asmlink20
lastasmword21   .equ asmlink21
lastasmword22   .equ asmlink22
lastasmword23   .equ asmlink23
lastasmword24   .equ asmlink24
lastasmword25   .equ asmlink25
lastasmword26   .equ asmlink26
lastasmword27   .equ asmlink27
lastasmword28   .equ asmlink28
lastasmword29   .equ asmlink29
lastasmword30   .equ asmlink30
lastasmword31   .equ asmlink31

    .ENDIF
