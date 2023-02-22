if (!(Test-Path -Path C:\Windows\Temp\azcopy.exe)){
    Write-Host "Downloading file"

    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://astuteglobaldeskimages.blob.core.windows.net/astutesoftware/azcopy.exe","C:\windows\temp\azcopy.exe")

}

$barc = "https://infrastructureprodsa.blob.core.windows.net/barc1406806312c/BARC1406806312C.zip"
$bwl = "https://infrastructureprodsa.blob.core.windows.net/bwlbarcap/bwl_barcap.bnlp"


C:\Windows\Temp\azcopy.exe cp $barc "C:\" --recursive=true --overwrite=true
C:\Windows\Temp\azcopy.exe cp $bwl "C:\" --recursive=true --overwrite=true