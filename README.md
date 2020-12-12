# FastForth for all MSP430FRxxxx TI's devices,  light, fast, efficient, reliable.

Tested on TI MSP-EXP430FR(5739,5969,5994,6989,4133,2355,2433) launchpads, at 1, 2, 4, 8, 12, 16 MHz plus 20MHz & 24MHz with MSP430FR(23xx,57xx) devices.

FastForth is a **5kB size** "load interpret compile" operating system for MSP430 devices with FRAM which includes:

* FORTH kernel with interpreting decimal, hex, binary numbers (#,$,% prefixes), double numbers and Q15.16 numbers,

* the assembler, **label free, with TI's syntax**,

* easy roundtrip between FORTH and ASSEMBLER in definitions, with only 2 switches: `HI2LO` and `LO2HI`,

* conditional compilation,

* efficient memory management which can be modulated according to these 3 levels: power on, reset, deep reset,

* automatic memory releasing with MARKER tags,

* robust and visual error handling,

* choice of the TERMINAL (TERATERM.exe) interface:

    * UART TERMINAL up to 6MBds @ MCLK=24MHz, with software (XON/XOFF) and/or hardware (RTS) control flow, **transmit delay: 0 ms/char, 0 ms/line**

    * **I2C TERMINAL up to 1MHz**, "full duplex" like, allowing to communicate with several **I2C_FastForth** targets,
    
* and therefore, **"loading, interpreting, compiling" a source file is faster and easier than loading its binary equivalent**,

* transmission errors, if any, are automatically rejected by the on-board interpreter,

* CPU in sleep mode LPM0:LPM4, awaiting a command from UART:I2C TERMINAL, or any user interrupt event,

* direct access to all SFR and other symbolic addresses by use of [GEMA preprocessor](https://github.com/NeonMan/gema),

* Fully configurable reset, initialisation and background sequences.

For only 3 kbytes in addition, you have the primitives to access the SD\_CARD FAT16 and FAT32: read, write, del, download source files and also copy them from PC to the SD_Card. It works with all SD\_CARD memories from 64MB to 64GB. The cycle to read/write a byte is below 1 us @ 16 MHz.

With all the kernel addons, including extended\_ASM and SD\_Card driver, FastForth size is **10 kB**.

However, if all works well with Windows 10, it works less well with Linux due to the lack of a good alternative to TERATERM...

Note: for every update, download all subdirectories to correctly update the project, without missing configurations files.

## how to connect TERMINAL

    The files \binaries\launchpad_xMHz.txt are the executables ready to use with a serial terminal 
    (TERATERM.exe), 115200Bds, with XON/XOFF or RTS_hardware flow controls and a PL2303TA/CP2102 cable.
    ------------------------------------------------------------------------------------------
    WARNING! doesn't use it to supply your launchpad: red wire is 5V ==> MSP430FRxxxx destroyed!
    ------------------------------------------------------------------------------------------
    (modify this first: open the box and weld red wire on 3.3V pad).

### programming with MSP430Flasher/UniFlash and FET interface

     TI Launchpad <--> CP2102/PL2302TA cable <------> USB <-------------> TERATERM.exe 
               RX <--- TX            )
              GND <--> GND           > used by FastForth TERMINAL
               TX ---> RX            )
              RTS ---> CTS (optionnal) RTS pin Px.y is described in your \inc\launchpad.asm)
    
     TI Launchpad <--> FET interface  <-------------> USB <-------------> MSP430Flasher.exe/UniFlash
              Vcc <--- 3V3
       TST/SBWTCK <--> SBWTCK
              GND <--> GND
      RST/SBWTDIO <--> SBWTDIO

### programming with BSL_Scripter.exe

     MSP430FRxxxx <--> CP2102/PL2303TA cable <------> USB <-------->+<--> TERATERM.exe
               RX <--- TX   )                                       |
              GND <--> GND  > used by FastForth TERMINAL            +<--> BSL_Scripter.exe
               TX ---> RX   )
              Vcc <--- 3V3      )
       TST/SBWTCK <--- RTS      )
              GND <--> GND      > used by BSL_Scripter
      RST/SBWTDIO <--> DTR      ) 
    
    Before programming device, close teraterm TERMINAL and connect the wire RST/SBWTDIO <--> DTR 
    Once device is programmed, open teraterm TERMINAL then disconnect the wire RST/SBWTDIO <--> DTR.

## Out of the box

Once FastForth is loaded in the target FRAM memory, you add assembly code or FORTH code, or both,
by downloading your source files which embedded FastForth interprets and compiles.
    
Beforehand, the preprocessor GEMA, by means of a \config\gema\target.pat file, will have translated
your generic MSP430FR.f source file in a targeted MSP430FRxxxx.4th source file, allowing you to use
symbolic addressing for all peripheral registers (SFR), without having to do FORTH declarations.
A set of .bat files in \MSP430-FORTH folder is furnished to do all this automatically.
    
To see all specifications of FastForth, download \MSP430-FORTH\FF_SPECS.f.

To change the terminal baudrate on the fly, 9600 Bauds up to 6 MBds, download \MSP430-FORTH\CHNGBAUD.f.
Beyond 1 MBds, shorten the PL2303HXD cable, down to 50 cm for 6MBds.

XON/XOFF flow control allows 3.75kV galvanic isolation of terminal input with SOIC8 Si8622EC|ISO7021.
With powered SOIC16W ISOW7821, you have 5kV rms isolation for both XON/XOFF TERMINAL and a 3V3 75mA supply.

If you choose I2C_FastForth for your target, you will need of one more to make the USBtoI2C bridge.
See driver for I2C_FastForth:  \MSP430-FORTH\UARTI2CS.f.

After downloading of complementary words in \MSP430-FORTH\ANS_COMP.f, FastForth executes CORETEST.4th
in less than a second, and without errors which ensures its compatibility with the FORTH CORE ANS94 standard.

Notice that FAST FORTH interprets lines up to 84 chars, only SPACE as delimiter, only CR+LF as
End Of Line, and BACKSPACE. 
And that the high limit of a FORTH program memory is $FF80. 

Finally, using the SCITE editor as IDE, all is ready to do everything from its "tools" menu.

What is new ?
-------------

### V308

* 16 bytes removed from (Kernel + Conditional_Compilation + Assembler).
    
* Source file copy from TERMINAL to the SD\_Card of any I2C\_FastForth target works fine.
    
* The bootstrap call is modified: `' BOOT IS WARM` to enable it, `' BOOT [PFA] IS WARM` to remove it.

* ASM definitions are renamed HDNCODE (HiDdeN CODE), ENDASM is replaced by ENDCODE.

    HDNCODE definitions are identical to low level CODE ones, but are hidden because defined in the ASSEMBLER word set, and can be used only
    in the scope of another low level CODE definition. See use in \MSP430-FORTH\UARTI2CS.f.
    
* FastForth passes CORETEST + COREPLUSTEST tests. See modified \MSP430-FORTH\CORETEST.4TH

* Double number word D< corrected in \MSP430-FORTH\DOUBLE.f


### V307

* 54 bytes added to (Kernel + Conditional_Compilation + Assembler).

* ~~Source file copy from I2C_TERMINAL to the SD_Card of any I2C_target works now.~~
    
* In addition of target's ID test made by Teraterm macro, a preamble has been added to all
    \MSP430-FORTH\source.f files to prohibit their downloading with another version of FastForth.

* Words @ ! ALLOT come back from "ANS_COMP" add-on to core.

* Recognized prefixes are $ # % and ' respectively for hex decimal binary and ASCII 'char' numbers.  
    Examples: 'U' - $55 = 0, '3' - #33 = 0, '@' - %0100_0000 = 0.  
    When use in source.f files, all ASCII special chars are available. See \inc\FastForthREGtoTI.pat.

* Assembler allows "argument+offset" into FORTH area (0 to $FFFF). Examples:  
 `MOV #RXON,&SLEEP+2` to store RXON addr at SLEEP+2 addr.  
 `MOV.B BUFFER+-1(X),TOS` to load the byte at BUFFER-1(X) addr in the register TOS.
    
* COLD does same than hardware RST.  
  WIPE does same than hardware SW1+RST (DEEP_RESET).


* More complicated:

In the FastForth init process, COLD WARM SLEEP are modified and INI_FORTH is added.
They start each with an immediate call to a paired assembly subroutine:
      
          RST_SYS failures ->+       +<- ABORT_TERM <- ABORT" <-(error)<-+-<-COMPILE/EXECUTE<-INTERPRET<-+
                             |       |                                   |                               ^
                             |       v                                   v                               |
          SW1+RST->+<-RST    |       +--> INI_FORTH -> ABORT" ->+->QUIT>-+->ACCEPT->+         +->ACCEPT->+
                   |         |            ---------             ^                   |         ^
                   v         v                                  |                   v         |  
          WIPE --->+->COLD-->+--> PUC --> INI_FORTH --> WARM -->+                   +->SLEEP->+  
                      ----                ---------     ----                           -----  
      
    subroutine:       COLD_APP            INI_SOFT_APP  INI_HARD_APP                   BACKGND_APP
    default CALL#     COLD_TERM           RET_ADR       INIT_TERM                      RXON
    Default action:   wait TERMINAL idle  do nothing    init TERM UCAx                 enable TERMINAL TX
                                                        + unlock I/O's                 (send RXON + /RTS)

   
On the other hand, MARKER is modified in such a way that MARKER\_DOES executes a CALL to
the content of BODY+4,   by default RET_ADR:
    
    MARKER [CFA]    = DODOES
           [PFA]    = MARKER_DOES
           [BODY]   = previous DP (Dictionnary Pointer)
           [BODY+2] = previous VOCLINK (if word-set addon)
           [BODY+4] = RET_ADR

By replacing [BODY+4] with the address of a new defined subroutine (named for example: STOP_XXX), 
MARKER_DOES will execute it to restore all critical pointers saved at BODY+6, BODY+8...

Thus, with MARKER and the definition of subroutines COLD_XXX, INI_SOFT_XXX, INI_HARD_XXX, BACKGND_XXX 
the programmer has full control of his "XXX" real time application using interrupts, 
with everything he needs to start it, stop it, and also to properly remove it with
a 'soft' MARKER word, avoiding the use of a WIPE or a SW1+RST of the last chance. 

See examples in  /MSP430-FORTH/UARTI2CS.f,  /MSP430-FORTH/RTC.f.

notes:

* RST and SW1+RST (deep RST) are hardware redirected to COLD via NMI and the USER\_NMI vector. 
 
* INI\_SOFT\_SD is used as INI\_SOFT\_APP alias by the SD_CARD driver to reinit handles.  

* WIPE|SW1+RST initialises this four APP calls plus TERMINAL\_INT Vector.  



### V306

* 8 bytes added to (Kernel + Conditional_Compilation + Assembler).
    
* Fixed the crash caused by forgetting the prefix '&' in the last term of an assembly instruction.
    (the TI's symbolic mode is not implemented).
    
* Added in the macro \config\SendFile.ttl the word ?ID to prevent any crash during download
    due to a device confusion:

   when downloading a source_file.f asked from the scite editor or by the use
   of SendSourceFileToTarget.bat, Teraterm macro first sends ?ID definition then 
   the string:  %deviceID% ?ID.  
   By executing ?ID, FastForth substracts %deviceID% value from the target's one then 
   executes ABORT" DeviceID mismatch!" : the downloading is aborted if DeviceID mismatch.  
   %deviceID% is provided by the file \config\select.bat.

   When downloading a source_file.4TH, it's up to you to be careful because 
   Teraterm sends the string 0 ?ID, so that ?ID bypasses the substraction.   
    
* Added the word set DOUBLE in the \MSP430-FORTH\DOUBLE.f file.

### V305

    48 bytes removed.
    
    from Scite menu, we can program MSP430FRxxxx also with BSL_Scripter.
    
    To do, save file \prog\BSL_Scripter.exe from: 
    https://github.com/drcrane/bslscripter-vs2017/releases/download/v3.4.2/BSL-Scripter-v3.4.2.zip,
    but erasing a MSP430FR2355 or MSP430FR2476 doesn't work, thanks to BSL V. 00.09.36.B4 & B5.
    See SLAU550Z tables 16 & 17.
    
    and buy a USB2UART module CP2102 6 pin. On the web, search: "CP2102 3.3V DTR RTS" 
    For wiring, see \config\BSL_Prog.bat.
    
    So, we download both binaries and source files with only one CP2102|PL2303TA module,
    the XON/XOFF TERMINAL and BSL_Scripter. Bye bye T.I. FET!
    
    ABORT messages display first the I2C address, if applicable.
    QNUMBER some issues solved.
    UART version of ACCEPT and KEY are shortened.
    EVALUATE is moved to CORE_ANS.

### V304

    36 bytes removed.
    
    Fixed: word F. issue in FIXPOINT.asm
    
    the new kernel DEFERRED option adds :NONAME CODENNM DEFER IS.
    
    pin RESET is software replaced by pin NMI and so, RESET executes COLD, allowing code insert before BOR.
    however SYSRSTIV numbering remains unchanged: = 4 for RESET, = 6 for COLD.
    
    Hardware Deep RESET (S1+RST) reinitializes vectors interrupts and SIGNATURES area, as WIPE.
    
    
    A newcomer: FastForth for I2C TERMINAL. With the driver UART2I2CS running on another FastForth target,
                we have the USB to I2C_Slave bridge we need: one TERMINAL for up to 112 I2C_FastForth targets.

                                                                                    +---------------------------+
      notebook                     USB to I2C_Slave bridge                    +-I2C-| others I2C_slave target   |
    +-----------+      +-------------------------------------------------+   /    +--------------------------+  |
    |           |      ¦ PL2303HXD         target running UARTI2CS @24MHz¦  +-I2C-|  MSP430FR4133 @ 1 MHz    |  |
    |           |      ¦------------+       +----------------------------¦ /   +--------------------------+  |--+
    |           |      ¦            | 3wires|   MSP430FR2355 @ 24MHz     ¦/    |   MSP430FR5738 @ 24 MHz  |  |
    | TERATERM -o->USB-o->USB2UART->o->UART-o-> FAST FORTH -> UARTI2CS  -o-I2C-o-> FAST FORTH with option |--+
    | terminal  |      ¦            | 6MBds |               (I2C MASTER) ¦     |  TERMINAL_I2C (I2C SLAVE)| 
    |           |      ¦------------+       +----------------------------¦     +--------------------------+
    |           |      ¦            |< 20cm>|                            ¦       up to 112 I2C_Slave targets  
    +-----------+      +-------------------------------------------------+

    With the indicated MCLK and UART speed, Coretest.4th is downloaded to (and executed by) I2C_Slave in 800ms.
    The driver UARTI2CS works without error from 1MHz to 24MHz MCLK and from 115200Bds up to 6MBds UART.
    With I2C_Master running at 24 MHz, the I2C bus frequency is about 1MHz, and it works fine even if I2C_slave is running at 1 MHz.
    Don't forget to add two 3k3 pullup resistors on SCL and SDA...

    the Multi Master Mode works but is not tested in multi master environment.
    
    "cerise sur le gâteau": when they wait for a TERMINAL input (idle state), 
    both I2C_Master and I2C_Slave(s) are sleeping in LPMx mode and the bus I2C is freed. 
    LPM4 mode is available for I2C_Slave devices.
    
    The driver UART2I2CS doesn't use the UCBx I2C_Master hardware, really too bad, but
    profitably its software version, much more faster, which consumes just two I/O (better in the range Px0-Px3),
    the UCBx remaining available for another I2C_Slave or SPI driver.
    

##### HOW TO DO ?

    first you make a I2C cable (GND,SDA,SCL,3V3) between your 2 LaunchPad, with 3,3k pullup resistors on SDA and SCL lines.
    see each of two /inc/target.pat files to know SDA ans SCL pins.
    
    to compile FastForth for I2C TERMINAL from forthMSP430FR.asm file:
    1-  uncomment the line "TERMINAL_I2C".
    2-  search "I2CSLAVEADR" line and set your <slave address you want>, i.e. 10h.
    3-  compile file then prog your I2C_Slave LaunchPad.
    
    with the another LaunchPad running FastForth:
    At the end of UART2I2CS.f file set the <slave address you want>, i.e. $10.
    then download it, it's done: TERMINAL is linked to I2C_Slave.
    
    Type `Alt+B` on teraterm (send UART break) to unlink I2C_Slave.

### V302

    646 bytes removed
    Kernel + FIXPOINT input + DOUBLE input + Conditional Compilation + Assembler under 5 kB.
    
    the FORTH kernel is drastically reduced to 55 words.
    All others are moved in the \ADDON\ANS_COMPLEMENT.asm file, 
    the conditionnal compilation with the assembler allowing to reuse them on request.
    
    Fixed:  QNUMBER, 
            ACCEPT (XON/XOFF TERMINAL with MSP430FR2xxx).
    Modified: [ELSE].
    
    FF_SPECS.f displays FastForth environment.

### V301

    584 bytes removed, Kernel + Conditional Compilation + Assembler under 5.5 kb.
    
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

### V300

    4 bytes removed.
    The prompt "ok" becomes a compilation option.
    
    Taking into account the digit separator '_' in ?NUMBER, to better see when typing binary numbers.
        example: %1010100011000111 can be typed as well: %1010_1000_1100_0111
    
    Corrected >NUMBER
    
    Modified GetFreeHandle CloseHandle
    
    Tested with BLE 5.0 terminal (a couple of BGX13P EVK) at 16MHz, 921600 bds + terminal 5 wires: 
        download throughput = 5 kbytes/s (and with errors when ECHO is ON), disappointing...
        (Bluetooth 2.1 terminal with one RN42 works well).
    
    RePeaTed instructions RRUX,RRCX,RLAX,ADDX,SUBX work fine! See TESTASMX.4TH


### PREVIOUS versions
    
Unlocking I/O's is transfered from RESET to WARM.
Thus, by redirecting WARM, you can add I/O's configuration of your application before unlock them.


The structure of primary DEFERred words as KEY,EMIT,CR,WARM... is modified,
the address of their default execute part, without name, can be found with:
 `' <name> >BODY`

example, after this entry: `' DROP IS KEY` KEY runs DROP i.e. runs the redirection
made by IS,  
but `' KEY >BODY EXECUTE` runs KEY, the default action at the BODY address.

and: `' KEY >BODY IS KEY`
restore the default action of this **primary** DEFERred word.


WARNING! you cannot do that with words created by DEFER which creates only **secondary** DEFERred words, without BODY !

to build a **primary** DEFERred FORTH word, you must create a DEFERred word followed by a
:NONAME definition:

    DEFER truc
    :NONAME         \ does nothing (for the example)
        DUP
        DROP
    ; IS truc       \
    
The advantage of creating primary DEFERred words is to set their
default state, enabling to reinitialize them easily.

CODENNM is the low level equivalent of :NONAME

to build the primary DEFERred low level definition "machin" :
             -------

    DEFER machin

    CODENNM
        NOP2        \ assembly instruction
        NOP3        \ assembly instruction
        MOV @IP+,PC \ mandatory before ENDCODE
    ENDCODE IS machin

you can obviously mix LOW/HIGH levels in CODENNM and :NONAME

All interpretation/compilation errors now execute PWR_STATE, so any incorrect definition
and all its source file will be automatically erased.
    

Accept SD_Card from 64 MB (FAT16) up to 64 GB (FAT32).  
Note that Windows 10 no longer offers the FAT32 format for the highest sizes of SD_CARD memory.
So you must use an alternative to do, for example: https://www.partitionwizard.com.


Added direct file transfer from PC to the target SD_CARD.  
Measured throughput with "HCI" SD CARD: 90 kbytes/s at 3Mbauds TERMINAL and 16MHz MCLK.
You can do it from scite editor (menu Tools) or by using specific bat file.
Double click on it to see how to do.

JTAG and BSL signatures (FF80h-FF88h) are protected against overwrite during source file download. 


## Many thanks to Brad Rodriguez

for his CamelForth which served me as a kind of canvas.
And also to Matthias Koch for its ideas about Q15.16 implementation.

Unlike CamelForth FASTFORTH is a "Direct Threaded Code", with an embedded assembler following the standard syntax,
not the one used in the world Forth.

Its core is fully compliant with the standard ANS.

It is optimized for the speed, especially in the interpreter mode, so that you can load an application program written in FORTH/Assembler faster than its binary via MSP430 Flasher.exe.
Everything can be done from your text editor, the preprocessor and a serial terminal.

## What's this and why?

I have first programmed atmel tiny devices.
Particularly I2C master driver to have both I2C slave and I2C master on a ATtiny461.
which means a lot of back and forth between the editor, assembler, the programmer and the test in situ.

Previously I had programmed a FORTH on a Motorola 6809 and had been seduced by the possibility of sending a source file directly to the target using a serial terminal. Target which compiled and executed the program. At the time FORTH program lay in a battery backed RAM.

The advent of chip MSP430 TEXAS INSTRUMENT with embedded FRAM gave me the idea to do it again : FAST FORTH was born.

Today I dropped the ATMEL chips and proprietary interfaces, I program my applications in a mix 80%/20% of assembler/FORTH I then sent on MSP430FR5738 chips with embedded FAST FORTH.

And that's the magic: After I finished editing (or modify) the source file, I press the "send" button in my text editor and I can test result on target in the second following. This is the whole point of an IDE reduced to its simplest form: a text editor, a cable, a target.


## build your FastForth local copy

download https://framagit.org/Jean-Mi/FAST-FORTH/tree/master
Once you have unzipped it into your folder, share it - with you - and notice its network path.
Then right clic on the root of your notepad to create a network drive by recopying this network path (change backslashes \ to / ); then set drive letter as you want.

In explorer you should obtain this back your driver letter:


    \ForthMSP430FR.asm                main FASTFORTH program
    \ForthMSP430FR_ASM.asm            assembler
    \ForthMSP430FR_EXTD_ASM.asm       extended assembler 
    \ForthMSP430FR_CONDCOMP.asm       conditionnal compilation
    \ForthMSP430FR_SD_ACCEPT.asm      ACCEPT for SD_Card
    \ForthMSP430FR_SD_INIT.asm        init SD_CARD (FAT16/32)
    \ForthMSP430FR_SD_LOAD.asm        load source files from SD_CARD
    \ForthMSP430FR_SD_LowLevel.asm    SPI routines + Read / write sector 
    \ForthMSP430FR_SD_RW.asm          read create write del SD_CARD files + file copy to SD_CARD
    \ForthMSP430FR_TERM_I2C.asm       I2C terminal
    \ForthMSP430FR_TERM_UART.asm      full duplex UART terminal
    \ForthMSP430FR_TERM_UART_HALF.asm half duplex UART terminal
    \SciTEDirectories.properties      copy of \config\scite\AS_MSP430\SciTEDirectories.properties

    \ADD-ON\                          FASTFORTH OPTIONAL KERNEL ADD-ON (not erasable version)
           \CORE_ANS.asm              set of complementary words to pass CORETEST.4TH
           \FIXPOINT.asm              adds HOLDS F+ F- F* F/ F#S F. S>F
           \SD_TOOLS.asm              adds some trivial words to display sectors content
           \UTILITY.asm               adds WORDS, DUMP, ? .S .RS
    
    \binaries\files.txt              ready for drag'n drop to prog.bat
             \prog(.bat)             to do what ?...
   
    \config\
           \asm.properties                     configuration for *.inc,*.asm files
           \forth.properties                   configuration for *.f,*.4th files
           \fortran.properties                 configuration for *.pat files
           \SendFile.ttl                       TERATERM macro file to send source file to FASTFORTH
           \SendToSD.ttl                       TERATERM macro file to send source file to embedded SD_CARD 
           \build(.bat)                        called by scite to build target.txt program 
           \BSL_prog(.bat)                     to flash target with target.txt file with BSL_Scripter
           \FET_prog(.bat)                     to flash target with target.txt file with MSP430Flasher
           \CopyTo_SD_Card(.bat)               to copy in your MSP430-FORTH
           \SendSource(.bat)                   to send file to FASTFORTH
           \Preprocess(.bat)                   to convert generic .f file to specific .4th file
           \CopySourceFileToTarget_SD_Card.bat copy it in any user folder for drag'n drop use
           \SendSourceFileToTarget.bat         copy it in any user folder for drag'n drop use
           \PreprocessSourceFile.bat           copy it in any user folder for drag'n drop use
           \SelectTarget.bat                   called to select target, device and deviceID
    
    \inc\                         MACRO ASsembler files.inc, files.asm, GEMA preprocessor files.pat
        \MSP430FRxxxx.inc         device configuration for AS assembler
        \MSP430FRxxxx.asm         device init code for AS assembler 
        \MSP_EXP430FRxxxx.asm     target configuration for AS assembler
        \FastForthREGtoTI.pat     converts FORTH symbolic registers names to TI Rx registers
        \tiREGtoFastForth.pat     converts TI Rx registers to FORTH symbolic registers names 
        \MSP430FRxxxx.pat         device configuration for gema preprocessor
        \MSP_EXP430FRxxxx.pat     target configuration for gema preprocessor
        \ThingsInFirst.inc        general pre configuration for AS assembler
        \ThingsInLast.inc         general post configuration for AS assembler

    \prog\        SciTEGlobal.properties, TERATERM.INI + programs.url
        
### FORTH generic_source_files.f and targeted_source_files.4th

    \MSP430-FORTH\
                 \PreprocessSourceFile.bat            (link)
                 \SendSourceFileToTarget.bat          (link)
                 \CopySourceFileToTarget_SD_Card.bat  (link)
                 \*.f            source files which must be preprocessed before downloading  
                 \*.4th          source files ready to download to any target
                 \LAST.4TH       last source target file issued by preprocessor
                 \BOOT.f         performs bootstrap
                 \CHNGBAUD.f     allows you to change terminal baudrate
                 \CORE_ANS.f     same as CORE_ANS.asm, (but erasable) 
                 \CORETEST.4TH   ANS core tests 
                 \CORDIC.f       for afficionados 
                 \DOUBLE.f       adds DOUBLE word set
                 \FIXPOINT.f     same as FIXPOINT.asm, (but erasable)
                 \FF_SPECS.f     shows all specificities of FAST-FORTH compiled on your target 
                 \RTC.f          set date and time, one example of MARKER use.
                 \RC5toLCD.f     multitasking example 
                 \SD_test.f      tests for SD_CARD driver
                 \SD_TOOLS.f     same as SD_TOOLS.asm, (but erasable)
                 \TESTASM.f      some tests for embedded assembler
                 \TESTXASM.f     some tests for embedded extended assembler
                 \UARTI2CS.f     I2C_Master driver to link TERMINAL UART with any I2CSlave target
                 \UTILITY.f      same as UTILITY.asm, (but erasable)
    

Note: all actions (flashing target, download files) can be made by using bat files directly,.
The next is to download IDE (WINDOWS):

## First get TI's programs

[MSP430-FLASHER](https://www.ti.com/tool/MSP430-FLASHER), [MSP430_FET_Drivers](http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSP430_FET_Drivers/latest/index_FDS.html)

install in the suggested directory, then copy MSP430Flasher.exe and MSP430.dll to \prog\

## download IDE

* [modified BSL-Scripter.zip](https://github.com/drcrane/bslscripter-vs2017/releases) and unzip as \prog\BSL-Scriper.exe

* [teraterm](https://osdn.net/projects/ttssh2/releases/)

* [GEMA general purpose preprocessor](https://sourceforge.net/projects/gema/files/latest/download), unzip in drive:\prog\

* [sCiTE single file executable](https://www.scintilla.org/SciTEDownload.html) to drive:\prog\, then rename Scxxx.exe to scite.exe

* [Macro AS](http://john.ccac.rwth-aachen.de:8000/ftp/as/precompiled/i386-unknown-win32/aswcurr.zip), unzip in drive:\prog\  

* [srecord](https://sourceforge.net/projects/srecord/files/srecord-win32/1.64/), unzip in drive:\prog\  


In explorer you should obtain that (minimum requested programs):


    \prog\as.msg
         \asw.exe
         \BSL-Scripter.exe
         \cmdarg.msg
         \gema.exe
         \ioerrs.msg
         \MSP430.dll
         \MSP430Flasher.exe
         \P2hex.exe	
         \P2hex.msg
         \srec_cat.exe
         \sCiTE.exe
         \SciTEGlobal.properties
         \tools.msg
    

Next we need to change the drive letter in hard links below:

    \binaries\prog.bat
    \MSP430-FORTH\SendSourceFileToTarget.bat
                 \CopySourceFileToTarget_SD_Card.bat
                 \PreprocessSourceFile.bat

to do, right clic on them
     select "properties"
            set your drive letter in "target"

The last step is ask Windows to associate scite editor with file types:

right clic on a .asm file, 
    select "open with", 
            select "other application" then select: drive:\prog\scite.exe

repeat for .inc, .lst, .f, .4th, .pat, .properties, .TTL files.


IT's done ! See  forthMSP430FRxxxx.asm to configure TeraTerm


## Build the program file

\forthMSP430FR.asm is the main file to compile FastForth:    

* Open forthMSP430FR.asm with scite editor

* uncomment the target as you want, i.e. MSP_EXP430FR5969

* choose frequency, baudrate, flow control.

* comment / uncomment options switches as your convenience.

* save file.

* assemble (CTRL+0). A window asks you for 4 parameters:

* set target as first param, i.e. MSP_EXP430FR5969

* then execute. the output will be \binaries\MSP_EXP430FR5969.txt

## Load Txt file (TI format) to target

    in \binaries folder, drag your target.txt file and drop it on prog.bat
    
    or use scite internal command TOOLS: FET prog (CTRL+1).

nota : programming the device use SBW2 interface, so UARTn is free for serial terminal connexion.

If you want to program your own MSP430FRxxxx board, wire its pins TST, RST, 3V3 and GND 
to same pins of the launchpad, on eZ-FET side of the programming connector.

## Connect the FAST FORTH target to a serial terminal

you will need an USBtoUART cable with a PL2303TA or PL2303HXD device that allows both XON/XOFF 
and hardware control flow :

[PL2303HXD 3.3V](http://www.google.com/search?q=PL2303HXD+3.3V+cable)
[PL2303 driver](http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=225&pcid=41)

WARNING! always verify VCC PIN = 3.3V before use to supply your target with.

or with a CP2102 device and 3.3V/5V that allows XON/XOFF control flow up to 921600 Bds:

[CP2102 3.3V](https://www.google.com/search?q=cp2102+3.3V+6PIN)
[CP2102 driver](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers)

WARNING! always verify VCC PIN = 3.3V before use to supply your target with.


## Send a source file.f or file.4th to the FAST FORH target

Three bat files are done in \MSP430-FORTH that enable you to do all you want.
drag and drop your source file on to.
you can also open any source file with scite editor, and do all you want via its Tools menu.

If you have any downloading error, first verify in "LAST.4th" that all lines are 
correctly ended with CR+LF.

## SD_Card driver

#### First, hardware

If you have MSP-EXP430FR5994, nothing to do.

For the choice of a SD card socket be carefull, pin CD (Card Detect) must be present! 
google search: "micro SD card 9 pin"
Look for the good wiring in /Launchpad.asm file

#### Compile with SD_Card addon

in forthMSP430FR.asm, uncomment lines SD_CARD_LOADER,  SD_CARD_READ_WRITE, SD_TOOLS 
then compile for your target

### the commands

With the LOAD" pathame" command FastForth loads source files from a SD_CARD memory.

See "SD_TESTS.f", a FORTH program done for example

If you remove the SD memory card reader and then reset, all SD\_IO pins are available except SD_CD.  
Drive letters are always ignored.  

    LOAD" path\filename.4th".

The file is interpreted by FORTH in same manner than from the serial terminal.  
When EOF is reached, the file is automatically closed.  
A source file can LOAD" another source file, and so on in the limit of 8 handles. 

LOAD" may be used as Change Directory command: 

    LOAD" \misc".       \misc becomes the current folder.
    LOAD" ..\"          parent folder becomes the current folder.
    LOAD" \"            Root becomes the current folder.


     READ" path\filename.ext".  

The first sector of this file is loaded in BUFFER.
To read next sectors, use the command READ that loads the next sector in the buffer, 
and leaves on the stack a flag that is true when the EOF is reached. 
The file is automatically closed. See tstwords.4th for basic usage.

The variable BufferLen keep the count of bytes to be read (0 to 512).

If you want to anticipate the end, use the CLOSE command.

    WRITE" path\filename.ext".

If the file does not exist, create it, else open it and set the write pointer at the end of the file, 
ready to append chars.

See example of use in \MSP430-FORTH\SD_TEST.f.

To overwrite an existing file: DEL" file" then  WRITE" file".

Use CLOSE to close the file.


    DEL" path\filename.ext". If the file is not found, do nothing, no error.


#### Copy source file to SD_Card

to copy a source file (.f or.4th) to SD_CARD target, use CopySourceFileToTarget\_SD\_Card.bat.
Double click on one of this bat files to see how to do.

or use scite.

If you have any copy error, first verify in "LAST.4th" that all lines are 
correctly ended with CR+LF.

## The system is not responding ?

First, remove the USBtoUART bridge then reconnect it. Perhaps it was in suspend state...

If the system is always freezed, press <reset> button on the MSP-EXP430FR5xxx ; FORTH restarts 
as it was after the last RST_HERE command.

If the system does not restart again, press `SW1+RESET`. 
FORTH restarts in the state it is in its object txt file.

Here is the FastForth memory management, one of its major assets :

    case 1 : when you type `PWR_STATE` the program beyond PWR_HERE marker is lost.

    case 1.1 : when you type `WARM`, FORTH interpreter is restarted, the program beyond PWR_HERE is lost. 
               The WARM display starts with "#0". 
    
    case 1.2 : Power ON performs a reset and the program beyond PWR_HERE is lost.
               the WARM display starts with the SYSRSTIV value "#2".
    
    case 1.3 : SVSHIFG SVSH event, same effects,
               the WARM display starts with the SYSRSTIV decimal value "#14".

    
    case 2 : when you type `RST_STATE` the program beyond RST_HERE marker is lost.

    case 2.1 : <RESET> performs reset and the program beyond RST_HERE is lost,
               the WARM display starts with the SYSRSTIV value "#4".
    
    case 2.2 : when you type `COLD` (software reset), same effects,
               the WARM display starts with the SYSRSTIV value "#6".
    
    case 2.3 : PUC on failure, same effects,
               The WARM display starts with the SYSRSTIV decimal value.

    
    case 3 : when you type `WIPE` (software Deep Reset) 
            * all programs donwloaded from the terminal or the SD_Card are lost,
            * the default state of COLD_APP, INI_SOFT_APP, INI_HARD_APP and BACKGND_APP are restored,
            * all "defered" words are initialised with their default value,
            * same thing for interrupts vectors, 
            * and SIGNATURES area is cleared (FFh).
             The WARM display starts with #-1.

    case 3.1 : <SW1+RESET> performs hardware deep reset, same effects. 
               The WARM display starts with #-1.
    
    case 3.2 : after compiling new FastForth, same effects obviously!
               The WARM display starts with #-3.


    case 4 : FastForth keeps the memory of all resident definitions. During source file download the
             conditionnal compilation allows to compile only non-resident definitions.

    case 4.1 : Running a "MARKER" definition will delete anything compiled beyond that.
               By starting a source file with this "MARKER" tag, the memory is first cleared of
               all the contents of that source file each time it is reloaded.



As all other words FORTH, PWR_STATE PWR_HERE RST_STATE RST_HERE and MARKER defn. may be also used in definitions.    

If you have previously set 'NOECHO', there is no WARM display.

With I2C_FastForth, WARM display is preceded by the I2C slave address, example; `@18`. 

If an error occurs from the interpreter, FORTH is restarted, the error is always displayed and the program beyond PWR_HERE is lost. 

In this way, any error is followed by the complete erasure of a bad definined word causing this error, 
or by that of the downloaded source file including it. 

It is therefore recommended to end a source file with at least 'PWR_HERE' to protect it
from any subsequent error.


## VOCABULARY ADD-ON

These words are not ANS94 compliant, they are those of F83 standard.

For example, after loading SD_TOOLS add-on, you can type: ALSO ASSEMBLER WORDS PREVIOUS WORDS

    With `ALSO ASSEMBLER`, the vocabulary ASSEMBLER is added to the search CONTEXT thus the ASSEMBLER words
    become visible,
    
    WORDS display the words of ASSEMBLER then those of FORTH,
    
    PREVIOUS remove the vocabulary ASSEMBLER form the CONTEXT, and the ASSEMBLER words become hidden,
    
    so the last WORDS display only FORTH words.

In the forthMSP430FR_ASM.asm, see the FORTH word CODE that add ASSEMBLER to the search CONTEXT and the ASSEMBLER word ENDCODE
 that remove ASSEMBLER from search CONTEXT. Thus, the assembler words can be used only between CODE and ENDCODE.

The CONTEXT can grow up to 6 vocabularies by using the word ALSO.

If you want add words to the assembler you must type: ALSO ASSEMBLER DEFINITIONS,
The vocabulary ASSEMBLER is added to the search CONTEXT as previously but also becomes the CURRENT vocabulary in which the new words will be stored.

Finally, `FORTH ONLY DEFINITIONS` limits the search CONTEXT to FORTH and the CURRENT vocabulary is FORTH. 

**WARNING !** it is discouraged to execute any definition included in the assembler word-set.

## EMBEDDED ASSEMBLER

The preprocessor GEMA allows the embedded assembler to access all system variables. 
See files \\inc\\Target.pat. 

### HOW TO MIX assembly and FORTH ?

FAST FORTH knows three kinds of definitions :

* high level FORTH definitions : <name> ... ;

* low level definitions CODE <name> ... ENDCODE

* low level hidden definitions HDNCODE <name> ... ENDCODE
    they are hidden because not FORTH executable.
    
Examples:
    
    : NOOP              \ FORTH definiton "NOOP", do nothing
        DUP
        DROP
    ;


    CODE ADD            \ low level definition "ADD", alias of word +
        ADD @PSP+,TOS
        MOV @IP+,PC
    ENDCODE


    HDNCODE WDT_INT     \ low level hidden definition "WDT_INT" (Watchdog interrupt)
    BIT #8,&TERM_STATW  \ break (ALT+b) sent by TERMINAL ?
    0<> IF              \ if yes
        MOV #ABORT,PC   \   continue with ABORT (no return)
    THEN
                        \ else return to background task SLEEP
    MOV @RSP+,SR        \ restore SR flags
    BIC #%1111_1000,SR  \ but force CPU Active Mode
    RET                 \ (instead of RETI)
    ENDCODE
    
    
A the end of low level CODE definition, the instruction MOV @IP+,PC jumps to the next definition. 
This faster (4 cycles) and shorter (one word) instruction replaces the famous pair of assembly 
instructions : CALL #LABEL ... RET (4+4 cycles, 2+1 words). The register IP is the Interpretative Pointer. 

High level FORTH definitions starts with a boot code "DOCOL" that save the IP pointer, reload it with the first address
of a list of execution addresses, then performs a postincrement branch to this first address. 
The list ends with the address of another piece of code: EXIT (6 cycles) that restores IP before the instruction MOV @IP+,PC.

here, the compilation of low level ADD definition :

                    header          \ compiled by the word CODE
    execution addr  ADD @PSP+,TOS
                    MOV @IP+,PC     \ instruction called NEXT

and the one of the high level word NOOP :

                    header          \ compiled by the word :
    execution addr  CALL rDOCOL     \ boot code "DOCOL" compiled by the word :
                    addr of DUP     \ execution addr of DUP
                    addr of DROP    \ execution addr of DROP
                    addr of EXIT    \ execution addr of EXIT compiled by the word ;

_A high level FORTH word is a list of execution addresses preceded by a boot code and ending with EXIT address._

### WRITING RULES

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
            MOV @IP+,PC         \ goto NEXT
        ENDCODE                 \ end of low level word, compile nothing

If we see the code "MIX\_FORTH\_ASM" after compilation :

            header              \ compiled by :
    exec@   CALL rDOCOL         \ boot code "DOCOL" (which saves IP onto stack) compiled by :
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
        ;                       \ end of high level word, compile EXIT

If we see this code "MIX\_ASM\_FORTH" after compilation :

            header              \ compiled by CODE
    exec@   asm1
            asm2
            CALL rDOCOL         \ "DOCOL" compiled by COLON
            addr of word1
            addr of word2
            addr of EXIT        \ EXIT restores IP from stack then executes MOV @IP+,PC

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
    exec@   CALL rDOCOL         \ "DOCOL" boot code compiled by :
            addr of word1
            addr of word2
            ...
            next addr           \ compiled by HI2LO
            MOV #0,IP           \ IP is free for use
            asm1                \ assembly instruction
            ...
            CALL #EXIT          \ compiled by LO2HI
            addr of word3
            addr of word4
            addr of EXIT        \ compiled by ;

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
        COLON                   \ switch to start FORTH word (COLON saves IP)
            word
            ... 
        HI2LO                   \ FORTH to assembler switch
            asm3
            asm4
            MOV @RSP+,IP        \ restore IP
            MOV @IP+,PC         \ goto NEXT
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
            CALL rDOCOL         \ "DOCOL" compiled by COLON
            addr
            addr
            next address        \ compiled by HI2LO
            asm
            asm
            CALL #EXIT          \ compiled by LO2HI
            addr
            addr
            EXIT addr           \ that restores IP from return stack and then executes MOV @IP+,PC


### ASSEMBLER WITHOUT LABELS ? YES !

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

you can MIX conditional branches with a mix of FORTH/assembly: see TEST5 in the demo file \MSP430-FORTH\TESTASM.4TH


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

### SYMBOLIC ASSEMBLER ? YES !

I have discovered a little semantic preprocessor "GEMA", just like that FAST FORTH have its symbolic assembler !

* \inc\DEVICE.pat contains memory map and vectors for a specified DEVICE
* \inc\LAUNCHPAD.pat is the I/O config file for specific LAUNCHPAD (or application)

Gema translates FORTH registers in ASM registers (R0 to R15) via \inc\ThingsInFirst.pat

With the three bat files in \MSP430_FORTH folder all is done automatically.

# COMPILE FAST FORTH FOR YOUR TARGET

1- in forthMSP430FR.asm "TARGET configuration"  create a line for your target, example:

    ;MY_MSP430FR5738_1 ; compile for my own MSP430FR5738 miniboard V1

2- create your \inc\MSP430FR5738_1.asm and \inc\MSP430FR5738.inc from another target.asm and device.inc as pattern, 
Notice that you must define here only the necessary for FAST-FORTH compilation.

3- in \inc\ThingsInFirst.inc add one "device.inc" item:

        .IFDEF MY_MSP430FR5738_1
    UCA0_UART   ; defines uart used by FORTH input terminal 
    LF_XTAL     ; defines if your module have a 32768 Hz xtal, to enable it.
    UCB0_SD     ; defines UC used for SD Card driver if any
        .include "MSP430FR5738.inc"  ; include device declarations
        .ENDIF

4- in \inc\TargetInit.asm add one "target.asm" item: 

        .IFDEF MY_MSP430FR5738_1
            .include MY_MSP430FR5738_1.asm
        .ENDIF

Then, for the preprocessor which you will use when downloading FORTH source files:

1- create your \inc\device.pat file if not exist, from your \inc\device.inc and/or another \inc\device.pat as pattern.

2- create your \inc\target.pat file from your \inc\target.asm and/or another \inc\target.pat as pattern.

Best practice, I suggest you that all digital pins you define (input or output) in your projects have their idle state high, with external pull up resistor
that is the reset state of FastForth...


# ANNEXES

Here you have a good view of MSP430 assembly:
[MSP430 ISA](http://www.ece.utep.edu/courses/web3376/Notes_files/ee3376-isa.pdf)

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
If you use them you may either PUSHM #4,M before and POPM #4,M after,
or use then restore FastForth default values:
xdocol, xdovar, xdocon, xdodoes. See device.pat.

When you use these registers you can't call any FORTH words created by them at the same time! 

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

to push one cell on the RSP stack : `PUSH <what you want>`

to pop one cell from the RSP stack : `MOV @RSP+,<where you want>`

don't never pop a byte with instruction `MOV.B @RSP+, ...`


to push multiple registers on the RSP stack :

    PUSHM #n,Rx                 \  with 0 <= x-(n-1) < 16

to pop multiple registers from the RSP stack :

    POPM #n,Rx                  \  with 0 <= x-(n-1) < 16

    PUSHM order : PSP,TOS, IP, S , T , W , X , Y ,rDOVAR,rDOCON,rDODOES,rDOCOL, R3, SR,RSP, PC
    PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5   ,  R4  , R3, R2, R1, R0

example : `PUSHM #6,IP` pushes `IP,S,T,W,X,Y` registers to return stack

    POPM  order :  PC,RSP, SR, R3,rDOCOL,rDODOES,rDOCON,rDOVAR, Y , X , W , T , S , IP,TOS,PSP
    POPM  order :  R0, R1, R2, R3,  R4  ,  R5   ,  R6  ,   R7 , R8, R9,R10,R11,R12,R13,R14,R15

example : `POPM #6,IP` pulls `Y,X,W,T,S,IP` registers from return stack

Error occurs if `#n` is out of bounds.

**conditionnal jumps use**

    0=    with IF UNTIL WHILE ?GOTO
    0<>   with IF UNTIL WHILE ?GOTO   
    U>=   with IF UNTIL WHILE ?GOTO   
    U<    with IF UNTIL WHILE ?GOTO    
    S<    with IF UNTIL WHILE ?GOTO    
    S>=   with IF UNTIL WHILE ?GOTO   
    0>=   with IF UNTIL WHILE
    0<    with ?GOTO 


# FAST FORTH resumed


    RETURN-STACK-CELLS  = 48            maximum size of the return stack, in cells  
    STACK-CELLS         = 48            maximum size of the data stack, in cells  
    /COUNTED-STRING	 = 255           maximum size of a counted string, in characters  
    /HOLD	           = 34            size of the pictured numeric output string buffer, in characters  
    /PAD	            = 84            size of the scratch area pointed to by PAD, in characters  
    ADDRESS-UNIT-BITS   = 16            size of one address unit, in bits  
    FLOORED	         = true          true if floored division is the default  
    MAX-CHAR	        = 255           maximum value of any character in the implementation-defined character set  
    MAX-N               = 32767         largest usable signed integer  
    MAX-U               = 65535         largest usable unsigned integer  
    MAX-D	           = 2147483647    largest usable signed double number  
    MAX-UD              = 4294967295    largest usable unsigned double number  
    DeFiNiTiOnS aRe CaSe-InSeNsItIvE    Strings are case-sensitive


## FORTH word-set

It is reduced to a minimum, but nevertheless extensible up to ... $FF80 !

    RST_HERE        PWR_HERE        RST_STATE       PWR_STATE       CREATE          ;               :               IMMEDIATE       
    POSTPONE        ]               [               \               '               [']             ABORT"          INTERPRET       
    COUNT           LITERAL         ALLOT           ,               >NUMBER         FIND            WORD            ."              
    S"              .               U.              SIGN            HOLD            #>              #S              #               
    <#              !               @               CR              TYPE            NOECHO          ECHO            EMIT            
    KEY             ACCEPT          COLD            WARM            WIPE            

[CREATE     ](https://forth-standard.org/standard/core/CREATE)
[;          ](https://forth-standard.org/standard/core/Semi)
[:          ](https://forth-standard.org/standard/core/Colon)
[IMMEDIATE  ](https://forth-standard.org/standard/core/IMMEDIATE)
[POSTPONE   ](https://forth-standard.org/standard/core/POSTPONE)
[\]         ](https://forth-standard.org/standard/core/right-bracket)
[\[         ](https://forth-standard.org/standard/core/Bracket)
[\\         ](https://forth-standard.org/standard/block/bs)
[\[\'\]     ](https://forth-standard.org/standard/core/BracketTick)
[\'         ](https://forth-standard.org/standard/core/Tick)
[ABORT"     ](https://forth-standard.org/standard/core/ABORTq)
[COUNT      ](https://forth-standard.org/standard/core/COUNT)
[LITERAL    ](https://forth-standard.org/standard/core/LITERAL)
[ALLOT      ](https://forth-standard.org/standard/core/ALLOT)
[,          ](https://forth-standard.org/standard/core/Comma)
[>NUMBER    ](https://forth-standard.org/standard/core/toNUMBER)
[FIND       ](https://forth-standard.org/standard/core/FIND)
[WORD       ](https://forth-standard.org/standard/core/WORD)
[."         ](https://forth-standard.org/standard/core/Dotq)
[S"         ](https://forth-standard.org/standard/core/Sq)
[.          ](https://forth-standard.org/standard/core/d)
[U.         ](https://forth-standard.org/standard/core/Ud)
[SIGN       ](https://forth-standard.org/standard/core/SIGN)
[HOLD       ](https://forth-standard.org/standard/core/HOLD)
[#>         ](https://forth-standard.org/standard/core/num-end)
[#S         ](https://forth-standard.org/standard/core/numS)
[#          ](https://forth-standard.org/standard/core/num)
[<#         ](https://forth-standard.org/standard/core/num-start)
[!          ](https://forth-standard.org/standard/core/Store)
[@          ](https://forth-standard.org/standard/core/Fetch)
[CR         ](https://forth-standard.org/standard/core/CR)
[TYPE       ](https://forth-standard.org/standard/core/TYPE)
[EMIT       ](https://forth-standard.org/standard/core/EMIT)
[KEY        ](https://forth-standard.org/standard/core/KEY)
[ACCEPT     ](https://forth-standard.org/standard/core/ACCEPT)  

    COLD            PFA of COLD content = STOP_APP subroutine address, by default --> STOP_TERM  
    WARM            PFA of WARM content = INI_APP subroutine address, by default --> ENABLE_IO  
    WIPE            resets the program memory to its original state (Deep_RST have same effect).
    RST_HERE        defines the bound of the program memory protected against COLD or hardware reset.  
    PWR_HERE        defines the bound of the program memory protected against ON/OFF and also against any error occurring.  
    RST_STATE       removes all words defined after RST_HERE (COLD or <reset> have same effet)  
    PWR_STATE       removes all words defined after PWR_HERE (an error has same effect)  
    INTERPRET       text interpreter, common part of EVALUATE and QUIT.  
    NOECHO          stop display on output   
    ECHO            start display on output  

### words added by the option MSP430ASSEMBLER:

    HDNCODE         CODE            HI2LO

    CODE <word>     creates a word written in assembler.
                    this defined <word> must be ended with ENDCODE unless COLON or LO2HI use.  
    HDNCODE <word>  creates a word written in assembler but not interpretable by FORTH (because ended by RET instr.).  
                    Visible only from assembler  
    HI2LO           used to switch compilation from high level (FORTH) to low level (assembler).

### Other words are useable in any source_files.f, see \inc\device.pat file :

    SLEEP               CODE_WITHOUT_RETURN: CPU shutdown  
    LIT                 CODE compiled by LITERAL  
    XSQUOTE             CODE compiled by S" and S_  
    HEREXEC             CODE HERE and BEGIN execute address  
    QFBRAN              CODE compiled by IF UNTIL  
    BRAN                CODE compiled by ELSE REPEAT AGAIN  
    NEXT_ADR            CODE NEXT instruction (MOV @IP+,PC)  
    XDO                 CODE compiled by DO  
    XPLOOP              CODE compiled by +LOOP  
    XLOOP               CODE compiled by LOOP  
    MUSMOD              ASM 32/16 unsigned division, used by ?NUMBER, UM/MOD  
    MDIV1DIV2           ASM input for 48/16 unsigned division with DVDhi=0, see DOUBLE M*/  
    MDIV1               ASM input for 48/16 unsigned division, see DOUBLE M*/  
    RET_ADR             ASM content of INI_FORTH_PFA and MARKER+8 definitions,  
    SETIB               CODE Set Input Buffer with org & len values, reset >IN pointer  
    REFILL              CODE accept one line from input and leave org len of input buffer  
    CIB_ADR             [CIB_ADR] = TIB_ORG by default; may be redirected to SDIB_ORG  
    XDODOES             to restore rDODOES: `MOV #XDODOES,rDODOES`  
    XDOCON              to restore rDOCON: `MOV #XDOCON,rDOCON`  
    XDOVAR              to restore rDOVAR: `MOV #XDOVAR,rDOVAR`  
    !                   to restore rDOCOL: `MOV &WIPE_DOCOL,rDOCOL`  
    INI_FORTH           CODE_WITHOUT_RETURN common part of RST and QABORT, starts FORTH engine  
    QABORT              CODE_WITHOUT_RETURN run-time part of ABORT"  
    ABORT_TERM          CODE_WITHOUT_RETURN called by QABORT, also by QREVEAL and INTERPRET     
    UART_COLD_TERM      ASM, content of COLD_PFA by default  
    UART_INIT_TERM      ASM, content of WARM_PFA by default  
    UART_RXON           ASM, content of SLEEP_PFA by default  
    UART_RXOFF          ASM, called by ACCEPT before Receiving char LF.  
    I2C_COLD_TERM       ASM, content of COLD_PFA by default  
    I2C_INIT_TERM       ASM, content of WARM_PFA by default  
    I2C_RXON            ASM, content of SLEEP_PFA by default  
    I2C_CTRL_CH         ASM, used as is: `MOV.B #CTRL_CHAR,Y`  
    !                                    `CALL #I2C_CTRL_CH`
    ABORT               ABORT address
    QUIT                QUIT address


### Other variables useable in source_files.f, see \inc\device.pat file :

    FREQ_KHZ        FREQUENCY (in kHz)
    TERMBRW_RST     TERMBRW_RST
    TERMMCTLW_RST   TERMMCTLW_RST
    I2CSLAVEADR     I2C_SLAVE address
    I2CSLAVEADR1       
    LPM_MODE        LPM_MODE value, LPM0+GIE is the default value
    RSTIV_MEM       SYSRSTIV memory, set to -1 to do Deep RESET
    RST_DP          RST value for DP
    RST_VOC         RST value for VOClink
    VERSION 
    THREADS 
    KERNEL_ADDON    

    WIPE_INI                MOV #WIPE_INI,X
    WIPE_COLD       WIPE value for PFA_COLD
    WIPE_INI_FORTH  WIPE value for PFA_INI_FORTH
    WIPE_SLEEP      WIPE value for PFA_SLEEP
    WIPE_WARM       WIPE value for PFA_WARM
    WIPE_TERM_INT   WIPE value for TERMINAL vector
    WIPE_DP         WIPE value for RST_DP   
    WIPE_VOC        WIPE value for RST_VOC

    INI_FORTH_INI   MOV #INI_FORTH_INI,X    \ >BODY instruction of default INI_SOFT_APP
    INIT_ACCEPT     FORTH value for PFAACCEPT
    INIT_CR         FORTH value for PFACR
    INIT_EMIT       FORTH value for PFAEMIT
    INIT_KEY        FORTH value for PFAKEY
    INIT_CIB        FORTH value for CIB_ADR
    HALF_FORTH_INI  to preserve the state of DEFERed words, used by user INI_SOFT_APP as:
    !                   ADD #4,0(RSP)           \ skip INI_FORTH >BODY instruction "MOV #INI_FORTH_INI,X"
    !                   MOV #HALF_FORTH_INI,X   \ replace it by "MOV #HALF_FORTH_INI,X"
    !                   MOV @RSP+,PC            \ then RET
    INIT_DOCOL      FORTH value for rDOCOL   (R4) to restore rDOCOL: MOV &INIT_DOCOL,rDOCOL
    INIT_DODOES     FORTH value for rDODOES  (R5)
    INIT_DOCON      FORTH value for rDOCON   (R6)
    INIT_DOVAR      FORTH value for rDOVAR   (R7)
    INIT_CAPS       FORTH value for CAPS
    INIT_BASE       FORTH value for BASE
    


## MSP430ASSEMBLER word-set

    ?GOTO           GOTO            FW3             FW2             FW1             BW3             BW2             
    BW1             REPEAT          WHILE           AGAIN           UNTIL           ELSE            THEN            
    IF              0=              0<>             U>=             U<              0<              0>=             
    S<              S>=             RRUM            RLAM            RRAM            RRCM            POPM            
    PUSHM           CALL            PUSH.B          PUSH            SXT             RRA.B           RRA             
    SWPB            RRC.B           RRC             AND.B           AND             XOR.B           XOR             
    BIS.B           BIS             BIC.B           BIC             BIT.B           BIT             DADD.B          
    DADD            CMP.B           CMP             SUB.B           SUB             SUBC.B          SUBC            
    ADDC.B          ADDC            ADD.B           ADD             MOV.B           MOV             RETI            
    LO2HI           COLON           ENDASM          ENDCODE

[ADD, ADD.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=135),
[ADDC, ADDC.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=136),
[AND, AND.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=137),
[BIC, BIC.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=138),
[BIS, BIS.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=139),
[BIT, BIT.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=140),
[CALL           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=142),
[CMP, CMP.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=147),
[DADD, DADD.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=149),
[MOV, MOV.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=165),
[PUSH, PUSH.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=168),
[RETI           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=170),
[RRA, RRA.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=173),
[RRC, RRC.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=174)
[SUB, SUB.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=179)
[SUBC, SUBC.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=180)
[SWPB           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=181)
[SXT            ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=182)
[XOR, XOR.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=184)
[RRUM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=218)
[RLAM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=208)
[RRAM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=211)
[RRCM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=214)
[POPM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=204)
[PUSHM          ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=205)

    ?GOTO           used after a conditionnal (0=,0<>,U>=,U<,0<,S<,S>=) to branch to a label FWx or BWx  
    GOTO            used as unconditionnal branch to a label FWx or BWx  
    BW3             BACKWARD branch destination n°3  
    BW2                                         n°2  
    BW1                                         n°1  
    FW3             FORWARD branch destination  n°3  
    FW2                                         n°2  
    FW1                                         n°1  
    REPEAT          assembler version of the FORTH word REPEAT  
    WHILE           idem  
    AGAIN           idem  
    UNTIL           idem  
    ELSE            idem  
    THEN            idem  
    IF              idem  
    0=              conditionnal       
    0<>             conditionnal  
    U>=             conditionnal  
    U<              conditionnal  
    0<              conditionnal, to use only with ?GOTO  
    0>=             conditionnal, to use only with IF UNTIL WHILE  
    S<              conditionnal  
    S>=             conditionnal  
    LO2HI           switches compilation between low level and high level modes without saving IP register.  
    COLON           pushes IP then performs LO2HI, used as: CODE <word> ... assembler instr ... COLON ... FORTH words ... ;
    ENDCODE         to end a CODE or HDNCODE definition.  

#### EXTENDED_MEM WORDS set:

Gives access to addresses beyond $FFFF

[POPM.A         ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=204),
[PUSHM.A        ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=205),
[ADDA           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=229),
[CALLA          ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=232),
[CMPA           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=235),
[MOVA           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=238),
[SUBA           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=241)

#### EXTENDED_ASM WORDS set:

Full 20 bits address/data assembler

[ADDX, ADDX.A, ADDX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=187),
[ADDCX, ADDCX.A, ADDCX.B](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=188),
[ANDX ANDX.A, ANDX.B    ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=189),
[BICX, BICX.A, BICX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=190),
[BISX, BISX.A, BISX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=191),
[BITX, BITX.A, BITX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=192),
[CMPX, CMPX.A, CMPX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=194),
[DADDX, DADDX.A, DADDX.B](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=196),
[MOVX, MOVX.A, MOVX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=202),
[PUSHX, PUSHX.A, PUSHX.B](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=207),
[RRAX, RRAX.A, RRAX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=212),
[RRCX, RRCX.A, RRCX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=216),
[RRUX, RRUX.A, RRUX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=219),
[SUBX, SUBX.A, SUBX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=221),
[SUBCX, SUBCX.A, SUBCX.B](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=222),
[SWPBX, SWPBX.A         ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=223),
[SXTX, SXTX.A           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=225),
[XORX, XORX.A, XORX.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=227),
[RPT                    ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=119)

### CONDCOMP ADD-ON

[MARKER         ](https://forth-standard.org/standard/core/MARKER),
[\[DEFINED\]    ](https://forth-standard.org/standard/tools/BracketDEFINED),
[\[UNDEFINED\]  ](https://forth-standard.org/standard/tools/BracketUNDEFINED),
[\[IF\]         ](https://forth-standard.org/standard/tools/BracketIF),
[\[ELSE\]       ](https://forth-standard.org/standard/tools/BracketELSE),
[\[THEN\]       ](https://forth-standard.org/standard/tools/BracketTHEN)


### VOCABULARY ADD-ON

[DEFINITIONS     ](https://forth-standard.org/standard/search/DEFINITIONS),
[ONLY            ](https://forth-standard.org/standard/search/ONLY),
[PREVIOUS        ](https://forth-standard.org/standard/search/PREVIOUS),
[ALSO            ](https://forth-standard.org/standard/search/ALSO)  

ASSEMBLER sets ASSEMBLER as CONTEXT word set  
FORTH sets FORTH as CONTEXT word set  
VOCABULARY <name> creates a new word-set 


### NONAME ADD-ON

[\:NONAME      ](https://forth-standard.org/standard/core/ColonNONAME),
[DEFER         ](https://forth-standard.org/standard/core/DEFER),
[IS            ](https://forth-standard.org/standard/core/IS)

CODENNM is the assembly counterpart of :NONAME.


### SD_CARD_LOADER ADD-ON

    LOAD"           LOAD" SD_TEST.4TH" loads source file SD_TEST.4TH from SD_Card and compile it.


### SD_CARD_READ_WRITE ADD-ON

    TERM2SD"        SD_EMIT         WRITE           READ            CLOSE           DEL"            WRITE"          
    READ"

    TERM2SD"        TERM2SD" SD_TEST.4TH" copy input file to SD_CARD (use CopySourceFileToTarget_SD_Card.bat to do)
    SD_EMIT         sends output stream at the end of last opened as write file.
    WRITE           write sequentially BUFFER content to a sector
    READ            read sequentially a sector to BUFFER
    CLOSE           close last opened file.
    DEL"            DEL" SD_TEST.4TH" remove this file from SD_CARD.
    WRITE"          WRITE" TRUC" open or create TRUC file ready to write to the end of this file
    READ"           READ" TRUC" open TRUC and load its first sector in BUFFER



### BOOTLOADER

to enable bootloader: `' BOOT IS WARM`,
to disable bootloader: `' BOOT [PFA] IS WARM`

Once bootloader enabled, any PUC event loads (and executes) the file \BOOT.4TH from the SD_Card.


## OPTIONNAL ADD-ON

* when ADD-ONs are compiled with the kernel, their respective MARKER word identified with braces {} does nothing.  
  Sources are in the folder \ADDON, as source.asm file.

* when ADD-ONs are downloaded, their respective MARKER word identified with braces {} removes all ADD-ONs words.  
  Sources are in the folder \MSP430-FORTH\, as source.f file.

### ANS_COMP

Adds complement to pass FORTH ANS94 core test.

[VALUE           ](https://forth-standard.org/standard/core/VALUE),
[TO              ](https://forth-standard.org/standard/core/TO),
[BEGIN           ](https://forth-standard.org/standard/core/BEGIN),
[DOES>           ](https://forth-standard.org/standard/core/DOES),
[SPACES          ](https://forth-standard.org/standard/core/SPACES),
[SPACE           ](https://forth-standard.org/standard/core/SPACE),
[BL              ](https://forth-standard.org/standard/core/BL),
[PAD             ](https://forth-standard.org/standard/core/PAD),       
[>IN             ](https://forth-standard.org/standard/core/toIN),
[BASE            ](https://forth-standard.org/standard/core/BASE),
[STATE           ](https://forth-standard.org/standard/core/STATE),
[CONSTANT        ](https://forth-standard.org/standard/core/CONSTANT),
[VARIABLE        ](https://forth-standard.org/standard/core/VARIABLE),
[SOURCE          ](https://forth-standard.org/standard/core/SOURCE),
[RECURSE         ](https://forth-standard.org/standard/core/RECURSE),
[EVALUATE        ](https://forth-standard.org/standard/core/EVALUATE),
[EXECUTE         ](https://forth-standard.org/standard/core/EXECUTE),
[>BODY           ](https://forth-standard.org/standard/core/toBODY),
[.(              ](https://forth-standard.org/standard/core/Dotp),
[(               ](https://forth-standard.org/standard/core/p),
[DECIMAL         ](https://forth-standard.org/standard/core/DECIMAL),
[HEX             ](https://forth-standard.org/standard/core/HEX),
[HERE            ](https://forth-standard.org/standard/core/HERE),
[FILL            ](https://forth-standard.org/standard/core/FILL),
[MOVE            ](https://forth-standard.org/standard/core/MOVE),
[+!              ](https://forth-standard.org/standard/core/PlusStore),
[[CHAR]          ](https://forth-standard.org/standard/core/BracketCHAR),
[CHAR            ](https://forth-standard.org/standard/core/CHAR),
[CELL+           ](https://forth-standard.org/standard/core/CELLPlus),
[CELLS           ](https://forth-standard.org/standard/core/CELLS),
[CHAR+           ](https://forth-standard.org/standard/core/CHARPlus),
[CHARS           ](https://forth-standard.org/standard/core/CHARS),
[ALIGN           ](https://forth-standard.org/standard/core/ALIGN),
[ALIGNED         ](https://forth-standard.org/standard/core/ALIGNED),
[2OVER           ](https://forth-standard.org/standard/core/TwoOVER),
[2SWAP           ](https://forth-standard.org/standard/core/TwoSWAP),
[2DROP           ](https://forth-standard.org/standard/core/TwoDROP),
[2DUP            ](https://forth-standard.org/standard/core/TwoDUP),
[2!              ](https://forth-standard.org/standard/core/TwoStore),
[2@              ](https://forth-standard.org/standard/core/TwoFetch),
[R@              ](https://forth-standard.org/standard/core/RFetch),
[ROT             ](https://forth-standard.org/standard/core/ROT),
[OVER            ](https://forth-standard.org/standard/core/OVER),
[*/              ](https://forth-standard.org/standard/core/TimesDiv),
[*/MOD           ](https://forth-standard.org/standard/core/TimesDivMOD),
[MOD             ](https://forth-standard.org/standard/core/MOD),
[/               ](https://forth-standard.org/standard/core/Div),
[/MOD            ](https://forth-standard.org/standard/core/DivMOD),
[*               ](https://forth-standard.org/standard/core/Times),
[FM/MOD          ](https://forth-standard.org/standard/core/FMDivMOD),
[ABS             ](https://forth-standard.org/standard/core/ABS),
[NEGATE          ](https://forth-standard.org/standard/core/NEGATE),
[SM/REM          ](https://forth-standard.org/standard/core/SMDivREM),
[UM/MOD          ](https://forth-standard.org/standard/core/UMDivMOD),
[M*              ](https://forth-standard.org/standard/core/MTimes),
[UM*             ](https://forth-standard.org/standard/core/UMTimes),
[2/              ](https://forth-standard.org/standard/core/TwoDiv),
[2*              ](https://forth-standard.org/standard/core/TwoTimes),
[MIN             ](https://forth-standard.org/standard/core/MIN),
[MAX             ](https://forth-standard.org/standard/core/MAX),
[RSHIFT          ](https://forth-standard.org/standard/core/RSHIFT),
[LSHIFT          ](https://forth-standard.org/standard/core/LSHIFT),
[INVERT          ](https://forth-standard.org/standard/core/INVERT),
[1-              ](https://forth-standard.org/standard/core/OneMinus),
[1+              ](https://forth-standard.org/standard/core/OnePlus),
[S>D             ](https://forth-standard.org/standard/core/StoD),
[XOR             ](https://forth-standard.org/standard/core/XOR),
[OR              ](https://forth-standard.org/standard/core/OR),
[AND             ](https://forth-standard.org/standard/core/AND),
[LEAVE           ](https://forth-standard.org/standard/core/LEAVE),
[UNLOOP          ](https://forth-standard.org/standard/core/UNLOOP),
[J               ](https://forth-standard.org/standard/core/J),
[I               ](https://forth-standard.org/standard/core/I),
[+LOOP           ](https://forth-standard.org/standard/core/PlusLOOP),
[LOOP            ](https://forth-standard.org/standard/core/LOOP),
[DO              ](https://forth-standard.org/standard/core/DO),  
[REPEAT          ](https://forth-standard.org/standard/core/REPEAT),
[WHILE           ](https://forth-standard.org/standard/core/WHILE),
[AGAIN           ](https://forth-standard.org/standard/core/AGAIN),
[UNTIL           ](https://forth-standard.org/standard/core/UNTIL),
[THEN            ](https://forth-standard.org/standard/core/THEN),
[ELSE            ](https://forth-standard.org/standard/core/ELSE),
[IF              ](https://forth-standard.org/standard/core/IF),
[>               ](https://forth-standard.org/standard/core/more),
[<               ](https://forth-standard.org/standard/core/less),
[U<              ](https://forth-standard.org/standard/core/Uless),
[=               ](https://forth-standard.org/standard/core/Equal),
[0<              ](https://forth-standard.org/standard/core/Zeroless),
[0=              ](https://forth-standard.org/standard/core/ZeroEqual),
[C,              ](https://forth-standard.org/standard/core/CComma),
[C!              ](https://forth-standard.org/standard/core/CStore),
[C@              ](https://forth-standard.org/standard/core/CFetch),
[R>              ](https://forth-standard.org/standard/core/Rfrom),
[>R              ](https://forth-standard.org/standard/core/toR),
[NIP             ](https://forth-standard.org/standard/core/NIP),
[DROP            ](https://forth-standard.org/standard/core/DROP),
[SWAP            ](https://forth-standard.org/standard/core/SWAP),
[DEPTH           ](https://forth-standard.org/standard/core/DEPTH),
[EXIT            ](https://forth-standard.org/standard/core/EXIT),
[?DUP            ](https://forth-standard.org/standard/core/qDUP),
[DUP             ](https://forth-standard.org/standard/core/DUP),
[-               ](https://forth-standard.org/standard/core/Minus),
[+               ](https://forth-standard.org/standard/core/Plus)


### FIXPOINT

    S>F             F.              F*              F#S             F/              F-              F+              
    HOLDS           {FIXPOINT}

    S>F             u/n -- Qlo Qhi       convert u/n in a Q15.16 value
    F.              display a Q15.16 value
    F*              Q15.16 multiplication  
    F#S             Qlo Qhi u -- Qhi 0    
                    convert fractionnal part of a Q15.16 value displaying u digits
    F/              Q15.16 division        
    F-              Q15.16 soustraction
    F+              Q15.16 addition
    HOLDS           https://forth-standard.org/standard/core/HOLDS


### UTILITY

    DUMP            U.R             WORDS           ?               .RS             .S              {TOOLS}

[DUMP           ](https://forth-standard.org/standard/tools/DUMP), 
[U.R            ](https://forth-standard.org/standard/core/UDotR),
[WORDS          ](https://forth-standard.org/standard/tools/WORDS),  
[?              ](https://forth-standard.org/standard/tools/q), 
[.S             ](https://forth-standard.org/standard/tools/DotS),

    .RS             displays Return Stack content  

### SD_TOOLS

    DIR             FAT             CLUSTER         SECTOR          {SD_TOOLS}

    DIR             dump first sector of current directory  
    FAT             dump first sector of FAT1  
    CLUSTER         .123 CLUSTER displays first sector of cluster 123  
    SECTOR          .123456789 SECTOR displays sector 123456789  

### DOUBLE word set

[D.R             ](https://forth-standard.org/standard/double/DDotR),
[2LITERAL        ](https://forth-standard.org/standard/double/TwoLITERAL),
[2VALUE          ](https://forth-standard.org/standard/double/TwoVALUE),
[2CONSTANT       ](https://forth-standard.org/standard/double/TwoCONSTANT),
[2VARIABLE       ](https://forth-standard.org/standard/double/TwoVARIABLE),
[M*/             ](https://forth-standard.org/standard/double/MTimesDiv),
[DMIN            ](https://forth-standard.org/standard/double/DMIN),
[DMAX            ](https://forth-standard.org/standard/double/DMAX),
[D2*             ](https://forth-standard.org/standard/double/DTwoTimes),
[D2/             ](https://forth-standard.org/standard/double/DTwoDiv),
[DABS            ](https://forth-standard.org/standard/double/DABS),
[DNEGATE         ](https://forth-standard.org/standard/double/DNEGATE),
[D-              ](https://forth-standard.org/standard/double/DMinus),
[M+              ](https://forth-standard.org/standard/double/MPlus),
[D+              ](https://forth-standard.org/standard/double/DPlus),
[DU<             ](https://forth-standard.org/standard/double/DUless),
[D<              ](https://forth-standard.org/standard/double/Dless),
[D=              ](https://forth-standard.org/standard/double/DEqual),
[D0<             ](https://forth-standard.org/standard/double/DZeroless),
[D0=             ](https://forth-standard.org/standard/double/DZeroEqual),
[D>S             ](https://forth-standard.org/standard/double/DtoS),
[2ROT            ](https://forth-standard.org/standard/double/TwoROT),
[D.              ](https://forth-standard.org/standard/double/Dd),
[2R>             ](https://forth-standard.org/standard/core/TwoRfrom),
[2R@             ](https://forth-standard.org/standard/core/TwoRFetch),
[2>R             ](https://forth-standard.org/standard/core/TwotoR)


## IDE for linux UBUNTU 

First search from ti.com: [MSP430Flasher](http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSP430Flasher/latest/index_FDS.html)

untar in a home folder then:
* open MSPFlasher-1.3.16-linux-x64-installer.run
* install in MSP430Flasher (under home)

open a terminal in MSP430Flasher/Drivers: 
    sudo ./msp430uif_install.sh
    
copy MSP430Flasher/MSP430Flasher to /usr/local/bin/MSP430Flasher 
copy MSP430Flasher/libmsp430.so  to /usr/local/lib/MSP430Flasher/libmsp430.so

open an editor as superuser in /etc/ld.so.conf.d/
     write on first line (of new file): /usr/local/lib/msp430flasher/
     save this new file as libmsp430.conf
then in a terminal: sudo /sbin/ldconfig


#### install the package srecord

install the package scite
as super user, edit /etc/scite/SciTEGlobal.properties
uncomment (line 18): position.maximize=1
uncomment (line 257): properties.directory.enable=1
add line 7: PLAT_WIN=0
add line 8: PLAT_GTK=1
save file

at the end of your ~.profile file, add these two lines:
FF="/the_root_of_your_FastForth_local_copy"
export FF

https://sourceforge.net/projects/gema/files/gema/gema-1.4-RC/gema-1.4RC-src.tgz/download
untar in a home folder then:
make (ignore warnings)
sudo make install (ignore warnings)
make clean
result in: /usr/local/bin/gema

http://john.ccac.rwth-aachen.de:8000/ftp/as/source/c_version/asl-current.tar.gz
untar in a home folder then:
copy /Makefile.def-samples/Makefile.def-i386-unknown-linux2.x,x to ../Makefile.def
edit this Makefile.def to remove "-march=i586" option from line 7 (if any)
make
make test
sudo make install
make clean
result: asl files are in /usr/local


#### install minicom package


sudo gpasswd --add ${USER} dialout

copy /config/msp430/.minirc.dfl in your home directory.

In /inc/RemoveComments.pat, deselect windows part, select linux part. 


With scite editor you can 
   - assemble FastForth then download it to eZFET target, 
   - edit your source files
   - preprocess file.f to file.4th 

With minicom you can send a file.4th to your target via dev/ttyUSB0, up to 4Mbauds:
CTRL_A + Y to send a file



