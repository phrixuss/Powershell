Function Createscheduletask {

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/logonscriptOD.ps1","C:\windows\temp\logonscriptOD.ps1")
  
    $t = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(60)
    $t.EndBoundary = (get-date).AddSeconds(60).ToString('s')
    Register-ScheduledTask -Force -TaskName Netextender -user "***\Administrator" -Password "***" -Action (New-ScheduledTaskAction -Execute "C:\windows\temp\logonscriptOD.ps1") -RunLevel Highest -Trigger $t -Settings (New-ScheduledTaskSettingsSet -DeleteExpiredTaskAfter 00:00:01)

}

try{
    Test-Path $env:onedrive
} catch {
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/OneDriveSetup.exe","C:\Windows\temp\OneDriveSetup.exe")

    C:\Windows\temp\OneDriveSetup.exe /quiet /qn /norestart
}

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/OneDrive.admx","C:\Windows\PolicyDefinitions\OneDrive.admx")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/OneDriveES.adml","C:\Windows\PolicyDefinitions\en-US\OneDrive.adml")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/OneDrive.adml","C:\Windows\PolicyDefinitions\OneDrive.adml")

Start-Sleep 30

$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'##Path to HKLM keys
$DiskSizeregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB'##Path to max disk size key
$TenantGUID = 'e67959d2-4af1-4191-9085-30014add5e56'

if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}
if(!(Test-Path $DiskSizeregistryPath)){New-Item -Path $DiskSizeregistryPath -Force}

New-ItemProperty -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable silent account configuration
New-ItemProperty -Path $HKLMregistryPath -Name "FilesOnDemandEnabled" -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $HKLMregistryPath -Name "KFMOptInWithWizard" -Value $TenantGUID -Force


Start-Sleep 60

Createscheduletask