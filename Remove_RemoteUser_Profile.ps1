$computer = Read-Host "Please Enter Remote Server: "
$user = Read-Host "Enter Username: "
$load_status = Get-WmiObject -Class Win32_UserProfile -Computer $computer | Where-Object {$_.Special -ne 'Special' -and $_.LocalPath -like "*$($user)" } | Select-Object LocalPath, Loaded

if ($load_status.Loaded -eq $true) {
"User is logged on or Active. Logging user off..."
$matches = $null
$regex_true = $null
$regex_false = $null
foreach ($i in (quser /server:$computer)) {
if ($i -like "*$($user)*") { $Session = $i }
}
$regex_true = [regex] '#[0-9]+'
$regex_false = [regex] '[0-9]'
if ($session -match $regex_true) {
$Session = ($Session.Substring($session.IndexOf("#")+7)).Substring(0,8).Trim() 
} elseif ($Session -match $regex_false) {
$Session = $Session.Substring($session.IndexOf($Matches.Values)-1,6).Trim() 
} else { "Error"; quit

logoff $session /server:$computer

}
}
"Removing User profile [$user] from [$computer]..."
Invoke-Command -ComputerName $computer -ScriptBlock {
    param($user)
    $localpath = 'c:\users\' + $user
    Get-WmiObject -Class Win32_UserProfile | Where-Object {$_.LocalPath -eq $localpath} | 
    Remove-WmiObject
} -ArgumentList $user
if ((Test-Path "C:\Users\$user") -eq $true) { "Profile not removed!" 
} else { 
"Profile removed successfully!" 
}
