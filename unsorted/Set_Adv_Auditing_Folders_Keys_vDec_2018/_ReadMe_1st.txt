These settings are based on the following Cheat Sheets

1) 'Windows Logging Cheat Sheet'
2) 'Windows PowerShell Auditing Cheat Sheet'
3) 'Windows File Auditing Cheat Sheet'
4) 'Windows Registry Auditing Cheat Sheet'

Available at:  www.MalwareArchaeology.com\cheat-sheets

Created by Michael Gough - Malware Archeology
Updated Dec 2018

######################################################################################################

The scripts will set the items for the current logged in user.  

Place these files together anywhere on the system in a directory (e.g. Set-Auditing) and launch the following scripts:

1_Set_Audit_Pol_PS_v2_3_4_5.cmd

2_Set_User_Folder_Auditing_v2.cmd

3_Set_User_Registry_Auditing.cmd

The results from before and after will also be saved.

Use Group Policy to set these for all systems in a domain.

Folder and Registry scripts must be run AFTER the user account has been created on a target system.

You can add more folders and registry keys you feel appropriate that you want to audit.

Some errors will occur is the location does not exist.


