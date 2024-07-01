## Windows AD DS first-steps

 - Verify PowerShell version installed
```powershell
$PSVersionTable
```

 - Disable PowerShell restrictions
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

 - Enable PowerShell restrictions
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted
```

```powershell
Get-InstalledModule -Name AuditPolicyDsc
Get-InstalledModule -Name SecurityPolicyDsc
Get-InstalledModule -Name NetworkingDsc
Get-InstalledModule -Name PSDesiredStateConfiguration
```
```powershell
Install-Module -Name AuditPolicyDsc
Install-Module -Name SecurityPolicyDsc
Install-Module -Name NetworkingDsc
Install-Module -Name PSDesiredStateConfiguration
```

 - Disable Guest account
```powershell
Get-LocalUser Guest | Disable-LocalUser
Disable-ADAccount -Identity Guest
```

 - Disable IPv6
```powershell
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
```

 - Disable SMBv1
```powershell
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
```

 - Disable Print Spooler service
```powershell
Stop-Service -Name Spooler -Force
Set-Service -Name Spooler -StartupType Disabled
```

 - Update password length policy
```powershell
Set-ADDefaultDomainPasswordPolicy -Identity lab2012.ronpinz.com -MinPasswordLength 9
```

 - Update Global Policies on client machines
```powershell
gpupdate /force
```

```powershell
# Disable Guest Account
Get-LocalUser Guest | Disable-LocalUser
Disable-ADAccount -Identity Guest
# Disable IPv6
Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
#  Disable Print Spooler service
Stop-Service -Name Spooler -Force
Set-Service -Name Spooler -StartupType Disabled
# Update password length policy
Set-ADDefaultDomainPasswordPolicy -Identity lab2012.ronpinz.com -MinPasswordLength 9
```

 - Hardened UNC Paths
[How to own any Windows network with group policy hijacking attacks](https://labs.withsecure.com/publications/how-to-own-any-windows-network-with-group-policy-hijacking-attacks)
```
\\*\NETLOGON RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1
\\*\SYSVOL   RequireMutualAuthentication=1, RequireIntegrity=1, RequirePrivacy=1
```
 - display addapters with IPv6
```powershell
Get-NetAdapterBinding -ComponentID ms_tcpip6
```
 - disable print Spooler service
```powershell
Stop-Service -Name Spooler -Force -PassThru
Set-Service -Name Spooler -StartupType Disabled
```
 - disable SMBv1
```powershell
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
Uninstall-WindowsFeature –Name FS-SMB1 –Remove
```
 - disable SMBv1 Protocol
```powershell
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
```
 - Unprotected OUs
```powershell
Get-ADOrganizationalUnit -filter * -Properties ProtectedFromAccidentalDeletion | Where-Object {$_.ProtectedFromAccidentalDeletion -eq $false}
```
 - Protect unprotected OUs
```powershell
Get-ADOrganizationalUnit -filter * -Properties ProtectedFromAccidentalDeletion | Where-Object {$_.ProtectedFromAccidentalDeletion -eq $false} | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true
```
 - time servers
```powershell
w32tm /config /manualpeerlist:"time.cloudflare.com time.windows.com" /syncfromflags:manual /update
```
