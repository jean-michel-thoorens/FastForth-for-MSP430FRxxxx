@ECHO OFF
if not exist %~dpn1.hex exit
if exist %2 exit
a:\prog\srecord\srec_cat %~dpn1.hex -intel -output %~dpn1.txt -ti-txt
exit

rem %1 is the target device, example: MSP430FR5969