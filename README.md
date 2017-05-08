Fast Forth For MSP430FRxxxx TI's devices
========================================


FAST FORTH is the Swiss Army knife you need for your MSP430FRxxxx.
Usable with all the TI LaunchPads MSP430 FRAM and all MSP430FRxxxx, without moderation!

	With its embedded assembler the size of FAST FORTH is < 6 kb, else: 4kb.
    With SD_CARD file Load|Read|Write|Delete, plus a direct file transfer from PC to SD_CARD, its size is under 9Kb.
    Excepted MSP430FR4133, because no hardware multiplier, works with SD CARD memories from 64MB to 64GB.
    This enable to make a data logger with a small MSP430FR5738 QFN24 and its RTC and 24MHz SPI CLK. 

	Fully tested on MSP-EXP430FR5969, FR5994, FR6989, FR4133 launchpads and CHIPSTICKFR2433, at 0.5, 1, 2, 4, 8, 16 MHz,
    plus 24MHz on a MSP430FR5738 module.

	Files launchpad_3Mbd.txt are 16threads vocabularies 16MHz executables, with 3MBds, XON/XOFF terminal,
    Launchpad_115200.txt files are same except 115200Bds for unlucky linux men without TERATERM.    
    For the launchpad MSP-EXP430FR5994 with SD_CARD, full version with SD_Card driver is available.
	For others, you must before compile forthMSP430FR.asm with SD_CARD_LOADER and
    SD_CARD_READ_WRITE switches turned ON (uncomment their line).

    Once the Fast Forth binary is loaded into the target's FRAM memory, you add assembly code or FORTH code, or both,
    by downloading source files that Fast Forth can interpret and compile. The download channel consists of the TERATERM program
    on the PC side (the Fast Forth input terminal), and a USB-UART bridge (PL2303TA cable) that you connect between your PC
    and your target.
    
    Once your source files (files.f) in symbolic assembler are written, 
    the preprocessor GEMA translates them into Fast Forth source files (files.4th) ready to download, by
    using .pat files (equivalent to the C files.h).
    A set of .bat files is furnished to do this automatically. See it all in the MSP430-FORTH folder.

	The download, interpretation and compilation of a file.4th is done at a throughput of 40/80/120 kbytes/sec
    with a 8/16/24 MHz clock. Considering a ratio 5/1, that of the compiled code is 8/16/24 kbytes/sec. 
    To compare with the 8kbytes/s of the FlashPro-MSP programmer in SBW mode.

    After downloading of complementary words in COMPxMPY.f, FastForth executes CORETEST.4th without errors
    which ensures its compatibility with the FORTH ANS94 standard.
    For MSP430FR4133 choose COMPSMPY.f, for all other COMPHMPY.f.

    Notice that FAST FORTH interprets only SPACE as delimiter (not TAB), BACKSPACE, and CR+LF (not LF) as end of line.

    Finally, if you use the scite editor you can do everything from its "tools" menu.

What is new ?
-------------

	FAST FORTH V160, major version.

    Accept SD_Card from 64 MB (FAT16) up to 64 GB (FAT32). 
    Note that Windows 10 no longer offers the FAT32 format for the highest sizes of SD_CARD memory.
    So you must use an alternative to do, for example: https://www.partitionwizard.com.
    
    Added an extension for 32 bits numbers and the words D. UD. to display them.
        Typed numbers > 65535 or < -32768 are automatically processed as 32 bits numbers,
        and to force a typed number of 16 bits to 32 bits, insert a decimal point.
        Example :   $-12 is processed as 16 bits negative number.
                    $-.12 or $-1.2 or $-12. are processed as 32 bits negative numbers.
    
    in SD_TOOLS the word SECT_D (dump sector) use a 32 bits number.
                added the word CLUST_D (dump first sector of a cluster). Usage (notice the point): number. CLUST_D


    PREVIOUS versions
	
    Added direct file.4th transfer of PC to target SD_CARD. 
    Measured speed: 90 kbytes/s at 3Mbauds and 16MHz target clock, with "HCI" SD CARD.
    You can do it from scite editor (menu Tools) or by using specific bat files.
    Double click on these to see how to do.
	
    JTAG and BSL signatures (FF80h-FF88h) are protected against overwrite, typically during source file download. 
    
    added signed number prefixes $ (hex), % (bin) and # (decimal) to supersede current BASE.

	Added words ASM and ENDASM to create assembler words that are not interpretable by FORTH
    i.e. that are called by {CALL|INTERRUPT} and ended by {RET|RETI}. These so created words can be used only in ASSEMBLER context.

	In the embedded assembler, added 3 backward BW1 BW2 BW3 and 3 forward FW1 FW2 FW3 jump labels to use with GOTO, ?GOTO.
    These labels are for single use (one jump for one label).
	
	you can compile up to 32 threads vocabularies ==> interpretation time is divided by sqrt(threads).

	In root folder you can program files *.txt to any target by using drag and drop on their respective file.bat, 
	The same applies to MSP430-FORTH\source files .f and .4th to any target by using drag and drop. 
	Double click on these files.bat to see how to do.

	Memory management :
	Fast Forth defines 4 levels of programm memory :
		WIPE that resets programm memory as txt file was,
		RST_HERE / RST_STATE that set / reset the boundary of program protected against <reset>,
		PWR_HERE / PWR_STATE that set / reset the boundary of program protected against power ON/OFF,
		and nothing, i.e. volatile memory.

	You can download source files with hardware or software control flow (i.e. without line or char delays) up to:
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

    You can select mode LPM{0,1,2,3,4} in your application, depending of family, FR2xxx : LPM0,
    FR57xx : LPM0 to 2, FR59xx : LPM0 to 4.

    DEEP_RST (RESET + WIPE) can be hardware performed via the programmation interface (Vcc,RX,TX,RST,TEST,GND).


Many thanks to Brad Rodriguez
-----------------------------

for his CamelForth which served me as a kind of canvas.

Unlike CamelForth this FORTH is a "Direct Threaded Code", with an embedded assembler following the standard syntax,
not the one used in the world Forth.

Its core is fully compliant with the standard ANS.

This is a FORTH optimized for the speed, especially in the interpreter mode, so that you can load an application program written in FORTH/Assembler faster than its binary via MSP430 Flasher.exe : everything can be done from your text editor, the preprocessor and a serial terminal.

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

With a size about 5.5 kb (enhanced version with vocabularies 16 threads), Fast Forth contains 111 words:

    COLD            WARM            (WARM)          WIPE            RST_HERE        RST_STATE       PWR_HERE        PWR_STATE    
    MOVE            LEAVE           +LOOP           LOOP            DO              REPEAT          WHILE           AGAIN        
    UNTIL           BEGIN           THEN            ELSE            IF              POSTPONE        [']             IS           
    IMMEDIATE       ;               :               RECURSE         ]               [               DEFER           DOES>        
    CREATE          CONSTANT        VARIABLE        \               '               ABORT"          ABORT           QUIT         
    EVALUATE        COUNT           LITERAL         ,               EXECUTE         >NUMBER         FIND            WORD         
    ."              S"              TYPE            SPACES          SPACE           CR              (CR)            NOECHO       
    ECHO            EMIT            (EMIT)          ACCEPT          KEY             (KEY)           C,              ALLOT        
    HERE            .               D.              U.              UD.             SIGN            HOLD            #>           
    #S              #               <#              BL              STATE           BASE            >IN             J            
    I               UNLOOP          U<              >               <               =               0<              0=           
    ABS             NEGATE          XOR             OR              AND             -               +               C!           
    C@              !               @               DEPTH           R@              R>              >R              ROT          
    OVER            SWAP            DROP            ?DUP            DUP             LIT             EXIT

...size that includes its embedded assembler of 73 words:

    ?GOTO           GOTO            FW3             FW2             FW1             BW3             BW2             BW1          
    ?JMP            JMP             REPEAT          WHILE           AGAIN           UNTIL           ELSE            THEN         
    IF              0=              0<>             U>=             U<              0<              0>=             S<           
    S>=             RRUM            RLAM            RRAM            RRCM            POPM            PUSHM           CALL         
    PUSH.B          PUSH            SXT             RRA.B           RRA             SWPB            RRC.B           RRC          
    AND.B           AND             XOR.B           XOR             BIS.B           BIS             BIC.B           BIC          
    BIT.B           BIT             DADD.B          DADD            CMP.B           CMP             SUB.B           SUB          
    SUBC.B          SUBC            ADDC.B          ADDC            ADD.B           ADD             MOV.B           MOV          
    RETI            LO2HI           COLON           ENDASM          ENDCODE         ASM             CODE            HI2LO        
    ASSEMBLER   

...everything you need to program effectively in assembly or FORTH or mix, as you want. See examples in \MSP430-FORTH folder.

VOCABULARY ADD-ON swith in forthMSP430.asm adds:

    DEFINITIONS     ONLY            PREVIOUS        ALSO            FORTH           VOCABULARY   
<<<<<<< HEAD

SD\_CARD\_LOADER ADD-ON swith in forthMSP430.asm adds:

=======

SD\_CARD\_LOADER ADD-ON swith in forthMSP430.asm adds:

>>>>>>> 4f83c2458a3d0b038b9a82e6290d4818d9ce3447
    LOAD"           (ACCEPT)     

SD\_CARD\_READ\_WRITE ADD-ON swith in forthMSP430.asm adds:

    TERM2SD"        SD_EMIT         WRITE           WRITE"          READ            READ"           CLOSE           DEL"         

external ANS\_COMPLEMENT in COMPHMPY.f or COMPSMPY.f adds:

    >BODY           SOURCE          .(              (               DECIMAL         HEX             FILL            +!           
    [CHAR]          CHAR            CELL+           CELLS           CHAR+           CHARS           ALIGN           ALIGNED      
    2OVER           2SWAP           2DROP           2DUP            2!              2@              */              */MOD        
    MOD             /               /MOD            *               FM/MOD          SM/REM          UM/MOD          M*           
    UM*             S>D             NIP             2/              2*              MIN             MAX             1-           
    1+              RSHIFT          LSHIFT          INVERT          
  
external SD\_TOOLS ADD-ON in SD\_TOOLS.f adds:

    DIR_D           FAT_D           CLUST_D         SECT_D          DUMP            U.R             MIN          
    MAX             WORDS           .S              SP@             ?


Organize your gitlab copy of FastForth
-------

download zip of last version

copy it to a subfolder, i.e. FastForth, created in your user folder

right clic on it to share it with yourself.

remember its shared name i.e. : //myPC/users/my/FastForth.

in file explorer then right clic on root to connect a network drive, copy shared name in drive name and choose a free drive letter a:, b: ...

Thus all relative paths will be linked to this drive, except the files.bat links in the folder \MSP430-forth.
For all of them right clic select, select properties then check drive letter in target.

WARNING! if you erase a file directly in this drive or in one of its subfolders, no trash, the file is lost!



Minimal Software
--

If you are under WINDOWS :

	First, you download the TI's programmer from TI : http://www.ti.com/tool/MSP430-FLASHER.
	And the MSP430Drivers : 
	http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSP430_FET_Drivers/latest/index_FDS.html

	The next tool is TERATERM.EXE : http://logmett.com/index.php?/products/teraterm.html.
	
	As scite is my editor, this github repository is fully configured for scite users.
    download the single file executable called sc1 (not the full download) :
    http://www.scintilla.org/SciTEDownload.html, then save it as \prog\wscite\scite.exe.

	download GEMA preprocessor : https://sourceforge.net/projects/gema/files/gema/gema-1.4-RC/

	The MacroAssembler AS :	http://john.ccac.rwth-aachen.de:8000/as/

	and Srecord : http://srecord.sourceforge.net/download.html to convert HEX file to TI TXT files.

	copy last 3 items onto their respective \prog subfolder. 

	ask windows to open .asm, .inc, lst, .map, .4th, .f files with scite.exe
	

If you are linux or OS X men, sorry...


Build the program file
----------------------
 

\forthMSP430FR.asm is the main file to compile FastForth. It calls :	

	- mspregister.mac that defines the TI symbolic instructions,
	- TargetMap.inc that defines for each device the eUSCI used as Terminal
	  and then selects the declarations file family.map, 
	- ForthThreads.mac in case of multithread vocabularies,
	- optionally, forthMSP430FR_SD.asm file(s) for SD_Card,
	- optionally, forthMSP430FR_ASM.asm for assembler,
	- TargetInit.asm that selects the target.asm,
	- and then TERMINALBAUDRATE.asm.

open it with scite

uncomment the target as you want, i.e. MSP_EXP430fr5969

choose frequency, baudrate, UART handshake.

uncomment options switches as your convenience.

save file.

assemble (CTRL+0). A window asks you for 4 parameters:

set device as first param, i.e. MSP430FR5969,

set your target as 2th param, i.e. MSP_EXP430fr5969,

then execute. the output is a target.txt file.



Load Txt file (TI format) to target
-----------------------------------

	drag your target.txt file and drop it on TARGETprog.bat

    or use scite internal command TOOLS:FET prog (CTRL+1).

nota : programming the device use SBW2 interface, so UART0 is free for serial terminal use.

If you want to program your own MSP430FRxxxx board, wire its pins TST, RST, 3V3 and GND to same pins of the launchpad, on eZ-FET side of the programming connector.



Connect the FAST FORTH target to a serial terminal
-------------------------------------------------

you will need an USBtoUART cable with a PL2303TA or PL2303HXD device that allows XON/XOFF control flow :

	http://www.google.com/search?q=PL2303TA
    http://www.prolific.com.tw/UserFiles/files/PL2303_Prolific_DriverInstaller_v1_14_0.zip

or USBtoUART bridge, with a CP2102 device that allows XON/XOFF control flow :

	http://www.google.com/search?q=cp2102+module+3.3V
	http://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx

you must program CP2102 device to access 1382400 and 1843200 bds rates :

	http://www.silabs.com/Support%20Documents/Software/install_USBXpress_SDK.exe
	http://www.silabs.com/Support%20Documents/TechnicalDocs/an169.pdf

or a USBtoUART bridge, with a FT232RL device for only hardware control flow:

	http://www.google.com/search?q=FT232RL+module+3.3V
  	http://www.ftdichip.com/Drivers/CDM/CDM%20v2.12.00%20WHQL%20Certified.exe


How to configure the connection ?
-------------------------------

1-    the best ! Launchpad UARTn  <--> USBtoUART bridge with cp2102|PL2303TA chipset <--> TERATERM

       UARTn <--> CP2102 module | PL2303TA cable
         TXn ---> RX    
         RXn <--- TX    
        (GND <--> GND)  
		WARNING! DON'T CONNECT 5V RED WIRE! 

      TeraTerm configuration : see DTCforthMSP430fr5xxx.asm

If you plan to supply your target vith a PL2303 cable, open its box to weld red wire onto 3.3V pad.

2-    Launchpad UARTn <--> USBtoUART bridge with FT232RL chipset <--> TERATERM
	  WARNING! buy a FT232RL module with a switch 5V/3V3 and select 3V3.
 
       UARTn <--> FT232RL module
         TXn ---> RX    
         RXn <--- TX    
         RTS ---> CTS    
        (GND <--> GND)     
		WARNING! select 3V3 ! 
		WARNING! DON'T CONNECT 5V ! 

      TeraTerm configuration : see DTCforthMSP430fr5xxx.asm


Send a source file to the FAST FORH target
------------------

Two .bat files are done in the folder \MSP430-FORTH that enable you to send any source file to any target.

See how to in the file \MSP430-FORTH\send\_source\_file\_to\_target\_readme.txt. Or double click on .bat file

you can also open any source file with scite, and do all via menu Tools.


SD_Card Load, Read, Write and Delete 
=============================================

First, hardware
---------------

If you have MSP-EXP430FR5994, nothing to do.

For the choice of a SD card socket be carefull : pin CD (Card Detect) must be present !

 	http://www.ebay.com/itm/2-PCS-SD-Card-Module-Slot-Socket-Reader-For-Arduino-MCU-/181211954262?pt=LH_DefaultDomain_0&hash=item2a3112fc56


the commands
------------

With the LOAD" pathame" command you load your source files from a SD_CARD memory in both execute and compile modes. Idem for READ", WRITE" and DEL" commands.

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
To read next sectors, use the command READ that loads the next sector in the buffer, and leaves on the stack a flag that is true when the EOF is reached. 
The file is automatically closed. See tstwords.4th for basic usage.

The variable BufferLen keep the count of bytes to be read (0 to 512).

If you want to anticipate the end, use the CLOSE command.

HowTo WRITE a file
---------------

	WRITE" path\filename.ext".

If the file does not exist, create it, else open it and set the write pointer at the end of the file, ready to append chars.

See example of use in \MSP430-forth\SD_TEST.f.

To overwrite an existing file: DEL" file" then  WRITE" file".

Use CLOSE to close the file.

HowTo delete a file
---------------

	DEL" path\filename.ext". If the file is not found, do nothing, no error.

HowTo change DIRectory
---------------

	READ" \misc". 		    \misc becomes the current folder.
	READ" ..\"    			parent folder becomes the current folder.
	READ" \"				Root becomes the current folder.

Drive letters are always ignored.

Downloading source file to SD_Card
------------------------------------------

to download a file.f/file.4th onto SD_CARD, use Send_file.f_to_SD_CARD_targe.bat/Send_file.4th_to_SD_CARD_targe.bat.
any file.f will be preprocessed by gema before sending to SD_CARD as file.4th.

Double click on one of this bat files to see how to do.


I2C DRIVERS
===========

The I2C\_Soft\_Master driver with normal/fast mode allows you to add then use any couple of pins to drive a bus I2C :

 - without use of eUSCI UCBx
 - I2C\_Soft\_MultiMaster driver : same plus detection collision
 - plus I2C\_Slave driver that uses the eUSCI UCBx hardware


Other interesting specificities :
=====

Management of vocabularies (not ANSI). VOCABULARY, DEFINITIONS, ONLY, ALSO, PREVIOUS, CONTEXT, CURRENT, FORTH, ASSEMBLER. 
In fact, it's the operation of the assembler that requires the vocabularies management.

Recognizing prefixed numbers %101011 (bin), $00FE (hex) and #220 (decimal).

CAPS ON/OFF add on

ECHO / NOECHO

The words DEFER and IS are implemented. CR, EMIT, KEY and WARM are deferred words.

Error messages are colored (reverse video on ANSI terminal).

Assembly jumps are as FORTH one's : IF, ELSE, THEN, BEGIN, AGAIN, UNTIL, WHILE.
Not canonical jumps are also available with JMP|?JMP to a defined word and GOTO|?GOTO to backward labels BW1 BW2 BW3 or forward labels FW1 FW2 FW3.
These labels are one use.
Switch  within definitions between FORTH and Assembly contexts with words HI2LO and LO2HI. See examples in the TstWords.f file. This is perhaps the most interesting feature for development...


The system is not responding ?
======

First, swich off then switch on. FORTH restarts as it was after the last PWR\_HERE command.

If the system is not restarted, press <reset> button on the MSP-EXP430FR5xxx ; FORTH restarts as it was after the last RST_HERE command.

If the system does not restart again, wire the TERMINAL TX pin to GND via 4k7 resistor then <reset> ; FORTH restarts as it is in the HEX file.
Equivalent word : COLD + WIPE.

Here is the FastForth init architecture :

	case 0 : when you type WARM, FORTH interpreter is restarted, no program lost. 
			 if ECHO is on, the WARM display is preceded by "0", else no display. 

	case 1 : Power ON ==> performs reset and the program beyond PWR_HERE is lost.
			 if ECHO is on, the WARM display is preceded by the SYSRSTIV value "2", else no display.

	case 1.1 : when you type PWR_STATE ==> the program beyond PWR_HERE is lost.


	case 2 : <reset>  ==> performs reset and the program beyond RST_HERE is lost.
		 	 if ECHO is on, the WARM display is preceded by the SYSRSTIV value "4", else no display.
	
	case 2.1 : when you type COLD (software reset) ==> same effects.
			   if ECHO is on, the WARM display is preceded by the SYSRSTIV value "6", else no display.

	case 2.2 : when you type RST_STATE ==> the program beyond RST_HERE is lost.


	case 3 : when you type WIPE ==> all programs donwloaded from the terminal or the SD_Card are lost.


	case 4 : TERM_TX wired to GND via 4k7 during <reset> = DEEP_RST ===> performs reset, and all programs donwloaded from the terminal or the SD_Card are lost.
             The WARM display is preceded by "-4". 
	
	case 4.1 : software reset on failure (SYSRSTIV = 0Ah | SYSRSTIV >= 16h) ===> same effects
			   The WARM display is preceded by the SYSRSTIV value.
	
	case 4.2 : writing -1 in SAVE_SYSRSTIV before COLD = software DEEP_RST ===> same effects
			   The WARM display is preceded by "-1".


If SD\_CARD extention and SD\_CARD memory with \BOOT.4TH included, the cases 1 to 4 start it after displaying of WARM message. 


EMBEDDED ASSEMBLER
======

With the preprocessor GEMA and the file MSP430FR\_FastForth.pat, the embedded assembler allows access to all system variables. See \\config\\gema\\MSP430FR\_FastForth.pat. You can also access to VARIABLE, CONSTANT or DOES type words in immediate (#), absolute (&) and indexed (Rx) assembly modes.

Clearly, after the instruction "MOV &BASE,R6", R6 equals the contents of the FORTH variable "BASE", and after "MOV #BASE,R6" R6 contains its address.

If you want to create a buffer of 8 bytes (4 words) :

	CREATE BUFFER_OUT 8 ALLOT
the access to this buffer is done by :

	MOV #BUFFER_OUT,R8
	MOV.B @R8,R9
with R8 as org address of the buffer.

Or by indexed addressing :

	MOV.B BUFFER_OUT(R8),R9
with R8 register as buffer pointer.

see TESTASM.4th in \MSP430-FORTH folder.

What is the interest of a very fast baud rate ?
---------------------

This seems obvious: you can edit a source program and then test it immediatly on the target: above, from my text editor, the download, compile and start are done in less than 1 sec.

VOCABULARY ADD-ON
====

These words are not ANS94 compliant, they are those of F83 standard.

For example, after loading SD_TOOLS add-on, you can type: ALSO ASSEMBLER WORDS PREVIOUS WORDS

    With ALSO ASSEMBLER, the vocabulary ASSEMBLER is added to the search CONTEXT thus the ASSEMBLER words become visible
    
    WORDS display the words of ASSEMBLER then those of FORTH,

    PREVIOUS remove the vocabulary ASSEMBLER form the CONTEXT, and the ASSEMBLER words become hidden,

    so the last WORDS display only FORTH words.

In the forthMSP430FR_ASM.asm, see the FORTH word CODE that add ASSEMBLER to the search CONTEXT and the ASSEMBLER word ENDCODE
 that remove ASSEMBLER from search CONTEXT. Thus, the assembler words can be used only between CODE and ENDCODE.

The CONTEXT can grow up to 6 vocabularies by using the word ALSO.

If you want add words to the assembler you must type: ALSO ASSEMBLER DEFINITIONS,
The vocabulary ASSEMBLER is added to the search CONTEXT as previously but also becomes the CURRENT vocabulary in which the new words will be stored.

Finally, FORTH ONLY DEFINITIONS limits the search CONTEXT to FORTH and the CURRENT vocabulary is FORTH. 
 

