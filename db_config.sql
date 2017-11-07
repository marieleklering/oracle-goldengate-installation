create tablespace gg_tbs datafile '/u01/app/oracle/oradata/tpharma1/gg_tbs_data01.dbf' size 100m;
create user ggs identified by ggs default tablespace gg_tbs quota unlimited on gg_tbs;
grant CREATE SESSION, CONNECT, RESOURCE, ALTER ANY TABLE, ALTER SYSTEM, CREATE TABLE, DBA, LOCK ANY TABLE, SELECT ANY TRANSACTION, FLASHBACK ANY TABLE to ggs;
grant execute on utl_file to ggs;
execute dbms_goldengate_auth.grant_admin_privilege('ggs');
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE FORCE LOGGING;
alter system set enable_goldengate_replication=TRUE scope=both;
exit
