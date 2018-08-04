# Initialize
# Created by Jacob Ouellette
Import-module ActiveDirectory
$path = "%TEMP%\ADUser.csv"
$userPath = Read-Host -Prompt 'Enter path for users shared directories'

# Get all AD username
Get-ADUser -Filter * | Select SamAccountName | Export-Csv -Path $path -Encoding UTF8
(Get-Content $path) -replace('"', '') | Where-Object{$_ -notmatch '#|Administrator|Guest|SamAccountName|DefaultAccount|krbtgt'} | Set-Content $path

# Create folders
$content = Get-Content -Path $path
foreach ($username in $content) {
    md $userPath\$username
}

rmdir $path
