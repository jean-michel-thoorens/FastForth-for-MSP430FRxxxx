
@GOTO %1

:DownloadErrorF
@call :before0
@call :before
@echo how to download a generic file.f to your target
@echo -----------------------------------------------
@echo       1- clic on your file.f,
@echo       2- ctrl+clic on your selected target.pat file, for example MSP_EXP430FR5994.pat
@echo       3- then drag and drop your file.f onto %2
@echo               the generic file.f is sent so to the preprocessor gema.exe which products a specific file.4th
@echo               which is itself downloaded onto target
@echo.
@pause
exit

:DownloadError4th
@call :before0
@call :before
@echo how to download a file.4th to your target
@echo -----------------------------------------
@echo       drag and drop your file.4th onto %2
@echo.
@pause
exit

:CopyErrorF
@call :before0
@call :before
@echo how to copy a generic file.f to your SD_CARD target
@echo ---------------------------------------------------
@echo       and a formatted FAT16/32 SD_CARD is in it's slot... 
@echo       1- clic on your file.f,
@echo       2- ctrl+clic on your selected target.pat file, for example MSP_EXP430FR5994.pat
@echo       3- release ctrl+clic
@echo       4- then drag and drop your file.f onto %2
@echo               the generic file.f is sent so to the preprocessor gema.exe which products a specific file.4th
@echo               which is itself copied onto SD_CARD target
@echo.
@pause
exit

:CopyError4th
@call :before0
@call :before
@echo how to copy a file.4th to the SD_CARD target
@echo --------------------------------------------
@echo       and a formatted FAT16/32 SD_CARD is in it's slot... 
@echo       drag and drop your file.4th onto %2
@echo.
@pause
exit

:ConvertError
@call :before0
@echo how to convert a generic file.f to a target specific file.4th
@echo -------------------------------------------------------------
@echo       1- clic on a file.f,
@echo       2- ctrl+clic on your selected target.pat file, for example MSP_EXP430FR5994.pat
@echo       3- release ctrl+clic
@echo       4- then drag and drop your file.f onto %2
@echo             the generic file.f is sent so to the preprocessor gema.exe which products a specific file.4th
@echo.
@pause
exit

:DownloadError
@call :before0
@call :before
@echo how to download a generic file.f to your target
@echo -----------------------------------------------
@echo       1- clic on your file.f,
@echo       2- ctrl+clic on your selected target.pat file, for example MSP_EXP430FR5994.pat
@echo       3- release ctrl+clic
@echo       4- then drag and drop your file.f onto %2
@echo               the generic file.f is sent so to the preprocessor gema.exe which products a specific file.4th
@echo               which is itself downloaded onto target
@echo.
@echo how to download a file.4th to your target
@echo -----------------------------------------
@echo       drag and drop your file.4th onto %2
@echo.
@pause
exit


:COPYError
@call :before0
@call :before
@echo how to copy a generic file.f to your SD_CARD target
@echo ---------------------------------------------------
@echo       and a formatted FAT16/32 SD_CARD is in it's slot... 
@echo       1- clic on your file.f,
@echo       2- ctrl+clic on your selected target.pat file, for example MSP_EXP430FR5994.pat
@echo       3- release ctrl+clic
@echo       4- then drag and drop your file.f onto %2
@echo               the generic file.f is sent so to the preprocessor gema.exe which products a specific file.4th
@echo               which is itself copied onto SD_CARD target
@echo.
@echo how to download a file.4th to your target
@echo -----------------------------------------
@echo       drag and drop your file.4th onto %2
@echo.
@pause
exit


:before0
@echo you have downloaded your copy of gitlab fast forth onto a folder shared and connected as virtual drive (A: or B: ...)
@echo     so config files.pat for the preprocessor gema.exe are in the folder \config\gema\
@echo     and batch file are in the folder \config\scite\msp430_as\
@echo you have installed the last version of teraterm,
@echo you have installed the last version of gema.exe in the folder \prog\gema\.
@echo.
@echo edit properties of these three links SendSourceFileToTarget.bat, CopySourceFileToTarget_SD_Card.bat and
@echo PreprocessSourceFile.f.bat to change the drive letter B: as yours.
@echo.
@exit /B

:before
@echo before sending a file
@echo ---------------------
@echo     teraterm must be well configured, and its config must be saved,
@echo     so you must see the FAST FORTH prompt "ok" when you type "return" on the teraterm terminal.
@echo.
@exit /B