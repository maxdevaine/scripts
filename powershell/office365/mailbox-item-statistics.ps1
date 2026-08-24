# author: Gemini AI + Max Devaine <maxdevaine@gmail.com>
# created: 2026/08
# license: GNU GPLv3
# description
# List all folders in a mailbox and display stats (name, path, item count, size in MiB)

Get-MailboxFolderStatistics -Identity "user@domain.tld" -ResultSize Unlimited | 
    Select-Object @{Name="Název"; Expression={$_.Name}},
        @{Name="Cesta"; Expression={$_.FolderPath}},
        @{Name="Počet položek"; Expression={$_.ItemsInFolder}},
        @{Name="Velikost (MB)"; Expression={
            if ($_.FolderSize -match '\(([\d,]+)\s+bytes\)') {
                [math]::Round([int64]($Matches[1] -replace ',','') / 1MB, 2)
            } else { 0 }
        }} | 
    Sort-Object "Velikost (MB)" -Descending
