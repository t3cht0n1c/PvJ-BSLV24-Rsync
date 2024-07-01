# This is a crazy spell that will somehow disable PSExec due to some Windows magic. Credit to John Lambert's tweet for telling me how to do this
# Below is an sc query and the expected output when PSExec is ENABLED
# sc.exe \\targethost
# D:(A;;CC;;;AU)(A;;CCLCRPRC;;;IU)(A;;CCLCRPRC;;;SU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)(A;;CC;;;AC)

# Run this command in a CMD shell (not Powershell) to disable psexec on the target
# sc.exe sdset scmanager 'D:(D;;GA;;;NU)(A;;CC;;;AU)(A;;CCLCRPRC;;;IU)(A;;CCLCRPRC;;;SU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)(A;;CC;;;AC)'

# Disables File and Printer Sharing
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=No
# Disables the admin$ share
reg add HKLM\System\CurrentControlSet\Services\LanManServer\Parameters /f /v AutoShareWks /t REG_DWORD /d 0

# For servers
# reg add HKLM\System\CurrentControlSet\Services\LanManServer\Parameters /f /v AutoShareServer /t REG_DWORD /d 0

# Disable SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol $False -Force

# Disable SMBv2
Set-SmbServerConfiguration -EnableSMB2Protocol $False -Force

# Force SMBv3 encyrption
Set-SmbServerConfiguration -EncryptData $True -Force

# Force SMB siging
Set-SmbServerConfiguration -EnableSecuritySignature $True -Force

# Force SMB signing
Set-SmbServerConfiguration -RequireSecuritySignature $True -Force

# Rate limit SMB connections per session (30s)
Set-SmbServerConfiguration -InvalidAuthenticationDelayTimeInMs 30000 -Force

# Disable IPC$ anonymous access
reg add HKLM\SYSTEM\CurrentControlSet\Control\LSA /v restrictanonymous /f /t REG_DWORD /d 2

# Restart LanManServer with dependencies
Get-Service LanManServer | Restart-Service -Verbose