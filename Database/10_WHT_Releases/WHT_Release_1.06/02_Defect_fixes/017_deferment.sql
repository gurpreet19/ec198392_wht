insert into class_attr_property_cnfg (CLASS_NAME, ATTRIBUTE_NAME, PROPERTY_CODE, OWNER_CNTX, PRESENTATION_CNTX, PROPERTY_TYPE, PROPERTY_VALUE)
values ('WELL_DEFERMENT',	'REASON_CODE_3',	'IS_MANDATORY',	2500	,'/',	'VIEWLAYER',	'N');

Update viewlayer_dirty_log set dirty_ind = 'Y' where object_name IN( 'CT_LPO_OFF_EVENT_DAY');
commit;

execute ecdp_viewlayer.buildviewlayer('CT_LPO_OFF_EVENT_DAY', p_force => 'Y'); 
execute ecdp_viewlayer.buildreportlayer('CT_LPO_OFF_EVENT_DAY', p_force => 'Y'); 
