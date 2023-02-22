$User = "steer-storageaccount@dqgrouplive.onmicrosoft.com"
$PWord = ConvertTo-SecureString -String "***" -AsPlainText -Force
$Credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $User,$PWord
Set-ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue
$TLS12Protocol = [System.Net.SecurityProtocolType] 'Ssl3 , Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $TLS12Protocol
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Microsoft.Graph -AllowClobber -Scope AllUsers -force
Install-Script -Name Get-WindowsAutoPilotInfo -force
Connect-MSGraph -Credential $Credential
Set-Location "C:\Program Files\WindowsPowerShell\Scripts\"
.\Get-WindowsAutoPilotInfo.ps1 -Online