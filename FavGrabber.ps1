########################################################################
#
#	Script Title: FavGrabber.ps1
#	Author: Brennan Custard
#	Date: 9/4/2022
#	Description: This script looks for favorites in each user folder
#   and cleanly reports them one line at a time.
#
#
########################################################################

    <#
    .Synopsis
        Lists the server names of all favorites found on the device
    .Description
        Iterates through all user folders and finds favorites for Chrome
        and Windows/IE/Edge

    #>


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
        # Split up the string based on the / char and grab the 2nd element of that array, the server name
        $i = $uri.split('/')[2]
        # Get rid of port numbers and show the output
        $i.split(':')[0]
    }
}

function Resolve-ShortcutFile {

    <#
    https://devblogs.microsoft.com/powershell/resolve-shortcutfile/
    #>
    param(
    [Parameter(
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position = 0)]
    [Alias("FullName")]
    [string]
    $fileName
    )
process {

        if ($fileName -like "*.url") {
            Get-Content $fileName | Where-Object {
                $_ -like "url=*"
            } |
            Select-Object @{
                Name='ShortcutFile'
                Expression = {Get-Item $fileName}
            }, @{
                Name='Url'
                Expression = {$_.Substring($_.IndexOf("=") + 1 )}
            }
        }

}

}

Function cleanWinFavs($favs)
{
    foreach ($fav in $favs)
    {
        ($fav | Resolve-ShortcutFile).url
    }
}

# Capture Chrome favorites
foreach ($user in $userDirs.name)
{

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

# Capture IE/Windows favorites
foreach ($user in $userDirs.name)
{
    IF (Test-Path $usersPath\$user\Favorites)
    {
        $files = gci -Recurse $usersPath\$user\Favorites *.url
        IF ($files.count -gt 0)
        {
            $cleanWin = cleanWinFavs($files)
            $cleanWin = cleanUri($cleanWin)
            $cleanWin = $cleanWin | select -Unique
            $count = $count + $cleanWin.count
            $list = $list + $cleanWin
        }
    }
}


$list
$count