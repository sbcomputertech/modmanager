# SpiderHeck Mod Manager

## How to install / add mods
### Setup
1. Download and unzip the file from the releases page
2. Run the `mod_manager` application
3. Go to the settings tab and set the game folder. On windows, this defaults to `C:\Program Files (x86)\Steam\steamapps\common\SpiderHeck`
4. Also on the settings tab, set the instance root to an empty folder on your computer

### Vanilla
5. Go to the instances tab (second), and click `select` under the vanilla instance
6. Click the launch button in the bottom right

### Adding / using mods
5. Go to the instances tab (second), and click the plus button at the bottom
6. Fill in the name and id. (Note: the ID will also be the name of the folder in the instance root path you set earlier)
7. Under the instance name, click the mods button
8. Click the add button at the bottom

#### ModWeaver !NOT IMPLEMENTED YET!
9. Enter the GUID of the mod you want (it will look something like this: `com.example.spiderheckmod`)
10. Click the install button, and it will take care of the rest

#### Local file
9. Click the locate button, and browse to the .dll file of the mod you want to install
10. Fill in the mod's name, GUID and version
11. Click the install button to add it


## Features
* [x] Instances
* [ ] ModWeaver API integration
* ~~Some BepInHecks config settings~~
* [x] File picker for mod dlls
* [x] Game stat system
* [x] Display BepInHecks version on instances
