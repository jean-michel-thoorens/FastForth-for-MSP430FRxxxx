::PreProcessSourceFile.bat
::used as link in any folder to drag and drop file.f on it.

:: %1 is file.f to be preprocessed
:: %2 is used by Preprocess.bat as error : "unexpected third parameter"

call  ..\config\Select.bat SelectTemplate
call  ..\config\Preprocess.bat %1 ..\inc\%template% %2
pause
exit
