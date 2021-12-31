::@echo off

@if F%1==F (
    @echo no file to do that! 
) else (
    @call  %~d1\config\Select.bat SelectDevice %1
    @IF EXIST %~dp1binaries\%~n1.txt GOTO progtxt
    @IF EXIST %~dp1binaries\%~n1.hex GOTO proghex
)
@exit

:progtxt
%~d1\prog\msp430flasher -s -m SBW2 -u -n %device% -v -w %~dp1binaries\%~n1.txt  -z [RESET,VCC]
@exit

:proghex
%~d1\prog\msp430flasher -s -m SBW2 -u -n %device% -v -w %~dp1binaries\%~n1.hex  -z [RESET,VCC]
@exit

:: your git copy must be the root of a virtual drive

:: %n1 = filename of file to flash
:: %nx1 = filename.ext of file to flash
:: -s : force update
:: -m : select SBW2 mode
:: -u : Unlocks locked flash memory (INFOA) for writing.
:: -n %device% : device set from %n1
:: -v : verify device
:: -w %~dpn1.txt : file to be flashed
:: -z [] : end of flasher behaviour
