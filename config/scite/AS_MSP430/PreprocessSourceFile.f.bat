@ECHO OFF
IF NOT EXIST %~dpn1.f GOTO error
IF NOT EXIST %~dpn2.pat GOTO error

IF "%3" == "" GOTO preprocess

:error
@start %~d1\config\scite\AS_MSP430\Error.bat ConvertError %~nx0
exit

:preprocess
@%~d1\prog\gema\gema.exe -nobackup -line -t -f  %~dpn2.pat %~dpn1.f %~dpn1.4th 
exit

:: %~dpn1.f is the symbolic source file described as drive\path\name.f of first arg (%1)
:: %~dpn2.pat is the pattern file for preprocessor gema.exe described as drive\path\name.pat of 2th arg (%2)
:: %~dpn1.4th is the source file ready to send to the target
:: %~d1 is the drive of arg %1
:: %~nx0 is name.ext of this bat file

rem your git copy must be the root of a virtual drive

