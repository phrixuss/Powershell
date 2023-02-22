write-Host "############################################"


# Set execution policy to unrestricted (use with caution)
#Set-ExecutionPolicy unrestricted -Force -ErrorAction Ignore

# Install all modules
Write-Verbose "Installing all modules"
Write-Verbose "##########################################################################"

# Set TLS 1.2 as the default security protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Verbose "##############################################################################"
Write-Verbose "Gathering hash and uploading to Dataquest Azure"

# Define variables
$serialnumber = $env:COMPUTERNAME
$tempDir = "C:\temp"
$msiUrl = "https://firstftorage01.blob.core.windows.net/software/callswitch65.msi"
$msiPath = Join-Path $tempDir "callswitch.msi"
$logPath = Join-Path $tempDir "logcallswitch.txt"

# Download MSI to temp directory
if (-not (Test-Path $tempDir)) {
  New-Item -Path "C:\" -Name "Temp" -ItemType Directory
}

$WebClient = New-Object System.Net.WebClient
try {
  $WebClient.DownloadFile($msiUrl, $msiPath)
} catch {
  Write-Error "Error downloading MSI: $_"
  exit 1
}

# Install MSI
try {
  Start-Process $msiPath "/qn /L*V $logPath" -Wait
} catch {
  Write-Error "Error installing MSI: $_"
  exit 1
}

# Remove MSI from temp directory
Remove-Item $msiPath

# Add firewall rule
try {
  netsh advfirewall firewall add rule name="CallSwitch" dir=in action=allow program="C:\Program Files\TelcoSwitch\CallSwitch\CallSwitch.exe" enable=yes
} catch {
  Write-Error "Error adding firewall rule: $_"
  exit 1
}


Write-Verbose "############################################"