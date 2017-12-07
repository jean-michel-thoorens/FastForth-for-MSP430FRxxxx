@ECHO OFF
%~d1\prog\MacroAssemblerAS\bin\asw -L -i \projets\msp430 %1 -o %2.p
%~d1\prog\MacroAssemblerAS\bin\p2hex %2.p -r 0x0000-0xffff
%~d1\prog\srecord\srec_cat %2.hex -intel -output %2.txt -ti-txt
del %2.p
del %2.hex
exit

rem your git copy must be the root of a virtual drive

rem %1 is the input file.asm
rem %2 is the target name, plus optional infos
