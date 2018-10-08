---refresh materialized views
execute ecdp_classmeta.RefreshMViews(p_force => 'Y');
--EXECUTE ec_generate.Synchronise;
 
---t_temptext trunctate
DELETE FROM t_temptext WHERE id LIKE 'INVALIDOBJECTS%';
 
execute dbms_utility.compile_schema(user,false);