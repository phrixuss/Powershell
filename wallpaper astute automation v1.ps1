##### Checking if AZCopy exits in the device ######

if (!(Test-Path -Path C:\Windows\Temp\azcopy.exe)){
    Write-Host "Downloading file"

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://astuteglobaldeskimages.blob.core.windows.net/astutesoftware/azcopy.exe","C:\windows\temp\azcopy.exe")

}

#### Continuing to the script #####




REG ADD 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v InactivityTimeoutSecs /t REG_DWORD /d 1200 /f
powercfg -h off
powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 259200
powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 259200
powercfg.exe /setactive SCHEME_CURRENT

function ScreenSaverWin7 {

  
  # Screensaver picture
  $getRandomWallpaper = Get-ChildItem -Recurse "c:\windows\system32\oobe\info" | where {$_.Extension -eq ".jpg"}  | Get-Random -Count 1 


  # Setting wallpaper to the regisrty.
  Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $getRandomWallpaper.FullName  

  # updating the user settings
  rundll32.exe user32.dll, UpdatePerUserSystemParameters 
  rundll32.exe user32.dll, UpdatePerUserSystemParameters 
  rundll32.exe user32.dll, UpdatePerUserSystemParameters 
  
}


#(Get-WmiObject -class Win32_OperatingSystem).Caption
$Ver = [System.Environment]::OSVersion.Version.Major
echo $ver
If ($Ver -eq 10){

    if(!(Test-Path -Path "C:\windows\temp\")){
        New-Item -Path "C:\Windows\Temp\" -Name "LockScreen" -ItemType "Directory"

    }
       # $WebClient = New-Object System.Net.WebClient
       # $WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/support%20(1).jpg","C:\windows\temp\LockScreen\support.jpg")
    
    C:\Windows\Temp\azcopy.exe cp "https://astuteglobaldeskimages.blob.core.windows.net/astuteukimages?st=2021-12-07T11%3A37%3A11Z&se=2026-12-01T11%3A37%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=ngt%2BzuPxq%2B2bKjl%2FEuEDJWJ%2FGyxtScZ%2BFyGsX16WJBE%3D" "C:\windows\temp\LockScreen\" --recursive=true --overwrite=true


    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    $LockScreenPath = "LockScreenImagePath"
    $LockScreenStatus = "LockScreenImageStatus"
    $LockScreenUrl = "LockScreenImageUrl"
    
    $StatusValue = "1"
    $LockScreenImageValue = "C:\windows\temp\LockScreen\support1.jpg"  #Change as per your needs
    
    
    IF(!(Test-Path $RegKeyPath))
    
      {
    
        New-Item -Path $RegKeyPath -Force 
    
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force 
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force 
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force 
        
        }
    
     ELSE {
        
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $value -PropertyType DWORD -Force 
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force
        }
    
#win7
}else{

    echo "windows 7"
    New-Item -Path "c:\windows\system32\oobe\" -Name "info" -ItemType "Directory"
    New-Item -Path "c:\windows\system32\oobe\info" -Name "backgrounds" -ItemType "Directory"
    New-Item -Path "C:\Windows\Temp\" -Name "LockScreen" -ItemType "Directory"

    
    #$WebClient = New-Object System.Net.WebClient
    #$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/support%20(1).jpg","c:\windows\system32\oobe\info\backgrounds\BackgroundDefault.jpg")

    C:\Windows\Temp\azcopy.exe cp "https://astuteglobaldeskimages.blob.core.windows.net/astuteukimages?st=2021-12-07T11%3A37%3A11Z&se=2026-12-01T11%3A37%3A00Z&sp=rl&sv=2018-03-28&sr=c&sig=ngt%2BzuPxq%2B2bKjl%2FEuEDJWJ%2FGyxtScZ%2BFyGsX16WJBE%3D" "C:\windows\temp\LockScreen\" --recursive=true --overwrite=true

    Copy-Item -Path "C:\windows\Temp\LockScreen\astuteukimages\support1.jpg" -Destination "c:\windows\system32\oobe\info\backgrounds\BackgroundDefault.jpg" -Force
    
    $LockScreenPath = "OEMBackground"

    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background"
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -value 1 -PropertyType DWORD -force



} 