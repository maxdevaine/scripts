#!/bin/sh
# author Max Devaine <maxdevaine@gmail.com>
# created: 101/2009
# License: GNU GPLv3

# base settings / variables
USER="ftpuser@192.168.1.1"
PASS="password*123"

SERVERPROXY=192.168.100.1
SERVER=192.168.200.1

LOCALDIR=/home/proftpd/EDI
LOGFILE=/home/proftpd/EDI/logfile.log
LOGFILE2=/home/proftpd/EDI/logfile.log

# check if edi files exist
cd $LOCALDIR
#if [ $(find . -maxdepth 1 -type f -name "*.[tT][xX][tT]" | wc -l) == 0 ]; then 
#if [ $(find . -maxdepth 1 -type f -name "*.FF1" | wc -l) == 0 ]; then 
if [ $(find . -maxdepth 1 -type f -name "*.[xX][mM][lL]" | wc -l) == 0 ]; then 
    echo "No EDI files found"
    exit 1
  else
    echo -e "EDI files exists"
fi


#######################################################################
# rename all files for transfer
# update: not needed anymore
#cd $LOCALDIR
#for i in  *.txt;
#   do mv $i ${i%txt}bak 2>/dev/null;
#done
#
#
# create command to revert name :
#for i in *.bak; do
#  newfile=`echo "$i" | sed 's/\.bak/\.txt/'`
#  rename=`echo -e "rename $i $newfile\n$rename"`
#done
#
#
#ftp -inv $SERVER << EOFtp >${LOGFILE} 2>&1
#user $USER $PASS
#mput *.bak
#$rename
#bye
#EOFtp
#######################################################################

# create list of xml files
# for pom in *.XML; do
#  rmfilelist=`echo -e "rm $pom\n$filelist"`
#  filelist=`echo -e "put $pom\n$filelist"`
#done

#pom=`ls *.XML -t | tail -n1`
pom=`ls *.[xX][mM][lL] -t | tail -n1`
rmfilelist=`echo -e "rm $pom\n"`
filelist=`echo -e "put $pom\n"`

# Check if is ftp server alive (port 2100),
# (if not, immediate stop next step)
if nc -zv -w30 $SERVERPROXY 2100 <<< ” &> /dev/null
   then
     echo 'Port is open'
   else
     echo 'Port is closed'
     exit 1
fi


sleep 2

# copy files to ftp :
ftp -inv $SERVERPROXY << EOFtp >${LOGFILE} 2>&1
user $USER $PASS
$filelist
bye
EOFtp


# Error handlig (with awk) and log :

awk 'BEGIN{
ftperr[202]="Command not implemented" 
ftperr[421]="Service not available,closing control connection"
ftperr[426]="Connection closed, transfer aborted"
ftperr[450]="File unavailable(e.g. file busy)"
ftperr[451]="Requested action aborted, local error in processing"
ftperr[452]="Requested action not taken. Insufficient storage space in system"
ftperr[500]="Syntax error, command unrecognized"
ftperr[501]="Syntax error in parameters or arguments"
ftperr[502]="Command not implemented"
ftperr[503]="Bad sequence of commands"
ftperr[504]="Command not implemented for that parameter"
ftperr[530]="User not logged in. Check username and password"
ftperr[550]="Requested action not taken. File unavailable" 
ftperr[552]="Requested file action aborted, storage allocation exceeded"
ftperr[553]="Requested action not taken. Illegal file name"
ftperr[999]="Invalid Command"
ftperr[777]="Unknown host"
ftperr[666]="A file or directory not exist"
#ftperr[226]="Transfer Complete"
ecode="000"
FOUND="F"
}
{
for ( i in ftperr)
{
if ( i == $1 )
{
ecode=$1
FOUND="T"
}
else if ( $0 ~ /Invalid/ )
{
ecode="999"
FOUND="T"
}
else if ( $0 ~ /Unknown host/ || $0 ~ /Not connected/ )
{
ecode="777"
FOUND="T"
}
else if ( $0 ~ /not exist/ || $0 ~ /No such/ )
{
ecode="666"
FOUND="T"
}
if ( FOUND == "T" )
{
exit;
}
}
}
END {
if ( ecode == "000" ) 
{
print ecode ":FTP Successfully done"
}
else
{
print ecode ":"ftperr[ecode];
system("echo > error-echo.log")
}
}' ${LOGFILE}

# write log in to file :
echo "------------$(date +%Y-%m-%d-%H%M%S)--------------" >> /var/log/ftp_copy/ftp_copy-$(date +%Y-%m).log
cat $LOGFILE >> /var/log/ftp_copy/ftp_copy-$(date +%Y-%m).log

# create body email in variable
LOGERROR=`cat $LOGFILE | sed 's/^/\r\n/'`

# if error happend copy xml file + temporary log and send email to admin
if [ -e error-echo.log ]; then {
    echo "sent mail"
rm error-echo.log
#tar --exclude archiv -cvf error-XML-$(date +%Y-%m-%d-%H%M%S).tar *
cp logfile.log false-copy/logfile-$(date +%Y-%m-%d-%H%M%S).log
echo $LOGERROR | mail -s "FTP - XML Error Transfer" admin@domain.tld
#cp -a *.XML false-copy/
cp -a $pom false-copy/
}
else
echo "All ok, archiving xml files"
#tar -cvf archiv/archiv-XML-$(date +%Y-%m-%d-%H%M%S).tar *.XML
#cp -a *.XML archiv/
mkdir -p archiv/$(date +%Y-%m) > /dev/null
cp -a $pom archiv/$(date +%Y-%m)/
$rmfilelist 2>/dev/null
fi

# remove temporary log
rm $LOGFILE 2>/dev/null
