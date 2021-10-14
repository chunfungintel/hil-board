@echo off

rem This script flashes the Arduino board with the HIL firmware.
rem
rem Usage: Run hil_arduino_flash.bat [noprompt]
rem Please contact harts_support@intel.com for any issues regarding flashing of the HIL board.
rem
rem Revision history:
rem 1.0 08/12/2014 amihaila - Initial version
rem 1.1 08/14/2014 amihaila - Do not prompt during driver installation and fixed bug when the Arduino board is connected to a COM port larger than COM9. Upgraded devcon.exe from WDK 8.1 Update.
rem 1.2 08/21/2014 amihaila - Detect also Arduino USB drivers having the signature "Arduino Mega 2560 R3 (COMx)" in the Device Manager


setlocal enableDelayedExpansion

:variables
    set FW_HEX_FILE=Harts_IO_Lite.hex
    set ARDUINO_MEGA_2560_SIGNATURE="Arduino Mega 2560.*\(COM[0-9]+\)"
    set NON_INTERACTIVE_MODE=%1

pushd %~dp0

if not exist .\%FW_HEX_FILE% (
  echo The binary file .\%FW_HEX_FILE% does not exist! Run hil_build.bat first!
  goto error
)

:check_architecture
    set DEVCON_EXE=.\utils\devcon-amd64.exe   

    if PROCESSOR_ARCHITECTURE == x86 (
        set DEVCON_EXE=.\utils\devcon-x86.exe
    )
    
:check_files_exist
    if not exist !DEVCON_EXE! (
        echo Error: The file !DEVCON_EXE! was not found!
        goto error
    )

rem Note: If still facing issues with USB device enumeration, restart USB ROOT_HUB with devcon.exe restart *ROOT_HUB* (see SMS05470638)
    
:get_arduino_com_port
    !DEVCON_EXE! find * | .\utils\grep.exe -oE !ARDUINO_MEGA_2560_SIGNATURE! | .\utils\grep.exe -oE COM[0-9]+ > .\com.txt.tmp

    set /P COM_TMP=<.\com.txt.tmp
    if "%COM_TMP%" == "" (
        echo Error on finding the COM port for the Arduino board!
        goto error
    )
    del .\com.txt.tmp

:flash_arduino
    echo Flashing Arduino board found on %COM_TMP% ...
    .\utils\flash_programmer\avrdude.exe -C.\utils\flash_programmer\avrdude.conf -patmega2560 -P\\.\%COM_TMP% -cwiring -b115200 -D -U"flash:w:%FW_HEX_FILE%"
    if !errorlevel! == 0 goto success

:error
    echo An error has occured and the flashing of Arduino has been aborted!
    popd
    if "%NON_INTERACTIVE_MODE%" == "" (
        pause
    )
    exit /B 1

:success
    echo Flashing succeeded!
    if "%NON_INTERACTIVE_MODE%" == "" (
        pause
    )
    popd
    