#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2022/06
# license: GNU GPLv3
# description: parse data from Linuxbox (based on webmin) status page
# Linuxbox is commercial SaS, home page: https://www.linuxbox.cz/

USERNAME=username
PASSWORD=password

COOKIEFILE=cjar
URL=https://linuxbox.corp.devaine.tld:10000
URLLOGIN=${URL}/lbox_session_login.cgi
CHECKLOGGED=`curl -s -k --cookie ${COOKIEFILE} ${URL}/lbox_sysinfo/ |grep "Přihlásit" |wc -l`

# login if we are not logged
if [ ${CHECKLOGGED} -ge 1 ]; then
# echo "Not logged, generating new session..."
 rm -f ${COOKIEFILE}
 curl -s -k --cookie-jar ${COOKIEFILE} --output /dev/null ${URL}
 curl -s -k --cookie ${COOKIEFILE} --cookie-jar ${COOKIEFILE} --data user=${USERNAME} --data pass=${PASSWORD} --location --output /dev/null ${URLLOGIN}
fi

# load body of pages in to variables
GETSYSPAGE=$(curl -s -k --cookie ${COOKIEFILE} ${URL}/lbox_sysinfo/)
GETMAILPAGE=$(curl -s -k --cookie ${COOKIEFILE} ${URL}/lbox_sendmail/)

# parse pages from variables
LOAD5MIN=`echo ${GETSYSPAGE} |tr -s "<tr>" "\n" |grep 5min -A7 |tail -1`
DISKROOT=`echo ${GETSYSPAGE} |sed 's/oddRow/\n&/g' |sed 's/evenRow/\n&/g' |grep "/dev/mapper/vg-root" | awk '{print $7,$10,$12,$14}' |tr -d '">'`
DISKHOME=`echo ${GETSYSPAGE} |sed 's/oddRow/\n&/g' |sed 's/evenRow/\n&/g' |grep "/dev/mapper/vg-home" | awk '{print $7,$10,$12,$14}' |tr -d '">'`
DISKVAR=`echo ${GETSYSPAGE} |sed 's/oddRow/\n&/g' |sed 's/evenRow/\n&/g' |grep "/dev/mapper/vg-var" | awk '{print $7,$10,$12,$14}' |tr -d '">'`
DISKTMP=`echo ${GETSYSPAGE} |sed 's/oddRow/\n&/g' |sed 's/evenRow/\n&/g' |grep "/dev/mapper/vg-tmp" | awk '{print $7,$10,$12,$14}' |tr -d '">'`
MAILQUEU=`echo ${GETMAILPAGE} |tr -s "<" "\n" |grep zpráv| sed 's/[^0-9]*//g'`

# print parsed information
echo -e "Load last 5min: ${LOAD5MIN}"
echo -e "Mail in queue: ${MAILQUEU}"
echo -e "/root: ${DISKROOT}"
echo -e "/home: ${DISKHOME}"
echo -e "/var: ${DISKVAR}"
echo -e "/tmp: ${DISKTMP}"
