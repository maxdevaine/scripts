# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/01
# license: GNU GPLv3
# description
# Send databases and mailboxes statistics (databases size, mailboxes size, mailboxes items count...)

###First, the administrator must change the mail message values in this section
$FromAddress = "MailboxReport@domain.tld"
$ToAddress = "admin@domain.tld"
$MessageSubject = "Exchange 2013 : Mailbox Size Report"
$MessageBody = "Attached is the current list of mailbox sizes."
$SendingServer = "smtp.domain.tld"
$Timestamp = get-date -f yyyy-MM-dd
$OutputFile = $PSScriptRoot + '\' + 'mailboxes-' + $Timestamp + '.txt'

Write-Host $OutputFile

###Now get the stats and store in a text file
$a = Get-Date
"Date: " + $a.ToShortDateString() > $OutputFile
"Time: " + $a.ToShortTimeString() >> $OutputFile

Get-MailboxDatabase -Server EX1-PH | Select Server, StorageGroupName, Name, @{Name="Size (GB)";Expression={$objitem = (Get-MailboxDatabase $_.Identity); $path = "`\`\" + $objitem.server + "`\" + $objItem.EdbFilePath.DriveName.Remove(1).ToString() + "$"+ $objItem.EdbFilePath.PathName.Remove(0,2); $size = ((Get-ChildItem $path).length)/1048576KB; [math]::round($size, 2)}}, @{Name="Size (MB)";Expression={$objitem = (Get-MailboxDatabase $_.Identity); $path = "`\`\" + $objitem.server + "`\" + $objItem.EdbFilePath.DriveName.Remove(1).ToString() + "$"+ $objItem.EdbFilePath.PathName.Remove(0,2); $size = ((Get-ChildItem $path).length)/1024KB; [math]::round($size, 2)}}, @{Name="No. Of Mbx";expression={(Get-Mailbox -Database $_.Identity | Measure-Object).Count}} | Format-table -AutoSize >> $OutputFile

Get-MailboxDatabase -Server EX1-PH | Get-MailboxStatistics | Sort-Object TotalItemSize -Descending | ft DisplayName,@{label="TotalItemSize(MB)";expression={$_.TotalItemSize.Value.ToMB()}},ItemCount >> $OutputFile


###Create the mail message and add the statistics text file as an attachment
$SMTPMessage = New-Object System.Net.Mail.MailMessage $FromAddress, $ToAddress, 
$MessageSubject, $MessageBody
$Attachment = New-Object Net.Mail.Attachment($OutputFile)
$SMTPMessage.Attachments.Add($Attachment)

###Send the message
$SMTPClient = New-Object System.Net.Mail.SMTPClient $SendingServer
$SMTPClient.Send($SMTPMessage)
