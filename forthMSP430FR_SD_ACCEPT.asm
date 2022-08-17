; -*- coding: utf-8 -*-
;
;Z SD_ACCEPT  addr addr len -- addr' len'  get line to interpret from a SD Card file
; no interrupt allowed
; defered word ACCEPT is redirected here by the word LOAD"
; "defered" word CIB is redirected to SDIB (PAD if RAM<2k) by the word LOAD"
; sequentially move an input line ended by CRLF from SD_BUF to PAD
;   if end of SD_BUF is reached before CRLF, asks Read_File to refill buffer with next sector
;   then load the end of the line to SDIB_ptr.
; when the last buffer is loaded, the handle is automaticaly closed
; when all LOAD"ed files are read, redirects defered word ACCEPT to default ACCEPT and restore interpret pointers.
; see CloseHandle.

; used variables : BufferPtr, BufferLen
; EMIT uses only IP TOS and Y registers
; ==================================;
;    FORTHWORD "SD_ACCEPT"          ; SDIB_org SDIB_org SDIB_len -- SDIB len        94 bytes
; ==================================;
SD_ACCEPT                           ; sequentially move from SD_BUF to SDIB (PAD if RAM=1k) a line of chars delimited by CRLF
; ----------------------------------; up to CPL = 80 chars
        PUSH    IP                  ;
        MOV     #SDA_YEMIT_RET,IP   ; set YEMIT return
; ----------------------------------;
        MOV &CurrentHdl,T           ; prepare a link for a next LOADed file, if any...
        MOV &BufferPtr,HDLW_BUFofst(T)  ; ...see usage : GetFreeHandle(CheckCaseOfLoadFileToken)
; ----------------------------------;
; SDA_InitDstAddr                   ;
; ----------------------------------;
        MOV     @PSP+,W             ; -- SDIB_org SDIB_len  W=SDIB_ptr
        MOV     TOS,X               ;                       X=SDIB_len
        MOV     #0,TOS              ; -- SDIB_org len   of moved bytes from SD_buf to SDIB
; ----------------------------------;
SDA_InitSrcAddr                     ; <== SDA_GetFileNextSect
; ----------------------------------;
        MOV     &BufferPtr,S        ;                   S=SD_buf_ptr
        MOV     &BufferLen,T        ;                   T=SD_buf_len
        JMP     SDA_ComputeChar     ;
; ----------------------------------;
SDA_YEMIT_RET                       ;
; ----------------------------------;
        mNEXTADR                    ;
        SUB     #2,IP               ; 1                 restore YEMIT return
; ----------------------------------;
SDA_ComputeChar                     ; -- SDIB_org len
; ----------------------------------;
        CMP     T,S                 ; 1 SD_buf_ptr >= SD_buf_len ?
        JC      SDA_GetFileNextSect ; 2 if yes
        MOV.B   SD_BUF(S),Y         ; 3 Y = char
        ADD     #1,S                ; 1 increment SD_buf_ptr
        CMP.B   #32,Y               ; 2 ascii printable char ?
        JC      SDA_MoveChar        ; 2 yes
        CMP.B   #10,Y               ; 2 control char = 'LF' ?
        JNZ     SDA_ComputeChar     ; 2 no, loop back
; ----------------------------------;
SDA_EndOfLine                       ; -- SDIB_org len
; ----------------------------------;
        MOV S,&BufferPtr            ; yes  save SD_buf_ptr for next line
        MOV @RSP+,IP                ;
        MOV #32,S                   ; S = BL
        JMP ACCEPT_EOL              ; -- SDIB_org len       ==> output
; ----------------------------------;
SDA_MoveChar                        ;
; ----------------------------------;
        CMP     TOS,X               ; 1 len = SDIB_len ?
        JZ      QYEMIT              ; 2 yes, don't move char to dst
        MOV.B   Y,0(W)              ; 3 move char to dst
        ADD     #1,W                ; 1 increment SDIB_ptr
        ADD     #1,TOS              ; 1 increment len of moved chars
        JMP     QYEMIT              ; 9/6~ send echo to terminal if ECHO, do nothing if NOECHO
; ----------------------------------; 29/26~ char loop, add 14~ for readsectorW one char ==> 43/40~ ==> 186/200 kbytes/s @ 8MHz
SDA_GetFileNextSect                 ; -- SDIB_org len
; ----------------------------------;
        PUSHM   #2,W                ; save SDIB_ptr, SDIB_len
        CALL    #Read_File          ; which clears SD_buf_ptr and set SD_buf_len
        POPM    #2,W                ; restore SDIB_ptr, SDIB_len
        JMP     SDA_InitSrcAddr     ; loopback to end the line
; ----------------------------------;