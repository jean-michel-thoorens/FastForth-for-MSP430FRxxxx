::@echo off

@call  %~d1\config\Select.bat SelectDevice %1
@echo %device% programmation
C:\ti\uniflash_5.3.1\dslite.bat -c C:\ti\uniflash_5.3.1\deskdb\content\TICloudAgent\win\ccs_base\common\targetdb\devices\%device%.xml --flash --verify %~d1\binaries\%~n1.txt 
@exit

:: your git copy must be the root of a virtual drive

:: %n1 = file filename (= target) to flash
:: -s : force update
:: -m : select SBW2 mode
:: -n %device% : device set from %n1
:: -v : verify device
:: -w %~dpn1.txt : file to be flashed
:: -z [] : end of flasher behaviour
