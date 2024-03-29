
@goto %1


:SelectTarget
:: called by PreprocessSourceFile.bat, SendSourceFileToTarget.bat and CopySourceFileToTarget_SD_Card.bat
:: just before calling Preprocess.bat,             SendSource.bat and           CopyToTarget_SD_Card.bat

::%1 = "SelectTemplate"
::%2 = file.f name

@echo select your target:
@echo 1  MSP_EXP430FR5739
@echo 2  MSP_EXP430FR5969
@echo 3  MSP_EXP430FR5994
@echo 4  MSP_EXP430FR6989
@echo 5  MSP_EXP430FR4133
@echo 6  MSP_EXP430FR2433
@echo 7  CHIPSTICK_FR2433
@echo 8  MSP_EXP430FR2355
@echo 9  LP_MSP430FR2476
@set /p choice=your choice: 

@if %choice% == 1    set target=MSP_EXP430FR5739
@if %choice% == 2    set target=MSP_EXP430FR5969
@if %choice% == 3    set target=MSP_EXP430FR5994
@if %choice% == 4    set target=MSP_EXP430FR6989
@if %choice% == 5    set target=MSP_EXP430FR4133
@if %choice% == 6    set target=MSP_EXP430FR2433
@if %choice% == 7    set target=CHIPSTICK_FR2433
@if %choice% == 8    set target=MSP_EXP430FR2355
@if %choice% == 9    set target=LP_MSP430FR2476

@exit /b

:SelectDevice
:: fonction called by FET_prog.bat and preprocess.bat with variable %target%
@if /I %target:~0,16%  == MSP_EXP430FR5739 set device=MSP430FR5739
@if /I %target:~0,16%  == MSP_EXP430FR5969 set device=MSP430FR5969
@if /I %target:~0,16%  == MSP_EXP430FR5994 set device=MSP430FR5994
@if /I %target:~0,16%  == MSP_EXP430FR6989 set device=MSP430FR6989
@if /I %target:~0,16%  == MSP_EXP430FR4133 set device=MSP430FR4133
@if /I %target:~0,16%  == MSP_EXP430FR2433 set device=MSP430FR2433
@if /I %target:~0,16%  == CHIPSTICK_FR2433 set device=MSP430FR2433
@if /I %target:~0,16%  == MSP_EXP430FR2355 set device=MSP430FR2355
@if /I %target:~0,15%  == LP_MSP430FR2476  set device=MSP430FR2476
::pause

@exit /b

:SelectDeviceId
:: fonction called by SendSource.bat

::echo %~n2
@set target=%~n2
@if /I %target:~0,16%  == MSP_EXP430FR5739 set deviceid=$8103
@if /I %target:~0,16%  == MSP_EXP430FR5969 set deviceid=$8169
@if /I %target:~0,16%  == MSP_EXP430FR5994 set deviceid=$82A1
@if /I %target:~0,16%  == MSP_EXP430FR6989 set deviceid=$81A8
@if /I %target:~0,16%  == MSP_EXP430FR4133 set deviceid=$81F0
@if /I %target:~0,16%  == MSP_EXP430FR2433 set deviceid=$8240
@if /I %target:~0,16%  == CHIPSTICK_FR2433 set deviceid=$8240
@if /I %target:~0,16%  == MSP_EXP430FR2355 set deviceid=$830C
@if /I %target:~0,15%  == LP_MSP430FR2476  set deviceid=$832A

::echo %deviceid%
::%1 = "SelectDevice"
::%2 = file.pat name

@exit /b


:SelectPortCOM
:: fonction called by BSL_prog.bat
@set /p number=select your Port: COM
@set PortCOM=COM%number%

@exit /b


:SelectBridge
@echo select your bridge:
@echo 1  USB to UART
@echo 2  WIFI
@set /p choice=your choice: 

@if %choice% == 1    set bridge="C/ ECHO"
@if %choice% == 2    set bridge="FastForth:3000 HALF"

@exit /b


