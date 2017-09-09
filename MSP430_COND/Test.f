\ ------------------
\ BOOT.f
\ ------------------

\ must be preprocessed with yourtarget.pat file

\ REGISTERS USAGE
\ R4 to R7 must be saved before use and restored after
\ scratch registers Y to S are free for use
\ under interrupt, IP is free for use

\ PUSHM order : PSP,TOS, IP,  S,  T,  W,  X,  Y, R7, R6, R5, R4
\ example : PUSHM IP,Y
\
\ POPM  order :  R4, R5, R6, R7,  Y,  X,  W,  T,  S, IP,TOS,PSP
\ example : POPM Y,IP

\ ASSEMBLER conditionnal usage after IF UNTIL WHILE : S< S>= U< U>= 0= 0<> 0>=
\ ASSEMBLER conditionnal usage before GOTO ?GOTO     : S< S>= U< U>= 0= 0<> <0 

\ FORTH conditionnal usage before IF UNTIL WHILE : 0= 0< = < > U<

\ NOECHO      ; if an error occurs, comment this line before new download to find it.


\ This source is loaded when FastForth detects a SD_Card memory

\ =======================================================
\ then, start what you want FastForth to do
\ =======================================================

\ ECHO      ; if an error occurs during download, uncomment this line then download again

\ PWR_HERE  ; uncomment if you really want to preserve all previous and volatile applications



: BOOT
        ECHO CR
        ."    1 set RTC" CR
        ."    2 add SD_TOOLS" CR
        ."    3 Test ANS94" CR
        ."    your choice : "
    
        KEY
        $30 - 
        DUP 1 = 
        IF .
            LOAD" RTC.4TH"  \ perform (reset to) PWR_STATE ==> remove BOOT 
        ELSE DUP 2 =
            IF .
                LOAD" SD_TOOLS.4th" \ performs PWR_HERE
            ELSE DUP 3 =
                IF .
                    LOAD" CORETEST.4TH"
                ELSE
                    DROP 0 .
                THEN
            THEN
    THEN
    CR
;

BOOT
