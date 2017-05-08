@ECHO OFF
if not exist %~dpn1%.4th goto error
if exist %2 goto error
taskkill /F /IM ttermpro.exe 1> NULL 2>&1
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d0\config\scite\AS_MSP430\SendtoSD.ttl %~dpn1%.4th /C    1> NULL 2>&1
if ERRORLEVEL 1 goto nextcmd
exit

:nextcmd
del null
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d0\config\scite\AS_MSP430\SendtoSD.ttl %~dpn1%.4th /C
exit

:error

@start %~d0\config\scite\AS_MSP430\error4thtoSDCARD.bat
exit

rem %~d0% is the drive of bat file
rem %~dpn1%.4th is the file to send described as drive\path\name.4th of param %1
rem %~d1 is the drive of param %1
