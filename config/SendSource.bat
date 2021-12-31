::SendSource.bat
::used by SendSourceFileToTarget.bat or by scite editor Tools menu

::echo %2
::echo %~dp1..\inc\%~n2.pat

@ECHO OFF

::first select part .4TH or .f

IF /I "%~x1" == ".4TH" GOTO 4TH

:: ==============================================================================================
:: source file.f part
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

IF NOT EXIST %~dp1..\inc\%~n2.pat (
echo %~dp1..\inc\%~n2.pat not found!
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
@%~d1\prog\gema.exe -nobackup -line -t '-\r\n=\r\n' -f  %~dp1..\inc\%~n2.pat %~dpn1.f %~dpn1.4TH
@call  %~d1\config\Select.bat SelectDeviceId %~dp1..\inc\%~n2.pat

:DownloadF
@taskkill /F /IM ttermpro.exe 1> NUL 2>&1

:Win32F
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\SendFile.ttl %~dpn1.4TH /C %3 %deviceid% 1> NUL 2>&1
@IF NOT ERRORLEVEL 1 GOTO EndF

:Win64F
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\SendFile.ttl %~dpn1.4TH /C %3 %deviceid%

:EndF
@MOVE "%~dpn1.4TH" "%~dp1LAST.4TH" > NUL
call  %~d1\config\Select.bat SelectDevice %~dp1..\inc\%~n2.pat
if not exist  %~dp1SD_%device:~3% MD %~dp1SD_%device:~3% > NUL 
COPY /y %~dp1LAST.4TH %~dp1SD_%device:~3%\%~n1.4TH > NUL
exit


:: ==============================================================================================
:: source file.4TH part
:: %~dpn1.4TH is the file to be sent described as drive\path\name.4TH
:: %~d1 is the drive of param %1
:: %~nx0 is name.ext of this bat file

:4TH

shift /3

::echo %1
::echo %2
::echo %3
::pause

IF NOT EXIST %~dpn1.4TH (
echo %~dpn1.4TH not found!
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

:Win324th
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\SendFile.ttl %~dpn1.4TH /C %2 0 1> NUL 2>&1
@IF NOT ERRORLEVEL 1 GOTO End4th

:Win644th
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\SendFile.ttl %~dpn1.4TH /C %2 0

:End4th
@COPY "%~dpn1.4TH" "%~dp1LAST.4TH" > NUL
exit

