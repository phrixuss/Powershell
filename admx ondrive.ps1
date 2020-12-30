
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://****.blob.core.windows.net/images/OneDrive.admx","C:\Windows\PolicyDefinitions\OneDrive.admx")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://****.blob.core.windows.net/images/OneDriveES.adml","C:\Windows\PolicyDefinitions\en-US\OneDrive.adml")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://****.blob.core.windows.net/images/OneDrive.adml","C:\Windows\PolicyDefinitions\OneDrive.adml")