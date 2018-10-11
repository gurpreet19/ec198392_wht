---running force buildviewlayer on all objects
update VIEWLAYER_DIRTY_LOG set dirty_ind='Y';
commit;

execute ecdp_viewlayer.buildviewlayer(p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer(p_force => 'Y'); 
---refresh materialized views
execute ecdp_classmeta.RefreshMViews(p_force => 'Y');
--EXECUTE ec_generate.Synchronise;
 
---t_temptext trunctate
DELETE FROM t_temptext WHERE id LIKE 'INVALIDOBJECTS%';
 
execute dbms_utility.compile_schema(user,false);