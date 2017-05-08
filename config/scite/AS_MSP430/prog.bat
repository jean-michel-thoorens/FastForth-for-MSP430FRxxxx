\prog\MSP430Flasher\msp430flasher -s -m SBW2 -n %1 -v -w %2  -z [RESET,VCC]
exit

rem -s : force update
rem -m : select SBW2 mode
rem -n %1 : device
rem -v : verify device
rem -w %2 : file to be flashed
rem -z [] : end of flasher behaviour