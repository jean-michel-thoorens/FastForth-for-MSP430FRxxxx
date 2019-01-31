::@echo off

@call  %~d1\config\Select.bat SelectDevice %1
@echo %device% programmation
%~d1\prog\msp430flasher -s -m SBW2 -n %device% -v -w %~d1\binaries\%~n1.txt  -z [RESET,VCC]

@exit

:: your git copy must be the root of a virtual drive

:: %n1 = file filename (= target) to flash
:: -s : force update
:: -m : select SBW2 mode
:: -n %device% : device set from %n1
:: -v : verify device
:: -w %~dpn1.txt : file to be flashed
:: -z [] : end of flasher behaviour
