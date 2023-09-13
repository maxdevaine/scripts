#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/07
# license: GNU GPLv3
# description
# Delete all emails in selected date range
# search-mailbox is limited to 10000 results, so this is why cycle with counter ("-le 2" = up to 20000 items)

$var = 1
$mailbox = user1

while ($var -le 2) {
   search-mailbox -identity $mailbox -searchquery {received:01/04/2015..05/10/2021} -deletecontent -force
   #Search-Mailbox -Identity $mailbox -SearchQuery 'Received<="2022-08-31" AND kind:email' -DeleteContent -force
   Write-Host The value of Var is: $var
   $var++
}

Write-Host End of While loop.
