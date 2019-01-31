::SendSourceFileToTarget.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

IF  /I "%~x1" == ".f" goto sendF

:send4th

start  SendSource.bat %1  NOECHO
::PAUSE > NUL
exit


:sendF

call  Select.bat SelectTemplate

start  SendSource.bat %1 %~d1\inc\%template% NOECHO

::PAUSE > NUL
exit
:: %1 is file.f to be send
