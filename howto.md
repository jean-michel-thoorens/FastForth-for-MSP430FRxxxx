

    WHAT IS FAST FORTH FOR MSP430FR ?
    HARDWARE TO START
    FAST FORTH IS IT AN IDE ?
    HOW TO MIX ASSEMBLY and FORTH ?
    WRITING RULES
    ASSEMBLY WITHOUT LABEL ?
    SYMBOLIC ASSEMBLER ? YES !
    COMPILE FAST FORTH FOR YOUR MODULE
    START YOUR PROJECT
    Case of MSP430FR2xxx family (with FLL)
    ANNEXE
    
WHAT IS FAST FORTH FOR MSP430FRxxxx ?
--

FAST FORTH is a FORTH program written in MSP430 assembly and it runs on TI's LAUNCHPAD : 
MSP-EXP430FR5739, MSP-EXP430FR5969, MSP-EXP430FR6989... or any MSP430 FRAM device.
Its core is ANS FORTH standard compliant.

Built-in assembler allows you to program an application using interruptions and LPMX modes.

If you are beginner in FORTH, a vastefull literature is available on the web, try: http://www.forth.org/tutorials.html.
Select "starting Forth" of Leo Brodie, that is sufficient for our purpose.
In addition, as you can see in forthMSP430FR.asm, each FORTH word definition includes a reference to the ANS standard.



HARDWARE TO START
--

    a TI launchpad, the basic MSP-EXP430FR5969 or the MSP_EXP4305994 with SD card slot.

    an UARTtoUSB cable with a PL2303TA (best choice) :
        Search :"PL2303TA"
        RX and TX wires are 3.3V level.

        BE CAREFULL ! if you plan to supply your MSP430FRxxxx device with the PL2303TA cable,
        you MUST open it to weld the red wire (+) onto the 3.3V pad !!!
        otherwise, cut it...


    or UARTtoUSB bridge with CP2102 device :
        search on ebay :"UART to USB CP2102"
        Check for a 3.3V pin before paying !

    
If you want to test RC5toLCD.f :
    
    a standard LCD DISPLAY 2x16 or 2x20 chars,
    a VISHAY IR receiver TSOP32236 or equivalent plus an IR remote with RC5/RC6 Philips protocol,
    a piece of PCB to wire the diode, resistor and two capacitors of the LCD_Vo booster. See RC5toLCD.f

And to use the SD_Card extension : 

    http://www.ebay.com/itm/2-PCS-SD-Card-Module-Slot-Socket-Reader-For-Arduino-MCU-/181211954262?pt=LH_DefaultDomain_0&hash=item2a3112fc56
    http://fr.aliexpress.com/item/5V-3-3V-Compatible-Perfect-SD-Card-Module-Slot-Socket-Reader-For-ARM-MCU-Read/32223868267.html?isOrigTitle=true

It is not wasteful.


I suggest you to wire constantly the RX0 TX0 pins of your LAUNCHPAD (RX1 TX1 pins for MSP-EXP430FR6989 launchpad) to a free USB socket on your PC via the cable UARTtoUSB PL2303TA.
So you can drag and drop HEX file on MSP-EXP430FRxxxxprog.bat to regenerate FORTH kernel or download RC5toLCD.f without doing anything else...


FAST FORTH IS IT AN IDE ?
--

YES, if you admit that you can program in FORTH / in assembler, not C... Look at "RC5toLCD.f".

In fact, you have an IDE with two languages, one low level other high level, and it's easy to mix them. 


HOW TO MIX assembly and FORTH ?
---

FAST FORTH knows two kinds of words :

    low level assembly words start with CODE <name> and end with ENDCODE.

    high level FORTH words begin with : <name> and end with ;


Examples

    CODE ADD    \ Assembly word, alias of word +
        ADD @PSP+,TOS
        MOV @IP+,PC
    ENDCODE


    : NOOP      \ FORTH word, do nothing
        DUP
        DROP
    ;



To end a low level assembly word, the instruction MOV @IP+,PC jumps to the next FORTH word. This faster (4 cycles) and shorter (one word) instruction replaces the famous pair of assembly instructions : CALL #LABEL ... RET (4+4 cycles, 2+1 words). The register IP is the Interpretative Pointer. 

High level FORTH word starts with a boot code DOCOL that save the IP pointer, load it with the first address of a list of execution addresses, then perform a postincrement branch to this first address. The list ends with the address of another piece of code EXIT (6 cycles) that restores IP before the instruction MOV @IP+,PC.


here, the compilation of low level word ADD :

                    preamble        \ compiled by the word CODE
    execution addr  ADD @PSP+,TOS
                    MOV @IP+,PC     \ instruction called NEXT

and the one of the high level word NOOP :

                    preamble        \ compiled by the word :
    execution addr  PUSH IP         \ boot code compiled by the word :
                    CALL rEXIT      \ boot code compiled by the word :
                    addr of DUP     \ execution addr of DUP
                    addr of DROP    \ execution addr of DROP
                    addr of EXIT    \ execution addr of EXIT compiled by the word ;


_A high level FORTH word is a list of execution addresses preceded by a boot code and ending with EXIT address._


WRITING RULES
--

any low level FORTH words must be ended with the instruction MOV @IP+,PC (NEXT).

        CODE TEST               \ CODE starts a low level word
            asm1                \ assembly instruction 1
            asm2                \ assembly instruction 2
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word


If you want to use the IP register, save it before and restore it before NEXT

        CODE TEST1              \ CODE starts a low level word
            asm1                \ assembly instructions
            ...
            PUSH IP             \ save IP before use
            MOV #1,IP           \ assembly instruction that uses IP
            ...                 \ assembly instructions
            MOV @RSP+,IP        \ restore IP
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word


A little more complex, the case of mixing FORTH and assembly that is enabled by the words HI2LO, LO2HI and COLON

        : MIX_FORTH_ASM         \ definition of a FORTH word starts with :
            SWAP
            DUP
        HI2LO                   \ FORTH to assembler switch
            asm1                \ assembly instruction
            asm2                \ assembly instruction
            ...                 \ you can freely use IP !
            ...                 \ assembly instructions
            MOV @RSP+,IP        \ restore IP
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word
    
If we see the code "MIX\_FORTH\_ASM" after compilation :

            preamble            \ compiled by :
    exec@   PUSH IP             \ save IP compiled by :
            CALL rEXIT          \ execute EXIT compiled by :
            addr                \ execution addr of SWAP
            addr                \ execution addr of DUP
            next addr           \ addr of asm1, compiled by HI2LO
            asm1                \ assembly instruction
            asm2                \ assembly instruction
            ...                 \ you can freely use IP !
            ...                 \ assembly instructions
            MOV @RSP+,IP        \ restore IP saved by :
            MOV @IP+,PC         \ NEXT

the instruction "CALL rEXIT" (CALL R7), have EXIT address as rEXIT content.


going a step further :

        CODE MIX_ASM_FORTH      \ CODE starts a low level word
            asm1                \ assembly instruction 1
            asm2                \ assembly instruction 2
        COLON                   \ starts high level
            word1
            word2
        ;                       \ end of high level word


If we see this code "MIX\_ASM\_FORTH" after compilation :

            preamble            \ compiled by CODE
    exec@   asm1                \ assembly instruction 1
            asm2                \ assembly instruction 2
            PUSH IP             \ save IP compiled by COLON
            CALL rEXIT          \ execute EXIT compiled by COLON
            addr1               \ of word1
            addr2               \ of word2
            addr of EXIT        \ the word ; compiles EXIT that restores IP then executes MOV @IP+,PC


EXIT is used twice !

the first time, at the start of FORTH word, after save IP:

    EXIT    MOV @RSP+,IP    \ 2 pop into IP next PC pushed on return stack by CALL rEXIT
            MOV @IP+,PC     \ 4 execute the routine pointed by the the address next "CALL rEXIT" 

then at the end of FORTH word :

    EXIT    MOV @RSP+,IP    \ 2 pop old IP from return stack
            MOV @IP+,PC     \ 4 execute the routine pointed by the old IP


A new step

        : MIX_FORTH_ASM_FORTH   \ definition of a FORTH word starts with :
            word1
            word2
            ...
        HI2LO                   \ FORTH to assembler switch
            MOV #0,IP           \ IP is free for use
            asm1
            ...
        LO2HI                   \ assembler to FORTH switch
            word3
            word4
        ;                       \ end of high level word

the compiled result    

            preamble            \ compiled by :
    exec@   PUSH IP             \ save IP compiled by :
            CALL rEXIT          \ move next PC from return stack into IP, compiled by :
            addr1               \ of word1
            addr2               \ of word2
            ...
            next addr           \ compiled by HI2LO
            MOV #0,IP           \ IP is free for use
            asm1                \ assembly instruction
            ...
            CALL rEXIT          \ compiled by LO2HI (10 cycles switch)
            addr3               \ of word3
            addr4               \ of word4
            addr5               \ of EXIT

Still another step : 

        CODE MIX_ASM_FORTH_ASM  \ CODE starts a low level word
            asm1                \ assembly instruction
            asm2                \ assembly instruction
        COLON                   \ starts high level
            word
            ... 
        HI2LO                   \ FORTH to assembler switch
            asm3                \ assembly instruction
            asm4                \ assembly instruction
            MOV @RSP+,IP        \ restore IP
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word

In fact, an exclusive of FAST FORTH, the start of a word FORTH can be placed anywhere :

        CODE MIX_ASM_FORTH_ASM_FORTH
            asm
            asm
            ...
        COLON                   \ starts high level
            word
            word
            ...
        HI2LO                   \ FORTH to assembler switch
            asm
            asm
           ...
        LO2HI                   \ assembler to FORTH switch
            word
            word
            ...
        ;                       \ end of high level word

with the compiled result :

            preamble            \ compiled by CODE
    exec@   asm
            asm
            PUSH IP             \ compiled by COLON
            CALL rEXIT          \ compiled by COLON
            addr
            addr
            next address        \ compiled by HI2LO
            asm
            asm
            CALL rEXIT          \ compiled by LO2HI
            addr
            addr
            EXIT addr           \ that restores IP from return stack and then executes MOV @IP+,PC

As we see, IP is saved only once, it's logical.                      


ASSEMBLY WITHOUT LABEL ?
---

Yes ! the assembly syntax borrows FORTH's one for jumps :

    CODE TEST_IF_THEN
        CMP #1,R8           \ set Z,N,V, flags
        0= IF               \ irritating, the "IF =" upside down, isn't it?
            ADD R8,R9       \ true part of comparaison
        THEN                    
        ...                 \ the next
        MOV @IP+,PC         \ don't forget...
    ENDCODE                 \ don't forget...

and the complete version :

    CODE TEST_IF_ELSE_THEN
        CMP #1,R8           \ set Z,N,V, flags
        0= IF               \
            ADD R8,R9       \ true part of comparaison
        ELSE
            SUB R8,R9       \ false part of comparaison
        THEN                    
        ...                 \ following for the two branches
        MOV @IP+,PC         \ don't forget...
    ENDCODE                 \ don't forget...

test for loop back version BEGIN ... UNTIL
                            
    CODE TEST_BEGIN_UNTIL
        MOV #8,R10
        BEGIN           
            SUB #1,R10      \ set Z,N,V flags
        0= UNTIL            \ loop back to BEGIN if flag Z is set
        ... 
        MOV @IP+,PC
    ENDCODE

test for out of loop version BEGIN ... WHILE ... REPEAT

    CODE TEST_BEGIN_WHILE_REPEAT
        MOV #8,R10
        BEGIN
            SUB #1,R10      \ set Z,N,V flags
        0<> WHILE           \ go to out of loop if X=0 (Z flag =1)
            XOR #1,R9   
        REPEAT              \ unconditionnal loop back to BEGIN 
        ...                 \ out of loop here
        MOV @IP+,PC
    ENDCODE

infinite loop :

    CODE TEST_BEGIN_AGAIN
        BEGIN
            ADD #1,R9
        AGAIN               \ unconditionnal loop back to BEGIN 
    ENDCODE

to quit this infinite loop, press <reset> 


We can nest several conditional branches :

    CODE TEST_NESTED_IF_ELSE
        CMP #0,R10
        0= IF
            CMP #0,R10
            0= IF
                MOV #0,R11
            ELSE
                SUB #1,R11
            THEN
        ELSE
            MOV #1,R11
        THEN
        MOV @IP+,PC
    ENDCODE
    
another nest :

    CODE TEST_NESTED_BEGIN_AGAIN_IF
        MOV #8,R9
        BEGIN
            CMP #-1,R9
            0= IF   
                MOV @IP+,PC \ out of test_NESTED_BEGIN_AGAIN_IF
            THEN
            SUB #1,R9
        AGAIN
    ENDCODE


you can also MIX conditional branches with a mix of FORTH/assembly :

    see TEST5 in the demo file \MSP430-FORTH\TESTASM.4TH


...but not quite !
---

unconditionnal backward jump :

        CODE UNCOND_BACKWARD
            asm
            asm
            JMP TEST        \ jump backward to the word TEST
        ENDCODE

conditionnal backward jump :

        CODE COND_BACKWARD
            asm
            CMP #0,R8
            S< ?JMP TEST    \ jump backward to TEST if negative
            asm
            MOV @IP+,PC
        ENDCODE

FAST FORTH have one pass assembler, not able to make forward jump.

I have added possibility of several "non canonical" jumps, up to 3 backward and up to 3 forward imbricated jumps to label :

    \ C UM/MOD   udlo|udhi u1 -- ur uq
    CODE UM/MOD
        MOV @PSP+,W     \ 2 W = DIVIDENDhi
        MOV @PSP,S      \ 2 S = DIVIDENDlo
    \ T.I. ROUTINE  Section 5.1.5 of MSP430 Family Application Reports
        MOV #0,Y        \ 1 CLEAR RESULT
        MOV #16,X       \ 2 INITIALIZE LOOP COUNTER
    BW1 CMP TOS,W       \ 1
        U< ?GOTO FW1    \ 2 if not carry
        SUB TOS,W       \ 1 if carry DIVIDENDhi-divisor
    FW1                 \   FW1 label is resolved therefore reusable
    BW2 ADDC Y,Y        \ 1 RLC quotient
        U>= ?GOTO FW1   \ 2 if carry Error: result > 16 bits
        SUB #1,X        \ 1 Decrement loop counter
        <0 ?GOTO FW2    \ 2 if 0< terminate w/o error
        ADD S,S         \ 1 RLA DIVIDENDlo
        ADDC W,W        \ 1 RLC DIVIDENDhi
        U< ?GOTO BW1    \ 2 if not carry    14~ loop
        SUB TOS,W       \ 1 if carry DIVIDENDhi-divisor
        BIS #1,SR       \ 1 SETC
        GOTO BW2        \ 2                 14~ loop
    FW2 BIC #1,SR       \ 1 CLRC  No error, C = 0
    FW1                 \  Error indication in C
    \ END T.I. ROUTINE  Section 5.1.5 of MSP430 Family Application Reports
        MOV W,0(PSP)    \ 3 remainder on stack
        MOV Y,TOS       \ 1 quotient in TOS
        MOV @IP+,PC     \ 4
    ENDCODE


SYMBOLIC ASSEMBLER ? YES !
--

I have discovered a little semantic preprocessor "GEMA", just like that FAST FORTH have its symbolic assembler !

    \config\gema\MSP430FR_FastForth.pat contains variables FORTH for all devices
    \config\gema\MSP430FR57xx.pat contains declarations for FR57 family
    \config\gema\MSP430FR5x6x.pat ... for FR59/FR69 families
    \config\gema\MSP430FR2x4x.pat ... for FR2/FR4 families.
    \config\gema\DEVICE.pat contains memory map and vectors for a specified DEVICE
    \MSP430-FORTH\LAUNCHPAD.pat is the I/O config file for specific LAUNCHPAD or application

gema translates also FORTH registers in ASM registers (R0 to R15)

If you have created a network drive from your local gitlab directory, it's easy :
with scite editor open a file.f, then select in the menu "tools" the items "preprocess..." 

furnished examples : see \MSP430-FORTH\
Enjoy !

Try SD\_TEST.f to build a SD\_Card test.


COMPILE FAST FORTH FOR YOUR MODULE
--

The principle is to create (or modify) first existing configuration files only to compile FAST FORTH.

1- in forthMSP430FR.asm "TARGET configuration SWITCHES"  create a line for your target, example:

    ;MY_MSP430FR5738_1 ; compile for my own MSP430FR5738 miniboard

2- in Target.inc add one item:

        .IFDEF MY_MSP430FR5738_1
        .warning "Code for MY_MSP430FR5738_1"
    DEVICE = "MSP430FR5738" ; for family.inc file below, defines your device
    ;CHIP  .equ 5738 ; not used
    UCA0_UART   ; for family.inc file below, defines uart used by FORTH input terminal 
    LF_XTAL     ; for family.inc file below, defines if your module have a 32768 Hz xtal, to enable it.
    UCB0_SD     ; for family.inc file below, defines UC used for SD Card driver if used
        .include "MSP430FR57xx.inc"  ; include family declarations file: MSP430FR2x4x.inc, MSP430FR57xx.inc or MSP430FR5x6x.inc
        .ENDIF  ; MY_MSP430FR5738_1

3- complete family.inc file with declarations for your device if not exists. 
   take care to verify they not already exist in common part at the end of the file.

4- include an item in TargetInit.asm:
    .IFDEF MY_MSP430FR5738_1
    .include "MSP430FR5738_1.asm"
    .ENDIF

5- create your target MSP430FR5738_1.asm from another target.asm as model, then customize declarations.


6- if you use SD Card you must add an item in the forthMSP430FR_SD_INIT.asm file. Proceed as target.asm:

        .IFDEF MY_MSP430FR5738_1
    
    ; COLD default state : Px{DIR,SEL0,SEL1,SELC,IE,IFG,IV} = 0 ; PX{OUT,REN} = 1 ; Px{IN,IES} = ?
    
    ; P2.3 as SD_CD
    SD_CD           .equ  08h
    SD_CDIN         .equ  P2IN
    ; P2.4 as SD_CS
    SD_CS           .equ  10h
    SD_CSOUT        .equ  P2OUT
    
        BIS.B #SD_CS,&P2DIR ; SD_CS output high
    
    ; P2.2/UCB0CLK                ---> SD_CardAdapter CLK (SCK)   default value
    ; P1.6/UCB0SIMO/UCB0SDA/TA0.0 ---> SD_CardAdapter SDI (MOSI)  default value
    ; P1.7/UCB0SOMI/UCB0SCL/TA1.0 <--- SD_CardAdapter SDO (MISO)  default value
        BIS #04C0h,&PASEL1  ; Configure UCB0 pins: P2.2 as UCB0CLK, P1.6 as UCB0SIMO & P1.7 as UCB0SOMI
                            ; P2DIR.x is controlled by eUSCI_B0 module
        BIC #04C0h,&PAREN   ; disable pullup resistors for SIMO/SOMI/CLK pins
    
        .ENDIF

Then, for the needs of syntactic preprocessor:

1- create a \config\gema\device.pat file if not exist, from analog device.pat file

2- create your MSP430-FORTH\target.pat file from analog target.pat file, include same forth declarations as target.asm and complete it for your application

Best practice, I suggest you that all digital pins you define (input or output) in your projects have their idle state high, with external pull up resistor


START YOUR PROJECT
--

How to start your project ?

I show you, assuming you are working from the scite editor with its enhanced tools menu.

First you create two files : project.f and test.f

PROJECT.f :

    ; ----------------------------------------------------
    ; MSP430FR5969 MSP_EXP430FR5969 8MHZ 921600bds PROJECT
    ; ----------------------------------------------------
    WIPE        ; restore the content of your target.txt HEX file

here you append your already tested routines :

    CODE FIRST  \ assembler CODE words are FORTH executable
        ...
    MOV @IP+,PC \ NEXT
    ENCODE

    ASM TWO     \ assembler ASM words are not FORTH executable and can only be used in assembler mode
        ...     \ used to define interrupt routines, or subroutines as here.
    RET
    ENDASM

    CODE THREE
        ...
    CALL #TWO   \ CALL only ASM words (finishing with RET(I))...
        ...
    MOV @IP+,PC \ NEXT
    ENCODE

    ASM WDT_INT             \ interrupt routine
        ...
        ...
    BIC #WDTIFG,&SFRIFG1    \ reset WDT_INT flag
    BIC #$F8,0(RSP)         \ set CPU ON and GIE OFF in retiSR
    RETI                    \   
    ENDASM

    ;

then finish with this 2 "magic" words plus one optional : START, STOP and optional BACKGROUND

    ASM BACKGROUND          \ (optional)
        ...                 \ insert here your background task
        ...
        ...
    MOV #(SLEEP),PC         \ Must be the last statement of BACKGROUND
    ENDASM                  \

    CODE START              \ to init your app
        ...                 \ init assembly part
    

    MOV #SLEEP,X            \ redirect default background task to yours (optional)
    MOV #BACKGROUND,2(X)    \

    COLON
        ...                 \ init FORTH part
    
    \   NOECHO              \ uncomment if your app runs without terminal
        LIT RECURSE IS WARM \ insert START (so your init app) in the FORTH init process
        (WARM)              \ then continue the FORTH init process
    ;


    CODE STOP               \ to properly stop your app
        MOV #SLEEP,X        \ restore the default background (optional)
        MOV #(SLEEP),2(X)   \ (words SLEEP and (SLEEP) can only be used in assembler mode)
                            \ (thus "['] (SLEEP) IS SLEEP" don't works.)
    COLON
        ['] (WARM) IS WARM  \ remove START from FORTH init process 
        ECHO                \ to retrieve FORTH input terminal
        COLD                \ reset CPU, interrupt vectors and restart FORTH.
    ;


                ; compiling is done
    RST_HERE    ; thus allowing to restart your app with <reset> or COLD
    START       ; let's go!

end of file


Each time you download this project file in LAUNCHPAD, the word WIPE returns the dictionary set as it was in TXT file. 
And the word RST_HERE protects the PROJECT against <RESET\>. 

The word START allows to include your app init into FORTH's one.
The word STOP unlink your app.

Look at the file RC5toLCD.f to retrieve this structure.



TEST.f :

    \ ----------------------------------
    \ MSP-EXP430FR5969_8MHZ_TEST.f
    \ ----------------------------------
    RST_STATE   \ restore the state defined by PROJECT.f

    here you write your routine to test
    
    CODE TEST
    ...
    ...
    MOV @IP+,PC
    ENDCODE


    PWR_HERE    \ test.f content is protected against POWER OFF, but volatile with <reset>



Each time you download this test file, the word RST\_STATE returns the <RESET\> dictionary set (i.e. PROJECT). The word PWR\_HERE protects the test against POWER OFF. without the word PWR\_HERE, the test is lost when power down.

let's go
--

With the SCITE menu tools : send a file.f, you download first your project.f file, then your test.f file that include the routine to test.

If the test don't work, modify it in the test.f file, then reload it.

When the routine "test" works as you want, you cut it in test.f file and copy it in project.f, then when you reload it, test is done !

Good luck !



Case of MSP430FR2xxx family (with FLL)
---


Difficult to download CORETEST.4th on CHIPSTICK @ 8MHz without error (tested with USBtoUART device = CP2102).

To resolve, I was forced to speed the clock up to 8.29 MHz ! (see ChipStick_fr2433.inc) 

And there is no this problem @ 16MHz !

Is a problem that affects this device only, or corrupt TLV area during welding?

If you ever encounter the same difficulty, recompile + download CORETEST.4th several times by increasing each time by 2 the FLLN value until you reach the good compromising...


ANNEXE
--

The embedded assembler don't recognize the (useless) TI's symbolic addressing mode: ADD.B EDE,TONI.

REGISTERS correspondence

    ASM     TI      FASTFORTH   comment 
                             
    R0      PC      PC          Program Counter
    R1      SP      RSP         Return Stack Pointer
    R2      SR/CG1  SR          Status Register/Constant Generator 1
    R3      CG2                 Constant Generator 2
    R4      R4      rDODOES     contents address of xdodoes
    R5      R5      rDOCON      contents address of xdocon
    R6      R6      rDOVAR      contents address of RFROM
    R7      R7      rEXIT       contents address of EXIT
    R8      R8      Y           scratch register
    R9      R9      X           scratch register
    R10     R10     W           scratch register
    R11     R11     T           scratch register
    R12     R12     S           scratch register
    R13     R13     IP          Interpretation Pointer
    R14     R14     TOS         Top Of parameters Stack
    R15     R15     PSP         Parameters Stack Pointer

    FASTFORTH registers must be preprocessed by gema.exe before sending to the embedded assembler.
    (don't use R3 and use R2 only with register addressing mode).

REGISTERS use

    The FASTFORTH registers rDOCOL, rDOVAR, rDOCON and rDODOES must be preserved. 
    PUSHM R7,R4 before use and POPM R4,R7 after.

    Under interrupt, the use of scratch registers and IP is free.
    Else, only scratch registers.


PARAMETERS STACK use

    The register TOS (Top Of Stack) is the first cell of the Parameters stack. 
    The register PSP (Parameters Stack Pointer) points the second cell.

    to push one cell on the PSP stack :

        SUB #2,PSP                  \ insert a empty 2th cell
        MOV TOS,0(PSP)              \ mov first cell in this empty 2th cell
        MOV <what you want>,TOS     \ or MOV.B <what you want>,TOS ; i.e. in first cell
        ...

    to pop one cell from the PSP stack :

        MOV @PSP+,TOS               \ first cell is lost
        ...


RETURN STACK use

    register RSP is the Return Stack Pointer (SP).

    to push one cell on the RSP stack :

        PUSH <what you want>        \
        ...

    to pop one cell from the RSP stack :

        MOV @RSP+,<where you want>   \
        ...

    to push multiple registers on the RSP stack :

        PUSHM Rx,Ry                 \ x > y 
        ...

    to pop multiple registers from the RSP stack :

        POPM Ry,Rx                  \ y < x
        ...

CPUx instructions PUSHM / POPM (my own syntax, not the TI's one, too bad :-)

    PUSHM order : PSP,TOS, IP, S, T, W, X, Y, R7, R6, R5, R4

    example : PUSHM IP,Y    \ push IP, S, T, W, X, Y registers onto the stack RSP


    POPM  order :  R4, R5, R6, R7, Y, X, W, T, S, IP,TOS,PSP

    example : POPM Y,IP         \ pop Y, X, W, T, S, IP registers from the stack RSP

    error occurs if bad order (PUSHM Y,IP for example)


CPUx instructions RRCM,RRAM,RLAM,RRUM
    
    example : RRUM #3,R9      \ R9 register is Unsigned Right shifted by n=3

    error occurs if 1 > n > 4


conditionnal jumps use with symbolic assembler

    0=    { IF UNTIL WHILE ?JMP ?GOTO }
    0<>   { IF UNTIL WHILE ?JMP ?GOTO }   
    U>=   { IF UNTIL WHILE ?JMP ?GOTO }   
    U<    { IF UNTIL WHILE ?JMP ?GOTO }    
    S<    { IF UNTIL WHILE ?JMP ?GOTO }    
    S>=   { IF UNTIL WHILE ?JMP ?GOTO }   
    0>=   { IF UNTIL WHILE }
    0<    { ?JMP ?GOTO } 

