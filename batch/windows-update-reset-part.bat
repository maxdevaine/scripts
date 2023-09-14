REM #### stop services ####
net stop bits
net stop wuauserv
net stop appidsvc
net stop cryptsvc

REM #### Delete cache ####
Del "%ALLUSERSPROFILE%\Application Data\Microsoft\Network\Downloader\*.*"
rmdir %systemroot%\SoftwareDistribution /S /Q
rmdir %systemroot%\system32\catroot2 /S /Q

REM #### reset BITS ####
sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)
sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)

REM #### register all dll ####
REM cd /d %windir%\system32
REM regsvr32.exe /s atl.dll
REM regsvr32.exe /s urlmon.dll
REM regsvr32.exe /s mshtml.dll
REM regsvr32.exe /s shdocvw.dll
REM regsvr32.exe /s browseui.dll
REM regsvr32.exe /s jscript.dll
REM regsvr32.exe /s vbscript.dll
REM regsvr32.exe /s scrrun.dll
REM regsvr32.exe /s msxml.dll
REM regsvr32.exe /s msxml3.dll
REM regsvr32.exe /s msxml6.dll
REM regsvr32.exe /s actxprxy.dll
REM regsvr32.exe /s softpub.dll
REM regsvr32.exe /s wintrust.dll
REM regsvr32.exe /s dssenh.dll
REM regsvr32.exe /s rsaenh.dll
REM regsvr32.exe /s gpkcsp.dll
REM regsvr32.exe /s sccbase.dll
REM regsvr32.exe /s slbcsp.dll
REM regsvr32.exe /s cryptdlg.dll
REM regsvr32.exe /s oleaut32.dll
REM regsvr32.exe /s ole32.dll
REM regsvr32.exe /s shell32.dll
REM regsvr32.exe /s initpki.dll
REM regsvr32.exe /s wuapi.dll
REM regsvr32.exe /s wuaueng.dll
REM regsvr32.exe /s wuaueng1.dll
REM regsvr32.exe /s wucltui.dll
REM regsvr32.exe /s wups.dll
REM regsvr32.exe /s wups2.dll
REM regsvr32.exe /s wuweb.dll
REM regsvr32.exe /s qmgr.dll
REM regsvr32.exe /s qmgrprxy.dll
REM regsvr32.exe /s wucltux.dll
REM regsvr32.exe /s muweb.dll
REM regsvr32.exe /s wuwebv.dll

REM #### reset winsock ####
netsh winsock reset
netsh winsock reset proxy

REM #### start services ####
net start bits
net start wuauserv
net start appidsvc
net start cryptsvc
