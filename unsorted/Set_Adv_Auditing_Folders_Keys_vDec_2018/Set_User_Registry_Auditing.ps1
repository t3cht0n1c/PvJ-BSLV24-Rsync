######################################################
#                                                    #
#  POWERSHELL AUDITING SCRIPT TO LOG THE BAD STUFF   #
#         This script adds Registry auditing         #
#      to objects commonly accessed by malware.      #
#  Look in the Security event log for EventID 4657.  #
#             Created by Louie Lemert...             #
#        with lots of help from The Internet.        #
#                                                    #
#              updated by Michael Gough              #
#             www.MalwareArchaeology.com             #
#                                                    #
#                     Oct, 2016                      #
#                 Updated Dec 2018                   #
#        Added flexible file folder location         #
#                                                    #
######################################################
#
# Set directory files were placed
#
$Tool_Path = 
$Tool_Path = $pwd.Path
#
#  Create needed report
#
Remove-Item $Tool_Path\z_1_Initial_Keys_Audit_Settings.csv
Remove-Item $Tool_Path\z_2_Final_Keys_Audit_Settings.csv
#
New-Item -ItemType "file" -Path $Tool_Path\z_1_Initial_Keys_Audit_Settings.csv
New-Item -ItemType "file" -Path $Tool_Path\z_2_Final_Keys_Audit_Settings.csv
#
Write-Output "This file contains keys that do not exist."
Write-Output "This file contains keys that do not exist." | Out-File -FilePath $Tool_Path\z_3_Non-Existing_Reg_Keys.txt 
Write-Output -------------------------------------------------------------------------------------------------------------------- | Out-File -Append -FilePath $Tool_Path\z_3_Non-Existing_Reg_Keys.txt
#
function AuditAndSegmentExistingIndividualRegKeys {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$key,
        [string]$AccessSent,
        [string]$KeyAndSubs
    )
    
    if(Test-Path $key){
        Get-Acl $key -Audit | select Path,AuditToString | Export-csv -Append $Tool_Path\z_1_Initial_Keys_Audit_Settings.csv -Force
        $hold = Get-Acl $key
        $hold = $hold.path
        $RegKey_ACL = Get-Acl -Path $hold
        $AccessRule = New-Object System.Security.AccessControl.RegistryAuditRule("Everyone",$AccessSent,$KeyAndSubs,"none",”Success")
        $RegKey_ACL.AddAuditRule($AccessRule)
        $RegKey_ACL | Set-Acl -Path $hold
        Write-Output "Passed,$hold"
        Get-Acl $key -Audit | select Path,AuditToString | Export-csv -Append "$Tool_Path\z_2_Final_Keys_Audit_Settings.csv" -Force

     }else{
        $key| Format-List Path,AuditToString  | Out-File -Append -FilePath "$Tool_Path\z_3_Non-Existing_Reg_Keys.txt"
        Write-Output "Failed,$key" 
     }
}
function AuditAndSegmentExistingUserKeys {
    param
    (
        [Parameter(Mandatory=$true)]
        [string]$keySent,
        [string]$AccessSent,
        [string]$KeyAndSubs
    )
    $hkeyUsers = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('USERS', $env:COMPUTERNAME)
    $hkeyUsersSubkeys = $hkeyUsers.GetSubKeyNames()
    Set-Location Registry::\HKEY_USERS
    New-PSDrive HKU Registry HKEY_USERS
    Set-Location HKU:
    foreach($key in $hkeyUsersSubkeys){
        if(Test-Path -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\"){
            Write-Output "passed,$keySent"
            get-acl "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\" -Audit | select Path,AuditToString |  Export-csv -Append "$Tool_Path\z_1_Initial_Keys_Audit_Settings.csv" -Force
            $RegKey_ACL = Get-Acl -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\"
            $AccessRule = New-Object System.Security.AccessControl.RegistryAuditRule("Everyone",$AccessSent,$KeyAndSubs,"none",”Success")
            $RegKey_ACL.AddAuditRule($AccessRule)
            $RegKey_ACL | Set-Acl -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\"
            Write-Output "Passed,Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\"
            get-acl -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\" -Audit | select Path,AuditToString |  Export-csv -Append "$Tool_Path\z_2_Final_Keys_Audit_Settings.csv" -Force
        }else{
            Write-Output "failed,$keySent"
            "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$key\$keySent\" | Out-File -Append -FilePath "$Tool_Path\z_3_Non-Existing_Reg_Keys.txt"
        }
    }
}
#
# Set HKCU This Key Only Settings (none)
#
AuditAndSegmentExistingUserKeys ".DEFAULT\Control Panel\Desktop” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingUserKeys "Environment” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingUserKeys "Control Panel\Desktop” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingUserKeys "Software\Microsoft\Windows NT\CurrentVersion\Accessibility” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingUserKeys "Software\Microsoft\Windows NT\CurrentVersion\Windows" "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "none"
#
# Set HKCU This Key and subkeys Settings (containerinherit)
#
AuditAndSegmentExistingUserKeys “Software\Microsoft\Windows\CurrentVersion\Run” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Windows\CurrentVersion\RunOnce” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Windows\CurrentVersion\Shell Extentions\Cached” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Windows\CurrentVersion\Explorer” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Office\Outlook\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Office\PowerPoint\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Office\Word\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Office\14.0\Word” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Office Test” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\Internet Explorer\UrlSearchHooks” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\ALPS” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Policies\Microsoft\Windows\System\Scripts” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Nico Mak Computing” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Synaptics” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\WinRAR” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\CTF” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Microsoft\MultiMedia” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Classes\CLSID\{b5f8350b-0548-48b1-a6ee-88bd00b4a5e7}” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Classes\Wow6432Node\CLSID\{BCDE0395-E52F-467C-8E3D-C4579291692E}” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
#
# Set HKCU MUICache This Key and subkeys Settings (containerinherit)
#
AuditAndSegmentExistingUserKeys “Software\Microsoft\Windows\ShellNoRoam\MUICache” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
AuditAndSegmentExistingUserKeys “Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MUICache” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “containerinherit”
#
# Set HKLM This Key Only Settings (none)
#
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\WBEM\CIMOM” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "none"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs" "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "none"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Windows" "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "none"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Lsa” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SecurityProviders” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SecurityProviders\WDigest” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Terminal Server\Wds\rdpwd” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Terminal Server\AddIns” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" “none”
#
# Set HKLM This Key and subkeys Settings (containerinherit)
#
#AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\*\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\AllFileSystemObjects\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\Directory\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\Folder\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\Protocols\Filter” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\Protocols\Handler” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\CLSID\{083863F1-70DE-11d0-BD40-00A0C911CE86}\Instance” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Classes\Htmlfile\Shell\Open\Command” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Clients\Mail” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Clients\.NETFramework” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Active Setup\Installed Components” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Internet Explorer\Toolbar” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Office\Outlook\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Office\Excel\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Office\PowerPoint\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Office\Word\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Terminal Server Client” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\WBEM\ESS” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\Credential Provider Filters” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\PLAP Providers” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\ShellExecuteHooks” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\TBDEn” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Group Policy\Scripts” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows\CurrentVersion\Shell Extentions” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AeDebug” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Drivers32” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Font Drivers” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Windows\IconServiceLib” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Policies\Microsoft\Windows\System\Scripts” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Policies\Microsoft\PowerShell” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
#
# Set HKLM System (containerinherit)
#
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\SafeBoot” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Session Manager” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Print\Monitors” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\NetworkProvider\Order” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\StartupPrograms” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Services” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Services\NTDS” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Services\Remote Access” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\System\CurrentControlSet\Services\WinSock2” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
#
# Set HKLM Wow6432Node (containerinherit)
#
#AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Classes\*\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Classes\AllFileSystemObjects\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Classes\Directory\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Classes\Folder\ShellEx” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Classes\CLSID\{083863F1-70DE-11d0-BD40-00A0C911CE86}\Instance” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\.NETFramework” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Office\Outlook\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Office\Excel\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Office\PowerPoint\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Office\Word\Addins” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellExecuteHooks” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellIconOverlayIdentifiers” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\AeDebug” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
AuditAndSegmentExistingIndividualRegKeys "HKLM:\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32” "SetValue,CreateSubKey,Delete,ChangePermissions,TakeOwnership" "containerinherit"
#
#  Open files after scripts complete
#
#  Remark in the next 3 lines by taking out the # if you want the files to open aftger the script runs
#
#Invoke-Item  "$Tool_Path\z_3_Non-Existing_Reg_Keys.txt"
#Invoke-Item  "$Tool_Path\z_1_Initial_Keys_Audit_Settings.csv"
#Invoke-Item  "$Tool_Path\z_2_Final_Keys_Audit_Settings.csv"
