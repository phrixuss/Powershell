$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/chrome.admx","C:\Windows\PolicyDefinitions\chrome.admx")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/google.admx","C:\Windows\PolicyDefinitions\google.admx")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/google.adml","C:\Windows\PolicyDefinitions\en-GB\google.adml")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/googleus.adml","C:\Windows\PolicyDefinitions\en-US\google.adml")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://firstftorage01.blob.core.windows.net/images/chromeus.adml","C:\Windows\PolicyDefinitions\en-GB\chrome.adml")
