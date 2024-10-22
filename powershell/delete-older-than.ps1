# author: Max Devaine <maxdevaine@gmail.com>
# created: 2024/10
# license: GNU GPLv3
# description
# Delete files and folders older than defined days.

# Windows scheduler example
# Program: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
# Pramaters: -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\delete-older-than.ps1"
# source: https://stackoverflow.com/questions/17829785/delete-files-older-than-15-days-using-powershell

$limit = (Get-Date).AddDays(-365)
$path = "C:\Some\Path"

# Delete files older than the $limit.
#Get-ChildItem -Path $path -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force -Recurse
Get-ChildItem -Path $path -Force | Where-Object { $_.CreationTime -lt $limit } | Remove-Item -Force -Recurse
