$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'Darktrace cSensor'"
$app.uninstall()