$ApplicationId         = 'xxxx-xxxx-xxxx-xxxx-xxx'
$ApplicationSecret     = 'YOURSECRET' | Convertto-SecureString -AsPlainText -Force
$TenantID              = 'xxxxxx-xxxx-xxx-xxxx--xxx'
$RefreshToken          = 'LongResourcetoken'
$ExchangeRefreshToken  = 'LongExchangeToken'
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
 
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID
 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
