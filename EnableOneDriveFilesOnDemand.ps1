$registryPath = "HKLM:SOFTWARE\Policies\Microsoft\OneDrive"

New-Item -Path $registryPath -Force | Out-Null

New-ItemProperty -Path $registryPath -Name "FilesOnDemandEnabled" -Value 1 -PropertyType DWORD -Force | Out-Null


