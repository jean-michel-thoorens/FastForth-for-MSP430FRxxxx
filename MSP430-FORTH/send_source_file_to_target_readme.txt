you have downloaded your copy of gitlab fast forth onto a folder shared and connected as virtual drive (A: or B: or ... or Y: or Z:)
    so config files.pat for the preprocessor gema.exe are in the folder \config\gema\
    and batch file are in the folder \config\scite\msp430_as\,
you have installed the last version of teraterm,
you have installed the last version of gema.exe in the folder \prog\gema\.

finally, edit properties of these three shortcuts "send_file.f_to_target.bat", "send_file.4th_to_target.bat file" and
process_file.f_to_file.4th.bat to change the drive letter B: as yours.

before sending a file :
=====================
    teraterm must be well configured, and its config must be saved,
    i.e. you must see the FAST FORTH prompt "ok" when you type <return> on the teraterm terminal. (you can then close the teraterm window).


to send a file.f to a specific target :
=====================================
  1 clic on the what_you_want.f file                example : utility.f
  2 ctrl+clic on the what_you_want.pat file         example : MSP_EXP430FR5969.pat (target = MSP_EXP430FR5969 launchpad)
  3 release ctrl and clic
  4 then drag and drop the what_you_want.f file onto the send_file.f_to_target.bat file
                                         -                         -
the *.pat files are used by the preprocesor GEMA.exe to translate symbolic labels from *.f files in their values to *.4th files.

to send a file.4th to any target :
================================
  drag and drop the what_you_want.4th file onto the send_file.4th_to_target.bat file      example : coretest.4th
                                  ---                         ---

to preprocess file.f to file.4th (debug) :
========================================
do same as to send a file.f, but with process_file.f_to_file.4th.bat


To send a file to be written on SD_CARD target, process with the specific SD_CARD_target.bat.
When TERATERM ask you for file to send, you can add a path to the file to be written on SD_CARD.




As these bat files are in fact shortcuts, you can define them to execute with hidden window.



