::SendSourceFileToTarget.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

:: %1 is file.f to be send

::@ECHO OFF

IF  /I "%~x1" == ".f" goto sendF

:send4th

start  %~dp1..\config\SendSource.bat %1  ECHO
::PAUSE > NUL
exit


:sendF

call  %~dp1..\config\Select.bat SelectTemplate

start  %~dp1..\config\SendSource.bat %1 %~dp1..\inc\%template% ECHO

::PAUSE > NUL
exit
