##### - User changable variables
param ($DaysBack = 365) #Delete profiles older than this many days. Can also provide the script with the parameter DaysBack.
$SafeUsers = "Public", "Default", "Default.migrated", "juser" #User profiles to ignore
#####

$UsersToRemove = Get-ChildItem "C:\Users" |? {$_.psiscontainer -and $_.lastwritetime -le (get-date).adddays(-$DaysBack)}
$UsersFromReg = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$Key = $UsersFromReg | Get-ItemProperty -name "ProfileImagePath"


foreach ($item in $UsersToRemove)
{
    if ($SafeUsers.Contains($item.Name) -eq 0)
    { 
        $Key | ForEach-Object {
            If($_.ProfileImagePath.ToLower() -match $item.Name)
            {
                Write-Output $_.PSPath ' = ' $_.ProfileImagePath
                Remove-Item $_.PSPath -Recurse -Force
                takeown /f $_.ProfileImagePath /a /r /d Y > null 2>&1
                Remove-Item $_.ProfileImagePath -Recurse -Force
            }
        }
    }
}