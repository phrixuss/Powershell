$params = @{'server'='***.database.windows.net';'Database'='Dataquest-azure-sql';'username'='***';'password'=''}
 
#Fucntion to manipulate the data
Import-Module SQLServer



Function ActiveUsers
{
param($CompanyID,$UserPrincipalname,$DisplayName,$LastLogonTime,$CreationTime,$InactiveDays,$MailboxType,$AssignedLicenses,$roles)

$InsertResults = @"

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND TABLE_NAME = 'UserReport'))
BEGIN



    INSERT INTO [Dataquest-azure-sql].[dbo].[UserReport](CompanyID,UserPrincipalName,DisplayName,LastLogonTime,CreationTime,InactiveDays,MailboxType,AssignedLicenses,Roles)
    VALUES ('$CompanyID','$UserPrincipalname','$DisplayName','$LastLogonTime','$CreationTime','$InactiveDays','$MailboxType','$AssignedLicenses','$roles')




END;
else
BEGIN

    CREATE TABLE "UserReport" (

        UserID int identity(1,1) NOT NULL,
        CompanyID int NOT NULL,
        UserPrincipalName varchar(255) NOT NULL,
        DisplayName varchar(255) NOT NULL,
        LastLogonTime DATETIME NOT NULL,
        CreationTime DATETIME NOT NULL,
        InactiveDays int,
        MailboxType varchar(255),
        AssignedLicenses varchar(255),
        Roles varchar(255)


        CONSTRAINT PK_user PRIMARY KEY (UserID,UserPrincipalName)

    );

    INSERT INTO [Dataquest-azure-sql].[dbo].[UserReport](CompanyID,UserPrincipalName,DisplayName,LastLogonTime,CreationTime,InactiveDays,MailboxType,AssignedLicenses,Roles)
    VALUES ('$CompanyID','$UserPrincipalname','$DisplayName','$LastLogonTime','$CreationTime','$InactiveDays','$MailboxType','$AssignedLicenses','$roles')

end;

    


"@      

Invoke-sqlcmd @params -Query $InsertResults

}

function Userreportextractiono365 {
    param (
        $usernameo365,$passwordo365,$companyidcheck
    )

$username = $usernameo365
$password = ConvertTo-SecureString $passwordo365 -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
#Connect-MSolService -Credential $psCred

#$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $psCred -Authentication Basic -AllowRedirection
Set-ExecutionPolicy RemoteSigned
Connect-MSolService -Credential $psCred
Import-PSSession $Session

$Result=""
$Output=@()
$MBUserCount=0
$OutputCount=0
$FriendlyNameHash=Get-Content -Raw -Path "C:\Users\cgoes\OneDrive - Dataquest UK\Documents\LicenseFriendlyName.txt" -ErrorAction Stop | ConvertFrom-StringData

    Get-Mailbox -ResultSize Unlimited | Where-Object {$_.DisplayName -notlike "Discovery Search Mailbox"} | ForEach-Object {
    $upn=$_.UserPrincipalName
    $CreationTime=$_.WhenCreated
    $LastLogonTime=(Get-MailboxStatistics -Identity $upn).lastlogontime
    $DisplayName=$_.DisplayName
    $MBType=$_.RecipientTypeDetails
    $Print=1
    $MBUserCount++
    $RolesAssigned=""
    Write-Progress -Activity "`n     Processed mailbox count: $MBUserCount "`n"  Currently Processing: $DisplayName"

    #Retrieve lastlogon time and then calculate Inactive days
    if($LastLogonTime -eq $null)
    {
    $LastLogonTime ="Never Logged In"
    $InactiveDaysOfUser="-"
    }
    else
    {
    $InactiveDaysOfUser= (New-TimeSpan -Start $LastLogonTime).Days
    }

    #Get licenses assigned to mailboxes
    $User=(Get-MsolUser -UserPrincipalName $upn)
    $Licenses=$User.Licenses.AccountSkuId
    $AssignedLicense=""
    $Count=0

    #Convert license plan to friendly name
    foreach($License in $Licenses)
    {
        $Count++
        $LicenseItem= $License -Split ":" | Select-Object -Last 1
        $EasyName=$FriendlyNameHash[$LicenseItem]
        if(!($EasyName))
        {$NamePrint=$LicenseItem}
        else
        {$NamePrint=$EasyName}
        $AssignedLicense=$AssignedLicense+$NamePrint
        if($count -lt $licenses.count)
        {
        $AssignedLicense=$AssignedLicense+","
        }
    }
    if($Licenses.count -eq 0)
    {
    $AssignedLicense="No License Assigned"
    }

    #Inactive days based filter
    if($InactiveDaysOfUser -ne "-"){
    if(($InactiveDays -ne "") -and ([int]$InactiveDays -gt $InactiveDaysOfUser))
    {
    $Print=0
    }}

    #License assigned based filter
    if(($UserMailboxOnly.IsPresent) -and ($MBType -ne "UserMailbox"))
    {
    $Print=0
    }

    #Never Logged In user
    if(($ReturnNeverLoggedInMB.IsPresent) -and ($LastLogonTime -ne "Never Logged In"))
    {
    $Print=0
    }

    #Get roles assigned to user
    $Roles=(Get-MsolUserRole -UserPrincipalName $upn).Name
    if($Roles.count -eq 0)
    {
    $RolesAssigned="No roles"
    }
    else
    {
    foreach($Role in $Roles)
    {
    $RolesAssigned=$RolesAssigned+$Role
    if($Roles.indexof($role) -lt (($Roles.count)-1))
    {
        $RolesAssigned=$RolesAssigned+","
    }
    }
    }



    #Export result to CSV file
    if($Print -eq 1)
    {
    $OutputCount++
    $Result=@{'UserPrincipalName'=$upn;'DisplayName'=$DisplayName;'LastLogonTime'=$LastLogonTime;'CreationTime'=$CreationTime;'InactiveDays'=$InactiveDaysOfUser;'MailboxType'=$MBType; 'AssignedLicenses'=$AssignedLicense;'Roles'=$RolesAssigned}
    $Output= New-Object PSObject -Property $Result
    $Output | Select-Object UserPrincipalName,DisplayName,LastLogonTime,CreationTime,InactiveDays,MailboxType,AssignedLicenses,Roles #| Export-Csv -Path $ExportCSV -Notype -Append
    }

    foreach ($userforeach in $output){

        ActiveUsers $companyidcheck $userforeach.UserPrincipalName $userforeach.DisplayName $userforeach.lastlogontime $userforeach.creationtime $userforeach.InactiveDays $userforeach.MailboxType $userforeach.AssignedLicenses $userforeach.roles

    }
    }
}

Invoke-Sqlcmd @params -Query "DROP TABLE [Dataquest-azure-sql].[dbo].[UserReport]"


Userreportextractiono365 "dataquest.admin@thestorymakers.onmicrosoft.com" "Team()(work17" "40"

Get-PSSession | ForEach-Object {Remove-PSSession $_.Id}

start-sleep 10

Userreportextractiono365 "dataquest.admin@" ""

#>






