::Preprocess.bat
::used by PreprocessSourceFile.bat or by scite editor Tools menu

@ECHO OFF

::echo %2
::echo %~d1\config\gema\%~n2.pat

IF "%2" == "" ( 
echo no file to be preprocessed!
goto badend 
)

IF NOT EXIST %~dpn1.f (
echo %~dpn1.f not found!
goto badend 
)

IF NOT EXIST %~d1\config\gema\%~n2.pat (
echo %~d1\config\gema\%~n2.pat not found!
goto badend 
)

IF "%3" == "" GOTO preprocess

echo unexpected third parameter!

:badend
pause > nul
exit


:preprocess
%~d1\prog\gema\gema.exe -nobackup -line -t -f  %~d1\config\gema\%~n2.pat %1 %~dp1\last.4th 
exit

:: %~dpn1.f is the symbolic source file
:: %~d1\config\gema\%~n2.pat is the pattern file for preprocessor gema.exe
:: %~dpn1.4th is the output source file (ready to send to the target)
:: %~d1 is the drive of arg %1
:: %~n2 is your selected template by SelectTarget.bat or your scite $(1)

rem your git copy must be the root of a virtual drive

