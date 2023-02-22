Import-Module SQLServer


$params = @{'server'='vascentsqldev';'Database'='****';'username'='csv.service';'password'='***'}
$InsertResults = @"

BEGIN
Drop table TsunamiCounterfeitPart
END;
BEGIN

Create View TsunamiCounterfeitPart as
SELECT p.Oid as PartID, p.ManufacturerPartNumber, cp.oid as CounterfeitID, cp.datediscovered, cp.DateCode, cp.LotCode, cp.notes, cp.ReportedtoERAI, ReportedToUKEA, cp.NotifiedGidep, cp.FileAttachment, cp.CreatedDate
FROM [AscentReloaded].[dbo].[Part] p Join [AscentReloaded].[dbo].[CounterfeitPart] cp
on p.oid = cp.Part;

END;
BEGIN
Select * FROM TsunamiCounterfeitPart
END;

    
"@      

Invoke-sqlcmd @params -Query $InsertResults | export-csv C:\results\sqltest.csv


Import-Module Posh-SSH

Write-host "Starting SFTP process"
$ComputerName = "Test.***.com"
$UserName = "***"
$KeyFile = "C:\Results\***.pem"
$nopasswd = new-object System.Security.SecureString
$Credential = New-Object System.Management.Automation.PSCredential ($UserName, $nopasswd)
$LocalPath = "C:\results\"
$SftpPath = 'results/'
$SFTPSession = New-SFTPSession -ComputerName $ComputerName -Credential $Credential -KeyFile $KeyFile


$FilePath "C:\results\sqltest.csv"
$SftpPath "/***"

Set-SFTPFile -SessionId ($SFTPSession).SessionId -Localfile $FilePath -RemotePath $SftpPath

Get-SFTPSession | % { Remove-SFTPSession -SessionId ($_.SessionId) }

