$hkey = "HKLM:\SOFTWARE\Policies\Microsoft\FVE\"
$hkname = "OSAllowSecureBootForIntegrity"

if ((get-item -path $hkey).property -contains $hkname){
Set-ItemProperty -Path $hkey -Name $hkname -Value 1
}else{
New-ItemProperty -Path $hkey -Name $hkname -propertytype "dword" -Value 1
}