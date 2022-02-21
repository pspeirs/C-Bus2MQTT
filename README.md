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
* For each C-Bus object you wish to publish to the MQTT broker, simply add the above keyword into the objects keywords list.
* Set up each resident script with the correct connection details for your MQTT broker.


### Creating the project
* *File > New > C Project*. 
* Enter a project name. *Project type* should be **Embedded C Project**. Next.
* Search for the chip (STM32F107VC) and select it. Next.
* Uncheck *Use tiny printf*. Next.
* Keep Next-ing and finally Finish. The project should now be created, with *main.c* displayed first.

### Importing the needed source files
* Copy the *core_cm3.h* in the repo to overwrite the default version in your project's *Libraries/CMSIS/Include*.
* Right-click on the project name in the *Project Explorer* pane. Select **Import**.
* In the window, select General > Filesystem. Next.
* Select **Browse** and navigate to the repository. Select the *libcbus* folder and click **OK**.
* You should see all the *libcbus* files now displayed in the window. Click **Select All** to add all the files.
* Click **Advanced**. Select **Create links in workspace**. Leave everything else as is. Click **Finish**.
* A new *libcbus* folder should now be visible in the *Project Explorer* pane, its files present as symlinks.
* Follow those same steps to **Import** the *src* folder.
* If asked whether to overwite *src* files already present, select **Yes to All**.
* The *src* files should now be imported as symlinks.

### Adding the include paths
* Go to *Project > Properties > C/C++ General > Paths and Symbols > Includes*.
* Under *GNU C*, select the existing *src* path and click **Delete** to since that path no longer leads anywhere useful.
* Click **Add**. Select *Add to all configurations* and *Add to all languages*. 
* Click **File system** and navigate to the *src* folder in the git repo. Click **OK** till you exit the *Properties* window.
* If asked, go ahead and rebuild the index.
* Repeat the same steps to add the repo *libcbus* folder to the *Includes*.

### Adding source file locations
* Go to *Project > Properties > C/C++ General > Paths and Symbols > Source Locations*.
* Click **Add Folder**, select *libcbus*. Click **OK** till you exit the *Properties* window.

### Verification
* *Project > Build Project* to confirm that the project has been setup correctly.

### Printf and floats
By default, floats will display as blanks when using printf
*  *Project > Properties > C/C++ Build > Settings > Tool Settings > C Linker > Command*.
*  Add ***-u _printf_float*** to the **Command** text box.

### Generate Intex Hex File
Create a intel hex file on build, used with MikroProg Programmer
*  *Project > Properties > C/C++ Build > Settings > Tool Settings > Other > Output format*.
*  Ensure **Convert build output** is checked and format is set to **Intel Hex**.


**NOTE**: Before editing any symlinked files, make sure to first close them in the Editor (if they are already open) and then re-open them.
