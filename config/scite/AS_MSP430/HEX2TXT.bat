@ECHO OFF
if not exist %~dpn1.hex goto eof
if exist %2 goto eof
a:\prog\srecord\srec_cat %~dpn1.hex -intel -output %~dpn1.txt -ti-txt
:eof
exit

rem %1 is the target device, example: MSP430FR5969