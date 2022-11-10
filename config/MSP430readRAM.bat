
:: usage: MSP430Read RAM|INFO|MAIN|BSL output
:: %~dp0 is the path of this file.bat

%~dp0..\prog\msp430flasher -m SBW2 -r [target_RAM.txt,RAM] -z [VCC=3000]
::%~dp0..\prog\srec_cat %readfile%_%howtoread%.HEX -intel -output %readfile%_%howtoread%.bin -Binary
::%~dp0..\prog\HxD\HxD.exe" %readfile%_%howtoread%.bin

pause
