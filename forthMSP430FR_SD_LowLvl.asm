; -*- coding: utf-8 -*-
; forthMSP430FR_SD_lowLvl.asm

BytsPerSec      .equ 512

; all sectors are computed as logical, then physically translated at last time by RW_Sector_CMD

; in SPI mode CRC is not required, but CMD frame must be ended with a stop bit
; ==================================;
RW_Sector_CMD                       ;WX <=== CMD17 or CMD24 (read or write Sector CMD)
; ==================================;
    BIC.B   #CS_SD,&SD_CSOUT        ; set Chip Select low
    BIT.B   #CD_SD,&SD_CDIN         ; test Card Detect: memory card present ?
    JZ      ComputePhysicalSector   ; yes
    MOV     #COLD,PC                ; no: force COLD
; ----------------------------------;
ComputePhysicalSector               ; input = logical sector...
; ----------------------------------;
    ADD     &BS_FirstSectorL,W      ;3
    ADDC    &BS_FirstSectorH,X      ;3
; ----------------------------------; ...output = physical sector
;Compute CMD                        ;
; ----------------------------------;
    MOV     #1,&SD_CMD_FRM          ;3 $(01 00 xx xx xx CMD) set stop bit in CMD frame
    CMP     #2,&FATtype             ;3 FAT32 ?          
    JZ      FAT32_CMD               ;2 yes
FAT16_CMD                           ;  FAT16 : CMD17/24 byte address = Sector * BPB_BytsPerSec
    ADD     W,W                     ;1 shift left one Sector
    ADDC.B  X,X                     ;1
    MOV     W,&SD_CMD_FRM+2         ;3 $(01 00 ll LL xx CMD)
    MOV.B   X,&SD_CMD_FRM+4         ;3 $(01 00 ll LL hh CMD) 
    JMP     WaitIdleBeforeSendCMD   ;
FAT32_CMD                           ;  FAT32 : CMD17/24 sector address
    MOV.B   W,&SD_CMD_FRM+1         ;3 $(01 ll xx xx xx CMD)
    SWPB    W                       ;1
    MOV.B   W,&SD_CMD_FRM+2         ;3 $(01 ll LL xx xx CMD)
    MOV.B   X,&SD_CMD_FRM+3         ;3 $(01 ll LL hh xx CMD)
    SWPB    X                       ;1
    MOV.B   X,&SD_CMD_FRM+4         ;3 $(01 ll LL hh HH CMD)
; ==================================;
WaitIdleBeforeSendCMD               ; <=== CMD41, CMD1, CMD16 (forthMSP430FR_SD_INIT.asm)
; ==================================;
    CALL #SPI_GET                   ;
    ADD.B   #1,W                    ; expected value = FFh <==> MISO = 1 = SPI idle state
    JNZ WaitIdleBeforeSendCMD       ; loop back if <> FFh
; ==================================; W = 0 = expected R1 response = ready, for CMD41,CMD16, CMD17, CMD24
sendCommand                         ;  
; ==================================;
                                    ; input : SD_CMD_FRM : {CRC,byte_l,byte_L,byte_h,byte_H,CMD} 
                                    ;         W = expected return value
                                    ; output  W is unchanged, flag Z is positionned
                                    ; reverts CMD bytes before send : $(CMD hh LL ll 00 CRC)
    MOV     #5,X                    ; X = SD_CMD_FRM ptr AND countdown
; ----------------------------------;
Send_CMD_PUT                        ; performs little endian --> big endian conversion
; ----------------------------------;
    MOV.B   SD_CMD_FRM(X),&SD_TXBUF ;5 
    CMP     #0,&SD_BRW              ;3 full speed ?
    JZ      FullSpeedSend           ;2 yes
Send_CMD_Loop                       ;  case of low speed during memCardInit
    BIT     #RX_SD,&SD_IFG          ;3
    JZ      Send_CMD_Loop           ;2
    CMP.B   #0,&SD_RXBUF            ;3 to clear UCRXIFG
FullSpeedSend                       ;
;   NOP                             ;0 NOPx adjusted to avoid SD error
    SUB.B   #1,X                    ;1
    JC      Send_CMD_PUT            ;2 U>= : don't skip SD_CMD_FRM(0) !

                                    ; host must provide height clock cycles to complete operation
                                    ; here X=255, so wait for CMD return expected value with PUT FFh 256 times

;    MOV     #4,X                    ; to pass made in PRC SD_Card init 
;    MOV     #16,X                   ; to pass Transcend SD_Card init
;    MOV     #32,X                   ; to pass Panasonic SD_Card init
;    MOV     #64,X                   ; to pass SanDisk SD_Card init
; ----------------------------------;
Wait_Command_Response               ; expect W = return value during X = 255 times
; ----------------------------------;
    SUB     #1,X                    ;1
    JN      SPI_WAIT_RET            ;2 error on time out with flag Z = 0
    MOV.B   #-1,&SD_TXBUF           ;3 PUT FFh
    CMP     #0,&SD_BRW              ;3 full speed ?
    JZ      FullSpeedGET            ;2 yes
cardResp_Getloop                    ;  case of low speed during memCardInit (CMD0,CMD8,ACMD41,CMD16)
    BIT     #RX_SD,&SD_IFG          ;3
    JZ      cardResp_Getloop        ;2
FullSpeedGET                        ;
;    NOP                            ;  NOPx adjusted to avoid SD_error
    CMP.B   &SD_RXBUF,W             ;3 return value = ExpectedValue ?
    JNZ     Wait_Command_Response   ;2 16~ full speed loop
SPI_WAIT_RET                        ; flag Z = 1 <==> Returned value = expected value
    MOV @RSP+,PC                    ; W = expected value, unchanged
; ----------------------------------;

; ----------------------------------;
sendCommandIdleRet                  ; <=== CMD0, CMD8, CMD55: W = 1 = R1 expected response = idle (forthMSP430FR_SD_INIT.asm)
; ----------------------------------;
    MOV     #1,W                    ; expected R1 response (first byte of SPI R7) = 01h : idle state
    JMP     sendCommand             ;
; ----------------------------------;


; SPI_GET and SPI_PUT are adjusted for SD_CLK = MCLK
; PUT value must be a word or  byte:byte because little endian to big endian conversion

; ==================================;
SPI_GET                             ; PUT(FFh) one time, output : W = received byte, X = 0
; ==================================;
    MOV #1,X                        ;
; ==================================;
SPI_X_GET                           ; PUT(FFh) X times, output : W = last received byte, X = 0
; ==================================;
    MOV #-1,W                       ;
; ==================================;
SPI_PUT                             ; PUT(W) X times, output : W = last received byte, X = 0
; ==================================;
            SWPB W                  ;1 
            MOV.B W,&SD_TXBUF       ;3 put W high byte then W low byte and so forth, that performs little to big endian conversion
            CMP #0,&SD_BRW          ;3 full speed ?
            JZ FullSpeedPut         ;2 
SPI_PUTWAIT BIT #RX_SD,&SD_IFG      ;3
            JZ SPI_PUTWAIT          ;2
            CMP.B #0,&SD_RXBUF      ;3 reset RX flag
FullSpeedPut
;           NOP                     ;  NOPx adjusted to avoid SD error
            SUB #1,X                ;1
            JNZ SPI_PUT             ;2 12~ loop
SPI_PUT_END MOV.B &SD_RXBUF,W       ;3
            MOV @RSP+,PC            ;4
; ----------------------------------;

        ASMWORD "READ_SWX"
; ==================================;
ReadSectorWX                        ; SWX read a logical sector
; ==================================;
    BIS     #1,S                    ; preset sd_read error
    MOV.B   #51h,&SD_CMD_FRM+5      ; CMD17 = READ_SINGLE_BLOCK
    CALL    #RW_Sector_CMD          ; which performs logical sector to physical sector then little endian to big endian conversion
    JNE     SD_CARD_ERROR           ; time out error if R1 <> 0 
; ----------------------------------;
WaitFEhResponse                     ; wait SD_Card response FEh
; ----------------------------------;
    CALL #SPI_GET                   ;
    ADD.B   #2,W                    ;1 FEh expected value
    JZ  ReadSectorFirstByte         ; 2
    JNZ WaitFEhResponse             ;2
; ----------------------------------;
ReadSectorLoop                      ; get 512+1 bytes, write 512 bytes in SD_BUF
; ----------------------------------;
    MOV.B   &SD_RXBUF,SD_BUF-1(X)   ; 5
ReadSectorFirstByte                 ; 
    MOV.B   #-1,&SD_TXBUF           ; 3 put FF
    NOP                             ; 1 NOPx adjusted to avoid read SD_error
    ADD     #1,X                    ; 1
    CMP     #BytsPerSec+1,X         ; 2
    JNZ     ReadSectorLoop          ; 2 14 cycles loop read byte
; ----------------------------------;
    MOV.B #-1,&SD_TXBUF             ; 3 put only one FF because first CRC byte is already received...
; ----------------------------------;
ReadWriteHappyEnd                   ; <==== WriteSector
; ----------------------------------;
    BIC #3,S                        ; reset read and write errors
    BIS.B #CS_SD,&SD_CSOUT          ; Chip Select high
    MOV @RSP+,PC                    ; 
; ----------------------------------;

    .IFDEF SD_CARD_READ_WRITE

        ASMWORD "WRITE_SWX"
; ==================================;
WriteSectorWX                       ; write a logical sector
; ==================================;
    BIS     #2,S                    ; preset sd_write error
    MOV.B   #058h,SD_CMD_FRM+5      ; CMD24 = WRITE_SINGLE_BLOCK
    CALL    #RW_Sector_CMD          ; which performs logical sector to physical sector then little endian to big endian conversions
    JNE     SD_CARD_ERROR           ; ReturnError = 2
    MOV     #0FFFEh,W               ; PUT FFFEh as preamble requested for sector write
    MOV     #2,X                    ; to put 16 bits value
    CALL    #SPI_PUT                ; which performs little endian to big endian conversion
; ----------------------------------;
WriteSectorLoop                     ; 11 cycles loop write, starts with X = 0
; ----------------------------------;
    MOV.B   SD_BUF(X),&SD_TXBUF     ; 5
    NOP                             ; 1 NOPx adjusted to avoid write SD_error
    ADD     #1,X                    ; 1
    CMP     #BytsPerSec,X           ; 2
    JNZ     WriteSectorLoop         ; 2
; ----------------------------------;
WriteSkipCRC16                      ; CRC16 not used in SPI mode
; ----------------------------------;
    MOV     #3,X                    ; PUT 2 bytes to skip CRC16
    CALL    #SPI_X_GET              ; + 1 byte to get data token in W
; ----------------------------------;
CheckWriteState                     ;
; ----------------------------------;
    BIC.B   #0E1h,W                 ; apply mask for Data response
    CMP.B   #4,W                    ; data accepted
    JZ      ReadWriteHappyEnd       ;
; ----------------------------------;

    .ENDIF ; SD_CARD_READ_WRITE

; SD Error n°
; High byte
; 1   = CMD17    read error
; 2   = CMD24    write error 
; 4   = CMD0     time out (GO_IDLE_STATE)
; 8   = ACMD41   time out (APP_SEND_OP_COND)
; $10 = CMD16    time out (SET_BLOCKLEN)
; $20 = not FAT16/FAT32 media, low byte = partition ID

; low byte, if CMD R1 response : %0xxx_xxxx
; 1th bit = In Idle state
; 2th bit = Erase reset
; 3th bit = Illegal command
; 4th bit = Command CRC error
; 5th bit = erase sequence error
; 6th bit = address error
; 7th bit = parameter error

; Data Response Token
; Every data block written to the card will be acknowledged by a data response token. 
; It is one byte long and has the following format:
; %xxxx_sss0 with bits(3-1) = Status
;The meaning of the status bits is defined as follows:
;'010' - Data accepted.
;'101' - Data rejected due to a CRC error.
;'110' - Data Rejected due to a Write Error

; ----------------------------------;
SD_CARD_ERROR                       ; <=== SD_INIT errors 4,8,$10 from forthMSP430FR_SD_INIT.asm
; ----------------------------------;
    SWPB S                          ; High Level error in High byte
    ADD &SD_RXBUF,S                 ; add SPI(GET) return value as low byte error
SD_CARD_ID_ERROR                    ; <=== SD_INIT error $20 from forthMSP430FR_SD_INIT.asm
    BIS.B #CS_SD,&SD_CSOUT          ; Chip Select high
    mDOCOL                          ;
    .word   ECHO
    .word   XSQUOTE                 ; don't use S register
    .byte   11,"< SD Error!"        ;
; ----------------------------------;
ABORT_SD                            ; <=== OPEN file errors from forthMSP430FR_SD_LOAD.asm
; ----------------------------------;
    .word   $+2                     ;
    SUB #2,PSP                      ;
    MOV TOS,0(PSP)                  ;
    MOV #10h,&BASE                  ; select hex
    MOV S,TOS                       ;
    ASMtoFORTH                      ;
    .word UDOT,ABORT_TERM           ; no return...
; ----------------------------------;

