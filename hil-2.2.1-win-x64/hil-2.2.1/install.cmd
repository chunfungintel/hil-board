@echo off

rem Check for Administrator access rights
NET SESSION >nul 2>&1
IF !ERRORLEVEL! NEQ 0 (
    echo Run this installation script as administrator
    goto error
)

echo 1. Install Arduino drivers ...
call .\arduino\hil_arduino_install.bat

echo 2. Flash Arduino
call .\arduino\hil_arduino_flash.bat

echo 3. Install Windows service
call .\service\install_service.cmd

echo 4. Starting Windows service HilStackService
net start HilStackService

rem TODO Check exit codes from all steps
echo Hil service was installed succesfully
exit /b 0

error:
    exit /b 1