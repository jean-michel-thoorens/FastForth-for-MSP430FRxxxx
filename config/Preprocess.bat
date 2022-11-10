::Preprocess.bat
::used to preprocess source.f files, from PreprocessSourceFile.bat or scite editor Tools menu

::@ECHO OFF

::echo %2
::echo %~dp1..\inc\%~n2.pat

IF "%2" == "" ( 
echo no file to be preprocessed!
goto badend 
)

IF NOT EXIST %~dpn1.f (
echo %~dpn1.f not found!
goto badend 
)

IF NOT EXIST %~dp0..\inc\%~n2.pat (
echo %~dp0..\inc\%~n2.pat not found!
goto badend 
)

IF "%3" == "" GOTO preprocess

echo unexpected third parameter!

:badend
pause > nul
exit


:preprocess
%~dp0..\prog\gema.exe -nobackup -line -t '-\r\n=\r\n' -f %~dp0..\inc\%~n2.pat  %~dpn1.f %~dp1LAST.4TH
set target=%~n2
call %~dp0Select.bat SelectDevice %%target%%
if not exist  %~dp1SD_%device:~3% MD %~dp1SD_%device:~3% > NUL 
COPY /y %~dp1LAST.4TH %~dp1SD_%device:~3%\%~n1.4TH > NUL
::pause > NUL
exit

:: %~dp0 is the path of this file.bat
:: %~dpn1.f is the symbolic source file
:: %~dp0..\inc\%~n2.pat is the pattern file for preprocessor gema.exe
:: %~dp1LAST.4TH is the output source file (ready to send to the target)
:: %~d1 is the drive of arg %1
:: %~n2 is your selected template by SelectTarget.bat or your scite $(1)

rem your git copy must be the root of a virtual drive

