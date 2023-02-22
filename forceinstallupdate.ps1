[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default
Install-Module -Name PSWindowsUpdate -force
get-windowsupdate -install -acceptall -ignorereboot