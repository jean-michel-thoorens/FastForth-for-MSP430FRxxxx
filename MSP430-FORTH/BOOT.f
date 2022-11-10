
; --------
; BOOT.f
; --------
\
\ TARGET SELECTION ( = the name of \INC\target.pat file without the extension)
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433    MSP_EXP430FR2433    MSP_EXP430FR2355
\ LP_MSP430FR2476
\
\ from scite editor : copy your target selection in (shift+F8) parameter 1:
\
\ or, from windows explorer:
\ drag and drop this file onto SendSourceFileToTarget.bat
\ then select your TARGET when asked.
\
\ SYSRSTIV decimal/hex values for MSP430FR5994 (device specific)
\ ----------------------------------------------------------
\ #00 $00 No interrupt pending
\ #02 $02 Brownout (BOR)
\ #04 $04 RSTIFG RST/NMI (BOR)
\ #06 $06 PMMSWBOR software BOR (BOR)
\ #08 $08 LPMx.5 wake up (BOR)
\ #10 $0A violation memory protected areas (BOR)
\ #12 $0C Reserved
\ #14 $0E SVSHIFG SVSH event (BOR)
\ #16 $10 Reserved
\ #18 $12 Reserved
\ #20 $14 PMMSWPOR software POR (POR)
\ #22 $16 WDTIFG watchdog timeout (PUC)
\ #24 $18 WDTPW password violation (PUC)
\ #26 $1A FRCTLPW password violation (PUC)
\ #28 $1C Uncorrectable FRAM bit error detection (PUC)
\ #30 $1E Peripheral area fetch (PUC)
\ #32 $20 PMMPW PMM password violation (PUC)
\ #34 $22 MPUPW MPU password violation (PUC)
\ #36 $24 CSPW CS password violation (PUC)
\ #38 $26 MPUSEGIPIFG encapsulated IP memory segment violation (PUC)
\ #40 $28 MPUSEGIIFG information memory segment violation (PUC)
\ #42 $2A MPUSEG1IFG segment 1 memory violation (PUC)
\ #44 $2C MPUSEG2IFG segment 2 memory violation (PUC)
\ #46 $2E MPUSEG3IFG segment 3 memory violation (PUC)
\
\ emulated SYSRSTIV values added by FastForth
\ -------------------------------------------
\ -n SYS            : BOR + Deep Reset --> WARM display #-1  
\ <SW1+RESET>       : BOR + Deep Reset --> WARM display #-1
\ SYS               : NO PUC -->  -->  --> WARM display #0
\ n SYS  (n odd )   : NO PUC -->  -->  --> WARM display #n (odd)
\ n SYS  (n even )  : BOR    -->  -->  --> WARM display #n (even)
\ <RESET>           : BOR    -->  -->  --> WARM display #4
\
\ note
\ ------------------------------------------------------------------------------
\ When BOOT.4TH is called by the FastForth bootstrap, the SYSRSTIV (hardware or
\ emulated value) is on the Top Of paramater Stack -TOS- ready to test.
\ ------------------------------------------------------------------------------
\ to enable bootstrap: BOOT
\ to disable bootstrap: UNBOOT
\ ------------------------------------------------------------------------------
\
\ it's an example:

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.f)
; ------------------------------------------------------------------

    [UNDEFINED] DUP [IF]
\ https://forth-standard.org/standard/core/DUP
\ DUP      x -- x x      duplicate top of stack
    CODE DUP
BW1 SUB #2,PSP      \ 2  push old TOS..
    MOV TOS,0(PSP)  \ 3  ..onto stack
    MOV @IP+,PC     \ 4
    ENDCODE

\ https://forth-standard.org/standard/core/qDUP
\ ?DUP     x -- 0 | x x    DUP if nonzero
    CODE ?DUP
    CMP #0,TOS      \ 2  test for TOS nonzero
    0<> ?GOTO BW1    \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] DROP [IF]
\ https://forth-standard.org/standard/core/DROP
\ DROP     x --          drop top of stack
    CODE DROP
    MOV @PSP+,TOS   \ 2
    MOV @IP+,PC     \ 4
    ENDCODE
    [THEN]

    [UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
    CODE =
    SUB @PSP+,TOS   \ 2
    SUB #1,TOS      \ 1 borrow (clear cy) if TOS was 0
    SUBC TOS,TOS    \ 1 TOS=-1 if borrow was set
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] + [IF]
\ https://forth-standard.org/standard/core/Plus
\ +       n1/u1 n2/u2 -- n3/u3     add n1+n2
    CODE +
    ADD @PSP+,TOS
    MOV @IP+,PC
    ENDCODE
    [THEN]

    [UNDEFINED] EXECUTE [IF]
\ https://forth-standard.org/standard/core/EXECUTE
\ EXECUTE   i*x xt -- j*x   execute Forth word at 'xt'
    CODE EXECUTE
    MOV #EXECUTE,PC
    ENDCODE
    [THEN]

; --------------------------
; end of definitions we need
; --------------------------

; ------------------------------------------------------------------------------
; WARNING !
; ------------------------------------------------------------------------------
; it is not recommended here to compile then execute a definition
; because the risk of crushing thereafter.
; Interpreting mode as below is required:
; ------------------------------------------------------------------------------

    DUP 6 =                 \ TOS = SYS value
    [IF]                    \ if <RESET> | 6 SYS
        DROP                \
        RST_RET             \ remove definitions above
        LOAD" SD_TEST.4TH"  \ load a file to test the SD_Card driver
    [ELSE]                  \ else
        TOS2WARM EXECUTE    \ TOS2WARM address, does same as n SYS (n odd)
    [THEN]                  \ then
