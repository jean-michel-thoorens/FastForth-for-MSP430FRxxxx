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
; QYEMIT uses only IP and Y registers
; ==================================;
;    FORTHWORD "SD_ACCEPT"          ; SDIB_org SDIB_org SDIB_len -- SDIB_org len    IP = QUIT4
; ==================================;
SD_ACCEPT                           ; sequentially move from SD_BUF to SDIB a line of chars delimited by CRLF
        PUSH    IP                  ;                           R-- IP
        MOV     #SDA_YEMIT_RET,IP   ; set QYEMIT return
; ----------------------------------; up to CPL = 80 chars
        MOV &CurrentHdl,T           ; prepare a link for a next LOADed file, if any...
        MOV &BufferPtr,HDLW_BUFofst(T)  ; ...see usage : GetFreeHandle(CheckCaseOfLoadFileToken)
; ----------------------------------;
; SDA_InitDstAddr                   ;
; ----------------------------------;
        ADD     TOS,0(PSP)          ; -- SDIB_org SDIB_end SDIB_len
        MOV     2(PSP),TOS          ; -- SDIB_org SDIB_end SDIB_ptr
; ==================================;
SDA_InitSrcAddr                     ; -- SDIB_org SDIB_end SDIB_ptr     <== Read_File return
; ==================================;
        MOV     &BufferPtr,S        ;
        MOV     &BufferLen,T        ;
        MOV     @PSP,W              ; W = SDIB_end
        MOV.B   #32,X               ; X = BL
        JMP     SDA_ComputeCharLoop ;
; ----------------------------------;
SDA_YEMIT_RET                       ;
; ----------------------------------;
        mNEXTADR                    ;
        SUB     #2,IP               ; 1 restore YEMIT return
; ----------------------------------;
SDA_ComputeCharLoop                 ; -- SDIB_org SDIB_end SDIB_ptr
; ----------------------------------;
        CMP     T,S                 ; 1 SD_buf_ptr >= SD_buf_len ?
        JC      SDA_GetFileNextSect ; 2 if yes
        MOV.B   SD_BUF(S),Y         ; 3 Y = char
        ADD     #1,S                ; 1 increment SD_buf_ptr
        CMP.B   X,Y                 ; 1 ascii printable char ?
        JC      SDA_MoveChar        ; 2 yes
        CMP.B   #10,Y               ; 2 control char = 'LF' ?
        JNZ     SDA_ComputeCharLoop ; 2 no, loop back
; ----------------------------------;
;SDA_EndOfLine                      ;
; ----------------------------------;
        MOV S,&BufferPtr            ; save SD_buf_ptr for next line loop
; ==================================;
SDA_EndOfFile                       ; -- SDIB_org SDIB_end SDIB_ptr     <== CloseHandle return
; ==================================;
        MOV     @RSP+,IP            ;                           R--
        ADD     #2,PSP              ; -- SDIB_ORG SDIB_PTR
        SUB     @PSP,TOS            ; -- SDIB_ORG LEN
        MOV.B   X,Y                 ; Y = BL
        JMP     QYEMIT              ; -- org len                        ==> output of SD_ACCEPT ==> INTERPRET
; ----------------------------------;
SDA_MoveChar                        ; -- SDIB_ORG SDIB_END SDIB_PTR
; ----------------------------------;
        CMP     W,TOS               ; 1 SDIB_ptr = SDIB_end ?
        JZ      QYEMIT              ; 2 yes, don't move char to dst
        MOV.B   Y,0(TOS)            ; 3 move char to dst
        ADD     #1,TOS              ; 1 increment SDIB_ptr
        JMP     QYEMIT              ; 9/6~ send echo to terminal if ECHO, do nothing if NOECHO
; ----------------------------------; 27/24~ char loop, add 14~ for readsectorW one char ==> 41/38~ ==> 195/210 kbytes/s @ 8MHz
SDA_GetFileNextSect                 ; -- SDIB_org SDIB_end SDIB_ptr
; ----------------------------------;
        PUSH    #SDA_InitSrcAddr    ; set the default return of Read_File, modified by CloseHandle when the end of file is reached 
        MOV     #Read_File,PC       ;
; ----------------------------------;