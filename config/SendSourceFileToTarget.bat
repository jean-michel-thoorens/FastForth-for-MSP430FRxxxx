::SendSourceFileToTarget.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

:: %~dp0 is the path of this file.bat
:: %1 is file.f to be send

::@ECHO OFF

IF  /I "%~x1" == ".f" goto sendF

:send4th

start  %~dp0SendSource.bat %1  ECHO
@PAUSE > NUL
exit


:sendF

call  %~dp0Select.bat SelectTarget
start  %~dp0SendSource.bat %1 %~dp0..\inc\%target% ECHO
@PAUSE > NUL
exit
