##### - User changable variables
param ($DaysBack = 365) #Delete profiles older than this many days. Can also provide the script with the parameter DaysBack.
$SafeUsers = "Public", "Default", "Default.migrated", "juser" #User profiles to ignore
#####

$UsersToRemove = Get-ChildItem "C:\Users" |? {$_.psiscontainer -and $_.lastwritetime -le (get-date).adddays(-$DaysBack)}
$UsersFromReg = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"  | Where-Object { (-not($_ -match 'S-1-5-18|S-1-5-19|S-1-5-20')) } #Users from registry, ignoring system accounts
$Key = $UsersFromReg | Get-ItemProperty -name "ProfileImagePath"



# This script requires that Audit Logon events are enabled in Group Policy and those events are kept for the amount of history preferred
$UserArray = New-Object System.Collections.ArrayList

# Query all logon events with id 4624 
Get-EventLog -LogName "Security" -InstanceId 4624 -ErrorAction "SilentlyContinue" | ForEach-Object {

    $EventMessage = $_
    $AccountName = $EventMessage.ReplacementStrings[5]
    $LogonType = $EventMessage.ReplacementStrings[8]


    # Look for events that contain local or remote logon events, while ignoring Windows service accounts
    if ( ( $LogonType -in "2", "10" ) -and ( $AccountName -notmatch "^(DWM|UMFD)-\d" ) ) {
    
        # Skip duplicate names
        if ( $UserArray -notcontains $AccountName ) {

            $null = $UserArray.Add($AccountName)
            
            # Translate the Logon Type
            if ( $LogonType -eq "2" ) {

                $LogonTypeName = "Local"

            } elseif ( $LogonType -eq "10" ) {

                $LogonTypeName = "Remote"

            }

            # Build an object containing the Username, Logon Type, and Last Logon time
            if (([DateTime]$EventMessage.TimeGenerated.ToString("yyyy-MM-dd")) -ge ([DateTime](get-date).adddays(-$DaysBack)))
            {
                $SafeUsers += $AccountName
            }

        }

    }

}


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