
@goto %1


:SelectTemplate
:: called by PreprocessSourceFile.bat, SendSourceFileToTarget.bat and CopySourceFileToTarget_SD_Card.bat
:: just before calling Preprocess.bat,             SendSource.bat and           CopyToTarget_SD_Card.bat

@echo select your target:
@echo 1  MSP_EXP430FR5739
@echo 2  MSP_EXP430FR5969
@echo 3  MSP_EXP430FR5994
@echo 4  MSP_EXP430FR6989
@echo 5  MSP_EXP430FR4133
@echo 6  MSP_EXP430FR2433
@echo 7  CHIPSTICK_FR2433
@echo 8  MSP_EXP430FR2355
@echo 9  MSP430FRxxxx (select if unknown device)

@echo 10 MY_SP430FR5738
@echo 11 MY_SP430FR5738_1
@echo 12 MY_SP430FR5738_2
@echo 13 MY_SP430FR5948
@echo 14 MY_SP430FR5948_1
@echo 15 JMJ_BOX
@echo 16 PA8_PA_MSP430
@echo 17 PA_PA_MSP430
@echo 18 PA_Core_MSP430
@set /p choice=your choice: 

@if %choice% == 1    set template=MSP_EXP430FR5739
@if %choice% == 2    set template=MSP_EXP430FR5969
@if %choice% == 3    set template=MSP_EXP430FR5994
@if %choice% == 4    set template=MSP_EXP430FR6989
@if %choice% == 5    set template=MSP_EXP430FR4133
@if %choice% == 6    set template=MSP_EXP430FR2433
@if %choice% == 7    set template=CHIPSTICK_FR2433
@if %choice% == 8    set template=MSP_EXP430FR2355
@if %choice% == 9    set template=MSP430FRxxxx

@if %choice% == 10   set template=MY_MSP430FR5738
@if %choice% == 11   set template=MY_MSP430FR5738_1 
@if %choice% == 12   set template=MY_MSP430FR5738_2
@if %choice% == 13   set template=MY_MSP430FR5948
@if %choice% == 14   set template=MY_MSP430FR5948_1 
@if %choice% == 15   set template=JMJ_BOX 
@if %choice% == 16   set template=PA8_PA_MSP430 
@if %choice% == 17   set template=PA_PA_MSP430 
@if %choice% == 18   set template=PA_Core_MSP430 

@exit /b

:SelectDevice
:: fonction called by prog.bat

@shift /1

@set device=%~n1
@if /I %device:~0,16%  == MSP_EXP430FR5739 set device=MSP430FR5739
@if /I %device:~0,16%  == MSP_EXP430FR5969 set device=MSP430FR5969
@if /I %device:~0,16%  == MSP_EXP430FR5994 set device=MSP430FR5994
@if /I %device:~0,16%  == MSP_EXP430FR6989 set device=MSP430FR6989
@if /I %device:~0,16%  == MSP_EXP430FR4133 set device=MSP430FR4133
@if /I %device:~0,16%  == MSP_EXP430FR2433 set device=MSP430FR2433
@if /I %device:~0,16%  == CHIPSTICK_FR2433 set device=MSP430FR2433
@if /I %device:~0,16%  == MSP_EXP430FR2355 set device=MSP430FR2355

@if /I %device:~0,15%  == MY_MSP430FR5738  set device=MSP430FR5738
@if /I %device:~0,15%  == MY_MSP430FR5948  set device=MSP430FR5948
@if /I %device:~0,13%  == PA8_PA_MSP430    set device=MSP430FR5738
@if /I %device:~0,12%  == PA_PA_MSP430     set device=MSP430FR5738
@if /I %device:~0,14%  == PA_CORE_MSP430   set device=MSP430FR5948
@if /I %device:~0,7%   == JMJ_BOX          set device=MSP430FR5738

@exit /b

