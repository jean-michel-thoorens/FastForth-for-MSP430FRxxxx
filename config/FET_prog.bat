::@echo off

set target=%~n1
IF EXIST config\Select.bat (
:: used by scite commands Ctrl+1 or Ctrl+4
	call config\Select.bat SelectDevice  %%target%%
    	IF EXIST %~dp1binaries\%~n1.txt (	
	    call %~dp1prog\msp430flasher -s -m SBW2 -u -n %%device%% -v -w %~dp1binaries\%~n1.txt  -z [RESET,VCC]
	) else ( 
:: hex files generate error 60: verify error 
            IF EXIST %~dp1binaries\%~n1.hex (
                call %~dp1prog\msp430flasher -s -m SBW2 -u -n %%device%% -v -w %~dp1binaries\%~n1.hex  -z [RESET,VCC]
                )
	)
) else (
    IF EXIST %~dp1..\config\Select.bat (
:: used by drag n drop on \binaries\FET_prog.bat
	call  %~dp1..\config\Select.bat SelectDevice %%target%%
        IF EXIST %~n1.txt (
	    call %~dp1..\prog\msp430flasher -s -m SBW2 -u -n %%device%% -v -w %~n1.txt  -z [RESET,VCC]
        ) else (
:: hex files generate error 60: verify error 
            IF EXIST %~n1.hex (
                call %~dp1..\prog\msp430flasher -s -m SBW2 -u -n %%device%% -v -w %~n1.hex  -z [RESET,VCC]
                )
        )
    )
)
::pause
@exit

:: %n1 = filename of file to flash
:: -s : force update
:: -m : select SBW2 mode
:: -u : Unlocks locked flash memory (INFOA) for writing.
:: -n %device% : device set from %n1
:: -v : verify device
:: -w %~dpn1.txt : file to be flashed
:: -z [] : end of flasher behaviour
