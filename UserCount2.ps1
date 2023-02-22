set-executionpolicy unrestricted

write-Host "Installing All Modules"
write-Host "##########################################################################"
#Get-ChildItem -Path "D:\modules" -Recurse | Move-Item -Destination "C:\Program Files\WindowsPowerShell\Modules" -force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
install-module az.accounts -Force
Install-module aztable -Force
install-module az.storage -Force
install-module Az.Resources -force
Install-Script -Name Get-WindowsAutoPilotInfo -force
Install-Module pswindowsupdate -force
Import-Module PSWindowsUpdate -force
import-module aztable
write-Host "##############################################################################"
write-Host "gathering Hash and uploading to Dataquest Azure"


Function ActiveUsers
{
param($CompanyID,$UserPrincipalname,$DisplayName,$LastLogonTime,$CreationTime,$InactiveDays,$MailboxType,$AssignedLicenses,$roles)

    Add-AzTableRow -table $table -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{"CompanyID"=$CompanyID;"UserPrincipalname"=$UserPrincipalname;"DisplayName"=$DisplayName;"LastLogonTime"=$LastLogonTime;"CreationTime"=$CreationTime;"InactiveDays"=$InactiveDays;"MailboxType"=$MailboxType;"AssignedLicenses"=$AssignedLicenses;"roles"=$roles}


}

function Userreportextractiono365 {
    param (
        $usernameo365,$passwordo365,$companyidcheck
    )

$resourcegroup = "MailExchange"
$storageAccountName = 'dqgroup'
$tableName = 'UserCount'
$sasToken = '?sv=2020-08-04&ss=bfqt&srt=sc&sp=rwdlacupitfx&se=2023-04-19T18:04:54Z&st=2022-03-23T11:04:54Z&spr=https&sig=OxoMQLsFae95YNw63cS0Pg0Q%2BGgpNcT3sFCpdylrEzs%3D'
$dateTime = get-date
$partitionKey = $companyidcheck
$processes = @()

$User = "azure.tablewriter@**.com"
$PWord = ConvertTo-SecureString -String "****" -AsPlainText -Force
$tenant = "0a91d318-af5d-4e1f-be09-df2fd654347b"
$subscription = "06d385af-b061-4727-941c-cbc854a54813"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
Connect-AzAccount -Credential $Credential -Tenant $tenant -Subscription $subscription

# Step 2, Connect to Azure Table Storage
$table = Get-AzTableTable -resourceGroup $resourceGroup -TableName $tableName -storageAccountName $storageAccountName

$sacontext = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context
$table = (Get-AzStorageTable -Name $tableName -Context $saContext).CloudTable
# Step 3, get the data 



$username = $usernameo365
$password = ConvertTo-SecureString $passwordo365 -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
#Connect-MSolService -Credential $psCred

#$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $psCred -Authentication Basic -AllowRedirection
Set-ExecutionPolicy RemoteSigned
Connect-MSolService -Credential $psCred
Connect-ExchangeOnline -credential $pscred

Import-PSSession $Session

$Result=""
$Output=@()
$MBUserCount=0
$OutputCount=0
$FriendlyNameHash=Get-Content -Raw -Path "C:\Users\christopher.goes\LicenseFriendlyName.txt" -ErrorAction Stop | ConvertFrom-StringData

    Get-Mailbox -ResultSize Unlimited | Where-Object {$_.DisplayName -notlike "Discovery Search Mailbox"} | ForEach-Object {
    $upn=$_.UserPrincipalName
    $CreationTime=$_.WhenCreated
    $LastLogonTime=(Get-MailboxStatistics -Identity $upn).lastlogontime
    $DisplayName=$_.DisplayName
    $MBType=$_.RecipientTypeDetails
    $Print=1
    $MBUserCount++
    $RolesAssigned=""
    Write-Progress -Activity "`n     Processed mailbox count: $MBUserCount "`n"  Currently Processing: $DisplayName"

    #Retrieve lastlogon time and then calculate Inactive days
    if($LastLogonTime -eq $null)
    {
    $LastLogonTime ="Never Logged In"
    $InactiveDaysOfUser="-"
    }
    else
    {
    $InactiveDaysOfUser= (New-TimeSpan -Start $LastLogonTime).Days
    }

    #Get licenses assigned to mailboxes
    $User=(Get-MsolUser -UserPrincipalName $upn)
    $Licenses=$User.Licenses.AccountSkuId
    $AssignedLicense=""
    $Count=0

    #Convert license plan to friendly name
    foreach($License in $Licenses)
    {
        $Count++
        $LicenseItem= $License -Split ":" | Select-Object -Last 1
        $EasyName=$FriendlyNameHash[$LicenseItem]
        if(!($EasyName))
        {$NamePrint=$LicenseItem}
        else
        {$NamePrint=$EasyName}
        $AssignedLicense=$AssignedLicense+$NamePrint
        if($count -lt $licenses.count)
        {
        $AssignedLicense=$AssignedLicense+","
        }
    }
    if($Licenses.count -eq 0)
    {
    $AssignedLicense="No License Assigned"
    }

    #Inactive days based filter
    if($InactiveDaysOfUser -ne "-"){
    if(($InactiveDays -ne "") -and ([int]$InactiveDays -gt $InactiveDaysOfUser))
    {
    $Print=0
    }}

    #License assigned based filter
    if(($UserMailboxOnly.IsPresent) -and ($MBType -ne "UserMailbox"))
    {
    $Print=0
    }

    #Never Logged In user
    if(($ReturnNeverLoggedInMB.IsPresent) -and ($LastLogonTime -ne "Never Logged In"))
    {
    $Print=0
    }

    #Get roles assigned to user
    $Roles=(Get-MsolUserRole -UserPrincipalName $upn).Name
    if($Roles.count -eq 0)
    {
    $RolesAssigned="No roles"
    }
    else
    {
    foreach($Role in $Roles)
    {
    $RolesAssigned=$RolesAssigned+$Role
    if($Roles.indexof($role) -lt (($Roles.count)-1))
    {
        $RolesAssigned=$RolesAssigned+","
    }
    }
    }



    #Export result to CSV file
    if($Print -eq 1)
    {
    $OutputCount++
    $Result=@{'UserPrincipalName'=$upn;'DisplayName'=$DisplayName;'LastLogonTime'=$LastLogonTime;'CreationTime'=$CreationTime;'InactiveDays'=$InactiveDaysOfUser;'MailboxType'=$MBType; 'AssignedLicenses'=$AssignedLicense;'Roles'=$RolesAssigned}
    $Output= New-Object PSObject -Property $Result
    $Output | Select-Object UserPrincipalName,DisplayName,LastLogonTime,CreationTime,InactiveDays,MailboxType,AssignedLicenses,Roles #| Export-Csv -Path $ExportCSV -Notype -Append
    }

    foreach ($userforeach in $output){

        ActiveUsers $companyidcheck $userforeach.UserPrincipalName $userforeach.DisplayName $userforeach.lastlogontime $userforeach.creationtime $userforeach.InactiveDays $userforeach.MailboxType $userforeach.AssignedLicenses $userforeach.roles

    }
    }
}


Userreportextractiono365 "admin@livedq.onmicrosoft.com" "m2RC$D8Gj%b9fwMZ" "40"

Get-PSSession | ForEach-Object {Remove-PSSession $_.Id}

start-sleep 10








