$Users = Import-Csv "C:\users\cgoes.adm\emailmigration1.csv"

# Specify target group where the users will be removed from
# You can add the distinguishedName of the group. For example: CN=Pilot,OU=Groups,OU=Company,DC=exoip,DC=local
$Group = "Office365_License_E3" 

foreach ($User in $Users) {
    # Retrieve UPN
  $UPN = Get-mailbox -Identity ($user.emailaddress +"@cce.co.uk") | Select-Object samaccountname
    $ADUser = Get-ADUser $UPN.samaccountname | Select-Object SamAccountName
    
    # User from CSV not in AD
    if ($ADUser -eq $null) {
        Write-Host "$UPN does not exist in AD" -ForegroundColor Red
    }
    else {
        # Retrieve AD user group membership
        $ExistingGroups = Get-ADPrincipalGroupMembership $ADUser.SamAccountName | Select-Object Name

        # User member of group
        if ($ExistingGroups.Name -eq $Group) {

            # Remove user from group
            Remove-ADGroupMember -Identity $Group -Members $ADUser.SamAccountName -Confirm:$false -WhatIf
            Write-Host "Removed $UPN from $Group" -ForeGroundColor Green
        }
        else {
            # User not member of group
            Write-Host "$UPN does not exist in $Group" -ForeGroundColor Yellow
        }
    }
}