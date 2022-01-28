#!/usr/bin/python2
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2018/05
# license: GNU GPLv3

# description
# download file from ftp to temp directiry and then move to production directory

import os
import pwd
import grp
import datetime
from ftplib import FTP

# old
#ftpserver = "192.168.50.1"
#ftpport = 2100
#ftplogin = "ftpuser@192.168.150.1"
# test server :
#ftplogin = "ftpusertest@192.168.250.1"


# definition of variables
ftpserver = "192.168.50.1"
ftpport = 21
passive = 1
ftpdebug = 0
ftpcontimeout = 15
# test server :
#ftplogin = "Bftpuser"
# production :
ftplogin = "ftpuser"
ftppass = "password*123"
ftpdir = "/Versand"
localdir = "/home/proftpd/receive"
localtemp = "/home/proftpd/tmp"
filematch = "*.xml"
logfile = "logfile.txt"


# set local directory for store files
if os.path.isdir(localtemp) != True or os.path.isdir(localdir) != True:
    print "Directory not exist !!!"
    exit()
else:
    os.chdir(localtemp)


# check if is server up
response = os.system("ping -c 1 -w2 " + ftpserver + " > /dev/null 2>&1")
if response != 0:
  print "ping error"
  exit()


# connect to ftp server
ftp = FTP()
if ftpdebug !=0: ftp.set_debuglevel(ftpdebug)
ftp.connect(ftpserver, ftpport, timeout=ftpcontimeout)
ftp.login(ftplogin, ftppass)
ftp.set_pasv(passive)
ftp.cwd(ftpdir)


#ftp.nlst(filematch)
#except (ftplib.all_errors) as e:
#if str(e) == "550 No files found":
#print "Directory is empty."

# set date to logfile
now = datetime.datetime.now()
print "########## "+ now.strftime("%Y-%m-%d %H:%M") +" ##########"

uid = pwd.getpwnam("ftpuser").pw_uid
gid = grp.getgrnam("ftpgroup").gr_gid

# download all files from ftp folder with specific filematch
for filename in ftp.nlst(filematch):
    fhandle = open(filename, 'wb')
    print (filename)
    ftp.retrbinary('RETR ' + filename, fhandle.write)
    if os.path.isfile(filename) == True:
        ftp.rename(filename, "OK/" + filename)
        fullpathlocaltemp = os.path.join(localtemp, filename)
        fullpathlocaldir = os.path.join(localdir, filename)
        os.chown(fullpathlocaltemp, uid, gid)
        os.rename(fullpathlocaltemp, fullpathlocaldir)
    fhandle.close()

ftp.close()
