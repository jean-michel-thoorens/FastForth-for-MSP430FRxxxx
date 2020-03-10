; -*- coding: utf-8 -*-
; http://patorjk.com/software/taag/#p=display&f=Banner&t=Fast Forth

; Fast Forth For Texas Instrument MSP430FRxxxx FRAM devices with UART TERMINAL
; Copyright (C) <2019>  <J.M. THOORENS>
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

;-------------------------------------------------------------------------------
; Vingt fois sur le métier remettez votre ouvrage,
; Polissez-le sans cesse, et le repolissez,
; Ajoutez quelquefois, et souvent effacez.               Boileau, L'Art poétique
;-------------------------------------------------------------------------------
; Purgare ... et repurgare.                    Molière, Le Malade imaginaire ;-)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; SCITE editor: copy https://www.scintilla.org/Sc4xx.exe to \prog\scite.exe
;-------------------------------------------------------------------------------
; MACRO ASSEMBLER AS
; unzip http://john.ccac.rwth-aachen.de:8000/ftp/as/precompiled/i386-unknown-win32/aswcurr.zip to \prog\
;-------------------------------------------------------------------------------
    .listing purecode   ; reduce listing to true conditionnal parts
    MACEXP_DFT noif     ; reduce macros listing to true part
;-------------------------------------------------------------------------------

VER .equ "V305"     ; FORTH version

;===============================================================================
; before assembling or programming you must set TARGET in scite param1 (SHIFT+F8)
; according to the selected (uncommented) TARGET below
;===============================================================================

;===============================================================================
; FAST FORTH has a minimalistic footprint to enable its use from 8k FRAM devices
; kernel size below are for 8MHz, DTC=1, THREADS=1, 4WIRES (RTS) options
;===============================================================================
;    TARGET        ;                                        ;INFO+VECTORS+ MAIN bytes
;MSP_EXP430FR5739  ; compile for MSP-EXP430FR5739 launchpad ; 30 +  96   + 2770 bytes
;MSP_EXP430FR5969  ; compile for MSP-EXP430FR5969 launchpad ; 30 +  96   + 2760 bytes
MSP_EXP430FR5994  ; compile for MSP-EXP430FR5994 launchpad ; 30 +  96   + 2782 bytes
;MSP_EXP430FR6989  ; compile for MSP-EXP430FR6989 launchpad ; 30 +  96   + 2786 bytes
;MSP_EXP430FR4133  ; compile for MSP-EXP430FR4133 launchpad ; 30 +  96   + 2826 bytes
;MSP_EXP430FR2355  ; compile for MSP-EXP430FR2355 launchpad ; 30 +  96   + 2758 bytes
;MSP_EXP430FR2433  ; compile for MSP-EXP430FR2433 launchpad ; 30 +  96   + 2750 bytes
;LP_MSP430FR2476   ; compile for LP_MSP430FR2476  launchpad ; 30 +  96   + 2758 bytes
;CHIPSTICK_FR2433  ; compile for "CHIPSTICK" of M. Ken BOAK ; 30 +  96   + 2750 bytes

; choose DTC (Direct Threaded Code) model, if you don't know, choose 2, for DOxxx routines without scratch register use
DTC .equ 2  ; DTC model 1 : DOCOL = CALL rDOCOL           14 cycles 1 word      shortest DTC model
            ; DTC model 2 : DOCOL = PUSH IP, CALL rEXIT   13 cycles 2 words     best compromize to mix FORTH/ASM code
            ; DTC model 3 : inlined DOCOL                  9 cycles 4 words     fastest

THREADS     .equ 16 ;  1,  2 ,  4 ,  8 ,  16,  32  search entries in dictionnary.
                    ; +0, +28, +48, +56, +90, +154 bytes, usefull to speed up compilation;
                    ; the FORTH interpreter speeds up by about a square root factor of THREADS.

FREQUENCY   .equ 16 ; fully tested at 1,2,4,8,16 MHz (+ 24 MHz for MSP430FR57xx,MSP430FR2355)

;===============================================================================
TERMINALBAUDRATE    .equ 115200 ; choose value considering the frequency and the UART2USB bridge, see explanations below.
TERMINAL3WIRES      ; + 18 bytes    enable 3 wires (GND,TX,RX) with XON/XOFF software flow control (PL2303TA/HXD, CP2102)
TERMINAL4WIRES      ; + 12 bytes    enable 4 wires with hardware flow control on RX with RTS (PL2303TA/HXD, FT232RL)
;TERMINAL5WIRES      ; + 10 bytes    enable 5 wires with hardware flow control on RX/TX with RTS/CTS (PL2303TA/HXD, FT232RL)...
;HALFDUPLEX          ; switch to UART half duplex TERMINAL input
;===============================================================================
TERMINAL_I2C        ; uncomment to select I2C Slave TERMINAL instead of UART TERMINAL
;===============================================================================

;===============================================================================
; MINIMAL ADDONS if you want a canonical FORTH: CORE_COMPLEMENT + CONDCOMP + PROMPT
;===============================================================================
; MINIMAL ADDONS for FAST FORTH: MSP430ASSEMBLER + CONDCOMP
;===============================================================================

;-------------------------------------------------------------------------------
; KERNEL ADDONs that can't be added later
;-------------------------------------------------------------------------------
MSP430ASSEMBLER     ; + 1710 bytes : adds embedded assembler with TI syntax; without, you can do all but bigger and slower...
CONDCOMP            ; +  302 bytes : adds conditionnal compilation [IF] [ELSE] [THEN] [DEFINED] [UNDEFINED]
DOUBLE_INPUT        ; +   58 bytes : adds the interpretation engine for double numbers (numbers with dot)
FIXPOINT_INPUT      ; +  128 bytes : adds the interpretation engine for Q15.16 numbers (numbers with comma)
DEFERRED            ; +  122 bytes : adds DEFER IS :NONAME CODENNM (CODE_No_NaMe).
VOCABULARY_SET      ; +  106 bytes : adds words: VOCABULARY FORTH ASSEMBLER ALSO PREVIOUS ONLY DEFINITIONS (FORTH83)
EXTENDED_MEM        ; +  318 bytes : allows MSP430ASSEMBLER to read/write datas beyond $FFFF.
EXTENDED_ASM        ; + 1488 bytes : adds extended assembler for programming beyond $FFFF.
SD_CARD_LOADER      ; + 1766 bytes : to load source files from SD_card
SD_CARD_READ_WRITE  ; + 1148 bytes : to read, create, write and del files + copy text files from PC to target SD_Card
BOOTLOADER          ; +  128 bytes : includes in WARM the bootloader SD_CARD\BOOT.4TH.
;PROMPT              ; +   22 bytes : to display prompt "ok "
;------------------------------------------------------------------------------- 

;-------------------------------------------------------------------------------
; OPTIONS that can be added later by downloading their source file              >-----------------------+
; however, added here, they are protected against WIPE and Deep Reset.                                  |
;-------------------------------------------------------------------------------                        v
;CORE_COMPLEMENT     ; + 1872 bytes : MINIMAL OPTIONS if you want a conventional FORTH              CORECOMP.f
;FIXPOINT            ; +  422/528 bytes add HOLDS F+ F- F/ F* F#S F. S>F                            FIXPOINT.f
;UTILITY             ; +  434/524 bytes (1/16threads) : add .S .RS WORDS U.R DUMP ?                 UTILITY.f
;SD_TOOLS            ; +  142 bytes for trivial DIR, FAT, CLUSTER and SECTOR view, (adds UTILITY)   SD_TOOLS.f
    .save
    .listing off
;===============================================================================
; Software control flow XON/XOFF configuration:
;===============================================================================
; Launchpad --- UARTtoUSB device
;        RX <-- TX
;        TX --> RX
;       GND <-> GND
;
; TERATERM config terminal:     NewLine receive : LF,
;                               NewLine transmit : CR+LF
;                               Size : 128 chars x 49 lines (adjust lines according to your display)
;
; TERATERM config serial port:  TERMINALBAUDRATE value,
;                               8 bits, no parity, 1 Stop bit,
;                               XON/XOFF flow control,
;                               delay = 0ms/line, 0ms/char
;
; don't forget to save always new TERATERM configuration !

; --------------------------------------------------------------------------------------------
; Only two usb2uart bridges correctly handle XON / XOFF: cp2102 and pl2303.
; --------------------------------------------------------------------------------------------
; the best and cheapest: UARTtoUSB cable with Prolific PL2303HXD (or PL2303TA)
; works well in 3 WIRES (XON/XOFF) and 4WIRES (GND,RX,TX,RTS) config
; --------------------------------------------------------------------------------------------
;       PL2303TA 4 wires CABLE                         PL2303HXD 6 wires CABLE
; pads upside: 3V3,txd,rxd,gnd,5V               pads upside: gnd, 3V3,txd,rxd,5V
;    downside: cts,dcd,dsr,rts,dtr                 downside:     rts,cts
; --------------------------------------------------------------------------------------------
; WARNING ! if you use PL2303TA/HXD cable as supply, open the box before to weld red wire on 3v3 pad !
; --------------------------------------------------------------------------------------------
; up to 134400 Bds  (500kHz,FR5xxx)
; up to 268800 Bds  (1MHz,FR5xxx)
; up to 614400 Bds  (2MHz,FR5xxx)
; up to 1228800 Bds (4MHz,FR5xxx)
; up to 2457600 Bds (8MHz,FR5xxx)
; up to 3MBds       (16MHz,FR5xxx,PL2303TA)
; up to 5MBds       (16MHz,FR5xxx,PL2303HXD with shortened cable) 5MBds at 16MHz, not too lazy !:-)
; up to 6MBds       (24MHz,FR57xx,PL2303HXD with shortened cable)

; UARTtoUSB module with Silabs CP2102 (supply current = 20 mA)
; ---------------------------------------------------------------------------------------------------
; WARNING ! if you use it as supply, buy a CP2102 module with a VCC switch 5V/3V3 and swith on 3V3 !
; ---------------------------------------------------------------------------------------------------
; 9600,19200,38400 (250kHz)
; + 57600 (500kHz)
; + 115200,134400,230400 (1MHz)
; + 460800 (2MHz)
; + 921600 (4MHz,8MHz,16MHz,24MHz)

;===============================================================================
; Hardware control flow configuration: RTS is wired on UART2USB CTS pin
;===============================================================================

; Launchpad <-> UARTtoUSB
;        RX <-- TX
;        TX --> RX
;       RTS --> CTS     (see launchpad.asm for RTS selected pin)
;       GND <-> GND

; RTS pin may be permanently wired on SBWTCK/TEST pin without disturbing SBW 2 wires programming

; TERATERM config terminal      : NewLine receive : LF,
;                                 NewLine transmit : CR+LF
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : TERMINALBAUDRATE value,
;                                 8bits, no parity, 1Stopbit,
;                                 Hardware flow control,
;                                 delay = 0ms/line, 0ms/char

; don't forget : save new TERATERM configuration !

; notice that the control flow seems not necessary for TX (CTS <-- RTS)

; UARTtoUSB module with PL2303TA/HXD
; --------------------------------------------------------------------------------------------
; WARNING ! if you use PL2303TA/HXD cable as supply, open the box before to weld red wire on 3v3 pad !
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


; TERATERM config terminal      : NewLine receive : LF,
;                                 NewLine transmit : CR+LF
;                                 Size : 128 chars x 49 lines (adjust lines to your display)

; TERATERM config serial port   : TERMINALBAUDRATE value,
;                                 8bits, no parity, 1Stopbit,
;                                 Hardware flow control or software flow control or ...no flow control!
;                                 delay = 0ms/line, 0ms/char

; don't forget : save new TERATERM configuration !

; in fact, compared to using a UART USB bridge, only the COMx port is to be updated.
; ------------------------------------------------------------------------------
    .restore
    .include "ThingsInFirst.inc" ; macros, target definitions, init FORTH variables...
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
TIB_LEN     .equ    84      ; | grows up    (ans spec. : TIB >= 80 chars)
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
HOLDS_ORG       .equ TIB_ORG+TIB_LEN

HOLD_BASE       .equ HOLDS_ORG+HOLD_LEN

; ----------------------------------------------------
; RAM_ORG + $1B2 : RAM VARIABLES
; ----------------------------------------------------
HP              .equ HOLD_BASE      ; HOLD ptr
CAPS            .equ HOLD_BASE+2    ; CAPS ON = 32, CAPS OFF = 0
LAST_NFA        .equ HOLD_BASE+4    ; NFA, VOC_PFA, CFA, PSP of last created word
LAST_THREAD     .equ HOLD_BASE+6    ; used by QREVEAL
LAST_CFA        .equ HOLD_BASE+8
LAST_PSP        .equ HOLD_BASE+10
STATE           .equ HOLD_BASE+12   ; Interpreter state
SOURCE          .equ HOLD_BASE+14   ; len, org of input stream
SOURCE_LEN      .equ HOLD_BASE+14
SOURCE_ORG      .equ HOLD_BASE+16
TOIN            .equ HOLD_BASE+18   ; CurrentInputBuffer pointer
DDP             .equ HOLD_BASE+20   ; dictionnary pointer
LASTVOC         .equ HOLD_BASE+22   ; keep VOC-LINK
CONTEXT         .equ HOLD_BASE+24   ; CONTEXT dictionnary space (8 CELLS)
CURRENT         .equ HOLD_BASE+40   ; CURRENT dictionnary ptr
BASE            .equ HOLD_BASE+42
LINE            .equ HOLD_BASE+44   ; line in interpretation (see NOECHO, ECHO)

; --------------------------------------------------------------;
; RAM_ORG + $1E0 : free for user after source file compilation  ;
; --------------------------------------------------------------;

; --------------------------------------------------
; RAM_ORG + $1FC : RAM SD_CARD SD_BUF 4 + 512 bytes
; --------------------------------------------------
SD_BUF_I2CADR   .equ SD_BUF-4
SD_BUF_I2CCNT   .equ SD_BUF-2
SD_BUF          .equ HOLD_BASE+78
SD_BUF_END      .equ SD_BUF + 200h   ; 512bytes

    .org    INFO_ORG
;-------------------------------------------------------------------------------
; INFO(DCBA) >= 256 bytes memory map (FRAM) :
;-------------------------------------------------------------------------------
; FRAM INFO KERNEL CONSTANTS
; --------------------------
INI_THREAD      .word THREADS           ; used by ADDON_UTILITY.f
    .IFDEF TERMINAL_I2C
I2CSLAVEADR     .word 010h              ; on MSP430FR2xxx devices with BSL I2C, Slave address is FFA0h
I2CSLAVEADR1    .word 0
    .ELSE ; TERMINAL_UART
TERMBRW_RST     .word TERMBRW_INI       ; set by TERMINALBAUDRATE.inc
TERMMCTLW_RST   .word TERMMCTLW_INI     ; set by TERMINALBAUDRATE.inc
    .ENDIF ; TERMINAL_I2C
    .IF FREQUENCY = 0.25    
FREQ_KHZ        .word 250               ;
    .ELSEIF FREQUENCY = 0.5 
FREQ_KHZ        .word 500               ;
    .ELSE   
FREQ_KHZ        .word FREQUENCY*1000    ; user use
    .ENDIF ; FREQUENCY  
SAVE_SYSRSTIV   .word 5                 ; to identify reset after compiling kernel
    .IFDEF TERMINAL_I2C
LPM_MODE        .word GIE+LPM4          ; LPM4 is the default mode for I2C TERMINAL
    .ELSE ; TERMINAL_UART
LPM_MODE        .word GIE+LPM0          ; LPM0 is the default mode for UART TERMINAL
;LPM_MODE        .word GIE+LPM1          ; LPM1 is the default mode (disable FLL)
    .ENDIF ; TERMINAL_I2C
INIDP           .word ROMDICT           ; define RST_STATE
INIVOC          .word lastvoclink       ; define RST_STATE
FORTHVERSION    .word VAL(SUBSTR(VER,1,0));
FORTHADDON      .word FADDON            ;
                .word RXON              ; 1814h for user use: CALL &RXON
                .word RXOFF             ; 1816h for user use: CALL &RXOFF
    .IFDEF SD_CARD_LOADER
                .word ReadSectorWX      ; 1818h used by SD_TOOLS.f
        .IFDEF SD_CARD_READ_WRITE
                .word WriteSectorWX     ; 181Ah
        .ELSE
                .word WARM              ;      
        .ENDIF
    .ELSE       
                .word WARM              ;
                .word WARM
    .ENDIF
INT_TERMINAL    .word TERMINAL_INT      ; to init TERM_VEC

    .IFDEF SD_CARD_LOADER
; ---------------------------------------
; VARIABLES that should be in RAM
; ---------------------------------------
        .IF RAM_LEN < 2048              ; if RAM < 2K (FR57xx) the variables below are in INFO space (FRAM)
SD_ORG     .equ INFO_ORG+2Ch            ;
        .ELSE                           ; if RAM >= 2k the variables below are in RAM
SD_ORG     .equ SD_BUF_END+2            ; 1 word guard
    .ENDIF

    .org SD_ORG
; ---------------------------------------
; FAT FileSystemInfos
; ---------------------------------------
FATtype         .equ SD_ORG+0
BS_FirstSectorL .equ SD_ORG+2           ; init by SD_Init, used by RW_Sector_CMD
BS_FirstSectorH .equ SD_ORG+4           ; init by SD_Init, used by RW_Sector_CMD
OrgFAT1         .equ SD_ORG+6           ; init by SD_Init,
FATSize         .equ SD_ORG+8           ; init by SD_Init,
OrgFAT2         .equ SD_ORG+10          ; init by SD_Init,
OrgRootDIR      .equ SD_ORG+12          ; init by SD_Init, (FAT16 specific)
OrgClusters     .equ SD_ORG+14          ; init by SD_Init, Sector of Cluster 0
SecPerClus      .equ SD_ORG+16          ; init by SD_Init, byte size

SD_LOW_LEVEL    .equ SD_ORG+18
; ---------------------------------------
; SD command
; ---------------------------------------
SD_CMD_FRM      .equ SD_LOW_LEVEL       ; SD_CMDx inverted frame ${CRC7,ll,LL,hh,HH,CMD}
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
ClusterL        .equ SD_FAT_LEVEL       ;
ClusterH        .equ SD_FAT_LEVEL+2     ;
NewClusterL     .equ SD_FAT_LEVEL+4     ;
NewClusterH     .equ SD_FAT_LEVEL+6     ;
CurFATsector    .equ SD_FAT_LEVEL+8     ; current FATSector of last free cluster
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

    .IF RAM_LEN < 2048     ; due to the lack of RAM, only 5 handles and PAD replaces SDIB
HandleMax       .equ 5 ; and not 8 to respect INFO size (FRAM)
HandleLenght    .equ 28
HandleEnd       .equ FirstHandle+handleMax*HandleLenght
SD_END          .equ HandleEnd
SDIB_I2CADR     .equ PAD_ORG-4
SDIB_I2CCNT     .equ PAD_ORG-2
SDIB_ORG        .equ PAD_ORG
    .ELSE      ; RAM_Size >= 2k all is in RAM
HandleMax       .equ 8
HandleLenght    .equ 28
HandleEnd       .equ FirstHandle+handleMax*HandleLenght
SDIB_I2CADR     .equ SDIB_ORG-4
SDIB_I2CCNT     .equ SDIB_ORG-2
SDIB_ORG        .equ HandleEnd+4
SDIB_LEN        .equ 84             ; = TIB_LEN = PAD_LEN
SD_END          .equ SDIB_ORG+SDIB_LEN
    .ENDIF ; RAM_Size
SD_LEN          .equ SD_END-SD_ORG
    .ENDIF ; SD_CARD_LOADER

    .org    MAIN_ORG
;-------------------------------------------------------------------------------
; DTCforthMSP430FR5xxx program (FRAM) memory
;-------------------------------------------------------------------------------
; here we place maximum of primitives without associated word FORTH.
; as their addresses are options independent, FORTH can access via declarations made in MSP430xxxx.pat

;###############################################################################################################
;###############################################################################################################
SLEEP       MOV @PC+,PC             ;3  Code Field Address (CFA) of SLEEP
PFASLEEP    .word BODYSLEEP         ;   Parameter Field Address (PFA) of SLEEP, with BODYSLEEP as default exec addr
BODYSLEEP   CALL #RXON              ;4  enable TERMINAL RX
            BIS &LPM_MODE,SR        ;3  enter in LPMx sleep mode with GIE=1
; ----------------------------------;   default FAST FORTH mode (for its input terminal use) : LPM0.

; ### #     # ####### ####### ######  ######  #     # ######  #######  #####     #     # ####### ######  #######
;  #  ##    #    #    #       #     # #     # #     # #     #    #    #     #    #     # #       #     # #
;  #  # #   #    #    #       #     # #     # #     # #     #    #    #          #     # #       #     # #
;  #  #  #  #    #    #####   ######  ######  #     # ######     #     #####     ####### #####   ######  #####
;  #  #   # #    #    #       #   #   #   #   #     # #          #          #    #     # #       #   #   #
;  #  #    ##    #    #       #    #  #    #  #     # #          #    #     #    #     # #       #    #  #
; ### #     #    #    ####### #     # #     #  #####  #          #     #####     #     # ####### #     # #######

; here, FAST FORTH sleeps, waiting any interrupt. 
; And any interruption must interrupt FAST FORTH only here..
; IP,S,T,W,X,Y registers (R13 to R8) are free for any interrupt routine...
; ...and so PSP and RSP stacks with their rules of use.
; remember: in any interrupt routine you must include : BIC #0xF8,0(RSP) before RETI to force SLEEP executing. 
;           You can reuse UF9 UF10 UF11 SR flags saved in 0(RSP)
;           or simply (previous SR flags will be lost) : ADD #2 RSP, then RET instead of RETI

; ==================================;
            JMP SLEEP               ;2  here is the return for any interrupts, else TERMINAL_INT  :-)
;###############################################################################################################
;###############################################################################################################

; ------------------------------------------------------------------------------
; COMPILING OPERATORS
; ------------------------------------------------------------------------------
; Primitive LIT; compiled by LITERAL
; lit      -- x    fetch inline literal to stack
; This is the execution part of LITERAL.
;            FORTHWORD "LIT"
LIT         SUB #2,PSP      ; 2  push old TOS..
            MOV TOS,0(PSP)  ; 3  ..onto stack
            MOV @IP+,TOS    ; 2  fetch new TOS value
NEXT_ADR    MOV @IP+,PC     ; 4  NEXT

; Primitive XSQUOTE; compiled by SQUOTE
; (S")     -- addr u   run-time code to get address and length of a compiled string.
XSQUOTE     SUB #4,PSP      ; 1 -- x x TOS      ; push old TOS on stack
            MOV TOS,2(PSP)  ; 3 -- TOS x x      ; and reserve one cell on stack
            MOV.B @IP+,TOS  ; 2 -- x u          ; u = lenght of string
            MOV IP,0(PSP)   ; 3 -- addr u
            ADD TOS,IP      ; 1 -- addr u       IP=addr+u=addr(end_of_string)
            BIT #1,IP       ; 1 -- addr u       IP=addr+u   Carry set/clear if odd/even
            ADDC #0,IP      ; 1 -- addr u       IP=addr+u aligned
            MOV @IP+,PC     ; 4  16~

; https://forth-standard.org/standard/core/HERE
; HERE    -- addr      returns memory ptr
HERE        SUB #2,PSP
            MOV TOS,0(PSP)
            MOV &DDP,TOS
            MOV @IP+,PC
;-------------------------------------------------------------------------------
; BRANCH OPERATORS
;-------------------------------------------------------------------------------
; Primitive QTBRAN
;Z ?TrueBranch   x --       ; branch if TOS is true (TOS <> 0)
QTBRAN      CMP #0,TOS      ; 1  test TOS value
            MOV @PSP+,TOS   ; 2  pop new TOS value (doesn't change flags)
            JZ SKIPBRAN     ; 2  if TOS was = 0, skip the branch
; Primitive BRAN
;Z branch   --              ;
BRAN        MOV @IP,IP      ; 2  take the branch destination
            MOV @IP+,PC     ; 4  ==> branch taken = 11 cycles
            
; Primitive QFBRAN; compiled by IF UNTIL 
;Z ?FalseBranch   x --      ; branch if TOS is FALSE (TOS = 0)
QFBRAN      CMP #0,TOS      ; 1  test TOS value
            MOV @PSP+,TOS   ; 2  pop new TOS value (doesn't change flags)
            JZ BRAN         ; 2  if TOS was = 0, take the branch
; Primitive SKIPBRAN
;Z SkipBranch   --          ;
SKIPBRAN    ADD #2,IP       ; 1  skip the branch destination
            MOV @IP+,PC     ; 4  ==> branch not taken = 10 cycles

;-------------------------------------------------------------------------------
; LOOP OPERATORS
;-------------------------------------------------------------------------------
; Primitive XDO; compiled by DO         
;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2      run-time code for DO
;                                               n1|u1=limit, n2|u2=index
XDO         MOV #8000h,X    ;2 compute 8000h-limit = "fudge factor"
            SUB @PSP+,X     ;2
            MOV TOS,Y       ;1 loop ctr = index+fudge
            MOV @PSP+,TOS   ;2 pop new TOS
            ADD X,Y         ;1 Y = INDEX
            PUSHM #2,X      ;4 PUSHM X,Y, i.e. PUSHM LIMIT, INDEX
            MOV @IP+,PC     ;4

; Primitive XPLOOP; compiled by +LOOP
;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates, clean up the
; return stack and skip the branch. Else take the inline branch.
XPLOOP      ADD TOS,0(RSP)  ;4 increment INDEX by TOS value
            MOV @PSP+,TOS   ;2 get new TOS, doesn't change flags
XLOOPNEXT   BIT #100h,SR    ;2 is overflow bit set?
            JZ BRAN         ;2 no overflow = loop
            ADD #4,RSP      ;1 empty RSP
            ADD #2,IP       ;1 overflow = loop done, skip branch ofs
            MOV @IP+,PC     ;4 16~ taken or not taken xloop/loop

; Primitive XLOOP; compiled by LOOP
;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates, clean up the
; return stack and skip the branch.  Else take the inline branch.
; Note that LOOP terminates when index=8000h.
XLOOP       ADD #1,0(RSP)   ;4 increment INDEX
            JMP XLOOPNEXT   ;2

; primitive MUSMOD; compiled by ?NUMBER UM/MOD
;-------------------------------------------------------------------------------
; unsigned 32-BIT DiViDend : 16-BIT DIVisor --> 32-BIT QUOTient, 16-BIT REMainder
;-------------------------------------------------------------------------------
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

MUSMOD      MOV TOS,T           ;1 T = DIVlo
            MOV 2(PSP),S        ;3 S = DVDlo
            MOV @PSP,TOS        ;2 TOS = DVDhi
MUSMOD1     MOV #0,W            ;1  W = REMlo = 0
            MOV #32,rDODOES     ;2  init loop count
            CMP #0,TOS          ;1  DVDhi=0 ?
            JNZ MDIV1           ;2  no
; -----------------------------------------
            RRA rDODOES         ;1  yes:loop count / 2
            MOV S,TOS           ;1      DVDhi <-- DVDlo
            MOV #0,S            ;1      DVDlo <-- 0
            MOV #0,X            ;1      QUOTlo <-- 0 (to do QUOThi = 0 at the end of division)
; -----------------------------------------
MDIV1       CMP T,W             ;1  REMlo U>= DIV ?
            JNC MDIV2           ;2  no : carry is reset
            SUB T,W             ;1  yes: REMlo - DIV ; carry is set
MDIV2       ADDC X,X            ;1  RLC quotLO
            ADDC Y,Y            ;1  RLC quotHI
            SUB #1,rDODOES      ;1  Decrement loop counter
            JN ENDMDIV          ;2
            ADD S,S             ;1  RLA DVDlo
            ADDC TOS,TOS        ;1  RLC DVDhi
            ADDC W,W            ;1  RLC REMlo
            JNC MDIV1           ;2
            SUB T,W             ;1  REMlo - DIV
            BIS #1,SR           ;1  SETC
            JMP MDIV2           ;2
ENDMDIV     MOV #xdodoes,rDODOES;2  restore rDODOES
            MOV W,2(PSP)        ;3  REMlo in 2(PSP)
            MOV X,0(PSP)        ;3  QUOTlo in 0(PSP)
            MOV Y,TOS           ;1  QUOThi in TOS
            MOV @RSP+,PC        ;4  35 words, about 473 cycles, not FORTH executable !

; : SETIB SOURCE 2! 0 >IN ! ;       
; SETIB      org len --        set Input Buffer, shared by INTERPRET and [ELSE]
SETIB       MOV TOS,&SOURCE_LEN     ; -- org len
            MOV @PSP+,&SOURCE_ORG   ; -- len
            MOV @PSP+,TOS           ; --
            MOV #0,&TOIN            ;
            MOV @IP+,PC             ;

; REFILL    accept one line from input and leave org len of input buffer
; : REFILL TIB DUP TIB_LEN ACCEPT   ;   -- org len'    shared by QUIT and [ELSE]
REFILL      SUB #6,PSP              ;2
            MOV TOS,4(PSP)          ;3
            MOV #TIB_LEN,TOS        ;2  -- x x len 
            .word 40BFh             ;                   MOV #imm,index(PSP)
CIB_ADR     .word TIB_ORG           ;                   imm=TIB_ORG
            .word 0                 ;4  -- x org len    index=0 ==> MOV #TIB_ORG,0(PSP)
            MOV @PSP,2(PSP)         ;4  -- org org len
            JMP ACCEPT              ;2  org org len -- org len'

XDODOES   ; -- addr         ; 4 for CALL rDODOES       S-- BODY      PFA  R-- 
            SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3 save TOS on parameters stack
            MOV @RSP+,TOS   ; 2 TOS = PFA address of master word, i.e. address of its first cell after DOES>
            PUSH IP         ; 3 save IP on return stack
            MOV @TOS+,IP    ; 2 IP = CFA of Master word, TOS = BODY address of created word
            MOV @IP+,PC     ; 4 Execute Master word

XDOCON                      ; 4 for CALL rDOCON       S-- CTE      PFA  R--       
            SUB #2,PSP      ; 1    
            MOV TOS,0(PSP)  ; 3 save TOS on parameters stack
            MOV @RSP+,TOS   ; 2 TOS = PFA address of master word CONSTANT
FETCH       MOV @TOS,TOS    ; 2 TOS = CONSTANT value
            MOV @IP+,PC     ; 4 execute next word
                            ; 16 = ITC (+4)

    .IF DTC = 1             ; DOCOL = CALL rDOCOL, [rDOCOL] = xdocol
XDOCOL      MOV @RSP+,W     ; 2
            PUSH IP         ; 3     save old IP on return stack
            MOV W,IP        ; 1     set new IP to PFA
            MOV @IP+,PC     ; 4     = NEXT
                            ; 10 cycles
    .ENDIF
;-------------------------------------------------------------------------------
; INTERPRETER INPUT
;-------------------------------------------------------------------------------
    .IFDEF SD_CARD_LOADER
    .include "forthMSP430FR_SD_ACCEPT.asm" ; to enable SD CARD access, adds word SD_ACCEPT
    .ENDIF

    .IFDEF DEFER_ACCEPT
            FORTHWORD "ACCEPT"
;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get line at addr to interpret len' chars
ACCEPT      MOV @PC+,PC             ;3 Code Field Address (CFA) of ACCEPT
PFAACCEPT   .word   BODYACCEPT      ;  Parameter Field Address (PFA) of ACCEPT
BODYACCEPT                          ;  BODY of ACCEPT = default execution of ACCEPT
    .ELSE
            FORTHWORD "ACCEPT"
;https://forth-standard.org/standard/core/ACCEPT
;C ACCEPT  addr addr len -- addr len'  get line at addr to interpret len' chars
ACCEPT
    .ENDIF ; DEFER_ACCEPT

;-------------------------------------------------------------------------------
; SELECT TERMINAL : I2C_SLave, UART_HalfDuplex, UART ; words ACCEPT KEY EMIT ECHO NOECHO
;-------------------------------------------------------------------------------
    .IFDEF TERMINAL_I2C ; FAST FORTH with TERMINAL I/O via I2C_Slave (half duplex)
        .include "forthMSP430FR_TERM_I2C.asm"
    .ELSE
        .include "forthMSP430FR_TERM_UART.asm"
    .ENDIF

            FORTHWORD "TYPE"
;https://forth-standard.org/standard/core/TYPE
;C TYPE    adr len --     type string to terminal
TYPE        CMP #0,TOS              ;1
            JZ TWODROP              ;2                  abort fonction
            PUSH IP                 ;3
            MOV #TYPE_NEXT,IP       ;2
TYPELOOP    MOV @PSP,Y              ;2 -- adr len       Y = adr
            SUB #2,PSP              ;1 -- adr x len
            MOV TOS,0(PSP)          ;3 -- adr len len
            MOV.B @Y+,TOS           ;2 -- adr len char
            MOV Y,2(PSP)            ;3 -- adr+1 len char
            JMP EMIT                ;2+13               all scratch registers must be and are free
TYPE_NEXT   .word $+2               ;  -- adr+1 len
            SUB #2,IP               ;1                  [IP] = TYPE_NEXT
            SUB #1,TOS              ;1 -- adr+1 len-1
            JNZ TYPELOOP            ;2                  30~ EMIT loop
            MOV @RSP+,IP            ;3 -- adr+len 0
TWODROP     ADD #2,PSP              ;1 -- 0
DROP        MOV @PSP+,TOS           ;2 --
            MOV @IP+,PC             ;4

            FORTHWORD "CR"
; https://forth-standard.org/standard/core/CR
; CR      --               send CR to the output device
CR          MOV @PC+,PC             ;3 Code Field Address (CFA) of CR
PFACR       .word   BODYCR          ;  Parameter Field Address (PFA) of CR, with its default value
BODYCR      mDOCOL                  ;  send CR+LF to the default output device
            .word   XSQUOTE
            .byte   2,13,10
            .word   TYPE,EXIT

;-------------------------------------------------------------------------------
; STACK OPERATIONS
;-------------------------------------------------------------------------------
    .IFDEF CORE_COMPLEMENT
            FORTHWORD "DUP"
    .ENDIF
; https://forth-standard.org/standard/core/DUP
; DUP      x -- x x      duplicate top of stack
DUP         SUB #2,PSP      ; 2  push old TOS..
            MOV TOS,0(PSP)  ; 3  ..onto stack
            MOV @IP+,PC     ; 4

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "?DUP"
    .ENDIF
; https://forth-standard.org/standard/core/qDUP
; ?DUP     x -- 0 | x x    DUP if nonzero
QDUP        CMP #0,TOS      ; 2  test for TOS nonzero
            JNZ DUP         ; 2
            MOV @IP+,PC     ; 4

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "2DUP"
    .ENDIF
; https://forth-standard.org/standard/core/TwoDUP
; 2DUP   x1 x2 -- x1 x2 x1 x2   dup top 2 cells
TWODUP      MOV TOS,-2(PSP) ; 3
            MOV @PSP,-4(PSP); 4
            SUB #4,PSP      ; 1
            MOV @IP+,PC     ; 4

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "SWAP"
    .ENDIF
; https://forth-standard.org/standard/core/SWAP
; SWAP     x1 x2 -- x2 x1    swap top two items
SWAP        MOV @PSP,W      ; 2
            MOV TOS,0(PSP)  ; 3
            MOV W,TOS       ; 1
            MOV @IP+,PC     ; 4

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "DROP"
; https://forth-standard.org/standard/core/DROP
; DROP     x --          drop top of stack
            MOV @PSP+,TOS   ; 2
            MOV @IP+,PC     ; 4
 
            FORTHWORD "NIP"
; https://forth-standard.org/standard/core/NIP
; NIP      x1 x2 -- x2         Drop the first item below the top of stack
            ADD #2,PSP      ; 1
            MOV @IP+,PC     ; 4

            FORTHWORD "OVER"
;https://forth-standard.org/standard/core/OVER
;C OVER    x1 x2 -- x1 x2 x1
            MOV TOS,-2(PSP) ; 3 -- x1 (x2) x2
            MOV @PSP,TOS    ; 2 -- x1 (x2) x1
            SUB #2,PSP      ; 1 -- x1 x2 x1
            MOV @IP+,PC     ; 4

            FORTHWORD "ROT"
;https://forth-standard.org/standard/core/ROT
;C ROT    x1 x2 x3 -- x2 x3 x1
            MOV @PSP,W      ; 2 fetch x2
            MOV TOS,0(PSP)  ; 3 store x3
            MOV 2(PSP),TOS  ; 3 fetch x1
            MOV W,2(PSP)    ; 3 store x2
            MOV @IP+,PC     ; 4

            FORTHWORD "DEPTH"
    .ENDIF
; https://forth-standard.org/standard/core/DEPTH
; DEPTH    -- +n        number of items on stack, must leave 0 if stack empty
DEPTH       MOV TOS,-2(PSP)
            MOV #PSTACK,TOS
            SUB PSP,TOS     ; PSP-S0--> TOS
            RRA TOS         ; TOS/2   --> TOS
            SUB #2,PSP      ; post decrement stack...
            MOV @IP+,PC

    .IFDEF CORE_COMPLEMENT
            FORTHWORD ">R"
; https://forth-standard.org/standard/core/toR
; >R    x --   R: -- x   push to return stack
TOR         PUSH TOS
            MOV @PSP+,TOS
            MOV @IP+,PC
    .ENDIF
    .IFDEF CORE_COMPLEMENT
            FORTHWORD "R>"
    .ENDIF
; https://forth-standard.org/standard/core/Rfrom
; R>    -- x    R: x --   pop from return stack
RFROM       SUB #2,PSP      ; 1
            MOV TOS,0(PSP)  ; 3
            MOV @RSP+,TOS   ; 2
            MOV @IP+,PC     ; 4

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "R@"
;https://forth-standard.org/standard/core/RFetch
;C R@    -- x     R: x -- x   fetch from rtn stk
            SUB #2,PSP
            MOV TOS,0(PSP)
            MOV @RSP,TOS
            MOV @IP+,PC
    .ENDIF

;-------------------------------------------------------------------------------
; ARITHMETIC OPERATIONS
;-------------------------------------------------------------------------------
    .IFDEF CORE_COMPLEMENT
            FORTHWORD "-"
    .ENDIF
; https://forth-standard.org/standard/core/Minus
; -      n1/u1 n2/u2 -- n3/u3      n3 = n1-n2
MINUS       SUB @PSP+,TOS   ;2  -- n2-n1
NEGATE      XOR #-1,TOS     ;1
ONEPLUS     ADD #1,TOS      ;1  -- n3 = -(n2-n1) = n1-n2
            MOV @IP+,PC

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "1-"
; https://forth-standard.org/standard/core/OneMinus
; 1-      n1/u1 -- n2/u2     subtract 1 from TOS
            SUB #1,TOS
            MOV @IP+,PC

            FORTHWORD "+"
;https://forth-standard.org/standard/core/Plus
;C +       n1/u1 n2/u2 -- n3/u3     add n1+n2
            ADD @PSP+,TOS
            MOV @IP+,PC

            FORTHWORD "1+"
; https://forth-standard.org/standard/core/OnePlus
; 1+      n1/u1 -- n2/u2       add 1 to TOS
            ADD #1,TOS
            MOV @IP+,PC
    .ENDIF

;-------------------------------------------------------------------------------
; MEMORY OPERATIONS
;-------------------------------------------------------------------------------
    .IFDEF CORE_COMPLEMENT
            FORTHWORD "@"
; https://forth-standard.org/standard/core/Fetch
; @       a-addr -- x   fetch cell from memory
            MOV @TOS,TOS
            MOV @IP+,PC

            FORTHWORD "!"
    .ENDIF
; https://forth-standard.org/standard/core/Store
; !        x a-addr --   store cell in memory
STORE       MOV @PSP+,0(TOS);4
            MOV @PSP+,TOS   ;2
            MOV @IP+,PC     ;4

;-------------------------------------------------------------------------------
; COMPARAISON OPERATIONS
;-------------------------------------------------------------------------------
    .IFDEF CORE_COMPLEMENT
            FORTHWORD "0="
    .ENDIF
; https://forth-standard.org/standard/core/ZeroEqual
; 0=     n/u -- flag    return true if TOS=0
ZEROEQUAL   SUB #1,TOS      ;1 borrow (clear cy) if TOS was 0
            SUBC TOS,TOS    ;1 TOS=-1 if borrow was set
            MOV @IP+,PC

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "0<"
    .ENDIF
; https://forth-standard.org/standard/core/Zeroless
; 0<     n -- flag      true if TOS negative
ZEROLESS    ADD TOS,TOS     ;1 set carry if TOS negative
            SUBC TOS,TOS    ;1 TOS=-1 if carry was clear
INVERT      XOR #-1,TOS     ;1 TOS=-1 if carry was set
            MOV @IP+,PC     ;

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "U<"
    .ENDIF
; https://forth-standard.org/standard/core/Uless
; U<    u1 u2 -- flag       test u1<u2, unsigned
ULESS       SUB @PSP+,TOS   ;2
            JZ ULESSEND     ;2 flag 
            MOV #-1,TOS     ;1 flag Z = 0
            JC ULESSEND     ;2 unsigned
            AND #0,TOS      ;1
ULESSEND    MOV @IP+,PC     ;4

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "="
; https://forth-standard.org/standard/core/Equal
; =      x1 x2 -- flag         test x1=x2
            SUB @PSP+,TOS   ;2
            JZ INVERT       ;2 flag Z will be = 0
            AND #0,TOS      ;1 flag Z = 1
            MOV @IP+,PC     ;4

            FORTHWORD "<"
;https://forth-standard.org/standard/core/less
;C <      n1 n2 -- flag        test n1<n2, signed
            SUB @PSP+,TOS   ;1 TOS=n2-n1
            JZ LESSEND      ;2
            JL TOSFALSE     ;2 signed
TOSTRUE     MOV #-1,TOS     ;1 flag Z = 0
LESSEND     MOV @IP+,PC     ;4

            FORTHWORD ">"
;https://forth-standard.org/standard/core/more
;C >     n1 n2 -- flag         test n1>n2, signed
            SUB @PSP+,TOS   ;2 TOS=n2-n1
            JL TOSTRUE      ;2 --> +5
TOSFALSE    AND #0,TOS      ;1 flag Z = 1
            MOV @IP+,PC     ;4

;-------------------------------------------------------------------------------
; CORE ANS94 complement OPTION
;-------------------------------------------------------------------------------
    .include "ADDON/CORE_ANS.asm"
    .ENDIF ; CORE_COMPLEMENT

;-------------------------------------------------------------------------------
; NUMERIC OUTPUT
;-------------------------------------------------------------------------------
; Numeric conversion is done last digit first, so
; the output buffer is built backwards in memory.

            FORTHWORD "<#"
; https://forth-standard.org/standard/core/num-start
; <#    --       begin numeric conversion (initialize Hold Pointer)
LESSNUM     MOV #HOLD_BASE,&HP
            MOV @IP+,PC

            FORTHWORD "#"
; https://forth-standard.org/standard/core/num
; #     ud1lo ud1hi -- ud2lo ud2hi          convert 1 digit of output
NUM         MOV &BASE,T         ;3                              T = Divisor
NUM1        MOV @PSP,S          ;2 -- DVDlo DVDhi               S = DVDlo
            SUB #2,PSP          ;1 -- x x DVDhi                 TOS = DVDhi
            CALL #MUSMOD1       ;4 -- REMlo QUOTlo QUOThi       T is unchanged
            MOV @PSP+,0(PSP)    ;4 -- QUOTlo QUOThi
TODIGIT     CMP.B #10,W         ;2                              W = REMlo
            JNC TODIGIT1        ;2  jump if U<
            ADD.B #7,W          ;2
TODIGIT1    ADD.B #30h,W        ;2
HOLDW       SUB #1,&HP          ;4  store W=char --> -[HP]
            MOV &HP,Y           ;3
            MOV.B W,0(Y)        ;3
            MOV @IP+,PC         ;4  23 words

            FORTHWORD "#S"
; https://forth-standard.org/standard/core/numS
; #S    udlo udhi -- 0 0       convert remaining digits
NUMS        mDOCOL
            .word   NUM         ;       X=QUOTlo
NUM_RETURN  .word   $+2         ;       next adr
            SUB #2,IP           ;1      restore NUM return
            CMP #0,X            ;1      test ud2lo first (generally <>0)
            JNZ NUM1            ;2      
            CMP #0,TOS          ;1      then test ud2hi (generally =0)
            JNZ NUM1            ;2
EXIT        MOV @RSP+,IP 
            MOV @IP+,PC         ;6 10 words, about 241/417 cycles/char

            FORTHWORD "#>"
; https://forth-standard.org/standard/core/num-end
; #>    udlo:udhi -- c-addr u    end conversion, get string
NUMGREATER  MOV &HP,0(PSP)
            MOV #HOLD_BASE,TOS
            SUB @PSP,TOS
            MOV @IP+,PC

            FORTHWORD "HOLD"
; https://forth-standard.org/standard/core/HOLD
; HOLD  char --        add char to output string
HOLD        MOV.B TOS,W         ;1
            MOV @PSP+,TOS       ;2
            JMP HOLDW           ;15

            FORTHWORD "SIGN"
; https://forth-standard.org/standard/core/SIGN
; SIGN  n --           add minus sign if n<0
SIGN        CMP #0,TOS
            MOV @PSP+,TOS
            MOV.B #'-',W
            JN HOLDW            ; jump if 0<
            MOV @IP+,PC

            FORTHWORD "U."
; https://forth-standard.org/standard/core/Ud
; U.    u --           display u (unsigned)
UDOT        MOV #0,Y            ; 1
DOTTODDOT   SUB #2,PSP          ; 1 convert n|u to d|ud with Y = -1|0
            MOV TOS,0(PSP)      ; 3
            MOV Y,TOS           ; 1
DDOT        PUSH IP             ; paired with EXIT      R-- IP
            PUSH TOS            ; paired with RFROM     R-- IP sign
            AND #-1,TOS         ; clear V, set N
            JGE DDOTNEXT        ; if positive (N=0)
            XOR #-1,0(PSP)      ;4
            XOR #-1,TOS         ;1
            ADD #1,0(PSP)       ;4
            ADDC #0,TOS         ;1
DDOTNEXT    ASMTOFORTH          ;10
            .word   LESSNUM,NUMS
            .word   RFROM,SIGN,NUMGREATER,TYPE
            .word   FBLANK,EMIT,EXIT

            FORTHWORD "."
; https://forth-standard.org/standard/core/d
; .     n --           display n (signed)
DOT         CMP #0,TOS
            JGE UDOT
            MOV #-1,Y
            JMP DOTTODDOT

; ------------------------------------------------------------------------------
; STRINGS PROCESSING
; ------------------------------------------------------------------------------
            FORTHWORDIMM "S\34" ; immediate
; https://forth-standard.org/standard/core/Sq
; S"       --             compile in-line string
SQUOTE      MOV #0,&CAPS        ; CAPS OFF
            mDOCOL
            .word   lit,XSQUOTE,COMMA
SQUOTE1     .word   lit,'"'     ;      separator for WORD
            .word   WORDD       ; -- c-addr (= HERE)
            .word   $+2
            MOV #32,&CAPS       ; CAPS ON
            MOV.B @TOS,TOS      ; -- u
            ADD #1,TOS          ; -- u+1
            BIT #1,TOS          ;1 C = ~Z
            ADDC TOS,&DDP
DROPEXIT    MOV @RSP+,IP
            MOV @PSP+,TOS
            MOV @IP+,PC

            FORTHWORDIMM ".\34" ; immediate
; https://forth-standard.org/standard/core/Dotq
; ."       --              compile string to print
DOTQUOTE    mDOCOL
            .word   SQUOTE
            .word   lit,TYPE,COMMA,EXIT

;-------------------------------------------------------------------------------
; INTERPRETER
;-------------------------------------------------------------------------------
            FORTHWORD "WORD"
; https://forth-standard.org/standard/core/WORD
; WORD   char -- addr        Z=1 if len=0
; parse a word delimited by char separator; by default (CAPS=$20), this "word" is capitalized
; when used by S" (CAPS=0), this "word" will not be capitalized.
WORDD       MOV #SOURCE_LEN,S       ;2 -- separator
            MOV @S+,X               ;2              X = src_len
            MOV @S+,W               ;2              W = src_org
            ADD W,X                 ;1              X = src_end
            ADD @S+,W               ;2              W = src_org + >IN = src_ptr
            MOV @S,Y                ;2              Y = HERE = dst_ptr
SKIPCHARLOO CMP W,X                 ;1              src_ptr = src_end ?
            JZ SKIPCHAREND          ;2              if yes : End Of Line !
            CMP.B @W+,TOS           ;2              does char = separator ?
            JZ SKIPCHARLOO          ;2              if yes; 7~ loop
            SUB #1,W                ;1              move back one the (post incremented) pointer
SCANWORD    MOV #96,T               ;2              T = 96 = ascii(a)-1 (test value set in a register before SCANWORD loop)
            MOV &CAPS,rDODOES       ;3
SCANWORDLOO MOV.B S,0(Y)            ;3              first time make room in dst for word length; next, put char @ dst.
            CMP W,X                 ;1              src_ptr = src_end ?
            JZ SCANWORDEND          ;2              if yes
            MOV.B @W+,S             ;2
            CMP.B S,TOS             ;1              does char = separator ?
            JZ SCANWORDEND          ;2              if yes
            ADD #1,Y                ;1              increment dst just before test loop
            CMP.B S,T               ;1              char U< 'a' ?  ('a'-1 U>= char) this condition is tested at each loop
            JC SCANWORDLOO          ;2              15~ upper case char loop
            CMP.B #123,S            ;2              char U>= 'z'+1 ?
            JC SCANWORDLOO          ;2              loopback if yes
            SUB.B rDODOES,S         ;1              convert a...z to A...Z if CAPS ON (rDODOES=32)
            JMP SCANWORDLOO         ;2              22~ lower case char loop
SCANWORDEND MOV #XDODOES,rDODOES    ;2
SKIPCHAREND SUB &SOURCE_ORG,W       ;3 -- separator W=src_ptr - src_org = new >IN (first char separator next)
            MOV W,&TOIN             ;3              update >IN
            MOV &DDP,TOS            ;3 -- c-addr
            SUB TOS,Y               ;1              Y=Word_Length
            MOV.B Y,0(TOS)          ;3
            MOV @IP+,PC             ;4 -- c-addr    43 words      Z=1 <==> lenght=0 <==> EOL

            FORTHWORD "FIND"        ;  -- c-addr            at transient RAM area (HERE)
; https://forth-standard.org/standard/core/FIND
; FIND   c-addr -- c-addr 0   if not found ; flag Z=1
;                  CFA -1      if found     ; flag Z=0
;                  CFA  1      if immediate ; flag Z=0
; compare WORD at c-addr (HERE)  with each of words in each of listed vocabularies in CONTEXT
; FIND to WORDLOOP  : 14/20 cycles,
; mismatch word loop: 13 cycles on len, +7 cycles on first char,
;                     +10 cycles char loop,
; VOCLOOP           : 12/18 cycles,
; WORDFOUND to end  : 21 cycles.
; note: with 16 threads vocabularies, FIND takes only! 75% of CORETEST.4th processing time
FIND        SUB #2,PSP              ;1 -- ???? c-addr       reserve one cell, not at FINDEND because kill flag Z
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
MAKETHREAD  MOV.B 1(S),Y            ;3 -- ???? VOC_PFA0     S=c-addr Y=first char of c-addr string
            AND.B #(THREADS-1)*2,Y  ;2 -- ???? VOC_PFA0     Y=thread offset
            ADD Y,TOS               ;1 -- ???? VOC_PFAx     TOS = words set entry
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
CHARCOMP    CMP.B @X+,1(W)          ;4                      compare chars
            JNZ WORDLOOP            ;2 -- ???? NFA          20~ word loop on first char mismatch
            ADD #1,W                ;1
            SUB.B #1,Y              ;1                      decr count
            JNZ CHARCOMP            ;2 -- ???? NFA          10~ char loop

WORDFOUND   BIT #1,X                ;1
            ADDC #0,X               ;1
            MOV X,S                 ;1                      S=aligned CFA
            CMP.B #0,0(TOS)         ;3 -- ???? NFA          0(TOS)=NFA_first_char
            MOV #1,TOS              ;1 -- ???? 1            preset immediate flag
            JN FINDEND              ;2 -- ???? 1            jump if negative = immediate
            SUB #2,TOS              ;1 -- ???? -1
FINDEND     MOV S,0(PSP)            ;3 not found: -- c-addr 0                           flag Z=1
            MOV #xdocon,rDOCON      ;2     found: -- xt -1|+1 (not immediate|immediate) flag Z=0
            MOV #xdodoes,rDODOES    ;2
            MOV @IP+,PC             ;4 42/47 words

    .IFDEF MPY_32 ; if 32 bits hardware multiplier

            FORTHWORD ">NUMBER"
; >NUMBER  ud1lo ud1hi addr1 cnt1 -- ud2lo ud2hi addr2 cnt2
; https://forth-standard.org/standard/core/toNUMBER
; ud2 is the unsigned result of converting the characters within the string specified by c-addr1 u1 into digits,
; using the number in BASE, and adding each into ud1 after multiplying ud1 by the number in BASE. 
; Conversion continues left-to-right until a character that is not convertible (including '.'  ','  '_')
; is encountered or the string is entirely converted. c-addr2 is the location of the first unconverted character
; or the first character past the end of the string if the string was entirely converted.
; u2 is the number of unconverted characters in the string.
; An ambiguous condition exists if ud2 overflows during the conversion.
TONUMBER    MOV @PSP+,S             ;2 -- ud1lo ud1hi cnt1  S = addr1
            MOV @PSP+,Y             ;2 -- ud1lo cnt1        Y = ud1hi
            MOV @PSP,X              ;2 -- x cnt1            X = ud1lo
            SUB #4,PSP              ;1 -- x x x cnt
            MOV &BASE,T             ;3
TONUMLOOP   MOV.B @S,W              ;2 -- x x x cnt         S=adr, T=base, W=char, X=udlo, Y=udhi 
DDIGITQ     SUB.B #30h,W            ;2                      skip all chars < '0'
            CMP.B #10,W             ;2                      char was U< 58 (U< ':') ?
            JNC DDIGITQNEXT         ;2                      no
            SUB.B #7,W              ;2
            CMP.B #10,W             ;2
            JNC TONUMEND            ;2 -- x x x cnt         if '9' < char < 'A', then return to QNUMBER with Z=0
DDIGITQNEXT CMP T,W                 ;1                      digit-base
            BIC #Z,SR               ;1                      reset Z before return to QNUMBER because
            JC  TONUMEND            ;2                          with Z=1, QNUMBER conversion would be true :-(
UDSTAR      MOV X,&MPY32L           ;3                      Load 1st operand (ud1lo)
            MOV Y,&MPY32H           ;3                      Load 1st operand (ud1hi)
            MOV T,&OP2              ;3                      Load 2nd operand with BASE
            MOV &RES0,X             ;3                      lo result in X (ud2lo)
            MOV &RES1,Y             ;3                      hi result in Y (ud2hi)
MPLUS       ADD W,X                 ;1                      ud2lo + digit
            ADDC #0,Y               ;1                      ud2hi + carry
TONUMPLUS   ADD #1,S                ;1                      adr+1
            SUB #1,TOS              ;1 -- x x x cnt         cnt-1
            JNZ TONUMLOOP           ;2                      if count <>0
TONUMEND    MOV S,0(PSP)            ;3 -- x x addr2 cnt2
            MOV Y,2(PSP)            ;3 -- x ud2hi addr2 cnt2
            MOV X,4(PSP)            ;3 -- ud2lo ud2hi addr2 cnt2
            MOV @IP+,PC             ;4 42 words

; ?NUMBER makes the interface between INTERPRET and >NUMBER; it's a subset of INTERPRET.
; can't be simplified because also used by assembler.
; convert a string to a signed number; FORTH 2012 prefixes $, %, # are recognized,
; digits separator '_' also.
; with DOUBLE_INPUT switched ON, 32 bits signed numbers (with decimal point) are recognized,
; with FIXPOINT_INPUT switched ON, Q15.16 signed numbers (with comma) are recognized.
; prefixed chars - # % $ are processed before calling >NUMBER,
; chars . , _  are processed as >NUMBER exits.
;Z ?NUMBER  addr -- n|d -1  if convert ok ; flag Z=0, UF9=1 if double
;Z          addr -- addr 0  if convert ko ; flag Z=1
QNUMBER
        .IFDEF DOUBLE_NUMBERS       ;                                   DOUBLE_NUMBERS = DOUBLE_INPUT | FIXPOINT_INPUT
            BIC #UF9,SR             ;2                          reset UF9 used as double number flag
        .ENDIF                      ;
            MOV &BASE,T             ;3                          T=BASE
            MOV #0,S                ;1                          S=sign of result
            PUSHM #3,IP             ;5 R-- IP sign base         PUSH IP,S,T
            MOV #TONUMEXIT,IP       ;2                          set TONUMEXIT as return from >NUMBER
            MOV #0,X                ;1                          X=ud1lo
            MOV #0,Y                ;1                          Y=ud1hi
            SUB #8,PSP              ;1 -- x x x x addr          save TOS and make room for >NUMBER
            MOV TOS,6(PSP)          ;3 -- addr x x x addr
            MOV TOS,S               ;1                          S=addr
            MOV.B @S+,TOS           ;2 -- addr x x x cnt        TOS=count
QNUMLDCHAR  MOV.B @S,W              ;2                          W=char
;            CMP.B W,-1(S)           ;3                          for purists:
;            JZ BADPPFIX             ;2                          if already same prefix
            CMP.B #'-',W            ;2
            JNC QBINARY             ;2                          jump if char < '-'
            JNZ DDIGITQ             ;2 -- addr x x x cnt        jump if char > '-'
            MOV #-1,2(RSP)          ;3 R-- IP sign base         set sign flag
            JMP PREFIXED            ;2
QBINARY     MOV #2,T                ;1                          preset base 2
            SUB.B #'%',W            ;2                          binary number ?
            JZ PREFIXED             ;2
QDECIMAL    ADD #8,T                ;1
            ADD.B #2,W              ;1                          decimal number ?
            JZ PREFIXED             ;2
QHEXA       MOV #16,T               ;2
            SUB.B #1,W              ;1                          hex number ?
            JNZ QNUMNEXT            ;2 -- addr x x x cnt        abort if not recognized prefix
PREFIXED    ADD #1,S                ;1
            SUB #1,TOS              ;1 -- addr x x x cnt-1      S=adr+1 TOS=count-1
            JNZ QNUMLDCHAR          ;2
            JZ  BADPPFIX            ;2                          abort if count = 0, because no number after Prefix !
; ----------------------------------;

TONUMEXIT   .word $+2               ;  -- addr ud2lo-hi addr2 cnt2      R-- IP sign BASE    S=addr2
; ----------------------------------;
            JZ QNUMNEXT             ;2                                  TOS=cnt2, Z=1 if conversion is ok
; ----------------------------------;
            SUB #2,IP               ;                                   redefines TONUMEXIT as >NUMBER return, if loopback applicable
            CMP.B #28h,W            ;                                   rejected char by >NUMBER is a underscore ? ('_'-30h-7 = 28h)
            JNZ BADPPFIX            ;                                   goto next test if no
            CMP #0,4(PSP)           ;                                   authorized underscore ? (udlo <> 0 ?)
            JNZ TONUMPLUS           ;                                   yes loopback to >NUMBER to skip char
BADPPFIX                            ;                                   if Bad Prefix|Postfix, goto QNUMKO
        .IFDEF DOUBLE_NUMBERS       ;                                   DOUBLE_NUMBERS = DOUBLE_INPUT | FIXPOINT_INPUT
            BIT #UF9,SR             ;                                   UF9 already set ? ( when you have typed .. )
            JNZ QNUMNEXT            ;                                   yes, goto QNUMKO
            BIS #UF9,SR             ;2                                  set double number flag
        .ELSE
            BIC #Z,SR               ;                                   case of BADPPFIX without DOUBLE_NUMBERS, Z=0 forces QNUMKO
        .ENDIF
        .IFDEF DOUBLE_INPUT         ;
            CMP.B #0F7h,W           ;2                                  rejected char by >NUMBER is a decimal point ? ('.'-30h-7 = -9)
            JZ TONUMPLUS            ;2                                  yes, loopback to >NUMBER with skip char
        .ENDIF                      ;
        .IFDEF FIXPOINT_INPUT       ;
            CMP.B #0F5h,W           ;2                                  rejected char by >NUMBER is a comma ? (','-30h-7 = -7)
            JNZ QNUMNEXT            ;2                                  no, goto QNUMKO
; ----------------------------------;
S15Q16      MOV TOS,W               ;1 -- addr ud2lo x x x              W=cnt2
            MOV #0,X                ;1 -- addr ud2lo x 0 x              init X = ud2lo' = 0
S15Q16LOOP  MOV X,2(PSP)            ;3 -- addr ud2lo ud2lo' ud2lo' x    0(PSP) = ud2lo'
            SUB.B #1,W              ;1                                  decrement cnt2
            MOV W,X                 ;1                                  X = cnt2-1
            ADD S,X                 ;1                                  X = end_of_string-1,-2,-3...
            MOV.B @X,X              ;2                                  X = last char of string first (reverse conversion)
            SUB.B #30h,X            ;2                                  char --> digit conversion
            CMP.B #10,X             ;2
            JNC QS15Q16DIGI         ;2                                  if 0 <= digit < 10
            SUB.B #7,X              ;2                                  char 
            CMP.B #10,X             ;2                                  to skip all chars between "9" and "A"
            JNC S15Q16EOC           ;2
QS15Q16DIGI CMP T,X                 ;1                                  R-- IP sign BASE    is X a digit ?
            JC S15Q16EOC            ;2 -- addr ud2lo ud2lo' x ud2lo'    if no goto QNUMNEXT (abort then)
            MOV X,0(PSP)            ;3 -- addr ud2lo ud2lo' digit x
            MOV T,TOS               ;1 -- addr ud2lo ud2lo' digit base  R-- IP sign base
            PUSHM #3,S              ;5                                  PUSH S,T,W: R-- IP sign base addr2 base cnt2
            CALL #MUSMOD            ;4 -- addr ud2lo ur uqlo uqhi
            POPM #3,S               ;5                                  restore W,T,S: R-- IP sign BASE
            JMP S15Q16LOOP          ;2                                  W=cnt
S15Q16EOC   MOV 4(PSP),2(PSP)       ;5 -- addr ud2lo ud2hi uqlo x       ud2lo from >NUMBER becomes here ud2hi part of Q15.16
            MOV @PSP,4(PSP)         ;4 -- addr ud2lo ud2hi x x          uqlo becomes ud2lo part of Q15.16
            CMP.B #0,W              ;1                                  count = 0 if end of conversion ok
        .ENDIF ; FIXPOINT_INPUT     ;
; ----------------------------------;
QNUMNEXT    POPM #3,IP              ;5 -- addr ud2lo-hi x x             POPM T,S,IP  S = sign flag = {-1;0}
            MOV S,TOS               ;1 -- addr ud2lo-hi x sign
            MOV T,&BASE             ;3
            JZ QNUMOK               ;2 -- addr ud2lo-hi x sign          conversion OK if Z=1
QNUMKO      
        .IFDEF DOUBLE_NUMBERS       ; 
            BIC #UF9,SR             ;2                                  reset flag UF9, before use as double number flag
        .ENDIF
            ADD #6,PSP              ;1 -- addr sign
            AND #0,TOS              ;1 -- addr ff                       TOS=0 and Z=1 ==> conversion ko
            MOV @IP+,PC             ;4
; ----------------------------------;
        .IFDEF DOUBLE_NUMBERS       ;  -- addr ud2lo-hi x sign 
QNUMOK      ADD #2,PSP              ;1 -- addr ud2lo-hi sign
            MOV 2(PSP),4(PSP)       ;  -- udlo udlo udhi sign
            MOV @PSP+,0(PSP)        ;4 -- udlo udhi sign                note : PSP is incremented before write back.
            XOR #-1,TOS             ;1 -- udlo udhi inv(sign)
            JNZ QDOUBLE             ;2                                  if jump : TOS=-1 and Z=0 ==> conversion ok
QDNEGATE    XOR #-1,TOS             ;1 -- udlo udhi tf
            XOR #-1,2(PSP)          ;3
            XOR #-1,0(PSP)          ;3 -- (dlo dhi)-1 tf
            ADD #1,2(PSP)           ;3
            ADDC #0,0(PSP)          ;3
QDOUBLE     BIT #UF9,SR             ;2 -- dlo dhi tf                    decimal point or comma fixpoint ?
            JNZ QNUMEND             ;2                                  leave double
            ADD #2,PSP              ;1 -- n tf                          leave number
QNUMEND     MOV @IP+,PC             ;4                                  TOS<>0 and Z=0 ==> conversion ok
        .ELSE
QNUMOK      ADD #4,PSP              ;1 -- addr ud2lo sign
            MOV @PSP+,0(PSP)        ;4 -- udlo sign                     note : PSP is incremented before write back !!!
            XOR #-1,TOS             ;1 -- udlo inv(sign)
            JNZ QNUMEND             ;2                                  if jump : TOS=-1 and Z=0 ==> conversion ok
QNEGATE     XOR #-1,0(PSP)          ;3
            ADD #1,0(PSP)           ;3 -- n tf
            XOR #-1,TOS             ;1 -- udlo udhi tf                  TOS=-1 and Z=0
QNUMEND     MOV @IP+,PC             ;4                                  TOS=-1 and Z=0 ==> conversion ok
        .ENDIF ; DOUBLE_NUMBERS     ;
; ----------------------------------;119 words

    .ELSE ; no hardware MPY

            FORTHWORD "UM*"
; T.I. UNSIGNED MULTIPLY SUBROUTINE: U1 x U2 -> Ud
; https://forth-standard.org/standard/core/UMTimes
; UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
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
            MOV @IP+,PC             ;4 17 words

            FORTHWORD ">NUMBER"
; https://forth-standard.org/standard/core/toNUMBER
; ud2 is the unsigned result of converting the characters within the string specified by c-addr1 u1 into digits,
; using the number in BASE, and adding each into ud1 after multiplying ud1 by the number in BASE. 
; Conversion continues left-to-right until a character that is not convertible, including '.', ',' or '_',
; is encountered or the string is entirely converted. c-addr2 is the location of the first unconverted character
; or the first character past the end of the string if the string was entirely converted.
; u2 is the number of unconverted characters in the string.
; An ambiguous condition exists if ud2 overflows during the conversion.
; >NUMBER  ud1lo|ud1hi addr1 count1 -- ud2lo|ud2hi addr2 count2
TONUMBER    MOV @PSP,S              ;2                          S=adr
            MOV TOS,T               ;1                          T=count
            MOV &BASE,W             ;3
TONUMLOOP   MOV.B @S,Y              ;2 -- ud1lo ud1hi x x       S=adr, T=count, W=BASE, Y=char
DDIGITQ     SUB.B #30h,Y            ;2                          skip all chars < '0'
            CMP.B #10,Y             ;2                          char was > "9" ?
            JNC DDIGITQNEXT         ;2 -- ud1lo ud1hi x x       no: good end
            SUB.B #07,Y             ;2                          skip all chars between "9" and "A"
            CMP.B #10,Y             ;2                          char was < "A" ?
            JNC TONUMEND            ;2                          yes: for bad end
DDIGITQNEXT CMP W,Y                 ;1 -- ud1lo ud1hi x x       digit-base
            BIC #Z,SR               ;1                          reset Z before jmp TONUMEND because...
            JC  TONUMEND            ;2                          ...QNUMBER conversion will be true if Z = 1  :-(
UDSTAR      PUSHM #6,IP             ;8 -- ud1lo ud1hi x x       save IP S T W X Y used by UM*   r-- IP adr count base x digit
            MOV 2(PSP),S            ;3 -- ud1lo ud1hi x x       S=ud1hi
            MOV W,TOS               ;1 -- ud1lo ud1hi x base
            MOV #UMSTARNEXT1,IP     ;2
UMSTARONE   JMP UMSTAR1             ;2                          ud1hi * base -- x ud3hi             X=ud3lo
UMSTARNEXT1 .word   $+2             ;  -- ud1lo ud1hi x ud3hi
            MOV X,2(RSP)            ;3                                                          r-- IP adr count base ud3lo digit
            MOV 4(PSP),S            ;3 -- ud1lo ud1hi x ud3hi   S=ud1lo
            MOV 4(RSP),TOS          ;3 -- ud1lo ud1hi x base
            MOV #UMSTARNEXT2,IP     ;2
UMSTARTWO   JMP UMSTAR1             ;2 -- ud1lo ud1hi x ud4hi   X=ud4lo
UMSTARNEXT2 .word   $+2             ;  -- ud1lo ud1hi x ud4hi    
MPLUS       ADD @RSP+,X             ;2 -- ud1lo ud1hi x ud4hi   X=ud4lo+digit=ud2lo             r-- IP adr count base ud3lo
            ADDC @RSP+,TOS          ;2 -- ud1lo ud1hi x ud2hi   TOS=ud4hi+ud3lo+carry=ud2hi     r-- IP adr count base
            MOV X,4(PSP)            ;3 -- ud2lo ud1hi x ud2hi
            MOV TOS,2(PSP)          ;3 -- ud2lo ud2hi x x                                       r-- IP adr count base
            POPM #4,IP              ;6 -- ud2lo ud2hi x x       W=base, T=count, S=adr, IP=prevIP   r-- 
TONUMPLUS   ADD #1,S                ;1                           
            SUB #1,T                ;1
            JNZ TONUMLOOP           ;2 -- ud2lo ud2hi x x       S=adr+1, T=count-1, W=base     68 cycles char loop
TONUMEND    MOV S,0(PSP)            ;3 -- ud2lo ud2hi adr2 count2
            MOV T,TOS               ;1 -- ud2lo ud2hi adr2 count2
            MOV @IP+,PC             ;4 50/82 words/cycles, W = BASE

; ?NUMBER makes the interface between >NUMBER and INTERPRET; it's a subset of INTERPRET.
; convert a string to a signed number; FORTH 2012 prefixes $, %, # are recognized
; digits separator '_' is recognized
; with DOUBLE_INPUT switched ON, 32 bits signed numbers (with decimal point) are recognized
; with FIXPOINT_INPUT switched ON, Q15.16 signed numbers (with comma) are recognized.
; prefixes # % $ - are processed before calling >NUMBER
; chars . , _ are processed as >NUMBER exits
;Z ?NUMBER  addr -- n|d -1  if convert ok ; flag Z=0, UF9=1 if double
;Z          addr -- addr 0  if convert ko ; flag Z=1
QNUMBER
        .IFDEF DOUBLE_NUMBERS       ;                                   DOUBLE_NUMBERS = DOUBLE_INPUT | FIXPOINT_INPUT
            BIC #UF9,SR             ;2                          reset flag UF9, before use as double number flag
        .ENDIF                      ;
            MOV &BASE,T             ;3          T=BASE
            MOV #0,S                ;1
            PUSHM #3,IP             ;5          R-- IP sign base (push IP,S,T)
            MOV #TONUMEXIT,IP       ;2          define >NUMBER return
            MOV T,W                 ;1          W=BASE
            SUB #8,PSP              ;1 -- x x x x addr
            MOV TOS,6(PSP)          ;3 -- addr x x x addr
            MOV #0,4(PSP)           ;3
            MOV #0,2(PSP)           ;3 -- addr ud=0 x addr
            MOV TOS,S               ;1
            MOV.B @S+,T             ;2 -- addr ud=0 x x     S=adr, T=count
QNUMLDCHAR  MOV.B @S,Y              ;2                      Y=char
;            CMP.B W,-1(S)           ;3
;            JZ BADPPFIX             ;2                          if already same Prefix
            CMP.B #'-',Y            ;2
            JNC QBINARY             ;2                      if char < '-'
            JNZ DDIGITQ             ;2                      if char > '-'
            MOV #-1,2(RSP)          ;3                      R-- IP sign base
            JMP PREFIXED            ;2
QBINARY     MOV #2,W                ;1                      preset base 2
            SUB.B #'%',Y            ;2                      binary number ?
            JZ PREFIXED             ;2
QDECIMAL    ADD #8,W                ;1
            ADD.B #2,Y              ;1                      decimal number ?
            JZ PREFIXED             ;2
QHEXA       MOV #16,W               ;1
            SUB.B #1,Y              ;2                      hex number ?
            JNZ QNUMNEXT            ;2 -- addr ud=0 x x     abort if not recognized prefix
PREFIXED    CMP.B #2,T              ;
            JNC QNUMNEXT            ;                       abort if T = 1 <==> no char after prefix!
            ADD #1,S                ;1
            SUB #1,T                ;1 -- addr ud=0 x x     S=adr+1 T=count-1
            JNZ QNUMLDCHAR          ;2
            JZ  BADPPFIX            ;2                      abort if count = 0, because no number after Prefix !
; ----------------------------------;42

TONUMEXIT   .word   $+2             ;  -- addr ud2lo-hi addr2 cnt2      R-- IP sign BASE    S=addr2,T=cnt2
; ----------------------------------;
            JZ QNUMNEXT             ;2                                  if conversion is ok
; ----------------------------------;
            SUB #2,IP
            CMP.B #28h,Y            ;                                   rejected char by >NUMBER is a underscore ?
            JNZ BADPPFIX            ;                                   goto next test if no
            CMP #0,4(PSP)           ;                                   authorized underscore ? (udlo <> 0)
            JNZ TONUMPLUS           ;                                   yes loopback to >NUMBER to skip char
BADPPFIX                            ;                                   if Bad Prefix|Postfix, goto QNUMKO
        .IFDEF DOUBLE_NUMBERS       ;                                   DOUBLE_NUMBERS = DOUBLE_INPUT | FIXPOINT_INPUT
            BIT #UF9,SR             ;                                   UF9 already set ? ( when you have typed .. )
            JNZ QNUMNEXT            ;                                   yes, goto QNUMKO
            BIS #UF9,SR             ;2                                  set double number flag
        .ELSE
            BIC #Z,SR               ;                                   case of BADPPFIX without DOUBLE_NUMBERS, Z=0 forces QNUMKO
        .ENDIF
        .IFDEF DOUBLE_INPUT
            CMP.B #0F7h,Y           ;2                                  rejected char by >NUMBER is a decimal point ?
            JZ TONUMPLUS            ;2                                  to terminate conversion
        .ENDIF
        .IFDEF FIXPOINT_INPUT       ;
            CMP.B #0F5h,Y           ;2                                  rejected char by >NUMBER is a comma ?
            JNZ QNUMNEXT            ;2                                  no, goto QNUMKO
; ----------------------------------;
S15Q16      MOV #0,X                ;1 -- addr ud2lo x 0 x              init ud2lo' = 0
S15Q16LOOP  MOV X,2(PSP)            ;3 -- addr ud2lo ud2lo' ud2lo' x    X = 0(PSP) = ud2lo'
            SUB.B #1,T              ;1                                  decrement cnt2
            MOV T,X                 ;1                                  X = cnt2-1
            ADD S,X                 ;1                                  X = end_of_string-1, first...
            MOV.B @X,X              ;2                                  X = last char of string, first...
            SUB.B #30h,X            ;2                                  char --> digit conversion
            CMP.B #10,X             ;2
            JNC QS15Q16DIGI         ;2
            SUB.B #7,X              ;2
            CMP.B #10,X             ;2
            JNC S15Q16EOC           ;2
QS15Q16DIGI CMP W,X                 ;1                                  R-- IP sign BASE, W=BASE,    is X a digit ?
            JC  S15Q16EOC           ;2 -- addr ud2lo ud2lo' x ud2lo'    if no
            MOV X,0(PSP)            ;3 -- addr ud2lo ud2lo' digit x
            MOV W,TOS               ;1 -- addr ud2lo ud2lo' digit base  R-- IP sign base
            PUSHM #3,S              ;5                                  PUSH S,T,W: R-- IP sign base addr2 cnt2 base
            CALL #MUSMOD            ;4 -- addr ud2lo ur uqlo uqhi
            POPM #3,S               ;5                                  restore W,T,S: R-- IP sign BASE
            JMP S15Q16LOOP          ;2                                  W=cnt
S15Q16EOC   MOV 4(PSP),2(PSP)       ;5 -- addr ud2lo ud2lo uqlo x       ud2lo from >NUMBER part1 becomes here ud2hi=S15 part2
            MOV @PSP,4(PSP)         ;4 -- addr ud2lo ud2hi x x          uqlo becomes ud2lo
            CMP.B #0,T              ;1                                  cnt2 = 0 if end of conversion ok
        .ENDIF ; FIXPOINT_INPUT     ;
; ----------------------------------;97
QNUMNEXT    POPM #3,IP              ;4 -- addr ud2lo-hi x cnt2          POPM T,S,IP   S = sign flag = {-1;0}
            MOV S,TOS               ;1 -- addr ud2lo-hi x sign
            MOV T,&BASE             ;3
            JZ QNUMOK               ;2 -- addr ud2lo-hi x sign          conversion OK
QNUMKO      
        .IFDEF DOUBLE_NUMBERS
            BIC #UF9,SR
        .ENDIF
            ADD #6,PSP              ;1 -- addr sign
            AND #0,TOS              ;1 -- addr ff                       TOS=0 and Z=1 ==> conversion ko
            MOV @IP+,PC             ;4
; ----------------------------------;
        .IFDEF DOUBLE_NUMBERS
QNUMOK      ADD #2,PSP              ;1 -- addr ud2lo ud2hi sign
            MOV 2(PSP),4(PSP)       ;  -- udlo udlo udhi sign
            MOV @PSP+,0(PSP)        ;4 -- udlo udhi sign                note : PSP is incremented before write back !!!
            XOR #-1,TOS             ;1 -- udlo udhi inv(sign)
            JNZ QDOUBLE             ;2                                  if jump : TOS=-1 and Z=0 ==> conversion ok
Q2NEGATE    XOR #-1,TOS             ;1 -- udlo udhi tf
            XOR #-1,2(PSP)          ;3
            XOR #-1,0(PSP)          ;3
            ADD #1,2(PSP)           ;3
            ADDC #0,0(PSP)          ;3 -- dlo dhi tf
QDOUBLE     BIT #UF9,SR             ;2 -- dlo dhi tf                decimal point added ?
            JNZ QNUMEND             ;2 -- dlo dhi tf                leave double
            ADD #2,PSP              ;1 -- dlo tf                    leave number, Z=0
QNUMEND     MOV @IP+,PC             ;4                              TOS=-1 and Z=0 ==> conversion ok
        .ELSE
QNUMOK      ADD #4,PSP              ;1 -- addr ud2lo sign
            MOV @PSP+,0(PSP)        ;4 -- udlo sign                note : PSP is incremented before write back !!!
            XOR #-1,TOS             ;1 -- udlo udhi inv(sign)
            JNZ QNUMEND             ;2                                  if jump : TOS=-1 and Z=0 ==> conversion ok
QNEGATE     XOR #-1,0(PSP)          ;3
            ADD #1,0(PSP)           ;3 -- n tf
            XOR #-1,TOS             ;1 -- udlo udhi tf              TOS=-1 and Z=0
QNUMEND     MOV @IP+,PC             ;4                              TOS=-1 and Z=0 ==> conversion ok
        .ENDIF ; DOUBLE_NUMBERS

    .ENDIF ; of Hardware/Software MPY

;-------------------------------------------------------------------------------
; DICTIONARY MANAGEMENT
;-------------------------------------------------------------------------------
            FORTHWORD ","
; https://forth-standard.org/standard/core/Comma
; ,    x --           append cell to dict
COMMA       MOV &DDP,W              ;3
            MOV TOS,0(W)            ;3
            ADD #2,&DDP             ;3
            MOV @PSP+,TOS           ;2
            MOV @IP+,PC             ;4 15~

        .IFDEF CORE_COMPLEMENT
            FORTHWORD "ALLOT"
; https://forth-standard.org/standard/core/ALLOT
; ALLOT   n --         allocate n bytes
            ADD TOS,&DDP
            MOV @PSP+,TOS
            MOV @IP+,PC

            FORTHWORD "EXECUTE"
; https://forth-standard.org/standard/core/EXECUTE
; EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
            JMP EXECUTE
        .ENDIF

            FORTHWORDIMM "LITERAL"  ; immediate
; https://forth-standard.org/standard/core/LITERAL
; LITERAL  n --        append single numeric literal if compiling state
;          d --        append two numeric literals if compiling state and UF9<>0 (not ANS)
LITERAL     CMP #0,&STATE           ;3
    .IFDEF DOUBLE_NUMBERS           ; are recognized
            JZ LITERAL2             ;2 if interpreting state, clear UF9 flag then NEXT
LITERAL1    MOV &DDP,W              ;3
            ADD #4,&DDP             ;3
            MOV #lit,0(W)           ;4
            MOV TOS,2(W)            ;3
            MOV @PSP+,TOS           ;2
            BIT #UF9,SR             ;2 double number ?
LITERAL2    BIC #UF9,SR             ;2    in all case, clear UF9
            JZ LITERALEND           ;2 no
            MOV 2(W),X              ;3 yes, invert literals
            MOV TOS,2(W)            ;3
            MOV X,TOS               ;1
            JMP LITERAL1            ;2
    .ELSE
            JZ LITERALEND           ;2 if interpreting state, do nothing
LITERAL1    MOV &DDP,W              ;3
            ADD #4,&DDP             ;3
            MOV #lit,0(W)           ;4
            MOV TOS,2(W)            ;3
            MOV @PSP+,TOS           ;2
    .ENDIF
LITERALEND  MOV @IP+,PC             ;4

            FORTHWORD "COUNT"
; https://forth-standard.org/standard/core/COUNT
; COUNT   c-addr1 -- adr len   counted->adr/len
COUNT       SUB #2,PSP              ;1
            ADD #1,TOS              ;1
            MOV TOS,0(PSP)          ;3
            MOV.B -1(TOS),TOS       ;3
            MOV @IP+,PC             ;4 15~

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "BL"
    .ENDIF
; https://forth-standard.org/standard/core/BL
; BL      -- char            an ASCII space
FBLANK       CALL rDOCON
            .word   20h

            FORTHWORD "INTERPRET"
; INTERPRET    i*x addr u -- j*x      interpret given buffer
; This is the common factor of EVALUATE and QUIT.
; set addr u as input buffer then parse it word by word
INTERPRET   mDOCOL                  ;
            .word   SETIB
INTLOOP     .word   FBLANK,WORDD    ; -- c-addr     Z = End Of Line
            .word   $+2             ;
            JZ DROPEXIT             ;2              Z=1, EOL reached
            MOV #INTFINDNEXT,IP     ;2              define INTFINDNEXT as FIND return
            JMP FIND                ;2              Z=0, EOL not reached
INTFINDNEXT .word   $+2             ; -- c-addr fl  Z = not found
            MOV TOS,W               ;               W = flag =(-1|0|+1)  as (normal|not_found|immediate)
            MOV @PSP+,TOS           ; -- c-addr
            MOV #INTQNUMNEXT,IP     ;2              define QNUMBER return
            JZ QNUMBER              ;2 c-addr --    Z=1, not found, search a number
            MOV #INTLOOP,IP         ;2              define (EXECUTE | COMMA) return
            XOR &STATE,W            ;3
            JZ COMMA                ;2 c-addr --    if W xor STATE = 0 compile xt then loop back to INTLOOP
EXECUTE     PUSH TOS                ; 3
            MOV @PSP+,TOS           ; 2 fetch new TOS
            MOV @RSP+,PC            ; 4 xt --> PC

INTQNUMNEXT .word   $+2             ;  -- n|c-addr fl   Z = not a number, SR(UF9) double number request
            MOV @PSP+,TOS           ;2
            MOV #INTLOOP,IP         ;2 -- n|c-addr  define LITERAL return
            JNZ LITERAL             ;2 n --         Z=0, is a number, execute LITERAL then loop back to INTLOOP

NotFoundExe ADD.B #1,0(TOS)         ;3 c-addr --    Z=1, Not a Number : incr string count to add '?'
            MOV.B @TOS,Y            ;2              Y=count+1
            ADD TOS,Y               ;1              Y=end of string addr
            MOV.B #'?',0(Y)         ;5              add '?' to end of string
            MOV #FQABORTYES,IP      ;2              define the return of COUNT
            JMP COUNT               ;2 -- addr len  35 words

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "EVALUATE"
; https://forth-standard.org/standard/core/EVALUATE
; EVALUATE          \ i*x c-addr u -- j*x  interpret string
EVALUATE    MOV #SOURCE_LEN,X       ;2
            MOV @X+,S               ;2 S = SOURCE_LEN
            MOV @X+,T               ;2 T = SOURCE_ORG
            MOV @X+,W               ;2 W = TOIN
            PUSHM #4,IP             ;6 PUSHM IP,S,T,W
            ASMtoFORTH
            .word   INTERPRET
            .word   $+2
            MOV @RSP+,&TOIN         ;4
            MOV @RSP+,&SOURCE_ORG   ;4
            MOV @RSP+,&SOURCE_LEN   ;4
            MOV @RSP+,IP 
            MOV @IP+,PC
    .ENDIF

    .IFDEF DEFER_QUIT               ; defined in ThingsInFirst.inc

QUIT0       MOV #0,&SAVE_SYSRSTIV   ; clear SAVE_SYSRSTIV, usefull for next ABORT...
            MOV #RSTACK,RSP         ; ANS mandatory for QUIT
            MOV #LSTACK,&LEAVEPTR   ; 
            MOV #0,&STATE           ; ANS mandatory for QUIT
            MOV @IP+,PC

            FORTHWORD "BOOT"
;c BOOT  --  load BOOT.4th file from SD_Card then loop to QUIT1
            CMP #0,&SAVE_SYSRSTIV           ; = 0 if WARM
            JZ BODYQUIT                     ; no boostrap if no reset event, default QUIT instead
            BIT.B #CD_SD,&SD_CDIN           ; SD_memory in SD_Card module ?
            JNZ BODYQUIT                    ; if not, no bootstrap, default QUIT instead
            SUB #2,PSP                      ;
            MOV TOS,0(PSP)                  ;
            MOV &SAVE_SYSRSTIV,TOS          ; -- SAVE_SYSRSTIV      TOS = reset event, for tests in BOOT.4TH
            ASMtoFORTH                      ;
            .word NOECHO                    ;
            .word QUIT0                     ;
            .word XSQUOTE                   ; -- addr u
            .byte 15,"LOAD\34 BOOT.4TH\34"  ; LOAD" BOOT.4TH" issues error 2 if no such file...
            .word BRAN,QUIT4                ; to interpret this string

            FORTHWORD "QUIT"
; https://forth-standard.org/standard/core/QUIT
; QUIT  --     interpret line by line the input stream, primary DEFERred word
; to enable bootstrap type: ' BOOT IS QUIT
; to disable bootstrap type: ' QUIT >BODY IS QUIT
QUIT        MOV @PC+,PC             ;3 Code Field Address (CFA) of QUIT
PFAQUIT     .word   BODYQUIT        ;  Parameter Field Address (PFA) of QUIT
BODYQUIT    ASMtoFORTH              ;  BODY of QUIT = default execution of QUIT
            .word   QUIT0           ;

    .ELSE ; if no BOOTLOADER, QUIT is not DEFERred

            FORTHWORD "QUIT"
; https://forth-standard.org/standard/core/QUIT
; QUIT  --     interpret line by line the input stream
QUIT
QUIT0       MOV #0,&SAVE_SYSRSTIV   ; clear SAVE_SYSRSTIV, usefull for next ABORT...
            MOV #RSTACK,RSP         ; ANS mandatory for QUIT
            MOV #LSTACK,&LEAVEPTR   ; 
            MOV #0,&STATE           ; ANS mandatory for QUIT
            ASMtoFORTH              ;

    .ENDIF ; bootloader

    .IFDEF PROMPT
QUIT1       .word   XSQUOTE         ;
            .byte   5,13,10,"ok "   ; CR+LF + Forth prompt
QUIT2       .word   TYPE            ; display it
    .ELSE
QUIT2       .word   CR
    .ENDIF
            .word   REFILL          ; -- org len      refill input buffer from ACCEPT (one line)
QUIT3       .word   FBLANK,EMIT     ;
QUIT4       .word   INTERPRET       ; interpret this line|string
            .word   DEPTH,ZEROLESS  ; stack empty test
            .word   XSQUOTE         ; ABORT" stack empty! "
            .byte 12,"stack empty!" ;
            .word   QABORT          ;
            .word   lit,FRAM_FULL   ;
            .word   HERE,ULESS      ; FRAM full test
            .word   XSQUOTE         ; ABORT" FRAM full! "
            .byte   10,"FRAM full!" ;
            .word   QABORT          ;
    .IFDEF PROMPT
            .word   LIT,STATE,FETCH ; STATE @
            .word   QFBRAN,QUIT1    ; 0= case of interpretion state
            .word   XSQUOTE         ; 0<> case of compilation state
            .byte   5,13,10,"   "   ; CR+LF + 3 spaces
    .ENDIF
            .word   BRAN,QUIT2

            FORTHWORD "ABORT"
; https://forth-standard.org/standard/core/ABORT
; ABORT    i*x --   R: j*x --   clear stack & QUIT
ABORT       MOV #PSTACK,PSP
            JMP QUIT

            FORTHWORDIMM "ABORT\34" ; immediate
; https://forth-standard.org/standard/core/ABORTq
; ABORT"  i*x flag -- i*x   R: j*x -- j*x  flag=0
;         i*x flag --       R: j*x --      flag<>0
ABORTQUOTE  mDOCOL                  ; ABORT address + 10
            .word   SQUOTE
            .word   lit,QABORT,COMMA
            .word   EXIT

; define run-time part of ABORT"
;Z ?ABORT   f c-addr u --      abort & print msg,
;            FORTHWORD "?ABORT"
QABORT      CMP #0,2(PSP)           ; -- f c-addr u         flag test
            JNZ QABORTYES           ;
THREEDROP   ADD #4,PSP              ;
            MOV @PSP+,TOS           ;
            MOV @IP+,PC             ;
; ----------------------------------; QABORTYES = QABORT + 14
QABORTYES   CALL #QAB_DEFER         ; init some variables, common part with WIPE, see WIPE
; ----------------------------------;
    .IFDEF TERMINAL_I2C
            MOV.B #2,Y              ;           send ctrl_char $02 to I2C_Master which will execute on its side QABORT_TERM
            CALL #CTRLCHARTX
            mDOCOL
            .word   PWR_STATE       ; remove all words beyond PWR_HERE, including the definition leading to an error
            .word   lit,LINE,FETCH  ; -- c-addr u line          fetch line number before set ECHO !
            .word   ECHO            ;                           to see abort message
            .word   XSQUOTE
            .byte   5,27,"[7m",'@'  ;
            .word   TYPE            ;  cmd "reverse video" + displays "@"
            .word   LIT,I2CSLAVEADR
            .word   FETCH,DOT       ;  displays <I2C_Slave_Address>
; ----------------------------------;
    .ELSE ; TERMINAL_UART
QABORT_TERM CALL #RXON              ; resume downloading source file then wait the end of downloading.
QABORTLOOP  BIC #RX_TERM,&TERM_IFG  ; clear RX_TERM
            MOV &FREQ_KHZ,Y         ; 1000, 2000, 4000, 8000, 16000, 240000
QABUSBLOOPJ MOV #32,X               ; 2~        <-------+ windows 10 seems very slow... ==> ((32*3)+5)*1000 = 101ms delay
QABUSBLOOPI SUB #1,X                ; 1~        <---+   |
            JNZ QABUSBLOOPI         ; 2~ 3~ loop ---+   | to refill its USB buffer
            SUB #1,Y                ; 1~                |
            JNZ QABUSBLOOPJ         ; 2~ 101~ loop -----+
; QABUSBLOOPJ MOV #65,X               ; 2~        <-------+ linux with minicom seems very very slow...
; QABUSBLOOPI SUB #1,X                ; 1~        <---+   |  ==> ((65*3)+5)*1000 = 200ms delay
;             JNZ QABUSBLOOPI         ; 2~ 3~ loop ---+   | to refill its USB buffer
;             SUB #1,Y                ; 1~                |
;             JNZ QABUSBLOOPJ         ; 2~ 200~ loop -----+
            BIT #RX_TERM,&TERM_IFG  ; 4 new char in TERMRXBUF after QABUSBLOOPJ delay ?
            JNZ QABORTLOOP          ; 2 yes, the input stream is still active: loop back
            mDOCOL                  ;
            .word   PWR_STATE       ; remove all words beyond PWR_HERE, including the definition leading to an error
            .word   lit,LINE,FETCH  ; -- c-addr u line          fetch line number before set ECHO !
            .word   ECHO            ;                           to see abort message
            .word   XSQUOTE         ;
            .byte   4,27,"[7m"      ;                           type ESC[7m    (set reverse video)
            .word   TYPE            ;  
; ----------------------------------;
    .ENDIF ; TERMINAL               ; -- c-addr u line
; ----------------------------------;
; Display error "line:xxx"          ;
; ----------------------------------;
            .word   QDUP,QFBRAN     ;
            .word   QAB_DISPLAY     ;           do nothing if LINE = 0
            .word   XSQUOTE         ; -- c-addr u line c-addr1 u1   displays the line where error occured
            .byte   5,"line:"       ;
            .word   TYPE            ; -- c-addr u line
            .word   UDOT            ; -- c-addr u
; ----------------------------------;
; Display ABORT" message"           ; <== WARM jumps here
; ----------------------------------;
QAB_DISPLAY .word   TYPE            ; --                type abort message
            .word   XSQUOTE         ; -- c-addr u
            .byte   4,27,"[0m"      ;
            .word   TYPE            ; --                set normal video
FABORT      .word   ABORT           ; no return; FABORT = BRACTICK-8

;-------------------------------------------------------------------------------
; COMPILER
;-------------------------------------------------------------------------------
            FORTHWORDIMM "[']"      ; immediate word, i.e. word executed during compilation
; https://forth-standard.org/standard/core/BracketTick
; ['] <name>        --         find word & compile it as literal
BRACTICK    mDOCOL
            .word   TICK            ; get xt of <name>
            .word   lit,lit,COMMA   ; append LIT action
            .word   COMMA,EXIT      ; append xt literal

            FORTHWORD "'"
; https://forth-standard.org/standard/core/Tick
; '    -- xt           find word in dictionary and leave on stack its execution address
TICK        mDOCOL
            .word   FBLANK,WORDD,FIND
            .word   QFBRAN,NotFound
            .word   EXIT
NotFound    .word   NotFoundExe     ; see INTERPRET

            FORTHWORDIMM "\\"       ; immediate
; https://forth-standard.org/standard/block/bs
; \         --      backslash
; everything up to the end of the current line is a comment.
BACKSLASH   MOV &SOURCE_LEN,&TOIN   ;
            MOV @IP+,PC

            FORTHWORDIMM "["    ; immediate
; https://forth-standard.org/standard/core/Bracket
; [        --      enter interpretative state
LEFTBRACKET
            MOV #0,&STATE
            MOV @IP+,PC

            FORTHWORD "]"
; https://forth-standard.org/standard/core/right-bracket
; ]        --      enter compiling state
RIGHTBRACKET
            MOV  #-1,&STATE
            MOV @IP+,PC

            FORTHWORDIMM "POSTPONE" ; immediate
; https://forth-standard.org/standard/core/POSTPONE
POSTPONE    mDOCOL
            .word   FBLANK,WORDD,FIND,QDUP
            .word   QFBRAN,NotFound
            .word   ZEROLESS        ; immediate word ?
            .word   QFBRAN,POST1    ; if immediate
            .word   lit,lit,COMMA   ; else  compile lit
            .word   COMMA           ;       compile xt
            .word   lit,COMMA       ;       CFA of COMMA
POST1       .word   COMMA,EXIT      ; then compile: if immediate xt of word found else CFA of COMMA

            FORTHWORD "IMMEDIATE"
; https://forth-standard.org/standard/core/IMMEDIATE
; IMMEDIATE        --   make last definition immediate
IMMEDIATE   MOV &LAST_NFA,W
            BIS.B #80h,0(W)
            MOV @IP+,PC

            FORTHWORD ":"
; https://forth-standard.org/standard/core/Colon
; : <name>     --      begin a colon definition
; HEADER is CALLed by all compiling words
COLON       PUSH #COLONNEXT         ;3 define COLONNEXT as HEADER RET
;-----------------------------------;
HEADER      BIT #1,&DDP             ;3              carry set if odd
            ADDC #2,&DDP            ;4              (DP+2|DP+3) bytes, make room for LFA
            mDOCOL                  ;
            .word FBLANK,WORDD      ;
            .word   $+2             ; -- HERE       HERE is the NFA of this new word
            MOV @RSP+,IP            ;
            MOV TOS,Y               ; -- NFA        Y=NFA
            MOV.B @TOS+,W           ; -- NFA+1      W=Count_of_chars
            BIS.B #1,W              ;               W=count is always odd
            ADD.B #1,W              ;               W=add one byte for length
            ADD Y,W                 ;               W=Aligned_CFA
            MOV &CURRENT,X          ;               X=VOC_BODY of CURRENT
    .SWITCH THREADS                 ;
    .CASE   1                       ;               nothing to do
    .ELSECASE                       ;               multithreading add 5~ 4words
            MOV.B @TOS,TOS          ; -- char       TOS=first CHAR of new word
            AND #(THREADS-1)*2,TOS  ; -- offset     TOS= Thread offset
            ADD TOS,X               ;               X=VOC_PFAx = thread x of VOC_PFA of CURRENT
    .ENDCASE                        ;
            MOV @PSP+,TOS           ; --
HEADEREND   MOV Y,&LAST_NFA         ;               NFA --> LAST_NFA            used by QREVEAL, IMMEDIATE, MARKER
            MOV X,&LAST_THREAD      ;               VOC_PFAx --> LAST_THREAD    used by QREVEAL
            MOV W,&LAST_CFA         ;               HERE=CFA --> LAST_CFA       used by DOES>, RECURSE
            MOV PSP,&LAST_PSP       ;               save PSP for check compiling, used by QREVEAL
            ADD #4,W                ;               by default make room for two words...
            MOV W,&DDP              ;   
            MOV @RSP+,PC            ; RET           W is the new DP value )
                                    ;               X is LAST_THREAD      > used by compiling words: CREATE, DEFER, :...
COLONNEXT                           ;               Y is NFA              )
    .SWITCH DTC                     ; Direct Threaded Code select
    .CASE 1                         ;
            MOV #DOCOL1,-4(W)       ; compile CALL rDOCOL ([rDOCOL] = XDOCOL)
            SUB #2,&DDP             ;
    .CASE 2                         ;
            MOV #DOCOL1,-4(W)       ; compile PUSH IP       3~
            MOV #DOCOL2,-2(W)       ; compile CALL rDOCOL ([rDOCOL] = EXIT)
    .CASE 3                         ;
            MOV #DOCOL1,-4(W)       ; compile PUSH IP       3~
            MOV #DOCOL2,-2(W)       ; compile MOV PC,IP     1~
            MOV #DOCOL3,0(W)        ; compile ADD #4,IP     1~
            MOV #NEXT,+2(W)         ; compile MOV @IP+,PC   4~
            ADD #4,&DDP             ;
    .ENDCASE                        ;
            MOV #-1,&STATE          ; enter compiling state
            MOV @IP+,PC             ;
;-----------------------------------;

;;Z ?REVEAL   --      if no stack mismatch, link this new word in the CURRENT vocabulary
QREVEAL     CMP PSP,&LAST_PSP       ; Check SP with its saved value by :, :NONAME, CODE...
            JNZ BAD_CSP             ; if no stack mismatch.
GOOD_CSP    MOV &LAST_NFA,Y         ; GOOD_CSP is the end of word MARKER
            MOV &LAST_THREAD,X      ;
REVEAL      MOV @X,-2(Y)            ; [LAST_THREAD] --> LFA         (for NONAME: [LAST_THREAD] --> unused PA reg)
            MOV Y,0(X)              ; LAST_NFA --> [LAST_THREAD]    (for NONAME: LAST_NFA --> unused PA reg) 
NEXTADR     MOV @IP+,PC

BAD_CSP     mDOCOL
            .word   XSQUOTE
            .byte   15,"stack mismatch!"
FQABORTYES  .word   QABORTYES

            FORTHWORDIMM ";"        ; immediate
; https://forth-standard.org/standard/core/Semi
; ;            --      end a colon definition
SEMICOLON   CMP #0,&STATE           ; if interpret mode, semicolon becomes a comment identifier
            JZ BACKSLASH            ; tip: ";" is transparent to the preprocessor, so semicolon comments are kept in file.4th
            mDOCOL                  ; compile mode
            .word   lit,EXIT,COMMA
            .word   QREVEAL,LEFTBRACKET,EXIT

            FORTHWORD "CREATE"
; https://forth-standard.org/standard/core/CREATE
; CREATE <name>        --          define a CONSTANT with its next address
; Execution: ( -- a-addr )          ; a-addr is the address of name's data field
;                                   ; the execution semantics of name may be extended by using DOES>
CREATE      CALL #HEADER            ; --        W = DDP
            MOV #DOCON,-4(W)        ;4          -4(W) = CFA = DOCON
            MOV W,-2(W)             ;3          -2(W) = PFA = W = next address
            JMP REVEAL              ;           to link created VARIABLE in vocabulary

    .IFDEF CORE_COMPLEMENT
            FORTHWORD "DOES>"
; https://forth-standard.org/standard/core/DOES
; DOES>    --          set action for the latest CREATEd definition
DOES        MOV &LAST_CFA,W         ;           W = CFA of CREATEd word
            MOV #DODOES,0(W)        ;           replace CFA (DOCON) by new CFA (DODOES)
            MOV IP,2(W)             ;           replace PFA by the address after DOES> as execution address
            MOV @RSP+,IP            ;
            MOV @IP+,PC             ;           exit of the new created word

            FORTHWORD "VARIABLE"
;https://forth-standard.org/standard/core/VARIABLE
;C VARIABLE <name>       --                      define a Forth VARIABLE
VARIABLE    CALL #HEADER            ; W = DDP = CFA + 2 words
            MOV #DOVAR,-4(W)        ;   CFA = DOVAR, PFA is undefined
            JMP REVEAL              ;           to link created VARIABLE in vocabulary

            FORTHWORD "CONSTANT"
;https://forth-standard.org/standard/core/CONSTANT
;C CONSTANT <name>     n --                      define a Forth CONSTANT
CONSTANT    CALL #HEADER            ; W = DDP = CFA + 2 words
            MOV #DOCON,-4(W)        ;   CFA = DOCON
            MOV TOS,-2(W)           ;   PFA = n
            MOV @PSP+,TOS
            JMP REVEAL              ;           to link created VARIABLE in vocabulary

    .ENDIF ; CORE_COMPLEMENT

    .IFDEF DEFERRED
            FORTHWORD ":NONAME"
; https://forth-standard.org/standard/core/ColonNONAME
; :NONAME        -- xt
            PUSH #COLONNEXT         ; define COLONNEXT as HEADERLESS RET
HEADERLESS  SUB #2,PSP              ; common part of :NONAME and CODENNM
            MOV TOS,0(PSP)          ;
            MOV &DDP,TOS            ; -- HERE
            BIT #1,TOS              ;
            ADDC #0,TOS             ; -- xt     aligned CFA of this NONAME or CODENNM word
            MOV TOS,W               ;  W=CFA
            MOV #210h,X             ;2 MOV Y,0(X) will write to a unused PA register = first lure for semicolon REVEAL...
            MOV X,Y                 ;1
            ADD #2,Y                ;1 MOV @X,-2(Y) also will write to same register = 2th lure for semicolon REVEAL...
            JMP HEADEREND           ; ...because we don't want to write a preamble in dictionnary!

; https://forth-standard.org/standard/core/DEFER
; Skip leading space delimiters. Parse name delimited by a space.
; Create a definition for name with the execution semantics defined below.
;
; name Execution:   --
; Execute the xt that name is set to execute, i.e. NEXT (nothing),
; until the phrase ' word IS name is executed, causing a new value of xt to be assigned to name.
            FORTHWORD "DEFER"
            CALL #HEADER   
            MOV #4030h,-4(W)        ;4 first CELL = MOV @PC+,PC = BR...
            MOV #NEXTADR,-2(W)      ;3 second CELL              =   ...mNEXT : do nothing by default
            JMP REVEAL              ; to link created word in vocabulary

; DEFER! ( xt CFA_DEFERed_WORD -- ) 
;            FORTHWORD "DEFER!"
DEFERSTORE  MOV @PSP+,2(TOS)        ; -- CFA_DEFERed_WORD          xt --> [CFA_DEFERed_WORD+2]
            MOV @PSP+,TOS           ; --
            MOV @IP+,PC             ;

; IS <name>        xt --
; used as is :
; DEFER DISPLAY                         create a "do nothing" definition (2 CELLS)
; inline command : ' U. IS DISPLAY      U. becomes the runtime of the word DISPLAY
; or in a definition : ... ['] U. IS DISPLAY ...
; KEY, EMIT, CR, ACCEPT and WARM are examples of DEFERred words
            FORTHWORDIMM "IS"       ; immediate
IS          CMP #0,&STATE    
            JZ IS_EXEC     
IS_COMPILE  mDOCOL
            .word   BRACTICK             ; find the word, compile its CFA as literal
            .word   lit,DEFERSTORE,COMMA ; compile DEFERSTORE
            .word   EXIT
IS_EXEC     mDOCOL
            .word   TICK,DEFERSTORE     ; find the word, leave its CFA on the stack and execute DEFERSTORE
            .word   EXIT

    .ENDIF ; DEFERRED

    .IFDEF MSP430ASSEMBLER
           FORTHWORD "CODE"         ; a CODE word must be finished with ENDCODE
ASMCODE     CALL #HEADER            ; (that makes room for CFA and PFA)
ASMCODE1    SUB #4,&DDP             ; remove default room for CFA and PFA
ASMCODE2
    .IFDEF EXTENDED_ASM
            MOV #0,&RPT_WORD        ; clear RPT instruction
    .ENDIF
            mDOCOL
            .word   ALSO,ASSEMBLER,EXIT

        .IFDEF DEFERRED
            FORTHWORD "CODENNM"     ; CODENoNaMe is the assembly counterpart of :NONAME
CODENNM     PUSH #ASMCODE1          ; define HEADERLESS return
            JMP HEADERLESS          ; that makes room for CFA and PFA
        .ENDIF

            asmword "ENDCODE"       ; test PSP balancing then restore previous context
ENDCODE     mDOCOL
            .word   QREVEAL,PREVIOUS,EXIT

; ASM and ENDASM are used to define an assembler word which is not executable by FORTH interpreter
; i.e. typically an assembler word called by CALL and ended by RET, or an interrupt routine ended by RETI.
; ASM words are only usable in another ASSEMBLER words
; any ASM word must be finished with ENDASM. 
; The template " ASM ... COLON ... ; " or any other finishing by SEMICOLON is 
; prohibited because it doesn't restore CURRENT.
            FORTHWORD "ASM"
            MOV #BODYASSEMBLER,&CURRENT ; select ASSEMBLER word set to link this ASM word
            JMP ASMCODE

            asmword "ENDASM"        ; end of an ASM word
            mDOCOL                  ; select PREVIOUS word set as CURRENT word set
            .word   ENDCODE,DEFINITIONS,EXIT

; here are words used to switch from/to FORTH to/from ASSEMBLER
            asmword "COLON"         ; compile DOCOL, remove ASSEMBLER from CONTEXT, switch to compilation state
            MOV &DDP,W
    .SWITCH DTC
    .CASE 1
            MOV #DOCOL1,0(W)        ; compile CALL xDOCOL
            ADD #2,&DDP
    .CASE 2
            MOV #DOCOL1,0(W)        ; compile PUSH IP
COLON1      MOV #DOCOL2,2(W)        ; compile CALL rEXIT
            ADD #4,&DDP
    .CASE 3 ; inlined DOCOL
            MOV #DOCOL1,0(W)        ; compile PUSH IP
COLON1      MOV #DOCOL2,2(W)        ; compile MOV PC,IP
            MOV #DOCOL3,4(W)        ; compile ADD #4,IP
            MOV #NEXT,6(W)          ; compile MOV @IP+,PC
            ADD #8,&DDP             ;
    .ENDCASE ; DTC

COLON2      MOV #-1,&STATE          ; enter in compile state
            MOV #PREVIOUS,PC        ; restore previous state of CONTEXT

            asmword "LO2HI"         ; same as COLON but without saving IP
    .SWITCH DTC
    .CASE 1                         ; compile 2 words
            MOV &DDP,W
            MOV #12B0h,0(W)         ; compile CALL #EXIT, 2 words  4+6=10~
            MOV #EXIT,2(W)
            ADD #4,&DDP
            JMP COLON2
    .ELSECASE                       ; CASE 2 : compile 1 word, CASE 3 : compile 3 words
            SUB #2,&DDP             ; to skip PUSH IP
            MOV &DDP,W
            JMP COLON1
    .ENDCASE

            FORTHWORDIMM "HI2LO"    ; immediate, switch to low level, set interpretation state, add ASSEMBLER context
            mDOCOL
            .word   HERE,CELLPLUS,COMMA ; compile HERE+2
            .word   LEFTBRACKET         ; switch to interpret state
            .word   ASMCODE2            ; add ASSEMBLER in context
            .word   EXIT

    .ENDIF ; MSP430ASSEMBLER

    .IFDEF CONDCOMP
; ------------------------------------------------------------------------------
; forthMSP430FR :  CONDITIONNAL COMPILATION
; ------------------------------------------------------------------------------
        .include "forthMSP430FR_CONDCOMP.asm"
    .ENDIF

        .IFDEF CORE_COMPLEMENT
; ------------------------------------------------------------------------------
; CONTROL STRUCTURES
; ------------------------------------------------------------------------------
; THEN and BEGIN compile nothing
; DO compile one word
; IF, ELSE, AGAIN, UNTIL, WHILE, REPEAT, LOOP & +LOOP compile two words
; LEAVE compile three words

            FORTHWORDIMM "IF"       ; immediate
; https://forth-standard.org/standard/core/IF
; IF       -- IFadr    initialize conditional forward branch
IFF         SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            MOV &DDP,TOS            ; -- HERE
            ADD #4,&DDP             ;           compile one word, reserve one word
            MOV #QFBRAN,0(TOS)      ; -- HERE   compile QFBRAN
        .ENDIF ; CORE_COMPLEMENT
CELLPLUS    ADD #2,TOS              ; -- HERE+2=IFadr
            MOV @IP+,PC

        .IFDEF CORE_COMPLEMENT
            FORTHWORDIMM "ELSE"     ; immediate
; https://forth-standard.org/standard/core/ELSE
; ELSE     IFadr -- ELSEadr        resolve forward IF branch, leave ELSEadr on stack
ELSS        ADD #4,&DDP             ; make room to compile two words
            MOV &DDP,W              ; W=HERE+4
            MOV #BRAN,-4(W)
            MOV W,0(TOS)            ; HERE+4 ==> [IFadr]
            SUB #2,W                ; HERE+2
            MOV W,TOS               ; -- ELSEadr
            MOV @IP+,PC

            FORTHWORDIMM "THEN"     ; immediate
; https://forth-standard.org/standard/core/THEN
; THEN     IFadr --                resolve forward branch
THEN        MOV &DDP,0(TOS)         ; -- IFadr
            MOV @PSP+,TOS           ; --
            MOV @IP+,PC

            FORTHWORDIMM "BEGIN"    ; immediate
; https://forth-standard.org/standard/core/BEGIN
; BEGIN    -- BEGINadr             initialize backward branch
            MOV #HERE,PC

            FORTHWORDIMM "UNTIL"    ; immediate
; https://forth-standard.org/standard/core/UNTIL
; UNTIL    BEGINadr --             resolve conditional backward branch
UNTIL       MOV #QFBRAN,X
UNTIL1      ADD #4,&DDP             ; compile two words
            MOV &DDP,W              ; W = HERE
            MOV X,-4(W)             ; compile Bran or QFBRAN at HERE
            MOV TOS,-2(W)           ; compile bakcward adr at HERE+2
            MOV @PSP+,TOS
            MOV @IP+,PC

            FORTHWORDIMM "AGAIN"    ; immediate
; https://forth-standard.org/standard/core/AGAIN
;X AGAIN    BEGINadr --             resolve uncondionnal backward branch
AGAIN       MOV #BRAN,X
            JMP UNTIL1

            FORTHWORDIMM "WHILE"    ; immediate
; https://forth-standard.org/standard/core/WHILE
; WHILE    BEGINadr -- WHILEadr BEGINadr
WHILE       mDOCOL
            .word   IFF,SWAP,EXIT

            FORTHWORDIMM "REPEAT"   ; immediate
; https://forth-standard.org/standard/core/REPEAT
; REPEAT   WHILEadr BEGINadr --     resolve WHILE loop
REPEAT      mDOCOL
            .word   AGAIN,THEN,EXIT

            FORTHWORDIMM "DO"       ; immediate
; https://forth-standard.org/standard/core/DO
; DO       -- DOadr   L: -- 0
DO          SUB #2,PSP              ;
            MOV TOS,0(PSP)          ;
            ADD #2,&DDP             ;   make room to compile xdo
            MOV &DDP,TOS            ; -- HERE+2
            MOV #xdo,-2(TOS)        ;   compile xdo
            ADD #2,&LEAVEPTR        ; -- HERE+2     LEAVEPTR+2
            MOV &LEAVEPTR,W         ;
            MOV #0,0(W)             ; -- HERE+2     L-- 0
            MOV @IP+,PC

            FORTHWORD "I"
; https://forth-standard.org/standard/core/I
; I        -- n   R: sys1 sys2 -- sys1 sys2
;                  get the innermost loop index
II          SUB #2,PSP              ;1 make room in TOS
            MOV TOS,0(PSP)          ;3
            MOV @RSP,TOS            ;2 index = loopctr - fudge
            SUB 2(RSP),TOS          ;3
            MOV @IP+,PC             ;4 13~

            FORTHWORDIMM "LOOP"     ; immediate
; https://forth-standard.org/standard/core/LOOP
; LOOP    DOadr --         L-- an an-1 .. a1 0
LOO         MOV #xloop,X
LOOPNEXT    ADD #4,&DDP             ; make room to compile two words
            MOV &DDP,W
            MOV X,-4(W)             ; xloop --> HERE
            MOV TOS,-2(W)           ; DOadr --> HERE+2
; resolve all "leave" adr
LEAVELOOP   MOV &LEAVEPTR,TOS       ; -- Adr of top LeaveStack cell
            SUB #2,&LEAVEPTR        ; --
            MOV @TOS,TOS            ; -- first LeaveStack value
            CMP #0,TOS              ; -- = value left by DO ?
            JZ LOOPEND
            MOV W,0(TOS)            ; move adr after loop as UNLOOP adr
            JMP LEAVELOOP
LOOPEND     MOV @PSP+,TOS
            MOV @IP+,PC

            FORTHWORDIMM "+LOOP"    ; immediate
; https://forth-standard.org/standard/core/PlusLOOP
; +LOOP   adrs --   L-- an an-1 .. a1 0
PLUSLOOP    MOV #xploop,X
            JMP LOOPNEXT
    .ENDIF ; CORE_COMPLEMENT

    .IFDEF VOCABULARY_SET
;-------------------------------------------------------------------------------
; WORDS SET for VOCABULARY, not ANS compliant
;-------------------------------------------------------------------------------
        .IFNDEF DOES
            FORTHWORD "DOES>"
; https://forth-standard.org/standard/core/DOES
; DOES>    --          set action for the latest CREATEd definition
DOES        MOV &LAST_CFA,W         ;           W = CFA of CREATEd word
            MOV #DODOES,0(W)        ;           replace CFA (DOCON) by new CFA (DODOES)
            MOV IP,2(W)             ;           replace PFA by the address after DOES> as execution address
            MOV @RSP+,IP            ;
            MOV @IP+,PC             ;           exit of the new created word
        .ENDIF

            FORTHWORD "VOCABULARY"
;X VOCABULARY       -- create a vocabulary, up to 7 vocabularies in CONTEXT
VOCABULARY  mDOCOL
            .word   CREATE
        .SWITCH THREADS
        .CASE   1
            .word   lit,0,COMMA     ; will keep the NFA of the last word of the future created vocabularies
        .ELSECASE
            .word   lit,THREADS,lit,0,xdo
VOCABULOOP  .word   lit,0,COMMA
            .word   xloop,VOCABULOOP
        .ENDCASE
            .word   HERE            ; link via LASTVOC the future created vocabulary
            .word   LIT,LASTVOC,DUP
            .word   FETCH,COMMA     ; compile [LASTVOC] to HERE+
            .word   STORE           ; store (HERE - CELL) to LASTVOC
            .word   DOES            ; compile CFA and PFA for the future defined vocabulary

    .ENDIF ; VOCABULARY_SET

VOCDOES     .word   LIT,CONTEXT,STORE
            .word   EXIT

    .IFDEF VOCABULARY_SET
            FORTHWORD "FORTH"
    .ENDIF ; VOCABULARY_SET
;X  FORTH    --                     ; set FORTH the first context vocabulary; FORTH must be the first vocabulary
FORTH                               ; leave BODYFORTH on the stack and run VOCDOES
            CALL rDODOES            ; Code Field Address (CFA) of FORTH
PFAFORTH    .word   VOCDOES         ; Parameter Field Address (PFA) of FORTH
BODYFORTH                           ; BODY of FORTH
            .word   lastforthword
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

    .IFDEF MSP430ASSEMBLER
    .IFDEF VOCABULARY_SET
            FORTHWORD "ASSEMBLER"
    .ENDIF ; VOCABULARY_SET
;X  ASSEMBLER       --              ; set ASSEMBLER the first context vocabulary
ASSEMBLER   CALL rDODOES        ; leave BODYASSEMBLER on the stack and run VOCDOES
                .word   VOCDOES
BODYASSEMBLER
            .word   lastasmword
    .SWITCH THREADS
    .CASE   2
            .word   lastasmword1
    .CASE   4
            .word   lastasmword1
            .word   lastasmword2
            .word   lastasmword3
    .CASE   8
            .word   lastasmword1
            .word   lastasmword2
            .word   lastasmword3
            .word   lastasmword4
            .word   lastasmword5
            .word   lastasmword6
            .word   lastasmword7
    .CASE   16
            .word   lastasmword1
            .word   lastasmword2
            .word   lastasmword3
            .word   lastasmword4
            .word   lastasmword5
            .word   lastasmword6
            .word   lastasmword7
            .word   lastasmword8
            .word   lastasmword9
            .word   lastasmword10
            .word   lastasmword11
            .word   lastasmword12
            .word   lastasmword13
            .word   lastasmword14
            .word   lastasmword15
    .CASE   32
            .word   lastasmword1
            .word   lastasmword2
            .word   lastasmword3
            .word   lastasmword4
            .word   lastasmword5
            .word   lastasmword6
            .word   lastasmword7
            .word   lastasmword8
            .word   lastasmword9
            .word   lastasmword10
            .word   lastasmword11
            .word   lastasmword12
            .word   lastasmword13
            .word   lastasmword14
            .word   lastasmword15
            .word   lastasmword16
            .word   lastasmword17
            .word   lastasmword18
            .word   lastasmword19
            .word   lastasmword20
            .word   lastasmword21
            .word   lastasmword22
            .word   lastasmword23
            .word   lastasmword24
            .word   lastasmword25
            .word   lastasmword26
            .word   lastasmword27
            .word   lastasmword28
            .word   lastasmword29
            .word   lastasmword30
            .word   lastasmword31
    .ELSECASE
    .ENDCASE
            .word   voclink
voclink     .set    $-2
    .ENDIF ; MSP430ASSEMBLER

    .IFDEF VOCABULARY_SET
            FORTHWORD "ALSO"
    .ENDIF ; VOCABULARY_SET
;X  ALSO    --                  make room to put a vocabulary as first in context
ALSO        MOV #12,W               ; -- move up 6 words, 8th word of CONTEXT area must remain to 0
            MOV #CONTEXT+12,X       ; X=src
            MOV X,Y
            ADD #2,Y                ; Y=dst
MOVEUP      SUB #1,X
            SUB #1,Y
            MOV.B @X,0(Y)           ; if X=src < Y=dst copy W bytes beginning with the end
            SUB #1,W
            JNZ MOVEUP 
MOVEND      MOV @IP+,PC

    .IFDEF VOCABULARY_SET
            FORTHWORD "PREVIOUS"
    .ENDIF ; VOCABULARY_SET
;X  PREVIOUS   --               pop last vocabulary out of context
PREVIOUS    MOV #14,W               ; move down 7 words, first with the 8th word equal to 0
            MOV #CONTEXT,Y          ; Y=dst
            MOV Y,X
            ADD #2,X                ; X=src
MOVEDOWN    MOV.B @X+,0(Y)          ; if X=src > Y=dst copy W bytes
            ADD #1,Y
            SUB #1,W
            JNZ MOVEDOWN
            MOV @IP+,PC

    .IFDEF VOCABULARY_SET
            FORTHWORD "ONLY"
    .ENDIF ; VOCABULARY_SET
;X ONLY     --      cut context list to access only first vocabulary, ex.: FORTH ONLY
ONLY        MOV #0,&CONTEXT+2
            MOV @IP+,PC

    .IFDEF VOCABULARY_SET
            FORTHWORD "DEFINITIONS"
    .ENDIF ; VOCABULARY_SET
;X DEFINITIONS  --      set last context vocabulary as entry for further defining words
DEFINITIONS MOV &CONTEXT,&CURRENT
            MOV @IP+,PC

;-------------------------------------------------------------------------------
; MEMORY MANAGEMENT
;-------------------------------------------------------------------------------
    .IFDEF USE_MOVE
            FORTHWORD "MOVE"
; https://forth-standard.org/standard/core/MOVE
; MOVE    addr1 addr2 u --     smart move
;             VERSION FOR 1 ADDRESS UNIT = 1 CHAR
MOVE        MOV TOS,W               ; W = cnt
            MOV @PSP+,Y             ; Y = addr2 = dst
            MOV @PSP+,X             ; X = addr1 = src
            MOV @PSP+,TOS           ; pop new TOS
            CMP #0,W                ; count = 0 ?
            JZ MOVEND               ; already done ! see ALSO
            CMP X,Y                 ; Y-X ; dst - src
            JZ MOVEND               ; already done !
            JNC MOVEDOWN            ; see PREVIOUS
            ADD W,Y                 ; move beginning with the end
            ADD W,X                 ;
            JMP MOVEUP              ; see ALSO
    .ENDIF

STATE_DOES  ; execution part of PWR_STATE ; sorry, doesn't restore search order pointers
            .word   FORTH,ONLY,DEFINITIONS
            .word   $+2             ; -- BODY       IP is free
            MOV @TOS+,W             ; -- BODY+2     W = old VOCLINK = VLK
            MOV W,&LASTVOC          ;               restore LASTVOC
            MOV @TOS,TOS            ; -- OLD_DP
            MOV TOS,&DDP            ; -- DP         restore DP
                                    ; then restore words link(s) with it value < old DP
    .SWITCH THREADS
    .CASE   1 ; mono thread vocabularies
MARKALLVOC  MOV W,Y                 ; -- DP         W=VLK   Y=VLK
MRKWORDLOOP MOV -2(Y),Y             ; -- DP         W=VLK   Y=NFA
            CMP Y,TOS               ; -- DP         CMP = TOS-Y : OLD_DP-NFA
            JNC MRKWORDLOOP         ;                loop back if TOS<Y : OLD_DP<NFA
            MOV Y,-2(W)             ;                W=VLK   X=THD   Y=NFA   refresh thread with good NFA
            MOV @W,W                ; -- DP         W=[VLK] = next voclink
            CMP #0,W                ; -- DP         W=[VLK] = next voclink   end of vocs ?
            JNZ MARKALLVOC          ; -- DP         W=VLK                   no : loopback
    .ELSECASE ; multi threads vocabularies
MARKALLVOC  MOV #THREADS,IP         ; -- DP         W=VLK
            MOV W,X                 ; -- DP         W=VLK   X=VLK
MRKTHRDLOOP MOV X,Y                 ; -- DP         W=VLK   X=VLK   Y=VLK
            SUB #2,X                ; -- DP         W=VLK   X=THD (thread ((case-2)to0))
MRKWORDLOOP MOV -2(Y),Y             ; -- DP         W=VLK   Y=NFA
            CMP Y,TOS               ; -- DP         CMP = TOS-Y : DP-NFA
            JNC MRKWORDLOOP         ;               loop back if TOS<Y : DP<NFA
MARKTHREAD  MOV Y,0(X)              ;               W=VLK   X=THD   Y=NFA   refresh thread with good NFA
            SUB #1,IP               ; -- DP         W=VLK   X=THD   Y=NFA   IP=CFT-1
            JNZ MRKTHRDLOOP         ;                       loopback to compare NFA in next thread (thread-1)
            MOV @W,W                ; -- DP         W=[VLK] = next voclink
            CMP #0,W                ; -- DP         W=[VLK] = next voclink   end of vocs ?
            JNZ MARKALLVOC          ; -- DP         W=VLK                   no : loopback
    .ENDCASE ; of THREADS           ; -- DP
            MOV @PSP+,TOS           ;
            MOV @RSP+,IP            ;
            MOV @IP+,PC             ;

            FORTHWORD "PWR_STATE"   ; executed after POWER_ON, ABORT; does PWR_HERE word set
PWR_STATE   CALL rDODOES            ; DOES part of MARKER : resets pointers DP, voclink and latest
            .word   STATE_DOES      ; execution vector of PWR_STATE
MARKVOC     .word   lastvoclink     ; initialised by forthMSP430FR.asm as voclink value
MARKDP      .word   ROMDICT         ; initialised by forthMSP430FR.asm as DP value

            FORTHWORD "RST_STATE"   ; executed by <reset>, COLD, SYSRSTIV error; does RST_HERE word set
RST_STATE   MOV &INIVOC,&MARKVOC    ; INIT value above (FRAM value)
            MOV &INIDP,&MARKDP      ; INIT value above (FRAM value)
            JMP PWR_STATE

            FORTHWORD "PWR_HERE"    ; define word set bound for POWER_ON, ABORT.
PWR_HERE    MOV &LASTVOC,&MARKVOC
            MOV &DDP,&MARKDP
            MOV @IP+,PC

            FORTHWORD "RST_HERE"    ; define word set bound for <reset>, COLD, SYSRSTIV error.
RST_HERE    MOV &LASTVOC,&INIVOC
            MOV &DDP,&INIDP
            JMP PWR_HERE            ; and obviously the same for POWER_ON...

        FORTHWORD "WIPE"            ; restore the word set as defined by forthMSP430FR.txt program file
WIPE
            MOV #lastvoclink,&INIVOC; reinit this 2 factory values
            MOV #ROMDICT,&INIDP     
            PUSH #RST_STATE         ; define the next of WIPE
            MOV #BODYSLEEP,&PFASLEEP;4 restore default background task
            MOV #BODYWARM,&PFAWARM  ;4 restore default WARM
    .IFDEF DEFER_QUIT               ;
            MOV #BODYQUIT,&PFAQUIT  ;4 restore QUIT
    .ENDIF
;-----------------------------------; 
; WIPE, QABORT, COLD common subrouti; <--- COLD, reset and PUC calls here
;-----------------------------------; 
RST_INIT
;-----------------------------------; 
; WIPE, QABORT common subroutine    ; <--- ?ABORT calls here
;-----------------------------------; 
QAB_DEFER
            MOV #BODYEMIT,&PFAEMIT  ;4 ' EMIT >BODY IS EMIT   default console output
            MOV #BODYCR,&PFACR      ;4 ' CR >BODY IS CR       default CR
            MOV #BODYKEY,&PFAKEY    ;4 ' KEY >BODY IS KEY     default KEY
    .IFDEF DEFER_ACCEPT             ;  true if SD_CARD_LOADER
        MOV #BODYACCEPT,&PFAACCEPT  ;4 ' ACCEPT >BODY IS ACCEPT
            MOV #TIB_ORG,&CIB_ADR   ;4 TIB_ORG TO CIB  (Current Input Buffer)
    .ENDIF
    .IFDEF SD_CARD_LOADER           ; close all handles 
            MOV &CurrentHdl,T       ;
            JMP QAB_QCLOSE          ;
QAB_CLOSE   MOV.B #0,HDLB_Token(T)  ;
            MOV @T,T                ;
QAB_QCLOSE  CMP #0,T                ;
            JNZ QAB_CLOSE           ;
    .ENDIF                          ;
    .IFDEF TERMINAL_I2C
            MOV #LPM4+GIE,&LPM_MODE ; I2C Slave START interrupt works down to LPM4
    .ELSE
            MOV #LPM0+GIE,&LPM_MODE ; UART RX interrupt works down to LPM0
    .ENDIF
    .SWITCH DTC
    .CASE 1
            MOV #xdocol,rDOCOL
    .CASE 2
            MOV #EXIT,rDOCOL
    .ENDCASE
            MOV #RFROM,rDOVAR       
            MOV #xdocon,rDOCON
            MOV #xdodoes,rDODOES
            MOV #32,&CAPS           ; init CAPS ON
            MOV #10,&BASE           ; init decimal base
            MOV @RSP+,PC            ; RET
;-----------------------------------; 

; --------------------------------------------------------------------------------
; forthMSP430FR : WARM
; --------------------------------------------------------------------------------
            FORTHWORD "WARM"
;Z WARM   --    ; deferred word, enabling the initialisation of your application
WARM        MOV @PC+,PC             ;3 MOV #BODYWARM,PC
PFAWARM     .word   BODYWARM        ; Parameter Field Address of WARM, may be redirected.
BODYWARM    MOV @PC+,IP             ; MOV #WARMTYPE,IP
ENDOFWARM   .word   WARMTYPE        ; define next step of WARM, examples: WARMTYPE, ABORT, BOOT...
;=================================================================================
; WARM 1: activates I/O: inputs and outputs are active only here (hiZ before here)
;=================================================================================
            BIC #LOCKLPM5,&PM5CTL0  ; activate all previous I/O settings (before I/O tests below).
                                    ; Moved in WARM area to be redirected in your app START routine, 
                                    ; enabling you full control of the I/O RESET state.
;=================================================================================
; RESET 7: test DEEP RESET
;---------------------------------------------------------------------------------
RST_EVENT   MOV &SAVE_SYSRSTIV,TOS  ;
            NOP3                    ; UNLOCK LPM5 can take a longer time (case of MSP430FR2433)
            BIT.B #IO_WIPE,&WIPE_IN ; IO_WIPE is low ?
            JNZ Q_DEEP_RST          ; no
            XOR #-1,TOS             ; yes : force DEEP_RST (RESET + WIPE + restore vectors + signatures)
            ADD #1,TOS              ;       to display SAVE_SYSRSTIV as negative value
;-----------------------------------; 
Q_DEEP_RST  CMP #0,TOS
            JZ RST_SEL_END          ;       if WARM event
            JGE RST_EVENT_END       ;       if TOS positive
;-----------------------------------;       if TOS negative
            MOV #16,X               ; max known SIGNATURES length = 16
SIGNLOO     SUB #2,X                ;
            MOV #-1,SIGNATURES(X)   ; reset signature; WARNING ! DON'T CHANGE THIS IMMEDIATE VALUE !
            JNZ SIGNLOO             ;
;-----------------------------------; X = 0
            MOV #RESET,-2(X)        ; write RESET vector FFFEh
INITVECLOOP SUB #2,X                ;
            MOV #RESET-4,-2(X)      ; -2(X) = FFFCh first, [RESET-4] = BR COLD
            CMP #-84,X              ; init 42 vectors (down to 0FFAAh)
            JNZ INITVECLOOP         ;
        MOV #TERMINAL_INT,&TERM_VEC ;
;-----------------------------------; 
RST_EVENT_END
;---------------------------------------------------------------------------------
; RESET 8: INIT SD_Card, after activating I/O:
;---------------------------------------------------------------------------------
    .IFDEF SD_CARD_LOADER           ;
            BIT.B #CD_SD,&SD_CDIN   ; SD_memory in SD_Card module ?
            JNZ RST_SEL             ; no
        .IF RAM_LEN < 2048          ; case of MSP430FR57xx : SD datas are in FRAM
            MOV #SD_LEN,X           ;                        not initialised by RESET.
ClearSDdata SUB #2,X                ; 1
            MOV #0,SD_ORG(X)        ; 3 
            JNZ ClearSDdata         ; 2
        .ENDIF
    .include "forthMSP430FR_SD_INIT.asm"; no use of IP,TOS
    .ENDIF ; SD_CARD_LOADER
;---------------------------------------------------------------------------------
; RESET 9: RESET events handler: Select POWER_ON|<reset>|DEEP_RST
;---------------------------------------------------------------------------------
RST_SEL     CMP #0,TOS              ; SYSRSTIV is negative : DEEP_RST request...
            JN  WIPE                ; ...adds WIPE to achieve DEEP_RST
            CMP #2,TOS              ; SYSRSTIV = BOR ?
            JZ  PWR_STATE           ; yes   execute PWR_STATE, return to [ENDOFWARM]
            JC  RST_STATE           ; if  SYSRSTIV > BOR  execute RST_STATE, return to [ENDOFWARM]
RST_SEL_END MOV @IP+,PC             ; if SYSRSTIV =0, return to [ENDOFWARM]

;---------------------------------------------------------------------------------
; WARM 2: type message on console output (if ECHO)
;---------------------------------------------------------------------------------
WARMTYPE    
    .IFDEF TERMINAL_I2C
            .word   XSQUOTE
            .byte   7,13,10,27,"[7m@"   ; CR + cmd "reverse video" + @
            .word   TYPE
            .word   LIT,I2CSLAVEADR,FETCH,DOT
            .word   LIT,'#',EMIT
    .ELSE
            .word   XSQUOTE
            .byte   7,13,10,27,"[7m#"   ; CR + cmd "reverse video" + $
            .word   TYPE
    .ENDIF
            .word   DOT                ; display signed SAVE_SYSRSTIV
            .word   XSQUOTE
            .byte   25,"FastForth ©J.M.Thoorens "
            .word   TYPE
            .word   LIT,FRAM_FULL,HERE,MINUS,UDOT
            .word   XSQUOTE
            .byte   10,"bytes free"
            .word   BRAN,QAB_DISPLAY

            FORTHWORD "COLD"
;Z COLD     --      performs a software reset
; as pin RST is replaced by pin NMI, hard RESET falls down here via USER NMI vector
; COLD address = RESET address - 4
            MOV @PC+,PC
            .word COLD                  ; see forthMSP430FR_TERM_xxxx.asm

RESET   ; hard RESET falls down here once, only after reprogramming device
;---------------------------------------------------------------------------------
; RESET 1: INIT NMI, stops WDT_RESET
;---------------------------------------------------------------------------------
            BIS #3,&SFRRPCR             ; pin RST becomes falling edge pin NMI, with SYSRSTIV = 4 
            BIS #10h,&SFRIE1            ; enable NMI interrupt, --> USERNMI, that executes COLD
            MOV #5A80h,&WDTCTL          ; stop RESET on WDT
;---------------------------------------------------------------------------------
; RESET 2: Initialisation limited to FastForth usage : I/O, RAM, RTC, CS, SYS
;          all unused I/O are set as input with pullup resistor
;---------------------------------------------------------------------------------
            .include "TargetInit.asm"   ; include target specific FastForth init code
;---------------------------------------------------------------------------------
; RESET 3: INIT TERMINAL + optionnal SD_CARD
;---------------------------------------------------------------------------------
    .IFDEF TERMINAL_I2C
            BIS #07C0h,&TERM_CTLW0          ; set I2C_Slave in RX mode to receive I2C_address
            MOV &I2CSLAVEADR,Y              ; init value found in FRAM INFO
            RRA Y                           ; I2C Slave address minus R/W bit 
            BIS #400h,Y                     ; enable I2COA0 Slave address
            MOV Y,&TERM_I2COA0              ;
    .ELSE ; TERMINAL UART
            MOV #0081h,&TERM_CTLW0          ; UC SWRST + UCLK = SMCLK
            MOV &TERMBRW_RST,&TERM_BRW      ; RST value in FRAM
            MOV &TERMMCTLW_RST,&TERM_MCTLW  ; RST value in FRAM
    .ENDIF ; TERMINAL select
            BIS.B #BUS_TERM,&TERM_SEL       ; Configure pins TERM_UART|TERM_I2C
            BIC #1,&TERM_CTLW0              ; release UC_TERM from reset...
            BIS #WAKE_UP,&TERM_IE           ; then enable interrupt for wake up on terminal input

    .IFDEF SD_CARD_LOADER                   ;
            MOV #0A981h,&SD_CTLW0           ; UCxxCTL1  = CKPH, MSB, MST, SPI_3, SMCLK  + UCSWRST
            MOV #FREQUENCY*3,&SD_BRW        ; UCxxBRW init SPI CLK = 333 kHz ( < 400 kHz) for SD_Card init
            BIS.B #CS_SD,&SD_CSDIR          ; SD_CS as output high
            BIS #BUS_SD,&SD_SEL             ; Configure pins as SIMO, SOMI & SCK (PxDIR.y are controlled by eUSCI module)
            BIC #1,&SD_CTLW0                ; release eUSCI from reset
    .ENDIF
;---------------------------------------------------------------------------------
; RESET 4: init RAM
;---------------------------------------------------------------------------------
            MOV #RAM_LEN,X
INITRAMLOOP SUB #2,X 
            MOV #0,RAM_ORG(X)
            JNZ INITRAMLOOP             ; 6~ loop
;---------------------------------------------------------------------------------
; RESET 5: INIT STACKS
;---------------------------------------------------------------------------------
            MOV #RSTACK,RSP             ; init return stack
            MOV #PSTACK,PSP             ; init parameter stack
;---------------------------------------------------------------------------------
; RESET 6: INIT FORTH machine
;---------------------------------------------------------------------------------
            PUSH #WARM                  ; WARM = return of RST_INIT
            JMP RST_INIT
;---------------------------------------------------------------------------------

    .IFDEF MSP430ASSEMBLER
;-------------------------------------------------------------------------------
; ASSEMBLER OPTION
;-------------------------------------------------------------------------------
        .IFDEF EXTENDED_ASM
            .include "forthMSP430FR_EXTD_ASM.asm"
        .ELSE
            .include "forthMSP430FR_ASM.asm"
        .ENDIF
    .ENDIF
    .IFDEF UTILITY
;-------------------------------------------------------------------------------
; UTILITY WORDS OPTION
;-------------------------------------------------------------------------------
        .include "ADDON/UTILITY.asm"
    .ENDIF
    .IFDEF FIXPOINT
;-------------------------------------------------------------------------------
; FIXED POINT OPERATORS OPTION
;-------------------------------------------------------------------------------
        .include "ADDON/FIXPOINT.asm"
    .ENDIF
    .IFDEF SD_CARD_LOADER
;-------------------------------------------------------------------------------
; SD CARD FAT OPTIONS
;-------------------------------------------------------------------------------
        .include "forthMSP430FR_SD_LowLvl.asm"  ; SD primitives
        .include "forthMSP430FR_SD_LOAD.asm"    ; SD LOAD driver
        .IFDEF SD_CARD_READ_WRITE
            .include "forthMSP430FR_SD_RW.asm"  ; SD Read/Write driver
        .ENDIF
        .IFDEF SD_TOOLS
            .include "ADDON/SD_TOOLS.asm"
        .ENDIF
    .ENDIF
;-------------------------------------------------------------------------------
; ADD HERE YOUR CODE TO BE INTEGRATED IN KERNEL (protected against WIPE)
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
;
;           .include "MY_CODE.asm"
;
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; ADD HERE YOUR CODE TO BE INTEGRATED IN KERNEL (protected against WIPE)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; RESOLVE ASSEMBLY PTR, init interrupt Vectors
;-------------------------------------------------------------------------------
    .include "ThingsInLast.inc"
