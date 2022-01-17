#!/bin/bash
# script name: catherineClassic.fix.sh
# author: GostLy
#
#!!! Download(Proton 6.1-GE-2): 
#!!! https://github.com/GloriousEggroll/proton-ge-custom/releases/download/6.1-GE-2/Proton-6.1-GE-2.tar.gz
#!!! Follow the install instructions: 
#!!! https://github.com/GloriousEggroll/proton-ge-custom/wiki
#
# Linux dependencies: curl, git
#
##################################################################################
#                           !!!!READ ME FIRST!!!!                                #
#                                                                                #
# Before running this script it is important that you read this section.         #
#                                                                                #
# The following is required to do in steam:                                      #
#                                                                                #
# Inside your steam library find Catherine Classic and open properties:          #
# Under Launch Options, add the following: PROTON_USE_WINED3D=1 %command%        #
# Change compatibility to force the use of Proton-6.1-GE-2                       #
# Now open/run the game once so that the wine pfx gets created.                  #
#                                                                                #
# Edit/verify the directories defined below (steamLib AND steamProtonDir)        #
# Run the script and with any luck you'll be able to play Catherine Classic!     #
#                                                                                #
##################################################################################
# This script is intended to fix Catherine Classic so that it will work on Linux;#
#                                                                                #
#@@@ WARNING: There are no error checks in this script so use at your own risk!  #
#@@@ But as long as you set all variables correctly there will be no problems ;) #
##################################################################################

# steamAppID should only be changed if you're trying to run this script for another game.
steamAppID="893180" # Catherine Classic

# *** Edit: gitMethod *** set to either SSH or HTTPS
# If you've never setup git to work with SSH then leave it set to HTTPS
gitMethod="HTTPS"

# *** Edit: steamLib *** to the location where the game is installed
# If you only have one drive on your PC then most likely you can use the default location
steamLib=~/.steam/steam # Default Location of steam library
#steamLib="/mnt/Samsung.500/SteamLibrary" # Example location of steam on another drive

# *** Edit: steamProtonDir *** to the location of the Proton version you intend to use with Catherine Classic;
steamProtonDir=~/.steam/steam/compatibilitytools.d/Proton-6.1-GE-2

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# @@@ NO EDITING REQUIRED BEYOND THIS POINT @@@
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

winebin="$steamProtonDir/dist/bin"
export WINEPREFIX="$steamLib/steamapps/compatdata/$steamAppID/pfx"

syswow64="$WINEPREFIX/drive_c/windows/syswow64"

# Install mediafoundation:
if [ ! -d ~/tmp ]; then
	mkdir -p ~/tmp
fi
cd ~/tmp
if [ ! -f ~/tmp/mf-install/mf-install.sh ]; then	
	if [ $gitMethod == "SSH" ]; then
		git clone git@github.com:z0z0z/mf-install.git
	else
		git clone https://github.com/z0z0z/mf-install.git
	fi
fi
cd mf-install
PROTON="$steamProtonDir" ./mf-install.sh -proton

# Download needed DLL files:
rm "$syswow64/dxva2.dll"
rm "$syswow64/evr.dll"
curl -o "$syswow64/dxva2.dll" https://github.com/GostLy/GLib/raw/main/dxva2.dll
curl -o "$syswow64/evr.dll" https://github.com/GostLy/GLib/raw/main/evr.dll
curl -o "$syswow64/mp4sdecd.dll" https://github.com/GostLy/GLib/raw/main/mp4sdecd.dll
curl -o "$syswow64/wmadmod.dll" https://github.com/GostLy/GLib/raw/main/wmadmod.dll

# Register DLL files inside of WINEPREFIX:
$winebin/wine regsvr32 $syswow64/evr.dll
$winebin/wine regsvr32 $syswow64/mp4sdecd.dll
$winebin/wine regsvr32 $syswow64/wmadmod.dll

# Add DLL's to the registry
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\CLSID\\{41457294-644c-4298-a28a-bd69f2c0cf3b}" /f /t REG_SZ /v "" /d "ASF Byte Stream Handler"
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\CLSID\\{41457294-644c-4298-a28a-bd69f2c0cf3b}\\InprocServer32" /f /t REG_SZ /v "" /d "C:\\windows\\system32\\mf.dll"
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\CLSID\\{41457294-644c-4298-a28a-bd69f2c0cf3b}\\InprocServer32" /f /t REG_SZ /v "ThreadingModel" /d "Both"
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\MediaFoundation\\Transforms\\2eeb4adf-4578-4d10-bca7-bb955f56320a" /f /t REG_SZ /v "" /d "WMAudio Decoder MFT"
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\MediaFoundation\\Transforms\\2eeb4adf-4578-4d10-bca7-bb955f56320a" /f /t REG_BINARY /v "InputTypes" /d "6175647300001000800000aa00389b716101000000001000800000aa00389b716175647300001000800000aa00389b716201000000001000800000aa00389b71"
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\MediaFoundation\\Transforms\\2eeb4adf-4578-4d10-bca7-bb955f56320a" /f /t REG_BINARY /v "OutputTypes" /d "6175647300001000800000aa00389b710300000000001000800000aa00389b716175647300001000800000aa00389b710100000000001000800000aa00389b71"
$winebin/wine64 reg add "HKEY_CLASSES_ROOT\\Wow6432Node\\MediaFoundation\\Transforms\\Categories\\9ea73fb4-ef7a-4559-8d5d-719d8f0426c7\\2eeb4adf-4578-4d10-bca7-bb955f56320a"

echo "Try playing Catherine Classic now and enjoy!"
