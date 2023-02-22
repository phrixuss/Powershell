Param (
    [Parameter(Mandatory = $true)]
    [string]$Url
)

# Set the execution policy to unrestricted, force the change and continue silently if an error occurs
Set-ExecutionPolicy Unrestricted -force -ErrorAction SilentlyContinue

# Install the NuGet package provider with a minimum version of 2.8.5.201, and force the change if it already exists
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Check if the az.accounts module is installed, and install it if it's not
if (!(get-installedmodule -name "az.accounts" -ErrorAction SilentlyContinue)){
    install-module -name az.accounts -AllowClobber -Scope AllUsers -force
}

# Check if the aztable module is installed, and install it if it's not
if (!(get-installedmodule -name "aztable" -ErrorAction SilentlyContinue)){
    install-module -name aztable -AllowClobber -force
}

# Check if the az.storage module is installed, and install it if it's not
if (!(get-installedmodule -name "az.storage" -ErrorAction SilentlyContinue)){
    install-module -name az.storage -AllowClobber -force
}

# Check if the Az.Resources module is installed, and install it if it's not
if (!(get-installedmodule -name "Az.Resources" -ErrorAction SilentlyContinue)){
    install-module -name Az.Resources -AllowClobber -force
}

# Import the aztable module
import-module aztable

# Store the username and password as variables
$User = "DQ-storageaccount@dqgroup.com"
$PWord = ConvertTo-SecureString -String "***" -AsPlainText -Force
$tenant = "686249a1-57c6-4972-adc6-bb519d2f1160"
$subscription = "57e6d23d-86ec-4eb7-b2eb-67d7a5dd65d9"

# Create a new PSCredential object with the username and password
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord

# Connect to the Azure account with the specified tenant and subscription using the PSCredential object
Connect-AzAccount -Credential $Credential -Tenant $tenant -Subscription $subscription

# Store the resource group, storage account, table name, and partition key as variables
$resourceGroup = "dqnablestorage"
$storageAccount = "dqstoragenable"
$tableName = "DQGroup"
$partitionKey = "DQGroup"

# Get the table using the specified resource group, storage account, and table name
$SaContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).Context
$table = (Get-AzStorageTable -Name $tableName -Context $saContext).CloudTable

# Get the rows of the table
$parameters = Get-AzTableRow -Table $table

# Loop through the rows of the table
foreach ($parameter in $parameters) {
    try {
        #if($env:computername.StartsWith($parameter.computername)){
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile("$($Url)","C:\temp\windowsagentsetup.exe")

            # Exit with code 10 if download fails
            if (-not(Test-Path "C:\temp\windowsagentsetup.exe")) {
                exit 10
            }

            $pinfo = New-Object System.Diagnostics.ProcessStartInfo
            $pinfo.FileName = "C:\temp\windowsagentsetup.exe"
            $pinfo.RedirectStandardError = $true
            $pinfo.RedirectStandardOutput = $true
            $pinfo.UseShellExecute = $false
            $pinfo.Arguments = "/quiet /v"" /qn CUSTOMERID=$($parameter.code) CUSTOMERSPECIFIC=1 REGISTRATION_TOKEN=$($parameter.token) SERVERPROTOCOL=HTTPS SERVERADDRESS=ncod601.n-able.com SERVERPORT=443 """
            $p = New-Object System.Diagnostics.Process
            $p.StartInfo = $pinfo
            $p.Start() | Out-Null
            $p.WaitForExit()

            # Exit with the process exit code if installation fails
            if ($p.ExitCode -ne 0) {
                exit $p.ExitCode
            }

            Remove-Item -Path C:\temp\windowsagentsetup.exe -Force -Confirm:$false
        #}
    } catch {
        Write-Error $_
        exit 1
    }
}

exit 0

