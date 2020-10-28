; -*- coding: utf-8 -*-
;
;Z SD_ACCEPT  addr addr len -- addr' len'  get line to interpret from a SD Card file
; no interrupt allowed
; defered word ACCEPT is redirected here by the word LOAD"
; "defered" word CIB is redirected to SDIB (PAD if RAM<2k) by the word LOAD"
; sequentially move an input line ended by CRLF from SD_BUF to PAD
;   if end of SD_BUF is reached before CRLF, asks Read_HandledFile to refill buffer with next sector
;   then load the end of the line to PAD ptr.
; when all LOAD"ed files are read, redirects defered word ACCEPT to default ACCEPT and restore interpret pointers.
; see CloseHandleT.

; used variables : BufferPtr, BufferLen

; ----------------------------------;
;    FORTHWORD "SD_ACCEPT"          ; CIB CIB CPL -- CIB len
; ----------------------------------;
SD_ACCEPT                           ; sequentially move from SD_BUF to SDIB (PAD if RAM=1k) a line of chars delimited by CRLF
; ----------------------------------; up to CPL = 80 chars
    PUSH    IP                      ;
    MOV     #SDA_YEMIT_RET,IP       ; set YEMIT return
; ----------------------------------;
StartNewLine                        ; -- CIB CIB CPL
; ----------------------------------;
    MOV &CurrentHdl,T               ; prepare a link for the next LOADed file, if any...
    MOV &BufferPtr,HDLW_BUFofst(T)  ; ...see usage : GetFreeHandle(CheckCaseOfLoadFileToken)
; ----------------------------------;
    MOV     @PSP+,W                 ; -- CIB CPL        W=dst_ptr
    MOV     TOS,X                   ;                   X=dst_len
    MOV     #0,TOS                  ; -- CIB cnt
; ----------------------------------;
SDA_InitSrcAddr                     ; <== SDA_GetFileNextSector
; ----------------------------------;
    MOV     &BufferPtr,S            ;                   S=src_ptr
    MOV     &BufferLen,T            ;                   T=src_len
    JMP     SDA_ComputeChar         ;
; ----------------------------------;
SDA_YEMIT_RET                       ;
; ----------------------------------;
    .word   $+2                     ;
    SUB     #2,IP                   ; 1                 restore YEMIT return
; ----------------------------------;
SDA_ComputeChar                     ; -- CIB cnt
; ----------------------------------;
    CMP     T,S                     ; 1 src_ptr >= src_len ?
    JC      SDA_GetFileNextSector   ; 2 yes
    MOV.B   SD_BUF(S),Y             ; 3 Y = char
    ADD     #1,S                    ; 1 increment input BufferPtr
    CMP.B   #32,Y                   ; 2 ascii printable char ?
    JC      SDA_MoveChar            ; 2 yes
    CMP.B   #10,Y                   ; 2 control char = 'LF' ?
    JNZ     SDA_ComputeChar         ; 2 no
; ----------------------------------;
SDA_EndOfLine                       ; -- org cnt
; ----------------------------------;
    MOV     @RSP+,IP                ;
    MOV     S,&BufferPtr            ; yes  save BufferPtr for next line
    MOV     #32,S                   ; S = BL
    JMP     ACCEPT_EOL              ; ==> output            
; ----------------------------------;
SDA_MoveChar                        ;
; ----------------------------------;
    CMP     X,TOS                   ; 1 cnt = dst_len ?
    JZ      YEMIT                   ; 2 yes, don't move char to dst
    MOV.B   Y,0(W)                  ; 3 move char to dst
    ADD     #1,W                    ; 1 increment dst addr
    ADD     #1,TOS                  ; 1 increment count of moved chars
    JMP     YEMIT                   ; 9/6~ send echo to terminal if ECHO, do nothing if NOECHO
; ----------------------------------; 29/26~ char loop, add 14~ for readsectorW ==> 43/40~ ==> 186/200 kbytes/s @ 8MHz
SDA_GetFileNextSector               ; CIB cnt --
; ----------------------------------;
    PUSHM   #2,W                    ; save dst_ptr, dst_len
    CALL    #Read_File              ; that resets BufferPtr
    POPM    #2,W                    ; restore dst_ptr, dst_len
    JMP     SDA_InitSrcAddr         ; loopback to end the line
; ----------------------------------;