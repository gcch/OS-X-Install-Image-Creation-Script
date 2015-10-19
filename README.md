# OS X Installation Disk Image Creation Script

## Overview
For you who prefer a optical installation disk to a USB installation media

## Description
You can make a OS X installation image from an app file which can be got from App Store.

## Supported Installation Packages
* Install OS X Mavericks.app
* Install OS X Yosemite.app
* Install OS X El Capitan.app

Maybe this script can be executed with the below packages:
* Install Mac OS X Lion.app (customizing this script is required)
* Install OS X Mountain Lion.app

## Usage
1. Deploy this script at any folder
2. Open it and rewrite the variable which is named *nickname* to any OS X nickname such as Mavericks, Yosemite, El Capitan, and so on.
3. Deploy "Install OS X *nickname*.app" at the same folder
4. Grant execute permission (example: chmod +x os-x-inst-dsk-img-creation-script.command)
5. Execute this script (example: ./os-x-inst-dsk-img-creation-script.command)
6. Wait for a while
7. Generate a installation DMG image (and burn it on a DVD+-R/RW DL or BD-R/RE blank media with Disk Utility)

OS X Terminal:

    $ cd ~/Desktop
    $ git clone https://github.com/gcch/OS-X-Installation-Disk-Image-Creation-Script.git
    $ cd OS-X-Installation-Disk-Image-Creation-Script
    $ vim os-x-inst-dsk-img-creation-script.command
    $ chmod +x os-x-inst-dsk-img-creation-script.command
    $ cp "/Applications/Install OS X *nickname*.app" ./
    $ ./os-x-inst-dsk-img-creation-script.command


## License
This script is released under the MIT license. See LICENSE.txt.

## Author
* tag (Twitter: [@tag_ism](https://twitter.com/tag_ism "tag (@tag_ism) | Twitter") / Blog: http://karat5i.blogspot.jp/)
