# RemoveUsers
Removes roaming profiles from a local machine older than a given amount of days

This simple PowerShell script was designed to safely remove roaming profiles from a local machine. Roaming profiles leave a local copy of the profile on a local machine after the user has logged out.
These profiles are never deleted by Windows and add up over time. Unfortunately just deleting the folder in C:\Users is not an option because if the user attempts to log into that PC again, the registry will
tell it to look for the profile in C:\Users. When it can't find the deleted profile, a temporary profile will be created. This script solves this by removing the registry key, taking ownership of the user
profile folder and then deleting it so nothing is left behind.

The PowerShell script is designed to be run on a schedule to keep up with the cleaning up of any users added. It can also be used in one off situations as well. While this has been designed for roaming profiles,
I would imagine that it would work just fine for local profiles as well. Keeping in mind that any local profiles that are deleted are gone for good. <b>Use caution and use the SafeUsers variable</b> at the top of the script to ensure safety.
