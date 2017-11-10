\ BOOT.4th

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  CHIPSTICK_FR2433
\ MY_MSP430FR5948   MY_MSP430FR5948_1   



\ SYSRSTIV decimal values for MSP430FR5994 (device specific)
\ ----------------------------------------------------------
\ 00 No interrupt pending                                      
\ 02 Brownout (BOR)                                            
\ 04 RSTIFG RST/NMI (BOR)                                      
\ 06 PMMSWBOR software BOR (BOR)                               
\ 08 LPMx.5 wake up (BOR)                                      
\ 10 Security violation (BOR)                                  
\ 12 Reserved                                                  
\ 14 SVSHIFG SVSH event (BOR)                                  
\ 16 Reserved                                                  
\ 18 Reserved                                                  
\ 20 PMMSWPOR software POR (POR)                               
\ 22 WDTIFG watchdog timeout (PUC)                             
\ 24 WDTPW password violation (PUC)                            
\ 26 FRCTLPW password violation (PUC)                          
\ 28 Uncorrectable FRAM bit error detection (PUC)              
\ 30 Peripheral area fetch (PUC)                               
\ 32 PMMPW PMM password violation (PUC)                        
\ 34 MPUPW MPU password violation (PUC)                        
\ 36 CSPW CS password violation (PUC)                          
\ 38 MPUSEGIPIFG encapsulated IP memory segment violation (PUC)
\ 40 MPUSEGIIFG information memory segment violation (PUC)     
\ 42 MPUSEG1IFG segment 1 memory violation (PUC)               
\ 44 MPUSEG2IFG segment 2 memory violation (PUC)               
\ 46 MPUSEG3IFG segment 3 memory violation (PUC)   





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
