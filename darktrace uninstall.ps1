$app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -match "Darktrace cSensor"}

$app.Uninstall()