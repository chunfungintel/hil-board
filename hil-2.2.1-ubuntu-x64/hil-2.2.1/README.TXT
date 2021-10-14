HIL Stack Service Suite

Support:
-------
    http://harts.intel.com/hil or
    harts_support@intel.com


Content:
-------
    Windows:
        - Arduino USB Driver for Windows
        - Arduino Firmware
        - Windows Service
            - Windows OS Service ver 1.1.1 (HilWinService.exe)
            - Hil REST-API server (hil_server.exe)
            - Windows Service Monitor ver 1.0.2 (HilServiceMonitor.exe)
        - Client (HARTS_IO_Client.exe) ver 5.1.1
    Ubuntu / MacOS:
        - Arduino Firmware
        - Hil REST-API server (hil_server)
        
        
Installation instructions:
--------------------------
    Windows:
    -------
        - Unpack the hil_suite-*.zip under e.g. C:\HIL\ directory
        - Run as Administrator:
            - install.cmd
                    
        Note: The Windows OS Service configuration assumes that the server is stored under C:\HIL\service\
            If placed under a different directory, the configuration file .\service\HilWinService.exe.config must be edited
            to specify the absolute or relative path to the hil_server.exe file (PathToProcess key). 
            
        Note: When starting or stopping the Windows OS Service there will be logs available in the Windows "Event Viewer" / Application section.
    
    Linux Ubuntu:
    -------------
        - Unpack the hil_suite-*.zip
        - Flash Arduino:            
            sudo apt-get install avrdude
            cd ./arduino
            avrdude -p atmega2560 -P /dev/ttyACM0 -b 115200 -c wiring -D -U "flash:w:Harts_IO_Lite.hex"
        
        - In order to be able to access the Serial port, the user must be added to the group 'dialout', e.g.:
            sudo usermod -a -G dialout <your_username>
            
        - Start the server: ./hil_server start &
            - There is no need to start the server with 'sudo'!
        - Stop the server: ./hil_server stop
                
        - By default, the serial port for Arduino is detected automatically by the server. For debugging purposes, the serial port for Arduino can be identified as follows:
        ls -l /dev/serial/by-id/usb-Arduino*   
            lrwxrwxrwx 1 root root 13 Feb  4 09:31 /dev/serial/by-id/usb-Arduino__www.arduino.cc__0042_8523535313735130A122-if00 -> ../../ttyACM0
                    - In most of the cases the serial port is assigned to /dev/ttyACM0
        udevadm info /dev/ttyACM0
            This prints the device ID and the signatures from the Arduino device.
                           
    
    MacOS:
    ------
        - Unpack the hil_suite-*.zip
        - Flash Arduino:
            Download and install the OSX-AVR package from http://sourceforge.net/projects/osxavr/
            avrdude -p atmega2560 -P /dev/tty.usbmodem1411 -b 115200 -c stk500v2 -D -U "flash:w:Harts_IO_Lite.hex"

        - By default, the serial port for Arduino is detected automatically by the server. For debugging purposes, the serial port for Arduino can be identified as follows:
        - See: http://arduino.cc/en/Guide/MacOSX#toc8 In general, the serial port can be e.g. /dev/tty.usbmodem1411

        - Start the server: ./hil_server start &
            - There is no need to start the server with 'sudo'!
        - Stop the server: ./hil_server stop


Smoke Test:
-----------
Operate 'usb1' from command line using 'HARTS_IO_Client.exe':
    Harts_IO_Client.exe -c ping
    Harts_IO_Client.exe -c "PUT /api/v1/stack/hil1/usb1 {\"state\": 1}"
    Harts_IO_Client.exe -c "PUT /api/v1/stack/hil1/usb1 {\"state\": 0}"
    Harts_IO_Client.exe -c stop

Operate 'usb1' from command line using 'curl' utility:
    curl -X POST http://localhost:9999/api/v1/stack
    curl -X PUT http://localhost:9999/api/v1/stack/hil1/usb1 -H "Content-Type: application/json" -d "{\"state\": 1}"
    curl -X PUT http://localhost:9999/api/v1/stack/hil1/usb1 -H "Content-Type: application/json" -d "{\"state\": 0}"
    curl -X DELETE http://localhost:9999/api/v1/stack


Integration to CLA:
--------------------
    Windows:
    -------
        N.B. Make sure the HIL server is already running by navigating to http://localhost:9999 
        It's the user's responsibility to install the HIL Windows Service to start the server at Windows startup. 
        CLA doesn't start the HIL server any more but it expects it to be running.

        * CLA releases >= 15.41
            CLA already supports the new HIL REST-API server.
        * CLA releases < 15.41
            1. Download the latest version of Harts_io-x.y.groovy file from http://mu-artifactory-builds.imu.intel.com:8081/artifactory/harts-sit-swtools-imc-mu/hcloud_utils/hcloud_hil_sw/cla/
            2. Remove the suffix -x.y and replace the file \CLA\api_library\Harts_io.groovy
            3. Recompile CLA's API library
            4. Remove the old Harts_IO_Server.exe from \CLA\3rd_party\hil\HARTS_IO_Server.exe
            5. Copy the new Harts_IO_Client.exe from e.g. C:\HIL\client\HARTS_IO_Client.exe to \CLA\3rd_party\hil\Harts_IO_Client.exe
    Linux:
    -----
          N.B. No automatic mechanism is provided yet to start the hil_server process as a system service during startup.
        * CLA releases >= 16.60
            CLA already supports the new HIL REST-API server.


Known issues:
-------------
    - HTTP proxy must be bypassed for 'localhost':
        * Effects:
            - HARTS_IO_Client.exe won't work.
        * Workarounds: 
            - Export the environment variable 'no_proxy' to bypass proxy for localhost:
                'export no_proxy="127.0.0.1,localhost"'
            - Or unset the 'http_proxy' environment variable: 
                'set http_proxy='  (in Windows) 
                'unset http_proxy' (in Linux and MacOS)
            - When using the 'curl' utility, call it with the following arguments: 
                'curl --noproxy localhost http://localhost:9999/...'
    - When running the web server from the command line, it is sometimes not possible to terminate the
    process using Ctrl-C. The only solution to this currently is to manually terminate the process or wait for longer time
    to respond to Ctrl-C keystroke.


Revision history:
-----------------
2.2.1   07/31/2017
    - [Feature] SMS20963709  | Allow host to sleep while watchdog is enabled
        The host should inform Arduino with how many seconds it intends to sleep.
        When host wakes up, the test case must notify Arduino that is awake (sleep = 0)
        Arduino will reset the WDT by itself until the host wakes up.
        Should host not wake up in time the WDT will reset the board.
    - [Stability] SMS21163562 | Upgrade pySerial 2.7 to 3.4
        pySerial version 3.4 shows better stability in Linux Ubuntu 16.04 during Arduino Rx

2.2.0   07/24/2017
    - [Feature] SMS18408536 | Watchdog support (HIL to power off modem if connection with congatec is lost)
        On the client side, there is no notification mechanism in case the Arduino got reset. 
        The watchdog should reset the Arduino only in case the host PC freezes, so the campaign is compromised anyway.

2.1.0   01/17/2017
    - [Feature] SMS17921630 | Open connection to Arduino without resetting the HIL board's state

2.0.5   15/04/2016
    - [BugFix] SMS12118549 | ArduinoDriverRestart Windows utility must statically link to the C++ 2015 runtime  

2.0.4   11/03/2016
    - [BugFix] SMS11447947 | ArduinoDriverRestart Windows utility should handle both versions of Arduino boards (.cc and .org)
    - Improve logging when Arduino Tx doesn't work
    - Usability improvement in the Web UI: display connection status as label and standalone button for Connect / Disconnect

2.0.3   12/01/2016
    - [BugFix] SMS10431798 | Restart the Arduino driver when the COM port is open but Rx doesn't work

2.0.2   12/07/2015
    - [BugFix] SMS09758275 | Hil Server release based on Python 2.7 64bit

2.0.1   11/13/2015
    - [BugFix][SMS07336976] - PySerial can't open the COM port in Windows
    - HIL Server sets HTTP header 'Content-Type: application/json'

2.0.0   10/12/2015
    - Version renamed from 1.1.0 to 2.0.0 in order to avoid confusion from the new packaging as a suite.
    - [BugFix][Linux] pySerial bug fix on Linux kernel version 3.13.0-65 (Ubuntu)
    - [BugFix] Set all resources on/off doesn't affect USB HighSpeed (2.0) resources
    - [BugFix] Close COM port while error occurs during port opening.
    - [Feature] Provide unique log file for server, rotated after 10MB
    - [BugFix][Linux] Stop the server gracefully in case HTTP Proxy are used
    - [Feature][Windows] HARTS_IO_Client.exe logs all the activity
    - [Feature][Windows] The Windows OS service kills the hil_server.exe in case of not graceful server shutdown
    - [Feature][Windows] The Windows OS service display the reason why the service cannot be started in Windows Event Viewer

1.1.0   07/03/2015
    - Support to switch USB SuperSpeed (3.0) and USB HighSpeed (2.0) lanes
    - Test cases interface for CLA (Groovy API)
    - Support for Arduino Mega 2560 coming from www.arduino.org and also for Arduino Mega 2560 R2
    - The Hil Server sends HTTP code 410 (Gone) in case Arduino board is unresponsive.

1.0.2   03/31/2015    
    - Handle unresponsive Arduino board due to OS Device Driver:
    - Each command sent to Arduino is retried 5 times.
    - Close the communication port
    - Invoke external process to restart the Arduino Device Driver (Windows only).
        See hil_server.cfg, the key arduino_driver_fix to specify the path.
    - HilWinService.exe: use relative path to hil_server.exe

1.0.1   02/04/2015    
   - Bug fix: successfully auto-detect the serial port for Arduino in Linux (Ubuntu) and MacOS. (hil_lib-1.2.3)
   - Documented configuration file for the Windows OS Service, documented the port for Arduino for Ubuntu (/dev/ttyACM0) and MacOs (/dev/tty.usbmodem1411)
   - Documented issues related to access rights for the serial port in Ubuntu and 'curl' to bypass the proxy server for 'localhost'
   - Release HIL SW Stack Suite for Ubuntu64 and MacOS64.

1.0.0   01/29/2015    
  - First release as a bundle.
  - Added support to detect the SIM card insertion in the SIM switch slots.
        - See  GET /api/v<version>/stack/simsw<n>/sims
  - HIL board(s) can be stacked together with SIM switch(es) only with the Power Interface board.
  - The connection to Arduino is thread-safe.
  - The dashboard GUI is also compatible with Internet Explorer 8
  - Dashboard GUI redesign, automatic page refresh
