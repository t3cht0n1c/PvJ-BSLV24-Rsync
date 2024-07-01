#  This is based on the 'Windows File Auditing Cheat Sheet'
#  www.MalwareArchaeology.com\cheat-sheets
#
#  Created by Michael Gough - Malware Archaeology
#  Updated Dec 2018
#
# Set File or Dir Auditing for Everyone for Create and change Perms only
#
param($path=$(throw "You must specify a directory"))
$ACL = new-object System.Security.AccessControl.DirectorySecurity
$AccessRule = new-object System.Security.AccessControl.FileSystemAuditRule("Everyone","AppendData, ChangePermissions, CreateDirectories, CreateFiles, Delete, DeleteSubdirectoriesAndFiles, TakeOwnership, Write, WriteAttributes, WriteExtendedAttributes","ContainerInherit, ObjectInherit","NoPropagateInherit","Success")
$ACL.SetAuditRule($AccessRule)
$ACL | Set-Acl $path
#
# Set
#
#AppendData
#ChangePermissions
#CreateDirectories
#CreateFiles
#Delete
#DeleteSubdirectoriesAndFiles
#TakeOwnership
#Write
#WriteAttributes
#WriteData
#WriteExtendedAttributes

#
# Do NOT set
#
#ExecuteFile
#FullControl
#ListDirectory
#Modify
#Read
#ReadAndExecute
#ReadAttributes
#ReadData
#ReadExtendedAttributes
#ReadPermissions
#Synchronize
#Traverse
