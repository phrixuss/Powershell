$client_id = "EnterClientIDHere"
$client_secret = "EnterClientSecretHere"
$tenant_id = "EnterYourTenantIDHere"
$secpasswd = ConvertTo-SecureString $client_secret -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($client_id, $secpasswd)
 
$token = New-PartnerAccessToken -Consent -Credential $mycreds -Resource https://api.partnercenter.microsoft.com -TenantId $tenant_id
$refreshToken = $token.RefreshToken
$refreshToken | out-file C:\temp\refreshToken.txts