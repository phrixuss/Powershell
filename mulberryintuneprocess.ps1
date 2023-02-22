set-executionpolicy unrestricted -force

write-Host "Installing All Modules"
write-Host "##########################################################################"
#Get-ChildItem -Path "D:\modules" -Recurse | Move-Item -Destination "C:\Program Files\WindowsPowerShell\Modules" -force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
if (!(get-installedmodule -name "az.accounts" -ErrorAction SilentlyContinue)){
    install-module -name az.accounts -AllowClobber -Scope AllUsers -force
}
if (!(get-installedmodule -name "aztable" -ErrorAction SilentlyContinue)){
    install-module -name aztable -AllowClobber -force
}if (!(get-installedmodule -name "az.storage" -ErrorAction SilentlyContinue)){
    install-module -name az.storage -AllowClobber -force
}if (!(get-installedmodule -name "Az.Resources" -ErrorAction SilentlyContinue)){
    install-module -name Az.Resources -AllowClobber -force
}if (!(get-installedmodule -name "pswindowsupdate" -ErrorAction SilentlyContinue)){
    install-module -name pswindowsupdate -AllowClobber -force
}if (!(get-installedmodule -name "WindowsAutoPilotinfo" -ErrorAction SilentlyContinue)){
    install-module -name Get-WindowsAutoPilotInfo -AllowClobber -force
}
Install-Script -Name Get-WindowsAutoPilotInfo -force
Import-Module PSWindowsUpdate -force
import-module aztable
write-Host "##############################################################################"
write-Host "gathering Hash and uploading to Dataquest Azure"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Register-PSRepository -Default
#Get-ChildItem -Path "D:\modules" -Recurse | Move-Item -Destination "C:\Program Files\WindowsPowerShell\Modules" -force


#*****************************************************
# This script gets services running on the local machine
# and writes the output to Azure Table Storage
#
#*****************************************************

# Step 1, Set variables
# Enter Table Storage location data 
$resourcegroup = "MailExchange"
$storageAccountName = 'dqgroup'
$tableName = 'Mulberry'
$sasToken = '?sv=2020-08-04&ss=bfqt&srt=sc&sp=rwdlacupitfx&se=2023-04-19T18:04:54Z&st=2022-03-23T11:04:54Z&spr=https&sig=OxoMQLsFae95YNw63cS0Pg0Q%2BGgpNcT3sFCpdylrEzs%3D'
$dateTime = get-date
$partitionKey = 'MulberryAssets'
$processes = @()

$User = "azure.tablewriter@livedq.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String "**" -AsPlainText -Force
$tenant = "0a91d318-af5d-4e1f-be09-df2fd654347b"
$subscription = "06d385af-b061-4727-941c-cbc854a54813"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
Connect-AzAccount -Credential $Credential -Tenant $tenant -Subscription $subscription

# Step 2, Connect to Azure Table Storage
$table = Get-AzTableTable -resourceGroup $resourceGroup -TableName $tableName -storageAccountName $storageAccountName

$sacontext = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName).Context
$table = (Get-AzStorageTable -Name $tableName -Context $saContext).CloudTable
# Step 3, get the data 

$serialnumber = Get-WmiObject win32_bios | select Serialnumber
$hardwarehash = (Get-WindowsAutoPilotInfo.ps1)."Hardware Hash"

$version = Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
$versionumber = ($version.OsHardwareAbstractionLayer).Split('.')[-1]
if (1766 -le $versionumber){
write-host "build number is higher"
Add-AzTableRow -table $table -partitionKey $partitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{"serialnumber"=$serialnumber.serialnumber;"Hash"=$hardwarehash}
Write-host "Hash upload and process finished"
write-host " .----------------.  .----------------.  .-----------------. .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |  _________   | || |     _____    | || | ____  _____  | || |     _____    | || |    _______   | || |  ____  ____  | |
| | |_   ___  |  | || |    |_   _|   | || ||_   \|_   _| | || |    |_   _|   | || |   /  ___  |  | || | |_   ||   _| | |
| |   | |_  \_|  | || |      | |     | || |  |   \ | |   | || |      | |     | || |  |  (__ \_|  | || |   | |__| |   | |
| |   |  _|      | || |      | |     | || |  | |\ \| |   | || |      | |     | || |   '.___`-.   | || |   |  __  |   | |
| |  _| |_       | || |     _| |_    | || | _| |_\   |_  | || |     _| |_    | || |  |`\____) |  | || |  _| |  | |_  | |
| | |_____|      | || |    |_____|   | || ||_____|\____| | || |    |_____|   | || |  |_______.'  | || | |____||____| | |
| |              | || |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
'----------------'  '----------------'  '----------------'  '----------------'  '----------------'  '----------------' "
}else{
Write-Host "builder is lower"
write-Host "############################################"
Install-WindowsUpdate -AcceptAll -Install -AUTOREBOOT

}
