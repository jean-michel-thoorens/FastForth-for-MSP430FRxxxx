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
;    FORTHWORD "SD_ACCEPT"          ; TIB TIB TIB_LEN -- PAD|SDIB len'
; ----------------------------------;
SD_ACCEPT                           ; sequentially move from BUFFER to SDIB (or PAD) a line of chars delimited by CRLF
; ----------------------------------; up to TIB_LEN = 80 chars
    PUSH    IP                      ;
    MOV     #SDA_YEMIT_RET,IP       ; set YEMIT return
; ----------------------------------;
StartNewLine                        ;
; ----------------------------------;
    MOV &CurrentHdl,T               ; prepare a link for the next LOADed file...
    MOV &BufferPtr,HDLW_BUFofst(T)  ; ...see usage : HandleComplements
; ----------------------------------; -- TIB TIB len
    .IFDEF RAM_1K                   ; use PAD as SD Input Buffer because the lack of RAM
    MOV     #PAD,W                  ;               W=dst
    .ELSEIF                         ; use SDIB as SD Input Buffer
    MOV     #SDIB,W                 ;               W=dst
    .ENDIF
    MOV     W,2(PSP)                ; -- StringOrg' TIB TIB_LEN
    MOV     TOS,0(PSP)              ; -- StringOrg' TIB_LEN TIB_LEN
    MOV     #0,TOS                  ; -- StringOrg' TIB_LEN Count
; ----------------------------------;
SDA_InitSrcAddr                     ; <== SDA_GetFileNextSector
; ----------------------------------;
    CMP     #0,&BufferLen           ; test if input buffer is empty (EOF)
    JZ      SDA_GoToInterpret       ; yes, to interpret an empty line (to do nothing)
    MOV     &BufferPtr,X            ;               X=src
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
    CMP.B   #10,Y                   ; 2 control char = 'LF' ?
    JNZ     SDA_ComputeChar         ; 2 no
; ----------------------------------;
SDA_EndOfLine                       ;
; ----------------------------------;
    MOV     X,&BufferPtr            ; yes  save BufferPtr for next line
; ----------------------------------;
SDA_GoToInterpret                   ; -- StringOrg' TIB_LEN len'
; ----------------------------------;
    ADD     #2,PSP                  ; -- StringOrg' len'
    MOV     @RSP+,IP                ;
    MOV     @IP+,PC                 ; ===> unique output
; ----------------------------------;
SDA_MoveChar                        ;
; ----------------------------------;
    CMP     @PSP,TOS                ; 2 count = TIB_LEN ?
    JZ      YEMIT                   ; 2 yes, don't move char to dst
    MOV.B   Y,0(W)                  ; 3 move char to dst
    ADD     #1,W                    ; 1 increment dst addr
    ADD     #1,TOS                  ; 1 increment count of moved chars
    JMP     YEMIT                   ; 9/6~ send echo to terminal if ECHO, do nothing if NOECHO
; ----------------------------------; 32/29~ char loop, add 14~ for readsectorW ==> 46/43~ ==> 174/186 kbytes/s @ 8MHz
SDA_GetFileNextSector               ; StringOrg' TIB_LEN Count --
; ----------------------------------;
    PUSH    W                       ; save dst
    CALL    #Read_File              ; that resets BufferPtr
    MOV     @RSP+,W                 ; restore dst
    JMP     SDA_InitSrcAddr         ; loopback to end the line
; ----------------------------------;


