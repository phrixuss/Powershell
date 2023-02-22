if(!(get-module -ListAvailable -name SQLServer)){
    
    Install-Module SQLserver -force

}


$params = @{'server'='***.database.windows.net';'Database'='Dataquest-azure-sql';'username'='dataquest.admin';'password'=''}
 
#Fucntion to manipulate the data
Import-Module SQLServer



Function ActiveUsers
{
param($name,$domain)

$InsertResults = @"

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'dbo' 
                 AND TABLE_NAME = 'Companies'))
BEGIN


    DECLARE @declarocompanyname varchar(255)
    SET @declarocompanyname = '$name'

    
    DECLARE @declarecompanydomain varchar(255)
    SET @declarecompanydomain = '$domain'



    INSERT INTO [Dataquest-azure-sql].[dbo].[Companies](CompanyName,CompanyDomain)
    VALUES (@declarocompanyname,@declarecompanydomain)




END;
else
BEGIN

    CREATE TABLE "Companies" (

        CompanyID int IDENTITY(1,1),
        CompanyName varchar(255) NOT NULL,
        CompanyDomain varchar(255) NOT NULL,

        CONSTRAINT PK_Company PRIMARY KEY (CompanyDomain,CompanyID)

    );

    INSERT INTO [Dataquest-azure-sql].[dbo].[Companies](CompanyName,CompanyDomain)
    VALUES ('$name','$domain')

end;

    


"@      

Invoke-sqlcmd @params -Query $InsertResults

}

$comapnies = Import-Csv C:\users\cgoes\Downloads\Customers.csv
foreach ($comapny in $comapnies){
#echo $item

ActiveUsers $comapny.name $comapny.domain
}

#Invoke-Sqlcmd @params -Query "SELECT * FROM 'Dataquest'" | format-table -AutoSize



