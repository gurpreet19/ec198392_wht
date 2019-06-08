---running build view and report layer
exec ecdp_viewlayer.buildviewlayer(p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer(p_force => 'Y'); 
---refresh materialized views
--execute ecdp_classmeta.RefreshMViews(p_force => 'Y');
EXECUTE ECDP_SYNCHRONISE.Synchronise;
commit;
 
execute dbms_utility.compile_schema(user,false);

GRANT EXECUTE ON ECDB_BUILDUTILS_ASUSER TO REPORT_ROLE_&operation;

---refresh ACL---
execute ecdp_acl.refreshall();