function encodeME($convertDots)
    {
        $COD = $convertDots
        [System.Char]$charVal = “.”
        $num = 0

        $newCOD

    while($num -lt $COD.Length)
        {

        if($COD[$num] -ne $charVal)
            {
            $newCOD = $newCOD + $COD[$num]
            $num++
            }

        elseif($COD[$num] -eq $charVal)
            {
            #this logic works up to here
            $newCOD = $newCOD + “%2E”
            $num++
            }

        }

    [System.String]$strnewCOD = $newCOD
    return $strnewCOD
    }
    

######################
##Script starts here##
########################
#Need to grab site URL from user#
Write-Host “Input URL of the SharePoint Site and press Enter”
$siteURL = Read-Host;Write-Host

#Need the library name#
Write-Host “Input name of library to sync and press Enter”
$listNameTMP = Read-Host;Write-Host
$listName = “/” + $listNameTMP

#Enter email address (UPN) of user#
Write-Host “Enter credentials of user that will sync and select Enter” -ForegroundColor Yellow
Write-Host “Username should be in UPN/Email format” -ForegroundColor Yellow
Write-Host
$UPN = Read-Host;Write-Host

#Need to connect to site#
Write-Host “Please authenticate to the site using SPO Admin Credentials”;Write-Host
Read-Host “Press Enter Key to get started”
$cred = get-credential

if($siteURL, $libName, $UPN -ne $null)
{
Connect-PnPOnline -url $siteURL -Credentials $cred

#Grabbing Site, Web, and List ID’s
$site = Get-PnPSite -Includes Id, URL
$siteIDtmp = $site.ID.toString()
#Adding some encoding here#
$siteID = “%7B” + $siteIDtmp + “%7D”

$web = Get-PnPWeb -includes Id, URL
$webIDtmp = $web.ID.toString()
#Adding some encoding here#
$webID = “%7B” + $webIDtmp + “%7D”

$list = Get-PnPList -Identity $listName -includes Id
$listIDtmp = $list.ID.toString()
#Adding some encoding here#
$listID = “%7B” + $listIDtmp + “%7D”

if($siteID, $webID, $listID)
{
#update encoding for UPN and SiteURL
[System.String]$newtmpSiteURL = encodeMe($siteURL)
[System.String]$newSiteURL = $newtmpSiteURL.Split(”,[System.StringSplitOptions]::RemoveEmptyEntries)
[System.String]$newtmpUPN = encodeMe($UPN)
[System.String]$newUPN = $newtmpUPN.Split(”,[System.StringSplitOptions]::RemoveEmptyEntries)

$resultTMP = “odopen://sync/?siteId=” + $siteID + “&webId=” + $webID + “&listId=” + $listID + “&listTitle=” + $listNameTMP + “&userEmail=” + $newUPN + “&webUrl=” + $newSiteURL

#Do remaining encoding work now#
$resultTMP2 = $resultTMP -replace “-“, “%2D”
$result = $resultTMP2 -replace “@”, “%40”

Write-Host $result
}
}

else
{Write-Host “Missing one of the requested values! Please run script again and insert correct values”;return}