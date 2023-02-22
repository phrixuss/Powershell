# Connect to AzureAD
Connect-AzureAD

# Get all Microsoft 365 users
$users = Get-AzureADUser -All $true

# Initialize an array to store the user information
$userData = @()

# Loop through each user
foreach ($user in $users) {

    # Get the manager's information
    $manager = Get-AzureADUsermanager -ObjectId $user.ObjectId
    $officeplace = get-msoluser -object $user.objectid | select-object office
    # Get the user's license information
    $licenses = Get-AzureADUserLicenseDetail -ObjectId $user.ObjectId
    $licensesAssigned = @()
    # Loop through each license
    foreach ($license in $licenses) {
        if(!($license.SkuPartNumber -in "POWER_BI_PRO","WINDOWS_STORE","FLOW_FREE","POWER_BI_STANDARD","TEAMS_EXPLORATORY")){
         $licensesAssigned += $license.SkuPartNumber
        }
    }
    # Add the user's information to the array
    $userData += [PSCustomObject]@{
        DisplayName = $user.DisplayName
        UserPrincipalName = $user.UserPrincipalName
        Title = $user.jobtitle
        Office = $officeplace.office
        Department = $user.Department
        PhoneNumber = $user.TelephoneNumber
        MobileNumber = $user.Mobile
        ManagerName = $manager.DisplayName
        ManagerUPN = $manager.UserPrincipalName
        LicenseSKU = ($licensesAssigned -join ",")
    }
}

# Export the user information to a CSV file
$userData | Export-Csv -Path "C:\temp\outeput12.csv" -NoTypeInformation