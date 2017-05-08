

@echo how to receive a file from target SD_CARD
@echo -----------------------------------------
@echo       I presume you are connected via TERATERM.EXE to your fastforth target with its SD_CARD extensions,
@echo       and a formatted FAT 16 SD_CARD is in it's slot... 
@echo       1- drag and drop any file.f/.4th of your destination folder onto Receive_file_from_SD_CARD_target.bat
@echo          this defines path for 2th window below
@echo       2- in the first window opened by TERATERM select the SD_CARD file you want upload
@echo       3- in the 2th window, change if necessary filename to be written on your PC.
@echo       4- wait for TERATERM window blinking (at 15kb/s, this may do a long time): it's done.

@pause
exit

