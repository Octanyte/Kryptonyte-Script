::     ___       _                    _              
::    / _ \  ___| |_ __ _ _ __  _   _| |_ ___        Soham Ray [Octanyte]
::   | | | |/ __| __/ _` | '_ \| | | | __/ _ \       https://octanyte.com
::   | |_| | (__| || (_| | | | | |_| | ||  __/       https://github.com/Octanyte
::    \___/ \___|\__\__,_|_| |_|\__, |\__\___|       https://gitlab.com/Octanyte
::                              |___/                
::
:: Description:     This script performs a number of operations using Windows10's built-in tools to-
::                  1. Clean-up unwanted leftover files, folders etc.
::                  2. Repair the Windows10 installation using DISM & SFC.
::                  3. Reset & clean network IPs, HOSTS file etc.
::                  4. Check & Repair system drive / filesystem.
::                  5. Clean-up old Windows Restore Points.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
cls

color 0E
title Kryptonyte Maintenance Script

:: Intro.
echo.
echo  "--------------------------------------------------------------------------"
echo  "      _   __                     _                         _              "
echo  "     | | / /                    | |                       | |             "
echo  "     | |/ /  _ __  _   _  _ __  | |_   ___   _ __   _   _ | |_   ___      "
echo  "     |    \ | '__|| | | || '_ \ | __| / _ \ | '_ \ | | | || __| / _ \     "
echo  "     | |\  \| |   | |_| || |_) || |_ | (_) || | | || |_| || |_ |  __/     "
echo  "     \_| \_/|_|    \__, || .__/  \__| \___/ |_| |_| \__, | \__| \___|     "
echo  "                    __/ || |                         __/ |                "
echo  "                   |___/ |_|                        |___/                 "
echo  "                                                                          "
echo  "                                                                          "
echo  "                Welcome to the Kryptonyte Maintenance Script              "
echo  "                                                                          "
echo  "                 This script will perform various operations              "
echo  "                                                                          "
echo  "                                     to                                   "
echo  "                                                                          "
echo  "                       Clean & Optimize your system                       "
echo  "                                                                          "
echo  "--------------------------------------------------------------------------"
echo.

:: Begin DISM System File Repair.
echo Starting System File Repair using DISM . . . .
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth

:: Begin SFC System File Repair.
echo Starting System File Repair using SFC . . . .
sfc /scannow

:: Run Disk-Cleanup Utility.
echo Opening Windows Disk Cleanup Utility . . . .
"%windir%\system32\cleanmgr.exe" /sageset:65535
"%windir%\system32\cleanmgr.exe" /sagerun:65535

:: Clean Temp & Prefetch files.
echo Starting Temporary ^& Prefetch Files clean-up . . . .
del /s /f /q %windir%\temp\*.*
del /s /f /q %windir%\Prefetch\*.*
del /s /f /q %windir%\system32\dllcache\*.*
del /s /f /q "%SysteDrive%\Temp"\*.*
del /s /f /q %temp%\*.*

:: Clean Temporary User-Files.
echo Starting Temporary User-Files clean-up . . . .
del /s /f /q "%USERPROFILE%\Local Settings\History"\*.*
rd /s /q "%USERPROFILE%\Local Settings\History"
del /s /f /q "%USERPROFILE%\Local Settings\Temporary Internet Files"\*.*
rd /s /q "%USERPROFILE%\Local Settings\Temporary Internet Files"
del /s /f /q "%USERPROFILE%\Local Settings\Temp"\*.*
rd /s /q "%USERPROFILE%\Local Settings\Temp"
del /s /f /q "%USERPROFILE%\Recent"\*.*
rd /s /q "%USERPROFILE%\Recent"
del /s /f /q "%USERPROFILE%\Cookies"\*.*
rd /s /q "%USERPROFILE%\Cookies"
del /s /f /q "%USERPROFILE%\3D Objects"\*.*
rd /s /q "%USERPROFILE%\3D Objects"
del /s /f /q "%USERPROFILE%\Contacts"\*.*
rd /s /q "%USERPROFILE%\Contacts"
del /s /f /q "%USERPROFILE%\Favorites"\*.*
rd /s /q "%USERPROFILE%\Favorites"
del /s /f /q "%USERPROFILE%\Intel"\*.*
rd /s /q "%USERPROFILE%\Intel"
del /s /f /q "%USERPROFILE%\Links"\*.*
rd /s /q "%USERPROFILE%\Links"
del /s /f /q "%USERPROFILE%\MicrosoftEdgeBackups"\*.*
rd /s /q "%USERPROFILE%\MicrosoftEdgeBackups"
del /s /f /q "%USERPROFILE%\Saved Games"\*.*
rd /s /q "%USERPROFILE%\Saved Games"
del /s /f /q "%USERPROFILE%\Searches"\*.*
rd /s /q "%USERPROFILE%\Searches"

:: Clean UWP App-Packages & Package Cache.
echo Starting UWP App-Packages ^& Package Cache clean-up . . . .
del /s /f /q "%PROGRAMDATA%\Packages"\*.*
rd /s /q "%PROGRAMDATA%\Packages"
del /s /f /q "%PROGRAMDATA%\Package Cache"\*.*
rd /s /q "%PROGRAMDATA%\Package Cache"
del /s /f /q "%PROGRAMDATA%\Intel"\*.*
rd /s /q "%PROGRAMDATA%\Intel"

:: Clean SSH Keys & Sessions.
echo Starting SSH Cleanup . . . .
del /s /f /q "%PROGRAMDATA%\ssh"\*.*
rd /s /q "%PROGRAMDATA%\ssh"

:: Start App-specific clean-up.
echo Starting App-Specific clean-up . . . .
:: Discord.
del /s /f /q "%PROGRAMDATA%\SquirrelMachineInstalls"\*.*
rd /s /q "%PROGRAMDATA%\SquirrelMachineInstalls"

:: Run Disk-Defrag Utility.
echo Opening Disk Defrag Utility . . . .
dfrgui.exe

:: Run Disk-Check Utility.
echo Scheduling Disk Check . . . .
chkdsk /scan /f /perf /sdcleanup

:: Clear old System Restore Points.
echo Clearing old Restore Points . . . .
vssadmin delete shadows /all

:: Begin Network Reset.
echo Starting Network Reset process . . . .

:: Reset the HOSTS file.    [Note: Comment this section out if you have custom HOSTS entries]
echo Resetting the HOSTS file . . . .
pushd\windows\system32\drivers\etc
attrib -h -s -r hosts
echo 127.0.0.1 localhost>HOSTS
attrib +r +h +s hosts
popd

:: Reset IP configurations & Flush the DNS Resolver Cache.
echo Resetting IP Configurations ^& flushing DNS resolver Cache . . . .
ipconfig /release
ipconfig /renew
ipconfig /flushdns
netsh winsock reset all
netsh int ip reset all

echo The maintenance operation completed successfully. Please restart your PC now.
pause

:::::::::::::::::::::::::::::::::::::::::::: END OF SCRIPT :::::::::::::::::::::::::::::::::::::::::