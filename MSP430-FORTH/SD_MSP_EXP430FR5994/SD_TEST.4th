 
LOAD" SD_TOOLS.4TH"
RST_HERE
NOECHO
: SD_TEST
    ECHO CR
    ."    1 Load ANS core tests" CR
    ."    2 Load, compile and run a 10k program "
            ." from its source file (quiet mode)" CR
    ."    3 Read only this source file (quiet mode)" CR
    ."    4 Write a dump of the FORTH kernel to yourfile.txt" CR
    ."    5 append a dump of the FORTH kernel to yourfile.txt" CR
    ."    6 Load truc (test error)" CR
    ."    your choice : "
    KEY
    48 - 
    DUP 1 = 
    IF  .
        LOAD" CORETSTH.4TH"
    ELSE DUP 2 =
        IF  .
            LOAD" Prog10k.4th"
        ELSE DUP 3 =
            IF  .
                READ" Prog10k.4th"
                BEGIN
                    READ
                UNTIL
            ELSE DUP 4 =
                IF  .
                    DEL" yourfile.txt"
                    WRITE" yourfile.txt"
                    ['] SD_EMIT IS EMIT
                    $4000 HERE OVER - DUMP
                    ['] (EMIT) IS EMIT
                    CLOSE
                ELSE DUP 5 =
                    IF  .
                        WRITE" yourfile.txt"
                        ['] SD_EMIT IS EMIT
                        $4000 HERE OVER - DUMP
                        ['] (EMIT) IS EMIT
                        CLOSE
                    ELSE DUP 6 =
                        IF  .
                            LOAD" truc"
                        ELSE 
                            DROP ." ?"
                            CR ."    loading TSTWORDS.4th..."
                            LOAD" TSTWORDS.4TH"
                        THEN
                    THEN
                THEN
            THEN
        THEN
    THEN
    CR ." It's done..."
;
PWR_HERE
SD_TEST
