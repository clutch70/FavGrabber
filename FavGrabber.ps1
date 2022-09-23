########################################################################
#
#	Script Title: FavGrabber.ps1
#	Author: Brennan Custard
#	Date: 9/4/2022
#	Description: This script looks for favorites in each user folder
#   and cleanly reports them one line at a time.
#
#
#
#
########################################################################


# Variables we'll need
$userDirs = gci C:\Users

$usersPath = 'C:\Users'
$firefoxPath = '\appdata'
$chromePath = 'AppData\Local\Google\Chrome\User Data\Default'
$chromeFile = 'bookmarks'
[regex]$regex = '(http[s]?|[s]?ftp[s]?)(:\/\/)([^\s,]+)'
$count = 0
$list

Function cleanUri($uriList)
{
    foreach ($uri in $uriList)
    {
        $uri.split('/')[2]
    }
}

foreach ($user in $userDirs.name)
{
    #$target = $usersPath\$user\$chromePath\$chromeFile
    If (Test-Path $usersPath\$user\$chromePath\$chromeFile)
    {
        #Write-Output "Found Chrome favorites for $user!!!"
        $data = Get-Content $usersPath\$user\$chromePath\$chromeFile
        $data = $regex.matches($data).value
        $cleaned = cleanUri($data)
        $cleaned = $cleaned | select -Unique
        $list = $list + $cleaned
        $count = $count + $cleaned.count

    }
}

$list
$count