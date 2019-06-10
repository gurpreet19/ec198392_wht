WHENEVER SQLERROR EXIT SQL.SQLCODE;


CREATE OR REPLACE PACKAGE eckernel_grant_check AS

  PROCEDURE CheckGrantsgiven;
  
  
END;
/

CREATE OR REPLACE PACKAGE BODY eckernel_grant_check AS


  PROCEDURE CheckOneGrantsgiven(p_object     varchar2,
                                p_priviledge varchar2,
                                p_grantable  varchar2,
								p_priv_optional varchar2 DEFAULT NULL)
  IS

    CURSOR curGrant(p_object     varchar2,
                    p_priviledge varchar2,
                    p_grantable  varchar2,
					p_priv_optional varchar2) is
    select * from ALL_TAB_PRIVS 
    where grantee in (user,'PUBLIC') 
    and table_name = p_object
    and PRIVILEGE IN (p_priviledge,p_priv_optional)
    and grantable = nvl(p_grantable,grantable);

    ln_grant_found number;

  BEGIN

     ln_grant_found := 0;
       
     FOR c1 in curGrant(p_object,p_priviledge,p_grantable,p_priv_optional) LOOP
       ln_grant_found := 1;
     END LOOP;
    
     IF ln_grant_found = 0 THEN
       Raise_Application_Error (-20100, 'Missing '||p_priviledge||' ON '||p_object);
     end if;  
  END;



 
  PROCEDURE CheckGrantsgiven IS


  BEGIN

     CheckOneGrantsgiven('DBMS_SESSION','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_LOCK','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_JOB','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_LOB','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_METADATA','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_OBFUSCATION_TOOLKIT','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_OUTPUT','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_SQL','EXECUTE',NULL);
     CheckOneGrantsgiven('DBMS_XMLGEN','EXECUTE',NULL);
     CheckOneGrantsgiven('UTL_RAW','EXECUTE',NULL);
     CheckOneGrantsgiven('ALL_VIEWS','READ','YES','SELECT');
     CheckOneGrantsgiven('ALL_TAB_COLUMNS','READ','YES','SELECT');
	 CheckOneGrantsgiven('ALL_TABLES','READ','YES','SELECT');
     CheckOneGrantsgiven('ALL_OBJECTS','READ','YES','SELECT');
     CheckOneGrantsgiven('DUAL','READ','YES','SELECT');
     CheckOneGrantsgiven('OBJ$','READ',NULL,'SELECT');
     CheckOneGrantsgiven('DBA_PENDING_TRANSACTIONS','READ',NULL,'SELECT');
     CheckOneGrantsgiven('PENDING_TRANS$','READ',NULL,'SELECT');
     CheckOneGrantsgiven('DBA_2PC_PENDING','READ',NULL,'SELECT');
     CheckOneGrantsgiven('DBMS_XA','EXECUTE',NULL);

  END;

END;
/

exec eckernel_grant_check.CheckGrantsgiven;
 

drop package eckernel_grant_check;

WHENEVER SQLERROR CONTINUE;
