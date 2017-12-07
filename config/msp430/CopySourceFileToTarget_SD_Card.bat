::CopySourceFileToTarget_SD_Card.bat
::used as link in any folder to drag and drop file.f or file.4th on it.

IF /I "%~x1" == ".4TH" goto letsgo

::@call  SelectTarget.bat
@call  Select.bat SelectTemplate

:letsgo

@start  CopyTo_SD_Card.bat %1 %~d1\config\gema\%template% %2
exit
:: %1 is file.f or file.4th to be send
:: optionnal %2 may be used by CopyTo_SD_Card.bat