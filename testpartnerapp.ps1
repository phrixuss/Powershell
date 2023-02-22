# Replace with your own variables
$ApplicationID = "be60a724-f932-456f-a2d3-0953140cfaed"
$applicationsecret = "="
$refreshtoken = ""
$exchangerefreshtoken = ""
$MyTenant = ".onmicrosoft.com"
# Do not edit below this line

function Get-GraphToken($tenantid, $scope, $AsApp, $AppID, $erefreshToken, $ReturnRefresh) {
    if (!$scope) { $scope = 'https://graph.microsoft.com/.default' }

    $AuthBody = @{
        client_id     = $ApplicationId
        client_secret = $ApplicationSecret
        scope         = $Scope
        refresh_token = $eRefreshToken
        grant_type    = "refresh_token"
                    
    }

    if ($null -ne $AppID -and $null -ne $erefreshToken) {
        $AuthBody = @{
            client_id     = $appid
            refresh_token = $eRefreshToken
            scope         = $Scope
            grant_type    = "refresh_token"
        }
    }

    if (!$tenantid) { $tenantid = $env:tenantid }
    $AccessToken = (Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$($tenantid)/oauth2/v2.0/token" -Body $Authbody -ErrorAction Stop)
    if ($ReturnRefresh) { $header = $AccessToken } else { $header = @{ Authorization = "Bearer $($AccessToken.access_token)" } }

    return $header
}
function Connect-graphAPI {
    [CmdletBinding()]
    Param
    (
        [parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$ApplicationId,
         
        [parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$ApplicationSecret,
         
        [parameter(Position = 2, Mandatory = $true)]
        [ValidateNotNullOrEmpty()][String]$TenantID,
 
        [parameter(Position = 3, Mandatory = $false)]
        [ValidateNotNullOrEmpty()][String]$RefreshToken
 
    )
    Write-Verbose "Removing old token if it exists"
    $Script:GraphHeader = $null
    Write-Verbose "Logging into Graph API"
    try {
        if ($ApplicationId) {
            Write-Verbose "   using the entered credentials"
            $script:ApplicationId = $ApplicationId
            $script:ApplicationSecret = $ApplicationSecret
            $script:RefreshToken = $RefreshToken
            $AuthBody = @{
                client_id     = $ApplicationId
                client_secret = $ApplicationSecret
                scope         = 'https://graph.microsoft.com/.default'
                refresh_token = $RefreshToken
                grant_type    = "refresh_token"
                
            }
             
        }
        else {
            Write-Verbose "   using the cached credentials"
            $AuthBody = @{
                client_id     = $script:ApplicationId
                client_secret = $Script:ApplicationSecret
                scope         = 'https://graph.microsoft.com/.default'
                refresh_token = $script:RefreshToken
                grant_type    = "refresh_token"
                
            }
        }
        $AccessToken = (Invoke-RestMethod -Method post -Uri "https://login.microsoftonline.com/$($tenantid)/oauth2/v2.0/token" -Body $Authbody -ErrorAction Stop).access_token
 
        $Script:GraphHeader = @{ Authorization = "Bearer $($AccessToken)" }
    }
    catch {
        Write-Host "Could not log into the Graph API for tenant $($TenantID): $($_.Exception.Message)" -ForegroundColor Red
    }
 
}
 
write-host "Starting test of the standard Refresh Token" -ForegroundColor Green

try {
    write-host "Attempting to retrieve an Access Token" -ForegroundColor Green
    Connect-graphAPI -ApplicationId $applicationid -ApplicationSecret $applicationsecret -RefreshToken $refreshtoken -TenantID $MyTenant
}
catch {
    $ErrorDetails = if ($_.ErrorDetails.Message) {
        $ErrorParts = $_.ErrorDetails.Message | ConvertFrom-Json
        "[$($ErrorParts.error)] $($ErrorParts.error_description)"
    }
    else {
        $_.Exception.Message
    }
    Write-Host "Unable to generate access token. The detailed error information, if returned was: $($ErrorDetails)" -ForegroundColor Red
}

try {
    write-host "Attempting to retrieve all tenants you have delegated permission to" -ForegroundColor Green
    $Tenants = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/contracts?`$top=999" -Method GET -Headers $script:GraphHeader).value
}
catch {
    $ErrorDetails = if ($_.ErrorDetails.Message) {
        $ErrorParts = $_.ErrorDetails.Message | ConvertFrom-Json
        "[$($ErrorParts.error)] $($ErrorParts.error_description)"
    }
    else {
        $_.Exception.Message
    }
    Write-Host "Unable to retrieve tenants. The detailed error information, if returned was: $($ErrorDetails)" -ForegroundColor Red
}

# Setup some variables for use in the foreach. Pay no attention to the man behind the curtain....
$TenantCount = $Tenants.Count
$IncrementAmount = 100 / $TenantCount
$i = 0
$ErrorCount = 0

write-host "$TenantCount tenants found, attempting to loop through each to test access to each individual tenant" -ForegroundColor Green
# Loop through every tenant we have, and attempt to interact with it with Graph
foreach ($Tenant in $Tenants) {
    Write-Progress -Activity "Checking Tenant - Refresh Token" -Status "Progress -> Checking $($Tenant.defaultDomainName)" -PercentComplete $i -CurrentOperation TenantLoop
    If ($i -eq 0) { Write-Host "Starting Refresh Token Loop Tests" }
    $i = $i + $IncrementAmount

    try {
        Connect-graphAPI -ApplicationId $applicationid -ApplicationSecret $applicationsecret -RefreshToken $refreshtoken -TenantID $tenant.customerid
    }
    catch {
        $ErrorDetails = if ($_.ErrorDetails.Message) {
            $ErrorParts = $_.ErrorDetails.Message | ConvertFrom-Json
            "[$($ErrorParts.error)] $($ErrorParts.error_description)"
        }
        else {
            $_.Exception.Message
        }
        Write-Host "Unable to connect to graph API for $($Tenant.defaultDomainName). The detailed error information, if returned was: $($ErrorDetails)" -ForegroundColor Red
        $ErrorCount++
        continue
    }


    try {
        $Result = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users" -Method GET -Headers $script:GraphHeader).value
    }
    catch {
        $ErrorDetails = if ($_.ErrorDetails.Message) {
            $ErrorParts = $_.ErrorDetails.Message | ConvertFrom-Json
            "[$($ErrorParts.error)] $($ErrorParts.error_description)"
        }
        else {
            $_.Exception.Message
        }
        Write-Host "Unable to get users from $($Tenant.defaultDomainName) in Refresh Token Test. The detailed error information, if returned was: $($ErrorDetails)" -ForegroundColor Red
        $ErrorCount++
    }
    
}

Write-Host "Standard Graph Refresh Token Test: $TenantCount total tenants, with $ErrorCount failures"
Write-Host "Now attempting to test the Exchange Refresh Token"

# Setup some variables for use in the foreach. Pay no attention to the man behind the curtain....
$j = 0
$ExcErrorCount = 0

foreach ($Tenant in $Tenants) {
    Write-Progress -Activity "Checking Tenant - Exchange Refresh Token" -Status "Progress -> Checking $($Tenant.defaultDomainName)" -PercentComplete $j -CurrentOperation TenantLoop
    If ($j -eq 0) { Write-Host "Starting Exchange Refresh Token Test" }
    $j = $j + $IncrementAmount

    try {
        $upn = "notRequired@required.com"
        $tokenvalue = ConvertTo-SecureString (Get-GraphToken -AppID 'a0c73c16-a7e3-4564-9a95-2bdf47383716' -ERefreshToken $ExchangeRefreshToken -Scope 'https://outlook.office365.com/.default' -Tenantid $tenant.defaultDomainName).Authorization -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($tenant.defaultDomainName)&BasicAuthToOAuthConversion=true" -Credential $credential -Authentication Basic -AllowRedirection -ErrorAction Continue
        $session = Import-PSSession $session -ea Silentlycontinue -AllowClobber -CommandName "Get-OrganizationConfig"
        $org = Get-OrganizationConfig
        $null = Get-PSSession | Remove-PSSession
    }
    catch {
        $ErrorDetails = if ($_.ErrorDetails.Message) {
            $ErrorParts = $_.ErrorDetails.Message | ConvertFrom-Json
            "[$($ErrorParts.error)] $($ErrorParts.error_description)"
        }
        else {
            $_.Exception.Message
        }
        Write-Host "Tenant: $($Tenant.defaultDomainName)-----------------------------------------------------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "Failed to Connect to Exchange for $($Tenant.defaultDomainName). The detailed error information, if returned was: $($ErrorDetails)" -ForegroundColor Red        
        $ExcErrorCount++
    }
}

Write-Host "Exchange Refresh Token Test: $TenantCount total tenants, with $ExcErrorCount failures"
Write-Host "All Tests Finished"