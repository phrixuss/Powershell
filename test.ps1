$users = import-csv "C:\Users\me0909\Desktop\richmondfinal.csv"
foreach ($user in $users){
    $email = $user.userPrincipalName
    $number = $user.o365ddi
    $policy = "UK"

    try {
        Write-Host "Assiging number to $email with the number $number"
        Set-CsUser -Identity $email -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI $number
        Grant-CsOnlineVoiceRoutingPolicy -identity $email -policyname "UK"
        Grant-CsTenantDialPlan -Identity $email -PolicyName MainDP


    }catch [UnAuthorized,Microsoft.Rtc.Management.AD.Cmdlets.SetOcsUserCmdlet] {
        Write-Host "Unable to assign $email with the number $number"


    }



   
}



$users = import-csv "C:\Users\me0909\Desktop\richmondfinal.csv"
$out=@() 
foreach ($user in $users){
    $email = $user.UserPrincipalName
    $number = $user.O365ddi
    $policy = "UK"
    $userresult =  Get-MsolUser -UserPrincipalName $email | Where-Object {($_.licenses).AccountSkuId -match "M365EDU_A5_FACULTY"} | Select-Object UserPrincipalName,@{l='UserA5'; e={"True"} }
    $DeviceInfo= @{} 

    if ($userresult.usera5 -eq "true"){
        #Write-Host $userresult.UserPrincipalName " User contains A5"
        $DeviceInfo.add("Username", $userresult.UserPrincipalName) 
        $DeviceInfo.add("A5", $userresult.UserA5) 
    }else{
        #$usercheckafter = Get-MsolUser -UserPrincipalName $email
        #Write-Host $email " User doesnt have A5"
        $DeviceInfo.add("Username", $email) 
        $DeviceInfo.add("A5", "False") 
    }
    $out += New-Object PSObject -Property $DeviceInfo | Select-Object "Username","A5" 

 

    }Write-Verbose ($out | Out-String) -Verbose              

    $out | Export-CSV C:\Users\me0909\Desktop\licensed2.csv -NoTypeInformation 
Import-Csv .\users.csv | ForEach-Object {
    $User = Get-MsolUser -UserPrincipalName $_.UserPrincipalName
    $Skus = $User.licenses.AccountSkuId
    Set-MsolUserLicense -UserPrincipalName $User.UserPrincipalName -RemoveLicenses $Skus
}
OK3560@rutc.ac.uk

Set-CsUser -Identity "me0909@rutc.ac.uk" -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI "tel:+442086078175"
Grant-CsOnlineVoiceRoutingPolicy -identity "me0909@rutc.ac.uk" -policyname "UK"
New-CSOnlineVoiceRoutingPolicy "UK" -OnlinePstnUsages "UK" 
Get-MsolUserlicense -UserPrincipalName "PU2470@rutc.ac.uk"
$user = Get-MsolUser -UserPrincipalName "PU2470@rutc.ac.uk" | Select-Object Licenses
$user -contains "rutc1:M365EDU_A5_FACULTY"


    #Get-MsolUser -UserPrincipalName $email | Where-Object {($_.licenses).AccountSkuId -notmatch "M365EDU_A5_FACULTY"} | Select-Object UserPrincipalName,@{l='UserA5'; e={"False"} }


    #Get-MsolUser -UserPrincipalName $email | Where-Object {($_.licenses).AccountSkuId -match "M365EDU_A5_FACULTY"} | Select-Object UserPrincipalName,Licenses

    #Set-MsolUser -UserPrincipalName $email -UsageLocation $usage
    #Set-MsolUserLicense -UserPrincipalName $email -AddLicenses $sku

$mailboxs = get-mailbox -filter * | Select-Object name 

$out = @() 

foreach ($mailbox in $mailboxs){ 

 

    $results = get-mailboxstatistics -identity $mailbox.name | Select-Object TotalItemSize 

    $mailboxname = get-mailbox -identity $mailbox.name | Select-Object PrimarySmtpAddress 

 

    $DeviceInfo= @{} 

     

    $DeviceInfo.add("Mailbox Name", $mailboxname.PrimarySmtpAddress) 

     

    $DeviceInfo.add("Mailbox Usage", $results.TotalItemSize) 

 

    $out += New-Object PSObject -Property $DeviceInfo | Select-Object ` 

              "Mailbox Name", 

              "Mailbox Usage" 

 

    }Write-Verbose ($out | Out-String) -Verbose              

    $out | Export-CSV C:\result.csv -NoTypeInformation 



    $email = "FAC5L049@rutc.ac.uk"
    $number = "tel:+442086078175"
    $policy = "UK"
    Write-Host "Assiging number to $email with the number $number"
    Set-CsUser -Identity $email -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI $number
   # Grant-CsOnlineVoiceRoutingPolicy -identity $email -policyname "UK"
   # Grant-CsTenantDialPlan -Identity $email -PolicyName MainDP



   New-CsOnlineApplicationInstance -UserPrincipalName "itsupport.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "IT Support"
   New-CsOnlineApplicationInstance -UserPrincipalName "Reception.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Reception"
   New-CsOnlineApplicationInstance -UserPrincipalName "SafeGuarding.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "SafeGuarding"
   New-CsOnlineApplicationInstance -UserPrincipalName "Bursary.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Bursary"
   New-CsOnlineApplicationInstance -UserPrincipalName "Admissions.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Admissions"
   New-CsOnlineApplicationInstance -UserPrincipalName "Apprentiships.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Apprentiships"
   New-CsOnlineApplicationInstance -UserPrincipalName "Careers.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Careers"
   New-CsOnlineApplicationInstance -UserPrincipalName "Caretakers.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Caretakers"
   New-CsOnlineApplicationInstance -UserPrincipalName "Estates.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Estates"

   New-CsOnlineApplicationInstance -UserPrincipalName "StudentServices.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Student Services"
   New-CsOnlineApplicationInstance -UserPrincipalName "SupportedLearning.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Supported Learning"
   New-CsOnlineApplicationInstance -UserPrincipalName "Finance.queue@rutc.ac.uk" -ApplicationId "11cd3e2e-fccb-42ad-ad00-878b93575e07" -DisplayName "Finance"




   Set-CsOnlineApplicationInstance -Identity "itsupport.queue@rutc.ac.uk" -OnpremPhoneNumber +4402086078222
   Set-CsOnlineApplicationInstance -Identity "Reception.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078000
   Set-CsOnlineApplicationInstance -Identity "SafeGuarding.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078300
   Set-CsOnlineApplicationInstance -Identity "Bursary.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078311
   Set-CsOnlineApplicationInstance -Identity "Admissions.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078307
   Set-CsOnlineApplicationInstance -Identity "Apprentiships.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078171
   Set-CsOnlineApplicationInstance -Identity "Careers.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078324
   Set-CsOnlineApplicationInstance -Identity "Caretakers.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078304
   Set-CsOnlineApplicationInstance -Identity "Estates.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078401


   Set-CsOnlineApplicationInstance -Identity "StudentServices.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078199
   Set-CsOnlineApplicationInstance -Identity "SupportedLearning.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078329
   Set-CsOnlineApplicationInstance -Identity "Finance.queue@rutc.ac.uk" -OnpremPhoneNumber +442086078349


   get-CsOnlineApplicationInstance -Identity "itsupport.queue@rutc.ac.uk" 
   get-CsOnlineApplicationInstance -Identity "Reception.queue@rutc.ac.uk" 
   get-CsOnlineApplicationInstance -Identity "SafeGuarding.queue@rutc.ac.uk"
   get-CsOnlineApplicationInstance -Identity "Bursary.queue@rutc.ac.uk"
   get-CsOnlineApplicationInstance -Identity "Admissions.queue@rutc.ac.uk" 
   get-CsOnlineApplicationInstance -Identity "Apprentiships.queue@rutc.ac.uk" 
   get-CsOnlineApplicationInstance -Identity "Careers.queue@rutc.ac.uk"
   get-CsOnlineApplicationInstance -Identity "Caretakers.queue@rutc.ac.uk"
   get-CsOnlineApplicationInstance -Identity "Estates.queue@rutc.ac.uk"


   get-CsOnlineApplicationInstance -Identity "StudentServices.queue@rutc.ac.uk"
   get-CsOnlineApplicationInstance -Identity "SupportedLearning.queue@rutc.ac.uk"
   get-CsOnlineApplicationInstance -Identity "Finance.queue@rutc.ac.uk"