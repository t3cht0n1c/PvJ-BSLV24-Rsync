@echo off
cls
::
::  Change the username to match the username you want to set auditing on
::  This must run while the user is logged in.
::
::  This is based on the 'Windows File Auditing Cheat Sheet'
::  www.MalwareArchaeology.com\cheat-sheets
::
::  Created by Michael Gough - Malware Archaeology
::  Updated Dec 2018
::
:: ##################################################################################################
::
echo.
Echo  Setting Folder Auditing (This Folder, Subfolders and Files) on the following Folders...
echo.
echo -----------------------------------------------------------------------------------------------
::
powershell ./Set_User_Folder_Auditing_This_folder_sub-folders_and_files_v1.ps1 "C:\Users\Default\AppData\Roaming\Microsoft\Windows\'Start Menu'\Programs\Startup"
::
powershell ./Set_User_Folder_Auditing_This_folder_sub-folders_and_files_v1.ps1 "C:\users\public"
::
powershell ./Set_User_Folder_Auditing_This_folder_sub-folders_and_files_v1.ps1 "c:\users\%USERNAME%\appdata\local"
::
powershell ./Set_User_Folder_Auditing_This_folder_sub-folders_and_files_v1.ps1 "c:\users\%USERNAME%\appdata\locallow"
::
powershell ./Set_User_Folder_Auditing_This_folder_sub-folders_and_files_v1.ps1 "c:\users\%USERNAME%\appdata\roaming"
::
:: ##################################################################################################################
::
:End
