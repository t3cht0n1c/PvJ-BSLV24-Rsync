@echo off
cls
::
::  This must run while the user is logged in.
::
::  This will set registry key auditing and then create 3 reports on what was set.
::  Edit the PowerShell script to add or remove keys to audit.
::
::  This is based on the 'Windows Registry Auditing Cheat Sheet'
::  www.MalwareArchaeology.com\cheat-sheets
::
::  Created by Michael Gough - Malware Archaeology
::  Updated Dec 2018
::
:: ##################################################################################################
::
echo.
Echo  Setting Registry Auditing (This Key and Sub-Keys)...
echo.
echo -----------------------------------------------------------------------------------------------
::
powershell ./Set_User_Registry_Auditing.ps1
::
:: ##################################################################################################################
::
:End
