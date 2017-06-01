@ECHO OFF
IF NOT EXIST %~dpn1.f GOTO error
IF NOT EXIST %~dpn2.pat GOTO error

if "%3"=="" goto testend
if /I "%3"=="ECHO" GOTO testend
if /I "%3"=="NOECHO" GOTO testend

:error
@start %~d1\config\scite\AS_MSP430\errorf.bat
exit


:testend
@%~d1\prog\gema\gema.exe -nobackup -line -t -f  %~dpn2.pat %~dpn1.f %~dpn1.4th 

@taskkill /F /IM ttermpro.exe 1> NULL 2>&1
@"C:\Program Files\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C  %3  1> NULL 2>&1
if ERRORLEVEL 1 goto nextcmd
exit

:nextcmd
del null
@"C:\Program Files (x86)\teraterm\ttpmacro.exe" /V %~d1\config\scite\AS_MSP430\SendFile.ttl %~dpn1.4th /C %3
@del %~dpn1.4th
:eof
exit


rem %~dpn1.f is the symbolic source file described as drive\path\name.f of first arg (%1)
rem %~dpn2.pat is the pattern file for preprocessor gema.exe described as drive\path\name.pat of 2th arg (%2)
rem %~dpn1.4th is the source file send to the target
rem %~d1 is the drive of arg %1

