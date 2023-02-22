connect-AzAccount -Subscription "06d385af-b061-4727-941c-cbc854a54813"

####### declarations ######

$vaultname = "DQGroup-Vault"
$Vaults = Get-AzKeyVaultSecret -VaultName $vaultname

$SqlServer    = 'CS-IT-BI' # SQL Server instance (HostName\InstanceName for named instance)
$Database     = 'Master'      # SQL database to connect to 
$SqlAuthLogin = 'dataquest\christopher.goes'            # SQL Authentication login
$SqlAuthPw    = '!***!'     # SQL Authentication login password



####### end declarations ######

##########################################################################################
##########################################################################################
##########################################################################################

####### Functions #######

Function Connect_MgGraph{

    param(
        $Token
    )

    #Check for module installation

    <#
    $Module=Get-Module -Name microsoft.graph -ListAvailable

    if($Module.count -eq 0){ 

        Write-Host Microsoft Graph PowerShell SDK is not available  -ForegroundColor yellow  
        $Confirm= Read-Host Are you sure you want to install module? [Y] Yes [N] No 
            if($Confirm -match "[yY]"){ 

                Write-host "Installing Microsoft Graph PowerShell module..."
                Install-Module Microsoft.Graph -Repository PSGallery -Scope CurrentUser -AllowClobber -Force
            }else{
                Write-Host "Microsoft Graph PowerShell module is required to run this script. Please install module using Install-Module Microsoft.Graph cmdlet." 
                Exit
            }
    }
        if($CreateSession.IsPresent){
            Disconnect-MgGraph
    }
    #Connecting to MgGraph beta
    Select-MgProfile -Name beta
    #>
    Write-Host Connecting to Microsoft Graph...
    Connect-MgGraph -accesstoken $token
}

Function droptables
{
param($appid)

$droptables = @"

    IF (EXISTS (SELECT * 
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = 'dbo' 
                    AND TABLE_NAME = 'usercount_mfa'))
    BEGIN



        drop table usercount_mfa




    END;

    IF (EXISTS (SELECT * 
                    FROM INFORMATION_SCHEMA.TABLES 
                    WHERE TABLE_SCHEMA = 'dbo' 
                    AND TABLE_NAME = 'usercount_report'))
    BEGIN



        drop table usercount_report




    END;
"@   


Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;" -Query "$droptables"

}

Function Orginformation
{
param($appid)

$tenantinformation = @"

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND TABLE_NAME = 'usercount_org'))
BEGIN



    SELECT * FROM UserCount_org WHERE Tenant_appID LIKE '$appid'




END;
"@   


Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;" -Query "$tenantinformation"

}

Function Import_SQL_MFA
{
    param($id,$name,$upn,$department,$license,$signinstatus,$authmethod,$mfastatus,$mfaphone,$mfaconfigstatus,$3rdpartymfa,$additionaldetails)
#Name,UPN,Department,'License Status','SignIn Status','Authentication Methods','MFA Status','MFA Phone','Microsoft Authenticator Configured Device','Is 3rd-Party Authenticator Used','Additional Details'
$tenantinformation = @"

        IF (EXISTS (SELECT * 
                        FROM INFORMATION_SCHEMA.TABLES 
                        WHERE TABLE_SCHEMA = 'dbo' 
                        AND TABLE_NAME = 'usercount_mfa'))
        BEGIN



            INSERT INTO [master].[dbo].[usercount_mfa](tenantid,tenant_user_name,Tenant_user_UPN,tenant_user_department,tenant_user_license,Tenant_user_signinstatus,tenant_user_authmethod,tenant_user_mfastatus,tenant_user_mfaphone,tenant_user_mfaconfigstatus,tenant_user_3rdpartymfa,tenant_user_additionaldetails)
            VALUES ('$id','$name','$upn','$department','$license','$signinstatus','$authmethod','$mfastatus','$mfaphone','$mfaconfigstatus','$3rdpartymfa','$additionaldetails')




        END;
        else
        BEGIN

            CREATE TABLE UserCount_MFA (

            ID int IDENTITY(1,1) PRIMARY KEY,
            TenantID varchar(255) NOT NULL,
            Tenant_User_name VARCHAR(255),
            Tenant_user_UPN VARCHAR(255),
            Tenant_user_department VARCHAR(255),
            Tenant_user_license varchar(255),
            Tenant_user_signinstatus varchar(255),
            Tenant_user_authmethod varchar(255),
            Tenant_user_mfastatus varchar(255),
            Tenant_user_mfaphone varchar(255),
            Tenant_user_mfaconfigstatus varchar(255),
            Tenant_user_3rdpartymfa varchar(255),
            Tenant_user_Additionaldetails varchar(255),


            );

            INSERT INTO [master].[dbo].[usercount_mfa](tenantid,tenant_user_name,Tenant_user_UPN,tenant_user_department,tenant_user_license,Tenant_user_signinstatus,tenant_user_authmethod,tenant_user_mfastatus,tenant_user_mfaphone,tenant_user_mfaconfigstatus,tenant_user_3rdpartymfa,tenant_user_additionaldetails)
            VALUES ('$id','$name','$upn','$department','$license','$signinstatus','$authmethod','$mfastatus','$mfaphone','$mfaconfigstatus','$3rdpartymfa','$additionaldetails')

        end;
"@   


Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;" -Query "$tenantinformation"
}

Function Import_SQL_report
{
param(
    $TenantID,
    $Tenant_report_UPN,
    $tenant_report_DisplayName,
    $tenant_report_Status,
    $tenant_report_LastSignIn,
    $tenant_report_DaysSinceSignIn,
    $tenant_report_EXOLastActive,
    $tenant_report_EXODaysSinceActive,
    $tenant_report_EXOQuotaUsed,
    $tenant_report_EXOItems,
    $tenant_report_EXOSendCount,
    $tenant_report_EXOReadCount,
    $tenant_report_EXOReceiveCount,
    $tenant_report_TeamsLastActive,
    $tenant_report_TeamsDaysSinceActive,
    $Tenant_report_TeamsChannelChat,
    $tenant_report_TeamsPrivateChat,
    $tenant_report_TeamsMeetings,
    $tenant_report_TeamsCalls,
    $tenant_report_SPOLastActive,
    $tenant_report_SPODaysSinceActive,
    $tenant_report_SPOViewedEditedFiles,
    $Tenant_report_SPOSyncedFiles,
    $tenant_report_SPOSharedExtFiles,
    $tenant_report_SPOSharedIntFiles,
    $tenant_report_SPOVisitedPages,
    $tenant_report_OneDriveLastActive,
    $tenant_report_OneDriveDaysSinceActive,
    $tenant_report_OneDriveFiles,
    $tenant_report_OneDriveStorage,
    $tenant_report_OneDriveQuota,
    $tenant_report_YammerLastActive,
    $Tenant_report_YammerDaysSinceActive,
    $Tenant_report_YammerPosts,
    $tenant_report_YammerReads,
    $tenant_report_YammerLikes,
    $tenant_report_License,
    $tenant_report_OneDriveSite,
    $Tenant_report_IsDeleted,
    $tenant_report_EXOReportDate,
    $tenant_report_TeamsReportDate,
    $Tenant_report_UsageFigure
)
#Name,UPN,Department,'License Status','SignIn Status','Authentication Methods','MFA Status','MFA Phone','Microsoft Authenticator Configured Device','Is 3rd-Party Authenticator Used','Additional Details'
$tenantinformation = @"

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND TABLE_NAME = 'usercount_report'))
BEGIN



    INSERT INTO [master].[dbo].[usercount_report](TenantID,Tenant_report_UPN,tenant_report_DisplayName,tenant_report_Status,tenant_report_LastSignIn,tenant_report_DaysSinceSignIn,tenant_report_EXOLastActive,tenant_report_EXODaysSinceActive,tenant_report_EXOQuotaUsed,tenant_report_EXOItems,tenant_report_EXOSendCount,tenant_report_EXOReadCount,tenant_report_EXOReceiveCount,tenant_report_TeamsLastActive,tenant_report_TeamsDaysSinceActive,Tenant_report_TeamsChannelChat,tenant_report_TeamsPrivateChat,tenant_report_TeamsMeetings,tenant_report_TeamsCalls,tenant_report_SPOLastActive,tenant_report_SPODaysSinceActive,tenant_report_SPOViewedEditedFiles,Tenant_report_SPOSyncedFiles,tenant_report_SPOSharedExtFiles,tenant_report_SPOSharedIntFiles,tenant_report_SPOVisitedPages,tenant_report_OneDriveLastActive,tenant_report_OneDriveDaysSinceActive,tenant_report_OneDriveFiles,tenant_report_OneDriveStorage,tenant_report_OneDriveQuota,tenant_report_YammerLastActive,Tenant_report_YammerDaysSinceActive,Tenant_report_YammerPosts,tenant_report_YammerReads,tenant_report_YammerLikes,tenant_report_License,tenant_report_OneDriveSite,Tenant_report_IsDeleted,tenant_report_EXOReportDate,tenant_report_TeamsReportDate,Tenant_report_UsageFigure)
    VALUES (
        '$TenantID',
        '$Tenant_report_UPN',
        '$tenant_report_DisplayName',
        '$tenant_report_Status',
        '$tenant_report_LastSignIn',
        '$tenant_report_DaysSinceSignIn',
        '$tenant_report_EXOLastActive',
        '$tenant_report_EXODaysSinceActive',
        '$tenant_report_EXOQuotaUsed',
        '$tenant_report_EXOItems',
        '$tenant_report_EXOSendCount',
        '$tenant_report_EXOReadCount',
        '$tenant_report_EXOReceiveCount',
        '$tenant_report_TeamsLastActive',
        '$tenant_report_TeamsDaysSinceActive',
        '$Tenant_report_TeamsChannelChat',
        '$tenant_report_TeamsPrivateChat',
        '$tenant_report_TeamsMeetings',
        '$tenant_report_TeamsCalls',
        '$tenant_report_SPOLastActive',
        '$tenant_report_SPODaysSinceActive',
        '$tenant_report_SPOViewedEditedFiles',
        '$Tenant_report_SPOSyncedFiles',
        '$tenant_report_SPOSharedExtFiles',
        '$tenant_report_SPOSharedIntFiles',
        '$tenant_report_SPOVisitedPages',
        '$tenant_report_OneDriveLastActive',
        '$tenant_report_OneDriveDaysSinceActive',
        '$tenant_report_OneDriveFiles',
        '$tenant_report_OneDriveStorage',
        '$tenant_report_OneDriveQuota',
        '$tenant_report_YammerLastActive',
        '$Tenant_report_YammerDaysSinceActive',
        '$Tenant_report_YammerPosts',
        '$tenant_report_YammerReads',
        '$tenant_report_YammerLikes',
        '$tenant_report_License',
        '$tenant_report_OneDriveSite',
        '$Tenant_report_IsDeleted',
        '$tenant_report_EXOReportDate',
        '$tenant_report_TeamsReportDate',
        '$Tenant_report_UsageFigure'

    )



END;
else
BEGIN

    CREATE TABLE UserCount_report (
        ID int IDENTITY(1,1) PRIMARY KEY,
        TenantID varchar(255) NOT NULL,
        Tenant_report_UPN varchar(255),
        tenant_report_DisplayName varchar(255),
        tenant_report_Status varchar(255),
        tenant_report_LastSignIn varchar(255),
        tenant_report_DaysSinceSignIn varchar(255),
        tenant_report_EXOLastActive varchar(255),
        tenant_report_EXODaysSinceActive varchar(255),
        tenant_report_EXOQuotaUsed varchar(255),
        tenant_report_EXOItems varchar(255),
        tenant_report_EXOSendCount varchar(255),
        tenant_report_EXOReadCount varchar(255),
        tenant_report_EXOReceiveCount varchar(255),
        tenant_report_TeamsLastActive varchar(255),
        tenant_report_TeamsDaysSinceActive varchar(255),
        Tenant_report_TeamsChannelChat varchar(255),
        tenant_report_TeamsPrivateChat varchar(255),
        tenant_report_TeamsMeetings varchar(255),
        tenant_report_TeamsCalls varchar(255),
        tenant_report_SPOLastActive varchar(255),
        tenant_report_SPODaysSinceActive varchar(255),
        tenant_report_SPOViewedEditedFiles varchar(255),
        Tenant_report_SPOSyncedFiles varchar(255),
        tenant_report_SPOSharedExtFiles varchar(255),
        tenant_report_SPOSharedIntFiles varchar(255),
        tenant_report_SPOVisitedPages varchar(255),
        tenant_report_OneDriveLastActive varchar(255),
        tenant_report_OneDriveDaysSinceActive varchar(255),
        tenant_report_OneDriveFiles varchar(255),
        tenant_report_OneDriveStorage varchar(255),
        tenant_report_OneDriveQuota varchar(255),
        tenant_report_YammerLastActive varchar(255),
        Tenant_report_YammerDaysSinceActive varchar(255),
        Tenant_report_YammerPosts varchar(255),
        tenant_report_YammerReads varchar(255),
        tenant_report_YammerLikes varchar(255),
        tenant_report_License varchar(255),
        tenant_report_OneDriveSite varchar(255),
        Tenant_report_IsDeleted varchar(255),
        tenant_report_EXOReportDate varchar(255),
        tenant_report_TeamsReportDate varchar(255),
        Tenant_report_UsageFigure varchar(255)

    );

    INSERT INTO [master].[dbo].[usercount_report](TenantID,Tenant_report_UPN,tenant_report_DisplayName,tenant_report_Status,tenant_report_LastSignIn,tenant_report_DaysSinceSignIn,tenant_report_EXOLastActive,tenant_report_EXODaysSinceActive,tenant_report_EXOQuotaUsed,tenant_report_EXOItems,tenant_report_EXOSendCount,tenant_report_EXOReadCount,tenant_report_EXOReceiveCount,tenant_report_TeamsLastActive,tenant_report_TeamsDaysSinceActive,Tenant_report_TeamsChannelChat,tenant_report_TeamsPrivateChat,tenant_report_TeamsMeetings,tenant_report_TeamsCalls,tenant_report_SPOLastActive,tenant_report_SPODaysSinceActive,tenant_report_SPOViewedEditedFiles,Tenant_report_SPOSyncedFiles,tenant_report_SPOSharedExtFiles,tenant_report_SPOSharedIntFiles,tenant_report_SPOVisitedPages,tenant_report_OneDriveLastActive,tenant_report_OneDriveDaysSinceActive,tenant_report_OneDriveFiles,tenant_report_OneDriveStorage,tenant_report_OneDriveQuota,tenant_report_YammerLastActive,Tenant_report_YammerDaysSinceActive,Tenant_report_YammerPosts,tenant_report_YammerReads,tenant_report_YammerLikes,tenant_report_License,tenant_report_OneDriveSite,Tenant_report_IsDeleted,tenant_report_EXOReportDate,tenant_report_TeamsReportDate,Tenant_report_UsageFigure)
    VALUES (
        '$TenantID',
        '$Tenant_report_UPN',
        '$tenant_report_DisplayName',
        '$tenant_report_Status',
        '$tenant_report_LastSignIn',
        '$tenant_report_DaysSinceSignIn',
        '$tenant_report_EXOLastActive',
        '$tenant_report_EXODaysSinceActive',
        '$tenant_report_EXOQuotaUsed',
        '$tenant_report_EXOItems',
        '$tenant_report_EXOSendCount',
        '$tenant_report_EXOReadCount',
        '$tenant_report_EXOReceiveCount',
        '$tenant_report_TeamsLastActive',
        '$tenant_report_TeamsDaysSinceActive',
        '$Tenant_report_TeamsChannelChat',
        '$tenant_report_TeamsPrivateChat',
        '$tenant_report_TeamsMeetings',
        '$tenant_report_TeamsCalls',
        '$tenant_report_SPOLastActive',
        '$tenant_report_SPODaysSinceActive',
        '$tenant_report_SPOViewedEditedFiles',
        '$Tenant_report_SPOSyncedFiles',
        '$tenant_report_SPOSharedExtFiles',
        '$tenant_report_SPOSharedIntFiles',
        '$tenant_report_SPOVisitedPages',
        '$tenant_report_OneDriveLastActive',
        '$tenant_report_OneDriveDaysSinceActive',
        '$tenant_report_OneDriveFiles',
        '$tenant_report_OneDriveStorage',
        '$tenant_report_OneDriveQuota',
        '$tenant_report_YammerLastActive',
        '$Tenant_report_YammerDaysSinceActive',
        '$Tenant_report_YammerPosts',
        '$tenant_report_YammerReads',
        '$tenant_report_YammerLikes',
        '$tenant_report_License',
        '$tenant_report_OneDriveSite',
        '$Tenant_report_IsDeleted',
        '$tenant_report_EXOReportDate',
        '$tenant_report_TeamsReportDate',
            # Process Exchange D
        '$Tenant_report_UsageFigure'

    )


end;
"@   


Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;" -Query "$tenantinformation"
}

####### end Functions ########




if (Get-AzKeyVault -Name DQGroup-Vault){
    Write-host "Azure key vault exist, script will continue"
}else{
    Write-host "Azure Key Vault does not exist, script cannot continue"
}

$tenant_information = Orginformation

droptables

foreach ($vault in $Vaults){

    if(Orginformation $vault.name){
            $thumbprint = get-azkeyvaultsecret -vaultname $vaultname -name $vault.name -AsPlainText

            $appidreturn = Orginformation $vault.name

            $appid = $vault.name
            $tenantid = $appidreturn.tenant_id  
            $secret = $thumbprint

            $body =  @{
                Grant_Type    = "client_credentials"
                Scope         = "https://graph.microsoft.com/.default"
                Client_Id     = $appid
                Client_Secret = $secret
            }

            $connection = Invoke-RestMethod `
                -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
                -Method POST `
                -Body $body

            $token = $connection.access_token

        #################################################################################################


            Connect_MgGraph $token
            
            if((Get-MgContext) -ne ""){

                Write-Host Connected to Microsoft Graph PowerShell using (Get-MgContext).Account account -ForegroundColor Yellow

            }
            
                $ProcessedUserCount=0
                $ExportCount=0

            #Set output file 

                $ExportCSV="C:\temp\MfaStatusReport_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"
                $Result=""  
                $Results=@()

            #Get all users

                Get-MgUser -All -Filter "UserType eq 'Member'" | foreach {
                $ProcessedUserCount++
                $Name= $_.DisplayName
                $UPN=$_.UserPrincipalName
                $Department=$_.Department

                if($_.AccountEnabled -eq $true){
                    $SigninStatus="Allowed"
                }else{

                    $SigninStatus="Blocked"

                }


                if(($_.AssignedLicenses).Count -ne 0){

                    $LicenseStatus="Licensed"

                }else{

                    $LicenseStatus="Unlicensed"

                }

            $Is3rdPartyAuthenticatorUsed="False"
            $MFAPhone="-"
            $MicrosoftAuthenticatorDevice="-"
            Write-Progress -Activity "`n     Processed users count: $ProcessedUserCount "`n"  Currently processing user: $Name"
            [array]$MFAData=Get-MgUserAuthenticationMethod -UserId $UPN
            $AuthenticationMethod=@()
            $AdditionalDetails=@()
            
            foreach($MFA in $MFAData)
            { 
            Switch ($MFA.AdditionalProperties["@odata.type"]) 
            { 
                "#microsoft.graph.passwordAuthenticationMethod"
                {
                $AuthMethod     = 'PasswordAuthentication'
                $AuthMethodDetails = $MFA.AdditionalProperties["displayName"] 
                } 
                "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod"  
                { # Microsoft Authenticator App
                $AuthMethod     = 'AuthenticatorApp'
                $AuthMethodDetails = $MFA.AdditionalProperties["displayName"] 
                $MicrosoftAuthenticatorDevice=$MFA.AdditionalProperties["displayName"]
                }
                "#microsoft.graph.phoneAuthenticationMethod"                  
                { # Phone authentication
                $AuthMethod     = 'PhoneAuthentication'
                $AuthMethodDetails = $MFA.AdditionalProperties["phoneType", "phoneNumber"] -join ' ' 
                $MFAPhone=$MFA.AdditionalProperties["phoneNumber"]
                } 
                "#microsoft.graph.fido2AuthenticationMethod"                   
                { # FIDO2 key
                $AuthMethod     = 'Fido2'
                $AuthMethodDetails = $MFA.AdditionalProperties["model"] 
                }  
                "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" 
                { # Windows Hello
                $AuthMethod     = 'WindowsHelloForBusiness'
                $AuthMethodDetails = $MFA.AdditionalProperties["displayName"] 
                }                        
                "#microsoft.graph.emailAuthenticationMethod"        
                { # Email Authentication
                $AuthMethod     = 'EmailAuthentication'
                $AuthMethodDetails = $MFA.AdditionalProperties["emailAddress"] 
                }               
                "microsoft.graph.temporaryAccessPassAuthenticationMethod"   
                { # Temporary Access pass
                $AuthMethod     = 'TemporaryAccessPass'
                $AuthMethodDetails = 'Access pass lifetime (minutes): ' + $MFA.AdditionalProperties["lifetimeInMinutes"] 
                }
                "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod" 
                { # Passwordless
                $AuthMethod     = 'PasswordlessMSAuthenticator'
                $AuthMethodDetails = $MFA.AdditionalProperties["displayName"] 
                }      
                "#microsoft.graph.softwareOathAuthenticationMethod"
                { 
                $AuthMethod     = 'SoftwareOath'
                $Is3rdPartyAuthenticatorUsed="True"            
                }
                
            }
            $AuthenticationMethod +=$AuthMethod
            if($AuthMethodDetails -ne $null)
            {
                $AdditionalDetails +="$AuthMethod : $AuthMethodDetails"
            }
            }
            #To remove duplicate authentication methods
            $AuthenticationMethod =$AuthenticationMethod | Sort-Object | Get-Unique
            $AuthenticationMethods= $AuthenticationMethod  -join ","
            $AdditionalDetail=$AdditionalDetails -join ", "
            $Print=1
            #Determine MFA status
            [array]$StrongMFAMethods=("Fido2","PhoneAuthentication","PasswordlessMSAuthenticator","AuthenticatorApp","WindowsHelloForBusiness")
            $MFAStatus="Disabled"
            

            foreach($StrongMFAMethod in $StrongMFAMethods)
            {
            if($AuthenticationMethod -contains $StrongMFAMethod)
            {
                $MFAStatus="Strong"
                break
            }
            }

            if(($MFAStatus -ne "Strong") -and ($AuthenticationMethod -contains "SoftwareOath"))
            {
            $MFAStatus="Weak"
            }
            #Filter result based on MFA status
            if($MFADisabled.IsPresent -and $MFAStatus -ne "Disabled")
            {
            $Print=0
            }
            if($MFAEnabled.IsPresent -and $MFAStatus -eq "Disabled")
            {
            $Print=0
            }

            #Filter result based on license status
            if($LicensedUsersOnly.IsPresent -and ($LicenseStatus -eq "Unlicensed"))
            {
            $Print=0
            }

            #Filter result based on signin status
            if($SignInAllowedUsersOnly.IsPresent -and ($SigninStatus -eq "Blocked"))
            {
            $Print=0
            }
     
            if($Print -eq 1)
            {
            $ExportCount++
            $Result=@{'Name'=$Name;'UPN'=$UPN;'Department'=$Department;'License Status'=$LicenseStatus;'SignIn Status'=$SigninStatus;'Authentication Methods'=$AuthenticationMethods;'MFA Status'=$MFAStatus;'MFA Phone'=$MFAPhone;'Microsoft Authenticator Configured Device'=$MicrosoftAuthenticatorDevice;'Is 3rd-Party Authenticator Used'=$Is3rdPartyAuthenticatorUsed;'Additional Details'=$AdditionalDetail} 
            $Results= New-Object PSObject -Property $Result 
            #$Results | Select-Object Name,UPN,Department,'License Status','SignIn Status','Authentication Methods','MFA Status','MFA Phone','Microsoft Authenticator Configured Device','Is 3rd-Party Authenticator Used','Additional Details' | Export-Csv -Path $ExportCSV -Notype -Append
            foreach($importsql1 in $results){
                
            Import_SQL_MFA $appidreturn.tenant_id $importsql1.name $importsql1.upn $importsql1.department $importsql1.'License Status' $importsql1.'Signin Status' $importsql1.'authentication mathods' $importsql1.'MFA Status' $importsql1.'MFA Phone' $importsql1.'Microsoft Authenticator Configured Device' $importsql1.'Is 3rd-Party Authenticator Used' $importsql1.'Additional Detais'
                                

            }
                

            }
        }



    }else{
        Write-Host 'App not created'
    }


}

FOREACH ($vault in $vaults){
    if(Orginformation $vault.name){    
            $thumbprint = get-azkeyvaultsecret -vaultname $vaultname -name $vault.name -AsPlainText

            $appidreturn = Orginformation $vault.name

            
            $appid = $vault.name
            $tenantid = $appidreturn.tenant_id  
            $secret = $thumbprint

            $StartTime1 = Get-Date

            # Construct URI and body needed for authentication
            $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
            $body = @{
                client_id     = $AppId
                scope         = "https://graph.microsoft.com/.default"
                client_secret = $Secret
                grant_type    = "client_credentials" }

            # Get OAuth 2.0 Token
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

            # Unpack Access Token
            $token = ($tokenRequest.Content | ConvertFrom-Json).access_token

            # Base URL
            $headers = @{Authorization = "Bearer $token"}

            Write-Host "Fetching Teams user activity data from the Graph..."
            # The Graph returns information in CSV format. We convert it to allow the data to be more easily processed by PowerShell
            # Get Teams Usage Data - the replace parameter is there to remove three odd leading characters (ï»¿) in the CSV data returned by the 
            $TeamsUserReportsURI = "https://graph.microsoft.com/v1.0/reports/getTeamsUserActivityUserDetail(period='D90')"
            $TeamsUserData = (Invoke-RestMethod -Uri $TeamsUserReportsURI -Headers $Headers -Method Get -ContentType "application/json") -Replace "...Report Refresh Date", "Report Refresh Date" | ConvertFrom-Csv 

            Write-Host "Fetching OneDrive for Business user activity data from the Graph..."
            # Get OneDrive for Business data
            $OneDriveUsageURI = "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountDetail(period='D90')"
            $OneDriveData = (Invoke-RestMethod -Uri $OneDriveUsageURI -Headers $Headers -Method Get -ContentType "application/json") -Replace "...Report Refresh Date", "Report Refresh Date" | ConvertFrom-Csv 
            
            Write-Host "Fetching Exchange Online user activity data from the Graph..."
            # Get Exchange Activity Data
            $EmailReportsURI = "https://graph.microsoft.com/v1.0/reports/getEmailActivityUserDetail(period='D90')"
            $EmailData = (Invoke-RestMethod -Uri $EmailReportsURI -Headers $Headers -Method Get -ContentType "application/json") -Replace "...Report Refresh Date", "Report Refresh Date" | ConvertFrom-Csv 

            # Get Exchange Storage Data   
            $MailboxUsageReportsURI = "https://graph.microsoft.com/v1.0/reports/getMailboxUsageDetail(period='D90')"
            $MailboxUsage = (Invoke-RestMethod -Uri $MailboxUsageReportsURI -Headers $Headers -Method Get -ContentType "application/json") -Replace "...Report Refresh Date", "Report Refresh Date" | ConvertFrom-Csv 
            Write-Host "Fetching SharePoint Online user activity data from the Graph..."
            # Get SharePoint usage data
            $SPOUsageReportsURI = "https://graph.microsoft.com/v1.0/reports/getSharePointActivityUserDetail(period='D90')"
            $SPOUsage = (Invoke-RestMethod -Uri $SPOUsageReportsURI -Headers $Headers -Method Get -ContentType "application/json") -Replace "...Report Refresh Date", "Report Refresh Date" | ConvertFrom-Csv 

            Write-Host "Fetching Yammer user activity data from the Graph..."
            # Get Yammer usage data
            $YammerUsageReportsURI = "https://graph.microsoft.com/v1.0/reports/getYammerActivityUserDetail(period='D90')"
            $YammerUsage = (Invoke-RestMethod -Uri $YammerUsageReportsURI -Headers $Headers -Method Get -ContentType "application/json") -Replace "...Report Refresh Date", "Report Refresh Date" | ConvertFrom-Csv 

            # Create hash table for user sign in data
            $UserSignIns = @{}
            # And hash table for the output data
            $DataTable = @{}
            # Get User sign in data
            Write-Host "Fetching user sign-in data from the Graph..."
            $URI = "https://graph.microsoft.com/beta/users?`$select=displayName,userPrincipalName, mail, id, CreatedDateTime, signInActivity, UserType&`$top=999"
            $SignInData = (Invoke-RestMethod -Uri $URI -Headers $Headers -Method Get -ContentType "application/json") 
            # Update the user sign in hash table
            ForEach ($U in $SignInData.Value) {
            If ($U.UserType -eq "Member") {
                $DataTable.Add([String]$U.UserPrincipalName,$Null)
                If ($U.SignInActivity.LastSignInDateTime) {
                    $LastSignInDate = Get-Date($U.SignInActivity.LastSignInDateTime) -format g
                    $UserSignIns.Add([String]$U.UserPrincipalName, $LastSignInDate) }
            }}

            # Do we have extra data to fetch?
            $NextLink = $SignInData.'@Odata.NextLink'
            # If we have a next link, go and process the remaining set of users
            While ($NextLink -ne $Null) { 
            Write-Host "Still processing..."
            $SignInData = Invoke-WebRequest -Method GET -Uri $NextLink -ContentType "application/json" -Headers $Headers -UseBasicParsing
            $SignInData = $SignInData | ConvertFrom-JSon
            ForEach ($U in $SignInData.Value) {  
            If ($U.UserType -eq "Member") {
                $DataTable.Add([String]$U.UserPrincipalName,$Null)
                If ($U.SignInActivity.LastSignInDateTime) {
                    $LastSignInDate = Get-Date($U.SignInActivity.LastSignInDateTime) -format g
                    $UserSignIns.Add([String]$U.UserPrincipalName, $LastSignInDate) }
            }}
            $NextLink = $SignInData.'@Odata.NextLink'
            } # End while

            $StartTime2 = Get-Date
            Write-Host "Processing activity data fetched from the Graph..."
            # Process Teams Data
            ForEach ($T in $TeamsUserData) {
            If ([string]::IsNullOrEmpty($T."Last Activity Date")) { 
                $TeamsLastActivity = "No activity"
                $TeamsDaysSinceActive = "N/A" }
            Else {
                $TeamsLastActivity = Get-Date($T."Last Activity Date") -format "dd-MMM-yyyy" 
                $TeamsDaysSinceActive = (New-TimeSpan($TeamsLastActivity)).Days }
            $ReportLine  = [PSCustomObject] @{          
                TeamsUPN               = $T."User Principal Name"
                TeamsLastActive        = $TeamsLastActivity  
                TeamsDaysSinceActive   = $TeamsDaysSinceActive      
                TeamsReportDate        = Get-Date($T."Report Refresh Date") -format "dd-MMM-yyyy"  
                TeamsLicense           = $T."Assigned Products"
                TeamsChannelChats      = $T."Team Chat Message Count"
                TeamsPrivateChats      = $T."Private Chat Message Count"
                TeamsCalls             = $T."Call Count"
                TeamsMeetings          = $T."Meeting Count"
                TeamsRecordType        = "Teams"}
            $DataTable[$T."User Principal Name"] = $ReportLine} 

            # Process Exchange Data
            ForEach ($E in $EmailData) {
            $ExoDaysSinceActive = $Null
            If ([string]::IsNullOrEmpty($E."Last Activity Date")) { 
                $ExoLastActivity = "No activity"
                $ExoDaysSinceActive = "N/A" }
            Else {
                $ExoLastActivity = Get-Date($E."Last Activity Date") -format "dd-MMM-yyyy"
                $ExoDaysSinceActive = (New-TimeSpan($ExoLastActivity)).Days }
            $ReportLine  = [PSCustomObject] @{          
                ExoUPN                = $E."User Principal Name"
                ExoDisplayName        = $E."Display Name"
                ExoLastActive         = $ExoLastActivity   
                ExoDaysSinceActive    = $ExoDaysSinceActive    
                ExoReportDate         = Get-Date($E."Report Refresh Date") -format "dd-MMM-yyyy"  
                ExoSendCount          = [int]$E."Send Count"
                ExoReadCount          = [int]$E."Read Count"
                ExoReceiveCount       = [int]$E."Receive Count"
                ExoIsDeleted          = $E."Is Deleted"
                ExoRecordType         = "Exchange Activity"}
            [Array]$ExistingData = $DataTable[$E."User Principal Name"] 
            [Array]$NewData = $ExistingData + $ReportLine
            $DataTable[$E."User Principal Name"] = $NewData } 
            
            ForEach ($M in $MailboxUsage) {
            If ([string]::IsNullOrEmpty($M."Last Activity Date")) { 
                $ExoLastActivity = "No activity" }
            Else {
                $ExoLastActivity = Get-Date($M."Last Activity Date") -format "dd-MMM-yyyy"
                $ExoDaysSinceActive = (New-TimeSpan($ExoLastActivity)).Days }
            $ReportLine  = [PSCustomObject] @{          
                MbxUPN                = $M."User Principal Name"
                MbxDisplayName        = $M."Display Name"
                MbxLastActive         = $ExoLastActivity 
                MbxDaysSinceActive    = $ExoDaysSinceActive          
                MbxReportDate         = Get-Date($M."Report Refresh Date") -format "dd-MMM-yyyy"  
                MbxQuotaUsed          = [Math]::Round($M."Storage Used (Byte)"/1GB,2) 
                MbxItems              = [int]$M."Item Count"
                MbxRecordType         = "Exchange Storage"}
            [Array]$ExistingData = $DataTable[$M."User Principal Name"] 
            [Array]$NewData = $ExistingData + $ReportLine
            $DataTable[$M."User Principal Name"] = $NewData } 

            # SharePoint data
            ForEach ($S in $SPOUsage) {
            If ([string]::IsNullOrEmpty($S."Last Activity Date")) { 
                $SPOLastActivity = "No activity"
                $SPODaysSinceActive = "N/A" }
            Else {
                $SPOLastActivity = Get-Date($S."Last Activity Date") -format "dd-MMM-yyyy"
                $SPODaysSinceActive = (New-TimeSpan ($SPOLastActivity)).Days }
            $ReportLine  = [PSCustomObject] @{          
                SPOUPN              = $S."User Principal Name"
                SPOLastActive       = $SPOLastActivity    
                SPODaysSinceActive  = $SPODaysSinceActive 
                SPOViewedEdited     = [int]$S."Viewed or Edited File Count"     
                SPOSyncedFileCount  = [int]$S."Synced File Count"
                SPOSharedExt        = [int]$S."Shared Externally File Count"
                SPOSharedInt        = [int]$S."Shared Internally File Count"
                SPOVisitedPages     = [int]$S."Visited Page Count" 
                SPORecordType       = "SharePoint Usage"}
            [Array]$ExistingData = $DataTable[$S."User Principal Name"] 
            [Array]$NewData = $ExistingData + $ReportLine
            $DataTable[$S."User Principal Name"] = $NewData }  

            # OneDrive for Business data
            ForEach ($O in $OneDriveData) {
            $OneDriveLastActivity = $Null
            If ([string]::IsNullOrEmpty($O."Last Activity Date")) { 
                $OneDriveLastActivity = "No activity"
                $OneDriveDaysSinceActive = "N/A" }
            Else {
                $OneDriveLastActivity = Get-Date($O."Last Activity Date") -format "dd-MMM-yyyy" 
                $OneDriveDaysSinceActive = (New-TimeSpan($OneDriveLastActivity)).Days }
            $ReportLine  = [PSCustomObject] @{          
                ODUPN               = $O."Owner Principal Name"
                ODDisplayName       = $O."Owner Display Name"
                ODLastActive        = $OneDriveLastActivity    
                ODDaysSinceActive   = $OneDriveDaysSinceActive    
                ODSite              = $O."Site URL"
                ODFileCount         = [int]$O."File Count"
                ODStorageUsed       = [Math]::Round($O."Storage Used (Byte)"/1GB,4) 
                ODQuota             = [Math]::Round($O."Storage Allocated (Byte)"/1GB,2) 
                ODRecordType        = "OneDrive Storage"}
            [Array]$ExistingData = $DataTable[$O."Owner Principal Name"] 
            [Array]$NewData = $ExistingData + $ReportLine
            $DataTable[$O."Owner Principal Name"] = $NewData }  

            # Yammer Data
            ForEach ($Y in $YammerUsage) {  
            If ([string]::IsNullOrEmpty($Y."Last Activity Date")) { 
                $YammerLastActivity = "No activity" 
                $YammerDaysSinceActive = "N/A" }
            Else {
                $YammerLastActivity = Get-Date($Y."Last Activity Date") -format "dd-MMM-yyyy" 
                $YammerDaysSinceActive = (New-TimeSpan ($YammerLastActivity)).Days }
            $ReportLine  = [PSCustomObject] @{          
                YUPN             = $Y."User Principal Name"
                YDisplayName     = $Y."Display Name"
                YLastActive      = $YammerLastActivity      
                YDaysSinceActive = $YammerDaysSinceActive   
                YPostedCount     = [int]$Y."Posted Count"
                YReadCount       = [int]$Y."Read Count"
                YLikedCount      = [int]$Y."Liked Count"
                YRecordType      = "Yammer Usage"}
            [Array]$ExistingData = $DataTable[$Y."User Principal Name"] 
            [Array]$NewData = $ExistingData + $ReportLine
            $DataTable[$Y."User Principal Name"] = $NewData }


            # Create set of users that we've collected data for - each of these users will be in the $DataTable with some information.
            [System.Collections.ArrayList]$Users = @()
            ForEach ($UserPrincipalName in $DataTable.Keys) { 
            If ($DataTable[$UserPrincipalName]) { #Info exists in datatable
            $obj = [PSCustomObject]@{ 
                UPN  = $UserPrincipalName}
            $Users.add($obj) | Out-Null }
            }
            $StartTime3 = Get-Date
            # Set up progress bar
            $ProgressDelta =aaaata
            [string]$ExoUPN = (Out-String -InputObject $UserData.ExoUPN).Trim()
            [string]$ExoLastActive = (Out-String -InputObject $UserData.ExoLastActive).Trim()
            If ([string]::IsNullOrEmpty($ExoUPN) -or $ExoLastActive -eq "No Activity") {
                $ExoDaysSinceActive  = "N/A"
                $EXoLastActive = "No Activity" }
            Else {
                [string]$ExoLastActive = (Out-String -InputObject $UserData.ExoLastActive).Trim()
                [string]$ExoDaysSinceActive = (Out-String -InputObject $UserData.ExoDaysSinceActive).Trim() }
            
            # Parse OneDrive for Business usage data 
            [string]$ODUPN = (Out-String -InputObject $UserData.ODUPN).Trim()
            [string]$ODLastActive = (Out-String -InputObject $UserData.ODLastActive).Trim()  # Possibility of a second OneDrive account for some users.
            If (($ODLastActive -Like "*No Activity*") -or ([string]::IsNullOrEmpty($ODLastActive))) {$ODLastActive = "No Activity"} # this is a hack until I figure out a better way to handle the situation
            If ([string]::IsNullOrEmpty($ODUPN)-eq $Null -or $ODLastActive -eq "No Activity") {
                [string]$ODDaysSinceActive  = "N/A"
                [string]$ODLastActive = "No Activity"
                $ODFiles            = 0
                $ODStorage          = 0
                $ODQuota            = 1024 }
            Else {
                [string]$ODDaysSinceActive = (Out-String -InputObject $UserData.ODDaysSinceActive).Trim()
                [string]$ODLastActive = (Out-String -InputObject $UserData.ODLastActive).Trim()
                [string]$ODFiles = (Out-String -InputObject $UserData.ODFileCount).Trim()
                [string]$ODStorage = (Out-String -InputObject $UserData.ODStorageUsed).Trim()
                [string]$ODQuota = (Out-String -InputObject $UserData.ODQuota).Trim()  }

            # Parse Yammer usage data; Yammer isn't used everywhere, so make sure that we record zero data 
            [string]$YUPN = (Out-String -InputObject $UserData.YUPN).Trim()
            [string]$YammerLastActive = (Out-String -InputObject $UserData.YLastActive).Trim()
            If (([string]::IsNullOrEmpty($YUPN) -or ($YammerLastActive -eq "No Activity"))) { 
                $YammerLastActive = "No Activity"  
                $YammerDaysSinceActive  = "N/A" 
                $YammerPosts             = 0
                $YammerReads             = 0
                $YammerLikes             = 0 }
            Else {
                [string]$YammerDaysSinceActive = (Out-String -InputObject $UserData.YDaysSinceActive).Trim()
                [string]$YammerPosts = (Out-String -InputObject $UserData.YPostedCount).Trim()
                [string]$YammerReads = (Out-String -InputObject $UserData.YReadCount).Trim()
                [string]$YammerLikes = (Out-String -InputObject $UserData.YLikedCount).Trim() }
            
            If ($UserData.TeamsDaysSinceActive -gt 0) {
                [string]$TeamsDaysSinceActive = (Out-String -InputObject $UserData.TeamsDaysSinceActive).Trim()
                [string]$TeamsLastActive = (Out-String -InputObject $UserData.TeamsLastActive).Trim() }
            Else { 
                [string]$TeamsDaysSinceActive = "N/A"
                [string]$TeamsLastActive = "No Activity" }
            
            If ($UserData.SPODaysSinceActive -gt 0) {
                [string]$SPODaysSinceActive = (Out-String -InputObject $UserData.SPODaysSinceActive).Trim()
                [string]$SPOLastActive = (Out-String -InputObject $UserData.SPOLastActive).Trim() }
            Else { 
                [string]$SPODaysSinceActive = "N/A"
                [string]$SPOLastActive = "No Activity" }
            
            # Fetch the sign in data if available
            $LastAccountSignIn = $Null; $DaysSinceSignIn = 0
            $LastAccountSignIn = $UserSignIns.Item($U)
            If ($LastAccountSignIn -eq $Null) { $LastAccountSignIn = "No sign in data found"; $DaysSinceSignIn = "N/A"}
            Else { $DaysSinceSignIn = (New-TimeSpan($LastAccountSignIn)).Days }
            
            # Figure out if the account is used
            [int]$ExoDays = 365; [int]$TeamsDays = 365; [int]$SPODays = 365; [int]$ODDays = 365; [int]$YammerDays = 365

            # Base is 2 if someuse uses the five workloads because the Graph is usually 2 days behind, but we have some N/A values for days used
            If ($ExoDaysSinceActive -ne "N/A") {$ExoDays = $ExoDaysSinceActive -as [int]}
            If ($TeamsDaysSinceActive -eq "N/A") {$TeamsDays = 365} Else {$TeamsDays = $TeamsDaysSinceActive -as [int]}
            If ($SPODaysSinceActive -eq "N/A") {$SPODays = 365} Else {$SPODays = $SPODaysSinceActive -as [int]}  
            If ($ODDaysSinceActive -eq "N/A") {$ODDays = 365} Else {$ODDays = $ODDaysSinceActive -as [int]} 
            If ($YammerDaysSinceActive -eq "N/A") {$YammerDays = 365} Else {$YammerDays = $YammerDaysSinceActive -as [int]}
            
            # Average days per workload used...
            $AverageDaysSinceUse = [Math]::Round((($ExoDays + $TeamsDays + $SPODays + $ODDays + $YammerDays)/5),2)

            Switch ($AverageDaysSinceUse) { # Figure out if account is used
            ({$PSItem -le 8})                          { $AccountStatus = "Heavy usage" }
            ({$PSItem -ge 9 -and $PSItem -le 50} )     { $AccountStatus = "Moderate usage" }   
            ({$PSItem -ge 51 -and $PSItem -le 120} )   { $AccountStatus = "Poor usage" }
            ({$PSItem -ge 121 -and $PSItem -le 300 } ) { $AccountStatus = "Review account"  }
            default                                    { $AccountStatus = "Account unused" }
            } # End Switch

            # And an override if someone has been active in just one workload in the last 14 days
            [int]$DaysCheck = 14 # Set this to your chosen value if you want to use a different period.
            If (($ExoDays -le $DaysCheck) -or ($TeamsDays -le $DaysCheck) -or ($SPODays -le $DaysCheck) -or ($ODDays -le $DaysCheck) -or ($YammerDays -le $DaysCheck)) {
                $AccountStatus = "Account in use"}

            If ((![string]::IsNullOrEmpty($ExoUPN))) {
            # Build a line for the report file with the collected data for all workloads and write it to the list
            $OutLine  = [PSCustomObject] @{          
                UPN                     = $U
                DisplayName             = (Out-String -InputObject $UserData.ExoDisplayName).Trim()
                Status                  = $AccountStatus
                LastSignIn              = $LastAccountSignIn
                DaysSinceSignIn         = $DaysSinceSignIn 
                EXOLastActive           = $ExoLastActive  
                EXODaysSinceActive      = $ExoDaysSinceActive  
                EXOQuotaUsed            = (Out-String -InputObject $UserData.MbxQuotaUsed).Trim()
                EXOItems                = (Out-String -InputObject $UserData.MbxItems).Trim()
                EXOSendCount            = (Out-String -InputObject $UserData.ExoSendCount).Trim()
                EXOReadCount            = (Out-String -InputObject $UserData.ExoReadCount).Trim()
                EXOReceiveCount         = (Out-String -InputObject $UserData.ExoReceiveCount).Trim()
                TeamsLastActive         = $TeamsLastActive
                TeamsDaysSinceActive    = $TeamsDays 
                TeamsChannelChat        = (Out-String -InputObject $UserData.TeamsChannelChats).Trim()
                TeamsPrivateChat        = (Out-String -InputObject $UserData.TeamsPrivateChats).Trim()
                TeamsMeetings           = (Out-String -InputObject $UserData.TeamsMeetings).Trim()
                TeamsCalls              = (Out-String -InputObject $UserData.TeamsCalls).Trim()
                SPOLastActive           = $SPOLastActive
                SPODaysSinceActive      = $SPODays 
                SPOViewedEditedFiles    = (Out-String -InputObject $UserData.SPOViewedEdited).Trim()
                SPOSyncedFiles          = (Out-String -InputObject $UserData.SPOSyncedFileCount).Trim()
                SPOSharedExtFiles       = (Out-String -InputObject $UserData.SPOSharedExt).Trim()
                SPOSharedIntFiles       = (Out-String -InputObject $UserData.SPOSharedInt).Trim()
                SPOVisitedPages         = (Out-String -InputObject $UserData.SPOVisitedPages).Trim()
                OneDriveLastActive      = $ODLastActive
                OneDriveDaysSinceActive = $ODDaysSinceActive
                OneDriveFiles           = $ODFiles
                OneDriveStorage         = $ODStorage
                OneDriveQuota           = $ODQuota
                YammerLastActive        = $YammerLastActive  
                YammerDaysSinceActive   = $YammerDaysSinceActive
                YammerPosts             = $YammerPosts
                YammerReads             = $YammerReads
                YammerLikes             = $YammerLikes
                License                 = (Out-String -InputObject $UserData.TeamsLicense).Trim()
                OneDriveSite            = (Out-String -InputObject $UserData.ODSite).Trim()
                IsDeleted               = (Out-String -InputObject $UserData.ExoIsDeleted).Trim()
                EXOReportDate           = (Out-String -InputObject $UserData.ExoReportDate).Trim()
                TeamsReportDate         = (Out-String -InputObject $UserData.TeamsReportDate).Trim()
                UsageFigure             = $AverageDaysSinceUse }
            $OutData.Add($OutLine)   } 
            } #End processing user data


            $StartTime4 = Get-Date
            $GraphTime = $StartTime2 - $StartTime1
            $PrepTime = $StartTime3 - $StartTime2
            $ReportTime = $StartTime4 - $StartTime3
            $ScriptTime = $StartTime4 - $StartTime1
            $AccountsPerMinute = [math]::Round(($Outdata.count/($ScriptTime.TotalSeconds/60)),2)
            $GraphElapsed = $GraphTime.Minutes.ToString() + ":" + $GraphTime.Seconds.ToString()
            $PrepElapsed = $PrepTime.Minutes.ToString() + ":" + $PrepTime.Seconds.ToString()
            $ReportElapsed = $ReportTime.Minutes.ToString() + ":" + $ReportTime.Seconds.ToString()
            $ScriptElapsed = $ScriptTime.Minutes.ToString() + ":" + $ScriptTime.Seconds.ToString()

            foreach ($sql_report in $outdata){
                Import_SQL_report $appidreturn.tenant_id $sql_report.UPN $sql_report.DisplayName $sql_report.Status $sql_report.LastSignIn $sql_report.DaysSinceSignIn $sql_report.EXOLastActive $sql_report.EXODaysSinceActive $sql_report.EXOQuotaUsed $sql_report.EXOItems $sql_report.EXOSendCount $sql_report.EXOReadCount $sql_report.EXOReceiveCount $sql_report.TeamsLastActive $sql_report.TeamsDaysSinceActive $sql_report.TeamsChannelChat $sql_report.TeamsPrivateChat $sql_report.TeamsMeetings $sql_report.TeamsCalls $sql_report.SPOLastActive $sql_report.SPODaysSinceActive $sql_report.SPOViewedEditedFiles $sql_report.SPOSyncedFiles $sql_report.SPOSharedExtFiles $sql_report.SPOSharedIntFiles $sql_report.SPOVisitedPages $sql_report.OneDriveLastActive $sql_report.OneDriveDaysSinceActive $sql_report.OneDriveFiles $sql_report.OneDriveStorage $sql_report.OneDriveQuota $sql_report.YammerLastActive $sql_report.YammerDaysSinceActive $sql_report.YammerPosts $sql_report.YammerReads $sql_report.YammerLikes $sql_report.License $sql_report.OneDriveSite $sql_report.IsDeleted $sql_report.EXOReportDate $sql_report.TeamsReportDate $sql_report.UsageFigure
            }


        }else{
        Write-Host 'App not created'
        }   



<#
$certname = "PowerBiCertificate"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\localmachine\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
Export-Certificate -Cert $cert -FilePath "C:\temp\$certname.cer"

#>

# Populate with the App Registration details and Tenant ID
