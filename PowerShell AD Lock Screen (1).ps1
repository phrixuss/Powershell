Powercfg /Change monitor-timeout-ac 30m
Powercfg /Change monitor-timeout-dc 30m
Powercfg /Change standby-timeout-ac 30m
Powercfg /Change standby-timeout-dc 30m

New-Item -Path "C:\Windows\Temp\" -Name "LockScreen" -ItemType "Directory"

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://scx2.b-cdn.net/gfx/news/hires/2018/hack.jpg","C:\Windows\Temp\LockScreen\Monday.png")
$WebClient.DownloadFile("https://m.economictimes.com/thumb/msid-73420856,width-1200,height-900,resizemode-4,imgsize-272701/getty.jpg","C:\Windows\Temp\LockScreen\Tuesday.png")
$WebClient.DownloadFile("https://www.pandasecurity.com/mediacenter/src/uploads/2019/07/pandasecurity-How-do-hackers-pick-their-targets.jpg","C:\Windows\Temp\LockScreen\Wednesday.png")
$WebClient.DownloadFile("https://www.pandasecurity.com/mediacenter/src/uploads/2016/03/pandasecurity-Who-are-the-most-famous-hackers-in-history.jpg","C:\Windows\Temp\LockScreen\Thursday.png")
$WebClient.DownloadFile("https://cdn.arstechnica.net/wp-content/uploads/2019/05/GettyImages-843466180.png","C:\Windows\Temp\LockScreen\Friday.png")
$WebClient.DownloadFile("https://qtxasset.com/fiercepharma/1588966924/iStock-540848970.jpg/iStock-540848970.jpg?CTmGXqSbR7o_mTmIzJ6uECMV8DOnhZVm","C:\Windows\Temp\LockScreen\Saturday.png")
$WebClient.DownloadFile("https://hotelpartner.hrs.com/fileadmin/Business_Lounge/Hacker_Angriff/hrs-hacker-attack-head.jpg","C:\Windows\Temp\LockScreen\Sunday.png")

New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP -Force | Out-Null
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name InactivityTimeoutSecs -Value 0x00000600 -PropertyType DWORD -Force | Out-Null

$Date = Get-Date -Format "dddd"

New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP -Name LockScreenImagePath -Value C:\Windows\Temp\LockScreen\$Date.png -PropertyType STRING -Force | Out-Null