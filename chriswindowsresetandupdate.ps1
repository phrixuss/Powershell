$services = @("wuauserv","cryptsvc","bits","msiserver")

Write-Host Stopping Services
$services | foreach {net stop $_}

Write-Host Clearing Files and Windows Updates

$tempfolders = @(“C:\Windows\Temp\*”, “C:\Windows\Prefetch\*”, “C:\Documents and Settings\*\Local Settings\temp\*”, “C:\Users\*\Appdata\Local\Temp\*”)
$tempfolders | foreach {remove-Item $_ -force -recurse -ErrorAction Ignore}

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

rename-Item -Path "C:\Windows\SoftwareDistribution" -newname "C:\Windows\SoftwareDistribution-old"
rename-Item -Path "C:\Windows\System32\catroot2" -newname "C:\Windows\System32\catroot2-old"

$services | foreach {Net Start $_}

start-sleep 120

if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -force 
} 
import-Module pswindowsupdate
Get-WindowsUpdate –Install


start-sleep 60

$Shell = New-Object -ComObject Shell.Application
$Shell.open("intunemanagementextension://syncapp")