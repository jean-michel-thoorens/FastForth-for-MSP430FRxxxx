::@echo off

set target=%~n1

call %~dp0Select.bat SelectDevice %target%
IF EXIST %~dp0..\binaries\%~n1.txt (
    call %~dp0..\prog\MSP430Flasher -s -m SBW2 -u -n %device% -v -w %~dp0..\binaries\%~n1.txt  -z [RESET,VCC]
    ) else (
:: hex files generate error 60: verify error 
        IF EXIST %~dp0..\binaries\%~n1.hex (
            call %~dp0..\prog\MSP430Flasher -s -m SBW2 -u -n %device% -v -w %~dp0..\binaries\%~n1.hex  -z [RESET,VCC]
                        )
            )
::pause
@exit

:: %~dp0 is the path of this file.bat
:: %n1 = filename of file to flash
:: -s : force update
:: -m : select SBW2 mode
:: -u : Unlocks locked flash memory (INFOA) for writing.
:: -n %device% : device set from %n1
:: -v : verify device
:: -w %~dpn1.txt : file to be flashed
:: -z [] : end of flasher behaviour
