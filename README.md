## FastForth for MSP430FRxxxx TI's CPUs, light, fast, reliable.


Tested on TI MSP-EXP430FR
[5739](https://duckduckgo.com/?q=MSP-EXP430FR5739&iax=images&ia=images),
[**5969**](https://duckduckgo.com/?q=MSP-EXP430FR5969&iax=images&ia=images),
[**5994**](https://duckduckgo.com/?q=MSP-EXP430FR5994&iax=images&ia=images),
[6989](https://duckduckgo.com/?q=MSP-EXP430FR6989&iax=images&ia=images),
[4133](https://duckduckgo.com/?q=MSP-EXP430FR4133&iax=images&ia=images),
[2476](https://duckduckgo.com/?q=LP-MSP430FR2476&iax=images&ia=images),
[**2355**](https://duckduckgo.com/?q=MSP-EXP430FR2355&iax=images&ia=images),
[2433](https://duckduckgo.com/?q=MSP-EXP430FR2433&iax=images&ia=images) launchpads, at 1, 2, 4, 8, 12, 16 MHz plus 20 & 24 MHz with MSP430FR(23xx,57xx) devices.


note: if you want to write a program to make a LED flash, i suggest you to go [here](https://www.raspberrypi.com),
      but if you want to deepen your programming basics, you've come to the right place.

FastForth is a "Just In First" Load-Interpret-Compile Operating System for all the 16/20 bits CPU MSP430FRxxxx (MSP430 with FRAM) :

* LOAD: choice of the TERMINAL interface:

    * UART TERMINAL up to 6MBds @ MCLK=24MHz, with software (XON/XOFF) or hardware (RTS) control flow, **transmit delay: 0 ms/char, 0 ms/line**

    * a very well designed **I2C TERMINAL**, with a full duplex behaviour, ready to communicate with all the targets **I2C_FastForth** wired on its I2C bus,
    
* INTERPRET: with a 16-entry word-set that speeds up the FORTH interpreter by 4,

* COMPILE: in addition to the FORTH engine, the **MSP430 assembler, label free, with the TI's syntax** (not the FORTH one!),

and as result "Load Interpret Compile" a source file is faster and easier than **just** loading its equivalent TI.txt binary file via the TI's eZFET interface. 
For example, with a target running at 24MHz, UART=6MBds 8n1, an USBtoUART bridge [PL2303GC](https://duckduckgo.com/?q=DSD+TECH+SH-U06A) 
and [Teraterm.exe](https://osdn.net/projects/ttssh2/releases/) as TERMINAL, 
the "JIF" process of the /MSP430-FORTH/CORETEST.4TH file is done at an **effective rate** up to 800 kBds, up to 500 kBds with an I2C_Slave target running at 24MHz, and beyond 1Mbit/s from a SD_CARD.  
This is, by far, unparalleled on the planet FORTH, and on others too.   

Despite its **size of 4.75 kb** FastForth includes:

* FORTH kernel with interpreting decimal, hex, binary (#,$,% prefixed) numbers, digits separator '_', 'char', double numbers and Q15.16 numbers,

* the assembler for MSP430 (with TI's syntax),

* a good error handling which discards the "JIF" process of source files and thus avoids system crash,

* a memory management which can be modulated according to these 3 levels (software|hardware): `-1 SYS`|`<SW1+RST>`, `MARKER`|, `6 SYS`|`<RST>`.

* everything you need to write a real time application:

    * the complete set of the FORTH building definitions,

    * conditional compilation,

    * thanks to [GEMA preprocessor](http://gema.sourceforge.net/new/index.shtml), the compilation of all symbolic addresses without having to declare them in FORTH, 

    * easy roundtrip between FORTH and ASSEMBLER levels with only two 'one word' switches: `HI2LO`, `LO2HI`,

    * automatic releasing memory with `MARKER` and `RST_SET`/`RST_RET` tags,

    * Fully configurable sequences reset, init and background,

    * CPU in sleep mode LPM0|LPM4 in awaiting a command from UART|I2C TERMINAL, and ready to process any interrupts.

If you want to quickly get an idea of what Fast Forth can do, see the /MSP430-FORTH/UARTI2CS.f application file. 
You will see that the FORTH language is used here as packaging of the program written in assembler.
See /MSP430-FORTH/FF_SPECS.f for another point of view.

For only 3 kb in addition, we have the primitives to access the SD_CARD FAT32: read, write, del, download source files and also to copy them from PC to the SD_Card.
It works with all SD\_CARD memories from 4GB to 64GB with FAT32 format.

With all the kernel addons, including the 20 bits MSP430\_X assembler and the SD\_Card driver, FastForth size is **10 kB**.

Once downloading /MSP430-FORTH/CORE_ANS.f file (2.25 kb), FastForth passes the tests: /MSP430-FORTH/CORETEST.4TH ( CORE ANS94 + COREPLUSTEST ), thus proving its compliance with the ANS94 standard.

However, if all works well with Windows 10, it works less well with Linux due to the lack of a good alternative to TERATERM...

Note: please, for each update download all subdirectories to correctly update the project.

## how to connect TERMINAL

    The files \binaries\launchpad_xMHz.txt are the executables ready to use with a serial terminal 
    (TERATERM.exe), with XON/XOFF or RTS_hardware flow controls and a PL2303TA/CP2102 cable.
    ------------------------------------------------------------------------------------------
    WARNING! doesn't use it to supply your launchpad: red wire is 5V ==> MSP430FRxxxx destroyed!
    ------------------------------------------------------------------------------------------
    (modify this first: open the box and weld red wire on 3.3V pad).

### programming with MSP430Flasher/UniFlash and FET interface:

            J101 connector
                    |
                    v
     TI Launchpad <--> FET interface  <-------------> USB <-------->COMx<----> MSP430Flasher.exe/UniFlash
              Vcc <--- 3V3
       TST/SBWTCK <--> SBWTCK        ) 
              GND <--> GND           > used to program MAIN
      RST/SBWTDIO <--> SBWTDIO       ) 

     TI Launchpad <--> CP2102/PL2303 cable <--------> USB <-------->COMy<----> TERATERM.exe 
               RX <--- TX            )
              GND <--> GND           > FastForth TERMINAL
               TX ---> RX            )
     Pin Px.y RTS ---> CTS (optionnal) RTS pin Px.y is described in your \inc\launchpad.asm)
    
    TERATERM config terminal:   NewLine receive : LF,
                                NewLine transmit : CR+LF
                                Size : 80 chars x 42 lines (adjust lines according to your display)
                                type terminal : VT520

    TERATERM config serial port:    COM = these of your USBtoUART device
                                    speed = TERMINALBAUDRATE value,
                                    8 bits, no parity, 1 Stop bit,
                                    XON/XOFF flow control,
                                    delay = 0ms/line, 0ms/char
    
    **don't forget to save always new TERATERM configuration !**

## Out of the box

Once FastForth is loaded in the target FRAM memory, you add assembly code or FORTH code, or both,
by downloading your source files which embedded FastForth interprets and compiles.
    
Beforehand, the preprocessor GEMA, by means of a \config\gema\target.pat file, will have translated
your generic MSP430FR.f source file in a targeted MSP430FRxxxx.4th source file, allowing you to use
symbolic addressing for all peripheral registers (SFR), without having to do FORTH declarations.
A set of .bat files in \MSP430-FORTH folder is furnished to do all this automatically.
    
To see all specifications of FastForth, download \MSP430-FORTH\FF_SPECS.f.

To change the UART TERMINAL baudrate on the fly, 9600 Bauds up to 6 MBds, download \MSP430-FORTH\CHNGBAUD.f.
Beyond 1 MBds, shorten the PL2303HXD cable, down to 50 cm for 6MBds.

XON/XOFF flow control allows 3.75kV galvanic isolation of terminal input with SOIC8 Si8622EC|ISO7021.

If you choose I2C_FastForth for your project, you will need of one more launchpad to make the UARTtoI2C bridge.
See driver for it :  \MSP430-FORTH\UARTI2CS.f.

Notice that FAST FORTH interprets lines up to 84 chars, only SPACE as delimiter, only CR+LF as
End Of Line, and BACKSPACE; all other control chars are discarded. 
And that the high limit of a FORTH program memory is $FF40. 

Finally, using the SCITE editor as IDE, all is ready to do everything from its "tools" menu.

What is new ?
-------------

### V4.1, the last.   

* = V4.0 - 10 bytes.

* the pack of \inc\files.pat, used by GEMA.EXE to convert a generic FORTH file.f to a customised FORTH file.4TH, is simplified:
    * MSP430FRxxxx.pat for FRAM(INFO TLV MAIN) declarations,
    * MSP430FR5xxx.pat, MSP430FR57xx.pat and MSP430FR2xxx.pat for RAM declarations,
    * \<target\>.pat and \<device\>.pat for target and device configurations.

* rewritten bat files.

* WARM now displays a number which includes the error codes SYSUNIV (7) and SYSSNIV (15), in addition to SYSRSTIV ones (31)

* fixed `>NUMBER`

* SD_TEST.4TH used as SD_CARD bootstrap on reset (or not) works fine, just for my 68th birthday!

### V4.0, the penultimate last.   

* = V3.9 - 26 bytes.

* `HNDCODE` and `TICK` fixed

* `KEY` and `EMIT` rewritten, also `ECHO` and `NOECHO`

* the assembler handles correctly argument+/-offset

* the SD_Card driver is re-rewritten

    * it only supports FAT32 format and SD Cards from 4 GB to 64 GB

    * FAT32 Directories can be enlarged

    * fixed errors handling

* the driver UART to I2C is enhanced and more reliable

* added DOUBLE.asm in /ADDONS (DOUBLE word set)


### V3.9   

* = V3.8 - 350 bytes.

* removed `INTERPRET`, `CR` and the useless error line displaying.

* Removed `PWR_HERE` and `PWR_STATE`, replaced `RST_HERE` by `RST_SET` and `RST_STATE` by `RST_RET`.

* Replaced `WIPE` by `-1 SYS`, `COLD` by `4 SYS` and `WARM` by `0 SYS` or simply `SYS`.

* replaced `VOCABULARY` with `WORDSET`. `ALSO` is removed because the executing of a definition created by `WORDSET` adds it into the CONTEXT stack. For example, typing `FORTH` adds it into CONTEXT. Note that as result the use of ONLY is modified: `FORTH ONLY` instead of ~~`ONLY FORTH`~~.

* modified QNUMBER QABORT `ABORT` `QUIT` `HI2LO` `PREVIOUS` `WORD` `FIND` `>NUMBER` `TYPE` `#>` `COUNT` `SWAP` `TICK` `POSTPONE` `COLON` `[ELSE]` plus the assembler.

* The bootstrap ON/OFF is modified: `BOOT` / `NOBOOT` to enable / disable it.

* the word-set `ASSEMBLER` is renamed `hidden` because it stores not only the ASM instructions definitions but also HDNCODE definitions.

* when you execute a `MARKER` definition, it starts by removing from its previous definition if exists.

* Some bugs corrected:  
    * QNUMBER FORWDOES `TYPE` `WORD`, 
    * `M*/` in \MSP430-FORTH\DOUBLE.f file, 
    * ~~the assembler handles correctly argument+/-offset.~~

* User can choose floored or symmetric division. See \MSP430-FORTH\ANS_CORE.f

* the words `:NONAME` `IS` `DOES>` `CODENNM` are added to the core and there is still enough room in its 5kb for the VOCABULARY_SET add-on.  
  DEFER is not included because too easy to replace by a CODE definition, see CR in file CORE_ANS.f. 

* When used with VOCABULARY_SET activated, `RST_SET`/`RST_RET` and definition/use of `MARKER` tags save/restore the full word-set environment: DP, CURRENT, CONTEXT stack, VOCLINK.

* FF_SPECS.f displays all word-sets, including the `hidden` one.

* the SD_Card driver is rewritten. Only FAT32 format is supported. I suggest 4kb sized clusters.   
  The old `WRITE"` command is duplicated :  
    * `WRITE"` to create a new file (to overwrite if found),  
    * `APPEND"` to append to a file (to create it if not found)


### V3.8

* = V3.7 - 16 bytes.
    
* Source file copy from TERMINAL to the SD\_Card of any I2C\_FastForth target works fine.
    
* ~~The bootstrap call is modified: `' BOOT IS WARM` to enable it, `' BOOT [PFA] IS WARM` to remove it~~.

* `ASM` definitions are renamed `HDNCODE` (HiDdeN CODE), `ENDASM` is replaced by `ENDCODE`.

    `HDNCODE` definitions are identical to low level `CODE` ones, but are hidden because defined in the ~~`ASSEMBLER`~~ `hidden` word set, and must be used only
    in the scope of another low level CODE definition. See use in \MSP430-FORTH\UARTI2CS.f.
    
* FastForth passes CORETEST + COREPLUSTEST tests. See modified \MSP430-FORTH\CORETEST.4TH

* Double number word `D<` corrected in \MSP430-FORTH\DOUBLE.f


### V3.7

* 54 bytes added to (Kernel + Conditional_Compilation + Assembler).

* ~~Source file copy from I2C_TERMINAL to the SD_Card of any I2C_target works now.~~
    
* In addition of target's ID test made by Teraterm macro, a preamble has been added to all
    \MSP430-FORTH\source.f files to prohibit their downloading with another version of FastForth.

* Words @ ! ALLOT come back from "ANS_COMP" add-on to core.

* Recognized prefixes are $ # % and ' respectively for hex decimal binary and ASCII 'char' numbers.  
    Examples: 'U' - $55 = 0, '3' - #33 = 0, '@' - %0100_0000 = 0.  
    When use in source.f files, all ASCII special chars are available. See \inc\FastForthREGtoTI.pat.

* Assembler allows "argument+offset" into FORTH area (0 to $FFFF). Examples:  
 `MOV #RXON,&BACKGRND+2` to store RXON addr at BACKGRND+2 addr.  
 `MOV.B BUFFER-1(X),TOS` to load the byte at BUFFER-1(X) addr in the register TOS.
    
* `6 SYS` does same than hardware RST.  
  `-1 SYS` does same than hardware SW1+RST (DEEP_RESET).  


* More complicated:

  In the FastForth init process, COLD WARM ABORT" BACKGRND are modified and INIT_FORTH is added.  
  They include each a call to a paired assembly subroutine:
      
          RST_SYS failures ------------>+       +<----------<display error>----- ABORT" <---+<-- COMPILE/EXECUTE<-INTERPRET <--+
                                        |       |                                =====      |                                  ^
          RST ----------->+             |       v                                           v                                  |
                          v             |       +-> INIT_FORTH ----------->+-> ABORT->QUIT->+->ACCEPT->+            +->ACCEPT->+
          SW1+RST ------->+             |           ==========             ^                           |            ^
                          v             v                                  |                           v            |  
          -n SYS -------->+---> COLD -->+->PUC->+-> INIT_FORTH --> WARM -->+                           +->BACKGRND->o  
                          ^     ====            ^   ==========     ====                                   ========  ^
                          |                     |                                                                   \
          +n SYS (even) ->+                     |                                                                   /
                                                |                                                                   \
          +n SYS (odd) -->+--> (NOPUC) -------->+                                                        UART_RX_INT/I2C_START_INT
                          ^     ==== 
          [0] SYS ------->+
   
                      CALL...   &STOP_APP          &SOFT_APP    &HARD_APP       &ABORT_APP               &BACKGRND_APP
                                =========          =========    =========       ==========               =============

           Default subroutine   INIT_STOP          INIT_SOFT    INIT_TERM       ABORT_TERM               INIT_BACKGRND
               Default action   UART: wait idle    do nothing   init TERM UC..  discard..                UART: send RXON
                                I2C: do nothing                 ..unlock I/O    ..downloading            I2C: send Ctrl_Char $00 
          
          note: -n SYS|SW1+RST reset the default subroutine of these five calls. 
                don't use TOS in these subroutines.

    On the other hand, MARKER is modified in such a way that MARKER\_DOES executes a CALL to
    the content of USER_PARAM-2,   by default RET_ADR:
    
        MARKER [CFA]         = DODOES
               [PFA]         = MARKER_DOES
               [BODY]        = previous DP (Dictionnary Pointer)
               ...
               [USER_PARAM-2] = RET_ADR  as REMOVE_APP by default


By replacing [USER_PARAM-2] with the address of a new defined subroutine (named for example: REMOVE_XXX), 
MARKER_DOES will execute it to restore n critical pointers (room made by 2n ALLOT) at USER_PARAM, USER_PARAM+2, ...

Thus, with MARKER and the definition of some subroutines according to the need: STOP_XXX, SOFT_XXX, HARD_XXX, ABORT_XXX, BACKGRND_XXX, 
the programmer has full control of his "XXX" real time application using interrupts,
with everything he needs to start, stop and remove it properly, thanks to this 'soft' MARKER definition,
avoiding the hardware (SW1+RST) of the last chance. 

See example in  /MSP430-FORTH/UARTI2CS.f.


### V3.6

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

### V3.5

* 48 bytes removed.
    
* from Scite menu, we can program MSP430FRxxxx also with BSL_Scripter.
    
    To do, save file \prog\BSL_Scripter.exe from: 
    https://github.com/drcrane/bslscripter-vs2017/releases/download/v3.4.2/BSL-Scripter-v3.4.2.zip,
    but erasing a MSP430FR2355 or MSP430FR2476 doesn't work, thanks to BSL V. 00.09.36.B4 & B5.
    See SLAU550Z tables 16 & 17.
    
    and buy a USB2UART module CP2102 6 pin. On the web, search: "CP2102 3.3V DTR RTS" 
    For wiring, see \config\BSL_Prog.bat.
    
    So, we download both binaries and source files with only one CP2102|PL2303TA module,
    the XON/XOFF TERMINAL and BSL_Scripter. Bye bye T.I. FET!
    
* ABORT messages display first the I2C address, if applicable.

* QNUMBER some issues solved.
* UART version of ACCEPT and KEY are shortened.
* EVALUATE is moved to CORE_ANS.

### V3.4

* 36 bytes removed.
    
* Fixed: word F. issue in FIXPOINT.asm
    
* the new kernel DEFERRED option adds :NONAME CODENNM DEFER IS.
    
* pin RESET is software replaced by pin NMI and so, RESET executes COLD, allowing code insert before BOR.
  however SYSRSTIV numbering remains unchanged: = 4 for RESET, = 6 for COLD.
    
* Hardware Deep RESET (S1+RST) reinitializes vectors interrupts and SIGNATURES area, as WIPE.
    
    
* A newcomer: FastForth for I2C TERMINAL. With the driver UART2I2CS running on another FastForth target, 
we have the USB to I2C_Slave bridge we need: one TERMINAL for up to 112 I2C_FastForth targets.

                                                                                      +-------------------------+ 
        notebook                     USB to I2C_Slave bridge                    +-I2C-| others I2C_slave target | 
      +-----------+      +-------------------------------------------------+   /    +-------------------------+ | 
      |           |      ¦ PL2303HXD         target running UARTI2CS @24MHz¦  +-I2C-|  MSP430FR4133 @ 1 MHz   | |
      |           |      ¦------------+       +----------------------------¦ /   +--------------------------+ |-+
      |           |      ¦            | 3wires|   MSP430FR2355 @ 24MHz     ¦/    |   MSP430FR5738 @ 24 MHz  | |
      | TERATERM -o->USB-o->USB2UART->o->UART-o-> FAST FORTH -> UARTI2CS  -o-I2C-o-> FAST FORTH with option |-+
      | terminal  |      ¦            | 6MBds |               (I2C MASTER) ¦     |  TERMINAL_I2C (I2C SLAVE)| 
      |           |      ¦------------+       +----------------------------¦     +--------------------------+
      |           |      ¦            |< 20cm>|                            ¦       up to 112 I2C_Slave targets  
      +-----------+      +-------------------------------------------------+

With the indicated MCLK and UART speed, Coretest.4th (45896 bytes) is downloaded to (and executed by) I2C_Slave in 1220ms.   
The driver UARTI2CS works without error from 1MHz to 24MHz MCLK and from 115200Bds up to 6MBds UART.  
With I2C_Master running at 24 MHz, the I2C bus frequency is about 1MHz, and it works fine
even if I2C_slave is running at 1 MHz.
Don't forget to add two 3k3 pullup resistors on SCL and SDA...

the Multi Master Mode works but is not tested in multi master environment.
    
"Cerise sur le gâteau": when they wait for a TERMINAL input (idle state), 
both I2C_Master and I2C_Slave(s) are sleeping in LPMx mode and the bus I2C is freed. 
The I2C_slave driver handles LPM4 mode.
    
The UART2I2CS does not use TI's horrible UCBx_I2C_Master driver, but a much faster software driver,
with one more UCBx still available for an I2C_Slave or SPI driver.

##### HOW TO DO ?

    first you make the I2C cable (GND,SDA,SCL,3V3) between your 2 LaunchPad, with 3,3k pullup resistors
    on SDA and SCL lines. See in forthMSP430FR_TERM_I2C.asm to select SDA and SCL pins.
    
    to compile FastForth for I2C TERMINAL from forthMSP430FR.asm file:
    -  uncomment the line "TERMINAL_I2C".
    -  search "I2CSLAVEADR" line and set your <slave address you want>, i.e. 10h.
    -  compile file then prog your I2C_Slave LaunchPad.
    
    with the another LaunchPad running FastForth:
    At the end of UART2I2CS.f file set the <slave address you want>, i.e. $10.
    then download it, it's done: TERMINAL is linked to I2C_Slave.
    
    Type `Alt+B` on teraterm (send a BREAK) or press S2 on UARTtoI2C module to unlink I2C_Slave.

### PREVIOUS versions
    
Unlocking I/O's is transfered from RESET to WARM.
Thus, by redefining HARD_APP, you can add I/O's configuration for your application before a global unlocking.


The structure of primary DEFERred words as KEY,EMIT,CR,ACCEPT... is modified,
the address of their default execute part, without name, can be found with: `' <name> >BODY`

example, after this entry: `' DROP IS KEY` KEY runs DROP i.e. runs the redirection made by IS,  

but `' KEY >BODY EXECUTE` runs KEY, the default action at the BODY address.

and `' KEY >BODY IS KEY` restores the default action of this **primary** DEFERred word.


to build a **primary** DEFERred definition, you must create a CODE definition followed by a :NONAME definition:

    CODE SPACES         \ create a CODE definition named 'SPACES' which does a jump to the NEXT_ADR instruction to do nothing
    MOV #NEXT_ADR,PC    \ CFA = code of the instruction, PFA = parameter I of the instruction = NEXT_ADR
    ENDCODE             \ this definition 'SPACES' does nothing, for the moment...

    :NONAME             \ starts a FORTH definition without name
    BEGIN
        ?DUP
    WHILE
        'SP' EMIT
        1-
    REPEAT
    ;
    IS SPACES           \ this :NONAME execution_address is stored at PFA of SPACES, replacing NEXT_ADR
    
The advantage of creating primary DEFERred definitionss is to set their
default execution subroutine at their BODY address, enabling to reinitialize them easily:
' truc >BODY IS truc

Same with CODENNM definition, as low level equivalent of :NONAME

    CODE TSTBIT         \ create a CODE definition named 'TSTBIT' which does a jump to the NEXT_ADR instruction to do nothing
    MOV #NEXT_ADR,PC    \ CFA = instruction, PFA = NEXT_ADR
    ENDCODE             \ this definition 'TSTBIT' does nothing, for the moment...

    CODENNM             \ starts an assembly definition without name
    MOV @PSP+,X
    AND @X,TOS
    MOV @IP+,PC
    ENDCODE             \ -- execution_address_of_CODENNM
    IS TSTBIT           \ this CODENNM execution_address is stored at PFA of TSTBIT, replacing NEXT_ADR

you can obviously mix LOW/HIGH levels in CODENNM and :NONAME

All interpretation/compilation errors now execute ~~`PWR_RET`~~ `RST_RET`, so any incorrect definition
and all its source file will be automatically erased.
    

Accept SD_Card from 4 to 64 GB (FAT32).  
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
             \prog(.bat)             to do...
   
    \config\
           \SciTEUser.properties                copy it in your home directory
           \SciTEDirectory.properties           copy it to your project root folder
           \asm.properties                      configuration for *.inc,*.asm, .pat files
           \forth.properties                    configuration for *.f,*.4th files
           \SendFile.ttl                        TERATERM macro file to send source file to FASTFORTH
           \SendToSD.ttl                        TERATERM macro file to send source file to embedded SD_CARD 
           \build(.bat)                         called by scite to build target.txt program 
           \BSL_prog(.bat)                      to flash target with target.txt file with BSL_Scripter
           \FET_prog(.bat)                      to flash target with target.txt file with MSP430Flasher
           \Select.bat                          called to select target, device and deviceID
           \CopyTo_SD_Card(.bat)                to copy a file in the target SD_Card
           \SendSource(.bat)                    to send file to FASTFORTH
           \Preprocess(.bat)                    to convert generic .f file to specific .4th file
           \CopySourceFileToTarget_SD_Card.bat  create a link in any user folder for drag'n drop use
           \SendSourceFileToTarget.bat          create a link in any user folder for drag'n drop use
           \PreprocessSourceFile.bat            create a link in any user folder for drag'n drop use
    
    \inc\                         MACRO ASsembler files.inc, files.asm, GEMA preprocessor files.pat
        \TargetInit.asm           select target configuration file for AS assembler
        \MSP_EXP430FRxxxx.asm     target minimalist hardware config to compile FastForth
        \ThingsInFirst.inc        general configuration for AS assembler
        \MSP430FRxxxx.inc         device declarations
        \ThingsInLast.inc         general post configuration for AS assembler
    
        \FastForthREGtoTI.pat     converts FORTH symbolic registers names to TI Rx registers
        \tiREGtoFastForth.pat     converts TI Rx registers to FORTH symbolic registers names 
        \MSP430FRxxxx.pat         FastForth generic declarations for INFO TLV FRAM areas
        \MSP430FR2xxx.pat         FastForth RAM declarations for FR2xxx and FR4xxx families
        \MSP430FR57xx.pat         FastForth RAM declarations for FR57xx family
        \MSP430FR5xxx.pat         FastForth RAM declarations for FR5xxx and FR6xxx families
        \MSP_EXP430FRxxxx.pat     target (launchpad) configuration

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
                 \SD_TEST.f      tests for SD_CARD driver
                 \SD_TOOLS.f     same as SD_TOOLS.asm, (but erasable)
                 \TESTASM.f      some tests for embedded assembler
                 \TESTXASM.f     some tests for embedded extended assembler
                 \UARTI2CS.f     I2C_Master driver to link TERMINAL UART with any I2CSlave target
                 \UTILITY.f      same as UTILITY.asm, (but erasable)
    

Note: all actions (flashing target, download files) can be made by using bat files directly.
The next is to download IDE (WINDOWS):

## First get TI's programs

[MSP430-FLASHER](https://www.ti.com/tool/MSP430-FLASHER), [MSP430_FET_Drivers](http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSP430_FET_Drivers/latest/index_FDS.html)

install in the suggested directory, then copy MSP430Flasher.exe and MSP430.dll to \prog\

## download IDE

* [modified BSL-Scripter.zip](https://github.com/drcrane/bslscripter-vs2017/releases) and unzip as \prog\BSL-Scriper.exe

* [teraterm](https://osdn.net/projects/ttssh2/releases/)

* [GEMA general purpose preprocessor](https://sourceforge.net/projects/gema/files/latest/download), unzip in drive:\prog\

* [sCiTE single file executable](https://www.scintilla.org/SciTEDownload.html) to drive:\prog\, then rename Scxxx.exe to scite.exe

* [Macro AS](http://john.ccac.rwth-aachen.de:8000/ftp/as/precompiled/i386-unknown-win32/aswcurr-142-bld158.zip), unzip in drive:\prog\  

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

* set your target as first param, i.e. MSP_EXP430FR5969

* then execute. the output will be \binaries\MSP_EXP430FR5969.txt

## Load Txt file (TI format) to target

    in \binaries folder, drag your target.txt file and drop it on prog.bat
    
    or use scite internal command TOOLS: FET prog (CTRL+1).

nota : programming the device use SBW2 interface, so UARTn is free for serial terminal connexion.

If you want to program your own MSP430FRxxxx board, wire its pins TST, RST, 3V3 and GND 
to same pins of the launchpad, on eZ-FET side of the programming connector.

## Connect the FAST FORTH target to a serial terminal

you will need an USBtoUART cable with a PL2303TA|PL2303HXD|PL1303GC device that allows both XON/XOFF 
and hardware control flow :

[PL2303GC](https://duckduckgo.com/?q=DSD+TECH+SH-U06A+PL2303GC)
[PL2303 driver](http://www.prolific.com.tw/US/ShowProduct.aspx?p_id=225&pcid=41)

WARNING! always verify VCC PIN = 3.3V before use to supply your target with.

or with a CP2102 device and 3.3V/5V that allows XON/XOFF control flow up to 921600 Bds:

[CP2102 3.3V](https://duckduckgo.com/q=cp2102+3.3V+6PIN)
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
Look for the good wiring in /Launchpad.asm file

#### Compile with SD_Card addon

in forthMSP430FR.asm, uncomment lines SD_CARD_LOADER,  SD_CARD_READ_WRITE
then compile for your target

### the commands

With the `LOAD"` pathame" command FastForth loads source files from a SD_CARD memory.

    * LOAD" path\filename.4th" relative path,

    * LOAD" \path\filename.4th" absolute path.

The file is interpreted by FORTH in same manner than from the serial terminal.  
When EOF is reached, the file is automatically closed.  
A source file can `LOAD"` another source file, and so on in the limit of 8 handles. 

`LOAD"` may be used as Change Directory command: 

    * LOAD" \misc".       \misc becomes the current folder.

    * LOAD" ..\"          parent folder becomes the current folder.

    * LOAD" \"            Root becomes the current folder.


To read a file: `READ"` pathname"

* open it, the first sector is loaded in SD_BUF

The command `READ` sequentially loads the next sector in the buffer and leaves on the stack a true flag when the EOF is reached.    
The variable BufferLen keep the count of bytes to be read (1 to 512).

The file is automatically closed.  
  
If you want to anticipate the end, remove the false flag left by the previous `READ` then use the `CLOSE` command.

To overwrite a file: `WRITE"` path\filename.ext".

* If the file does not exist, create it

* set the write pointer at the **beginning** of the file, ready to append chars.

To write a file: `APPEND"` path\filename.ext".

* If the file does not exist, create it

* set the write pointer at the **end** of the file, ready to append chars.

The command `WRITE` sequentially writes the SD_BUF in SD_CARD and increments the current sector.

Use `CLOSE` to close a WRITE file.

See examples of use in \MSP430-FORTH\SD_TEST.f.


#### Copy source file to SD_Card

to copy a source file (.f or.4th) to SD_CARD target, use CopySourceFileToTarget\_SD\_Card.bat.
Double click on one of this bat files to see how to do.

or use scite.

If you have any copy error, first verify in "LAST.4th" that all lines are 
correctly ended with CR+LF.

## The system is not responding ?

First, remove the USBtoUART bridge then reconnect it. Perhaps it was in suspend state...

If the system is always freezed, press `RST` button on the MSP-EXP430FR5xxx ; FORTH restarts 
as it was after the last `RST_SET` command.

If the system does not restart again, press `SW1+RESET`. 
FORTH restarts in the state of its object file.

Here is the FastForth memory management, one of its major assets, with both hardware events and software equivalent:

*  RST_RET 
    
    *  when you type `RST_RET` the program beyond the last RST_SET is lost.

    *  Running a `MARKER` definition will remove it and the program beyond. In addition the user can link it a routine to remove the modified configuration in system: vectors, hardware, I/Os... 


*  WARM level : `SYS` -->(no PUC)--> INIT_FORTH --> INIT_HARD --> WARM display --> ABORT --> ACCEPT --> BACKGRND --> SLEEP.

    *  when you type `SYS`, FORTH restarts, the WARM display starts by #0. 
    
    *  when you type `+n SYS` (n>0, odd), the WARM display starts by #+n. 

        * same effect as RST_RET

        * words ACCEPT, EMIT, KEY are initialised with their default value,
    
        * TIB is initialised with its default value.


*  COLD level : `+n SYS` --> PUC --> INIT_FORTH --> INIT_HARD --> WARM display --> ABORT --> ACCEPT --> BACKGRND --> SLEEP.

    *  Power ON : the WARM display starts with the SYSRSTIV value #2.
    
    *  hardware `RST` : the WARM display starts with the SYSRSTIV value #6, because RST pin acts as NMI pin.
    
    *  SVSHIFG SVSH event (supply dropout) : the WARM display starts with the SYSRSTIV value: #14.

    *  PUC on failure : the WARM display starts with the SYSRSTIV value: #n.

    *  other `+n SYS` (n>0 and even) are software RESET : the WARM display starts with the SYSRSTIV value "#+n" (even).

        * same effects as WARM level, plus:

        * performs a PUC.

    

*  DEEP RESET level:

    *  `-n SYS` (n<0) performs the software Deep Reset, WARM display = #-n.
 
    *  hardware `SW1+RESET`, WARM display = #-1.
    
    *  recompiling FastForth, WARM display = #-3.

        * same effects as COLD level, plus:

        *  all programs donwloaded from the TERMINAL or from the SD_CARD are lost,

        *  COLD_APP, ABORT_APP, SOFT_APP, HARD_APP and BACKGND_APP default values are restored,

        *  all interrupts vectors are initialised with their default value, 

        *  SIGNATURES area is FFh full filled.


* ERROR : ABORT" your_text" --> INIT_FORTH --> display = "your_text" --> ABORT --> ACCEPT --> BACKGRND --> SLEEP. 
    
    *  when an error occurs, FASTFORTH discards the end of current downloading if any. In this way, any error is followed by the complete erasure of the bad defined word causing this error, and also by discarding the end of downloading of the source file including it. 


Once validate, it is strongly recommended to end any source file with `RST_SET` to protect the resulting program from a subsequent download error.

As all other FORTH words, `RST_SET` `RST_RET` and` MARKER` definitions may be freely used in compiling mode.    

If you have previously set `NOECHO`, there is no WARM display.

If you don't want to display an ABORT" message, type: `ABORT" "`

With I2C_FastForth version, WARM and `ABORT"` displays are preceded by the decimal I2C slave address, example: `@18`. 


## VOCABULARY ADD-ON

These words are not ANS94 compliant.

The CONTEXT stack is 8 word_set sized.

after typing: `WORDSET TRUC`   a new word-set called TRUC is created, then:

* `TRUC`            adds the word-set TRUC first in the CONTEXT stack, the interpreter search existing definitions first in TRUC

* `DEFINITIONS`     adds news definitions in the first word-set in the CONTEXT stack, i.e. TRUC,
* `PREVIOUS`        removes TRUC from CONTEXT but new definitions are still added in TRUC
* `DEFINITIONS`     new definitions are added into the previous first word-set in the CONTEXT stack,
*  after `-1 SYS`, FORTH is the CONTEXT and the CURRENT word-set.


## EMBEDDED ASSEMBLER

The preprocessor GEMA allows the embedded assembler to access all system variables. 
See files \\inc\\Target.pat. 

### HOW TO MIX assembly and FORTH ?

FAST FORTH knows two modes of definitions :

* high level FORTH definitions `: <name> ... ;`

* assembly low level definitions `CODE <name> ... ENDCODE`

there is also some variations of these two modes :

* high level definitions `NONAME: ... ;`

* low level definitions `CODENNM ... ENDCODE`, low-level equivalent of `NONAME:`
    
* low level definitions `HDNCODE <name> ... ENDCODE`, these definitions are 'hidden' and can be accessed only from assembly level.
    
Examples:
    
    : NOOP              \ FORTH definition "NOOP", does nothing
        DUP
        DROP
    ;


    CODE ADD            \ low level definition "ADD", alias of word +
        ADD @PSP+,TOS
        MOV @IP+,PC
    ENDCODE


    HDNCODE WDT_INT         \ low level hidden definition "WDT_INT" (Watchdog interrupt)
    BIT #8,&TERM_STATW      \ break (ALT+b) sent by TERMINAL ?
    0<> IF                  \ if yes
        MOV #ABORT,PC       \   continue with ABORT (no return)
    THEN
                            \ else return to background task SLEEP
    BIC #%0111_1000,0(RSP)  \ force CPU Active Mode, disable all interrupts
    RETI                    \
    ENDCODE
    
    
At the end of low level CODE definition, the instruction MOV @IP+,PC jumps to the next definition. 
This faster (4 cycles) and shorter (one word) instruction replaces the famous pair of assembly 
instructions : CALL #LABEL ... RET (4+4 cycles, 2+1 words).  
The register IP is the Interpretative Pointer. 

High level FORTH definitions starts with a boot code "DOCOL" which saves the IP pointer and loads it with the first address
of a list of execution addresses, then performs a postincrement branch to the first one. 
The list ends with the address of another piece of code: EXIT (6 cycles) which restores IP from stack before the instruction MOV @IP+,PC.

here, the compilation of low level ADD definition :

                    header          \ compiled by the word CODE
    execution addr  ADD @PSP+,TOS
                    MOV @IP+,PC     \ instruction called NEXT

and the one of the high level word NOOP :

                    header          \ compiled by the word :
    execution addr  PUSH IP         \ boot code "DOCOL"...
                    CALL rDOCOL     \ ...compiled by the word :
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
    exec@   PUSH IP             \ 
            CALL rDOCOL
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
    DOCOL   PUSH IP
            CALL rDOCOL         \ "DOCOL" compiled by COLON
            addr of word1
            addr of word2
            addr of EXIT        \ EXIT restores IP from stack then executes MOV @IP+,PC

A new step:

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

            header              \ )
    exec@   PUSH IP             \ > compiled by :
            CALL rDOCOL         \ )
            addr of word1
            addr of word2
            ...
            next addr           \ compiled by HI2LO
            MOV #0,IP           \ IP is free for use
            asm1                \ assembly instruction
            ...
            CALL rDOCOL         \ compiled by LO2HI
            addr of word3
            addr of word4
            addr of EXIT        \ compiled by ;

Still another step : 

        CODE MIX_ASM_FORTH_ASM  \ CODE starts a low level word
            asm1
            asm2
        COLON                   \ start high level definition
            word
            ... 
        HI2LO                   \ switch high to low level
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
        COLON                   \ starts high level definition
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
    DOCOL   PUSH IP             \ compiled... 
            CALL rDOCOL         \ ...by COLON
            addr
            addr
            next address        \ compiled by HI2LO
            asm
            asm
            CALL rDOCOL         \ compiled by LO2HI
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


FAST FORTH have one pass assembler, not able to resolve forward jumps.

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
until their new definition.

### SYMBOLIC ASSEMBLER ? YES !

I have discovered a little semantic preprocessor "GEMA", just like that FAST FORTH have its symbolic assembler !

* \inc\DEVICE.pat contains memory map and vectors for a specified DEVICE
* \inc\LAUNCHPAD.pat is the I/O config file for specific LAUNCHPAD (or application)

Gema translates FORTH registers in ASM registers (R0 to R15) via \inc\ThingsInFirst.pat

With the three bat files in \MSP430_FORTH folder all is done automatically.

### WHAT ABOUT VARIABLES, CONSTANTS...

In addition to the FORTH VARIABLE and CONSTANT definitions, the macroassembler allows to use symbolic variables and constants
which are compiled / executed as number by the FORTH interpreter, also by the assembler, but only in the scope of a source use.f file with their declaration done in a use.pat file.

On the other hand, the CONSTANT, VARIABLE and MARKER definitions are correctly handled by the assembler which provides for each case the expected argument: the constant, the address of the variable and the address of the first user variable with MARKER.

Example:

    VARIABLE BASE 
    $10 BASE !
    2 CONSTANT TWO
    MARKER {MYAPP}
    'ESC' , 'XON' C, 'XOFF' C,
    
    HDNCODE EXAMPLE         \ hidden definition to be linked in the hidden word-set
    CMP #RET_ADR,&{MYAPP}-2 \ compare content of {MYAPP}-2 address with RET_ADR
    MOV &BASE,X             \ X = 16
    MOV #BASE,X             \ X = address of base
    MOV @X,X                \ X = 16
    MOV #TWO,Y              \ Y = 2
    MOV &{MYAPP},W          \ W = $1B
    MOV.B &{MYAPP}+2,W      \ W = 17
    MOV.B &{MYAPP}+3,W      \ W = 19
    MOV @IP+PC
    ENDCODE

    CODE RUN_EXAMPLE
    MOV #EXAMPLE,PC         \ = BR EXAMPLE      runs EXAMPLE, without return
    ENDCODE


# COMPILE FAST FORTH FOR YOUR TARGET

1- in forthMSP430FR.asm "TARGET configuration"  create a line for your target, example:

    ;MY_MSP430FR5738_1 ; compile for my own MSP430FR5738 miniboard V1

2- create your \inc\MSP430FR5738_1.asm and \inc\MSP430FR5738.inc from another target.asm and device.inc as pattern, 
Notice that you must define here only the necessary for FAST-FORTH compilation.

3- in \inc\ThingsInFirst.inc add one "device.inc" item:

        .IFDEF MY_MSP430FR5738_1
    UCA0_UART   ; defines uart used for TERMINAL 
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

Here you have a good overview of MSP430 assembly:
[MSP430 ISA](http://www.ece.utep.edu/courses/web3376/Notes_files/ee3376-isa.pdf)

FastForth embedded assembler doesn't recognize the (useless) TI's symbolic addressing mode: ADD.B EDE,TONI.

REGISTERS correspondence (you can freely use ASM or TI or FASTFORTH registers's names).

        REG         TI      FASTFORTH   comment 
    
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
If you use them you may either `PUSHM #4,M` before and `POPM #4,M after`,
or use them directly then restore FastForth default values:

`MOV #INIT_DOXXX,X`  
`MOV @X+,rDOCOL`  
`MOV @X+,rDODOES`  
`MOV @X+,rDOCON`  
`MOV @X,rDOVAR`

(Search `INIT_DOXXX` in \inc\MSP430xxxx.pat)

If you want to restore only rDODOES, rDOCON and rDOVAR:

`MOV #INIT_DOXXX+2,X`  
`MOV @X+,rDODOES`  
`MOV @X+,rDOCON`  
`MOV @X,rDOVAR`

If you want to restore only rDODOES and rDOCON:

`MOV #XDODOES,rDODOES`  
`MOV #XDOCON,rDOCON`  

When you use these registers you can't call any FORTH words using them at the same time! 

don't use R3 and use R2 (SR) only with BIC, BIT, BIS instructions in register mode.

The bits 0-11 of SR register are saved by interrupts and restored by the instruction RETI.
you can use freely UF9 UF10 and UF11 as SR bits 9-11. 
FastForth uses UF9 for double numbers interpreting and also by TO ... VALUE.
    

**PARAMETERS STACK**

The register TOS (Top Of Stack) is the first cell of the Parameters stack. 
The register PSP (Parameters Stack Pointer) points the second cell.

to push one cell on the PSP stack :

    SUB #2,PSP                  \ insert a empty 2th cell
    MOV TOS,0(PSP)              \ fill this 2th cell with first cell
    MOV(.B) <what you want>,TOS \ i.e. update first cell

to pop one cell from the PSP stack :

    MOV @PSP+,TOS               \ first cell TOS is lost and replaced by the 2th.

don't never pop a byte with instruction MOV.B @PSP+, because it generates a stack misalignement...

**RETURN STACK**

register RSP is the Return Stack Pointer (SP).

to push one cell on the RSP stack: `PUSH <what you want>`

to pop one cell from the RSP stack: `MOV @RSP+,<where you want>`

don't never push or pop a byte on RSP stack !


to push multiple registers on the RSP stack :

`PUSHM #n,Rx`,  with 0 <= x-(n-1) < 16

to pop multiple registers from the RSP stack :

`POPM #n,Rx`,  with 0 <= x-(n-1) < 16

    PUSHM order : PSP,TOS, IP, S , T , W , X , Y ,rDOVAR,rDOCON,rDODOES,rDOCOL, R3, SR,RSP, PC
    PUSHM order : R15,R14,R13,R12,R11,R10, R9, R8,  R7  ,  R6  ,  R5   ,  R4  , R3, R2, R1, R0

example : `PUSHM #6,IP` pushes IP,S,T,W,X,Y registers to return stack

    POPM  order :  PC,RSP, SR, R3,rDOCOL,rDODOES,rDOCON,rDOVAR, Y , X , W , T , S , IP,TOS,PSP
    POPM  order :  R0, R1, R2, R3,  R4  ,  R5   ,  R6  ,   R7 , R8, R9,R10,R11,R12,R13,R14,R15

example : `POPM #6,IP` pulls Y,X,W,T,S,IP registers from return stack

Error occurs if #n is out of bounds.

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

    RETURN-STACK-CELLS  = 48            max size of the return stack, in cells  
    STACK-CELLS         = 48            max size of the data stack, in cells  
    /COUNTED-STRING	 = 255              max size of a counted string, in characters  
    /HOLD	           = 34            size of the pictured numeric output string buffer, in characters  
    /PAD	            = 84            size of the scratch area pointed to by PAD, in characters  
    ADDRESS-UNIT-BITS   = 16            size of one address unit, in bits
    FLOORED	         = true             true if floored division is the default
    MAX-CHAR	        = 255           max value of any character in the implementation-defined character set
    MAX-N               = 32767         largest usable signed integer  
    MAX-U               = 65535         largest usable unsigned integer  
    MAX-D	           = 2147483647     largest usable signed double number  
    MAX-UD              = 4294967295    largest usable unsigned double number  
    DeFiNiTiOnS aRe CaSe-InSeNsItIvE    they are compiled in their CAPS_ON form.

## FORTH word-set

Reduced to 53 definitions, but with everything necessary to be expandable up to $FF80.

RST_SET,
RST_RET,
[MARKER     ](https://forth-standard.org/standard/core/MARKER),
HI2LO,
CODENNM,
HDNCODE,
CODE,
[IS         ](https://forth-standard.org/standard/core/IS),
[\:NONAME   ](https://forth-standard.org/standard/core/ColonNONAME),
[DOES>      ](https://forth-standard.org/standard/core/DOES),
[CREATE     ](https://forth-standard.org/standard/core/CREATE),
[IMMEDIATE  ](https://forth-standard.org/standard/core/IMMEDIATE),
[;          ](https://forth-standard.org/standard/core/Semi),
[:          ](https://forth-standard.org/standard/core/Colon),
[POSTPONE   ](https://forth-standard.org/standard/core/POSTPONE),
[\\         ](https://forth-standard.org/standard/core/bs),
[\]         ](https://forth-standard.org/standard/core/right-bracket),
[\[         ](https://forth-standard.org/standard/core/Bracket),
[\[\'\]     ](https://forth-standard.org/standard/core/BracketTick),
[\'         ](https://forth-standard.org/standard/core/Tick),
[ABORT"     ](https://forth-standard.org/standard/core/ABORTq),
[ALLOT      ](https://forth-standard.org/standard/core/ALLOT),
[COUNT      ](https://forth-standard.org/standard/core/COUNT),
[LITERAL    ](https://forth-standard.org/standard/core/LITERAL),
[,          ](https://forth-standard.org/standard/core/Comma),
[>NUMBER    ](https://forth-standard.org/standard/core/toNUMBER),
[FIND       ](https://forth-standard.org/standard/core/FIND),
[WORD       ](https://forth-standard.org/standard/core/WORD),
[."         ](https://forth-standard.org/standard/core/Dotq),
[S"         ](https://forth-standard.org/standard/core/Sq),
[.          ](https://forth-standard.org/standard/core/d),
[U.         ](https://forth-standard.org/standard/core/Ud),
[SIGN       ](https://forth-standard.org/standard/core/SIGN),
[HOLD       ](https://forth-standard.org/standard/core/HOLD),
[#>         ](https://forth-standard.org/standard/core/num-end),
[#S         ](https://forth-standard.org/standard/core/numS),
[#          ](https://forth-standard.org/standard/core/num),
[<#         ](https://forth-standard.org/standard/core/num-start),
[\[UNDEFINED\]  ](https://forth-standard.org/standard/tools/BracketUNDEFINED),
[\[DEFINED\]    ](https://forth-standard.org/standard/tools/BracketDEFINED),
[\[IF\]         ](https://forth-standard.org/standard/tools/BracketIF),
[\[THEN\]       ](https://forth-standard.org/standard/tools/BracketTHEN)
[\[ELSE\]       ](https://forth-standard.org/standard/tools/BracketELSE),
[!          ](https://forth-standard.org/standard/core/Store),
[@          ](https://forth-standard.org/standard/core/Fetch),
[TYPE       ](https://forth-standard.org/standard/core/TYPE),
NOECHO,
ECHO,
[EMIT       ](https://forth-standard.org/standard/core/EMIT),
[KEY        ](https://forth-standard.org/standard/core/KEY),
[ACCEPT     ](https://forth-standard.org/standard/core/ACCEPT),
SYS.

Words ACCEPT KEY EMIT are DEFERred definitions. ACCEPT doesn't use KEY.

    RST_SET         defines the bound of the program memory protected against any PUC.  
    RST_RET         removes all words defined after RST_SET.  
    HI2LO           used to switch compilation from high level (FORTH) to low level (assembler).
    CODENNM         the assembler counterpart of :NONAME.
    CODE <name>     creates a definition written in assembler.
                    this defined <name> must be ended with ENDCODE unless COLON or LO2HI use. 
    HDNCODE <name>  same as CODE but the definition is in the hidden word-set to be visible only in the assembly mode.
    NOECHO          disables display on the TERMINAL  
    ECHO            enables display on the TERMINAL
    SYS             0 SYS | SYS   executes WARM
                    +n (odd) SYS  same,
                    +n (even) SYS does software RESET then executes WARM 
                    -n SYS        same as +n (even) SYS, plus resets the program memory to its original state.

### Other constants/addresses which are usable in any generic source_files.f

**All constants, variables and definitions included in \inc\any.pat files are usable by
the assembler and also by the FORTH interpreter.**


## MSP430ASSEMBLER word-set (in the hidden word-set)

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
[RRC, RRC.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=174),
[SUB, SUB.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=179),
[SUBC, SUBC.B   ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=180),
[SWPB           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=181),
[SXT            ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=182),
[XOR, XOR.B     ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=184),
[RRUM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=218),
[RLAM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=208),
[RRAM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=211),
[RRCM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=214),
[POPM           ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=204),
[PUSHM          ](http://www.ti.com/lit/ug/slau272d/slau272d.pdf#page=205),
?GOTO,
GOTO, 
BW3, 
BW2,
BW1,
FW3,
FW2,
FW1,
REPEAT,
WHILE,
AGAIN,
UNTIL,
ELSE,
THEN,
IF,
0=,
0<>,
U>=,
U<,
0<,
0>=,
S<,
S>=,
LO2HI,
COLON,
ENDCODE.

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
    LO2HI           switches compilation from low level to high level modes without saving IP register.  
    COLON           pushes IP then performs LO2HI.
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

### VOCABULARY ADD-ON

[DEFINITIONS     ](https://forth-standard.org/standard/search/DEFINITIONS),
[PREVIOUS        ](https://forth-standard.org/standard/search/PREVIOUS),
ONLY,
FORTH,
WORDSET.

    FORTH               adds FORTH as first CONTEXT word-set  
    FORTH ONLY          clears the CONTEXT stack, same as `-1 SYS`
    WORDSET <name>      creates a new word-set named <name>
    <name>              adds this named word-set in the CONTEXT stack


### SD_CARD_LOADER ADD-ON

    LOAD" SD_TEST.4TH"  loads source file SD_TEST.4TH from SD_Card and compile it.
    BOOT                enable bootstrap
    NOBOOT              disable bootstrap

Once bootloader is enabled, any PUC event loads (and executes) the file \BOOT.4TH from the SD_Card.

### SD_CARD_READ_WRITE ADD-ON

    TERM2SD"        TERM2SD" SD_TEST.4TH" copy SD_TEST.4TH file to SD_CARD (use CopySourceFileToTarget_SD_Card.bat to do)
    WRITE           write sequentially the content of SD_buf to a file
    READ            read sequentially a file in SD_buf, leave a flag, false when the file is automatically closed.
    CLOSE           close last opened file.
    DEL" TRUC"      remove quietly the file TRUC from SD_CARD.
    WRITE" TRUC"    create or overwrite a file TRUC ready to write to its beginning.
    APPEND" TRUC"   open or create a file TRUC ready to write to the end of this file
    READ" TRUC"     open TRUC and load its first sector in SD_buf
    WR_SECT         Write SD_BUF in Sector loaded in  W=lo:X=hi
    RD_SECT         Read Sector W=lo:X=hi into SD_BUF, set BufferPtr=0


## OPTIONNAL ADD-ON

* Their respective MARKER word identified with braces {} removes all subsequent words.  
  Sources are in the folder \MSP430-FORTH\, as source.f file.

### ANS_COMP

Adds complement to pass FORTH ANS94 core test.

[VALUE      ](https://forth-standard.org/standard/core/VALUE),
[TO         ](https://forth-standard.org/standard/core/TO),
[DEFER      ](https://forth-standard.org/standard/core/DEFER),
[BEGIN      ](https://forth-standard.org/standard/core/BEGIN),
[SPACES     ](https://forth-standard.org/standard/core/SPACES),
[SPACE      ](https://forth-standard.org/standard/core/SPACE),
[BL         ](https://forth-standard.org/standard/core/BL),
[PAD        ](https://forth-standard.org/standard/core/PAD),
[>IN        ](https://forth-standard.org/standard/core/toIN),
[BASE       ](https://forth-standard.org/standard/core/BASE),
[STATE      ](https://forth-standard.org/standard/core/STATE),
[CONSTANT   ](https://forth-standard.org/standard/core/CONSTANT),
[VARIABLE   ](https://forth-standard.org/standard/core/VARIABLE),
[SOURCE     ](https://forth-standard.org/standard/core/SOURCE),
[RECURSE    ](https://forth-standard.org/standard/core/RECURSE),
[EVALUATE   ](https://forth-standard.org/standard/core/EVALUATE),
[EXECUTE    ](https://forth-standard.org/standard/core/EXECUTE),
[>BODY      ](https://forth-standard.org/standard/core/toBODY),
[.(         ](https://forth-standard.org/standard/core/Dotp),
[(          ](https://forth-standard.org/standard/core/p),
[DECIMAL    ](https://forth-standard.org/standard/core/DECIMAL),
[HEX        ](https://forth-standard.org/standard/core/HEX),
[HERE       ](https://forth-standard.org/standard/core/HERE),
[FILL       ](https://forth-standard.org/standard/core/FILL),
[MOVE       ](https://forth-standard.org/standard/core/MOVE),
[+!         ](https://forth-standard.org/standard/core/PlusStore),
[[CHAR]     ](https://forth-standard.org/standard/core/BracketCHAR),
[CHAR       ](https://forth-standard.org/standard/core/CHAR),
[CELL+      ](https://forth-standard.org/standard/core/CELLPlus),
[CELLS      ](https://forth-standard.org/standard/core/CELLS),
[CHAR+      ](https://forth-standard.org/standard/core/CHARPlus),
[CHARS      ](https://forth-standard.org/standard/core/CHARS),
[ALIGN      ](https://forth-standard.org/standard/core/ALIGN),
[ALIGNED    ](https://forth-standard.org/standard/core/ALIGNED),
[2OVER      ](https://forth-standard.org/standard/core/TwoOVER),
[2SWAP      ](https://forth-standard.org/standard/core/TwoSWAP),
[2DROP      ](https://forth-standard.org/standard/core/TwoDROP),
[2DUP       ](https://forth-standard.org/standard/core/TwoDUP),
[2!         ](https://forth-standard.org/standard/core/TwoStore),
[2@         ](https://forth-standard.org/standard/core/TwoFetch),
[R@         ](https://forth-standard.org/standard/core/RFetch),
[ROT        ](https://forth-standard.org/standard/core/ROT),
[OVER       ](https://forth-standard.org/standard/core/OVER),
[*/         ](https://forth-standard.org/standard/core/TimesDiv),
[*/MOD      ](https://forth-standard.org/standard/core/TimesDivMOD),
[MOD        ](https://forth-standard.org/standard/core/MOD),
[/          ](https://forth-standard.org/standard/core/Div),
[/MOD       ](https://forth-standard.org/standard/core/DivMOD),
[*          ](https://forth-standard.org/standard/core/Times),
[FM/MOD     ](https://forth-standard.org/standard/core/FMDivMOD),
[ABS        ](https://forth-standard.org/standard/core/ABS),
[NEGATE     ](https://forth-standard.org/standard/core/NEGATE),
[SM/REM     ](https://forth-standard.org/standard/core/SMDivREM),
[UM/MOD     ](https://forth-standard.org/standard/core/UMDivMOD),
[M*         ](https://forth-standard.org/standard/core/MTimes),
[UM*        ](https://forth-standard.org/standard/core/UMTimes),
[2/         ](https://forth-standard.org/standard/core/TwoDiv),
[2*         ](https://forth-standard.org/standard/core/TwoTimes),
[MIN        ](https://forth-standard.org/standard/core/MIN),
[MAX        ](https://forth-standard.org/standard/core/MAX),
[RSHIFT     ](https://forth-standard.org/standard/core/RSHIFT),
[LSHIFT     ](https://forth-standard.org/standard/core/LSHIFT),
[INVERT     ](https://forth-standard.org/standard/core/INVERT),
[1-         ](https://forth-standard.org/standard/core/OneMinus),
[1+         ](https://forth-standard.org/standard/core/OnePlus),
[S>D        ](https://forth-standard.org/standard/core/StoD),
[XOR        ](https://forth-standard.org/standard/core/XOR),
[OR         ](https://forth-standard.org/standard/core/OR),
[AND        ](https://forth-standard.org/standard/core/AND),
[LEAVE      ](https://forth-standard.org/standard/core/LEAVE),
[UNLOOP     ](https://forth-standard.org/standard/core/UNLOOP),
[J          ](https://forth-standard.org/standard/core/J),
[I          ](https://forth-standard.org/standard/core/I),
[+LOOP      ](https://forth-standard.org/standard/core/PlusLOOP),
[LOOP       ](https://forth-standard.org/standard/core/LOOP),
[DO         ](https://forth-standard.org/standard/core/DO),
[REPEAT     ](https://forth-standard.org/standard/core/REPEAT),
[WHILE      ](https://forth-standard.org/standard/core/WHILE),
[AGAIN      ](https://forth-standard.org/standard/core/AGAIN),
[UNTIL      ](https://forth-standard.org/standard/core/UNTIL),
[THEN       ](https://forth-standard.org/standard/core/THEN),
[ELSE       ](https://forth-standard.org/standard/core/ELSE),
[IF         ](https://forth-standard.org/standard/core/IF),
[>          ](https://forth-standard.org/standard/core/more),
[<          ](https://forth-standard.org/standard/core/less),
[U<         ](https://forth-standard.org/standard/core/Uless),
[=          ](https://forth-standard.org/standard/core/Equal),
[0<         ](https://forth-standard.org/standard/core/Zeroless),
[0=         ](https://forth-standard.org/standard/core/ZeroEqual),
[C,         ](https://forth-standard.org/standard/core/CComma),
[C!         ](https://forth-standard.org/standard/core/CStore),
[C@         ](https://forth-standard.org/standard/core/CFetch),
[R>         ](https://forth-standard.org/standard/core/Rfrom),
[>R         ](https://forth-standard.org/standard/core/toR),
[NIP        ](https://forth-standard.org/standard/core/NIP),
[DROP       ](https://forth-standard.org/standard/core/DROP),
[SWAP       ](https://forth-standard.org/standard/core/SWAP),
[DEPTH      ](https://forth-standard.org/standard/core/DEPTH),
[EXIT       ](https://forth-standard.org/standard/core/EXIT),
[?DUP       ](https://forth-standard.org/standard/core/qDUP),
[DUP        ](https://forth-standard.org/standard/core/DUP),
[-          ](https://forth-standard.org/standard/core/Minus),
[+          ](https://forth-standard.org/standard/core/Plus),
[CR         ](https://forth-standard.org/standard/core/CR).


### FIXPOINT

S>F,
F.,
F*,
F#S,
F/,
F-,
F+,
[HOLDS          ](https://forth-standard.org/standard/core/HOLDS).

    S>F             u/n -- Qlo Qhi       convert u/n in a Q15.16 value
    F.              display a Q15.16 value
    F*              Q15.16 multiplication  
    F#S             Qlo Qhi u -- Qhi 0    
                    convert fractionnal part of a Q15.16 value displaying u digits
    F/              Q15.16 division        
    F-              Q15.16 soustraction
    F+              Q15.16 addition


### UTILITY

[DUMP           ](https://forth-standard.org/standard/tools/DUMP), 
[U.R            ](https://forth-standard.org/standard/core/UDotR),
[WORDS          ](https://forth-standard.org/standard/tools/WORDS),
[?              ](https://forth-standard.org/standard/tools/q), 
[.S             ](https://forth-standard.org/standard/tools/DotS),
.RS.

    .RS             displays Return Stack content  

### SD_TOOLS

    DIR             dump first sector of current directory  
    FAT             dump first sector of FAT1  
    CLUSTER.        .123 CLUSTER. displays first sector of cluster 123  
    SECTOR.         .123456789 SECTOR. displays sector 123456789  

### DOUBLE word set (ANS94 compliant)

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
* set executable flag in permission of this file
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



