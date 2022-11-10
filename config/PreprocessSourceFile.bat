::PreProcessSourceFile.bat
::used as link in any folder to drag and drop source file.f on it.

:: %~dp0 is the path of this file.bat
:: %1 is file.f to be preprocessed

call  %~dp0Select.bat SelectTarget
start  %~dp0Preprocess.bat %1 %~dp0..\inc\%target%

@pause > NUL
exit
