# author: Max Devaine <maxdevaine@gmail.com>
# created: 2023/05
# license: GNU GPLv3
# description
# logoff all disconnected rdp sessions on windows terminal server

# creat array variable
$result = @()

# list of all disconnected users
quser | Select-String "Disc" | ForEach {

# parse session id
   $sessionid = ($_.tostring() -split ' +')[2]

# store all session id to array
   $result += $sessionid
}

# print all session is stored in variable / array
Write-Host $result

# run job on background to logoff users
foreach ($id in $result) {
  Start-Job -ScriptBlock {logoff $args} -ArgumentList @($id)
}
