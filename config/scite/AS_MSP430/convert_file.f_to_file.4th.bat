@ECHO OFF
if not exist %~dpn1.f goto error
if not exist %~dpn2.pat goto error
if exist %3 goto error
@%~d1\prog\gema\gema.exe -nobackup -line -t -f  %~dpn2.pat %~dpn1.f %~dpn1.4th 
exit

:error

@start %~d1\config\scite\AS_MSP430\errorfto4th.bat
exit



exit
%~dpn1.f is the symbolic source file described as drive\path\name.f of first arg (%1)
%~dpn2.pat is the pattern file for preprocessor gema.exe described as drive\path\name.pat of 2th arg (%2)
%~dpn1.4th is the source file ready to send to the target
%~d1 is the drive of arg %1
