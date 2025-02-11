#!/bin/bash
# created: Max Devaine <maxdevaine@gmail.com>
# license: GNU GPLv3

# description
# restore OracleDB from rman backup to testing environment
# fully automatated

################ general ###################
ORA_OWNER=oracle
#source ". /home/oracle/.bash_profile"
ORACLE_SID=TORCLDB
ORACLE_UNQNAME=TORCLDB_PRIMARY
set_grid_env=". /home/oracle/grid_env"
set_db_env=". /home/oracle/db_env"


############### passwords ##################
export_pw_script=@/home/oracle/export_users_pw.sql;
import_pw_script=@/home/oracle/users_pw_for_import.sql;

################ logging ###################
MAILADR=devaine@domain.tld
SCRIPT_LOG_DIR=/var/log/oracl-mgmt
REFRESH_LOG_FILE=oracle-db-refresh.log

################ backups ###################
BACKUP_DIR=/mnt/oracle-backup/backup/
LAST_BACKUP=`find $BACKUP_DIR -type f -iname "*.bkp" -printf "%h\n" |sort -u |tail -1`


stop_db() {
echo "########## Stop db ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
shutdown immediate;
EOS
EOO
}


start_nomount_db() {
echo "########## start db nomount ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
startup nomount;
EOS
EOO
}


start_db() {
echo "########## Start db ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
startup;
EOS
EOO
}


clear_archive_logs() {
echo "########## Clear transaction files and set nolog db ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
startup mount;
ALTER DATABASE NOARCHIVELOG;
ALTER DATABASE OPEN;
EOS
EOO

su - "$ORA_OWNER" <<EOO
$set_db_env
rman target / <<EOS
crosscheck archivelog all;
delete noprompt archivelog all;
EOS
EOO
}


delete_datafiles() {
echo "########## delete datafiles ##########"
su - "$ORA_OWNER" <<EOO
$set_grid_env
asmcmd <<EOS
rm -f DATADG/${ORACLE_UNQNAME}/DATAFILE/*
EOS
EOO
}


import_db_backup() {
echo "########## import last database backup ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
rman auxiliary / <<EOS
DUPLICATE DATABASE TO $ORACLE_SID BACKUP LOCATION '${LAST_BACKUP}' NOFILENAMECHECK;
EOS
EOO
}


export_users_pw() {
echo "########## export users pw ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
$export_pw_script
EOS
EOO
}

import_users_pw() {
echo "########## export users pw ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
$import_pw_script
EOS
EOO
}


after_import_sql() {
echo "########## change user pw ##########"
su - "$ORA_OWNER" <<EOO
$set_db_env
sqlplus /nolog <<EOS
connect / as sysdba
CREATE USER AUTOMATIC_TEST IDENTIFIED BY "blankpw";
GRANT CONNECT TO AUTOMATIC_TEST;
GRANT DBA TO AUTOMATIC_TEST;
EOS
EOO
}


firewall_add_drop_rule() {
  # to prevent lock all users with wrong password
  iptables -I INPUT 2 -p tcp -m state --state NEW -m tcp --dport 1521 -j DROP
}

firewall_resore_rules() {
  iptables -D INPUT 2
}



case "$1" in
    stop_database)
        stop_db
        ;;

    start_database_nomount)
        start_nomount_db
        ;;

    start_database)
        start_db
        ;;

    delete_asm_datafiles)
        delete_datafiles
        ;;

    import_database_backup)
        import_db_backup
        ;;

    clear_transaction_files)
        stop_db
        clear_archive_logs
        ;;

    export_users_passwords)
        export_users_pw
        ;;

    import_users_passwords)
        import_users_pw
        ;;

    auto-refresh)
        export_users_pw
        stop_db
        delete_datafiles
        firewall_add_drop_rule
        start_nomount_db
        import_db_backup
        stop_db
        clear_archive_logs
        after_import_sql
        import_users_pw
        firewall_resore_rules
        ;;


*)
        echo "Usage: $0 {auto-refresh|stop_database|start_database_nomount|start_database|delete_asm_datafiles|import_database_backup|clear_transaction_files|export_users_passwords|import_users_passwords}"
        ;;
esac
