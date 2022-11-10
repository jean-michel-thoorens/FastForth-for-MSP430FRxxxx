
:: usage: MSP430Read RAM|INFO|MAIN|BSL output
:: %~dp0 is the path of this file.bat

set howtoread=%1
set readfile=%2
if "%1" == "" set howtoread=MAIN
if "%2" == "" set readfile=Target_MAIN

%~dp0..\prog\msp430flasher -m SBW2 -r [%readfile%.HEX,%howtoread%] -z [VCC=3000]

::%~dp0..\prog\srec_cat %readfile%_%howtoread%.HEX -intel -output %readfile%_%howtoread%.bin -Binary
::%~dp0..\prog\HxD\HxD.exe" %readfile%_%howtoread%.bin

pause
