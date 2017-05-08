@ECHO OFF
\prog\MacroAssemblerAS\bin\asw -L -i \projets\msp430 %1 -o %2.p
\prog\MacroAssemblerAS\bin\p2hex %2.p -r 0x0000-0xffff
\prog\srecord\srec_cat %2.hex -intel -output %2.txt -ti-txt
del %2.p
del %2.hex
exit

rem %1 is the target device, example: MSP430FR5969
rem %2 is the target, example: MSP_EXP430FR5969