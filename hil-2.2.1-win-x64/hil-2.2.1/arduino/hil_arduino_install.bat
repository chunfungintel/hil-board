@echo off

rem This script installs the Arduino drivers
rem
rem - Installation of the Arduino driver is performed only when the driver is not already present.
rem 
rem
rem Revision history:
rem 1.0 08/12/2014 amihaila - Initial version
rem 1.1 08/14/2014 amihaila - Do not prompt during driver installation and fixed bug when the Arduino board is connected to a COM port larger than COM9. Upgraded devcon.exe from WDK 8.1 Update.
rem 1.2 08/21/2014 amihaila - Detect also Arduino USB drivers having the signature "Arduino Mega 2560 R3 (COMx)" in the Device Manager
rem 1.3 11/04/2014 amihaila - Force installation of the Arduino drivers.
rem     01/07/2015 amihaila - Install driver from Arduino.cc (initial driver) and also from Arduino.org (the new driver)


setlocal enableDelayedExpansion
pushd %~dp0


:variables
    set CERTIFICATE_FILE_LLC=.\drivers\ArduinoLLC.cer
    set CERTIFICATE_FILE_SRL=.\drivers\ArduinoSRL.cer
    set NON_INTERACTIVE_MODE=%1
    
    :check_architecture
        set CERTMGR_EXE=.\utils\certmgr-amd64.exe
	set DEVCON_EXE=.\utils\devcon-amd64.exe
	set DPINST_EXE=.\drivers\dpinst-amd64.exe
    
        if PROCESSOR_ARCHITECTURE == x86 (
            set CERTMGR_EXE=.\utils\certmgr-x86.exe
	    set DEVCON_EXE=.\utils\devcon-x86.exe
	    set DPINST_EXE=.\drivers\dpinst-x86.exe
        )
    
:check_files_exist
    if not exist !CERTMGR_EXE! (
        echo Error: The file !CERTMGR_EXE! was not found!
        goto error
    )
	if not exist !DEVCON_EXE! (
        echo Error: The file !DEVCON_EXE! was not found!
        goto error
    )
	if not exist !DPINST_EXE! (
        echo Error: The file !DPINST_EXE! was not found!
        goto error
    )
    if not exist !CERTIFICATE_FILE_LLC! (
        echo Error: The file !CERTIFICATE_FILE_LLC! was not found!
        goto error
    )
	if not exist !CERTIFICATE_FILE_SRL! (
        echo Error: The file !CERTIFICATE_FILE_SRL! was not found!
        goto error
    )

:install_arduino_driver
    echo Check for Administrator access rights
    NET SESSION >nul 2>&1
    IF !ERRORLEVEL! NEQ 0 (
        echo Please run this script in Administrator mode in order to install the Arduino USB drivers!
        goto error
    )        
    
    echo - Adding certificate to trust Arduino LLC publisher
    !CERTMGR_EXE! -add !CERTIFICATE_FILE_LLC! -s -r localMachine trustedpublisher
    if !errorlevel! neq 0 (
        echo Error on installing the certificate !CERTIFICATE_FILE_LLC!
        goto error
    )
	
	echo - Adding certificate to trust Arduino SRL publisher
    !CERTMGR_EXE! -add !CERTIFICATE_FILE_SRL! -s -r localMachine trustedpublisher
    if !errorlevel! neq 0 (
        echo Error on installing the certificate !CERTIFICATE_FILE_SRL!
        goto error
    )
    
    echo Installing Arduino drivers (.cc and .org). Please wait ...
	!DPINST_EXE! /S /C
         
    echo Installing Arduino drivers finished. Waiting for 30 seconds to scan for HW changes...
    rem timeout /t 5  - This does not work when calling this .bat from another .bat
    ping -n 30 127.0.0.1 > nul
    !DEVCON_EXE! rescan
    if !errorlevel! neq 0 (
        echo Error on scanning for hardware changes in Device Manager.
        goto error
    )

:end
    goto success
    
    
:error
    echo An error has occured and installing of Arduino USB driver has been aborted!
    popd
    if "%NON_INTERACTIVE_MODE%" == "" (
        pause
    )
    exit /B 1

:success
    echo Installing Arduino USB driver succeeded!
    if "%NON_INTERACTIVE_MODE%" == "" (
        pause
    )
    popd
 