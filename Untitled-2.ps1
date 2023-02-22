# Output will be added to C:\temp folder. Open the Add-onmicrosoft-SMTP.log with a text editor. For example, Notepad.
Start-Transcript -Path C:\temp\Add-onmicrosoft-SMTP.log -Append

# Get all mailboxes
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# Loop through each mailbox
foreach ($Mailbox in $Mailboxes) {

    # Search for @mail.onmicrosoft.com SMTP in every mailbox
    $OnMicrosoftAddress = $Mailbox.EmailAddresses | Where-Object { $_.AddressString -like "*@CCEngineering.mail.onmicrosoft.com" }
      
    # Do nothing when there is already an @mail.onmicrosoft.com SMTP configured
    If (($OnMicrosoftAddress | Measure-Object).Count -eq 0) {

        # Change exoip with the domain name that you want to add as SMTP
        $OnMSAddress = "$($Mailbox.Alias)@CCEngineering.mail.onmicrosoft.com"
        Set-Mailbox $Mailbox -EmailAddresses @{add = $OnMSAddress }

        # Write output
        Write-Host "Adding $($OnMSAddress) to $($Mailbox.Name) Mailbox" -ForegroundColor Green
    }
}

Stop-Transcript