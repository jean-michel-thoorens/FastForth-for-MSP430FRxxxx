@ECHO OFF
if not exist %~dpn1.4th goto error

if "%2"=="" GOTO testend
if /I "%2"=="ECHO" GOTO testend
if /I "%2"=="NOECHO" GOTO testend

:error
start %~d1\config\scite\AS_MSP430\error4th.bat
exit





:testend
taskkill /F /IM ttermpro.exe 1> NULL 2>&1
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C %2  1> NULL 2>&1
if ERRORLEVEL 1 goto nextcmd
exit

:nextcmd
del null
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C %2
:eof
exit



rem %~dpn1.4th is the file to send described as drive\path\name.4th of param %1
rem %~d1 is the drive of param %1




