::@ECHO OFF
%~dp1prog\asw -x -q -L -i %~dp1inc %1 -o %~dp1binaries\%2.p
%~dp1prog\p2hex %~dp1binaries\%2.p -r 0x0000-0xffff
%~dp1prog\srec_cat -contradictory-bytes=warning %~dp1binaries\%2.hex -intel -output %~dp1binaries\%2.txt -ti-txt
del %~dp1binaries\%2.p
del %~dp1binaries\%2.hex
::pause
exit

rem %1 is the input file.asm
rem %2 is the target name
