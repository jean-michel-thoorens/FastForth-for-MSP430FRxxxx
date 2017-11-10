::@echo off

@set device=%~n1
@if %device:~0,16%  == MSP_EXP430FR5739 set device=MSP430FR5739
@if %device:~0,16%  == MSP_EXP430FR5969 set device=MSP430FR5969
@if %device:~0,16%  == MSP_EXP430FR5994 set device=MSP430FR5994
@if %device:~0,16%  == MSP_EXP430FR6989 set device=MSP430FR6989
@if %device:~0,16%  == MSP_EXP430FR4133 set device=MSP430FR4133
@if %device:~0,16%  == CHIPSTICK_FR2433 set device=MSP430FR2433

%~d1\prog\MSP430Flasher\msp430flasher -s -m SBW2 -n %device% -v -w %~n1.txt  -z [RESET,VCC]

@exit

:: your git copy must be the root of a virtual drive

:: %n1 = file filename (= target) to flash
:: -s : force update
:: -m : select SBW2 mode
:: -n %device% : device set from %n1
:: -v : verify device
:: -w %~dpn1.txt : file to be flashed
:: -z [] : end of flasher behaviour
