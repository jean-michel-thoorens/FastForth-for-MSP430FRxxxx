::@ECHO OFF
%~dp0..\prog\asw -x -q -L -i %~dp0..\inc %1 -o %~dp0..\binaries\%2.p
%~dp0..\prog\p2hex %~dp0..\binaries\%2.p -r 0x0000-0xffff
%~dp0..\prog\srec_cat -contradictory-bytes=warning %~dp0..\binaries\%2.hex -intel -output %~dp0..\binaries\%2.txt -ti-txt
del %~dp0..\binaries\%2.p
del %~dp0..\binaries\%2.hex
::pause
exit

:: %~dp0 is the path of this file.bat
:: %1 is the input file.asm
:: %2 is the target name
