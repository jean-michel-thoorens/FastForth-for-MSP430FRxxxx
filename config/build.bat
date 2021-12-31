::@ECHO OFF
%~d1\prog\asw -x -q -L -i %~dp1inc %1 -o %~dp1binaries\%2.p
%~d1\prog\p2hex %~dp1binaries\%2.p -r 0x0000-0xffff
%~d1\prog\srec_cat -contradictory-bytes=warning %~dp1binaries\%2.hex -intel -output %~dp1binaries\%2.txt -ti-txt
del %~dp1binaries\%2.p
::del %~dp1binaries\%2.hex
exit

rem your git copy must be the root of a virtual drive

rem %1 is the input file.asm
rem %2 is the target name
