Welcome to the HIL (H-Cloud Hardware IO Lite) Broker.
http://harts.intel.com/hil


Prerequisites:
-------------

    - Python 2.7 or above
    - Requests python package (http://docs.python-requests.org/en/latest/)
    - Tested on Windows 8, but should work on other systems


    Broker (aka Client) between the CLA (or any other party) and the HIL Server
            CLA   <->  Broker/Client   <->   HIL Server
    Dynamics:
        - CLA makes a call to hil_server by executing the broker CLU and passing the command as parameter
        - The broker makes a REST API call to the HIL server by passing the requested command.
        - The broker exits the process with the exit code 0 if the command was successful, and 1 otherwise
            - Any error message will be displayed at console
        - CLA interprets these error codes

    The HIL server (service) is always available as a http server but the board is not connected by default.
    This is to allow disconnecting the USB port safely for e.g. board replacements, maintenance, etc.

    Via the broker, CLA requests connecting and disconnecting the board.
    Connecting to the board is done via the 'ping' command, whereas disconnecting is done via the 'stop' command.
    Connecting the board means also "starting a session", whereas disconnecting means "closing the session"."""

Usage:
------
<HIL_broker> -c <command> -a <HIL server address> -p <HIL server port>
   where:
        <command> can be one of the followings:
            ping
            stop
            "<POST|DELETE|GET|PUT any_rest_url {json_payload}>"
        <HIL server URL> is the IP address of the HIL server, default is 'localhost'
        <HIL server port> is the port of the HIL server, default is 9999
        All REST API URLs must be prefixed with '/', e.g. /api/v1/stack/hil1/usb1,
        e.g. <HIL_broker> -c "PUT /api/v1/stack/hil1/usb1 {\"state\": 1}"  or
             <HIL_broker> -c "PUT /api/v1/stack/hil1/usb1 {\"state\": 0}" or
             <HIL_broker> -c "PUT /api/v1/stack/hil1/usb1 {\"state\": \"on\"}" or
             <HIL_broker> -c "PUT /api/v1/stack/hil1/usb1 {\"state\": \"off\"}" or
             <HIL_broker> -c "PUT /api/v1/stack/simsw0 {\"enabled\": true, \"sim\": \"SIM0\"}"
   It exits with error code 1 if the command was successful and 0 otherwise.

<HIL_broker> -h
   prints help information message

<HIL_broker> -V
    prints the version of the broker and exits


Mapping of the Harts_IO_Client.exe v4.0 commands to the new commands:
------------------------------------------------------------------------
    all_off         "PUT /api/v1/stack/hil1/all {\"state\": 0}"
    usb1_on         "PUT /api/v1/stack/hil1/usb1 {\"state\": 1}"
    usb1_off        "PUT /api/v1/stack/hil1/usb1 {\"state\": 0}"
    usb2_on         "PUT /api/v1/stack/hil1/usb2 {\"state\": 1}"
    usb2_off        "PUT /api/v1/stack/hil1/usb2 {\"state\": 0}"
    usb3_on         "PUT /api/v1/stack/hil1/usb3 {\"state\": 1}"
    usb3_off        "PUT /api/v1/stack/hil1/usb3 {\"state\": 0}"
    power1_on       "PUT /api/v1/stack/hil1/power1 {\"state\": 1}"
    power1_off      "PUT /api/v1/stack/hil1/power1 {\"state\": 0}"
    power2_on       "PUT /api/v1/stack/hil1/power2 {\"state\": 1}"
    power2_off      "PUT /api/v1/stack/hil1/power2 {\"state\": 0}"
    power3_on       "PUT /api/v1/stack/hil1/power3 {\"state\": 1}"
    power3_off      "PUT /api/v1/stack/hil1/power3 {\"state\": 0}"
    switch1_on      "PUT /api/v1/stack/hil1/switch1 {\"state\": 1}"
    switch1_off     "PUT /api/v1/stack/hil1/switch1 {\"state\": 0}"
    switch2_on      "PUT /api/v1/stack/hil1/switch2 {\"state\": 1}"
    switch2_off     "PUT /api/v1/stack/hil1/switch2 {\"state\": 0}"
    switch3_on      "PUT /api/v1/stack/hil1/switch3 {\"state\": 1}"
    switch3_off     "PUT /api/v1/stack/hil1/switch3 {\"state\": 0}"
