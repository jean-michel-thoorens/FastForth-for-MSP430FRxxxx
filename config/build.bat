@ECHO OFF
%~d1\prog\asw -L -i %~d1\inc %1 -o %~d1\binaries\%2.p
%~d1\prog\p2hex %~d1\binaries\%2.p -r 0x0000-0xffff
%~d1\prog\srec_cat %~d1\binaries\%2.hex -intel -output %~d1\binaries\%2.txt -ti-txt
del %~d1\binaries\%2.p
del %~d1\binaries\%2.hex
exit

rem your git copy must be the root of a virtual drive

rem %1 is the input file.asm
rem %2 is the target name, plus optional infos
