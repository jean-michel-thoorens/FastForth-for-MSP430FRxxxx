::SendSourceFileToTarget.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

@ECHO OFF

IF  /I "%~x1" == ".f" goto sendF

:send4th

start  %~d1\config\SendSource.bat %1  ECHO
::PAUSE > NUL
exit


:sendF

call  %~d1\config\Select.bat SelectTemplate

start  %~d1\config\SendSource.bat %1 %~d1\inc\%template% ECHO

::PAUSE > NUL
exit
:: %1 is file.f to be send
