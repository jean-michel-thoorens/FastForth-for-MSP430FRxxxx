

@echo how to copy a generic file.f to your SD_CARD target
@echo ---------------------------------------------------
@echo       I presume you are connected via TERATERM.EXE to your fastforth target with its SD_CARD extensions,
@echo       and a formatted FAT 16 SD_CARD is in it's slot... 
@echo       1- clic on your file.f,
@echo       2- ctrl clic on your selected target.pat file, for example MSP_EXP430FR5994.pat
@echo       3- then drag and drop your file.f onto Send_File.f_to_SD_CARD_target.bat
@echo               the generic file.f is sent so to the preprocessor gema.exe which products a specific file.4th
@echo               which is itself copied onto SD_CARD target

@pause
exit

