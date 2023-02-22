Set-ExecutionPolicy Unrestricted
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
}
import-module aztable

$User = "steer-storageaccount@dqgrouplive.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String "-***" -AsPlainText -Force
$tenant = "686249a1-57c6-4972-adc6-bb519d2f1160"
$subscription = "57e6d23d-86ec-4eb7-b2eb-67d7a5dd65d9"
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
Connect-AzAccount -Credential $Credential -Tenant $tenant -Subscription $subscription

$resourceGroup = "dqgroup-storageaccount"
$storageAccount = "steergroupstorage"
$tableName = "steernable"
$partitionKey = "SteerNable"

#Get-AzTableTable -resourceGroup $resourceGroup -TableName $tableName -storageAccountName $storageAccount

$SaContext = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).Context
$table = (Get-AzStorageTable -Name $tableName -Context $saContext).CloudTable
$parameters = Get-AzTableRow -Table $table
foreach ($parameter in $parameters){
    if($env:computername.StartsWith($parameter.computername)){
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("https://ncod601.n-able.com/download/2022.7.0.26/winnt/N-central/WindowsAgentSetup.exe","C:\temp\windowsagentsetup.exe")

        $argumentchange = "/quiet /v"" /qn CUSTOMERID=$($parameter.code) CUSTOMERSPECIFIC=1 REGISTRATION_TOKEN=$($parameter.token) SERVERPROTOCOL=HTTPS SERVERADDRESS=ncod601.n-able.com SERVERPORT=443 """

        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = "C:\temp\windowsagentsetup.exe"
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = $argumentchange
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $p.WaitForExit()

        Remove-Item -Path C:\temp\windowsagentsetup.exe -Force -Confirm:$false

        exit $p.ExitCode
    }
}


