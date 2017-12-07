::SendSourceFileToTarget.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

IF /I "%~x1" == ".4TH" goto letsgo

::@call  SelectTarget.bat
@call  Select.bat SelectTemplate

:letsgo

@start  SendSource.bat %1 %~d1\config\gema\%template% %2
exit
:: %1 is file.f to be send
:: %2 = \config\gema\ !!!
:: optionnal %3 may be used by SendSource.bat