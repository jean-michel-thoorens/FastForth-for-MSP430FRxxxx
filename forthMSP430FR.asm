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
; compiled with MACROASSEMBLER AS (http://john.ccac.rwth-aachen.de:8000/as/)
; ----------------------------------------------------------------------
    .cpu MSP430
    .include "mspregister.mac" ;
;    macexp off             ; uncomment to hide macro results

VER .equ "V205"

;-------------------------------------------------------------------------------
; Vingt fois sur le métier remettez votre ouvrage,
; Polissez-le sans cesse, et le repolissez,
; Ajoutez quelquefois, et souvent effacez.
;                                                        Boileau, L'Art poétique
;-------------------------------------------------------------------------------

;===============================================================================
;===============================================================================
; before assembling or programming you must set TARGET in param1 (SHIFT+F8)
; according to the TARGET "switched" below
;===============================================================================
;===============================================================================

;-------------------------------------------------------------------------------
; TARGETS kernel    ; sizes are for 8MHz, DTC=1, 2457600 bds, 3WIRES (XON/XOFF)
;-------------------------------------------------------------------------------
;MSP_EXP430FR5739   ; compile for MSP-EXP430FR5739 launchpad        ; 3998 bytes
;MSP_EXP430FR5969   ; compile for MSP-EXP430FR5969 launchpad        ; 3986 bytes
;MSP_EXP430FR5994   ; compile for MSP-EXP430FR5994 launchpad        ; 4004 bytes
;MSP_EXP430FR6989   ; compile for MSP-EXP430FR6989 launchpad        ; 4014 bytes
;MSP_EXP430FR4133   ; compile for MSP-EXP430FR4133 launchpad        ; 4048 bytes
;MSP_EXP430FR2433   ; compile for MSP-EXP430FR2433 launchpad        ; 3966 bytes
;CHIPSTICK_FR2433   ; compile for the "CHIPSTICK" of M. Ken BOAK    ; 3958 bytes
MSP_EXP430FR2355   ; compile for MSP-EXP430FR2355 launchpad        ; 3980 bytes

; choose DTC (Direct Threaded Code) model, if you don't know, choose 2
DTC .equ 2  ; DTC model 1 : DOCOL = CALL rDOCOL           14 cycles 1 word      shortest DTC model
            ; DTC model 2 : DOCOL = PUSH IP, CALL rEXIT   13 cycles 2 words     good compromize for mix FORTH/ASM code
            ; DTC model 3 : inlined DOCOL                  9 cycles 4 words     fastest

FREQUENCY   .equ 24  ; fully tested at 0.25,0.5,1,2,4,8,16 (and 24 for MSP430FR57xx) MHz
THREADS     .equ 16  ;  1,    2,    4,    8,   16,   32 search entries in dictionnary.
                    ; +0, +108, +122, +138, +180, +232 bytes
                    ; used to speed compilation; with bluetooth connection, choose 1,
                    ; with uart usb bridge, choose 16.
;-------------------------------------------------------------------------------
; KERNEL ADD-ON SWITCHES
;-------------------------------------------------------------------------------
MSP430ASSEMBLER     ;; + 1882 bytes : adds embedded assembler with TI syntax; without, you can do all but all much more slowly...
CONDCOMP            ;; +  324 bytes : add conditionnal compilation : MARKER [UNDEFINED] [DEFINED] [IF] [ELSE] [THEN] COMPARE
FIXPOINT_INPUT      ;; +   78 bytes : adds the interpretation input for Q15.16 numbers
LOWERCASE           ;; +   30 bytes : enables to write strings in lowercase.
VOCABULARY_SET      ;; +  102 bytes : adds words: VOCABULARY FORTH ASSEMBLER ALSO PREVIOUS ONLY DEFINITIONS (FORTH83)
;SD_CARD_LOADER      ;; + 1740 bytes : to LOAD source files from SD_card
;SD_CARD_READ_WRITE  ;; + 1188 bytes : to read, create, write and del files + source files direct copy from PC to SD_Card
;BOOTLOADER          ; +   52 bytes : adds to <reset> a bootstrap to SD_CARD\BOOT.4TH.
;QUIETBOOT           ; +    2 bytes : to perform bootload without displaying.
;NONAME              ; +   34 bytes : adds :NONAME
;TOTAL               ; +    4 bytes : to save R4 to R7 registers during interrupts.

;-------------------------------------------------------------------------------
; OPTIONAL KERNEL ADD-ON SWITCHES (can be downloaded later)                     >------------------+
; Tip: when added here, ADD-ONs become protected against WIPE and Deep Reset...                    |
;-------------------------------------------------------------------------------                   v
;UARTtoI2C           ;                to redirect source file to a I2C TERMINAL FastForth device UART2IIC.f
UTILITY             ;; +  426/508 bytes : add .S .RS WORDS U.R DUMP ?                            UTILITY.f
;FIXPOINT            ; +  452 bytes : add Q15.16 words HOLDS F+ F- F/ F* F#S F. S>F 2@ 2CONSTANT FIXPOINT.f
;SD_TOOLS            ;; +  126 bytes for trivial DIR, FAT, CLUSTER and SECTOR view, adds UTILITY  SD_TOOLS.f
;ANS_CORE_COMPLIANT  ; +  876 bytes : required to pass coretest.4th ; (includes items below)     ANS_COMP.f
;ARITHMETIC          ; +  358 bytes : add S>D M* SM/REM FM/MOD * /MOD / MOD */MOD /MOD */
;DOUBLE              ; +  130 bytes : add 2@ 2! 2DUP 2SWAP 2OVER
;ALIGNMENT           ; +   24 bytes : add ALIGN ALIGNED
;PORTABILITY         ; +   46 bytes : add CHARS CHAR+ CELLS CELL+


;-------------------------------------------------------------------------------
; FAST FORTH TERMINAL configuration
;-------------------------------------------------------------------------------

TERMINALBAUDRATE    .equ 115200 ; choose value considering the frequency and the UART2USB bridge, see explanations below.

;HALFDUPLEX          ; to use FAST FORTH with half duplex terminal

TERMINAL3WIRES      ;;               enable 3 wires (GND,TX,RX) with XON/XOFF software flow control (PL2303TA/HXD, CP2102)
TERMINAL4WIRES      ; + 18 bytes    enable 4 wires with hardware flow control on RX with RTS (PL2303TA/HXD, FT232RL)
;                                    this RTS pin may be permanently wired on SBWTCK/TEST pin without disturbing SBW 2 wires programming
;TERMINAL5WIRES      ; +  6 bytes    enable 5 wires with hardware flow control on RX/TX with RTS/CTS (PL2303TA/HXD, FT232RL)...

; if you uncomment TERMINAL3WIRES, you have a XON/XOFF terminal (software flow control)
; if you uncomment TERMINAL5WIRES, you have a RTS/CTS terminal (hardware flow control); mandatory option if you also want to perform binary transfers
; if you uncomment TERMINAL3WIRES + TERMINAL4WIRES, you have a XON/XOFF + RTS terminal; sufficient option to dowload with hardware control flow
; if you uncomment TERMINAL3WIRES + TERMINAL5WIRES, you have a XON/XOFF + RTS/CTS terminal


; --------------------------------------------------------------------------------------------
; Only two usb2uart bridges correctly handle XON / XOFF: cp2102 and pl2303.
; --------------------------------------------------------------------------------------------



; the best and cheapest: UARTtoUSB cable with Prolific PL2303HXD (or PL2303TA)
; works wel in 3 WIRES (XON/XOF) and 4WIRES (GND,RX,TX,RTS) config
; --------------------------------------------------------------------------------------------
;       PL2303TA 4 wires CABLE                         PL2303HXD 6 wires CABLE 
; pads upside: 3V3,txd,rxd,gnd,5V               pads upside: gnd, 3V3,txd,rxd,5V
;    downside: cts,dcd,dsr,rts,dtr                 downside:     rts,cts
; --------------------------------------------------------------------------------------------
; WARNING ! if you use PL2303TA/HXD cable as supply, open box before to weld red wire on 3v3 pad !
; --------------------------------------------------------------------------------------------
; 9600,19200,38400,57600    (250kHz)
; + 115200,134400           (500kHz)
; + 201600,230400,268800    (1MHz)
; + 403200,460800,614400    (2MHz)
; + 806400,921600,1228800   (4MHz)
; + 2457600                 (8MHz,PL2303TA)
; + 1843200,2457600         (8MHz,PL2303HXD)
; + 3MBds                   (16MHz,PL2303TA)
; + 3MBds,4MBds,5MBds       (16MHz,PL2303HXD)
; + 6MBds                   (MSP430FR57xx family,24MHz)


; UARTtoUSB module with Silabs CP2102 (supply current = 20 mA)
; ---------------------------------------------------------------------------------------------------
; WARNING ! if you use it as supply, buy a CP2102 module with a VCC switch 5V/3V3 and swith on 3V3 !
; ---------------------------------------------------------------------------------------------------
; 9600,19200,38400 (250kHz)
; + 57600 (500kHz)
; + 115200,134400,230400 (1MHz)
; + 460800 (2MHz)
; + 921600 (4MHz,8MHz,16MHz,24MHz)


; Launchpad --- UARTtoUSB device
;        RX <-- TX
;        TX --> RX
;       GND <-> GND

; TERATERM config terminal      : NewLine receive : AUTO,
;                                 NewLine transmit : CR+LF
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : TERMINALBAUDRATE value,
;                                 8bits, no parity, 1Stopbit,
;                                 XON/XOFF flow control,
;                                 delay = 0ms/line, 0ms/char

; don't forget : save new TERATERM configuration !


;===============================================================================
; Hardware control flow configuration: RTS is wired on UART2USB CTS pin
;===============================================================================

; Launchpad <-> UARTtoUSB
;        RX <-- TX
;        TX --> RX
;       RTS --> CTS
;       GND <-> GND

; notice that the control flow seems not necessary for TX (CTS pin)

; UARTtoUSB module with PL2303TA/HXD
; --------------------------------------------------------------------------------------------
; WARNING ! if you use PL2303HXD cable as supply, open box before to weld red wire on 3v3 pad !
; --------------------------------------------------------------------------------------------
; 9600,19200,38400,57600    (250kHz)
; + 115200,134400           (500kHz)
; + 201600,230400,268800    (1MHz)
; + 403200,460800,614400    (2MHz)
; + 806400,921600,1228800   (4MHz)
; + 2457600,3000000         (8MHz)
; + 4000000,5000000         (16MHz)
; + 6000000                 (24MHz)


; UARTtoUSB module with FTDI FT232RL (FT230X don't work correctly)
; ------------------------------------------------------------------------------
; WARNING ! buy a FT232RL module with a switch 5V/3V3 and select 3V3 !
; ------------------------------------------------------------------------------
; 9600,19200,38400,57600,115200 (500kHz)
; + 230400 (1MHz)
; + 460800 (2MHz)
; + 921600 (4,8,16 MHz)

; TERATERM config terminal      : NewLine receive : AUTO,
;                                 NewLine transmit : CR+LF
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : TERMINALBAUDRATE value,
;                                 8bits, no parity, 1Stopbit,
;                                 Hardware flow control,
;                                 delay = 0ms/line, 0ms/char

; don't forget : save new TERATERM configuration !

; ------------------------------------------------------------------------------
; UARTtoBluetooth 4.2 module (RN4870/RN4871 MIKROE click 2543/2544) at 921600 bds
; ------------------------------------------------------------------------------
; UARTtoBluetooth 2.0 module (RN42 sparkfun bluesmirf) at 921600bds
; ------------------------------------------------------------------------------
; 9600,19200,38400,57600,115200 (500kHz)
; + 230400 (1MHz)
; + 460800 (2MHz)
; + 921600 (4,8,16 MHz)

; RN42 config : connect RN41/RN42 module on teraterm, via USBtoUART bridge, 
; -----------   8n1, 115200 bds, no flow control, echo on 
;               $$$         // enter control mode, response: AOK
;               SU,92       // set 921600 bds, response: AOK
;               R,1         // reset module to take effect
;
;               connect RN42 module on FastForth target
;               add new bluetooth device on windows, password=1234
;               open the created output COMx port with TERATERM at 921600bds


; TERATERM config terminal      : NewLine receive : AUTO,
;                                 NewLine transmit : CR+LF
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : TERMINALBAUDRATE value,
;                                 8bits, no parity, 1Stopbit,
;                                 Hardware flow control or software flow control or ...no flow control!
;                                 delay = 0ms/line, 0ms/char

; in fact, compared to using a UART USB bridge, only the COMx port is to be updated.
; don't forget : save new TERATERM configuration !

; ------------------------------------------------------------------------------

    .include "Target.inc" ; to define target config: I/O, memory, SFR, vectors, TERMINAL eUSCI, SD_Card eUSCI, LF_XTAL,

    .include "ForthThreads.mac" ; init vocabulary pointers

;-------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx RAM memory map:
;-------------------------------------------------------------------------------

; name              words   ; comment

;LSTACK = L0 = LEAVEPTR     ; ----- RAMSTART
                            ; |
LSTACK_SIZE .equ    16      ; | grows up
                            ; V
                            ; ^
PSTACK_SIZE .equ    48      ; | grows down
                            ; |
;PSTACK=S0                  ; ----- RAMSTART + $80
                            ; ^
RSTACK_SIZE .equ    48      ; | grows down
                            ; |
;RSTACK=R0                  ; ----- RAMSTART + $E0

; names             bytes   ; comments

;PAD                        ; ----- RAMSTART + $E4
                            ; |
PAD_LEN     .equ    84      ; | grows up    (ans spec. : PAD >= 84 chars)
                            ; v
;PAD_END                    ; ----- RAMSTART + $138
;TIB-4                      ;       TIB_I2CADR
;TIB-2                      ;       TIB_I2CCNT
;TIB                        ; ----- RAMSTART + $13C
                            ; |
TIB_LEN     .equ    84      ; | grows up    (ans spec. : TIB >= 80 chars)
                            ; v
;HOLDS_ORG                  ; ------RAMSTART + $190
                            ; ^
HOLD_SIZE   .equ    34      ; | grows down  (ans spec. : HOLD_SIZE >= (2*n) + 2 char, with n = 16 bits/cell
                            ; |
;BASE_HOLD                  ; ----- RAMSTART + $1B2
                            ;
; variables system          ;
                            ;
                            ; ----- RAMSTART + $1E4
                            ;
                            ;       24 bytes free
                            ;
; variables system END      ; ----- RAMSTART + $1FC
                            ;       SD_BUF_I2CADR
                            ;       SD_BUF_I2CCNT
;SD_BUF                     ; ----- RAMSTART + $200
                            ;
                            ; 512 bytes buffer
                            ;
                            ; ----- RAMSTART + $2FF


LSTACK          .equ RAMSTART
LEAVEPTR        .equ LSTACK             ; Leave-stack pointer
PSTACK          .equ LSTACK+(LSTACK_SIZE*2)+(PSTACK_SIZE*2)
RSTACK          .equ PSTACK+(RSTACK_SIZE*2)
PAD_I2CADR      .equ PAD_ORG-4    
PAD_I2CCNT      .equ PAD_ORG-2
PAD_ORG         .equ RSTACK+4
TIB_I2CADR      .equ TIB_ORG-4   
TIB_I2CCNT      .equ TIB_ORG-2
TIB_ORG         .equ PAD_ORG+PAD_LEN+4
HOLDS_ORG       .equ TIB_ORG+TIB_LEN

BASE_HOLD       .equ HOLDS_ORG+HOLD_SIZE


; ----------------------------------------------------
; RAMSTART + $1B2 : RAM VARIABLES
; ----------------------------------------------------

HP              .equ BASE_HOLD      ; HOLD ptr
CAPS            .equ BASE_HOLD+2
LAST_NFA        .equ BASE_HOLD+4    ; NFA, VOC_PFA, CFA, PSP of last created word
LAST_THREAD     .equ BASE_HOLD+6    ; used by QREVEAL
LAST_CFA        .equ BASE_HOLD+8
LAST_PSP        .equ BASE_HOLD+10
STATE           .equ BASE_HOLD+12   ; Interpreter state
SAV_CURRENT     .equ BASE_HOLD+14   ; preserve CURRENT during create assembler words
OPCODE          .equ BASE_HOLD+16   ; OPCODE adr;                   also used as lure by :NONAME
ASMTYPE         .equ BASE_HOLD+18   ; keep the opcode complement;   also used as lure by :NONAME
SOURCE          .equ BASE_HOLD+20       
SOURCE_LEN      .equ BASE_HOLD+20       
SOURCE_ADR      .equ BASE_HOLD+22   ; len, addr of input stream
TOIN            .equ BASE_HOLD+24   ; CurrentInputBuffer pointer
DDP             .equ BASE_HOLD+26   ; dictionnary pointer
LASTVOC         .equ BASE_HOLD+28   ; keep VOC-LINK
CONTEXT         .equ BASE_HOLD+30   ; CONTEXT dictionnary space (8 CELLS)
CURRENT         .equ BASE_HOLD+46   ; CURRENT dictionnary ptr
BASE            .equ BASE_HOLD+48   
LINE            .equ BASE_HOLD+50   ; line in interpretation (initialized by NOECHO)

; ------------------------------------- ;
; RAMSTART + $1E6 : free to user        ;
; ------------------------------------- ;


; --------------------------------------------------
; RAMSTART + $1FC : RAM SD_CARD SD_BUF 4 + 512 bytes
; --------------------------------------------------
SD_BUF_I2CADR   .equ SD_BUF-4    
SD_BUF_I2CCNT   .equ SD_BUF-2
SD_BUF          .equ BASE_HOLD+78
SD_BUFEND       .equ SD_BUF + 200h   ; 512bytes


;-------------------------------------------------------------------------------
; INFO(DCBA) >= 256 bytes memory map:
;-------------------------------------------------------------------------------

    .org    INFOSTART

; --------------------------
; FRAM INFO KERNEL CONSTANTS
; --------------------------

INI_THREAD      .word THREADS               ; used by ADDON_UTILITY.f
INI_TERM        .word TERMINAL_INT          ;

    .IF FREQUENCY = 0.25
FREQ_KHZ        .word 250                   ;
    .ELSEIF FREQUENCY = 0.5
FREQ_KHZ        .word 500                   ;
    .ELSE
FREQ_KHZ        .word FREQUENCY*1000        ; user use
    .ENDIF
HECTOBAUDS      .word TERMINALBAUDRATE/100  ; user use

SAVE_SYSRSTIV   .word 05                    ; value to identify first start after core recompiling
LPM_MODE        .word CPUOFF+GIE            ; LPM0 is the default mode
;LPM_MODE        .word CPUOFF+GIE+SCG0       ; LPM1 is the default mode (disable FLL)
INIDP           .word ROMDICT               ; define RST_STATE
INIVOC          .word lastvoclink           ; define RST_STATE

                .word RXON                   ; user use
                .word RXOFF                  ; user use

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

INFO_BASE_END

; ------------------------------
; VARIABLES that could be in RAM
; ------------------------------

    .IFDEF RAM_1K       ; if RAM = 1K (FR57xx) the variables below are in INFO space (FRAM)
    .org INFO_BASE_END
    .ELSE               ; if RAM >= 2k the variables below are in RAM
    .org SD_BUFEND
    .ENDIF

    .IFDEF SD_CARD_LOADER

SD_ORG_DATA

; ---------------------------------------
; FAT FileSystemInfos
; ---------------------------------------
FATtype         .equ SD_ORG_DATA+2
BS_FirstSectorL .equ SD_ORG_DATA+4  ; init by SD_Init, used by RW_Sector_CMD
BS_FirstSectorH .equ SD_ORG_DATA+6  ; init by SD_Init, used by RW_Sector_CMD
OrgFAT1         .equ SD_ORG_DATA+8  ; init by SD_Init,
FATSize         .equ SD_ORG_DATA+10 ; init by SD_Init,
OrgFAT2         .equ SD_ORG_DATA+12 ; init by SD_Init,
OrgRootDIR      .equ SD_ORG_DATA+14 ; init by SD_Init, (FAT16 specific)
OrgClusters     .equ SD_ORG_DATA+16 ; init by SD_Init, Sector of Cluster 0
SecPerClus      .equ SD_ORG_DATA+18 ; init by SD_Init, byte size

SD_LOW_LEVEL    .equ SD_ORG_DATA+20
; ---------------------------------------
; SD command
; ---------------------------------------
SD_CMD_FRM      .equ SD_LOW_LEVEL   ; SD_CMDx inverted frame ${CRC7,ll,LL,hh,HH,CMD}
SectorL         .equ SD_LOW_LEVEL+6
SectorH         .equ SD_LOW_LEVEL+8

; ---------------------------------------
; SD_BUF management
; ---------------------------------------
BufferPtr       .equ SD_LOW_LEVEL+10
BufferLen       .equ SD_LOW_LEVEL+12

SD_FAT_LEVEL    .equ SD_LOW_LEVEL+14 
; ---------------------------------------
; FAT entry
; ---------------------------------------
ClusterL        .equ SD_FAT_LEVEL     ;
ClusterH        .equ SD_FAT_LEVEL+2   ;
NewClusterL     .equ SD_FAT_LEVEL+4   ;
NewClusterH     .equ SD_FAT_LEVEL+6   ;
CurFATsector    .equ SD_FAT_LEVEL+8   ; current FATSector of last free cluster

; ---------------------------------------
; DIR entry
; ---------------------------------------
DIRClusterL     .equ SD_FAT_LEVEL+10    ; contains the Cluster of current directory ; = 1 as FAT16 root directory
DIRClusterH     .equ SD_FAT_LEVEL+12    ; contains the Cluster of current directory ; = 1 as FAT16 root directory
EntryOfst       .equ SD_FAT_LEVEL+14

; ---------------------------------------
; Handle Pointer
; ---------------------------------------
CurrentHdl      .equ SD_FAT_LEVEL+16    ; contains the address of the last opened file structure, or 0

; ---------------------------------------
; Load file operation
; ---------------------------------------

pathname        .equ SD_FAT_LEVEL+18    ; start address
EndOfPath       .equ SD_FAT_LEVEL+20    ; end address

; ---------------------------------------

FirstHandle     .equ SD_FAT_LEVEL+30

; ---------------------------------------
; Handle structure
; ---------------------------------------
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


    .IFDEF RAM_1K ; RAM_Size = 1k: due to the lack of RAM, PAD is SDIB

HandleMax       .equ 5 ; and not 8 to respect INFO size (FRAM)
HandleLenght    .equ 24
HandleEnd       .equ FirstHandle+handleMax*HandleLenght

LOADPTR         .equ HandleEnd
LOAD_STACK      .equ HandleEnd+2
LOADSTACK_SIZE  .equ HandleMax+1    ; make room for 3 words * handles
LoadStackEnd    .equ LOAD_STACK+LOADSTACK_SIZE*6

SDIB_I2CADR     .equ PAD_ORG-4   
SDIB_I2CCNT     .equ PAD_ORG-2
SDIB_ORG        .equ PAD_ORG


    .ELSEIF     ; RAM_Size > 1k all is in RAM

HandleMax       .equ 8
HandleLenght    .equ 24
HandleEnd       .equ FirstHandle+handleMax*HandleLenght

LOADPTR         .equ HandleEnd
LOAD_STACK      .equ HandleEnd+2
LOADSTACK_SIZE  .equ HandleMax+1    ; make room for 3 words * handles
LoadStackEnd    .equ LOAD_STACK+LOADSTACK_SIZE*6 ; 3 words by handle

SDIB_I2CADR     .equ SDIB_ORG-4    
SDIB_I2CCNT     .equ SDIB_ORG-2
SDIB_ORG        .equ LoadStackEnd+4
SDIB_LEN        .equ 84             ; = TIB_LEN = PAD_LEN

    .ENDIF ; RAM_Size

SD_END_DATA     .equ LoadStackEnd

    .ENDIF ; SD_CARD_LOADER


;-------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx program (FRAM) memory
;-------------------------------------------------------------------------------

    .org    PROGRAMSTART

;-------------------------------------------------------------------------------
; DEFINING EXECUTIVE WORDS - DTC model
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; very nice FAST FORTH added feature:
;-------------------------------------------------------------------------------
; as IP is always computed from the PC value, we can place low level to high level
; switches "COLON" or "LO2HI" anywhere in a word, i.e. not only at its beginning
; as ITC competitors.
;-------------------------------------------------------------------------------

RSP         .reg    R1      ; RSP = Return Stack Pointer (return stack)

; DOxxx registers           ; must be saved before use and restored after use
rDODOES     .reg    r4
rDOCON      .reg    r5
rDOVAR      .reg    r6
rDOCOL      .reg    R7      ; COLD defines xdocol as R7 content

L           .reg    R7
M           .reg    r6      ; ex. PUSHM L,N  
N           .reg    r5
P           .reg    r4

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

mNEXT       .MACRO          ; return for low level words (written in assembler)
            MOV @IP+,PC     ; 4 fetch code address into PC, IP=PFA
            .ENDM           ; 4 cycles,1word = ITC -2cycles -1 word

NEXT        .equ    4D30h   ; 4 MOV @IP+,PC

FORTHtoASM  .MACRO          ; compiled by HI2LO
            .word   $+2     ; 0 cycle
            .ENDM           ; 0 cycle, 1 word



    .SWITCH DTC
;-------------------------------------------------------------------------------
    .CASE 1 ; DOCOL = CALL rDOCOL
;-------------------------------------------------------------------------------


xdocol      MOV @RSP+,W     ; 2
            PUSH IP         ; 3     save old IP on return stack
            MOV W,IP        ; 1     set new IP to PFA
            MOV @IP+,PC     ; 4     = NEXT
                            ; 10 cycles

ASMtoFORTH  .MACRO          ; compiled by LO2HI
            CALL #EXIT      ; 2 words, 10 cycles
            .ENDM           ;

mDOCOL      .MACRO          ; compiled by : and by colon
            CALL rDOCOL     ; 1 word, 14 cycles (CALL included) = ITC+4
            .ENDM           ;

DOCOL1      .equ    1287h   ; 4 CALL R7

;-------------------------------------------------------------------------------
    .CASE 2 ; DOCOL = PUSH IP + CALL rEXIT
;-------------------------------------------------------------------------------

rEXIT       .reg    R7      ; COLD defines EXIT as R7 content

ASMtoFORTH  .MACRO          ; compiled by LO2HI
            CALL rEXIT      ; 1 word, 10 cycles
            .ENDM           ;

mDOCOL      .MACRO          ; compiled by : and by COLON
            PUSH IP         ; 3
            CALL rEXIT      ; 10
            .ENDM           ; 2 words, 13 cycles = ITC+3

DOCOL1      .equ    120Dh   ; 3 PUSH IP
DOCOL2      .equ    1287h   ; 4 CALL rEXIT

;-------------------------------------------------------------------------------
    .CASE 3 ; inlined DOCOL
;-------------------------------------------------------------------------------

R           .reg    R7      ; Scratch register

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
            .ENDM           ; 4 words, 9 cycles (ITC-1)

DOCOL1      .equ    120Dh   ; 3 PUSH IP
DOCOL2      .equ    400Dh   ; 1 MOV PC,IP
DOCOL3      .equ    522Dh   ; 1 ADD #4,IP

    .ENDCASE ; DTC

;-------------------------------------------------------------------------------
; mDOVAR leave on parameter stack the PFA of a VARIABLE definition
;-------------------------------------------------------------------------------

mDOVAR      .MACRO          ; compiled by VARIABLE
            CALL rDOVAR     ; 1 word, 14 cycles (ITC+4)
            .ENDM           ;

DOVAR       .equ    1286h   ; CALL rDOVAR ; [rDOVAR] is defined as RFROM by COLD


;-------------------------------------------------------------------------------
; mDOCON  leave on parameter stack the [PFA] of a CONSTANT definition
;-------------------------------------------------------------------------------

mDOCON      .MACRO          ; compiled by CONSTANT
            CALL rDOCON     ; 1 word, 16 cycles (ITC+4)
            .ENDM           ;

DOCON       .equ    1285h   ; 4 CALL rDOCON ; [rDOCON] is defined as xdocon by COLD

xdocon  ;   -- constant     ; 4 for CALL rDOCON
            SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3 save TOS on parameters stack
            MOV @RSP+,TOS   ; 2 TOS = CFA address of master word CONSTANT
            MOV @TOS,TOS    ; 2 TOS = CONSTANT value
            MOV @IP+,PC     ; 4 execute next word
                            ; 16 = ITC (+4)

;-------------------------------------------------------------------------------
; mDODOES  leave on parameter stack the PFA of a CREATE definition and execute Master word
;-------------------------------------------------------------------------------

mDODOES     .MACRO          ; compiled  by DOES>
            CALL rDODOES    ;    CALL xdodoes
            .ENDM           ; 1 word, 19 cycles (ITC-2)

DODOES      .equ    1284h   ; 4 CALL rDODOES ; [rDODOES] is defind as xdodoes by COLD

xdodoes   ; -- a-addr       ; 4 for CALL rDODOES
            SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3 save TOS on parameters stack
            MOV @RSP+,TOS   ; 2 TOS = CFA address of master word, i.e. address of its first cell after DOES>
            PUSH IP         ; 3 save IP on return stack
            MOV @TOS+,IP    ; 2 IP = CFA of Master word, TOS = BODY address of created word
            MOV @IP+,PC     ; 4 Execute Master word

;-------------------------------------------------------------------------------
; INTERPRETER LOGIC
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/EXIT
;C EXIT     --      exit a colon definition; CALL #EXIT performs ASMtoFORTH (10 cycles)
;                                            JMP #EXIT performs EXIT
            FORTHWORD "EXIT"
EXIT        MOV @RSP+,IP        ; 2 pop previous IP (or next PC) from return stack
            MOV @IP+,PC         ; 4 = NEXT
                                ; 6 = ITC - 2

;Z lit      -- x    fetch inline literal to stack
; This is the execution part of LITERAL.
            FORTHWORD "LIT"
lit         SUB #2,PSP          ; 2  push old TOS..
            MOV TOS,0(PSP)      ; 3  ..onto stack
            MOV @IP+,TOS        ; 2  fetch new TOS value
            MOV @IP+,PC         ; 4  NEXT
                                ; 11 = ITC - 2

;-------------------------------------------------------------------------------
; STACK OPERATIONS
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/DUP
;C DUP      x -- x x      duplicate top of stack
            FORTHWORD "DUP"
DUP         SUB #2,PSP          ; 2  push old TOS..
            MOV TOS,0(PSP)      ; 3  ..onto stack
            mNEXT               ; 4

;https://forth-standard.org/standard/core/qDUP
;C ?DUP     x -- 0 | x x    DUP if nonzero
            FORTHWORD "?DUP"
QDUP        CMP #0,TOS          ; 2  test for TOS nonzero
            JNZ DUP             ; 2
            mNEXT               ; 4

;https://forth-standard.org/standard/core/DROP
;C DROP     x --          drop top of stack
            FORTHWORD "DROP"
DROP        MOV @PSP+,TOS       ; 2
            mNEXT               ; 4

;https://forth-standard.org/standard/core/NIP
;C NIP      x1 x2 -- x2         Drop the first item below the top of stack
            FORTHWORD "NIP"
NIP         ADD #2,PSP          ; 1
            mNEXT               ; 4

;https://forth-standard.org/standard/core/SWAP
;C SWAP     x1 x2 -- x2 x1    swap top two items
            FORTHWORD "SWAP"
SWAP        MOV @PSP,W          ; 2
            MOV TOS,0(PSP)      ; 3
            MOV W,TOS           ; 1
            mNEXT               ; 4

;https://forth-standard.org/standard/core/OVER
;C OVER    x1 x2 -- x1 x2 x1
            FORTHWORD "OVER"
OVER        MOV TOS,-2(PSP)     ; 3 -- x1 (x2) x2
            MOV @PSP,TOS        ; 2 -- x1 (x2) x1
            SUB #2,PSP          ; 2 -- x1 x2 x1
            mNEXT               ; 4

;https://forth-standard.org/standard/core/ROT
;C ROT    x1 x2 x3 -- x2 x3 x1
            FORTHWORD "ROT"
ROT         MOV @PSP,W          ; 2 fetch x2
            MOV TOS,0(PSP)      ; 3 store x3
            MOV 2(PSP),TOS      ; 3 fetch x1
            MOV W,2(PSP)        ; 3 store x2
            mNEXT               ; 4

;https://forth-standard.org/standard/core/toR
;C >R    x --   R: -- x   push to return stack
            FORTHWORD ">R"
TOR         PUSH TOS
            MOV @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/Rfrom
;C R>    -- x    R: x --   pop from return stack ; CALL #RFROM performs DOVAR
            FORTHWORD "R>"
RFROM       SUB #2,PSP          ; 1
            MOV TOS,0(PSP)      ; 3
            MOV @RSP+,TOS       ; 2
            mNEXT               ; 4

;https://forth-standard.org/standard/core/RFetch
;C R@    -- x     R: x -- x   fetch from rtn stk
            FORTHWORD "R@"
RFETCH      SUB #2,PSP
            MOV TOS,0(PSP)
            MOV @RSP,TOS
            mNEXT

;https://forth-standard.org/standard/core/DEPTH
;C DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
            FORTHWORD "DEPTH"
DEPTH       MOV TOS,-2(PSP)
            MOV #PSTACK,TOS
            SUB PSP,TOS       ; PSP-S0--> TOS
            SUB #2,PSP        ; post decrement stack...
            RRA TOS           ; TOS/2   --> TOS
            mNEXT

;-------------------------------------------------------------------------------
; MEMORY OPERATIONS
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/Fetch
;C @       a-addr -- x   fetch cell from memory
            FORTHWORD "@"
FETCH       MOV @TOS,TOS
            mNEXT

;https://forth-standard.org/standard/core/Store
;C !        x a-addr --   store cell in memory
            FORTHWORD "!"
STORE       MOV @PSP+,0(TOS)    ;4
            MOV @PSP+,TOS       ;2
            mNEXT               ;4

;https://forth-standard.org/standard/core/CFetch
;C C@     c-addr -- char   fetch char from memory
            FORTHWORD "C@"
CFETCH      MOV.B @TOS,TOS      ;2
            mNEXT               ;4

;https://forth-standard.org/standard/core/CStore
;C C!      char c-addr --    store char in memory
            FORTHWORD "C!"
CSTORE      MOV.B @PSP+,0(TOS)  ;4
            ADD #1,PSP          ;1
            MOV @PSP+,TOS       ;2
            mNEXT

;-------------------------------------------------------------------------------
; ARITHMETIC OPERATIONS
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/Plus
;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
            FORTHWORD "+"
PLUS        ADD @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/Minus
;C -      n1/u1 n2/u2 -- n3/u3      n3 = n1-n2
            FORTHWORD "-"
MINUS       SUB @PSP+,TOS   ;2  -- n2-n1
NEGATE      XOR #-1,TOS     ;1
            ADD #1,TOS      ;1  -- n3 = -(n2-n1)
            mNEXT

;https://forth-standard.org/standard/core/OnePlus
;C 1+      n1/u1 -- n2/u2       add 1 to TOS
            FORTHWORD "1+"
ONEPLUS     ADD #1,TOS
            mNEXT

;https://forth-standard.org/standard/core/OneMinus
;C 1-      n1/u1 -- n2/u2     subtract 1 from TOS
            FORTHWORD "1-"
ONEMINUS    SUB #1,TOS
            mNEXT

;https://forth-standard.org/standard/double/DABS
;C DABS     d1 -- |d1|     absolute value
            FORTHWORD "DABS"
DABBS       AND #-1,TOS     ; clear V, set N
            JGE DABBSEND    ; JMP if positive
DNEGATE     XOR #-1,0(PSP)
            XOR #-1,TOS
            ADD #1,0(PSP)
            ADDC #0,TOS
DABBSEND    mNEXT

;-------------------------------------------------------------------------------
; COMPARAISON OPERATIONS
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/ZeroEqual
;C 0=     n/u -- flag    return true if TOS=0
            FORTHWORD "0="
ZEROEQUAL   SUB #1,TOS      ; borrow (clear cy) if TOS was 0
            SUBC TOS,TOS    ; TOS=-1 if borrow was set
            mNEXT

;https://forth-standard.org/standard/core/Zeroless
;C 0<     n -- flag      true if TOS negative
            FORTHWORD "0<"
ZEROLESS    ADD TOS,TOS     ;1 set carry if TOS negative
            SUBC TOS,TOS    ;1 TOS=-1 if carry was clear
            XOR #-1,TOS     ;1 TOS=-1 if carry was set
            mNEXT

;https://forth-standard.org/standard/core/Equal
;C =      x1 x2 -- flag         test x1=x2
            FORTHWORD "="
EQUAL       SUB @PSP+,TOS   ;2
            JNZ TOSFALSE    ;2 --> +4
TOSTRUE     MOV #-1,TOS     ;1
            mNEXT           ;4

;https://forth-standard.org/standard/core/less
;C <      n1 n2 -- flag        test n1<n2, signed
            FORTHWORD "<"
LESS        MOV @PSP+,W     ;2 W=n1
            SUB TOS,W       ;1 W=n1-n2 flags set
LESSNEXT    JL TOSTRUE      ;2
TOSFALSE    MOV #0,TOS      ;1
            mNEXT           ;4

;https://forth-standard.org/standard/core/more
;C >     n1 n2 -- flag         test n1>n2, signed
            FORTHWORD ">"
GREATER     SUB @PSP+,TOS   ;2 TOS=n2-n1
            JMP LESSNEXT

;https://forth-standard.org/standard/core/Zeromore
;C 0>     n -- flag      true if TOS positive
            FORTHWORD "0>"
ZEROMORE    CMP #1,TOS
            JGE TOSTRUE
            JMP TOSFALSE

;https://forth-standard.org/standard/core/Uless
;C U<    u1 u2 -- flag       test u1<u2, unsigned
            FORTHWORD "U<"
ULESS       MOV @PSP+,W     ;2
            SUB TOS,W       ;1 u1-u2 in W, carry clear if borrow
            JNC TOSTRUE     ;2
            JMP TOSFALSE

;-------------------------------------------------------------------------------
; BRANCH and LOOP OPERATORS
;-------------------------------------------------------------------------------

;Z branch   --                  branch always
BRAN        MOV @IP,IP      ; 2
            mNEXT           ; 4

;Z ?branch   x --              branch if TOS = zero
QBRAN       CMP #0,TOS      ; 1  test TOS value
QBRAN1      MOV @PSP+,TOS   ; 2  pop new TOS value (doesn't change flags)
            JZ bran         ; 2  if TOS was zero, take the branch = 11 cycles
            ADD #2,IP       ; 1  else skip the branch destination
            mNEXT           ; 4  ==> branch not taken = 10 cycles

;Z 0?branch   x --              branch if TOS <> zero
QZBRAN      SUB #1,TOS      ; 1 borrow (clear cy) if TOS was 0
            SUBC TOS,TOS    ; 1 TOS=-1 if borrow was set
            JMP QBRAN1      ; 2


;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2      run-time code for DO
;                                               n1|u1=limit, n2|u2=index
xdo         MOV #8000h,X    ;2 compute 8000h-limit "fudge factor"
            SUB @PSP+,X     ;2
            MOV TOS,Y       ;1 loop ctr = index+fudge
            MOV @PSP+,TOS   ;2 pop new TOS
            ADD X,Y         ;1
            .word 01519h    ;4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
            mNEXT           ;4

;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates, clean up the
; return stack and skip the branch. Else take the inline branch.
xploop      ADD TOS,0(RSP)  ;4 increment INDEX by TOS value
            MOV @PSP+,TOS   ;2 get new TOS, doesn't change flags
xloopnext   BIT #100h,SR    ;2 is overflow bit set?
            JZ bran         ;2 no overflow = loop
            ADD #2,IP       ;1 overflow = loop done, skip branch ofs
UNXLOOP     ADD #4,RSP      ;1 empty RSP
            mNEXT           ;4 16~ taken or not taken xloop/loop


;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates, clean up the
; return stack and skip the branch.  Else take the inline branch.
; Note that LOOP terminates when index=8000h.
xloop       ADD #1,0(RSP)   ;4 increment INDEX
            JMP xloopnext   ;2

;https://forth-standard.org/standard/core/UNLOOP
;C UNLOOP   --   R: sys1 sys2 --  drop loop parms
            FORTHWORD "UNLOOP"
UNLOOP      JMP UNXLOOP

;https://forth-standard.org/standard/core/I
;C I        -- n   R: sys1 sys2 -- sys1 sys2
;C                  get the innermost loop index
            FORTHWORD "I"
II          SUB #2,PSP      ;1 make room in TOS
            MOV TOS,0(PSP)  ;3
            MOV @RSP,TOS    ;2 index = loopctr - fudge
            SUB 2(RSP),TOS  ;3
            mNEXT           ;4 13~

;https://forth-standard.org/standard/core/J
;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
            FORTHWORD "J"
JJ          SUB #2,PSP      ; make room in TOS
            MOV TOS,0(PSP)
            MOV 4(RSP),TOS  ; index = loopctr - fudge
            SUB 6(RSP),TOS
            mNEXT

;-------------------------------------------------------------------------------
; SYSTEM  CONSTANTS
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/BL
;C BL      -- char            an ASCII space
            FORTHWORD "BL"
FBLANK       mDOCON
            .word   32

;-------------------------------------------------------------------------------
; SYSTEM VARIABLES
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/BASE
;C BASE    -- a-addr       holds conversion radix
            FORTHWORD "BASE"
FBASE       mDOCON
            .word   BASE    ; VARIABLE address in RAM space

;https://forth-standard.org/standard/core/STATE
;C STATE   -- a-addr       holds compiler state
            FORTHWORD "STATE"
FSTATE      mDOCON
            .word   STATE   ; VARIABLE address in RAM space

;-------------------------------------------------------------------------------
; ANS complement OPTION
;-------------------------------------------------------------------------------
    .IFDEF ANS_CORE_COMPLIANT
    .include "ADDON\ANS_COMPLEMENT.asm"
    .ELSEIF

;-------------------------------------------------------------------------------
; ALIGNMENT OPERATORS OPTION
;-------------------------------------------------------------------------------
        .IFDEF ALIGNMENT ; included in ANS_COMPLEMENT
        .include "ADDON\ALIGNMENT.asm"
        .ENDIF ; ALIGNMENT

;-------------------------------------------------------------------------------
; PORTABILITY OPERATORS OPTION
;-------------------------------------------------------------------------------
        .IFDEF PORTABILITY
        .include "ADDON\PORTABILITY.asm"
        .ENDIF ; PORTABILITY

;-------------------------------------------------------------------------------
; DOUBLE OPERATORS OPTION
;-------------------------------------------------------------------------------
        .IFDEF DOUBLE ; included in ANS_COMPLEMENT
        .include "ADDON\DOUBLE.asm"
        .ENDIF ; DOUBLE

;-------------------------------------------------------------------------------
; ARITHMETIC OPERATORS OPTION
;-------------------------------------------------------------------------------
        .IFDEF ARITHMETIC ; included in ANS_COMPLEMENT
        .include "ADDON\ARITHMETIC.asm"
        .ENDIF ; ARITHMETIC

    .ENDIF ; ANS_COMPLEMENT

;-------------------------------------------------------------------------------
; NUMERIC OUTPUT
;-------------------------------------------------------------------------------

; Numeric conversion is done last digit first, so
; the output buffer is built backwards in memory.

;https://forth-standard.org/standard/core/num-start
;C <#    --       begin numeric conversion (initialize Hold Pointer)
            FORTHWORD "<#"
LESSNUM     MOV #BASE_HOLD,&HP
            mNEXT

;https://forth-standard.org/standard/core/UMDivMOD
; UM/MOD   udlo|udhi u1 -- r q   unsigned 32/16->16
            FORTHWORD "UM/MOD"
UMSLASHMOD  PUSH #DROP          ; 3 return address for MU/MOD

; unsigned 32-BIT DiViDend : 16-BIT DIVisor --> 32-BIT QUOTient, 16-BIT REMainder
; 2 times faster if DVDhi = 0 (it's the general case)

; reg     division        MU/MOD      NUM
; -----------------------------------------
; S     = DVDlo (15-0)  = ud1lo     = ud1lo
; TOS   = DVDhi (31-16) = ud1hi     = ud1hi
; T     = DIVlo         = BASE
; W     = REMlo         = REMlo     = digit --> char --> -[HP]
; X     = QUOTlo        = ud2lo     = ud2lo
; Y     = QUOThi        = ud2hi     = ud2hi
; rDODOES = count

; MU/MOD        DVDlo DVDhi DIVlo -- REMlo QUOTlo QUOThi, used by fixpoint and #
MUSMOD      MOV TOS,T           ;1 T = DIVlo
            MOV @PSP,TOS        ;2 TOS = DVDhi
            MOV 2(PSP),S        ;3 S = DVDlo
MUSMOD1     MOV #0,W            ;1  W = REMlo = 0
MUSMOD2     MOV #32,rDODOES     ;2  init loop count
            CMP #0,TOS          ;1  DVDhi=0 ?
            JNZ MDIV1           ;2  no
            RRA rDODOES         ;1  yes:loop count / 2
            MOV S,TOS           ;1      DVDhi <-- DVDlo
            MOV #0,S            ;1      DVDlo <-- 0
            MOV #0,X            ;1      QUOTlo <-- 0 (to do QUOThi = 0 at the end of division)
MDIV1       CMP T,W             ;1  REMlo U>= DIVlo ?
            JNC MDIV2           ;2  no : carry is reset
            SUB T,W             ;1  yes: REMlo - DIVlo ; carry is set after soustraction!
MDIV2       ADDC X,X            ;1  RLC quotLO
            ADDC Y,Y            ;1  RLC quotHI
            SUB #1,rDODOES      ;1  Decrement loop counter
            JN ENDMDIV          ;2
            ADD S,S             ;1  RLA DVDlo
            ADDC TOS,TOS        ;1  RLC DVDhi
            ADDC W,W            ;1  RLC REMlo
            JNC MDIV1           ;2
            SUB T,W             ;1  REMlo - DIVlo
            BIS #1,SR           ;1  SETC
            JMP MDIV2           ;2   
ENDMDIV     MOV #xdodoes,rDODOES;2  restore rDODOES
            MOV W,2(PSP)        ;3  REMlo in 2(PSP)
            MOV X,0(PSP)        ;3  QUOTlo in 0(PSP)
            MOV Y,TOS           ;1  QUOThi in TOS
            RET                 ;4  35 words, about 252/473 cycles, not FORTH executable !

;https://forth-standard.org/standard/core/num
;C #     ud1lo ud1hi -- ud2lo ud2hi          convert 1 digit of output
            FORTHWORD "#"
NUM         MOV &BASE,T         ;3                      T = Divisor 
NUM1        MOV @PSP,S          ;2 -- DVDlo DVDhi       S = DVDlo
            SUB #2,PSP          ;1 -- DVDlo x DVDhi     TOS = DVDhi
            CALL #MUSMOD1       ;4 -- REMlo QUOTlo QUOThi
            MOV @PSP+,0(PSP)    ;4 -- QUOTlo QUOThi  
TODIGIT     CMP.B #10,W         ;2  W = REMlo
            JLO TODIGIT1        ;2  U<
            ADD #7,W            ;2
TODIGIT1    ADD #30h,W          ;2
HOLDW       SUB #1,&HP          ;3  store W=char --> -[HP]
            MOV &HP,Y           ;3
            MOV.B W,0(Y)        ;3
            mNEXT               ;4  26 words

;https://forth-standard.org/standard/core/numS
;C #S    udlo:udhi -- udlo:udhi=0       convert remaining digits
            FORTHWORD "#S"
NUMS        mDOCOL
            .word   NUM         ;       X=QUOTlo
            FORTHtoASM          ;
            SUB #2,IP           ;1      restore NUM return
            CMP #0,X            ;1      test ud2lo first (generally true)
            JNZ NUM1            ;2
            CMP #0,TOS          ;1      then test ud2hi (generally false)
            JNZ NUM1            ;2
            MOV @RSP+,IP        ;2
            mNEXT               ;4 10 words, about 241/417 cycles/char

;https://forth-standard.org/standard/core/num-end
;C #>    udlo:udhi=0 -- c-addr u    end conversion, get string
            FORTHWORD "#>"
NUMGREATER  MOV &HP,0(PSP)
            MOV #BASE_HOLD,TOS
            SUB @PSP,TOS
            mNEXT

;https://forth-standard.org/standard/core/HOLD
;C HOLD  char --        add char to output string
            FORTHWORD "HOLD"
HOLD        MOV TOS,W           ;1
            MOV @PSP+,TOS       ;2
            JMP HOLDW           ;15

;https://forth-standard.org/standard/core/SIGN
;C SIGN  n --           add minus sign if n<0
            FORTHWORD "SIGN"
SIGN        CMP #0,TOS
            MOV @PSP+,TOS
            MOV #'-',W
            JN HOLDW        ; 0<
            mNEXT

;https://forth-standard.org/standard/core/Ud
;C U.    u --           display u (unsigned)
            FORTHWORD "U."
UDOT        mDOCOL
            .word   LESSNUM,lit,0,NUMS,NUMGREATER,TYPE,SPACE,EXIT

;https://forth-standard.org/standard/double/Dd
;C D.     dlo dhi --           display d (signed)
            FORTHWORD "D."
DDOT         mDOCOL
            .word   LESSNUM,SWAP,OVER,DABBS,NUMS
            .word   ROT,SIGN,NUMGREATER,TYPE,SPACE,EXIT

;https://forth-standard.org/standard/core/d
;C .     n --           display n (signed)
            FORTHWORD "."
DOT         CMP #0,TOS
            JGE UDOT
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV #-1,TOS         ; extend sign
            JMP DDOT

;-------------------------------------------------------------------------------
; DICTIONARY MANAGEMENT
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/HERE
;C HERE    -- addr      returns dictionary ptr
            FORTHWORD "HERE"
HERE        SUB #2,PSP
            MOV TOS,0(PSP)
            MOV &DDP,TOS
            mNEXT

;https://forth-standard.org/standard/core/ALLOT
;C ALLOT   n --         allocate n bytes in dict
            FORTHWORD "ALLOT"
ALLOT       ADD TOS,&DDP
            MOV @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/CComma
;C C,   char --        append char to dict
            FORTHWORD "C,"
CCOMMA      MOV &DDP,W
            MOV.B TOS,0(W)
            ADD #1,&DDP
            MOV @PSP+,TOS
            mNEXT

; ------------------------------------------------------------------------------
; TERMINAL I/O, input part
; ------------------------------------------------------------------------------

;Z (KEY)    -- c      get character from the terminal
            FORTHWORD "(KEY)"
PARENKEY    MOV &TERMRXBUF,Y        ; empty buffer
            SUB #2,PSP              ; 1  push old TOS..
            MOV TOS,0(PSP)          ; 4  ..onto stack
            CALL #RXON
KEYLOOP     BIT #UCRXIFG,&TERMIFG   ; loop if bit0 = 0 in interupt flag register
            JZ KEYLOOP              ;
            MOV &TERMRXBUF,TOS      ;
            CALL #RXOFF             ;
            mNEXT

;https://forth-standard.org/standard/core/KEY
;C KEY      -- c      wait character from input device ; deferred word
            FORTHWORD "KEY"
KEY         MOV @PC+,PC
            .word   PARENKEY

;-------------------------------------------------------------------------------
; INTERPRETER INPUT, the kernel of kernel !
;-------------------------------------------------------------------------------

    .IFDEF SD_CARD_LOADER
    .include "forthMSP430FR_SD_ACCEPT.asm"
DEFER_INPUT ; CIB (Current Input Buffer) and ACCEPT must to be redirected for SD_LOAD usage
    .ENDIF

    .IFDEF DEFER_INPUT

; CIB           --  addr          of Current Input Buffer
            FORTHWORD "CIB"
FCIB        mDOCON
            .WORD    TIB_ORG        ; constant, may be DEFERed as SDIB_ORG by OPEN.

; : REFILL CIB DUP TIB_LEN ACCEPT ;   -- CIB CIB len    shared by QUIT and [ELSE]
REFILL      SUB #6,PSP              ;2
            MOV TOS,4(PSP)          ;3
            MOV #TIB_LEN,TOS        ;2
            MOV &FCIB+2,0(PSP)      ;5
            MOV @PSP,2(PSP)         ;4
            JMP ACCEPT              ;2

;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get line at addr to interpret len' chars
            FORTHWORD "ACCEPT"
ACCEPT      MOV @PC+,PC             ;3
            .word   PARENACCEPT

;C (ACCEPT)  addr addr len -- addr len'     get len' (up to len) chars from terminal (TERATERM.EXE) via USBtoUART bridge
            FORTHWORD "(ACCEPT)"
PARENACCEPT

    .ELSE

; : REFILL TIB DUP TIB_LEN ACCEPT ;   -- TIB TIB len    shared by QUIT and [ELSE]
REFILL      SUB #6,PSP              ;2
            MOV TOS,4(PSP)          ;3
            MOV #TIB_LEN,TOS        ;2
            MOV #TIB_ORG,0(PSP)     ;4
            MOV @PSP,2(PSP)         ;4
            JMP ACCEPT              ;2

;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get line at addr to interpret len' chars
            FORTHWORD "ACCEPT"
ACCEPT

    .ENDIF ; DEFER_INPUT

    .IFDEF  HALFDUPLEX  ; to use FAST FORTH with half duplex input terminal (bluetooth or wifi connexion)

    .include "forthMSP430FR_HALFDUPLEX.asm"

    .ELSE   ; to use FAST FORTH with full duplex terminal (USBtoUART bridge)

; con speed of TERMINAL link, there are three bottlenecks :
; 1- time to send XOFF/RTS_high on CR (CR+LF=EOL), first emergency.
; 2- the char loop time,
; 3- the time between sending XON/RTS_low and clearing UCRXIFG on first received char,
; everything must be done to reduce these times, taking into account the necessity of switching to SLEEP (LPMx mode).
; ----------------------------------;
; (ACCEPT) I prepare TERMINAL_INT   ;
; ----------------------------------;
    .IFDEF TOTAL
            .word 1537h             ;6              push R7,R6,R5,R4
    .ENDIF                          ;
            MOV #ENDACCEPT,S        ;2              S = ACCEPT XOFF return
            MOV #AKEYREAD1,T        ;2              T = default XON return
            .word 152Dh             ;5              PUSHM IP,S,T, as IP ret, XOFF ret, XON ret
            MOV TOS,W               ;1 -- addr len
            MOV @PSP,TOS            ;2 -- org ptr                                             )
            ADD TOS,W               ;1 -- org ptr   W=Bound                                   )
            MOV #0Dh,T              ;2              T = 'CR' to speed up char loop in part II  > prepare stack and registers
            MOV #20h,S              ;2              S = 'BL' to speed up char loop in part II )  for TERMINAL_INT use
            MOV #AYEMIT_RET,IP      ;2              IP = return for YEMIT                     )
            BIT #UCRXIFG,&TERMIFG   ;3              RX_Int ?
            JZ ACCEPTNEXT           ;2              no : case of quiet input terminal
            MOV &TERMRXBUF,Y        ;3              yes: clear RX_Int
            CMP #0Ah,Y              ;2                   received char = LF ? (end of downloading ?)
            JNZ RXON                ;2                   no : RXON return = AKEYREAD1, to process first char of new line.
ACCEPTNEXT  ADD #2,RSP              ;1                   yes: remove AKEYREAD1 as XON return,
            MOV #SLEEP,X            ;2                        and set XON return = SLEEP
            .word 154Dh             ;7                        PUSHM IP,S,T,W,X before SLEEP (and so WAKE on any interrupts)
; ----------------------------------;
RXON                                ;
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;
    .IF TERMINALBAUDRATE/FREQUENCY <230400
RXON_LOOP   BIT #UCTXIFG,&TERMIFG   ;3  wait the sending end of XON, useless at high baudrates
            JZ RXON_LOOP            ;2
    .ENDIF
            MOV #17,&TERMTXBUF      ;4  move char XON into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;
            BIC.B #RTS,&HANDSHAKOUT ;4  set RTS low
    .ENDIF                          ;
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts first and 3th stopwatches  ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
            RET                     ;4  to BACKGND (End of file download or quiet input) or AKEYREAD1 (get next line of file downloading)
; ----------------------------------;   ...or user defined


; ----------------------------------;
RXOFF                               ;
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;
            MOV #19,&TERMTXBUF      ;4 move XOFF char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;
            BIS.B #RTS,&HANDSHAKOUT ;4 set RTS high
    .ENDIF                          ;
            RET                     ;4 to ENDACCEPT, ...or user defined
; ----------------------------------;


; ----------------------------------;
    ASMWORD "SLEEP"                 ; may be redirected
SLEEP       MOV @PC+,PC             ;3
            .word   PARENSLEEP      ;
; ----------------------------------;

; ----------------------------------;
    ASMWORD "(SLEEP)"               ;
PARENSLEEP  BIS &LPM_MODE,SR        ;3  enter in LPMx sleep mode with GIE=1
; ----------------------------------;   default FAST FORTH mode (for its input terminal use) : LPM0.

;###############################################################################################################
;###############################################################################################################

; ### #     # ####### ####### ######  ######  #     # ######  #######  #####     #     # ####### ######  #######
;  #  ##    #    #    #       #     # #     # #     # #     #    #    #     #    #     # #       #     # #
;  #  # #   #    #    #       #     # #     # #     # #     #    #    #          #     # #       #     # #
;  #  #  #  #    #    #####   ######  ######  #     # ######     #     #####     ####### #####   ######  #####
;  #  #   # #    #    #       #   #   #   #   #     # #          #          #    #     # #       #   #   #
;  #  #    ##    #    #       #    #  #    #  #     # #          #    #     #    #     # #       #    #  #
; ### #     #    #    ####### #     # #     #  #####  #          #     #####     #     # ####### #     # #######

;###############################################################################################################
;###############################################################################################################


; here, Fast FORTH sleeps, waiting any interrupt.
; IP,S,T,W,X,Y registers (R13 to R8) are free for any interrupt routine...
; ...and so PSP and RSP stacks with their rules of use.
; remember: in any interrupt routine you must include : BIC #0x78,0(RSP) before RETI
;           to force return to SLEEP.
;           or (bad idea ? previous SR flags are lost) simply : ADD #2 RSP, then RET instead of RETI


; ==================================;
            JMP SLEEP               ;2  here is the return for any interrupts, else TERMINAL_INT  :-)
; ==================================;


; **********************************;
TERMINAL_INT                        ; <--- TEMR RX interrupt vector, delayed by the LPMx wake up time
; **********************************;      if wake up time increases, max bauds rate decreases...
; (ACCEPT) part II under interrupt  ; Org Ptr -- len'
; ----------------------------------;
            ADD #4,RSP              ;1  remove SR and PC from stack, SR flags are lost (unused by FORTH interpreter)
            .word   173Ah           ;6  POPM ;W=buffer_bound, T=0Dh,S=20h, IP=AYEMIT_RET
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; starts the 2th stopwatch          ;
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD    MOV.B &TERMRXBUF,Y      ;3  read character into Y, UCRXIFG is cleared
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 3th stopwatch           ; 3th bottleneck result : 17~ + LPMx wake_up time ( + 5~ XON loop if F/Bds<230400 )
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;
AKEYREAD1
            CMP.B S,Y               ;1      printable char ?
            JHS ASTORETEST          ;2      yes
            CMP.B T,Y               ;1      char = CR ?
            JZ RXOFF                ;2      then RET to ENDACCEPT
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;+ 4    to send RXOFF
; stops the first stopwatch         ;=      first bottleneck, best case result: 27~ + LPMx wake_up time..
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;       ...or 14~ in case of empty line
            CMP.B #8,Y              ;1      char = BS ?
            JNE WAITaKEY            ;2      case of other control chars
; ----------------------------------;
; start of backspace                ;       made only by an human
; ----------------------------------;
            CMP @PSP,TOS            ;       Ptr = Org ?
            JZ WAITaKEY             ;       yes: do nothing
            SUB #1,TOS              ;       no : dec Ptr
            JMP YEMIT1              ;       send BS
; ----------------------------------;
; end of backspace                  ;
; ----------------------------------;
ASTORETEST  CMP W,TOS               ; 1 Bound is reached ?
            JZ YEMIT1               ; 2 yes: send echo then loopback
            MOV.B Y,0(TOS)          ; 3 no: store char @ Ptr, send echo then loopback
            ADD #1,TOS              ; 1     increment Ptr
YEMIT1
    .IF TERMINALBAUDRATE/FREQUENCY <230401
            BIT #UCTXIFG,&TERMIFG   ; 3 wait the sending end of previous char (sent before ACCEPT), useless at high baudrates
            JZ YEMIT1               ; 2
    .ENDIF
YEMIT2
    .IFDEF  TERMINAL5WIRES          ;
            BIT.B #CTS,&HANDSHAKIN  ; 3
            JNZ YEMIT2              ; 2
    .ENDIF
YEMIT                               ; hi7/4~ lo:12/9~ send/send_not  echo to terminal
            .word   4882h           ; 4882h = MOV Y,&<next_adr>
            .word   TERMTXBUF       ; 3
            mNEXT                   ; 4
; ----------------------------------;
AYEMIT_RET  FORTHtoASM              ; 0     YEMII NEXT address; NOP9
            SUB #2,IP               ; 1 set YEMIT NEXT address to AYEMIT_RET
WAITaKEY    BIT #UCRXIFG,&TERMIFG   ; 3 new char in TERMRXBUF ?
            JNZ AKEYREAD            ; 2 yes
            JZ WAITaKEY             ; 2 no
; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv;
; stops the 2th stopwatch           ; best case result: 26~/22~ (with/without echo) ==> 385/455 kBds/MHz
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^; 

; ----------------------------------;
ENDACCEPT                           ; <--- XOFF return address
; ----------------------------------;
            MOV #LPM0+GIE,&LPM_MODE ; reset LPM_MODE to default mode LPM0 for next line of input stream
            CMP #0,&LINE            ; if LINE <> 0...
            JZ ACCEPTEND            ;
            ADD #1,&LINE            ; ...increment LINE
ACCEPTEND   SUB @PSP+,TOS           ; Org Ptr -- len'
            MOV @RSP+,IP            ; 2 and continue with INTERPRET with GIE=0.
                                    ; So FORTH machine is protected against any interrupt...
    .IFDEF TOTAL
            .word 1734h             ;6              pop R4,R5,R6,R7
    .ENDIF
            mNEXT                   ; ...until next falling down to LPMx mode of (ACCEPT) part1,
; **********************************;    i.e. when the FORTH interpreter has no more to do.

; ------------------------------------------------------------------------------
; TERMINAL I/O, output part
; ------------------------------------------------------------------------------


;Z (EMIT)   c --    output character (byte) to the terminal
; hardware or software control on TX flow seems not necessary with UARTtoUSB bridges because
; they stop TX when their RX buffer is full. So no problem when the terminal input is echoed to output.
            FORTHWORD "(EMIT)"
PARENEMIT   MOV TOS,Y               ; 1
            MOV @PSP+,TOS           ; 2
            JMP YEMIT1              ;9  12~

    .ENDIF  ; HALFDUPLEX

;https://forth-standard.org/standard/core/EMIT
;C EMIT     c --    output character to the output device ; deferred word
            FORTHWORD "EMIT"
EMIT        MOV @PC+,PC             ;3  15~
            .word   PARENEMIT

;Z ECHO     --      connect console output (default)
            FORTHWORD "ECHO"
ECHO        MOV #4882h,&YEMIT       ; 4882h = MOV Y,&<next_adr>
            MOV #0,&LINE            ;
            mNEXT

;Z NOECHO   --      disconnect console output
            FORTHWORD "NOECHO"
NOECHO      MOV #NEXT,&YEMIT        ;  NEXT = 4030h = MOV @IP+,PC
            MOV #1,&LINE            ;
            mNEXT

;https://forth-standard.org/standard/core/SPACE
;C SPACE   --               output a space
            FORTHWORD "SPACE"
SPACE       SUB #2,PSP              ;1
            MOV TOS,0(PSP)          ;3
            MOV #20h,TOS            ;2
            JMP EMIT                ;17~  23~

;https://forth-standard.org/standard/core/SPACES
;C SPACES   n --            output n spaces
            FORTHWORD "SPACES"
SPACES      CMP #0,TOS
            JZ ONEDROP
            PUSH IP
            MOV #SPACESNEXT,IP
            JMP SPACE               ;25~
SPACESNEXT  FORTHtoASM
            SUB #2,IP               ;1
            SUB #1,TOS              ;1
            JNZ SPACE               ;25~ ==> 27~ by space ==> 2.963 MBds @ 8 MHz
DROPEXIT    MOV @RSP+,IP            ;
ONEDROP     MOV @PSP+,TOS           ; --         drop n
            mNEXT                   ;

;https://forth-standard.org/standard/core/TYPE
;C TYPE    adr len --     type line to terminal
            FORTHWORD "TYPE"
TYPE        CMP #0,TOS
            JZ TWODROP              ; abort fonction
            .word   0151Eh          ;5 PUSM TOS,IP      R-- len,IP 
            MOV #TYPE_NEXT,IP
TYPELOOP    MOV @PSP,Y              ;2 -- adr adr       ; 30~ char loop
            MOV.B @Y+,TOS           ;2
            MOV Y,0(PSP)            ;3 -- adr+1 char
            SUB #2,PSP              ;1 emit consumes one cell
            JMP EMIT                ;15
TYPE_NEXT   FORTHtoASM
            SUB #2,IP               ;1
            SUB #1,2(RSP)           ;4 len-1
            JNZ TYPELOOP            ;2
            .word   0171Dh          ;5 POPM IP,TOS
TWODROP     ADD #2,PSP              ;
            MOV @PSP+,TOS           ; -- 
            mNEXT                   ;

; (CR)     --               send CR+LF to the output terminal (via TYPE)
            FORTHWORD "(CR)"
PARENCR     mDOCOL
            .word   XSQUOTE
            .byte   2,13,10
            .word   TYPE,EXIT

;https://forth-standard.org/standard/core/CR
;C CR      --               send CR to the output device
            FORTHWORD "CR"
CR          MOV @PC+,PC
            .word   PARENCR

; ------------------------------------------------------------------------------
; STRINGS PROCESSING
; ------------------------------------------------------------------------------

;Z (S")     -- addr u   run-time code for S"
; get address and length of string.
XSQUOTE     SUB #4,PSP              ; 1 -- x x TOS      ; push old TOS on stack
            MOV TOS,2(PSP)          ; 3 -- TOS x x      ; and reserve one cell on stack
            MOV.B @IP+,TOS          ; 2 -- x u          ; u = lenght of string
            MOV IP,0(PSP)           ; 3 -- addr u
            ADD TOS,IP              ; 1 -- addr u       IP=addr+u=addr(end_of_string)
            BIT #1,IP               ; 1 -- addr u       IP=addr+u   Carry set/clear if odd/even
            ADDC #0,IP              ; 1 -- addr u       IP=addr+u aligned
            mNEXT                   ; 4  16~

    .IFDEF LOWERCASE

            FORTHWORD "CAPS_ON"
CAPS_ON     MOV #-1,&CAPS           ; state by default
            mNEXT

            FORTHWORD "CAPS_OFF"
CAPS_OFF    MOV #0,&CAPS    
            mNEXT

;https://forth-standard.org/standard/core/Sq
;C S"       --             compile in-line string
            FORTHWORDIMM "S\34"     ; immediate
SQUOTE      mDOCOL
            .word   lit,XSQUOTE,COMMA
SQUOTE1     .word   CAPS_OFF
            .word   lit,'"',WORDD   ; -- c-addr (= HERE)
            .word   CAPS_ON

    .ELSE

;https://forth-standard.org/standard/core/Sq
;C S"       --             compile in-line string
            FORTHWORDIMM "S\34"     ; immediate
SQUOTE      mDOCOL
            .word   lit,XSQUOTE,COMMA
SQUOTE1     .word   lit,'"',WORDD ; -- c-addr (= HERE)

    .ENDIF ; LOWERCASE

            FORTHtoASM
            MOV @RSP+,IP
            MOV.B @TOS,TOS          ; -- u
            SUB #1,TOS              ;   -1 byte
            ADD TOS,&DDP
            MOV @PSP+,TOS
CELLPLUSALIGN
            BIT #1,&DDP             ;3 carry set if 1
            ADDC #2,&DDP            ;4  +2 bytes
            mNEXT

;https://forth-standard.org/standard/core/Dotq
;C ."       --              compile string to print
            FORTHWORDIMM ".\34"     ; immediate
DOTQUOTE    mDOCOL
            .word   SQUOTE
            .word   lit,TYPE,COMMA,EXIT

;-------------------------------------------------------------------------------
; INTERPRETER
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/WORD
;C WORD   char -- addr        Z=1 if len=0
; parse a word delimited by char separator
;                                   "word" is capitalized
;                                   TOIN is the relative displacement in the ascii string 
;                                   separator filled line = 25 cycles + 7 cycles by char
            FORTHWORD "WORD"
WORDD       MOV #SOURCE_LEN,S       ;2 -- separator
            MOV @S+,X               ;2               X = str_len
            MOV @S+,W               ;2               W = str_org
            ADD W,X                 ;1               W = str_org    X = str_org + str_len = str_end
            ADD @S+,W               ;2               W = str_org + >IN = str_ptr    X = str_end
            MOV @S,Y                ;2 -- separator  W = str_ptr    X = str_end     Y = HERE, as dst_ptr
SKIPCHARLOO CMP W,X                 ;1               str_ptr = str_end ?
            JZ EOL_END              ;2 -- separator  if yes : End Of Line !
            CMP.B @W+,TOS           ;2               does char = separator ?
            JZ SKIPCHARLOO          ;2 -- separator  if yes
SCANWORD    SUB #1,W                ;1
            MOV #96,T               ;2              T = 96 = ascii(a)-1 (test value set in a register before SCANWORD loop)
SCANWORDLOO                         ; -- separator  15/23 cycles loop for upper/lower case char... write words in upper case !
            MOV.B S,0(Y)            ;3              first time make room in dst for word length, then put char @ dst.
            CMP W,X                 ;1              str_ptr = str_end ?
            JZ SCANWORDEND          ;2              if yes
            MOV.B @W+,S             ;2
            CMP.B S,TOS             ;1              does char = separator ?
            JZ SCANWORDEND          ;2              if yes
            ADD #1,Y                ;1              increment dst just before test loop
            CMP.B S,T               ;1              char U< 'a' ?  ('a'-1 U>= char) this condition is tested at each loop
            JC SCANWORDLOO          ;2              15~ upper case char loop
    .IFDEF LOWERCASE                ;
QCAPS       CMP #0,&CAPS            ;3              CAPS is OFF ? (case available only for ABORT" ." .( )
            JZ SCANWORDLOO          ;2              yes
    .ENDIF ; LOWERCASE              ;               here CAPS is ON (other cases)
            CMP.B #123,S            ;2              char U>= 'z'+1 ?
            JC SCANWORDLOO          ;2              if yes
            SUB.B #32,S             ;2              convert lowercase char to uppercase
            JMP SCANWORDLOO         ;2

SCANWORDEND SUB &SOURCE_ADR,W       ;3 -- separator  W=str_ptr - str_org = new >IN (first char separator next)
            MOV W,&TOIN             ;3               update >IN
EOL_END     MOV &DDP,TOS            ;3 -- c-addr
            SUB TOS,Y               ;1               Y=Word_Length
            MOV.B Y,0(TOS)          ;3
            mNEXT                   ;4 -- c-addr     40 words      Z=1 <==> lenght=0 <==> EOL


;https://forth-standard.org/standard/core/FIND
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
FIND        SUB #2,PSP              ;1 -- ???? c-addr       reserve one cell here, not at FINDEND because interacts with flag Z
            MOV TOS,S               ;1                      S=c-addr
            MOV.B @S,rDOCON         ;2                      R5= string count
            MOV.B #80h,rDODOES      ;2                      R4= immediate mask
            MOV #CONTEXT,T          ;2
VOCLOOP     MOV @T+,TOS             ;2 -- ???? VOC_PFA      T=CTXT+2
            CMP #0,TOS              ;1                      no more vocabulary in CONTEXT ?
            JZ FINDEND              ;2 -- ???? 0            yes ==> exit; Z=1
    .SWITCH THREADS
    .CASE   1
    .ELSECASE                       ;                       search thread add 6cycles  5words
MAKETHREAD  MOV.B 1(S),Y            ;3 -- ???? VOC_PFA0     S=c-addr Y=CHAR0
            AND.B #(THREADS-1)*2,Y  ;2 -- ???? VOC_PFA0     Y=thread offset
            ADD Y,TOS               ;1 -- ???? VOC_PFAx
    .ENDCASE
            ADD #2,TOS              ;1 -- ???? VOC_PFA+2
WORDLOOP    MOV -2(TOS),TOS         ;3 -- ???? [VOC_PFA]    [VOC_PFA] first, then [LFA]
            CMP #0,TOS              ;1 -- ???? NFA          no more word in the thread ?
            JZ VOCLOOP              ;2 -- ???? NFA          yes ==> search next voc in context
            MOV TOS,X               ;1
            MOV.B @X+,Y             ;2                      TOS=NFA,X=NFA+1,Y=NFA_char
            BIC.B rDODOES,Y         ;1                      hide Immediate bit
LENCOMP     CMP.B rDOCON,Y          ;1                      compare lenght
            JNZ WORDLOOP            ;2 -- ???? NFA          13~ word loop on lenght mismatch
            MOV S,W                 ;1                      W=c-addr
CHARLOOP    ADD #1,W                ;1
CHARCOMP    CMP.B @X+,0(W)          ;4                      compare chars
            JNZ WORDLOOP            ;2 -- ???? NFA          21~ word loop on first char mismatch
            SUB.B #1,Y              ;1                      decr count
            JNZ CHARLOOP            ;2 -- ???? NFA          10~ char loop

WORDFOUND   BIT #1,X                ;1
            ADDC #0,X               ;1
            MOV X,S                 ;1                      S=aligned CFA
            MOV.B @TOS,W            ;2 -- ???? NFA          W=NFA_first_char
            MOV #1,TOS              ;1 -- ???? 1            preset immediate flag
            CMP.B #0,W              ;1                      W is negative if immediate flag
            JN FINDEND              ;2 -- ???? 1
            SUB #2,TOS              ;1 -- ???? -1
FINDEND     MOV S,0(PSP)            ;3 not found: -- c-addr 0                           flag Z=1
                                    ;      found: -- xt -1|+1 (not immediate|immediate) flag Z=0
            MOV #xdocon,rDOCON      ;2
            MOV #xdodoes,rDODOES    ;2
            mNEXT                   ;4 42/47 words

    .IFDEF MPY_32 

;https://forth-standard.org/standard/core/toNUMBER
;C  convert a string to double number until count2 = 0 or until not convertible char
;C >NUMBER  ud1lo|ud1hi addr1 count1 -- ud2lo|ud2hi addr2 count2
            FORTHWORD ">NUMBER"     ; 23 cycles + 32/34 cycles DEC/HEX char loop
TONUMBER    MOV @PSP+,S             ;2                          S = adr
            MOV @PSP+,Y             ;2                          Y = ud1hi
            MOV @PSP,X              ;2                          X = ud1lo
            SUB #4,PSP              ;1
            MOV &BASE,T             ;3
TONUMLOOP   MOV.B @S,W              ;2 -- ud1lo ud1hi adr count W=char
DDIGITQ     SUB.B #30h,W            ;2                          skip all chars < '0' 
            CMP.B #10,W             ;2                          char was U< "10" ?
            JLO DDIGITQNEXT         ;2                          no
            SUB.B #7,W              ;2                          skip all chars between "9" and "A"
            CMP.B #10,W             ;2
            JLO TONUMEND            ;2
DDIGITQNEXT CMP T,W                 ;1                          digit-base
            JHS TONUMEND            ;2 -- ud1lo ud1hi adr count abort if < 0 or >= base
            MOV X,&MPY32L           ;3                          Load 1st operand (ud1lo)
            MOV Y,&MPY32H           ;3                          Load 1st operand (ud1hi)
            MOV T,&OP2              ;3                          Load 2nd operand with BASE
            MOV &RES0,X             ;3                          lo result in X (ud2lo)
            MOV &RES1,Y             ;3                          hi result in Y (ud2hi)
            ADD W,X                 ;1                          ud2lo + digit
            ADDC #0,Y               ;1                          ud2hi + carry
TONUMPLUS   ADD #1,S                ;1 -- ud1lo ud1hi adr count S=adr+1
            SUB #1,TOS              ;1 -- ud1lo ud1hi adr count-1
            JNZ TONUMLOOP           ;2                          if count <>0
            MOV Y,2(PSP)            ;3 -- ud2lo ud2hi adr count2
TONUMEND    MOV S,0(PSP)            ;3 -- ud2lo ud2hi addr2 count2
            MOV X,4(PSP)            ;3 -- ud2lo ud1hi adr count2
            mNEXT                   ;4 38 words


; ?NUMBER makes the interface between >NUMBER and INTERPRET; it's a subset of INTERPRET.
; convert a string to a signed number; FORTH 2012 prefixes $, %, # are recognized
; 32 bits numbers (with decimal point) and fixed point signed numbers (with a comma) are recognized.
; prefixes # % $ - are processed before calling >NUMBER
; not convertible chars '.' (double) and ',' (fixed point) are processed as >NUMBER exits
;Z ?NUMBER  c-addr -- n -1      if convert ok ; flag Z=0
;Z          c-addr -- c-addr 0  if convert ko ; flag Z=1
QNUMBER     MOV #0,S                ;1
            MOV &BASE,T             ;3                          T=BASE
            BIC #UF9,SR             ;2                          reset flag UF9, before use as decimal point flag
            .word   152Dh           ;5                          R-- IP sign base
            MOV #0,X                ;1                          X=ud1lo
            MOV #0,Y                ;1                          Y=ud1hi
            MOV #QNUMNEXT,IP        ;2                          return from >NUMBER
            SUB #8,PSP              ;1 -- x x x x c-addr        save TOS and make room for >NUMBER
            MOV TOS,6(PSP)          ;3 -- c-addr x x x c-addr
            MOV TOS,S               ;1                          S=addrr
            MOV.B @S+,TOS           ;2 -- c-addr x x x cnt      TOS=count
            MOV.B @S,W              ;2                          W=char
            SUB.B #',',W            ;2
            JHS QSIGN               ;2                          for current base, and for ',' or '.' process
            SUB.B #1,W              ;1
QBINARY     MOV #2,T                ;3                              preset base 2
            ADD.B #8,W              ;1                          '%' + 8 = '-'   binary number ?
            JZ PREFIXED             ;2
QDECIMAL    ADD #8,T                ;4
            ADD.B #2,W              ;1                          '#' + 2 = '%'   decimal number ?
            JZ PREFIXED             ;2
QHEXA       MOV #16,T               ;4
            SUB.B #1,W              ;2                          '$' - 1 = '#'   hex number ?
            JNZ TONUMLOOP           ;2 -- c-addr ud=0 x x       other cases will cause error
PREFIXED    ADD #1,S                ;1
            SUB #1,TOS              ;1 -- c-addr ud=0 x count   S=adr+1 TOS=count-1
            MOV.B @S,W              ;2                          X=2th char, W=adr
            SUB.B #',',W            ;2
QSIGN       CMP.B #1,W              ;1
            JNZ TONUMLOOP           ;2                          for positive number and for , or . process
            MOV #-1,2(RSP)          ;3                          R-- IP sign base
            JMP TONUMPLUS           ;2
; ----------------------------------; 39
QNUMNEXT    FORTHtoASM              ;  -- c-addr ud2lo-hi addr2 cnt2    R-- IP sign BASE    S=addr2
            CMP #0,TOS              ;1                                  cnt2=0 : conversion is ok ?
            JZ QNUMNEXT1            ;2                                  yes
            BIT #UF9,SR             ;2                                  already flagged double ? 
                                    ;                                   ( test to discard repeated points or repeated commas)
            JNZ QNUMNEXT1           ;2                                  abort
            BIS #UF9,SR             ;2                                  set double number flag

    .IFDEF FIXPOINT_INPUT

QQNUMDP     CMP.B #'.',0(S)         ;4                                  rejected char by >NUMBER = decimal point ?
            JNZ QQcomma             ;2                                  no
            SUB #2,IP               ;1                                  yes: reset QNUMNEXT address as >NUMBER return
            JMP TONUMPLUS           ;2                                      loop back to >NUMBER to terminate conversion
QQcomma     CMP.B #',',0(S)         ;5                                  rejected char by >NUMBER is a comma ?
            JNZ QNUMNEXT1           ;2                                  no
S15Q16      MOV TOS,W               ;1 -- c-addr ud2lo x x x            yes   W=cnt2
            MOV #0,X                ;1 -- c-addr ud2lo x 0 x            init X = ud2lo' = 0
S15Q16LOOP  MOV X,2(PSP)            ;3 -- c-addr ud2lo ud2lo' ud2lo' x  0(PSP) = ud2lo'   
            SUB.B #1,W              ;1                                  decrement cnt2
            MOV W,X                 ;1                                  X = cnt2-1
            ADD S,X                 ;1                                  X = end_of_string-1, first...
            MOV.B @X,X              ;2                                  X = last char of string, first...
            SUB #30h,X              ;2                                  char --> digit conversion
            CMP.B #10,X             ;2
            JLO QS15Q16DIGI         ;2
            SUB.B #7,X              ;2
            CMP.B #10,X             ;2
            JLO S15Q16EOC           ;2
QS15Q16DIGI CMP T,X                 ;1                                  R-- IP sign BASE    is X a digit ?
            JHS S15Q16EOC           ;2 -- c-addr ud2lo ud2lo' x ud2lo'  if no
            MOV X,0(PSP)            ;3 -- c-addr ud2lo ud2lo' digit x 
            MOV T,TOS               ;1 -- c-addr ud2lo ud2lo' digit     base R-- IP sign base
            .word 152Ch             ;6                                  PUSH S,T,W: R-- IP sign base addr2 base cnt2     
            CALL #MUSMOD            ;4 -- c-addr ud2lo ur uqlo uqhi
            .word 172Ah             ;6                                  restore W,T,S: R-- IP sign BASE     
            JMP S15Q16LOOP          ;2                                  W=cnt
S15Q16EOC   MOV 4(PSP),2(PSP)       ;5 -- c-addr ud2lo ud2hi uqlo x     ud2lo from >NUMBER part1 becomes here ud2hi=S15 part2
            MOV @PSP,4(PSP)         ;4 -- c-addr ud2lo ud2hi x x        uqlo becomes ud2lo
            MOV W,TOS               ;1 -- c-addr ud2lo ud2hi x cnt2
            CMP.B #0,TOS            ;1                                  TOS = 0 if end of conversion char = ',' (happy end)

    .ELSE ; no FIXPOINT_INPUT

QQNUMDP     CMP.B #'.',0(S)         ;4                                  rejected char by >NUMBER = decimal point ?
            JNZ QNUMNEXT1           ;2                                  no
            SUB #2,IP               ;1                                  yes: set QNUMNEXT address as >NUMBER return
            JMP TONUMPLUS           ;2                                      loop back to >NUMBER to terminate conversion

    .ENDIF

; ----------------------------------;88
QNUMNEXT1   .word   0172Bh          ;4 -- c-addr ud2lo-hi x cnt2        POPM T,S,IP  S = sign flag = {-1;0}
            MOV S,TOS               ;1 -- c-addr ud2lo-hi x sign
            MOV T,&BASE             ;3
            JZ QNUMOK               ;2 -- c-addr ud2lo-hi x sign        conversion OK
QNUMKO      ADD #6,PSP              ;1 -- c-addr sign
            AND #0,TOS              ;1 -- c-addr ff                     TOS=0 and Z=1 ==> conversion ko
            mNEXT                   ;4 
; ----------------------------------;97
QNUMOK      ADD #2,PSP              ;1 -- c-addr ud2lo-hi cnt2 
            MOV 2(PSP),4(PSP)       ;  -- udlo udlo udhi sign
            MOV @PSP+,0(PSP)        ;4 -- udlo udhi sign              note : PSP is incremented before write back !!!
            XOR #-1,TOS             ;1 -- udlo udhi inv(sign)
            JNZ QDOUBLE             ;2                      if jump : TOS=-1 and Z=0 ==> conversion ok
Q2NEGATE    XOR #-1,TOS             ;1 -- udlo udhi tf
            XOR #-1,2(PSP)          ;3 -- dlo-1 dhi-1 tf
            XOR #-1,0(PSP)          ;3 -- dlo-1 udhi tf
            ADD #1,2(PSP)           ;3 -- dlo dhi-1 tf
            ADDC #0,0(PSP)          ;3 -- dlo dhi tf
QDOUBLE     BIT #UF9,SR             ;2                      decimal point added ?
            JNZ QNUMEND             ;2                      leave double
            ADD #2,PSP              ;1                      leave number
QNUMEND    mNEXT                    ;4                      TOS=-1 and Z=0 ==> conversion ok
; ----------------------------------;119 words 

    .ELSE ; no hardware HRDWMPY

; T.I. SIGNED MULTIPLY SUBROUTINE: U1 x U2 -> Ud

;https://forth-standard.org/standard/core/UMTimes
;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
            FORTHWORD "UM*"
UMSTAR      MOV @PSP,S              ;2 MDlo
UMSTAR1     MOV #0,T                ;1 MDhi=0
            MOV #0,X                ;1 RES0=0
            MOV #0,Y                ;1 RES1=0
            MOV #1,W                ;1 BIT TEST REGISTER
UMSTARLOOP  BIT W,TOS               ;1 TEST ACTUAL BIT MRlo
            JZ UMSTARNEXT           ;2 IF 0: DO NOTHING
            ADD S,X                 ;1 IF 1: ADD MDlo TO RES0
            ADDC T,Y                ;1      ADDC MDhi TO RES1
UMSTARNEXT  ADD S,S                 ;1 (RLA LSBs) MDlo x 2
            ADDC T,T                ;1 (RLC MSBs) MDhi x 2
            ADD W,W                 ;1 (RLA) NEXT BIT TO TEST
            JNC UMSTARLOOP          ;2 IF BIT IN CARRY: FINISHED    10~ loop
            MOV X,0(PSP)            ;3 low result on stack
            MOV Y,TOS               ;1 high result in TOS
            mNEXT                   ;4 17 words

;https://forth-standard.org/standard/core/toNUMBER
;C  convert a string to double number until count2 = 0 or until not convertible char
;C >NUMBER  ud1lo|ud1hi addr1 count1 -- ud2lo|ud2hi addr2 count2
            FORTHWORD ">NUMBER"
TONUMBER    MOV @PSP,S              ;                           S=adr
            MOV TOS,T               ;                           T=count
TONUMLOOP   MOV.B @S,X              ; -- ud1lo ud1hi x x        X=char
DDIGITQ     SUB.B #30h,  X          ;2                          skip all chars < '0'
            CMP.B #10,X             ;                           char was > "9" ?
            JLO DDIGITQNEXT         ; -- ud1lo ud1hi x x        no: good end
            SUB.B #07,X             ;2                          skip all chars between "9" and "A"
            CMP.B #10,X             ;2                          char was < "A" ?
            JLO TONUMEND            ;2                          yes: bad end
DDIGITQNEXT CMP &BASE,X             ; -- ud1lo ud1hi x x        digit-base
            JHS TONUMEND            ; U>=
UDSTAR      .word 154Dh             ; -- ud1lo ud1hi x x        R-- IP adr count x digit        PSUHM IP,S,T,W,X
            MOV 2(PSP),S            ; -- ud1lo ud1hi x x        S=ud1hi
            MOV &BASE,TOS           ; -- ud1lo ud1hi x base
            MOV #UMSTARNEXT1,IP     ;
UMSTARONE   JMP UMSTAR1             ; ud1hi * base -- x ud3hi   X=ud3lo
UMSTARNEXT1 FORTHtoASM              ; -- ud1lo ud1hi x ud3hi     
            MOV X,2(RSP)            ;                           R-- IP adr count ud3lo digit
            MOV 4(PSP),S            ; -- ud1lo ud1hi x ud3hi    S=ud1lo
            MOV &BASE,TOS           ; -- ud1lo ud1hi x base
            MOV #UMSTARNEXT2,IP     ;
UMSTARTWO   JMP UMSTAR1             ; ud1lo * base -- x ud4hi   X=ud4lo
UMSTARNEXT2 FORTHtoASM              ; -- ud1lo ud1hi x ud4hi    r-- IP adr count ud3lo digit
            ADD @RSP+,X             ; -- ud1lo ud1hi x ud4hi    X = ud4lo+digit = ud2lo
MPLUS       ADDC @RSP+,TOS          ; -- ud1lo ud1hi x ud2hi    TOS = ud4hi+ud3lo+carry = ud2hi
            MOV X,4(PSP)            ; -- ud2lo ud1hi x ud2hi           
            MOV TOS,2(PSP)          ; -- ud2lo ud2hi x x        R-- IP adr count 
            .word 172Bh             ; -- ud2lo ud2hi x x        T=count, S=adr  POPM T,S,IP
TONUMPLUS   ADD #1,S                ;
            SUB #1,T                ;
            JNZ TONUMLOOP           ; -- ud2lo ud2hi x x        S=adr+1, T=count-1, X=ud2lo
TONUMEND    MOV S,0(PSP)            ; -- ud2lo ud2hi adr2 count2
            MOV T,TOS               ; -- ud2lo ud2hi adr2 count2
            mNEXT                   ; 46 words

; convert a string to a signed number
;Z ?NUMBER  c-addr -- n -1      if convert ok ; flag Z=0
;Z          c-addr -- c-addr 0  if convert ko ; flag Z=1
; FORTH 2012 prefixes $, %, # are recognised
; 32 bits numbers (with decimal point) are recognised
; with FIXPOINT_INPUT switched ON, fixed point signed numbers (with a comma) are recognised.
; prefixes # % $ - are processed before calling >NUMBER, decimal point and comma are >NUMBER exits
;            FORTHWORD "?NUMBER"
QNUMBER     MOV #0,S                ;1
            MOV &BASE,T             ;3          T=BASE
            BIC #UF9,SR             ;2          reset flag UF9 used here as decimal point flag
            .word 152Dh             ;5          R-- IP sign base
            MOV #QNUMNEXT,IP        ;2          define >NUMBER return
            SUB #8,PSP              ;1 -- x x x x c-addr
            MOV TOS,6(PSP)          ;3 -- c-addr x x x c-addr
            MOV #0,4(PSP)           ;3
            MOV #0,2(PSP)           ;3 -- c-addr ud=0 x c-addr
            MOV TOS,S               ;1
            MOV.B @S+,T             ;2 -- c-addr ud=0 x x   S=adr, T=count
            MOV.B @S,X              ;2                      X=char
            SUB.B #',',X            ;2
            JHS QSIGN               ;2                      for current base, and for ',' or '.' process
            SUB.B #1,X              ;1
QBINARY     MOV #2,&BASE            ;3                      preset base 2
            ADD.B #8,X              ;1                      '%' + 8 = '-'   binary number ?
            JZ PREFIXED             ;2
QDECIMAL    ADD #8,&BASE            ;4
            ADD.B #2,X              ;1                      '#' + 2 = '%'   decimal number ?
            JZ PREFIXED             ;2
QHEXA       MOV #16,&BASE           ;4
            SUB.B #1,X              ;2                      '$' - 1 = '#'   hex number ?
            JNZ TONUMLOOP           ;2 -- c-addr ud=0 x x   other cases will cause error
PREFIXED    ADD #1,S                ;1
            SUB #1,T                ;1 -- c-addr ud=0 x x   S=adr+1 T=count-1
            MOV.B @S,X              ;2                      X=2th char, W=adr
            SUB.B #',',X            ;2
QSIGN       CMP.B #1,X              ;1
            JNZ TONUMLOOP           ;2                      for positive number and for , or . process
            MOV #-1,2(RSP)          ;3                      R-- IP sign base
            JMP TONUMPLUS           ;2
; ----------------------------------;45
QNUMNEXT    FORTHtoASM              ;  -- c-addr ud2lo-hi addr2 cnt2    R-- IP sign BASE    S=addr2,T=cnt2
            CMP #0,TOS              ;1                                  cnt2=0 ? conversion is ok ?
            JZ QNUMNEXT1            ;2                                  yes
            BIT #UF9,SR             ;2                                  already flagged double ? 
                                    ;                                   ( test to discard repeated points or repeated commas)
            JNZ QNUMNEXT1           ;2                                  abort
            BIS #UF9,SR             ;2                                  set double number flag
; ----------------------------------;

    .IFDEF FIXPOINT_INPUT

QNUMDP      CMP.B #'.',0(S)         ;4                                  rejected char by >NUMBER is a decimal point ?
            JNZ QS15Q16             ;2                                  no
QNUMDPFOUND SUB #2,IP               ;1                                      set >NUMBER return address
            JMP TONUMPLUS           ;2                                      to terminate conversion
QS15Q16     CMP.B #',',0(S)         ;5                                  rejected char by >NUMBER is a comma ?
            JNZ QNUMNEXT1           ;2                                  no
S15Q16      MOV T,W                 ;1 -- c-addr ud2lo x x x            W=cnt2
            MOV &BASE,T             ;3                                  T=current base
            MOV #0,X                ;1 -- c-addr ud2lo x 0 x            init ud2lo' = 0
S15Q16LOOP  MOV X,2(PSP)            ;3 -- c-addr ud2lo ud2lo' ud2lo' x  X = 0(PSP) = ud2lo'   
            SUB.B #1,W              ;1                                  decrement cnt2
            MOV W,X                 ;1                                  X = cnt2-1
            ADD S,X                 ;1                                  X = end_of_string-1, first...
            MOV.B @X,X              ;2                                  X = last char of string, first...
            SUB #30h,X              ;2                                  char --> digit conversion
            CMP.B #10,X             ;2
            JLO QS15Q16DIGI         ;2
            SUB.B #7,X              ;2
            CMP.B #10,X             ;2
            JLO S15Q16EOC           ;2
QS15Q16DIGI CMP T,X                 ;1                                  R-- IP sign BASE    is X a digit ?
            JHS S15Q16EOC           ;2 -- c-addr ud2lo ud2lo' x ud2lo'  if no
            MOV X,0(PSP)            ;3 -- c-addr ud2lo ud2lo' digit x 
            MOV T,TOS               ;1 -- c-addr ud2lo ud2lo' digit     base R-- IP sign base
            .word 152Ch             ;6                                  PUSH S,T,W: R-- IP sign base addr2 base cnt2     
            CALL #MUSMOD            ;4 -- c-addr ud2lo ur uqlo uqhi
            .word 172Ah             ;6                                  restore W,T,S: R-- IP sign BASE     
            JMP S15Q16LOOP          ;2                                  W=cnt
S15Q16EOC   MOV 4(PSP),2(PSP)       ;5 -- c-addr ud2lo ud2lo uqlo x     ud2lo from >NUMBER part1 becomes here ud2hi=S15 part2
            MOV @PSP,4(PSP)         ;4 -- c-addr ud2lo ud2hi x x        uqlo becomes ud2lo
            MOV W,TOS               ;1 -- c-addr ud2lo ud2hi x cnt2
            CMP.B #0,TOS            ;1                                  TOS = 0 if end of conversion char = ',' (happy end)

    .ELSE ; no FIXPOINT_INPUT

QNUMDP      CMP.B #'.',0(S)         ;4                                  rejected char by >NUMBER is a decimal point ?
            JNZ QNUMNEXT1           ;2                                  no
QNUMDPFOUND SUB #2,IP               ;1                                      set >NUMBER return address
            JMP TONUMPLUS           ;2                                      to terminate conversion

    .ENDIF

; ----------------------------------;97
QNUMNEXT1   .word 0172Bh            ;4 -- c-addr ud2lo-hi x cnt2        POPM T,S,IP   S = sign flag = {-1;0}
            MOV S,TOS               ;1 -- c-addr ud2lo-hi x sign
            MOV T,&BASE             ;3
            JZ QNUMOK               ;2 -- c-addr ud2lo-hi x sign        conversion OK
QNUMKO      ADD #6,PSP              ;1 -- c-addr sign
            AND #0,TOS              ;1 -- c-addr ff                     TOS=0 and Z=1 ==> conversion ko
            mNEXT                   ;4
; ----------------------------------;
QNUMOK      ADD #2,PSP              ;1 -- c-addr ud2lo-hi sign
            MOV 2(PSP),4(PSP)       ;  -- udlo udlo udhi sign
            MOV @PSP+,0(PSP)        ;4 -- udlo udhi sign                note : PSP is incremented before write back !!!
            XOR #-1,TOS             ;1 -- udlo udhi inv(sign)
            JNZ QDOUBLE             ;2                                  if jump : TOS=-1 and Z=0 ==> conversion ok
Q2NEGATE    XOR #-1,TOS             ;1 -- udlo udhi tf
            XOR #-1,2(PSP)          ;3 -- dlo-1 dhi-1 tf
            XOR #-1,0(PSP)          ;3 -- dlo-1 udhi tf
            ADD #1,2(PSP)           ;3 -- dlo dhi-1 tf
            ADDC #0,0(PSP)          ;3 -- dlo dhi tf
QDOUBLE     BIT #UF9,SR             ;2      decimal point added ?
            JNZ QNUMEND             ;2      leave double
            ADD #2,PSP              ;1      leave number
QNUMEND     mNEXT                   ;4                           TOS=-1 and Z=0 ==> conversion ok
; ----------------------------------;128 words

    .ENDIF ; HRDWMPY

;https://forth-standard.org/standard/core/EXECUTE
;C EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
            FORTHWORD "EXECUTE"
EXECUTE     MOV TOS,W               ; 1 put word address into W
            MOV @PSP+,TOS           ; 2 fetch new TOS
            MOV W,PC                ; 3 fetch code address into PC

;https://forth-standard.org/standard/core/Comma
;C ,    x --           append cell to dict
            FORTHWORD ","
COMMA       MOV &DDP,W              ;3
            ADD #2,&DDP             ;3
            MOV TOS,0(W)            ;3
            MOV @PSP+,TOS           ;2
            mNEXT                   ;4 15~

;https://forth-standard.org/standard/core/LITERAL
;C LITERAL  (n|d) --        append single numeric literal if compiling state
;           (n|d) --        append double numeric literal if compiling state and if UF9<>0 (not ANS)
            FORTHWORDIMM "LITERAL"  ; immediate
LITERAL     CMP #0,&STATE           ;3
            JZ LITERALEND           ;2 if not immediate, leave n|d on the stack
LITERAL1    MOV &DDP,W              ;3
            ADD #4,&DDP             ;3
            MOV #lit,0(W)           ;4
            MOV TOS,2(W)            ;3
            MOV @PSP+,TOS           ;2
            BIT #UF9,SR             ;2
            BIC #UF9,SR             ;2
            JNZ LITERAL1            ;2
LITERALEND  mNEXT                   ;4 30~

;https://forth-standard.org/standard/core/COUNT
;C COUNT   c-addr1 -- adr len   counted->adr/len
            FORTHWORD "COUNT"
COUNT       SUB #2,PSP              ;1
            ADD #1,TOS              ;1
            MOV TOS,0(PSP)          ;3
            MOV.B -1(TOS),TOS       ;3
            mNEXT                   ;4 15~

; : SETIB SOURCE 2! 0 >IN ! ;       ; org len --        set Input Buffer, shared by INTERPRET and [ELSE]
SETIB       MOV #0,&TOIN            ;
            MOV TOS,&SOURCE_LEN     ; -- org len
            MOV @PSP+,&SOURCE_ADR   ; -- len 
            MOV @PSP+,TOS           ; -- 
            mNEXT                   ;

;C INTERPRET    i*x addr u -- j*x      interpret given buffer
; This is the common factor of EVALUATE and QUIT.
; set addr u as input buffer then parse it word by word
INTERPRET   mDOCOL                  ;
            .word   SETIB           ;               set Input buffer pointers SOURCE_LEN, SOURCE_ORG clear >IN
INTLOOP     .word   FBLANK,WORDD    ; -- c-addr     Z = End Of Line
            FORTHtoASM              ;
            MOV #INTFINDNEXT,IP     ;2              define INTFINDNEXT as FIND return
            JNZ FIND                ;2              if EOL not reached
            JMP DROPEXIT            ;               if EOL reached

INTFINDNEXT FORTHtoASM              ; -- c-addr fl  Z = not found
            MOV TOS,W               ;               W = flag =(-1|0|+1)  as (normal|not_found|immediate)
            MOV @PSP+,TOS           ; -- c-addr
            MOV #INTQNUMNEXT,IP     ;2              define QNUMBER return
            JZ QNUMBER              ;2 c-addr --    if not found search a number
            MOV #INTLOOP,IP         ;2              define (EXECUTE | COMMA) return
            XOR &STATE,W            ;3
            JZ COMMA                ;2 c-addr --    if W xor STATE = 0 compile xt then loop back to INTLOOP
            JNZ EXECUTE             ;2 c-addr --    if W xor STATE <>0 execute xt then loop back to INTLOOP

INTQNUMNEXT FORTHtoASM              ;  -- n|c-addr fl   Z = not a number, SR(UF9) double number request
            MOV @PSP+,TOS           ;2
            MOV #INTLOOP,IP         ;2 -- n|c-addr  define LITERAL return
            JNZ LITERAL             ;2 n --         execute LITERAL then loop back to INTLOOP
NotFoundExe ADD.B #1,0(TOS)         ;3 c-addr --    Not a Number : incr string count to add '?'
            MOV.B @TOS,Y            ;2
            ADD TOS,Y               ;1
            MOV.B #'?',0(Y)         ;5              add '?' to end of word string
            MOV #FQABORTYES,IP      ;2              define COUNT return
            JMP COUNT               ;2 -- addr len  36 words

;https://forth-standard.org/standard/core/EVALUATE
; EVALUATE          \ i*x c-addr u -- j*x  interpret string
            FORTHWORD "EVALUATE"
EVALUATE    MOV #SOURCE_LEN,X       ;2
            MOV @X+,S               ;2 S = SOURCE_LEN
            MOV @X+,T               ;2 T = SOURCE_ADR
            MOV @X+,W               ;2 W = TOIN
            .word 153Dh             ;6 PUSHM IP,S,T,W
            ASMtoFORTH
            .word   INTERPRET
            FORTHtoASM
            MOV @RSP+,&TOIN         ;4
            MOV @RSP+,&SOURCE_ADR   ;4
            MOV @RSP+,&SOURCE_LEN   ;4
            MOV @RSP+,IP            ;2
            mNEXT

    .IFDEF BOOTLOAD ; Boot loader requires Conditional Compilation
;c BOOT  --  jump to bootstrap then continues with (QUIT)
        FORTHWORD "BOOT"
BOOT    MOV #RSTACK,RSP
        MOV #LSTACK,&LEAVEPTR
        MOV #0,&STATE
; ----------------------------------;
; BOOTSTRAP TEST                    ;
; ----------------------------------;
    CMP #0,&SAVE_SYSRSTIV           ; if WARM
    JZ QUIT0                        ; no boostrap
    BIT.B #SD_CD,&SD_CDIN           ; SD_memory in SD_Card module ?
    JNZ QUIT0                       ; no
; ----------------------------------;
; BOOTSTRAP                         ; on SYSRSTIV <> 0
; ----------------------------------;
    SUB #2,PSP                      ;
    MOV TOS,0(PSP)                  ;
    MOV &SAVE_SYSRSTIV,TOS          ;
    MOV #0,&SAVE_SYSRSTIV           ;
    ASMtoFORTH                      ;
    .IFDEF QUIETBOOT                
    .word NOECHO                    ; warning ! your BOOT.4TH must to be finished with ECHO command! 
    .ENDIF
    .word XSQUOTE                   ; -- addr u
    .byte 15,"LOAD\34 BOOT.4TH\34"  ; issues error 2 if no such file...
    .word BRAN,QUIT4                ;
; ----------------------------------;

;https://forth-standard.org/standard/core/QUIT
;c QUIT  --     interpret line by line the input stream, but may be redirected as here:
        FORTHWORD "QUIT"
QUIT    MOV @PC+,PC
        .word   BOOT

        FORTHWORD "(QUIT)"
PARENQUIT

    .ELSE ; no BOOTLOADER, QUIT is not defered
;https://forth-standard.org/standard/core/QUIT
;c QUIT  --     interpret line by line the input stream
        FORTHWORD "QUIT"
QUIT

            MOV #RSTACK,RSP
            MOV #LSTACK,&LEAVEPTR
            MOV #0,&STATE
    .ENDIF
QUIT0       MOV #0,&SAVE_SYSRSTIV   ;
            ASMtoFORTH
QUIT1       .word   XSQUOTE
            .byte   5,13,10,"ok "   ; CR+LF + Forth prompt
QUIT2       .word   TYPE            ; display it
            .word   REFILL
QUIT3       .word   SPACE
QUIT4       .word   INTERPRET
            .word   DEPTH,ZEROLESS
            .word   XSQUOTE
            .byte   13,"stack empty! "
            .word   QABORT
            .word   lit,FRAM_FULL,HERE,ULESS
            .word   XSQUOTE
            .byte   11,"FRAM full! "
            .word   QABORT
            .word   FSTATE,FETCH
            .word   QBRAN,QUIT1     ; case of interpretion state
            .word   XSQUOTE         ; case of compilation state
            .byte   5,13,10,"   "   ; CR+LF + 3 blanks
            .word   BRAN,QUIT2

;https://forth-standard.org/standard/core/ABORT
;C ABORT    i*x --   R: j*x --   clear stack & QUIT
            FORTHWORD "ABORT"
ABORT       MOV #PSTACK,PSP
            JMP QUIT

WIP_DEFER   ; WIPE resets ALL factory defered words
            MOV #PARENWARM,&WARM+2      ; (WARM) is WARM    kill user interrupts init
            MOV #PARENSLEEP,&SLEEP+2    ; (SLEEP) is SLEEP  kill user background task

QAB_DEFER   ; QABORT resets some defered words 
            MOV #PARENEMIT,&EMIT+2      ;4 (EMIT) is EMIT   default console output
            MOV #PARENCR,&CR+2          ;4 (CR) is CR       default CR
            MOV #PARENKEY,&KEY+2        ;4 (KEY) is KEY     default KEY

    .IFDEF DEFER_INPUT                  ;  true if SD_LOADER
            MOV #TIB_ORG,&FCIB+2        ;4 TIB is CIB  (Current Input Buffer)
            MOV #PARENACCEPT,&ACCEPT+2  ;4 (ACCEPT) is ACCEPT
    .ENDIF
    .IFDEF MSP430ASSEMBLER          ; reset all branch labels
            MOV #0,&CLRBW1          ;3
            MOV #0,&CLRBW2          ;3
            MOV #0,&CLRBW3          ;3
            MOV #0,&CLRFW1          ;3
            MOV #0,&CLRFW2          ;3
            MOV #0,&CLRFW3          ;3
    .ENDIF  
            MOV #10,&BASE           ;4
            RET

RefillUSBtime .equ int(frequency*2730) ; 2730*frequency ==> 65520 @ max freq (24MHz)

;Z ?ABORT   f c-addr u --      abort & print msg
;            FORTHWORD "?ABORT"
QABORT      CMP #0,2(PSP)           ; -- f c-addr u         flag test
            JNZ QABORTYES
THREEDROP   ADD #4,PSP
            MOV @PSP+,TOS
            mNEXT

QABORTYES   MOV #4882h,&YEMIT       ;                       restore default YEMIT = set ECHO

    .IFDEF SD_CARD_LOADER           ; close all handles
            MOV &CurrentHdl,T
QABORTCLOSE CMP #0,T
            JZ QABORTCLOSEND
            MOV.B #0,HDLB_Token(T)
            MOV @T,T
            JMP QABORTCLOSE
QABORTCLOSEND
            
    .ENDIF
; ----------------------------------;
QABORTYESNOECHO                     ; <== WARM jumps here, thus, if NOECHO, TERMINAL can be disconnected without freezing the app
; ----------------------------------;
            CALL #QAB_DEFER         ; restore default deferred words ....else WARM and SLEEP.
; ----------------------------------;
QABORTTERM                          ; wait the end of source file downloading
; ----------------------------------;
    .IFDEF TERMINAL3WIRES           ;
            BIT #UCTXIFG,&TERMIFG   ; TX buffer empty ?
            JZ QABORTTERM           ; no
            MOV #17,&TERMTXBUF      ; yes move XON char into TX_buf
    .ENDIF                          ;
    .IFDEF TERMINAL4WIRES           ;
            BIC.B #RTS,&HANDSHAKOUT ; set /RTS low (connected to /CTS pin of UARTtoUSB bridge)
    .ENDIF                          ;
QABORTLOOP  BIC #UCRXIFG,&TERMIFG   ; reset TERMIFG(UCRXIFG)
            MOV #RefillUSBtime,Y    ; 2730*36 = 98 ms : PL2303TA seems to be the slower USB device to refill its TX buffer.
QABUSBLOOPJ MOV #8,X                ; 1~        <-------+
QABUSBLOOPI NOP                     ; 1~        <---+   |
            SUB #1,X                ; 1~            |   |
            JNZ QABUSBLOOPI         ; 2~ > 4~ loop -+   |
            SUB #1,Y                ; 1~                |
            JNZ QABUSBLOOPJ         ; 2~ --> 36~ loop --+
            BIT #UCRXIFG,&TERMIFG   ; 4 new char in TERMXBUF after refill time out ?
            JNZ QABORTLOOP          ; 2 yes, the input stream (download source file) is still active
; ----------------------------------;
; Display WARM/ABORT message        ;   no, the input stream is quiet (end of download source file)
; ----------------------------------;
            mDOCOL                  ;
            .word   XSQUOTE         ; -- c-addr u c-addr1 u1
            .byte   4,27,"[7m"      ;
            .word   TYPE            ; -- c-addr u       set reverse video
ERRLINE     .word   lit,LINE,FETCH,QDUP;       if LINE <> 0
            .word   QBRAN,ERRLINE_END
            .word   XSQUOTE         ;       displays the line where error occured
            .byte   5,"line:"       ;
            .word   TYPE            ;
            .word   ONEMINUS,UDOT   ;
            .word   ECHO            ;
ERRLINE_END .word   TYPE            ; --                type abort message
            .word   XSQUOTE         ; -- c-addr2 u2
            .byte   4,27,"[0m"      ;
            .word   TYPE            ; --                set normal video
; ----------------------------------;
            .word   PWR_STATE       ; remove all words beyond PWR_HERE 
    .IFDEF LOWERCASE                ;
            .word   CAPS_ON         ;
    .ENDIF                          ;
            .word   ABORT           ; no return
; ----------------------------------;

;https://forth-standard.org/standard/core/ABORTq
;C ABORT"  i*x flag -- i*x   R: j*x -- j*x  flag=0
;C         i*x flag --       R: j*x --      flag<>0
            FORTHWORDIMM "ABORT\34"        ; immediate
ABORTQUOTE  mDOCOL
            .word   SQUOTE
            .word   lit,QABORT,COMMA
            .word   EXIT

;https://forth-standard.org/standard/core/Tick
;C '    -- xt           find word in dictionary and leave on stack its execution address
            FORTHWORD "'"
TICK        mDOCOL          ; separator -- xt
            .word   FBLANK,WORDD,FIND    ; Z=1 if not found
            .word   QBRAN,NotFound
            .word   EXIT
NotFound    .word   NotFoundExe          ; in INTERPRET

;https://forth-standard.org/standard/block/bs
; \         --      backslash
; everything up to the end of the current line is a comment.
            FORTHWORDIMM "\\"      ; immediate
BACKSLASH   MOV &SOURCE_LEN,&TOIN       ;
            mNEXT

;-------------------------------------------------------------------------------
; COMPILER
;-------------------------------------------------------------------------------

;https://forth-standard.org/standard/core/Bracket
;C [        --      enter interpretative state
                FORTHWORDIMM "["    ; immediate
LEFTBRACKET     MOV #0,&STATE
                mNEXT

;https://forth-standard.org/standard/core/right-bracket
;C ]        --      enter compiling state
                FORTHWORD "]"
RIGHTBRACKET    MOV  #-1,&STATE
                mNEXT

;https://forth-standard.org/standard/core/BracketTick
;C ['] <name>        --         find word & compile it as literal
            FORTHWORDIMM "[']"      ; immediate word, i.e. word executed during compilation
BRACTICK    mDOCOL
            .word   TICK            ; get xt of <name>
            .word   lit,lit,COMMA   ; append LIT action
            .word   COMMA,EXIT      ; append xt literal

;https://forth-standard.org/standard/core/DEFERStore
;C DEFER!       xt CFA_DEFER --     ; store xt to the address after DODEFER
;                FORTHWORD "DEFER!"
DEFERSTORE  MOV @PSP+,2(TOS)        ; -- CFA_DEFER          xt --> [CFA_DEFER+2]
            MOV @PSP+,TOS           ; --
            mNEXT

;https://forth-standard.org/standard/core/IS
;C IS <name>        xt --
; used as is :
; DEFER DISPLAY                         create a "do nothing" definition (2 CELLS)
; inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
; or in a definition : ... ['] U. IS DISPLAY ...
; KEY, EMIT, CR, ACCEPT and WARM are examples of DEFERred words

; as IS replaces the PFA value of a "PFA word", it may be also used with VARIABLE and CONSTANT words...

            FORTHWORDIMM "IS"       ; immediate
IS          mDOCOL
            .word   FSTATE,FETCH
            .word   QBRAN,IS_EXEC
IS_COMPILE  .word   BRACTICK             ; find the word, compile its CFA as literal
            .word   lit,DEFERSTORE,COMMA ; compile DEFERSTORE
            .word   EXIT
IS_EXEC     .word   TICK,DEFERSTORE     ; find the word, leave its CFA on the stack and execute DEFERSTORE
            .word   EXIT

;https://forth-standard.org/standard/core/IMMEDIATE
;C IMMEDIATE        --   make last definition immediate
            FORTHWORD "IMMEDIATE"
IMMEDIATE   MOV &LAST_NFA,W
            BIS.B #80h,0(W)
            mNEXT

;https://forth-standard.org/standard/core/RECURSE
;C RECURSE  --      recurse to current definition (compile current definition)
            FORTHWORDIMM "RECURSE"  ; immediate
RECURSE     MOV &DDP,X              ;
            MOV &LAST_CFA,0(X)      ;
            ADD #2,&DDP             ;
            mNEXT

;https://forth-standard.org/standard/core/POSTPONE
            FORTHWORDIMM "POSTPONE" ; immediate
POSTPONE    mDOCOL
            .word   FBLANK,WORDD,FIND,QDUP
            .word   QBRAN,NotFound
            .word   ZEROLESS        ; immediate ?
            .word   QBRAN,POST1     ; yes
            .word   lit,lit,COMMA,COMMA
            .word   lit,COMMA
POST1       .word   COMMA,EXIT

;;Z ?REVEAL   --      if no stack mismatch, link this created word in the CURRENT vocabulary
;            FORTHWORD "REVEAL"
QREVEAL     CMP PSP,&LAST_PSP       ; Check SP with its saved value by :
            JZ GOOD_CSP             ; if no stack mismatch.
BAD_CSP     mDOCOL
            .word   XSQUOTE
            .byte   15,"stack mismatch!"
FQABORTYES  .word   QABORTYES

;https://forth-standard.org/standard/core/Semi
;C ;            --      end a colon definition
            FORTHWORDIMM ";"        ; immediate
SEMICOLON   CMP #0,&STATE           ; in interpret mode semicolon becomes a comment separator
            JZ BACKSLASH            ; tip: ";" is transparent to the preprocessor, so semicolon comments are kept in file.4th
            mDOCOL                  ; compile mode
            .word   lit,EXIT,COMMA
            .word   QREVEAL,LEFTBRACKET,EXIT

    .IFDEF NONAME
;https://forth-standard.org/standard/core/ColonNONAME
;CE :NONAME        -- xt
        FORTHWORD ":NONAME"
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV &DDP,TOS
            MOV TOS,W
            MOV #OPCODE,X           ; X = OPCODE as lure for semicolon LAST_THREAD REVEAL
            MOV #ASMTYPE,Y          ; Y = ASMTYPE as lure for semicolon LAST_NFA REVEAL
            CALL #HEADEREND
    .ENDIF 
COLONNEXT
    .SWITCH DTC
    .CASE 1
            MOV #DOCOL1,-4(W)       ; compile CALL rDOCOL
            SUB #2,&DDP             
    .CASE 2
            MOV #DOCOL1,-4(W)       ; compile PUSH IP       3~
            MOV #DOCOL2,-2(W)       ; compile CALL rEXIT
    .CASE 3 ; inlined DOCOL
            MOV #DOCOL1,-4(W)       ; compile PUSH IP       3~
            MOV #DOCOL2,-2(W)       ; compile MOV PC,IP     1~
            MOV #DOCOL3,0(W)        ; compile ADD #4,IP     1~
            MOV #NEXT,+2(W)         ; compile MOV @IP+,PC   4~
            ADD #4,&DDP           
    .ENDCASE ; of DTC
            MOV #-1,&STATE          ; enter compiling state
SAVE_PSP    MOV PSP,&LAST_PSP       ; save PSP for check compiling, used by QREVEAL
            mNEXT

;https://forth-standard.org/standard/core/Colon
;C : <name>     --      begin a colon definition
            FORTHWORD ":"
COLON       PUSH #COLONNEXT         ; define COLONNEXT as RET for HEADER

; HEADER        create an header for a new word. Max count of chars = 126
;               common code for VARIABLE, CONSTANT, CREATE, DEFER, :, MARKER, CODE, ASM.
;               don't link created word in vocabulary.
HEADER      mDOCOL
            .word CELLPLUSALIGN     ;               ALIGN then make room for LFA
            .word FBLANK,WORDD      ;
            FORTHtoASM              ; -- HERE       HERE is the NFA of this new word
            MOV TOS,Y               ;
            MOV.B @TOS+,W           ; -- xxx        W=Count_of_chars    Y=NFA
            BIS.B #1,W              ; -- xxx        W=count is always odd
            ADD.B #1,W              ; -- xxx        W=add one byte for length
            ADD Y,W                 ; -- xxx        W=Aligned_CFA
            MOV &CURRENT,X          ; -- xxx        X=VOC_BODY of CURRENT    Y=NFA
    .SWITCH THREADS
    .CASE   1                       ;               nothing to do
    .ELSECASE                       ;               multithreading add 5~ 4words
            MOV.B @TOS,TOS          ; -- xxx        TOS=first CHAR of new word
            AND #(THREADS-1)*2,TOS  ; -- xxx        TOS= Thread offset
            ADD TOS,X               ; -- xxx        TOS= Thread   X=VOC_PFAx = thread x of VOC_PFA of CURRENT
    .ENDCASE
            MOV @PSP+,TOS           ; --
            MOV @RSP+,IP  
HEADEREND   MOV Y,&LAST_NFA         ; --            NFA --> LAST_NFA            used by QREVEAL, IMMEDIATE
            MOV X,&LAST_THREAD      ; --            VOC_PFAx --> LAST_THREAD    used by QREVEAL
            MOV W,&LAST_CFA         ; --            HERE=CFA --> LAST_CFA       used by DOES>, RECURSE
            ADD #4,W                ; --            by default make room for two words...
            MOV W,&DDP              ; --    
            RET                     ; 23 words, W is the new DDP value )
                                    ;           X is LAST_THREAD       > used by VARIABLE, CONSTANT, CREATE, DEFER and :
                                    ;           Y is NFA               )

;https://forth-standard.org/standard/core/VARIABLE
;C VARIABLE <name>       --                      define a Forth VARIABLE
            FORTHWORD "VARIABLE"
VARIABLE    CALL #HEADER            ; W = DDP = CFA + 2 words
            MOV #DOVAR,-4(W)        ;   CFA = DOVAR
            JMP REVEAL              ;   PFA is undefined

;https://forth-standard.org/standard/core/CONSTANT
;C CONSTANT <name>     n --                      define a Forth CONSTANT (it's also an alias of VALUE)
            FORTHWORD "CONSTANT"
CONSTANT    CALL #HEADER            ; W = DDP = CFA + 2 words
            MOV #DOCON,-4(W)        ;   CFA = DOCON
            MOV TOS,-2(W)           ;   PFA = n
            MOV @PSP+,TOS         
            JMP REVEAL            

;;https://forth-standard.org/standard/core/VALUE
;;( x "<spaces>name" -- )                      define a Forth VALUE
;;Skip leading space delimiters. Parse name delimited by a space. 
;;Create a definition for name with the execution semantics defined below,
;;with an initial value equal to x.
;
;;name Execution: ( -- x )
;;Place x on the stack. The value of x is that given when name was created,
;;until the phrase x TO name is executed, causing a new value of x to be assigned to name.
;
;            FORTHWORD "VALUE"       ; VALUE is an alias of CONSTANT
;            JMP CONSTANT
;
;;TO name Run-time: ( x -- )
;;Assign the value x to name.
;
;            FORTHWORDIMM "TO"       ; TO is an alias of IS
;            JMP IS

; usage : SDIB_ORG IS CIB           ; modify Current_Input_Buffer address to read a SD file sector
;         ...
;         TIB_ORG IS CIB            ; restore Terminal_Input_Buffer address as Current_Input_Buffer address

;https://forth-standard.org/standard/core/CREATE
;C CREATE <name>        --          define a CONSTANT with its next address
; Execution: ( -- a-addr )          ; a-addr is the address of name's data field
;                                   ; the execution semantics of name may be extended by using DOES>
            FORTHWORD "CREATE"
CREATE      CALL #HEADER            ; --        W = DDP
            MOV #DOCON,-4(W)        ;4  CFA = DOCON
            MOV W,-2(W)             ;3  PFA = next address
            JMP REVEAL           

;https://forth-standard.org/standard/core/DOES
;C DOES>    --          set action for the latest CREATEd definition
            FORTHWORD "DOES>"
DOES        MOV &LAST_CFA,W         ; W = CFA of CREATEd word
            MOV #DODOES,0(W)        ; replace CFA (DOCON) by new CFA (DODOES)
            MOV IP,2(W)             ; replace PFA by the address after DOES> as execution address
            MOV @RSP+,IP            ; exit of the new created word
PFA_DEFER   mNEXT

;https://forth-standard.org/standard/core/DEFER
;C DEFER "<spaces>name"   -- 
;Skip leading space delimiters. Parse name delimited by a space. 
;Create a definition for name with the execution semantics defined below.

;name Execution:   --  
;Execute the xt that name is set to execute, i.e. NEXT (nothing), 
;until the phrase ' word IS name is executed, causing a new value of xt to be assigned to name.

            FORTHWORD "DEFER"
DEFER       CALL #HEADER   
            MOV #4030h,-4(W)        ;4  CFA = MOV @PC+,PC = BR...
            MOV #PFA_DEFER,-2(W)    ;4  PFA = address of NEXT: created word does nothing by default
            JMP REVEAL             

    .IFDEF CONDCOMP

; ------------------------------------------------------------------------------
; forthMSP430FR :  CONDITIONNAL COMPILATION
; ------------------------------------------------------------------------------
    .include "forthMSP430FR_CONDCOMP.asm"

            ; compile the words: COMPARE [THEN] [ELSE] [IF] [UNDEFINED] [DEFINED] MARKER 

    .ENDIF  ; CONDCOMP

GOOD_CSP    MOV &LAST_NFA,Y             ; GOOD_CSP is the end of word MARKER
            MOV &LAST_THREAD,X          ;
REVEAL      MOV @X,-2(Y)                ; [LAST_THREAD] --> LFA
            MOV Y,0(X)                  ; LAST_NFA --> [LAST_THREAD]
            mNEXT

; ------------------------------------------------------------------------------
; CONTROL STRUCTURES
; ------------------------------------------------------------------------------
; THEN and BEGIN compile nothing
; DO compile one word
; IF, ELSE, AGAIN, UNTIL, WHILE, REPEAT, LOOP & +LOOP compile two words
; LEAVE compile three words

;https://forth-standard.org/standard/core/IF
;C IF       -- IFadr    initialize conditional forward branch
            FORTHWORDIMM "IF"       ; immediate
IFF         SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            MOV &DDP,TOS            ; -- HERE
            ADD #4,&DDP             ;           compile one word, reserve one word
            MOV #QBRAN,0(TOS)       ; -- HERE   compile QBRAN
CELLPLUS    ADD #2,TOS              ; -- HERE+2=IFadr
            mNEXT

;https://forth-standard.org/standard/core/ELSE
;C ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
            FORTHWORDIMM "ELSE"     ; immediate
ELSS        ADD #4,&DDP             ; make room to compile two words
            MOV &DDP,W              ; W=HERE+4 
            MOV #bran,-4(W)     
            MOV W,0(TOS)            ; HERE+4 ==> [IFadr]
            SUB #2,W                ; HERE+2
            MOV W,TOS               ; -- ELSEadr
            mNEXT

;https://forth-standard.org/standard/core/THEN
;C THEN     IFadr --                resolve forward branch
            FORTHWORDIMM "THEN"     ; immediate
THEN        MOV &DDP,0(TOS)         ; -- IFadr
            MOV @PSP+,TOS           ; --
            mNEXT

;https://forth-standard.org/standard/core/BEGIN
;C BEGIN    -- BEGINadr             initialize backward branch
            FORTHWORDIMM "BEGIN"    ; immediate
BEGIN       MOV #HERE,PC            ; BR HERE

;https://forth-standard.org/standard/core/UNTIL
;C UNTIL    BEGINadr --             resolve conditional backward branch
            FORTHWORDIMM "UNTIL"    ; immediate
UNTIL       MOV #qbran,X    
UNTIL1      ADD #4,&DDP             ; compile two words
            MOV &DDP,W              ; W = HERE
            MOV X,-4(W)             ; compile Bran or qbran at HERE
            MOV TOS,-2(W)           ; compile bakcward adr at HERE+2
            MOV @PSP+,TOS
            mNEXT

;https://forth-standard.org/standard/core/AGAIN
;X AGAIN    BEGINadr --             resolve uncondionnal backward branch
            FORTHWORDIMM "AGAIN"    ; immediate
AGAIN       MOV #bran,X    
            JMP UNTIL1     

;https://forth-standard.org/standard/core/WHILE
;C WHILE    BEGINadr -- WHILEadr BEGINadr
            FORTHWORDIMM "WHILE"    ; immediate
WHILE       mDOCOL
            .word   IFF,SWAP,EXIT

;https://forth-standard.org/standard/core/REPEAT
;C REPEAT   WHILEadr BEGINadr --     resolve WHILE loop
            FORTHWORDIMM "REPEAT"   ; immediate
REPEAT      mDOCOL
            .word   AGAIN,THEN,EXIT

;https://forth-standard.org/standard/core/

;C DO       -- DOadr   L: -- 0
            FORTHWORDIMM "DO"       ; immediate
DO          SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            ADD #2,&DDP             ;   make room to compile xdo
            MOV &DDP,TOS            ; -- HERE+2
            MOV #xdo,-2(TOS)        ;   compile xdo
            ADD #2,&LEAVEPTR        ; -- HERE+2     LEAVEPTR+2
            MOV &LEAVEPTR,W         ;
            MOV #0,0(W)             ; -- HERE+2     L-- 0
            mNEXT

;https://forth-standard.org/standard/core/LOOP
;C LOOP    DOadr --         L-- an an-1 .. a1 0
            FORTHWORDIMM "LOOP"     ; immediate
LOO         MOV #xloop,X            
ENDLOOP     ADD #4,&DDP             ; make room to compile two words
            MOV &DDP,W         
            MOV X,-4(W)             ; xloop --> HERE
            MOV TOS,-2(W)           ; DOadr --> HERE+2
; resolve all "leave" adr
LEAVELOOP   MOV &LEAVEPTR,TOS       ; -- Adr of top LeaveStack cell
            SUB #2,&LEAVEPTR        ; --
            MOV @TOS,TOS            ; -- first LeaveStack value
            CMP #0,TOS              ; -- = value left by DO ?
            JZ ENDLOOPEND         
            MOV W,0(TOS)            ; move adr after loop as UNLOOP adr
            JMP LEAVELOOP         
ENDLOOPEND  MOV @PSP+,TOS         
            mNEXT

;https://forth-standard.org/standard/core/PlusLOOP
;C +LOOP   adrs --   L-- an an-1 .. a1 0
            FORTHWORDIMM "+LOOP"    ; immediate
PLUSLOOP    MOV #xploop,X    
            JMP ENDLOOP      

;https://forth-standard.org/standard/core/LEAVE
;C LEAVE    --    L: -- adrs
            FORTHWORDIMM "LEAVE"    ; immediate
LEAV        MOV &DDP,W              ; compile three words
            MOV #UNLOOP,0(W)        ; [HERE] = UNLOOP
            MOV #BRAN,2(W)          ; [HERE+2] = BRAN
            ADD #6,&DDP             ; [HERE+4] = take word for AfterLOOPadr
            ADD #2,&LEAVEPTR     
            ADD #4,W             
            MOV &LEAVEPTR,X      
            MOV W,0(X)              ; leave HERE+4 on LEAVEPTR stack
            mNEXT

;https://forth-standard.org/standard/core/MOVE
;C MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
            FORTHWORD "MOVE"
MOVE        MOV TOS,W           ; 1
            MOV @PSP+,Y         ; dest adrs
            MOV @PSP+,X         ; src adrs
            MOV @PSP+,TOS       ; pop new TOS
            CMP #0,W         
            JZ MOVE_X           ; already made !
            CMP X,Y             ; Y-X ; dst - src
            JZ MOVE_X           ; already made !
            JC MOVEUP           ; U>= if dst > src
MOVEDOWN    MOV.B @X+,0(Y)      ; if X=src > Y=dst copy W bytes down
            ADD #1,Y        
            SUB #1,W        
            JNZ MOVEDOWN    
            mNEXT
MOVEUP      ADD W,Y             ; start at end
            ADD W,X        
MOVUP1      SUB #1,X       
            SUB #1,Y       
MOVUP2      MOV.B @X,0(Y)       ; if X=src < Y=dst copy W bytes up
            SUB #1,W
            JNZ MOVUP1
MOVE_X      mNEXT

;-------------------------------------------------------------------------------
; WORDS SET for VOCABULARY, not ANS compliant
;-------------------------------------------------------------------------------

;X VOCABULARY       -- create a vocabulary

    .IFDEF VOCABULARY_SET

            FORTHWORD "VOCABULARY"
VOCABULARY  mDOCOL
            .word   CREATE
    .SWITCH THREADS
    .CASE   1
            .word   lit,0,COMMA             ; will keep the NFA of the last word of the future created vocabularies
    .ELSECASE
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

    .ELSECASE   ; = CASE 1
    .ENDCASE
            .word   voclink         ; here, voclink = 0
voclink         .set    $-2

;X  ALSO    --                  make room to put a vocabulary as first in context
    .IFDEF VOCABULARY_SET
            FORTHWORD "ALSO"
    .ENDIF ; VOCABULARY_SET
ALSO        MOV #14,W               ; -- move up 7 words
            MOV #CONTEXT,X          ; X=src
            MOV #CONTEXT+2,Y        ; Y=dst
            JMP MOVEUP              ; src < dst

;X  PREVIOUS   --               pop last vocabulary out of context
    .IFDEF VOCABULARY_SET
            FORTHWORD "PREVIOUS"
    .ENDIF ; VOCABULARY_SET
PREVIOUS    MOV #14,W               ; -- move down 7 words
            MOV #CONTEXT+2,X        ; X=src
            MOV #CONTEXT,Y          ; Y=dst
            JMP MOVEDOWN            ; src > dst

;X ONLY     --      cut context list to access only first vocabulary, ex.: FORTH ONLY
    .IFDEF VOCABULARY_SET
            FORTHWORD "ONLY"
    .ENDIF ; VOCABULARY_SET
ONLY        MOV #0,&CONTEXT+2
            mNEXT

;X DEFINITIONS  --      set last context vocabulary as entry for further defining words
    .IFDEF VOCABULARY_SET
            FORTHWORD "DEFINITIONS"
    .ENDIF ; VOCABULARY_SET
DEFINITIONS  MOV &CONTEXT,&CURRENT
            mNEXT

;-------------------------------------------------------------------------------
; IMPROVED ON/OFF AND RESET
;-------------------------------------------------------------------------------

STATE_DOES  ; execution part of PWR_STATE ; sorry, doesn't restore search order pointers
            .word   FORTH,ONLY,DEFINITIONS
            FORTHtoASM              ; -- BODY       IP is free
            MOV @TOS+,W             ; -- BODY+2     W = old VOCLINK = VLK
            MOV W,&LASTVOC          ; -- BODY+2     restore LASTVOC
            MOV @TOS,TOS            ; -- OLD_DP
            MOV TOS,&DDP            ; -- OLD_DP     restore DP
                                    ; then restore words link(s) with it value < old DP 
    .SWITCH THREADS
    .CASE   1 ; mono thread vocabularies
MARKALLVOC  MOV W,Y                 ; -- OLD_DP      W=VLK   Y=VLK
MRKWORDLOOP MOV -2(Y),Y             ; -- OLD_DP      W=VLK   Y=NFA
            CMP Y,TOS               ; -- OLD_DP      CMP = TOS-Y : OLD_DP-NFA
            JNC MRKWORDLOOP         ;                loop back if TOS<Y : OLD_DP<NFA
            MOV Y,-2(W)             ;                W=VLK   X=THD   Y=NFA   refresh thread with good NFA
            MOV @W,W                ; -- OLD_DP      W=[VLK] = next voclink
            CMP #0,W                ; -- OLD_DP      W=[VLK] = next voclink   end of vocs ?
            JNZ MARKALLVOC          ; -- OLD_DP      W=VLK                   no : loopback

    .ELSECASE ; multi threads vocabularies
MARKALLVOC  MOV #THREADS,IP         ; -- OLD_DP      W=VLK
            MOV W,X                 ; -- OLD_DP      W=VLK   X=VLK
MRKTHRDLOOP MOV X,Y                 ; -- OLD_DP      W=VLK   X=VLK   Y=VLK
            SUB #2,X                ; -- OLD_DP      W=VLK   X=THD (thread ((case-2)to0))
MRKWORDLOOP MOV -2(Y),Y             ; -- OLD_DP      W=VLK   Y=NFA
            CMP Y,TOS               ; -- OLD_DP      CMP = TOS-Y : OLD_DP-NFA
            JNC MRKWORDLOOP         ;               loop back if TOS<Y : OLD_DP<NFA
MARKTHREAD  MOV Y,0(X)              ;               W=VLK   X=THD   Y=NFA   refresh thread with good NFA
            SUB #1,IP               ; -- OLD_DP      W=VLK   X=THD   Y=NFA   IP=CFT-1
            JNZ MRKTHRDLOOP         ;                       loopback to compare NFA in next thread (thread-1)
            MOV @W,W                ; -- OLD_DP      W=[VLK] = next voclink
            CMP #0,W                ; -- OLD_DP      W=[VLK] = next voclink   end of vocs ?
            JNZ MARKALLVOC          ; -- OLD_DP      W=VLK                   no : loopback

    .ENDCASE ; of THREADS           ; -- DDP
            MOV     @PSP+,TOS       ;
            MOV     @RSP+,IP        ;
            mNEXT                   ;

            FORTHWORD "PWR_STATE"   ; executed by power ON, reinitializes dictionary in state defined by PWR_HERE
PWR_STATE   mDODOES                 ; DOES part of MARKER : resets pointers DP, voclink and latest
            .word   STATE_DOES      ; execution vector of PWR_STATE
MARKVOC     .word   lastvoclink     ; initialised by forthMSP430FR.asm as voclink value
MARKDP      .word   ROMDICT         ; initialised by forthMSP430FR.asm as DP value

            FORTHWORD "RST_STATE"   ; executed by <reset>, reinitializes dictionary in state defined by RST_HERE;
RST_STATE   MOV &INIVOC,&MARKVOC    ; INI value saved in FRAM
            MOV &INIDP,&MARKDP      ; INI value saved in FRAM
            JMP PWR_STATE

            FORTHWORD "PWR_HERE"    ; define dictionnary bound for power ON
PWR_HERE    MOV &LASTVOC,&MARKVOC
            MOV &DDP,&MARKDP
            mNEXT

            FORTHWORD "RST_HERE"    ; define dictionnary bound for <reset>...
RST_HERE    MOV &LASTVOC,&INIVOC
            MOV &DDP,&INIDP
            JMP PWR_HERE            ; ...and also for power ON...

            FORTHWORD "WIPE"        ; restore the program as it was in forthMSP430FR.txt file
WIPE        MOV #SIGNATURES,X       ; reset JTAG and BSL signatures   ; unlock JTAG, SBW and BSL
SIGNLOOP    MOV #-1,0(X)            ; reset signature; WARNING ! DON'T CHANGE THIS IMMEDIATE VALUE !
            ADD #2,X
            CMP #INTVECT,X
            JNZ SIGNLOOP
            CALL #WIP_DEFER         ; reinit all DEFERed words
            MOV #ROMDICT,&INIDP     ; reinit this 2 factory values
            MOV #lastvoclink,&INIVOC
            JMP RST_STATE           ; then execute RST_STATE and PWR_STATE

; ------------------------------------------------------------------------------
; forthMSP430FR : WARM
; ------------------------------------------------------------------------------

;Z (WARM)   --      ; init some user variables,
                    ; print start message if ECHO is set,
                    ; then ABORT
            FORTHWORD "(WARM)"
PARENWARM 
;            SUB     #4,PSP
;            MOV     &SYSSNIV,0(PSP)
;            MOV     &SYSUNIV,2(PSP)
            MOV     &SAVE_SYSRSTIV,TOS  ; to display it
            mDOCOL
            .word   XSQUOTE             ;
            .byte   6,13,1Bh,"[7m#"     ; CR + cmd "reverse video" + #
            .word   TYPE                ;
            .word   DOT                 ; display signed SAVE_SYSRSTIV
;            .word   DOT                 ; display SYSSNIV
;            .word   DOT                 ; display SYSUNIV
            .word   XSQUOTE
            .byte   31,"FastForth ",VER," (C)J.M.Thoorens "
            .word   TYPE
            .word   LIT,FRAM_FULL,HERE,MINUS,UDOT
            .word   XSQUOTE         ;
            .byte   11,"bytes free ";
            .word   QABORTYESNOECHO     ; NOECHO state enables any app to execute COLD or WARM without terminal connexion


;Z WARM   --    ; deferred word used to init your application
                ; define this word:  : START ...init app here... LIT RECURSE IS WARM (WARM) ;
            FORTHWORD "WARM"
WARM        MOV @PC+,PC                 ;3
            .word   PARENWARM

;-------------------------------------------------------------------------------
; RESET : Target Init, limited to FORTH usage : I/O, FRAM, RTC
; all others I/O are set as input with pullup resistor
;-------------------------------------------------------------------------------

;Z COLD     --      performs a software reset
            FORTHWORD "COLD"
COLD        MOV #0A500h+PMMSWBOR,&PMMCTL0


RESET
    .include "Target.asm"   ; include target specific init code


; reset all interrupt vectors to RESET vector
            MOV #RESET,W            ; W = reset vector
            MOV #INTVECT,X          ; interrupt vectors base address
RESETINT    MOV W,0(X)           
            ADD #2,X             
            JNZ RESETINT            ; endloop when X = 0

; reset default TERMINAL vector interrupt and LPM0 mode for terminal use
            MOV &INI_TERM,&TERMVEC
            MOV #CPUOFF+GIE,&LPM_MODE

; init RAM
            MOV #RAMSTART,X
INITRAM     MOV #0,0(X)
            ADD #2,X
            CMP #RAMEND,X
            JLO INITRAM             ; 8~ loop
;-------------------------------------------------------------------------------
; RESET : INIT FORTH machine
;-------------------------------------------------------------------------------
            MOV #RSTACK,RSP         ; init return stack
            MOV #PSTACK,PSP         ; init parameter stack
    .SWITCH DTC
    .CASE 1
            MOV #xdocol,rDOCOL      ; 
    .CASE 2
            MOV #EXIT,rEXIT
    .CASE 3                         ; inlined DOCOL, do nothing here
    .ENDCASE
            MOV #RFROM,rDOVAR
            MOV #xdocon,rDOCON
            MOV #xdodoes,rDODOES

            MOV #10,&BASE           ; init BASE
            MOV #-1,&CAPS           ; init CAPS ON

;-------------------------------------------------------------------------------
; RESET : test TERM_TXD before init TERM_UART  I/O
;-------------------------------------------------------------------------------
    BIC #LOCKLPM5,&PM5CTL0          ; activate all previous I/O settings before DEEP_RST test
    MOV &SAVE_SYSRSTIV,Y            ;3
    BIT.B #TXD,&TERM_IN             ; TERM_TXD wired to GND via 4k7 resistor ?
    JNZ TERM_INIT                   ; no
    XOR #-1,Y                       ;1 yes : force DEEP_RST (WIPE + COLD)
    ADD #1,Y                        ;1       to display SAVE_SYSRSTIV as negative value
    MOV Y,&SAVE_SYSRSTIV            ;3 save

TERM_INIT
;-------------------------------------------------------------------------------
; RESET : INIT TERM_UART
;-------------------------------------------------------------------------------
    MOV #0081h,&TERMCTLW0           ; Configure TERM_UART  UCLK = SMCLK

    .include "TERMINALBAUDRATE.asm" ; configure baudrate, no registers used

    BIS.B #TERM_BUS,&TERM_SEL       ; Configure pins TXD & RXD for TERM_UART (PORTx_SEL0 xor PORTx_SEL1)
                                    ; TERM_DIR is controlled by eUSCI_Ax module
    BIC #UCSWRST,&TERMCTLW0         ; release from reset...
    BIS #UCRXIE,&TERMIE             ; ... then enable RX interrupt for wake up on terminal input

;-------------------------------------------------------------------------------
; RESET : Select  POWER_ON|<reset>|DEEP_RST from Y = SAVE_SYSRSTIV
;-------------------------------------------------------------------------------

SelectReset MOV #COLD_END,IP    ; define return of WIPE,RST_STATE,PWR_STATE
            CMP #0Ah,Y          ; reset event = security violation BOR ???? not documented...
            JZ WIPE             ; Add WIPE to this reset to do DEEP_RST     --------------
            CMP #16h,Y          ; reset event > software POR : failure or DEEP_RST request
            JHS WIPE            ; U>= ; Add WIPE to this reset to do DEEP_RST
            CMP #2,Y            ; reset event = Brownout ?
            JNZ RST_STATE       ; else  execute RST_STATE, return to COLD_END
            JZ  PWR_STATE       ; yes   execute PWR_STATE, return to COLD_END

;-------------------------------------------------------------------------------
; RESET : INIT SD_Card option
;-------------------------------------------------------------------------------
COLD_END
    .IFNDEF SD_CARD_LOADER      ;
        .word   WARM            ; the next step
    .ELSE
        FORTHtoASM
        .IFDEF RAM_1K           ; case of MSP430FR57xx
        MOV #0,&CurrentHDL      ; init this FRAM area to pass QABORT
        .ENDIF
        BIT.B #SD_CD,&SD_CDIN   ; SD_memory in SD_Card module ?
        JNZ WARM                ; no
    .include "forthMSP430FR_SD_INIT.asm";
        JMP WARM
    .ENDIF

;-------------------------------------------------------------------------------
; ASSEMBLER OPTION
;-------------------------------------------------------------------------------
    .IFDEF MSP430ASSEMBLER
    .include "forthMSP430FR_ASM.asm"
    .ENDIF

;-------------------------------------------------------------------------------
; SD CARD FAT OPTIONS
;-------------------------------------------------------------------------------
    .IFDEF SD_CARD_LOADER
    .include "forthMSP430FR_SD_LowLvl.asm"  ; SD primitives
    .include "forthMSP430FR_SD_LOAD.asm"    ; SD LOAD driver
    ;---------------------------------------------------------------------------
    ; SD CARD READ WRITE
    ;---------------------------------------------------------------------------
        .IFDEF SD_CARD_READ_WRITE
        .include "forthMSP430FR_SD_RW.asm"  ; SD Read/Write driver
        .ENDIF
        ;-----------------------------------------------------------------------
        ; SD TOOLS
        ;-----------------------------------------------------------------------
        .IFDEF SD_TOOLS
        .include "ADDON/SD_TOOLS.asm"
        .ENDIF
    .ENDIF

;-------------------------------------------------------------------------------
; UTILITY WORDS OPTION
;-------------------------------------------------------------------------------
    .IFDEF UTILITY
    .include "ADDON/UTILITY.asm"
    .ENDIF

;-------------------------------------------------------------------------------
; FIXED POINT OPERATORS OPTION
;-------------------------------------------------------------------------------
    .IFDEF FIXPOINT
    .include "ADDON/FIXPOINT.asm"
    .ENDIF

;-------------------------------------------------------------------------------
; UART to I2C bridge OPTION
;-------------------------------------------------------------------------------
    .IFDEF UARTtoI2C    ; redirects TERMINAL on to I2C address
    .include "ADDON/UART2MI2C.asm" 
    .ENDIF

;-------------------------------------------------------------------------------
; ADD HERE YOUR PROGRAM TO BE INTEGRATED IN CORE (protected against WIPE)
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

;-------------------------------------------------------------------------------
; RESOLVE ASSEMBLY PTR
;-------------------------------------------------------------------------------

    .include "ResolveThreads.mac"


    .org 0FFFEh 
    .word reset

