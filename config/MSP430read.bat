
:: usage: MSP430Read RAM|INFO|MAIN|BSL output

set howtoread=%1
set readfile=%2
if "%1" == "" set howtoread=MAIN
if "%2" == "" set readfile=MAIN_DUMP

%~d1\prog\msp430flasher -m SBW2 -r [%readfile%_%howtoread%.txt,%howtoread%] -z [VCC=3000]
::%~d1\prog\srec_cat %readfile%_%howtoread%.HEX -intel -output %readfile%_%howtoread%.bin -Binary
::%~d1\prog\HxD\HxD.exe" %readfile%_%howtoread%.bin

pause
