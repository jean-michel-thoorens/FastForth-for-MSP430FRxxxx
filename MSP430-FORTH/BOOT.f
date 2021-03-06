
; --------
; BOOT.f
; --------
\
\ to see kernel options, download FastForthSpecs.f
\ FastForth kernel options: MSP430ASSEMBLER, CONDCOMP, SD_CARD_LOADER, BOOTLOADER
\
\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
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
\ SYSRSTIV values added by FastForth 
\ ----------------------------------
\ -3 reset after FastForth "flashing".
\ -1 Deep Reset: restores FastForth as it was "flashed".   
\
\ note
\ --------------------------------------------------------------------------------
\ any reset event is kept in SYSRSTIV register. Their values are device specific.
\ WARM displays the content of SYSRSTIV register.
\ --------------------------------------------------------------------------------
\ When BOOT.4TH is called by the FastForth bootstrap, the SYSRSTIV value is on
\ the Top Of paramater Stack -TOS- ready to test.
\ --------------------------------------------------------------------------------
\ to enable bootstrap: ' BOOT IS WARM
\ to disable bootstrap: ' BOOT [PFA] IS WARM
\ --------------------------------------------------------------------------------
\
\ first, we test for downloading driver only if good FastForth version

CODE ABORT_BOOTSTRAP
SUB #2,PSP
MOV TOS,0(PSP)      \
MOV &VERSION,TOS    \ -- sys_event version
SUB #308,TOS        \                   FastForth V3.8
COLON
'CR' EMIT            \ return to column 1 without 'LF'
ABORT" FastForth V3.8 please!"
PWR_STATE           \ remove ABORT_BOOTSTRAP definition before resuming
;

ABORT_BOOTSTRAP

[UNDEFINED] = [IF]
\ https://forth-standard.org/standard/core/Equal
\ =      x1 x2 -- flag         test x1=x2
CODE =
SUB @PSP+,TOS   \ 2
0<> IF          \ 2
    AND #0,TOS  \ 1
    MOV @IP+,PC \ 4
THEN
XOR #-1,TOS     \ 1 flag Z = 1
MOV @IP+,PC     \ 4
ENDCODE
[THEN]

\ --------------------------------------------------------------------------------
\ WARNING !
\ --------------------------------------------------------------------------------
\ it is not recommended here to compile then execute a word 
\ because the risk of crushing thereafter. 
\ Interpreting mode as below is required: 
\ --------------------------------------------------------------------------------

\ it's an example:

$04 = [IF]              \ if PUC event is <reset>
    LOAD" SD_TEST.4TH"
[THEN]
