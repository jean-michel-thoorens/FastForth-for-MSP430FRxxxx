::CopyTo_SD_Card.bat
::used by CopySourceFileToTarget_SD_Card.bat or by scite editor Tools menu

::echo %2
::echo %~dp1..\inc\%~n2.pat

::@ECHO OFF

::first select part .4TH or .f

IF /I "%~x1" == ".4TH" GOTO 4TH

:: ==============================================================================================
:: source file.f part
:: %~dp0 is the path of this file.bat
:: %~dpn1.f is the symbolic source file.f described as drive\path\name.f
:: %~d1\inc\%~n2.pat is the pattern file for preprocessor gema.exe
:: %~dpn1.4TH is the source file.4TH to be sent to the target
:: %~d1 is the drive of arg %1
:: %~n2 is your selected template by SelectTarget.bat or your scite $(1)

::echo %1
::echo %2
::echo %3
::pause

IF "%~x1" == "" (
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

IF /I "%3" == "" GOTO preprocessF

echo unexpected third parameter %3 !

:badend
pause > nul
exit


:preprocessF
%~dp0..\prog\gema.exe -nobackup -line -t '-\r\n=\r\n' -f  %~dp0..\inc\%~n2.pat %~dpn1.f %~dpn1.4TH
call  %~dp0Select.bat SelectDeviceId %~dp0..\inc\%~n2.pat

:DownloadF
taskkill /F /IM ttermpro.exe 1> NUL 2>&1

:win32F
"C:\Program Files\teraterm\ttpmacro.exe" /V %~dp0SendToSD.ttl %~dpn1.4TH /C %deviceid% 1> NUL 2>&1
IF NOT ERRORLEVEL 1 GOTO EndF

:win64F
"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~dp0SendToSD.ttl %~dpn1.4TH /C %deviceid%

:EndF
MOVE "%~dpn1.4TH" "%~dp1LAST.4TH" > NUL
exit


:: ==============================================================================================
:: source file.4TH part
:: %~dp0 is the path of this file.bat
:: %~dpn1.4TH is the file to be sent described as drive\path\name.4TH
:: %~d1 is the drive of param %1
:: %~nx0 is name.ext of this bat file

:4TH

shift /2

::echo %1
::echo %2
::echo %3
::pause

IF NOT EXIST %~dpn1.4TH (
echo %~dpn1.4TH not found!
goto badend
)

if /I "%2"=="" GOTO Download4th

echo unexpected 2th parameter %2 !
goto badend


:Download4th
taskkill /F /IM ttermpro.exe 1> NUL 2>&1

:win324th
"C:\Program Files\teraterm\ttpmacro.exe" /V %~dp0SendtoSD.ttl %~dpn1.4TH /C 0 1> NUL 2>&1
IF NOT ERRORLEVEL 1 GOTO End4th

:win644th
"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~dp0SendtoSD.ttl %~dpn1.4TH /C 0

:End4th
exit

