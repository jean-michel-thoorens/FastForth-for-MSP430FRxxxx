::CopySourceFileToTarget_SD_Card.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

IF  /I "%~x1" == ".f" goto sendF

:send4th

start  %~d1\config\SendSource.bat %1  NOECHO
::PAUSE > NUL
exit


:sendF

call  %~d1\config\Select.bat SelectTemplate

@start  %~d1\config\CopyTo_SD_Card.bat %1 %~dp1inc\%template% %2

::PAUSE > NUL
exit
:: %1 is file.f or file.4th to be send
:: optionnal %2 may be used by CopyTo_SD_Card.bat
