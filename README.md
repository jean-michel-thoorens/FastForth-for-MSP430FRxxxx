#FastForth for MSP430FRxxxx TI's devices

Small, smart, fast, efficient, versatile, reliable.

Tested on TI MSP-EXP430FR5739,5969,5994,6989,4133,2355,2433,2476 launchpads, at 0.5, 1, 2, 4, 8, 12, 16 MHz plus 20MHz and 24MHz with FR23xx,FR57xx devices.

It's an "interpret and compile" operating system for MSP430, very interesting because of its 5kB size.
That includes the kernel FORTH with double numbers and Q15.16 numbers interpreting,
an amazing assembler "label free" with conditional compilation, a 16-input search engine that speeds up the interpreter by 4,
and the choice between a connection with a serial terminal up to 6MBds, software (XON/XOFF) + hardware (RTS) control flow,
or with an I2C_Slave terminal up to 1MHz.

FastForth is a true ANS FORTH for afficionados but also it is used as superstructure for the embedded assembler.
So, if your goal is to program a MSP430FRxxxx in assembler or just to learn assembler, enjoy yourself: try it!
To discover how it works, compare the content of \ADDON\files.asm with their FORTH equivalent in \MSP430-FORTH\files.f

However, if the IDE works well with Windows 10, it works less well with Linux due to the lack of a good alternative to TERATERM...

For only 3 kbytes in addition, you have the primitives to access the SD\_CARD FAT16 and FAT32: read, write, del, download source files and to copy them from PC to the SD_Card. It works with all SD\_CARD memories from 64MB to 64GB. The cycle of read/write a byte is below 1 us @ 16 MHz.
This enables to make a fast data logger with a small footprint as a MSP430FR5738 QFN24.
With all the kernel addons, including extended\_ASM and SD\_Card driver, FastForth size is under 10 kB.

##how to connect TERMINAL

    The files launchpad_xMHz.txt are the executables ready to use with a serial terminal 
    (TERATERM.exe), 115200Bds, with XON/XOFF or RTS_hardware flow controls and a PL2303TA/CP2102 cable.
    ------------------------------------------------------------------------------------------
    WARNING! doesn't use them to supply your launchpad: red wire is 5V ==> MSP430FRxxxx destroyed!
    ------------------------------------------------------------------------------------------
    (modify this first, by opening the box to weld red wire on 3.3V pad).

programming with MSP430Flasher.exe and FET interface

     TI Launchpad <--> CP2102/PL2302TA cable <------> USB <-------------> TERATERM.exe 
              Vcc <--- 3V3           )
               RX <--- TX            )
              GND <--> GND           > used by FastForth TERMINAL
               TX ---> RX            )
              RTS ---> CTS (optionnal) RTS pin Px.y is described in your \inc\launchpad.asm)
    
     TI Launchpad <--> FET interface  <-------------> USB <-------------> MSP430Flasher.exe
              Vcc <--- 3V3
       TST/SBWTCK <--> SBWTCK
              GND <--> GND
      RST/SBWTDIO <--> SBWTDIO

programming with BSL_Scripter.exe

     TI Launchpad <--> CP2102/PL2303TA cable <------> USB <-------->+<--> TERATERM.exe
               RX <--- TX   )                                       |
              GND <--> GND  > used by FastForth TERMINAL            +<--> BSL_Scripter.exe
               TX ---> RX   )
              Vcc <--- 3V3  )   )
       TST/SBWTCK <--- RTS      )
              GND <--> GND      > used by BSL_Scripter
      RST/SBWTDIO <--> DTR      ) 
    
    Before programming device, close teraterm TERMINAL and connect the wire RST/SBWTDIO <--> DTR 
    Once device is programmed, open teraterm TERMINAL then disconnect the wire RST/SBWTDIO <--> DTR.

-

    Another interest of XON/XOFF flow control is to allow 3.75kV galvanic isolation of terminal input
    with SOIC8 Si8622EC|ISO7421E.
    
    Once FastForth is loaded in the target FRAM memory, you add assembly code or FORTH code, or both,
    by downloading your source files that FastForth and its assembler interpret and compile.
    
    Beforehand, the preprocessor GEMA, by means of a \config\gema\target.pat file, will have translated
    your generic source file.f in a targeted source file.4th, allowing you to use
    symbolic addresses for all peripheral registers, without having to declare them via FORTH words.
    A set of .bat files in \MSP430-FORTH folder is furnished to do all this automatically.
    
    If you want to change the terminal baudrate on the fly (230400 Bds up to 6 MBds),
    download to your launchpad the file \MSP430-FORTH\CHNGBAUD.f.
    
    To see all compilation options, download \MSP430-FORTH\FF_SPECS.f.

    If you choose for your target FastForth with I2C terminal, you will need a second launchpad to make the USBtoI2C bridge.
    
    After downloading of complementary words in \MSP430-FORTH\ANS_COMP.f, FastForth executes CORETEST.4th
    in less than a second, and without errors which ensures its compatibility with the FORTH CORE ANS94 standard.
    
    Notice that FAST FORTH interprets lines up to 84 chars, only SPACE as delimiter, only CR+LF as
    End Of Line, and BACKSPACE. 
    And that the high limit of FORTH program memory is $FF80. 
    
    Finally, using the SCITE editor as IDE, all is ready to do everything from its "tools" menu.

What is new ?
-------------

V306

    +8 bytes.
    
    Fixed the crash caused by forgetting the prefix '&' in the last term of an assembly instruction.
    (the TI's symbolic mode is not implemented).
    
    Added in the macro \config\SendFile.ttl the word ?ID to prevent any crash during download
    due to a device confusion:
        When downloading a source_file.f asked from the scite editor or by the use
        of SendSourceFileToTarget.bat, Teraterm macro first sends ?ID definition then 
        the string:  %deviceID% ?ID.
        By executing ?ID, FastForth substracts this %deviceID% value from the target's one then 
        executes ABORT" DeviceID mismatch!" : the downloading is aborted if DeviceID mismatch.
        %deviceID% is provided by the \config\select.bat file.
    
        When downloading a source_file.4TH, it's up to you to be careful because 
        Teraterm sends the string 0 ?ID, so that ?ID bypasses the substraction. 
        (when a source_file.4TH is issued from a source_file.f, you can verify
        the target name in its header).
    
    Added the word set DOUBLE in the \MSP430-FORTH\DOUBLE.f file.

V305

    -48 bytes.
    
    from Scite menu, we can program MSP430FRxxxx also with BSL_Scripter.
    
    To do, save file \prog\BSL_Scripter.exe from: 
    https://github.com/drcrane/bslscripter-vs2017/releases/download/v3.4.2/BSL-Scripter-v3.4.2.zip,
    but erasing a MSP430FR2355 doesn't work.
    
    and buy a USB2UART module CP2102 6 pin. On the web, search: "CP2102 3.3V DTR RTS" 
    For wiring, see \config\BSL_Prog.bat.
    
    So, we download both binaries and source files with only one CP2102|PL2303TA module,
    the XON/XOFF TERMINAL and BSL_Scripter. Bye bye T.I. FET!
    
    ABORT messages display first the I2C address, if applicable.
    QNUMBER some issues solved.
    UART version of ACCEPT and KEY are shortened.
    EVALUATE is moved to CORE_ANS.

V304

    -36 bytes.
    
    for kernel compiling use the last version of srecord (1.64) to enable overlapping in vectors area.
    
    The forthMSP430FR.lst output file is more readable because purged of all unused conditionnal parts.
    
    Fixed: word F. issue in FIXPOINT.asm
    
    Moved: words ALLOT and DOES> to CORE_ANS.asm/f files.
    
    CORDIC.f also works without hardware MPY (MSP430FR4133).
    
    By compiling :NONAME CODENNM DEFER IS, the new option DEFERRED superseeds the old NONAME option.
    
    pin RESET is software replaced by pin NMI and so, RESET executes COLD, allowing code insert before BOR.
    however SYSRSTIV numbering remains unchanged: = 4 for RESET, = 6 for COLD.
    
    Deep RESET reinitializes vectors interrupts and SIGNATURES area, instead of WIPE.
    
    Fast Forth Deep RESET is done by switches S1 + RST.
    
    
    A newcomer: FastForth for I2C TERMINAL. With the driver UART2I2CS running on another FastForth target,
    we have the USB to I2C_Slave bridge we need:
    only one TERMINAL interacts with all FastForth targets connected to an I2C network.
    
      notebook                              USB to I2C_Master bridge                      any I2C_slave with I2C TERMINAL
    +-----------+        +- - - - - - - - - - - - - - - - - - - - - - - - - --+          +-------------------------------+
    |           |        |                         master with UART TERMINAL  |         +-------------------------------+|
    |           |        +-----------+           +----------------------------+        +-------------------------------+||
    |           |        | PL2303TA  |2457600 Bds|           MCLK = 16 MHz    |        |                               |||
    | TERATERM -o-> USB -o->   or   -o--> UART --o--> FAST FORTH + UARTI2CS --o-> I2C -o--> FAST FORTH @ 16MHz with    ||+
    | terminal  |        |  CP2102   | XON/XOFF  |                            | 660kHz |  kernel option: TERMINAL_I2C  |+
    |           |        +-----------+           +----------------------------+        +-------------------------------+
    |           |        |                                                    |
    +-----------+        +- - - - - - - - - - - - - - - - - - - - - - - - - --+
    
    With the indicated MCLK and UART speeds, Coretest.4th is downloaded (and executed) to any I2C_Slave in 1,3s.
    The driver UARTI2CS works without error from 1MHz up to 24MHz MCLK and from 115200Bds up to 6MBds UART.
    With I2C_Master running at 24 MHz, the I2C bus frequency is about 1MHz, and it works fine even if I2C_slave is running at 1 MHz.

    The user could not tell the difference between using a uart terminal or using an I2C terminal, 
    if the WARM message did not mention the I2C address. 

-

    
    the copy of a file to I2C target SD_Card doesn't work.
    
    the Multi Master Mode works but is not tested in multi master environment.
    
    "Cherry on the pudding", when they wait for a TERMINAL input (idle state), 
    both I2C_Master and I2C_Slave(s) are sleeping in LPMx mode and the bus I2C is freed. 
    Sleep modes down to LPM4 are available for I2C_Slave devices.
    
    The driver UART2I2CS doesn't use the UCBx I2C_Master hardware, really too bad, but
    profitably its software version, faster, which consumes just two I/O (better in the range Px0-Px3),
    the UCBx remaining available typically for another I2C_Slave or SPI driver.
    
    On the side of I2C_Slave, pins SDA SCL are those defined as BUS_TERM in the file \inc\your_target.asm.
    I2CSLA0, in the file forthMSP430FR.asm, defines the I2C_Slave address of the I2C FastForth module.
    for I2C_Master, see \inc\your_UARTI2CS_bridge.pat the correnpodence of SM_SCL and SM_SDA.
    
    if you are uncomfortable with the flashing of leds,
    comment on their lines in the files forthMSP430FR_TERM_I2C.asm and MSP430-FORTH/UART2I2CS.f". 

#####HOW TO DO ?

    first you make a I2C cable (GND,SDA,SCL,3V3) between your 2 LaunchPad, with 3,3k pullup resistors on SDA and SCL lines.
    see each of two /inc/target.pat files to know SDA ans SCL pins.
    
    to compile FastForth for I2C TERMINAL from forthMSP430FR.asm file:
    1-  uncomment the line "TERMINAL_I2C".
    2-  search "I2CSLAVEADR" line and set your <slave address you want>, i.e. 10h.
    3-  compile file then prog your I2C_Slave LaunchPad.
    
    with the another LaunchPad running FastForth:
    At line 610 of UART2I2CS.f file set the <slave address you want>, i.e. $10.
    then download it, it's done: TERMINAL is linked to I2C_Slave.
    
    Type `Alt+B` on teraterm (send UART break) to unlink I2C_Slave.

V302

    -646 bytes
    Kernel + FIXPOINT input + DOUBLE input + :NONAME + Conditional Compilation + Assembler under 5 kB.
    
    the FORTH kernel is drastically reduced to 55 strutural words.
    All others are moved in the \ADDON\ANS_COMPLEMENT.asm file, 
    the conditionnal compilation with the assembler allowing to reuse them on request.
    
    Fixed:  QNUMBER, 
            ACCEPT (XON/XOFF TERMINAL with MSP430FR2xxx).
    Modified: [ELSE].
    
    FF_SPECS.f displays FastForth environment.

V301

    -584 bytes, Kernel + Conditional Compilation + Assembler under 5.5 kb.
    
    the FORTH kernel is drastically reduced to 82 words, just what the operating system needs.
    All others are moved in the \ADDON\ANS_COMPLEMENT.asm file, the conditionnal compilation
    allowing you to use them on request.
    
    Taking into account the new TI launchpad LP_MSP430FR2476.
    
    Fixed: :NONAME (now aligned), LOAD" (no more crash on error).
    Modified: ACCEPT, WORD, HEADER, CODE, ENDCODE, ASM, GOTO, ?GOTO, RPT.
    Removed JMP <word> and ?JMP <word> from assembler (replaced by GOTO BWx and ?GOTO BWx).
    
    ACCEPT is modified to include the RXON call in the word SLEEP. 
    By rewriting the defered word SLEEP, we can easily disable the TERMINAL_INPUT interrupt.
    See BACKGROUND, START and STOP  in \MSP430-FORTH\RC5toLCD.f.

V300

    -4 bytes.
    The prompt "ok" becomes a compilation option.
    
    Taking into account the digit separator '_' in ?NUMBER, to better see when typing binary numbers.
        example: %1010100011000111 can be typed as well: %1010_1000_1100_0111
    
    Corrected >NUMBER
    
    Modified GetFreeHandle CloseHandle
    
    Tested with BLE 5.0 terminal (a couple of BGX13P EVK) at 16MHz, 921600 bds + terminal 5 wires: 
        download throughput = 5 kbytes/s (and with errors when ECHO is ON), disappointing...
        (Bluetooth 2.1 terminal with one RN42 works well).
    
    RePeaTed instructions RRUX,RRCX,RLAX,ADDX,SUBX work fine! See TESTASMX.4TH

V209

    -26 bytes.
    V3 prerelease
    added experimental extended_assembler (MSP430FR5969,MSP430FR5994,MSP430FR6989)

V208

    -58 bytes.
    Simplified directory structure of project.
    Added switch DOUBLE_INPUT as kernel compilation ADDON, removed switch LOWERCASE.
    Added \MSP430-FORTH\CORDIC.f for aficionados.
    Added FF_SPECS.4th to show all specificities of FastForth compilation.
    Corrected LITERAL (double LITERAL part).
    Modified ACCEPT COLD WARM ?ABORT, S", QNUMBER.

V207 

    -50 bytes.
    Unlocking I/O's is transfered from RESET to WARM.
    Thus, by redirecting WARM, you can add I/O's configuration of your application before unlock them.
    
        two options to do this:
    
            Light option: 
            your START routine is inserted in WARM and continues with the default WARM. 
            Search "START" in the \MSP430_FORTH\IR_RC5.f file as application example.
    
            Complete option: 
            START routine replaces WARM and continues with ABORT (without WARM message).
            In this case, you can also change the Reset events handling but you will need to unlock I/O's 
            and configure TERMINAL I/O's in your START routine. 
            Search "activate I/O" in \MSP430_FORTH\RC5toLCD.f file to see how to do.
    
    Bugs corrected in target.asm, target.pat and device.inc files.

V206

    The terminal baudrate can be changed on the fly. Download MSP430-FORTH\CHNGBAUD.f to do.
    
    forthMSP430FR.asm: 
    
         Bugs corrected: ALSO and :NONAME (option).
    
         The structure of primary DEFERred words as KEY,EMIT,CR,WARM... is modified,
                          -------
         the address of their default execute part, without name, can be found with:
         ' <name> >BODY
    
             example, after this entry: ' DROP IS KEY
             KEY (or ' KEY EXECUTE) runs DROP i.e. runs the redirection made by IS,
             ' KEY >BODY EXECUTE runs KEY, the default action at the BODY address.
    
             and: ' KEY >BODY IS KEY
             restore the default action of this primary DEFERred word.
                                                -------
    
        WARNING! you cannot do that with words created by DEFER !
        DEFER creates only secondary DEFERred words, without BODY !
                            ---------
    
        to build a primary DEFERred FORTH word, 
                    -------
        you must create a DEFERred word followed by a
        :NONAME definition, ended by ; IS <name>
    
             DEFER truc
    
             :NONAME         \ does nothing (for the example)
                 DUP
                 DROP
             ; IS truc
    
        The advantage of creating primary DEFERred words is to set their
        default state, enabling to reinitialize them easily.
    
    forthMSP430FR_ASM.asm:
    
        All assembly code is revamped.
    
        POPM and PUSHM instructions now follow the TI syntax :-(
    
        Added CODENNM as assembly counterpart of :NONAME (option)
    
        to build the primary DEFERred assembly word "machin" :
                     -------
    
            DEFER machin
    
            CODENNM
                NOP2        \ assembly instruction
                NOP3        \ assembly instruction
                MOV @IP+,PC \ mandatory before ENDCODE
            ENDCODE IS machin
    
        you can obviously mix LOW/HIGH levels in CODENNM and :NONAME areas...

V205

    Added MSP-EXP430FR2355 launchpad
    Added word :NONAME (option).
    FastForth terminal via Bluetooth v2.1 + EDR (Microchip RN42) works fine in full duplex mode,
    up to 460800bds, 4 WIRES (GND,RX,TX,RTS); but with, as wireless effect, a bad troughput of 6kb/s
    instead of 30kb/s with a bridge UART2USB.
    Added 4Mbds,5Mbds terminal @16MHZ, for use with UART2USB PL2303HXD.
    Words AND, OR, XOR are moved as complement in ANS_COMP.f file.
    Simplified preprocessor files in \config\gema\ folder: only two for one target:
        one for the device, other for the target (launchpad or user application/module).
        and similarly with the assembly files: Device.inc and Target.asm, for compiling FastForth.
    Corrected startup time in target.asm files.
    Modified Clock config in MSP_EXP430FR2433.asm and MSP_EXP430FR4133.ASM, allowing clock modulation.

V202

    added the line number in case of error occurring when download a source file (*f,*.4th)
    in HALFDUPLEX mode (scite command CTRL+2) or in default NOECHO mode (scite cmd CTRL+0).
    However, in case of download a file.f (with preprocessing), this line number refers
    to the contents of the file named LAST.4th.

V201

    modified OPEN file primitive in forthMSP430FR_SD_LOAD.asm; modified forthMSP430FR_SD_INIT.asm
    reordered files preprocessor in only one folder.
    
    You can now compile FastForth from Linux, see FastForth.pdf
    ...But desperately searching for the linux equivalent of TERATERM !
    
    FastForth V2.0, major version.
    
    Word TIB is deprecated and replaced by CIB (Current Input Buffer)
    Word CR generates CR+LF instead of CR. TYPE is rewritten in assembly.
    
    Added fixed point s15q16 numbers. Thus FAST FORTH recognises : 
    unsigned/signed numbers u/n (u <= 65535) / (-32768 <= n <= 32767), 
    unsigned/signed double numbers ud/d by adding a decimal point 
    (ud <= .4294967295) / (-.2147483648 <= d <= .2147483647),
    and s15q16 signed numbers by adding a comma (-32768,00000 <= s15q16 <= 32767,00000).
    
    Fixed issue about the word LOAD": when called from a word, returns well into this calling word.
    Note that with MSP430FR57xx family, SDIB uses PAD, due to lack of RAM.
    
    With the BOOTLOADER option, QUIT becomes a DEFERed word to easily enable/disable bootloader:
    ' BOOT IS QUIT enables bootloader.
    ' QUIT >BODY IS QUIT disables bootloader.

V162

    Added a set of words to enable conditional interpretation/compilation : MARKER [DEFINED] [UNDEFINED] 
    [IF] [ELSE] [THEN]. A MARKER word (defined as {word} to well see it) allows you to wipe some program 
    even if loaded in memory below RST_STATE boundary.
    
    All interpretation/compilation errors now execute POWER_STATE, so any incorrect definition
    and all its source file will be automatically erased.
    
    Added a bootloader option which loads BOOT.4TH from SD_Card memory.

V161

    SD_Card driver works also with software multiplier (with MSP430FR4133)
    added SLEEP word enabling user access to background task, 
    see ACCEPT in forthMSP430FR.asm and see use in RC5toLCD.f
    
    You can type double numbers by inserting a decimal point.
    Example :   `$-12` is processed as 16 bits negative number.
                `$-.12` or `$-1.2` or `$-12.` are processed as 32 bits negative numbers.
    
    FAST FORTH V160, major version.
    
    Accept SD_Card from 64 MB (FAT16) up to 64 GB (FAT32). 
    Note that Windows 10 no longer offers the FAT32 format for the highest sizes of SD_CARD memory.
    So you must use an alternative to do, for example: https://www.partitionwizard.com.
    
    
    in SD_TOOLS the word SECTOR dumps a sector (use a 32 bits number).
                the word CLUSTER dumps first sector of a cluster. 
                Usage (notice the point): number. CLUSTER or number. SECTOR
    
    PREVIOUS versions
    
    Added direct file transfer from PC to the target SD_CARD. 
    Measured throughput with "HCI" SD CARD: 90 kbytes/s at 3Mbauds and 16MHz target clock.
    You can do it from scite editor (menu Tools) or by using specific bat file.
    Double click on it to see how to do.
    
    JTAG and BSL signatures (FF80h-FF88h) are protected against overwrite, typically during 
    source file download. 
    
    added signed number prefixes $ (hex), % (bin) and # (decimal) to supersede current BASE.
    
    Added words ASM and ENDASM to create assembler words that are not interpretable by FORTH
    i.e. that are called by {CALL|INTERRUPT} and ended by {RET|RETI}. These so created words 
    can be used only in ASSEMBLER context.
    
    In the embedded assembler, added 3 backward BW1 BW2 BW3 and 3 forward FW1 FW2 FW3 jump labels 
    to use with GOTO, ?GOTO.
    These labels are for single use (one jump for one label) but immediately reusable once resolved.
    
    you can compile up to 32 threads vocabularies.
    
    Memory management :
    Fast Forth defines 4 levels of program memory with this words :
        WIPE (and system failures) that resets program memory, vectors interrupts and any DEFERred words,
        RST_HERE/RST_STATE that sets/resets the boundary of program protected against <reset> and COLD,
        PWR_HERE/PWR_STATE that sets/resets the boundary of program protected against power ON/OFF,
        and nothing, i.e. volatile program.
    
    You can download source files with hardware and/or software control flow (i.e. without line 
    or char delays) up to:
        134400  bds @ 500kHz
        268800  bds @ 1MHz
        614400  bds @ 2MHz
        1228800 bds @ 4MHz
        2457600 bds @ 8MHz
        3000000 bds @ 16MHZ
        6000000 bds @ 24MHz with MSP430FR57xx devices
    See main file DTCforthMSP430FR5xxx.asm for the list of reliable baudrates.
    
    FAST FORTH can be adjusted by selection of SWITCHES in the source file to reduce its size according   
    to your convenience. To do, comment/uncomment their line.
    
    for your application, select the mode LPM{0,1,2,3,4} that enables wake on FAST FORTH input, 
    depending of family: FR2xxx: LPM0, FR57xx : LPM0 to LPM2, FR59xx : LPM0 to LPM4.
    
    DEEP_RST (RESET + WIPE) can be hardware performed via the programmation interface 
    (Vcc,RX,TX,RST,TEST,GND).

Many thanks to Brad Rodriguez
-----------------------------

for his CamelForth which served me as a kind of canvas.
And also to Matthias Koch for its ideas about Q15.16 implementation.

Unlike CamelForth FASTFORTH is a "Direct Threaded Code", with an embedded assembler following the standard syntax,
not the one used in the world Forth.

Its core is fully compliant with the standard ANS.

It is optimized for the speed, especially in the interpreter mode, so that you can load an application program written in FORTH/Assembler faster than its binary via MSP430 Flasher.exe.
Everything can be done from your text editor, the preprocessor and a serial terminal.

What's this and why?
---

I have first programmed atmel tiny devices.
Particularly I2C master driver to have both I2C slave and I2C master on a ATtiny461.
which means a lot of back and forth between the editor, assembler, the programmer and the test in situ.

Previously I had programmed a FORTH on a Motorola 6809 and had been seduced by the possibility of sending a source file directly to the target using a serial terminal. Target which compiled and executed the program. At the time FORTH program lay in a battery backed RAM.

The advent of chip MSP430 TEXAS INSTRUMENT with embedded FRAM gave me the idea to do it again : FAST FORTH was born.

Today I dropped the ATMEL chips and proprietary interfaces, I program my applications in a mix 80%/20% of assembler/FORTH I then sent on MSP430FR5738 chips with embedded FAST FORTH.

And that's the magic: After I finished editing (or modify) the source file, I press the "send" button in my text editor and I can test result on target in the second following. This is the whole point of an IDE reduced to its simplest form: a text editor, a cable, a target.

Content
-------

See FastForth.pdf

Organize your gitlab copy of FastForth
-------

See FastForth.pdf

Minimal Software
-----

See FastForth.pdf

Build the program file
----------------------

\forthMSP430FR.asm is the main file to compile FastForth:    

Open forthMSP430FR.asm with scite editor

uncomment the target as you want, i.e. MSP_EXP430FR5969

choose frequency, baudrate, flow control.

uncomment options switches as your convenience.

save file.

assemble (CTRL+0). A window asks you for 4 parameters:

set target as first param, i.e. MSP_EXP430FR5969

then execute. the output will be \binaries\MSP_EXP430FR5969.txt

Load Txt file (TI format) to target
-----------------------------------

    in \binaries folder, drag your target.txt file and drop it on prog.bat
    
    or use scite internal command TOOLS: FET prog (CTRL+1).

nota : programming the device use SBW2 interface, so UARTn is free for serial terminal connexion.

If you want to program your own MSP430FRxxxx board, wire its pins TST, RST, 3V3 and GND 
to same pins of the launchpad, on eZ-FET side of the programming connector.

Connect the FAST FORTH target to a serial terminal
-------------------------------------------------

you will need an USBtoUART cable with a PL2303TA or PL2303HXD device that allows both XON/XOFF 
and hardware control flow :

    http://www.google.com/search?q=PL2303TA
    http://www.google.com/search?q=PL2303HXD

or USBtoUART bridge, with a CP2102 device and 3.3V/5V that allows XON/XOFF control flow :

    search google: cp2102 module 3.3V
    http://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx
    
    you must program CP2102 device for speeds beyond 1MBds
    http://www.silabs.com/Support%20Documents/Software/install_USBXpress_SDK.exe
    http://www.silabs.com/Support%20Documents/TechnicalDocs/an169.pdf

or a USBtoUART bridge, with a FT232RL device and 3.3V/5V for only hardware control flow:

    WARNING! buy a FT232RL module with a switch 5V/3V3 and select 3V3.
    
    http://www.google.com/search?q=FT232RL+module+3.3V
    http://www.ftdichip.com

or compatible 921600bds wireless module: RN42 (bluesmirf), RN4878...

Send a source file.f or file.4th to the FAST FORH target
------------------

Three bat files are done in \MSP430-FORTH that enable you to do all you want.
drag and drop your source file on to.
you can also open any source file with scite editor, and do all you want via its Tools menu.

If you have any downloading error, first verify in "LAST.4th" that all lines are 
correctly ended with CR+LF.

SD_Card Load, Read, Write and Delete
=============================================

First, hardware
---------------

If you have MSP-EXP430FR5994, nothing to do.

For the choice of a SD card socket be carefull, pin CD (Card Detect) must be present! 
google search: "micro SD card 9 pin"
Look for the good wiring in /Launchpad.asm file

Compile with SD_Card addon
--------------

in forthMSP430FR.asm, uncomment lines SD_CARD_LOADER,  SD_CARD_READ_WRITE, SD_TOOLS 
then compile for your target

the commands
------------

With the LOAD" pathame" command you load your source files from a SD_CARD memory in both execute 
and compile modes. Idem for READ", WRITE" and DEL" commands.

See "SD_TESTS.f", a FORTH program done for example

If you remove the SD memory card reader and then reset, all SD\_IO pins are available except SD_CD obviously.

HowTo LOAD a sourcefile
--------------

    LOAD" path\filename.4th".

The file is interpreted by FORTH in same manner than from the serial terminal.

When EOF is reached, the file is automatically closed.

A source file can _LOAD"_ an other source file, and so on in the limit of available handles (up to 8).

HowTo READ a file
--------------

    READ" path\filename.ext".

The first sector of this file is loaded in BUFFER.
To read next sectors, use the command READ that loads the next sector in the buffer, 
and leaves on the stack a flag that is true when the EOF is reached. 
The file is automatically closed. See tstwords.4th for basic usage.

The variable BufferLen keep the count of bytes to be read (0 to 512).

If you want to anticipate the end, use the CLOSE command.

HowTo WRITE a file
---------------

    WRITE" path\filename.ext".

If the file does not exist, create it, else open it and set the write pointer at the end of the file, 
ready to append chars.

See example of use in \MSP430-FORTH\SD_TEST.f.

To overwrite an existing file: DEL" file" then  WRITE" file".

Use CLOSE to close the file.

HowTo delete a file
---------------

    DEL" path\filename.ext". If the file is not found, do nothing, no error.

HowTo change DIRectory
---------------

    LOAD" \misc".             \misc becomes the current folder.
    LOAD" ..\"                parent folder becomes the current folder.
    LOAD" \"                Root becomes the current folder.

Drive letters are always ignored.

Downloading source file to SD_Card
------------------------------------------

to download a source file (.f or.4th) onto SD_CARD target, use CopySourceFileToTarget\_SD\_Card.bat.
Double click on one of this bat files to see how to do.

or use scite.

If you have any downloading error, first verify in "LAST.4th" that all lines are 
correctly ended with CR+LF.

I2C DRIVERS
===========

The I2C\_Soft\_Master driver with normal/fast mode allows you to add then use any couple of pins to drive a bus I2C :

- without use of eUSCI UCBx
- I2C\_Soft\_MultiMaster driver : same plus detection collision
- plus I2C\_Slave driver that uses the eUSCI UCBx hardware

Other interesting specificities :
=====

Management of vocabularies (not ANSI) with the option VOCABULARY_SET:
VOCABULARY, DEFINITIONS, ONLY, ALSO, PREVIOUS, CONTEXT, CURRENT, FORTH, ASSEMBLER. 
In fact, it's the the assembler that requires the vocabularies management.

Recognizing prefixed numbers %101011 (bin), $00FE (hex) and #220 (decimal).
you can insert underscores in numbers: %1100_1101_0000_0001 instead of %1100110100000001.

ECHO / NOECHO

The words DEFER and IS are implemented. CR, EMIT, KEY, ACCEPT, QUIT and WARM are deferred words.

Error messages are colored (reverse video on ANSI terminal).

Assembly jumps are as FORTH one's : IF, ELSE, THEN, BEGIN, AGAIN, UNTIL, WHILE.
Not canonical jumps are also available with GOTO|?GOTO to 
backward labels BW1 BW2 BW3 or forward labels FW1 FW2 FW3.
Backward labels BWx are live until new definition, forward labels FWx are for single use.
Switch  within definitions between FORTH and Assembly contexts with words HI2LO and LO2HI. 
See examples in the TstWords.f file. This is perhaps the most interesting feature for development...

The system is not responding ?
======

First, swich off then switch on. FORTH restarts as it was after the last PWR\_HERE command.

If the system is not restarted, press <reset> button on the MSP-EXP430FR5xxx ; FORTH restarts 
as it was after the last RST_HERE command.

If the system does not restart again, press `SW2+RESET`. 
FORTH restarts as it is in the HEX file. Equivalent software : WIPE + COLD.

Here is the FastForth init architecture :

    case 0 : when you type `WARM`, FORTH interpreter is restarted, no program lost. 
             the WARM display is preceded by "#0". 
    
    case 1 : Power ON ==> performs reset and the program beyond PWR_HERE is lost.
             the WARM display is preceded by the SYSRSTIV value "#2".
    
    case 1.1 : when you type `PWR_STATE` ==> the program beyond PWR_HERE is lost.
    
    case 1.2 : If an error message (reverse video) occurs from the interpreter,
               PWR_STATE is automatically executed and the program beyond PWR_HERE is lost. 
               In this way, any error is followed by the complete erasure of the uncompleted word, 
               or by that of the downloading source file causing this error. 
               It is recommended to finish a source file with at least PWR_HERE to protect it
               against any subsequent error.
    
    case 2 : <reset>  ==> performs reset and the program beyond RST_HERE is lost.
             the WARM display is preceded by the SYSRSTIV value "#4".
    
    case 2.1 : when you type `COLD` (software reset) ==> same effects.
               the WARM display is preceded by the SYSRSTIV value "#6".
    
    case 2.2 : when you type `RST_STATE` ==> the program beyond RST_HERE is lost.
    
    
    case 3 : when you type `WIPE` ==> all programs donwloaded from the terminal or the SD_Card are lost.
    
    
    case 4 : `SW2+RESET` ===> performs deep reset, and all programs 
             donwloaded from the terminal or the SD_Card are lost. The WARM display is preceded by #-4.
    
    case 4.1 : reset on failure (SYSRSTIV = #10 | SYSRSTIV >= #22) ===> same effects
               The WARM display is preceded by the SYSRSTIV negative value.
    
    case 4.2 : writing -1 in SAVE_SYSRSTIV before COLD = software DEEP_RST ===> same effects
               The WARM display is preceded by "-1".
    
    case 5 : after FAST FORTH core compilation, the WARM displays #5. User may use this
             information before WARM occurs.

If SD\_CARD extention and SD\_CARD memory with \BOOT.4TH included, the cases 1 to 4 starts it 
after displaying of WARM message. 

VOCABULARY ADD-ON
====

These words are not ANS94 compliant, they are those of F83 standard.

For example, after loading SD_TOOLS add-on, you can type: ALSO ASSEMBLER WORDS PREVIOUS WORDS

    With ALSO ASSEMBLER, the vocabulary ASSEMBLER is added to the search CONTEXT thus the ASSEMBLER words
    become visible,
    
    WORDS display the words of ASSEMBLER then those of FORTH,
    
    PREVIOUS remove the vocabulary ASSEMBLER form the CONTEXT, and the ASSEMBLER words become hidden,
    
    so the last WORDS display only FORTH words.

In the forthMSP430FR_ASM.asm, see the FORTH word CODE that add ASSEMBLER to the search CONTEXT and the ASSEMBLER word ENDCODE
 that remove ASSEMBLER from search CONTEXT. Thus, the assembler words can be used only between CODE and ENDCODE.

The CONTEXT can grow up to 6 vocabularies by using the word ALSO.

If you want add words to the assembler you must type: ALSO ASSEMBLER DEFINITIONS,
The vocabulary ASSEMBLER is added to the search CONTEXT as previously but also becomes the CURRENT vocabulary in which the new words will be stored.

Finally, FORTH ONLY DEFINITIONS limits the search CONTEXT to FORTH and the CURRENT vocabulary is FORTH. 

EMBEDDED ASSEMBLER
======

With the preprocessor GEMA the embedded assembler allows access to all system variables. 
See files \\inc\\Target.pat. 
You can also access to VARIABLE, CONSTANT or DOES type words. See \\MSP430-FORTH\\TESTASM.4th.

HOW TO MIX assembly and FORTH ?
---

FAST FORTH knows three kinds of words :

    high level FORTH words beginning with : <name> and ended with ;

    low level assembly words starting with CODE <name> and ended with ENDCODE

    low level assembly words starting with ASM <name> and ended by ENDASM
    these words are hidden because they are not FORTH executable.
    they can be used only by calling from CODE words.
    
Examples
    
    : NOOP          \ FORTH word "NOOP", do nothing
        DUP
        DROP
    ;

    CODE ADD        \ Assembly word "ADD", alias of word +
        ADD @PSP+,TOS
        MOV @IP+,PC
    ENDCODE

    ASM WDT_INT     \ Watchdog interrupt
    BIT #8,&TERM_STATW  \ break (ALT+b) sent by TERMINAL ?
    0<> IF              \ if yes
        MOV #WARM,PC    \   continue with WARM
    THEN
    RETI                \ else return to background task SLEEP
    ENDASM
    
    
To end a low level assembly word, the instruction MOV @IP+,PC jumps to the next FORTH word. 
This faster (4 cycles) and shorter (one word) instruction replaces the famous pair of assembly 
instructions : CALL #LABEL ... RET (4+4 cycles, 2+1 words). The register IP is the Interpretative Pointer. 

High level FORTH word starts with a boot code DOCOL that save the IP pointer, load it with the first address
of a list of execution addresses, then performs a postincrement branch to this first address. 
The list ends with the address of another piece of code EXIT (6 cycles) that restores IP before the instruction MOV @IP+,PC.

here, the compilation of low level word ADD :

                    header          \ compiled by the word CODE
    execution addr  ADD @PSP+,TOS
                    MOV @IP+,PC     \ instruction called NEXT

and the one of the high level word NOOP :

                    header          \ compiled by the word :
    execution addr  CALL rDOCOL     \ boot code compiled by the word :
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
            asm1                \ assembly instruction
            ...
            PUSH IP             \ save IP before use
            MOV #1,IP           \ assembly instruction that uses IP
            ...                 \ assembly instructions
            MOV @RSP+,IP        \ restore IP
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word

A little more complex, the case of mixing FORTH and assembly with use of the words HI2LO, LO2HI and COLON

        : MIX_FORTH_ASM         \ definition of a FORTH word starts with :
            SWAP
            DUP
        HI2LO                   \ FORTH to assembler switch
            asm1                \ you can freely use IP
            asm2
            ... 
            ...
            MOV @RSP+,IP        \ restore IP stacked by :
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word

If we see the code "MIX\_FORTH\_ASM" after compilation :

            header              \ compiled by :
    exec@   CALL rDOCOL         \ boot code (which saves IP onto stack) compiled by :
            addr of SWAP
            addr of DUP
            next addr           \ addr of asm1, compiled by HI2LO
            asm1
            asm2
            ...
            ... 
            MOV @RSP+,IP        \ restore IP saved by boot code
            MOV @IP+,PC         \ NEXT

going a step further :

        CODE MIX_ASM_FORTH      \ CODE starts a low level word
            asm1
            asm2
        COLON                   \ starts high level
            word1
            word2
        ;                       \ end of high level word

If we see this code "MIX\_ASM\_FORTH" after compilation :

            header              \ compiled by CODE
    exec@   asm1
            asm2
            CALL rDOCOL         \ compiled by COLON
            addr of word1
            addr of word2
            addr of EXIT        \ the word ; compiles address of EXIT that restores IP then executes MOV @IP+,PC

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

            header              \ compiled by :
    exec@   CALL rDOCOL         \ boot code compiled by the word :
            addr of word1
            addr of word2
            ...
            next addr           \ compiled by HI2LO
            MOV #0,IP           \ IP is free for use
            asm1                \ assembly instruction
            ...
            CALL #EXIT          \ compiled by LO2HI (10 cycles switch)
            addr of word3
            addr of word4
            addr of EXIT

EXIT is used twice !

the first time, by LO2HI :

    EXIT    MOV @RSP+,IP    \ 2 pop into IP the PC pushed on return stack by CALL #EXIT
            MOV @IP+,PC     \ 4 execute the routine at addr3 

then at the end of FORTH word (addr5):

    EXIT    MOV @RSP+,IP    \ 2 pop old IP from return stack
            MOV @IP+,PC     \ 4 execute the routine pointed by the old IP

Still another step : 

        CODE MIX_ASM_FORTH_ASM  \ CODE starts a low level word
            asm1
            asm2
        COLON                   \ switches from assembly to FORTH (COLON saves IP)
            word
            ... 
        HI2LO                   \ FORTH to assembler switch
            asm3
            asm4
            MOV @RSP+,IP        \ restore IP
            MOV @IP+,PC         \ NEXT
        ENDCODE                 \ end of low level word

In fact, an exclusive of FAST FORTH, the start of a word FORTH can be placed anywhere :

        CODE MIX_ASM_FORTH_ASM_FORTH
            asm1
            asm2
            ...
        COLON                   \ starts high level
            word1
            word2
            ...
        HI2LO                   \ FORTH to assembler switch
            asm3
            asm4
           ...
        LO2HI                   \ assembler to FORTH switch
            word
            word
            ...
        ;                       \ end of high level word

with the compiled result :

            header              \ compiled by CODE
    exec@   asm
            asm
            CALL rDOCOL         \ compiled by COLON
            addr
            addr
            next address        \ compiled by HI2LO
            asm
            asm
            CALL #EXIT          \ compiled by LO2HI
            addr
            addr
            EXIT addr           \ that restores IP from return stack and then executes MOV @IP+,PC

As we see, IP is saved once time, it's logical.                      

ASSEMBLER WITHOUT LABELS ? YES !
---

To compare AS macro assembler and FastForth embedded assembler,
compare files \ADDON\FIXPOINT.asm and \MSP430-FORTH\FIXPOINT.f

The conditionnal instructions doesn't use labels.
Instead, they borrow FORTH's conditional environment:

    CODE TEST_IF_THEN
        CMP #1,R8           \ set Z,N,V, flags
        0= IF               \ irritating, the "IF 0=" upside down, isn't it?
            ADD R8,R9       \ true part of comparaison
        THEN                    
        ...                 \ the next
        ...
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
        ...                 \ the next for the two branches
        MOV @IP+,PC
    ENDCODE

test for loop back version BEGIN ... UNTIL

    CODE TEST_BEGIN_UNTIL
        MOV #8,R10
        BEGIN           
            SUB #1,R10      \ set Z,N,V flags
        0= UNTIL            \ loop back to BEGIN if flag Z is not set
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

to quit this infinite loop, press reset. 

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

you can also MIX conditional branches with a mix of FORTH/assembly: see TEST5 in the demo file \MSP430-FORTH\TESTASM.4TH


FAST FORTH have one pass assembler, not able to make forward jump.

I have added possibility of several "non canonical" jumps, up to 3 backward and up to 3 forward jumps to label :

    \ C UM/MOD   udlo|udhi u1 -- ur uq
    CODE UM/MOD
        MOV @PSP+,W     \ 2 W = DIVIDENDhi
        MOV @PSP,S      \ 2 S = DIVIDENDlo
    \ T.I. ROUTINE  Section 5.1.5 of MSP430 Family Application Reports
        MOV #0,Y        \ 1 CLEAR RESULT
        MOV #16,X       \ 2 INITIALIZE LOOP COUNTER
    BW1 CMP TOS,W       \ 1
        U>= IF          \ 2
            SUB TOS,W   \ 1 if carry DIVIDENDhi-divisor
        THEN
    BEGIN
        ADDC Y,Y        \ 1 RLC quotient
        U>= ?GOTO FW1   \ 2 if carry Error: result > 16 bits
        SUB #1,X        \ 1 Decrement loop counter
        <0 ?GOTO FW2    \ 2 if 0< terminate w/o error
        ADD S,S         \ 1 RLA DIVIDENDlo
        ADDC W,W        \ 1 RLC DIVIDENDhi
        U< ?GOTO BW1    \ 2 if not carry    14~ loop
        SUB TOS,W       \ 1 if carry DIVIDENDhi-divisor
        BIS #1,SR       \ 1 SETC
    AGAIN               \ 2                 14~ loop
    FW2 BIC #1,SR       \ 1 CLRC  No error, C = 0
    FW1                 \  Error indication in C
    \ END of T.I. ROUTINE  Section 5.1.5 of MSP430 Family Application Reports
        MOV W,0(PSP)    \ 3 remainder on stack
        MOV Y,TOS       \ 1 quotient in TOS
        MOV @IP+,PC     \ 4
    ENDCODE

Forward labels FWx are for single use, backward labels BWx can solve several jumps,
until new definition.

SYMBOLIC ASSEMBLER ? YES !
--

I have discovered a little semantic preprocessor "GEMA", just like that FAST FORTH have its symbolic assembler !

    \inc\DEVICE.pat contains memory map and vectors for a specified DEVICE
    \inc\LAUNCHPAD.pat is the I/O config file for specific LAUNCHPAD (or application)

gema translates also FORTH registers in ASM registers (R0 to R15)

With the three bat files in \MSP430_FORTH folder all is done automatically.

COMPILE FAST FORTH FOR YOUR MODULE
--

1- in forthMSP430FR.asm "TARGET configuration"  create a line for your target, example:

    ;MY_MSP430FR5738_1 ; compile for my own MSP430FR5738 miniboard V1

2- create your \inc\MSP430FR5738_1.asm and \inc\MSP430FR5738.inc from another target.asm and device.inc as pattern, 
Notice that you must define here only the necessary for FAST-FORTH compilation.

3- in \inc\ThingsInFirst.inc add one "device.inc" item:

        .IFDEF MY_MSP430FR5738_1
    UCA0_UART   ; defines uart used by FORTH input terminal 
    LF_XTAL     ; defines if your module have a 32768 Hz xtal, to enable it.
    UCB0_SD     ; defines UC used for SD Card driver if used
        .include "MSP430FR5738.inc"  ; include device declarations
        .ENDIF

4- in \inc\TargetInit.asm add one "target.asm" item: 

        .IFDEF MY_MSP430FR5738_1
            .include MY_MSP430FR5738_1.asm
        .ENDIF

Then, for the preprocessor which you will use when downloading source files:

1- create your \inc\device.pat file if not exist, from your \inc\device.inc and another \inc\device.pat as pattern.

2- create your \inc\target.pat file from your \inc\target.asm and another \inc\target.pat as pattern.

Best practice, I suggest you that all digital pins you define (input or output) in your projects have their idle state high, with external pull up resistor
that is the reset state of FastForth...

START YOUR PROJECT
--

How to start your project ?

I show you, assuming you are working from the scite editor with its enhanced tools menu.

First you create two files : project.f and test.f

PROJECT.f :

    ; ----------------------------------------------------
    ; MSP430FR5969 MSP_EXP430FR5969 8MHZ 921600bds PROJECT.f
    ; ----------------------------------------------------
    
    [DEFINED] {PROJECT} [IF] {PROJECT} [THEN] \ remove {PROJECT} if exist (memory managment)
    
    MARKER {PROJECT}

here you append your already tested routines :

    CODE FIRST  \ assembler CODE words are FORTH executable
        ...
    MOV @IP+,PC \ NEXT
    ENCODE
    
    ASM TWO     \ assembler ASM words are not FORTH executable and can only be used in assembler mode
        ...     \ used to define interrupt routines, or subroutines called by CALL...
    RET         \ and ended by RET or RETI.
    ENDASM
    
    CODE THREE
        ...
    CALL #TWO   \ CALL only ASM words
        ...
    MOV @IP+,PC \ NEXT
    ENCODE
    
    ASM WDT_INT             \ interrupt routine
        ...
        ...
    BIC #WDTIFG,&SFRIFG1    \ reset WDT_INT flag
    BIC #$F8,0(RSP)         \ set CPU ON and GIE OFF in saved SR
    RETI                    \   
    ENDASM
    
    ;

then finish with this 2 "magic" words plus one optional : START, STOP and optional BACKGROUND

    ASM BACKGROUND          \ (optional)
    BW1
        ...                 \ insert here your background task
        ...
        ...
    BIS &LPM_MODE,SR        \
    GOTO BW1
    ENDASM                  \
    
    
    
    
    
    CODE START              \ to init your app
        ...                 \ init assembly part
    MOV #WDT_INT,&VEC_WDT   \ init WDT vector interrupt
        ...
    BIC #RC5,&P1REN         \ init I/O
        ...
    
    MOV #SLEEP,X            \ redirect default background task
    MOV #BACKGROUND,2(X)    \ to yours (optional)
    
    COLON
        ...                 \ init FORTH part
    
        LIT RECURSE IS WARM \ replace WARM by START
        ['] WARM >BODY      \ and end START with default WARM
        EXECUTE             \ that unlock I/O, start FORTH process
    ;                       \ then fall down to sleep state, waiting any interrupt...
    
    
    CODE STOP               \ to properly stop your app
        MOV #SLEEP,X        \ restore the default background (optional)
        ADD #4,X            \ (word SLEEP can only be seen in assembler mode, not in FORTH)
        MOV X,-2(X)
    COLON
        ['] WARM >BODY
        IS WARM             \ remove START from FORTH init process 
        ECHO                \ to always retrieve FORTH input terminal
        COLD                \ reset CPU, interrupt vectors and restart FORTH.
    ;
    
    
    RST_HERE
    
    START       ; let's go!

end of file

Each time you download this project file, the word {PROJECT} removes all subsequent definitions,
and the word RST_HERE protects the PROJECT against RESET. 

The word START allows you to include your app init into FORTH's one.
The word STOP unlink your app from FORTH init process.

Look at the file RC5toLCD.f to retrieve this structure.

TEST.f :

    \ ----------------------------------
    \ MSP-EXP430FR5969_8MHZ_TEST.f
    \ ----------------------------------
    
    RST_STATE   \ memory managment
    
    here you write your routine to test
    
    CODE TEST
    ...
    ...
    MOV @IP+,PC
    ENDCODE
    
    
    PWR_HERE    \ test.f content is protected against POWER OFF, but volatile with <reset>

Each time you download this TEST file, the word RST\_STATE clears memory content beyond PROJECT. 

let's go
--

With the SCITE menu tools : send a file.f, you download first your project.f file, then your test.f file that include the routine to test.

If the test don't work, modify it in the test.f file, then reload it.

When the routine "test" works as you want, you cut it in test.f file and copy it in project.f, then when you reload it, test is done !

Good luck !

ANNEXE
==

Here you have a good view of MSP430 assembly:
http://www.ece.utep.edu/courses/web3376/Notes_files/ee3376-isa.pdf

FastForth embedded assembler doesn't recognize the (useless) TI's symbolic addressing mode: ADD.B EDE,TONI.

REGISTERS correspondence (you can use freely ASM or TI or FASTFORTH registers's names).

        ASSEMBLER   TI      FASTFORTH   comment 
    
        R0          PC      PC          Program Counter
        R1          SP      RSP         Return Stack Pointer
        R2          SR/CG1              Status Register/Constant Generator 1
        R3          CG2                 Constant Generator 2
        R4          R4      R (rDOCOL)  contents address of xDOCOL (DTC=1|2)            
        R5          R5      Q (rDODOES) contents address of xdodoes   
        R6          R6      P (rDOCON)  contents address of xdocon    
        R7          R7      M (rDOVAR)  contents address of RFROM           
        R8          R8      Y           scratch register
        R9          R9      X           scratch register
        R10         R10     W           scratch register
        R11         R11     T           scratch register
        R12         R12     S           scratch register      
        R13         R13     IP          Interpretation Pointer
        R14         R14     TOS         Top Of parameters Stack
        R15         R15     PSP         Parameters Stack Pointer

**REGISTERS use**

    The FASTFORTH registers rDOCOL, rDOVAR, rDOCON and rDODOES must be preserved. 
    If you use them you can either PUSHM #4,M before and POPM #4,M after,
    or use then restore FastForth default values:
    xdocol, xdovar, xdocon, xdodoes. See device.pat.
    
    But if you use this registers you must not at the same time call any FORTH words
    created by them! 
    
    don't use R3 and use R2 only with BIC, BIT, BIS instructions in register mode.

    The bits 0-11 of SR register are saved by interrupts and restored by the instruction RETI.
    you can use freely UF9 UF10 and UF11 as SR bits 9-11. 
    FastForth uses UF9 for double numbers interpreting.
    

**PARAMETERS STACK**

    The register TOS (Top Of Stack) is the first cell of the Parameters stack. 
    The register PSP (Parameters Stack Pointer) points the second cell.
    
    to push one cell on the PSP stack :
    
        SUB #2,PSP                  \ insert a empty 2th cell
        MOV TOS,0(PSP)              \ fill this 2th cell with first cell
        MOV <what you want>,TOS     \ MOV or MOV.B <what you want>,TOS ; i.e. update first cell
    
    to pop one cell from the PSP stack :
    
        MOV @PSP+,TOS               \ first cell TOS is lost and replaced by the 2th.
    
    don't never pop a byte with instruction MOV.B @PSP+, because it generates a stack misalignement...

**RETURN STACK**

    register RSP is the Return Stack Pointer (SP).
    
    to push one cell on the RSP stack :
    
        PUSH <what you want>        \
    
    to pop one cell from the RSP stack :
    
        MOV @RSP+,<where you want>   \
    
    don't never pop a byte with instruction MOV.B @RSP+, ...
    
    
    to push multiple registers on the RSP stack :
    
        PUSHM #n,Rx                 \  with 0 <= x-(n-1) < 16
    
    to pop multiple registers from the RSP stack :
    
        POPM #n,Rx                  \  with 0 <= x-(n-1) < 16
    
    PUSHM order : PSP,TOS, IP, S , T , W , X , Y ,rDOVAR,rDOCON,rDODOES,rDOCOL, R3, SR,RSP, PC
    PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5   ,  R4  , R3, R2, R1, R0
    
    example : PUSHM #6,IP pushes IP,S,T,W,X,Y registers to return stack
    
    POPM  order :  PC,RSP, SR, R3,rDOCOL,rDODOES,rDOCON,rDOVAR, Y , X , W , T , S , IP,TOS,PSP
    POPM  order :  R0, R1, R2, R3,  R4  ,  R5   ,  R6  ,   R7 , R8, R9,R10,R11,R12,R13,R14,R15
    
    example : POPM #6,IP pulls Y,X,W,T,S,IP registers from return stack
    
    error occurs if n is out of bounds

**conditionnal jumps use**

    0=    with IF UNTIL WHILE ?GOTO
    0<>   with IF UNTIL WHILE ?GOTO   
    U>=   with IF UNTIL WHILE ?GOTO   
    U<    with IF UNTIL WHILE ?GOTO    
    S<    with IF UNTIL WHILE ?GOTO    
    S>=   with IF UNTIL WHILE ?GOTO   
    0>=   with IF UNTIL WHILE
    0<    with ?GOTO 
