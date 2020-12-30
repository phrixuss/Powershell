if(!(get-module -ListAvailable -name SQLServer)){
    
    Install-Module SQLserver -force

}


$params = @{'server'='****.database.windows.net';'Database'='Dataquest-azure-sql';'username'='****';'password'=''}
 
#Fucntion to manipulate the data
Import-Module ActiveDirectory
Import-Module SQLServer



Function ActiveUsers
{
param($sqldomaincheck,$displayname,$username,$logonname)

$InsertResults = @"

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND TABLE_NAME = '$sqldomaincheck'))
BEGIN


    DECLARE @logonname varchar(128)
    SET @logonname = '$logonname'

    if exists (select * from $sqldomaincheck where logonName = @logonname )
    Begin
        
        UPDATE $sqldomaincheck
        SET 
        DisplayName = '$displayname',
        Username = '$username'
        WHERE LogonName = @logonname;

    End;
    ELSE
    BEGIN
    INSERT INTO [dataquestreporting].[dbo].[$sqldomaincheck](DisplayName,Username,LogonName)
    VALUES ('$displayname','$username','$logonname')
    END;




END;
else
BEGIN

    CREATE TABLE $sqldomaincheck (

        DisplayName varchar(255),
        Username varchar(320),
        LogonName varchar(255) NOT NULL,
        Primary Key (LogonName),

    );

    INSERT INTO [dataquestreporting].[dbo].[$sqldomaincheck](DisplayName,Username,LogonName)
    VALUES ('$displayname','$username','$logonname')

end;

    


"@      

Invoke-sqlcmd @params -Query $InsertResults

}
$prefixes = Invoke-Sqlcmd @params -Query "SELECT * FROM [dataquestreporting].[dbo].[prefixes]"
#$prefixes = "test","admin","backup","user","exchange","microsoft","Management","support","Helpdesk","Invoices","netwrix","mimecast","TV","room","Maintenance","info","Calendar","Meters","Manager","sql","WDS","vwvcs","account","accounts","Dataquest","Audit","Comms","Concept","Epay","CBS","Calendar","server"
$regex = "^($($prefixes.prefixes -Join "|"))\d*"

$userquery = Get-ADUser -Filter {Enabled -eq $TRUE} -Properties * | Where {($_.LastLogonDate -lt (Get-Date).AddDays(-30)) -and ($_.DisplayName -notmatch $regex) -and ($_.userprincipalname -notmatch $regex)} | select samaccountname
echo $userquery
$getdomainquery = Get-ADDomain | select name
$getdomaincheckafter = $getdomainquery.name


foreach ($item in $userquery){
#echo $item
$userinfo = $item.samaccountname
$userresult = Get-ADUser -Identity "$userinfo"

ActiveUsers $getdomainquery.name $userresult.Name $userresult.userprincipalname $userresult.SamAccountName
}

#Invoke-Sqlcmd @params -Query "SELECT * FROM 'Dataquest'" | format-table -AutoSize


function Set-MfaState {

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $ObjectId,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $UserPrincipalName,
        [ValidateSet("Disabled","Enabled","Enforced")]
        $State
    )

    Process {   
        Write-Verbose ("Setting MFA state for user '{0}' to '{1}'." -f $ObjectId, $State)
        $Requirements = @()
        if ($State -ne "Disabled") {
            $Requirement =
                [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
            $Requirement.RelyingParty = "*"
            $Requirement.State = $State
            $Requirements += $Requirement
        }

        Set-MsolUser -ObjectId $ObjectId -UserPrincipalName $UserPrincipalName `
                     -StrongAuthenticationRequirements $Requirements
    }
}

Get-MsolUser -All | where {$_.isLicensed -eq $true} | Set-MfaState -State Enabled