# author: Max Devaine <maxdevaine@gmail.com>
# created: 2020/07
# license: GNU GPLv3
# description
# Full reset of Windows Search (delete database, reset Working Rules / indexer settings)

# create temp directory and copy tools to change perm in registry (SetACL app from Nirsoft Company)
mkdir C:\temp-scripts
C:\WINDOWS\system32\xcopy \\share\SetACL\64bit\SetACL.exe C:\temp-scripts\ /Y

# stop indexer and disable service to prevent run again
Get-Service WSearch| Set-Service -StartupType Disabled
net stop "WSearch"

# Delete indexer database
del C:\ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb

# Grant permissions for admins to windows search records in Windows registry
c:
cd C:\temp-scripts
.\setacl.exe -on "HKLM\SOFTWARE\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\WorkingSetRules" -ot reg -rec yes -actn setowner -ownr "n:Administrators"
.\setacl.exe -on "HKLM\SOFTWARE\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\WorkingSetRules" -ot reg -rec yes -actn ace -ace "n:Administrators;p:full"

# Delete Windows Search records from Windows Registry
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Search\CrawlScopeManager\Windows\SystemIndex\WorkingSetRules" /f

# Allow Windows Search serverice and run wsearch again
# Get-Service WSearch| Set-Service -StartupType AutomaticDelayedStart
Get-Service WSearch| Set-Service -StartupType Automatic
net start "WSearch"

# clear temp files / directory
cd c:\
del C:\temp-scripts\SetACL.exe
rmdir C:\temp-scripts
