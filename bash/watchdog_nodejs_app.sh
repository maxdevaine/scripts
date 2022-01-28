#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2020/05
# license: GNU GPLv3

# description
# this program is watchdog for nodejs app
# response code 200 = all ok
# another else than 200 = do restart nodejs, log to file and send email message


SERVERLIST=("127.0.0.1:5000" "127.0.0.1:5001" "127.0.0.1:5002" "127.0.0.1:5003")
CHECKURL="curl -k --connect-timeout 15 --write-out '%{http_code}' --silent --output /dev/null"
LOGDIR="/home/nodeapps/bin/logs"
LOGFILE="watchdog_nodejs_app.log"
date=$(date '+%Y-%m-%d %H:%M:%S')
CHECKCODE="'200'"
CONTACT="devaine@domain.tld"

if [ ! -d $LOGDIR ]; then
   mkdir $LOGDIR
fi

for testval in ${SERVERLIST[*]}; do
    RESPONSE=`${CHECKURL} https://${testval}/auth/login/`
    if [ ! ${RESPONSE} == ${CHECKCODE} ]; then
      # if is not ok, then write message about this and restart NodeJS
      echo "${date} - Response code: ""${RESPONSE}"" is different from ""${CHECKCODE}"", restarting NodeJS" >> ${LOGDIR}/${LOGFILE}
      echo -e "Apps was restarted\n see logs in: ${LOGDIR}/${LOGFILE}" | mail -s "Nodejs Restarted" ${CONTACT}
      pm2 restart app-api
      sleep 4
    else
     echo All Ok
   fi
done
