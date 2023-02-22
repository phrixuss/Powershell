#set-executionpolicy unrestricted -force

write-Host "Installing All Modules"
write-Host "##########################################################################"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Register-PSRepository -Default
#Get-ChildItem -Path "D:\modules" -Recurse | Move-Item -Destination "C:\Program Files\WindowsPowerShell\Modules" -force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
if (!(get-installedmodule -name "az")){
    install-module -name AZ -AllowClobber -Scope AllUsers -force
}
if (!(get-installedmodule -name "aztable")){
    install-module -name aztable -AllowClobber -force
}


write-Host "##############################################################################"
write-Host "gathering Hash and uploading to Dataquest Azure"


#*****************************************************
# This script gets services running on the local machine
# and writes the output to Azure Table Storage
#
#*****************************************************

# Step 1, Set variables
# Enter Table Storage location data 
$resourcegroup = "MailExchange"
$storageAccountName = 'dqgroup'
$tableName = 'callswitch'
$sasToken = '?sv=2020-08-04&ss=bfqt&srt=sc&sp=rwdlacupitfx&se=2023-04-19T18:04:54Z&st=2022-03-23T11:04:54Z&spr=https&sig=OxoMQLsFae95YNw63cS0Pg0Q%2BGgpNcT3sFCpdylrEzs%3D'
$dateTime = get-date
$partitionKey = 'CallSwitch'
$processes = @()

$User = "azure.tablewriter@dataquestuk.com"
$PWord = ConvertTo-SecureString -String "***" -AsPlainText -Force
$tenant = "0a91d318-af5d-4e1f-be09-df2fd654347b"
$subscription = "06d385af-b061-4727-941c-cbc854a54813"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
Connect-AzAccount -Credential $Credential -Tenant $tenant -Subscription $subscription

# Step 2, Connect to Azure Table Storage
$table = Get-AzTableTable -resourceGroup $resourceGroup -TableName $tableName -storageAccountName $storageAccountName

$sacontext = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context
#$table = (Get-AzStorageTable -Name $tableName -Context $saContext).CloudTable
$table = Get-AzTableTable -resourceGroup $resourceGroup -TableName $tableName -storageAccountName $storageAccountName
# Step 3, get the data 

$serialnumber = $env:COMPUTERNAME


#remove-item c:\temp\callswitch.msi


#$userloggedin = (Get-WMIObject -ClassName Win32_ComputerSystem).Username


#$callswitch_install = Get-WmiObject -Class Win32_Product | where {$_.name -like "CallSwitch*"}
$myIP = (Invoke-WebRequest -uri "https://api.ipify.org/").Content
Add-AzTableRow -table $table -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{"Computername"=$serialnumber;"Public IP"=$myIP}





write-Host "############################################"
