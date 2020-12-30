#Download file
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://***.blob.core.windows.net/software/Cnp60MA64.INF","C:\windows\temp\Cnp60MA64.INF")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://***.blob.core.windows.net/software/gppcl6.cab","C:\windows\temp\gppcl6.cab")

$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://***.blob.core.windows.net/software/cnp60m.cat","C:\windows\temp\cnp60m.cat")

#Install Printer
pnputil.exe -a "C:\windows\temp\Cnp60MA64.INF"
Add-PrinterDriver -Name "Canon Generic Plus PCL6"
Get-PrinterDriver

Add-PrinterPort -Name "192.168.1.151" -PrinterHostAddress "192.168.1.151"
Start-Sleep 10
Add-Printer -Name "Stringer Printer" -ShareName "Stringer Printer"  -PortName "192.168.1.151" -DriverName "Canon Generic Plus PCL6"
