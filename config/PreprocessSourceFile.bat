::PreProcessSourceFile.bat
::used as link in any folder to drag and drop file.f on it.
::@call  SelectTarget.bat
@call  %~d1\config\Select.bat SelectTemplate
@start  %~d1\config\Preprocess.bat %1 %~d1\inc\%template% %2
exit
:: %1 is file.f to be preprocessed
:: %2 is used by Preprocess.bat as an unexpected third parameter