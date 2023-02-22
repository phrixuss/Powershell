$users = get-MsolUser -all



$Result=@()

foreach($user in $users) {



$manager = get-azureadusermanager -ObjectID $user.objectid




$Result += New-Object PSObject -property @{

    DisplayName = $user.displayname

    FirstName = $user.firstname

    LastName = $user.lastname

    IsLicensed = $user.IsLicensed

    LastPasswordChangeTimestamp = $user.LastPasswordChangeTimestamp

    MobilePhone = $user.MobilePhone

    Office = $user.Office

    PostalCode = $user.PostalCode

    UserPrincipalName = $user.userprincipalname

    Title = $user.Title

    Manager = $manager.userprincipalname

}




}$Result | Export-Csv steeruserlist.csv -NoTypeInformation -Encoding UTF8