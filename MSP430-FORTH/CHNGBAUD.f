\ CHNGBAUD.f

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433


: BAD_MHz
    1 ABORT"  only for 8,16,24 MHz! "
;

: CHNGBAUD                  \ only for 8, 16, 24 MHz
    PWR_STATE               \ to skip created words (garbage collector)
    ECHO CR
    ."    choose your baudrate:" CR
    ."    0 --> 5 MBds" CR
    ."    1 --> 921600 Bds" CR
    ."    2 --> 115200 Bds" CR
    ."    other --> abort, your choice: "
    KEY

    FREQ_KHZ @  >R      \ target MCLCK frequency --> RSP 

    48 - ?DUP 0=                \ select 5MBds ?
    IF  ." 5 MBds"              \ add this to the current line
        R@ 8000 =               \ 8MHz ?
        IF 1 ABORT"  with MCLK=8MHz? don't dream! "
        THEN                    \ no return attempted...
        R@ 16000 =              \ 16MHz ?
        IF  3                   \ UCAxBRW value for TERMBRW_RST
            $2100               \ UCAxMCTLW value for TERMMCTLW_RST
        ELSE R@ 24000 =         \ 24 MHz ?
            IF  4
                $EE00
            ELSE BAD_MHz        \ add your MCLCK value here...
            THEN
        THEN
        
    ELSE 1 - ?DUP 0=            \ select 921600 ?
        IF  ." 921600 Bds"
            R@ 8000 =
            IF  8
                $D600
            ELSE R@ 16000 =
                IF  $11
                    $4A00
                ELSE R@ 24000 =
                    IF 
                        1
                        $00A1
                    ELSE BAD_MHz
                    THEN
                THEN
            THEN
        ELSE 1 - ?DUP 0=        \ select 115200 ?
            IF  ." 115200 Bds"
                R@ 8000  =
                IF  4
                    $5551 
                ELSE R@ 16000 =
                    IF  8
                        $F7A1
                    ELSE R@ 24000 =
                        IF  $0D
                            $4901 
                        ELSE BAD_MHz
                        THEN
                    THEN
                THEN
            ELSE                \ other selected 
                ." abort" CR ABORT
            THEN
        THEN
    THEN
    TERMMCTLW_RST !             \ set UCAxMCTLW value in FRAM
    TERMBRW_RST !               \ set UCAxBRW value in FRAM
    R> DROP                     \ reset RSP and PSP
    CR ."    Change baudrate in Teraterm, save its setup then reboot."
;
    \
CHNGBAUD
