# C-Bus2MQTT
LUA Script Interface from SHAC to MQTT Server

## Installation Instructions

### cbus2mqtt.lua
This script is responsible for publishing messages passed in by the event script call_cbus2mqtt.lua
* Configure as a resident script running with an interval of 0 seconds

### mqtt2cbus.lua
This script subscribes to the relevant mqtt topic on the broker.  When it receives a valid message, it will be processed and passed into te C-Bus system.
* Configure as a resident script running with an interval of 0 seconds

### call_cbus2mqtt.lua
This is an event script using a keyword as the trigger rather than an object.  For example, MQTT_Grp.

## Configuration
* For each C-Bus object you wish to publish to the MQTT broker, simply add the above keyword 'MQTT_Grp' into the objects keywords list.
* Set up each resident script with the correct connection details for your MQTT broker.

