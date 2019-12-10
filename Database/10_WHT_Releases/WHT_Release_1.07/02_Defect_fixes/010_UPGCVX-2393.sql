insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE) values 
('FCST_STOR_LIFT_NOM_INFO',	'START_LIFTING_DATE'	,'DISABLED_IND',	2500	,'/'	,'VIEWLAYER','N');
insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE) values 
('FCST_STOR_LIFT_NOM_INFO',	'START_LIFTING_DATE'	,'LABEL',	2500	,'/EC'	,'APPLICATION','Loading Start Time');
Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'FCST_STOR_LIFT_NOM_INFO');
commit;

execute ecdp_viewlayer.buildviewlayer('FCST_STOR_LIFT_NOM_INFO', p_force => 'Y');
execute ecdp_viewlayer.buildreportlayer('FCST_STOR_LIFT_NOM_INFO', p_force => 'Y');