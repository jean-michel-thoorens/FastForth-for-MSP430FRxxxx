
; --------
; BOOT.4th for MSP_EXP430FR5994
; --------

    [UNDEFINED] = 
    [IF]
    CODE =
    SUB @R15+,R14
    SUB #1,R14
    SUBC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] +
    [IF]
    CODE +
    ADD @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] EXECUTE
    [IF]
    CODE EXECUTE
    PUSH R14
    MOV @R15+,R14
    MOV @R1+,R0
    ENDCODE
    [THEN]

    $04 =
    [IF]
        RST_RET
        NOECHO LOAD" SD_TEST.4TH"
    [ELSE]
        ' SYS $0A + EXECUTE
    [THEN]
