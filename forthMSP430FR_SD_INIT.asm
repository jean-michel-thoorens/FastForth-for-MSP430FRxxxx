; -*- coding: utf-8 -*-
; forthMSP430FR_SD_INIT.asm

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

; ===========================================================
; ABOUT INIT SD_CARD AND HOW TO SELECT FAT16/FAT32 FORMATTING
; ===========================================================
; FAT16/FAT32 selection is done via the ID of partition in EBP, because SD must be always FAT16 and SDHC must be always FAT32
; So we assume that the SD_Card FAT16/FAT32 formatting was done well !


; ===========================================================
; 1- Init eUSCI dedicated to SD_Card SPI driver
; ===========================================================

    MOV     #0A981h,&SD_CTLW0       ; UCxxCTL1  = CKPH, MSB, MST, SPI_3, SMCLK  + UCSWRST
    MOV     #FREQUENCY*3,&SD_BRW    ; UCxxBRW init SPI CLK = 333 kHz ( < 400 kHz) for SD_Card init


    .IFDEF MSP_EXP430FR5739 

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.2 - RF.16                  <--- CD  SD_CardAdapter (Card Detect)
SD_CD           .equ  4
SD_CDIN         .equ  P2IN
; P2.3 - RF.10                  ---> CS  SD_CardAdapter (Card Select)
SD_CS           .equ  8
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P2.4 - RF.14 UCA1 CLK         ---> CLK SD_CardAdapter (SCK)  
; P2.5 - RF.7  UCA1 TXD/SIMO    ---> SDI SD_CardAdapter (MOSI)
; P2.6 - RF.5  UCA1 RXD/SOMI    <--- SDO SD_CardAdapter (MISO)
    BIS.B #070h,&P2SEL1 ; Configure UCA1 pins P2.4 as UCA1CLK, P2.5 as UCA1SIMO & P2.6 as UCA1SOMI
                        ; P2DIR.x is controlled by eUSCI_A0 module
    BIC.B #070h,&P2REN  ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF
    .IFDEF MSP_EXP430FR5969 

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P4.2                <--- SD_CD (Card Detect)
SD_CD           .equ  4
SD_CDIN         .equ  P4IN
; P4.3                ---> SD_CS (Card Select)
SD_CS           .equ  8
SD_CSOUT        .equ  P4OUT
    BIS.B #SD_CS,&P4DIR  ; SD_CS output high

; P2.4  UCA1     CLK  ---> SD_CLK
; P2.5  UCA1 TX/SIMO  ---> SD_SDI
; P2.6  UCA1 RX/SOMI  <--- SD_SDO
    BIS.B   #070h,  &P2SEL1 ; Configure UCA1 pins P2.4 as UCA1CLK, P2.5 as UCA1SIMO & P2.6 as UCA1SOMI
                            ; P2DIR.x is controlled by eUSCI_A0 module
    BIC.B   #070h,  &P2REN  ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF
    .IFDEF MSP_EXP430FR5994 

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P7.2/UCB2CLK                        - SD_CD (Card Detect)
SD_CD           .equ  4 ; P7.2
SD_CDIN         .equ  P7IN
; P4.0/A8                             - SD_CS (Card Select)
SD_CS           .equ  1 ; P4.0
SD_CSOUT        .equ  P4OUT
    BIS.B #SD_CS,&P4DIR ; SD_CS output high

; P2.2/TB0.2/UCB0CLK                  - SD_CLK
; P1.6/TB0.3/UCB0SIMO/UCB0SDA/TA0.0   - SD_SDI
; P1.7/TB0.4/UCB0SOMI/UCB0SCL/TA1.0   - SD_SDO
    BIS #04C0h,&PASEL1  ; Configure UCB0 pins P1.6 as UCB0SIMO, P1.7 as UCB0SOMI& UCB0 pins P2.2 as UCB0CLK
                        ; PxDIR.x is controlled by eUSCI_A0 module
    BIC #04C0h,&PAREN   ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF
    .IFDEF MSP_EXP430FR6989 

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.7                <--- SD_CD (Card Detect)
SD_CD           .equ  80h
SD_CDIN         .equ  P2IN
; P2.6                ---> SD_CS (Card Select)
SD_CS           .equ  40h
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P2.2  UCA0     CLK  ---> SD_CLK
; P2.0  UCA0 TX/SIMO  ---> SD_SDI
; P2.2  UCA0 RX/SOMI  <--- SD_SDO
    BIS.B #007h,&P2SEL0 ; Configure UCA1 pins P2.2 as UCA0CLK, P2.0 as UCA0SIMO & P2.1 as UCA0SOMI
                        ; P2DIR.x is controlled by eUSCI_A0 module
    BIC.B #007h,&P2REN  ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF
;    .IFDEF MSP_EXP430FR4133 
;
;; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?
;
;; P8.0                <--- SD_CD (Card Detect)
;SD_CD           .equ  1
;SD_CDIN         .equ  P8IN
;; P8.1                ---> SD_CS (Card Select)
;SD_CS           .equ  2
;SD_CSOUT        .equ  P8OUT
;    BIS.B #SD_CS,&P8DIR ; SD_CS output high
;
;; P5.1  UCB0     CLK  ---> SD_CLK
;; P5.2  UCB0 TX/SIMO  ---> SD_SDI
;; P5.3  UCB0 RX/SOMI  <--- SD_SDO
;    BIS.B   #00Eh,&P5SEL1   ; Configure UCB0 pins P5.1 as CLK, P5.2 as SIMO & P5.3 as SOMI
;                            ; P2DIR.x is controlled by eUSCI_A0 module
;    BIC.B   #00Eh,&P5REN    ; disable pullup resistors for SIMO/SOMI/SCK pins
;
;    .ENDIF
    .IFDEF CHIPSTICK_FR2433 

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.3                <--- SD_CD (Card Detect)
SD_CD           .equ  8
SD_CDIN         .equ  P2IN
; P2.2                ---> SD_CS (Card Select)
SD_CS           .equ  4
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P1.1  UCB0     CLK  ---> SD_CLK
; P1.2  UCB0 TX/SIMO  ---> SD_SDI
; P1.3  UCB0 RX/SOMI  <--- SD_SDO
    BIS.B   #00Eh,&P1SEL0   ; Configure UCB0 pins P1.1 as CLK, P1.2 as SIMO & P1.3 as SOMI
                            ; P1DIR.x is controlled by eUSCI_B0 module
    BIC.B   #00Eh,&P1REN    ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF
    .IFDEF MY_MSP430FR5738

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.3 as SD_CD
SD_CD           .equ  08h
SD_CDIN         .equ  P2IN
; P2.4 as SD_CS
SD_CS           .equ  10h
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P2.2/UCB0CLK                ---> SD_CardAdapter CLK (SCK)   default value
; P1.6/UCB0SIMO/UCB0SDA/TA0.0 ---> SD_CardAdapter SDI (MOSI)  default value
; P1.7/UCB0SOMI/UCB0SCL/TA1.0 <--- SD_CardAdapter SDO (MISO)  default value
    BIS #04C0h,&PASEL1  ; Configure UCB0 pins P2.2 as UCB0CLK, P1.6 as UCB0SIMO & P1.7 as UCB0SOMI
                        ; P2DIR.x is controlled by eUSCI_B0 module
    BIC #04C0h,&PAREN   ; disable pullup resistors for SIMO/SOMI/CLK pins

    .ENDIF
    .IFDEF MY_MSP430FR5738_1

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.3 as SD_CD
SD_CD           .equ  08h
SD_CDIN         .equ  P2IN
; P2.4 as SD_CS
SD_CS           .equ  10h
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P2.2/UCB0CLK                ---> SD_CardAdapter CLK (SCK)   default value
; P1.6/UCB0SIMO/UCB0SDA/TA0.0 ---> SD_CardAdapter SDI (MOSI)  default value
; P1.7/UCB0SOMI/UCB0SCL/TA1.0 <--- SD_CardAdapter SDO (MISO)  default value
    BIS #04C0h,&PASEL1  ; Configure UCB0 pins P2.2 as UCB0CLK, P1.6 as UCB0SIMO & P1.7 as UCB0SOMI
                        ; P2DIR.x is controlled by eUSCI_B0 module
    BIC #04C0h,&PAREN   ; disable pullup resistors for SIMO/SOMI/CLK pins

    .ENDIF
    .IFDEF MY_MSP430FR5948 

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.3                <--- SD_CD (Card Detect)
SD_CD           .equ  08h
SD_CDIN         .equ  P2IN 
; P2.7                ---> SD_CS (Card Select)
SD_CS           .equ  80h
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P2.4  UCA1     CLK  ---> SD_CLK
; P2.5  UCA1 TX/SIMO  ---> SD_SDI
; P2.6  UCA1 RX/SOMI  <--- SD_SDO
    BIS.B #070h,&P2SEL1 ; Configure UCA1 pins P2.4 as UCA1CLK, P2.5 as UCA1SIMO & P2.6 as UCA1SOMI
                        ; P2DIR.x is controlled by eUSCI_A0 module
    BIC.B #070h,&P2REN  ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF
    .IFDEF MY_MSP430FR5948_1 ; = new version of MY_MSP430FR5948

; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?

; P2.7                ---> SD_CD (Card Detect)
SD_CD           .equ  80h
SD_CDIN         .equ  P2IN
; P2.3                <--- SD_CS (Card Select)
SD_CS           .equ  08h
SD_CSOUT        .equ  P2OUT
    BIS.B #SD_CS,&P2DIR ; SD_CS output high

; P2.4  UCA1     CLK  ---> SD_CLK
; P2.5  UCA1 TX/SIMO  ---> SD_SDI
; P2.6  UCA1 RX/SOMI  <--- SD_SDO
    BIS.B #070h,&P2SEL1 ; Configure UCA1 pins P2.4 as UCA1CLK, P2.5 as UCA1SIMO & P2.6 as UCA1SOMI
                        ; P2DIR.x is controlled by eUSCI_A0 module
    BIC.B #070h,&P2REN  ; disable pullup resistors for SIMO/SOMI/SCK pins

    .ENDIF

    BIC     #1,&SD_CTLW0            ; release eUSCI from reset

; ===========================================================
; 2- Init all SD_Card variables, handles and SDIB buffer to 0
; ===========================================================

InitSDdata
    MOV     #SD_ORG_DATA,X          ;
InitSDdataLoop                      ;
    MOV     #0,0(X)                 ;
    ADD     #2,X                    ;
    CMP     #SD_END_DATA,X          ;
    JNE     InitSDdataLoop          ;


; ===========================================================
; 3- Init SD_Card
; ===========================================================

SD_POWER_ON
    MOV     #8,X                    ; send 64 clk on SD_clk
    CALL    #SPI_X_GET              ;
    BIC.B   #SD_CS,&SD_CSOUT        ; set SD_CS output low to switch in SPI mode
    MOV     #4,S                    ; preset error 4R1
SEND_CMD0                           ; CMD0 : GO_IDLE_STATE
    MOV     #95h,&SD_CMD_FRM        ; $(95 00 00 00 00 00)
    MOV     #4000h,&SD_CMD_FRM+4    ; $(95 00 00 00 00 40); send CMD0 
    MOV     #1,W                    ; expected SPI_R1 response = 1 = idle state
    CALL    #sendCommand            ;X
    JZ      INIT_CMD8               ; if idle state
SD_INIT_ERROR                       ;
    MOV     #SD_CARD_ERROR,PC       ; ReturnError = $04R1, case of defectuous card (or insufficient SD_POWER_ON clk)
; ----------------------------------;
INIT_CMD8                           ; mandatory if SD_Card >= V2.x [11:8]supply voltage(VHS)
; ----------------------------------;
    CALL    #SPI_GET                ; (needed to pass SanDisk ultra 8GB "HC I")
    CMP.B   #-1,W                   ; FFh expected value <==> MISO = high level
    JNE     INIT_CMD8               ; loop back while yet busy
; ----------------------------------;
    MOV     #8,S                    ; preset error 8R1 for CMD1
    MOV     #0AA87h,&SD_CMD_FRM     ; $(87 AA ...)  (CRC:CHECK PATTERN)
    MOV     #1,&SD_CMD_FRM+2        ; $(87 AA 01 00 ...)  (CRC:CHECK PATTERN:VHS set as 2.7to3.6V:0)
    MOV     #4800h,&SD_CMD_FRM+4    ; $(87 AA 01 00 00 48)
SEND_CMD8                           ; CMD8 = SEND_IF_COND
    MOV     #1,W                    ; expected R1 response (first byte of SPI R7) = 01h : idle state
    CALL    #sendCommand            ; 
; ----------------------------------;
CMD8_NEXT                           ; time out occured with SD_Card V1.x and all MMC_card
    MOV     #4,X                    ;
    CALL    #SPI_X_GET              ;WX skip end of SD_Card V2.x type R7 response (4 bytes)
; ----------------------------------;
    MOV     #1,&SD_CMD_FRM          ; $(01 00 ...   set stop bit
    MOV     #0,&SD_CMD_FRM+2        ; $(01 00 00 00 ...
;    MOV.B   #16,Y                   ; init 16 * ACMD41 repeats (power on fails with SanDisk ultra 8GB "HC I" and Transcend 2GB)
;    MOV.B   #32,Y                   ; init 32 * ACMD41 repeats  ==> ~400ms
    MOV.B   #-1,Y                   ; init 255 * ACMD41 repeats ==> 3 s
; ----------------------------------;
SEND_ACMD41                         ; (CMD55+CMD41)
; ----------------------------------;
    ADD     S,S                     ; preset error 10R1 for ACMD41
SEND_CMD55                          ; CMD55 = APP_CMD
    MOV     #7700h,&SD_CMD_FRM+4    ; $(01 00 00 00 00 77)
    MOV     #1,W                    ; expected R1 response = 1 : idle
    CALL    #sendCommand            ;
SEND_CMD41                          ; CMD41 = APP OPERATING CONDITION
    MOV     #6940h,&SD_CMD_FRM+4    ; $(01 00 00 00 40 69) (30th bit = HCS = High Capacity Support request)
    CALL    #SDbusyLoop             ; wait until busy (needed to pass SanDisk ultra 8GB "HC I") then send Command CMD41
    JZ      SetBLockLength          ; if SD_Card ready (R1=0)
    SUB.B   #1,Y                    ; else decr time out delay
    JNZ     SEND_CMD55              ; then loop back while count of repeat not reached
    JMP     SD_INIT_ERROR           ; ReturnError on time out : unusable card
; ----------------------------------;
setBLockLength                      ; set block = 512 bytes (buffer size), usefull for FAT16 SD Cards
; ----------------------------------;
    ADD     S,S                     ; preset error $20 for CMD16
SEND_CMD16                          ; CMD16 = SET_BLOCKLEN
    MOV     #02h,&SD_CMD_FRM+2      ; $(01 00 02 00 ...)
    MOV     #5000h,&SD_CMD_FRM+4    ; $(01 00 02 00 00 50) 
    CALL    #SDbusyLoop             ; wait until busy then send CMD16
    JNZ     SD_INIT_ERROR           ; if W = R1 <> 0, ReturnError = $20R1 ; send command ko
; ----------------------------------;
SetHighSpeed                        ; end of SD init ==> SD_CLK = SMCLK
; ----------------------------------;
    BIS     #1,&SD_CTLW0            ; Software reset
    MOV     #0,&SD_BRW              ; UCxxBRW = 0 ==> SPI_CLK = MCLK
    BIC     #1,&SD_CTLW0            ; release from reset
; ----------------------------------;
Read_EBP_FirstSector                ; W=0, BS_FirstSectorHL=0
; ----------------------------------;
    ADD     S,S                     ; preset error $40 ; SD card not FAT16/FAT32
    CALL    #readSectorW            ; read physical first sector
    MOV     #BUFFER,Y               ;
    MOV     454(Y),&BS_FirstSectorL ;
    MOV     456(Y),&BS_FirstSectorH ;
    MOV.B   450(Y),W                ; W = partition ID 
; ----------------------------------;
TestPartitionID                     ;
; ----------------------------------;
    MOV     #1,&FATtype             ; preset FAT16
FAT16_CHS_LBA_Test                  ;
    SUB.B   #6,W                    ; ID=06h Partition FAT16 using CHS & LBA ?
    JZ      Read_MBR_FirstSector    ;
FAT16_LBA_Test                      ;
    SUB.B   #8,W                    ; ID=0Eh Partition FAT16 using LBA ?
    JZ      Read_MBR_FirstSector    ;
; ----------------------------------;
    MOV     #2,&FATtype             ; set FAT32
FAT32_LBA_Test                      ;
    ADD.B   #2,W                    ; ID=0Ch Partition FAT32 using LBA ?
    JZ      Read_MBR_FirstSector    ;
FAT32_CHS_LBA_Test                  ;
    ADD.B   #1,W                    ; ID=0Bh Partition FAT32 using CHS & LBA ?
    JZ      Read_MBR_FirstSector    ;
    ADD.B   #0Bh,W
    JNZ     SD_INIT_ERROR           ; ReturnError = $40xx with xx = partition ID 
; ----------------------------------;
Read_MBR_FirstSector                ; W=0
; ----------------------------------;
    CALL    #readSectorW            ; ...with the good bytes/sectors (FAT16/FAT32) CMD17 frame !
; ----------------------------------;
FATxx_SetFileSystem                 ;
; ----------------------------------;
    MOV.B   13(Y),&SecPerClus       ;
    MOV     14(Y),X                 ;3 X = BPB_RsvdSecCnt
    MOV     X,&OrgFAT1              ;3 set OrgFAT1
    MOV     22(Y),W                 ; W = BPB_FATsize
    CMP     #0,W                    ; BPB_FATsize = 0 ?
    JNZ     Set_FATsize             ;
    MOV     36(Y),W                 ; W = BPB_FATSz32
Set_FATsize                         ;
    MOV     W,&FATSize              ; limited to 16384 sectors....
    ADD     W,X                     ;
    MOV     X,&OrgFAT2              ; X = OrgFAT1 + FATsize = OrgFAT2
    ADD     W,X                     ; X = OrgFAT2 + FATsize = FAT16 OrgRootDir | FAT32 OrgDatas
    CMP     #2,&FATtype             ; FAT32?
    JZ      FATxx_SetFileSystemNext ; yes
FAT16_SetRootCluster                ;
    MOV     X,&OrgRootDIR           ; only FAT16 use, is a sector used by ComputeClusFrstSect
    ADD     #32,X                   ; OrgRootDir + RootDirSize = OrgDatas
FATxx_SetFileSystemNext             ;
    SUB     &SecPerClus,X           ; OrgDatas - SecPerClus*2 = OrgClusters
    SUB     &SecPerClus,X           ; no borrow expected
    MOV     X,&OrgClusters          ; X = virtual cluster 0 address (clusters 0 and 1 don't exist)
    MOV     &FATtype,&DIRClusterL   ; init DIRcluster as RootDIR
; ----------------------------------;


