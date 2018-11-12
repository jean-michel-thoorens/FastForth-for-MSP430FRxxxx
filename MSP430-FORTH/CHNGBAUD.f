; CHNGBAUD.f

\ TARGET SELECTION
\ MSP_EXP430FR5739  MSP_EXP430FR5969    MSP_EXP430FR5994    MSP_EXP430FR6989
\ MSP_EXP430FR4133  MSP_EXP430FR2433    MSP_EXP430FR2355    CHIPSTICK_FR2433
\
\
: BAD_MHz
    1 ABORT"  only for 4,8,16,24 MHz MCLK!"
;
: BAD_SPEED
FREQ_KHZ @ 0 1000 UM/MOD
SPACE 27 EMIT ." [7m"   \ set reverse video
." with MCLK = " .
1 ABORT" MHz? don't dream! "
;

: <> = 0= ;

: CHNGBAUD                  \ only for 8, 16, 24 MHz
PWR_STATE                   \ to remove this created word (garbage collector)
FREQ_KHZ @ >R               \ r-- target MCLCK frequency in MHz
ECHO CR
."    choose your baudrate:" CR
."    0 --> 6 MBds" CR
."    1 --> 5 MBds" CR
."    2 --> 4 MBds" CR      \ linux driver max speed
."    3 --> 2457600 Bds" CR
."    4 --> 921600 Bds" CR
."    5 --> 115200 Bds" CR
."    other --> abort" CR
."    your choice: "
KEY

48 - ?DUP 0=                \ select 5MBds ?
IF  ." 6 MBds"              \ add this to the current line
    R@ 4000 =               \ 4MHz ?
    IF  R@ BAD_SPEED        \ abort
    THEN
    R@ 8000 =               \ 8MHz ?
    IF  R@ BAD_SPEED        \ abort
    THEN
    R@ 16000 =              \ 16MHz ?
    IF  R@ BAD_SPEED
    THEN
    R@ 24000 <>             \ 24 MHz ?
    IF  BAD_MHz             \ no: --> abort
    THEN                
    $4                      \ TERM_BRW
    $0                      \ TERM_MCTLW
ELSE 1 - ?DUP 0=            \ select 5MBds ?
    IF  ." 5 MBds"
        R@ 4000 =           \ 4MHz ?
        IF  R@ BAD_SPEED    \ abort
        THEN
        R@ 8000 =           \ 8MHz ?
        IF  R@ BAD_SPEED    \ abort
        THEN
        R@ 16000 =
        IF  $3              \ TERM_BRW
            $2100           \ TERM_MCTLW
        ELSE R@ 24000 <>
            IF  BAD_MHz
            THEN
            $4              \ TERM_BRW
            $EE00           \ TERM_MCTLW
        THEN
    ELSE 1 - ?DUP 0=            \ select 4MBds ?
        IF  ." 4 MBds"
            R@ 4000 =           \ 4MHz ?
            IF  R@ BAD_SPEED    \ abort
            THEN
            R@ 8000 =
            IF  R@ BAD_SPEED    \ abort
            THEN
            R@ 16000 =
                IF  $4          \ TERM_BRW
                    $0          \ TERM_MCTLW
                ELSE R@ 24000 <>
                    IF  BAD_MHz
                    THEN
                    $6          \ TERM_BRW
                    $0          \ TERM_MCTLW
                THEN
        ELSE 1 - ?DUP 0=            \ select 2457600 ?
            IF  ." 2457600 Bds"
                R@ 4000 =           \ 4MHz ?
                IF  R@ BAD_SPEED    \ abort
                THEN
                R@ 8000 =
                IF  $3              \ TERM_BRW
                    $4400           \ TERM_MCTLW
                ELSE R@ 16000 =
                    IF  $6          \ TERM_BRW
                        $AA00       \ TERM_MCTLW
                    ELSE R@ 24000 <>
                        IF  BAD_MHz
                        THEN
                        $9          \ TERM_BRW
                        $DD00       \ TERM_MCTLW
                    THEN
                THEN
            ELSE 1 - ?DUP 0=                \ select 921600 ?
                IF  ." 921600 Bds"
                    R@ 4000 =               \ 4MHz ?
                    IF  4                   \ TERM_BRW
                        $4900               \ TERM_MCTLW
                    ELSE
                        R@ 8000 =
                        IF  8               \ TERM_BRW
                            $D600           \ TERM_MCTLW
                        ELSE R@ 16000 =
                            IF  $11         \ TERM_BRW
                                $4A00       \ TERM_MCTLW
                            ELSE R@ 24000 <>
                                IF  BAD_MHz
                                THEN
                                $1          \ TERM_BRW
                                $00A1       \ TERM_MCTLW
                            THEN
                        THEN
                    THEN
                ELSE 1 - ?DUP 0=                \ select 115200 ?
                    IF  ." 115200 Bds"
                        R@ 4000  =
                        IF  2                   \ TERM_BRW
                            $BB21               \ TERM_MCTLW
                        ELSE
                            R@ 8000  =
                            IF  4               \ TERM_BRW
                                $5551           \ TERM_MCTLW
                            ELSE R@ 16000 =
                                IF  8           \ TERM_BRW
                                    $F7A1       \ TERM_MCTLW
                                ELSE R@ 24000 <>
                                    IF  BAD_MHz
                                    THEN
                                    $0D         \ TERM_BRW
                                    $4901       \ TERM_MCTLW
                                THEN
                            THEN
                        THEN
                    ELSE                    \ other selected 
                        ." abort" CR ABORT
                    THEN
                THEN
            THEN
        THEN
    THEN
THEN
TERMMCTLW_RST !             \ set UCAxMCTLW value in FRAM
TERMBRW_RST !               \ set UCAxBRW value in FRAM
R> DROP                     \ clear stacks
CR ."    Change baudrate in Teraterm, save its setup then reboot."
;

CHNGBAUD
