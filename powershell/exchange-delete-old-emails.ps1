# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/07
# license: GNU GPLv3
# description
# Delete all emails in selected date range
# search-mailbox is limited to 10000 results, so this is why cycle with counter (for example "-le 2" = up to 20000 items)
# you can create batch file for windows scheduler, for example:
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command ". 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; . '"C:\Exchange_Scripts\exchange-delete-old-emails.ps1"' -MailboxName mailbox -Days 365 -LoopCountTotal 5"

<#
.SYNOPSIS
    .
.DESCRIPTION
    Script delete all emails older than defined days.
.PARAMETER MailboxName
    Name of mailbox
.PARAMETER Days
    Specify count of days (older than x days)
.EXAMPLE
    C:\PS> 
     -MailboxName User -Days 365 -LoopCountTotal 10
.NOTES
    Author: Max Devaine
    Date:   June 9, 2024
#>


Param($MailboxName,$Days,$LoopCountTotal)

$example = "Example: $PSCommandPath -MailboxName User -Days 365 -LoopCountTotal 10"

if ($MailboxName -eq $null) {
  Write-Host Please specify the MailboxName
  Write-Host $example
  Exit
}

if ($Days -eq $null) {
  Write-Host Please specify the Days value "(older than x days)"
  Write-Host $example
  Exit
}

if ($LoopCountTotal -eq $null) {
  Write-Host Please specify the LoopCountTotal value "(how many times run loop)"
  Write-Host $example
  Exit
}


$LoopCount = 1
$DaysAgoCount = (Get-Date).AddDays(-$Days)
$DaysAgo = Get-Date -Date $DaysAgoCount -Format "MM/dd/yyyy"

while ($LoopCount  -le $LoopCountTotal) {
   Write-Host The loop value is: $LoopCount/$LoopCountTotal
   Write-Host Remove all emails older than: $DaysAgo "(MM/dd/yyyy)"
   #search-mailbox -identity $MailboxName -searchquery {received:01/04/2015..07/07/2023} -deletecontent -force
   Search-Mailbox -Identity $MailboxName -SearchQuery "Received<=$DaysAgo AND kind:email" -DeleteContent -force
   $LoopCount++
}

Write-Host End of loop.
