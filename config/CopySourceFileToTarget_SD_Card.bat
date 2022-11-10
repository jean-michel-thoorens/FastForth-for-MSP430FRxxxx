::CopySourceFileToTarget_SD_Card.bat
::used as link to place in any folder to drag and drop file.f or file.4th on it.

IF  /I "%~x1" == ".f" goto sendF

:send4th

start  %~dp0CopyTo_SD_Card.bat %1
@PAUSE > NUL
exit


:sendF

call  %~dp0Select.bat SelectTarget
@start  %~dp0CopyTo_SD_Card.bat %1 %~dp1..\inc\%target%
@PAUSE > NUL
exit

:: %~dp0 is the path of this file.bat
:: %1 is file.f or file.4th to be send
