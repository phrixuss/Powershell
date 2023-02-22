$permissions = Import-Csv "C:\script\ntfsnew.csv"
foreach ($permission in $permissions){

$acl = Get-Acl -Path $permission.FolderName

$adgroup = $permission.adgroup
$ntfs = $permission.permissions

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($adgroup,$ntfs,"ContainerInherit, ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)

Write-Host "adding to the folder $permission.foldername"
Write-Host "the user/group $permission.adgroup"

Set-Acl $permission.FolderName $acl

}



$GroupName = ""
$AllowGroupCreation = "false"


$settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
if(!$settingsObjectID)
{
	  $template = Get-AzureADDirectorySettingTemplate | Where-object {$_.displayname -eq "group.unified"}
    $settingsCopy = $template.CreateDirectorySetting()
    New-AzureADDirectorySetting -DirectorySetting $settingsCopy
    $settingsObjectID = (Get-AzureADDirectorySetting | Where-object -Property Displayname -Value "Group.Unified" -EQ).id
}

$settingsCopy = Get-AzureADDirectorySetting -Id $settingsObjectID
$settingsCopy["EnableGroupCreation"] = $AllowGroupCreation

if($GroupName)
{
	$settingsCopy["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -SearchString $GroupName).objectid
}

Set-AzureADDirectorySetting -Id $settingsObjectID -DirectorySetting $settingsCopy

(Get-AzureADDirectorySetting -Id $settingsObjectID).Values