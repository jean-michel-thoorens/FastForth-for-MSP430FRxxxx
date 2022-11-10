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
:: %~dp0 is the path of this file.bat
:: %1 = target name without ext. of \binaries\target.txt file
:: %2 = port COMx in use
:: %~d1 = drive: of %1
:: %~nx1 = target name with ext. of %1


@set PortCOM=%2
@if 1%PortCOM% == 1 CALL %~dp0Select.bat SelectPortCOM

@%~dp0..\prog\BSL-Scripter.exe --log --quiet --initComm [INVOKE,%PortCOM%,UART,9600,PARITY] --device FRxx --erase ERASE_ALL --exit [RESET]
@%~dp0..\prog\BSL-Scripter.exe --log --initComm [INVOKE,%PortCOM%,UART,9600,PARITY] --device FRxx --speed FAST  --bslPwd %~dp0..\binaries\pass32_default.txt -w %~dp0..\binaries\%~nx1 --exit [RESET]
@pause
