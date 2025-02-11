set colsep ,
set headsep off
set pagesize 0
set trimspool on
set linesize 20000
set numwidth 5
set feedback off

spool users_pw_for_import.sql

SELECT
    'ALTER USER ' || U.USERNAME ||
    ' IDENTIFIED BY VALUES ''' || SU.SPARE4 ||
    ''' DEFAULT TABLESPACE ' || U.DEFAULT_TABLESPACE || ';' AS QUERY_2
FROM DBA_USERS U
INNER JOIN SYS.USER$ SU ON SU.NAME = U.USERNAME
WHERE 
U.ACCOUNT_STATUS <> 'LOCKED'  AND U.AUTHENTICATION_TYPE = 'PASSWORD'  AND U.ORACLE_MAINTAINED = 'N' AND SU.SPARE4 is not null;

spool off
