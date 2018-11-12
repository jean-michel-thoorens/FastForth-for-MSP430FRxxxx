; BOOT.4th

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433



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





\ SYSRSTIV values added by FAST FORTH 
\ -----------------------------------
\ 05 reset after compilation of FAST FORTH kernel
\ -1 hardware DEEP RESET: restores state of the lastest FastForth flashed   
             

\ note
\ Origin of reset is kept in SYSRSTIV register. Their values are device specific.
\ WARM displays the content of SYSRSTIV register.
\ When BOOT.4TH is called by the FastForth bootstrap, the SYSRSTIV value is on
\ the paramater stack, ready to test

\ --------------------------------------------------------------------------------
\ WARNING !
\ --------------------------------------------------------------------------------
\ it is not recommended to compile then execute a word to perform the bootstrap 
\ because the risk of crushing thereafter. Interpreting mode as below is required: 
\ --------------------------------------------------------------------------------


\ it's an example:

DUP $06 =
[IF]                \ origin of reset = COLD
    LOAD" SD_TEST.4TH"
[ELSE] DUP $02 = 
    [IF]            \ origin of reset = power ON
        LOAD" RTC.4TH"
    [THEN]
[THEN]
DROP
ECHO                \ don't forget!
