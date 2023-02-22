$params = @{'server'='****.database.windows.net';'Database'='clientchecks';'username'='dataquest.admin';'password'='****'}

#Fucntion to manipulate the data
Import-Module ActiveDirectory
Import-Module SQLServer



Function servercheck
{
param($Domain,$MACHINENAME)

$InsertResults = @"
    DECLARE @domain as VARCHAR(255)
        SET @domain = '$domain'

    DECLARE @devicename as VARCHAR(255)
        SET @devicename = '$machinename'

    INSERT INTO [DEVICE_INDEX] (COMPANYID,MACHINENAME)
    VALUES ((SELECT COMPANYID FROM MAIN_INDEX WHERE MAIN_INDEX.COMPANYDOMAIN = @domain),'$machinename')
"@      

Invoke-sqlcmd @params -Query $InsertResults

}


Function diskinput
{
param($sqlmachine_id,$sqlmachine_disk,$sqlmachine_disksize,$sqlmachine_diskfree)

$InsertResults2 = @"
    DECLARE @domain as VARCHAR(255)
        SET @domain = '$domain'

    DECLARE @devicenameid as VARCHAR(255)
        SET @devicenameid = '$sqlmachine_id'

    DECLARE @diskletter as varchar(255)  
        SET @diskletter = '$sqlmachine_disk'  

        
    INSERT INTO [dbo].[DISK_CHECKs] (MACHINEID,DATECHECK,DISKLETTER,DISKTOTALSIZE,DISKFREESIZE)
    VALUES (
        (SELECT MACHINEID FROM DEVICE_INDEX WHERE DEVICE_INDEX.MACHINENAME = @devicenameid),
        (SELECT CAST( GETDATE() AS Date )),
        @diskletter,
        $sqlmachine_disksize,
        $sqlmachine_diskfree
        )
"@      

Invoke-sqlcmd @params -Query $InsertResults2

}



########################################################################################
# Pre-Checks for input the data 

$serverquery = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties OperatingSystem -ErrorAction SilentlyContinue | select Name
$getdomainquery = Get-ADDomain | Select-Object name
$deviceindexquery =  Invoke-Sqlcmd @params -Query "SELECT * FROM [clientchecks].[dbo].[DEVICE_INDEX]"
$domainindex =  Invoke-Sqlcmd @params -Query "SELECT * FROM [clientchecks].[dbo].[MAIN_INDEX]"
$getdomainquery = Get-ADDomain | Select-Object name


########################################################################################
# Function checks
function DomainID {
    foreach ($queryid in $domainindex) {
        if ($queryid.companyname -eq $getdomainquery.name) {
            return $queryid.companyid
        }
    }
}
function MachineID {
    param($deviceidinput)
    foreach ($querymachineid in $deviceindexquery) {
        if ($querymachineid.machinename -eq $deviceidinput) {
            return $querymachineid.machineid
        }
    }
}

function DEVICEQUERY {
    Param($devicename)
    if ((($deviceindexquery.MACHINENAME).contains($devicename)) -and (DomainID)) {
        return 1
    }else{
        return 0
    }
}

function DEVICEQUERY2 {
    Param($devicename)
    foreach ($main_indexdevice in $deviceindexquery){
        if (($main_indexdevice.machinename -eq $devicename) -and ($main_indexdevice.companyid -eq (DomainID))){
            return 1
        }elseif (!(($main_indexdevice.machinename -eq $devicename) -and ($main_indexdevice.companyid -eq (DomainID)))) {
            
        }
    }

}


function drivequery {
    param ($machinelookup)
    Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $machinelookup -ErrorAction SilentlyContinue | 
    Select-Object SystemName,DeviceID,VolumeName,
    @{Name="size";Expression={"{0:N1}" -f($_.size/1gb)}},
    @{Name="freespace";Expression={"{0:N1}" -f($_.freespace/1gb)}}
}

####################################################################################################
# Inputing data with functions



foreach ($device in $serverquery){
    #drivechecking
    if ((DEVICEQUERY2 $device.name) -eq 1){
        $diskentries = drivequery $device.Name
        $query_machineid = MachineID $device.name
        foreach ($disk in $diskentries){                     
            diskinput $device.name $disk.deviceid $disk.size $disk.freespace
        }

    }else{
        servercheck $getdomainquery.name $device.name
        $diskentries = drivequery $device.Name
        $query_machineid = MachineID $device.name
        foreach ($disk in $diskentries){
            diskinput $query_machineid $disk.deviceid $disk.size $disk.freespace
        }
    }
    #run SQL Command
    # 
}
