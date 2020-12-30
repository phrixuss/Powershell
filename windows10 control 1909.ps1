#(Get-WmiObject -class Win32_OperatingSystem).Caption
$Ver = [System.Environment]::OSVersion.Version.Major
#Write-Host $ver
If ($Ver -eq 10){
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://****.blob.core.windows.net/software/stopwindowsupdate1909.reg","C:\windows\temp\stopwindowsupdate1909.reg")

    reg import C:\windows\temp\stopwindowsupdate1909.reg

    Remove-Item -Path "C:\windows\temp\stopwindowsupdate1909.reg"

    Write-Host "Registry applied"
#win7
}else{

    Write-Host "Windows 7 no updates required"

} 
