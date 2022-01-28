#!/usr/bin/python2
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2018/05
# license: GNU GPLv3

# description
# send file from local dir to ftp server

import glob, os
import datetime
from ftplib import FTP


# old via ftp proxy:
#ftpserver = "192.168.100.1"
#ftplogin = "username@192.168.50.1"
#ftpport = 2100
# test server :
#ftplogin = "username2@192.168.150.1"


# definition of variables
ftpserver = "192.168.50.1"
ftpport = 21
passive = 1
ftpdebug = 0
ftpcontimeout = 25
# test server :
#ftplogin = "192.168.150.1"
# production :
ftplogin = "ftpuser"
ftppass = "password"
ftpdir = "/Empfang"
localdir = "/home/proftpd/send"
archivedir = "/home/proftpd/send/OK"
extension = ".xml"
tmpextension = ".prt"
logfile = "logfile.txt"


# set local directory for send files
if os.path.isdir(localdir) != True:
    print "Send directory not exists !!!"
    exit()
else:
    os.chdir(localdir)

if os.path.isdir(archivedir) != True:
    print "Archive root directory not exists !!!"
    exit()

# create archive directory :
myarchivedir = os.path.join(archivedir, datetime.datetime.now().strftime('%Y-%m'))
if os.path.isdir(myarchivedir) != True:
    os.makedirs(myarchivedir)

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



# set date to logfile
now = datetime.datetime.now()
print "########## "+ now.strftime("%Y-%m-%d %H:%M") +" ##########"

# send all files from local folder with specific filematch to ftp
for (root, dirs, files) in os.walk(localdir):
    del dirs[:]
    for filename in files:
        if filename.endswith(extension):
            full_fname = os.path.join(root, filename)
            fullpathonftp = os.path.join(ftpdir, filename)
            fullpatharchive = os.path.join(myarchivedir, filename)

            # rename file extension
            tmp_filename = os.path.splitext(filename)[0]+tmpextension
            tmp_full_fname = os.path.join(root, tmp_filename)
            tmp_fullpathonftp = os.path.join(ftpdir, tmp_filename)
            os.rename(full_fname,tmp_full_fname)

            # copy file to ftp
            ftp.storbinary('STOR ' + tmp_fullpathonftp, open(tmp_full_fname, 'rb'))
            # rename file on ftp
            ftp.rename(tmp_fullpathonftp, fullpathonftp)

            # archive file on local drive
            os.rename(tmp_full_fname, fullpatharchive)
            #print(""+str(full_fname)+"\n -> REN to \""+str(tmp_full_fname)+"\"\n   -> FTP put:\""+str(tmp_fullpathonftp)+"\"\n     -> FTP ren:\""+str(fullpathonftp)+"\"")
            print filename

        # if tmp file exist, then send it to ftp and rename to right name
        if filename.endswith(tmpextension):
            tmp_filename = filename
            tmp_full_fname = os.path.join(root, tmp_filename)
            tmp_fullpathonftp = os.path.join(ftpdir, tmp_filename)

            orig_filename = os.path.splitext(tmp_filename)[0]+extension
            fullpathonftp = os.path.join(ftpdir, orig_filename)
            fullpatharchive = os.path.join(myarchivedir, orig_filename)

            # copy file to ftp
            ftp.storbinary('STOR ' + tmp_fullpathonftp, open(tmp_full_fname, 'rb'))
            # rename file on ftp
            ftp.rename(tmp_fullpathonftp, fullpathonftp)

            # archive file on local drive
            os.rename(tmp_full_fname, fullpatharchive)

            print filename
ftp.close()
