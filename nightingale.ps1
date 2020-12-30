Get-ADObject -SearchBase "OU=LISS,OU=Sites,DC=uk,DC=capio,DC=net" -Filter * | Format-Table name,distinguisedname
