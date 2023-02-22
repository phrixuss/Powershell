function Show-Menu
{
     param (
           [string]$Title = 'User Migration Sharepoint'
     )
     cls
     Write-Host "================ $Title ================"
    
     Write-Host "1: Press '1' Check user's folder in the fileserver."
     Write-Host "2: Press '2' Change folder name "
     Write-Host "3: Press '3' Generate CSV for onedrive migration"
     Write-Host "Q: Press 'Q' to quit."
}
do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
               $users = Import-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\users.csv"
                $out = @()
                foreach ($user in $users){
    
                    $result = Get-ChildItem E:\UsersProfile\ -Recurse -depth 2 -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match ($user.name) } | Select-Object fullname 
                    foreach ($results in $result) {
    
                    $folder = @{}
                    $folder.add("foldername", $results.fullname)

                    $out += New-Object PSObject -Property $folder | Select-Object `
                              "foldername"

                    }
                    Write-Verbose ($out | Out-String) -Verbose             
                    $out | Export-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\folderresult.csv" -NoTypeInformation
                }


           } '2' {
                cls
                     
     
            $users = Import-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\usersresult.csv"
            $out = @()      
            foreach ($user in $users){
            Write-Host $user.username
            Write-Host $user.foldername

            if ($user.foldername -match $user.username){

                Rename-Item -Path $user.foldername -NewName ("_OD_" + $user.username) -Force
    
            } else {

                Write-Warning "Username does not match the folder name, please check"

            }





         }

            #$users = Import-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\usersresult.csv"

            foreach ($user in $users){
    
                $result = Get-ChildItem E:\UsersProfile\ -Recurse -depth 2 -ErrorAction SilentlyContinue | Where-Object {$_.PSIsContainer -eq $true -and $_.Name -match ("_OD_" + $user.username) } | Select-Object fullname 
                foreach ($results in $result) {
    
                $folder = @{}
                $folder.add("foldernamemigration", $results.fullname)

                $out += New-Object PSObject -Property $folder | Select-Object `
                            "foldernamemigration"

                }
                Write-Verbose ($out | Out-String) -Verbose             

                $out | Export-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\folderresult_OD_.csv" -NoTypeInformation
            }
                
                   
               

           }'3' {
                cls

                $users = Import-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\usersresult.csv"
                $out = @()
                foreach ($user in $users){

                    $csv = @{}
                    $csv.add("c1", $user.foldernamemigration+"\Desktop")
                    $csv.add("c2", "")
                    $csv.add("c3", "")
                    $csv.add("c4", "https://thefrankgroup-my.sharepoint.com/personal/"+$user.Emailmigration)
                    $csv.add("c5", "Documents")
                    $csv.add("c6", "Desktop")
                    #$csv.add("Onedrive", $user.foldernamemigration + "\My Documents,,,https://thefrankgroup-my.sharepoint.com/personal/" + $user.emailmigration + ",Document,Documents")

                
                    $out += New-Object PSObject -Property $csv | Select-Object `
                            "c1","c2","c3","c4","c5","c6"
                   
                
                } foreach ($user in $users){

                    $csv = @{}
                    $csv.add("c1", $user.foldernamemigration+"\My Documents")
                    $csv.add("c2", "")
                    $csv.add("c3", "")
                    $csv.add("c4", "https://thefrankgroup-my.sharepoint.com/personal/"+$user.Emailmigration)
                    $csv.add("c5", "Documents")
                    $csv.add("c6", "Documents")
                    #$csv.add("Onedrive", $user.foldernamemigration + "\My Documents,,,https://thefrankgroup-my.sharepoint.com/personal/" + $user.emailmigration + ",Document,Documents")

                
                    $out += New-Object PSObject -Property $csv | Select-Object `
                            "c1","c2","c3","c4","c5","c6"
                   
                
                }

                Write-Verbose ($out | Out-String) -Verbose             
                
                $place = Read-Host "What is the name of the site?: "
                $date = get-date -Format "dd-MM-yyyy HH-mm"
                $csvname = $place + " " + $date
                
                $out | Export-Csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\script\$csvname.csv" -NoTypeInformation
                
                Write-Warning "Migrating to Onedrive"

                $csvItems = import-csv "\\convergentsd\c$\Users\csd\OneDrive - NIGEL FRANK INTERNATIONAL\Documents\script\$csvname.csv"
                
                Unregister-SPMTMigration
                Register-SPMTMigration
                ForEach ($item in $csvItems){

                Write-Host $item.c1

                Add-SPMTTask -FileShareSource $item.c1 -TargetSiteUrl $item.c4 -TargetList $item.c5 -TargetListRelativePath $item.c6

                
                } 
                Start-SPMTMigration
                

           }'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')