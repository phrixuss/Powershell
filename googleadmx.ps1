$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/chrome.admx","C:\Windows\PolicyDefinitions\chrome.admx")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/google.admx","C:\Windows\PolicyDefinitions\google.admx")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/google.adml","C:\Windows\PolicyDefinitions\en-GB\google.adml")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/googleus.adml","C:\Windows\PolicyDefinitions\en-US\google.adml")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/software/chromeus.adml","C:\Windows\PolicyDefinitions\en-GB\chrome.adml")
