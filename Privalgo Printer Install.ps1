
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://infrastructureprodsa.blob.core.windows.net/toshibauniversalprinter/Toshiba_Universal_Printer.zip","C:\windows\temp\Toshiba_Universal_Printer.zip")

#Install Printer

Expand-Archive -LiteralPath C:\windows\temp\Toshiba_Universal_Printer.zip -DestinationPath 'C:\windows\temp\Toshiba_Universal_Printer\Toshiba Universal Printer\' -Force
pnputil.exe -a "C:\windows\temp\Toshiba_Universal_Printer\Toshiba Universal Printer\esf6u.INF"
Add-PrinterDriver -Name "Toshiba Universal Printer 2"
Add-PrinterPort -Name "192.168.141.171" -PrinterHostAddress "192.168.141.171"
Start-Sleep 10
Add-Printer -Name "Toshiba Office Printer" -ShareName "Toshiba Office Printer"  -PortName "192.168.141.171" -DriverName "Toshiba Universal Printer 2"
