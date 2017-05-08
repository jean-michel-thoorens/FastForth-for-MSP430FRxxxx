\prog\MSP430Flasher\msp430flasher -m SBW2 -n MSP430fr5994 -v -w %1 -z [VCC=3000]
exit

tip : how to calculate MAIN program lenght ?

open the prog.txt file with your editor, select MAIN section
in status bar, keep the number of selected chars
if lines are ended with CR+LF, substract the number of lines selected
then divide by 3.  
