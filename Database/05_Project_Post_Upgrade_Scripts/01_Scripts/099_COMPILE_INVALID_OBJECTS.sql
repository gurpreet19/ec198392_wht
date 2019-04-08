---running build view and report layer
exec ecdp_viewlayer.buildviewlayer(p_force => 'Y'); 
exec ecdp_viewlayer.buildreportlayer(p_force => 'Y'); 
---refresh materialized views
EXECUTE ECDP_SYNCHRONISE.Synchronise;
commit;
 
execute dbms_utility.compile_schema(user,false);