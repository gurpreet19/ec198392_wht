--UPGCVX-2319
update prosty_codes set SORT_ORDER=700 where code_type='TZ_NAME' and code='Australia/Perth';

--UPGCVX-2401
update class_attribute_cnfg set DB_SQL_SYNTAX='EcBp_Deferment.getparenteventlossrate(event_no, ''GAS'', object_id)' where class_name ='CT_LPO_OFF_EVENT_DAY' and attribute_name ='GAS_EVENT_LOSS';
commit;

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'CT_LPO_OFF_EVENT_DAY');
commit;

execute ecdp_viewlayer.buildviewlayer('CT_LPO_OFF_EVENT_DAY', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('CT_LPO_OFF_EVENT_DAY', p_force => 'Y'); 

commit;