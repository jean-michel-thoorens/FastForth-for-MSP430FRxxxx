::CopyTo_SD_Card.bat
::used by CopySourceFileToTarget_SD_Card.bat or by scite editor Tools menu

::echo %2
::echo %~d1\config\gema\%~n2.pat

@ECHO OFF

::first select part .4th or .f

IF /I "%~x1" == ".4TH" GOTO 4th

:: ==============================================================================================
:: source file.f part
:: %~dpn1.f is the symbolic source file.f described as drive\path\name.f
:: %~d1\config\gema\%~n2.pat is the pattern file for preprocessor gema.exe
:: %~dpn1.4th is the source file.4th to be sent to the target
:: %~d1 is the drive of arg %1
:: %~n2 is your selected template by SelectTarget.bat or your scite $(1)

IF "%~x1" == "" (
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

IF /I "%3" == "" GOTO preprocessF
IF /I "%3" == "ECHO" GOTO preprocessF
IF /I "%3" == "NOECHO" GOTO preprocessF
IF /I "%3" == "HALF" GOTO preprocessF

echo unexpected third parameter %3 !

:badend
pause > nul
exit


:preprocessF
@%~d1\prog\gema\gema.exe -nobackup -line -t '\n=\r\n;\r\n=\r\n' -f  %~d1\config\gema\%~n2.pat %~dpn1.f %~dpn1.4th

:DownloadF
@taskkill /F /IM ttermpro.exe 1> NUL 2>&1

:win32F
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\msp430\SendToSD.ttl %~dpn1.4th /C  1> NUL 2>&1
@IF NOT ERRORLEVEL 1 GOTO EndF

:win64F
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\msp430\SendToSD.ttl %~dpn1.4th /C

:EndF
@MOVE "%~dpn1.4th" "%~dp1\LAST.4th" > NUL
exit


:: ==============================================================================================
:: source file.4th part
:: %~dpn1.4th is the file to be sent described as drive\path\name.4th
:: %~d1 is the drive of param %1
:: %~nx0 is name.ext of this bat file

:4th

shift /2

::echo %1
::echo %2
::echo %3
::pause

IF NOT EXIST %~dpn1.4th (
echo %~dpn1.4th not found!
goto badend
)

if /I "%2"=="" GOTO Download4th
if /I "%2"=="ECHO" GOTO Download4th
if /I "%2"=="NOECHO" GOTO Download4th
if /I "%2"=="HALF" GOTO Download4th

echo unexpected 2th parameter %2 !
goto badend


:Download4th
@taskkill /F /IM ttermpro.exe 1> NUL 2>&1

:win324th
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d0\config\msp430\SendtoSD.ttl %~dpn1.4th /C 1> NUL 2>&1
@IF NOT ERRORLEVEL 1 GOTO End4th

:win644th
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d0\config\msp430\SendtoSD.ttl %~dpn1.4th /C

:End4th
exit

