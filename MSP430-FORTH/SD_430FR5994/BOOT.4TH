
; --------
; BOOT.4th for MSP_EXP430FR5994
; --------

; ------------------------------------------------------------------
; first we download the set of definitions we need (from CORE_ANS.4th for MSP_EXP430FR5994)
; ------------------------------------------------------------------

    [UNDEFINED] DUP [IF]
    CODE DUP
BW1 SUB #2,R15
    MOV R14,0(R15)
    MOV @R13+,R0
    ENDCODE

    CODE ?DUP
    CMP #0,R14
    0<> ?GOTO BW1
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] DROP [IF]
    CODE DROP
    MOV @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] = [IF]
    CODE =
    SUB @R15+,R14
    SUB #1,R14
    SUBC R14,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] + [IF]
    CODE +
    ADD @R15+,R14
    MOV @R13+,R0
    ENDCODE
    [THEN]

    [UNDEFINED] EXECUTE [IF]
    CODE EXECUTE
    PUSH R14
    MOV @R15+,R14
    MOV @R1+,R0
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

    DUP 6 =
    [IF]
        DROP
        RST_RET
        LOAD" SD_TEST.4TH"
    [ELSE]
        ' SYS $0E + EXECUTE
    [THEN]
