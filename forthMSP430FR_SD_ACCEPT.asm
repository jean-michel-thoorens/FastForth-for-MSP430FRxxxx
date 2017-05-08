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


;Z SD_ACCEPT  addr addr len -- addr' len'  get line to interpret from a SD Card file
; note : addr = TIB, addr' = PAD
; defered word ACCEPT is redirected here by the word LOAD"
; sequentially move an input line ended by CRLF from BUFFER to PAD
;   if end of buffer is reached before CRLF, asks Read_HandledFile to fill buffer with next sector
;   then move the end of the line.
; when all LOAD"ed files are read, redirects defered word ACCEPT to (ACCEPT) and restore interpret pointers.
; see CloseHandleT.

; used variables : BufferPtr, BufferLen

; ----------------------------------;
;    FORTHWORD "SD_ACCEPT"          ; TIB TIB len -- SDIB len'
; ----------------------------------;
SD_ACCEPT                           ; sequentially move from BUFFER to SDIB (or PAD) a line of chars delimited by CRLF
; ----------------------------------;
    PUSH    IP                      ;
    MOV     #SDA_YEMIT_RET,IP       ; set YEMIT return
; ----------------------------------;
StartNewLine                        ;
; ----------------------------------;
    MOV     &CurrentHdl,T           ; prepare link for any next LOAD"ed file...
    MOV &BufferPtr,HDLW_BUFofst(T)  ; ...see usage : HandleComplements
    .IFDEF RAM_1K                   ; use PAD as SD Input Buffer because the lack of RAM
    MOV     #PAD,W                  ;               W=dst
    MOV     W,2(PSP)                ; -- PAD TIB max_chars_count
    MOV     #PAD_SIZE-4,0(PSP)      ; -- StringOrg' len" len
    .ELSEIF                         ; RAM >= 2k
    MOV     #SDIB,W                 ;               W=dst
    MOV     W,2(PSP)                ; -- SDIB TIB max_chars_count
    MOV     #SDIB_SIZE-4,0(PSP)     ; -- StringOrg' len" len
    .ENDIF
    MOV     #0,TOS                  ; -- StringOrg' len" Count
; ----------------------------------;
SDA_InitSrcAddr                     ; <== SDA_GetFileNextSector (if BufferLen<>0)
; ----------------------------------;
    MOV     &BufferPtr,X            ;               X=src (buf_offset)
    JMP     SDA_ComputeChar         ;
; ----------------------------------;
SDA_YEMIT_RET                       ;
; ----------------------------------;
    FORTHtoASM                      ;
    SUB     #2,IP                   ; 1 restore YEMIT return
; ----------------------------------;
SDA_ComputeChar                     ;
; ----------------------------------;
    CMP     &BufferLen,X            ; 3 BufferPtr >= BufferLen ?
    JHS     SDA_GetFileNextSector   ; 2 yes
    MOV.B   BUFFER(X),Y             ; 3 Y = char
    ADD     #1,X                    ; 1 increment input BufferPtr
    CMP.B   #32,Y                   ; 2 ascii printable char ?
    JHS     SDA_MoveChar            ; 2 yes
    CMP.B   #10,Y                   ; control char = 'LF' ?
    JNZ     SDA_ComputeChar         ; no
; ----------------------------------;
SDA_EndOfLine                       ;
; ----------------------------------;
    MOV     X,&BufferPtr            ; yes  save BufferPtr for next line
;    MOV     &CurrentHdl,T           ; prepare link for case of this line ask to LOAD" a new file...
;    MOV     X,HDLW_BUFofst(T)       ; to handle update. 
; ----------------------------------;
SDA_GoToInterpret                   ;
; ----------------------------------;
    ADD     #2,PSP                  ; -- StringOrg' len'
    MOV     @RSP+,IP                ;
    MOV     @IP+,PC                 ; ===> unique output
; ----------------------------------;
SDA_MoveChar                        ;
; ----------------------------------;
    CMP     TOS,0(PSP)              ; 3 count = max_chars_count ?
    JZ      YEMIT                   ; 2 yes, don't move char to dst
    MOV.B   Y,0(W)                  ; 3 move char to dst
    ADD     #1,W                    ; 1 increment dst addr
    ADD     #1,TOS                  ; 1 increment count of moved chars
    JMP     YEMIT                   ; 9/6~ send echo to terminal if ECHO, do nothing if NOECHO
; ----------------------------------; 33/30~ char loop
SDA_GetFileNextSector               ;
; ----------------------------------;
    PUSH    W                       ; save dst
    CALL    #Read_File              ; STWXY use
    MOV     @RSP+,W                 ; restore dst
    CMP     #0,&BufferLen           ; test if input buffer is empty (EOF)
    JNZ     SDA_InitSrcAddr         ; no : loopback to end the line
    JMP     SDA_GoToInterpret       ; yes, loopback to interpret the line, then on next SD_ACCEPT goto SDA_RestoreInputBuffer
; ----------------------------------;


;C ACCEPT  addr addr len -- addr' len'  get line at addr to interpret len' chars
            FORTHWORD "ACCEPT"
ACCEPT      MOV     #PARENACCEPT,PC

;C (ACCEPT)  addr addr len -- addr len'     get len' (up to len) chars from terminal (TERATERM.EXE) via USBtoUART bridge
            FORTHWORD "(ACCEPT)"
PARENACCEPT

