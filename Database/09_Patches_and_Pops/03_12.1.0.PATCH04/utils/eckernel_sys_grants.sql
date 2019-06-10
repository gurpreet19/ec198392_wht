-- The following grants need to be given from sys to the ECKERNEL User
-- Note that there in Oracle 12.2 is 578 DBMS packages, a few hundred of these are granted by default to PUBLIC
-- This list will also include some of these that we know that customers can have revoked from public.


define db_eckernel_user='&1'

create or replace procedure CondExplPackageGrant(
   p_packagename varchar2, 
   p_username varchar2,
   p_privilege varchar2)  is
/*  This function is used to provide necessary grants to ECKERNEL user:
     -  if there is a grant execute on the given package to PUBLIC, in that case this function will do nothing.
     -  if not, it will grant execute on the package with grant option to the ECKERNEL user, assuming the user
        running this script has the necessary grant privilegies, otherwise this script will fail
*/

cursor c_publicgrant is
SELECT 1, grantee
  FROM DBA_TAB_PRIVS
 WHERE owner = 'SYS'
   AND grantee = ('PUBLIC')
   AND GRANTABLE = 'YES'
   AND table_name = p_packagename
order by 1   ;

  lb_grantok boolean := False;
  lv2_grant varchar2(500);

begin

  FOR curGrant in c_publicgrant LOOP

       lb_grantok := True;
       EXIT;

  END LOOP;

  IF not lb_grantok THEN
 
       -- don't know if user have grantable privilegie, but if not this will fail, and hard failure is ok here.

       lv2_grant := 'GRANT '||p_privilege||' ON '||p_packagename||' TO '||p_username||' with grant option';
       EXECUTE IMMEDIATE lv2_grant;
       lb_grantok := True;
 
   --  Raise_Application_Error (-20100, 'Required grant for '||p_packagename||' can not be given since this user dont have the grantable priviliedge for this package.');
  end if;


end;
/


--Commented as session,user and role privs not needed for ECKERNEL user

-- GRANT CREATE session to &db_eckernel_user with admin option; 
-- GRANT CREATE USER to  &db_eckernel_user with admin option; 
-- GRANT CREATE ROLE to  &db_eckernel_user; 

GRANT CREATE TABLE to  &db_eckernel_user ;
GRANT CREATE VIEW to  &db_eckernel_user ;
GRANT CREATE PROCEDURE to  &db_eckernel_user ;
GRANT CREATE SEQUENCE to  &db_eckernel_user ;
GRANT CREATE TRIGGER to  &db_eckernel_user ;
GRANT CREATE SYNONYM to  &db_eckernel_user ;
GRANT CREATE TYPE to  &db_eckernel_user ;
GRANT CREATE JOB to  &db_eckernel_user ;
GRANT CREATE MATERIALIZED VIEW to  &db_eckernel_user ;

exec CondExplPackageGrant('DBMS_SESSION',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_LOCK',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_JOB',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_LOB',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_METADATA',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_OBFUSCATION_TOOLKIT',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_OUTPUT',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_SQL',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBMS_XMLGEN',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('UTL_RAW',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('DBA_PENDING_TRANSACTIONS',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('PENDING_TRANS$',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('DBA_2PC_PENDING',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('DBMS_XA',  '&db_eckernel_user','EXECUTE');
exec CondExplPackageGrant('ALL_VIEWS',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('ALL_TAB_COLUMNS',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('ALL_TABLES',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('ALL_OBJECTS',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('DUAL',  '&db_eckernel_user','READ');
exec CondExplPackageGrant('OBJ$',  '&db_eckernel_user','READ');


drop procedure CondExplPackageGrant; 

exit;
