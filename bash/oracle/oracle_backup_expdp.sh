#!/bin/bash
# created: Max Devaine <maxdevaine@gmail.com>
# license: GNU GPLv3

# description
# remote backup OracleDB via data pump
# checking file size of backup and log file with notify to email about status OK or ERROR


Help()
{
   # Display Help
   BASEME=`basename "$0"`
   echo "Syntax: ${BASEME} [-s|-b|v|h]"
   echo "options:"
   echo "-s     Oracle SID"
   echo "-b     Min backup file size in MiB (check file size of backup)"
   echo "-v     expdp compatibility version with oracle: 18.1.0, 19.0.0"
   echo "-e     exclude table (in this version only one)"
   echo
   echo "example:"
   echo "${BASEME} -s db1 -b 150 -v 19.0.0 -e table"
   echo
}


while getopts ":h:s:b:v:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s) # Enter a Oracle SID
         DBSID=$OPTARG;;
      b) # Enter a minimum Backup File Size
         MINBACKUPSIZE=$OPTARG;;
      v) # Enter a database version / compatibility level
         DBVER=$OPTARG;;
      e) # Exclude table
         EXCL=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

echo $DBSID and $MINBACKUPSIZE and $DBVER

# base variable to change
RECIPIENT=recipient@domain.tld

# ORACLE env
ORACLEHOST=${DBSID}db.corp.domain.tld
DBUSER=backupuser
DBPASS=supepass
ORACLE_SID=$DBSID; export ORACLE_SID
export ORACLE_BASE=/u01/oracle
export ORACLE_HOME=/u01/oracle/product/21c/client
export PATH=${PATH}:${ORACLE_HOME}/bin:${ORACLE_HOME}/OPatch
PATH=.:${JAVA_HOME}/bin:${PATH}:$HOME/bin:$ORACLE_HOME/bin
PATH=${PATH}:/usr/bin:/bin:/usr/bin/X11:/usr/local/bin
export PATH

DDATE=`date '+%Y-%m-%d'`
BDATE=`date '+%Y-%m-%d-%H%M%S'`
EXPDIR=/mnt/oracle-backup/${DBSID}db/rw/exp
RODIR=/mnt/oracle-backup/${DBSID}db/ro/exp
UPPERSID=`echo $DBSID | tr '[:lower:]' '[:upper:]'`

BEGINTIME=`date +%Y-%m-%d-%H:%M:%S`
LOGPATH="/home/oracle/scripts/logs"
LOGFILE="${LOGPATH}/${DBSID}-expdp-${BDATE}-complete.log"
LOGTEMP="${LOGPATH}/tmp.log"
SEPARATOR="#################################################################################"

if [[ -z "$MINBACKUPSIZE" ]]; then
   MINBACKUPSIZE=200
fi

if [[ -z "$DBVER" ]]; then
   echo "Database version parameter missing, setting to default: COMPATIBLE"
   DBVER="COMPATIBLE"
fi

DBVERSTR="version=${DBVER}"


if [[ -z "$EXCL" ]]; then
     echo "No exclude tables, leaving without variable"
     EXCLSTR=""
  else
     EXCLSTR=exclude=table:\"IN\(\'${EXCL}\'\)\"
fi

# check rw backup dir
#if [ ! -d "$EXPDIR" ]; then
#  echo "Directory \"${EXPDIR}\" doesn't exist."
#  exit 1
#fi

# check ro backup dir
#if [ ! -d "$RODIR" ]; then
#  echo "Directory \"${RODIR}\" doesn't exist."
#  exit 1
#fi

echo -e "Start backup: $BEGINTIME\n${SEPARATOR}\n" >>$LOGFILE
{ time $ORACLE_HOME/bin/expdp ${DBUSER}/${DBPASS}@${ORACLEHOST}:1521/${DBSID} ${DBVERSTR} full=y ${EXCLSTR} directory=${UPPERSID}_RWDIR dumpfile=expdp-${DBSID}-${DDATE}.dmp logfile=expdp-${DBSID}-${DDATE}.log ;}  >>$LOGFILE  2>>$LOGFILE

# file size in to variable
#BACKUPSIZE=`wc -c ${EXPDIR}/expdp-${DBSID}-${DDATE}.dmp |awk '{print $1}' 2>&1 |tee -a $LOGFILE`
BACKUPSIZE=`wc -c ${EXPDIR}/expdp-${DBSID}-${DDATE}.dmp |awk '{print $1}'`

# move backup to read-only share
mv -nv ${EXPDIR}/* ${RODIR}/ > $LOGTEMP 2>>$LOGFILE
ENDTIME=`date +%Y-%m-%d-%H:%M:%S`
echo -e "${SEPARATOR}\nEnd backup: ${ENDTIME}" >> $LOGFILE

# check error log
if grep -iq ' error\|ora-\|cannot\|failed' $LOGFILE; then
   LOGSTATUS=logerr
  else
   LOGSTATUS=logok
fi

# check error log for complete
if grep -iq ' successfully completed ' $LOGFILE; then
   LOGCOMPLETESTATUS=logcompleteok
  else
   LOGCOMPLETESTATUS=logcompleteerr
fi

# check min backup file size
MINBACKUPSIZE=$(($MINBACKUPSIZE*1024))
if [[ -z "$BACKUPSIZE" ]] || (( $BACKUPSIZE < $MINBACKUPSIZE )); then
#   echo $BACKUPSIZE vs $MINBACKUPSIZE
   FSSTATUS=filesizeerr
  else
   FSSTATUS=filesizeok
fi


# send notification to email
STATUS="${FSSTATUS} + ${LOGSTATUS} + ${LOGCOMPLETESTATUS}"
BACKUPSIZEGB=$((${BACKUPSIZE}/1024/1024))
BODYSEPARATOR="------------------------------"

if [[ "${LOGSTATUS}" == "logerr" ]] || [[ "${FSSTATUS}" == "filesizeerr" ]] || [[ "${LOGCOMPLETESTATUS}" == "logcompleteerr" ]]; then
   echo -e "Oracle ${DBSID} backup ERROR\n${BODYSEPARATOR}\nStart: ${BEGINTIME}\nEnd: ${ENDTIME}\nBackup file: ${EXPDIR}/expdp-${DBSID}-${DDATE}.dmp\nBackup size: $BACKUPSIZE (${BACKUPSIZEGB} MiB)\nDatabase dump version:${DBVER}\nStatus: $STATUS" | mail -s "ERROR: Oracle ${DBSID} backup - ${BDATE}" -a $LOGFILE $RECIPIENT
 else
   echo -e "Oracle ${DBSID} backup OK\n${BODYSEPARATOR}\nStart: ${BEGINTIME}\nEnd: ${ENDTIME}\nBackup file: ${EXPDIR}/expdp-${DBSID}-${DDATE}.dmp\nBackup size: $BACKUPSIZE (${BACKUPSIZEGB} MiB)\nDatabase dump version:${DBVER}\nStatus: $STATUS" | mail -s "OK: Oracle ${DBSID} backup - ${BDATE}" -a $LOGFILE $RECIPIENT
fi

# archive log file
mv -v $LOGFILE ${LOGFILE}.old


#echo zipping >>$LOGFILE
#cd /u02/backup/backup_db/
#for file in `find *`; do
#  7za a $file.7z $file
#  rm $file
#done
#echo zipping complet >> $LOGFILE
