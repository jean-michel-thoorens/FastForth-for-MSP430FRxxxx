@ECHO OFF

:: ==============================================================================================
:: your git copy of fast forth must be the root of a virtual drive
:: ==============================================================================================

IF "%1" == "" GOTO DownloadError

:: ==============================================================================================
:: source file.f part
:: %~dpn1.f is the symbolic source file.f described as drive\path\name.f
:: %~dpn2.pat is the pattern file.pat for preprocessor gema.exe described as drive\path\name.pat
:: %~dpn1.4th is the source file.4th to be sent to the target
:: %~d1 is the drive of arg %1
:: %~nx0 is name.ext of this bat file

IF NOT EXIST %~dpn1.f GOTO 4th
IF NOT EXIST %~dpn2.pat GOTO errorF

IF /I "%3" == "" GOTO preprocessF
IF /I "%3" == "ECHO" GOTO preprocessF
IF /I "%3" == "NOECHO" GOTO preprocessF

:errorF
@start %~d1\config\scite\AS_MSP430\Error.bat DownloadErrorF %~nx0
exit

:preprocessF
@%~d1\prog\gema\gema.exe -nobackup -line -t -f  %~dpn2.pat %~dpn1.f %~dpn1.4th 

:DownloadF
@taskkill /F /IM ttermpro.exe 1> NULL 2>&1

:Win32F
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C  %3  1> NULL 2>&1
@IF NOT ERRORLEVEL 1 GOTO EndF

:Win64F
del null
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C %3

:EndF
@del %~dpn1.4th
exit


:: ==============================================================================================
:: source file.4th part
:: %~dpn1.4th is the file to be sent described as drive\path\name.4th
:: %~d1 is the drive of param %1
:: %~nx0 is name.ext of this bat file

:4th

IF NOT EXIST %~dpn1.4th GOTO DownloadError

if /I "%2"=="" GOTO Download4th
if /I "%2"=="ECHO" GOTO Download4th
if /I "%2"=="NOECHO" GOTO Download4th

:Error4th
@start %~d1\config\scite\AS_MSP430\Error.bat DownloadError4th %~nx0
exit

:Download4th
@taskkill /F /IM ttermpro.exe 1> NULL 2>&1

:Win324th
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C %2  1> NULL 2>&1
@IF NOT ERRORLEVEL 1 GOTO End4th

:Win644th
del null
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C %2

:End4th
exit


:DownloadError
@start %~d1\config\scite\AS_MSP430\Error.bat DownloadError %~nx0
exit
