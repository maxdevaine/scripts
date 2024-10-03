# author: Max Devaine <maxdevaine@gmail.com>
# created: 2024/09
# license: GNU GPLv3
# description
# Watchdog script to check Geovision GV-VMS client access process)
# example for use: -processname CMSvr -programpath C:\GV-VMS\CMSvr.exe -weburl http://192.168.1.1:5611

# Windows scheduler example
# Program: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
# Parameters: -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\watchdog\watchdog-geovision-vms.ps1" -processname CMSvr -programpath C:\GV-VMS\CMSvr.exe -weburl http://192.168.1.1:5611

# set variables
param ($processname, $programpath, $weburl)

# function to check web url and return status code
function GetWebUrlStatusCode {
  try {
    $Response = Invoke-WebRequest -Method Get -Uri $weburl -TimeoutSec 4
    } catch {
      [int]$StatusCode = $Response.StatusCode
      
      # change variable if timeout happend
      $Error[0].Exception
      If (($Error[0].Exception) -match 'timed out') {
        $StatusCode = 2
      }
      return $StatusCode
    }
}

# function to find process by name and kill it
function KillMonitoredProcess {
  $processtokill = Get-Process -name $processname -ErrorAction SilentlyContinue
  if ($processtokill -ne $null) {
    $processtokill | Stop-Process -Force
  }
}

# if is set weburl variable, check http status code and kill process (killing process = service automatically run process again)
if ($weburl -ne $null) {
  if ((GetWebUrlStatusCode) -ne '0') {
      Write-Host Killing process
      KillMonitoredProcess
      Start-Sleep -Seconds 4
  }
}

# if isn't process running, run them again
if ($programpath -ne $null) {
  $processtostart = Get-Process -name $processname -ErrorAction SilentlyContinue
  if ($processtostart -eq $null) {
      Write-Host Proccess is not running, trying to start them...
      Start-Process $programpath
  }
}
