$ErrorActionPreference= 'silentlycontinue'

$bitness = get-itemproperty HKLM:\Software\Microsoft\Office\14.0\Outlook -name Bitness
if($bitness -eq $null) {
$bitness = get-itemproperty HKLM:\Software\Microsoft\Office\15.0\Outlook -name Bitness}
if($bitness -eq $null) {
$bitness = get-itemproperty HKLM:\Software\Microsoft\Office\16.0\Outlook -name Bitness}
if($bitness -eq $null) {
$bitness = get-itemproperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\14.0\Outlook -name Bitness}
if($bitness -eq $null) {
$bitness = get-itemproperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\15.0\Outlook -name Bitness}
if($bitness -eq $null) {
$bitness = get-itemproperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Outlook -name Bitness}

$bitVersion = $bitness.Bitness

if ($bitVersion -match "x86") {

Stop-Process -Name OUTLOOK -Force
Wait-Process -Name OUTLOOK

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://***.blob.core.windows.net/software/Mimecast for Outlook (x86).msi","C:\Windows\Temp\Mimecast for Outlook (x86).msi")

Start-Process "C:\Windows\Temp\Mimecast for Outlook (x86).msi" /quiet

}

if ($bitVersion -match "x64") {

Stop-Process -Name OUTLOOK -Force
Wait-Process -Name OUTLOOK

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://***.blob.core.windows.net/software/Mimecast for Outlook (x64).msi","C:\Windows\Temp\Mimecast for Outlook (x64).msi")

Start-Process "C:\Windows\Temp\Mimecast for Outlook (x64).msi" /quiet

}