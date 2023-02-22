$users = get-msoluser

foreach ($user in $users) {

#Ensures the object has an @CompanyX UPN, has never been synced, and contains details for a first and last name

if ($user.UserPrincipalName -match “@companyX.com” -and !$user.LastDirSyncTime -and $user.FirstName -and $user.LastName) {

#Put the SAM account together by getting the last name, adding an underscore and adding the first name (eg. smith_john). This will need to be modified to match whatever your company uses as a SAM account format.

$sam = $user.LastName + “_” + $user.firstname

#Get the AD user object based on the created SAM above, get the ObjectGUID value and convert it to a base64 value.

$ImmID = Get-ADUser -identity P.Kinch -Properties ObjectGUID | select ObjectGUID | foreach {[system.convert]::ToBase64String(([GUID]($_.ObjectGUID)).tobytearray())}

#Sets the converted ObjectGUID as the ImmutableID for the user

set-msoluser -UserPrincipalName $user.UserPrincipalName -ImmutableId $ImmID

}

}