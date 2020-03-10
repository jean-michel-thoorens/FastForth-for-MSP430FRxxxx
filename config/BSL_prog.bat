::@echo off
:: use with modified BSL_Scripter: https://github.com/drcrane/bslscripter-vs2017/releases
:: extract from zip file to \prog\BSL_Scripter.exe
::
:: wiring MSP430FRxx with UART2USB module
:: --------------------------------------
:: MSP430FRxxx      CP2102/PL2303TA
::  Vcc                3V3
::  GND                GND
::  TXD                RXD
::  RXD                TXD
::  RST/SBWTDIO        DTR
::  TEST/SBWTCK        RTS
::
:: usage : 
:: close teraterm (the port COMx which will be used by BSL_Scripter.exe is freed)
:: wire your target on USB2UART module as indicated above
:: use scite command CTRL+2, with param1 = "your target", param3 = "COMx",
:: 	or drag'n drop your \binaries\target.txt file onto BSL_Scripter.bat then
::	select port COM when asked.
:: Once finished, start teraterm then remove the wire DTR, that performs reset.
::
:: scite parameters (view command = SHIFT+F8)
:: scite commands in \config\asm.properties:
::      $(1) target, example: MSP_EXP430FR5969
::      $(2) target extension, example: _8MHz
::      $(3) port COMx in use, example: COM8
::
:: \config\BSL_Scripter.bat variables:
:: %1 = target name without ext. of \binaries\target.txt file
:: %2 = port COMx in use
:: %~d1 = drive: of %1
:: %~n1 = target name without ext. of %1


@set PortCOM=%2
@if 1%PortCOM% == 1 CALL %~d1\config\Select.bat SelectPortCOM

@%~d1\prog\BSL-Scripter.exe -g -q -i [INVOKE,%PortCOM%,UART,9600,PARITY] -n FRxx -e ERASE_ALL -z
@%~d1\prog\BSL-Scripter.exe -g -i [INVOKE,%PortCOM%,UART,9600,PARITY] -n FRxx -j FAST -b %~d1\binaries\pass32_default.txt -w %~d1\binaries\%~n1.txt -z
@pause