
Import-Module ActiveDirectory 


<#
.SYNOPSIS
Courtauld Students Accounts Creation

.DESCRIPTION
This script will generate users account created by Christopher Goes and Abdul Bashet
Script will work together with SITS when account is generated sent over to a file location and pull the information here and import the user data
The script will be part of 3 phases:
1. Gathering the information from the CSV generate from Sits
2. Checking the user details and assigning the attributes
    2a. Full Name
    2b. First Name
    2c. Last Name
    2d. Student Identification
    2e. Program name


idnumber
c_idnumber
firstname
lastname
fullname
programme
year

.PARAMETER String
This script is base only in the File location provided by Abdul Bashet the rest is automatically

.PARAMETER SpecialCharacterToKeep
Parameter description

.EXAMPLE
User Christopher Goes
Script will look for Firstname: Christopher and LastName: Goes, if doesnt exist it will create, If exists it will ignore and proceed with cloud group assignment

.NOTES
Creator: Christopher Goes
#>

function Remove-StringSpecialCharacter {

    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String[]]$String,

        [Alias("Keep")]
        #[ValidateNotNullOrEmpty()]
        [String[]]$SpecialCharacterToKeep
    )
    PROCESS {
        try {
            IF ($PSBoundParameters["SpecialCharacterToKeep"]) {
                $Regex = "[^\p{L}\p{Nd}"
                Foreach ($Character in $SpecialCharacterToKeep) {
                    IF ($Character -eq "-") {
                        $Regex += "-"
                    }
                    else {
                        $Regex += [Regex]::Escape($Character)
                    }
                    #$Regex += "/$character"
                }

                $Regex += "]+"
            } #IF($PSBoundParameters["SpecialCharacterToKeep"])
            ELSE { $Regex = "[^\p{L}\p{Nd}]+" }

            FOREACH ($Str in $string) {
                Write-Verbose -Message "Original String: $Str"
                $Str -replace $regex, ""
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    } #PROCESS
}

function get-Userlookup {
    param ($idname)

    Try
    {
    Get-ADUser $idname -ErrorAction Stop
        return 1
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
    { 
        return 0
    }
}

function SecuritygroupAssignment {
    param (
        $username,$programnamem
    )
    
    if($programnamem -eq "BAHA"){
        Add-ADGroupMember -Identity "#Students-BA-2021" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=BA,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to BA Year 1 History of Art"
    }elseif ($programnamem -eq "PMACU") {
        Add-ADGroupMember -Identity "#Students-MA-CU" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MACur,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to MA Curating"
    }elseif ($programnamem -eq "PMAHA") {
        Add-ADGroupMember -Identity "#Students-MA-HA" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MAHist,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to MA History of Art"
    }elseif ($programnamem -eq "CGDHA") {
        Add-ADGroupMember -Identity "#Students-CGDIP-HA" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=CGDipHA,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to CGDIP History of Art"
    }elseif ($programnamem -eq "PGDCP") {
        Add-ADGroupMember -Identity "#Students-PGDIP-CE" -Members $username
        Add-ADGroupMember -Identity "StuEasels" -Members $username
        Add-ADGroupMember -Identity "Conservation" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=PGDipEasels,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to Post Graduate Diploma Conservation of Easels"
    }elseif ($programnamem -eq "PMABC") {
        Add-ADGroupMember -Identity "#Students-MA-BU" -Members $username
        Add-ADGroupMember -Identity "StuBUMA" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MABU,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to MA in Buddhist Art History and Conservation"
    }elseif ($programnamem -eq "PMACN") {
        Add-ADGroupMember -Identity "#Students-MA-WA" -Members $username
        Add-ADGroupMember -Identity "StuWalls" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MAWalls,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to MA in Buddhist Art History and Conservation"
    }elseif (($programnamem -eq "UJTA") -or ($programnamem -eq "UJYA")) {
        Add-ADGroupMember -Identity "#Students-Abroad" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MAWalls,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to MA in Buddhist Art History and Conservation"
    }elseif (($programnamem -eq "RES") -or ($programnamem -eq "RESWP")) {
        Add-ADGroupMember -Identity "#Students-Research" -Members $username
        Add-ADGroupMember -Identity "Research" -Members $username
        Add-ADGroupMember -Identity "All Students" -Members $username
        Add-ADGroupMember -Identity "#Students-New" -Members $username
        Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=PG RESEARCH,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
        return "Added to Research in History of Art"
    }else {
        return "No Action Taken"
    }
}


function Find-Container
{
  $R = $_.distinguishedname.split(',')[3].split('=')[1]
  
  $DNlist = $_.distinguishedname.split(',')
  $OUlist = @()
  ForEach($item in $DNlist){
    $OUlist += $item.split('=')[1]
  }
  
  if($OUlist -contains "MABU"){
    $R = "MABU"
  }
  elseif($OUlist -contains "MAWalls"){
    $R = "MAWalls"
  }
  elseif($OUlist -contains "Intern"){
    $R = "Intern"
  }
  elseif($OUlist -contains "PGDipEasels"){
    $R = "PGDipEasels"
  }
  elseif($OUlist -contains "BA"){
    $R = "BA"
  }
  elseif($OUlist -contains "CGDipHA"){
    $R = "CGDipHA"
  }
  elseif($OUlist -contains "MACur"){
    $R = "MACur"
  }
  elseif($OUlist -contains "MAHist"){
    $R = "MAHist"
  }
  elseif($OUlist -contains "StudyAbroad"){
    $R = "StudyAbroad"
  }
  elseif($OUlist -contains "PG RESEARCH"){
    $R = "PG RESEARCH"
  }
  else{
    $R = ""
  }

  return $R

} 
function Find-Year
{
    param (
        $useryearlookup
    )
    $yearfilterout = Get-ADUser $useryearlookup | Select-Object distinguishedname
  $studentyear = $yearfilterout -replace "[^0-9]" , ''


  return $studentyear
} 



function Outuserprocess {
    param (
        $out_idnumber,
        $out_c_idnumber,
        $out_firstname,
        $out_lastname,
        $out_fullname,
        $out_programme,
        $out_year,
        $out_starting_year,
        $useremailaddress,
        $userstatus,
        $useraction

    )

    $Properties = [ordered]@{
        
        'ID'=$out_idnumber;
        'Username'=$out_c_idnumber;
        'firstname'=$out_firstname;
        'lastname'=$out_lastname;
        'FullName'=$out_fullname;
        'Programme'=$out_programme;
        'Year'=$out_year;
        'Starting_Year'=$out_starting_year;
        'EmailAddress'=$useremailaddress;
        'UserStatus'=$userstatus;
        'UserAction'=$useraction;
        

       
    }
    $global:Results += New-Object -TypeName PSObject -Property $Properties  
    
}

#Get-ADUser C1708147 -Properties * | Select Domain, Displayname, Description, AccountExpires, PasswordLastSet, Lastlogon, AccountIsDisabled, AccountIsLockedOut, PasswordNeverExpires, UserMustChangePassword, AccountIsExpired, PasswordIsExpired, AccountExpirationStatus, UserPrincipalName, @{l='distinguishedname'; e={Find-Year} }

function CurrentUserLookup {
    param (
        $currentusername,$currentprogramname,$currentprogramnameyear,$oldprogramlookup
    )
    #Remove-Variable * -ErrorAction SilentlyContinue
    if($oldprogramlookup -eq "BA"){
        #if($currentprogramnameyear -like "2017"){
            if($currentprogramname -eq "PMACU"){
                Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
                Add-ADGroupMember -Identity "All Students" -Members $currentusername
                Add-ADGroupMember -Identity "#Students-MA-CU" -Members $currentusername
                Get-ADUser -Identity $currentusername | Move-ADObject -TargetPath "OU=20,OU=MACur,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
                Write-Host "Move to MU Curating"
                return "Move to MU Curating"
            }elseif ($currentprogramname -eq "PMAHA") {
                Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
                Add-ADGroupMember -Identity "All Students" -Members $currentusername
                Add-ADGroupMember -Identity "#Students-MA-HA" -Members $currentusername
                Get-ADUser -Identity $currentusername | Move-ADObject -TargetPath "OU=20,OU=MAHist,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
                Write-Host "Move to MA History Of Art"
                return "Move to MA History Of Art"
            }elseif ($currentprogramname -eq "CGDHA") {
                Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
                Add-ADGroupMember -Identity "All Students" -Members $currentusername
                Add-ADGroupMember -Identity "#Students-CGDIP-HA" -Members $currentusername -ErrorAction SilentlyContinue
                Get-ADUser -Identity $currentusername | Move-ADObject -TargetPath "OU=20,OU=CGDipHA,OU=HIST,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
                Write-Host "Move to CGDIP History of Art"
                return "Move to CGDIP History of Art"
            }elseif ($currentprogramname -eq "PGDCP") {
                Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
                Add-ADGroupMember -Identity "All Students" -Members $currentusername
                Add-ADGroupMember -Identity "#Students-PGDIP-CE" -Members $currentusername -ErrorAction SilentlyContinue
                Add-ADGroupMember -Identity "StuEasels" -Members $currentusername -ErrorAction SilentlyContinue
                Add-ADGroupMember -Identity "Conservation" -Members $currentusername -ErrorAction SilentlyContinue
                Get-ADUser -Identity $currentusername | Move-ADObject -TargetPath "OU=20,OU=PGDipEasels,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
                Write-Host "Move to Post Graduate Diploma Conservation of Easels"
                return "Move to Post Graduate Diploma Conservation of Easels"
            }elseif ($currentprogramname -eq "PMABC") {
                Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
                Add-ADGroupMember -Identity "#Students-MA-BU" -Members $currentusername
                Add-ADGroupMember -Identity "StuBUMA" -Members $currentusername
                Add-ADGroupMember -Identity "All Students" -Members $currentusername
                Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MABU,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
                Write-Host "Move to MA in Buddhist Art: History and Conservation"
                return "Move to MA in Buddhist Art: History and Conservation"
            }elseif ($currentprogramname -eq "PMACN") {
                Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
                Add-ADGroupMember -Identity "#Students-MA-WA" -Members $currentusername
                Add-ADGroupMember -Identity "StuWalls" -Members $currentusername
                Add-ADGroupMember -Identity "All Students" -Members $currentusername
                Get-ADUser -Identity $username | Move-ADObject -TargetPath "OU=20,OU=MAWalls,OU=CON,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
                Write-Host "Move to MA Conservation of Wall Painting"
                return "Move to MA Conservation of Wall Painting"
            }else {
                return "No Action Taken"
            }
        
    }elseif ($currentprogramname -eq "RES") {
        if($oldprogramlookup -ne "BA"){
            Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
            Add-ADGroupMember -Identity "All Students" -Members $currentusername
            Add-ADGroupMember -Identity "#Students-Research" -Members $currentusername
            Get-ADUser -Identity $currentusername | Move-ADObject -TargetPath "OU=PG RESEARCH,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
            Write-Host "Moved to Research Student PHD"
            return "Moved to Research Student PHD"
    
        }else {
            return "No Action Taken"
        }

    }elseif ($currentprogramname -eq "RESWP") {
        if($oldprogramlookup -ne "BA"){
            Get-AdPrincipalGroupMembership -Identity $currentusername | Where-Object {($_.name -ne 'Domain Users')} | Remove-AdGroupMember -Members $currentusername -Confirm:$false
            Add-ADGroupMember -Identity "All Students" -Members $currentusername
            Add-ADGroupMember -Identity "#Students-Research" -Members $currentusername
            Get-ADUser -Identity $currentusername | Move-ADObject -TargetPath "OU=PG RESEARCH,OU=Students,OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"
            Write-Host "Moved to Research Student PHD"
            return "Moved to Research Student PHD"
    
        }else {
            return "No Action Taken"
        }
    }else {
        return "No Action Taken"
    }
}

function Useralreadyloogedlookup {
    
    param (
        $usernamecheck
    )
    
    $logfilelookup = Import-Csv "\\AWS-12-AP-01\ad\log\masterlog.csv"
    
    foreach ($row in $logfilelookup){
        if ($row.username -match $usernamecheck){
            return 1
        }
    }

    <#
    if ($logfilelookup.username -contains $usernamecheck){
        return 1
    }else{
        return 0
    }
    #>
}

function secondaryemailcheck {
    param (
        $emailsecondaryproxy
    )
    $emailsecondaryproxycheck = "smtp:" + $emailsecondaryproxy
    if (Get-ADUser -Filter {ProxyAddresses -eq $emailsecondaryproxycheck}){
        return 1
    }
}
Write-Host "loading all ad users"
#$storeadusers = Get-ADUser -SearchBase {"OU=Courtauld Users,DC=institute,DC=courtauld,DC=local"} -fitler * | Select-Object samaccountname,displayname,firstname,lastname,userprincipalname

Write-Host "Importing CSV and assigning individual users"

$loadcsv = "\\AWS-12-AP-01\ad\import\student.csv"

$fileimport = import-csv $loadcsv
$Global:Results = @()
foreach ($user in $fileimport){
 

    Write-Host "Checking user: " $user.FullName
    if((get-Userlookup $user.c_idnumber) -eq 1){
        
        $Userattributeloader1 = Get-ADUser $user.c_idnumber -Properties *

        $nowtime = Get-Date

        if ((Useralreadyloogedlookup $user.c_idnumber) -eq 1){
            Write-Host "user already been processed"
            
        }else{
            

            $useryear = $user.starting_year
            $replaceyear = $useryear.substring(0,4)
            Write-Host "User Exist"
            Set-ADUser $user.c_idnumber -Replace @{extensionattribute1=$user.programme}
            Set-ADUser $user.c_idnumber -Replace @{extensionattribute2=$user.year}
    
            $userprocess = Get-ADUser $user.c_idnumber -Properties * | Select-Object @{l='distinguishedname'; e={Find-Container} }
            $userprocessafter = CurrentUserLookup $user.c_idnumber $user.programme $replaceyear $userprocess.distinguishedname
            
            Outuserprocess $user.idnumber $user.c_idnumber $user.firstname $user.lastname $user.fullname $userprocess.distinguishedname $user.year $replaceyear $Userattributeloader1.mail "Old Student" $userprocessafter  
        }

    }else {


            Write-Host "User Does Not Exist"
            $password = "Summer2020$"
            $useremailnameformat = $user.c_idnumber + "@courtauld.ac.uk"
            $userfullnameformat = $user.lastname + ", " + $user.Firstname

            New-ADUser -SamAccountName $user.c_idnumber -UserPrincipalName $useremailnameformat -Name $user.fullname -DisplayName $userfullnameformat -GivenName $userfullnameformat -Surname $user.lastname -Office "Student" -Description $user.idnumber -accountpassword (ConvertTo-SecureString "$password" -AsPlainText -force) -Enabled $True -PasswordNeverExpires $false -ChangePasswordAtLogon $True -PassThru | Out-Null

            $userprocessnew = SecuritygroupAssignment $user.c_idnumber $user.programme
            $proxyaddress = $user.c_idnumber + "@courtauld.ac.uk"
            $secondaryproxy = $user.firstname + "." + $user.lastname + "@courtauld.ac.uk"



            Set-ADUser $user.c_idnumber -Add @{'ProxyAddresses' = $proxyaddress | ForEach-Object {"SMTP:$_"}}

            if (!((secondaryemailcheck $secondaryproxy) -eq 1)){
                Set-ADUser $user.c_idnumber -Add @{'ProxyAddresses' = $secondaryproxy | ForEach-Object {"smtp:$_"}}
            }else {
                $emailsecondaryfirstletter = ($user.firstname).substring(0,1)
                $emailwithfirstletter = $emailsecondaryfirstletter + $user.lastname + "@courtauld.ac.uk"
                Set-ADUser $user.c_idnumber -Add @{'ProxyAddresses' = $emailsecondaryfirstletter | ForEach-Object {"smtp:$_"}}
            }
            


            Set-ADUser $user.c_idnumber -Add @{'Mail' = $proxyaddress}
            Set-ADUser $user.c_idnumber -Replace @{extensionattribute1=$user.programme}
            Set-ADUser $user.c_idnumber -Replace @{extensionattribute2=$user.year}
            
            $Userattributeloader = Get-ADUser $user.c_idnumber -Properties *
            $oulookup = Get-ADUser $user.c_idnumber -Properties * | Select-Object @{l='distinguishedname'; e={Find-Container} }
            Outuserprocess $user.idnumber $user.c_idnumber $user.firstname $user.lastname $user.fullname $oulookup.distinguishedname $user.year $user.Starting_Year $Userattributeloader.mail "New Account" $userprocessnew
        

    }

}  
$fileexport = "\\AWS-12-AP-01\ad\log\" + "$((Get-Date).ToString("yyyyMMdd_HHmm")).csv"
$jsonfileexport = "\\AWS-12-AP-01\ad\log\" + "$((Get-Date).ToString("yyyyMMdd_HHmm")).json"
$csvfile = "\\AWS-12-AP-01\ad\log\masterlog.csv"
$jsonfile = "\\AWS-12-AP-01\ad\log\masterjson.json"


if ($Global:Results.count -gt 0){
    $Global:Results | Export-Csv -Path $fileexport -NoTypeInformation
    
    foreach ($masterimport in $Global:Results){
    $one=$masterimport.ID
    $two=$masterimport.username
    $three=$masterimport.firstname
    $four=$masterimport.lastname
    $five=$masterimport.fullname
    $six=$masterimport.programme
    $seven=$masterimport.year
    $eight=$masterimport.Starting_Year
    $nine=$masterimport.EmailAddress
    $ten=$masterimport.UserStatus
    $eleven=$masterimport.useraction
    $result2='"'+$one+'"'+","+'"'+$two+'"'+","+'"'+$three+'"'+","+'"'+$four+'"'+","+'"'+$five+'"'+","+'"'+$six+'"'+","+'"'+$seven+'"'+","+'"'+$eight+'"'+","+'"'+$nine+'"'+","+'"'+$ten+'"'+","+'"'+$eleven+'"'
    Add-Content $csvfile -value $result2 -Encoding UTF8 -Force
    }
    Write-Host "Starting ADSync"

    $Global:Results | ConvertTo-Json -Depth 100 | Out-File $jsonfileexport


    Start-ADSyncSyncCycle -PolicyType Initial

    Write-Host "Waiting to sync 5 Minutes..."

    Start-Sleep -Seconds 300

    Write-Host "Initiating O365"

    $username = "****"
    $password = ConvertTo-SecureString "****" -AsPlainText -Force
    $psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
    Connect-MSolService -Credential $psCred

    $Global:Results | ForEach-Object {

        $upntoprocess = $_.username + "@****.ac.uk"
        $UPN=$upntoprocess

        $Users=Get-MsolUser -UserPrincipalName $UPN

        $Groupid = Get-MsolGroup -ObjectId "53560852-af54-4561-aa5f-c6375d286577"

        

        $Users | ForEach-Object {Add-MsolGroupMember -GroupObjectId $GroupID.ObjectID -GroupMemberObjectId $Users.ObjectID -GroupMemberType User}


    }

}

