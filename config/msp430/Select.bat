
@goto %1


:SelectTemplate
:: fonction called by Preprocess.bat, SendSource.bat and CopyTo_SD_Card.bat

@echo select your target:
@echo 1  MSP_EXP430FR5739
@echo 2  MSP_EXP430FR5969
@echo 3  MSP_EXP430FR5994
@echo 4  MSP_EXP430FR6989
@echo 5  MSP_EXP430FR4133
@echo 6  MSP_EXP430FR2433
@echo 7  CHIPSTICK_FR2433
@set /p choice=your choice: 

@if %choice% == 1    set template=MSP_EXP430FR5739
@if %choice% == 2    set template=MSP_EXP430FR5969
@if %choice% == 3    set template=MSP_EXP430FR5994
@if %choice% == 4    set template=MSP_EXP430FR6989
@if %choice% == 5    set template=MSP_EXP430FR4133
@if %choice% == 6    set template=MSP_EXP430FR4133
@if %choice% == 7    set template=CHIPSTICK_FR2433

@exit /b

:SelectDevice
:: fonction called by prog.bat

@shift /1

@set device=%~n1
@if %device:~0,16%  == MSP_EXP430FR5739 set device=MSP430FR5739
@if %device:~0,16%  == MSP_EXP430FR5969 set device=MSP430FR5969
@if %device:~0,16%  == MSP_EXP430FR5994 set device=MSP430FR5994
@if %device:~0,16%  == MSP_EXP430FR6989 set device=MSP430FR6989
@if %device:~0,16%  == MSP_EXP430FR4133 set device=MSP430FR4133
@if %device:~0,16%  == MSP_EXP430FR2433 set device=MSP430FR2433
@if %device:~0,16%  == CHIPSTICK_FR2433 set device=MSP430FR2433

@exit /b
