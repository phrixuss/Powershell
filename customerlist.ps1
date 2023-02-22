$SqlServer    = 'CS-IT-BI' # SQL Server instance (HostName\InstanceName for named instance)
$Database     = 'Master'      # SQL database to connect to 
$SqlAuthLogin = 'dataquest\christopher.goes'            # SQL Authentication login
$SqlAuthPw    = '***'     # SQL Authentication login password
# query to show changes
$Query = '
SELECT @@SERVERNAME AS [ServerName]
    , des.login_name
    , DB_NAME()   AS [DatabaseName]
    , dec.net_packet_size
    , @@LANGUAGE  AS [Language]
    , des.program_name
    , des.host_name
FROM sys.dm_exec_connections dec
JOIN sys.dm_exec_sessions des ON dec.session_id = des.session_id
WHERE dec.session_id = @@SPID
'

$customerlist = Import-csv C:\users\christopher.goes\Downloads\customerlist.csv
foreach($list in $customerlist){
$b = $list.Domain
$c = $list.Name
$d = $list.RelationshipToPartner

$InsertResults = @"
BEGIN


    INSERT INTO [master].[dbo].[CustomerList](Domain,name,Relationship)
    VALUES ('$b','$c','$d')

end;
"@     

Invoke-Sqlcmd  -ConnectionString "Data Source=$SqlServer;Initial Catalog=$Database; Integrated Security=True;" -Query "$InsertResults"



}

 