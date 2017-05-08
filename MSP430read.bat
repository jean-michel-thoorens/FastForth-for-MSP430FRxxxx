
:: usage: MSP430Read RAM|INFO|MAIN|BSL output

set howtoread=%1
set readfile=%2
if c%1==c set howtoread=MAIN
if c%2==c set readfile=DUMP

A:\prog\MSP430Flasher\msp430flasher -m SBW2 -r [%readfile%_%howtoread%.hex,%howtoread%] -z [VCC=3000]
A:\prog\srecord\srec_cat %readfile%_%howtoread%.HEX -intel -output %readfile%_%howtoread%.bin -Binary
A:\prog\HxD\HxD.exe" %readfile%_%howtoread%.bin