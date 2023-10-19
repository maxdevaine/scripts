#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# created: 2023/10
# license: GNU GPLv3
# description: Dump a Table from MariaDB Database and copy a dump File to a sftp server

# Variables
DB_USER=dbuser
DB_PASS=dbpassword
DB_SELECT=select.sql

SFTP_SERVER=sftp.server.tld
SFTP_PORT=22
SFTP_LOGIN=sftplogin
SFTP_PW=sftppassword

FILE=dbtable.csv
FILE_DIR=/tmp
MINBACKUPSIZE=120

# Check if file exists
if [ -f "${FILE_DIR}/${FILE}" ]; then
  # echo -e "The File exists, removing"  
   rm -f ${FILE_DIR}/${FILE}
fi

# Generate a new file
mysql -u ${DB_USER} -p${DB_PASS} seznam < "${DB_SELECT}";

# Check size of the dump to prevent transfer damaged file
BACKUPSIZE=`wc -c ${FILE_DIR}/${FILE} |awk '{print $1}'`

MINBACKUPSIZE=$((${MINBACKUPSIZE}*1024))
if [[ -z "${BACKUPSIZE}" ]] || (( ${BACKUPSIZE} < ${MINBACKUPSIZE} )); then
   echo Error ${BACKUPSIZE} vs ${MINBACKUPSIZE}, exiting script.
   exit 0;
fi

# Upload a new file to sftp
cd ${FILE_DIR}
lftp -p ${SFTP_PORT} sftp://${SFTP_LOGIN}:${SFTP_PW}@${SFTP_SERVER}  -e "put -e ${FILE}; bye"

# Clean the File
rm -f ${FILE_DIR}/${FILE}
