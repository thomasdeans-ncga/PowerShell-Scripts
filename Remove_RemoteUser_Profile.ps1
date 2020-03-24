$Computer = Read-Host "Please Enter Remote Server: "
$user = Read-Host "Enter Username: "
$load_status = Get-WmiObject -Class Win32_UserProfile -Computer $computer | Where-Object {$_.Special -ne 'Special' -and $_.LocalPath -like "*$($user)" } | Select-Object LocalPath, Loaded

if ($load_status.Loaded -eq $true) {
"You cannot remove a user profile for a user who is logged in. Please log back into RDP and logout first."
} else {
"Removing User profile [$user] from [$computer]..."
Invoke-Command -ComputerName $computer -ScriptBlock {
    param($user)
    $localpath = 'c:\users\' + $user
    Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq $localpath} | 
    Remove-WmiObject
} -ArgumentList $user
if ((Test-Path "C:\Users\$user") -eq $true) { "Profile not removed!" } else { "Profile removed successfully!" }
}