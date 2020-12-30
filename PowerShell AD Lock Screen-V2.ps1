REG ADD 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' /v InactivityTimeoutSecs /t REG_DWORD /d 1200 /f
powercfg.exe /h off
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

function Set-RegistryValueForAllUsers {
  <#
  .SYNOPSIS
      This function uses Active Setup to create a "seeder" key which creates or modifies a user-based registry value
      for all users on a computer. If the key path doesn't exist to the value, it will automatically create the key and add the value.
  .EXAMPLE
      PS> Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'Setting'; 'Type' = 'String'; 'Value' = 'someval'; 'Path' = 'SOFTWARE\Microsoft\Windows\Something'}
      This example would modify the string registry value 'Type' in the path 'SOFTWARE\Microsoft\Windows\Something' to 'someval'
      for every user registry hive.
  .PARAMETER RegistryInstance
       A hash table containing key names of 'Name' designating the registry value name, 'Type' to designate the type
      of registry value which can be 'String,Binary,Dword,ExpandString or MultiString', 'Value' which is the value itself of the
      registry value and 'Path' designating the parent registry key the registry value is in.
  #>
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [hashtable[]]$RegistryInstance
  )
  try {
      New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null

      ## Change the registry values for the currently logged on user. Each logged on user SID is under HKEY_USERS
      $LoggedOnSids = $(Get-ChildItem HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | foreach-object { $_.Name })
      Write-Verbose "Found $($LoggedOnSids.Count) logged on user SIDs"
      foreach ($sid in $LoggedOnSids) {
          Write-Verbose -Message "Loading the user registry hive for the logged on SID $sid"
          foreach ($instance in $RegistryInstance) {
              ## Create the key path if it doesn't exist
              if (!(Test-Path "HKU:\$sid\$($instance.Path)")) {
                  New-Item -Path "HKU:\$sid\$($instance.Path | Split-Path -Parent)" -Name ($instance.Path | Split-Path -Leaf) -Force | Out-Null
              }
              ## Create (or modify) the value specified in the param
              Set-ItemProperty -Path "HKU:\$sid\$($instance.Path)" -Name $instance.Name -Value $instance.Value -Type $instance.Type -Force
          }
      }

      ## Create the Active Setup registry key so that the reg add cmd will get ran for each user
      ## logging into the machine.
      ## http://www.itninja.com/blog/view/an-active-setup-primer
      Write-Verbose "Setting Active Setup registry value to apply to all other users"
      foreach ($instance in $RegistryInstance) {
          ## Generate a unique value (usually a GUID) to use for Active Setup
          $Guid = [guid]::NewGuid().Guid
          $ActiveSetupRegParentPath = 'HKLM:\Software\Microsoft\Active Setup\Installed Components'
          ## Create the GUID registry key under the Active Setup key
          New-Item -Path $ActiveSetupRegParentPath -Name $Guid -Force | Out-Null
          $ActiveSetupRegPath = "HKLM:\Software\Microsoft\Active Setup\Installed Components\$Guid"
          Write-Verbose "Using registry path '$ActiveSetupRegPath'"

          ## Convert the registry value type to one that reg.exe can understand.  This will be the
          ## type of value that's created for the value we want to set for all users
          switch ($instance.Type) {
              'String' {
                  $RegValueType = 'REG_SZ'
              }
              'Dword' {
                  $RegValueType = 'REG_DWORD'
              }
              'Binary' {
                  $RegValueType = 'REG_BINARY'
              }
              'ExpandString' {
                  $RegValueType = 'REG_EXPAND_SZ'
              }
              'MultiString' {
                  $RegValueType = 'REG_MULTI_SZ'
              }
              default {
                  throw "Registry type '$($instance.Type)' not recognized"
              }
          }

          ## Build the registry value to use for Active Setup which is the command to create the registry value in all user hives
          $ActiveSetupValue = "reg add `"{0}`" /v {1} /t {2} /d {3} /f" -f "HKCU\$($instance.Path)", $instance.Name, $RegValueType, $instance.Value
          Write-Verbose -Message "Active setup value is '$ActiveSetupValue'"
          ## Create the necessary Active Setup registry values
          Set-ItemProperty -Path $ActiveSetupRegPath -Name '(Default)' -Value 'Active Setup Test' -Force
          Set-ItemProperty -Path $ActiveSetupRegPath -Name 'Version' -Value '1' -Force
          Set-ItemProperty -Path $ActiveSetupRegPath -Name 'StubPath' -Value $ActiveSetupValue -Force
      }
  }
  catch {
      Write-Warning -Message $_.Exception.Message
  }
}


#(Get-WmiObject -class Win32_OperatingSystem).Caption
$Ver = [System.Environment]::OSVersion.Version.Major
#Write-Host $ver
If ($Ver -eq 10){
New-Item -Path "C:\Users\Public\Pictures\" -Name "Astute" -ItemType "Directory" -ErrorAction SilentlyContinue
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://***.blob.core.windows.net/images/support%20(1).jpg","C:\Users\Public\Pictures\Astute\support.jpg")

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://***.blob.core.windows.net/images/support%20(2).jpg","C:\Users\Public\Pictures\Astute\support1.jpg")

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://***.blob.core.windows.net/images/support3.jpg","C:\Users\Public\Pictures\Astute\support2.jpg")

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://***.blob.core.windows.net/images/Christmas.jpg","C:\Users\Public\Pictures\Astute\Christmas.jpg")

    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    $LockScreenPath = "LockScreenImagePath"
    $LockScreenStatus = "LockScreenImageStatus"
    $LockScreenUrl = "LockScreenImageUrl"
    
    $StatusValue = "1"
    $LockScreenImageValue = "C:\Users\Public\Pictures\Astute\Christmas.jpg"  #Change as per your needs

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

    Start-Sleep 10  

    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowEnabled'; 'Type' = 'Dword'; 'Value' = '1'; 'Path' = 'Software\Microsoft\Windows\CurrentVersion\Lock Screen'}
    Start-Sleep 10
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowDuration'; 'Type' = 'Dword'; 'Value' = '0'; 'Path' = 'Software\Microsoft\Windows\CurrentVersion\Lock Screen'}
    Start-Sleep 10
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowSourceDirectoriesSet'; 'Type' = 'Dword'; 'Value' = '00000001'; 'Path' = 'Software\Microsoft\Windows\CurrentVersion\Lock Screen'}
    Start-Sleep 10
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowOptimizePhotoSelection'; 'Type' = 'Dword'; 'Value' = '00000001'; 'Path' = 'Software\Microsoft\Windows\CurrentVersion\Lock Screen'}
    Start-Sleep 10
    
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowDirectoryPath1'; 'Type' = 'ExpandString'; 'Value' = 'MKAFA8BUg/E0gouOpBhoYjAArADMdmBAvMkOcBAAAAAAAAAAAAAAAAAAAAAAAAAeAEDAAAAAA4VUqwVEAU1clJ3cAQGAJAABA8uveFV+U5VUqwlLAAAA8xHAAAAADFAAAAAAAAAAAoDAAAAAAQjs+AQVAMHAlBgcAMHAAAAQAMHAoBQZAwGAsBwMAIDAuAAZAwGAsBALA0CAyAQMAgDAxAwMAAAAUAAfAEDAAAAAA4VUKlVEAAVdixWajBAAmBQCAQAAv7rXRlWVeFlSZ5CAAAgtbmAAAAgAAAAAAAAAAAAA8AAAAAAAEyH8AAFA1BgYAwGApBwYAAAAABwcAgGAlBAbAwGAzAgMA4CAkBAbAwGAsAQLAIDAxAAOAEDA2AAAAYBACCQMAAAAAAAiRdBWRAAUpNGd1JXZzBAAqBQCAQAAv7rXRlWVIG1FY5CAAAAvbmAAAAgAAAAAAAAAAAAAABAAAAAA8PhQAAFApBwYAQHA1BgcAUGAzBAAAAEAzBAaAUGAsBAbAMDAyAgLAQGAsBAbAwCAtAgMAEDA4AAMAIDAAAAGAcOAxAAAAAAAIGVFYBBABNHd1RXZAAgPAkAAEAw7+iYUVgFiRVBWuAAAAkoRAAAAAYKAAAAAAAAAAAAAAAAAAAArbMSABBwcAQHA1BAdAUGAAAgFAMJAAAwJA8uvFCAAAEzUQN1td66/Nyx/DFIjECkOjOXLpBAAAQGAAAAAfAAAAwCAAAwdAkGAuBAZA8GA3BwcA4CApBQbA0GAlBgcAMHApBgdAUGAjBwbA4GA0BgcA8GAsBAcAEGAuBQZAwGAfBwYAcHA1AgbAEDAoBgMAQHA4BQeAUGA3BQeAAAAAAAAAAAAAAgFAAAA'; 'Path' = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Lock Screen'}
    Start-Sleep 10
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowDirectoryPath2'; 'Type' = 'ExpandString'; 'Value' = 'MKAFA8BUg/E0gouOpBhoYjAArADMdmBAvMkOcBAAAAAAAAAAAAAAAAAAAAAAAAAeAEDAAAAAA4VUqwVEAU1clJ3cAQGAJAABA8uveFV+U5VUqwlLAAAA8xHAAAAADFAAAAAAAAAAAoDAAAAAAQjs+AQVAMHAlBgcAMHAAAAQAMHAoBQZAwGAsBwMAIDAuAAZAwGAsBALA0CAyAQMAgDAxAwMAAAAUAAfAEDAAAAAA4VUKlVEAAVdixWajBAAmBQCAQAAv7rXRlWVeFlSZ5CAAAgtbmAAAAgAAAAAAAAAAAAA8AAAAAAAEyH8AAFA1BgYAwGApBwYAAAAABwcAgGAlBAbAwGAzAgMA4CAkBAbAwGAsAQLAIDAxAAOAEDA2AAAAYBACCQMAAAAAAAiRdBWRAAUpNGd1JXZzBAAqBQCAQAAv7rXRlWVIG1FY5CAAAAvbmAAAAgAAAAAAAAAAAAAABAAAAAA8PhQAAFApBwYAQHA1BgcAUGAzBAAAAEAzBAaAUGAsBAbAMDAyAgLAQGAsBAbAwCAtAgMAEDA4AAMAIDAAAAGAcOAxAAAAAAAIGVFYBBABNHd1RXZAAgPAkAAEAw7+iYUVgFiRVBWuAAAAkoRAAAAAYKAAAAAAAAAAAAAAAAAAAArbMSABBwcAQHA1BAdAUGAAAgFAMJAAAwJA8uvFCAAAEzUQN1td66/Nyx/DFIjECkOjOXLpBAAAQGAAAAAfAAAAwCAAAwdAkGAuBAZA8GA3BwcA4CApBQbA0GAlBgcAMHApBgdAUGAjBwbA4GA0BgcA8GAsBAcAEGAuBQZAwGAfBwYAcHA1AgbAEDAoBgMAQHA4BQeAUGA3BQeAAAAAAAAAAAAAAgFAAAA'; 'Path' = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Lock Screen'}
    Start-Sleep 10
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'RotatingLockScreenOverlayEnabled'; 'Type' = 'Dword'; 'Value' = '00000001'; 'Path' = 'SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'}
    Start-Sleep 10
    Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'RotatingLockScreenEnabled'; 'Type' = 'Dword'; 'Value' = '00000001'; 'Path' = 'SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'}


    #New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreenSlideshow" -Value "0" -PropertyType DWORD -Force

    

    If (Get-WmiObject -Class Win32_Battery){

        Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = 'SlideshowEnabledOnBattery'; 'Type' = 'Dword'; 'Value' = '00000001'; 'Path' = 'Software\Microsoft\Windows\CurrentVersion\Lock Screen'}
        Start-Sleep 10

            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile("https://***.blob.core.windows.net/software/OnBattery.reg","C:\windows\temp\OnBattery.reg")
            regedit.exe /s C:\windows\temp\OnBattery.reg
            
    }
#win7
}else{

    Write-Host "windows 7"
    New-Item -Path "c:\windows\system32\oobe\" -Name "info" -ItemType "Directory"
    New-Item -Path "c:\windows\system32\oobe\info" -Name "backgrounds" -ItemType "Directory"
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://***.blob.core.windows.net/images/Christmas.jpg","c:\windows\system32\oobe\info\backgrounds\BackgroundDefault.jpg")

    $LockScreenPath = "OEMBackground"

    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background"
    New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -value 1 -PropertyType DWORD -force



} 

